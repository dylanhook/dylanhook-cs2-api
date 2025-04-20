# Game

Read the current map or planted bomb state. Returned values are copies and do
not update themselves.

## game.map_name

```text
game.map_name() -> string | nil
```

Returns the current map name, such as `"de_mirage"`.

Render-side callbacks read the map for their current render snapshot.
`on.session_changed` reads the map that caused the change. Frame-stage,
game-event and console command callbacks can read the current map.

Other contexts return `nil` and set [`why.last()`](why.md#whylast).

```lua
on.session_changed(function()
    local map = game.map_name()
    if map then
        console.log("map: " .. map)
    else
        console.log("no map name available")
    end
end)
```

## game.bomb_snapshot

```text
game.bomb_snapshot() -> table | false | nil
```

Returns a new table for the active planted bomb. Call it with a current render
snapshot, or from `on.setup_command`, `on.command_finished`, `on.command_committed`
or `on.anti_aim`. Other contexts raise an error.

In paint and ESP value callbacks, the bomb state belongs to the current frame.
The first paint request returns `false` until the next frame captures the
bomb. That is "not yet", not a failure, and it leaves `why.last()` alone.

Returns `nil` when there is no ticking, non-defused bomb, its state cannot be
read, or its game clock is unavailable. `why.last()` gives the reason.
Failure returns one `nil`, with no second error value.

| Field | Type | Description |
| --- | --- | --- |
| `ticking` | boolean | Always `true` for a returned snapshot. |
| `defused` | boolean | Always `false` for a returned snapshot. |
| `being_defused` | boolean | Whether a defuse countdown is active. |
| `site_index` | integer | The game's raw site value. It is not restricted to `0` and `1`. |
| `site` | string | `"B"` when `site_index % 2 == 1`, otherwise `"A"`. Use this for display. |
| `current_time` | number | The bomb's game clock when this snapshot was captured, in seconds. |
| `blow_time` | number | Explosion deadline on the same clock as `current_time`, in seconds. |
| `timer_length` | number | Finite, positive full bomb timer, in seconds. |
| `seconds_remaining` | number | Time until explosion, clamped to `0..timer_length`. |
| `defuse_end_time` | number or nil | Defuse deadline on the same clock as `current_time`. Absent when no defuse is active. |
| `defuse_seconds_remaining` | number or nil | Time until the current defuse ends, clamped to at least zero. Absent when no defuse is active. |
| `defuse_will_succeed` | boolean or nil | Whether the current defuse deadline is at or before `blow_time`. Absent when no defuse is active. |

Use `seconds_remaining` for a countdown. It is computed from `blow_time` and
`current_time` using the same game clock. This clock accounts for game pauses.

The three defuse fields exist only while `being_defused` is true.
`defuse_will_succeed` compares the two deadlines. The player can still stop
defusing before then.

Read once per paint and reuse the returned values for that frame. Saving the
table does not keep its countdown updated. A paint call costs 1 native-work unit.
A command call costs 64.

This display also closes when the round ends or the bomb is resolved:

```lua
local ended = false
local function reset() ended = false end
local function finish() ended = true end

on.session_changed(reset)
on.game_event('round_start', reset)
on.game_event('bomb_planted', reset)
on.game_event('round_end', finish)
on.game_event('bomb_defused', finish)
on.game_event('bomb_exploded', finish)

on.paint(function()
    if ended then return end
    local bomb = game.bomb_snapshot()
    if not bomb or bomb.seconds_remaining <= 0 then return end
    render.text(24, 24, string.format(
        "%s | %.1fs", bomb.site, bomb.seconds_remaining
    ), color.white)
end)
```


## game.capture

```text
game.capture() -> table | nil
```

Returns the current render capture's `id`, `session_id`, `available`,
`view_available`, `map_name`, optional `tick`, `time`, `signon_state` and
`in_game`, plus `schema_status`, `pose_status` and `visibility_traced`.
IDs are exact decimal strings. Capture ID `"0"` means unavailable. Returns
`nil` outside a current render snapshot.

`map_name` is always present and can be `""`. `schema_status` and
`pose_status` are `"available"` when that part of the capture succeeded, or
otherwise the same reason string a [schema read](schema.md) or
[pose read](pose.md) would report, such as `"schema_snapshot_not_requested"` or
`"pose_not_captured_yet"`.

The session ID changes after an observed level exit and a new capture,
including a same-map reconnect. The roster and captured geometry have separate
sampling phases; this record does not claim an atomic sample of the whole game.

## game.auto_peek

```text
game.auto_peek() -> table | nil
```

Reads the native auto-peek publication independently of its indicator setting.
The table contains `available`; an available sample also contains
`command_number`, optional `anchor`, `returning` and `player_override`.
Returns `nil` when the source is unavailable. A disabled or reset feature
returns `available = false`.

## game.double_tap

```text
game.double_tap() -> table | nil
```

Reads the native double tap's charge, the value its keybind indicator draws.
`ready` is `true` when a press now takes a double tap's first shot. `charge`,
from `0` to `1`, says how soon its second shot follows: at once at `1`, and
sooner than an ordinary follow-up below that, so `ready` can be `true` before a
full `charge`. With the double tap keybind up the charge still fills and `ready`
stays `false`. Returns `nil` when there is nothing to report: no firearm held,
double tap off, the revolver, or its state unreadable. Available while the
script loads and in every callback.

```lua
on.paint(function()
    local tap = game.double_tap()
    if tap then
        render.rect(24, 300, 60 * tap.charge, 4, tap.ready and color(120, 220, 120) or color(220, 180, 80))
    end
end)
```

## game.grenade_path

```text
game.grenade_path() -> table | nil
```

Copies the native held-grenade prediction. The native trajectory feature must
be enabled and have a completed result. Failure returns `nil` and sets
`why.last()` to the reason: `disabled`, `unavailable` or
`capacity_exceeded`.

The table contains exact-string `id`, `points`, `contacts`, `end_position` and
`outcome`. Point and contact arrays contain `vec3` values. Outcome is
`"detonated"`, `"fizzled"` or `"budget_exhausted"`. This is the existing native
prediction of the throw you are making, not a guaranteed future result; to
predict a throw from another pose, use [`trace.grenade`](trace.md#tracegrenade).
It is sampled independently of the render-camera capture. Each read costs 64
native work units, plus one per started 16 points and contacts.

## game.grenade_warnings

```text
game.grenade_warnings() -> table | nil
```

Copies the native proximity warnings for HE grenades, molotovs, incendiaries
and active fires. Read from callbacks with a render snapshot. The first read
requests tracking until this script unloads, independently of the warning and
tracer visual toggles. It can return `nil` with `grenade_warnings_unavailable` in
`why.last()` while waiting for the next native update or while the local player
is unavailable. A native update that fails its own consistency check records
`grenade_warning_invalid_publication`.

The result contains exact-string `id` and `session_id`, plus a `warnings` array.
An empty array means the completed native update had no warnings. Each row has:

| Field | Type | Description |
| --- | --- | --- |
| `entity` | entity | Projectile or active fire identity. |
| `thrower` | entity or nil | Producing pawn identity when known. |
| `kind` | string | `"he"`, `"molotov"` or `"incendiary"`. |
| `outcome` | string | Native prediction result: `"detonated"`, `"fizzled"` or `"budget_exhausted"`. |
| `position` | vec3 | Predicted landing position or active fire origin. |
| `create_time` | number | Native start time in the level clock. |
| `end_time` | number | Predicted flight end time or fire expiration. |
| `distance` | number | Distance from the local player in game units. |
| `burning` | boolean | Whether this row describes an active fire. |
| `danger` | number or nil | Native warning intensity from 0 to 1. Absent when its assessment failed. |
| `reaches` | boolean or nil | Whether the assessed effect reaches the local player. Absent when unknown. |
| `health_loss` | integer or nil | Estimated HE damage. Absent for fire or an unavailable assessment. |

These are the native warning decisions, including their proximity and
friendly-fire rules. They are not an inventory of every projectile, an arbitrary
simulation, or a guarantee of future damage. Diverged predictions are excluded.
The update is independent of the render-camera capture.

The existing tracker holds 16 flights/fires. Pool exhaustion returns
`nil` with `grenade_warning_capacity_exceeded` instead of a truncated result. Each
read charges 16 native-work units. Unsafe mode retains the native tracker bound.


## game.catalog

```text
game.catalog(kind: string, cursor: integer = 0, item_definition: integer = 0) -> table | nil
```

Reads the native item catalog. Kinds are `"weapons"`, `"finishes"`, `"stickers"`,
`"patches"`, `"charms"`, `"music_kits"`, `"agents"` and `"categories"`.

Returns `items`, `total` and optional `next_cursor`. Pages contain up to 64 rows;
continue with `next_cursor` to read the complete kind. Each item has a display
`name` and native numeric `id`. Categories use their `token` instead of an ID.
Weapon and finish rows also include their native `token`.

Weapon rows include `category`, `rarity`, `sticker_slots`, `nameable`, `stattrak`
and `charms`. Finish rows include `rarity`, `legacy` and `glove`. Stickers,
patches and charms include their own `rarity`. Agents include `selectable`.
A row with a `rarity` also has `rarity_color`: the [color](../types/color.md) the game
paints that grade with, read from the game's own grade table. It is absent when
the grade did not resolve. A finish's `rarity` and color are its own grade, not
the grade it shows on a particular weapon.

For finishes, a nonzero `item_definition` filters by that weapon's real finish
pairings. Other kinds reject this filter. An unknown kind raises an error.
Unknown items, unavailable catalog data and invalid cursor ranges return `nil`
and set `why.last()`:

| Reason | Meaning |
| --- | --- |
| `catalog_unavailable` | The game's item data is not loaded. |
| `catalog_invalid_query` | The kind and filter combination was refused. |
| `catalog_item_absent` | `item_definition` names no known item. |
| `catalog_invalid_relationship` | The catalog's own links between items did not resolve. |
| `catalog_page_out_of_range` | `cursor` is past the end of the kind. |

The catalog contains the native supported item set, including its naming and
pairing filters. It is not an exhaustive dump of every internal economy record.
Read it during setup or callbacks; each page costs 64 native-work units.
