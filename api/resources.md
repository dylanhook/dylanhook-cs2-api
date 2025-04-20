# Assets and files

Use `assets` to read files shipped with your script. Use `fs` to keep the script's saved data between loads.

## Folders

For a script named `example.lua`, the usual layout is:

```text
%LOCALAPPDATA%\dylanhook\
  lua\
    scripts\
      example.lua
      example.assets\
        layout.json
    data\
      <private script data>
```

`assets` reads from `<current script name>.assets` beside the Lua file.
`fs` uses that script's private folder under
`%LOCALAPPDATA%\dylanhook\lua\data`. Pass only a filename to `fs`.
Dylanhook selects the script's data folder automatically.

## Filenames

Pass one filename, such as `preferences.json`, with at most 96 UTF-8 bytes. An empty name is invalid. Numbers are converted to text.

Names cannot contain `/`, `\`, `:`, `*`, `?`, double quotes, `<`, `>`, `|`, or ASCII control bytes 0-31 and 127. Leading or trailing spaces, a trailing dot, `.` and `..`, and a `.tmp` suffix are refused. The suffix check ignores case.

Windows device names are also refused, including `con`, `prn`, `aux`, `nul`, `com1`-`com9`, and `lpt1`-`lpt9`, even with an extension. The device-number check also covers superscript `¹`, `²`, and `³`.

The script's resource folder and the requested file must be regular paths, not symlinks or junctions. Paths are relative to the folders above.

## Availability and limits

Reads and existence checks are available during setup and render-side callbacks:
paint, above-menu paint, menu actions, control changes, timers, HTTP completions,
ESP values, session changes, shot callbacks and unload. Writes and removal use
the same callbacks but are unavailable during setup. Command, frame-stage and
game-event callbacks cannot use file functions.

| Resource | Limit |
| --- | --- |
| Filename | See [filenames](#filenames). |
| Private file | Up to the 8 MiB private-storage budget. |
| Private storage | 8 MiB total. |
| Private file count | 64 leaf files. |
| Asset read | Up to 4 MiB per call. Larger files can be read in ranges. |
| Each file operation | 64 native work units, plus 1 per started 64 KiB read or written. A read is charged for its bytes once they are known. |

Each operation uses the current [native-work allowance](../limits.md). Failed
operations count too. Reads return bytes as a Lua string, including NUL bytes.
Use [`json`](std.md#json) for structured data.

Private-storage limits are checked when writing or listing files. Replacing a file counts its replacement size toward the total. Subdirectories in the private data folder prevent writes and listings.

## assets.read

```text
assets.read(name: string | number) -> string | nil
assets.read(name: string | number, offset: integer | string, length: integer) -> string | nil
```

Reads the complete file from the script's asset folder. Returns its contents, including an empty string for an empty file, or `nil` on an operational failure.

Supply `offset` and `length` to read a range from a larger file. Offsets are
zero-based. Both values must be nonnegative whole numbers. Offsets beyond Lua's
exact numeric range use decimal strings. A range may request up to 4 MiB.

The result can be shorter at the end of the file. Reading exactly at EOF returns
an empty string. An offset past EOF returns `nil` with `file_range_invalid` in
`why.last()`. Each call reads the file as it exists at that time. Separate range
reads do not lock it against external edits.

```lua
local contents = assets.read("layout.json")
if contents ~= nil then
    local layout = json.decode(contents)
    console.log("loaded layout: " .. tostring(layout.name))
else
    console.warn("layout read failed: " .. (why.last() or "no reason recorded"))
