---@meta _
-- Editor-only declarations. Never load this file as a script.
error('Editor definitions must not execute inside the scripting runtime')

---@class Dylanhook.json_null
local _json_null = {}

---@class Dylanhook.callback_measurement
---@field calls number
---@field failures number
---@field last_ms number
---@field peak_ms number
---@field mean_ms number
---@field last_native_work number
---@field peak_native_work number
---@field native_overruns number
local _record_callback_measurement = {}

---@class Dylanhook.config_result
---@field id string
---@field operation string
---@field status string
---@field error string|nil
---@field name string|nil
---@field next_name string|nil
local _record_config_result = {}

---@class Dylanhook.control_info
---@field id string
---@field label string
---@field kind string
---@field type string|nil
---@field visible boolean
---@field default boolean|number|(boolean)[]|Dylanhook.color|string|nil
---@field options (string)[]
---@field minimum number|nil
---@field maximum number|nil
---@field step number|nil
---@field maximum_length integer|nil
local _record_control_info = {}

---@class Dylanhook.execution_budget
---@field profile "standard"|"unsafe"
---@field memory_limit number|nil
---@field memory_used number
---@field source_limit integer
---@field native_enforced boolean
---@field native_threshold number
---@field native_limit number|nil
---@field native_used number
---@field native_remaining number|nil
---@field instruction_limit number|nil
local _record_execution_budget = {}

---@class Dylanhook.execution_statistics
---@field memory_used number
---@field memory_peak number
---@field source Dylanhook.callback_measurement
---@field callbacks table<string, Dylanhook.callback_measurement>
---@field last_error string|nil
local _record_execution_statistics = {}

---@class Dylanhook.font_metrics
---@field ascent number
---@field descent number
---@field line_gap number
---@field line_height number
local _record_font_metrics = {}

---@class Dylanhook.font_options
---@field italic boolean|nil
---@field render_mode string|nil
---@field decoration string|nil
---@field letter_spacing number|nil
local _record_font_options = {}

---@class Dylanhook.http_progress
---@field phase string
---@field received_bytes string
---@field content_length string|nil
---@field status integer|nil
local _record_http_progress = {}

---@class Dylanhook.http_response
---@field ok boolean
---@field status integer|nil
---@field body string|nil
---@field streamed boolean
---@field received_bytes string
---@field headers table<string, string|(string)[]>
---@field error string|nil
---@field os_error integer|nil
local _record_http_response = {}

---@class Dylanhook.input_region
---@field hovered boolean
---@field cursor Dylanhook.vec2
---@field buttons table<integer, Dylanhook.input_region_button>
local _record_input_region = {}

---@class Dylanhook.input_region_button
---@field pressed boolean
---@field held boolean
---@field released boolean
---@field cancelled boolean
---@field origin Dylanhook.vec2|nil
local _record_input_region_button = {}

---@class Dylanhook.menu_theme
---@field accent Dylanhook.color
---@field form_outer Dylanhook.color
---@field form_rim Dylanhook.color
---@field form_dark Dylanhook.color
---@field form_bg Dylanhook.color
---@field rail_bg Dylanhook.color
---@field group_bg Dylanhook.color
---@field group_header_bg Dylanhook.color
---@field group_border_outer Dylanhook.color
---@field group_border_inner Dylanhook.color
---@field card_header_rim Dylanhook.color
---@field card_shadow_near Dylanhook.color
---@field card_shadow_far Dylanhook.color
---@field chip_rim_active Dylanhook.color
---@field chip_rim_rest Dylanhook.color
---@field border_outer Dylanhook.color
---@field border_inner Dylanhook.color
---@field control_top Dylanhook.color
---@field control_bot Dylanhook.color
---@field control_top_hover Dylanhook.color
---@field control_bot_hover Dylanhook.color
---@field control_pressed Dylanhook.color
---@field check_top Dylanhook.color
---@field check_bot Dylanhook.color
---@field track_top Dylanhook.color
---@field track_bot Dylanhook.color
---@field list_bg Dylanhook.color
---@field list_row_hover Dylanhook.color
---@field binding_table_separator Dylanhook.color
---@field popup_bg Dylanhook.color
---@field popup_border_outer Dylanhook.color
---@field popup_border_inner Dylanhook.color
---@field popup_row_hover Dylanhook.color
---@field text_primary Dylanhook.color
---@field text_secondary Dylanhook.color
---@field text_label Dylanhook.color
---@field text_muted Dylanhook.color
---@field text_placeholder Dylanhook.color
---@field text_shadow Dylanhook.color
---@field checker_light Dylanhook.color
---@field checker_dark Dylanhook.color
---@field picker_cursor Dylanhook.color
---@field cursor_outline Dylanhook.color
---@field chrome_outline Dylanhook.color
---@field chrome_rim Dylanhook.color
---@field status_error Dylanhook.color
---@field status_warning Dylanhook.color
---@field status_ok Dylanhook.color
local _record_menu_theme = {}

---@class Dylanhook.path_command
---@field kind string
---@field point Dylanhook.vec2|nil
---@field control1 Dylanhook.vec2|nil
---@field control2 Dylanhook.vec2|nil
local _record_path_command = {}

---@class Dylanhook.path_options
---@field stroke_width number|nil
---@field fill_rule string|nil
---@field join string|nil
---@field cap string|nil
---@field miter_limit number|nil
local _record_path_options = {}

---@class Dylanhook.script_entry
---@field name string
---@field status string
local _record_script_entry = {}

---@class Dylanhook.script_info
---@field name string
---@field logical_name string
---@field status string
---@field profile string
---@field config_operation_id string|nil
local _record_script_info = {}

---@class Dylanhook.setting_bind
---@field key integer
---@field mode string
---@field value number|string|(boolean)[]|nil
local _record_setting_bind = {}

---@class Dylanhook.shot_estimate
---@field damage number
---@field hitgroup integer|nil
---@field bone integer|nil
---@field expected_health integer|nil
---@field minimum_damage number|nil
---@field hitchance_threshold number|nil
---@field command_tick_base integer|nil
---@field snapshot_tick integer|nil
---@field record_tick integer
---@field attack_tick integer
---@field attack_fraction number
---@field penetrations integer
---@field extrapolated boolean
local _record_shot_estimate = {}

---@class Dylanhook.shot_notice
---@field id string
---@field session_id string|nil
---@field target Dylanhook.entity|nil
---@field origin Dylanhook.vec3
---@field aim_point Dylanhook.vec3
---@field weapon string
---@field estimate Dylanhook.shot_estimate
---@field outcome string|nil
---@field confirmation string|nil
---@field reason string|nil
---@field victim Dylanhook.entity|nil
---@field damage integer|nil
---@field hitgroup integer|nil
---@field remaining_health integer|nil
local _record_shot_notice = {}

---@class Dylanhook.text_layout_options
---@field flow string|nil
---@field align string|nil
local _record_text_layout_options = {}

---@class Dylanhook.text_metrics
---@field width number
---@field height number
---@field left number
---@field top number
---@field ink_left number
---@field ink_top number
---@field ink_right number
---@field ink_bottom number
---@field line_count integer
local _record_text_metrics = {}

---@class Dylanhook.transform_options
---@field rotation number|nil
---@field origin Dylanhook.vec2|nil
---@field translation Dylanhook.vec2|nil
---@field scale Dylanhook.vec2|nil
local _record_transform_options = {}

---@class Dylanhook.websocket_options
---@field url string
---@field headers table<string, string>|nil
---@field timeout_ms integer|nil
local _record_websocket_options = {}

---@class Dylanhook.websocket_status
---@field phase string
---@field http_status integer
---@field queued_send_bytes integer
---@field queued_send_messages integer
---@field received_bytes integer
---@field message_ready boolean
---@field close_observed boolean
---@field close_code integer|nil
---@field close_reason string|nil
---@field error string|nil
---@field os_error integer|nil
local _record_websocket_status = {}

---@class Dylanhook.anti_aim_references
local _dh_anti_aim_references = {}

---references:at_target() -> number | nil
---Reference: events.md:307
---@return number|nil
function _dh_anti_aim_references:at_target() end

---references:freestand() -> number | nil
---Reference: events.md:322
---@return number|nil
function _dh_anti_aim_references:freestand() end

---@class Dylanhook.color
---@field a integer
---@field b integer
---@field g integer
---@field r integer
local _dh_color = {}

---value:alpha(a: integer) -> color
---Reference: types/color.md:66
---@param a integer
---@return Dylanhook.color
function _dh_color:alpha(a) end

---value:lerp(other: color, t: number) -> color
---Reference: types/color.md:80
---@param other Dylanhook.color
---@param t number
---@return Dylanhook.color
function _dh_color:lerp(other, t) end

---@class Dylanhook.command
---@field decision table|nil
---@field kinematics table|nil
---@field number integer|nil
---@field subtick_count integer
---@field timing table
---@field view_angles Dylanhook.vec3|nil
---@field weapon_spread table|nil
local _dh_command = {}

---cmd:action_schedule() -> table | nil
---Reference: api/cmd.md:185
---@return table|nil
function _dh_command:action_schedule() end

---cmd:button_down(name: string) -> boolean
---Reference: api/cmd.md:116
---@param name string
---@return boolean
function _dh_command:button_down(name) end

---cmd:button_held(name: string) -> boolean
---Reference: api/cmd.md:126
---@param name string
---@return boolean
function _dh_command:button_held(name) end

---cmd:move() -> (forward: number, side: number) | nil
---Reference: api/cmd.md:276
---@return number|nil
---@return number|nil
function _dh_command:move() end

---cmd:move_toward(world_yaw: number) -> no values
---Reference: api/cmd.md:316
---@param world_yaw number
function _dh_command:move_toward(world_yaw) end

---cmd:override_setting(setting: native_setting, value: boolean | number | string | color | boolean[]) -> true | nil
---Reference: api/cmd.md:454
---@param setting Dylanhook.native_setting
---@param value boolean|number|string|Dylanhook.color|(boolean)[]
---@return true|nil
function _dh_command:override_setting(setting, value) end

---cmd:set_aim_angles(angles: vec3) -> no values
---Reference: api/cmd.md:68
---@param angles Dylanhook.vec3
function _dh_command:set_aim_angles(angles) end

