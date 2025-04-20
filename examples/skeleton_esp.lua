local group = menu.visuals.player_esp.enemy
local enabled = group:checkbox('skeleton esp', false, 'skeleton_esp.enabled')
local hidden_tint = enabled:with_color(color(210, 214, 222), 'skeleton_esp.hidden')
local visible_tint = group:color('visible skeleton', color(255, 96, 96), 'skeleton_esp.visible')
local use_visibility = group:checkbox('highlight visible players', true, 'skeleton_esp.visibility')
local thickness = group:slider('skeleton thickness', 1, 3, 1, 0.5, 'skeleton_esp.thickness')

local root_motion_name = 'root_motion'

local function project_bone(pose, projected, id)
    local cached = projected[id]
    if cached ~= nil then return cached or nil end

    local bone = pose.bones[id + 1]
    local screen = bone and bone.position and render.world_to_screen(bone.position) or nil
    projected[id] = screen or false
    return screen
end

local function hitbox_bones(pose)
    local result = {}
    for _, hitbox in ipairs(pose.hitboxes or {}) do
        if hitbox.bone ~= nil then result[hitbox.bone] = true end
    end
    return result
end

local function root_motion_id(pose)
    for _, bone in ipairs(pose.bones) do
        if bone.name and bone.name:lower() == root_motion_name then
            return bone.id
        end
    end
end

local function draw_skeleton(pawn, tint)
    local pose = player.pose(pawn)
    if not pose or not pose.parents_available or not pose.hitboxes then return end

    local hitbox = hitbox_bones(pose)
    local root_motion = root_motion_id(pose)
    local projected = {}
    local started = {}

    for _, shape in ipairs(pose.hitboxes) do
        local start = shape.bone
        if start ~= nil and not started[start] then
            started[start] = true
            local child = start
            local child_screen = project_bone(pose, projected, child)

            for _ = 1, #pose.bones do
                if not child_screen then break end
                local bone = pose.bones[child + 1]
                local parent = bone and bone.parent or nil
                if parent == nil or parent == root_motion or parent < 0 or parent >= #pose.bones then break end

                local parent_screen = project_bone(pose, projected, parent)
                if parent_screen then
                    render.line(child_screen.x, child_screen.y,
                        parent_screen.x, parent_screen.y, tint, thickness.value)
                end
                if hitbox[parent] then break end

                child = parent
                child_screen = parent_screen
            end
        end
    end
end

on.paint(function()
    if not enabled.value then return end

    local me = entity.local_player()
    local local_team = me and player.team(me) or nil
    if not me or local_team == nil then return end

    for _, pawn in ipairs(entity.players()) do
        local team = player.team(pawn)
        if not player.is_local(pawn) and team ~= nil and team ~= local_team then
            local box_x = player.bounding_box(pawn)
            if box_x ~= nil then
                local tint = hidden_tint.value
                if use_visibility.value and player.visible(pawn) == true then
                    tint = visible_tint.value
                end
                draw_skeleton(pawn, tint)
            end
        end
    end
end)
