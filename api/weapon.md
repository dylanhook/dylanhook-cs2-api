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

The function is available in callbacks, not while the script source is loading.
`on.setup_command`, `on.command_finished`, `on.frame_stage` and `on.game_event` read the current weapon. Other callbacks use the latest published classification.

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

The class IDs match the weapon-specific [menu destinations](menu.md#destinations)
and the `class` field returned by [`player.weapon_info`](entity.md#playerweapon_info).
