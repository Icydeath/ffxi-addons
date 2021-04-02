require("lists")
require("tables")
texts = require('texts')

local database = require('database')

local action_binder = {}

local kebab_casify = function(str)
	if not str and str ~= '' and not tonumber(str) then return '' end
    return str:lower():gsub('/', '\n'):gsub(':', ''):gsub('%p', ''):gsub(' ', '-'):gsub('\n', '/')
end

local icon_pack = nil

local get_icon_pathbase = function()
    return 'icons/iconpacks/' .. icon_pack
end

local maybe_get_custom_icon = function(category, action_name)
    local pathbase = get_icon_pathbase()
    local icon_path = pathbase .. '/' .. kebab_casify(category) .. '/' ..  kebab_casify(action_name) .. '.png'
    local icon_file = file.new('images/' .. icon_path)
    if (icon_file:exists()) then
        return icon_path
    else
        return nil
    end
end

local sw_zones = require('sw_zones')

local states = {
    ['HIDDEN'] = 0,
    ['SELECT_ACTION_TYPE'] = 1,
    ['SELECT_ACTION'] = 2,
    ['SELECT_ACTION_TARGET'] = 3,
    ['SELECT_PLAYER_BINDING'] = 4,
    ['SELECT_BUTTON_ASSIGNMENT'] = 5,
    ['CONFIRM_BUTTON_ASSIGNMENT'] = 6,
    ['SHOW_CREDITS'] = 7
}

local action_types = {
    ['DELETE'] = 0,
    ['JOB_ABILITY'] = 1,
    ['WEAPONSKILL'] = 2,
    ['PET_COMMAND'] = 3,
    ['WHITE_MAGIC'] = 4,
    ['BLACK_MAGIC'] = 5,
    ['SONG'] = 6,
    ['READY'] = 7,
    ['NINJUTSU'] = 8,
    ['SUMMON'] = 9,
    ['BP_RAGE'] = 10,
    ['BP_WARD'] = 11,
    ['BLUE_MAGIC'] = 12,
    ['PHANTOM_ROLL'] = 13,
    ['QUICK_DRAW'] = 14,
    ['STRATAGEMS'] = 15,
    ['DANCES'] = 16,
    ['RUNE_ENCHANTMENT'] = 17,
    ['WARD'] = 18,
    ['EFFUSION'] = 19,
    ['GEOMANCY'] = 20,
    ['TRUST'] = 21,
    ['MOUNT'] = 22,
    ['USABLE_ITEM'] = 23,
    ['TRADABLE_ITEM'] = 24,
    ['RANGED_ATTACK'] = 25,
    ['ATTACK'] = 26,
    ['ASSIST'] = 27,
    ['MAP'] = 28,
    ['LAST_SYNTH'] = 29,
    ['SWITCH_TARGET'] = 30,
    ['SHOW_CREDITS'] = 31,
	['EXECUTE_COMMAND'] = 32,
	['SUPERWARP'] = 33,
}

local prefix_lookup = {
    [action_types.DELETE] = '',
    [action_types.JOB_ABILITY] = 'ja',
    [action_types.WEAPONSKILL] = 'ws',
    [action_types.PET_COMMAND] = 'pet',
    [action_types.WHITE_MAGIC] = 'ma',
    [action_types.BLACK_MAGIC] = 'ma',
    [action_types.SONG] = 'ma',
    [action_types.READY] = 'pet',
    [action_types.NINJUTSU] = 'ma',
    [action_types.SUMMON] = 'ma',
    [action_types.BP_RAGE] = 'pet',
    [action_types.BP_WARD] = 'pet',
    [action_types.BLUE_MAGIC] = 'ma',
    [action_types.PHANTOM_ROLL] = 'ja',
    [action_types.QUICK_DRAW] = 'ja',
    [action_types.STRATAGEMS] = 'ja',
    [action_types.DANCES] = 'ja',
    [action_types.RUNE_ENCHANTMENT] = 'ja',
    [action_types.WARD] = 'ja',
    [action_types.EFFUSION] = 'ja',
    [action_types.GEOMANCY] = 'ma',
    [action_types.TRUST] = 'ma',
    [action_types.MOUNT] = 'mount',
    [action_types.USABLE_ITEM] = 'item',
    [action_types.TRADABLE_ITEM] = 'item',
    [action_types.RANGED_ATTACK] = 'ct',
    [action_types.ATTACK] = 'a',
    [action_types.ASSIST] = 'assist',
    [action_types.MAP] = 'map',
    [action_types.LAST_SYNTH] = 'ct',
    [action_types.SWITCH_TARGET] = 'ta',
	[action_types.EXECUTE_COMMAND] = 'ex',
	[action_types.SUPERWARP] = 'ex',
}

local action_targets = {
    ['NONE'] = '',
    ['SELF'] = 'me',
    ['CURRENT_TARGET'] = 't',
    ['BATTLE_TARGET'] = 'bt',
    ['SELECT_TARGET'] = 'st',
    ['SELECT_PLAYER'] = 'stpc',
    ['SELECT_NPC'] = 'stnpc',
    ['SELECT_PARTY'] = 'stpt',
    ['SELECT_ALLIANCE'] = 'stal'
}

local SPELL_TYPE_LOOKUP = {
    ['BardSong'] = 'songs',
    ['BlackMagic'] = 'black magic',
    ['BlueMagic'] = 'blue magic',
    ['WhiteMagic'] = 'white magic',
    ['SummonerPact'] = 'summoning magic',
	['Geomancy'] = 'geomancy',
}

local DRG_PET_ABILITIES = S{
	'Flame Breath',
	'Frost Breath',
	'Sand Breath',
	'Gust Breath',
	'Hydro Breath',
	'Lightning Breath',
	'Healing Breath',
	'Healing Breath II',
	'Healing Breath III',
	'Healing Breath IV',
	'Remove Poison',
	'Remove Blindness',
	'Remove Paralysis',
	'Remove Curse',
	'Remove Disease',
	'Super Climb'
}

function action_binder:setup(buttonmapping, save_binding_func, delete_binding_func, theme_options, base_x, base_y, max_width, max_height)
    self.button_layout = buttonmapping.button_layout
    self.confirm_button = buttonmapping.confirm_button
    self.cancel_button = buttonmapping.cancel_button
    self.mainmenu_button = buttonmapping.mainmenu_button
    self.activewindow_button = buttonmapping.activewindow_button
    self.save_binding = save_binding_func
    self.delete_binding = delete_binding_func
    self.is_hidden = true
    self.selector = require('ui/selectablelist')
    self.selector:setup(theme_options, base_x + 50, base_y + 75, max_width - 100, max_height - 175)
    self.theme_options = theme_options
    self.title = self:create_text('Select Action Type', base_x + 50, base_y + 30)
    self.title:size(18)
    self.title:hide()
    self.base_x = base_x or 150
    self.base_y = base_y or 150
    self.width =  max_width or (windower.get_windower_settings().ui_x_res - 300)
    self.height = max_height or (windower.get_windower_settings().ui_y_res - 300)
    self.state = states.HIDDEN
    self.action_type = nil
    self.action_name = nil
    self.target_type = nil
    self.action_target = nil
    self.active_crossbar = nil
    self.hotkey = nil
    self.selection_states = {}
    self.images = L{}
    self.hints = L{}
    self.dpad_left_pressed = false
    self.dpad_right_pressed = false
    self.dpad_down_pressed = false
    self.dpad_up_pressed = false
    self.button_a_pressed = false
    self.button_b_pressed = false
    self.button_x_pressed = false
    self.button_y_pressed = false
    self.trigger_left_pressed = false
    self.trigger_right_pressed = false

    icon_pack = theme_options.iconpack

    windower.prim.create('dialog_bg')
    windower.prim.set_color('dialog_bg', 150, 0, 0, 0)
    windower.prim.set_position('dialog_bg', self.base_x, self.base_y)
    windower.prim.set_size('dialog_bg', self.width, self.height)
    windower.prim.set_visibility('dialog_bg', false)

    windower.prim.create('button_entry_bg')
    windower.prim.set_color('button_entry_bg', 150, 0, 0, 0)
    windower.prim.set_position('button_entry_bg', self.base_x + 150, self.base_y + 150)
    windower.prim.set_size('button_entry_bg', self.width - 300, self.height - 300)
    windower.prim.set_visibility('button_entry_bg', false)
end

function action_binder:reset_state()
    self.state = states.HIDDEN
    self.action_type = nil
    self.action_name = nil
    self.target_type = nil
    self.action_target = nil
    self.active_crossbar = nil
    self.hotkey = nil
    self.selection_states = {}
    self.selector:hide()
    self.images = L{}
    self.hints = L{}
end

function action_binder:reset_gamepad()
    self:reset_gamepad_dpad()
    self:reset_gamepad_face_buttons()
    self:reset_gamepad_triggers()
end

function action_binder:reset_gamepad_dpad()
    self.dpad_left_pressed = false
    self.dpad_right_pressed = false
    self.dpad_down_pressed = false
    self.dpad_up_pressed = false
end

function action_binder:reset_gamepad_face_buttons()
    self.button_a_pressed = false
    self.button_b_pressed = false
    self.button_x_pressed = false
    self.button_y_pressed = false
end

function action_binder:reset_gamepad_triggers()
    self.trigger_left_pressed = false
    self.trigger_right_pressed = false
end

