# Script basics

Each loaded script has its own Lua state. Local modules share that state. Use
local variables for data that needs to survive between callbacks.

## Set up once

Code outside callbacks runs when the script loads. Create controls, register
callbacks and prepare reusable values here.

```lua
local enabled = menu.lua.a:checkbox('round notice', true, 'round_notice')

on.game_event('round_start', function()
    if enabled.value then
        notify.screen('new round')
    end
end)
```

Register `on.*`, timers that should start immediately and
`control:on_change` handlers during setup. Control values can be read later
through `.value`. Hidden controls keep their value.

## Local modules

For `example.lua`, local helpers live in `example.assets`.

```text
example.lua
example.assets/
    labels.lua
```

`labels.lua`:

```lua
local labels = {}

function labels.count(value)
    return string.format('%d entries', value)
end

return labels
```

Main script:

```lua
local labels = require('labels')
print(labels.count(3))
```

Helpers share the main script's globals and loaded libraries. See
[`require`](api/std.md#require) for naming, caching and limits.

## Pick the right callback

| Task | Callback |
| --- | --- |
| Draw an overlay | `on.paint` |
| Draw above the menu | `on.paint_above_menu` |
| Read or edit a command | `on.setup_command`, `on.command_finished` |
| Handle a game event | `on.game_event` |
| React to a control | `control:on_change` |
| Run later or repeatedly | `timer.after`, `timer.every` |
| Reset map-specific state | `on.session_changed` |
| React to a config load or save | `on.config_result` |

Drawing only works in paint callbacks. A timer or change callback can update
state that paint later draws.

See [callbacks](events.md) for callback order and available API context.

## Keep copied values

Read game data where it is available, then keep the simple values needed by
another callback.

```lua
local speed

on.setup_command(function()
    speed = nil

    local me = entity.local_player()
    if not me then return end

    local velocity = player.velocity(me)
    if velocity then speed = velocity:length2d() end
end)

on.session_changed(function()
    speed = nil
end)

on.paint(function()
    if speed == nil or not globals.in_game() then return end
    render.text(20, 20, string.format('speed %.0f', speed), color.white)
end)
```

Command and game-event objects expire when their callback returns. Copy the
numbers, strings, booleans or vectors you need before returning.

Entity handles can be stored, but the entity may disappear or its slot may be
reused. Check each read before using the result.

## Handle missing data

`nil` is often normal. The map may be loading, the local player may not exist,
or an entity may have disappeared.

Use `value == nil` when `false` or `0` is valid. Calls that record a reason
document it in their reference. Read [`why.last()`](api/why.md) immediately
after the failed call.

A call that fails returns a single `nil` and leaves the reason in `why.last()`.
No call returns the reason as a second result, apart from Lua's own
`loadstring`. A few calls return `false` for
"nothing yet", such as `http.read` with no chunk waiting.
[Failure shapes](api/why.md#failure-shapes) lists them.

## Use the right clock

Use [`globals.real_time()`](api/globals.md#globalsreal_time) for fades and local
elapsed time. `globals.curtime()` is the client level clock.

Bomb timing uses the clock returned by
[`game.bomb_snapshot()`](api/game.md#gamebomb_snapshot). Use
`seconds_remaining`, or compare `blow_time` and `current_time` from the same
snapshot.

[`system.time()`](api/system.md#systemtime) and
[`system.date()`](api/system.md#systemdate) use the computer's clock.

Command callbacks can run more than once for the same command. Use `cmd.number`
when your own bookkeeping should happen once. Command edits should still be
applied on every applicable dispatch.

## Saved settings

Menu controls are saved with Dylanhook profiles. Give persistent controls an
explicit ID:

```lua
local opacity = menu.lua.a:slider(
    'panel opacity', 0, 255, 220, 1, 'panel_opacity')
```

Keep the ID when changing only the label or menu destination. Use a new ID when
the setting changes meaning, type, range, step or option list.

Profiles also remember which scripts were loaded and the script version they
were saved with. After updating a script, load the new version and save the
profile again. Keep its matching `.assets` folder with it.

Use [files](api/resources.md) for script data that should not live in a profile.

## Reload and unload

A successful reload starts a fresh Lua state. Ordinary Lua variables reset while
compatible saved control values carry over.

A failed reload keeps the previous version running. There is no cumulative
successful-reload limit.

**unload** releases callbacks, timers, controls, requests and script-owned
resources. `on.unload` runs during normal unload and replacement, but should
not be the only place important persistent data is saved.

An uncaught callback error disables that callback and prints a traceback. Other
callbacks keep running. Fix the error and reload the script.
