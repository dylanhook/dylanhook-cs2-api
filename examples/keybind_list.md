# Keybind list

Displays active keybinds from `menu.active_binds()`. Rows fade in and out, the
panel resizes to its contents and long names are shortened to fit.

Menu: `visuals > view`. [Download `keybind_list.lua`](keybind_list.lua).

```lua
local group = menu.visuals.view
local enabled = group:checkbox('keybind list', true, 'binds.enabled')
local accent = enabled:with_color(color(130, 178, 255), 'binds.accent')
local maximum_rows = group:slider('keybind rows', 3, 14, 8, 1, 'binds.rows')
local horizontal = group:slider('keybind list x', 0, 10000, 7600, 1, 'binds.x')
local vertical = group:slider('keybind list y', 0, 10000, 3600, 1, 'binds.y')
horizontal.visible, vertical.visible = false, false

local font = assert(render.load_font('Verdana', 12, 'normal'), 'keybind list: Verdana unavailable')

local style = {
    padding = 8,
    text_padding = 4,
    row_padding = 2,
    accent_height = 2,
    minimum_width = 168,
    name_width = 180,
    maximum_name_bytes = 96,
    fade_speed = 11,
    background = color(17, 17, 17, 215),
    foreground = color(238, 241, 247),
    muted = color(146, 153, 168),
}

local mode_labels = {
    hold = 'hold',
    toggle = 'toggle',
    disable = 'off',
}

local rows = {}
local by_id = {}
local panel_alpha = 0

local function clean(text, maximum_bytes)
    text = tostring(text or ''):gsub('%c', ' ')
    if #text <= maximum_bytes then return text end
    local last = maximum_bytes - 3
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

local function remove_row(index)
    by_id[rows[index].id] = nil
    table.remove(rows, index)
end

local function clear()
    rows, by_id = {}, {}
    panel_alpha = 0
end

on.session_changed(clear)
enabled:on_change(clear)

local function update_rows(dt, menu_open)
    for _, row in ipairs(rows) do row.live = false end

    local incoming = menu.active_binds()
    for order, bind in ipairs(incoming) do
        local row = by_id[bind.id]
        if not row then
            row = { id = bind.id, alpha = 0 }
            rows[#rows + 1] = row
            by_id[bind.id] = row
        end
        row.name = clean(bind.name, style.maximum_name_bytes)
        row.mode = mode_labels[bind.mode] or bind.mode
        row.governing = bind.governing
        row.order = order
        row.live = true
    end

    local step = math.min(1, math.max(0, dt) * style.fade_speed)
    for index = #rows, 1, -1 do
        local row = rows[index]
        local target = row.live and 1 or 0
        row.alpha = row.alpha + (target - row.alpha) * step
        if not row.live and row.alpha < 0.01 then remove_row(index) end
    end

    table.sort(rows, function(a, b)
        if a.order == b.order then return a.name:lower() < b.name:lower() end
        return (a.order or 999) < (b.order or 999)
    end)

    local visible = #incoming > 0 or menu_open
    panel_alpha = panel_alpha + ((visible and 1 or 0) - panel_alpha) * step
end

local function panel_size()
    local title_width, text_height = render.measure_text('keybinds', font)
    local header = math.ceil(text_height) + style.text_padding * 2 + style.accent_height
    local row_height = math.ceil(text_height) + style.row_padding * 2
    local width = math.max(style.minimum_width, title_width + style.padding * 2)
    local visible = math.min(#rows, math.floor(maximum_rows.value))
    for index = 1, visible do
        local row = rows[index]
        local name_width
        row.label, name_width = fit(row.name, style.name_width)
        row.right = row.mode
        row.right_width = render.measure_text(row.right, font)
        width = math.max(width, name_width + row.right_width + style.padding * 3)
    end
    local extra = #rows > visible and 1 or 0
    local body_rows = math.max(1, visible + extra)
    return math.ceil(width), header + body_rows * row_height + style.row_padding, visible,
        header, row_height, text_height, title_width
end

local function place(width, height)
    local screen_width, screen_height = render.screen_size()
    local room_x = math.max(0, screen_width - width)
    local room_y = math.max(0, screen_height - height)
    local x = room_x * horizontal.value / 10000
    local y = room_y * vertical.value / 10000

    if menu.is_open() and input.has_focus() and not input.typing() then
        local dx, dy, active, _, released = input.drag('keybind_panel', x, y, width, height)
        if active or released then
            x = math.clamp(dx, 0, room_x)
            y = math.clamp(dy, 0, room_y)
            horizontal.value = room_x > 0 and math.floor(x / room_x * 10000 + 0.5) or 0
            vertical.value = room_y > 0 and math.floor(y / room_y * 10000 + 0.5) or 0
        end
    end
    return x, y
end

group:button('reset keybind position', function()
    horizontal.value, vertical.value = 7600, 3600
end)

on.paint(function()
    if not enabled.value then return end

    local dt = globals.frame_time()
    local menu_open = menu.is_open() == true
    update_rows(dt, menu_open)
    if panel_alpha < 0.01 then return end

    local width, height, visible, header, row_height, text_height, title_width = panel_size()
    local x, y = place(width, height)
    render.rect(x, y, width, height, faded(style.background, panel_alpha))
    render.rect(x, y, width, style.accent_height, faded(accent.value, panel_alpha))
    render.text(x + (width - title_width) / 2,
        y + style.accent_height + (header - style.accent_height - text_height) / 2,
        'keybinds', faded(style.foreground, panel_alpha), font)

    if visible == 0 then
        render.text(x + style.padding, y + header + (row_height - text_height) / 2,
            'no active binds', faded(style.muted, panel_alpha), font)
    end

    for index = 1, visible do
        local row = rows[index]
        local opacity = panel_alpha * row.alpha
        local row_y = y + header + (index - 1) * row_height + (row_height - text_height) / 2
        render.text(x + style.padding, row_y, row.label,
            faded(row.governing and style.foreground or style.muted, opacity), font)
        render.text(x + width - style.padding - row.right_width, row_y, row.right,
            faded(style.muted, opacity), font)
    end

    if #rows > visible then
        local more = string.format('+%d more', #rows - visible)
        render.text(x + style.padding, y + header + visible * row_height + (row_height - text_height) / 2,
            more, faded(style.muted, panel_alpha), font)
    end
end)
```

## Notes

- `menu.active_binds()` supplies the binding state. The script does not poll keys.
- Weapon-specific rows that are not currently selected are shown muted.
