local database = require('database')

local ui = {}

local text_setup = {
    flags = {
        draggable = false
    }
}

local right_text_setup = {
    flags = {
        right = true,
        draggable = false
    }
}

local images_setup = {
    draggable = false
}

local spellsThatRequireJA = require('spells_that_require_ja')

-- ui metrics
ui.hotbar_width = 0
ui.hotbar_spacing = 0
ui.slot_spacing = 0
ui.pos_x = 0
ui.pos_y = 0

-- ui variables
ui.battle_notice = images.new(images_setup)
ui.feedback_icon = nil
ui.hotbars = {}

-- ui theme options
ui.theme = {}

-- ui control
ui.feedback = {}
ui.feedback.is_active = false
ui.feedback.current_opacity = 0
ui.feedback.max_opacity = 0
ui.feedback.speed = 0

ui.disabled_slots = {}
ui.disabled_slots.actions = {}
ui.disabled_slots.no_vitals = {}
ui.disabled_slots.on_cooldown = {}
ui.disabled_slots.on_warmup = {}

local animation_frame_count = 0

ui.is_setup = false
-----------------------------
-- Helpers
-----------------------------

local wpn_img_ids = {
    ['H2H']          = 0,
    ['Dagger']       = 1,
    ['Sword']        = 2,
    ['Great Sword']  = 3,
    ['Axe']          = 4,
    ['Great Axe']    = 5,
    ['Scythe']       = 6,
    ['Polearm']      = 7,
    ['Katana']       = 8,
    ['Great Katana'] = 9,
    ['Club']         = 10,
    ['Staff']        = 11,
    ['Bow']          = 12,
    ['Marksmanship'] = 13
}

function map_ws(ws_id)
    image_id = 0
    if     ws_id >  0   and ws_id <  16  then image_id = wpn_img_ids['H2H']
    elseif ws_id >  16  and ws_id <  32  then image_id = wpn_img_ids['Dagger'] 
    elseif ws_id >  32  and ws_id <= 47  then image_id = wpn_img_ids['Sword'] 
    elseif ws_id >  48  and ws_id <= 61  then image_id = wpn_img_ids['Great Sword']
    elseif ws_id >  64  and ws_id <= 77  then image_id = wpn_img_ids['Axe']
    elseif ws_id >  79  and ws_id <= 93  then image_id = wpn_img_ids['Great Axe']
    elseif ws_id >  95  and ws_id <= 109 then image_id = wpn_img_ids['Scythe']
    elseif ws_id >  112 and ws_id <= 125 then image_id = wpn_img_ids['Polearm']
    elseif ws_id >  127 and ws_id <= 141 then image_id = wpn_img_ids['Katana']
    elseif ws_id >  144 and ws_id <= 158 then image_id = wpn_img_ids['Great Katana']
    elseif ws_id >  158 and ws_id <= 176 then image_id = wpn_img_ids['Club']
    elseif ws_id >  176 and ws_id <= 191 then image_id = wpn_img_ids['Staff']
    elseif ws_id >  191 and ws_id <= 203 then image_id = wpn_img_ids['Bow']
    elseif ws_id >  203 and ws_id <= 221 then image_id = wpn_img_ids['Marksmanship']
    elseif ws_id == 224                  then image_id = wpn_img_ids['Dagger']
    elseif ws_id >  224 and ws_id <= 255 then image_id = wpn_img_ids['Sword']
    end
	
	return image_id
end

-- setup images
function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:alpha(255)
    image:show()
end

-- setup text
function setup_text(text, theme_options)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(theme_options.font)
    text:size(theme_options.font_size)
    text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
    text:stroke_transparency(theme_options.font_stroke_alpha)
    text:stroke_color(theme_options.font_stroke_color_red, theme_options.font_stroke_color_green, theme_options.font_stroke_color_blue)
    text:stroke_width(theme_options.font_stroke_width)
    text:show()
end

local kebab_casify = function(str)
    return str:lower():gsub('/', '\n'):gsub(':', ''):gsub('%p', ''):gsub(' ', '-'):gsub('\n', '/'):gsub("'", '')
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

-- get x position for a given hotbar and slot
function ui:get_slot_x(h, i)
    local base = self.pos_x - 50
    if (h == 2) then
        base = base + 300
    elseif (h > 2) then
        base = base + 150
    end

    -- move the last icon in each group of 4 to the middle create the cross
    -- move icon 9 to the left cross's center to be the dpad icon
    -- move icon 10 to the right cross's center to be the face buttons icon
    local column = i
    if (i == 4) then
        column = 2
    elseif (i == 9) then
        column = 3
    elseif (i == 8 or i == 10) then
        column = 6
    end

    -- shift the two crosses closer to each other
    if (i > 4) then
        column = column - 1
    end

    return base + ((40 + self.slot_spacing) * (column - 1))
end

-- get y position for a given hotbar and slot
function ui:get_slot_y(h, i)
    local base = self.pos_y

    -- move the second icon in each group of 4 to the top and move the
    -- fourth icon in each group of 4 to the bottom to create the cross
    local row = 2
    if (i == 2 or i == 6) then
        row = 1
    elseif (i == 4 or i == 8) then
        row = 3
    end
    local spacing = self.hotbar_spacing
    if (self.is_compact) then
        spacing = spacing / 2
    end
    return base - (((row - 1) * spacing))
end

-----------------------------
-- Setup UI
-----------------------------

-- setup ui
function ui:setup(theme_options, enchanted_items)
    self.enchanted_items = enchanted_items
    database:import()

    icon_pack = theme_options.iconpack

    self.frame_skip = theme_options.frame_skip

    self.theme.hide_empty_slots = theme_options.hide_empty_slots
    self.theme.hide_action_names = theme_options.hide_action_names
    self.theme.hide_action_cost = theme_options.hide_action_cost
    self.theme.hide_action_element = theme_options.hide_action_element
    self.theme.hide_recast_animation = theme_options.hide_recast_animation
    self.theme.hide_recast_text = theme_options.hide_recast_text
    self.theme.hide_battle_notice = theme_options.hide_battle_notice

    self.theme.skillchain_window_opacity = theme_options.skillchain_window_opacity
    self.theme.skillchain_waiting_color_red = theme_options.skillchain_waiting_color_red
    self.theme.skillchain_waiting_color_green = theme_options.skillchain_waiting_color_green
    self.theme.skillchain_waiting_color_blue = theme_options.skillchain_waiting_color_blue
    self.theme.skillchain_open_color_red = theme_options.skillchain_open_color_red
    self.theme.skillchain_open_color_green = theme_options.skillchain_open_color_green
    self.theme.skillchain_open_color_blue = theme_options.skillchain_open_color_blue

    self.theme.slot_opacity = theme_options.slot_opacity
    self.theme.disabled_slot_opacity = theme_options.disabled_slot_opacity
    self.theme.hotbar_number = theme_options.hotbar_number

    self.theme.mp_cost_color_red = theme_options.mp_cost_color_red
    self.theme.mp_cost_color_green = theme_options.mp_cost_color_green
    self.theme.mp_cost_color_blue = theme_options.mp_cost_color_blue
    self.theme.tp_cost_color_red = theme_options.tp_cost_color_red
    self.theme.tp_cost_color_green = theme_options.tp_cost_color_green
    self.theme.tp_cost_color_blue = theme_options.tp_cost_color_blue
    self.theme.button_layout = theme_options.button_layout
    self.is_compact = theme_options.is_compact
    self.button_bg_alpha = theme_options.button_background_alpha

    self:setup_metrics(theme_options)
    self:load(theme_options)


    self.is_setup = true
