# Color

Use `color` for [drawing](../api/render.md) and [menu color controls](../api/menu.md). Its RGBA channels are integers from `0` through `255`. Alpha `0` is transparent and `255` is opaque.

Colors are read-only. Methods return new colors, so you can keep a palette and reuse it between callbacks.

## color

```text
color(r: integer, g: integer, b: integer, a: integer = 255) -> color
```

Creates a color from red, green, blue and alpha channels. The three RGB channels are required. Omit `a` for an opaque color. Explicitly passing `nil` raises an error. Channels outside `0..255` also raise an error. Fractional channels are truncated toward zero, not rejected.

```lua
local accent = color(255, 90, 170)
local background = color(20, 20, 24, 220)

on.paint(function()
    render.rect(24, 24, 180, 36, background)
    render.text(34, 30, 'dylanhook', accent)
end)
```

## Properties

| Property | Type | Value |
| --- | --- | --- |
| `r` | integer | Red channel, `0..255`. |
| `g` | integer | Green channel, `0..255`. |
| `b` | integer | Blue channel, `0..255`. |
| `a` | integer | Alpha channel, `0..255`. |

Reading an unknown property returns `nil`. Assigning a property raises an error. Use `color(existing.r, existing.g, existing.b, new_alpha)` or `existing:alpha(new_alpha)` to make an adjusted copy.

## Named colors

| Value | Equivalent |
| --- | --- |
| `color.white` | `color(255, 255, 255, 255)` |
| `color.black` | `color(0, 0, 0, 255)` |
| `color.red` | `color(255, 0, 0, 255)` |
| `color.green` | `color(0, 255, 0, 255)` |
| `color.blue` | `color(0, 0, 255, 255)` |

Use these values directly, such as `color.white:alpha(160)`.

## color.hsv

```text
color.hsv(h: number, s: number, v: number, a: integer = 255) -> color
```

Creates a color from hue, saturation and brightness. `h`, `s` and `v` must be finite numbers in `0..1`. Hue covers one full turn: `0` and `1` both select red. Saturation `0` produces gray.

`a` uses `0..255`, just like the RGBA constructor. Omit it for `255`. Explicit `nil` raises an error. The resulting RGB channels are rounded to the nearest integer.

```lua
local yellow = color.hsv(1 / 6, 1, 1)
local soft_blue = color.hsv(2 / 3, 0.35, 1, 180)
```

## color:alpha

```text
value:alpha(a: integer) -> color
```

Returns a copy with alpha set to `a`. The RGB channels stay the same. `a` must be in `0..255` and replaces the old alpha rather than multiplying it.

```lua
local tint = color(255, 90, 170, 100)
local opaque = tint:alpha(255)
-- tint.a is still 100.
```

## color:lerp

```text
value:lerp(other: color, t: number) -> color
```

Blends all four channels toward `other`. `t` must be finite and fit a 32-bit float. It is clamped to `0..1`: `0` gives the starting channels, `1` gives the ending channels and `0.5` gives the midpoint. Each channel is rounded to the nearest integer.

```lua
local low = color(255, 70, 70)
local high = color(100, 220, 140)
local halfway = low:lerp(high, 0.5)
```

## Keeping and comparing colors

You can create and use colors while loading or in any callback. They don't expire when a callback ends. A color read from a menu control is a copy. Read the control again to get its current value.

`==` compares color objects by identity. Compare `r`, `g`, `b` and `a` to check whether two separate objects contain the same channels. Colors have no arithmetic operators.

For [JSON](../api/std.md#json), store the channels in an ordinary table, then rebuild the color after decoding:

```lua
local tint = color(255, 90, 170, 200)
local saved = {r = tint.r, g = tint.g, b = tint.b, a = tint.a}
local restored = color(saved.r, saved.g, saved.b, saved.a)
```
