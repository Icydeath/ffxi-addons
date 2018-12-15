_addon.name = 'spellSpammer'
_addon.author = 'Lorand'
_addon.commands = {'spam','spellSpammer'}
_addon.version = '1.2.1'

local res = require('resources')
local config = require('config')
local aliases = config.load('..\\shortcuts\\data\\aliases.xml')
--local spellToSpam = 'Stone'
local spellsToSpam = {'Indi-Poison','Indi-Voidance','Indi-Precision'}
local lastIndex = 0
local keepSpamming = false
local spamDelay = 0.8
local spammer = {name='',actionStart=0,actionEnd=0}

local settings = {actionDelay = 2.75}


windower.register_event('addon command', function (command,...)
    command = command and command:lower() or 'help'
    local args = {...}
	
	if command == 'reload' then
		windower.send_command('lua reload spellSpammer')
	elseif command == 'unload' then
		windower.send_command('lua unload spellSpammer')
	elseif S{'on','start'}:contains(command) then
		keepSpamming = true
		print_status()
	elseif S{'off','stop'}:contains(command) then
		keepSpamming = false
		print_status()
	elseif command == 'toggle' then
		keepSpamming = not keepSpamming
		print_status()
	elseif S{'use','cast'}:contains(command) then
		local arg_string = table.concat(args,' ')
		local spellName = formatSpellName(arg_string)
		local spell = res.spells:with('en', spellName)
		if (spell ~= nil) then
			if canCast(spell) then
				spellToSpam = spell.en
				atc(0,'Successfully changed spell to spam to: '..spell.en)
			else
				atc(123,'Error: Unable to cast '..spell.en)
			end
		else
			atc(123,'Error: Invalid spell name: '..arg_string..' | '..spellName)
		end
	elseif command == 'status' then
		print_status()
	else
		atc(123, 'Error: Unknown command')
	end
end)

windower.register_event('load', function()
	lastAttempt = os.clock()
end)

windower.register_event('prerender', function()
	if keepSpamming then
		local now = os.clock()
		if (now - lastAttempt) >= spamDelay then
			local player = windower.ffxi.get_player()
			local mob = windower.ffxi.get_mob_by_target()
			--local spell = res.spells:with('en', spellToSpam)
			local spell = get_spell()
			
			if (player ~= nil) and (player.status == 0) and (mob ~= nil) and (spell ~= nil) then
                spammer.name = player.name
				if (windower.ffxi.get_spell_recasts()[spell.recast_id] == 0) then
					if (player.vitals.mp >= spell.mp_cost) and (mob.hpp > 0) then
						windower.send_command('input '..spell.prefix..' "'..spell.en..'" <t>')
						--local add_delay = 1.8
                        local add_delay = spell.cast_time + 2.5
						--if (spell.recast >= 4) then
						--	add_delay = 0.2
						--end
						--spamDelay = spell.recast + add_delay + (math.random(1, 3)/10)
                        spamDelay = add_delay + (math.random(2, 9)/10)
					end
				end
			end
			lastAttempt = now
		end
	end
end)

--[[
windower.register_event('prerender', function()
    local now = os.clock()
    local acting = isPerformingAction(moving)
    local player = windower.ffxi.get_player()
    spammer.name = player and player.name or 'Player'
    if (player ~= nil) and S{0,1}:contains(player.status) then    --0/1 = idle/engaged
        
        
        if keepSpamming and not acting then
            if (now - spammer.lastAction) > settings.actionDelay then
                
                spammer.lastAction = now     --Refresh stored action check time
            end
        end
        
    end
end)
--]]


function sizeof(tbl)
	local c = 0
	for _,_ in pairs(tbl) do c = c + 1 end
	return c
end

function get_spell()
	local index = lastIndex + 1
	if (index < 1) or (index > sizeof(spellsToSpam)) then
		index = 1
	end
	local spell_name = spellsToSpam[index]
	local spell = res.spells:with('en', spell_name)
	lastIndex = index
	return spell
end

function print_status()
	local onoff = keepSpamming and 'On' or 'Off'
    --local spellToSpam = get_spell()
	--windower.add_to_chat(0, '[spellSpammer: '..onoff..'] {'..spellToSpam..'}')
    windower.add_to_chat(0, '[spellSpammer: '..onoff..']')
end

function atc(c, msg)
	if (type(c) == 'string') and (msg == nil) then
		msg = c
		c = 0
	end
	windower.add_to_chat(c, '[spellSpammer]'..msg)
end

function canCast(spell)
	if spell.prefix == '/magic' then
		local player = windower.ffxi.get_player()
		if (player == nil) or (spell == nil) then return false end
		local mainCanCast = (spell.levels[player.main_job_id] ~= nil) and (spell.levels[player.main_job_id] <= player.main_job_level)
		local subCanCast = (spell.levels[player.sub_job_id] ~= nil) and (spell.levels[player.sub_job_id] <= player.sub_job_level)
		local spellAvailable = windower.ffxi.get_spells()[spell.id]
		return spellAvailable and (mainCanCast or subCanCast)
	end
	return true