end

-- load the images and text
function ui:load(theme_options)
    -- load battle notice
    setup_image(self.battle_notice, windower.addon_path .. '/themes/' .. (theme_options.battle_notice_theme:lower()) .. '/notice.png')
    self.battle_notice:pos(self.pos_x + self.hotbar_width - 90, self.pos_y - (theme_options.hotbar_spacing * (theme_options.hotbar_number)) - 24)
    self.battle_notice:hide()
    self.frame_image_path = windower.addon_path..'/themes/' .. (theme_options.frame_theme:lower()) .. '/frame.png'

    windower.prim.create('skillchain_indicator_bg')
    windower.prim.set_color('skillchain_indicator_bg', 150, 0, 0, 0)
    windower.prim.set_position('skillchain_indicator_bg', self:get_slot_x(1, 1) - 12, self:get_slot_y(1, 4) - 32)
    windower.prim.set_size('skillchain_indicator_bg', 604, 14)
    windower.prim.set_visibility('skillchain_indicator_bg', false)

    windower.prim.create('skillchain_indicator')
    windower.prim.set_color('skillchain_indicator', 220, 15, 205, 5)
    windower.prim.set_position('skillchain_indicator', self:get_slot_x(1, 1) - 10, self:get_slot_y(1, 4) - 30)
    windower.prim.set_size('skillchain_indicator', 600, 10)
    windower.prim.set_visibility('skillchain_indicator', false)

    self.bar_background = images.new(images_setup)
    if (self.is_compact) then
        self.bar_background:size(330, 180)
        self.bar_background:path(windower.addon_path .. 'images/' .. get_icon_pathbase() .. '/ui/bar_bg_compact.png')
    else
        self.bar_background:size(330, 220)
        self.bar_background:path(windower.addon_path .. 'images/' .. get_icon_pathbase() .. '/ui/bar_bg.png')
    end
    self.bar_background:alpha(self.button_bg_alpha)

    -- setup button ui hints
    self.action_binder_icon = images.new(images_setup)
    self.action_binder_icon:size(40, 40)
    self.action_binder_icon:pos(self:get_slot_x(1, 1) - 10, self:get_slot_y(1, 4) - 27)
    self.action_binder_icon:path(windower.addon_path .. 'images/' .. get_icon_pathbase() .. '/ui/binding_icons/minus_'..self.theme.button_layout..'.png')
    self.action_binder_icon:alpha(255)
    self.action_binder_text = texts.new(text_setup)
    setup_text(self.action_binder_text, theme_options)
    self.action_binder_text:pos(self:get_slot_x(1, 1) + 35, self:get_slot_y(1, 4) - 15)
    self.action_binder_text:text('Bind an action')
    self.environment_selector_icon = images.new(images_setup)
    self.environment_selector_icon:path(windower.addon_path .. 'images/' .. get_icon_pathbase() .. '/ui/binding_icons/plus_'..self.theme.button_layout..'.png')
    self.environment_selector_icon:size(40, 40)
    self.environment_selector_icon:pos(self:get_slot_x(2, 5) - 5, self:get_slot_y(1, 4) - 27)
    self.environment_selector_icon:alpha(255)
    self.environment_selector_text = texts.new(text_setup)
    setup_text(self.environment_selector_text, theme_options)
    self.environment_selector_text:pos(self:get_slot_x(2, 5) + 40, self:get_slot_y(1, 4) - 15)
    self.environment_selector_text:text('Change crossbar sets')
    if (not self.is_compact) then
        self:show_button_hints()
    else
        self:hide_button_hints()
    end

    -- create ui elements for hotbars
    for h=1,theme_options.hotbar_number,1 do
        self.hotbars[h] = {}
        self.hotbars[h].slot_background = {}
        self.hotbars[h].slot_icon = {}
        self.hotbars[h].slot_recast = {}
        self.hotbars[h].slot_warmup = {}
        self.hotbars[h].slot_frame = {}
        self.hotbars[h].slot_element = {}
        self.hotbars[h].slot_text = {}
        self.hotbars[h].slot_cost = {}
        self.hotbars[h].slot_recast_text = {}

        -- set up the highlighting background for when a hotbar is active
        for i=1,8,1 do
            local slot_pos_x = self:get_slot_x(h, i)
            local slot_pos_y = self:get_slot_y(h, i)
            local right_slot_pos_x = slot_pos_x - windower.get_windower_settings().ui_x_res + 16

            self.hotbars[h].slot_background[i] = images.new(images_setup)
            self.hotbars[h].slot_warmup[i] = images.new(images_setup)
            self.hotbars[h].slot_icon[i] = images.new(images_setup)
            self.hotbars[h].slot_recast[i] = images.new(images_setup)
            self.hotbars[h].slot_frame[i] = images.new(images_setup)
            self.hotbars[h].slot_element[i] = images.new(images_setup)
            self.hotbars[h].slot_text[i] = texts.new(text_setup)
            self.hotbars[h].slot_cost[i] = texts.new(right_text_setup)
            self.hotbars[h].slot_recast_text[i] = texts.new(right_text_setup)
            self.hotbars[h].slot_icon[i]:size(30, 30)
        
            setup_image(self.hotbars[h].slot_background[i], windower.addon_path..'/themes/' .. (theme_options.slot_theme:lower()) .. '/slot.png')
            setup_image(self.hotbars[h].slot_icon[i], windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/blank.png')
            setup_image(self.hotbars[h].slot_frame[i], self.frame_image_path)
            setup_image(self.hotbars[h].slot_element[i], windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/blank.png')
            setup_text(self.hotbars[h].slot_text[i], theme_options)
            setup_text(self.hotbars[h].slot_cost[i], theme_options)
            setup_text(self.hotbars[h].slot_recast_text[i], theme_options)

            self.hotbars[h].slot_cost[i]:size(8)
            self.hotbars[h].slot_cost[i]:stroke_transparency(220)
            self.hotbars[h].slot_background[i]:alpha(theme_options.slot_opacity)
            self.hotbars[h].slot_background[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_icon[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_frame[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_element[i]:pos(slot_pos_x + 28, slot_pos_y - 4)

            self.hotbars[h].slot_text[i]:pos(slot_pos_x - 2, slot_pos_y + 40)
            self.hotbars[h].slot_cost[i]:pos(right_slot_pos_x + 30, slot_pos_y + 28)
            self.hotbars[h].slot_recast_text[i]:pos(right_slot_pos_x + 20, slot_pos_y + 14)
            self.hotbars[h].slot_recast_text[i]:size(9)
        end

        -- special stuff for dpad and face buttons icons
        self.hotbars[h].slot_recast[9] = images.new(images_setup)
        self.hotbars[h].slot_recast[10] = images.new(images_setup)
    end

    -- load feedback icon last so it stays above everything else
    self.feedback_icon = images.new(images_setup)
    setup_image(self.feedback_icon, windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/feedback.png')
    self.feedback.max_opacity = theme_options.feedback_max_opacity
    self.feedback.speed = theme_options.feedback_speed
    self.feedback.current_opacity = self.feedback.max_opacity
    self.feedback_icon:hide()
end

-- setup positions and dimensions for ui
function ui:setup_metrics(theme_options)
    self.hotbar_width = (400 + theme_options.slot_spacing * 9)
    self.pos_x = (windower.get_windower_settings().ui_x_res / 2) - (self.hotbar_width / 2) + theme_options.offset_x
    self.pos_y = (windower.get_windower_settings().ui_y_res - 120) + theme_options.offset_y

    self.slot_spacing = theme_options.slot_spacing

    if theme_options.hide_action_names == true then
        theme_options.hotbar_spacing = theme_options.hotbar_spacing - 10
        self.pos_y = self.pos_y + 10
    end

    self.hotbar_spacing = theme_options.hotbar_spacing
end

-- hide all ui components
function ui:hide()
    self.battle_notice:hide()
    self.feedback_icon:hide()

    self:hide_button_hints()

    for h=1,self.theme.hotbar_number,1 do
        for i=1,8,1 do
            self.hotbars[h].slot_background[i]:hide()
            self.hotbars[h].slot_warmup[i]:hide()
            self.hotbars[h].slot_icon[i]:hide()
            self.hotbars[h].slot_frame[i]:hide()
            self.hotbars[h].slot_recast[i]:hide()
            self.hotbars[h].slot_element[i]:hide()
            self.hotbars[h].slot_text[i]:hide()
            self.hotbars[h].slot_cost[i]:hide()
            self.hotbars[h].slot_recast_text[i]:hide()
            -- self.hotbars[h].slot_key[i]:hide()
        end

        local dpadSlot = 9;
        local faceSlot = 10;
        self.hotbars[h].slot_recast[dpadSlot]:hide()
        self.hotbars[h].slot_recast[faceSlot]:hide()
    end
end

function ui:hide_button_hints()
    self.action_binder_icon:hide()
    self.action_binder_text:hide()
    self.environment_selector_icon:hide()
    self.environment_selector_text:hide()
end

-- show ui components
function ui:show(player_hotbar, environment)
    if self.theme.hide_battle_notice == false and environment == 'battle' then self.battle_notice:show() end

    self:maybe_show_button_hints()

    for h=1,self.theme.hotbar_number,1 do
        for i=1,8,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            if (action == nil or action.action == nil) then
                action = maybe_get_default_action(player_hotbar, environment, h, slot)
            end

            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_background[i]:show() end
            self.hotbars[h].slot_icon[i]:show()
            if action ~= nil then self.hotbars[h].slot_frame[i]:show() end
            if self.theme.hide_recast_animation == false then self.hotbars[h].slot_recast[i]:show() end
            if self.theme.hide_recast_animation == false then self.hotbars[h].slot_warmup[i]:show() end
            if self.theme.hide_action_element == false then self.hotbars[h].slot_element[i]:show() end
            if self.theme.hide_action_names == false then self.hotbars[h].slot_text[i]:show() end
            if self.theme.hide_action_cost == false then self.hotbars[h].slot_cost[i]:show() end
            if self.theme.hide_recast_text == false then self.hotbars[h].slot_recast_text[i]:show() end
            -- if self.theme.hide_empty_slots == false then self.hotbars[h].slot_key[i]:show() end
        end
    end
end

function ui:maybe_show_button_hints()
    if (not self.is_compact) then
        self:show_button_hints()
    end
end

function ui:show_button_hints()
    self.action_binder_icon:show()
    self.action_binder_text:show()
    self.environment_selector_icon:show()
    self.environment_selector_text:show()
end

function ui:show_bar_background(hotbar_number)
    self.bar_background:pos(self:get_slot_x(hotbar_number, 1) - 30, self:get_slot_y(hotbar_number, 4) - 35)
    self.bar_background:show()
end

-----------------------------
-- Actions UI
-----------------------------

-- load player hotbar
function ui:load_player_hotbar(player_hotbar, player_vitals, environment, gamepad_state)
    if environment == 'battle' and self.theme.hide_battle_notice == false then
        self.battle_notice:show()
    else
        self.battle_notice:hide()
    end

    -- reset disabled slots
    self.disabled_slots.actions = {}
    self.disabled_slots.no_vitals = {}
    self.disabled_slots.on_cooldown = {}
    self.disabled_slots.on_warmup = {}

    for h=1,self.theme.hotbar_number,1 do
        local shouldDrawThisBar = (gamepad_state.active_bar < 3 and (h == 1 or h == 2)) or (gamepad_state.active_bar == h)
        for slot=1,8,1 do
            local action = nil

            if (player_hotbar[environment] and player_hotbar[environment]['hotbar_' .. h] and
                player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]) then
                action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]
            end

            self:load_action(player_hotbar, environment, h, slot, action, player_vitals, shouldDrawThisBar)
        end
    end
end

local SPELL_TYPE_LOOKUP = {
    ['BardSong'] = 'songs',
    ['BlackMagic'] = 'spells',
    ['BlueMagic'] = 'blue magic',
    ['WhiteMagic'] = 'spells',
    ['SummonerPact'] = 'avatars',
	['Geomancy'] = 'geomancy',
}

local JOB_ABILITY_TYPE_LOOKUP = {
    ['BloodPactRage'] = 'blood pacts/rage',
    ['BloodPactWard'] = 'blood pacts/ward',
    ['CorsairRoll'] = 'phantom rolls',
    ['CorsairShot'] = 'quick draw',
    ['Effusion'] = 'effusions',
    ['Flourish1'] = 'dances',
    ['Flourish2'] = 'dances',
    ['Flourish3'] = 'dances',
    ['Jig'] = 'dances',
    ['JobAbility'] = 'abilities',
    ['Monster'] = 'ready',
	['PetCommand'] = 'petcommands',
    ['Rune'] = 'rune-enchantments',
    ['Samba'] = 'dances',
    ['Scholar'] = 'stratagems',
    ['Step'] = 'dances',
    ['Waltz'] = 'dances',
    ['Ward'] = 'wards',
}

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

-- load action into a hotbar slot
function ui:load_action(player_hotbar, environment, hotbar, slot, action, player_vitals, show_when_ready)
    local is_disabled = false

    self:clear_slot(hotbar, slot)

    local icon_overridden = false

    -- if slot is empty, check if there is an entry in the default crossbar
    if (action == nil or action.action == nil) then
        action = maybe_get_default_action(player_hotbar, environment, hotbar, slot)

        -- if default crossbar slot is empty, then hide the slot
        if (action == nil) then
            if self.theme.hide_empty_slots == true then
                self.hotbars[hotbar].slot_background[slot]:hide()
            else
                self.hotbars[hotbar].slot_background[slot]:show()
            end

            return
        end
    end

    -- if slot has a skill (ma, ja, pet or ws)
    if action.type == 'ma' or action.type == 'ja' or action.type == 'ws' or action.type == 'enchanteditem' or action.type == 'pet' then
        local skill = nil

        -- if its magic, look for it in spells
        if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
            skill = database.spells[(action.action):lower()]

            local spell = res.spells[tonumber(skill.icon)]
            local magic_skill = res.skills[spell.skill].en
            local category = SPELL_TYPE_LOOKUP[spell.type]
            if (category == nil) then
                category = spell.type
            end
            local icon_path = maybe_get_custom_icon(category, action.action)
            if (icon_path ~= nil) then
                icon_overridden = true
                icon_path = 'images/' .. icon_path
            else
				if spell.type == "BardSong" then
					local shortname = get_song_short_name(action.action)
					if shortname ~= nil then
						icon_path = maybe_get_custom_icon(category, shortname)
						if icon_path ~= nil then
							icon_overridden = true
							icon_path = 'images/' .. icon_path
						end
					end
				end
				
				if icon_path == nil then
					icon_path = '/images/icons/spells/' .. (string.format("%05d", skill.icon)) .. '.png'
				end
            end
            self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. icon_path)
        elseif (action.type == 'ja' or action.type == 'ws' or action.type == 'pet') and database.abilities[(action.action):lower()] ~= nil then
            skill = database.abilities[(action.action):lower()]

            if action.type == 'ja' or action.type == 'pet' then
                local category = JOB_ABILITY_TYPE_LOOKUP[skill.type]
                local icon_path = maybe_get_custom_icon(category, action.action)
                if (icon_path ~= nil) then
                    icon_overridden = true
                    icon_path = 'images/' .. icon_path
                else
					if action.type == 'pet' and skill.element ~= nil and (skill.type == 'BloodPactRage' or skill.type == 'BloodPactWard') then
						icon_path = '/images/icons/spells/' .. string.format("%05d", get_spirit_by_element(skill.element).id) .. '.png'
					end
					if icon_path == nil then
						icon_path = '/images/icons/abilities/' .. (string.format("%05d", skill.icon)) .. '.png'
					end
                end
                self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. icon_path)
            else
                if (skill.id ~= nil) then
                    local ws = res.weapon_skills[tonumber(skill.id)]
                    local weapon = res.skills[ws.skill].en:lower()
                    local icon_path = maybe_get_custom_icon('weaponskills/' .. weapon, ws.en)
                    if (icon_path ~= nil) then
                        icon_overridden = true
                        icon_path = 'images/' .. icon_path
                    else
						local weapon_icon = map_ws(tonumber(skill.id))
                        icon_path = '/images/icons/weapons/' .. (string.format("%02d", weapon_icon)) .. '.jpg'
                    end
                    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. icon_path)
                else
                    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/weapons/sword.png')
                end

                skill.tpcost = '1000'
            end
        elseif (action.type == 'enchanteditem') then
            self.enchanted_items:register(action.action, action.warmup, 2, action.cooldown)
            self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
            self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/items/' .. kebab_casify(action.action) .. '.png')
        end

        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        if (action.type ~= 'enchanteditem' and not icon_overridden) then
            self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot) + 4, self:get_slot_y(hotbar, slot) + 4) -- temporary fix for 32 x 32 icons
        else
            self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot)) -- temporary fix for 32 x 32 icons
        end
        if (show_when_ready) then
            self.hotbars[hotbar].slot_icon[slot]:show()
        end

        if skill ~= nil then
            -- display skill element
            if skill.element ~= nil and skill.element ~= 'None' and skill.element ~= '0' and self.theme.hide_action_element == false then
                self.hotbars[hotbar].slot_element[slot]:path(windower.addon_path .. '/images/icons/elements/' .. skill.element .. '.png')
                if (show_when_ready) then
                    self.hotbars[hotbar].slot_element[slot]:show()
                end
            end

            -- display mp cost
            if skill.mpcost ~= nil and skill.mpcost ~= '0' then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.mp_cost_color_red, self.theme.mp_cost_color_green, self.theme.mp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(skill.mpcost)

                if player_vitals.mp < tonumber(skill.mpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            -- display tp cost
            elseif skill.tpcost ~= nil and skill.tpcost ~= '0' then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.tp_cost_color_red, self.theme.tp_cost_color_green, self.theme.tp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(skill.tpcost)

                if player_vitals.tp < tonumber(skill.tpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            end
        end
    -- if action is an item
    elseif action.type == 'item' then
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))

        local icon_path = maybe_get_custom_icon('items', action.action)
        if (icon_path ~= nil) then
            icon_overridden = true
            icon_path = '/images/' .. icon_path
        elseif (action.usable ~= nil) then
            icon_path = '/images/' .. get_icon_pathbase() .. '/items/' .. kebab_casify(action.action) .. '.png'
        elseif (action.target == 'me') then
            icon_path = '/images/' .. get_icon_pathbase() .. '/usable-item.png'
        else
            icon_path = '/images/' .. get_icon_pathbase() .. '/item.png'
        end
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. icon_path)

        if (show_when_ready) then
            self.hotbars[hotbar].slot_icon[slot]:show()
        end
    elseif (action.type == 'mount') then
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))

        local icon_path = maybe_get_custom_icon('mounts', action.action)
        if (icon_path ~= nil) then
            icon_overridden = true
            icon_path = '/images/' .. icon_path
        else
            icon_path = '/images/' .. get_icon_pathbase() .. '/mount.png'
        end
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. icon_path)
    else
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
    end

    -- if action is custom
    if (not icon_overridden and action.icon ~= nil) then
        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/' .. action.icon .. '.png')
        if (show_when_ready) then
            self.hotbars[hotbar].slot_icon[slot]:show()
        end
    end

    -- check if action is on cooldown
    if self.disabled_slots.on_cooldown[action.action] ~= nil then is_disabled = true end
    if self.disabled_slots.on_warmup[action.action] ~= nil then is_disabled = true end

    if (show_when_ready) then
        self.hotbars[hotbar].slot_frame[slot]:show()
    end
    self.hotbars[hotbar].slot_text[slot]:text(action.alias)

    -- hide elements according to settings
    if self.theme.hide_action_names == true then
        self.hotbars[hotbar].slot_text[slot]:hide()
    elseif (show_when_ready) then
        self.hotbars[hotbar].slot_text[slot]:show()
    end
    if self.theme.hide_action_cost == true then
        self.hotbars[hotbar].slot_cost[slot]:hide()
    elseif (show_when_ready) then
        self.hotbars[hotbar].slot_cost[slot]:show()
    end

    -- if slot is disabled, disable it
    if is_disabled == true then
        self:toggle_slot(hotbar, slot, false)
        self.disabled_slots.actions[action.action] = true
    end
