-- Addon description
_addon.name = 'XIV Crossbar' -- based on Edeon's XIV Hotbar
_addon.author = 'Aliekber, modded by icy'
_addon.version = '0.1.2i'
_addon.language = 'english'
_addon.commands = {'xivcrossbar', 'xb'}

-- Libs
config = require('config')
file = require('files')
texts = require('texts')
images = require('images')
tables = require('tables')
resources = require('resources')
xml = require('libs/xml2')

-- User settings
local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)

-- Load theme options according to settings
local theme = require('theme')
local theme_options = theme.apply(settings)
local buttonmapping = require('buttonmapping')

-- Addon Dependencies
local action_manager = require('action_manager')
local keyboard = require('keyboard_mapper')
local gamepad = require('gamepad')
local player = require('player')
local ui = require('ui')
local env_chooser = require('environment_chooser')
local action_binder = require('action_binder')
local enchanted_items = require('enchanted_items')
local xivcrossbar = require('variables')
local skillchains = require('libs/skillchain/skillchains')
local consumables = require('consumables')
local gamepad_mapper = require('gamepad_mapper')
local function_key_bindings = require('function_key_bindings')

-----------------------------
-- Main
-----------------------------

local gamepad_state = {}
gamepad_state.left_trigger = false
gamepad_state.right_trigger = false
gamepad_state.active_bar = 0
local shift_pressed = false
local ui_dirty = false

-- command to set a crossbar action in action_binder
function set_hotkey(hotbar, slot, action_type, action, target, icon)
    local environment = player.hotbar_settings.active_environment

    local alias = nil
    icon = icon or nil
    if (action == 'Ranged Attack') then
        action = 'ra'
        alias = 'Ranged Attack'
        icon = 'ranged'
    elseif (action == 'Attack') then
        action = 'a'
        alias = 'Attack'
        icon = 'attack'
    elseif (action_type == 'assist') then
        action_type = 'ct'
        alias = action
        action = action:lower()
        icon = 'assist'
    elseif (action == 'Last Synth') then
        action = 'lastsynth'
        alias = 'Last Synth'
        icon = 'synth'
	elseif (action_type == 'ex' and action == icon) then
		alias = 'placeholder'
	elseif (action_type == 'ex' and (icon == 'home-point' or icon == 'survival-guide')) then
		alias = action
		local all = theme_options.enable_superwarp_all and ' all' or ''
		if (icon == 'home-point') then
			action = 'sw hp'.. all ..' '..alias
		else
			action = 'sw sg'.. all ..' '..alias
		end
    end

    local new_action = action_manager:build(action_type, action, target, alias, icon)
    player:add_action(new_action, environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
    set_active_environment(environment)
end

-- command to set a crossbar action in action_binder
function delete_hotkey(hotbar, slot)
    local environment = player.hotbar_settings.active_environment

    player:remove_action(environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
    set_active_environment(environment)
end

function start_controller_wrappers()
    if theme_options.use_directinput then
		windower.send_command('run addons/xivcrossbar/ffxi_directinput.ahk')
	end
	
	if theme_options.use_xinput then
		windower.send_command('run addons/xivcrossbar/ffxi_xinput.ahk')
	end
end

-- initialize addon
function initialize()
    local windower_player = windower.ffxi.get_player()
    local server = resources.servers[windower.ffxi.get_info().server].en

    if windower_player == nil then return end

    if (buttonmapping.validate()) then
        start_controller_wrappers()
        theme_options.button_layout = buttonmapping.button_layout
        action_binder:setup(buttonmapping, set_hotkey, delete_hotkey, theme_options, 150, 150, windower.get_windower_settings().ui_x_res - 300, windower.get_windower_settings().ui_y_res - 450)
    else
        theme_options.button_layout = 'nintendo'
        local temp_buttonmapping = {}
        theme_options.confirm_button = 'a'
        theme_options.cancel_button = 'b'
        theme_options.mainmanu_button = 'y'
        theme_options.activewindow_button = 'x'
        gamepad_mapper:setup(buttonmapping, start_controller_wrappers, theme_options, 150, 150, windower.get_windower_settings().ui_x_res - 300, windower.get_windower_settings().ui_y_res - 450)
        gamepad_mapper:show(true)
        action_binder:setup(temp_buttonmapping, set_hotkey, delete_hotkey, theme_options, 150, 150, windower.get_windower_settings().ui_x_res - 300, windower.get_windower_settings().ui_y_res - 450)
    end

    player:initialize(windower_player, server, theme_options, enchanted_items)
    player:load_hotbar()
    ui:setup(theme_options, enchanted_items)

    local default_active_environment = env_chooser:get_default_active_environment(player.hotbar)
    set_active_environment(default_active_environment)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment, gamepad_state)

    consumables:setup()
    env_chooser:setup(theme_options)

    xivcrossbar.ready = true
    xivcrossbar.initialized = true
end

-- trigger hotbar action
function trigger_action(slot)
    player:execute_action(slot)
    ui:trigger_feedback(player.hotbar_settings.active_hotbar, slot)
end

-- set battle environment
function set_battle_environment(in_battle)
    player:set_battle_environment(in_battle)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment, gamepad_state)
