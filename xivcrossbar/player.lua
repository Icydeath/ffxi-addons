local res = require('resources')
local storage = require('storage')
local action_manager = require('action_manager')

local player = {}

player.name = ''
player.main_job = ''
player.sub_job = ''
player.server = ''

player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0

player.hotbar = {}

player.hotbar_settings = {}
player.hotbar_settings.max = 1
player.hotbar_settings.active_hotbar = 1
player.hotbar_settings.active_environment = 'Field'

-- initialize player
function player:initialize(windower_player, server, theme_options, enchanted_items)
    self.name = windower_player.name
    self.main_job = windower_player.main_job
    self.sub_job = windower_player.sub_job
    self.server = server
    self.id = windower_player.id
    self.enchanted_items = enchanted_items

    self.hotbar_settings.max = theme_options.hotbar_number

    self.vitals.mp = windower_player.vitals.mp
    self.vitals.tp = windower_player.vitals.tp

    storage:setup(self)
end

local avatar_names = S{'Siren','Shiva','Ramuh','Garuda','Leviathan','Diabolos','Titan','Fenrir','Ifrit','Carbuncle','Fire Spirit','Air Spirit','Ice Spirit','Thunder Spirit','Light Spirit','Dark Spirit','Earth Spirit','Water Spirit','Cait Sith','Alexander','Odin','Atomos'}

local unescape = function(str)
    return str:gsub('&apos;', '\''):gsub('quote', '"')
end

-- update player jobs
function player:update_jobs(main, sub)
    self.main_job = main
    self.sub_job = sub

    storage:update_filename(main, sub)
end

function player:get_id()
    return self.id
end

-- Updates the set of spells the player can currently cast. Does not take
-- MP, recast timers, or special ability requirements into account. Only
-- whether or not FFXI's job data says the spell is there.
function player:update_current_spells()
    local mainJobSpellList = T()
    if windower.ffxi.get_player()['main_job_id'] == 16 then
        mainJobSpellList = T(windower.ffxi.get_mjob_data().spells)
        -- Returns all values but 512
        :filter(function(id) return id ~= 512 end)
        -- Transforms them from IDs to lowercase English names
        :map(function(id) return res.spells[id].english:lower() end)
    end

    local subJobSpellList = T()
    if windower.ffxi.get_player()['sub_job_id'] == 16 then
        subJobSpellList = T(windower.ffxi.get_sjob_data().spells)
        -- Returns all values but 512
        :filter(function(id) return id ~= 512 end)
        -- Transforms them from IDs to lowercase English names
        :map(function(id) return res.spells[id].english:lower() end)
    end

    self.current_spells = {}
    for _, spellName in ipairs(subJobSpellList) do
        self.current_spells[spellName] = true
    end
    for _, spellName in ipairs(mainJobSpellList) do
        self.current_spells[spellName] = true
    end
end

-- Returns true if the player has the spell and (if BLU) the spell is set.
function player:has_spell(spellName)
    return self.current_spells[spellName] == true
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    self:update_current_spells()
    self:reset_hotbar()
    local newly_created = false

    -- if normal hotbar file exists, load it. If not, create a default hotbar
    if storage.file:exists() then
        windower.console.write('[XIVCrossbar] Load crossbar sets for ' .. storage.filename)
        self:load_from_file(storage.file)
    else
        newly_created = true
        self:create_default_hotbar()
    end

    -- if job default file exists, load it. If not, create a default version
    if storage.job_default_file:exists() then
        windower.console.write('[XIVCrossbar] Load cross-subjob fallback crossbar set for ' .. player.main_job)
        self:load_from_file(storage.job_default_file)
    else
        newly_created = true
        self:create_job_default_hotbar()
    end

    -- if all jobs file exists, load it. If not, create a default version
    if storage.all_jobs_file:exists() then
        windower.console.write('[XIVCrossbar] Load cross-job fallback crossbar set')
        self:load_from_file(storage.all_jobs_file)
    else
        newly_created = true
        self:create_all_jobs_default_hotbar()
    end

    if (newly_created) then
        player:store_new_hotbars()
    end
end

function kebab_casify(str)
    return str:lower():gsub(' ', '-'):gsub('\'', '')
end

