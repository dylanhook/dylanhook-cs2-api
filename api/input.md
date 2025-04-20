# Input

Read the current frame's keyboard and mouse state, route mouse presses to regions your script draws, or take the mouse and keyboard from the game while your own interface is open.

Frame-input functions are available in `on.paint`, `on.paint_above_menu` and
menu button callbacks. Other phases, including source load, timers and
control-change callbacks, raise an error. `input.capture` is narrower: paint and
above-menu paint only. `input.has_focus` and `input.key_name` are separate
queries available in every context. See [callbacks](../events.md)
for phase details and [cmd](cmd.md) for command buttons.

Input reads do not consume an event. Several calls during the same frame see the same key edges, cursor position and wheel delta.

Frame-input calls raise an error for invalid key codes or an unavailable input
source. Focus and key-label queries have their own return rules below.

## input.has_focus

```text
input.has_focus() -> boolean
```

Returns whether the game window currently has focus. Before the window is
attached, it returns `false`. This does not report text-entry focus or consume
a key. Available while loading and in every callback.

## input.key_name

```text
input.key_name(key_code: integer) -> string | nil
```

Returns the same compact label used by the native keybind editor: `M1` through
`M5` for mouse buttons, `none` for zero, and a keyboard-layout-aware abbreviation
for keyboard keys. An unresolved key has an explicit `VK`-number label.
This is a display label, not a stable identifier or a full key name.

The key must be an integer from 0 through 255. Available while loading and in
every callback. Each call costs 16 native work units. Cache labels for fixed
shortcuts instead of resolving them every frame. A label-copy failure returns
`nil` with a failure reason.

## input.down

```text
input.down(key_code: integer) -> boolean
```

