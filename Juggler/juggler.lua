--[[
	Copyright (C) 2016, Ryan Skeldon
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
_addon.version = '0.1.0'
_addon.name = 'Juggler'
_addon.author = 'psykad'
_addon.commands = {'juggler','jugs'}

--------------------------------------------------------------------------------
-- Required libraries
--------------------------------------------------------------------------------
require 'tables'
local texts = require('texts')
local res = require('resources')
local config = require('config')

--------------------------------------------------------------------------------
-- Default add-on settings
--------------------------------------------------------------------------------
local defaults = {}

-- HUD settings.
defaults.ready_move_hud_settings = {}
defaults.ready_move_hud_settings.pos = {}
defaults.ready_move_hud_settings.pos.x = 0
defaults.ready_move_hud_settings.pos.y = 0
defaults.ready_move_hud_settings.bg = {}
defaults.ready_move_hud_settings.bg.alpha = 255
defaults.ready_move_hud_settings.bg.red = 0
defaults.ready_move_hud_settings.bg.green = 0
defaults.ready_move_hud_settings.bg.blue = 0
defaults.ready_move_hud_settings.bg.visible = true
defaults.ready_move_hud_settings.flags = {}
defaults.ready_move_hud_settings.flags.right = false
defaults.ready_move_hud_settings.flags.bottom = false
defaults.ready_move_hud_settings.flags.bold = false
defaults.ready_move_hud_settings.flags.italic = false
defaults.ready_move_hud_settings.text = {}
defaults.ready_move_hud_settings.text.size = 12
defaults.ready_move_hud_settings.text.font = 'Consolas'
defaults.ready_move_hud_settings.text.alpha = 255
defaults.ready_move_hud_settings.text.red = 255
defaults.ready_move_hud_settings.text.green = 255
defaults.ready_move_hud_settings.text.blue = 255

-- User specific settings.
defaults.ready_recast_time = 30;

--------------------------------------------------------------------------------
-- Add-on specfic variables
--------------------------------------------------------------------------------
local settings = config.load(defaults)
local ready_moves_hud = texts.new(settings.ready_move_hud_settings)
local colors = {}
colors.white = '255,255,255'
colors.gray = '96,96,96'

--------------------------------------------------------------------------------
-- Windower events
--------------------------------------------------------------------------------
windower.register_event('load', 'login', function()
    ready_moves_hud:visible(true)   
end)

windower.register_event('logout', 'unload', function()
    ready_moves_hud:visible(false)
end)

windower.register_event('job change', function(job)
    ready_moves_hud:visible(job == 9)
end)

windower.register_event('zone change', function()
    local pet = get_pet()

   ready_moves_hud:visible(pet ~= nil)
end)

local frame_count = 0
windower.register_event('prerender',function()    
    frame_count = frame_count+1

    -- Update display every second.
    if frame_count%30 == 0 then
        update_hud()

        -- Reset frame counter.
        frame_count = 0
    end    
end)

windower.register_event('addon command', function(...)
	if #arg == 0 then return end
	
	local command = arg[1]

    if command == 'ready_move' then    
        -- Check for pet.
        local pet = get_pet()
        if pet == nil then
            windower.add_to_chat(8, _addon.name..': You do not have a pet.')
            return
        end

        -- Check for the index of the ready move.
        local move_index = tonumber(arg[2])
        if move_index == nil then
            windower.add_to_chat(8, _addon.name..': No ready move number found.')
            return
        end
        
        -- Check if the index is valid for the current list of moves.
        local pet_abilities = get_pet_abilities()
        if move_index < 1 or move_index > #pet_abilities then
            windower.add_to_chat(8, _addon.name..': No move assigned to #'..move_index..'.')
            return
        end

        -- Execute the move.
        windower.send_command('input /ja "'..pet_abilities[move_index].en..'" <me>')
    elseif command == 'set_recast' then
        local new_recast_time = tonumber(arg[2])

        if new_recast_time == nil or new_recast_time <= 0 then
            windower.add_to_chat(8, _addon.name..': Recast time missing or invalid.')
            return
        end
        
	    settings.ready_recast_time = new_recast_time

        config.save(settings)

        windower.add_to_chat(8, _addon.name..': New recast time saved.')
    elseif command == 'set_xy' then
        local new_x = tonumber(arg[2])
        local new_y = tonumber(arg[3])

        if new_x == nil or new_y == nil then
            windower.add_to_chat(8, _addon.name..': Coordinates missing or invalid.')
            return
        end

        settings.ready_move_hud_settings.pos.x = new_x
        settings.ready_move_hud_settings.pos.y = new_y

        config.save(settings)

        ready_moves_hud:pos(new_x, new_y)
    end
end)

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function update_hud()
    local pet = get_pet()
    local hud_text = ""

    local player = windower.ffxi.get_player()
    local job = player.main_job_id
    
    -- Check if a pet exists.
    if pet ~= nil and job == 9 then
        local pet_abilities = get_pet_abilities()
    
        -- Charmed pets have no ready moves.
        if #pet_abilities == 0 then
            hud_text = "No ready moves"
        else
            -- Calculate current ready move count.
            local total_moves = 3
            local ready_ability_recast = windower.ffxi.get_ability_recasts()[102] -- 102 is Sic/Ready ability ID.
            local current_move_count = total_moves - math.ceil(ready_ability_recast / settings.ready_recast_time)

            local move_count_text = "Moves: "..current_move_count
            
            -- Setup message for next move tick.
            local next_move_ready_text = ""
            
            if ready_ability_recast >= 0 and current_move_count < total_moves then
                local time_til_next_move = ready_ability_recast - (settings.ready_recast_time * (total_moves - current_move_count - 1))
                next_move_ready_text = "Next: "..time_til_next_move.."s"
            else
                next_move_ready_text = "Next: Idle"
            end

            -- Iterate through available pet ready moves.
            local available_move_list_text = ""
            for i =1,#pet_abilities do
                local ability_status_color = current_move_count < pet_abilities[i].mp_cost and colors.gray or colors.white

                available_move_list_text = available_move_list_text..'\\cs('..ability_status_color..')'..'['..i..'] '..pet_abilities[i].en

                if i < #pet_abilities then
                    available_move_list_text = available_move_list_text..'\n'
                end
            end

            -- Set ready move count.
            hud_text = move_count_text..'\n'..next_move_ready_text..'\n'..available_move_list_text
        end
    end
    
    ready_moves_hud:text(hud_text)
    ready_moves_hud:visible(pet ~= nil and job == 9)
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function get_pet()
    return windower.ffxi.get_mob_by_target('pet')
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function get_pet_abilities()
    local abilities = windower.ffxi.get_abilities().job_abilities
    local pet_abilities = {}
    local move_index = 0

    -- Iterate through all current player abilities.
    for i=1,#abilities do
        local ability = res.job_abilities[tonumber(abilities[i])]
        
        -- Filter out everything but Monster abilities.
        if ability.type == 'Monster' then  
            move_index = move_index+1

            pet_abilities[move_index] = ability        
        end
    end

    return pet_abilities
end