---cmd:set_button(name: string, down: boolean = false) -> no values
---Reference: api/cmd.md:137
---@param name string
---@param down? boolean
function _dh_command:set_button(name, down) end

---cmd:set_button_schedule(name: string, down: boolean, changes: table[]) -> no values
---Reference: api/cmd.md:200
---@param name string
---@param down boolean
---@param changes (table)[]
function _dh_command:set_button_schedule(name, down, changes) end

---cmd:set_move(forward: number, side: number) -> no values
---Reference: api/cmd.md:288
---@param forward number
---@param side number
function _dh_command:set_move(forward, side) end

---cmd:set_move_schedule(segments: table[]) -> no values
---Reference: api/cmd.md:247
---@param segments (table)[]
function _dh_command:set_move_schedule(segments) end

---cmd:set_shot_angles(angles: vec3) -> integer
---Reference: api/cmd.md:81
---@param angles Dylanhook.vec3
---@return integer
function _dh_command:set_shot_angles(angles) end

---cmd:set_target_policy(pawn: entity, options: table | nil) -> boolean | nil, string | nil
---Reference: api/cmd.md:417
---@param pawn Dylanhook.entity
---@param options table|nil
---@return boolean|nil
---@return string|nil
function _dh_command:set_target_policy(pawn, options) end

---cmd:set_view_angles(angles: vec3) -> no values
---Reference: api/cmd.md:56
---@param angles Dylanhook.vec3
function _dh_command:set_view_angles(angles) end

---cmd:subtick_press(name: string, when: number) -> no values
---Reference: api/cmd.md:161
---@param name string
---@param when number
function _dh_command:subtick_press(name, when) end

---@class Dylanhook.config_operation
---@field id string
local _dh_config_operation = {}

---config_operation:release() -> boolean
---Reference: api/config.md:172
---@return boolean
function _dh_config_operation:release() end

---config_operation:result() -> config_result | nil
---Reference: api/config.md:149
---@return Dylanhook.config_result|nil
function _dh_config_operation:result() end

---@class Dylanhook.config_value
---@field default boolean|number|string|Dylanhook.color
---@field type string
---@field value boolean|number|string|Dylanhook.color
local _dh_config_value = {}

---@class Dylanhook.cvar
---@field name string
---@field type string
---@field value boolean|number|string|Dylanhook.color|Dylanhook.vec2|Dylanhook.vec3|table|nil
local _dh_cvar = {}

---ref:get_bool() -> boolean | nil
---Reference: api/cvar.md:63
---@return boolean|nil
function _dh_cvar:get_bool() end

---ref:get_float() -> number | nil
---Reference: api/cvar.md:82
---@return number|nil
function _dh_cvar:get_float() end

---ref:get_int() -> number | string | nil
---Reference: api/cvar.md:72
---@return number|string|nil
function _dh_cvar:get_int() end

---ref:get_string() -> string | nil
---Reference: api/cvar.md:91
---@return string|nil
function _dh_cvar:get_string() end

---ref:set_bool(value: boolean) -> true
---Reference: api/cvar.md:139
---@param value boolean
---@return true
function _dh_cvar:set_bool(value) end

---ref:set_float(value: number) -> true
---Reference: api/cvar.md:158
---@param value number
---@return true
function _dh_cvar:set_float(value) end

---ref:set_int(value: number | string) -> true
---Reference: api/cvar.md:148
---@param value number|string
---@return true
function _dh_cvar:set_int(value) end

---ref:set_string(value: string) -> true
---Reference: api/cvar.md:167
---@param value string
---@return true
function _dh_cvar:set_string(value) end

---@class Dylanhook.entity
---@field designer_name string|nil
---@field index integer|nil
---@field schema_class string|nil
---@field valid boolean
local _dh_entity = {}

---value:address() -> cdata | nil
---Reference: api/entity.md:267
---@return ffi.cdata*|nil
function _dh_entity:address() end

---value:get_schema(path: string) -> boolean | number | string | vec2 | vec3 | color | entity | table | nil
---Reference: api/entity.md:209
---@param path string
---@return boolean|number|string|Dylanhook.vec2|Dylanhook.vec3|Dylanhook.color|Dylanhook.entity|table|nil
function _dh_entity:get_schema(path) end

---entity:is_a(class: string) -> boolean | nil
---Reference: api/entity.md:654
---@param class string
---@return boolean|nil
function _dh_entity:is_a(class) end

---value:set_schema(path: string, new_value: boolean | number | vec2 | vec3 | color) -> true | nil
---Reference: api/entity.md:250
---@param path string
---@param new_value boolean|number|Dylanhook.vec2|Dylanhook.vec3|Dylanhook.color
---@return true|nil
function _dh_entity:set_schema(path, new_value) end

---@class Dylanhook.font
---@field name string
local _dh_font = {}

---font:metrics() -> font_metrics | nil
---Reference: api/render.md:546
---@return Dylanhook.font_metrics|nil
function _dh_font:metrics() end

---font:release()
---Reference: api/render.md:536
function _dh_font:release() end

---@class Dylanhook.function_hook
---@field active boolean
---@field original ffi.cdata*
local _dh_function_hook = {}

---hook:remove() -> boolean
---Reference: api/memory.md:402
---@return boolean
function _dh_function_hook:remove() end

---@class Dylanhook.game_event
---@field name string|nil
local _dh_game_event = {}

---event:get_float(field: string | number) -> number | nil
---Reference: events.md:190
---@param field string|number
---@return number|nil
function _dh_game_event:get_float(field) end

---event:get_int(field: string | number) -> integer | nil
---Reference: events.md:162
---@param field string|number
---@return integer|nil
function _dh_game_event:get_int(field) end

---event:get_player(field: string | number, kind: string = "pawn") -> entity | nil
---Reference: events.md:206
---@param field string|number
---@param kind? string
---@return Dylanhook.entity|nil
function _dh_game_event:get_player(field, kind) end

---event:get_string(field: string | number) -> string | nil
---Reference: events.md:198
---@param field string|number
---@return string|nil
function _dh_game_event:get_string(field) end

---event:get_uint64(field: string | number) -> string | nil
---Reference: events.md:180
---@param field string|number
---@return string|nil
function _dh_game_event:get_uint64(field) end

---@class Dylanhook.image_request
local _dh_image_request = {}

---request:cancel()
---Reference: api/render.md:740
function _dh_image_request:cancel() end

---request:status() -> string
---Reference: api/render.md:714
---@return string
function _dh_image_request:status() end

---request:take() -> texture | nil
---Reference: api/render.md:725
---@return Dylanhook.texture|nil
function _dh_image_request:take() end

---@class Dylanhook.menu_container
local _dh_menu_container = {}

---container:button(label: string, callback: function()) -> control
---Reference: api/menu.md:380
---@param label string
---@param callback fun()
---@return Dylanhook.menu_control
function _dh_menu_container:button(label, callback) end

---container:checkbox(label: string, default: boolean = false, stable_id: string? = nil) -> control
---Reference: api/menu.md:290
---@param label string
---@param default? boolean
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:checkbox(label, default, stable_id) end

---container:color(label: string, default: color, stable_id: string? = nil) -> control
---Reference: api/menu.md:350
---@param label string
---@param default Dylanhook.color
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:color(label, default, stable_id) end

---container:combobox(label: string, options: string[], default: integer = 1, stable_id: string? = nil) -> control
---Reference: api/menu.md:308
---@param label string
---@param options (string)[]
---@param default? integer
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:combobox(label, options, default, stable_id) end

---container:label(text: string) -> control
---Reference: api/menu.md:390
---@param text string
---@return Dylanhook.menu_control
function _dh_menu_container:label(text) end

---container:multiselect(label: string, options: string[], stable_id: string? = nil) -> control
---Reference: api/menu.md:330
---@param label string
---@param options (string)[]
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:multiselect(label, options, stable_id) end

---container:slider(label: string, min: number, max: number, default: number, step: number = 1, stable_id: string? = nil) -> control
---Reference: api/menu.md:298
---@param label string
---@param min number
---@param max number
---@param default number
---@param step? number
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:slider(label, min, max, default, step, stable_id) end

---container:text(label: string, default: string = '', max_length: integer = 256, stable_id: string? = nil) -> control
---Reference: api/menu.md:370
---@param label string
---@param default? string
---@param max_length? integer
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_container:text(label, default, max_length, stable_id) end

---@class Dylanhook.menu_control
---@field label string
---@field value boolean|number|(boolean)[]|Dylanhook.color|string|nil
---@field visible boolean
local _dh_menu_control = {}

---control:binds() -> setting_bind[]
---Reference: api/menu.md:526
---@return (Dylanhook.setting_bind)[]
function _dh_menu_control:binds() end

---control:clear_override() -> nil
---Reference: api/menu.md:516
---@return nil
function _dh_menu_control:clear_override() end

---control:get_base() -> boolean | number | boolean[] | color | string
---Reference: api/menu.md:440
---@return boolean|number|(boolean)[]|Dylanhook.color|string
function _dh_menu_control:get_base() end

---control:get_keybind_value() -> boolean | number | boolean[] | color | string
---Reference: api/menu.md:453
---@return boolean|number|(boolean)[]|Dylanhook.color|string
function _dh_menu_control:get_keybind_value() end

---control:info() -> control_info
---Reference: api/menu.md:465
---@return Dylanhook.control_info
function _dh_menu_control:info() end

---control:on_change(callback: function()) -> subscription
---Reference: api/menu.md:572
---@param callback fun()
---@return Dylanhook.subscription
function _dh_menu_control:on_change(callback) end

---control:on_submit(callback: function(text: string)) -> subscription
---Reference: api/menu.md:608
---@param callback fun(text: string)
---@return Dylanhook.subscription
function _dh_menu_control:on_submit(callback) end

---control:override(value: boolean | number | boolean[] | color | string) -> nil
---Reference: api/menu.md:499
---@param value boolean|number|(boolean)[]|Dylanhook.color|string
---@return nil
function _dh_menu_control:override(value) end