end
```

## assets.exists

```text
assets.exists(name: string | number) -> boolean | nil
```

Returns `true` for a file, `false` when the file or asset folder is absent or the requested name is a directory, and `nil` when the check fails. This checks existence, not whether a later read will fit the asset-size limit.

## fs.read

```text
fs.read(name: string | number) -> string | nil
fs.read(name: string | number, offset: integer | string, length: integer) -> string | nil
```

Reads the complete private file. Returns its contents, or `nil` if the file is missing, too large, or cannot be read. An empty file returns `""`.

The optional range follows `assets.read`, with up to 8 MiB per call. For example,
`fs.read('samples.bin', 128, 64)` reads up to 64 bytes after the first 128 bytes.

```lua
local contents = fs.read("preferences.json")
if contents ~= nil then
    local ok, preferences = pcall(json.decode, contents)
    if ok then
        console.log("preferences loaded")
    else
        console.warn("invalid preferences: " .. tostring(preferences))
    end
end
```

## fs.list

```text
fs.list() -> string[] | nil
```

Lists this script's private files as a sorted, `1`-indexed array of filenames.
The result is empty when the data folder is absent or empty. Private temporary
companions are excluded, but still count toward storage limits.

Available wherever `fs.read` is available. Returns `nil` if enumeration fails,
storage exceeds its limits, or an entry is a directory, reparse point, or invalid
filename. Use `why.last()` for the reason. No physical paths are returned.

```lua
local names = fs.list()
if names then
    for _, name in ipairs(names) do
        console.log(name)
    end
end
```

## fs.write

```text
fs.write(name: string | number, data: string | number) -> true | nil
```

Creates or replaces the whole private file. Creates the private data folder when needed. Returns `true` when the write completes, or `nil` on an operational failure. An empty string creates an empty file.

The contents are written and flushed to a temporary companion file before replacing the destination. The `.tmp` suffix is reserved for that operation.

```lua
local preferences = {compact = true, scale = 1}

timer.after(0, function()
    local contents = json.encode(preferences)
    if fs.write("preferences.json", contents) == nil then
        console.warn("save failed: " .. (why.last() or "no reason recorded"))
    end
end)
```

## fs.exists

```text
fs.exists(name: string | number) -> boolean | nil
```

Returns `true` for a private file, `false` when the file or data folder is absent or the requested name is a directory, and `nil` when the check fails. `false` does not record a new failure reason.

## fs.remove

```text
fs.remove(name: string | number) -> true | nil
```

Removes one private file. Returns `true` after removal, or `nil` if the file is missing or cannot be removed.

```lua
timer.after(0, function()
    local present = fs.exists("draft.json")
    if present == true then
        if fs.remove("draft.json") == nil then
            console.warn("remove failed: " .. (why.last() or "no reason recorded"))
        end
    elseif present == nil then
        console.warn("file check failed: " .. (why.last() or "no reason recorded"))
    end
end)
```

## Failures

Each file function returns exactly one value. An operational failure returns `nil` and records a string in [`why.last()`](why.md#whylast), such as `file_not_found (detail 2)`. Read the reason immediately after the failed call. Successful calls and an existence result of `false` leave the previous reason unchanged.

| Reason | Meaning |
| --- | --- |
| `unavailable` | The script's resource folder is unavailable. |
| `path_refused` | The folder or file could not be accepted, including a symlink or junction. |
| `file_not_found` | The requested file or resource folder is missing. |
| `file_too_large` | The file or proposed contents exceed the per-file limit. |
| `file_read_failed` | A file, its attributes, or the storage listing could not be read. |
| `directory_create_failed` | The private data directory could not be created. |
| `storage_entry_limit` | The private folder exceeds its file-count limit, or the write would exceed it. |
| `storage_byte_limit` | The private folder exceeds its byte limit, or the write would exceed it. |
| `storage_shape_invalid` | A directory occupies a file path or exists inside the private data folder. |
| `storage_changed` | The file size changed while storage use was being checked. |
| `atomic_write_failed` | Writing, flushing, or replacing the destination failed. |
| `file_remove_failed` | Removal failed. |

Bad argument types, invalid filenames, the wrong callback, exhausted enforced work allowances, and Lua allocation failures raise errors. Those errors do not set `why.last()`.
