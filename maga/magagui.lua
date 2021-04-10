--[[
TODOs: 
	- Creating aug sets...
	
	- Buttons for Accept, Cancel, Continue when aug conditions are met
	- Toggle button for Start/Stop
	- Buttons for Accept, Cancel when stopped
	
]]

require('tables')
require('sets')
require('Modes')
require('GUI')
inspect = require('inspect')

pellucid_state = false
taupe_state = false
fern_state = false
amounts = nil
start_state = false
accept_state = false
continue_state = false
cancel_state = false
initialized = false

function send_maga_command(cmd)
	if not cmd then return end
	cmd = 'maga '..cmd
	--log(cmd)
	windower.send_command(cmd)
end

function hide_GUI()
	if not initialized then
		return
	end
	
	buttons_settings_dividor:hide()
	
	startstop_label:hide()
	start_button:hide()
	
	pellucid_toggle:hide()
	pellucid_toggle_label:hide()
	
	taupe_toggle:hide()
	taupe_toggle_label:hide()
	
	fern_toggle:hide()
	fern_toggle_label:hide()
	
	--settings_label:hide()
	style_dropdown:hide()
	style_display:hide()
	
	--add_augment_label:hide()
	sets_dropdown:hide()
	augs_dropdown:hide()
	
	if amount_dropdown then amount_dropdown:hide() end
	
	hide_option_buttons()
end

function show_GUI()
	if not initialized then
		initialize_GUI()
		return
	end
	
	buttons_settings_dividor:show()
	
	startstop_label:show()
	start_button:show()
	
	pellucid_toggle:show()
	pellucid_toggle_label:show()
	
	taupe_toggle:show()
	taupe_toggle_label:show()
	
	fern_toggle:show()
	fern_toggle_label:show()
	
	--settings_label:show()
	style_dropdown:show()
	style_display:show()
	
	--add_augment_label:show()
	sets_dropdown:show()
	augs_dropdown:show()
	
	if amount_dropdown then amount_dropdown:show() end
	
	show_option_buttons()
end

function initialize_GUI()
	if initialized then
		show_GUI()
	end
	
	if not amounts then
		amounts = L{['description'] = ' Select Amount', '    AMOUNT'}
		amounts:append('remove')
		for i=1, 40 do amounts:append(tostring(i)) end
	end
	
	pellucid_state = settings.pellucid
	taupe_state = settings.taupe
	fern_state = settings.fern
	setup_checkboxes()
	setup_dropdowns()
	
	buttons_settings_dividor = Divider({
		x = settings.display.pos.x - 76,
		y = settings.display.pos.y - 33,
		size = 765
	})
	buttons_settings_dividor:draw()
	
	setup_start_stop_button()
	initialized = true
	
	--show_option_buttons()
end

function setup_start_stop_button()
	startstop_label = PassiveText({
		x = settings.display.pos.x - 58,
		y = settings.display.pos.y - 91,
		color = {255, 201, 255, 77},
		stroke_color = {200, 0, 0, 0},
		text = 'Start/Stop',
	})
	startstop_label:draw()

	start_button = ToggleButton {
		x = settings.display.pos.x - 51,
		y = settings.display.pos.y - 80,
		var = 'start_state',
		iconUp = 'start.png',
		iconDown = 'stop.png',
		command = function()
			if start_state then
				local has_augs_set = false
				if augments then
					for i,set in ipairs(augments) do
						if T(set):length() > 0 then
							has_augs_set = true
							break
						end
					end
				end
				
				if has_augs_set then
					send_maga_command('start')
				else
					start_state = false
					error('No augments added. Start aborted.')
				end
			else
				if status.gear then
					send_maga_command('stop')
				end
			end
		end
	}
	start_button:draw()
end

