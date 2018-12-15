_addon.name = 'OhNoYouDont'
_addon.author = 'Lorand'
_addon.command = 'onyd'
_addon.version = '0.7'
_addon.lastUpdate = '2015.03.13'

require('luau')
local res = require('resources')
local config = require('config')
local rarr = string.char(129,168)

local abil_start_ids = S{43,326,675}
local spell_start_ids = S{3,327,716}
local start_ids = abil_start_ids:union(spell_start_ids)

local msgMap = {['turn']='turn for',['stun']='stun'}

local defaults = {}
defaults.profile = {}
defaults.profile.shark = {}
defaults.profile.shark.stun = {'Protolithic Puncture','Pelagic Cleaver','Tidal Guillotine','Carcharian Verve','Marine Mayhem','Aquatic Lance'}
local settings = config.load(defaults)

local profile = {}
local enabled = false
local debugging = true

windower.register_event('load', function()
	print_helptext()
end)

windower.register_event('logout', function()
	windower.send_command('lua unload '.._addon.name)
end)

windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = {...}
	
	if (command == 'reload') then
		windower.send_command('lua reload '.._addon.name)
	elseif (command == 'unload') then
		windower.send_command('lua unload '.._addon.name)
	elseif S{'load','profile'}:contains(command) then
		if (args[1] ~= nil) then
			if (settings.profile[args[1]] ~= nil) then
				enabled = true
				loadProfile(args[1])
			else 
				atc('ERROR: Profile "'..args[1]..'" does not exist.')
			end
		else
			atc('ERROR: No profile name provided to load.')
		end
	elseif S{'enable','on','start'}:contains(command) then
		enabled = true
		print_status()
	elseif S{'disable','off','stop'}:contains(command) then
		enabled = false
		atc('Disabled.')
	elseif (command == 'status') then
		print_status()
	else
		atc('ERROR: Unknown command')
	end
end)

function loadProfile(pname)
	profile.name = pname
	profile.stun = S{}
	profile.stun_s = S{}
	profile.turn = S{}
	for action,skills in pairs(settings.profile[pname]) do
		for _,skill in pairs(skills) do
			local mabil = res.monster_abilities:with('en', skill)
			if (mabil ~= nil) then
				profile[action]:add(mabil.id)
			else
				local spell = res.spells:with('en', skill)
				if (spell ~= nil) then
					profile.stun_s:add(spell.id)
				else
					atc('ERROR: Unable to '..msgMap[action]..' '..skill)
				end
			end
		end
	end
	print_status()
end

function print_status()
	local pname = profile.name or '(none)'
	local etxt = enabled and 'ACTIVE' or 'DISABLED'
	atc('Profile loaded: '..pname..' ['..etxt..']')
	
	local stunning = profile.stun:format('list')
	for abilid,_ in pairs(profile.stun) do
		stunning = stunning:gsub(abilid, res.monster_abilities[abilid].en)
	end
	
	local stunning_s = profile.stun_s:format('list')
	for abilid,_ in pairs(profile.stun_s) do
		stunning_s = stunning_s:gsub(abilid, res.spells[abilid].en)
	end
	
	local turning = profile.turn:format('list')
	for abilid,_ in pairs(profile.turn) do
		turning = turning:gsub(abilid, res.monster_abilities[abilid].en)
	end
	
	if (stunning_s ~= '') then
		stunning = (stunning ~= '') and stunning..', ' or stunning
		stunning = stunning..stunning_s
	end
	stunning = (stunning == '') and '(nothing)' or stunning
	turning = (turning == '') and '(nothing)' or turning
	
	atc('Stunning: '..stunning)
	atc('Turning for: '..turning)
end

function getStunCommand()
	local player = windower.ffxi.get_player()
	if S{'BLM','DRK'}:contains(player.main_job) or S{'BLM','DRK'}:contains(player.sub_job) then
		return '/ma Stun <t>'
	elseif S{player.main_job,player.sub_job}:contains('DNC') then
		return '/ja "Violent Flourish" <t>'
	else
		atc('ERROR: Job combo has no abilities available to stun '..abilname)
		return nil
	end