function action_binder:create_text(caption, x, y)
    local text_field = texts.new({flags = {draggable = false}})
    text_field:bg_alpha(0)
    text_field:bg_visible(false)
    text_field:font(self.theme_options.font)
    text_field:size(self.theme_options.font_size)
    text_field:color(self.theme_options.font_color_red, self.theme_options.font_color_green, self.theme_options.font_color_blue)
    text_field:stroke_transparency(self.theme_options.font_stroke_alpha)
    text_field:stroke_color(self.theme_options.font_stroke_color_red, self.theme_options.font_stroke_color_green, self.theme_options.font_stroke_color_blue)
    text_field:stroke_width(self.theme_options.font_stroke_width)
    text_field:text(caption)
    text_field:pos(x, y)
    text_field:show()
    return text_field
end

function action_binder:update_active_crossbar(left_trigger_just_pressed, right_trigger_just_pressed)
    if (self.trigger_left_pressed and self.trigger_right_pressed) then
        if (self.theme_options.hotbar_number == 4) then
            if (left_trigger_just_pressed) then
                -- R -> L = bar 3
                self.active_crossbar = 3
            elseif (right_trigger_just_pressed) then
                -- L -> R = bar 4
                self.active_crossbar = 4
            end
        else
            self.active_crossbar = 3
        end
    elseif (self.trigger_left_pressed) then
        self.active_crossbar = 1
    elseif (self.trigger_right_pressed) then
        self.active_crossbar = 2
    else
        self.active_crossbar = nil
    end
end

function action_binder:dpad_left(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.dpad_left_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 1
            self:submit_selected_option()
        end
    elseif (pressed) then
        self:decrement_col()
    end
end

function action_binder:dpad_right(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.dpad_right_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 3
            self:submit_selected_option()
        end
    elseif (pressed) then
        self:increment_col()
    end
end

function action_binder:dpad_down(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.dpad_down_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 2
            self:submit_selected_option()
        end
    elseif (pressed) then
        self:increment_row()
    end
end

function action_binder:dpad_up(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.dpad_up_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 4
            self:submit_selected_option()
        end
    elseif (pressed) then
        self:decrement_row()
    end
end

function action_binder:button_a(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.button_a_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 6
            self:submit_selected_option()
        end
    elseif (pressed) then
        if (self.button_layout == 'gamecube' and self.confirm_button == 'a' or
            self.button_layout == 'playstation' and self.confirm_button == 'cross' or
            self.button_layout == 'xbox' and self.confirm_button == 'a' or
            self.button_layout == 'nintendo' and self.confirm_button == 'b') then
            self:submit_selected_option()
        elseif (self.button_layout == 'gamecube' and self.cancel_button == 'a' or
            self.button_layout == 'playstation' and self.cancel_button == 'cross' or
            self.button_layout == 'xbox' and self.cancel_button == 'a' or
            self.button_layout == 'nintendo' and self.cancel_button == 'b') then
            self:go_back()
        end
    end
end

function action_binder:button_b(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.button_b_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 5
            self:submit_selected_option()
        end
    elseif (pressed) then
        if (self.button_layout == 'gamecube' and self.confirm_button == 'b' or
            self.button_layout == 'playstation' and self.confirm_button == 'square' or
            self.button_layout == 'xbox' and self.confirm_button == 'x' or
            self.button_layout == 'nintendo' and self.confirm_button == 'y') then
            self:submit_selected_option()
        elseif (self.button_layout == 'gamecube' and self.cancel_button == 'b' or
            self.button_layout == 'playstation' and self.cancel_button == 'square' or
            self.button_layout == 'xbox' and self.cancel_button == 'x' or
            self.button_layout == 'nintendo' and self.cancel_button == 'y') then
            self:go_back()
        end
    end
end

function action_binder:button_x(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.button_x_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 7
            self:submit_selected_option()
        end
    elseif (pressed) then
        if (self.button_layout == 'gamecube' and self.confirm_button == 'x' or
            self.button_layout == 'playstation' and self.confirm_button == 'circle' or
            self.button_layout == 'xbox' and self.confirm_button == 'b' or
            self.button_layout == 'nintendo' and self.confirm_button == 'a') then
            self:submit_selected_option()
        elseif (self.button_layout == 'gamecube' and self.cancel_button == 'x' or
            self.button_layout == 'playstation' and self.cancel_button == 'circle' or
            self.button_layout == 'xbox' and self.cancel_button == 'b' or
            self.button_layout == 'nintendo' and self.cancel_button == 'a') then
            self:go_back()
        end
    end
end

function action_binder:button_y(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self:reset_gamepad_dpad()
        self:reset_gamepad_face_buttons()
        self.button_y_pressed = pressed
        if (pressed and (self.trigger_left_pressed or self.trigger_right_pressed)) then
            self:show_pressed_buttons()
            self.hotkey = 8
            self:submit_selected_option()
        end
    elseif (pressed) then
        if (self.button_layout == 'gamecube' and self.confirm_button == 'y' or
            self.button_layout == 'playstation' and self.confirm_button == 'triangle' or
            self.button_layout == 'xbox' and self.confirm_button == 'y' or
            self.button_layout == 'nintendo' and self.confirm_button == 'x') then
            self:submit_selected_option()
        elseif (self.button_layout == 'gamecube' and self.cancel_button == 'y' or
            self.button_layout == 'playstation' and self.cancel_button == 'triangle' or
            self.button_layout == 'xbox' and self.cancel_button == 'y' or
            self.button_layout == 'nintendo' and self.cancel_button == 'x') then
            self:go_back()
        end
    end
end

function action_binder:trigger_left(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        local just_pressed = pressed and not self.trigger_left_pressed
        self.trigger_left_pressed = pressed
        self:update_active_crossbar(just_pressed, false)
        self:show_pressed_buttons()
    end
end

function action_binder:trigger_right(pressed)
    if (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        local just_pressed = pressed and not self.trigger_right_pressed
        self.trigger_right_pressed = pressed
        self:update_active_crossbar(false, just_pressed)
        self:show_pressed_buttons()
    end
end

function action_binder:increment_row()
    self.selector:increment_row()
end

function action_binder:decrement_row()
    self.selector:decrement_row()
end

function action_binder:increment_col()
    self.selector:increment_col()
end

function action_binder:decrement_col()
    self.selector:decrement_col()
end

function action_binder:submit_selected_option()
    if (self.state == states.SELECT_ACTION_TYPE) then
        self.selection_states[states.SELECT_ACTION_TYPE] = self.selector:export_selection_state()
        self.action_type = self.selector:submit_selected_option().id

        if (self.action_type == action_types.SHOW_CREDITS) then
            self.state = states.SHOW_CREDITS
            self:display_credits()			
        elseif (self.action_type == action_types.DELETE) then
            self.state = states.SELECT_BUTTON_ASSIGNMENT
            self:display_button_assigner()
        elseif (self.action_type == action_types.ASSIST) then
            self.state = states.SELECT_PLAYER_BINDING
            self:display_player_selector(false)
        elseif (self.action_type == action_types.ATTACK or self.action_type == action_types.RANGED_ATTACK) then
            if (self.action_type == action_types.ATTACK) then
                self.action_name = 'Attack'
            elseif (self.action_type == action_types.RANGED_ATTACK) then
                self.action_name = 'Ranged Attack'
            end
            self.state = states.SELECT_ACTION_TARGET
            self.target_type = {['Enemy'] = true}
            self:display_target_selector()
        elseif (self.action_type == action_types.SWITCH_TARGET) then
            self.action_name = 'Switch Target'
            self.action_target = 'stnpc'
            self.state = states.SELECT_BUTTON_ASSIGNMENT
            self:display_button_assigner()
        elseif (self.action_type == action_types.MAP or self.action_type == action_types.LAST_SYNTH) then
            if (self.action_type == action_types.LAST_SYNTH) then
                self.action_name = 'Last Synth'
            elseif (self.action_type == action_types.MAP) then
                self.action_name = 'View Map'
            end
            self.action_target = nil
            self.state = states.SELECT_BUTTON_ASSIGNMENT
            self:display_button_assigner()
        else
            self.state = states.SELECT_ACTION
            self:display_action_selector()
        end
    elseif (self.state == states.SELECT_PLAYER_BINDING) then
        self.action_name = 'Assist ' .. self.selector:submit_selected_option().text
        self.state = states.SELECT_BUTTON_ASSIGNMENT
        self:display_button_assigner()
    elseif (self.state == states.SELECT_ACTION) then
        self.selection_states[states.SELECT_ACTION] = self.selector:export_selection_state()
        local option = self.selector:submit_selected_option()
        if (option.id == 'PREV') then
            self.selector:decrement_page()
        elseif (option.id == 'NEXT') then
            self.selector:increment_page()
        else
            self.action_name = option.text
            self.target_type = option.data.target_type
            if (self.target_type['Self'] and not (
                    self.target_type['NPC'] or
                    self.target_type['Enemy'] or
                    self.target_type['Party'] or
                    self.target_type['Player'] or
                    self.target_type['Ally'])) then
                self.action_target = action_targets.SELF
                self.state = states.SELECT_BUTTON_ASSIGNMENT
                self:display_button_assigner()
            elseif (self.target_type['None']) then
				if self.action_type == action_types.EXECUTE_COMMAND or self.action_type == action_types.SUPERWARP then
					self.icon = option.icon
				end
                self.action_target = nil
                self.state = states.SELECT_BUTTON_ASSIGNMENT
                self:display_button_assigner()
            else
                self.state = states.SELECT_ACTION_TARGET
                self:display_target_selector()
            end
        end
    elseif (self.state == states.SELECT_ACTION_TARGET) then
        self.selection_states[states.SELECT_ACTION_TARGET] = self.selector:export_selection_state()
        self.action_target = action_targets[self.selector:submit_selected_option().id]
        self.state = states.SELECT_BUTTON_ASSIGNMENT
        self:display_button_assigner()
    elseif (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        self.state = states.CONFIRM_BUTTON_ASSIGNMENT
        self:display_button_confirmer()
    elseif (self.state == states.CONFIRM_BUTTON_ASSIGNMENT) then
        if (self.action_type == action_types.DELETE) then
            self:delete_action()
        else
            self:assign_action()
        end
    end
end

function action_binder:go_back()
    if (self.state == states.SELECT_ACTION_TYPE) then
        self:hide()
        self:reset_state()
        self.selector:reset_state()
    elseif (self.state == states.SHOW_CREDITS) then
        self.state = states.SELECT_ACTION_TYPE
        self.action_type = nil
        self.selector:set_page(self.selection_states[states.SELECT_ACTION_TYPE].page)
        self:display_action_type_selector()
        self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION_TYPE])
        self.selection_states[states.SELECT_ACTION_TYPE] = nil
    elseif (self.state == states.SELECT_ACTION) then
        self.state = states.SELECT_ACTION_TYPE
        self.action_type = nil
        self.selector:set_page(self.selection_states[states.SELECT_ACTION_TYPE].page)
        self:display_action_type_selector()
        self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION_TYPE])
        self.selection_states[states.SELECT_ACTION_TYPE] = nil
    elseif (self.state == states.SELECT_PLAYER_BINDING) then
        self.state = states.SELECT_ACTION_TYPE
        self.action_type = nil
        self.selector:set_page(self.selection_states[states.SELECT_ACTION_TYPE].page)
        self:display_action_type_selector()
        self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION_TYPE])
        self.selection_states[states.SELECT_ACTION_TYPE] = nil
    elseif (self.state == states.SELECT_ACTION_TARGET) then
        if (self.action_type == action_types.ATTACK or self.action_type == action_types.RANGED_ATTACK) then
            self.state = states.SELECT_ACTION_TYPE
            self.action_type = nil
            self.target_type = nil
            self.selector:set_page(self.selection_states[states.SELECT_ACTION_TYPE].page)
            self:display_action_type_selector()
            self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION_TYPE])
            self.selection_states[states.SELECT_ACTION_TYPE] = nil
        else
            self.state = states.SELECT_ACTION
            self.action_name = nil
            self.selector:set_page(self.selection_states[states.SELECT_ACTION].page)
            self:display_action_selector()
            self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION])
            self.selection_states[states.SELECT_ACTION] = nil
        end
    elseif (self.state == states.SELECT_BUTTON_ASSIGNMENT) then
        -- check if we skipped target selection due to "Self" being the only option
        if (self.selection_states[states.SELECT_ACTION_TARGET] == nil) then
            self.state = states.SELECT_ACTION
            self.action_name = nil
            self.action_target = nil
            self.selector:set_page(self.selection_states[states.SELECT_ACTION].page)
            self:display_action_selector()
            self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION])
            self.selection_states[states.SELECT_ACTION] = nil
        else
            self.state = states.SELECT_ACTION_TARGET
            self.action_target = nil
            self.selector:set_page(self.selection_states[states.SELECT_ACTION_TARGET].page)
            self:display_target_selector()
            self.selector:import_selection_state(self.selection_states[states.SELECT_ACTION_TARGET])
            self.selection_states[states.SELECT_ACTION_TARGET] = nil
        end
    elseif (self.state == states.CONFIRM_BUTTON_ASSIGNMENT) then
        self.state = states.SELECT_BUTTON_ASSIGNMENT
        self.active_crossbar = nil
        self.hotkey = nil
        self:reset_gamepad()
        self:display_button_assigner()
    end