end

-- reset slot
function ui:clear_slot(hotbar, slot)
    self.hotbars[hotbar].slot_background[slot]:alpha(self.theme.slot_opacity)
    self.hotbars[hotbar].slot_frame[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/blank.png')
    self.hotbars[hotbar].slot_icon[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:alpha(255)
    self.hotbars[hotbar].slot_icon[slot]:color(255, 255, 255)
    self.hotbars[hotbar].slot_element[slot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/blank.png')
    self.hotbars[hotbar].slot_element[slot]:alpha(255)
    self.hotbars[hotbar].slot_element[slot]:hide()
    self.hotbars[hotbar].slot_text[slot]:text('')
    self.hotbars[hotbar].slot_cost[slot]:alpha(255)
    self.hotbars[hotbar].slot_cost[slot]:text('')
end

-----------------------------
-- Disabled Slots
-----------------------------

-- check player vitals
function ui:check_vitals(player_hotbar, player_vitals, environment)
    for h=1,self.theme.hotbar_number,1 do
        for i=1,8,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            -- use the default action if this slot is otherwise empty
            if (action == nil or action.action == nil) then
                action = maybe_get_default_action(player_hotbar, environment, h, slot)
            end

            if action ~= nil then
                local skill = nil
                local is_disabled = false

                -- if its magic, look for it in spells
                if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
                    skill = database.spells[(action.action):lower()]
                elseif (action.type == 'ja' or action.type == 'ws') and database.abilities[(action.action):lower()] ~= nil then
                    skill = database.abilities[(action.action):lower()]
                end

                if skill ~= nil then
                    if (skill.mpcost ~= nil and skill.mpcost ~= '0' and player_vitals.mp < tonumber(skill.mpcost)) or (skill.tpcost ~= nil and skill.tpcost ~= '0' and player_vitals.tp < tonumber(skill.tpcost)) then
                        self.disabled_slots.no_vitals[action.action] = true
                        is_disabled = true
                    else
                        self.disabled_slots.no_vitals[action.action] = nil
                    end

                    -- if it's not disabled by vitals nor cooldown, enable slot
                    if is_disabled == false and self.disabled_slots.actions[action.action] == true and self.disabled_slots.on_cooldown[action.action] == nil and self.disabled_slots.on_warmup[action.action] == nil then
                        self.disabled_slots.actions[action.action] = nil
                        self:toggle_slot(h, i, true)
                    end

                    -- if its disabled, disable slot
                    if is_disabled == true and self.disabled_slots.actions[action.action] == nil then
                        self.disabled_slots.actions[action.action] = true
                        self:toggle_slot(h, i, false)
                    end
                end
            end
        end
    end
end

local skillchain_indicator_state = ''

function ui:display_skillchain_indicator(player_vitals, skillchain_delay, skillchain_window)
    local target = windower.ffxi.get_mob_by_target('t', 'bt')
    if (target and target.hpp > 0) then
        if (skillchain_delay > 0) then
            local fraction = skillchain_delay / 3.0
            local base_width = math.round(600 * (1 - fraction))
            local left_spacer = math.round(300 * fraction)

            if (skillchain_indicator_state ~= 'waiting') then
                skillchain_indicator_state = 'waiting'
                windower.prim.set_color('skillchain_indicator',
                    self.theme.skillchain_window_opacity,
                    self.theme.skillchain_waiting_color_red,
                    self.theme.skillchain_waiting_color_green,
                    self.theme.skillchain_waiting_color_blue)
            end
            windower.prim.set_size('skillchain_indicator', base_width, 4)
            windower.prim.set_position('skillchain_indicator', left_spacer + self:get_slot_x(1, 1) - 10, self:get_slot_y(1, 4) - 27)
            windower.prim.set_visibility('skillchain_indicator', true)

            windower.prim.set_size('skillchain_indicator_bg', base_width + 4, 8)
            windower.prim.set_position('skillchain_indicator_bg', left_spacer + self:get_slot_x(1, 1) - 12, self:get_slot_y(1, 4) - 29)
            windower.prim.set_visibility('skillchain_indicator_bg', true)
        elseif (skillchain_window > 0) then
            local fraction = skillchain_window / 7.0
            local base_width = math.round(600 * fraction)
            local left_spacer = math.round(300 * (1 - fraction))

            if (skillchain_indicator_state ~= 'open') then
                skillchain_indicator_state = 'open'
                windower.prim.set_color('skillchain_indicator',
                    self.theme.skillchain_window_opacity,
                    self.theme.skillchain_open_color_red,
                    self.theme.skillchain_open_color_green,
                    self.theme.skillchain_open_color_blue)
            end
            windower.prim.set_size('skillchain_indicator', base_width, 10)
            windower.prim.set_position('skillchain_indicator', left_spacer + self:get_slot_x(1, 1) - 10, self:get_slot_y(1, 4) - 30)
            windower.prim.set_visibility('skillchain_indicator', true)

            windower.prim.set_size('skillchain_indicator_bg', base_width + 4, 14)
            windower.prim.set_position('skillchain_indicator_bg', left_spacer + self:get_slot_x(1, 1) - 12, self:get_slot_y(1, 4) - 32)
            windower.prim.set_visibility('skillchain_indicator_bg', true)
        else
            windower.prim.set_visibility('skillchain_indicator', false)
            windower.prim.set_visibility('skillchain_indicator_bg', false)
        end
    else
        windower.prim.set_visibility('skillchain_indicator', false)
        windower.prim.set_visibility('skillchain_indicator_bg', false)
    end
end

local last_log = os.clock()

function ui:mark_default_set_action(h, i, environment)
    if (environment ~= nil) then
        self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/' .. environment ..'.png')
        self.hotbars[h].slot_recast[i]:alpha(255)
        self.hotbars[h].slot_recast[i]:size(40, 40)
        self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i))
        self.hotbars[h].slot_recast[i]:show()
        self.hotbars[h].slot_recast_text[i]:hide()
        self.hotbars[h].slot_cost[i]:hide()
    end
end

-- check action recasts
function ui:check_recasts(player_hotbar, player_vitals, environment, spells, gamepad_state, skillchains, consumables, dim_default_slots, in_battle)
    animation_frame_count = animation_frame_count + self.frame_skip + 1
    if (animation_frame_count > 40) then
        animation_frame_count = 1
    end

    dim_default_slots = dim_default_slots or false

    local skillchain_delay, skillchain_window = skillchains.get_skillchain_window()
    self:display_skillchain_indicator(player_vitals, skillchain_delay, skillchain_window)

    if (gamepad_state.active_bar ~= 0) then
        self:show_bar_background(gamepad_state.active_bar)
    else
        self.bar_background:hide()
    end

    for h=1,self.theme.hotbar_number,1 do
        local shouldDrawThisBar = (gamepad_state.active_bar < 3 and (h == 1 or h == 2)) or (gamepad_state.active_bar == h)
        if (shouldDrawThisBar) then
            for i=1,8,1 do
                local slot = i
                if slot == 10 then slot = 0 end

                self.hotbars[h].slot_background[i]:show()
                self.hotbars[h].slot_icon[i]:show()
                self.hotbars[h].slot_frame[i]:show()
                self.hotbars[h].slot_element[i]:show()
                self.hotbars[h].slot_text[i]:show()
                self.hotbars[h].slot_cost[i]:show()

                local action = nil
                if (player_hotbar[environment] and player_hotbar[environment]['hotbar_' .. h]) then
                    action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]
                end

                if (action == nil or action.action == nil) then
                    action = maybe_get_default_action(player_hotbar, environment, h, slot)
                end

                if (action ~= nil and action.type == 'a' and action.action == 'a' and action.alias == 'Attack') then
                    if (in_battle) then
                        self.hotbars[h].slot_icon[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/disengage.png')
                        self.hotbars[h].slot_text[i]:text('Disengage')
                    else
                        self.hotbars[h].slot_icon[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/attack.png')
                        self.hotbars[h].slot_text[i]:text('Attack')
                    end
                elseif (action ~= nil and action.type == 'ta' and action.action == 'Switch Target' and action.alias == 'Switch Target') then
                    if (in_battle) then
                        self.hotbars[h].slot_icon[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/switchtarget.png')
                        self.hotbars[h].slot_text[i]:text('Switch Target')
                    else
                        self.hotbars[h].slot_icon[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/targetnpc.png')
                        self.hotbars[h].slot_text[i]:text('Target NPC')
                    end
                elseif (action ~= nil and action.type == 'map') then
                    self.hotbars[h].slot_icon[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/map.png')
                end

                if action == nil or (action.type ~= 'ma' and action.type ~= 'ja' and action.type ~= 'ws' and action.type ~= 'pet' and action.type ~= 'enchanteditem') then
                    self:clear_recast(h, i)
                    if (action ~= nil and action.type == 'item') then
                        local item_count = consumables:get_item_count_by_name(action.action)
                        if (item_count ~= nil) then
                            local display_count = item_count .. ''
                            self.hotbars[h].slot_cost[i]:text(display_count)
                            if (item_count > 1) then
                                self.hotbars[h].slot_cost[i]:color(0, 255, 0)
                            else
                                self.hotbars[h].slot_cost[i]:color(255, 0, 0)
                                has_spell = false
                            end
                            self.hotbars[h].slot_cost[i]:show()
                        else
                            self.hotbars[h].slot_cost[i]:hide()
                        end
                    end

                    -- Mark which actions came from a default set, if any, when the gamepad assigner is open
                    if (action ~= nil and action.source_environment ~= environment and dim_default_slots) then
                        self:mark_default_set_action(h, i, action.source_environment)
                    end
                else
                    local skill = nil
                    local skill_recasts = nil
                    local in_cooldown = false
                    local in_warmup = false
                    local is_in_seconds = false
                    local has_spell = true
                    local spell_requires_ja = false

                    local skillchain_prop = nil

                    -- if its magic, look for it in spells
                    if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
                        skill = database.spells[(action.action):lower()]
                        skill_recasts = windower.ffxi.get_spell_recasts()
                        has_spell = skill.type ~= 'BlueMagic' or spells[(action.action):lower()]
                        local spell_id = tonumber(skill.icon)
                        local tool_info = consumables:get_ninja_spell_info(spell_id)
                        if (tool_info ~= nil and tool_info.tool_count ~= nil and tool_info.master_tool_count ~= nil) then
                            local total_tool_count = tool_info.tool_count + tool_info.master_tool_count
                            local display_count = total_tool_count .. ''
                            if (total_tool_count > 99) then
                                display_count = '99+'
                            end
                            self.hotbars[h].slot_cost[i]:text(display_count)
                            if (tool_info.tool_count > 50) then
                                self.hotbars[h].slot_cost[i]:color(0, 255, 0)
                            elseif (total_tool_count > 50) then
                                self.hotbars[h].slot_cost[i]:color(255, 255, 0)
                            else
                                self.hotbars[h].slot_cost[i]:color(255, 0, 0)
                            end
                            self.hotbars[h].slot_cost[i]:show()

                            if (total_tool_count == 0) then
                                -- set up "Xed-out" element
                                self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/red-x.png')
                                self.hotbars[h].slot_recast[i]:alpha(150)
                                self.hotbars[h].slot_recast[i]:size(40, 40)
                                self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i))
                                self.hotbars[h].slot_recast[i]:show()
                                self.hotbars[h].slot_recast_text[i]:hide()
                            end
                        end
                    elseif (action.type == 'ja' or action.type == 'ws' or action.type == 'pet') and database.abilities[(action.action):lower()] ~= nil then
                        skill = database.abilities[(action.action):lower()]
                        if (action.type == 'ws') then
                            skillchain_prop = skillchains.get_skillchain_result(tonumber(skill.id), 'weapon_skills')
                        elseif (action.type == 'ja' or action_type == 'pet') then
                            skillchain_prop = skillchains.get_skillchain_result(tonumber(skill.icon), 'job_abilities')

                            local tool_info = consumables:get_ability_info_by_name(kebab_casify(action.action))

                            if (tool_info ~= nil and tool_info.tool_count ~= nil and tool_info.master_tool_count ~= nil) then

                                local total_tool_count = tool_info.tool_count + tool_info.master_tool_count
                                local display_count = total_tool_count .. ''
                                if (total_tool_count > 99) then
                                    display_count = '99+'
                                end
                                self.hotbars[h].slot_cost[i]:text(display_count)
                                if (tool_info.tool_count > 50) then
                                    self.hotbars[h].slot_cost[i]:color(0, 255, 0)
                                elseif (total_tool_count > 50) then
                                    self.hotbars[h].slot_cost[i]:color(255, 255, 0)
                                else
                                    self.hotbars[h].slot_cost[i]:color(255, 0, 0)
                                end
                                self.hotbars[h].slot_cost[i]:show()

                                if (total_tool_count == 0) then
                                    -- set up "Xed-out" element
                                    self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/red-x.png')
                                    self.hotbars[h].slot_recast[i]:alpha(150)
                                    self.hotbars[h].slot_recast[i]:size(40, 40)
                                    self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i))
                                    self.hotbars[h].slot_recast[i]:show()
                                    self.hotbars[h].slot_recast_text[i]:hide()
                                end
                            end
                        end

                        skill_recasts = windower.ffxi.get_ability_recasts()
                        is_in_seconds = true
                    elseif (action.type == 'enchanteditem') then
                        local warmup_fraction = self.enchanted_items:get_warmup_fraction(action.action)
                        in_warmup = warmup_fraction < 1 or self.disabled_slots.on_warmup[action.action]

                        if in_warmup then
                            -- register first cooldown to calculate percentage
                            if self.disabled_slots.on_warmup[action.action] == nil then
                                self.disabled_slots.on_warmup[action.action] = self.enchanted_items:get_warmup_time(action.action)

                                -- setup recast elements
                                self.hotbars[h].slot_warmup[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/blue-square.png')
                            end
                        end

                        local cooldown_fraction = self.enchanted_items:get_cooldown_fraction(action.action)
                        in_cooldown = cooldown_fraction > 0

                        if in_cooldown then
                            -- remove the warmup backdrop
                            self.disabled_slots.on_warmup[action.action] = nil
                            self.hotbars[h].slot_warmup[i]:hide()

                            -- register first cooldown to calculate percentage
                            if self.disabled_slots.on_cooldown[action.action] == nil then
                                self.disabled_slots.on_cooldown[action.action] = self.enchanted_items:get_cooldown_time(action.action)

                                -- setup recast elements
                                self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/black-square.png')
                            end
                        end

                        is_in_seconds = true
                    end

                    -- check if skill is in cooldown
                    if (has_spell and skill ~= nil and skill_recasts[tonumber(skill.icon)] ~= nil and skill_recasts[tonumber(skill.icon)] > 0) then
                        -- register first cooldown to calculate percentage
                        if self.disabled_slots.on_cooldown[action.action] == nil then
                            self.disabled_slots.on_cooldown[action.action] = skill_recasts[tonumber(skill.icon)]

                            -- setup recast elements
                            self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/black-square.png')
                        end

                        in_cooldown = true
                    end

                    -- if skill is in cooldown
                    if in_cooldown then
                        -- disable slot if it's not disabled
                        if self.disabled_slots.actions[action.action] == nil then
                            self.disabled_slots.actions[action.action] = true
                            self:toggle_slot(h, i, false)
                        end

                        -- show recast animation
                        if self.theme.hide_recast_animation == false or self.theme.hide_recast_text == false then
                            local time_remaining = 0

                            local new_height = 40
                            if (action.type == 'enchanteditem') then
                                time_remaining = self.enchanted_items:get_cooldown_fraction(action.action) * self.enchanted_items:get_cooldown_time(action.action)
                                new_height = 40 * self.enchanted_items:get_cooldown_fraction(action.action)
                            else
                                time_remaining = skill_recasts[tonumber(skill.icon)]
                                local full_recast = tonumber(self.disabled_slots.on_cooldown[action.action])
                                new_height = 40 * (time_remaining / full_recast)
                            end
                            if new_height > 40 then new_height = 40 end -- temporary bug fix
                            local recast_time = calc_recast_time(time_remaining, is_in_seconds)

                            -- show recast if settings allow it
                            if self.theme.hide_recast_animation == false then
                                self.hotbars[h].slot_recast[i]:alpha(150)
                                self.hotbars[h].slot_recast[i]:size(40, new_height)
                                self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i) + (40 - new_height))
                                self.hotbars[h].slot_recast[i]:show()
                            end

                            if (has_spell and self.theme.hide_recast_text == false) then
                                self.hotbars[h].slot_recast_text[i]:text(recast_time)
                                self.hotbars[h].slot_recast_text[i]:show()
                            else
                                self.hotbars[h].slot_recast_text[i]:hide()
                            end
                        end
                    elseif in_warmup then
                        -- show recast animation
                        if self.theme.hide_recast_animation == false then
                            local new_height = 40 * self.enchanted_items:get_warmup_fraction(action.action)
                            if new_height > 40 then new_height = 40 end -- temporary bug fix

                            -- show recast if settings allow it
                            if self.theme.hide_recast_animation == false then
                                self.hotbars[h].slot_warmup[i]:alpha(255)
                                self.hotbars[h].slot_warmup[i]:size(40, new_height)
                                self.hotbars[h].slot_warmup[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i) + (40 - new_height))
                                self.hotbars[h].slot_warmup[i]:show()
                            end
                        end
                    elseif not has_spell then
                        if (action.source_environment == environment or not dim_default_slots) then
                            if database.spells[(action.action):lower()] ~= nil and spellsThatRequireJA:contains((action.action):lower()) then
                                -- set up "needs JA" element
                                self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/needs_job_ability.png')
                            else
                                -- set up "Xed-out" element
                                self.hotbars[h].slot_recast[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/red-x.png')
                            end
                            self.hotbars[h].slot_recast[i]:alpha(150)
                            self.hotbars[h].slot_recast[i]:size(40, 40)
                            self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i))
                            self.hotbars[h].slot_recast[i]:show()
                            self.hotbars[h].slot_recast_text[i]:hide()
                        end
                    else
                        -- clear recast animation
                        self:clear_recast(h, i)

                        if self.disabled_slots.on_cooldown[action.action] == true then
                            self.disabled_slots.on_cooldown[action.action] = nil
                        end

                        -- if it's not disabled by vitals nor cooldown, enable slot
                        if self.disabled_slots.actions[action.action] == true and self.disabled_slots.no_vitals[action.action] == nil then
                            self.disabled_slots.actions[action.action] = nil
                            self:toggle_slot(h, i, true)
                        end
                    end

                    -- Show skillchain indicator if WS has a compatible skillchain property
                    if (skillchain_prop ~= nil) then
                        local frame_step = 1
                        if (animation_frame_count > 35) then
                            frame_step = 8
                        elseif (animation_frame_count > 30) then
                            frame_step = 7
                        elseif (animation_frame_count > 25) then
                            frame_step = 6
                        elseif (animation_frame_count > 20) then
                            frame_step = 5
                        elseif (animation_frame_count > 15) then
                            frame_step = 4
                        elseif (animation_frame_count > 10) then
                            frame_step = 3
                        elseif (animation_frame_count > 5) then
                            frame_step = 2
                        end

                        if (player_vitals.tp >= 1000) then
                            self.hotbars[h].slot_warmup[i]:alpha(255)
                            self.hotbars[h].slot_frame[i]:alpha(255)
                            self.hotbars[h].slot_icon[i]:hide()
                            self.hotbars[h].slot_cost[i]:hide()
                        else
                            self.hotbars[h].slot_warmup[i]:alpha(75)
                            self.hotbars[h].slot_frame[i]:alpha(150)
                            self.hotbars[h].slot_icon[i]:hide()
                            self.hotbars[h].slot_cost[i]:show()
                        end

                        self.hotbars[h].slot_frame[i]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/frame_step' .. frame_step .. '.png')
                        self.hotbars[h].slot_warmup[i]:path(windower.addon_path..'/images/' .. get_icon_pathbase() .. '/skillchain/' .. skillchain_prop:lower() .. '.png')
                        self.hotbars[h].slot_warmup[i]:size(40, 40)
                        self.hotbars[h].slot_warmup[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i))
                        self.hotbars[h].slot_warmup[i]:show()
                        self.hotbars[h].slot_warmup[i]:show()
                        self.hotbars[h].slot_icon[i]:hide()
                    elseif (not in_warmup) then
                        self.hotbars[h].slot_frame[i]:path(self.frame_image_path)
                        self.hotbars[h].slot_icon[i]:show()
                        self.hotbars[h].slot_warmup[i]:hide()
                        if (action.type == 'ws') then
                            self.hotbars[h].slot_cost[i]:show()
                        end
                    end

                    -- Mark which actions came from a default set, if any, when the gamepad assigner is open
                    if (action ~= nil and action.source_environment ~= environment and dim_default_slots) then
                        self:mark_default_set_action(h, i, action.source_environment)
                    end
                end
            end

            if (not self.is_compact) then
                self:show_controller_icons(h)
            end
        else
            for i=1,8,1 do
                self.hotbars[h].slot_background[i]:hide()
                self.hotbars[h].slot_warmup[i]:hide()
                self.hotbars[h].slot_icon[i]:hide()
                self.hotbars[h].slot_frame[i]:hide()
                self.hotbars[h].slot_recast[i]:hide()
                self.hotbars[h].slot_element[i]:hide()
                self.hotbars[h].slot_text[i]:hide()
                self.hotbars[h].slot_cost[i]:hide()
                self.hotbars[h].slot_recast_text[i]:hide()
                self:clear_recast(h, i)
            end

            self:hide_controller_icons(h)
        end
    end
