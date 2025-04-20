# Trace

Cast a line or shape, check visibility, or sample a bullet path. A clear path
is a successful result. An unavailable query returns `nil`.

Line, visibility, smoke, hull and sphere queries run in `on.setup_command`,
`on.command_finished`, `on.frame_stage`, `on.game_event` and `on.override_view`.
Bullet, damage and surface queries run only in the two command callbacks.
`trace.grenade` runs only in `on.frame_stage` and `on.game_event`. Other
contexts raise an error.

An unavailable or invalid query result returns one `nil` and sets
[`why.last()`](why.md#whylast). Result records are plain Lua tables containing
copied values. Vector arguments require `vec3` userdata and use world units.
`from`, `to` and shape arguments are required. Every query and `trace.request`
share one geometry rule: coordinates are finite, the distance from `from` to `to`
is finite, hull bounds are finite, and a sphere radius is finite and greater than
zero. Invalid argument types and geometry outside that rule raise an error. No
query returns an error string as a second result.

## Options

Line, visibility, hull and sphere queries accept an optional table. Omitting it
or passing `nil` uses the defaults:

| Option | Type | Description |
| --- | --- | --- |
| `mask` | string | Interaction mask. The default depends on the query. |
| `filter` | string | `"standard"`. The default and only supported filter. |
| `skip` | entity or nil | First entity to ignore. Defaults to `nil`. |
| `skip_second` | entity or nil | Second entity to ignore. Defaults to `nil`. |

`skip` and `skip_second` take entity userdata and must still resolve when the
query runs. Stale identities, unknown masks and unknown filters raise an error.
For these four queries, pass the local pawn as `skip` to ignore it. A missing
or `nil` option uses its default.

The mask constants have these string values:

| Constant | Value | Collision query |
| --- | --- | --- |
| `mask.visibility` | `"visibility"` | World and prop sight lines, excluding player bodies. |
| `mask.shot` | `"shot"` | Bullet collision layers. |
| `mask.solid` | `"solid"` | Solid world geometry, props and player bodies. |
| `mask.thrown_grenade` | `"thrown_grenade"` | Thrown grenade collision layers. |
| `mask.molotov_ground` | `"molotov_ground"` | Ground contact for a burning surface. |
| `mask.melee` | `"melee"` | Melee collision layers. |

## trace.visible

```text
trace.visible(from: vec3, to: vec3, options: table | nil = nil) -> boolean | nil
```

Returns `true` for a clear line, `false` for a hit or a start inside solid, and
`nil` when unavailable or invalid. The default mask is `mask.visibility`, which
checks world and prop obstructions without including player bodies.

## trace.line

```text
trace.line(from: vec3, to: vec3, options: table | nil = nil) -> table | nil
```

Casts a line from `from` to `to`. The default mask is `mask.visibility`.
Returns this table, or `nil` when the query is unavailable or invalid:

| Returned field | Type | Description |
| --- | --- | --- |
| `fraction` | number | Distance reached as a fraction in `0..1`. |
| `hit` | boolean | Whether `fraction < 1` or `started_solid` is true. |
| `started_solid` | boolean | Whether the query began inside solid geometry. |
| `end_pos` | vec3 | Copied end position of the cast. |
| `normal` | vec3 | Outward surface normal, or a zero vector when no surface normal is reported. |
| `entity` | entity or nil | Hit entity when available. World geometry can be hit without an entity. |

Use `hit` to test for an obstruction; `fraction == 1` can still accompany
`started_solid`. If a hit entity cannot supply a valid identity, the whole
query returns `nil`. A world hit with no entity still returns the table.

```lua
local overhead

on.frame_stage(function()
    overhead = nil
    local me = entity.local_player()
    if not me then return end

    local eye = player.eye_position(me)
    if not eye then return end

    overhead = trace.line(eye, eye + vec3(0, 0, 128), {
        mask = mask.solid,
        skip = me,
    })
end)

on.session_changed(function()
    overhead = nil
end)

on.paint(function()
    if overhead and overhead.hit then
        render.text(24, 80, "obstruction overhead", color.white)
    end
end)
```

## trace.smoke

```text
trace.smoke(from: vec3, to: vec3) -> boolean | nil
```

Runs the engine's volumetric smoke line-of-sight test. `true` means the segment
is blocked by the smoke-volume visibility query; `false` is a completed query
that did not reach that threshold. An unavailable query returns `nil`, not
`false`, and records `why.last()`.

This uses the current voxel state, including the cloud's growth, fading and
opened holes. It is not a sphere around the grenade. Solid voxels inside an
active smoke volume also block this test, so `true` does not by itself prove
that smoke particles occupy the whole segment. It does not replace a world
collision trace outside smoke volumes.

Exactly two `vec3` arguments are required. Each coordinate must be finite and
within `-1000000..1000000` world units. There is no mask or skip-entity option.
A zero-length segment returns `nil` with a reason.

`trace.smoke` and `trace.smoke_density` cannot run in paint. Collect the value
from a supported game callback and draw the copied result later.

## trace.smoke_density

```text
trace.smoke_density(from: vec3, to: vec3) -> number | nil
```

Returns the engine's accumulated, fade-adjusted voxel density along the segment.
The result is nonnegative and can exceed one. It is not a percentage, a distance
in smoke, or the normalized score used by `trace.smoke`.

The density query handles solid voxels using neighboring smoke density, making
it distinct from the line-of-sight query above. Do not reproduce `trace.smoke`
by comparing this result with a threshold. Its argument, callback and failure
rules are the same as `trace.smoke`.

## trace.hull

```text
trace.hull(from: vec3, to: vec3, mins: vec3, maxs: vec3, options: table | nil = nil) -> table | nil
```

Sweeps an axis-aligned hull. `mins` and `maxs` are offsets from the swept point,
and each minimum component must be finite and no greater than its matching
maximum. Invalid bounds raise an error. The default mask is `mask.solid`. Returns the
same table as `trace.line`, or `nil` when unavailable or invalid.

## trace.sphere

```text
trace.sphere(from: vec3, to: vec3, radius: number, options: table | nil = nil) -> table | nil
```

Sweeps a sphere with a finite radius greater than zero. Invalid radii raise an
error. The default mask is `mask.melee`. Returns the same table as `trace.line`,
or `nil` when unavailable or invalid.

## trace.bullet

```text
trace.bullet(from: vec3, to: vec3, options: table | nil = nil) -> table | nil
```

Simulates a round from a player's active weapon in `on.setup_command` or
`on.command_finished`. `to - from` supplies the direction. The cast distance is
the weapon's range, even when `to` is closer. The shooter and its weapon are
skipped. For a weapon that fires several pellets a round, the query traces the
one line it is given, as one pellet; damage is that pellet's.

| Option | Type | Description |
| --- | --- | --- |
| `mode` | string or nil | `"through_walls"` (the default) allows up to four penetrations; `"direct"` uses a limit of one and can still report `penetrated = true`. |
| `shooter` | entity or nil | The player pawn whose active weapon fires. Defaults to the local pawn. Use another player to ask what their weapon would do to you. |
| `target` | entity or nil | Price the round against this player pawn alone, passing everything else. Without it, the round stops at the first player it reaches, including teammates. |

Any other `mode` raises an error. A `shooter` or `target` that is not a player
pawn, or no longer exists, raises an error. Check `penetrated == false` when you
need a hit with no penetration.

| Returned field | Type | Description |
| --- | --- | --- |
| `damage` | number | Predicted health damage after distance, penetration, hitgroup and armor effects. |
| `penetrations` | integer | Penetrations used by the successful hit: `0..4`, or `0..1` in `"direct"` mode. |
| `penetrated` | boolean | Whether `penetrations` is nonzero. |
| `reached` | boolean | Whether the shot reached a player with at least one point of damage. |
| `entity` | entity or nil | Hit player's pawn identity, when available. |
| `hitgroup` | integer or nil | The game's [hitgroup](#hitgroups) for the struck hitbox, when a player was hit. |
| `lethal` | boolean or nil | Whether damage covers the hit player's expected health: networked health minus damage this client has already committed but the server has not yet reported. `false` when no player was hit. `nil` when that health is unknown, which includes the local player and teammates. |

A miss or damage below one point returns a table with zero damage and
penetrations, all three booleans `false` and no entity. A dead or unarmed
shooter, missing weapon data and simulation failures return `nil` with a reason.

### Hitgroups

Every hitgroup in the API uses the game's numbering:

| Value | Hitgroup |
| --- | --- |
| `-1` | invalid |
| `0` | generic |
| `1` | head |
| `2` | chest |
| `3` | stomach |
| `4` | left arm |
| `5` | right arm |
| `6` | left leg |
| `7` | right leg |
| `8` | neck |
| `9` | unused |
| `10` | gear |
| `11` | special |

```lua
local exposure = 0

on.setup_command(function(cmd)
    exposure = 0
    local me = entity.local_player()
    local eye = me and player.eye_position(me)
    local team = me and player.team(me)
    local pawns = entity.get_all_by_class('C_CSPlayerPawn')
    if eye == nil or team == nil or pawns == nil then return end

    for _, pawn in ipairs(pawns) do
        if pawn ~= me and player.is_alive(pawn) and player.team(pawn) ~= team then
            local their_eye = player.eye_position(pawn)
            local threat = their_eye and trace.bullet(their_eye, eye, { shooter = pawn, target = me })
            if threat and threat.reached then exposure = math.max(exposure, threat.damage) end
        end
    end
end)

on.paint(function()
    if exposure > 0 then
        render.text(24, 24, string.format('exposed: %.0f damage', exposure), color.red)
    end
end)
```

`from` is used as supplied. In command callbacks, [`player.eye_position`](entity.md#playereye_position)
can return the local pawn's command-start sample, or `nil` when unavailable.
That sample is not the separately timed origin of a particular attack.

## trace.scale_damage

```text
trace.scale_damage(target: entity, damage: number, hitgroup: integer, options: table | nil = nil) -> number | nil
```

Returns the health a round of `damage` takes from `target` when it lands on
`hitgroup`: the weapon's hitgroup multiplier, the server's damage scale and the
target's armor and helmet, the same stages `trace.bullet` ends with. `damage` is
the value after range falloff and penetration. Runs in `on.setup_command` or
`on.command_finished`.

`hitgroup` uses the numbering in [Hitgroups](#hitgroups) and must be an
integer from `0` to `11`. `damage` must be finite and zero or greater. The only
option is `shooter`, whose active weapon supplies the multipliers; it defaults
to the local pawn. A target that is not a live player pawn, a dead or unarmed
shooter, and unreadable armor or weapon data return `nil` with a reason.

```lua
local one_tap = {}

on.setup_command(function(cmd)
    local me = entity.local_player()
    local info = me and player.weapon_info(me)
    local pawns = entity.get_all_by_class('C_CSPlayerPawn')
    if info == nil or info.damage == nil or pawns == nil then return end

    one_tap = {}
    for _, pawn in ipairs(pawns) do
        if pawn ~= me and player.is_alive(pawn) then
            local head = trace.scale_damage(pawn, info.damage, 1)
            local health = player.health(pawn)
            if head and health and head >= health then one_tap[#one_tap + 1] = pawn end
        end
    end
end)
```

## trace.surface_probe

```text
trace.surface_probe(from: vec3, to: vec3) -> table | nil
```

Reports the first contact and penetration result for the local active weapon
in `on.setup_command` or `on.command_finished`. `to - from` supplies the
direction and the weapon's range supplies the distance. The local pawn and
weapon are skipped. A player behind the surface is not required.

| Returned field | Type | Description |
| --- | --- | --- |
| `entry` | vec3 | Copied first contact position. Meaningful when `contact` is true. |
| `exit` | vec3 | Copied exit position. Use it when `penetrated` is true. |
| `damage_after` | number | Remaining damage after the reported penetration, before player hitgroup and armor effects. Use it when `penetrated` is true. |
| `penetrations` | integer | Penetration count in `0..4`. |
| `contact` | boolean | Whether the probe reached a surface or entity. |
| `direct_player` | boolean | Whether its first contact was a player. |
| `penetrated` | boolean | Whether passage through a surface left at least one point of damage. |

No contact returns a valid table with zero positions and numeric fields, and
all three booleans `false`. Unavailable player or weapon state and failed
queries return `nil`; `why.last()` gives the reason. Using the same point for
`from` and `to` also returns `nil`.

## trace.grenade

```text
trace.grenade(throw: table) -> table | nil
```

Predicts where the grenade you are holding would go if thrown from a pose you
describe, without throwing it. This is the same simulation the native grenade
trajectory draws, with the same collisions, bounces, players and server
settings, and it works whether that visual is on or off. Use it to show where
a saved lineup lands.

| Field | Type | Meaning |
| --- | --- | --- |
| `eye_position` | vec3 | Where the throw starts: the thrower's eye. Required. |
| `center` | vec3 | The centre of the thrower's collision box (origin plus the middle of `mins` and `maxs` from [`cmd.kinematics`](cmd.md#cmdkinematics)). Required. |
| `angles` | vec3 | The angles the grenade leaves along: the view, plus any aim punch. Required. |
| `velocity` | vec3 | The thrower's velocity, part of which the grenade keeps. Defaults to standing still. |
| `strength` | number | Throw strength from `0` to `1`: `1` is a full throw, `0.5` a lob, `0` a drop. Defaults to `1`. |

An unknown field, a missing required field, a non-finite vector or a strength
outside `0`-`1` raises an error. The grenade type and its throw speed are the
held grenade's.

Returns a table with `points`, `contacts`, `end_position` and `outcome`, the
same fields [`game.grenade_path`](game.md#gamegrenade_path) returns apart from
`id`. Returns `nil` with `why.last()` set to `no_held_grenade` when the local
player is dead or not holding a grenade, `weapon_unreadable`,
`world_unreadable` when a server setting could not be read, `sweep_unavailable`,
`entity_unreadable`, `capacity_exceeded` or `simulator_unavailable`.

```lua
-- where does this lineup land? computed once, drawn every frame.
local lineup = {
    eye_position = vec3(-1200, 640, 64),
    center = vec3(-1200, 640, 36),
    angles = vec3(-40, 120, 0),
}
local landing
on.frame_stage(function(stage)
    if landing == nil then
        local path = trace.grenade(lineup)
        if path then landing = path.end_position end
    end
end)
```

## trace.request

```text
trace.request(kind: string, from: vec3, to: vec3, options: table | nil = nil) -> trace_request | nil
```

Queues a trace that runs later on the game thread, and returns a handle to
collect its result in a later callback. `kind` is `"line"`, `"hull"` or
`"sphere"`. Available in any active callback except unload, including paint;
setup and unload raise an error.

| Option | Type | Meaning |
| --- | --- | --- |
| `mask` | string | Interaction mask, as in [Options](#options). Lines default to `visibility`, hulls to `solid` and spheres to `melee`. |
| `filter` | string | Only `"standard"` is accepted. |
| `skip`, `skip_second` | entity | Identities the trace ignores. |
| `mins`, `maxs` | vec3 | Required for hulls. |
| `radius` | number | Required for spheres. |

Geometry follows the rule at the top of this page. Malformed input, an unknown
option value or the wrong callback raises an error. Every other refusal returns
`nil` and sets `why.last()` to `trace request refused: <reason>`: `session_unavailable`,
`session_changed`, `skip_expired`, `queue_full`, `result_limit`, `runtime_unavailable`,
`generation_inactive` or `identity_exhausted`. `context_unavailable` and
`invalid_input` raise an error with the same text instead. A script holds at most
32 requests. A line costs one native
work unit and a shape costs two.

```text
trace_request.id: string
trace_request:status() -> string
trace_request:result() -> table | false | nil
trace_request:cancel() -> boolean
trace_request:release() -> boolean
```

`status()` returns `pending`, `ready`, `refused`, `expired` or `cancelled`.
For a refusal, expiry or cancellation it also sets [`why.last()`](why.md#whylast)
to the reason below. `result()` returns the result table once the status is
`ready`, and `false` while the request is pending. A refused, expired, cancelled
or released request returns `nil` and sets `why.last()` to its reason. Each call
costs one unit.

| Reason | Meaning |
| --- | --- |
| `session_changed` | The map changed before the trace ran or finished. |
| `generation_inactive` | The script unloaded or reloaded before the trace ran. |
| `cancelled` | `cancel()` withdrew the request. |
| `released` | The handle was already released. |
| `entity_system_unavailable` | The entity list was unavailable when the skip entities were resolved. |
| `skip_expired` | A `skip` or `skip_second` entity no longer existed when the trace ran. |
| `invalid_input` | The queued query was malformed. |
| `native_unavailable_or_invalid` | The game's trace was unavailable or failed. |
| `hit_identity_unavailable` | The trace struck an entity whose identity could not be read. |

The result has the same `fraction`, `hit`, `started_solid`, `end_pos`, `normal`
and `entity` fields as `trace.line`, plus `kind`, `from`, `to`, the
`requested_session_id` and, from paint, `requested_capture_id`. It records when
the trace ran as `execution_session_id`, `execution_stage`, and `execution_tick`
and `execution_time` when those clocks exist. A map change expires pending
requests.

`cancel()` withdraws a request that has not started and returns whether it did.
`release()` frees its slot and returns whether the handle was still held.
Garbage collection and unloading release requests automatically.

## Cost

`trace.visible` and `trace.line` cost one native work unit.
`trace.hull`, `trace.sphere` and `trace.scale_damage` cost two. `trace.smoke`,
`trace.smoke_density`, `trace.bullet` and `trace.surface_probe` cost 32.
`trace.grenade` costs 128, plus one per started 16 points and contacts.

These costs use the current callback's [native-work allowance](../limits.md#native-calls).
Standard mode enforces the allowance. Unsafe mode only measures it.

Tables and vectors can be saved between callbacks. Their copied values remain
unchanged, while any entity identity inside a result can expire.
