local group = menu.visuals.world
local enabled = group:checkbox('bomb timer', true, 'bomb_timer.enabled')
local accent = enabled:with_color(color(239, 188, 93), 'bomb_timer.accent')
local show_defuse = group:checkbox('show defuse status', true, 'bomb_timer.defuse')
local horizontal = group:slider('bomb timer x', 0, 10000, 5000, 1, 'bomb_timer.x')
local vertical = group:slider('bomb timer y', 0, 10000, 700, 1, 'bomb_timer.y')
horizontal.visible, vertical.visible = false, false

local font = assert(render.load_font('Verdana', 12, 'normal'), 'bomb timer: Verdana unavailable')

local style = {
    width = 248,
    padding = 10,
    text_padding = 4,
    accent_height = 2,
    bar_height = 3,
    background = color(17, 17, 17, 225),
    foreground = color(241, 243, 248),
    muted = color(145, 152, 166),
    good = color(112, 214, 154),
    bad = color(241, 104, 112),
}

local round_over = false
local panel_alpha = 0

local function reset_round()
    round_over = false
end

local function finish_round()
    round_over = true
end

on.session_changed(reset_round)
on.game_event('round_start', reset_round)
on.game_event('bomb_planted', reset_round)
on.game_event('bomb_defused', finish_round)
on.game_event('bomb_exploded', finish_round)
on.game_event('round_end', finish_round)

local function faded(tint, opacity)
    return tint:alpha(math.floor(tint.a * opacity + 0.5))
end

local function place(height)
    local screen_width, screen_height = render.screen_size()
    local room_x = math.max(0, screen_width - style.width)
    local room_y = math.max(0, screen_height - height)
    local x = room_x * horizontal.value / 10000
    local y = room_y * vertical.value / 10000
    if menu.is_open() and input.has_focus() and not input.typing() then
        local dx, dy, active, _, released = input.drag('bomb_timer', x, y, style.width, height)
        if active or released then
            x = math.clamp(dx, 0, room_x)
            y = math.clamp(dy, 0, room_y)
            horizontal.value = room_x > 0 and math.floor(x / room_x * 10000 + 0.5) or 0
            vertical.value = room_y > 0 and math.floor(y / room_y * 10000 + 0.5) or 0
        end
    end
    return x, y
end

group:button('reset bomb timer position', function()
    horizontal.value, vertical.value = 5000, 700
end)

on.paint(function()
    if not enabled.value then panel_alpha = 0 return end

    local snapshot = not round_over and game.bomb_snapshot() or nil
    if snapshot and snapshot.seconds_remaining <= 0 then snapshot = nil end
    local preview = menu.is_open()
    local target_alpha = (snapshot or preview) and 1 or 0
    local step = math.min(1, math.max(0, globals.frame_time()) * 10)
    panel_alpha = panel_alpha + (target_alpha - panel_alpha) * step
    if panel_alpha < 0.01 then return end

    local site = snapshot and ('site ' .. snapshot.site) or 'bomb timer'
    local seconds = snapshot and string.format('%.1f', snapshot.seconds_remaining) or '--.-'
    local detail = 'waiting for a planted bomb'
    local detail_tint = style.muted

    if snapshot then
        detail = 'detonation'
        if show_defuse.value and snapshot.being_defused and snapshot.defuse_seconds_remaining ~= nil then
            local verdict = 'unknown'
            if snapshot.defuse_will_succeed ~= nil then
                verdict = snapshot.defuse_will_succeed and 'on time' or 'too late'
                detail_tint = snapshot.defuse_will_succeed and style.good or style.bad
            end
            detail = string.format('defuse %.1fs | %s',
                snapshot.defuse_seconds_remaining, verdict)
        end
    end

    local timer_width, text_height = render.measure_text(seconds, font)
    local row_height = math.ceil(text_height) + style.text_padding * 2
    local header = style.accent_height + row_height
    local height = header + row_height + style.bar_height + style.padding
    local x, y = place(height)
    render.rect(x, y, style.width, height, faded(style.background, panel_alpha))
    render.rect(x, y, style.width, style.accent_height, faded(accent.value, panel_alpha))

    local text_y = y + style.accent_height + (row_height - text_height) / 2
    render.text(x + style.padding, text_y, site, faded(style.foreground, panel_alpha), font)
    render.text(x + style.width - style.padding - timer_width, text_y, seconds,
        faded(style.foreground, panel_alpha), font)
    render.text(x + style.padding, y + header + (row_height - text_height) / 2,
        detail, faded(detail_tint, panel_alpha), font)

    local fraction = 0
    if snapshot and snapshot.timer_length > 0 then
        fraction = math.clamp(snapshot.seconds_remaining / snapshot.timer_length, 0, 1)
    end
    local bar_x, bar_y = x + style.padding, y + header + row_height
    local bar_width = style.width - style.padding * 2
    render.rect(bar_x, bar_y, bar_width, style.bar_height, faded(style.muted, panel_alpha * 0.28))
    if fraction > 0 then
        render.rect(bar_x, bar_y, bar_width * fraction, style.bar_height, faded(accent.value, panel_alpha))
    end
end)