end

-- show the dpad and face button icons
function ui:show_controller_icons(h)
    -- set up dpad element
    local dpadSlot = 9
    self.hotbars[h].slot_recast[dpadSlot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/dpad_'..self.theme.button_layout..'.png')
    self.hotbars[h].slot_recast[dpadSlot]:alpha(255)
    self.hotbars[h].slot_recast[dpadSlot]:size(40, 40)
    self.hotbars[h].slot_recast[dpadSlot]:pos(self:get_slot_x(h, dpadSlot), self:get_slot_y(h, dpadSlot) + 5)
    self.hotbars[h].slot_recast[dpadSlot]:show()

    -- set up face buttons element
    local faceSlot = 10
    self.hotbars[h].slot_recast[faceSlot]:path(windower.addon_path .. '/images/' .. get_icon_pathbase() .. '/ui/facebuttons_'..self.theme.button_layout..'.png')
    self.hotbars[h].slot_recast[faceSlot]:alpha(255)
    self.hotbars[h].slot_recast[faceSlot]:size(40, 40)
    self.hotbars[h].slot_recast[faceSlot]:pos(self:get_slot_x(h, faceSlot), self:get_slot_y(h, faceSlot) + 5)
    self.hotbars[h].slot_recast[faceSlot]:show()
end

-- hide the dpad and face button icons
function ui:hide_controller_icons(h)
    -- set up dpad element
    local dpadSlot = 9
    self.hotbars[h].slot_recast[dpadSlot]:hide()

    -- set up face buttons element
    local faceSlot = 10
    self.hotbars[h].slot_recast[faceSlot]:hide()
end

-- clear recast from a slot
function ui:clear_recast(hotbar, slot)
    self.hotbars[hotbar].slot_warmup[slot]:hide()
    self.hotbars[hotbar].slot_recast[slot]:hide()
    self.hotbars[hotbar].slot_recast_text[slot]:alpha(255)
    self.hotbars[hotbar].slot_recast_text[slot]:color(255, 255, 255)
    self.hotbars[hotbar].slot_recast_text[slot]:text('')
end

-- calculate recast time
function calc_recast_time(time, in_seconds)
    local recast = time / 60

    if in_seconds then
        if recast >= 60 then
            recast = string.format("%dh", recast / 60)
        elseif recast >= 1 then
            recast = string.format("%dm", recast)
        else
            recast = string.format("%ds", recast * 60)
        end
    else
        if recast >= 60 then
            recast = string.format("%dm", recast / 60)
        else
            recast = string.format("%ds", math.round(recast * 10)*0.1)
        end
    end

    return recast
end

-- disable slot
function ui:toggle_slot(hotbar, slot, is_enabled)
    local opacity = self.theme.disabled_slot_opacity

    if is_enabled == true then
        opacity = 255
    end

    self.hotbars[hotbar].slot_element[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_cost[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_icon[slot]:alpha(opacity)
end

-----------------------------
-- Enchanted Item Usage UI
-----------------------------
function ui:maybe_use_enchanted_item(hotbar, slot)
    local action = hotbar['hotbar_' .. h]['slot_' .. slot]
end

function maybe_get_default_action(hotbar, environment, hb, slot)
    local h = 'hotbar_' .. hb
    local i = 'slot_' .. slot
    local action = nil

    if (environment ~= 'job-default' and environment ~= 'all-jobs-default' and
        hotbar['default'] and hotbar['default'][h] and hotbar['default'][h][i]) then
        action = hotbar['default'][h][i]
        action.source_environment = 'default'
    elseif (environment ~= 'all-jobs-default' and hotbar['job-default'] and hotbar['job-default'][h] and hotbar['job-default'][h][i]) then
        action = hotbar['job-default'][h][i]
        action.source_environment = 'job-default'
    elseif (hotbar['all-jobs-default'] and hotbar['all-jobs-default'][h] and hotbar['all-jobs-default'][h][i]) then
        action = hotbar['all-jobs-default'][h][i]
        action.source_environment = 'all-jobs-default'
    end

    return action
end

-----------------------------
-- Feedback UI
-----------------------------

-- trigger feedback visuals in given hotbar and slot
function ui:trigger_feedback(hotbar, slot)
    if slot == 0 then slot = 10 end    

    self.feedback_icon:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
    self.feedback.is_active = true
end

-- show feedback
function ui:show_feedback()
    if self.feedback.current_opacity ~= 0 then
        self.feedback.current_opacity = self.feedback.current_opacity - self.feedback.speed
        self.feedback_icon:alpha(self.feedback.current_opacity)
        self.feedback_icon:show()
    elseif self.feedback.current_opacity < 1 then
        self.feedback_icon:hide()
        self.feedback.current_opacity = self.feedback.max_opacity
        self.feedback.is_active= false
    end
end

return ui