function setup_checkboxes()
	pellucid_toggle = ToggleButton{
		x = settings.display.pos.x + 70,
		y = settings.display.pos.y - 30,
		var = 'pellucid_state', 
		iconUp = 'uncheck.png',
		iconDown = 'check.png',
		command = function()
			send_maga_command('pellucid')
		end
	}
	pellucid_toggle:draw()
	
	pellucid_toggle_label = PassiveText({
		x = settings.display.pos.x + 95,
		y = settings.display.pos.y - 26,
		text = 'Pellucid',
	})
	pellucid_toggle_label:draw()
	
	
	
	taupe_toggle = ToggleButton{
		x = settings.display.pos.x + 150,
		y = settings.display.pos.y - 30,
		var = 'taupe_state',
		iconUp = 'uncheck.png',
		iconDown = 'check.png',
		command = function() 
			send_maga_command('taupe')
		end
	}
	taupe_toggle:draw()
	
	taupe_toggle_label = PassiveText({
		x = settings.display.pos.x + 175,
		y = settings.display.pos.y - 26,
		text = 'Taupe',
	})
	taupe_toggle_label:draw()
	
	
	
	fern_toggle = ToggleButton{
		x = settings.display.pos.x + 220,
		y = settings.display.pos.y - 30,
		var = 'fern_state',
		iconUp = 'uncheck.png',
		iconDown = 'check.png',
		command = function() 
			send_maga_command('fern')
		end
	}
	fern_toggle:draw()
	
	fern_toggle_label = PassiveText({
		x = settings.display.pos.x + 245,
		y = settings.display.pos.y - 26,
		text = 'Fern',
	})
	fern_toggle_label:draw()
end

function setup_dropdowns()
	-- settings_label = PassiveText({
		-- x = settings.display.pos.x - 70,
		-- y = settings.display.pos.y - 50,
		-- text = 'Settings:',
	-- })
	-- settings_label:draw()
	
	-- add_augment_label = PassiveText({
		-- x = settings.display.pos.x + 290,
		-- y = settings.display.pos.y - 50,
		-- text = 'Add augment:',
	-- })
	-- add_augment_label:draw()
	
	style_display = PassiveText({
			x = settings.display.pos.x + 5,
			y = settings.display.pos.y - 26,
			text = '  %s',
			align = 'left'
		},
		function()
			if settings.style then
				return settings.style
			end
		end
	)
	style_display:draw()
	
	local style_list = L{['description'] = 'Select Style', ' STYLE'}
	style_list:append("melee")
	style_list:append("magic")
	style_list:append("familiar")
	style_list:append("ranged")
	style_list:append("healing")
	style_dropdown_options = { M(style_list) }
	style_dropdown = Combobox {
		x = settings.display.pos.x - 61,
		y = settings.display.pos.y - 28,
		size = 10,
		width = 62,
		bold = true,
		var = style_dropdown_options[1],
		callback = (
			function(style_selected)
				if style_selected:startswith(' ') then return end
				send_maga_command('style '..style_selected)
			end
		),
	}
	draw_cb(style_dropdown)
	
	
	local set_list = L{'1','2','3','4','5','NEW'} -- L{['description'] = 'Select Set', ' SET'}
	sets_dropdown_options = { M(set_list) }
	sets_dropdown = Combobox {
		x = settings.display.pos.x + 300,
		y = settings.display.pos.y - 28,
		size = 10,
		width = 50,
		bold = true,
		var = sets_dropdown_options[1],
		callback = (
			function(set_selected) 
				if set_selected == 'NEW' then
					if augments:length() < 5 then
						send_maga_command('newset')
					else
						notice('Max sets reached.')
					end
				end
			end
		),
	}
	draw_cb(sets_dropdown)
	sets_dropdown._track._state = '1'
	
	
	local aug_list = L{['description'] = 'Select Augment', '                  AUGMENTS'}
	aug_list = extdata.distinct_aug_names(aug_list, true)
	aug_list:append('CLEAR SET')
	--aug_list:append('DELETE SET')
	augs_dropdown_options = { M(aug_list) }
	augs_dropdown = Combobox {
		x = settings.display.pos.x + 350,
		y = settings.display.pos.y - 28,
		size = 10,
		width = 235,
		bold = true,
		var = augs_dropdown_options[1],
		callback = augs_dropdown_callback,
	}
	draw_cb(augs_dropdown)
end