-- load a hotbar from existing file
function player:load_from_file(storage_file)
    local contents = xml.read(storage_file)

    if contents.name ~= 'hotbar' then
        windower.console.write('XIVCROSSBAR: invalid hotbar on ' .. storage.filename)
        return
    end

    -- parse xml to hotbar
    for key, environment in ipairs(contents.children) do
        local environment_name = nil
        for key, hotbar in ipairs(environment.children) do     -- hotbar number
            if (hotbar.name == 'name') then
                for key, name in ipairs(hotbar.children) do
                    environment_name = name.value
                end
            end
        end
        if (environment_name == nil) then
            environment_name = key
        end
        for key, hotbar in ipairs(environment.children) do     -- hotbar number
            if (hotbar.name ~= 'name') then
                for key, slot in ipairs(hotbar.children) do       -- slot number
                    local new_action = {}

                    for key, tag in ipairs(slot.children) do   -- action
                        if tag.name == 'type' then
                            new_action.type = tag.children[1].value
                        elseif tag.name == 'action' then
                            new_action.action = unescape(tag.children[1].value)
                        elseif tag.name == 'target' then
                            if tag.children[1] == nil then
                                new_action.target = nil
                            else
                                new_action.target = tag.children[1].value
                            end

                        elseif tag.name == 'alias' then
                            new_action.alias = tag.children[1].value
                        elseif tag.name == 'icon' then
                            new_action.icon = tag.children[1].value
                        elseif tag.name == 'equip_slot' then
                            new_action.equip_slot = tag.children[1].value
                        elseif tag.name == 'warmup' then
                            new_action.warmup = tag.children[1].value
                        elseif tag.name == 'cooldown' then
                            new_action.cooldown = tag.children[1].value
                        elseif tag.name == 'usable' then
                            new_action.usable = tag.children[1].value
                        end
                    end

                    self:add_action(
                        action_manager:build(new_action.type, new_action.action, new_action.target, new_action.alias, new_action.icon, new_action.equip_slot, new_action.warmup, new_action.cooldown, new_action.usable),
                        environment_name,
                        hotbar.name:gsub('hotbar_', ''),
                        slot.name:gsub('slot_', '')
                    )
                end
            end
        end
    end
end

-- create a default hotbar
function player:create_default_hotbar()
    windower.console.write('[XIVCrossbar] No hotbar found. Creating default for ' .. storage.filename)

    self.hotbar.default = {}
    self.hotbar.default['name'] = 'Default'
    self:setup_environment_hotbars('default')

    self.hotbar.basic = {}
    self.hotbar.basic['name'] = 'Basic'
    self:setup_environment_hotbars('basic')
end

-- create a fallback hotbar that applies to all subjobs of this job
function player:create_job_default_hotbar()
    windower.console.write('[XIVCrossbar] No cross-subjob fallback crossbar set found. Creating a default version')

    self.hotbar['job-default'] = {}
    self.hotbar['job-default']['name'] = 'Job Default'
    self:setup_environment_hotbars('job-default')
end

-- create a fallback hotbar that applies to all jobs on this character
function player:create_all_jobs_default_hotbar()
    windower.console.write('[XIVCrossbar] No cross-job fallback crossbar set found. Creating a default version')

    self.hotbar['all-jobs-default'] = {}
    self.hotbar['all-jobs-default']['name'] = 'All Jobs Default'
    self:setup_environment_hotbars('all-jobs-default')
end

function player:store_new_hotbars()
    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

    storage:store_new_hotbar(new_hotbar)
end

-- reset player hotbar
function player:reset_hotbar()
    self.hotbar = {}

    self.hotbar_settings.active_hotbar = 1
end

function player:setup_environment_hotbars(environment)
    for h=1,self.hotbar_settings.max,1 do
        self.hotbar[environment]['hotbar_' .. h] = {}

        -- This is a hack to make sure all newly-created crossbars show up in the crossbar set selector
        self.hotbar[environment]['hotbar_' .. h]['slot_9'] = {}
    end
end

-- set bar environment
function player:set_active_environment(environment)
    self.hotbar_settings.active_environment = kebab_casify(environment)
end

-- is valid environment
function player:is_valid_environment(environment)
    return self.hotbar[environment] ~= nil
end

function player:set_is_in_battle(in_battle)
    self.in_battle = in_battle
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'Field'
    if in_battle then environment = 'Battle' end

    self.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
    self.hotbar_settings.active_hotbar = new_hotbar

    if self.hotbar_settings.active_hotbar > self.hotbar_settings.max then
        self.hotbar_settings.active_hotbar = 1
    end
end

