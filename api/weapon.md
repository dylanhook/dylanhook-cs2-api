# Weapon

## weapon.active

```text
weapon.active() -> table | nil
```

Returns the local player's active weapon classification.

| Field | Type | Example |
| --- | --- | --- |
| `class` | string | `rifle_regular` |
| `category` | string | `rifles` |
| `label` | string | `regular` |
| `scoped` | boolean | `false` |

The function is available in callbacks, not while the script source is loading.
`on.setup_command`, `on.command_finished`, `on.command_committed`, `on.anti_aim`, `on.frame_stage`, `on.game_event` and console command callbacks read the current weapon. Other callbacks use the latest published classification.

`nil` means the classification could not be read. Check [why.last](why.md) for the reason. An identified empty hand uses `general`. Unreadable metadata does not.

| Class | Category |
| --- | --- |
| `general` | `general` |
| `pistol_light` | `pistols` |
| `pistol_heavy` | `pistols` |
| `pistol_revolver` | `pistols` |
| `rifle_regular` | `rifles` |
| `rifle_scoped` | `rifles` |
| `sniper_auto` | `snipers` |
| `sniper_awp` | `snipers` |
| `sniper_scout` | `snipers` |
| `shotgun` | `shotguns` |
| `smg` | `smg` |
| `lmg` | `lmg` |

Knives, grenades and anything without a dedicated settings group use
`general`.

```lua
on.paint(function()
    local active = weapon.active()
    if not active then return end

    render.text(24, 24, active.class, color.white)
end)
```

## weapon.classes

```text
weapon.classes() -> table[]
```

Returns every weapon class in menu order, each a table shaped like
`weapon.active()`'s: `class`, `category`, `label` and `scoped`. `label` is the
subtype's name in the menu and is empty for `general`, which has none. `scoped`
is `true` when every weapon in the class has a scope; those are the classes
whose rage settings show the scope options, such as automatic scope. Read it instead of keeping
your own copy of the table above, so a script picks up a class the day it's
added. Works anywhere, including while the script loads.

```lua
-- one settings page per weapon class, built from the live list.
for _, entry in ipairs(weapon.classes()) do
    local page = menu.rage.aimbot.weapons[entry.class]
    print(entry.category .. ' > ' .. entry.label, page ~= nil)
end
```

The class IDs match the weapon-specific [menu destinations](menu.md#destinations)
and the `class` field returned by [`player.weapon_info`](entity.md#playerweapon_info).