end

function attemptStun(abilname)
	local stunCmd = getStunCommand()
	if (stunCmd ~= nil) then
		windower.send_command('input '..stunCmd)
		atc(123, '===============> STUNNING '..abilname..' <===============')
	end
end

function processAction(m_id, a_id)
	if abil_start_ids:contains(m_id) then
		local mabil = res.monster_abilities[a_id]
		local abilname = mabil and mabil.en or '(unknown)'
		if profile.turn:contains(a_id) then
			local target = windower.ffxi.get_mob_by_target()
			windower.ffxi.turn(target.facing)
			atc(123,'Alert: Turning for '..abilname..'!')
			return true
		elseif profile.stun:contains(a_id) then
			--------
			if a_id == 3791 then
				attemptStun(abilname)
			else
				attemptStun(abilname)
			end
			-------
			return true
		else
			atcd('No action to perform for '..abilname..' [id: '..a_id..']')
		end
	elseif spell_start_ids:contains(m_id) then
		local spell = res.spells[a_id]
		local sname = spell and spell.en or '(unknown)'
		if profile.stun_s:contains(a_id) then
			attemptStun(sname)
			return true
		else
			atcd('No action to perform for '..sname..' [id: '..a_id..']')
		end
	end
	return false	
end

windower.register_event('incoming chunk', function(id, data)
	if enabled and (id == 0x28) then
		local ai = get_action_info(id, data)
		local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
		local target = windower.ffxi.get_mob_by_target()
		if (actor ~= nil) and (actor.is_npc) and (target ~= nil) and (target.id == ai.actor_id) then
			for _,targ in pairs(ai.targets) do
				for _,tact in pairs(targ.actions) do
					if start_ids:contains(tact.message_id) then
						if processAction(tact.message_id, tact.param) then
							return
						end
					end
				end
			end
		end
	end
end)

