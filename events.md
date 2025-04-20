# Events and timers

Register `on.*` callbacks while the script loads. Each call returns a
[subscription](#subscriptions) that can be removed later. Several callbacks can
listen to the same event.

Timers may be created during setup or from callbacks. They run on rendered
frames using elapsed real time.

Registering `on.*` after loading raises an error.

## Callback context

| Callback | Drawing | Input reads | Menu value writes |
| --- | --- | --- | --- |
| `on.paint`, `on.paint_above_menu` | Yes | Yes | Yes |
| Menu button, text submission | No | Yes | Yes |
| ESP value or item measure callback | No | No | Yes |
| ESP item draw callback | Yes | No | Yes |
| HTTP completion, control change, timer, `on.session_changed`, `on.config_result`, `on.unload`, `on.shot_miss`, `on.shot_committed`, `on.shot_settled` | No | No | Yes |
| `on.setup_command`, `on.command_finished`, `on.command_committed`, `on.anti_aim` | No | No | No |
| `on.frame_stage`, `on.game_event` | No | No | No |
| `on.override_view` | No | No | No |
| [`console.register`](api/console.md#consoleregister) commands | No | No | No |
| `on.console_input` | No | No | No |
| [`memory.hook`](api/memory.md#memoryhook) callbacks | No | No | No |

Render-side callbacks share the current render snapshot while their render
pass is active, including above-menu paint, timers, menu callbacks, control
changes and HTTP completions. Shutdown cleanup has no render snapshot. Command,
frame-stage, game-event, view and console-command callbacks can use the live
reads documented by each API.

[ESP value callbacks](api/esp.md) use copied player data and return values to the
native ESP. Custom [ESP items](api/esp.md#espadd_item) can measure text in
`measure` and draw inside their assigned bounds in `draw`.

## on.paint

```text
on.paint(callback: function()) -> subscription
```

Runs each rendered frame below the menu. Use it to draw overlays and read the current player and camera snapshot. It also runs outside a match, when player data may be absent.

Planted-bomb reads, class-based entity queries and supported schema-field reads
are available here as copied frame data. Their first request can wait for the
next capture. These reads do not require a command callback or a living local
player. See [game](api/game.md), [entities](api/entity.md) and [schema](api/schema.md).

```lua
local accent = color(160, 210, 255)

on.paint(function()
    render.rect(16, 16, 100, 3, accent)
end)
```

For each script, a frame runs session changes, control changes, due timers,
completed HTTP requests and then `on.paint`. Callbacks of the same kind run in
registration order.

## on.paint_above_menu

```text
on.paint_above_menu(callback: function()) -> subscription
```

Runs each rendered frame after the menu has been drawn. Use it for drawing that should stay above the menu.

Screen drawing, input and copied world reads are available. The camera and
world data use the same render snapshot as ordinary paint.

## on.setup_command

```text
on.setup_command(callback: function(cmd: command)) -> subscription
```

Runs after the game creates or rebuilds an input command, before Dylanhook's
command features run. `cmd` exposes the command's buttons, movement and angles.

```lua
local moving = false
local indicator = color(160, 210, 255)

on.setup_command(function(cmd)
    local forward, side = cmd:move()
    moving = forward ~= nil and (forward ~= 0 or side ~= 0)
end)

on.paint(function()
    if moving then
        render.rect(16, 24, 12, 12, indicator)
    end
end)
```

The game can rebuild a command and deliver this callback more than once in a tick. Use `cmd.number` when your own bookkeeping should run once per command.

`cmd` belongs to this invocation. Copy any numbers or vectors you need later. Accessing the saved command from another callback raises an expiration error.

## on.command_finished

```text
on.command_finished(callback: function(cmd: command)) -> subscription
```

Runs after Dylanhook's command features. You can read or edit the resulting
[command](api/cmd.md) here. Movement is committed and the command receives its
final validation after this callback returns. This does not mean a command was
sent or a shot fired. [`cmd:move_toward`](api/cmd.md#cmdmove_toward), which
needs the command's final view angles, is available only here.

The same command can be delivered again when the game rebuilds it. The `cmd` object is valid only in the callback that received it, just like `on.setup_command`.

## on.frame_stage

```text
on.frame_stage(callback: function(stage: integer, phase: string), phase: string = "after") -> subscription
```

Select `"enter"`, `"after"` or `"both"`. The callback receives the actual phase
as its second argument. The default runs after the game's handler. `stage` is
the native stage number; several stages can arrive between rendered frames.

Live entity reads and [`sound.play_game`](api/sound.md#soundplay_game) are available here. Queued console commands and cvar writes are processed before after-phase callbacks.

## on.game_event

```text
on.game_event(name: string | number, callback: function(event: game_event)) -> subscription
```

Runs when the named game event is delivered. `name` must contain 1-96 bytes, using lowercase ASCII letters, digits, and underscores. The name must also be accepted by the game when the script finishes loading. An invalid name or refused subscription makes the load fail.

```lua
on.game_event("player_hurt", function(event)
    local damage = event:get_int("dmg_health")
    local victim = event:get_player("userid")
    local local_player = entity.local_player()

    if damage ~= nil and victim ~= nil and victim == local_player then
        notify.screen(string.format("took %d damage", damage))
    end
end)
```

Read the fields before this callback returns. The event object is valid only in the invocation that received it. Save copied strings, numbers, or booleans when another callback needs them.

### event.name

```text
event.name: string | nil
```

The event name, copied into a Lua string, or `nil` when unavailable. This property is read-only.

### event:get_int

```text
event:get_int(field: string | number) -> integer | nil
```

Reads an integer field. The game supplies `0` for an absent integer field. A failed read returns `nil`, so `0` does not tell you whether the field was present.

```lua
on.game_event("player_hurt", function(event)
    local damage = event:get_int("dmg_health")
    if damage ~= nil then
        local message = string.format("damage: %d", damage)
        console.log(message)
    end
end)
```

### event:get_uint64

```text
event:get_uint64(field: string | number) -> string | nil
```

Reads an unsigned 64-bit event field as an exact decimal string. An absent
field uses the game's `"0"` default; it does not prove field presence. A failed
read returns `nil`. The event expires with its callback like other accessors.

### event:get_float

```text
event:get_float(field: string | number) -> number | nil
```

Reads a floating-point field. The game supplies `0` for an absent float field. A failed read returns `nil`.

### event:get_string

```text
event:get_string(field: string | number) -> string | nil
```

Reads a string field and copies it into Lua. The game supplies an empty string for an absent string field. A failed read returns `nil`. The returned string can be kept after the callback ends.

### event:get_player

```text
event:get_player(field: string | number, kind: string = "pawn") -> entity | nil
```

Reads a player reference such as `userid`, `attacker`, or `assister`. `kind` accepts `"pawn"` or `"controller"`. Omitting it or passing `nil` selects `"pawn"`. Other values raise an argument error.

Returns an [entity handle](api/entity.md), or `nil` if the field cannot resolve to a player. The handle follows the normal entity lifetime rules after the event ends. Use this method to read player fields. An integer event field is not an entity handle.

All five getters require a field name of 1-96 bytes with no NUL byte. A bad field name or an expired event raises an error. If field lookup is unavailable, the getters return `nil` and record a reason in [`why.last()`](api/why.md#whylast). Other unavailable reads can return `nil` without recording a new reason.

## on.session_changed

```text
on.session_changed(callback: function()) -> subscription
```

Runs once on the first rendered frame after loading, then whenever the map name seen by the script appears, disappears, or changes. Use [`game.map_name()`](api/game.md#gamemap_name) to read that name. It returns `nil` when no name is available.

An observed disconnect and reconnect also produces a notification when the map
name stays the same. This is an observed boundary, not an exact connection event.

```lua
local previous_map

on.session_changed(function()
    previous_map = game.map_name()
    console.log(previous_map and ("map: " .. previous_map) or "left the level")
end)
```

This callback runs before control-change callbacks, timers, and paint. Files, JSON, and menu control changes are available here. It can read the current render snapshot, but has no drawing or input context.

## on.config_result

```text
on.config_result(callback: function(result: config_result | nil)) -> subscription
```

Runs once when a native config operation completes, from the menu or from any
script, on the next rendered frame. The argument is the same copied record
[`config.last_result()`](api/config.md#configlast_result) returns, and receiving
it costs the same. Several operations that complete before one frame are a
single call with the latest of them. Use this instead of polling
`config.last_result()`.

A script only hears about operations that complete after it was created. That
includes a config load that loaded the script itself, whose `id` matches
`script.info().config_operation_id`.

```lua
on.config_result(function(result)
    if result and result.operation == 'load' and result.status == 'succeeded' then
        console.log('config loaded: ' .. tostring(result.name))
    end
end)
```

This callback runs after `on.session_changed` and before control-change
callbacks, timers and paint, with the same context as `on.session_changed`.

## on.anti_aim

```text
on.anti_aim(callback: function(pitch: number, yaw: number, references: anti_aim_references)) -> subscription
```

Selects pitch and yaw through Dylanhook's native anti-aim behavior. Return two
numbers to use your angles. Return nothing, or two `nil` values, to leave the
selection to the native settings. No menu values are changed.

The first callback receives the incoming command view. Later callbacks receive
the last accepted script selection. Pitch must be within the native view range,
currently -89 to 89 degrees. Yaw must be finite and is normalized before use.
Returning only one number, a wrong type or a nonfinite value disables that
callback and reports its error.

```lua
local enabled = menu.lua.a:checkbox('custom angles', false, 'angles.enabled')
local pitch = menu.lua.a:slider('pitch', -89, 89, -89, 1, 'angles.pitch')
local offset = menu.lua.a:slider('yaw offset', -180, 180, 180, 1, 'angles.yaw')

on.anti_aim(function(_, yaw)
    if not enabled.value then return end
    return pitch.value, yaw + offset.value
end)
```

The callback works with the native anti-aim toggle off. Native applicability,
camera preservation and movement compensation still apply. It is not called
while dead, frozen, using an interaction, or preparing or throwing a grenade.
A shot constraint can adjust the requested angles. Failed movement compensation
withholds the angle change.

This runs on the command thread. Live player reads and command-start movement
data follow command-callback rules. Drawing, render input and file access are
unavailable here. Use `on.command_committed` to observe the finalized command.
Removal, callback failure and unload release the script's demand for this
callback through the native owner.

### references:at_target

```text
references:at_target() -> number | nil
```

The third callback argument offers the yaws native anti-aim builds its own
angles from, so a script can start from the same reference instead of working
it out again. It is valid only during the callback that received it.

`at_target` returns the yaw in degrees from your eye to the enemy that the native
anti-aim target priority picks for this command. Returns `nil` and sets
[`why.last()`](api/why.md#whylast) to `no_target` when no enemy is available, or
`local_eye_unavailable`. Costs one native work unit.

### references:freestand

```text
references:freestand() -> number | nil
```

Returns the yaw native freestanding would choose for this command, with the same
cover survey and the same reluctance to switch sides: the covered side, else
straight away from the enemy, or straight back from your view when no enemy is
available. Returns `nil` with `why.last()` set to `local_eye_unavailable`,
`command_unavailable`, `survey_trace_unavailable` or `survey_geometry_invalid`
when the survey cannot run. Costs 54 native work units, the
traces of one full survey, even when the native feature already surveyed this
command.

```lua
on.anti_aim(function(pitch, yaw, references)
    local base = references:freestand()
    if base == nil then return end
    return 89, base
end)
```

## on.override_view

```text
on.override_view(callback: function(view: table)) -> subscription
```

Edits the camera for the frame being built. The callback receives one table and
changes it in place:

| Field | Type | Meaning |
| --- | --- | --- |
| `origin` | vec3 | Camera position in world units. |
| `angles` | vec3 | Camera pitch, yaw and roll in degrees. |
| `fov` | number | Horizontal field of view in degrees, with the screen's aspect already applied. A 90 degree view reads about 106 on a 16:9 screen. |

The table arrives with the finished native view, after the field-of-view,
aspect-ratio, recoil, third-person and free-camera settings have run, so a
script has the last word. With several callbacks, each receives the previous
one's result. Leave a field unchanged to keep it.

When the callback returns, all three fields are read back and applied together.
`origin` must be finite and within 1,000,000 units of the map origin. Pitch must
be within -90 to 90 degrees; yaw and roll are wrapped into -180 to 180. `fov`
must be greater than 1 and less than 180. A missing field, a wrong type or a
value outside those ranges raises an error, disables that callback and keeps the
native view. Nothing is written for a callback that fails.

```lua
local distance = menu.lua.a:slider('camera distance', 40, 250, 120, 1, 'view.distance')

on.override_view(function(view)
    local forward = view.angles:basis()
    local camera = view.origin - forward * distance.value
    local path = trace.line(view.origin, camera, { mask = mask.solid, skip = entity.local_player() })
    if path == nil then return end
    view.origin = path.end_pos
end)
```

It runs once per rendered frame on the thread that builds the view, before the
world is drawn with it. Live player reads and traces work as they do in
[`on.frame_stage`](#onframe_stage). Drawing, render input, menu writes and file
access are unavailable. [`render.camera`](api/render.md#rendercamera) reports
`script` as its `application` on a frame whose camera position or angles a
callback moved.

## on.console_input

```text
on.console_input(callback: function(line: string)) -> subscription
```

Offers each console line a player submits before the game runs it. `line` is
the whole line as typed, such as `"say hi; kill"`. Return `false` to stop the
game from running it. Any other result, including no value, lets it through.

The lines come from the game console, the developer console, key binds and
alias bodies. Lines from config files, from the game's own internal commands and
from [`console.exec`](api/console.md#consoleexec) are not offered, unless the line
names an alias, whose body is. The game's own rules run first: a line the game
already refuses is never offered.

```lua
on.console_input(function(line)
    if line:find('^disconnect') then
        console.warn('disconnect blocked by script')
        return false
    end
end)
```

The first `false` ends the chain for that line: later callbacks, in this script
or another, do not see it. This can run on any thread the game submits lines from, so only
thread-independent work is available: copied values, `console.*` output and
queued actions such as `console.exec`. Drawing, input reads, live player reads
and menu value writes are not. A callback error disables that callback and lets
the line through. A line longer than 4,096 bytes is not offered.

## on.shot_committed

```text
on.shot_committed(callback: function(shot: shot_notice)) -> subscription
```

Receives a copied firearm intent from Dylanhook's shot tracker. This says
the client committed an aimed round, not that the server accepted or fired it.
It does not report every manual shot, knife attack or zeus attack.

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | string | Exact decimal tracking ID. Use it as a table key. Converting it to a Lua number can lose precision. IDs are not reused while Dylanhook is running. |
| `session_id` | string or nil | Captured session identity, comparable with `game.capture().session_id`. Target and victim handles remain pinned to this session. |
| `target` | entity or nil | Intended target's copied handle, not a retained pawn pointer. |
| `origin` | vec3 | Client intent's shooting origin. |
| `aim_point` | vec3 | Client intent's aimed world position. |
| `weapon` | string | Captured canonical weapon label, up to 40 bytes. Empty when unavailable. This is not a weapon handle. |
| `estimate` | shot_estimate | Copied client estimates for the committed round. These are separate from observed damage. |

```text
shot_notice: table
shot_notice.id: string
shot_notice.session_id: string | nil
shot_notice.target: entity | nil
shot_notice.origin: vec3
shot_notice.aim_point: vec3
shot_notice.weapon: string
shot_notice.estimate: shot_estimate
shot_notice.outcome: string | nil
shot_notice.confirmation: string | nil
shot_notice.reason: string | nil
shot_notice.victim: entity | nil
shot_notice.damage: integer | nil
shot_notice.hitgroup: integer | nil
shot_notice.remaining_health: integer | nil

shot_estimate: table
shot_estimate.damage: number
shot_estimate.hitgroup: integer | nil
shot_estimate.bone: integer | nil
shot_estimate.expected_health: integer | nil
shot_estimate.minimum_damage: number | nil
shot_estimate.hitchance_threshold: number | nil
shot_estimate.command_tick_base: integer | nil
shot_estimate.snapshot_tick: integer | nil
shot_estimate.record_tick: integer
shot_estimate.attack_tick: integer
shot_estimate.attack_fraction: number
shot_estimate.penetrations: integer
shot_estimate.extrapolated: boolean
```

`estimate.damage` is the simulated health damage at commitment.
`estimate.hitgroup` is the simulated first contact group when captured, and
`bone` is the selected model bone. Neither is the observed damage hitgroup.

`expected_health` includes pending damage tracked by Dylanhook. `minimum_damage`
is the resolved health-damage requirement when enabled. `hitchance_threshold`
is the configured percentage threshold when enabled, not a measured probability.
Unavailable values are `nil`.

`record_tick` names the selected target record. `attack_tick` and
`attack_fraction` describe the client attack time. `command_tick_base` and
`snapshot_tick` are the captured command and network clocks when available.
`penetrations` counts simulated penetrations. `extrapolated` identifies a
predicted target record. These values describe the client's calculation, not a
server acknowledgement.

Shot callbacks run later than the command that created the intent. They cannot
draw, read input or perform live entity reads. Keep copied values for a later
paint callback.

The shot tracker keeps 64 entries. A long rendering pause, map change,
subscription removal or reload can prevent a matching pair from reaching a
script.

A newly loaded listener can receive settlement for an intent it did not receive.
Use the ID to pair records instead of relying on callback order.

## on.shot_settled

```text
on.shot_settled(callback: function(result: shot_notice)) -> subscription
```

Receives the native tracker's settled firearm evidence. It includes the same
identity and intent fields as `on.shot_committed`, plus:

| Field | Type | Meaning |
| --- | --- | --- |
| `outcome` | string | `"hurt"`, `"no_hurt"`, `"unconfirmed"` or `"unobservable"`, as described below. |
| `confirmation` | string | Strongest associated event: `"none"`, `"weapon_fire"`, `"bullet_impact"` or `"player_hurt"`. |
| `reason` | string or nil | The basic miss logger's classification when one is available. This is a client inference, not a server-supplied cause. |
| `victim` | entity or nil | Handle associated with observed damage. It can differ from `target`. |
| `damage` | integer or nil | Associated observed health damage. Absent when no damage event was observed. |
| `hitgroup` | integer or nil | Observed damage hitgroup, when available. |
| `remaining_health` | integer or nil | Observed victim health, when available. Zero is a valid value. |

`"hurt"` means associated damage was observed. `"no_hurt"` means the tracker
observed a firing/impact confirmation but no damage within its settlement window.
`"unconfirmed"` means no associated confirming event arrived. `"unobservable"`
means damage observation was unavailable and no damage was observed. None of the
last three outcomes fabricates `damage = 0` or a server-certified miss.

```lua
local latest = "waiting for a tracked round"

on.shot_committed(function(shot)
    latest = shot.id .. ": committed"
end)

on.shot_settled(function(result)
    latest = result.id .. ": " .. result.outcome
    if result.damage ~= nil then
        latest = latest .. " (" .. result.damage .. " damage)"
    end
end)

on.paint(function()
    render.text(24, 104, latest, color.white)
end)
```

The result is a fresh copy at settlement. If the client rebuilt an outstanding
command, its intent fields can differ from the earlier notification while its
tracking ID remains the same. The native event correlation is evidence, not an
unqualified guarantee about every projectile or victim.

Both callbacks use ordinary script permissions and do not depend on the native
log being visible. Removing the last relevant listener releases that script's
demand for collection. The reason-only callback below remains available.

## on.shot_miss

```text
on.shot_miss(callback: function(miss: table)) -> subscription
```

Receives the ordinary miss logger's settled firearm results. The copied table
contains one field, `miss.reason`, using the same wording as the native log.
No unsafe-script permission or beta access is required, and the callback does
not depend on the native miss-log display being enabled.

Possible reasons are `"spread"`, `"no-spread mismatch"`, `"occlusion"`,
`"extrapolation"`, `"position adjustment"`, `"trajectory mismatch"`,
`"position mismatch"`, `"no impact"`, `"target death"`, `"local death"`,
and `"unknown cause"`. These are the native logger's classifications from
available evidence, not reason strings supplied by the server.

Successful hits, melee diagnostics, below-minimum-damage diagnostics, missing
server confirmation and unavailable event observation do not emit this event.
There is no target, seed, trace, timing breakdown or beta diagnostic object in
the table. This is a miss notification, not an acknowledgement API for every shot.

Callbacks run before ordinary paint. Several results may arrive in one frame.
A newly loaded script does not receive older results. The table is a copy and can
be retained.

This callback can read the current render snapshot. It has no drawing, input or live entity context.
Logging, notifications, files, JSON, timers, script-control writes and queued
console/cvar operations follow their normal limits. Draw a saved message in
`on.paint` instead of drawing inside this callback.

```lua
local last_reason
local received_at = 0

on.shot_miss(function(miss)
    last_reason = miss.reason
    received_at = globals.real_time()
end)

on.session_changed(function()
    last_reason = nil
end)

on.paint(function()
    if last_reason and globals.real_time() - received_at < 3 then
        render.text(24, 180, "Missed shot due to " .. last_reason, color.white)
    end
end)
```

Removing the subscription or disabling it through an uncaught error stops that
callback. When the final active subscriber goes away, scripts stop requesting
miss collection. Other native consumers can still request it.

## on.unload

```text
on.unload(callback: function()) -> subscription
```

Runs during a normal unload, removal, or successful replacement of a loaded script. Use it to save data or release something your script owns.

```lua
local preferences = {compact = true}

on.unload(function()
    if fs.write("preferences.json", json.encode(preferences)) == nil then
        console.warn("save failed: " .. (why.last() or "no reason recorded"))
    end
end)
```

The script's state and resources are still alive during this callback. File writes, JSON, control changes, logging, and queued console commands are available.

A failed load does not run its unload callbacks. A failed reload leaves the
previous script running. Final Dylanhook shutdown skips unload callbacks, so save
important changes as they happen too.

After cleanup, callbacks and timers are removed and the script's Lua state and resources are released. An error in one unload callback does not prevent the remaining cleanup.

## control:on_change

[`control:on_change`](api/menu.md#controlon_change) registers one callback on a
value-bearing menu control. Call it while loading. Checkbox, slider, combobox,
multiselect, color, and text controls support it.

The callback runs once on the first rendered frame, then when the control's effective value differs from its last check. Read `control.value` inside the callback. Changes from the menu, config loads, bindings, and scripts use the same check. Several changes between checks can become one delivery.

```lua
local enabled = menu.lua.a:checkbox("show details", true, "show_details")

enabled:on_change(function()
    console.log(enabled.value and "details enabled" or "details disabled")
end)
```

The callback receives no arguments. Registration after loading, a second active callback on the same control, or a control without a value raises an error. Removing the subscription allows another registration while the script is still loading.

Menu button callbacks also receive no arguments and run when the button is clicked. Declare them through the [button constructor](api/menu.md). They are separate from `control:on_change`.

## control:on_submit

[`control:on_submit`](api/menu.md#controlon_submit) registers one callback on a
text control while the script loads. It receives the submitted text when Enter
or an ordinary focus change finishes an edit. Escape and control removal do not
submit. Assigning `.value` does not submit it.

Submission runs during menu input, with the same context as a menu button.
It is separate from `control:on_change`, which observes value changes on frames.

## timer.after

```text
timer.after(seconds: number, callback: function()) -> subscription
```

Runs the callback once after a finite delay from `0` through `86400` seconds. The returned subscription stays active until it is removed, fails, or finishes running.

```lua
timer.after(0, function()
    notify.screen("script ready")
end)
```

A timer declared while loading starts counting after the script activates. A timer created inside a callback starts counting when it is created. A zero delay runs in a later timer pass. It never calls the function inline.

## timer.every

```text
timer.every(seconds: number, callback: function()) -> subscription
```

Runs repeatedly with a finite interval from `0.001` through `86400` seconds. The first run is due one interval after creation, or after activation for a timer declared while loading.

```lua
local samples = 0
local timer_handle

timer_handle = timer.every(1, function()
    samples = samples + 1
    if samples == 5 then
        timer_handle:remove()
        notify.screen("five samples collected")
    end
end)
```

Timers are checked once per rendered frame, before `on.paint`. A repeating timer runs at most once in a timer pass and schedules its next run from that pass's time. Missed intervals are not replayed. Both timer types wait for rendering to resume when no frames are being delivered.

Timer callbacks receive no arguments. They can read and write files, use JSON, change menu controls, and send console output or notifications. They can read the current render snapshot, including its camera, but have no drawing, input or live entity context. Copy command/event values before scheduling work that needs those specific samples.

Each script has at most 128 active timer slots. Completed, removed, and failed timers release their slots. Invalid arguments, an invalid delay, or a full timer pool raise an error. No failed subscription is returned.

## Subscriptions

`on.*`, `timer.after`, `timer.every`, `control:on_change` and `control:on_submit`
return a subscription. Dropping the handle does not cancel the callback. Keep it
when you need to remove that callback yourself.

### subscription.active

```text
subscription.active: boolean
```

Reports whether the subscription is active. It becomes `false` after removal, a callback error, or completion of a one-shot timer. HTTP request subscriptions become inactive before their completion callback starts. See [HTTP](api/http.md). This property is read-only.

A one-shot timer remains active inside its callback until it returns, unless that callback removes it. This property can be read while loading and in any callback.

### subscription:remove

```text
subscription:remove() -> boolean
```

Stops future deliveries and releases the registered function. Returns `true` when it removed an active subscription, or `false` when that subscription was already inactive.

You can remove a subscription from its own callback. The current invocation continues until it returns. Removing a different callback before it is reached prevents that callback from running.

Removal is allowed while loading and in any callback. Removing a control-change subscription keeps the menu control and its value.

```lua
local paint_handle

paint_handle = on.paint(function()
    paint_handle:remove()
end)
```

## Errors and limits

Each script can declare 256 ordinary `on.*` callbacks and 64 game-event callbacks. Those declaration counts are separate from timers and menu callbacks. Removing an ordinary callback or game-event subscription does not reclaim its declaration slot.

An uncaught Lua error disables the callback that failed and reports the error with a traceback. The other callbacks keep running. A repeating timer that fails is removed. Use `pcall` around an operation whose ordinary error your script can handle.

In standard mode, instruction exhaustion also disables the callback, even if a
nested `pcall` catches the first error. APIs that charge native work use the
current callback's allowance. Running out of native work, or out of instructions
that a shared ESP or timer pass had already partly spent, stops only that
invocation: the callback runs again on its next event, and its staged command
changes are discarded. Unsafe mode keeps the measurements but does not enforce
those execution limits. See [Limits](limits.md).

A slow callback can produce one timing warning. The warning threshold is 2 ms for paint, above-menu paint, and unload, and 1 ms for the other callbacks. A timing warning alone does not disable the callback.

Callbacks are serialized within a script. Nested callback delivery is limited to
8 active invocations. Use each command or event object only in the callback that
received it.


## on.command_committed

```text
on.command_committed(callback: function(snapshot: table)) -> subscription
```

Runs in the native read-only phase after command movement commit and final
validation. The argument is a copied table, not mutable command userdata.
It does not acknowledge server execution and can repeat for one command number.

Fields are `dispatch_id`, `session_id`, `number`, `view_angles`, `forward_move`,
`side_move`, `held_buttons`, `timing`, `kinematics`, `decision`, `movement_assist`
and `edge_stop`. Unavailable values are absent. `held_buttons` is an
exact decimal uint64 string. `movement_assist` names the native movement assist
whose timed jump or crouch this command carries: `jump_release`, `crouch`,
`jump_bug`, `no_fall_damage`, `reduce_land_penalty`, `edge_bug`, `edge_jump` or
`long_jump`; it is absent when none placed one. `edge_stop` is `true` when the
native stop at edge set this command's movement. Timing and kinematics use the same records as
[`cmd.timing` and `cmd.kinematics`](api/cmd.md#cmdtiming).
`dispatch_id` is an exact decimal identifier for this pass. `decision` is the
same copied native selection as [`cmd.decision`](api/cmd.md#cmddecision).

Observed disconnect/reconnect boundaries now reset `on.session_changed` even
when the next session uses the same map name. This remains an observed session
change, not an exact engine connection notification.
