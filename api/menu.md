# Menu

Add controls to the Lua tab or beside a built-in feature. Create them while the
script loads, before callbacks begin.

Constructors return a control object. Invalid arguments, duplicate IDs, exceeded
limits and creation after loading raise an error. Controls are removed when the
script unloads or reloads.

Omitting an optional argument or passing `nil` uses its default.

To read or override an existing native setting, use [native setting references](native_settings.md).
Menu destinations below create script controls. They are not native setting keys.

```lua
local enabled = menu.lua.a:checkbox('show label', true, 'enabled')
local tint = enabled:with_color(color(255, 90, 170), 'tint')

on.paint(function()
    if enabled.value then
        render.text(24, 24, 'dylanhook', tint.value)
    end
end)
```

The Lua tab appears when a loaded script adds a control to `menu.lua.a` or `menu.lua.b`. These are its left and right groups.

Hiding every row with `.visible` does not remove the Lua tab. Controls cannot be removed individually. Reload the script to change its declarations.

## menu.active_binds

```text
menu.active_binds() -> table
```

Returns a new `1`-indexed array of the rows selected for the native keybind
indicator in this render frame. Call it from `on.paint` or
`on.paint_above_menu`. Other contexts raise an error. It works even when the
native indicator is hidden and requires no unsafe-script permission.

The array follows **show in binds**, master switches, linked controls and the
native per-weapon row selection. An empty array means no rows are active.
Reading it does not poll keys or change settings.

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | string | Stable setting ID used by the native indicator. Not a writable control reference. |
| `name` | string | Display name used by the native indicator. |
| `key` | integer | The binding's virtual-key code. |
| `mode` | string | `"hold"`, `"toggle"` or `"disable"`. |
| `value` | string | Formatted display value. Can be empty for a boolean setting. |
| `active` | boolean | Always `true`: this binding is active. |
| `governing` | boolean | Whether this setting's variant applies to the current weapon scope. Unscoped settings return `true`. |

`active` does not mean the feature is enabled: a held `"disable"` binding
turns its feature off. A toggled binding can remain active after releasing
the key. When no participating per-weapon variant governs, the native panel
keeps its first active row. That row has `governing == false`.

All consumers share one collection per render frame. Repeated calls return
independent Lua copies of those rows. Menu edits made after collection appear
in the next frame. Saved tables keep their old values.

Each call costs 8 native work units plus 1 per started group of 8 returned
rows. The complete result is refused when the shared budget is exhausted;
the function does not return a truncated array.

```lua
on.paint(function()
    for index, bind in ipairs(menu.active_binds()) do
        local value = bind.value ~= "" and (" | " .. bind.value) or ""
        render.text(24, 100 + (index - 1) * 18,
            bind.name .. " [" .. bind.mode .. "]" .. value, color.white)
    end
end)
```

## Menu state

Use these queries to line up custom panels with the native menu. They are
available during setup and render-side callbacks, including paint, above-menu
paint, menu actions, control changes, timers, HTTP completions, ESP values,
session changes, shot notifications and normal unload.

`on.paint_above_menu` sees the menu state from the current frame. Earlier
callbacks may see the previous rendered state. Returned vectors and colors are
copies.

### menu.is_open

```text
menu.is_open() -> boolean | nil
```

Returns the logical open state, not the closing fade or mouse capture state.
Returns `nil` until the menu state is available.

### menu.get_pos

```text
menu.get_pos() -> vec2 | nil
```

Returns the top-left of the last arranged menu window in authored pixels.
Returns `nil` with a failure reason before the menu has first drawn.

### menu.get_size

```text
menu.get_size() -> vec2 | nil
```

Returns the last arranged window width and height in authored pixels. It has the
same availability as `menu.get_pos`. Closing the menu retains its last bounds.

### menu.accent_color

```text
menu.accent_color() -> color | nil
```

