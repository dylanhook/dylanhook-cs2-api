# Watermark

A movable watermark with your display name, FPS, latency, map and local time.
It resizes to the current text.

Menu: `visuals > view`. [Download `watermark.lua`](watermark.lua).

```lua
local group = menu.visuals.view
local enabled = group:checkbox('watermark', true, 'watermark.enabled')
local accent = enabled:with_color(color(130, 178, 255), 'watermark.accent')
local show_fps = group:checkbox('show fps', true, 'watermark.fps')
local show_latency = group:checkbox('show latency', true, 'watermark.latency')
local show_map = group:checkbox('show map', true, 'watermark.map')
local show_username = group:checkbox('show username', true, 'watermark.username')
local horizontal = config.value('watermark.position.x', 'integer', 9800)
local vertical = config.value('watermark.position.y', 'integer', 220)

local font = assert(render.load_font('Verdana', 12, 'normal'), 'watermark: Verdana unavailable')
local style = {
    padding_x = 8,
    padding_y = 4,
    accent_height = 2,
    background = color(17, 17, 17, 225),
    foreground = color(238, 241, 247),
}

local smooth_frame_time
local measured_latency
local sample_accumulator = 0

local function reset()
    smooth_frame_time, measured_latency, sample_accumulator = nil, nil, 0
end

on.session_changed(reset)
enabled:on_change(reset)

local function update_metrics()
    local dt = globals.frame_time()
    if dt > 0 and dt < 0.25 then
        smooth_frame_time = smooth_frame_time and (smooth_frame_time * 0.9 + dt * 0.1) or dt
        sample_accumulator = sample_accumulator + dt
    end
    if sample_accumulator >= 0.25 then
        measured_latency = globals.in_game() and globals.latency() or nil
        sample_accumulator = 0
    end
end

local function compose()
    local parts = { 'dylanhook' }
    if show_username.value then
        local username = client.username()
        if username then parts[#parts + 1] = username:gsub('%c', ' ') end
    end
    if show_fps.value then
        parts[#parts + 1] = smooth_frame_time and string.format('%.0f fps', 1 / smooth_frame_time) or '-- fps'
    end
    local in_game = globals.in_game() == true
    if show_latency.value and in_game then
        parts[#parts + 1] = measured_latency and string.format('%d ms', measured_latency) or '-- ms'
    end
    if show_map.value and in_game then
        parts[#parts + 1] = (game.map_name() or 'loading'):gsub('%c', ' ')
    end
    parts[#parts + 1] = system.date('%H:%M:%S') or '--:--:--'
    return table.concat(parts, ' | ')
end

local function place(width, height)
    local screen_width, screen_height = render.screen_size()
    local room_x = math.max(0, screen_width - width)
    local room_y = math.max(0, screen_height - height)
    local x = room_x * math.clamp(horizontal.value, 0, 10000) / 10000
    local y = room_y * math.clamp(vertical.value, 0, 10000) / 10000
    if menu.is_open() and input.has_focus() and not input.typing() then
        local dx, dy, active, _, released = input.drag('session_watermark', x, y, width, height)
        if active or released then
            x, y = math.clamp(dx, 0, room_x), math.clamp(dy, 0, room_y)
            horizontal.value = room_x > 0 and math.floor(x / room_x * 10000 + 0.5) or 0
            vertical.value = room_y > 0 and math.floor(y / room_y * 10000 + 0.5) or 0
        end
    end
    return x, y
end

group:button('reset watermark position', function()
    horizontal.value, vertical.value = horizontal.default, vertical.default
end)

on.paint(function()
    if not enabled.value then return end
    update_metrics()

    local text = compose()
    local text_width, text_height = render.measure_text(text, font)
    local width = math.ceil(text_width) + style.padding_x * 2
    local height = style.accent_height + math.ceil(text_height) + style.padding_y * 2
    local x, y = place(width, height)

    render.rect(x, y, width, height, style.background)
    render.rect(x, y, width, style.accent_height, accent.value)
    local text_y = y + style.accent_height + (height - style.accent_height - text_height) / 2
    render.text(x + style.padding_x, text_y, text, style.foreground, font)
end)
```

## Notes

- FPS is smoothed so the value does not flicker every frame.
- `config.value` saves the normalized position with each config, without hidden controls.