end

dec2roman = {'I','II','III','IV','V','VI','VII','VIII','IX','X','XI'}
roman2dec = {['I']=1,['II']=2,['III']=3,['IV']=4,['V']=5,['VI']=6,['VII']=7,['VIII']=8,['IX']=9,['X']=10,['XI']=11}

function formatSpellName(text)
	if (type(text) ~= 'string') or (#text < 1) then return nil end
	
	if (aliases ~= nil) then
		local fromAlias = aliases[text]
		if (fromAlias ~= nil) then
			return fromAlias
		end
	end
	
	local parts = text:split(' ')
	if #parts >= 2 then
		local name = formatName(parts[1])
		for p = 2, #parts do
			local part = parts[p]
			local tier = toRomanNumeral(part) or part:upper()
			if (roman2dec[tier] == nil) then
				name = name..' '..formatName(part)
			else
				name = name..' '..tier
			end
		end
		return name
	else
		local name = formatName(text)
		local tier = text:sub(-1)
		local rnTier = toRomanNumeral(tier)
		if (rnTier ~= nil) then
			return name:sub(1, #name-1)..' '..rnTier
		else
			return name
		end
	end
end

function formatName(text)
	if (text ~= nil) and (type(text) == 'string') then
		return text:lower():ucfirst()
	end
	return text
end

function toRomanNumeral(val)
	if type(val) ~= 'number' then
		if type(val) == 'string' then
			val = tonumber(val)
		else
			return nil
		end
	end
	return dec2roman[val]
end



function isPerformingAction(moving)
    if (os.clock() - spammer.actionStart) > 8 then
        --Precaution in case an action completion isn't registered for a long time
        spammer.actionEnd = os.clock()
    end
    
    local acting = (spammer.actionEnd < spammer.actionStart)
    
    if (lastActingState ~= acting) then --If the current acting state is different from the last one
        if lastActingState then         --If an action was being performed
            settings.actionDelay = 2.75         --Set a longer delay
            spammer.lastAction = os.clock()      --The delay will be from this time
        else                    --If no action was being performed
            settings.actionDelay = 0.1          --Set a short delay
        end
        lastActingState = acting        --Refresh the last acting state
    end
    
    return acting
end


--[[
	Analyze the data contained in incoming packets for useful info.
	@param id packet ID
	@param data raw packet contents
--]]
function handle_incoming_chunk(id, data)
	if S{0x28,0x29}:contains(id) then	--Action / Action Message
		local ai = get_action_info(id, data)
		local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
		if (actor == nil) then return end
		if id == 0x28 then
			for _,targ in pairs(ai.targets) do
                local target = windower.ffxi.get_mob_by_id(targ.id)
                if (target == nil) then return end
                for _,tact in pairs(targ.actions) do
                    if spammer.name == actor.name then
                        if messages_initiating:contains(tact.message_id) then
                            spammer.actionStart = os.clock()
                        elseif messages_completing:contains(tact.message_id) then
                            spammer.actionEnd = os.clock()
                        end
                    end
                end
            end
		elseif id == 0x29 then
			if spammer.name == actor.name then
                if messages_initiating:contains(ai.message_id) then
                    spammer.actionStart = os.clock()
                elseif messages_completing:contains(ai.message_id) then
                    spammer.actionEnd = os.clock()
                end
            end
		end
	end
end


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
        local act = {
            actor_id = get_bit_packed(data,8,40),
            target_count = get_bit_packed(data,40,50),
            targets = {}
        }
        local offset = 118
        for i = 1, act.target_count do
            act.targets[i] = {
                id = get_bit_packed(data,offset,offset+32),
                action_count = get_bit_packed(data,offset+32,offset+36),
                actions = {}
            }
            offset = offset + 36
            for n = 1,act.targets[i].action_count do
                act.targets[i].actions[n] = {
                    message_id = get_bit_packed(data,offset+44,offset+54),
                    has_add_efct = get_bit_packed(data,offset+85,offset+86)
                }
                offset = offset + 86
                if act.targets[i].actions[n].has_add_efct == 1 then
                    offset = offset + 37
                end
                act.targets[i].actions[n].has_spike_efct = get_bit_packed(data,offset,offset+1)
                offset = offset + 1
                if act.targets[i].actions[n].has_spike_efct == 1 then
                    offset = offset + 34
                end
            end
        end
        return act
    elseif id == 0x29 then		----------- ACTION MESSAGE ------------
		local am = {}
		am.actor_id   = get_bit_packed(data,0,32)
		am.target_id  = get_bit_packed(data,32,64)
		am.message_id = get_bit_packed(data,160,175)	-- Cut off the most significant bit, hopefully
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


-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------