---control:set_binds(bindings: setting_bind[]) -> nil
---Reference: api/menu.md:538
---@param bindings (Dylanhook.setting_bind)[]
---@return nil
function _dh_menu_control:set_binds(bindings) end

---control:set_format(format: string)
---Reference: api/menu.md:650
---@param format string
function _dh_menu_control:set_format(format) end

---control:set_options(options: string[], selection: integer | boolean[] | nil = nil, default: integer | boolean[] | nil = nil)
---Reference: api/menu.md:675
---@param options (string)[]
---@param selection? integer|(boolean)[]|nil
---@param default? integer|(boolean)[]|nil
function _dh_menu_control:set_options(options, selection, default) end

---control:set_placeholder(text: string)
---Reference: api/menu.md:637
---@param text string
function _dh_menu_control:set_placeholder(text) end

---checkbox:with_color(default: color, stable_id: string? = nil) -> control
---Reference: api/menu.md:358
---@param default Dylanhook.color
---@param stable_id? string|nil
---@return Dylanhook.menu_control
function _dh_menu_control:with_color(default, stable_id) end

---@class Dylanhook.native_setting
---@field value boolean|number|string|Dylanhook.color|(boolean)[]
local _dh_native_setting = {}

---ref:binds() -> setting_bind[]
---Reference: api/native_settings.md:221
---@return (Dylanhook.setting_bind)[]
function _dh_native_setting:binds() end

---ref:clear_override() -> nil
---Reference: api/native_settings.md:118
---@return nil
function _dh_native_setting:clear_override() end

---ref:get_base() -> boolean | number | string | color | boolean[]
---Reference: api/native_settings.md:63
---@return boolean|number|string|Dylanhook.color|(boolean)[]
function _dh_native_setting:get_base() end

---ref:get_keybind_value() -> boolean | number | string | color | boolean[]
---Reference: api/native_settings.md:72
---@return boolean|number|string|Dylanhook.color|(boolean)[]
function _dh_native_setting:get_keybind_value() end

---ref:governing() -> boolean
---Reference: api/native_settings.md:175
---@return boolean
function _dh_native_setting:governing() end

---ref:hide_drawing() -> nil
---Reference: api/native_settings.md:130
---@return nil
function _dh_native_setting:hide_drawing() end

---ref:info() -> table
---Reference: api/native_settings.md:245
---@return table
function _dh_native_setting:info() end

---ref:on_change(callback: function()) -> subscription
---Reference: api/native_settings.md:188
---@param callback fun()
---@return Dylanhook.subscription
function _dh_native_setting:on_change(callback) end

---ref:override(value: boolean | number | string | color | boolean[]) -> nil
---Reference: api/native_settings.md:98
---@param value boolean|number|string|Dylanhook.color|(boolean)[]
---@return nil
function _dh_native_setting:override(value) end

---ref:set_binds(bindings: setting_bind[]) -> nil
---Reference: api/native_settings.md:232
---@param bindings (Dylanhook.setting_bind)[]
---@return nil
function _dh_native_setting:set_binds(bindings) end

---ref:show_drawing() -> nil
---Reference: api/native_settings.md:154
---@return nil
function _dh_native_setting:show_drawing() end

---@class Dylanhook.path
local _dh_path = {}

---path:bounds() -> left: number, top: number, width: number, height: number
---Reference: api/render.md:268
---@return number
---@return number
---@return number
---@return number
function _dh_path:bounds() end

---path:draw(x: number, y: number, tint: color)
---Reference: api/render.md:257
---@param x number
---@param y number
---@param tint Dylanhook.color
function _dh_path:draw(x, y, tint) end

---path:release()
---Reference: api/render.md:278
function _dh_path:release() end

---@class Dylanhook.player_preferences
local _dh_player_preferences = {}

---preferences:clear_override() -> boolean | nil, string | nil
---Reference: api/entity.md:708
---@return boolean|nil
---@return string|nil
function _dh_player_preferences:clear_override() end

---preferences:get() -> table | nil, string | nil
---Reference: api/entity.md:704
---@return table|nil
---@return string|nil
function _dh_player_preferences:get() end

---preferences:get_base() -> table | nil, string | nil
---Reference: api/entity.md:705
---@return table|nil
---@return string|nil
function _dh_player_preferences:get_base() end

---preferences:override(values: table) -> boolean | nil, string | nil
---Reference: api/entity.md:707
---@param values table
---@return boolean|nil
---@return string|nil
function _dh_player_preferences:override(values) end

---preferences:set(values: table) -> boolean | nil, string | nil
---Reference: api/entity.md:706
---@param values table
---@return boolean|nil
---@return string|nil
function _dh_player_preferences:set(values) end

---@class Dylanhook.schema_field
---@field kind string
---@field width integer
local _dh_schema_field = {}

---schema_field:get(value: entity) -> boolean | number | string | vec2 | vec3 | color | entity | table | nil
---Reference: api/schema.md:105
---@param value Dylanhook.entity
---@return boolean|number|string|Dylanhook.vec2|Dylanhook.vec3|Dylanhook.color|Dylanhook.entity|table|nil
function _dh_schema_field:get(value) end

---schema_field:set(value: entity, new_value: boolean | number | vec2 | vec3 | color) -> true | nil
---Reference: api/schema.md:143
---@param value Dylanhook.entity
---@param new_value boolean|number|Dylanhook.vec2|Dylanhook.vec3|Dylanhook.color
---@return true|nil
function _dh_schema_field:set(value, new_value) end

---@class Dylanhook.sound_clip
---@field duration number|nil
local _dh_sound_clip = {}

---sound_clip:play(volume: number = 1) -> true | nil
---Reference: api/sound.md:53
---@param volume? number
---@return true|nil
function _dh_sound_clip:play(volume) end

---sound_clip:release()
---Reference: api/sound.md:67
function _dh_sound_clip:release() end

---@class Dylanhook.subscription
---@field active boolean
local _dh_subscription = {}

---subscription:remove() -> boolean
---Reference: events.md:726
---@return boolean
function _dh_subscription:remove() end

---@class Dylanhook.text_layout
local _dh_text_layout = {}

---layout:draw(x: number, y: number, tint: color) -> true | nil
---Reference: api/render.md:480
---@param x number
---@param y number
---@param tint Dylanhook.color
---@return true|nil
function _dh_text_layout:draw(x, y, tint) end

---layout:metrics() -> text_metrics | nil
---Reference: api/render.md:495
---@return Dylanhook.text_metrics|nil
function _dh_text_layout:metrics() end

---layout:release()
---Reference: api/render.md:518
function _dh_text_layout:release() end

---layout:size() -> (width: number, height: number) | nil
---Reference: api/render.md:466
---@return number|nil
---@return number|nil
function _dh_text_layout:size() end

---@class Dylanhook.texture
local _dh_texture = {}

---texture:release()
---Reference: api/render.md:758
function _dh_texture:release() end

---texture:size() -> (width: integer, height: integer) | nil
---Reference: api/render.md:750
---@return integer|nil
---@return integer|nil
function _dh_texture:size() end

---@class Dylanhook.trace_request
---@field id string
local _dh_trace_request = {}

---trace_request:cancel() -> boolean
---Reference: api/trace.md:328
---@return boolean
function _dh_trace_request:cancel() end

---trace_request:release() -> boolean
---Reference: api/trace.md:329
---@return boolean
function _dh_trace_request:release() end

---trace_request:result() -> result: table | nil, status: string, reason: string | nil
---Reference: api/trace.md:327
---@return table|nil
---@return string
---@return string|nil
function _dh_trace_request:result() end

---trace_request:status() -> status: string, reason: string | nil
---Reference: api/trace.md:326
---@return string
---@return string|nil
function _dh_trace_request:status() end

---@class Dylanhook.vec2
---@field x number
---@field y number
---@operator add(Dylanhook.vec2):Dylanhook.vec2
---@operator sub(Dylanhook.vec2):Dylanhook.vec2
---@operator mul(number):Dylanhook.vec2
---@operator div(number):Dylanhook.vec2
---@operator unm:Dylanhook.vec2
local _dh_vec2 = {}

---value:distance(other: vec2) -> number
---Reference: types/vec2.md:87
---@param other Dylanhook.vec2
---@return number
function _dh_vec2:distance(other) end

---value:distance_sqr(other: vec2) -> number
---Reference: types/vec2.md:95
---@param other Dylanhook.vec2
---@return number
function _dh_vec2:distance_sqr(other) end

---value:dot(other: vec2) -> number
---Reference: types/vec2.md:79
---@param other Dylanhook.vec2
---@return number
function _dh_vec2:dot(other) end

---value:length() -> number
---Reference: types/vec2.md:63
---@return number
function _dh_vec2:length() end

---value:length_sqr() -> number
---Reference: types/vec2.md:71
---@return number
function _dh_vec2:length_sqr() end

---value:lerp(other: vec2, t: number) -> vec2
---Reference: types/vec2.md:126
---@param other Dylanhook.vec2
---@param t number
---@return Dylanhook.vec2
function _dh_vec2:lerp(other, t) end

---value:normalized() -> vec2 | nil
---Reference: types/vec2.md:109
---@return Dylanhook.vec2|nil
function _dh_vec2:normalized() end

---value:unpack() -> x: number, y: number
---Reference: types/vec2.md:55
---@return number
---@return number
function _dh_vec2:unpack() end

---@class Dylanhook.vec3
---@field x number
---@field y number
---@field z number
---@operator add(Dylanhook.vec3):Dylanhook.vec3
---@operator sub(Dylanhook.vec3):Dylanhook.vec3
---@operator mul(number):Dylanhook.vec3
---@operator div(number):Dylanhook.vec3
---@operator unm:Dylanhook.vec3
local _dh_vec3 = {}

---value:angles() -> vec3 | nil
---Reference: types/vec3.md:156
---@return Dylanhook.vec3|nil
function _dh_vec3:angles() end

---value:basis() -> (forward: vec3, left: vec3, up: vec3)
---Reference: types/vec3.md:176
---@return Dylanhook.vec3
---@return Dylanhook.vec3
---@return Dylanhook.vec3
function _dh_vec3:basis() end

---value:cross(other: vec3) -> vec3
---Reference: types/vec3.md:67
---@param other Dylanhook.vec3
---@return Dylanhook.vec3
function _dh_vec3:cross(other) end

