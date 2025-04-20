# Configs

Read and manage the same saved configs as the native menu. Typed script values
can join those configs without creating menu controls. Use `fs` for private
files that should stay independent of the selected config.

## config.list

```text
config.list() -> string[] | nil, string | nil
```

Returns the sorted saved config names, or `nil, reason` if the directory cannot
be read. Available during setup and render-side callbacks. Costs 32 native
work units.

The native config directory supports 1,024 entries and total stored bytes up
to four maximum-size config files. Unfinished saves and other regular files in
that directory count toward storage. An over-limit collection is refused
whole with `"config_entry_limit"` or `"config_byte_limit"`. Deletion remains
available so an oversized directory can be reduced.

## config.active

```text
config.active() -> string | nil
```

The last successfully saved or loaded name in this session, or `nil`. A reset
or deletion of that config clears it. Rename updates it. Import does not select
a saved name. Available during setup and render-side callbacks. Costs one unit.

## config.save

```text
config.save(name: string) -> config_operation | nil, string | nil
```

Queues a save of the current native settings and script values. Replaces an
existing config with the same name. Names contain 1-64 UTF-8 bytes and must be
valid single filenames. The operation result reports invalid names and I/O
failures. The config becomes active only after a successful save.
Requires **allow unsafe scripts**; without it the call raises an error.

Replacing a config accounts for its existing size. A storage-limit refusal
leaves the saved config unchanged. A detected concurrent file change reports
`"config_storage_changed"`; retry after the external edit finishes.

## config.load

```text
config.load(name: string) -> config_operation | nil, string | nil
```

Queues a normal config load, including its saved script selection. It can
replace or unload the calling script. A refused config or script candidate
leaves the current settings and scripts unchanged. Missing fields use their
declaration defaults.

Script-initiated loads cannot grant unsafe permission. A standard caller loads
standard scripts. An unsafe caller can retain unsafe permission only while
**allow unsafe scripts** is enabled.

## config.delete

```text
config.delete(name: string) -> config_operation | nil, string | nil
```

Queues removal of a saved config. Does not reset the current settings. An
absent file produces a failed result with `"not_found"`.
Requires **allow unsafe scripts**; without it the call raises an error.

## config.rename

```text
config.rename(name: string, new_name: string) -> config_operation | nil, string | nil
```

Queues a rename. Refuses to replace an existing destination with
`"already_exists"`. Both names follow the same rules as `config.save`.
Requires **allow unsafe scripts**; without it the call raises an error.

## config.reset

```text
config.reset() -> config_operation | nil, string | nil
```

Queues the native reset-to-defaults operation, including script profile cleanup.
This can unload the calling script. Saved config files remain on disk.

## config.export

```text
config.export() -> string | nil, string | nil
```

Returns the current config in the native share format, or `nil, reason`.
Available from active render-side callbacks. Costs 64 units. It does not access
the clipboard.

Native bytes awaiting transfer share one maximum config-share allowance across
all callers. Reentrant exports that exceed it return
`nil, "config_export_capacity"`. The allowance is released after each result
has been copied to Lua, including failed Lua transfers.

## config.import

```text
config.import(data: string) -> config_operation | nil, string | nil
```

Queues a native config share import. Uses the same validation and script
replacement as a normal config load. Malformed input produces a failed result
without partially applying settings.
Requires **allow unsafe scripts**; without it the call raises an error.

## Queued operations

Save, load, delete, rename, reset and import are available from active callbacks.
They run in request order on the render thread after the callback finishes.
Each costs 64 units. Import additionally costs one unit per 256 input bytes,
rounded up. Unsafe mode measures these costs without enforcing a work ceiling.

A returned handle means the request was accepted, not that it succeeded. Queue
refusal returns `nil, reason`. Requests share the 128-entry lifecycle queue.
Each script can retain 128 operation results. Releasing a handle frees its
result after completion and does not cancel accepted work. A request is
cancelled if its originating script was replaced or unloaded before execution.

