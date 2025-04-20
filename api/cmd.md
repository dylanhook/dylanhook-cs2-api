# Command

`on.setup_command` and `on.command_finished` pass a command object to your
callback. Use its properties to read the command and its methods to change it.
`cmd` in this reference is that callback argument.

The object expires when its callback returns. Even another callback for the
same command must use its own argument. Reading or calling an expired object
raises an error. Copied numbers and vectors can be saved between callbacks.

Properties are read-only. Assigning them raises an error. An unknown property
reads as `nil`. Each setter's return contract is listed below.

Command callbacks can run several times for one game tick. Apply changes on
every call where they are needed. Deduplicate only side effects such as logging
or collecting one sample per tick.

The game rebuilds the command it is building once per rendered frame, so a view
you set on every call moves at the frame rate. Smooth an aim there; `on.paint`
has no command to write.

Several calls can also carry the same command number. Use `cmd.number` to
identify a command. A client tick count does not identify it uniquely.

## cmd.number

```text
cmd.number: integer | nil
```

Returns the current command number, or `nil` when it cannot be read. The
number can restart when the level changes.

## cmd.view_angles

```text
cmd.view_angles: vec3 | nil
```

Returns a copy of the outer view angles in degrees: x is pitch, y is yaw and
z is roll. Returns `nil` when the complete angle cannot be read.

## cmd.subtick_count

```text
cmd.subtick_count: integer
```

Returns the number of subtick records currently attached to the command, or
`-1` when movement data is unavailable. A valid command can hold at most 32
entries, shared by the game, built-in features and scripts.

## cmd:set_view_angles

```text
cmd:set_view_angles(angles: vec3) -> no values
```

Sets the command's outer view angles. All components must be finite. Invalid
angles or unavailable outer-angle data raise an error. The supplied angles
are not clamped or normalized.

This does not rewrite the aim angles stored in input history.

## cmd:set_aim_angles

```text
cmd:set_aim_angles(angles: vec3, options: table | nil = nil) -> no values
```

Sets the outer view and available input-history aim angles to the same value.
All components must be finite. Invalid angles or unavailable outer-angle data
raise an error. The supplied angles are not clamped or normalized.

Unavailable history entries are skipped. The call does not return a separate
status for them.

| Option | Type | Meaning |
| --- | --- | --- |
| `keep_camera` | boolean | Keep the camera and the player's movement on the player's own view. Defaults to `false`. |

Without `keep_camera` the outer view also turns the camera, and the next
command starts from the written angles. With `keep_camera = true` the call
writes the angles the way the native straight throw does: the player's
movement keys keep moving relative to where the player is looking, and the
camera stays on the player's view instead of following the aim. This is how
to throw a grenade or fire at other angles without moving the view. An
unknown option raises an error.

`keep_camera` is available only in `on.command_finished`, after native
features such as anti-aim have written their angles. A refusal raises an
error, leaves the command's view as it was, and names the reason: the
server's movement settings are unreadable, or the player's movement cannot
be kept on this command (on a ladder, in noclip, or swimming while the server
does not take movement from sub-tick view angles). When the server does not
take movement from sub-tick view angles, the call costs two native work units.

```lua
-- throw at fixed angles while the camera stays where the player looks.
local lineup = vec3(-35, 90, 0)
on.command_finished(function(cmd)
    if cmd:button_held('attack') then
        cmd:set_aim_angles(lineup, { keep_camera = true })
    end
end)
```

## cmd:set_shot_angles

```text
cmd:set_shot_angles(angles: vec3) -> integer
```

Sets only the input-history aim angles, which the server resolves this
command's shot from. The outer view is left alone, so the camera does not move
and the next command starts from where the player was looking: this is silent
aim. All components must be finite; invalid angles raise an error. The supplied
angles are not clamped or normalized.

Returns how many history entries now carry the angles. `0` means the command
has no input history, so there is no shot entry to aim.

Native features that aim a shot (the rage aimbot, knife bot, zeus bot and
straight throw) write the same entries after `on.setup_command`, so their angles
replace yours on commands where they act. Native no-recoil also runs after it
and subtracts the recoil from whatever the entries hold, yours included. From
`on.command_finished` your angles replace every native write, and recoil is
not removed from them.

