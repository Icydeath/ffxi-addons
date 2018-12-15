--[[

Copyright © 2016, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of React nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'ReactRedux'
_addon.author = 'Sammeh,bangerang'
_addon.version = '0.1'
_addon.command = 'react'

-- 1.3.0 changing map.lua to job specific
-- 1.4.0 Allow react to react to PCs only if target = self 
-- 1.4.0.2/3 Fix for no primary target or skill in resources
-- 1.4.0.4 Add in a default "complete" command of "gs c update".
-- 1.4.0.5 Fix 1.4.0.4... urghzzz
-- 1.4.0.6 (Forgot to add in a part for auto doing "gs c update" for cure parts)
-- 1.4.0.7 Enhanced Debugging - Print to screen when in debugmode.
-- 1.4.0.8 With help of Langly - Fixed turnaround/facemob to be based on vector of the two objects vs. where the target is facing.  So now works with all angles
-- 1.4.0.9 Enhance the new turnaround/facemob with (actor) parameters so its not exclusively off target, but 'actor' in some instances.
-- 1.5.0.0 Add in new commands (runto and runaway) - Auto runs to or away from mob)
-- 1.5.0.1 Change runto and runaway to have a Yalm parameter to stop running after # of yalms.
------- PLEASE NOTE runto/runaway will not work if you are locked onto a target.
-- 1.5.0.2 Fix an issue with runaway/to based on target that died or was no longer aggressive etc.
-- 1.5.0.3 Went ahead and made it where you can't run away/to  yourself ;)
-- 1.5.0.4 Identified if 'locked on' to target.   Thx sdahlka on Windower forums.


-- 1.6.0.0 Add "ActorID" as global variable for use in custom commands
-- Planned: 1.6.0.1 add in Global commands:   if (Mob specific) then react;  elseif (global) then react; else - no react
-- 0.1 Renamed ReactRedux. New version standard. Removed actor condition. 'Cleaned up' addon chat. Stop yelling at me. (bangerang)

require 'tables'
require 'sets'
require 'strings'
require 'actions'
require 'pack'
require 'logger'
files = require 'files'
require('chat')
res = require 'resources'

-- Change default React comments.
chatcolor = 8

-- Auto Run = Off
autorun = 0


if windower.ffxi.get_player() then 
 self = windower.ffxi.get_player()

 custom_reactions_file = files.new('react_'..self.main_job..'.lua')

if custom_reactions_file:exists() then
 windower.add_to_chat(2,'[React] Loading File... react_'..self.main_job..'.lua')
else
 windower.add_to_chat(2,'[React] New job detected. Creating file... react_'..self.main_job..'.lua')
 custom_reactions = {}
 custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end


custom_reactions = require('react_'..self.main_job)

end

function addaction(args)
	local monster_action = args[1]
	local monster_reactiontype = args[2]
	if monster_reactiontype:lower() ~= "ready" and monster_reactiontype:lower() ~= "complete" then
		windower.add_to_chat(2,"[React] Error: You did not specify the action type as 'ready' or 'complete'")
		return
	end
	local monster_reaction = args[3]
	if custom_reactions[monster_action] then
		if custom_reactions[monster_action] then
			current_ready_reaction = custom_reactions[monster_action].ready_reaction or ""
			current_complete_reaction = custom_reactions[monster_action].complete_reaction or ""
			if monster_reactiontype:lower() == "ready" then
				custom_reactions[monster_action] = {ready_reaction=monster_reaction, complete_reaction=current_complete_reaction}
			elseif monster_reactiontype:lower() == "complete" then
				custom_reactions[monster_action] = {complete_reaction=monster_reaction, ready_reaction=current_ready_reaction}
			end
		else 
			custom_reactions[monster_action] = {}
			if monster_reactiontype:lower() == "ready" then
				custom_reactions[monster_action] = {ready_reaction=monster_reaction, complete_reaction=""}
			elseif monster_reactiontype:lower() == "complete" then
				custom_reactions[monster_action] = {complete_reaction=monster_reaction, ready_reaction=""}
			end
		end
	else 
		custom_reactions[monster_action] = {}
		if custom_reactions[monster_action] then
			current_ready_reaction = custom_reactions[monster_action].ready_reaction or ""
			current_complete_reaction = custom_reactions[monster_action].reaction or ""
			if monster_reactiontype:lower() == "ready" then
				custom_reactions[monster_action] = {ready_reaction=monster_reaction, complete_reaction=current_complete_reaction}
			elseif monster_reactiontype:lower() == "complete" then
				custom_reactions[monster_action] = {complete_reaction=monster_reaction, ready_reaction=current_ready_reaction}
			end
		else 
			custom_reactions[monster_action] = {}
			if monster_reactiontype:lower() == "ready" then
				custom_reactions[monster_action] = {ready_reaction=monster_reaction, complete_reaction=""}
			elseif monster_reactiontype:lower() == "complete" then
				custom_reactions[monster_action] = {complete_reaction=monster_reaction, ready_reaction=""}
			end
		end
	end
	custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end

function listaction(args)
	local list = ""
	for index,value in pairs(custom_reactions) do
		list = list .. '[Action]  "'..index..'"  [Ready Reaction]  "'..value.ready_reaction..'"  [Complete Reaction]  "'..value.complete_reaction..'"\n'
	end
	if list then
		windower.add_to_chat(122, list)
	else
		windower.add_to_chat(122, '[React] No actions found to react to.')
	end
	--windower.add_to_chat(2,"No action found to list actions for:"..monster)
end

function removeaction(args)
	--local monster = args[1]
	local monster_action = args[1]
	if custom_reactions[monster_action] then
		windower.add_to_chat(chatcolor,"[React] Removed Reactions for: "..monster_action)
		custom_reactions[monster_action] = nil
	else
		windower.add_to_chat(chatcolor,"[React] Error: Could not find action to remove: "..monster_action)
	end
	custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end

windower.register_event('action',function (act)
	-- info here: http://dev.windower.net/doku.php?id=lua:api:events:action
		local actor = windower.ffxi.get_mob_by_id(act.actor_id)		
		local self = windower.ffxi.get_player()
		local target_count = act.target_count 
		local category = act.category  
		local param = act.param
		local recast = act.recast  
		local targets = act.targets
		local primarytarget = windower.ffxi.get_mob_by_id(targets[1].id)
		local valid_target = act.valid_target
		-- React to incidents where you're the primary target or any action by an NPC
		if actor and (actor.is_npc or primarytarget.name == self.name) and actor.name ~= self.name then 
			if debugmode == 1 then
				if category == 7 then 
					if res.monster_abilities[targets[1].actions[1].param] then 
						print('[React] Ready Move: ',actor.name,res.monster_abilities[targets[1].actions[1].param].en)
					end
				elseif category == 8 then 
					if res.spells[targets[1].actions[1].param] then
						print('[React] Begins Casting ',actor.name,res.spells[targets[1].actions[1].param].en,res.skills[res.spells[targets[1].actions[1].param].skill].en)
					end
				elseif category == 11 then
					if res.monster_abilities[param] then 
						print('[React] Completed Ready Move: ',actor.name,res.monster_abilities[param].en)
					end
				elseif category == 4 then
					if res.spells[param] then
						print('[React] Completed Casting ',actor.name,res.spells[param].en)
					end
				end
			end
			if category == 7 then -- Begin JA http://dev.windower.net/doku.php?id=lua:api:events:category_07
				if targets[1].actions[1].param ~= 0 then
					if res.monster_abilities[targets[1].actions[1].param] then 
						ability = res.monster_abilities[targets[1].actions[1].param] -- .en
						reaction(actor,category,ability,primarytarget)
					end
				end
			elseif category == 11 then  -- Finished JA (1hr's start / end here)  http://dev.windower.net/doku.php?id=lua:api:events:category_11
				if res.monster_abilities[param] then
					ability = res.monster_abilities[param] -- .en
					reaction(actor,category,ability,primarytarget)
				end
			elseif category == 8 then -- Start Casing Spell  http://dev.windower.net/doku.php?id=lua:api:events:category_08
				if targets[1].actions[1].param ~= 0 then
					ability = res.spells[targets[1].actions[1].param] -- .en
					reaction(actor,category,ability,primarytarget)
				end
			elseif category == 4 then -- Finished Casting Spell  http://dev.windower.net/doku.php?id=lua:api:events:category_04
				if res.spells[param] then
					ability = res.spells[param] --.en
					reaction(actor,category,ability,primarytarget)
				end
			end
		end
		
end)


windower.register_event('prerender', function()
    if autorun == 1 and autorun_target and autorun_distance and autorun_tofrom then 
		local t = windower.ffxi.get_mob_by_index(autorun_target.index)
		if t.valid_target and (t.status == 1 or t.status == 0) then 
			if autorun_tofrom == 2 then -- run away from
				if t.distance:sqrt() > autorun_distance then	
					windower.ffxi.run(false)
					autorun = 0
				else
					local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
					local angle = (math.atan2((t.y - self_vector.y), (t.x - self_vector.x))*180/math.pi)*-1
					windower.ffxi.run((angle+180):radian())
				end
			elseif autorun_tofrom == 1 then -- run towards
				if t.distance:sqrt() < autorun_distance then	
					windower.ffxi.run(false)
					autorun = 0
				else 
					local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
					local angle = (math.atan2((t.y - self_vector.y), (t.x - self_vector.x))*180/math.pi)*-1
					windower.ffxi.run((angle):radian())
				end
			end
		else
			windower.add_to_chat(chatcolor,"[React] Target no longer valid. Stop running.")
			windower.ffxi.run(false)
			autorun = 0
		end 
	end
end)


function reaction(actor,category,ability,primarytarget)
	if custom_reactions[ability.en] then 
		if category == 7 or category == 8 then 
			if custom_reactions[ability.en].ready_reaction then
				if custom_reactions[ability.en].ready_reaction:lower() == 'turnaround' then 
					turnaround(actor)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Turning Around")
					end
				elseif custom_reactions[ability.en].ready_reaction:lower() == 'facemob' then 
					facemob(actor)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Facing Mob")
					end
				elseif string.find(custom_reactions[ability.en].ready_reaction:lower(), 'runaway') then 
					local actionstring = custom_reactions[ability.en].ready_reaction:lower()
					local run_distance = string.match(actionstring,"%d+")
					runaway(actor,math.floor(run_distance))
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Runaway "..run_distance.." yalms.")
					end
				elseif string.find(custom_reactions[ability.en].ready_reaction:lower(), 'runto') then 
					local actionstring = custom_reactions[ability.en].ready_reaction:lower()
					local run_distance = string.match(actionstring,"%d+")
					runto(actor,math.floor(run_distance))
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Runto "..run_distance.." yalms.")
					end
				else
					currentReaction = parseAction(actor,custom_reactions[ability.en].ready_reaction)
					windower.send_command(currentReaction)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: "..custom_reactions[ability.en].ready_reaction)
					end
				end
			end
		else
			if custom_reactions[ability.en].complete_reaction then
				if custom_reactions[ability.en].complete_reaction:lower() == 'turnaround' then 
					turnaround(actor)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Turning Around")
					end
				elseif custom_reactions[ability.en].complete_reaction:lower() == 'facemob' then 
					facemob(actor)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Facing")
					end
				elseif string.find(custom_reactions[ability.en].complete_reaction:lower(), 'runaway') then 
					local actionstring = custom_reactions[ability.en].complete_reaction:lower()
					local run_distance = string.match(actionstring,"%d+")
					runaway(actor,math.floor(run_distance))
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Runaway "..run_distance.." yalms.")
					end
				elseif string.find(custom_reactions[ability.en].complete_reaction:lower(), 'runto') then 
					local actionstring = custom_reactions[ability.en].complete_reaction:lower()
					local run_distance = string.match(actionstring,"%d+")
					runto(actor,math.floor(run_distance))
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Runto "..run_distance.." yalms.")
					end
				elseif custom_reactions[ability.en].complete_reaction == '' then
					windower.send_command("gs c update")
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: Running Default gs c update")
					end
				else
					currentReaction = parseAction(actor, custom_reactions[ability.en].complete_reaction)
					windower.send_command(currentReaction)
					if showcmds == 1 then 
						windower.add_to_chat(chatcolor,"[React] Action: "..custom_reactions[ability.en].complete_reaction)
					end
				end
			end
		end
	end
	-- Looking for if the target is yourself, and the magic skill is enhancing or healing magic
	if primarytarget and res.skills[ability.skill] then
		if (primarytarget.name == self.name and (res.skills[ability.skill].en == "Enhancing Magic" or res.skills[ability.skill].en == "Healing Magic")) then
			if debugmode == 1 then
				print('Primary Target Self, Spell:',ability.en,'Type:',res.skills[ability.skill].en)
			end
			if custom_reactions[self.name] then
				if custom_reactions[self.name][ability.en] then
					if category == 7 or category == 8 then
						if custom_reactions[self.name][ability.en].ready_reaction then
							currentReaction = parseAction(actor,custom_reactions[self.name][ability.en].ready_reaction)
							windower.send_command(currentReaction)
							if showcmds == 1 then 
								windower.add_to_chat(chatcolor,"[React] Action: "..custom_reactions[self.name][ability.en].ready_reaction)
							end
						end
					else
						if custom_reactions[self.name][ability.en].complete_reaction then
							if custom_reactions[self.name][ability.en].complete_reaction == '' then
								windower.send_command("gs c update")
								if showcmds == 1 then 
									windower.add_to_chat(chatcolor,"[React] Action: Running Default gs c update")
								end
							else
								currentReaction = parseAction(actor,custom_reactions[self.name][ability.en].complete_reaction)
								windower.send_command(currentReaction)
								if showcmds == 1 then 
									windower.add_to_chat(chatcolor,"[React] Action: "..custom_reactions[self.name][ability.en].complete_reaction)
								end
							end
						end
					end
				end
			end
		end
	end
end

windower.register_event('load', function()	
	debugmode = 0
	showcmds = 0
end)

windower.register_event('zone change',function(new,old)
end)

windower.register_event('addon command', function(command, ...)
	local args = L{...}
	if command:lower() == 'debugmode' then
		if debugmode == 0 then
			debugmode = 1
			windower.add_to_chat(chatcolor,"[React] Debug mode on")
		else 
			debugmode = 0
			windower.add_to_chat(chatcolor,"[React] Debug mode off")
		end
	end
	if command:lower() == 'showcmds' then
		if showcmds == 0 then
			showcmds = 1
			windower.add_to_chat(chatcolor,"[React] Show commands on")
		else 
			showcmds = 0
			windower.add_to_chat(chatcolor,"[React] Show commands off")
		end
	end

	if command:lower() == 'add' then
		addaction(args)
	end
	if command:lower() == 'list' then
		listaction()
	end
	if command:lower() == 'remove' then
		removeaction(args)
	end
	if command:lower() == 'help' then
		local help ='\n[React Help]\n' ..
					'	Please note all abilities are case sensitive.\n' ..
					'	Use quotes to distinguish arugments with multiple words.  Ex: "Tail Swing"\n' ..
					'[React Commands]\n' ..
					'list:  Lists abilities.\n' ..
					'add:  Adds a reaction to an ability.  args[1]"action" args[2]type\{ready or complete\} args[3]"reaction"\n' ..
					'    Example: //react add "Tail Swing" ready "gs equip sets.defense.PDT"\n' ..
					'remove:  Removes action.  ARGS[1]"Action"\n' ..
					'debugmode: Print to console all actions capable of reacting to.\n' ..
					'showcmds: Toggle printing reactions into the chat toggle on/off. Default: on.'
		windower.add_to_chat(2, help)
	end

	if command:lower() == 'turnaround' then
		turnaround()
	end
    
    if command:lower() == 'facemob' then
        facemob()
    end
	
	if command:lower() == 'runaway' then 
		local rundistance = args[1] or 35 -- Setting Default run distance to 35
		runaway(nil,math.floor(rundistance))		
	end
	
	if command:lower() == 'runto'  then 
		local rundistance = args[1] or 2 -- default will run up to 2 yalms infront of
		runto(nil,math.floor(rundistance))
	end
	
	if command:lower() == 'stoprun' then 
		windower.ffxi.run(false)
		autorun = 0
	end
	

	

end)


function turnaround(actor) 
	local target = {}
	if actor then 
		target = actor
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	end
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target then  -- Pleaes note if you target yourself you will face due West
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.turn((angle+180):radian())
	else 
		windower.add_to_chat(10,"[React] You are not targeting anything to turn around from.")
	end
end

function runaway(actor,action_distance) 
	if windower.ffxi.get_player().target_locked then 
		windower.send_command("input /lockon")
	end
	local target = {}
	if actor then 
		target = actor
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	end
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target and target.name ~= self_vector.name then 
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.run((angle+180):radian())
		autorun = 1
		autorun_target = target
		autorun_distance = action_distance
		autorun_tofrom = 2
	else 
		windower.add_to_chat(10,"[React] You are not targeting anything to run away from.")
	end
end

function facemob(actor)
	local target = {}
	if actor then
		target = actor
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	end
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target then  -- Please note if you target yourself you will face Due East
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.turn((angle):radian())
	else
		windower.add_to_chat(10,"[React] You are not targeting anything to face.")
	end
end

function runto(actor,action_distance)
	local target = {}
	if actor then
		target = actor
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	end
	local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	if target and target.name ~= self_vector.name then  -- Please note if you target yourself you will run Due East
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		windower.ffxi.run((angle):radian())
		autorun = 1
		autorun_target = target
		autorun_distance = action_distance
		autorun_tofrom = 1	
	else
		windower.add_to_chat(10,"[React] You are not targeting anything to run to.")
	end
end

function parseAction(actor,reaction)
	local currentAction = string.gsub(reaction, "%$ACTORID", actor.id)
	return currentAction
end

windower.register_event('job change', function()
	windower.send_command('lua r react')    
end)

windower.register_event('login', function()
	windower.send_command('lua r react')    
end)