---value:distance(other: vec3) -> number
---Reference: types/vec3.md:121
---@param other Dylanhook.vec3
---@return number
function _dh_vec3:distance(other) end

---value:distance_sqr(other: vec3) -> number
---Reference: types/vec3.md:129
---@param other Dylanhook.vec3
---@return number
function _dh_vec3:distance_sqr(other) end

---value:dot(other: vec3) -> number
---Reference: types/vec3.md:113
---@param other Dylanhook.vec3
---@return number
function _dh_vec3:dot(other) end

---value:length() -> number
---Reference: types/vec3.md:81
---@return number
function _dh_vec3:length() end

---value:length2d() -> number
---Reference: types/vec3.md:97
---@return number
function _dh_vec3:length2d() end

---value:length2d_sqr() -> number
---Reference: types/vec3.md:105
---@return number
function _dh_vec3:length2d_sqr() end

---value:length_sqr() -> number
---Reference: types/vec3.md:89
---@return number
function _dh_vec3:length_sqr() end

---value:lerp(other: vec3, t: number) -> vec3
---Reference: types/vec3.md:145
---@param other Dylanhook.vec3
---@param t number
---@return Dylanhook.vec3
function _dh_vec3:lerp(other, t) end

---value:normalized() -> vec3 | nil
---Reference: types/vec3.md:137
---@return Dylanhook.vec3|nil
function _dh_vec3:normalized() end

---value:unpack() -> x: number, y: number, z: number
---Reference: types/vec3.md:59
---@return number
---@return number
---@return number
function _dh_vec3:unpack() end

---@class Dylanhook.websocket
local _dh_websocket = {}

---socket:close(code: integer = 1000, reason: string = "") -> boolean | (nil, error: string, os_error: integer)
---Reference: api/websocket.md:126
---@param code? integer
---@param reason? string
---@return boolean|nil
---@return nil|string
---@return nil|integer
function _dh_websocket:close(code, reason) end

---socket:receive() -> (data: string, kind: string) | nil | (nil, error: string, os_error: integer)
---Reference: api/websocket.md:102
---@return string|nil
---@return string|nil
---@return nil|integer
function _dh_websocket:receive() end

---socket:send(data: string, kind: string = "text") -> true | (nil, error: string, os_error: integer)
---Reference: api/websocket.md:86
---@param data string
---@param kind? string
---@return true|nil
---@return nil|string
---@return nil|integer
function _dh_websocket:send(data, kind) end

---socket:status() -> websocket_status | (nil, error: string, os_error: integer)
---Reference: api/websocket.md:51
---@return Dylanhook.websocket_status|nil
---@return nil|string
---@return nil|integer
function _dh_websocket:status() end

assets = {}

base64 = {}

client = {}

clipboard = {}

---@class Dylanhook.color_constructor
---@overload fun(r: integer, g: integer, b: integer, a?: integer): Dylanhook.color
---@field white Dylanhook.color
---@field black Dylanhook.color
---@field red Dylanhook.color
---@field green Dylanhook.color
---@field blue Dylanhook.color
color = {}

config = {}

console = {}

cvar = {}

entity = {}

esp = {}

fs = {}

game = {}

globals = {}

hash = {}

http = {}

input = {}

json = {}

memory = {}

menu = {}

notify = {}

on = {}

panorama = {}

player = {}

render = {}

schema = {}

script = {}

sound = {}

system = {}

timer = {}

trace = {}

weapon = {}

websocket = {}

why = {}

---assets.exists(name: string | number) -> boolean | nil
---Reference: api/resources.md:89
---@param name string|number
---@return boolean|nil
function assets.exists(name) end

---assets.read(name: string | number) -> string | nil
---Reference: api/resources.md:61
---@param name string|number
---@return string|nil
function assets.read(name) end

---assets.read(name: string | number, offset: integer | string, length: integer) -> string | nil
---Reference: api/resources.md:62
---@param name string|number
---@param offset integer|string
---@param length integer
---@return string|nil
function assets.read(name, offset, length) end

---base64.decode(text: string) -> string | (nil, error: string)
---Reference: api/bytes.md:19
---@param text string
---@return string|nil
---@return nil|string
function base64.decode(text) end

---base64.encode(bytes: string) -> string
---Reference: api/bytes.md:10
---@param bytes string
---@return string
function base64.encode(bytes) end

---client.username() -> string | nil
---Reference: api/client.md:6
---@return string|nil
function client.username() end

---clipboard.read() -> string | nil
---Reference: api/clipboard.md:13
---@return string|nil
function clipboard.read() end

---clipboard.write(text: string) -> true | nil
---Reference: api/clipboard.md:23
---@param text string
---@return true|nil
function clipboard.write(text) end

---color.hsv(h: number, s: number, v: number, a: integer = 255) -> color
---Reference: types/color.md:51
---@param h number
---@param s number
---@param v number
---@param a? integer
---@return Dylanhook.color
function color.hsv(h, s, v, a) end

---config.active() -> string | nil
---Reference: api/config.md:26
---@return string|nil
function config.active() end

---config.delete(name: string) -> config_operation | nil, string | nil
---Reference: api/config.md:67
---@param name string
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.delete(name) end

---config.export() -> string | nil, string | nil
---Reference: api/config.md:96
---@return string|nil
---@return string|nil
function config.export() end

---config.import(data: string) -> config_operation | nil, string | nil
---Reference: api/config.md:111
---@param data string
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.import(data) end

---config.last_result() -> config_result | nil
---Reference: api/config.md:181
---@return Dylanhook.config_result|nil
function config.last_result() end

---config.list() -> string[] | nil, string | nil
---Reference: api/config.md:10
---@return (string)[]|nil
---@return string|nil
function config.list() end

---config.load(name: string) -> config_operation | nil, string | nil
---Reference: api/config.md:52
---@param name string
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.load(name) end

---config.rename(name: string, new_name: string) -> config_operation | nil, string | nil
---Reference: api/config.md:77
---@param name string
---@param new_name string
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.rename(name, new_name) end

---config.reset() -> config_operation | nil, string | nil
---Reference: api/config.md:87
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.reset() end

---config.save(name: string) -> config_operation | nil, string | nil
---Reference: api/config.md:36
---@param name string
---@return Dylanhook.config_operation|nil
---@return string|nil
function config.save(name) end

---config.value(id: string, type: string, default: boolean | number | string | color) -> config_value
---Reference: api/config.md:214
---@param id string
---@param type string
---@param default boolean|number|string|Dylanhook.color
---@return Dylanhook.config_value
function config.value(id, type, default) end

---console.error(text: string | number) -> true | (false, reason: string)
---Reference: api/console.md:39
---@param text string|number
---@return true|false
---@return nil|string
function console.error(text) end

---console.exec(...: string | number) -> no values
---Reference: api/console.md:102
---@param ... string|number
function console.exec(...) end

---console.log(text: string | number) -> true | (false, reason: string)
---Reference: api/console.md:10
---@param text string|number
---@return true|false
---@return nil|string
function console.log(text) end

---console.register(name: string, callback: function(...: string), help: string = "") -> subscription
---Reference: api/console.md:123
---@param name string
---@param callback fun(...: string)
---@param help? string
---@return Dylanhook.subscription
function console.register(name, callback, help) end

---console.warn(text: string | number) -> true | (false, reason: string)
---Reference: api/console.md:27
---@param text string|number
---@return true|false
---@return nil|string
function console.warn(text) end

---cvar.get(name: string) -> cvar_ref | nil
---Reference: api/cvar.md:10
---@param name string
---@return Dylanhook.cvar|nil
function cvar.get(name) end

---entity.at(index: integer) -> entity | nil
---Reference: api/entity.md:145
---@param index integer
---@return Dylanhook.entity|nil
function entity.at(index) end

---entity.controllers() -> table | nil
---Reference: api/entity.md:577
---@return table|nil
function entity.controllers() end

---entity.designer_name(value: entity) -> string | nil
---Reference: api/entity.md:183
---@param value Dylanhook.entity
---@return string|nil
function entity.designer_name(value) end

---entity.find_by_class(class: string, include_derived: boolean = false) -> entity | nil
---Reference: api/entity.md:98
---@param class string
---@param include_derived? boolean
---@return Dylanhook.entity|nil
function entity.find_by_class(class, include_derived) end

---entity.get_all() -> table | nil
---Reference: api/entity.md:634
---@return table|nil
function entity.get_all() end

---entity.get_all_by_class(class: string, include_derived: boolean = false) -> table | nil
---Reference: api/entity.md:119
---@param class string
---@param include_derived? boolean
---@return table|nil
function entity.get_all_by_class(class, include_derived) end

---entity.index(value: entity) -> integer | nil
---Reference: api/entity.md:159
---@param value Dylanhook.entity
---@return integer|nil
function entity.index(value) end

---entity.local_controller() -> entity | nil
---Reference: api/entity.md:589
---@return Dylanhook.entity|nil
function entity.local_controller() end

---entity.local_player() -> entity | nil
---Reference: api/entity.md:44
---@return Dylanhook.entity|nil
function entity.local_player() end

---entity.planted_c4() -> entity | nil
---Reference: api/entity.md:57
---@return Dylanhook.entity|nil
function entity.planted_c4() end

---entity.players() -> table
---Reference: api/entity.md:75
---@return table
function entity.players() end

---entity.valid(value: entity) -> boolean
---Reference: api/entity.md:169
---@param value Dylanhook.entity
---@return boolean
function entity.valid(value) end

---esp.add_bar(id: string, options: table) -> subscription
---Reference: api/esp.md:53
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.add_bar(id, options) end

---esp.add_flag(id: string, options: table) -> subscription
---Reference: api/esp.md:11
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.add_flag(id, options) end

---esp.add_item(id: string, options: table) -> subscription
---Reference: api/esp.md:79
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.add_item(id, options) end

---esp.add_text(id: string, options: table) -> subscription
---Reference: api/esp.md:44
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.add_text(id, options) end

---esp.chams(id: string, options: table) -> subscription
---Reference: api/esp.md:177
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.chams(id, options) end