Import data uses the native config share size bound. The queued batch shares
one such payload allowance. A full queue, full retained-result slots or full
payload allowance returns `"queue_full"`, `"config_result_limit"` or
`"config_queue_payload_limit"` respectively.

## config_operation.id

```text
config_operation.id: string
```

The exact operation ID as a decimal string. IDs are session-local and are not
array indexes.

## config_operation:result

```text
config_operation:result() -> config_result | nil
```

A copied completion, or `nil` while queued. Costs one unit. Raises
`"config_operation_expired"` after the handle is released.

```text
config_result: table
config_result.id: string
config_result.operation: string
config_result.status: string
config_result.error: string | nil
config_result.name: string | nil
config_result.next_name: string | nil
```

`status` is `"succeeded"`, `"failed"` or `"cancelled"`. `error` contains the
native failure reason when unsuccessful. `name` and `next_name` appear for
named operations. Completion is recorded after the full transaction finishes.

## config_operation:release

```text
config_operation:release() -> boolean
```

Drops interest in the result. Returns `true` once and `false` afterward.
Garbage collection does the same. Accepted work still runs.

## config.last_result

```text
config.last_result() -> config_result | nil
```

The most recent completed native config operation, including operations from
the menu or another script. Available during setup and render-side callbacks.
Costs one unit. `operation` is `"save"`, `"load"`, `"delete"`, `"rename"`,
`"reset"`, `"export"`, `"import"`, `"export_clipboard"` or `"import_clipboard"`.

Match `id` before treating this as your completion. A replacement script can
match it against `script.info().config_operation_id`. During replacement setup
the initiating operation is still pending, so `last_result()` can describe an
earlier operation. The result handle is preferable when the calling script
remains loaded.

```lua
local saving
menu.lua.a:button('save current config', function()
    saving = assert(config.save('my config'))
end)

on.paint(function()
    if not saving then return end
    local result = saving:result()
    if not result then return end
    console.log(result.status)
    saving:release()
    saving = nil
end)
```

## config.value

```text
config.value(id: string, type: string, default: boolean | number | string | color) -> config_value
```

Declares a value during setup. IDs are local to the script and contain 1-256
bytes. Invalid config keys raise. Repeating the same declaration reuses its
value. Changing its type or default, or colliding with a control's saved field,
raises instead of creating another value under the same key.

| Type | Value |
| --- | --- |
| `boolean` | A strict boolean. |
| `number` | A finite native 32-bit floating-point number. |
| `integer` | A whole number from -2,147,483,648 to 2,147,483,647. |
| `bitmask` | An exact unsigned 64-bit decimal string. Writes also accept exact nonnegative numbers up to 2^53−1. |
| `string` | Up to 4,096 bytes, including binary data. |
| `color` | A color value. |

Values share the existing 1,024 retained script-field slots with menu controls.
Unloading leaves the stored field available for a later load. Declarations cost
8 native work units, plus one per 256 string bytes, rounded up.

## config_value.value

```text
config_value.value: boolean | number | string | color
```

Reads or writes the saved base value. Setup writes remain staged until the load
succeeds. A failed load leaves the current value unchanged. After loading, writes
require a render-side callback. The next normal config save persists them.

Boolean and numeric reads work in any callback. String and color reads require
setup or a render-side callback. Each access costs one unit, plus one per 256
string bytes, rounded up.

## config_value.default

```text
config_value.default: boolean | number | string | color
```

A copied, read-only declaration default. Available during setup and callbacks.
Assign it to `.value` to restore that default. Costs match `.value` reads.

## config_value.type

```text
config_value.type: string
```

The read-only type name supplied to `config.value`. Costs one unit.

```lua
local x = config.value('panel.x', 'number', 24)
local y = config.value('panel.y', 'number', 80)
local title = config.value('panel.title', 'string', 'my panel')

menu.lua.a:button('reset panel position', function()
    x.value = x.default
    y.value = y.default
end)
```
