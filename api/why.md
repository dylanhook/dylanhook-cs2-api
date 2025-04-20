# Why

Read the explanation left by an API call that could not return its result.

## why.last

```text
why.last() -> string | nil
```

Returns the most recent reason recorded by this script, or `nil` if no reason has been recorded. Available while loading and in every callback.

Read it immediately after a call whose reference says it records a reason. A later call can replace that reason. Reading it does not clear it, and successful calls leave the previous reason in place.

```lua
local contents = assets.read("layout.json")
if contents == nil then
    console.warn("layout read failed: " .. (why.last() or "no reason recorded"))
end
```

Reasons are plain strings. For example, a missing file can record `file_not_found (detail 2)`. The `detail` value is a numeric detail from the failed operation. It can be `0` when no further detail is available.

Check the original result to decide whether an operation failed. An ordinary absent value may return `nil` without recording a new reason, so `why.last()` can still describe an earlier call.

Functions that raise Lua errors report those errors through `pcall` or the callback error log. `why.last()` does not collect them. A successful reload creates a new state with no saved reason.