Returns the native theme's accent color. Returns `nil` until the menu state is
available. Reading menu state does not change settings or claim input. Use
[`input.drag`](input.md#inputdrag) to move a custom panel.

### menu.alpha

```text
menu.alpha() -> number | nil
```

Returns the native menu's current fade from `0` to `1`, or `nil` before menu
state is available. Use it to fade a custom panel with the menu. It has the same
callback availability as `menu.is_open`.

### menu.theme

```text
menu.theme() -> menu_theme | nil
```

Returns a copy of the native menu colors, or `nil` before menu state is available.
It has the same callback availability as `menu.is_open`. Changing the returned
table or its colors does not change the menu. Colors do not include the menu fade.

```text
menu_theme: table
menu_theme.accent: color
menu_theme.form_outer: color
menu_theme.form_rim: color
menu_theme.form_dark: color
menu_theme.form_bg: color
menu_theme.rail_bg: color
menu_theme.group_bg: color
menu_theme.group_header_bg: color
menu_theme.group_border_outer: color
menu_theme.group_border_inner: color
menu_theme.card_header_rim: color
menu_theme.card_shadow_near: color
menu_theme.card_shadow_far: color
menu_theme.chip_rim_active: color
menu_theme.chip_rim_rest: color
menu_theme.border_outer: color
menu_theme.border_inner: color
menu_theme.control_top: color
menu_theme.control_bot: color
menu_theme.control_top_hover: color
menu_theme.control_bot_hover: color
menu_theme.control_pressed: color
menu_theme.check_top: color
menu_theme.check_bot: color
menu_theme.track_top: color
menu_theme.track_bot: color
menu_theme.list_bg: color
menu_theme.list_row_hover: color
menu_theme.binding_table_separator: color
menu_theme.popup_bg: color
menu_theme.popup_border_outer: color
menu_theme.popup_border_inner: color
menu_theme.popup_row_hover: color
menu_theme.text_primary: color
menu_theme.text_secondary: color
menu_theme.text_label: color
menu_theme.text_muted: color
menu_theme.text_placeholder: color
menu_theme.text_shadow: color
menu_theme.checker_light: color
menu_theme.checker_dark: color
menu_theme.picker_cursor: color
menu_theme.cursor_outline: color
menu_theme.chrome_outline: color
menu_theme.chrome_rim: color
menu_theme.status_error: color
menu_theme.status_warning: color
menu_theme.status_ok: color
```

```lua
on.paint_above_menu(function()
    local palette = menu.theme()
    local alpha = menu.alpha()
    if palette == nil or alpha == nil or alpha == 0 then return end
    local text = palette.text_primary
    render.text(24, 24, "my panel", text:alpha(text.a * alpha))
end)
```

## Destinations

Call a constructor on a final destination listed below. Parent tables such as `menu.legit.aimbot` and `menu.legit.aimbot.weapons` group destinations. They do not create controls.

| Container | Location |
| --- | --- |
| `menu.legit.aimbot.all` | legit > aimbot, for every weapon selection |
| `menu.legit.aimbot.weapons.<class>` | legit > aimbot, for one weapon class |
| `menu.legit.other.all` | legit > other, on main and trigger |
| `menu.legit.other.main.all` | legit > other > main, for every weapon selection |
| `menu.legit.other.main.weapons.<class>` | legit > other > main, for one weapon class |
| `menu.legit.other.trigger.all` | legit > other > trigger, for every weapon selection |
| `menu.legit.other.trigger.weapons.<class>` | legit > other > trigger, for one weapon class |
| `menu.rage.aimbot.all` | rage > aimbot, for every weapon selection |
| `menu.rage.aimbot.weapons.<class>` | rage > aimbot, for one weapon class |
| `menu.rage.anti_aim` | rage > anti aim |
| `menu.visuals.player_esp.all` | visuals > player esp, on enemy, team and local |
| `menu.visuals.player_esp.enemy` | visuals > player esp > enemy |
| `menu.visuals.player_esp.team` | visuals > player esp > team |
| `menu.visuals.player_esp["local"]` | visuals > player esp > local |
| `menu.visuals.world` | visuals > world |
| `menu.visuals.view` | visuals > view |
| `menu.misc.movement` | misc > movement |
| `menu.misc.other` | misc > other |
| `menu.misc.settings` | misc > settings |
| `menu.skins.loadout` | skins > loadout |
| `menu.skins.options.all` | skins > options, on finish, sticker and charm |
| `menu.skins.options.finish` | skins > finish options |
| `menu.skins.options.sticker` | skins > sticker options |
| `menu.skins.options.charm` | skins > charm options |
| `menu.players.adjustments` | players > adjustments |
| `menu.lua.a` | lua > `A`, in the left column |
| `menu.lua.b` | lua > `B`, in the right column |

The destination ID `menu.visuals.player_esp.local` contains a Lua keyword. Access it with `menu.visuals.player_esp["local"]` in code.

Replace `<class>` with one of these exact names:

| Class | Menu selection |
| --- | --- |
| `general` | general |
| `pistol_light` | pistols > light |
| `pistol_heavy` | pistols > heavy |
| `pistol_revolver` | pistols > revolver |
| `rifle_regular` | rifles > regular |
| `rifle_scoped` | rifles > scoped |
| `sniper_auto` | snipers > auto |
| `sniper_awp` | snipers > awp |
| `sniper_scout` | snipers > scout |
| `shotgun` | shotguns |
| `smg` | smg |
| `lmg` | lmg |

For example, `menu.rage.aimbot.weapons.sniper_awp` is a container. Weapon-specific rows follow the weapon class being edited in the menu. Their visibility does not automatically restrict when a script callback runs.

An `.all` control has one value, identity and change callback. Pages that show it share that state. It counts as one control even when several pages display it.

```lua
local local_esp = menu.visuals.player_esp["local"]
local_esp:checkbox("extra indicator", false, "local_indicator")
```

## Labels and IDs

| Item | Limit |
| --- | --- |
| Controls | 128 per script, including buttons, labels and attached colors. |
| Saved control identities | 1,024 shared across all scripts while Dylanhook is running. |
| Labels and option text | 1-128 bytes each. ASCII control bytes (`0..31` and `127`) are refused. |
| Explicit `stable_id` | Up to 244 bytes. |

Value controls accept an optional `stable_id`. Omitting it, passing `nil`, or using an empty string uses the label instead. Saved IDs cannot contain `=`, ASCII control bytes or a trailing space. When the label supplies the ID, those restrictions apply to the label too.

The control type and ID identify a setting across the entire script. Two checkboxes with the same ID conflict even in different containers. Different control types may share an ID. Buttons and labels use their text as the ID, so two buttons with identical text also conflict.

With an explicit ID, you can rename a control or move it to another destination without changing its saved identity. Keep its default and limits unchanged across reloads. Changing a default, slider range or step, option text or order, or maximum text length under the same identity fails the load. Use a new ID for a changed setting.

Reusing an identity doesn't spend another saved-control slot. Unloading keeps its saved value and identity available for the next load, so it doesn't free that slot.

## container:checkbox

```text
container:checkbox(label: string, default: boolean = false, stable_id: string? = nil) -> control
```

Creates a checkbox. Its `.value` is a boolean. Defaults and assignments use Lua truthiness: only `false` and `nil` are false.

## container:slider

```text
container:slider(label: string, min: number, max: number, default: number, step: number = 1, stable_id: string? = nil) -> control
```

Creates a numeric slider. `min` must be less than `max`, `default` must be within that range, and `step` must be positive. Numbers must fit a finite 32-bit float.

`.value` is a number. `step` sets the menu increment. Assigning from Lua does not round to that step. An assignment outside the range raises an error.

## container:combobox

```text
container:combobox(label: string, options: string[], default: integer = 1, stable_id: string? = nil) -> control
```

Creates a single-choice control. Pass a dense array of 1-128 option strings.
`.value` is the selected one-based index. Defaults and assignments must be whole
indices into the list. Fractional values raise an error rather than being rounded.

The options are copied when you create the control. Editing the original table
doesn't change them. Use [`control:set_options`](#controlset_options) to replace them.

```lua
local positions = { 'top', 'bottom' }
local position = menu.lua.a:combobox('position', positions, 1, 'position')

position:on_change(function()
    console.log('position: ' .. positions[position.value])
end)
```

## container:multiselect

```text
container:multiselect(label: string, options: string[], stable_id: string? = nil) -> control
```

Creates a multiple-choice control from a dense array of 1-64 option strings. The options are copied at creation and default to all off. `.value` returns a new boolean array in option order.

Assign a complete array to change the selection. Editing the returned table alone does not update the control.

Options and values start at index `1`. The assigned value must have exactly one boolean per option. A wrong length or non-boolean entry raises an error.

```lua
local details = menu.lua.a:multiselect('details', { 'time', 'map' }, 'details')

menu.lua.a:button('select all details', function()
    details.value = { true, true }
end)
```

## container:color

```text
container:color(label: string, default: color, stable_id: string? = nil) -> control
```

Creates a color picker. `default` is required. `.value` returns an immutable [color](../types/color.md). Assign a new color to change the setting.

## control:with_color

```text
checkbox:with_color(default: color, stable_id: string? = nil) -> control
```

Adds a color picker to a checkbox row and returns the color control. Each checkbox supports one attached color. Call this while the script loads.

`default` is required. Using another control type or attaching a second color raises an error.

The color has its own saved value, ID and change callback. Without an explicit ID, it uses the checkbox's label, even when the checkbox has a different ID. Its visibility follows the checkbox row.

## container:text

```text
container:text(label: string, default: string = '', max_length: integer = 256, stable_id: string? = nil) -> control
```

Creates a text input. `.value` is a string. `max_length` is measured in bytes and must be between 1 and 4096. The default and later assignments must fit.

Text values may be empty and may contain control characters, including NUL. Clean those characters before displaying text where a single line is expected.

## container:button

```text
container:button(label: string, callback: function()) -> control
```

Creates a button. Its callback receives no arguments. An uncaught error disables further calls from that button. The row stays visible.

The callback can read input and write control values, but cannot draw. Return values are ignored. Buttons have no stable-ID parameter. Their label identifies them within the script.

## container:label

```text
container:label(text: string) -> control
```

Adds a static text row. The text follows the label restrictions above and cannot be changed after creation.

Buttons and labels have `.label` and `.visible`. Their `.value` is `nil`. Assigning it raises an error.

## control.value

```text
control.value: boolean | number | boolean[] | color | string | nil
```

Read or assign a control's value. After loading, reads include active keybinds and this script's temporary overrides. Assigning changes the saved base value. An active override can still determine what the next read returns.

After `set_options`, assignments and `get_base()` use the new list's staged base
selection. `.value` includes its staged script override when one exists. Native
keybind activation takes effect again when the menu applies the update.

During loading, reads start from the retained base value or the declared default for a new setting. They include earlier assignments and staged script overrides, but no keybind activation. Assignments take effect when the load succeeds.

All values can be read while loading and from paint, above-menu paint, buttons, control-change callbacks, timers, HTTP completions, ESP values, session changes, shot notifications and unload. Those are also the places where values may be assigned.

Command, frame-stage and game-event callbacks may read checkboxes, sliders, comboboxes and multiselects. They cannot read color or text values, or change controls. An unsupported access raises an error.

## control.visible

```text
control.visible: boolean
```

Starts as `true`. Assign `false` to remove the row from layout and input. Hiding a control keeps its value and callbacks. Visibility resets on reload and is not saved in profiles.

The flag can be read while loading and in any callback. Assignment uses Lua truthiness. A control whose flag is true can still be hidden by its menu tab or subpage.

Visibility changes use the same allowed callbacks as value assignments. An attached color follows its checkbox's visibility. Setting the color's own `.visible` does not hide that swatch independently.

## control.label

```text
control.label: string
```

Read-only text supplied at creation. An attached color returns its checkbox's label. Unknown properties read as `nil`. Assigning an unknown or read-only property raises an error.

The label can be read while loading and in any callback.

## control:get_base

```text
control:get_base() -> boolean | number | boolean[] | color | string
```

Reads the saved value beneath keybinds and temporary overrides. During setup it
reads the candidate's base value, including earlier assignments. After
`set_options` it reads the new list's staged base selection.

Availability matches `.value`. Costs one native work unit, plus one per 256
string bytes, rounded up. Buttons and labels have no value and raise.

## control:get_keybind_value

```text
control:get_keybind_value() -> boolean | number | boolean[] | color | string
```

Reads the value the control's keybinds give it, ignoring this script's
temporary override, with the same rules as
[`ref:get_keybind_value`](native_settings.md#refget_keybind_value). With no
active keybind it matches `get_base()`, which is also what it reads during
setup. Availability and cost match `get_base()`.

## control:info

```text
control:info() -> control_info
```

Returns copied metadata for this script's control. `id` is its explicit stable
ID, or its label when no ID was supplied. `default` uses the same value shape as
`.value`. It is absent for buttons and labels. Pending options and their default
are visible immediately. Available during setup and callbacks. Costs 16 units.

```text
control_info: table
control_info.id: string
control_info.label: string
control_info.kind: string
control_info.type: string | nil
control_info.visible: boolean
control_info.default: boolean | number | boolean[] | color | string | nil
control_info.options: string[]
control_info.minimum: number | nil
control_info.maximum: number | nil
control_info.step: number | nil
control_info.maximum_length: integer | nil
```

`kind` is the constructor name: `checkbox`, `slider`, `combobox`, `multiselect`,
`color`, `text`, `button` or `label`. `type` is the value's type, in the same
vocabulary as [`ref:info()`](native_settings.md#refinfo): `boolean`, `number`,
`combobox`, `multiselect`, `color` or `string`. Buttons and labels have no `type`.
Numeric bounds are present for sliders. `maximum_length` is present for text
controls. Assign `control:info().default` to `.value` to restore the declared
default.

## control:override

```text
control:override(value: boolean | number | boolean[] | color | string) -> nil
```

Temporarily replaces the effective value without changing the saved base.
Uses the control's current type and domain. Checkbox values must be booleans.
Costs one unit, plus one per 256 string bytes, rounded up.

Available during setup and render-side callbacks. Setup claims become active
only if the load succeeds. Pending option updates retain the claim in the new
option domain. A later base assignment remains underneath it.

Claims share the script's native setting override owner and its
[resource limits](native_settings.md#refoverride). Unloading releases them.

## control:clear_override

```text
control:clear_override() -> nil
```

Removes this script's temporary claim. The current keybind or saved base becomes
effective. Repeated calls are safe. During setup it cancels the candidate's staged
claim. Available wherever `control:override()` is available. Costs one unit.

## control:binds

```text
control:binds() -> setting_bind[]
```

Returns a copied list of configured keybinds. Available during setup and
callbacks for checkboxes, sliders, comboboxes and multiselects. It includes
staged changes made by this script. Costs 16 units.

These are configured rows. Use `menu.active_binds()` for current activation.

## control:set_binds

```text
control:set_binds(bindings: setting_bind[]) -> nil
```

Replaces the complete keybind list. An empty list clears it. Available during
setup and render-side callbacks. Setup changes commit only when the load
succeeds. With pending options, rows use the new option list and commit with it.
Costs 16 units.

A target supports up to six rows. Each row is validated before any changes
apply. Invalid keys, modes, option values and values outside the native slider
step domain raise. Values are never silently clamped or rounded. Replacement
resets native hold/toggle activation and closes an outdated keybind editor.

```text
setting_bind: table
setting_bind.key: integer
setting_bind.mode: string
setting_bind.value: number | string | boolean[] | nil
```

`key` is a virtual-key code from 0 to 255. Zero is an unassigned row. `mode` is
`"hold"` or `"toggle"`, with `"disable"` also available for checkboxes. Checkbox
rows omit `value`. Other rows use the same value shape as their setting.

```lua
local amount = menu.lua.a:slider('amount', 0, 100, 25, 1, 'amount')
amount:set_binds({{key = 0x48, mode = 'hold', value = 75}})
local base = amount:get_base()
local initial = amount:info().default
```

## control:on_change

```text
control:on_change(callback: function()) -> subscription
```

Registers a change callback while the file loads. Value controls support one active change callback each. Buttons and labels do not support it.

Changes are compared against the last delivered effective value. Changing a value
and restoring it before the next delivery produces no extra notification. Script
overrides participate in the same change detection.

Previous text values share the script's 1 MiB native observation pool with
[native setting handlers](native_settings.md#refon_change). This concrete bound
also applies in unsafe mode.

Invalid callbacks, a second active handler and registration after loading raise an error. The callback can read and write control values, but cannot draw or read input. Return values are ignored.

It runs once on the first render frame, then when the effective value differs from the previous check. It takes no arguments. Read `.value` inside the callback.

Checks follow handler registration order, after session-change callbacks and
before timers and paint. Several writes between checks may produce one call, or
none when the value returns to its previous state. Assigning a value doesn't call
the handler immediately.

```lua
local enabled = menu.lua.a:checkbox('show note', true, 'show_note')
local note = menu.lua.a:text('note', '', 96, 'note')

enabled:on_change(function()
    note.visible = enabled.value
end)
```

The returned [subscription](../events.md#subscriptions) can stop the callback. An uncaught error also disables it. Changing visibility does not trigger a value-change callback.

## control:on_submit

```text
control:on_submit(callback: function(text: string)) -> subscription
```

Registers one submission callback on a text control while the script loads.
Enter or an ordinary focus change submits the current text once. The callback
receives a copied string. Assigning `.value` does not submit it.

Escape, hiding the control and removing it do not submit. Escape does not undo
values already written while typing. The callback has the same input and menu
access as a button. It cannot draw.

```lua
local note = menu.lua.a:text('note', '', 128, 'note')
note:set_placeholder('type a note and press enter')
note:on_submit(function(text)
    if fs.write('note.txt', text) == nil then
        console.warn(why.last() or 'save failed')
    end
end)
```

The returned subscription can remove the handler. An uncaught error disables it.
A second active handler, a non-function callback, registration after loading or
use on another control type raises an error. Submission is independent of
`control:on_change`.

## control:set_placeholder

```text
control:set_placeholder(text: string)
```

Sets an existing text control's hint, shown while the input is empty and unfocused.
Pass `""` to clear it. The hint does not change `.value` or its saved data.

Accepts up to 128 bytes without ASCII control bytes. Available during setup and
where control value writes are allowed. A shown control updates on its next
frame, in place. The hint resets on reload unless the script sets it again.

## control:set_format

```text
control:set_format(format: string)
```

Changes how an existing slider displays its value. It does not change the value,
range or step. Available during setup and where control value writes are allowed.
A shown control updates on its next frame, in place, without interrupting a drag.

```lua
local delay = menu.lua.a:slider('delay', 0, 1000, 250, 1, 'delay')
delay:set_format('{:.0f} ms')
```

The format must have exactly one numeric field. Use `{}` or `{0}` for the default
number format, `{:.2f}` for two decimals, or `{:6.0f}` for a six-column field.
Padding uses spaces, including when the width has a leading zero. Supported
types are `f`, `g`, `G`, or no type. Precision is `0` through `15`. Use `{{` and `}}`
for literal braces.

The format and requested padding width are limited to 128 bytes/columns. ASCII
control bytes, other argument indices, multiple fields and unsupported formats
raise an error. Formatting resets on reload unless set again.

## control:set_options

```text
control:set_options(options: string[], selection: integer | boolean[] | nil = nil, default: integer | boolean[] | nil = nil)
```

Replaces an existing combobox or multiselect's copied option list. Uses the same
option counts and label rules as its constructor. Available during setup and
where control value writes are allowed.

For a combobox, `selection` and `default` are one-based indices into the new list.
For a multiselect, each is a complete boolean array in the new option order.
Omitting either preserves that value by matching its selected labels exactly.
If a selected label is removed or duplicated, supply the corresponding value
explicitly. Unselected multiselect options can be removed without a replacement.

Existing keybind selections also follow their labels. Removing a bound label or
making it ambiguous refuses the whole update. Remove or change that binding first.
An invalid or refused update leaves the previous options, values and bindings intact.

Binding keys and modes are preserved, but their active hold/toggle state resets
when the replacement is applied. Refreshing the control also closes its open
popup and ends any active edit.

Each attempt costs 8 native work units, plus the text and label-matching charges
listed in [Limits](../limits.md). Unsafe mode measures this work without enforcing
the allowance.

```lua
local order = menu.lua.a:combobox('order', {'name', 'date'}, 1, 'order')
menu.lua.a:button('sort choices by date first', function()
    order:set_options({'date', 'name'})
    -- The selected name stays the same despite its new index.
end)
```

Lua value reads, assignments, overrides, keybind edits and subsequent `set_options` calls use the new list
immediately. The native control applies the complete update at the next menu
refresh. Several updates before that refresh keep the latest result. The input
edit is canceled when the control refreshes.

Live options and their defaults are retained across compatible script reloads.
The constructor declaration still identifies the original control. Saved values
include the option vocabulary, so loading a profile with a different list fails
instead of applying an index to a different label.

Loading a config checks any pending option list before applying its saved values.
A successful load keeps those values through the menu refresh. A failed load
leaves the current values and pending edits unchanged.

An active script override is remapped by the same exact-label rule. Removing or
ambiguously remapping its selected label raises `control_override_conflicts_with_options`
and preserves the complete prior update. Clear the override before deliberately
removing its selected option.

## Saved settings and keybinds

Value controls are included in profiles. Compatible values survive a reload. An unsuccessful replacement leaves the previous script and values running. Buttons, labels and visibility are not saved settings.

Combobox and multiselect profiles include their option labels and order. A
different list, or a saved keybind without its matching option information,
refuses the profile. Older profiles containing number-only Lua choice records
are also refused. Recreate and save those profiles with the current version.

Right-click a checkbox, slider, combobox or multiselect to add a keybind, or use **misc > settings > keybinds**. Color and text controls are not keybind targets.

See [Saved settings](../concepts.md#saved-settings) for profile behavior. The
[examples](../examples/README.md) use stable IDs and native menu destinations.