Returns whether the key is held in the current frame. Use a [key constant](#key-constants) or a virtual-key code from `0` through `255`.

```lua
on.paint(function()
    if input.down(key.shift) and not input.typing() then
        render.text(24, 24, 'shift held', color.white)
    end
end)
```

## input.pressed

```text
input.pressed(key_code: integer) -> boolean
```

Returns whether the key went down during this frame. A held key does not keep reporting new presses from keyboard repeat.

`key_code` must be in `0..255`. A press and release between frames can make both `pressed` and `released` true while `down` is false.

## input.released

```text
input.released(key_code: integer) -> boolean
```

Returns whether the key went up during this frame. `key_code` must be in `0..255`.

Losing window focus also releases held keys.

Keep toggle handling in one callback so you do not process the same edge twice:

```lua
local show_hint = true

on.paint(function()
    if not input.typing() and input.pressed(key.f6) then
        show_hint = not show_hint
    end
    if show_hint then
        render.text(24, 54, 'f6 toggles this hint', color.white)
    end
end)
```

## input.repeated

```text
input.repeated(key_code: integer) -> boolean
```

Returns whether the frame received an initial keyboard press or an operating
system repeat for the key. Use it for repeatable actions such as moving a
selection with the arrow keys. Use `input.pressed` for toggles.

The key must be in `0..255`. Several repeat events in one frame return one
`true`, not a count. A held key with no new repeat returns `false`. Mouse
buttons do not generate keyboard repeats. Losing focus clears pending repeats
when the next frame captures input.

## input.cursor

```text
input.cursor() -> vec2
```

Returns a copied [vec2](../types/vec2.md) containing the cursor position relative to the game's client area, in the same **authored pixels** as [render](render.md): `x` increases to the right and `y` increases downward.

```lua
on.paint(function()
    local cursor = input.cursor()
    render.circle(cursor.x, cursor.y, 4, color.white)
end)
```

## input.delta

```text
input.delta() -> vec2
```

Returns a copied [vec2](../types/vec2.md) with the tracked cursor displacement
since the previous frame, in **authored pixels**. The first frame returns zero.
Repeated reads during one frame return the same value.

This is cursor movement, not raw relative mouse input. Cursor repositioning can
contribute to it, and focus changes do not reset its baseline. Check
`input.has_focus()` when an interaction should run only in the focused window.

## input.wheel

```text
input.wheel() -> number
```

Returns the accumulated vertical wheel movement for this frame in wheel steps. Positive values scroll up. Negative values scroll down. One ordinary wheel notch is `1`, and finer input can produce fractions. No wheel movement returns `0`.

## input.typing

```text
input.typing() -> boolean
```

Returns whether keyboard input belongs to something other than this script: the
game's text input, its console, a Dylanhook menu text field with keyboard focus,
or another script's [keyboard capture](#inputcapture). A capture this script holds
does not count. Check it before handling a script shortcut that should stay quiet
while typing.

This value does not report whether the menu is open or whether the game window
has focus. `down`, `pressed`, `released`, `repeated`, `delta` and `wheel` remain
readable while it is true.

## input.text

```text
input.text() -> string
```

Returns the characters typed since the previous frame, as UTF-8. These are the
operating system's own typed characters, so the keyboard layout, Shift,
dead keys and IME composition are already applied. Use it for a text field in
your interface instead of mapping key codes yourself. Control characters such
as Backspace and Enter are not included. Read those with
[`input.repeated`](#inputrepeated).

Returns an empty string while [`input.typing()`](#inputtyping) is true, because
the text then belongs to the game, the menu or another script's keyboard
capture. [Capture the keyboard](#inputcapture) while your field has focus so
the typed keys stay out of the game. Available in the same callbacks as
`input.typing`.

## input.region

```text
input.region(id: string, x: number, y: number, width: number, height: number) -> input_region
```

Routes mouse presses to a region without moving it. Pass bounds in
**authored pixels**, using the same identity and coordinate rules as `input.drag`.
Available in paint, above-menu paint and menu button callbacks.

```text
input_region: table
input_region.hovered: boolean
input_region.cursor: vec2
input_region.buttons: table<integer, input_region_button>

input_region_button: table
input_region_button.pressed: boolean
input_region_button.held: boolean
input_region_button.released: boolean
input_region_button.cancelled: boolean
input_region_button.origin: vec2 | nil
```

`hovered` reports whether the cursor is geometrically inside the bounds.
`cursor` is relative to the current top-left corner, in authored pixels. It may
be outside the rectangle.

Index `buttons` with `key.mouse1` through `key.mouse5`. Each button has one
owner for its physical press. `pressed` begins ownership, `held` keeps it while
down, and `released` reports the owned release. A complete tap can set
`pressed` and `released` together. `origin` is the original press offset from
the region's top-left corner, in authored pixels, and is present for those states.

Native menu and popup geometry has priority over script regions. Among script
regions, including drag regions, the first eligible call wins each button. Repeat
reads with the same script and ID see the same state that frame. Hover alone
never consumes a press. A captured press stays consumed outside the rectangle
and after the region disappears, until physical release.

Poll visible interactive regions each frame while the menu is open or your
script holds a [mouse capture](#inputcapture). Missing a
frame, unloading, reloading or a callback error cancels capture. When this call
observes focus loss or a replacement press, it sets `cancelled` for its previous capture.
Cancellation is not a click release. A new press is tested independently and
can also set `pressed` in that call. There is no delayed release after a missed
frame or unload. Typing prevents new captures.

Like `input.drag`, this helper only intercepts the game's mouse stream while
the menu is open or a script holds a mouse capture. Native mouse binds evaluate
after UI routing, so a claimed press cannot also activate a mouse bind.

```lua
local clicks = 0
on.paint(function()
    if not menu.is_open() or not input.has_focus() then return end
    local text = 'clicks | ' .. clicks
    local width, height = render.measure_text(text)
    width, height = width + 20, height + 16
    local area = input.region('button', 24, 80, width, height)
    if area.buttons[key.mouse1].released and area.hovered then
        clicks = clicks + 1
    end
    render.rect(24, 80, width, height, color(25, 25, 30, 230))
    render.text(34, 88, text, color.white)
end)
```

## input.drag

```text
input.drag(id: string, x: number, y: number, width: number, height: number)
    -> x: number, y: number, active: boolean, started: boolean, released: boolean
```

Moves a rectangle while the left mouse button is held. Pass its current position and size in **authored pixels**, the coordinates you draw it with, then keep the returned position for the next frame.

While the menu is open or a script holds a [mouse capture](#inputcapture), mouse
presses that start inside the rectangle belong to the region. Left-click moves it. Right-click is consumed but does not start a
drag. A press that belongs to the region stays blocked from gameplay until the
button is released, even if the cursor leaves the rectangle or the drag is
canceled. Hovering alone does not block input.

Call the helper each paint while the region is shown. Drawing a rectangle or
text does not register an input area by itself. The provided width and height
determine which part of what you draw consumes clicks; pass its full size to
include its body, not just its heading. With the menu closed and no mouse
capture held, the helper can still calculate a drag but does not intercept the
game's normal mouse stream.

| Argument | Meaning |
| --- | --- |
| `id` | A stable name for this region within the script. Use 1-64 bytes with no ASCII control bytes (`0..31` or `127`). |
| `x`, `y` | The current top-left position in authored pixels. |
| `width`, `height` | The hit area in authored pixels. Both must be non-negative. A zero-sized area cannot start a drag. |

All four numbers must be finite and fit a 32-bit float. Invalid arguments raise an error.

| Return | Meaning |
| --- | --- |
| `x`, `y` | The updated position while captured, including the last position on release. Otherwise, the input position. |
| `active` | The captured left mouse button is still held. |
| `started` | This call began the drag. |
| `released` | This call observed the captured drag ending. |

A release followed by another press before the next call ends the old capture
and tests the new press independently. Its initial offset is derived again;
the old release cannot cancel a newly started drag.

A press starts a drag when its recorded button-down position falls inside the
rectangle, including the left and top edges and excluding the right and bottom
edges. Later mouse movement does not change where the press began. Its initial
cursor offset is preserved, so the region does not jump to center itself under
the cursor.

A complete tap between frames returns `started = true`, `released = true` and
`active = false` in the same call. It does not leave a held capture or produce a
delayed release in another frame.

Only one script region can own the left press at a time across all loaded
scripts. Dragging and `input.region` share this owner. Native menu and popup
geometry has priority, then the first eligible script call wins. The `id` itself
is local to the script, so different scripts may reuse the same name.

`input.typing()` prevents a new drag from starting. Call `input.drag` once each
frame for a movable region. Missing a frame, unloading or reloading cancels the
drag.

If editing is gated on `menu.is_open()`, closing the menu cancels the drag on
the next frame. A canceled drag does not report a delayed `released` later. The
consumed button must still be released before a new gameplay press can begin.

The helper returns the position and drag state. Draw the region yourself, and clamp or save the position when your script needs those behaviors.

```lua
local x, y = 24, 100
local width, height = 180, 40
local background = color(20, 20, 24, 220)

on.paint(function()
    local active = false
    if menu.is_open() and input.has_focus() and not input.typing() then
        local dragging
        x, y, dragging = input.drag('status_panel', x, y, width, height)
        active = dragging
    end

    render.rect(x, y, width, height, background)
    render.text(x + 10, y + 7, active and 'moving' or 'status panel', color.white)
end)
```

The position resets when the script reloads. See the [spectator list](../examples/spectator_list.md) for a complete movable overlay.

## input.capture

```text
input.capture(device: string) -> nil
```

Takes the mouse or the keyboard from the game for this frame, the same way the
Dylanhook menu does while it is open. `device` is `"mouse"` or `"keyboard"`; any
other value raises an error. Call it from `on.paint` or `on.paint_above_menu`;
other callbacks raise an error.

A capture lasts for the frame it is claimed in. Call it on every frame your
interface wants the device, and stop calling to give it back: the game has it
again on the next frame. A closed window, a disabled callback, a reload and an
unload all release it the same way, so a script cannot leave the camera locked.
Several calls in one frame, from one script or from several, are one capture.

| Device | While captured |
| --- | --- |
| `mouse` | The camera stops following the mouse, the game receives no mouse movement, and the Dylanhook cursor is drawn over the game in place of the Windows cursor. `input.region` and `input.drag` claim presses as they do while the menu is open. A press no region claims still reaches the game as a click, exactly as it does with the menu open. |
| `keyboard` | New key presses are withheld from the game and from Dylanhook keybinds. This script still reads every key through `input.down`, `input.pressed` and the other key functions, and its own `input.typing()` stays `false`; every other script reads `true`. The menu key still opens the menu. |

The two devices are independent: a mouse capture leaves movement keys with the
game, and a keyboard capture leaves the camera alone. Capture the keyboard only
while a text field in your interface has focus, since it also silences keybinds.

Presses are routed to regions from the frame after a mouse capture begins, once
the game has stopped reading the mouse. The native menu and a script capture can
be active together; neither releases the other's hold.

```lua
local open = false
local x, y = 400, 300
local width, height = 220, 64
local background = color(20, 20, 24, 235)

on.paint(function()
    if input.has_focus() and not input.typing() and input.pressed(key.f7) then
        open = not open
    end
    if not open then return end
    input.capture('mouse')

    local dragging
    x, y, dragging = input.drag('window', x, y, width, height)
    render.rect(x, y, width, height, background)
    render.text(x + 12, y + 12, dragging and 'moving' or 'drag me', color.white)
end)
```

## Key constants

These are virtual-key numbers for `input.down`, `input.pressed`, `input.repeated` and `input.released`.

| Constant | Value |
| --- | --- |
| `key.mouse1` | `1`, left mouse button. |
| `key.mouse2` | `2`, right mouse button. |
| `key.mouse3` | `4`, middle mouse button. |
| `key.mouse4` | `5`, first extra mouse button. |
| `key.mouse5` | `6`, second extra mouse button. |
| `key.backspace` | `8` |
| `key.tab` | `9` |
| `key.enter` | `13` |
| `key.shift` | `16` |
| `key.control` | `17` |
| `key.alt` | `18` |
| `key.escape` | `27` |
| `key.space` | `32` |
| `key.page_up` | `33` |
| `key.page_down` | `34` |
| `key["end"]` | `35` |
| `key.home` | `36` |
| `key.left` | `37` |
| `key.up` | `38` |
| `key.right` | `39` |
| `key.down` | `40` |
| `key.insert` | `45` |
| `key.delete` | `46` |
| `key.f1`, `key.f2`, `key.f3`, `key.f4` | `112`, `113`, `114`, `115` |
| `key.f5`, `key.f6`, `key.f7`, `key.f8` | `116`, `117`, `118`, `119` |
| `key.f9`, `key.f10`, `key.f11`, `key.f12` | `120`, `121`, `122`, `123` |

For letters and digits, use the uppercase character code, such as `string.byte('W')` or `string.byte('1')`.

Use brackets for `key["end"]` because `end` is a Lua keyword.