## Buttons

These exact button names are accepted:

```text
attack, attack2, jump, duck, forward, back, use, reload, use_or_reload,
move_left, move_right, turn_left, turn_right, speed, zoom, score, inspect
```

Numeric button masks are not accepted. An unknown name raises
`unknown CS2 command button` in every button method. A known name the game's
button table did not resolve raises
`command button did not resolve from the game's InputBitMask_t`. These names are separate from the virtual-key codes
accepted by [input](input.md).

## cmd:button_down

```text
cmd:button_down(name: string) -> boolean
```

Tests the held state together with the command's subtick change state. A
release transition can therefore make this true. Use `button_held` when only
the held state matters. Returns `false` when the needed data cannot be read.

## cmd:button_held

```text
cmd:button_held(name: string) -> boolean
```

Reads only the command's held-button state. This is command intent after binds
and other input work, not a physical keyboard query.

Returns `false` when the held state cannot be read.

## cmd:set_button

```text
cmd:set_button(name: string, down: boolean = false) -> no values
```

Sets or clears the held-button state for this dispatch. `down` follows Lua
truthiness. `false`, `nil` or an omitted value clears it. Any other value sets
it. Existing subtick transitions are not removed, so clearing a held button
does not guarantee that `button_down` becomes false.

The call returns no success flag. Unavailable held-button data is not reported
as a write error.

The example below adds crouch while the command's walk button is held:

```lua
on.setup_command(function(cmd)
    if cmd:button_held("speed") then
        cmd:set_button("duck", true)
    end
end)
```

## cmd:subtick_press

```text
cmd:subtick_press(name: string, when: number) -> no values
```