end

function action_binder:hide()
    self.is_hidden = true
    windower.prim.set_visibility('dialog_bg', false)
    windower.prim.set_visibility('button_entry_bg', false)
    self.title:hide()
    self.selector:hide()
    for i, image in ipairs(self.images) do
        image:hide()
    end
    for i, hint in ipairs(self.hints) do
        hint:hide()
    end
end

function action_binder:show()
    self.is_hidden = false
    if (self.state == states.HIDDEN) then
        self.state = states.SELECT_ACTION_TYPE
        self:display_action_type_selector()
    end
    windower.prim.set_visibility('dialog_bg', true)
    self.title:show()
    self.selector:show()
end

function action_binder:display_action_type_selector()
    self.title:text('Select Action Type')
    self.title:show()

    local player = windower.ffxi.get_player()
    local main_job = player.main_job
    local sub_job = player.sub_job

    local pet_jobs = {BST = true, SMN = true, DRG = true, PUP = true}
    local white_magic_jobs = {WHM = true, RDM = true, PLD = true, SCH = true, RUN = true}
    local black_magic_jobs = {BLM = true, RDM = true, DRK = true, SCH = true, GEO = true, RUN = true}

    local action_type_list = L{}
    action_type_list:append({id = action_types.DELETE, name = 'Remove a Binding', icon = get_icon_pathbase() .. '/ui/red-x.png'})
    action_type_list:append({id = action_types.JOB_ABILITY, name = 'Job Ability', icon = 'icons/abilities/00001.png', icon_offset = 4})
    action_type_list:append({id = action_types.WEAPONSKILL, name = 'Weaponskill', icon = 'icons/weapons/03.jpg', icon_offset = 4})
    if (pet_jobs[main_job] or pet_jobs[sub_job]) then
        action_type_list:append({id = action_types.PET_COMMAND, name = 'Pet Command', icon = get_icon_pathbase() .. '/mounts/crab.png'})
    end
    if (white_magic_jobs[main_job] or white_magic_jobs[sub_job]) then
        action_type_list:append({id = action_types.WHITE_MAGIC, name = 'White Magic', icon = get_icon_pathbase() .. '/jobs/WHM.png'})
    end
    if (black_magic_jobs[main_job] or black_magic_jobs[sub_job]) then
        action_type_list:append({id = action_types.BLACK_MAGIC, name = 'Black Magic', icon = get_icon_pathbase() .. '/jobs/BLM.png'})
    end
    if (main_job == 'BRD' or sub_job == 'BRD') then
        action_type_list:append({id = action_types.SONG, name = 'Song', icon = get_icon_pathbase() .. '/jobs/BRD.png'})
    end
    if (main_job == 'BST' or sub_job == 'BST') then
        action_type_list:append({id = action_types.READY, name = 'Ready', icon = get_icon_pathbase() .. '/jobs/BST.png'})
    end
    if (main_job == 'NIN' or sub_job == 'NIN') then
        action_type_list:append({id = action_types.NINJUTSU, name = 'Ninjutsu', icon = get_icon_pathbase() .. '/jobs/NIN.png'})
    end
    if (main_job == 'SMN' or sub_job == 'SMN') then
        action_type_list:append({id = action_types.SUMMON, name = 'Summon', icon = get_icon_pathbase() .. '/jobs/SMN.png'})
        action_type_list:append({id = action_types.BP_RAGE, name = 'Blood Pact: Rage', icon = get_icon_pathbase() .. '/jobs/SMN.png'})
        action_type_list:append({id = action_types.BP_WARD, name = 'Blood Pact: Ward', icon = get_icon_pathbase() .. '/jobs/SMN.png'})
    end
    if (main_job == 'BLU' or sub_job == 'BLU') then
        action_type_list:append({id = action_types.BLUE_MAGIC, name = 'Blue Magic', icon = get_icon_pathbase() .. '/jobs/BLU.png'})
    end
    if (main_job == 'COR' or sub_job == 'COR') then
        action_type_list:append({id = action_types.PHANTOM_ROLL, name = 'Phantom Roll', icon = get_icon_pathbase() .. '/jobs/COR.png'})
        action_type_list:append({id = action_types.QUICK_DRAW, name = 'Quick Draw', icon = get_icon_pathbase() .. '/jobs/COR.png'})
    end
    if (main_job == 'SCH' or sub_job == 'SCH') then
        action_type_list:append({id = action_types.STRATAGEMS, name = 'Stratagem', icon = get_icon_pathbase() .. '/jobs/SCH.png'})
    end
    if (main_job == 'DNC' or sub_job == 'DNC') then
        action_type_list:append({id = action_types.DANCES, name = 'Dance', icon = get_icon_pathbase() .. '/jobs/DNC.png'})
    end
    if (main_job == 'RUN' or sub_job == 'RUN') then
        action_type_list:append({id = action_types.RUNE_ENCHANTMENT, name = 'Rune Enchantment', icon = get_icon_pathbase() .. '/jobs/RUN.png'})
        action_type_list:append({id = action_types.WARD, name = 'Ward', icon = get_icon_pathbase() .. '/jobs/RUN.png'})
        action_type_list:append({id = action_types.EFFUSION, name = 'Effusion', icon = get_icon_pathbase() .. '/jobs/RUN.png'})
    end
    if (main_job == 'GEO' or sub_job == 'GEO') then
        action_type_list:append({id = action_types.GEOMANCY, name = 'Geomancy', icon = get_icon_pathbase() .. '/jobs/GEO.png'})
    end
    action_type_list:append({id = action_types.TRUST, name = 'Call Trust', icon = get_icon_pathbase() .. '/trust/yoran-oran.png'})
    action_type_list:append({id = action_types.MOUNT, name = 'Call Mount', icon = get_icon_pathbase() .. '/mount.png'})
    action_type_list:append({id = action_types.USABLE_ITEM, name = 'Use Item', icon = get_icon_pathbase() .. '/usable-item.png'})
    action_type_list:append({id = action_types.TRADABLE_ITEM, name = 'Trade Item', icon = get_icon_pathbase() .. '/item.png'})
    action_type_list:append({id = action_types.RANGED_ATTACK, name = 'Ranged Attack', icon = get_icon_pathbase() .. '/ranged.png'})
    action_type_list:append({id = action_types.ATTACK, name = 'Attack', icon = get_icon_pathbase() .. '/attack.png'})
    action_type_list:append({id = action_types.ASSIST, name = 'Assist', icon = get_icon_pathbase() .. '/assist.png'})
    action_type_list:append({id = action_types.SWITCH_TARGET, name = 'Switch Target', icon = get_icon_pathbase() .. '/targetnpc.png'})
    action_type_list:append({id = action_types.MAP, name = 'View Map', icon = get_icon_pathbase() .. '/map.png'})
    action_type_list:append({id = action_types.LAST_SYNTH, name = 'Repeat Last Synth', icon = get_icon_pathbase() .. '/synth.png'})
	action_type_list:append({id = action_types.EXECUTE_COMMAND, name = 'Execute Command', icon = get_icon_pathbase() .. '/windower4.png'})
	action_type_list:append({id = action_types.SUPERWARP, name = 'Superwarp', icon = 'credit_avatars/akadentk.png'})
    action_type_list:append({id = action_types.SHOW_CREDITS, name = 'XIVCrossbar Credits', icon = 'credit_avatars/xiv.png'})
    self.selector:display_options(action_type_list)

    self:show_control_hints('Confirm', 'Exit')