end

-- set active environment
function set_active_environment(environment_name)
    player:set_active_environment(environment_name)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment, gamepad_state)
end

-- check validity of an environment
function is_valid_environment(environment_name)
    return player:is_valid_environment(environment_name)
end

-- reload hotbar
function reload_hotbar()
    player:load_hotbar()
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment, gamepad_state)
end

-- change active hotbar
function change_active_hotbar(new_hotbar)
    player:change_active_hotbar(new_hotbar)
end

-----------------------------
-- Addon Commands
-----------------------------

-- command to set an action in a hotbar
function set_action_command(args)
    if not args[5] then
        print('XIVCROSSBAR: Invalid arguments: set <mode> <hotbar> <slot> <action_type> <action> <target (optional)> <alias (optional)> <icon (optional)>')
        return
    end

    local environment = args[1]:lower()

    if (args[2] == nil) then
        if (is_valid_environment(args[2])) then
            set_active_environment(args[2])
        else
            print('XIVCROSSBAR: "' .. args[2] .. '" is not a valid crossbar set.')
        end
    end

    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local action_type = args[4]:lower()
    local action = args[5]
    local target = args[6] or nil
    local alias = args[7] or nil
    local icon = args[8] or nil

    if hotbar < 1 or hotbar > theme_options.hotbar_number then
        print('XIVCROSSBAR: Invalid hotbar. Please use a number between 1 and ' .. theme_options.hotbar_number .. '.')
        return
    end

    if slot < 1 or slot > 8 then
        print('XIVCROSSBAR: Invalid slot. Please use a number between 1 and 8.')
        return
    end

    if target ~= nil then target = target:lower() end

    local new_action = action_manager:build(action_type, action, target, alias, icon)
    player:add_action(new_action, environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
end

-- command to delete an action from an hotbar
function delete_action_command(args)
    if not args[3] then
        print('XIVCROSSBAR: Invalid arguments: del <mode> <hotbar> <slot>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0

    if hotbar < 1 or hotbar > theme_options.hotbar_number then
        print('XIVCROSSBAR: Invalid hotbar. Please use a number between 1 and ' .. theme_options.hotbar_number .. '.')
        return
    end

    if slot < 1 or slot > 8 then
        print('XIVCROSSBAR: Invalid slot. Please use a number between 1 and 8.')
        return
    end

    player:remove_action(environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
end

-- command to copy an action to another slot
function copy_action_command(args, is_moving)
    local command = 'copy'
    if is_moving then command = 'move' end

    if not args[6] then
        print('XIVCROSSBAR: Invalid arguments: ' .. command .. ' <mode> <hotbar> <slot> <to_mode> <to_hotbar> <to_slot>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local to_environment = args[4]:lower()
    local to_hotbar =  tonumber(args[5]) or 0
    local to_slot =  tonumber(args[6]) or 0

    if hotbar < 1 or hotbar > 3 or to_hotbar < 1 or to_hotbar > 3 then
        print('XIVCROSSBAR: Invalid hotbar. Please use a number between 1 and ' .. theme_options.hotbar_number .. '.')
        return
    end

    if slot < 1 or slot > 8 or to_slot < 1 or to_slot > 8 then
        print('XIVCROSSBAR: Invalid slot. Please use a number between 1 and 8.')
        return
    end

    player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    player:save_hotbar()
    reload_hotbar()
end

-- command to update action alias
function update_alias_command(args)
    if not args[4] then
        print('XIVCROSSBAR: Invalid arguments: alias <mode> <hotbar> <slot> <alias>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local alias = args[4]

    if hotbar < 1 or hotbar > 3 then
        print('XIVCROSSBAR: Invalid hotbar. Please use a number between 1 and ' .. theme_options.hotbar_number .. '.')
        return
    end

    if slot < 1 or slot > 8 then
        print('XIVCROSSBAR: Invalid slot. Please use a number between 1 and 8.')
        return
    end

    player:set_action_alias(environment, hotbar, slot, alias)
    player:save_hotbar()
    reload_hotbar()
end

-- command to update action icon
function update_icon_command(args)
    if not args[4] then
        print('XIVCROSSBAR: Invalid arguments: icon <mode> <hotbar> <slot> <icon>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local icon = args[4]

    if hotbar < 1 or hotbar > 3 then
        print('XIVCROSSBAR: Invalid hotbar. Please use a number between 1 and ' .. theme_options.hotbar_number .. '.')
        return
    end

    if slot < 1 or slot > 8 then
        print('XIVCROSSBAR: Invalid slot. Please use a number between 1 and 8.')
        return
    end

    player:set_action_icon(environment, hotbar, slot, icon)
    player:save_hotbar()
    reload_hotbar()
end

-- command to update action icon
function new_environment_command(args)
    if not args[1] then
        print('XIVCROSSBAR: Invalid arguments: new <name>')
        return
    end

    local environment = args[1]
    local env_lower = environment:lower()

    if (env_lower == 'default' or env_lower == 'job-default' or env_lower == 'all-jobs-default') then
        print('XIVCROSSBAR: Crossbar set name "' .. environment .. '" is reserved. Unable to create.')
        return
    end

    player:create_new_environment(environment)
    player:save_hotbar()
    reload_hotbar()
    set_active_environment(environment)
end

-- command to rerun the setup dialog
function remap()
    gamepad_mapper:setup(buttonmapping, start_controller_wrappers, theme_options, 150, 150, windower.get_windower_settings().ui_x_res - 300, windower.get_windower_settings().ui_y_res - 450)
    gamepad_mapper:show(false)
end

-- command to display help for the user
function display_help_menu()
    local layout = theme_options.button_layout:lower()
    local minus_button = 'Minus'
    if (layout == 'playstation') then
        minus_button = 'Share'
    elseif (layout == 'xbox') then
        minus_button = 'Back'
    end
    local plus_button = 'Plus'
    if (layout == 'playstation') then
        plus_button = 'Options'
    elseif (layout == 'xbox') then
        plus_button = 'Start'
    end
    local left_trigger = 'L'
    if (layout == 'playstation') then
        left_trigger = 'L2'
    end
    local right_trigger = 'R'
    if (layout == 'playstation') then
        right_trigger = 'R2'
    end
    local buttons = 'A/B/X/Y'
    if (layout == 'playstation') then
        buttons = 'Face'
    end

    windower.send_command('echo ================XIVCrossbar Help===============')
    windower.send_command('echo To create a new crossbar set, use the command:')
    windower.send_command('echo xb new <crossbar name>')
    windower.send_command('echo ===============================================')
    windower.send_command('echo To rerun the setup utility, use the command:')
    windower.send_command('echo xb remap')
    windower.send_command('echo ===============================================')
    windower.send_command('echo Gamepad Controls (' .. theme_options.button_layout .. '):')
    windower.send_command('echo ' .. plus_button .. ' + D-Pad (↑/↓): Switch between crossbar sets')
    windower.send_command('echo ' .. minus_button .. ': Open/close button bind utility')
    windower.send_command('echo ' .. left_trigger .. '/' .. right_trigger .. ' Triggers + D-Pad: Navigate button bind utility (when open)')
    windower.send_command('echo ' .. left_trigger .. '/' .. right_trigger .. ' Triggers + D-Pad or ' .. buttons .. ' Button: executes bound action')
    windower.send_command('echo ===============================================')
end

-----------------------------
-- Bind Events
-----------------------------

-- ON LOAD
windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
    skillchains.load()

    -- Unbind Ctrl + <F1 through F12> because they're going proxy the gamepad's triggers and buttons
    -- We use Ctrl instead of Alt because Alt gets stuck in a down state when Alt+Tabbing sometimes
    -- minus button
    windower.send_command('unbind ^f1')
    -- plus button
    windower.send_command('unbind ^f2')
    -- dpad up
    windower.send_command('unbind ^f3')
    -- dpad right
    windower.send_command('unbind ^f4')
    -- dpad down
    windower.send_command('unbind ^f5')
    -- dpad left
    windower.send_command('unbind ^f6')
    -- a button
    windower.send_command('unbind ^f7')
    -- b button
    windower.send_command('unbind ^f8')
    -- x button
    windower.send_command('unbind ^f9')
    -- y button
    windower.send_command('unbind ^f10')
    -- left trigger
    windower.send_command('unbind ^f11')
    -- right trigger
    windower.send_command('unbind ^f12')
end)

-- ON LOGIN
windower.register_event('login',function()
    initialize()
    skillchains.login()
end)

-- ON LOGOUT
windower.register_event('logout', function()
    ui:hide()
    skillchains.logout()
end)

-- ON UNLOAD
windower.register_event('unload',function()
	if theme_options.on_unload_killahk then
		windower.send_command('run addons/xivcrossbar/killahk.bat')
	end
end)

-- ON COMMAND
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    if command == 'reload' then
        return reload_hotbar()

    elseif command == 'set' then
        set_action_command(args)
    elseif command == 'del' or command == 'delete' then
        delete_action_command(args)
    elseif command == 'cp' or command == 'copy' then
        copy_action_command(args, false)
    elseif command == 'mv' or command == 'move' then
        copy_action_command(args, true)
    elseif command == 'ic' or command == 'icon' then
        update_icon_command(args)
    elseif command == 'al' or command == 'alias' then
        update_alias_command(args)
    elseif command == 'n' or command == 'new' then
        new_environment_command(args)
	elseif #args > 0 and command == 'sw' or command == 'switch' then
		local to = table.concat(args, ' ')
        if is_valid_environment(to) then
			set_active_environment(args[1]:lower())
		end
    elseif command == 'remap' then
        remap()
    elseif command == '?' or command == 'help' then
        display_help_menu()
    end
end)

local keys = {
    [2] = '1',
    [3] = '2',
    [4] = '3',
    [5] = '4',
    [6] = '5',
    [7] = '6',
    [8] = '7',
    [9] = '8',
    [10] = '9',
    [11] = '0',
    [12] = '-',
    [30] = 'A',
    [48] = 'B',
    [46] = 'C',
    [32] = 'D',
    [18] = 'E',
    [33] = 'F',
    [34] = 'G',
    [35] = 'H',
    [23] = 'I',
    [36] = 'J',
    [37] = 'K',
    [38] = 'L',
    [50] = 'M',
    [49] = 'N',
    [24] = 'O',
    [25] = 'P',
    [16] = 'Q',
    [19] = 'R',
    [31] = 'S',
    [20] = 'T',
    [22] = 'U',
    [47] = 'V',
    [17] = 'W',
    [45] = 'X',
    [21] = 'Y',
    [44] = 'Z'
}

-- ON KEY
windower.register_event('keyboard', function(dik, pressed, flags, blocked)
    local left_trigger_just_pressed = pressed and gamepad.is_left_trigger(dik) and not gamepad_state.left_trigger
    local right_trigger_just_pressed = pressed and gamepad.is_right_trigger(dik) and not gamepad_state.right_trigger
    local left_trigger_just_released = (not pressed) and gamepad.is_left_trigger(dik) and gamepad_state.left_trigger
    local right_trigger_just_released = (not pressed) and gamepad.is_right_trigger(dik) and gamepad_state.right_trigger

    ui_dirty = left_trigger_just_pressed or right_trigger_just_pressed or left_trigger_just_released or right_trigger_just_released

    if (gamepad.is_left_trigger(dik)) then
        gamepad_state.left_trigger = pressed
    elseif (gamepad.is_right_trigger(dik)) then
        gamepad_state.right_trigger = pressed
    elseif (dik == keyboard.ctrl) then
        gamepad_state.capturing = pressed
    elseif (dik == keyboard.shift) then
        shift_pressed = pressed
    elseif (gamepad.is_minus(dik)) then
        gamepad_state.minus_button = pressed
    elseif (gamepad.is_plus(dik)) then
        gamepad_state.plus_button = pressed
    end
    
    -- windower.send_command('@input /echo '..dik)

    -- If the user presses Ctrl+F1 through Ctrl+F10 and neither trigger is down, then activate their bound command
    local no_triggers_pressed = not gamepad_state.left_trigger and not gamepad_state.right_trigger
    local no_menu_buttons_pressed = not gamepad_state.minus_button and not gamepad_state.plus_button
    if (gamepad_state.capturing and no_triggers_pressed and no_menu_buttons_pressed and dik >= keyboard.f1 and dik <= keyboard.f8 and pressed) then
        local function_key = (dik - keyboard.f1) + 1
        local natural_binding_key = 'CtrlF' .. function_key .. 'Command'
        local command = function_key_bindings[natural_binding_key]
        windower.send_command(command)
    end

    if (env_chooser.capturing and keys[dik] ~= nil) then
        if (pressed) then
            if (shift_pressed) then
                env_chooser:send_key(keys[dik])
            else
                env_chooser:send_key(keys[dik]:lower())
            end
        end
        return true
    elseif (env_chooser.capturing and dik == keyboard.backspace and pressed) then
        env_chooser:send_backspace()
    elseif (env_chooser.capturing and dik == keyboard.esc and pressed) then
        local next_environment = env_chooser:get_next_environment(player.hotbar, player.hotbar_settings.active_environment)
        set_active_environment(next_environment)
        env_chooser:send_escape()
    elseif (env_chooser.capturing and dik == keyboard.enter and pressed) then
        if (env_chooser:validate_new_set_name()) then
            new_environment_command(L{env_chooser:get_new_set_name()})
            env_chooser:clear()
        else
            windower.send_command('input /echo [XIVCrossbar] Crossbar set name "' .. env_chooser:get_new_set_name() .. '" is reserved. Unable to create.')
        end
        return true
    end

    if (gamepad_state.capturing and gamepad_state.left_trigger and not gamepad_state.right_trigger) then
        change_active_hotbar(1)
        gamepad_state.active_bar = 1
    elseif (gamepad_state.capturing and gamepad_state.right_trigger and not gamepad_state.left_trigger) then
        change_active_hotbar(2)
        gamepad_state.active_bar = 2
    elseif (gamepad_state.capturing and gamepad_state.right_trigger and gamepad_state.left_trigger) then
        if (theme_options.hotbar_number == 4) then
            if (left_trigger_just_pressed) then
                -- R -> L = bar 3
                change_active_hotbar(3)
                gamepad_state.active_bar = 3
            elseif (right_trigger_just_pressed) then
                -- L -> R = bar 4
                change_active_hotbar(4)
                gamepad_state.active_bar = 4
            end
        else
            change_active_hotbar(3)
            gamepad_state.active_bar = 3
        end
    else
        gamepad_state.active_bar = 0
    end

    if (not gamepad_mapper.is_showing and gamepad_state.capturing and gamepad.is_minus(dik) and pressed) then
        if (action_binder.is_hidden) then
            action_binder:show()
            ui:hide_button_hints()
            env_chooser:temp_hide_default_sets_tooltip()
        else
            action_binder:hide()
            action_binder:reset_state()
            ui:maybe_show_button_hints()
            env_chooser:maybe_unhide_default_sets_tooltip()
        end
        return true
    end

    if (gamepad_mapper.is_showing) then
        if (gamepad.is_face_button_or_dpad(dik)) then
            if (gamepad.is_button_b(dik)) then
                gamepad_mapper:button_b(pressed)
            elseif (gamepad.is_button_a(dik)) then
                gamepad_mapper:button_a(pressed)
            elseif (gamepad.is_button_x(dik)) then
                gamepad_mapper:button_x(pressed)
            elseif (gamepad.is_button_y(dik)) then
                gamepad_mapper:button_y(pressed)
            end
            return true
        end

        if (gamepad.is_left_trigger(dik)) then
            gamepad_mapper:trigger_left(pressed)
        elseif (gamepad.is_right_trigger(dik)) then
            gamepad_mapper:trigger_right(pressed)
        end
    elseif (not action_binder.is_hidden) then
        if (gamepad_state.capturing) then
            if (gamepad.is_face_button_or_dpad(dik)) then
                local action_binder_was_showing = not action_binder.is_hidden

                if (gamepad.is_dpad_left(dik)) then
                    action_binder:dpad_left(pressed)
                elseif (gamepad.is_dpad_down(dik)) then
                    action_binder:dpad_down(pressed)
                elseif (gamepad.is_dpad_right(dik)) then
                    action_binder:dpad_right(pressed)
                elseif (gamepad.is_dpad_up(dik)) then
                    action_binder:dpad_up(pressed)
                elseif (gamepad.is_button_b(dik)) then
                    action_binder:button_b(pressed)
                elseif (gamepad.is_button_a(dik)) then
                    action_binder:button_a(pressed)
                elseif (gamepad.is_button_x(dik)) then
                    action_binder:button_x(pressed)
                elseif (gamepad.is_button_y(dik)) then
                    action_binder:button_y(pressed)
                end
                if (action_binder_was_showing and action_binder.is_hidden) then
                    ui:maybe_show_button_hints()
                end
                return true
            end

            if (gamepad.is_left_trigger(dik)) then
                action_binder:trigger_left(pressed)
            elseif (gamepad.is_right_trigger(dik)) then
                action_binder:trigger_right(pressed)
            end
        end
    end

    if (env_chooser:is_showing() and pressed) then
        -- handle up and down arrows if the environment chooser is showing
        if gamepad_state.capturing and gamepad.is_dpad_down(dik) then
            local prev_environment = env_chooser:get_prev_environment(player.hotbar, player.hotbar_settings.active_environment)
            set_active_environment(prev_environment)
            env_chooser:show_player_environments(player.hotbar, player.hotbar_settings.active_environment)
            return true
        elseif gamepad_state.capturing and gamepad.is_dpad_up(dik) then -- up dpad
            local next_environment = env_chooser:get_next_environment(player.hotbar, player.hotbar_settings.active_environment)
            set_active_environment(next_environment)
            env_chooser:show_player_environments(player.hotbar, player.hotbar_settings.active_environment)
            return true
        end
    end

    local any_trigger_down = gamepad_state.left_trigger or gamepad_state.right_trigger
    if (gamepad_state.capturing and any_trigger_down and gamepad.is_face_button_or_dpad(dik)) then
        if (pressed) then
            if (gamepad.is_dpad_left(dik)) then
                trigger_action(1)
            elseif (gamepad.is_dpad_down(dik)) then
                trigger_action(2)
            elseif (gamepad.is_dpad_right(dik)) then
                trigger_action(3)
            elseif (gamepad.is_dpad_up(dik)) then
                trigger_action(4)
            elseif (gamepad.is_button_b(dik)) then
                trigger_action(5)
            elseif (gamepad.is_button_a(dik)) then
                trigger_action(6)
            elseif (gamepad.is_button_x(dik)) then
                trigger_action(7)
            elseif (gamepad.is_button_y(dik)) then
                trigger_action(8)
            end

            if (not (gamepad.is_plus(dik) or gamepad.is_minus(dik))) then
                return true
            end
        end
    end

    if (gamepad_state.capturing and gamepad.is_plus(dik)) then
        if (pressed) then
            local environments = env_chooser:get_player_environments(player.hotbar)
            env_chooser:show_player_environments(player.hotbar, player.hotbar_settings.active_environment)
        else
            env_chooser:hide_player_environments()
        end
    end
end)

local frame = 0

-- ON PRERENDER
windower.register_event('prerender',function()
    -- allow settings to skip rendering frames
    frame = (frame + 1)  % (theme_options.frame_skip + 1)
    if (frame > 0 and not ui_dirty) then
        return
    end

    skillchains.prerender()
    if xivcrossbar.ready == false then
        return
    end

    if ui.feedback.is_active then
        ui:show_feedback()
    end

    if ui.is_setup and xivcrossbar.hide_hotbars == false then
        local dim_default_slots = not action_binder.is_hidden        
        ui:check_recasts(player.hotbar, player.vitals, player.hotbar_settings.active_environment, player.current_spells, gamepad_state, skillchains, consumables, dim_default_slots, xivcrossbar.in_battle)
    end

    ui_dirty = false
end)

-- ON ACTIONS (filtered to Job Abilities)
windower.register_event('action', function(actor_id, category)
    if (actor_id == player:get_id() and category == 6) then -- category 6 = Job Ability
        player:update_current_spells()
    end
end)

-- EVERY VANA'DIEL MINUTE
windower.register_event('time change', function(actor_id, category)
    player:update_current_spells()
end)

-- ON MP CHANGE
windower.register_event('mp change', function(new, old)
    player.vitals.mp = new
    ui:check_vitals(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end)

-- ON TP CHANGE
windower.register_event('tp change', function(new, old)
    player.vitals.tp = new
    ui:check_vitals(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end)

-- ON STATUS CHANGE
windower.register_event('status change', function(new_status_id)
    -- hide/show bar in cutscenes
    if xivcrossbar.hide_hotbars == false and new_status_id == 4 then
        xivcrossbar.hide_hotbars = true
        ui:hide()
    elseif xivcrossbar.hide_hotbars and new_status_id ~= 4 then
        xivcrossbar.hide_hotbars = false
        ui:show(player.hotbar, player.hotbar_settings.active_environment)
    end

    -- Disabling this for now, but we might want it later
    -- -- alternate environment on battle
    if xivcrossbar.in_battle == false and (new_status_id == 1 or new_status_id == 3) then
        xivcrossbar.in_battle = true
        player:set_is_in_battle(true)
    --     set_battle_environment(true)
    elseif xivcrossbar.in_battle and new_status_id ~= 1 and new_status_id ~= 3 then
        xivcrossbar.in_battle = false
        player:set_is_in_battle(false)
    --     set_battle_environment(false)
    end
end)

-- ON JOB CHANGE
windower.register_event('job change',function(main_job, main_job_level, sub_job, sub_job_level)
    skillchains.job_change(main_job, main_job_level)
    player:update_jobs(resources.jobs[main_job].ens, resources.jobs[sub_job].ens)
    reload_hotbar()
end)

windower.register_event('incoming chunk', function(id, data)
    skillchains.incoming_chunk(id, data)
end)

windower.register_event('zone change', function()
    skillchains.zone_change()
end)