Adds a press record at a fraction of the current tick. `name` is `attack`,
`attack2`, `jump` or `duck`; other buttons raise an error. Time movement keys
with [`cmd:set_move_schedule`](#cmdset_move_schedule), which carries them as
movement: a timed direction press can make the server drop every timed record
in the command. `when` must be finite and fit a 32-bit float. The fraction is rounded to the nearest `1 / 64`, then
clamped to `1 / 64` through `63 / 64`.

A request at `0` is placed at `1 / 64`. A request at `1` is placed at `63 / 64`.
Finite values outside `0`-`1` are also clamped. Invalid numbers, unavailable
command data, unavailable or failed allocation, and exhausted entry capacity
raise an error.

This adds a press without clearing held state, removing earlier transitions
or adding a release. It consumes the command's shared 32-entry capacity.
Repeated calls can add repeated entries, including when one command is
processed more than once. To time a new press, the button must be up before
that fraction. Adding a press cannot delay a button that is already held.

## cmd:action_schedule

```text
cmd:action_schedule() -> table | nil
```

Returns the button changes the command carries inside its tick, in order: an
array of tables with `button` (a [button name](#buttons)), `pressed` (`true` for
a press, `false` for a release) and `when`, the fraction of the tick from `0` to
`1`. An empty array means no timed changes. The buttons are `attack`,
`attack2`, `jump` and `duck`: timed direction keys are movement, which the
command carries as its movement axes rather than as button changes. Returns
`nil` with `why.last()` set when the command's timing records cannot be read:
`no_base` when the records are unreadable, `count_invalid` when their
count is out of range, or `step_malformed` when one of them carries something
the server would refuse.

## cmd:set_button_schedule

```text
cmd:set_button_schedule(name: string, down: boolean, changes: table[]) -> no values
```

Replaces every timed change of `jump` or `duck` in this command. `down` is the
button's state at the start of the tick, and `changes` lists its presses and
releases after that, each a table with `when` and `pressed`, in the shape
`cmd:action_schedule` returns. Up to 32 changes, each at a later `when` than the
one before. The button leaves the tick as its last change set it, or as `down`
with no changes, and the next command starts from that state.

`when` is rounded to the nearest `1 / 64` of the tick. Two changes that round to
the same point, a change that rounds to `1`, and a change that does not change
the button (a press while it is down) raise an error. Other buttons raise an
error: time them with [`cmd:subtick_press`](#cmdsubtick_press). Native bhop, air
duck and the movement assists (jump bug, edge bug, edge jump, long jump and the
landing assists) leave a button a script scheduled alone for that command: an
assist that needs it does not act on that command.

```lua
-- tap jump for the middle half of the tick.
on.setup_command(function(cmd)
    if cmd:button_held('speed') then
        cmd:set_button_schedule('jump', false, {
            { when = 0.25, pressed = true },
            { when = 0.75, pressed = false },
        })
    end
end)
```

The command's other timed changes are kept. A command holds 32 timed records
in total, shared by the game, native features and scripts; a schedule that no
longer fits raises an error and changes nothing.

## Jump-throws

The server keeps a jump-throw consistent on its own. About 0.1 seconds after a
jump it records your eye angles, eye position and velocity, and a grenade
released within 0.2 seconds after that is thrown from the recorded values
rather than the live ones. Moving on the ground before the release discards
the record. A timed release inside the jump's own tick is therefore not what
makes a jump-throw repeatable. Jump on one command and release the throw
button with [`cmd:set_button`](#cmdset_button) on a later command in that
window.

## cmd:set_move_schedule

```text
cmd:set_move_schedule(segments: table[]) -> no values
```

Sets the movement axes for parts of the tick. Each segment is a table with
`when`, `forward` and `side`, and holds from its `when` until the next
segment's. The first segment starts at `0`; up to 32 segments, each at a later
`when`, rounded to `1 / 64` of the tick like `cmd:set_button_schedule`. Axes
follow [`cmd:set_move`](#cmdset_move): each is finite and inside `[-1, 1]`.

```lua
-- strafe left for the first half of the tick, then right.
on.setup_command(function(cmd)
    local forward = cmd:move()
    if forward == nil then return end
    cmd:set_move_schedule({
        { when = 0, forward = forward, side = 1 },
        { when = 0.5, forward = forward, side = -1 },
    })
end)
```

The last segment's axes become the command's movement, as `cmd:set_move` would
set them, and the changes inside the tick are sent as timed records. A later
`cmd:set_move` in the same pass replaces the schedule with one value for the
whole tick. Invalid segments raise an error and change nothing.

## cmd:move_schedule

```text
cmd:move_schedule() -> table | nil
```

Returns the movement axes the server moves the player on during this tick, in
the shape [`cmd:set_move_schedule`](#cmdset_move_schedule) takes: an array of
segments with `when`, `forward` and `side`, starting at `when = 0`, with one
segment for each change. Changes inside the tick come from movement keys
pressed or released partway through it, or from a schedule a script or a
native feature wrote. `when` is the fraction of the tick, rounded to `1 / 64`
the way the server rounds it. The axes are the ones the server uses, already
rounded to whole numbers when the server has `sv_quantize_movement_input` on,
so passing the result back to `cmd:set_move_schedule` moves the player the same
way.

In `on.setup_command` this is the player's own command. In
`on.command_finished` it includes every native feature's movement.

Returns `nil` with `why.last()` set when the tick cannot be replayed:
`seed_unavailable` when the previous command's movement did not read,
`steps_unreadable` or `steps_unordered` for the command's timed records,
`view_unavailable`, `buttons_unavailable`, `pair_unavailable`,
`cvar_unavailable` when the server's movement settings did not read, or
`basis_undecidable` for a view pointing straight up or down.

## cmd:view_schedule

```text
cmd:view_schedule() -> table | nil
```

Returns the view angles the server builds this tick's movement direction from,
in the shape [`cmd:set_view_schedule`](#cmdset_view_schedule) takes: an array
of segments with `when` and `angles` (a vec3). Each segment covers the part of
the tick that ends at its `when`, and the last one ends at `1`. When the player
turns the mouse during a tick, the parts of the tick before and after the
turn move along different angles; this returns each part.

With the server's `sv_subtick_movement_view_angles` off, the whole tick moves
along the outer view and this returns one segment. Returns `nil` the same way
[`cmd:move_schedule`](#cmdmove_schedule) does.

```lua
-- record the movement of every command, exactly as the server runs it.
local recording = {}
on.setup_command(function(cmd)
    local moves, views = cmd:move_schedule(), cmd:view_schedule()
    if moves and views and cmd.number then
        recording[cmd.number] = { moves = moves, views = views }
    end
end)
```

## cmd:set_view_schedule

```text
cmd:set_view_schedule(segments: table[]) -> no values
```

Sets the view angles each part of the tick moves along. Each segment is a table
with `when` and `angles` (a vec3), and covers the part of the tick from the
previous segment's `when` up to its own. Up to 32 segments, each at a later
`when`, rounded to `1 / 64` of the tick. Every segment but the last must
round to less than `1`, and the last must round to `1`. Angles must be finite.

The command's timed records keep their buttons and movement axes; only the
direction they move in changes. The outer view, the camera and the aim are not
changed. Together with `cmd:set_move_schedule` this replays a recorded
command's movement exactly.

Available only in `on.command_finished`: the angles are stored relative to the
command's final outer view, which native features such as anti-aim write after
`on.setup_command`. The server reads these angles only while its
`sv_subtick_movement_view_angles` is on, so the call raises an error when it is
off, as well as for invalid segments, unreadable movement settings or a full
command.

```lua
-- replay movement recorded as in the cmd:view_schedule example, keyed by the
-- command number it should go out on.
local replay = {}
on.command_finished(function(cmd)
    local recorded = cmd.number and replay[cmd.number]
    if not recorded then return end
    cmd:set_move_schedule(recorded.moves)
    cmd:set_view_schedule(recorded.views)
end)
```

## cmd:move

```text
cmd:move() -> (forward: number, side: number) | nil
```

Returns the current forward and side movement axes. Returns one `nil` when the
command does not expose them.

Positive forward means forward. Negative means backward. Positive side means
left. Negative means right. An absent axis reads as `0`.

## cmd:set_move

```text
cmd:set_move(forward: number, side: number) -> no values
```

Sets both movement axes. Each value must be finite and inside `[-1, 1]`.

These are normalized inputs, not a requested speed in world units. Invalid
values raise an error. The call also updates the four directional held buttons
and clears their subtick change states.

An axis above `0.01` selects its positive direction. Below `-0.01` selects its
negative direction. From `-0.01` through `0.01`, neither direction is selected,
while the supplied analog value is retained.

This replaces any earlier movement sequence for the current command pass.
Unavailable movement data is not reported as a write error.

```lua
on.setup_command(function(cmd)
    local forward, side = cmd:move()
    if forward == nil then return end

    cmd:set_move(forward, 0)
end)
```

## cmd:move_toward

```text
cmd:move_toward(world_yaw: number) -> no values
```

Makes the player move at full speed toward a world direction, given as a yaw
in degrees. This is the writer auto peek's return uses. It picks the channel
the server's `sv_subtick_movement_view_angles` and `sv_quantize_movement_input`
leave live, so the heading holds whichever way the camera or anti-aim faces.
The command's movement keys are set to match the heading and `speed` is
released, so keys the player holds do not add to it.

Available only in `on.command_finished`. The heading is written relative to
the command's final view angles, and native features that change those angles
(anti-aim, the aimbot) run after `on.setup_command`. Calling it from any other
callback raises an error. A non-finite yaw raises an error, and so does a
refusal, with the reason in the message: the server's movement settings are
unreadable, the command's movement or view data is unavailable, or the command
has no room left for timing records.

```lua
-- walk toward the world origin while walk is held.
on.command_finished(function(cmd)
    if not cmd:button_held('speed') then return end
    local me = entity.local_player()
    if me == nil then return end
    local here = player.origin(me)
    if here == nil then return end
    cmd:move_toward(math.deg(math.atan2(-here.y, -here.x)))
end)
```

## Callback placement

[`on.setup_command`](../events.md#onsetup_command) runs before Dylanhook's
command features. [`on.command_finished`](../events.md#oncommand_finished) runs
after them.

Both receive the same command object shape and callback-scoped lifetime. The game
can still process the command afterward. `command_finished` does not mean a
command was sent or a shot fired.


## cmd.timing

```text
cmd.timing: table
```

A copied timing record with `prediction_phase`, `command_tick_base`,
`last_snapshot_tick` and `last_executed_command`. Unavailable clocks are absent.
These describe the command's native clock sample, not the current server time.
`prediction_phase` is `"before_pass"`, `"after_pass"`, `"stale"` or `"unknown"`.

## cmd.kinematics

```text
cmd.kinematics: table | nil
```

The copied local movement state from the start of this command. Repeated
callbacks for that command use the same starting sample. Returns `nil` when
that sample is unavailable; it never substitutes current predicted state.

Fields: `origin`, `velocity`, local hull `mins` and `maxs`, `flags`, `move_type`,
`water_level`, `surface_friction`, `stamina`, `duck_amount`, `ducking` and
`walking`. Optional fields are `ground_entity`, `ladder_normal` and
`eye_position`. A missing ground entity can mean world geometry or airborne.

## cmd.weapon_spread

```text
cmd.weapon_spread: table | nil
```

A copied record of the local weapon's spread for the round this command would
fire, computed the way the native hit-chance check computes it on this pass:
the state the round fires from once this command's own movement has run -- its
speed, air time and walk state after the command's input, and the weapon's
recovery one step on. Read it in `on.setup_command` to decide what
[`cmd:set_target_policy`](#cmdset_target_policy) should ask of that round.
Returns `nil` with `why.last()` set when the player is dead or has no weapon,
when the command jumps, lands or walks off a ledge (the native check holds its
round on those commands too), or when the movement or the weapon's accuracy
data is unavailable.

| Field | Meaning |
| --- | --- |
| `inaccuracy` | The inaccuracy now: stance, recoil and landing recovery, plus movement, air and turning. |
| `spread` | The weapon's base spread. |
| `settled_inaccuracy` | The inaccuracy once recoil, landing and scoping recovery finish, holding this movement. |
| `rest_inaccuracy` | The lowest this stance and firing mode allow: recovery finished, standing still, and at the top of the jump when airborne. |

`inaccuracy + spread` is the tangent of the cone's half-angle, so
`(rest_inaccuracy + spread) / (inaccuracy + spread)` says how close this round
is to the most accurate one available without changing stance. The server's
`weapon_accuracy_nospread` and `weapon_accuracy_forcespread` apply to every
field. When the server enables strafing inaccuracy, this uses the command's
view direction, while the native check uses the chosen aim point.

## cmd.can_fire

```text
cmd.can_fire: boolean | nil
```

Whether pressing `attack` on this command puts a round out. This is the
server's own check, asked on the command's tick: the weapon's cooldown, freeze
time, defusing, the player's state, and the semi-auto lock that wants
`attack` released between shots. The rage aimbot fires off the same answer.

With the R8 a press only starts the hammer, and the round leaves 13 ticks
later if `attack` stays down. `can_fire` is `true` only on the command
the hammer lands on. Use [`cmd.hammer_pull`](#cmdhammer_pull) for the rest of
the pull.

Returns `nil` with `why.last()` set when the player is dead, has no weapon, the
command has no tick base yet, or a weapon field can't be read. With the R8 it
is also `nil` (`hammer_unknown`) when the hammer's position isn't known, which
lasts until a command goes out with every attack and reload button up. `nil` is falsy,
so `if cmd.can_fire then` treats an unknown gate as shut.

```lua
-- tap attack whenever a press would fire while mouse 4 is held.
on.setup_command(function(cmd)
    if not input.down(key.mouse4) then return end
    if cmd.can_fire or cmd.hammer_pull then
        cmd:set_button("attack", true)
    end
end)
```

## cmd.hammer_pull

```text
cmd.hammer_pull: boolean | nil
```

R8 only. `true` when pressing `attack` on this command cocks or holds the
hammer without firing. Keep `attack` down through these commands and the round
leaves on the one where `can_fire` turns `true`. Letting go drops the hammer.
Always `false` for other weapons. Returns `nil` the same way `can_fire` does.

## cmd.can_fire_secondary

```text
cmd.can_fire_secondary: boolean | nil
```

Whether pressing `attack2` on this command reaches the weapon's secondary
attack, by the server's own secondary cooldown. With the R8 that is firing from
rest, or dropping a cocked hammer. Returns `nil` with `why.last()` set when the player is
dead, has no weapon, the command has no tick base yet, or the gate can't be
read.

## cmd:set_target_policy

```text
cmd:set_target_policy(pawn: entity, options: table | nil) -> true | nil
```

Sets this command pass's native rage targeting policy for one player pawn.
Available only in `on.setup_command`. This changes neither saved weapon settings
nor player-list preferences. Native feature activation and target eligibility
still apply.

| Option | Type | Meaning |
| --- | --- | --- |
| `ignore` | boolean | Exclude the pawn from rage selection for this pass. |
| `priority` | boolean | Consider it before ordinary targets. |
| `hitboxes` | string[] | Enabled hitbox groups. An empty array disables every group. |
| `multipoint` | string[] | Groups that generate extra points. |
| `point_scale` | number | Point scale from 0 to 100. |
| `minimum_damage` | number or false | Native threshold from 1 to 110, or disable the gate. |
| `hitchance` | number or false | Native threshold from 0 to 100, or disable the gate. |

Groups are `head`, `neck`, `chest`, `stomach`, `pelvis`, `arms`, `legs` and
`feet`. Damage values up to 100 require that much damage, capped at the target's
expected health. Values 101 through 110 require a kill plus 1 through 10 damage.
With the weapon's `force shoot` on, a round below the hit-chance threshold still
fires once waiting can't make it more accurate.

Omitted fields use the native weapon/player preferences. A later call for the
same pawn replaces the entire request. Pass `nil` to remove it. Requests expire
after this command pass, including repeated passes with the same command number.
They do not change collision or remove other players as physical blockers.

Returns `true` on success, or `nil` with [`why.last()`](why.md#whylast) set to
`target_policy_invalid_target` for an unavailable pawn or
`target_policy_capacity` for full native player capacity. Malformed options raise
an error before the request changes; option values outside their range raise
`target_policy_invalid_hitboxes`, `target_policy_invalid_point_scale`,
`target_policy_invalid_minimum_damage` or `target_policy_invalid_hitchance`.
The call charges two native-work units. Unsafe mode keeps the same lifetime and
native resource contracts.

## cmd:override_setting

```text
cmd:override_setting(setting: native_setting, value: boolean | number | string | color | boolean[]) -> true | nil
```

Overrides a [native setting](native_settings.md) for this command only.
Available only in `on.setup_command`. The setting must support per-command
overrides; `setting:info().command_override` says whether it does. The value
uses the same representation as `setting.value` and is validated against the
setting's domain. The override applies only when the callback completes, and
never changes the saved value or other commands.

Among the settings that accept one are anti-aim's enable, auto peek, fast walk,
straight throw, quick stop, air duck, bhop, circle strafe, ramp boost, fast
ladder, standalone air stop, the air strafe settings and the seven movement
assists: edge bug, jump bug, edge jump, stop at edge, long jump, no fall damage
and reduce land penalty. `command_override` is the authority. A
feature turned off for one command runs its own off path on that command, the
way switching it off would: auto peek drops its recorded cover, and anti-aim
does not fake that command and hands the camera back. Turned on for one command, a
feature acts on it with its saved options. Set the override on every call for
the commands it should cover.

A command holds up to 64 overrides. Returns `true`, or `nil` with `why.last()`
set to `setting_reference_expired`, `setting_not_found`, `setting_domain_changed`
or `setting_command_limit` when the reference or its domain changed or the table
is full. An unsupported setting,
an invalid value or another callback raises an error. Costs two native work units.

## cmd.decision

```text
cmd.decision: table | nil
```

Copies the native rage selection for this command pass. Usually read in
`on.command_finished`; it is `nil` before selection or when no target was chosen.
The same record is included in `on.command_committed`'s copied observation.

| Field | Type | Meaning |
| --- | --- | --- |
| `dispatch_id` | string | Exact identifier for this command pass. |
| `session_id` | string | Session that produced the command. |
| `target` | entity | Selected pawn identity. |
| `point` | vec3 | Selected world point. |
| `origin` | vec3 or nil | Resolved native shot origin. Absent during provisional selection. |
| `damage` | number | Native damage estimate for the reported point. |
| `bone` | integer | Selected runtime bone index. |
| `geometry_resolved` | boolean | Whether the reported point passed native commit geometry checks. |
| `policy` | table | Effective values for the seven options above. |

This is a selection observation, not proof that a shot fired or hit. A provisional
point can support native movement planning while the actual shot origin is
unavailable. Later native checks can still refuse the command or shot.
