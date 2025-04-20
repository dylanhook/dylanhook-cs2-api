# Native settings

Find an existing native setting, read it, change its base value or apply a
temporary override. [Menu destinations](menu.md) are separate and are only used
to add script controls.

## menu.find

```text
menu.find(path: string) -> native_setting | nil
```

Uses an exact, case-sensitive setting path such as
`"visuals.esp.enemy.health"`. Use `menu.settings` to discover available
paths. A path contains 1-512 bytes without NUL.

Returns `nil` and sets `why.last()` when that key is not exposed. The exposed
types are native booleans, floating-point numbers, integers, 64-bit selections,
strings and colors. Per-player adjustment objects, private beta fields,
script-created controls and the unsafe-script setting are not exposed here.
In particular, this API cannot grant unsafe-script permission.

Lookup is available during setup and callbacks and costs 32 native work units.
Store the returned reference instead of searching every frame. A reference
expires if the native setting table is rebuilt. Use `menu.find` again after that.

## menu.settings

```text
menu.settings(prefix: string = "", cursor: integer = 0) -> string[], integer | nil
```

Returns up to 64 exact paths beginning with `prefix` and a continuation cursor.
Pass the cursor to the next call. `nil` means the scan is finished. The result
array is 1-based and the cursor is not an array index. Each page costs 32 units.

```lua
local paths, next_page = menu.settings("visuals.esp.enemy.")
local health = menu.find("visuals.esp.enemy.health")
assert(health, "native health setting is unavailable")
local metadata = health:info()
```

## ref.value

```text
ref.value: boolean | number | string | color | boolean[]
ref.value = value
```

Reading returns the effective value observed by the native feature, including active
keybinds and script overrides. Scalars are available during setup and callbacks.
Strings and colors require setup or a render-side callback. The returned string
or color is a copy.

Costs one unit, plus one per 256 string bytes, rounded up. Use `ref:governing()`
to check whether a scoped setting is the active copy. This does not assert that
its feature is executing.

## ref:get_base

```text
ref:get_base() -> boolean | number | string | color | boolean[]
```

Reads the underlying user/profile value, ignoring temporary overrides. Context
and cost are the same as reading `ref.value`.

## ref:get_keybind_value

```text
ref:get_keybind_value() -> boolean | number | string | color | boolean[]
```

Reads the value the native keybinds give the setting, ignoring every script
override. While one of its keybinds is active this is that keybind's value.
A checkbox keybind gates the saved value rather than replacing it: while an
enable keybind is active the saved checkbox shows through, while it is not the
setting reads off, and an active disable keybind reads off. With no keybind at
all it is the same as `get_base()`. Strings and colors have no keybinds
and always read their base.

Use it when your script overrides a setting and still needs the user's own
keybind state: `ref.value` returns your override, and `get_base()` ignores
keybinds. Context and cost are the same as reading `ref.value`.

Assigning `ref.value` changes the base value, as on script controls. Assigning any
other field raises an error. The normal profile save can persist it. Unloading the
script does not undo it. An active override can keep the effective value different.
Costs one unit and validates the native type, numeric bounds, option domain and
configuration field validator before writing. Values are refused, not clamped.
Strings use the native field's domain and preserve their exact bytes. Copying
strings adds one unit per 256 bytes, rounded up.

## ref:override

```text
ref:override(value: boolean | number | string | color | boolean[]) -> nil
```

Creates or updates this script's temporary override. Script overrides take
precedence over native keybinds. When several scripts override the same setting,
the most recently loaded script wins. Updating an older script's override does
not change that order.

Each script can hold 128 overrides. One setting can be overridden by up to 64
scripts. Each script's native override owner can retain 1 MiB of string payload
across all claims, including claims hidden by newer scripts. Exceeding that pool
raises `setting_owner_text_limit` and preserves the existing claims. Replacing
or clearing a claim releases its storage. The pool applies in unsafe mode too.

A claim changes only the referenced setting. Overriding a numeric value does not
implicitly enable a separate checkbox linked to its native keybind.

## ref:clear_override

```text
ref:clear_override() -> nil
```

Removes this script's temporary override. Repeating the operation is safe. The
next script override, native keybind or base value becomes effective.

Unloading the script clears all of its overrides. It does not restore an old base
value over a later user edit. Costs one unit.

## ref:hide_drawing

```text
ref:hide_drawing() -> nil
```

Stops the native drawing this setting controls without changing its value. The
menu keeps showing the user's choice, `ref.value` keeps reading it, and nothing
else that depends on the setting changes. Only the native feature stops drawing.
Use it to replace a native element with your own: hide the native ESP box, then
draw yours while `ref.value` is true.