-- add given action to a hotbar
function player:add_action(action, environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    local env_key = kebab_casify(environment)

    if self.hotbar[env_key] == nil then
        self.hotbar[env_key] = {}
        self.hotbar[env_key]['name'] = environment
        self:setup_environment_hotbars(env_key)
    end

    if self.hotbar[env_key]['hotbar_' .. hotbar] == nil then
        windower.console.write('XIVCROSSBAR: invalid hotbar (hotbar number)')
        return
    end

    if self.hotbar[env_key]['hotbar_' .. hotbar]['slot_' .. slot] == nil then
        self.hotbar[env_key]['hotbar_' .. hotbar]['slot_' .. slot] = {}
    end

    self.hotbar[env_key]['hotbar_' .. hotbar]['slot_' .. slot] = action
end

function create_send_command_coroutine(command)
    return function()
        windower.send_command(command)
    end
end

function player:create_use_item_coroutine(item_name)
    local enchanted_items = self.enchanted_items
    return function()
        enchanted_items:use(item_name)
    end
end

-- execute action from given slot
function player:execute_action(slot)
    local h = self.hotbar_settings.active_hotbar
    local env = self.hotbar_settings.active_environment

    local action = self.hotbar[env]['hotbar_' .. h]['slot_' .. slot]
    local is_missing = action == nil or action.action == nil

    if (is_missing and env ~= 'default' and env ~= 'job-default' and env ~= 'all-jobs-default' and self.hotbar['default'] and self.hotbar['default']['hotbar_' .. h] and
        self.hotbar['default']['hotbar_' .. h]['slot_' .. slot]) then
        action = self.hotbar['default']['hotbar_' .. h]['slot_' .. slot]
    elseif (is_missing and env ~= 'job-default' and env ~= 'all-jobs-default' and self.hotbar['job-default'] and self.hotbar['job-default']['hotbar_' .. h] and
        self.hotbar['job-default']['hotbar_' .. h]['slot_' .. slot]) then
        action = self.hotbar['job-default']['hotbar_' .. h]['slot_' .. slot]
    elseif (is_missing and env ~= 'all-jobs-default' and self.hotbar['all-jobs-default'] and self.hotbar['all-jobs-default']['hotbar_' .. h] and
        self.hotbar['all-jobs-default']['hotbar_' .. h]['slot_' .. slot]) then
        action = self.hotbar['all-jobs-default']['hotbar_' .. h]['slot_' .. slot]
    end

    local is_still_missing = action == nil or action.action == nil
    if (is_still_missing) then return end

    if action.type == 'ct' then
        local command = '/' .. action.action

        if  action.target ~= nil then
            command = command .. ' <' ..  action.target .. '>'
        end

        windower.send_command('input ' .. command)
        return
    end

    if action.type == 'ex' then
        windower.send_command(action.action)
        return
    end

    if action.type == 'enchanteditem' then
        local item = action.action
        local equip_slot = action.equip_slot
        local delay = 0.5
        if (action.warmup ~= nil) then
            delay = delay + action.warmup
        end
        local recast = action.cooldown

        if (equip_slot ~= nil) then
            windower.send_command('gs disable ' .. equip_slot)
            windower.send_command('input /equip '.. equip_slot .. ' "' .. item .. '"')
            self.enchanted_items:equip(item)
        end

        local use_item = create_send_command_coroutine('input /item "' .. item .. '" <' .. action.target .. '>')
        coroutine.schedule(use_item, delay)
        local mark_used_item = player:create_use_item_coroutine(item)
        coroutine.schedule(mark_used_item, delay)

        if (equip_slot ~= nil) then
            local reactivate_equip_slot = create_send_command_coroutine('gs enable ' .. equip_slot)
            coroutine.schedule(reactivate_equip_slot, delay + 2)
        end
        return
    end

    local target_string = ''
    if (action.target ~= nil) then
        target_string = '" <' .. action.target .. '>'
    end

    if action.type == 'mount' and action.action == 'Mount Roulette' then
        windower.send_command("mr")
        return
    elseif (action.type == 'ta' and action.action == 'Switch Target' and action.alias == 'Switch Target') then
        if (self.in_battle) then
            windower.send_command('input /a ' .. target_string)
        else
            windower.send_command('input /ta ' .. target_string)
        end
        return
    end
	
	-- run all other actions
    windower.send_command('input /' .. action.type .. ' "' .. action.action .. target_string)
	
	-- switch to avatars bar if it exists
	if action.type == 'ma' and avatar_names:contains(action.action:capitalize()) then
		local env = nil
		local abil_name_lc = action.action:lower()
		for hb,_ in pairs(self.hotbar) do
			if abil_name_lc == hb:lower() or abil_name_lc:startswith(hb:lower()) then
				env = hb
				break
			end
		end
		
		if env ~= nil then
			set_active_environment(env)
		end
	elseif action.type == 'pet' and action.action:capitalize() == "Release" then -- go back to basic if release is used.
		set_active_environment("basic")
	end
end

-- remove action from slot
function player:remove_action(environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil
end

-- copy action from one slot to another
function player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if to_environment == 'b' then to_environment = 'battle' elseif to_environment == 'f' then to_environment = 'field' end
    if slot == 10 then slot = 0 end
    if to_slot == 10 then to_slot = 0 end

    if self.hotbar[environment] == nil or self.hotbar[to_environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil or self.hotbar[to_environment]['hotbar_' .. to_hotbar] == nil then return end

    self.hotbar[to_environment]['hotbar_' .. to_hotbar]['slot_' .. to_slot] = self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot]

    if is_moving then self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil end
end

-- update action alias
function player:set_action_alias(environment, hotbar, slot, alias)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].alias = alias
end

-- update action icon
function player:set_action_icon(environment, hotbar, slot, icon)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].icon = icon
end

-- create a new environment for the existing hotbar
function player:create_new_environment(name)
    local new_environment = {}
    for h=1,self.hotbar_settings.max,1 do
        new_environment['name'] = name
        new_environment['hotbar_' .. h] = {}
        for i=1,8,1 do
            new_environment['hotbar_' .. h]['slot_' .. i] = {}
        end
    end

    self.hotbar[kebab_casify(name)] = new_environment
end

-- save current hotbar
function player:save_hotbar()
    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

    storage:save_hotbar(new_hotbar)
end

return player