end

function action_binder:display_action_selector()
    if (self.action_type == action_types.JOB_ABILITY) then
        self:display_ability_selector()
    elseif (self.action_type == action_types.WEAPONSKILL) then
        self:display_weaponskill_selector()
    elseif (self.action_type == action_types.PET_COMMAND) then
        self:display_pet_command_selector()
    elseif (self.action_type == action_types.WHITE_MAGIC) then
        self:display_white_magic_selector()
    elseif (self.action_type == action_types.BLACK_MAGIC) then
        self:display_black_magic_selector()
    elseif (self.action_type == action_types.SONG) then
        self:display_song_selector()
    elseif (self.action_type == action_types.READY) then
        self:display_ready_selector()
    elseif (self.action_type == action_types.NINJUTSU) then
        self:display_ninjutsu_selector()
    elseif (self.action_type == action_types.SUMMON) then
        self:display_summoning_selector()
    elseif (self.action_type == action_types.BP_RAGE) then
        self:display_bp_rage_selector()
    elseif (self.action_type == action_types.BP_WARD) then
        self:display_bp_ward_selector()
    elseif (self.action_type == action_types.BLUE_MAGIC) then
        self:display_blue_magic_selector()
    elseif (self.action_type == action_types.PHANTOM_ROLL) then
        self:display_phantom_roll_selector()
    elseif (self.action_type == action_types.QUICK_DRAW) then
        self:display_quick_draw_selector()
    elseif (self.action_type == action_types.STRATAGEMS) then
        self:display_stratagem_selector()
    elseif (self.action_type == action_types.DANCES) then
        self:display_dance_selector()
    elseif (self.action_type == action_types.RUNE_ENCHANTMENT) then
        self:display_rune_enchantment_selector()
    elseif (self.action_type == action_types.WARD) then
        self:display_ward_selector()
    elseif (self.action_type == action_types.EFFUSION) then
        self:display_effusion_selector()
    elseif (self.action_type == action_types.GEOMANCY) then
        self:display_geomancy_selector()
    elseif (self.action_type == action_types.TRUST) then
        self:display_trust_selector()
    elseif (self.action_type == action_types.MOUNT) then
        self:display_mount_selector()
    elseif (self.action_type == action_types.USABLE_ITEM) then
        self:display_usable_item_selector()
    elseif (self.action_type == action_types.TRADABLE_ITEM) then
        self:display_tradable_item_selector()
    elseif (self.action_type == action_types.RANGED_ATTACK) then
        self:display_tradable_item_selector()
	elseif (self.action_type == action_types.EXECUTE_COMMAND) then
        self:display_execute_command_selector()
	elseif (self.action_type == action_types.SUPERWARP) then
        self:display_superwarp_selector()
    end
end

