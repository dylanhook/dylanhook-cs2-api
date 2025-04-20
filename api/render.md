# Render

Draw shapes, text and images in `on.paint`, `on.paint_above_menu` or a custom
[ESP item](esp.md#espadd_item) draw callback. Text measurement also works in an
ESP item measure callback. Drawing, measurement and viewport calls raise an
error in other contexts.

Camera and projection reads use the current render snapshot, including in
above-menu paint and other render-side callbacks. They return `nil` when that
snapshot is unavailable and do not grant a drawing surface.

Create reusable colors, fonts and textures while the script loads. Fonts and
textures can also be created in render-side callbacks. See
[color](../types/color.md), [vec2](../types/vec2.md), [vec3](../types/vec3.md)
and [callbacks](../events.md).

## Coordinates

Positions and sizes use authored pixels. `(0, 0)` is the top-left corner.
`x` increases right and `y` increases down. `render.dpi_scale()` converts these
coordinates to device pixels.

Use `render.screen_size()` for layout. `render.device_size()` returns physical
backbuffer pixels. Cursor, region and drag input use the same authored pixels as
drawing. See [input.drag](input.md#inputdrag).

Geometry arguments must be finite numbers within the 32-bit float range. Widths,
heights and radii must be non-negative. Invalid arguments raise an error. A
zero-sized shape draws nothing.

## render.rect

```text
render.rect(x: number, y: number, width: number, height: number, tint: color)
```

Draws a filled rectangle from its top-left corner.

## render.rect_outline

```text
render.rect_outline(x: number, y: number, width: number, height: number, tint: color, thickness: number = 1)
```

Draws an outline inside the rectangle. Thickness must be positive. It is raised to at least one device pixel, then limited to half the smaller dimension. Rectangles whose smaller dimension is at most two authored pixels become a fill.

## render.rounded_rect

```text
render.rounded_rect(x: number, y: number, width: number, height: number, radius: number, tint: color, corner_segments: integer = 12)
```

Draws a filled rounded rectangle. The radius is capped at half the smaller dimension. A radius of `0` gives square corners. Each corner uses 2-32 segments.

## render.rounded_rect_outline

```text
render.rounded_rect_outline(x: number, y: number, width: number, height: number, radius: number, tint: color, thickness: number = 1, corner_segments: integer = 12)
```

Draws an antialiased rounded-rectangle outline. The stroke is centered on the
edge `render.rounded_rect` fills with the same arguments, so an outline drawn
over a fill of the same size traces its border. Radius and corner segments
follow `render.rounded_rect`. Thickness must be positive and has a minimum of
one device pixel.

## render.line

```text
render.line(x1: number, y1: number, x2: number, y2: number, tint: color, thickness: number = 1)
```

Draws an antialiased line between two points. Positive thickness is centered on the line and has a minimum of one device pixel. Lines shorter than `0.001` authored pixels draw nothing.

## render.circle

```text
render.circle(x: number, y: number, radius: number, tint: color, segments: integer = 48)
```

Draws a filled circle centered on `(x, y)`. Segments must be between 8 and 256.

## render.circle_outline

```text
render.circle_outline(x: number, y: number, radius: number, tint: color, thickness: number = 1, segments: integer = 48)
```

Draws an antialiased ring centered on the radius. Thickness must be positive and has a minimum of one device pixel. Segments must be between 8 and 256.

## render.triangle

```text
render.triangle(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, tint: color, tint2: color? = nil, tint3: color? = nil)
```

Draws a filled antialiased triangle. Either winding order is accepted.

Pass one color to fill it flat. Pass three and each point gets its own color,
blended across the face. A fan of these around one center makes a radial
gradient:

```lua
-- a soft glow: solid in the middle, clear at the rim.
local function glow(x, y, radius, tint)
    local rim = tint:alpha(0)
    local steps = 32
    for i = 0, steps - 1 do
        local a = i / steps * math.pi * 2
        local b = (i + 1) / steps * math.pi * 2
        render.triangle(x, y,
            x + math.cos(a) * radius, y + math.sin(a) * radius,
            x + math.cos(b) * radius, y + math.sin(b) * radius,
            tint, rim, rim)
    end
end
```

Passing a second color without a third raises an error.

## render.gradient

```text
render.gradient(x: number, y: number, width: number, height: number, top: color, bottom: color)
```

Draws a vertical gradient between the two colors.

## render.clip

```text
render.clip(x: number, y: number, width: number, height: number, callback: function())
```

Runs a function with drawing restricted to the rectangle. Nested clips intersect. The previous clip is restored even when the function raises an error. The error then reaches the caller.

The callback receives no arguments and its return values are ignored. Coordinates still start at the screen origin. An empty clip still runs the callback. Each call costs `2` [native work units](../limits.md#native-calls).

Between clip changes, shapes draw first, then built-in text grouped by font, then images. A custom-font text call keeps its position in the draw order: earlier drawing stays behind it, and later drawing stays in front. Use separate clip calls to order groups that only use built-in fonts.

```lua
local background = color(20, 20, 24, 220)

on.paint(function()
    render.rect(24, 24, 180, 40, background)
    render.clip(34, 34, 160, 20, function()
        render.text(34, 34, 'this text stays inside the panel', color.white)
    end)
end)
```

## render.gradient_corners

```text
render.gradient_corners(x: number, y: number, width: number, height: number, top_left: color, top_right: color, bottom_left: color, bottom_right: color)
```

Draws a smooth four-corner gradient, including alpha. Shares the same clipping,
opacity and transforms as other shapes. Zero width or height draws nothing.
Invalid geometry or a full drawing buffer raises an error.

Costs `1 + floor(prepared_vertices / 256)` native work units. The prepared mesh
depends on the dimensions and corner colors.

## render.opacity

```text
render.opacity(amount: number, callback: function)
```

Multiplies the alpha of every shape, text and image submitted by the callback.
`amount` must be in `0..1`. Nested scopes multiply together. Already submitted
drawing receives the opacity even when the callback raises an error, which is
then propagated. Drawing after the scope is unchanged.

Overlapping objects blend individually. This is not an offscreen group whose
combined image fades as one object.

Costs `2 + floor(submitted_vertices / 256)` native work units, including when
the callback raises an error.

## render.layer

```text
render.layer(callback: function)
```

Places drawing from the callback after earlier drawing and before later drawing.
Use separate layers when a later shape must cover earlier text or images.
The normal batching rules still apply inside each layer. Nested layers work,
and callback errors close the layer before propagating. Costs one native work unit.

## Retained paths

Prepare a path once, then draw it with different positions or colors. Creation
is available while loading and in render-side callbacks. Drawing requires a
drawing callback. Coordinates use authored pixels.

```text
render.path(commands: path_command[], options: path_options? = nil) -> path
path_command: table
path_command.kind: string
path_command.point: vec2?
path_command.control1: vec2?
path_command.control2: vec2?
path_options: table
path_options.stroke_width: number?
path_options.fill_rule: string?
path_options.join: string?
path_options.cap: string?
path_options.miter_limit: number?
```

Commands form a dense array. Start each contour with `move`.

| Kind | Fields |
| --- | --- |
| `move` | `point` starts a contour. |
| `line` | `point` ends a straight segment. |
| `quadratic` | `control1`, `point` define a quadratic curve. |
| `cubic` | `control1`, `control2`, `point` define a cubic curve. |
| `close` | Closes the current contour. No point fields. |

Paths are filled by default. Set a positive `stroke_width` to prepare a stroke.
`fill_rule` is `"nonzero"` by default or `"even_odd"` for alternating interiors.
`join` is `"miter"`, `"bevel"` or `"round"`. `cap` is `"butt"`, `"square"`
or `"round"`. Miter joins and butt caps are the defaults. `miter_limit` defaults
to `10` and must be at least `1`. Unknown fields and invalid values raise an error.

Concave and intersecting contours use the selected fill rule. Curves are prepared
for the supported DPI range. Drawing a prepared path does not repeat that work.
Strokes are centered on their contours and do not automatically grow to one
device pixel. Paths have ordinary raster edges without an added feather border.

Each path accepts up to 4096 commands and enough prepared triangles to fit one
shape drawing buffer. Preparation costs `128 + floor(commands / 16)` native work
units. Its triangles are retained in Lua memory. There is no separate path-count
allowance. Invalid input or exhausted preparation resources raise an error.

The input and retained triangles are bounded. Native preparation may use
additional temporary memory and has no wall-time interrupt. Shape complexity
affects preparation time, so keep and reuse prepared paths.

```lua
local marker = render.path({
    {kind = 'move', point = vec2(0, 14)},
    {kind = 'line', point = vec2(7, 0)},
    {kind = 'line', point = vec2(14, 14)},
    {kind = 'close'}
})

on.paint(function()
    marker:draw(24, 24, color.white)
end)
```

### Point and curved shapes

```text
render.polygon(points: vec2[], options: path_options? = nil) -> path
render.polyline(points: vec2[], options: path_options? = nil) -> path
render.arc(radius: number, start_degrees: number, sweep_degrees: number, options: path_options? = nil) -> path
render.rounded_outline(width: number, height: number, radius: number, options: path_options? = nil) -> path
```

These constructors return the same retained path type. A polygon closes its
contour. A polyline remains open and defaults to a one-pixel authored stroke.
Use a polygon with `stroke_width` for a closed line. A polygon takes at most
4095 points and a polyline at most 4096. More, or none, raises an error.

An arc is centered on `(0, 0)`. Zero degrees points right and positive sweep
turns clockwise. Sweep must be within `-360..360`. Rounded outlines start at
`(0, 0)` and limit radius to half their smaller dimension. Arcs and rounded
outlines are stroked. Their width defaults to one authored pixel. Radius and
dimensions must be non-negative; zero-sized shapes are empty.

### path:draw

```text
path:draw(x: number, y: number, tint: color)
```

Draws the prepared triangles translated by `(x, y)`. Clipping, transforms and
opacity apply normally. Costs `1 + floor(vertices / 256)` native work units.
A full drawing buffer refuses the complete path. Invalid coordinates or a
released path raise an error. Submitted drawing survives release later that frame.

### path:bounds

```text
path:bounds() -> left: number, top: number, width: number, height: number
```

Returns the prepared geometry's bounds before translation, including stroke
width. An empty path returns four zeros. Available in every callback and while
loading. A released path raises an error.

### path:release

```text
path:release()
```

Invalidates the path. Repeated calls are harmless. Lua reclaims its triangle
storage when the value is collected or the script unloads.

## render.text

```text
render.text(x: number, y: number, text: string, tint: color, font: font? = nil)
```

Draws text with the menu font, or the supplied font. `(x, y)` is the top-left of the text's layout cell, not its baseline or first visible pixel. Text is limited to 4096 bytes.

Exceeding the limit or using a released font raises an error. Empty text draws nothing. With a built-in font, invalid UTF-8 or a failed layout draws nothing and records a log message. With a custom font, a failed layout or submission records `why.last()` and raises an error.

Drawing costs `3 + floor(text_bytes / 256)` native work units with any font, built-in or custom. The font's size follows the current DPI scale.

## render.measure_text

```text
render.measure_text(text: string, font: font? = nil) -> (width: number, line_height: number) | nil
```

Measures text in authored pixels using the same font as `render.text`. The second result is one full line height, not a tight glyph box or the total height of multiline text.

An empty string has zero width and still returns the line height. Use the same font when measuring and drawing. The text limit is 4096 bytes.

With a built-in font, a failed or unavailable measurement returns zero width and may record a log message. With a custom font, failure returns a single `nil` and records `why.last()`. A released font raises an error. Measurement costs `1 + floor(text_bytes / 256)` native work units with any font.

```lua
local background = color(20, 20, 24, 220)

on.paint(function()
    local text = 'ready'
    local width, height = render.measure_text(text)
    local screen_width = render.screen_size()
    local x = (screen_width - width) / 2

    render.rect(x - 10, 20, width + 20, height + 16, background)
    render.text(x, 28, text, color.white)
end)
```

## render.font

```text
render.font(name: string) -> font | nil
```

Selects a built-in font from the table below. Names are case-sensitive.

Returns `nil` for an unknown font and records [why.last()](why.md#whylast). Lookup is allowed while loading and in any callback. Keep the returned handle and reuse it.

| Name | Face | Size | Style |
| --- | --- | --- | --- |
| `menu` | Segoe UI | 14 points | Regular |
| `esp_name` | Verdana | 11 points | Bold, drop shadow |
| `esp_small` | Tahoma | 9 points | Outlined |
| `esp_info` | Tahoma | 12 points | Drop shadow |
| `dropped` | Tahoma | 11 points | Outlined |
| `brand` | Segoe UI | 20 points | Bold |
| `console` | Lucida Console | 10 authored pixels | Aliased, drop shadow |

Point sizes convert at `96 / 72` authored pixels per point. Dylanhook updates
these fonts for the current scale. Keep the handle for the script's lifetime.

## render.load_font

```text
render.load_font(family: string, size: number, weight: string | integer = "normal", options: font_options? = nil) -> font | nil
```

Loads an installed Windows font family at an authored pixel size. Create it while
loading or in a render-side callback, then keep the handle for drawing and
measurement. `size` is an em size, not visible letter height or a point size.

Use the height returned by `render.measure_text(text, font)` to size a text row.
Pass that same font to `render.text`. For vertical centering, place the text at
`row_y + (row_height - text_height) / 2`. Account for borders and padding outside
that row. A font's requested size is not a substitute for its measured line height.

```lua
local heading = render.load_font("Segoe UI", 18, "bold")
assert(heading, why.last())

on.paint(function()
    render.text(24, 24, "Ready", color.white, heading)
end)
```

| Argument or resource | Accepted value |
| --- | --- |
| `family` | An installed family name, up to 384 UTF-8 bytes and 127 UTF-16 code units. |
| `size` | A positive finite number up to `512 / 6` authored pixels (about 85.33), sized to remain within the font renderer's limit at every supported DPI. |
| `weight` | A weight name -- `"thin"`, `"extra_light"`, `"light"`, `"normal"`, `"medium"`, `"semi_bold"`, `"bold"`, `"extra_bold"` or `"black"` (100 through 900) -- or a whole number from 1 to 999 on the same scale. Omitting it or passing `nil` selects normal. The family's nearest face is used, with bold synthesized where the family has none. |
| Live custom fonts | Eight per script. Built-in font handles do not use these slots. |
| Each load attempt | 128 native work units. |

A missing family returns `nil`. Another family is not silently selected for it. Windows may use other installed fonts for characters the chosen family lacks. Font files cannot be loaded through this function.

Invalid family encoding, unsupported sizes, a missing family or a resource limit returns `nil` and records `why.last()`. Wrong argument types, an unknown weight, an unsupported callback context and an exhausted work allowance raise an error. A device-dependent failure can still occur on the first draw.

The font automatically follows scale and rendering-device changes. It belongs to the loaded script and is released on unload, garbage collection or an explicit release.

```text
font_options: table
font_options.italic: boolean?
font_options.render_mode: string?
font_options.decoration: string?
font_options.letter_spacing: number?
```

`italic` defaults to `false`. `render_mode` is `"natural"` or `"aliased"`,
with natural smoothing by default. `decoration` is `"none"`, `"dropshadow"`
or `"outline"`. Decoration affects drawing and does not enlarge text measurements.
`letter_spacing` adds authored pixels after every character, the last included.
It defaults to `0` and can be negative. It is part of the text layout, so
`render.measure_text` and layouts measure what is drawn, and it scales with the
display like the size does. It must be within `-size / 2` to `size`. A value
outside that range makes the load return `nil`. Unknown fields or values raise
an error.

## render.load_font_file

```text
render.load_font_file(name: string, size: number, weight: string | integer = "normal", options: font_options? = nil) -> font | nil
```

Loads a bundled TTF or OTF from the script's asset folder. Pass a leaf filename,
such as `heading.ttf`, using the same naming rules as [assets.read](resources.md#filenames).
Ship a font you have permission to distribute beside your other script assets.

Call while loading or in a render-side callback. Size, weight and the eight-font allowance are shared with
`render.load_font`. Files are limited to 4 MiB and must contain one supported
font family. Files containing several families are refused. Each attempt costs 128 native work
units. A missing, invalid or unsupported file returns `nil` and records `why.last()`.

The returned handle uses the same drawing, measurement and release methods as an
installed font. Its `.name` is the supplied filename. Font bytes are retained for
the loaded script, so deleting or changing the file does not alter that handle.
Reload to read a changed font. Device and DPI changes are handled automatically.

## render.layout_text

```text
render.layout_text(text: string, font: font, width: number, options: text_layout_options? = nil) -> text_layout
```

Creates a reusable text layout. Text is limited to 4096 bytes and
width must be positive and finite, in authored pixels. Construction is available
during setup and callbacks. It allocates Lua values without a native-work charge.

The descriptor keeps its text and font alive. There is no separate layout-count
allowance. Native shaping and glyph data share the font's bounded cache. Reuse a
descriptor while its text and width stay the same, and create another when they change.

```text
text_layout_options: table
text_layout_options.flow: string?
text_layout_options.align: string?
```

`flow` is `"wrap"` by default. `"trim"` keeps each explicit line on one row
and adds an ellipsis when it exceeds the width. Trimming preserves Unicode
clusters. `align` is `"left"`, `"center"` or `"right"`, relative to the layout
width on each line. Left alignment is the default. Unknown options raise an error.

Wrapping, Unicode shaping and line heights use the same text layout for measuring
and drawing. Layouts follow the current DPI scale. Explicitly releasing the font
makes later measurement and drawing raise an error; it does not select another font.

```lua
local body = render.load_font('Segoe UI', 16)
assert(body, why.last())
local layout = render.layout_text('A measured panel wraps its text to the available width.', body, 220)

on.paint(function()
    local width, height = layout:size()
    if not width then return end
    render.rounded_rect(20, 20, math.max(220, width) + 24, height + 24, 6, color(24, 24, 28, 230))
    assert(layout:draw(32, 32, color.white), why.last())
end)
```

### layout:size

```text
layout:size() -> (width: number, height: number) | nil
```

Returns the measured text width and complete multiline height in authored pixels.
Requires paint or an ESP item measure/draw callback. Width includes trailing spaces and can be smaller than
the requested wrapping width. Explicit newlines contribute full lines.

Costs `1 + floor(text_bytes / 256)` native work units. A shaping or resource failure
returns `nil` and records `why.last()`. Invalid UTF-8 and a wrapping width outside
the native layout's supported range are refused. A released layout or font raises an error.

### layout:draw

```text
layout:draw(x: number, y: number, tint: color) -> true | nil
```

Draws the complete layout from its top-left cell in a drawing callback. Coordinates
are authored pixels. Uses the supplied font, including built-in font decoration,
and preserves submission order with surrounding drawing.

Costs `3 + floor(text_bytes / 256)` native work units. Returns `true` after submission,
or `nil` with `why.last()` when layout preparation or submission fails. A released
layout or font raises an error. Submitted glyphs remain drawable if the font is
released later in the same frame.

### layout:metrics

```text
layout:metrics() -> text_metrics | nil
text_metrics: table
text_metrics.width: number
text_metrics.height: number
text_metrics.left: number
text_metrics.top: number
text_metrics.ink_left: number
text_metrics.ink_top: number
text_metrics.ink_right: number
text_metrics.ink_bottom: number
text_metrics.line_count: integer
```

Returns copied measurements in authored pixels. Width includes trailing spaces.
`left` and `top` locate the text within its layout cell. The four `ink_*` fields
bound the visible glyphs relative to that cell, excluding shadow or outline.
`line_count` includes explicit and wrapped lines.

Available wherever `layout:size()` is available, with the same cost and failure behavior.

### layout:release

```text
layout:release()
```

Releases the descriptor's retained text and font references. Repeated release is
harmless. Garbage collection and unload release these references automatically.
This does not explicitly release a font still held by another Lua value.

## font.name

```text
font.name: string
```

Read-only built-in role name, installed family name or bundled font filename. It is available while loading and in any callback. Reading it after release raises an error. Unknown fields return `nil`. Assigning a field raises an error.

## font:release

```text
font:release()
```

Releases this handle. Repeated calls are harmless. A custom font's resource slot is freed at the start of the next frame. Releasing a built-in handle leaves the shared built-in font available to other handles.

Text already submitted remains drawable through the frame. Further drawing, measurement or name reads through the released handle are refused. This method is available while loading and in any callback.

## font:metrics

```text
font:metrics() -> font_metrics | nil
font_metrics: table
font_metrics.ascent: number
font_metrics.descent: number
font_metrics.line_gap: number
font_metrics.line_height: number
```

Returns copied font measurements in authored pixels for the current DPI. Ascent
is the line's baseline offset. Descent and line gap come from the font face.
Line height is the spacing used by drawing, including pixel rounding.

Requires paint or an ESP item measure/draw callback and costs one native work unit. A resource failure
returns `nil` with `why.last()`. A released font raises an error.

## render.load_image

```text
render.load_image(bytes: string, format: string) -> texture | nil
```

Decodes PNG, JPEG or BMP into a texture. `format` is `"png"`, `"jpeg"` or
`"bmp"`, and the bytes must begin with that format's signature. A mismatch
returns `nil` with `why.last()` naming `format_mismatch`. Dimensions come from the image.
Pass exactly two arguments, the encoded bytes and format.

Call while loading or in a render-side callback. Decoding completes before the
call returns. Use [assets.read](resources.md#assetsread) to read a packaged image.

| Resource | Limit |
| --- | --- |
| Encoded input | 4 MiB per image. |
| Width and height | 1-2048 image pixels each. |
| Frames | One per image. |
| Decoded image | Up to 16 MiB, at four bytes per pixel. |
| Live textures | 16 per script. |
| Retained CPU pixel-buffer storage | 32 MiB total per script. |
| Each decode | 128 [native work units](../limits.md#native-calls). |

Empty data and animated images are refused. The texture belongs to the loaded
script. The original byte string need not be retained. Cache the handle and
reuse it when drawing.

The pixel allowance covers retained CPU pixel-buffer storage, which can exceed
the image's logical byte count. Native decoding can use additional temporary
memory and is not a wall-time limit.

Invalid image data or a texture-limit failure returns `nil` and records [why.last()](why.md#whylast). Bad argument types, an unsupported callback context and exhausted work allowances raise an error. Failed decode attempts spend the same work allowance.

## render.game_icon

```text
render.game_icon(name: string, source: string = "equipment_svg") -> image_request | nil
```

Prepares a game icon in the background. Returns an [image request](#image-requests),
with the same activation, cancellation and texture limits as `render.prepare_image`.
Call while loading or in an active callback except unload. Each call costs one
native work unit.

`equipment_svg` reads the game's equipment art. Names such as `weapon_ak47`,
`item_defuser` and `ak47` use the game's equipment naming convention.
`econ_silhouette` reads the alpha silhouette of an exact inventory-image stem.
It preserves that stem, including any `weapon_` prefix. Sources never fall back
to each other.

Names contain ASCII letters, digits, underscores or hyphens, without a directory
or extension. The normalized stem may contain up to 95 bytes. Missing art and
unsupported resources produce a failed request, with the reason available from
`why.last()` after `request:take()`.

Both sources produce white coverage art at 32 pixels high, with width derived
from the image's aspect and limited to 256 pixels. Tint it with `render.image`.
These are silhouettes, not full-color inventory thumbnails.

## render.draw_game_icon

```text
render.draw_game_icon(name: string, x: number, y: number, height: number, tint: color, source: string = "equipment_svg") -> number | false | nil
```

Draws a game icon from the shared icon cache native ESP uses, so it takes no
texture from your script's 16. Use this for weapon icons in custom ESP, where a
texture per icon would run out. The icon is drawn `height` authored pixels tall
at its own aspect, and the call returns the drawn width. Names and sources
follow [render.game_icon](#rendergame_icon), and `height` must be in `(0, 256]`.
Available in paint callbacks, including an ESP item's `draw`. Costs one native
work unit.

Returns `false` while the cache is still preparing the icon: call again next
frame. Returns `nil` with [why.last()](why.md#whylast) set when the icon cannot
be drawn at all. `icon_not_found` means the game has no art for that name.
`icon_admission_limit` means the session has already admitted 256 icon names
chosen by scripts and this one is new. `icon_unavailable` means the cache has
no rendering device yet. `image_frame_full` and `viewport_unavailable` mean the
icon wasn't queued, as with [render.image](#renderimage). Icons draw in the
order your script draws them.

## render.measure_game_icon

```text
render.measure_game_icon(name: string, height: number, source: string = "equipment_svg") -> number | false | nil
```

Returns the width `render.draw_game_icon` would draw the icon at `height`,
without drawing it, `false` while the icon is being prepared, or `nil` with
the same reasons. Available wherever text can
be measured, including an ESP item's `measure`. Costs one native work unit.

## render.game_resource

```text
render.game_resource(name: string) -> image_request | nil
```

Prepares a packaged game image in the background, such as
`backgrounds/weekly_rewards_png`. Returns an
[image request](#image-requests) with the same activation, cancellation and
texture limits as `render.game_icon`. Call while loading or in an active
callback except unload. Each call costs one native work unit.

Name the image by its path inside the game's image folder, without the compiled
extension. Use lowercase ASCII letters, digits, underscores, hyphens and dots,
separated by `/`, with no empty, `.` or `..` segment, in at most 233 bytes. Other
names raise an error. The image keeps its packaged color and size. A missing
image produces a `failed` request. One the game does not store as a single
PNG-backed texture produces an `unavailable` request. Either way the reason is
available from `why.last()` after `request:take()`.

## Image requests

```text
render.prepare_image(bytes: string, format: string) -> image_request | nil
```

Prepares an image asynchronously. Arguments and image limits match
`render.load_image`. Available while loading and in active callbacks except
unload. Loading stages the request; work starts after the script activates. Each request costs
128 native work units. The request owns a copy of the input bytes.

Keep the request until it finishes. Garbage collection, cancellation and script
unload discard it. Already running native work may finish before its memory is
released, but its discarded result cannot appear in another request.

All scripts share 16 preparation slots, up to 64 MiB of encoded input and 32 MiB
of retained CPU pixel-buffer storage for completed images. One script holds at
most 8 slots and 16 MiB of that storage, so it cannot starve the others. Decoder
working memory is separate. These limits also apply to unsafe scripts. A queue,
share or input refusal returns `nil` with `why.last()`, such as `queue_full` or
`owner_limit`. A completed image that would exceed the storage fails with
`output_limit`, or `owner_output_limit` when the script's own share is the bound.

```lua
local bytes = assert(assets.read('badge.png'), why.last())
local request = render.prepare_image(bytes, 'png')
assert(request, why.last())
local badge

on.paint(function()
    if request and request:status() == 'ready' then
        badge = request:take()
        if badge then request = nil end
    end
    if badge then render.image(badge, 24, 24, 32, 32) end
end)
```

The same request type is returned by [player.avatar](entity.md#playeravatar).

### request:status

```text
request:status() -> string
```

Returns `"pending"`, `"ready"`, `"failed"`, `"unavailable"`, `"consumed"` or
`"cancelled"`. Unavailable means the source has no image; it does not create a
blank texture. A failed or unavailable request retains its failure for `take()`
without retaining a native preparation slot.

### request:take

```text
request:take() -> texture | false | nil
```

Returns a texture from a ready image. Available while
loading and in render-side callbacks. Costs one native work unit. Pending work
returns `false` and leaves `why.last()` alone. A terminal failure returns `nil`
and records `why.last()`.

If the script's texture slots or pixel allowance are full, the request stays
ready so it can be retried after releasing textures. Successful transfer marks
it consumed. Taking a consumed or cancelled request raises an error. The returned
texture has the usual drawing, size, release and device-change behavior.

### request:cancel

```text
request:cancel()
```

Discards outstanding work and any untaken image. Available in every callback and
while loading. Repeated calls are harmless. It does not release a texture that
was already taken.

## texture:size

```text
texture:size() -> (width: integer, height: integer) | nil
```

Returns the original image dimensions in image pixels. Returns a single `nil` and sets `why.last()` after release. This method is available while loading and in any callback.

## texture:write

```text
texture:write(x: integer, y: integer, width: integer, height: integer, bytes: string) -> true | nil
```

Overwrites a box of the texture with new pixels: `bytes` is the box's RGBA8,
row major, straight alpha, exactly `width * height * 4` bytes, the same layout
[render.load_rgba](#renderload_rgba) takes. `x` and `y` are the box's top-left
corner in texture pixels. Works on every texture, decoded images included.

Only the box goes to the GPU, at the texture's next draw, so a live graph, a
minimap or a glyph atlas updates in place instead of being rebuilt. A texture
shows its last write of the frame everywhere it's drawn in that frame.

Available while loading and in render-side callbacks, like `render.load_rgba`.
Costs `1 + ceil(bytes / 65536)` native work units. A box outside the texture or
the wrong byte count raises an error. A released texture returns `nil` with
`why.last()` set.

```lua
-- a 128x32 sparkline, one column redrawn per frame.
local graph = render.load_rgba(string.rep('\0', 128 * 32 * 4), 128, 32)
local column = 0

on.paint(function()
    local level = math.floor((math.sin(globals.real_time()) * 0.5 + 0.5) * 31)
    local pixels = {}
    for row = 0, 31 do
        pixels[#pixels + 1] = row >= 31 - level and '\255\255\255\255' or '\0\0\0\0'
    end
    graph:write(column, 0, 1, 32, table.concat(pixels))
    column = (column + 1) % 128
    render.image(graph, 20, 20, 128, 32)
end)
```

## texture:release

```text
texture:release()
```

Releases the texture. Repeated calls are harmless. Textures are also released when collected or when their script unloads. This method is available while loading and in any callback.

Size and image calls refuse a released handle immediately. Releasing a texture during source load does not make room for another decode in that load. Images already queued remain drawable through the frame. Unknown texture fields return `nil`. Assigning fields raises an error.

## render.load_rgba

```text
render.load_rgba(bytes: string, width: integer, height: integer) -> texture | nil
```

Creates a texture from tightly packed, row-major RGBA8 bytes while loading or in a render-side callback. Each
pixel has red, green, blue and alpha bytes in that order. Alpha is straight,
not premultiplied. The input must contain exactly `width * height * 4` bytes.

Dimensions are 1-2048 pixels. Raw RGBA and decoded images share the same 16 live slots,
32 MiB retained CPU pixel-buffer allowance and texture methods. The bytes are
copied, so the Lua string need not be retained. Device changes recreate the
texture from that copy.

Each attempt costs `1 + ceil(input_bytes / 65536)` native work units. Wrong dimensions
raise an argument error. A byte-count or resource failure returns `nil` and records
`why.last()`, including `rgba_size_invalid`, `texture_limit` or `texture_byte_limit`.

```lua
local pixels = string.char(255, 255, 255, 255, 255, 90, 170, 255)
local strip = render.load_rgba(pixels, 2, 1)
assert(strip, why.last())
on.paint(function() render.image(strip, 20, 20, 100, 16) end)
```

## render.transform

```text
transform_options: table
transform_options.rotation: number?
transform_options.origin: vec2?
transform_options.translation: vec2?
transform_options.scale: vec2?

render.transform(options: transform_options, callback: function())
```

Transforms all shapes, text and images submitted by the callback. Requires a drawing callback.
The callback receives no arguments and its return values are ignored.

| Option | Default | Meaning |
| --- | --- | --- |
| `rotation` | `0` | Clockwise degrees. |
| `origin` | `vec2(0, 0)` | Scaling and rotation origin, in authored pixels. |
| `translation` | `vec2(0, 0)` | Movement after scaling and rotation. |
| `scale` | `vec2(1, 1)` | Independent axis scales. Negative values mirror; zero collapses an axis. |

Options must be finite. Unknown fields raise an error. The order is scale around
the origin, rotate around the origin, then translate. An outer scope transforms
the completed result of each inner scope. Drawing outside the callback is unchanged.
Measurement returns the original layout size; transforms do not change input hit areas.

Clip rectangles remain in screen space. Use `render.clip` for the final visible
area; a rotated shape does not rotate its scissor rectangle.

```lua
on.paint(function()
    render.transform({rotation = 12, origin = vec2(120, 60)}, function()
        render.rounded_rect(20, 20, 200, 80, 6, color(24, 24, 28, 230))
        render.text(36, 40, 'rotated panel', color.white)
    end)
end)
```

Work is proportional to the submitted vertices: `2 + floor(vertex_count / 256)`
native work units. Nested scopes process their own ranges. Unsafe mode only
measures this work. If the callback or the closing work check fails, drawing already
submitted inside the scope still receives its transform before the error propagates.
An unrepresentable transformed coordinate discards the whole scope and raises
`coordinate_overflow`; it never leaves partially transformed drawing.

## render.image

```text
render.image(texture: texture, x: number, y: number, width: number, height: number, tint: color? = nil) -> true | nil
render.image(texture: texture, x: number, y: number, width: number, height: number, tint: color?, source_x: number, source_y: number, source_width: number, source_height: number) -> true | nil
```

Draws an image in a drawing callback. Omitting `tint` or passing `nil` uses white and preserves the image's color and alpha. Each image channel is multiplied by the matching tint channel divided by `255`.

Omit the source rectangle to draw the whole image. To crop, provide all four source arguments in original image pixels. `source_x` and `source_y` must be non-negative. The crop must have positive dimensions and fit inside the image. The destination uses authored pixels.

The cropped form takes exactly ten arguments. Pass `nil` in the tint position for an untinted crop. Passing only part of the source rectangle, or `nil` for one of its numbers, raises an error.

Returns `true` when submitted, or `nil` with `why.last()` set when it was not: a released or unavailable texture, `image_frame_full` when the frame's image allowance is spent, or `viewport_unavailable`. Invalid geometry raises an error. A successful call can still be invisible because of clipping, a zero-sized destination, or an off-screen position.

With `badge.png` in the script's asset folder:

```lua
local bytes = assets.read('badge.png')
assert(bytes, why.last())
local badge = render.load_image(bytes, 'png')
assert(badge, why.last())
local width, height = badge:size()

on.paint(function()
    render.image(badge, 24, 24, width, height)
end)
```

## render.screen_size

```text
render.screen_size() -> width: integer, height: integer
```

Returns the authored viewport dimensions: device size divided by `render.dpi_scale()`, rounded down. Use these with drawing and projection coordinates.

## render.device_size

```text
render.device_size() -> width: integer, height: integer
```

Returns the backbuffer dimensions in device pixels.

## render.dpi_scale

```text
render.dpi_scale() -> number
```

Returns the scale from authored pixels to device pixels. Available wherever text can be measured or input read, including menu button callbacks. `render.screen_size` and `render.device_size` require a drawing callback.

## render.world_to_screen

```text
render.world_to_screen(position: vec3) -> vec2 | nil
```

Projects a world position into authored screen coordinates from the current render snapshot. Returns `nil` when the view is unavailable or the point is behind the near plane. Check the result before using `.x` or `.y`. Reading a projection does not give an ESP value callback a drawing surface.

A projected point can lie outside the screen rectangle. Projection uses the same frame as the player snapshot.

## render.camera

```text
render.camera() -> table | nil
```

Returns the camera used by the current render snapshot, or `nil` when unavailable.

| Field | Type | Meaning |
| --- | --- | --- |
| `position` | `vec3` | World position |
| `angles` | `vec3` | Pitch, yaw and roll in degrees |
| `fov` | number | Horizontal field of view in degrees |
| `capture_id` | string | Exact render capture identity. |
| `application` | string | `"engine"`, `"thirdperson"`, `"free_camera"`, `"script"`, `"refused"` or `"unavailable"`. Reports the actual view edit, not the requested setting. `"script"` means an [`on.override_view`](../events.md#onoverride_view) callback moved the camera. |
| `observer_mode` | integer or nil | Current copied local observer mode, when available. |

The returned table and vectors are copies. You can keep them between callbacks, but they don't update themselves. Camera and projection failures record `why.last()`.

## Drawing limits

These limits are shared by all scripts, built-in overlays and the menu in one rendered frame.

| Drawing | Frame limit |
| --- | --- |
| Shapes | 1,048,576 vertices. |
| Built-in text | 131,072 vertices per font, including shadows and outlines. |
| Custom text | 131,072 vertices shared by all custom fonts. |
| Images | 16,384 image quads with a nonzero destination. |

A shape or built-in text run that doesn't fit is skipped and logged. A custom text run that doesn't fit is refused whole and raises an error. An image over the frame limit is skipped and its call returns `nil` with `image_frame_full`. Images that use the same texture one after another draw together, so an atlas costs one draw for a whole run of crops; the limit counts quads, not draws. These are geometry limits, so a circle or an outline uses more of the allowance than a filled rectangle.
