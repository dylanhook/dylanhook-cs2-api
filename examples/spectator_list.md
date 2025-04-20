# Spectator list

Displays who is watching you or the player you are spectating. Rows fade when
players join or leave, and the panel resizes to their names.

Menu: `visuals > view`. [Download `spectator_list.lua`](spectator_list.lua).

```lua
local group = menu.visuals.view
local enabled = group:checkbox('spectator list', true, 'spectators.enabled')
local accent = enabled:with_color(color(255, 166, 82), 'spectators.accent')
local maximum_rows = group:slider('spectator rows', 2, 12, 7, 1, 'spectators.rows')
local horizontal = group:slider('spectator list x', 0, 10000, 7600, 1, 'spectators.x')
local vertical = group:slider('spectator list y', 0, 10000, 5200, 1, 'spectators.y')
horizontal.visible, vertical.visible = false, false

local font = assert(render.load_font('Verdana', 12, 'normal'), 'spectator list: Verdana unavailable')

local style = {
    padding = 8,
    text_padding = 4,
    row_padding = 2,
    accent_height = 2,
    minimum_width = 170,
    name_width = 240,
    fade_speed = 10,
    background = color(17, 17, 17, 215),
    foreground = color(238, 241, 247),
    muted = color(146, 153, 168),
}

local rows = {}
local by_index = {}
local panel_alpha = 0
local watched

local function clean(text)
    text = tostring(text or ''):gsub('%c', ' ')
    if #text <= 96 then return text end
    local last = 93
    while last > 0 and text:byte(last + 1) >= 128 and text:byte(last + 1) < 192 do
        last = last - 1
    end
    return text:sub(1, last) .. '...'
end

local function fit(text, limit)
    local width = render.measure_text(text, font)
    if width <= limit then return text, width end
    local ends = {0}
    for index = 1, #text do
        local byte = text:byte(index + 1)
        if not byte or byte < 128 or byte >= 192 then ends[#ends + 1] = index end
    end
    local low, high = 1, #ends
    while low < high do
        local middle = math.ceil((low + high) / 2)
        if render.measure_text(text:sub(1, ends[middle]) .. '...', font) <= limit then low = middle
        else high = middle - 1 end
    end
    text = text:sub(1, ends[low]) .. '...'
    return text, render.measure_text(text, font)
end

local function faded(tint, opacity)
    return tint:alpha(math.floor(tint.a * opacity + 0.5))
end

local function reset()
    rows, by_index = {}, {}
    watched = nil
    panel_alpha = 0
end

on.session_changed(reset)
enabled:on_change(reset)

local function remove_row(index)
    local row = rows[index]
    if by_index[row.index] == row then by_index[row.index] = nil end
    table.remove(rows, index)
end

local function update(dt, menu_open)
    local controller = entity.local_controller()
    local info = controller and player.info(controller)
    local target = info and info.observed_subject or nil
    if target ~= watched then
        reset()
        watched = target
    end

    for _, row in ipairs(rows) do row.live = false end
    local incoming = target and player.spectators(target) or {}
    for order, spectator in ipairs(incoming) do
        local index = entity.index(spectator.controller)
        if index then
            local row = by_index[index]
            if row and row.controller ~= spectator.controller then
                for position, previous in ipairs(rows) do
                    if previous == row then remove_row(position) break end
                end
                row = nil
            end
            if not row then
                row = { index = index, controller = spectator.controller, alpha = 0 }
                rows[#rows + 1] = row
                by_index[index] = row
            end
            row.name = clean(spectator.name)
            row.order = order
            row.live = true
        end
    end

    local step = math.min(1, math.max(0, dt) * style.fade_speed)
    for index = #rows, 1, -1 do
        local row = rows[index]
        row.alpha = row.alpha + ((row.live and 1 or 0) - row.alpha) * step
        if not row.live and row.alpha < 0.01 then remove_row(index) end
    end
    table.sort(rows, function(a, b)
        if a.order == b.order then return a.name:lower() < b.name:lower() end
        return (a.order or 999) < (b.order or 999)
    end)
    panel_alpha = panel_alpha + (((#incoming > 0 or menu_open) and 1 or 0) - panel_alpha) * step
end

local function measure()
    local title_width, text_height = render.measure_text('spectators', font)
    local header = math.ceil(text_height) + style.text_padding * 2 + style.accent_height
    local row_height = math.ceil(text_height) + style.row_padding * 2
    local visible = math.min(#rows, math.floor(maximum_rows.value))
    local width = style.minimum_width
    for index = 1, visible do
        local label, name_width = fit(rows[index].name, style.name_width)
        rows[index].label = label
        width = math.max(width, name_width + style.padding * 2)
    end
    local extra = #rows > visible and 1 or 0
    local body = math.max(1, visible + extra)
    return math.ceil(width), header + body * row_height + style.row_padding, visible,
        header, row_height, text_height, title_width
end

local function place(width, height)
    local screen_width, screen_height = render.screen_size()
    local room_x, room_y = math.max(0, screen_width - width), math.max(0, screen_height - height)
    local x, y = room_x * horizontal.value / 10000, room_y * vertical.value / 10000
    if menu.is_open() and input.has_focus() and not input.typing() then
        local dx, dy, active, _, released = input.drag('spectator_panel', x, y, width, height)
        if active or released then
            x, y = math.clamp(dx, 0, room_x), math.clamp(dy, 0, room_y)
            horizontal.value = room_x > 0 and math.floor(x / room_x * 10000 + 0.5) or 0
            vertical.value = room_y > 0 and math.floor(y / room_y * 10000 + 0.5) or 0
        end
    end
    return x, y
end

group:button('reset spectator position', function()
    horizontal.value, vertical.value = 7600, 5200
end)

on.paint(function()
    if not enabled.value then return end
    update(globals.frame_time(), menu.is_open() == true)
    if panel_alpha < 0.01 then return end

    local width, height, visible, header, row_height, text_height, title_width = measure()
    local x, y = place(width, height)
    render.rect(x, y, width, height, faded(style.background, panel_alpha))
    render.rect(x, y, width, style.accent_height, faded(accent.value, panel_alpha))
    render.text(x + (width - title_width) / 2,
        y + style.accent_height + (header - style.accent_height - text_height) / 2,
        'spectators', faded(style.foreground, panel_alpha), font)

    if visible == 0 then
        render.text(x + style.padding, y + header + (row_height - text_height) / 2,
            watched and 'nobody is watching' or 'no player being watched',
            faded(style.muted, panel_alpha), font)
    end
    for index = 1, visible do
        local row = rows[index]
        render.text(x + style.padding, y + header + (index - 1) * row_height + (row_height - text_height) / 2,
            row.label, faded(style.foreground, panel_alpha * row.alpha), font)
    end
    if #rows > visible then
        render.text(x + style.padding, y + header + visible * row_height + (row_height - text_height) / 2,
            string.format('+%d more', #rows - visible), faded(style.muted, panel_alpha), font)
    end
end)
```

## Notes

- `player.info()` supplies the observed player. Roaming cameras have no target.
- `player.spectators()` supplies the list, including while your own pawn is absent.
- The row limit shows a `+N more` entry when the list is longer.
- The empty panel stays visible while the menu is open so it can still be moved.
