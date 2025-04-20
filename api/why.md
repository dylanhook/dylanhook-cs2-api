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

Reasons are plain strings. For example, a missing file can record `file_not_found (detail 2)`. The `detail` value is a numeric detail from the failed operation. It can be `0` when no further detail is available. A reason is kept up to 511 bytes; a longer one is cut at the last whole UTF-8 character that fits.

Check the original result to decide whether an operation failed. An ordinary absent value may return `nil` without recording a new reason, so `why.last()` can still describe an earlier call.

Functions that raise Lua errors report those errors through `pcall` or the callback error log. `why.last()` does not collect them. A successful reload creates a new state with no saved reason.

## Failure shapes

A call that cannot produce its result returns one `nil` and records the reason here. No call returns a reason or an error code as a second result; the one exception is Lua's own [`loadstring`](std.md#loadstring), which keeps its standard `nil, message`. When the failure has a numeric detail, such as a Windows error code, it is part of the reason in the same `(detail N)` form shown above.

A few calls have an answer that is "nothing yet" rather than a failure. Those return `false` and leave `why.last()` alone:

| Call | `false` means |
| --- | --- |
| `http.read` | No chunk is waiting. |
| `socket:receive()` | No complete message is waiting. |
| `socket:close()` | Closing already started or finished. |
| `trace_request:result()` | The request is still pending. |
| `config_operation:result()` | The operation is still queued. |
| `request:take()` on an image request | The image is still being prepared. |
| `render.draw_game_icon`, `render.measure_game_icon` | The shared icon is still being prepared. |
| `game.bomb_snapshot`, `entity.planted_c4` | Paint asked before the next frame captured the bomb. |
| `player.weapon_info` | Paint asked before the next snapshot captured the weapon. |
| `entity.at`, `entity.find_by_class`, `entity.get_all_by_class`, `entity.get_all`, `entity.designer_name`, `value.schema_class` | Paint asked before the next frame captured entities. |
| `player.pose`, `player.bone_position`, `player.hitbox_position`, `player.hitbox_capsule` | Paint asked before the next frame captured the pose. |

Reads whose value can itself be `false`, such as `schema_field:get` and `value:is_a`, cannot use `false` for "nothing yet". Before their data is captured they return `nil` and record `schema_snapshot_not_requested`.

`trace_request:status()` returns only the status string. When that status is `refused`, `expired` or `cancelled`, it also records the reason here.
