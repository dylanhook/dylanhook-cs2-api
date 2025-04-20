# Speed graph

Graphs horizontal player speed sampled from `on.setup_command`. It shows the
current speed, average and session peak.

Menu: `misc > movement`. [Download `speed_graph.lua`](speed_graph.lua).

```lua
local group = menu.misc.movement
local enabled = group:checkbox('speed graph', true, 'speed_graph.enabled')
local accent = enabled:with_color(color(115, 215, 171), 'speed_graph.accent')
local history = group:slider('samples', 40, 128, 96, 1, 'speed_graph.samples')
local horizontal = group:slider('speed graph x', 0, 10000, 300, 1, 'speed_graph.x')
local vertical = group:slider('speed graph y', 0, 10000, 6800, 1, 'speed_graph.y')
horizontal.visible, vertical.visible = false, false

local font = assert(render.load_font('Verdana', 12, 'normal'), 'speed graph: Verdana unavailable')

local style = {
    width = 326,
    padding = 10,
    text_padding = 4,
    accent_height = 2,
    graph_height = 54,
    graph_gap = 5,
    background = color(17, 17, 17, 225),
    foreground = color(239, 242, 247),
    muted = color(145, 152, 166),
    grid = color(145, 152, 166, 30),
}

local capacity = 128
local samples = {}
local next_index, count = 1, 0
local last_command
local latest, peak = 0, 0

local function clear()
    samples, next_index, count = {}, 1, 0
    last_command, latest, peak = nil, 0, 0
end

enabled:on_change(clear)
on.session_changed(clear)
on.game_event('round_start', clear)

on.setup_command(function(cmd)
    if not enabled.value then return end
    local number = cmd.number
    if not number then clear() return end
    if number == last_command then return end
    if last_command and number ~= last_command + 1 then clear() end
    last_command = number

    local me = entity.local_player()
    local velocity = me and player.is_alive(me) == true and player.velocity(me) or nil
    if not velocity then clear() return end

    latest = velocity:length2d()
    peak = math.max(peak, latest)
    samples[next_index] = latest
    next_index = next_index % capacity + 1
    count = math.min(count + 1, capacity)
end)

local function place(height)
    local screen_width, screen_height = render.screen_size()
    local room_x = math.max(0, screen_width - style.width)
    local room_y = math.max(0, screen_height - height)
    local x, y = room_x * horizontal.value / 10000, room_y * vertical.value / 10000
    if menu.is_open() and input.has_focus() and not input.typing() then
        local dx, dy, active, _, released = input.drag('speed_graph', x, y, style.width, height)
        if active or released then
            x, y = math.clamp(dx, 0, room_x), math.clamp(dy, 0, room_y)
            horizontal.value = room_x > 0 and math.floor(x / room_x * 10000 + 0.5) or 0
            vertical.value = room_y > 0 and math.floor(y / room_y * 10000 + 0.5) or 0
        end
    end
    return x, y
end

group:button('reset speed graph position', function()
    horizontal.value, vertical.value = 300, 6800
end)

on.paint(function()
    if not enabled.value then return end
    local preview = menu.is_open()
    if count == 0 and not preview then return end

    local _, text_height = render.measure_text('velocity', font)
    local line_height = math.ceil(text_height)
    local header = style.accent_height + line_height + style.text_padding * 2
    local footer_height = line_height + style.text_padding * 2
    local height = header + style.graph_gap * 2 + style.graph_height + footer_height
    local x, y = place(height)
    local text_y = y + style.accent_height + (header - style.accent_height - text_height) / 2
    render.rect(x, y, style.width, height, style.background)
    render.rect(x, y, style.width, style.accent_height, accent.value)
    render.text(x + style.padding, text_y, 'velocity', style.foreground, font)

    local current_text = count > 0 and string.format('%.0f u/s', latest) or '-- u/s'
    local current_width = render.measure_text(current_text, font)
    render.text(x + style.width - style.padding - current_width, text_y,
        current_text, accent.value, font)

    local graph_left = x + style.padding
    local graph_top = y + header + style.graph_gap
    local graph_width = style.width - style.padding * 2
    local graph_bottom = graph_top + style.graph_height
    for line = 0, 2 do
        local gy = graph_top + style.graph_height * line / 2
        render.line(graph_left, gy, graph_left + graph_width, gy, style.grid, 1)
    end

    if count == 0 then
        local message = 'move to begin sampling'
        local message_width = render.measure_text(message, font)
        render.text(graph_left + (graph_width - message_width) / 2,
            graph_top + (style.graph_height - text_height) / 2, message, style.muted, font)
        return
    end

    local requested = math.floor(history.value)
    local visible = math.min(count, requested)
    local first = (next_index - visible - 1) % capacity + 1
    local scale = 300
    local sum = 0
    for offset = 0, visible - 1 do
        local value = samples[(first + offset - 1) % capacity + 1]
        scale = math.max(scale, value)
        sum = sum + value
    end
    scale = math.ceil(scale / 50) * 50

    local step = graph_width / math.max(1, requested - 1)
    for offset = 1, visible - 1 do
        local previous = samples[(first + offset - 2) % capacity + 1]
        local current = samples[(first + offset - 1) % capacity + 1]
        local px = graph_left + (requested - visible + offset - 1) * step
        local cx = px + step
        render.line(px, graph_bottom - previous / scale * style.graph_height,
            cx, graph_bottom - current / scale * style.graph_height, accent.value, 2)
    end

    local footer = string.format('avg %.0f | peak %.0f | scale %d',
        sum / visible, peak, scale)
    local footer_y = y + height - footer_height + (footer_height - text_height) / 2
    render.text(graph_left, footer_y, footer, style.muted, font)
end)
```

## Notes

- `cmd.number` prevents duplicate samples.
- The graph keeps up to 128 samples and adjusts its vertical scale automatically.