A hidden element gives up its space too, the same way switching it off would,
so an [ESP item](esp.md#espadd_item) can take its place. The drawing stays
hidden while any loaded script hides it. Unloading the script shows it again.

`info().hide_drawing` says whether a setting supports this. Currently those are
the ESP elements in each of `visuals.esp.enemy`, `.team` and `.local` (box,
name, health, weapon icon, ammo bar, distance, flags, skeleton and bones), plus
`visuals.watermark.elements`, `visuals.keybind_indicator.enabled` and
`visuals.spectator_list.enabled`. Other settings raise
`setting_drawing_unsupported`. Repeating the call is safe. A script can hide
128 drawings at once. Availability and cost are the same as `ref:override()`.

## ref:show_drawing

```text
ref:show_drawing() -> nil
```

Removes this script's `hide_drawing` request. The native drawing returns unless
another script still hides it. Repeating the call is safe. Availability and
cost are the same as `ref:override()`.

`set`, `override` and `clear_override` require a render-side callback:
paint, above-menu paint, menu actions, control changes, timers, HTTP completions,
session or shot callbacks, ESP value callbacks, or normal unload.

They are not available while the script is loading or from command, frame-stage
or game-event callbacks.

Look up references during setup, then apply initial overrides from `on.paint`
or another supported callback. Update an override only when its desired value
changes. See [Native ESP extensions](../examples/native_esp.md).

## ref:governing

```text
ref:governing() -> boolean
```

Returns whether this is the currently active copy of a scoped setting, such as
one setting in a weapon-specific configuration. An unscoped setting returns
`true`. This does not enable the feature or select a different configuration.

Available during setup and render-side callbacks. Costs one native work unit.
An expired reference or unsupported callback context raises.

## ref:on_change

```text
ref:on_change(callback: function()) -> subscription
```

Registers an initial notification, then notifications when the effective value
changes. Delivery runs on the render side before paint. Changes between deliveries
are combined. Changing a value and restoring it before delivery produces no extra
notification.

The callback receives no arguments. Capture the reference and read it inside the
callback. It can update controls and render-side settings, but cannot draw or
read input. Register during setup or a render-side callback. Costs 16 units.

The returned subscription supports `.active` and `:remove()`. Removal stops future
delivery immediately. Unload removes every handler. Rebuilding the setting table
expires the reference and disables its handler.

Native-reference handlers share the existing 256 callback slots. Previous values
for all control and native-setting change handlers share a separate 1 MiB native
text pool per script. A registration that cannot fit raises
`setting_observation_text_limit`. If a later value exceeds the available pool,
the handler is disabled and the callback diagnostic reports that reason. Unsafe
mode retains this resource bound.

```lua
local enabled = assert(menu.find('visuals.esp.enemy.health'))
local observed = enabled:on_change(function()
    console.log('health label enabled: ' .. tostring(enabled.value))
end)
```

## ref:binds

```text
ref:binds() -> setting_bind[]
```

Returns copied configured keybind rows. Available during setup and callbacks.
Strings and colors have no native keybind editor and raise `setting_has_no_keybinds`.
Costs 16 native work units. See [Configured keybinds](menu.md#controlset_binds)
for the row format.

## ref:set_binds

```text
ref:set_binds(bindings: setting_bind[]) -> nil
```

Replaces the native setting's complete keybind list. The validation, six-row
limit and activation reset match [`control:set_binds`](menu.md#controlset_binds).
Changes can be saved in the normal profile. They remain after script unload.

Requires an active render-side callback, just like assigning `ref.value`. Costs 16 units.
An invalid row leaves the existing list intact.

## ref:info

```text
ref:info() -> table
```

Returns copied `path`, `label`, `type`, `options`, `command_override` and
`hide_drawing`, plus `minimum`, `maximum` and `step` when a numeric range was
configured. `command_override` is `true` when [`cmd:override_setting`](cmd.md#cmdoverride_setting)
accepts the setting. `hide_drawing` is `true` when
[`ref:hide_drawing`](#refhide_drawing) does. `options` names each option in
order, including each bit of a multiselect. For the weapon override masks
(`rage.weapon_overrides`, `legit.weapon_overrides`), option N is the Nth weapon
category after `general`. It is available during setup and
callbacks and costs 16 units. Missing bounds are omitted, not supplied as zero.

| Type | Lua value |
| --- | --- |
| `boolean` | A strict boolean. |
| `string` | A copied string validated by the native field. |
| `color` | A copied color value. |
| `number` | A finite number within the native domain. |
| `combobox` | A 1-based option index; `options` lists labels. |
| `integer` | A native whole integer when no option list is configured. |
| `multiselect` | A 1-based boolean array exactly matching `options`. |
| `bitmask` | An exact unsigned decimal string when no option list is configured. Writes also accept exact nonnegative numbers up to 2^53−1. |

Combobox values are 1-based Lua indices. Do not subtract one before writing.
Bone and hitbox IDs are unrelated native IDs. See [Bones and hitboxes](pose.md).

## Custom name settings

The native name controls are available as `misc.name_mode`, `misc.name_text`,
`misc.name_prefix` and `misc.name_prefix_text`. Custom text and prefixes each
accept up to 32 bytes without embedded NUL bytes. Oversized input raises and
leaves the previous value intact.

```lua
local mode = assert(menu.find('misc.name_mode'))
local text = assert(menu.find('misc.name_text'))

menu.lua.a:button('use script name', function()
    text:override('my name')
    mode:override(3) -- custom
end)
```

These overrides clear when the script unloads. Use `set()` when the value should
become the saved base setting instead.
