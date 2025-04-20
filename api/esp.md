# Native ESP contributions

Add flags, text, bars or custom measured items to the native player ESP layout. Native names, health,
ammo, distance, weapon icons and flags keep their normal spacing around script
items. [`esp.chams`](#espchams) and [`esp.glow`](#espglow) decide a player's model
material and outline.

## esp.add_flag

```text
esp.add_flag(id: string, options: table) -> subscription
```

Registers a short label using the native small ESP font. Register during source
loading. `id` is unique within the script and contains 1-64 printable bytes.

| Option | Meaning |
| --- | --- |
| `value` | Required function receiving a pawn identity and returning a string, optionally followed by a color. |
| `side` | `"left"`, `"right"`, `"top"` or `"bottom"`. Default: `"right"`. An item also accepts `"box"` ([Box items](#box-items)). |
| `targets` | `"enemy"`, `"team"`, `"local"` or `"all"`. Default: `"enemy"`. |
| `color` | Default color. White when omitted. A returned color overrides it for that item. |
| `label` | Optional descriptive name, 1-128 printable bytes. Defaults to `id`. It does not create a menu control. |

Return `nil`, `false` or an empty string to omit a label. A visible result must
be one line of at most 256 bytes. NUL, tabs, line breaks and other ASCII control
bytes are refused. Invalid results disable that callback
and report its error without disabling the other callbacks or the script's paint.
Valid text with no visible width is omitted without disabling the callback.

```lua
esp.add_flag("scoped", {
    side = "right",
    color = color(160, 210, 255),
    value = function(pawn)
        if player.is_scoped(pawn) then return "SCOPED" end
    end
})
```

## esp.add_text

```text
esp.add_text(id: string, options: table) -> subscription
```

Uses the same options and result rules as `esp.add_flag`, with the native
information font.

## esp.add_bar

```text
esp.add_bar(id: string, options: table) -> subscription
```

The same options, except `value` returns a finite fraction in `[0, 1]`, optionally
followed by a color. `nil` or `false` hides the bar. Zero is a real empty bar, not
absence. Out-of-range fractions are refused rather than silently clamped.

Left and right bars are vertical and fill upward. Top and bottom bars are
horizontal and fill to the right. Native ESP handles their size, border and
spacing.

```lua
esp.add_bar("armor", {
    side = "left",
    color = color(100, 175, 255),
    value = function(pawn)
        local armor = player.armor(pawn)
        if armor == nil then return nil end
        return math.clamp(armor / 100, 0, 1)
    end
})
```

## esp.add_item

```text
esp.add_item(id: string, options: table) -> subscription
```

Registers a custom item in the same native layout. Uses the same `id`, `label`,
`side` and `targets` options as the other contributions. Instead of `value` and
`color`, provide two functions:

| Option | Meaning |
| --- | --- |
| `measure` | `function(pawn, context)` returning positive, finite width and height in authored pixels. Return `nil` or `false` to hide the item. |
| `draw` | `function(pawn, context)` drawing inside the final `context.bounds` rectangle. Its return values are ignored. |

Unknown options raise an error. Measurement runs once for each matching pawn.
Drawing follows native placement and runs only for a visible, successfully
measured item. Both callbacks read the same player snapshot.

Each context is a copied table:

| Field | Meaning |
| --- | --- |
| `box` | The native player box, with `x`, `y`, `width` and `height`. |
| `bounds` | The placed item rectangle with the same fields. Present only during `draw`. |
| `side` | The item's configured side. |

Measurement can call `render.measure_text`, `font:metrics`, `layout:size` and
`layout:metrics`. It cannot draw. The draw callback can use the normal rendering
API. Its clip rectangle is the measured item bounds, so text, images and geometry
cannot overlap neighboring items. Input is unavailable in either callback.

Rows are placed alongside native labels before outward bars. Keep measurement and
drawing consistent, including any padding or font decoration. These callbacks
are not used by the menu's ESP preview.

Each phase costs one native-work unit plus its API calls, sharing the existing
ESP frame allowance. An error disables the registration. Removing the
subscription during either phase discards the current item. A draw error also
discards that item's drawing. Unload and reload remove both callbacks together.

```lua
local font = assert(render.load_font('Segoe UI', 14), why.last())

esp.add_item('health label', {
    side = 'bottom',
    measure = function(pawn)
        local health = player.health(pawn)
        if not health then return nil end
        local width, height = render.measure_text(tostring(health) .. ' hp', font)
        if width then return width + 12, height + 6 end
    end,
    draw = function(pawn, context)
        local box = context.bounds
        render.rounded_rect(box.x, box.y, box.width, box.height, 3, color(20, 25, 36, 230))
        render.text(box.x + 6, box.y + 3, tostring(player.health(pawn)) .. ' hp', color.white, font)
    end
})
```

### Box items

An item with `side = 'box'` is drawn over the player box itself rather than
placed among the labels. It takes no `measure`, and passing one raises. Its
`context.bounds` is the box, and `draw` runs for every player the pass accepts,
before the labels. The drawing is clipped to the box grown by the 2-pixel gap
native labels keep from it. That leaves room for an outline without reaching a
label. Only `esp.add_item` accepts `'box'`.

Pair it with [`ref:hide_drawing`](native_settings.md#refhide_drawing) to replace
the native box. The user's box toggle keeps its meaning, so draw yours only while
it is on:

```lua
local enemy_box = assert(menu.find('visuals.esp.enemy.box'))
local hidden = false
on.paint(function()
    if not hidden then
        enemy_box:hide_drawing()
        hidden = true
    end
end)

esp.add_item('corner box', {
    side = 'box',
    draw = function(pawn, context)
        if not enemy_box.value then return end
        local b = context.bounds
        local s = math.min(b.width, b.height) / 4
        local c = color(255, 255, 255)
        render.line(b.x, b.y, b.x + s, b.y, c)
        render.line(b.x, b.y, b.x, b.y + s, c)
        render.line(b.x + b.width, b.y + b.height, b.x + b.width - s, b.y + b.height, c)
        render.line(b.x + b.width, b.y + b.height, b.x + b.width, b.y + b.height - s, c)
    end
})
```

## esp.chams

```text
esp.chams(id: string, options: table) -> subscription
```

Decides how a player's model is drawn: the colored material the native chams
draw, a hidden model, or the game's normal model. Register during source
loading. `id` follows the `esp.add_flag` rules.

| Option | Meaning |
| --- | --- |
| `fn` | Required function receiving a pawn identity and the current answer, and returning a new answer or `nil`. |
| `targets` | `"enemy"`, `"team"`, `"local"` or `"all"`. Default: `"enemy"`. |

The current answer is what the native chams settings chose for that player, or
what an earlier script's `esp.chams` returned:

| Answer | Meaning |
| --- | --- |
| `nil` | The normal model. Nothing is drawn over it. |
| `"hidden"` | The model is not drawn at all. |
| table | `visible` and `occluded` are each a color to draw that pass, or `false` to skip it. `style` is `"shaded"` or `"flat"`. |

Return `nil` to keep the current answer, `false` for the normal model,
`"hidden"` to hide the model, or a table in the same shape. In a returned table
an omitted pass is not drawn, an omitted `style` is `"shaded"`, and a table
drawing neither pass means the normal model. The visible pass draws where the
model can be seen and the occluded pass through walls.

```lua
esp.chams('low_health', {
    targets = 'enemy',
    fn = function(pawn, current)
        local health = player.health(pawn)
        if health and health <= 30 then
            return { visible = color(255, 80, 80), occluded = color(160, 40, 40, 180), style = 'flat' }
        end
    end
})
```

This works with the native chams off. A player hidden with **hide model** or
**hide esp** in the players list is not offered: those choices stay the user's.
Each script can register 8 chams overrides and 8 glow overrides; they do not
count toward the 128 ESP contributions.

## esp.glow

```text
esp.glow(id: string, options: table) -> subscription
```

Decides a player's glow outline. The options are those of `esp.chams`. `fn`
receives the pawn and the current glow color, or `nil` when the player has no
glow, and returns a color, `false` to remove the glow, or `nil` to keep the
current answer.

```lua
esp.glow('scoped', {
    targets = 'enemy',
    fn = function(pawn)
        if player.is_scoped(pawn) then return color(255, 200, 60) end
    end
})
```

This works with the native glow off. Returning `false` removes only Dylanhook's
outline: the outline the game draws itself, such as on teammates, stays.

## Context, visibility and lifetime

Each flag, text or bar callback runs once for every matching player accepted by native ESP. It can
read copied player data but cannot draw or read input. Return the value you want
native ESP to display. `esp.chams` and `esp.glow` callbacks run once per frame
for every matching player the chams and glow consider, under the same rules.

Enemy, team and local filtering follows the native ESP rules. Visible-only
filtering and screen rejection apply to script items too. Script items do not
turn on native names, boxes or health bars.

The returned subscription supports `.active` and `:remove()`. Removing it
inside its callback discards the current item. Reloading or unloading the script
removes all of its ESP registrations.

All ESP callbacks from one script share an execution allowance for that ESP
frame. Each evaluation costs one native-work unit plus the API calls it makes.
Standard mode stops further ESP callback work for the frame if the allowance is
exhausted. Unsafe mode keeps the measurements but does not enforce the threshold.
A callback that raises an error is disabled.

At most 128 ESP contributions can be registered across all loaded scripts.
Removing one frees its slot when the script reloads or unloads.