---esp.glow(id: string, options: table) -> subscription
---Reference: api/esp.md:224
---@param id string
---@param options table
---@return Dylanhook.subscription
function esp.glow(id, options) end

---fs.exists(name: string | number) -> boolean | nil
---Reference: api/resources.md:165
---@param name string|number
---@return boolean|nil
function fs.exists(name) end

---fs.list() -> string[] | nil
---Reference: api/resources.md:121
---@return (string)[]|nil
function fs.list() end

---fs.read(name: string | number) -> string | nil
---Reference: api/resources.md:97
---@param name string|number
---@return string|nil
function fs.read(name) end

---fs.read(name: string | number, offset: integer | string, length: integer) -> string | nil
---Reference: api/resources.md:98
---@param name string|number
---@param offset integer|string
---@param length integer
---@return string|nil
function fs.read(name, offset, length) end

---fs.remove(name: string | number) -> true | nil
---Reference: api/resources.md:173
---@param name string|number
---@return true|nil
function fs.remove(name) end

---fs.write(name: string | number, data: string | number) -> true | nil
---Reference: api/resources.md:144
---@param name string|number
---@param data string|number
---@return true|nil
function fs.write(name, data) end

---game.auto_peek() -> table | nil
---Reference: api/game.md:117
---@return table|nil
function game.auto_peek() end

---game.bomb_snapshot() -> table | nil
---Reference: api/game.md:34
---@return table|nil
function game.bomb_snapshot() end

---game.capture() -> table | nil
---Reference: api/game.md:101
---@return table|nil
function game.capture() end

---game.catalog(kind: string, cursor: integer = 0, item_definition: integer = 0) -> table | nil
---Reference: api/game.md:208
---@param kind string
---@param cursor? integer
---@param item_definition? integer
---@return table|nil
function game.catalog(kind, cursor, item_definition) end

---game.double_tap() -> table | nil
---Reference: api/game.md:129
---@return table|nil
function game.double_tap() end

---game.grenade_path() -> table | nil, string | nil
---Reference: api/game.md:153
---@return table|nil
---@return string|nil
function game.grenade_path() end

---game.grenade_warnings() -> table | nil, string | nil
---Reference: api/game.md:168
---@return table|nil
---@return string|nil
function game.grenade_warnings() end

---game.map_name() -> string | nil
---Reference: api/game.md:9
---@return string|nil
function game.map_name() end

---globals.curtime() -> number | nil
---Reference: api/globals.md:24
---@return number|nil
function globals.curtime() end

---globals.frame_count() -> number
---Reference: api/globals.md:70
---@return number
function globals.frame_count() end

---globals.frame_time() -> number
---Reference: api/globals.md:59
---@return number
function globals.frame_time() end

---globals.in_game() -> boolean | nil
---Reference: api/globals.md:100
---@return boolean|nil
function globals.in_game() end

---globals.latency() -> integer | nil
---Reference: api/globals.md:118
---@return integer|nil
function globals.latency() end

---globals.max_players() -> integer
---Reference: api/globals.md:110
---@return integer
function globals.max_players() end

---globals.real_time() -> number
---Reference: api/globals.md:37
---@return number
function globals.real_time() end

---globals.tick_count() -> integer | nil
---Reference: api/globals.md:12
---@return integer|nil
function globals.tick_count() end

---globals.ticks_to_time(ticks: integer) -> number
---Reference: api/globals.md:82
---@param ticks integer
---@return number
function globals.ticks_to_time(ticks) end

---globals.time_to_ticks(seconds: number) -> integer
---Reference: api/globals.md:90
---@param seconds number
---@return integer
function globals.time_to_ticks(seconds) end

---hash.sha256(bytes: string) -> string | (nil, error: string)
---Reference: api/bytes.md:40
---@param bytes string
---@return string|nil
---@return nil|string
function hash.sha256(bytes) end