function action_binder:display_target_selector()
    self.title:text('Select Action Target')
    self.title:show()

    local target_options = L{}

    if (self.target_type['Self']) then
        target_options:append({id = 'SELF', name = 'Self (<me>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end
    if (self.target_type['Party'] or self.target_type['Corpse']) then
        target_options:append({id = 'SELECT_PARTY', name = 'Select Party (<stpt>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end
    if (self.target_type['Ally'] or self.target_type['Corpse']) then
        target_options:append({id = 'SELECT_ALLIANCE', name = 'Select Ally (<stal>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end
    if (self.target_type['Player'] or self.target_type['Corpse']) then
        target_options:append({id = 'SELECT_PLAYER', name = 'Select Player (<stpc>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end
    if (self.target_type['NPC'] or self.target_type['Enemy']) then
        target_options:append({id = 'SELECT_NPC', name = 'Select NPC (<stnpc>)', icon = get_icon_pathbase() .. '/mappoint.png'})
        target_options:append({id = 'CURRENT_TARGET', name = 'Current Target (<t>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end
    if (self.target_type['Enemy']) then
        target_options:append({id = 'SELECT_TARGET', name = 'Select Target (<st>)', icon = get_icon_pathbase() .. '/mappoint.png'})
        target_options:append({id = 'BATTLE_TARGET', name = 'Battle Target (<bt>)', icon = get_icon_pathbase() .. '/mappoint.png'})
    end

    self.selector:display_options(target_options)
end

function action_binder:display_button_assigner()
    self.title:text('Enter Button Combo')
    self.title:show()

    self.selector:hide()

    windower.prim.set_visibility('button_entry_bg', true)

    for i, image in ipairs(self.images) do
        image:hide()
    end
    for i, hint in ipairs(self.hints) do
        hint:hide()
    end

    local caption_x = self.base_x + self.width / 2 - 200
    local caption_y = self.base_y + self.height / 2 - 40
    local caption_text = ''
    if (self.action_type == action_types.DELETE) then
        caption_text = 'Press a button combo to remove its bound action'
    else
        caption_text = 'Press a button combo to bind it to this action'
    end

    local caption = self:create_text(caption_text, caption_x, caption_y)
    caption:size(14)
    self.hints:append(caption)
    self:show_exit_hint()
end

function action_binder:display_button_confirmer()
    self.title:text('Enter Button Combo')
    self.title:show()

    self.selector:hide()

    for i, hint in ipairs(self.hints) do
        hint:hide()
    end

    local caption_x = self.base_x + self.width / 2
    local caption_y = self.base_y + self.height / 2 - 40
    local caption_text = ''
    if (self.action_type == action_types.DELETE) then
        caption_text = 'Delete binding?'
    else
        caption_text = 'Bind ' .. self.action_name .. '?'
    end
    caption_x = caption_x - (caption_text:len() * 5)

    self:confirm_buttons()
    self:show_control_hints('Confirm', 'Go Back')

    local caption = self:create_text(caption_text, caption_x, caption_y)
    caption:size(14)
    self.hints:append(caption)
end

function action_binder:assign_action()
	self.save_binding(self.active_crossbar, self.hotkey, prefix_lookup[self.action_type], self.action_name, self.action_target, self.icon)
    self:hide()
    self:reset_state()
end

function action_binder:delete_action()
    self.delete_binding(self.active_crossbar, self.hotkey, prefix_lookup[self.action_type], self.action_name, self.action_target)
    self:hide()
    self:reset_state()
end

function action_binder:show_icon(path, x, y)
    local icon = images.new({draggable = false})
    local icon_path = windower.addon_path .. 'images/' .. get_icon_pathbase() .. '/' .. path
    icon:path(icon_path)
    icon:repeat_xy(1, 1)
    icon:draggable(false)
    icon:fit(true)
    icon:alpha(255)
    icon:show()
    icon:pos(x, y)
    self.images:append(icon)
end

function action_binder:show_pressed_buttons()
    local icons = L{}
    for i, image in ipairs(self.images) do
        image:hide()
    end

    if (self.theme_options.hotbar_number == 4) then
        if (self.active_crossbar == 1) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 2) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 3) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/arrow_right.png')
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 4) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/arrow_right.png')
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        end
    else
        if (self.trigger_left_pressed) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        end
        if (self.trigger_right_pressed) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        end
    end

    if (self.dpad_left_pressed) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_left.png')
    end
    if (self.dpad_right_pressed) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_right.png')
    end
    if (self.dpad_down_pressed) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_down.png')
    end
    if (self.dpad_up_pressed) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_up.png')
    end
    if (self.button_a_pressed) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png')
    end
    if (self.button_b_pressed) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png')
    end
    if (self.button_x_pressed) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png')
    end
    if (self.button_y_pressed) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png')
    end
    
    local all_icon_width = #icons * 40
    local center = self.width / 2
    local start_x = self.base_x + center - (all_icon_width / 2)
    local start_y = self.base_y + self.height / 2

    for i=1,#icons,1 do
        self:show_icon(icons[i], start_x + (i - 1) * 40, start_y)
    end

    self:show_exit_hint()
end

function action_binder:confirm_buttons()
    local icons = L{}
    for i, image in ipairs(self.images) do
        image:hide()
    end

    if (self.theme_options.hotbar_number == 4) then
        if (self.active_crossbar == 1) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 2) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 3) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/arrow_right.png')
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        elseif (self.active_crossbar == 4) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/arrow_right.png')
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        end
    else
        if (self.trigger_left_pressed) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_left.png')
            icons:append('ui/binding_icons/plus.png')
        end
        if (self.trigger_right_pressed) then
            icons:append('ui/binding_icons/trigger_' .. self.button_layout .. '_right.png')
            icons:append('ui/binding_icons/plus.png')
        end
    end

    if (self.hotkey == 1) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_left.png')
    end
    if (self.hotkey == 3) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_right.png')
    end
    if (self.hotkey == 2) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_down.png')
    end
    if (self.hotkey == 4) then
        icons:append('ui/binding_icons/dpad_' .. self.button_layout .. '_up.png')
    end
    if (self.hotkey == 6) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png')
    end
    if (self.hotkey == 5) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png')
    end
    if (self.hotkey == 7) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png')
    end
    if (self.hotkey == 8) then
        icons:append('ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png')
    end

    local all_icon_width = #icons * 40
    local center = self.width / 2
    local start_x = self.base_x + center - (all_icon_width / 2)
    local start_y = self.base_y + self.height / 2

    for i=1,#icons,1 do
        self:show_icon(icons[i], start_x + (i - 1) * 40, start_y)
    end
end

function action_binder:show_hint(hint_text, path, x, y)
    self:show_icon(path, x, y)
    local caption = self:create_text(hint_text, x + 45, y + 10)
    caption:size(14)
    self.hints:append(caption)
end

function action_binder:show_exit_hint()
    local x = self.base_x + 10
    local y = self.base_y + self.height - 50

    if (self.button_layout == 'gamecube') then
        if (self.confirm_button == 'a') then
            self:show_hint('Exit', 'ui/binding_icons/minus_' .. self.button_layout .. '.png', x, y)
        end
    elseif (self.button_layout == 'playstation') then
        if (self.confirm_button == 'cross') then
            self:show_hint('Exit', 'ui/binding_icons/minus_' .. self.button_layout .. '.png', x, y)
        end
    elseif (self.button_layout == 'xbox') then
        if (self.confirm_button == 'a') then
            self:show_hint('Exit', 'ui/binding_icons/minus_' .. self.button_layout .. '.png', x, y)
        end
    elseif (self.button_layout == 'nintendo') then
        if (self.confirm_button == 'b') then
            self:show_hint('Exit', 'ui/binding_icons/minus_' .. self.button_layout .. '.png', x, y)
        end
    end
end

function action_binder:show_control_hints(confirm, go_back)
    for i, hint in ipairs(self.hints) do
        hint:hide()
    end
    local y = self.base_y + self.height - 50
    local x1 = self.base_x + self.width - 130
    local x2 = self.base_x + self.width - 250

    self:show_exit_hint()

    if (self.button_layout == 'gamecube') then
        if (self.confirm_button == 'a') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x2, y)
        elseif (self.confirm_button == 'b') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x2, y)
        elseif (self.confirm_button == 'x') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x2, y)
        elseif (self.confirm_button == 'y') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x2, y)
        end
    elseif (self.button_layout == 'playstation') then
        if (self.confirm_button == 'cross') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x2, y)
        elseif (self.confirm_button == 'square') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x2, y)
        elseif (self.confirm_button == 'circle') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x2, y)
        elseif (self.confirm_button == 'triangle') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x2, y)
        end
    elseif (self.button_layout == 'xbox') then
        if (self.confirm_button == 'a') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x2, y)
        elseif (self.confirm_button == 'x') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x2, y)
        elseif (self.confirm_button == 'b') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x2, y)
        elseif (self.confirm_button == 'y') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x2, y)
        end
    elseif (self.button_layout == 'nintendo') then
        if (self.confirm_button == 'b') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x2, y)
        elseif (self.confirm_button == 'y') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x2, y)
        elseif (self.confirm_button == 'a') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x2, y)
        elseif (self.confirm_button == 'x') then
            self:show_hint(confirm, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x2, y)
        end
    end

    if (self.button_layout == 'gamecube') then
        if (self.cancel_button == 'a') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x1, y)
        elseif (self.cancel_button == 'b') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x1, y)
        elseif (self.cancel_button == 'x') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x1, y)
        elseif (self.cancel_button == 'y') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x1, y)
        end
    elseif (self.button_layout == 'playstation') then
        if (self.cancel_button == 'cross') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x1, y)
        elseif (self.cancel_button == 'square') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x1, y)
        elseif (self.cancel_button == 'circle') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x1, y)
        elseif (self.cancel_button == 'triangle') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x1, y)
        end
    elseif (self.button_layout == 'xbox') then
        if (self.cancel_button == 'a') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x1, y)
        elseif (self.cancel_button == 'x') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x1, y)
        elseif (self.cancel_button == 'b') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x1, y)
        elseif (self.cancel_button == 'y') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x1, y)
        end
    elseif (self.button_layout == 'nintendo') then
        if (self.cancel_button == 'b') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_a.png', x1, y)
        elseif (self.cancel_button == 'y') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_b.png', x1, y)
        elseif (self.cancel_button == 'a') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_x.png', x1, y)
        elseif (self.cancel_button == 'x') then
            self:show_hint(go_back, 'ui/binding_icons/facebuttons_' .. self.button_layout .. '_y.png', x1, y)
        end
    end
end

