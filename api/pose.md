# Bones and hitboxes

Use `player.pose` for a complete copied skeleton and hitbox sample. The
individual helpers are useful when you only need one or two points.

## player.pose

```text
player.pose(pawn: entity) -> table | false | nil
```

Returns a Lua-owned table with these fields:

| Field | Meaning |
| --- | --- |
| `phase` | `"render"` when reading the current render snapshot. `"live"` in a permitted game callback. |
| `skeleton_id` | Session-local decimal ID for the current model's bone definition. It is not an address or persistent asset ID. |
| `bones` | A 1-based Lua array in the model's native bone order. Each row has native `id`, optional `name`, optional world `position`, and optional native `parent` index. |
| `parents_available` | Whether this sample has a validated complete parent-index array. With this false, omitted parents mean unknown rather than root bones. |
| `hitbox_definition` | Decimal change token for the current hitbox definition, when available. It is not a persistent asset ID. |
| `hitboxes` | A 1-based Lua array of hitbox rows, or `nil` when the model's hitbox data is unavailable. |

Bone IDs and parent IDs are **native zero-based indices**. Lua arrays remain
1-based: bone ID `i` is in `pose.bones[i + 1]`. A missing parent with
`parents_available == true` is a root. Bone names come from the current model.
Do not reuse an index on another model merely because both arrays have equal size.

A hitbox row contains `id` (native set index), `bone` (native bone index),
`hitgroup` (see [Hitgroups](trace.md#hitgroups)), and `available`. When available, it also contains world-space capsule
endpoints `a` and `b`, `center`, and `radius`. An unavailable shape keeps its row
and identity but has no geometry. Later rows are not shifted to conceal it.

The capsule center is `(a + b) / 2`. Its endpoints are not AABB minima and
maxima. A bone origin and the center of a hitbox attached to it may differ.

The table, strings and vectors are copied. They can be retained or changed by
the script without changing the engine or another sample.

## player.bone_position

```text
player.bone_position(pawn: entity, bone: integer | string) -> vec3 | false | nil
```

Reads a bone origin by native index or model bone name. Name matching is ASCII
case-insensitive. Names contain 1-63 bytes without NUL.
An index must be an integer from 0 through 255. A valid index outside the current
model's array returns `nil`. A missing name or unavailable position also returns
`nil`, with a reason in `why.last()`.

## player.hitbox_position

```text
player.hitbox_position(pawn: entity, hitbox_id: integer) -> vec3 | false | nil
```

Returns the center of the transformed capsule, not its bone origin. `hitbox_id`
is a native set index from 0 through 39. Discover the actual IDs and hitgroups
through `player.pose`. Do not assume a model-independent numbered anatomy list.

## player.hitbox_capsule

```text
player.hitbox_capsule(pawn: entity, hitbox_id: integer) -> table | false | nil
```

Returns one available hitbox row in the shape described above. Missing hitbox data
or invalid/unavailable transforms return `nil` rather than a partly populated
shape. Invalid index/name arguments raise an argument error.

## Callback and lifetime rules

In [render-side callbacks](../events.md#callback-context), poses come from the
current render snapshot. This includes ordinary and above-menu paint, ESP
callbacks, timers and menu callbacks while that render pass is active. The first
request returns `false` until the next frame captures the pose.

Command callbacks (`on.setup_command`, `on.command_finished`,
`on.command_committed`, `on.anti_aim`), `on.frame_stage`, `on.game_event`,
`on.override_view` and console command callbacks can sample the current live pose.
Consecutive reads of the same pawn within one callback share a sample. Use
`player.pose` when several reads must refer to the same pose.

Setup and callbacks without a render snapshot or an allowed live read cannot
read poses. Shutdown cleanup has no render snapshot.
Missing entities and unavailable model data return `nil` with `why.last()`.
Bone data is capped at 256 entries and hitbox data at 40 entries per pawn. Larger
results are refused instead of truncated.

Each pose API call costs one native work unit. A fresh live sample costs another
32 units. Use the bulk table when reading several bones or hitboxes.

The [skeleton ESP](../examples/skeleton_esp.md) demonstrates model-specific
hitbox-bone parent chains without hardcoded anatomy indices.