augs_dropdown_callback = function(aug_selected)
	if amount_dropdown then
		amount_dropdown:undraw()
		amount_dropdown = nil
	end
	
	if aug_selected:startswith(' ') then return end
	if aug_selected == 'DELETE SET' then
		send_maga_command('delset '..sets_dropdown._track._state)
		return
	end
	if aug_selected == 'CLEAR SET' then
		send_maga_command('clear '..sets_dropdown._track._state)
		return
	end				
	
	amount_dropdown_options = { M(amounts) }
	amount_dropdown = Combobox {
		x = settings.display.pos.x + 585,
		y = settings.display.pos.y - 28,
		size = 10,
		width = 100,
		bold = true,
		var = amount_dropdown_options[1],
		callback = (
			function(amount_selected)
				if amount_selected:startswith(' ') then return end
				
				local setnum = sets_dropdown._track._state
				local augname = augs_dropdown._track._state
				if tonumber(amount_selected) then
					send_maga_command('add "'..augname..'" '..amount_selected..' '..setnum)
				else
					if augments[setnum] then
						send_maga_command('remove "'..augname..'" '..setnum)
					end
				end
			end
		)
	}
	draw_cb(amount_dropdown)
end


function draw_cb(cb)
	cb:draw()
	if settings.gui.hide_combobox_bg then
		windower.prim.set_visibility(tostring(cb)..' mid', false)
	end
end


function setup_option_buttons()
	--options background
	option_buttons_area = 'option_buttons area'
	windower.prim.create(option_buttons_area)
	windower.prim.set_visibility(option_buttons_area, true)
	windower.prim.set_position(option_buttons_area, settings.display.pos.x + 28, settings.display.pos.y - 91)
	windower.prim.set_color(option_buttons_area, 70, 236, 112, 99)
	windower.prim.set_size(option_buttons_area, 177, 50)
	
	-- ACCEPT
	accept_label = PassiveText({
		x = settings.display.pos.x + 35,
		y = settings.display.pos.y - 90,
		color = {255, 0, 209, 6},
		stroke_color = {200, 0, 0, 0},
		text = 'ACCEPT',
	})
	accept_label:draw()

	accept_button = ToggleButton {
		x = settings.display.pos.x + 37,
		y = settings.display.pos.y - 77,
		var = 'accept_state',
		iconUp = 'accept.png',
		iconDown = 'accept.png',
		command = function()
			if accept_state then
				send_maga_command('accept')
				accept_button:unpress()
				hide_option_buttons()
			end
		end
	}
	accept_button:draw()
	
	-- CONTINUE
	continue_label = PassiveText({
		x = settings.display.pos.x + 90,
		y = settings.display.pos.y - 90,
		color = {255, 91, 210, 255},
		stroke_color = {200, 0, 0, 0},
		text = 'CONTINUE',
	})
	continue_label:draw()

	continue_button = ToggleButton {
		x = settings.display.pos.x + 98,
		y = settings.display.pos.y - 80,
		var = 'accept_state',
		iconUp = 'continue.png',
		iconDown = 'continue.png',
		command = function()
			if accept_state then
				send_maga_command('continue')
				continue_button:unpress()
				hide_option_buttons()
			end
		end
	}
	continue_button:draw()
	
	-- CANCEL
	cancel_label = PassiveText({
		x = settings.display.pos.x + 157,
		y = settings.display.pos.y - 90,
		color = {255, 255, 77, 0},
		stroke_color = {200, 0, 0, 0},
		text = 'CANCEL',
	})
	cancel_label:draw()

	cancel_button = ToggleButton {
		x = settings.display.pos.x + 157,
		y = settings.display.pos.y - 80,
		var = 'accept_state',
		iconUp = 'cancel.png',
		iconDown = 'cancel.png',
		command = function()
			if accept_state then
				send_maga_command('cancel')
				cancel_button:unpress()
				hide_option_buttons()
			end
		end
	}
	cancel_button:draw()
	
	option_buttons_created = true
end

function show_option_buttons(keep_continue_hidden)
	if not option_buttons_created then
		setup_option_buttons()
		if keep_continue_hidden then
			continue_label:hide()
			continue_button:hide()
		end
		return
	end
	accept_label:show()
	accept_button:show()
	
	if not keep_continue_hidden then
		continue_label:show()
		continue_button:show()
	end
	
	cancel_label:show()
	cancel_button:show()
	
	windower.prim.set_visibility(option_buttons_area, true)
end

function hide_option_buttons()	
	if not option_buttons_created then
		return
	end
		
	accept_label:hide()
	accept_button:hide()
	
	continue_label:hide()
	continue_button:hide()
	
	cancel_label:hide()
	cancel_button:hide()
	
	windower.prim.set_visibility(option_buttons_area, false)
end




