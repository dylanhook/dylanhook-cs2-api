# vec3

Use `vec3` for world positions, directions, velocities and angles. Its `x`, `y` and `z` components are read-only. [render.camera](../api/render.md#rendercamera) returns `vec3` values for its position and angles.

The unit comes from the function supplying the value. A world position uses game units. An angle uses degrees with `x` as pitch, `y` as yaw and `z` as roll.

## vec3

```text
vec3(x: number, y: number, z: number = 0) -> vec3
```

Creates a vector. `x` and `y` are required. Omitting `z` or passing `nil` sets it to `0`.

Components must be finite numbers that fit a 32-bit float and are stored at that precision.

```lua
local start = vec3(0, 0, 64)
local finish = vec3(100, 100, 80)
local offset = finish - start
local direction = offset:normalized()

if direction then
    local next_point = start + direction * 16
    print(string.format('next point: %.1f, %.1f, %.1f',
        next_point.x, next_point.y, next_point.z))
end
```

## Properties

| Property | Type | Value |
| --- | --- | --- |
| `x` | number | First component. Pitch for an angle. |
| `y` | number | Second component. Yaw for an angle. |
| `z` | number | Third component. Roll for an angle. |

Reading an unknown property returns `nil`. Assigning a property raises an error. Create a new value to change one component: `vec3(position.x, position.y, position.z + 16)`.

## Operators

| Expression | Result |
| --- | --- |
| `a + b` | A new vector with the components added. |
| `a - b` | A new vector with the components subtracted. |
| `a * scale`, `scale * a` | A new vector with every component multiplied by `scale`. |
| `a / scale` | A new vector with every component divided by `scale`. |
| `-a` | A new vector with every component negated. |
| `a == b` | Whether all stored components are equal. |

`a` and `b` must both be `vec3` values. `scale` must be a finite number that fits a 32-bit float. A divisor must also be nonzero.

Vector-by-vector multiplication and division, and scalar-by-vector division,
are unsupported. An operation that produces a non-finite component raises an error.

## vec3:unpack

```text
value:unpack() -> x: number, y: number, z: number
```

Returns the components as three separate values, without creating a table.

## vec3:cross

```text
value:cross(other: vec3) -> vec3
```

Returns the right-handed cross product. The inputs are unchanged. An overflowing
or non-finite result raises an error.

```lua
local perpendicular = vec3(1, 0, 0):cross(vec3(0, 1, 0))
assert(perpendicular == vec3(0, 0, 1))
```

## vec3:length

```text
value:length() -> number
```

Returns the 3d length, `sqrt(x*x + y*y + z*z)`.

## vec3:length_sqr

```text
value:length_sqr() -> number
```

Returns the squared 3d length, `x*x + y*y + z*z`.

## vec3:length2d

```text
value:length2d() -> number
```

Returns `sqrt(x*x + y*y)`, ignoring `z`. For a velocity in game units per second, this is horizontal speed.

## vec3:length2d_sqr

```text
value:length2d_sqr() -> number
```

Returns `x*x + y*y`, ignoring `z`.

## vec3:dot

```text
value:dot(other: vec3) -> number
```

Returns `x*other.x + y*other.y + z*other.z`. For unit vectors, the result is `1` in the same direction, `0` when perpendicular and `-1` in opposite directions.

## vec3:distance

```text
value:distance(other: vec3) -> number
```

Returns the straight-line 3d distance to `other`.

## vec3:distance_sqr

```text
value:distance_sqr(other: vec3) -> number
```

Returns the squared 3d distance to `other`. Compare this with `radius * radius` to check a range without taking a square root.

## vec3:normalized

```text
value:normalized() -> vec3 | nil
```

Returns a new vector pointing in the same direction with length `1`. A zero vector returns `nil` and does not set a [failure reason](../api/why.md).

## vec3:lerp

```text
value:lerp(other: vec3, t: number) -> vec3
```

Returns `value + (other - value) * t`. `t` must be finite and fit a 32-bit float. It is not clamped: `0` selects the starting point, `1` selects the ending point, and values outside that range extend past the endpoints. A non-finite result raises an error.

The calculation avoids an overflowing float difference between opposite finite
endpoints. Each returned component must still fit the vector's finite float range.

## vec3:angles

```text
value:angles() -> vec3 | nil
```

Treats the vector as a direction and returns its pitch, yaw and roll in degrees. Positive pitch points down, yaw turns around the vertical axis, and roll is `0`.

For a direction straight up or down, yaw is `0` and pitch is `-90` or `90`. A zero vector returns `nil` without setting a failure reason. To find the angle between two positions, subtract them first:

```lua
local eye = vec3(0, 0, 64)
local target = vec3(100, 100, 100)
local angles = (target - eye):angles()

if angles then
    print(string.format('pitch %.1f, yaw %.1f', angles.x, angles.y))
end
```

## vec3:basis

```text
value:basis() -> (forward: vec3, left: vec3, up: vec3)
```

Treats the vector as pitch, yaw and roll in degrees and returns the three unit
directions of that view: where it looks, its left side and its top. Positive
pitch looks down. Roll turns `left` and `up` around `forward`; it does not change
`forward`. `basis` is the reverse of [`angles`](#vec3angles) for the forward
direction.

`left` is the direction a positive side move travels, the same convention as
[`cmd:move`](../api/cmd.md#cmdmove). Negate it for the right side.

```lua
local angles = vec3(10, 90, 0)
local forward, left, up = angles:basis()
local ahead = vec3(0, 0, 64) + forward * 100 + up * 8

print(string.format('ahead %.1f %.1f %.1f, left.x %.2f', ahead.x, ahead.y, ahead.z, left.x))
```

## Keeping and comparing vectors

You can create vectors while loading or in any callback, then keep them after the callback ends. Methods and operators leave the original values unchanged. A copied position stays at its recorded coordinates until you replace it.

`==` compares the stored components exactly. `rawequal` compares object identity.
Use `a:distance_sqr(b) <= tolerance * tolerance` for a distance-based comparison.

Length, distance and dot products use 32-bit arithmetic. Extreme components can overflow a numeric result even when both inputs are finite. Addition, subtraction, scaling and interpolation reject a non-finite vector result. `angles()` and `basis()` also use 32-bit arithmetic, so use ordinary world-scale directions and angles.

For [JSON](../api/std.md#json), store `{x = value.x, y = value.y, z = value.z}` and rebuild it with `vec3(saved.x, saved.y, saved.z)`. See [vec2](vec2.md) for screen positions and [render.world_to_screen](../api/render.md#renderworld_to_screen) for projection.
