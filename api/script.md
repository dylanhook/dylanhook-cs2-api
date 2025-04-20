# Script runtime

Inspect script identity, execution limits and callback measurements. Each
function below states its available contexts.

## script.info

```text
script.info() -> script_info
```

Returns copied information about this script. Available during setup and every
callback. Costs one native work unit.

```text
script_info: table
script_info.name: string
script_info.logical_name: string
script_info.status: string
script_info.profile: string
script_info.config_operation_id: string | nil
```

`name` is the current local filename. `logical_name` identifies its saved values
and can retain an earlier filename after a verified rename. `status` is
`"loading"` during setup and `"loaded"` during callbacks. `profile` is the frozen
`"standard"` or `"unsafe"` execution policy for this load.

`config_operation_id` identifies the config load or import that created this
script instance. It is `nil` for normal script loads and reloads. Match it with
`config.last_result().id` to observe completion after config replacement.

## script.list

```text
script.list() -> script_entry[]
```

Returns copied names and statuses from the native script list. Available during
setup and render-side callbacks. Costs 32 units. It grants no access to another
script's state or permission to control it.

```text
script_entry: table
script_entry.name: string
script_entry.status: string
```

Status is `"unloaded"`, `"loaded"`, `"load_failed"`, `"reload_failed"` or
`"remove_failed"`. A failed reload can leave the previous loaded script running.

## script.reload

```text
script.reload() -> true | nil
```

Queues a reload of the current script. Available from an active callback. The
current callback finishes before the request is processed on the next frame.
An unsuccessful replacement leaves the current script running.

Self-reload cannot grant unsafe permission. The replacement keeps the current
permission only while **allow unsafe scripts** remains enabled. A standard
script stays standard until the user reloads it from the menu.

## script.unload

```text
script.unload() -> true | nil
```

Queues an unload of the current script, including normal `on.unload` cleanup.
Available from an active callback. The current callback finishes first.

Both functions return `true` when queued, or `nil` if the request cannot be
accepted. Read `why.last()` for the reason. Queued requests belong to the
current loaded instance and are discarded if it is replaced or unloaded first.
These functions are unavailable during setup. Cleanup cannot reload an instance
that has already been removed from the active set.

```lua
menu.lua.a:button("reload script", function()
    if script.reload() == nil then
        console.warn(why.last() or "reload unavailable")
    end
end)
```

## script.budget

```text
script.budget() -> execution_budget
```

```text
execution_budget: table
execution_budget.profile: "standard" | "unsafe"
execution_budget.memory_limit: number | nil
execution_budget.memory_used: number
execution_budget.source_limit: integer
execution_budget.native_enforced: boolean
execution_budget.native_threshold: number
execution_budget.native_limit: number | nil
execution_budget.native_used: number
execution_budget.native_remaining: number | nil
execution_budget.instruction_limit: number | nil
```

| Field | Meaning |
| --- | --- |
| `profile` | `"standard"` or `"unsafe"`. The value is fixed when the script loads. |
| `memory_limit` | Lua memory limit in bytes, or `nil` in unsafe mode. |
| `memory_used` | Lua memory currently in use. This is not total process memory. |
| `source_limit` | Maximum main script size in bytes. |
| `native_enforced` | Whether the native-work threshold is enforced. |
| `native_threshold` | Enforced limit or advisory threshold. |
| `native_limit` | Enforced allowance, or `nil` in advisory mode. |
| `native_used` | Native work used so far in the current setup or callback. |
| `native_remaining` | Remaining enforced work, or `nil` in advisory mode. |
| `instruction_limit` | VM instruction limit, or `nil` in unsafe mode. |

Calling `script.budget()` has no native-work charge. Creating the returned table
still uses Lua memory.

ESP value callbacks share one native-work allowance for the script's ESP pass.

## script.stats

```text
script.stats() -> execution_statistics
```

```text
callback_measurement: table
callback_measurement.calls: number
callback_measurement.failures: number
callback_measurement.last_ms: number
callback_measurement.peak_ms: number
callback_measurement.mean_ms: number
callback_measurement.last_native_work: number
callback_measurement.peak_native_work: number
callback_measurement.native_overruns: number

execution_statistics: table
execution_statistics.memory_used: number
execution_statistics.memory_peak: number
execution_statistics.source: callback_measurement
execution_statistics.callbacks: table<string, callback_measurement>
execution_statistics.last_error: string | nil
```

`memory_used` and `memory_peak` cover the current Lua state. Reloading starts
new measurements.

Each callback row contains:

- `calls`
- `failures`
- `last_ms`
- `peak_ms`
- `mean_ms`
- `last_native_work`
- `peak_native_work`
- `native_overruns`

Rows are grouped by callback kind, so several `on.paint` callbacks share the
`paint` row. Measurements include completed calls only. Timing includes time
spent in synchronous child callbacks and time the process was descheduled.

`last_error` keeps the most recent callback error until another error or reload.

```lua
menu.lua.a:button('inspect script performance', function()
    local stats = script.stats()
    local paint = stats.callbacks.paint

    print('paint mean ms:', paint.mean_ms)
    print('paint peak ms:', paint.peak_ms)
    print('lua peak bytes:', stats.memory_peak)
end)
```

## Unsafe mode

Enable **allow unsafe scripts** and reload to use unsafe mode.

Unsafe mode makes native-work limits advisory and removes the Lua memory and VM
instruction limits. `script.budget()` reports:

- `native_enforced == false`
- `memory_limit == nil`
- `instruction_limit == nil`

FFI, `loadstring`, HTTP and [WebSocket](websocket.md) also require unsafe mode.

API-specific limits still apply. This includes request sizes, textures,
registrations, files and schema capture limits. Unsafe mode cannot protect the
game from a blocking or crashing FFI call.

See [Limits](../limits.md).