--[[
	Parse the given packet and construct a table to make its contents useful.
	Based on the 'incoming chunk' function in the Battlemod addon (thanks to Byrth / SnickySnacks)
	@param id packet ID
	@param data raw packet contents
	@return a table representing the given packet's data
--]]
function get_action_info(id, data)
	local pref = data:sub(1,4)
	local data = data:sub(5)
	if id == 0x28 then			-------------- ACTION PACKET ---------------
		local act = {}
		act.do_not_need	= get_bit_packed(data,0,8)
		act.actor_id	= get_bit_packed(data,8,40)
		act.target_count= get_bit_packed(data,40,50)
		act.category	= get_bit_packed(data,50,54)
		act.param	= get_bit_packed(data,54,70)
		act.unknown	= get_bit_packed(data,70,86)
		act.recast	= get_bit_packed(data,86,118)
		act.targets = {}
		local offset = 118
		for i = 1, act.target_count do
			act.targets[i] = {}
			act.targets[i].id = get_bit_packed(data,offset,offset+32)
			act.targets[i].action_count = get_bit_packed(data,offset+32,offset+36)
			offset = offset + 36
			act.targets[i].actions = {}
			for n = 1,act.targets[i].action_count do
				act.targets[i].actions[n] = {}
				act.targets[i].actions[n].reaction	= get_bit_packed(data,offset,offset+5)
				act.targets[i].actions[n].animation	= get_bit_packed(data,offset+5,offset+16)
				act.targets[i].actions[n].effect	= get_bit_packed(data,offset+16,offset+21)
				act.targets[i].actions[n].stagger	= get_bit_packed(data,offset+21,offset+27)
				act.targets[i].actions[n].param		= get_bit_packed(data,offset+27,offset+44)
				act.targets[i].actions[n].message_id	= get_bit_packed(data,offset+44,offset+54)
				act.targets[i].actions[n].unknown	= get_bit_packed(data,offset+54,offset+85)
				act.targets[i].actions[n].has_add_efct	= get_bit_packed(data,offset+85,offset+86)
				offset = offset + 86
				if act.targets[i].actions[n].has_add_efct == 1 then
					act.targets[i].actions[n].has_add_efct		= true
					act.targets[i].actions[n].add_efct_animation	= get_bit_packed(data,offset,offset+6)
					act.targets[i].actions[n].add_efct_effect	= get_bit_packed(data,offset+6,offset+10)
					act.targets[i].actions[n].add_efct_param	= get_bit_packed(data,offset+10,offset+27)
					act.targets[i].actions[n].add_efct_message_id	= get_bit_packed(data,offset+27,offset+37)
					offset = offset + 37
				else
					act.targets[i].actions[n].has_add_efct		= false
					act.targets[i].actions[n].add_efct_animation	= 0
					act.targets[i].actions[n].add_efct_effect	= 0
					act.targets[i].actions[n].add_efct_param	= 0
					act.targets[i].actions[n].add_efct_message_id	= 0
				end
				act.targets[i].actions[n].has_spike_efct = get_bit_packed(data,offset,offset+1)
				offset = offset + 1
				if act.targets[i].actions[n].has_spike_efct == 1 then
					act.targets[i].actions[n].has_spike_efct	= true
					act.targets[i].actions[n].spike_efct_animation	= get_bit_packed(data,offset,offset+6)
					act.targets[i].actions[n].spike_efct_effect	= get_bit_packed(data,offset+6,offset+10)
					act.targets[i].actions[n].spike_efct_param	= get_bit_packed(data,offset+10,offset+24)
					act.targets[i].actions[n].spike_efct_message_id	= get_bit_packed(data,offset+24,offset+34)
					offset = offset + 34
				else
					act.targets[i].actions[n].has_spike_efct	= false
					act.targets[i].actions[n].spike_efct_animation	= 0
					act.targets[i].actions[n].spike_efct_effect	= 0
					act.targets[i].actions[n].spike_efct_param	= 0
					act.targets[i].actions[n].spike_efct_message_id	= 0
				end
			end
		end
		return act
	elseif id == 0x29 then		----------- ACTION MESSAGE ------------
		local am = {}
		am.actor_id	= get_bit_packed(data,0,32)
		am.target_id	= get_bit_packed(data,32,64)
		am.param_1	= get_bit_packed(data,64,96)
		am.param_2	= get_bit_packed(data,96,106)	-- First 6 bits
		am.param_3	= get_bit_packed(data,106,128)	-- Rest
		am.actor_index	= get_bit_packed(data,128,144)
		am.target_index	= get_bit_packed(data,144,160)
		am.message_id	= get_bit_packed(data,160,175)	-- Cut off the most significant bit, hopefully
		return am
	end
end

function get_bit_packed(dat_string,start,stop)
	--Copied from Battlemod; thanks to Byrth / SnickySnacks
	local newval = 0   
	local c_count = math.ceil(stop/8)
	while c_count >= math.ceil((start+1)/8) do
		local cur_val = dat_string:byte(c_count)
		local scal = 256
		if c_count == math.ceil(stop/8) then
			cur_val = cur_val%(2^((stop-1)%8+1))
		end
		if c_count == math.ceil((start+1)/8) then
			cur_val = math.floor(cur_val/(2^(start%8)))
			scal = 2^(8-start%8)
		end
		newval = newval*scal + cur_val
		c_count = c_count - 1
	end
	return newval
end

function print_helptext()
	atc('Commands:')
	atc('onyd load <profile name> : load profile <profile name>')
end

function atc(c, msg)
	if (type(c) == 'string') and (msg == nil) then
		msg = c
		c = 0
	end
	windower.add_to_chat(c, msg)
end

function atcd(text)
	if debugging then
		atc(text)
	end
end

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2015, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of OhNoYouDont nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------