---http.get(url: string, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
---Reference: api/http.md:12
---@param url string
---@param callback fun(response: Dylanhook.http_response)
---@return Dylanhook.subscription|nil
---@return nil|string
---@return nil|integer
function http.get(url, callback) end

---http.get(url: string, options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
---Reference: api/http.md:13
---@param url string
---@param options table
---@param callback fun(response: Dylanhook.http_response)
---@return Dylanhook.subscription|nil
---@return nil|string
---@return nil|integer
function http.get(url, options, callback) end

---http.post(url: string, body: string, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
---Reference: api/http.md:19
---@param url string
---@param body string
---@param callback fun(response: Dylanhook.http_response)
---@return Dylanhook.subscription|nil
---@return nil|string
---@return nil|integer
function http.post(url, body, callback) end

---http.post(url: string, body: string, options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
---Reference: api/http.md:20
---@param url string
---@param body string
---@param options table
---@param callback fun(response: Dylanhook.http_response)
---@return Dylanhook.subscription|nil
---@return nil|string
---@return nil|integer
function http.post(url, body, options, callback) end

---http.progress(request: subscription) -> http_progress | (nil, error: string)
---Reference: api/http.md:121
---@param request Dylanhook.subscription
---@return Dylanhook.http_progress|nil
---@return nil|string
function http.progress(request) end

---http.read(request: subscription) -> string | (nil, error: string)
---Reference: api/http.md:140
---@param request Dylanhook.subscription
---@return string|nil
---@return nil|string
function http.read(request) end

---http.request(options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
---Reference: api/http.md:29
---@param options table
---@param callback fun(response: Dylanhook.http_response)
---@return Dylanhook.subscription|nil
---@return nil|string
---@return nil|integer
function http.request(options, callback) end

---input.capture(device: string) -> nil
---Reference: api/input.md:338
---@param device string
---@return nil
function input.capture(device) end

---input.cursor() -> vec2
---Reference: api/input.md:112
---@return Dylanhook.vec2
function input.cursor() end

---input.delta() -> vec2
---Reference: api/input.md:127
---@return Dylanhook.vec2
function input.delta() end

---input.down(key_code: integer) -> boolean
---Reference: api/input.md:46
---@param key_code integer
---@return boolean
function input.down(key_code) end

---input.drag(id: string, x: number, y: number, width: number, height: number)     -> x: number, y: number, active: boolean, started: boolean, released: boolean
---Reference: api/input.md:252
---@param id string
---@param x number
---@param y number
---@param width number
---@param height number
---@return number
---@return number
---@return boolean
---@return boolean
---@return boolean
function input.drag(id, x, y, width, height) end

---input.has_focus() -> boolean
---Reference: api/input.md:20
---@return boolean
function input.has_focus() end

---input.key_name(key_code: integer) -> string | nil
---Reference: api/input.md:30
---@param key_code integer
---@return string|nil
function input.key_name(key_code) end

---input.pressed(key_code: integer) -> boolean
---Reference: api/input.md:62
---@param key_code integer
---@return boolean
function input.pressed(key_code) end

---input.region(id: string, x: number, y: number, width: number, height: number) -> input_region
---Reference: api/input.md:184
---@param id string
---@param x number
---@param y number
---@param width number
---@param height number
---@return Dylanhook.input_region
function input.region(id, x, y, width, height) end

---input.released(key_code: integer) -> boolean
---Reference: api/input.md:72
---@param key_code integer
---@return boolean
function input.released(key_code) end

---input.repeated(key_code: integer) -> boolean
---Reference: api/input.md:97
---@param key_code integer
---@return boolean
function input.repeated(key_code) end

---input.text() -> string
---Reference: api/input.md:165
---@return string
function input.text() end

---input.typing() -> boolean
---Reference: api/input.md:149
---@return boolean
function input.typing() end

---input.wheel() -> number
---Reference: api/input.md:141
---@return number
function input.wheel() end

---json.array(value: table) -> table
---Reference: api/std.md:377
---@param value table
---@return table
function json.array(value) end

---json.decode(text: string | number) -> boolean | number | string | table | json.null
---Reference: api/std.md:358
---@param text string|number
---@return boolean|number|string|table|Dylanhook.json_null
function json.decode(text) end

---json.encode(value: nil | boolean | number | string | table | json.null) -> string
---Reference: api/std.md:324
---@param value nil|boolean|number|string|table|Dylanhook.json_null
---@return string
function json.encode(value) end

---loadstring(source: string, chunk_name: string = "=(loadstring)") -> function | (nil, error: string)
---Reference: api/std.md:63
---@param source string
---@param chunk_name? string
---@return function|nil
---@return nil|string
function loadstring(source, chunk_name) end

---math.clamp(value: number, minimum: number, maximum: number) -> number
---Reference: api/std.md:222
---@param value number
---@param minimum number
---@param maximum number
---@return number
function math.clamp(value, minimum, maximum) end

---math.lerp(from: number, to: number, amount: number) -> number
---Reference: api/std.md:231
---@param from number
---@param to number
---@param amount number
---@return number
function math.lerp(from, to, amount) end

---math.normalize_angle(angle: number) -> number
---Reference: api/std.md:263
---@param angle number
---@return number
function math.normalize_angle(angle) end

---math.remap(value: number, input_minimum: number, input_maximum: number,            output_minimum: number, output_maximum: number) -> number
---Reference: api/std.md:241
---@param value number
---@param input_minimum number
---@param input_maximum number
---@param output_minimum number
---@param output_maximum number
---@return number
function math.remap(value, input_minimum, input_maximum, output_minimum, output_maximum) end

---math.round(value: number, decimals: integer = 0) -> number
---Reference: api/std.md:252
---@param value number
---@param decimals? integer
---@return number
function math.round(value, decimals) end

---memory.find_pattern(module: string, pattern: string) -> cdata | nil
---Reference: api/memory.md:255
---@param module string
---@param pattern string
---@return ffi.cdata*|nil
function memory.find_pattern(module, pattern) end

---memory.hook(target: cdata, returns: string, arguments: string[], callback: function(...: any)) -> function_hook
---Reference: api/memory.md:305
---@param target ffi.cdata*
---@param returns string
---@param arguments (string)[]
---@param callback fun(...: any)
---@return Dylanhook.function_hook
function memory.hook(target, returns, arguments, callback) end

---memory.interface(module: string, name: string) -> cdata | nil
---Reference: api/memory.md:288
---@param module string
---@param name string
---@return ffi.cdata*|nil
function memory.interface(module, name) end

---menu.accent_color() -> color | nil
---Reference: api/menu.md:119
---@return Dylanhook.color|nil
function menu.accent_color() end

---menu.active_binds() -> table
---Reference: api/menu.md:33
---@return table
function menu.active_binds() end

---menu.alpha() -> number | nil
---Reference: api/menu.md:129
---@return number|nil
function menu.alpha() end

---menu.find(path: string) -> native_setting | nil
---Reference: api/native_settings.md:10
---@param path string
---@return Dylanhook.native_setting|nil
function menu.find(path) end

---menu.get_pos() -> vec2 | nil
---Reference: api/menu.md:101
---@return Dylanhook.vec2|nil
function menu.get_pos() end

---menu.get_size() -> vec2 | nil
---Reference: api/menu.md:110
---@return Dylanhook.vec2|nil
function menu.get_size() end

---menu.is_open() -> boolean | nil
---Reference: api/menu.md:92
---@return boolean|nil
function menu.is_open() end

---menu.settings(prefix: string = "", cursor: integer = 0) -> string[], integer | nil
---Reference: api/native_settings.md:30
---@param prefix? string
---@param cursor? integer
---@return (string)[]
---@return integer|nil
function menu.settings(prefix, cursor) end

---menu.theme() -> menu_theme | nil
---Reference: api/menu.md:139
---@return Dylanhook.menu_theme|nil
function menu.theme() end

---notify.screen(text: string | number) -> true | (false, reason: string)
---Reference: api/notify.md:8
---@param text string|number
---@return true|false
---@return nil|string
function notify.screen(text) end

---on.anti_aim(callback: function(pitch: number, yaw: number, references: anti_aim_references)) -> subscription
---Reference: events.md:268
---@param callback fun(pitch: number, yaw: number, references: Dylanhook.anti_aim_references)
---@return Dylanhook.subscription
function on.anti_aim(callback) end

---on.command_committed(callback: function(snapshot: table)) -> subscription
---Reference: events.md:767
---@param callback fun(snapshot: table)
---@return Dylanhook.subscription
function on.command_committed(callback) end

---on.command_finished(callback: function(cmd: command)) -> subscription
---Reference: events.md:106
---@param callback fun(cmd: Dylanhook.command)
---@return Dylanhook.subscription
function on.command_finished(callback) end

---on.config_result(callback: function(result: config_result | nil)) -> subscription
---Reference: events.md:240
---@param callback fun(result: Dylanhook.config_result|nil)
---@return Dylanhook.subscription
function on.config_result(callback) end

---on.console_input(callback: function(line: string)) -> subscription
---Reference: events.md:391
---@param callback fun(line: string)
---@return Dylanhook.subscription
function on.console_input(callback) end

---on.frame_stage(callback: function(stage: integer, phase: string), phase: string = "after") -> subscription
---Reference: events.md:120
---@param callback fun(stage: integer, phase: string)
---@param phase? string
---@return Dylanhook.subscription
function on.frame_stage(callback, phase) end

---on.game_event(name: string | number, callback: function(event: game_event)) -> subscription
---Reference: events.md:132
---@param name string|number
---@param callback fun(event: Dylanhook.game_event)
---@return Dylanhook.subscription
function on.game_event(name, callback) end

---on.override_view(callback: function(view: table)) -> subscription
---Reference: events.md:345
---@param callback fun(view: table)
---@return Dylanhook.subscription
function on.override_view(callback) end

---on.paint(callback: function()) -> subscription
---Reference: events.md:41
---@param callback fun()
---@return Dylanhook.subscription
function on.paint(callback) end

---on.paint_above_menu(callback: function()) -> subscription
---Reference: events.md:66
---@param callback fun()
---@return Dylanhook.subscription
function on.paint_above_menu(callback) end

---on.session_changed(callback: function()) -> subscription
---Reference: events.md:218
---@param callback fun()
---@return Dylanhook.subscription
function on.session_changed(callback) end

---on.setup_command(callback: function(cmd: command)) -> subscription
---Reference: events.md:77
---@param callback fun(cmd: Dylanhook.command)
---@return Dylanhook.subscription
function on.setup_command(callback) end

---on.shot_committed(callback: function(shot: shot_notice)) -> subscription
---Reference: events.md:423
---@param callback fun(shot: Dylanhook.shot_notice)
---@return Dylanhook.subscription
function on.shot_committed(callback) end

---on.shot_miss(callback: function(miss: table)) -> subscription
---Reference: events.md:556
---@param callback fun(miss: table)
---@return Dylanhook.subscription
function on.shot_miss(callback) end

---on.shot_settled(callback: function(result: shot_notice)) -> subscription
---Reference: events.md:503
---@param callback fun(result: Dylanhook.shot_notice)
---@return Dylanhook.subscription
function on.shot_settled(callback) end

---on.unload(callback: function()) -> subscription
---Reference: events.md:611
---@param callback fun()
---@return Dylanhook.subscription
function on.unload(callback) end

---panorama.run(source: string, panel_id: string = "") -> any
---Reference: api/panorama.md:10
---@param source string
---@param panel_id? string
---@return any
function panorama.run(source, panel_id) end

---player.armor(pawn: entity) -> integer | nil
---Reference: api/entity.md:391
---@param pawn Dylanhook.entity
---@return integer|nil
function player.armor(pawn) end

---player.avatar(controller: entity) -> image_request | nil, string | nil
---Reference: api/entity.md:680
---@param controller Dylanhook.entity
---@return Dylanhook.image_request|nil
---@return string|nil
function player.avatar(controller) end

---player.bone_position(pawn: entity, bone: integer | string) -> vec3 | nil
---Reference: api/pose.md:42
---@param pawn Dylanhook.entity
---@param bone integer|string
---@return Dylanhook.vec3|nil
function player.bone_position(pawn, bone) end

---player.bounding_box(pawn: entity) -> (x: number, y: number, width: number, height: number) | nil
---Reference: api/entity.md:508
---@param pawn Dylanhook.entity
---@return number|nil
---@return number|nil
---@return number|nil
---@return number|nil
function player.bounding_box(pawn) end

---player.eye_position(pawn: entity) -> vec3 | nil
---Reference: api/entity.md:359
---@param pawn Dylanhook.entity
---@return Dylanhook.vec3|nil
function player.eye_position(pawn) end

---player.flags(pawn: entity) -> number | nil
---Reference: api/entity.md:413
---@param pawn Dylanhook.entity
---@return number|nil
function player.flags(pawn) end

---player.flash_duration(pawn: entity) -> number | nil
---Reference: api/entity.md:435
---@param pawn Dylanhook.entity
---@return number|nil
function player.flash_duration(pawn) end

---player.health(pawn: entity) -> integer | nil
---Reference: api/entity.md:295
---@param pawn Dylanhook.entity
---@return integer|nil
function player.health(pawn) end

---player.hitbox_capsule(pawn: entity, hitbox_id: integer) -> table | nil
---Reference: api/pose.md:64
---@param pawn Dylanhook.entity
---@param hitbox_id integer
---@return table|nil
function player.hitbox_capsule(pawn, hitbox_id) end

---player.hitbox_position(pawn: entity, hitbox_id: integer) -> vec3 | nil
---Reference: api/pose.md:54
---@param pawn Dylanhook.entity
---@param hitbox_id integer
---@return Dylanhook.vec3|nil
function player.hitbox_position(pawn, hitbox_id) end

---player.info(controller: entity) -> table | nil
---Reference: api/entity.md:599
---@param controller Dylanhook.entity
---@return table|nil
function player.info(controller) end

---player.is_alive(pawn: entity) -> boolean | nil
---Reference: api/entity.md:325
---@param pawn Dylanhook.entity
---@return boolean|nil
function player.is_alive(pawn) end

---player.is_local(value: entity) -> boolean | nil
---Reference: api/entity.md:345
---@param value Dylanhook.entity
---@return boolean|nil
function player.is_local(value) end

---player.is_scoped(pawn: entity) -> boolean | nil
---Reference: api/entity.md:426
---@param pawn Dylanhook.entity
---@return boolean|nil
function player.is_scoped(pawn) end

---player.name(pawn: entity) -> string | nil
---Reference: api/entity.md:335
---@param pawn Dylanhook.entity
---@return string|nil
function player.name(pawn) end

---player.observing(controller: entity) -> (target: entity | nil, mode: integer) | nil
---Reference: api/entity.md:533
---@param controller Dylanhook.entity
---@return Dylanhook.entity|nil|nil
---@return integer|nil
function player.observing(controller) end

---player.origin(pawn: entity) -> vec3 | nil
---Reference: api/entity.md:378
---@param pawn Dylanhook.entity
---@return Dylanhook.vec3|nil
function player.origin(pawn) end

---player.pose(pawn: entity) -> table | nil
---Reference: api/pose.md:9
---@param pawn Dylanhook.entity
---@return table|nil
function player.pose(pawn) end

---player.preferences(controller: entity) -> player_preferences | nil, string | nil
---Reference: api/entity.md:703
---@param controller Dylanhook.entity
---@return Dylanhook.player_preferences|nil
---@return string|nil
function player.preferences(controller) end

---player.relation(pawn: entity) -> string | nil
---Reference: api/entity.md:668
---@param pawn Dylanhook.entity
---@return string|nil
function player.relation(pawn) end

---player.spectators(target: entity) -> table | nil
---Reference: api/entity.md:547
---@param target Dylanhook.entity
---@return table|nil
function player.spectators(target) end

---player.steam_id(pawn: entity) -> string | nil
---Reference: api/entity.md:315
---@param pawn Dylanhook.entity
---@return string|nil
function player.steam_id(pawn) end

---player.team(pawn: entity) -> integer | nil
---Reference: api/entity.md:305
---@param pawn Dylanhook.entity
---@return integer|nil
function player.team(pawn) end

---player.velocity(pawn: entity) -> vec3 | nil
---Reference: api/entity.md:400
---@param pawn Dylanhook.entity
---@return Dylanhook.vec3|nil
function player.velocity(pawn) end

---player.visible(pawn: entity) -> boolean | nil
---Reference: api/entity.md:494
---@param pawn Dylanhook.entity
---@return boolean|nil
function player.visible(pawn) end

---player.weapon_info(pawn: entity) -> table | nil
---Reference: api/entity.md:445
---@param pawn Dylanhook.entity
---@return table|nil
function player.weapon_info(pawn) end

---print(...: any) -> true | (false, reason: string)
---Reference: api/console.md:53
---@param ... any
---@return true|false
---@return nil|string
function print(...) end

---render.arc(radius: number, start_degrees: number, sweep_degrees: number, options: path_options? = nil) -> path
---Reference: api/render.md:240
---@param radius number
---@param start_degrees number
---@param sweep_degrees number
---@param options? Dylanhook.path_options|nil
---@return Dylanhook.path
function render.arc(radius, start_degrees, sweep_degrees, options) end

---render.camera() -> table | nil
---Reference: api/render.md:903
---@return table|nil
function render.camera() end

---render.circle(x: number, y: number, radius: number, tint: color, segments: integer = 48)
---Reference: api/render.md:78
---@param x number
---@param y number
---@param radius number
---@param tint Dylanhook.color
---@param segments? integer
function render.circle(x, y, radius, tint, segments) end

---render.circle_outline(x: number, y: number, radius: number, tint: color, thickness: number = 1, segments: integer = 48)
---Reference: api/render.md:86
---@param x number
---@param y number
---@param radius number
---@param tint Dylanhook.color
---@param thickness? number
---@param segments? integer
function render.circle_outline(x, y, radius, tint, thickness, segments) end

---render.clip(x: number, y: number, width: number, height: number, callback: function())
---Reference: api/render.md:110
---@param x number
---@param y number
---@param width number
---@param height number
---@param callback fun()
function render.clip(x, y, width, height, callback) end

---render.device_size() -> width: integer, height: integer
---Reference: api/render.md:877
---@return integer
---@return integer
function render.device_size() end

---render.dpi_scale() -> number
---Reference: api/render.md:885
---@return number
function render.dpi_scale() end

---render.draw_game_icon(name: string, x: number, y: number, height: number, tint: color, source: string = "equipment_svg") -> number | nil
---Reference: api/render.md:624
---@param name string
---@param x number
---@param y number
---@param height number
---@param tint Dylanhook.color
---@param source? string
---@return number|nil
function render.draw_game_icon(name, x, y, height, tint, source) end

---render.font(name: string) -> font | nil
---Reference: api/render.md:325
---@param name string
---@return Dylanhook.font|nil
function render.font(name) end

---render.game_icon(name: string, source: string = "equipment_svg") -> image_request | nil
---Reference: api/render.md:598
---@param name string
---@param source? string
---@return Dylanhook.image_request|nil
function render.game_icon(name, source) end

---render.game_resource(name: string) -> image_request | nil
---Reference: api/render.md:655
---@param name string
---@return Dylanhook.image_request|nil
function render.game_resource(name) end

---render.gradient(x: number, y: number, width: number, height: number, top: color, bottom: color)
---Reference: api/render.md:102
---@param x number
---@param y number
---@param width number
---@param height number
---@param top Dylanhook.color
---@param bottom Dylanhook.color
function render.gradient(x, y, width, height, top, bottom) end

---render.gradient_corners(x: number, y: number, width: number, height: number, top_left: color, top_right: color, bottom_left: color, bottom_right: color)
---Reference: api/render.md:133
---@param x number
---@param y number
---@param width number
---@param height number
---@param top_left Dylanhook.color
---@param top_right Dylanhook.color
---@param bottom_left Dylanhook.color
---@param bottom_right Dylanhook.color
function render.gradient_corners(x, y, width, height, top_left, top_right, bottom_left, bottom_right) end

---render.image(texture: texture, x: number, y: number, width: number, height: number, tint: color? = nil) -> true | nil
---Reference: api/render.md:840
---@param texture Dylanhook.texture
---@param x number
---@param y number
---@param width number
---@param height number
---@param tint? Dylanhook.color|nil
---@return true|nil
function render.image(texture, x, y, width, height, tint) end

---render.image(texture: texture, x: number, y: number, width: number, height: number, tint: color?, source_x: number, source_y: number, source_width: number, source_height: number) -> true | nil
---Reference: api/render.md:841
---@param texture Dylanhook.texture
---@param x number
---@param y number
---@param width number
---@param height number
---@param tint? Dylanhook.color|nil
---@param source_x number
---@param source_y number
---@param source_width number
---@param source_height number
---@return true|nil
function render.image(texture, x, y, width, height, tint, source_x, source_y, source_width, source_height) end

---render.layer(callback: function)
---Reference: api/render.md:163
---@param callback function
function render.layer(callback) end

---render.layout_text(text: string, font: font, width: number, options: text_layout_options? = nil) -> text_layout
---Reference: api/render.md:424
---@param text string
---@param font Dylanhook.font
---@param width number
---@param options? Dylanhook.text_layout_options|nil
---@return Dylanhook.text_layout
function render.layout_text(text, font, width, options) end

---render.line(x1: number, y1: number, x2: number, y2: number, tint: color, thickness: number = 1)
---Reference: api/render.md:70
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param tint Dylanhook.color
---@param thickness? number
function render.line(x1, y1, x2, y2, tint, thickness) end

---render.load_font(family: string, size: number, weight: string | integer = "normal", options: font_options? = nil) -> font | nil
---Reference: api/render.md:348
---@param family string
---@param size number
---@param weight? string|integer
---@param options? Dylanhook.font_options|nil
---@return Dylanhook.font|nil
function render.load_font(family, size, weight, options) end

---render.load_font_file(name: string, size: number, weight: string | integer = "normal", options: font_options? = nil) -> font | nil
---Reference: api/render.md:404
---@param name string
---@param size number
---@param weight? string|integer
---@param options? Dylanhook.font_options|nil
---@return Dylanhook.font|nil
function render.load_font_file(name, size, weight, options) end

---render.load_image(bytes: string, format: string) -> texture | nil
---Reference: api/render.md:564
---@param bytes string
---@param format string
---@return Dylanhook.texture|nil
function render.load_image(bytes, format) end

---render.load_rgba(bytes: string, width: integer, height: integer) -> texture | nil
---Reference: api/render.md:768
---@param bytes string
---@param width integer
---@param height integer
---@return Dylanhook.texture|nil
function render.load_rgba(bytes, width, height) end

---render.measure_game_icon(name: string, height: number, source: string = "equipment_svg") -> number | nil
---Reference: api/render.md:645
---@param name string
---@param height number
---@param source? string
---@return number|nil
function render.measure_game_icon(name, height, source) end

---render.measure_text(text: string, font: font? = nil) -> (width: number, line_height: number) | nil
---Reference: api/render.md:299
---@param text string
---@param font? Dylanhook.font|nil
---@return number|nil
---@return number|nil
function render.measure_text(text, font) end

---render.opacity(amount: number, callback: function)
---Reference: api/render.md:146
---@param amount number
---@param callback function
function render.opacity(amount, callback) end

---render.path(commands: path_command[], options: path_options? = nil) -> path
---Reference: api/render.md:178
---@param commands (Dylanhook.path_command)[]
---@param options? Dylanhook.path_options|nil
---@return Dylanhook.path
function render.path(commands, options) end

---render.polygon(points: vec2[], options: path_options? = nil) -> path
---Reference: api/render.md:238
---@param points (Dylanhook.vec2)[]
---@param options? Dylanhook.path_options|nil
---@return Dylanhook.path
function render.polygon(points, options) end

---render.polyline(points: vec2[], options: path_options? = nil) -> path
---Reference: api/render.md:239
---@param points (Dylanhook.vec2)[]
---@param options? Dylanhook.path_options|nil
---@return Dylanhook.path
function render.polyline(points, options) end

---render.prepare_image(bytes: string, format: string) -> image_request | nil
---Reference: api/render.md:674
---@param bytes string
---@param format string
---@return Dylanhook.image_request|nil
function render.prepare_image(bytes, format) end

---render.rect(x: number, y: number, width: number, height: number, tint: color)
---Reference: api/render.md:34
---@param x number
---@param y number
---@param width number
---@param height number
---@param tint Dylanhook.color
function render.rect(x, y, width, height, tint) end

---render.rect_outline(x: number, y: number, width: number, height: number, tint: color, thickness: number = 1)
---Reference: api/render.md:42
---@param x number
---@param y number
---@param width number
---@param height number
---@param tint Dylanhook.color
---@param thickness? number
function render.rect_outline(x, y, width, height, tint, thickness) end

---render.rounded_outline(width: number, height: number, radius: number, options: path_options? = nil) -> path
---Reference: api/render.md:241
---@param width number
---@param height number
---@param radius number
---@param options? Dylanhook.path_options|nil
---@return Dylanhook.path
function render.rounded_outline(width, height, radius, options) end

---render.rounded_rect(x: number, y: number, width: number, height: number, radius: number, tint: color, corner_segments: integer = 12)
---Reference: api/render.md:50
---@param x number
---@param y number
---@param width number
---@param height number
---@param radius number
---@param tint Dylanhook.color
---@param corner_segments? integer
function render.rounded_rect(x, y, width, height, radius, tint, corner_segments) end

---render.rounded_rect_outline(x: number, y: number, width: number, height: number, radius: number, tint: color, thickness: number = 1, corner_segments: integer = 12)
---Reference: api/render.md:58
---@param x number
---@param y number
---@param width number
---@param height number
---@param radius number
---@param tint Dylanhook.color
---@param thickness? number
---@param corner_segments? integer
function render.rounded_rect_outline(x, y, width, height, radius, tint, thickness, corner_segments) end

---render.screen_size() -> width: integer, height: integer
---Reference: api/render.md:869
---@return integer
---@return integer
function render.screen_size() end

---render.text(x: number, y: number, text: string, tint: color, font: font? = nil)
---Reference: api/render.md:287
---@param x number
---@param y number
---@param text string
---@param tint Dylanhook.color
---@param font? Dylanhook.font|nil
function render.text(x, y, text, tint, font) end

---render.transform(options: transform_options, callback: function())
---Reference: api/render.md:800
---@param options Dylanhook.transform_options
---@param callback fun()
function render.transform(options, callback) end

---render.triangle(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, tint: color)
---Reference: api/render.md:94
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@param tint Dylanhook.color
function render.triangle(x1, y1, x2, y2, x3, y3, tint) end

---render.world_to_screen(position: vec3) -> vec2 | nil
---Reference: api/render.md:893
---@param position Dylanhook.vec3
---@return Dylanhook.vec2|nil
function render.world_to_screen(position) end

---schema.field(module: string, class: string, path: string) -> schema_field
---Reference: api/schema.md:12
---@param module string
---@param class string
---@param path string
---@return Dylanhook.schema_field
function schema.field(module, class, path) end

---schema.fields(module: string, class: string, cursor: integer = 0) -> table | nil
---Reference: api/schema.md:291
---@param module string
---@param class string
---@param cursor? integer
---@return table|nil
function schema.fields(module, class, cursor) end

---script.budget() -> execution_budget
---Reference: api/script.md:92
---@return Dylanhook.execution_budget
function script.budget() end

---script.info() -> script_info
---Reference: api/script.md:9
---@return Dylanhook.script_info
function script.info() end

---script.list() -> script_entry[]
---Reference: api/script.md:36
---@return (Dylanhook.script_entry)[]
function script.list() end

---script.reload() -> true | nil
---Reference: api/script.md:55
---@return true|nil
function script.reload() end

---script.stats() -> execution_statistics
---Reference: api/script.md:130
---@return Dylanhook.execution_statistics
function script.stats() end

---script.unload() -> true | nil
---Reference: api/script.md:69
---@return true|nil
function script.unload() end

---sound.load_file(filename: string | number) -> sound_clip | nil
---Reference: api/sound.md:8
---@param filename string|number
---@return Dylanhook.sound_clip|nil
function sound.load_file(filename) end

---sound.play_game(path: string | number, gain: number) -> true
---Reference: api/sound.md:77
---@param path string|number
---@param gain number
---@return true
function sound.play_game(path, gain) end

---system.date(format: string = "%H:%M:%S", timestamp: integer? = nil,             timezone: string = "local") -> string | table | nil
---Reference: api/system.md:19
---@param format? string
---@param timestamp? integer|nil
---@param timezone? string
---@return string|table|nil
function system.date(format, timestamp, timezone) end

---system.time() -> integer
---Reference: api/system.md:10
---@return integer
function system.time() end

---timer.after(seconds: number, callback: function()) -> subscription
---Reference: events.md:667
---@param seconds number
---@param callback fun()
---@return Dylanhook.subscription
function timer.after(seconds, callback) end

---timer.every(seconds: number, callback: function()) -> subscription
---Reference: events.md:683
---@param seconds number
---@param callback fun()
---@return Dylanhook.subscription
function timer.every(seconds, callback) end

---trace.bullet(from: vec3, to: vec3, options: table | nil = nil) -> table | nil
---Reference: api/trace.md:171
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param options? table|nil
---@return table|nil
function trace.bullet(from, to, options) end

---trace.hull(from: vec3, to: vec3, mins: vec3, maxs: vec3, options: table | nil = nil) -> table | nil
---Reference: api/trace.md:150
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param mins Dylanhook.vec3
---@param maxs Dylanhook.vec3
---@param options? table|nil
---@return table|nil
function trace.hull(from, to, mins, maxs, options) end

---trace.line(from: vec3, to: vec3, options: table | nil = nil) -> table | nil
---Reference: api/trace.md:61
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param options? table|nil
---@return table|nil
function trace.line(from, to, options) end

---trace.request(kind: string, from: vec3, to: vec3, options: table | nil = nil) -> trace_request | nil
---Reference: api/trace.md:301
---@param kind string
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param options? table|nil
---@return Dylanhook.trace_request|nil
function trace.request(kind, from, to, options) end

---trace.scale_damage(target: entity, damage: number, hitgroup: integer, options: table | nil = nil) -> number | nil
---Reference: api/trace.md:237
---@param target Dylanhook.entity
---@param damage number
---@param hitgroup integer
---@param options? table|nil
---@return number|nil
function trace.scale_damage(target, damage, hitgroup, options) end

---trace.smoke(from: vec3, to: vec3) -> boolean | nil
---Reference: api/trace.md:111
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@return boolean|nil
function trace.smoke(from, to) end

---trace.smoke_density(from: vec3, to: vec3) -> number | nil
---Reference: api/trace.md:135
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@return number|nil
function trace.smoke_density(from, to) end

---trace.sphere(from: vec3, to: vec3, radius: number, options: table | nil = nil) -> table | nil
---Reference: api/trace.md:161
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param radius number
---@param options? table|nil
---@return table|nil
function trace.sphere(from, to, radius, options) end

---trace.surface_probe(from: vec3, to: vec3) -> table | nil
---Reference: api/trace.md:275
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@return table|nil
function trace.surface_probe(from, to) end

---trace.visible(from: vec3, to: vec3, options: table | nil = nil) -> boolean | nil
---Reference: api/trace.md:51
---@param from Dylanhook.vec3
---@param to Dylanhook.vec3
---@param options? table|nil
---@return boolean|nil
function trace.visible(from, to, options) end

---vec2(x: number, y: number) -> vec2
---Reference: types/vec2.md:10
---@param x number
---@param y number
---@return Dylanhook.vec2
function vec2(x, y) end

---vec3(x: number, y: number, z: number = 0) -> vec3
---Reference: types/vec3.md:10
---@param x number
---@param y number
---@param z? number
---@return Dylanhook.vec3
function vec3(x, y, z) end

---weapon.active() -> table | nil
---Reference: api/weapon.md:6
---@return table|nil
function weapon.active() end

---websocket.connect(options: websocket_options) -> websocket | (nil, error: string, os_error: integer)
---Reference: api/websocket.md:11
---@param options Dylanhook.websocket_options
---@return Dylanhook.websocket|nil
---@return nil|string
---@return nil|integer
function websocket.connect(options) end

---why.last() -> string | nil
---Reference: api/why.md:8
---@return string|nil
function why.last() end

menu.lua = {}
---@type Dylanhook.menu_container
menu.lua.a = {}
---@type Dylanhook.menu_container
menu.lua.b = {}
menu.misc = {}
---@type Dylanhook.menu_container
menu.misc.movement = {}
---@type Dylanhook.menu_container
menu.misc.other = {}
---@type Dylanhook.menu_container
menu.misc.settings = {}
menu.players = {}
---@type Dylanhook.menu_container
menu.players.adjustments = {}
menu.rage = {}
---@type Dylanhook.menu_container
menu.rage.anti_aim = {}
menu.skins = {}
---@type Dylanhook.menu_container
menu.skins.loadout = {}
menu.visuals = {}
---@type Dylanhook.menu_container
menu.visuals.view = {}
---@type Dylanhook.menu_container
menu.visuals.world = {}
menu.legit = {}
menu.legit.aimbot = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.all = {}
menu.legit.other = {}
---@type Dylanhook.menu_container
menu.legit.other.all = {}
menu.rage.aimbot = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.all = {}
menu.skins.options = {}
---@type Dylanhook.menu_container
menu.skins.options.all = {}
---@type Dylanhook.menu_container
menu.skins.options.charm = {}
---@type Dylanhook.menu_container
menu.skins.options.finish = {}
---@type Dylanhook.menu_container
menu.skins.options.sticker = {}
menu.visuals.player_esp = {}
---@type Dylanhook.menu_container
menu.visuals.player_esp.all = {}
---@type Dylanhook.menu_container
menu.visuals.player_esp.enemy = {}
---@type Dylanhook.menu_container
menu.visuals.player_esp["local"] = {}
---@type Dylanhook.menu_container
menu.visuals.player_esp.team = {}
menu.legit.aimbot.weapons = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.general = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.lmg = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.pistol_heavy = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.pistol_light = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.pistol_revolver = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.rifle_regular = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.rifle_scoped = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.shotgun = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.smg = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.sniper_auto = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.sniper_awp = {}
---@type Dylanhook.menu_container
menu.legit.aimbot.weapons.sniper_scout = {}
menu.legit.other.main = {}
---@type Dylanhook.menu_container
menu.legit.other.main.all = {}
menu.legit.other.trigger = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.all = {}
menu.rage.aimbot.weapons = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.general = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.lmg = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.pistol_heavy = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.pistol_light = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.pistol_revolver = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.rifle_regular = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.rifle_scoped = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.shotgun = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.smg = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.sniper_auto = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.sniper_awp = {}
---@type Dylanhook.menu_container
menu.rage.aimbot.weapons.sniper_scout = {}
menu.legit.other.main.weapons = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.general = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.lmg = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.pistol_heavy = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.pistol_light = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.pistol_revolver = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.rifle_regular = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.rifle_scoped = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.shotgun = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.smg = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.sniper_auto = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.sniper_awp = {}
---@type Dylanhook.menu_container
menu.legit.other.main.weapons.sniper_scout = {}
menu.legit.other.trigger.weapons = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.general = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.lmg = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.pistol_heavy = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.pistol_light = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.pistol_revolver = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.rifle_regular = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.rifle_scoped = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.shotgun = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.smg = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.sniper_auto = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.sniper_awp = {}
---@type Dylanhook.menu_container
menu.legit.other.trigger.weapons.sniper_scout = {}

---@class Dylanhook.key_codes
---@field mouse1 integer
---@field mouse2 integer
---@field mouse3 integer
---@field mouse4 integer
---@field mouse5 integer
---@field backspace integer
---@field tab integer
---@field enter integer
---@field shift integer
---@field control integer
---@field alt integer
---@field escape integer
---@field space integer
---@field left integer
---@field up integer
---@field right integer
---@field down integer
---@field insert integer
---@field delete integer
---@field home integer
---@field end integer
---@field page_up integer
---@field page_down integer
---@field f1 integer
---@field f2 integer
---@field f3 integer
---@field f4 integer
---@field f5 integer
---@field f6 integer
---@field f7 integer
---@field f8 integer
---@field f9 integer
---@field f10 integer
---@field f11 integer
---@field f12 integer
key = {}

---@type Dylanhook.json_null
json.null = _json_null