function action_binder:display_ability_selector()
    self.title:text('Select Job Ability')
    self.title:show()

    local abilities = windower.ffxi.get_abilities().job_abilities
    local ability_list = L{}

    local skip_abilities = {
        ['Phantom Roll'] = true,
        ['Quick Draw'] = true,
        ['Stratagems'] = true,
        ['Sambas'] = true,
        ['Jigs'] = true,
        ['Steps'] = true,
        ['Flourishes I'] = true,
        ['Flourishes II'] = true,
        ['Flourishes III'] = true,
        ['Curing Waltz'] = true,
        ['Healing Waltz'] = true,
        ['Divine Waltz'] = true,
        ['Ward'] = true,
        ['Effusion'] = true,
        ['Ready'] = true,
        ['Blood Pact: Rage'] = true,
        ['Blood Pact: Ward'] = true,
    }

    for key, id in pairs(abilities) do
        local name = res.job_abilities[id].en
        local target_type = res.job_abilities[id].targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'JobAbility' and not skip_abilities[skill.name]) then
            local icon_path = maybe_get_custom_icon('abilities', name)
            local icon_offset = 0
            if (icon_path == nil) then
                icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                icon_offset = 4
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_weaponskill_selector()
    self.title:text('Select Weaponskill')
    self.title:show()

    local abilities = windower.ffxi.get_abilities().weapon_skills
    local ability_list = L{}

    for key, id in pairs(abilities) do
        local ws = res.weapon_skills[id]
        local weapon = res.skills[ws.skill].en:lower()
        local name = ws.en
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'WeaponSkill') then
            local icon_path = maybe_get_custom_icon('weaponskills/' .. weapon, name)
            local icon_offset = 0
            if (icon_path == nil) then
                icon_path = 'icons/weapons/' .. (string.format("%02d", map_ws(tonumber(skill.id)))) .. '.jpg'
                icon_offset = 4
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = {['Enemy'] = true}}})
        end
    end

    ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_pet_command_selector()
    self.title:text('Select Pet Command')
    self.title:show()

    local player = windower.ffxi.get_player()

	-- DRG
    local commands = get_drg_pet_commands(player.main_job_id, player.main_job_level)
    for i, command in ipairs(get_drg_pet_commands(player.sub_job_id, player.sub_job_level)) do
        commands:append(command)
    end
	
    -- BST
    local commands = get_bst_pet_commands(player.main_job_id, player.main_job_level)
    for i, command in ipairs(get_bst_pet_commands(player.sub_job_id, player.sub_job_level)) do
        commands:append(command)
    end

    -- SMN
    for i, command in ipairs(get_smn_pet_commands(player.main_job_id, player.main_job_level)) do
        commands:append(command)
    end
    for i, command in ipairs(get_smn_pet_commands(player.sub_job_id, player.sub_job_level)) do
        commands:append(command)
    end

    -- PUP
    for i, command in ipairs(get_pup_pet_commands(player.main_job_id, player.main_job_level)) do
        commands:append(command)
    end
    for i, command in ipairs(get_pup_pet_commands(player.sub_job_id, player.sub_job_level)) do
        commands:append(command)
    end

    self.selector:display_options(commands)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_magic_selector_internal(magic_type)
    local player = windower.ffxi.get_player()
    local main_job = player.main_job:lower()
    local jp_spent = player.job_points[main_job].jp_spent
    local level = player.main_job_level

    -- JP gift spells have a "level" requirement equivalent to their JP spend requirement
    if (level == 99 and jp_spent > 99) then
        level = jp_spent
    end

    local main_spells = get_spells_for_job(player.main_job_id, level, magic_type)
    local sub_spells = get_spells_for_job(player.sub_job_id, player.sub_job_level, magic_type)
    
    local all_spells = T{}
    for id in pairs(main_spells) do
        all_spells[id] = id
    end
    for id in pairs(sub_spells) do
        all_spells[id] = id
    end

    local spell_list = L{}
    for id in pairs(all_spells) do
        local name = res.spells[id].name
        local target_type = res.spells[id].targets
        local spell = database.spells[name:lower()]

        if (spell ~= nil and spell.type == magic_type) then
            local magic_spell = res.spells[tonumber(spell.icon)]
            local magic_skill = res.skills[magic_spell.skill].en
            local icon_path = maybe_get_custom_icon(magic_skill, magic_spell.en)
            local icon_offset = 0
            if (icon_path == nil) then
                local category = SPELL_TYPE_LOOKUP[magic_type]
                if (category == nil) then
                    category = magic_type
                end
				
				local sname = magic_spell.en:lower()
				if category == 'songs' then
					sname = get_song_short_name(sname)
				end
				
                icon_path = maybe_get_custom_icon(category, sname)
            end
            if (icon_path == nil) then
                icon_path = 'icons/spells/' .. string.format("%05d", spell.icon) .. '.png'
                icon_offset = 4
            end
            spell_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    spell_list:sort(sortByName)

    self.selector:display_options(spell_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_white_magic_selector()
    self.title:text('Select White Magic Spell')
    self.title:show()

    self:display_magic_selector_internal('WhiteMagic')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_black_magic_selector()
    self.title:text('Select Black Magic Spell')
    self.title:show()

    self:display_magic_selector_internal('BlackMagic')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_song_selector()
    self.title:text('Select Song')
    self.title:show()
	
    self:display_magic_selector_internal('BardSong')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_ready_selector()
    self.title:text('Select Ready Ability')
    self.title:show()

    local ability_list = L{}

    for id, ability in pairs(res.job_abilities) do
        local name = ability.name
        local target_type = ability.targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'Monster') then
            local icon_path = maybe_get_custom_icon('ready', name)
            local icon_offset = 0
            if (icon_path == nil) then
                icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                icon_offset = 4
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_ninjutsu_selector()
    self.title:text('Select Ninjutsu Spell')
    self.title:show()

    self:display_magic_selector_internal('Ninjutsu')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_summoning_selector()
    self.title:text('Select Summoning Spell')
    self.title:show()

    self:display_magic_selector_internal('SummonerPact')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_bp_rage_selector()
    self.title:text('Select Blood Pact: Rage')
    self.title:show()

    local ability_list = L{}

    for id, ability in pairs(res.job_abilities) do
        local name = ability.name
        local target_type = ability.targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'BloodPactRage' and not DRG_PET_ABILITIES:contains(name)) then
            local icon_path = maybe_get_custom_icon('blood-pacts/rage', name)
            local icon_offset = 0
            if (icon_path == nil) then
				if skill.element ~= nil then
					icon_path = 'icons/spells/' .. string.format("%05d", get_spirit_by_element(skill.element).id) .. '.png'
					icon_offset = 4
				else
					icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
					icon_offset = 4
				end
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    --ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_bp_ward_selector()
    self.title:text('Select Blood Pact: Ward')
    self.title:show()

    local ability_list = L{}

    for id, ability in pairs(res.job_abilities) do
        local name = ability.name
        local target_type = ability.targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'BloodPactWard' and not DRG_PET_ABILITIES:contains(name)) then
            local icon_path = maybe_get_custom_icon('blood-pacts/ward', name)
            local icon_offset = 0
            if (icon_path == nil) then
				if skill.element ~= nil then
					icon_path = 'icons/spells/' .. string.format("%05d", get_spirit_by_element(skill.element).id) .. '.png'
					icon_offset = 4
				else
					icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
					icon_offset = 4
				end
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    --ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_blue_magic_selector()
    self.title:text('Select Blue Magic Spell')
    self.title:show()

    self:display_magic_selector_internal('BlueMagic')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_phantom_roll_selector()
    self.title:text('Select Phantom Roll')
    self.title:show()

    local abilities = windower.ffxi.get_abilities().job_abilities
    local ability_list = L{}

    for key, id in pairs(abilities) do
        local name = res.job_abilities[id].name
        local target_type = res.job_abilities[id].targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'CorsairRoll') then
            local icon_path = maybe_get_custom_icon('phantom-rolls', name)
            local icon_offset = 0
            if (icon_path == nil) then
                icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                icon_offset = 4
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_quick_draw_selector()
    self.title:text('Select Quick Draw')
    self.title:show()

    local abilities = windower.ffxi.get_abilities().job_abilities
    local ability_list = L{}

    for key, id in pairs(abilities) do
        local name = res.job_abilities[id].name
        local target_type = res.job_abilities[id].targets
        local skill = database.abilities[name:lower()]
        if (skill ~= nil and skill.type == 'CorsairShot') then
            local icon_path = maybe_get_custom_icon('quick-draw', name)
            local icon_offset = 0
            if (icon_path == nil) then
                icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                icon_offset = 4
            end
            ability_list:append({id = id, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
        end
    end

    ability_list:sort(sortByName)

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_stratagem_selector()
    self.title:text('Select Stratagem')
    self.title:show()

    local player = windower.ffxi.get_player()
    local stratagems = get_stratagems(player.main_job_id, player.main_job_level)

    for i, stratagem in ipairs(get_stratagems(player.sub_job_id, player.sub_job_level)) do
        stratagems:append(stratagem)
    end

    self.selector:display_options(stratagems)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_dance_selector()
    self.title:text('Select Dance')
    self.title:show()

    local player = windower.ffxi.get_player()
    local dances = get_dances(player.main_job_id, player.main_job_level)

    for i, dance in ipairs(get_dances(player.sub_job_id, player.sub_job_level)) do
        dances:append(dance)
    end

    self.selector:display_options(dances)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_geomancy_selector()
    self.title:text('Select Geomancy Spell')
    self.title:show()

    self:display_magic_selector_internal('Geomancy')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_rune_enchantment_selector()
    self.title:text('Select Rune Enchantment')
    self.title:show()

    local player = windower.ffxi.get_player()
    local is_main_high_enough = (player.main_job_id == 22 and player.main_job_level >= 5)
    local is_sub_high_enough = (player.sub_job_id == 22 and player.sub_job_level >= 5)
    
    local rune_enchantment_list = L{}
    if (is_main_high_enough or is_sub_high_enough) then
        rune_enchantment_list = L{358, 359, 360, 361, 362, 363, 364, 365}
    end

    local ability_list = L{}
    for key, id in ipairs(rune_enchantment_list) do
        local name = res.job_abilities[id].name
        local target_type = res.job_abilities[id].targets
        local element = res.elements[res.job_abilities[id].element].en:lower()
        local ability = database.abilities[name:lower()]
        local icon_path = maybe_get_custom_icon('rune-enchantments', name)
        if (icon_path == nil) then
            icon_path = get_icon_pathbase() .. '/elements/' .. element .. '.png'
        end
        ability_list:append({id = id, name = name, icon = icon_path, data = {target_type = target_type}})
    end

    self.selector:display_options(ability_list)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_ward_selector()
    self.title:text('Select Ward')
    self.title:show()

    local player = windower.ffxi.get_player()
    local wards = get_wards(player.main_job_id, player.main_job_level)

    for i, ward in ipairs(get_wards(player.sub_job_id, player.sub_job_level)) do
        wards:append(ward)
    end

    self.selector:display_options(wards)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_effusion_selector()
    self.title:text('Select Effusion')
    self.title:show()

    local player = windower.ffxi.get_player()
    local effusions = get_effusions(player.main_job_id, player.main_job_level)

    for i, effusion in ipairs(get_effusions(player.sub_job_id, player.sub_job_level)) do
        effusions:append(effusion)
    end

    self.selector:display_options(effusions)
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_trust_selector()
    self.title:text('Select Trust')
    self.title:show()

    self:display_magic_selector_internal('Trust')
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_mount_selector()
    self.title:text('Select Mount')
    self.title:show()

    self.selector:display_options(get_mounts())
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_usable_item_selector()
    self.title:text('Select Usable Item')
    self.title:show()

    self.selector:display_options(get_usable_items())
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_tradable_item_selector()
    self.title:text('Select Tradable Item')
    self.title:show()

    self.selector:display_options(get_tradable_items())
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_player_selector(include_self)
    self.title:text('Select Player to Assist')
    self.title:show()

    self.selector:display_options(get_party_names(include_self))
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_execute_command_selector()
    self.title:text('Select an icon for the command')
    self.title:show()

    self.selector:display_options(get_icons())
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_superwarp_selector()
    self.title:text('Select Warp Location')
    self.title:show()

    self.selector:display_options(get_warp_zones())
    self:show_control_hints('Confirm', 'Go Back')
end

function action_binder:display_credits()
    self.title:text('XIVCrossbar Development Credits')
    self.title:show()

    local NO_DATA = {target_type = {['None'] = true}}

    local credits = L{
        {id = 0, name = 'Programming\nAliekber', icon = 'credit_avatars/aliekber.png', data = NO_DATA},
        {id = 0, name = 'MS Paint Art\nAliekber', icon = 'credit_avatars/aliekber.png', data = NO_DATA},
        {id = 0, name = 'newline', icon = '', data = NO_DATA},
        {id = 0, name = 'newline', icon = '', data = NO_DATA},
        {id = 0, name = 'Based on XIVHotbar by\nSirEdeonX', icon = 'credit_avatars/edeon.png', data = NO_DATA},
        {id = 0, name = 'newline', icon = '', data = NO_DATA},
        {id = 0, name = 'Skillchain library\nIvaar', icon = 'credit_avatars/ivaar.png', data = NO_DATA},
        {id = 0, name = 'MountRoulette library\nXurion', icon = 'credit_avatars/xurion.png', data = NO_DATA},
        {id = 0, name = 'newline', icon = '', data = NO_DATA},
        {id = 0, name = 'newline', icon = '', data = NO_DATA},
        {id = 0, name = 'Beta Testing\nJinxs', icon = 'credit_avatars/jinxs.png', data = NO_DATA},
        {id = 0, name = 'Beta Testing\nMartel', icon = 'credit_avatars/martel.png', data = NO_DATA},
    }

    self.selector:display_options(credits)
    self:show_control_hints('Confirm', 'Go Back')
end



function get_spells_for_job(job_id, job_level, magic_type)
    local known_spell_ids = T(windower.ffxi.get_spells()):filter(boolean._true):keyset()
    local all_spells = res.spells:type(magic_type)
    local job_spells = T{}

    for id, spell in pairs(all_spells) do
        local is_known = known_spell_ids[id] ~= nil
        local job_can_know = spell.levels[job_id] ~= nil
        if (job_can_know and is_known and spell.levels[job_id] <= job_level and spell.type == magic_type) then
            job_spells[id] = id
        end
    end

    return job_spells:keyset()
end

function get_drg_pet_commands(job_id, job_level)
	local commands = L{
        {name = 'Dismiss', id = 87, level = 1},
        {name = 'Smiting Breath', id = 318, level = 90},
        {name = 'Restoring Breath', id = 319, level = 90},
        {name = 'Steady Wing', id = 295, level = 95},
    }
	
	command_list = L{}

    if (job_id == 14) then
        for i, command in ipairs(commands) do
            if (job_level >= command.level) then
                local skill = database.abilities[command.name:lower()]
                local target_type = res.job_abilities[command.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('petcommands', command.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                command_list:append({id = command.id, name = command.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return command_list
end

function get_bst_pet_commands(job_id, job_level)
    local commands = L{
        {name = 'Fight', id = 69, level = 1},
        {name = 'Heel', id = 70, level = 10},
        {name = 'Stay', id = 73, level = 15},
        {name = 'Sic', id = 72, level = 25},
        {name = 'Leave', id = 71, level = 35},
        {name = 'Snarl', id = 225, level = 45},
        {name = 'Spur', id = 281, level = 83},
        {name = 'Run Wild', id = 282, level = 93}
    }

    command_list = L{}

    if (job_id == 9) then
        for i, command in ipairs(commands) do
            if (job_level >= command.level) then
                local skill = database.abilities[command.name:lower()]
                local target_type = res.job_abilities[command.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('petcommands', command.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                command_list:append({id = command.id, name = command.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return command_list
end

function get_smn_pet_commands(job_id, job_level)
    local commands = L{
        {name = 'Assault', id=88, level = 1},
        {name = 'Retreat', id=89, level = 1},
        {name = 'Release', id=90, level = 1},
        {name = 'Avatar\'s Favor', id=250, level = 55}
    }
    command_list = L{}

    if (job_id == 15) then
        for i, command in ipairs(commands) do
            if (job_level >= command.level) then
                local skill = database.abilities[command.name:lower()]
                local target_type = res.job_abilities[command.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('petcommands', command.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                command_list:append({id = command.id, name = command.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return command_list
end

function get_pup_pet_commands(job_id, job_level)
    local commands = L{
        {name = 'Deploy', id = 138, level = 1},
        {name = 'Deactivate', id = 139, level = 1},
        {name = 'Retrieve', id = 140, level = 10},
        {name = 'Fire Maneuver', id = 141, level = 1},
        {name = 'Ice Maneuver', id = 142, level = 1},
        {name = 'Wind Maneuver', id = 143, level = 1},
        {name = 'Earth Maneuver', id = 144, level = 1},
        {name = 'Thunder Maneuver', id = 145, level = 1},
        {name = 'Water Maneuver', id = 146, level = 1},
        {name = 'Light Maneuver', id = 147, level = 1},
        {name = 'Dark Maneuver', id = 148, level = 1}
    }

    command_list = L{}

    if (job_id == 18) then
        for i, command in ipairs(commands) do
            if (job_level >= command.level) then
                local skill = database.abilities[command.name:lower()]
                local target_type = res.job_abilities[command.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('petcommands', command.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                command_list:append({id = command.id, name = command.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return command_list
end

function get_stratagems(job_id, job_level)
    --local all_abilities = res.job_abilities

    local grimoire_white = get_icon_pathbase() .. '/abilities/book_white.png'
    local grimoire_black = get_icon_pathbase() .. '/abilities/book_black.png'

    local stratagems = L{
        {name = 'Penury', id = 215, level = 10, icon = grimoire_white},
        {name = 'Celerity', id = 216, level = 25, icon = grimoire_white},
        {name = 'Addendum: White', id = 234, level = 10, icon = grimoire_white},
        {name = 'Accession', id = 218, level = 40, icon = grimoire_white},
        {name = 'Rapture', id = 217, level = 55, icon = grimoire_white},
        {name = 'Altruism', id = 240, level = 75, icon = grimoire_white},
        {name = 'Tranquility', id = 242, level = 75, icon = grimoire_white},
        {name = 'Perpetuance', id = 316, level = 87, icon = grimoire_white},
        {name = 'Parsimony', id = 219, level = 10, icon = grimoire_black},
        {name = 'Alacrity', id = 220, level = 25, icon = grimoire_black},
        {name = 'Addendum: Black', id = 235, level = 30, icon = grimoire_black},
        {name = 'Manifestation', id = 222, level = 40, icon = grimoire_black},
        {name = 'Ebullience', id = 221, level = 55, icon = grimoire_black},
        {name = 'Focalization', id = 241, level = 75, icon = grimoire_black},
        {name = 'Equanimity', id = 243, level = 75, icon = grimoire_black},
        {name = 'Immanence', id = 317, level = 87, icon = grimoire_black},
    }

    stratagem_list = L{}

    if (job_id == 20) then
        for i, stratagem in ipairs(stratagems) do
            if (job_level >= stratagem.level) then
                local target_type = res.job_abilities[stratagem.id].targets
                local icon_path = maybe_get_custom_icon('stratagems', stratagem.name)
                if (icon_path == nil) then
                    icon_path = stratagem.icon
                end
                stratagem_list:append({id = stratagem.id, name = stratagem.name, icon = icon_path, data = {target_type = target_type}})
            end
        end
    end

    return stratagem_list
end

function get_dances(job_id, job_level)
    --local all_abilities = res.job_abilities

    local dances = L{
        {name = 'Drain Samba', id = 184, level = 5},
        {name = 'Drain Samba II', id = 185, level = 35},
        {name = 'Drain Samba III', id = 186, level = 65},
        {name = 'Aspir Samba', id = 187, level = 25},
        {name = 'Aspir Samba II', id = 188, level = 60},
        {name = 'Haste Samba', id = 189, level = 45},
        {name = 'Healing Waltz', id = 194, level = 35},
        {name = 'Curing Waltz', id = 190, level = 15},
        {name = 'Curing Waltz II', id = 191, level = 30},
        {name = 'Curing Waltz III', id = 192, level = 45},
        {name = 'Curing Waltz IV', id = 193, level = 70},
        {name = 'Curing Waltz V', id = 311, level = 87},
        {name = 'Divine Waltz', id = 195, level = 25},
        {name = 'Divine Waltz II', id = 262, level = 78},
        {name = 'Spectral Jig', id = 196, level = 25},
        {name = 'Chocobo Jig', id = 197, level = 55},
        {name = 'Chocobo Jig II', id = 381, level = 70},
        {name = 'Quickstep', id = 201, level = 20},
        {name = 'Box Step', id = 202, level = 30},
        {name = 'Stutter Step', id = 203, level = 40},
        {name = 'Feather Step', id = 312, level = 83},
        {name = 'Animated Flourish', id = 204, level = 20},
        {name = 'Desperate Flourish', id = 205, level = 30},
        {name = 'Violent Flourish', id = 207, level = 45},
        {name = 'Reverse Flourish', id = 206, level = 40},
        {name = 'Building Flourish', id = 208, level = 50},
        {name = 'Wild Flourish', id = 209, level = 60},
        {name = 'Climactic Flourish', id = 264, level = 80},
        {name = 'Striking Flourish', id = 313, level = 89},
        {name = 'Ternary Flourish', id = 314, level = 93}
    }

    dance_list = L{}

    if (job_id == 19) then
        for i, dance in ipairs(dances) do
            if (job_level >= dance.level) then
                local skill = database.abilities[dance.name:lower()]
                local target_type = res.job_abilities[dance.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('dances', dance.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                dance_list:append({id = dance.id, name = dance.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return dance_list
end

function get_wards(job_id, job_level)
    --local all_abilities = res.job_abilities

    local wards = L{
        {name = 'Vallation', id = 366, level = 10},
        {name = 'Pflug', id = 369, level = 40},
        {name = 'Valiance', id = 371, level = 50},
        {name = 'Battuta', id = 376, level = 75},
        {name = 'Liement', id = 373, level = 85}
    }

    ward_list = L{}

    if (job_id == 22) then
        for i, ward in ipairs(wards) do
            if (job_level >= ward.level) then
                local skill = database.abilities[ward.name:lower()]
                local target_type = res.job_abilities[ward.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('wards', ward.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                ward_list:append({id = ward.id, name = ward.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return ward_list
end

function get_effusions(job_id, job_level)
    --local all_abilities = res.job_abilities

    local effusions = L{
        {name = 'Swipe', id = 344, level = 25},
        {name = 'Lunge', id = 368, level = 25},
        {name = 'Gambit', id = 372, level = 70},
        {name = 'Rayke', id = 375, level = 75}
    }

    effusion_list = L{}

    if (job_id == 22) then
        for i, effusion in ipairs(effusions) do
            if (job_level >= effusion.level) then
                local skill = database.abilities[effusion.name:lower()]
                local target_type = res.job_abilities[effusion.id].targets
                local icon_path = 'ui/red-x.png'
                local icon_offset = 0
                if (skill ~= nil) then
                    icon_path = maybe_get_custom_icon('effusions', effusion.name)
                    if (icon_path == nil) then
                        icon_path = 'icons/abilities/' .. string.format("%05d", skill.icon) .. '.png'
                        icon_offset = 4
                    end
                end
                effusion_list:append({id = effusion.id, name = effusion.name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
            end
        end
    end

    return effusion_list
end

function get_mounts()
	local FAKE_ID = 0
	local mount_list = L{}
	local possible_mounts = L{}
	
	-- set possible mounts
	for _, mount in pairs(resources.mounts) do
		possible_mounts:append(mount.name:lower())
	end

	-- set allowed mounts (mounts the player actual has)
	local allowed_mounts_set = S{}
	local kis = windower.ffxi.get_key_items()
	for _, id in ipairs(kis) do
		local ki = resources.key_items[id]
		if ki.category == 'Mounts' and ki.name ~= "trainer's whistle" then -- Don't care about the quest KI
			local mount_index = possible_mounts:find(function(possible_mount)
				return windower.wc_match(ki.name:lower(), '♪' .. possible_mount .. '*')
			end)
			local mount = possible_mounts[mount_index]

			allowed_mounts_set:add(mount)
		end
	end
	
	local allowed_mounts = L{}
	allowed_mounts = L(allowed_mounts_set)
	allowed_mounts:append('mount roulette')
	
	-- setup the mount list (menu buttons)
    local target_type = {['None'] = true}
    for i, mount_name in ipairs(allowed_mounts) do
        local icon_path = maybe_get_custom_icon('mounts', mount_name)
        if (icon_path == nil) then
            icon_path = get_icon_pathbase() .. '/mount.png'
        end

        mount_list:append({id = FAKE_ID, name = mount_name:capitalize(), icon = icon_path, data = {target_type = target_type}})
    end

    mount_list:sort(sortByName)

    local mount_name = 'mount roulette'
    local icon_path = maybe_get_custom_icon('mounts', mount_name)
    if (icon_path == nil) then
        icon_path = get_icon_pathbase() .. '/mount.png'
    end
    mount_list:append({id = FAKE_ID, name = mount_name:capitalize(), icon = icon_path, data = {target_type = target_type}})

    return mount_list
end

function get_party_names(include_self)
    local player_name = windower.ffxi.get_player().name
    local party = windower.ffxi.get_party()

    icon_path = get_icon_pathbase() .. '/party-member.png'

    local party_names = L{}

    for key, person in pairs(party) do
        if (person ~= nil and type(person) ~= 'number') then
            if (include_self or person.name ~= player_name) then
                party_names:append({id = FAKE_ID, name = person.name, icon = icon_path, data = NO_DATA})
            end
        end
    end

    return party_names
end

local INVENTORY_BAG = 0

function get_items(category)
    local usable_icon_path = get_icon_pathbase() .. '/usable-item.png'
    local tradable_icon_path = get_icon_pathbase() .. '/item.png'
    local inventory = windower.ffxi.get_items(INVENTORY_BAG)
    local ignore_indices = {max = true, count = true, enabled = true}

    if (inventory) then
        local all_items = L{}
        local already_included_ids = {}

        for i, inv_item in pairs(inventory) do
            if ((not ignore_indices[i]) and inv_item.id ~= 0) then
                local item = res.items[inv_item.id]
                if (not already_included_ids[item.id]) then
                    already_included_ids[item.id] = true
                    local icon_path = maybe_get_custom_icon('items', item.en)
                    local target_type = nil

                    local is_usable = item.category == 'Usable' and category == 'Usable'
                    local is_tradable = item.category == 'General' and category == 'General'
                    if (is_usable) then
                        target_type = item.targets
                        if (icon_path == nil) then
                            icon_path = usable_icon_path
                        end
                    elseif (is_tradable) then
                        target_type = {NPC = true}
                        if (icon_path == nil) then
                            icon_path = tradable_icon_path
                        end
                    end

                    if (is_usable or is_tradable) then
                        all_items:append({id = item.id, name = item.en, icon = icon_path, data = {target_type = target_type}})
                    end
                end
            end
        end

        all_items:sort(sortByName)

        return all_items
    else
        return L{}
    end
end

function get_usable_items()
    return get_items('Usable')
end

function get_tradable_items()
    return get_items('General')
end

function get_icons() -- Used for EXECUTE_COMMAND action type
	local lognotice = false
	local command_list = L{}
	
	local txt_file = file.new('images/' .. get_icon_pathbase() .. '/icon_list.txt')
	if txt_file:exists() then
		local FAKE_ID = 0
		local icon_offset = 0
		local target_type = {['None'] = true}
		
		local icon_list = txt_file:readlines()
		for key,line in pairs(icon_list) do
			if not tonumber(line) and line ~= nil and line ~= '' and not line:contains('home-point') and not line:contains('survival-guide') then
				local icon_name = tostring(line):gsub('.png',''):gsub('\\','/')
				local icon_path = get_icon_pathbase()..'/'..icon_name..'.png'
				local icon_file = file.new('images/'..icon_path)
				if icon_file:exists() then
					command_list:append({id = FAKE_ID, name = icon_name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
				elseif not shownotice then
					lognotice = true
				end
			end
		end
	else
		error('FILE NOT FOUND "icon_list.txt". Please run "images/'..get_icon_pathbase()..'/GENERATE_ICON_LIST.bat"')
	end
	
	if lognotice then
		warning('Some icons not found. Resolve by running "images/'..get_icon_pathbase()..'/GENERATE_ICON_LIST.bat"')
	end
	
	command_list:sort(sortByName)
	
	return command_list
end

function get_warp_zones() -- For creating superwarp macros
	local command_list = L{}
	local FAKE_ID = 0
	local icon_offset = 0
	local target_type = {['None'] = true}
	
	for key,entry in pairs(res.zones) do
		if entry and entry.en ~= 'unknown' then
			local name = entry.en
			local icon_path
			if sw_zones.hp[name] then
				icon_path = maybe_get_custom_icon('', 'home point') --..'/home-point.png'
				command_list:append({id = FAKE_ID, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
			end
			if sw_zones.sg[name] then
				icon_path = maybe_get_custom_icon('', 'survival guide') --..'/survival-guide.png'
				command_list:append({id = FAKE_ID, name = name, icon = icon_path, icon_offset = icon_offset, data = {target_type = target_type}})
			end
		end
	end
	
	command_list:sort(sortByName)
	
	return command_list
end

-- helper methods
function get_spirit_by_element(ele_name)
	local elements = res.elements
	for key, entry in pairs(res.spells) do
		if entry.type == 'SummonerPact' and entry.en:contains('Spirit') then
			if entry.element == elements:with('en', ele_name).id then
				return entry
			end
		end
	end
end

function get_song_short_name(str)
	if not str then return '' end
	str = str:lower()
	
	local newstr = ''
	local splat = str:split(' ')
	local cnt = 1
	for _, s in ipairs(splat) do
		if cnt ~= 1 then
			if cnt < #splat then
				newstr = newstr .. ' ' .. s
			else
				if s ~= 'ii' and s ~= 'iii' and s ~= 'iv' and s ~= 'v' and s ~= 'vi' and s ~= 'vii' then
					newstr = newstr .. ' ' .. s
				end
			end
		end
		
		cnt = cnt + 1
	end
	
	return newstr:trim()
end

local click_row = nil
local click_col = nil

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    if (action_binder.selector and action_binder.selector.is_showing) then
        -- Mouse left click
        if type == 1 then
            local row, col = action_binder.selector:get_row_col_from_pos(x, y)
            if (action_binder.selector:is_valid_row_col(row, col)) then
                click_row = row
                click_col = col
                return true
            end
        -- Mouse left release
        elseif type == 2 then
            local row, col = action_binder.selector:get_row_col_from_pos(x, y)
            if (row == click_row and col == click_col) then
                action_binder:submit_selected_option()
                return true
            end
        end
    end
end)

-- HELPER FUNCTIONS
function sortByName(a, b)
    return a.name < b.name
end

return action_binder
