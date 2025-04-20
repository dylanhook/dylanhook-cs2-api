# Native ESP extensions

Adds scoped/flashed flags, optional health text and an armor bar directly to the native enemy ESP layout. It also demonstrates a temporary claim on the native health setting.

Menu: `visuals > player esp > enemy`. [Download `native_esp.lua`](native_esp.lua).

```lua
local group = menu.visuals.player_esp.enemy
local enabled = group:checkbox('esp additions', true, 'esp.additions')
local tint = enabled:with_color(color(136, 196, 255), 'esp.tint')
local scoped_flag = group:checkbox('scoped flag', true, 'esp.scoped')
local flashed_flag = group:checkbox('flashed flag', true, 'esp.flashed')
local health_text = group:checkbox('health text', false, 'esp.health_text')
local armor_bar = group:checkbox('armor bar', true, 'esp.armor_bar')
local replace_health = group:checkbox('replace native health', false, 'esp.replace_health')

local native_health = assert(
    menu.find('visuals.esp.enemy.health'),
    'native health setting unavailable')

local health_claimed = false

-- setting writes belong in callbacks, not file scope.
on.paint(function()
    local wanted = enabled.value and health_text.value and replace_health.value
    if wanted == health_claimed then return end
    if wanted then
        native_health:override(false)
    else
        native_health:clear_override()
    end
    health_claimed = wanted
end)

esp.add_flag('script_scoped', {
    side = 'right',
    value = function(pawn)
        if enabled.value and scoped_flag.value and player.is_scoped(pawn) == true then
            return 'SCOPED', tint.value
        end
    end,
})

esp.add_flag('script_flashed', {
    side = 'right',
    value = function(pawn)
        if not enabled.value or not flashed_flag.value then return nil end
        local duration = player.flash_duration(pawn)
        if duration and duration > 0 then
            return string.format('FLASH %.1f', duration), color(255, 214, 104)
        end
    end,
})

esp.add_text('script_health', {
    side = 'bottom',
    value = function(pawn)
        if not enabled.value or not health_text.value then return nil end
        local health = player.health(pawn)
        if health == nil then return nil end
        local ratio = math.clamp(health / 100, 0, 1)
        local low = color(240, 88, 96)
        local high = color(112, 214, 154)
        return health .. ' HP', low:lerp(high, ratio)
    end,
})

esp.add_bar('script_armor', {
    side = 'left',
    value = function(pawn)
        if not enabled.value or not armor_bar.value then return nil end
        local armor = player.armor(pawn)
        if armor == nil then return nil end
        return math.clamp(armor / 100, 0, 1), tint.value
    end,
})

-- reload or unload clears script overrides and ESP registrations.
```

## Notes

- Value callbacks return data only. Native ESP owns spacing and drawing.
- The health override is applied from `on.paint` and only written when its desired state changes.
- Use this pattern when extending native ESP instead of drawing a second ESP stack.
