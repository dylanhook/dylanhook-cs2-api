# Entities and players

Use `entity` to find an entity and `player` to read a player's state. Player
functions take a pawn unless their signature asks for a controller.

Keep the entity userdata when tracking something between callbacks. An entity
index alone can be reused after the old entity disappears.

Keeping the userdata does not keep the entity alive. Two entity values compare
equal with `==` only when they refer to the same entity identity and observed
session. A completed render callback uses its captured session; live reads reject
an expired session even if the native handle bits have been reused.

## When values are available

`on.paint` reads copied state for its frame. This page calls
`on.setup_command`, `on.command_finished`, `on.command_committed`, `on.anti_aim`,
`on.frame_stage`, `on.game_event`, `on.override_view` and
[`console.register`](console.md#consoleregister) command callbacks **game
callbacks**. They can read live entities. The two command callbacks also
have a sample of the local pawn from the start of the command.

[ESP value callbacks](esp.md) use the same copied world data as paint, without a
drawing surface. [Bones and hitboxes](pose.md) describes coherent pose reads.
On this page, paint-read availability also includes these render callbacks and
ESP value callbacks. A
requirement for a paint snapshot does not mean the callback can draw.

Above-menu paint, timers, menu callbacks, control changes, HTTP completions and
session changes share the current render snapshot while their render pass is
active. Normal unload cleanup can use that snapshot; shutdown cleanup cannot.
These callbacks never gain live entity access. Each method below
says whether an unavailable context returns `nil`, returns `false`, or raises
an error. None of these functions returns an error string as a second result.
[`why.last()`](why.md#whylast) supplies a reason for many unavailable reads;
not every `nil` supplies a new reason.

All listed arguments are required. Pass entity userdata where requested;
passing an index or `nil` raises an error. Returned vectors, strings and tables
are copies. They keep their values when saved, while entity identities inside
them can expire.

## entity.local_player

```text
entity.local_player() -> entity | nil
```

Returns the local player pawn. Paint uses its frame's local pawn, command
callbacks use their command's local pawn, and frame-stage and game-event
callbacks read the live local pawn.

Returns `nil` when no local pawn is available, including outside those
callbacks. A returned pawn is not a promise that the player is alive.

## entity.planted_c4

```text
entity.planted_c4() -> entity | false | nil
```

Returns the active planted bomb's identity from `on.paint` or a command callback.
Other contexts raise an error. Paint reads the current frame's captured bomb,
including while dead or spectating. Its first request returns `false` while
capture starts on the next frame.

Returns `nil` when there is no active bomb or its identity cannot be read, and
sets `why.last()`. A missing countdown clock does not prevent returning the identity.
For a timer, use [`game.bomb_snapshot`](game.md#gamebomb_snapshot), which returns
the deadlines and their matching clock together.

A paint call costs 1 native work unit. A command call costs 64.

## entity.players

```text
entity.players() -> table
```

Returns a fresh `1`-indexed array of alive player pawns from the current render snapshot.
The array contains up to 64 entries, includes the local pawn and teammates
when present, and can be empty. Calling it without a current render snapshot raises an error.

```lua
on.paint(function()
    for row, pawn in ipairs(entity.players()) do
        local name = player.name(pawn)
        local health = player.health(pawn)
        if name ~= nil and health ~= nil then
            local text = string.format("%s: %d hp", name, health)
            render.text(24, 80 + (row - 1) * 16, text, color.white)
        end
    end
end)
```

## entity.find_by_class

```text
entity.find_by_class(class: string, include_derived: boolean = false) -> entity | false | nil
```

Returns the first entity of an exact concrete schema class in `client.dll`.
For example, `"C_PlantedC4"`, `"C_Inferno"` or `"C_CSGameRulesProxy"`.
Set `include_derived` to `true` to include verified nonvirtual derived classes.
The default is exact matching. Designer names such as `"planted_c4"` are not
schema class names. Ambiguous or unsupported inheritance refuses the query.

Call from paint or a game callback. Paint uses copied class membership and
identities. Its first request returns `false` until the next capture, including
when the player is dead or spectating. Game callbacks query current entities.

No match, unavailable capture or a class that cannot be resolved returns `nil`
and sets `why.last()`. Invalid arguments and other callback contexts raise an
error. A class lookup does not select active gameplay state: use
`entity.planted_c4()` for the active bomb.

## entity.get_all_by_class

```text
entity.get_all_by_class(class: string, include_derived: boolean = false) -> table | false | nil
```

Uses the same exact class matching and callback rules as `find_by_class`.
Returns a fresh `1`-indexed array, ordered by entity index. An empty array is a
successful query with no matches; `false` means paint asked before the next
capture; `nil` means the query is unavailable or failed.
If a matching entity has no usable identity, the complete result is withheld
rather than returning a partial array. Check `why.last()` after `nil`.

```lua
on.paint(function()
    local fires = entity.get_all_by_class("C_Inferno")
    if fires == nil then return end
    render.text(24, 112, "fires: " .. #fires, color.white)
end)
```

The first use of each class costs 32 native-work units. A loaded script can
remember up to 128 class names. Each live query costs 64 units.
A paint query costs 1 unit plus 1 per started block of 512 captured entities;
both kinds cost 1 more per started block of 16 returned identities. Budget
exhaustion raises an error. Query once and reuse the result within the callback.

## entity.at

```text
entity.at(index: integer) -> entity | false | nil
```

Looks up an entity slot in paint or a game callback. Indices run from `0` through
`32766`, inclusive. An empty slot or unavailable entity system returns `nil`
and sets `why.last()`.

Paint requests copied entity membership and returns `false` until the next
capture. Each call costs 1 native work unit. Other contexts and out-of-range
indices raise an error.

## entity.index

```text
entity.index(value: entity) -> integer | nil
```

Returns the entry index stored in an identity, or `nil` for an invalid entry
index. Available in every context. This reads the identity without checking
whether its entity still exists.

## entity.valid

```text
entity.valid(value: entity) -> boolean
```

Checks whether an identity is available in the current callback. Paint checks
its player pawns, observer controllers, captured planted bomb and any requested
general entity snapshot. Game callbacks check the live entity. Other contexts
raise an error.

`false` in paint means the identity is absent from that snapshot. An entity
outside the snapshot's roster can still exist in the game.

## entity.designer_name

```text
entity.designer_name(value: entity) -> string | false | nil
```

Returns the entity's copied designer name in paint or a game callback. Paint
requests the general entity snapshot and costs 1 native work unit. Its first
request returns `false` until the next capture. Returns `nil` when the entity
or name is unavailable. Other contexts raise an error.

This name is separate from the concrete schema class that `entity.schema_class`
returns and that [`schema.field`](schema.md#schemafield) and the class queries accept.

## Entity properties

```text
value.index: integer | nil
value.valid: boolean
value.designer_name: string | false | nil
```

These properties call the matching `entity` functions and follow the same
callback rules. Read them directly: `value.valid`, for example. Assigning a
property raises an error. An unknown property reads as `nil`.

## entity:get_schema

```text
value:get_schema(path: string) -> boolean | number | string | vec2 | vec3 | color | entity | table | nil
```

Reads an exact schema field or supported nested path using this entity's own
concrete runtime class. No module name, class name or setup declaration is
required. Names remain case-sensitive: `"m_iHealth"`, not `"m_ihealth"`.

```lua
on.paint(function()
    local me = entity.local_player()
    if not me then return end
    local health = me:get_schema("m_iHealth")
    if health == nil then return end
    render.text(24, 80, "health: " .. health, color.white)
end)
```

Available in paint and game callbacks. Other contexts, invalid arguments and
an exhausted execution allowance raise an error. An unavailable entity, field,
type or capture returns `nil` and records a reason in `why.last()`. A returned
`false`, zero, empty string or empty array is a successful value.

Paint uses copied frame data. The first reads can return `nil` until the class
and field are available on the next frame. Game callbacks read the current
entity.

Resolved class/path pairs are reused until the script unloads. Field values are
read again for each callback. Nested paths, copied strings, arrays and type
checks use the same rules as [schema fields](schema.md). That includes a weapon's
or grenade's authored data through
[`m_pSubclassVData`](schema.md#subclass-data), for example
`weapon:get_schema("m_pSubclassVData.CCSWeaponBaseVData::m_nNumBullets")`.

Each call costs 1 native work unit plus the field's read cost. A new class/path
pair costs another 32 units for resolution and shares the global registered-field
limit. Use `schema.field` during setup when a known class should be validated at
load time. For ordinary player health, `player.health(me)` remains available.

## entity:set_schema

```text
value:set_schema(path: string, new_value: boolean | number | vec2 | vec3 | color) -> true | nil
```

Writes one scalar schema field, using the same exact paths as `entity:get_schema`.
Requires **allow unsafe scripts** and an active game-main `on.frame_stage`,
`on.game_event` or console command callback. Other contexts raise an error.

The value must match the field's kind: booleans, integers within the field's
width, finite floats, `vec2`, `vec3`, angles and colors. Entity handles, strings
and arrays cannot be written. A mismatched or out-of-range value raises an
argument error. An unavailable entity or refused path returns `nil` and sets
`why.last()`. A write lasts until the game next updates the field. Costs the
field's read cost in native work units.

## entity:address

```text
value:address() -> cdata | nil
```

Returns the entity's native address as an FFI `void*`, for reading what the typed
API does not reach. Requires **allow unsafe scripts** and a game callback; other
contexts and a denied script raise an error. An entity that no longer exists
returns `nil` and sets `why.last()`.

The address is resolved when you call it and is valid only while the entity
exists. Keep the entity userdata, not the pointer, between callbacks. Reading
through a wrong offset or a destroyed entity can crash the game; see
[FFI](memory.md).

```lua
local ffi = require('ffi')

on.frame_stage(function(stage)
    local me = entity.local_player()
    local base = me and me:address()
    if base == nil then return end
    local bytes = ffi.cast('uint8_t*', base)
    print(string.format('first byte %d', bytes[0]))
end)
```

## player.health

```text
player.health(pawn: entity) -> integer | nil
```

Returns health in points. Paint reads the copied value. Game callbacks read
live health. Returns `nil` when the pawn, value or callback context is
unavailable. Zero is a valid health value.

## player.team

```text
player.team(pawn: entity) -> integer | nil
```

Returns the team number from paint or a game callback. The value is in
`0..255`: `0` is unassigned, `1` is spectator, `2` is terrorist and `3` is
counter-terrorist. Returns `nil` when the pawn, team or context is unavailable.

## player.steam_id

```text
player.steam_id(pawn: entity) -> string | nil
```

Returns the exact decimal Steam ID from the paint snapshot. Keep it as a string
when storing or comparing it. A zero or unavailable ID returns `nil`, including
unassigned identities and bots without an ID. Other contexts also return `nil`.

## player.is_alive

```text
player.is_alive(pawn: entity) -> boolean | nil
```

Returns `true` for a pawn in paint's alive-player snapshot. A missing pawn
returns `nil`. Game callbacks read live liveness and can return `false` for a
dead pawn. An unavailable pawn, value or context returns `nil`.

## player.name

```text
player.name(pawn: entity) -> string | nil
```

Returns the copied display name from the paint snapshot: a configured player
alias if there is one, otherwise the player's Steam name, so an in-game name
prefix or name change does not show. A bot, or a player whose Steam name has not
arrived yet, reads as the scoreboard name. An empty captured name remains `""`.
A missing pawn or any other callback context returns `nil`.

## player.is_local

```text
player.is_local(value: entity) -> boolean | nil
```

Tests whether the identity belongs to the local player. Paint checks player
pawns only. Game callbacks accept either a pawn or a player controller.

Returns `false` for an unrelated or expired identity and for a controller in
paint. Returns `nil` and sets [`why.last()`](why.md#whylast) when the answer is
unknown: outside paint or game callbacks, while the local player is unavailable,
or when a live controller's local-player flag is unreadable.

## player.eye_position

```text
player.eye_position(pawn: entity) -> vec3 | nil
```

Returns the eye position in world units. Availability depends on the callback:

| Callback | Local pawn | Other pawn |
| --- | --- | --- |
| `on.paint` | Copied eye position, or `nil`. | Raises an error. |
| `on.setup_command`, `on.command_finished` | Command-start eye position, or `nil`. | Live eye position, or `nil`. |
| `on.frame_stage`, `on.game_event`, `on.override_view` | Live eye position, or `nil`. | Live eye position, or `nil`. |

Other contexts raise an error. Both command callbacks keep the same starting
sample as the local origin and velocity. A missing sample returns `nil` and sets
`why.last()`. No earlier paint position is substituted. This is not a post-movement
prediction or the separately timed origin of a particular attack.

## player.origin

```text
player.origin(pawn: entity) -> vec3 | nil
```

Returns the pawn's origin in world units. Paint reads its copied origin.
Command callbacks read the local pawn's origin from the start of the command;
other game reads use the live origin.

`on.command_finished` keeps that same starting sample. A missing sample, pawn,
origin or callback context returns `nil`.

## player.armor

```text
player.armor(pawn: entity) -> integer | nil
```

Returns armor in points from paint or a game callback. Zero means no armor.
Returns `nil` when the pawn, armor or context is unavailable.

## player.velocity

```text
player.velocity(pawn: entity) -> vec3 | nil
```

Returns velocity in world units per second. Available in game callbacks only;
other contexts raise an error.

Both command callbacks read the local pawn's velocity from the start of the
command. Other game reads use live velocity. A missing sample, pawn or value
returns `nil`.

## player.flags

```text
player.flags(pawn: entity) -> number | nil
```

Returns the pawn's flags as an exact integer-valued number in `0..4294967295`.
Available in game callbacks only. Other contexts raise an error.

Both command callbacks read the local pawn's flags from the start of the
command. Other game reads use live flags. An unavailable sample, pawn or value
returns `nil`.

## player.is_scoped

```text
player.is_scoped(pawn: entity) -> boolean | nil
```

Returns the copied scope state in paint or the live state in a game callback.
`false` means unscoped. An unavailable pawn, state or context returns `nil`.

## player.flash_duration

```text
player.flash_duration(pawn: entity) -> number | nil
```

Returns the pawn's flash duration in seconds. Paint reads the copied value;
game callbacks read the live value. An unavailable pawn, duration or context
returns `nil`. This is the duration field, not an absolute expiry time.

## player.weapon_info

```text
player.weapon_info(pawn: entity) -> table | false | nil
```

Returns a fresh table for the pawn's active weapon, with these fields:

| Field | Type | Value |
| --- | --- | --- |
| `canonical_name` | string | Game weapon name, such as `"weapon_ak47"`. |
| `class` | string | Weapon class, such as `"rifle_regular"`. |
| `category` | string | Weapon category, such as `"rifles"`. |
| `label` | string | The class's subtype name in the menu, such as `"regular"`; empty for `general`. |
| `scoped` | boolean | Whether every weapon in the class has a scope. |
| `clip` | integer | Current clip count. |
| `max_clip` | integer | Clip capacity; `-1` means there is no magazine. |
| `entity` | entity or nil | Active weapon identity, when it can be read. |
| `automatic` | boolean | Automatic-fire capability. |
| `supports_scope` | boolean | Scope capability, independent of current scope state. |
| `revolver` | boolean | Native revolver classification. |
| `reloading` | boolean or nil | Current reload state. |
| `damage` | integer or nil | Base weapon damage. |
| `penetration` | number or nil | Native penetration power. |
| `range` | number or nil | Native range in world units. |
| `range_modifier` | number or nil | Native damage falloff coefficient. |
| `armor_ratio` | number or nil | Native armor ratio. |
| `headshot_multiplier` | number or nil | Native headshot multiplier. |
| `max_speed` | number or nil | Maximum speed for the current weapon mode. |
| `cycle_time` | number or nil | Primary-fire cycle time in seconds: the refire every primary attack uses, whatever the weapon mode. |
| `definition_index` | integer or nil | The item definition index, which tells individual knife models and weapon variants apart. |
| `pin_pulled` | boolean or nil | Grenades only: whether the pin is pulled. |
| `throw_strength` | number or nil | Grenades only: the throw strength, `0` to `1`. |
| `throw_time` | number or nil | Grenades only: the grenade's `m_fThrowTime` value. |
| `inaccuracy` | number or nil | Local player only: the weapon's current inaccuracy, including stance, recoil, movement and air. |
| `spread` | number or nil | Local player only: the weapon's base spread for the current firing mode. |

`inaccuracy + spread` is the tangent of the spread cone's half-angle, the value
the native spread circle draws. Paint and game callbacks aim it along the current
camera. In the command callbacks it is the cone of the round that command would
fire, the same numbers as [`cmd.weapon_spread`](cmd.md#cmdweapon_spread). Other
players' weapons never carry these two fields.

Paint uses copied data. The first request returns `false` while weapon data
is added to the next snapshot. Game callbacks read current weapon data.
Missing pawn, weapon, metadata, clip data or callback context returns `nil`
and sets `why.last()`.

See [weapon](weapon.md) for the class and category names and the local weapon's
`weapon.active` classification.

## player.visible

```text
player.visible(pawn: entity) -> boolean | nil
```

Returns the saved line-of-sight verdict in paint. `true` means clear and `false`
means blocked. The check covers world and prop obstructions. Other player
bodies do not block it.

Returns `nil` when no verdict was captured, the pawn is absent, or the callback
is not `on.paint`. Calling this function does not issue a new trace or request
a visibility sample.

## player.bounding_box

```text
player.bounding_box(pawn: entity) -> (x: number, y: number, width: number, height: number) | nil
```

Returns `x`, `y`, `width` and `height` in authored pixels, using the same
coordinates as the render drawing calls. The box comes from projecting the top
and bottom of the pawn's copied bounds through paint's camera. `x` and `y` mark
the top-left corner. Width is half the projected height.

Returns one `nil` when the player, bounds, camera or projection is unavailable,
including outside `on.paint`.

```lua
on.paint(function()
    for _, pawn in ipairs(entity.players()) do
        local x, y, width, height = player.bounding_box(pawn)
        if x ~= nil then
            render.rect_outline(x, y, width, height, color.white)
        end
    end
end)
```

## player.observing

```text
player.observing(controller: entity) -> (target: entity | nil, mode: integer) | nil
```

Returns an observer controller's captured target and mode. Mode `2` is first
person and mode `3` is chase. An invalid target identity returns `nil` together
with the mode. A returned identity can also have expired.

Returns one `nil` when the current render roster has no matching controller
following a player in either mode. A missing render context or malformed roster
raises an error, matching the other connected-player reads.

## player.spectators

```text
player.spectators(target: entity) -> table | nil
```

Returns a fresh `1`-indexed array of spectators following the target pawn in the
current render roster. An empty array means none were found. An expired target
returns `nil`. A missing render context or malformed roster raises an error.

| Field on each spectator | Type | Value |
| --- | --- | --- |
| `name` | string | Copied display name. |
| `mode` | integer | `2` for first person or `3` for chase. |
| `controller` | entity | Spectator controller identity. |

```lua
on.paint(function()
    local me = entity.local_player()
    if not me then return end

    for row, spectator in ipairs(player.spectators(me)) do
        render.text(24, 240 + (row - 1) * 16, spectator.name, color.white)
    end
end)
```

See [events](../events.md) for getting player pawns and controllers from an event.


## entity.controllers

```text
entity.controllers() -> table | nil
```

Returns connected controller identities, including bots, dead players and
spectators. Known relay clients are excluded. Uses the current render roster;
an unavailable context or malformed roster raises an error. Capture startup
returns `nil` and sets `why.last()`. An empty table
means no connected players. Each identity includes its entity generation.

## entity.local_controller

```text
entity.local_controller() -> entity | nil
```

Returns the local controller from the current render roster or a game callback.
Unlike the local player pawn, this identity remains available while spectating.
Returns `nil` when unavailable.

## player.info

```text
player.info(controller: entity) -> table | nil
```

Reads a connected controller from the current render roster. Returns `nil` when
that controller is absent. Missing individual fields are unavailable reads.

| Field | Type | Description |
| --- | --- | --- |
| `controller` | entity | Connected controller identity. |
| `name` | string | Copied display name: a local alias, else the Steam name (see `player.name`). |
| `controlled_pawn` | entity or nil | Currently driven entity, including an observer pawn. |
| `player_pawn` | entity or nil | Driven pawn when it is a player pawn. |
| `observed_subject` | entity or nil | Living controlled pawn or followed player. Absent for roaming cameras. |
| `observer_mode` | integer or nil | Current observer mode when available. |
| `steam_id` | string or nil | Exact decimal account value. `"0"` means no assigned account. |
| `team` | integer or nil | Controller team. |
| `ping` | integer or nil | Scoreboard round trip in milliseconds. |
| `is_local` | boolean or nil | Whether this controller is local. |
| `is_bot` | boolean or nil | Whether the controller is a fake client. |
| `alive` | boolean or nil | Driven player pawn liveness. |
| `connection_state` | integer | Native connected state. |

```lua
on.paint(function()
    local controller = entity.local_controller()
    local info = controller and player.info(controller)
    if info and info.observed_subject then
        local watchers = player.spectators(info.observed_subject)
    end
end)
```

## entity.get_all

```text
entity.get_all() -> table | false | nil
```

Returns all captured entity identities, ordered by index, from a render or game
callback. A render request returns `false` until capture starts. An empty table
is a successful empty query. Invalid membership refuses the complete result.

## entity.schema_class

```text
entity.schema_class: string | false | nil
```

Returns the verified concrete schema class, distinct from the designer name
returned by `entity.designer_name`. Read it as `value.schema_class`.
A render read returns `false` until the next capture. Unavailable capture or
unsupported class metadata returns `nil`.

## entity:is_a

```text
entity:is_a(class: string) -> boolean | nil
```

Tests the concrete class or a verified nonvirtual base class with
`value:is_a(class)`. An unrelated class returns `false`; unavailable, ambiguous
or unsupported metadata returns `nil` and sets `why.last()`. Because `false` is
an answer here, a render read before the next capture also returns `nil`, with
`schema_snapshot_not_requested` in `why.last()`.

Class inspection uses render captures or live game callbacks. Inheritance
queries charge one additional native-work unit per inspected entity.


## player.relation

```text
player.relation(pawn: entity) -> string | nil
```

Reads the native overlay classification from the current render snapshot:
`"local"`, `"teammate"`, `"enemy"` or `"hidden"`. It uses the captured team/FFA
rule and native hide-ESP preference. Unavailable inputs return `nil` and set
`why.last()`; they are never reported as an enemy by this API.


## player.avatar

```text
player.avatar(controller: entity) -> image_request | nil
```

Requests the controller's large Steam avatar through the shared
[image request](render.md#image-requests) owner. Call from a render snapshot or
a game callback. The controller's exact account identity is captured when the
request is submitted. Bots and unavailable accounts return
`nil` and set `why.last()`.

The request reports pending, ready, unavailable or failed. Unavailable means
Steam reports no avatar; failures remain distinct. Take the ready image through
the request to obtain a normal texture. Reload/unload cancels owned requests.

Use `texture:size()` to read the dimensions supplied by Steam. The width and
height passed to `render.image` control the display size, not the source size.

Each request reads fresh available bytes. Keep the returned texture for drawing
and issue another request when a refresh is needed. Calling this every paint
creates new resource requests; it is not a cached texture getter. No unsafe
permission is required for this native public-profile image source.

## player.preferences

```text
player.preferences(controller: entity) -> player_preferences | nil
preferences:get() -> table | nil
preferences:get_base() -> table | nil
preferences:set(values: table) -> boolean | nil
preferences:override(values: table) -> boolean | nil
preferences:clear_override() -> boolean | nil
```

Accesses the native player-list preferences for a connected controller. The
reference expires on disconnect, controller replacement or session change.
Account preferences survive reconnects within the running session. Bot
preferences reset when their controller slot is reused. These values are not
saved in configuration profiles.

`get()` copies effective values. `get_base()` copies the manual values beneath
held binds and script overrides. `set()` changes supplied base fields and leaves
other fields unchanged. `override()` replaces this script's temporary claim;
omitted fields no longer belong to that claim. `clear_override()` releases it.

| Field | Type | Description |
| --- | --- | --- |
| `whitelist` | boolean | Native player whitelist preference. |
| `priority` | boolean | Native player priority preference. |
| `hide_esp` | boolean | Hide this player's native overlays. |
| `hide_model` | boolean | Native hidden-model preference. |
| `override_hitboxes` | boolean | Enable the selected hitbox groups. |
| `hitboxes` | string[] | Selected groups: `head`, `neck`, `chest`, `stomach`, `pelvis`, `arms`, `legs`, `feet`. |
| `disable_no_spread` | boolean | Native per-player no-spread exclusion. |
| `alias` | string | Local display alias. Empty clears it. At most 127 bytes, without NUL. |

Writes require a render-side callback, such as paint, a timer, a menu callback
or unload. Each write charges eight native-work units. Reads charge one.
Malformed fields raise an error before anything changes. Refusals return
`nil` and set `why.last()` to the reason:

| Reason | Meaning |
| --- | --- |
| `player_subject_expired` | The controller disconnected, was replaced or the session changed. |
| `player_preference_flags_invalid` | The supplied flag combination was refused. |
| `player_preference_hitboxes_invalid` | The `hitboxes` list was refused. |
| `player_alias_invalid` | The alias was refused. |
| `player_preference_owner_capacity` | Too many scripts hold claims on this player. |
| `player_preference_identity_exhausted` | No new claim identity is available. |

Script claims take precedence over native held binds. When scripts claim the
same field, the later acquired generation owner wins; refreshing a claim does
not change its priority. Reload, unload and subject expiration release claims.
Releasing a claim or held bind reveals the current base value, including edits
made while the override was active.
