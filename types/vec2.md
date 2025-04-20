# vec2

Use `vec2` for a screen position or a 2d direction. Its `x` and `y` components are read-only. [input.cursor](../api/input.md#inputcursor) and [render.world_to_screen](../api/render.md#renderworld_to_screen) return this type.

A `vec2` has no built-in unit. Cursor and projected positions use authored pixels. Check the function that supplied the value before combining them.

## vec2

```text
vec2(x: number, y: number) -> vec2
```

Creates a vector. Both components are required and must be finite numbers that fit a 32-bit float. Components are stored at that precision.

```lua
local start = vec2(24, 80)
local finish = vec2(184, 160)
local middle = start:lerp(finish, 0.5)
local accent = color(255, 90, 170)

on.paint(function()
    render.line(start.x, start.y, finish.x, finish.y, color.white)
    render.circle(middle.x, middle.y, 3, accent)
end)
```

## Properties

| Property | Type | Value |
| --- | --- | --- |
| `x` | number | First component. |
| `y` | number | Second component. |

Reading an unknown property returns `nil`. Assigning a property raises an error. Build a replacement such as `vec2(position.x + 10, position.y)`, or use an operator.

## Operators

| Expression | Result |
| --- | --- |
| `a + b` | A new `vec2(a.x + b.x, a.y + b.y)`. |
| `a - b` | A new `vec2(a.x - b.x, a.y - b.y)`. |
| `a * scale`, `scale * a` | A new vector with each component multiplied by `scale`. |
| `a / scale` | A new vector with each component divided by `scale`. |
| `-a` | A new vector with both components negated. |
| `a == b` | Whether both stored components are equal. |

`a` and `b` must both be `vec2` values. `scale` must be a finite number that fits a 32-bit float. A divisor must also be nonzero.

Vector-by-vector multiplication and division, and scalar-by-vector division,
are unsupported. An operation that produces a non-finite component raises an error.

## vec2:unpack

```text
value:unpack() -> x: number, y: number
```

Returns both components as separate values. It does not create a table.

## vec2:length

```text
value:length() -> number
```

Returns the length, `sqrt(x*x + y*y)`.

## vec2:length_sqr

```text
value:length_sqr() -> number
```

Returns the squared length, `x*x + y*y`. Use it to compare distances without taking a square root.

## vec2:dot

```text
value:dot(other: vec2) -> number
```

Returns `x*other.x + y*other.y`. For unit vectors, the result describes their alignment: `1` points the same way, `0` is perpendicular and `-1` points the opposite way.

## vec2:distance

```text
value:distance(other: vec2) -> number
```

Returns the straight-line distance to `other`.

## vec2:distance_sqr

```text
value:distance_sqr(other: vec2) -> number
```

Returns the squared distance to `other`. Compare it with a squared radius:

```lua
local point = vec2(110, 95)
local center = vec2(100, 100)
local inside = point:distance_sqr(center) <= 20 * 20
```

## vec2:normalized

```text
value:normalized() -> vec2 | nil
```

Returns a new vector pointing in the same direction with length `1`. A zero vector returns `nil` and does not set a [failure reason](../api/why.md).

```lua
local offset = vec2(30, 40)
local direction = offset:normalized()
if direction then
    local step = direction * 10
    print(string.format('step: %.1f, %.1f', step.x, step.y))
end
```

## vec2:lerp

```text
value:lerp(other: vec2, t: number) -> vec2
```

Returns `value + (other - value) * t`. `t` must be finite and fit a 32-bit float. It is not clamped: `0.5` gives the midpoint, while values below `0` or above `1` extend beyond the endpoints. A non-finite result raises an error.

The calculation avoids an overflowing float difference between opposite finite
endpoints. Each returned component must still fit the vector's finite float range.

## Keeping and comparing vectors

You can create vectors while loading or in any callback, then keep them after the callback ends. Methods and operators leave the original values unchanged.

`==` compares the stored components exactly. `rawequal` compares object identity.
Use `a:distance_sqr(b) <= tolerance * tolerance` for a distance-based comparison.

Length, distance and dot products use 32-bit arithmetic. Extreme components can overflow a numeric result even when both inputs are finite. Addition, subtraction, scaling and interpolation reject a non-finite vector result.

For [JSON](../api/std.md#json), store `{x = value.x, y = value.y}` and rebuild it with `vec2(saved.x, saved.y)`. See [vec3](vec3.md) for world positions and 3d directions.
