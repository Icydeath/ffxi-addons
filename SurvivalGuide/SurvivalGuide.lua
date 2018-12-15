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
    * Neither the name of SurvivalGuide nor the
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

_addon.name = 'SurvivalGuide'

_addon.author = 'Sammeh'

_addon.version = '1.0.3'

_addon.command = 'sg'

-- 1.0.1 - Fixed issue with prematurely sending packet before validating a Survival Guide in zone.
-- 1.0.2 - Added a reset option in case npc locked.  //sg reset
-- 1.0.3 - Added Thrifty Transit warning / Correction (Ugly)

require('tables')
require('chat')
require('logger')
require('functions')
packets = require('packets')
json  = require('json')
files = require('files')
config = require('config')
db = require('map')
res = require('resources')

npc_name = ""

found = 0

pkt = {}

found = 0
defaults = {}

settings = config.load(defaults)

busy = false
menu = 8500 -- default value for menus unless Kupo Fried is there.  If Kupofried do //sg reset and //sg reset1 (unlock yourself)  then //sg free  to set Menu to 8501 then //sg warp

windower.register_event('addon command', function(...)

    local args = T{...}
    local cmd = args[1]
	args:remove(1)
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	local item = table.concat(args," "):lower()
	if cmd == 'warp' then
		local validatehp = fetch_db(item)
		local findhp = find_sg()
		if findhp == 1 then 
			if validatehp then
				windower.add_to_chat(10,"Warping to: "..item)
				if menu == 8500 then
					windower.add_to_chat(10,"Please Note: If Thrifty Transit in Scope.  Please issue a //sg reset1; then //sg free; then //sg warp "..item.." again!")
				end
				if menu == 8501 then
					windower.add_to_chat(10,"Please Note: If Thrifty Transit fell Out of Scope.  Please issue a //sg reset; then //sg paid; then //sg warp "..item.." again!")
				end
				if not busy then
					pkt = validate(item)
					if pkt then
						busy = true
						poke_npc(pkt['Target'],pkt['Target Index'])
					end
				end
			else 
				windower.add_to_chat(10,"Could not find Survival Guide: "..item)
			end
		elseif cmd == 'test' then
			test = 1
			if not busy then
				pkt = validate(item)
				if pkt then
					busy = true
					poke_npc(pkt['Target'],pkt['Target Index'])
				end
			end
		else
			windower.add_to_chat(10,"No Survival Guide found.  Are you near one?")
		end
	elseif cmd == 'reset' then
		reset_me()	
	elseif cmd == 'reset1' then
		reset_me1()	
	elseif cmd == 'free' then
		menu = 8501
	elseif cmd == 'paid' then
		menu = 8500
	end
end)




function validate(item)

	local zone = windower.ffxi.get_info()['zone']

	local me,target_index,target_id,distance,found
	

	local result = {}

	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == windower.ffxi.get_player().name then
			result['me'] = i
		elseif string.find(v['name'],'Survival Guide') then
			found = 1
			target_index = i
			target_id = v['id']
			npc_name = v['name']
			result['Menu ID'] = menu
			
			distance = windower.ffxi.get_mob_by_id(target_id).distance
			windower.add_to_chat(8,'Found :'..npc_name..' Distance:'..math.sqrt(distance))
			if math.sqrt(distance)<6 then break end
		end
	end

	if found == 1 then 
	
	if math.sqrt(distance)<6 then
		local ite = fetch_db(item)
		
		if ite then
			result['Target'] = target_id
			result['Option Index'] = ite['Option']
			result['_unknown1'] = ite['Index']
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
		if test == 1 then
			result['Target'] = target_id
			result['Option Index'] = 1
			result['_unknown1'] = item
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
	else
		windower.add_to_chat(10,"Found Survival Guide - but too far! Get within 6 yalms")
		result = nil
	end
	
	else 
	  windower.add_to_chat(10,"No Survival Guide Found")
	end
	return result

end


function fetch_db(item)
 for i,v in pairs(db) do
  if string.lower(i) == string.lower(item) then
	return v
  end
 end
end


windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)

	if id == 0x034 or id == 0x032 then

	 if busy == true and pkt then

		local packet = packets.new('outgoing', 0x05B)

		-- request warp
		packet["Target"]=pkt['Target']
		packet["Option Index"]=8
		packet["_unknown1"]=0
		packet["Target Index"]=pkt['Target Index']
		packet["Automated Message"]=true
		packet["_unknown2"]=0
		packet["Zone"]=pkt['Zone']
		packet["Menu ID"]=pkt['Menu ID']
		packets.inject(packet)

		packet["Target"]=pkt['Target']
		packet["Option Index"]=pkt['Option Index']
		packet["_unknown1"]=pkt['_unknown1']
		packet["Target Index"]=pkt['Target Index']
		packet["Automated Message"]=true
		packet["_unknown2"]=0
		packet["Zone"]=pkt['Zone']
		packet["Menu ID"]=pkt['Menu ID']
		packets.inject(packet)
		
		-- send exit menu
		packet["Target"]=pkt['Target']
		packet["Option Index"]=pkt['Option Index']
		packet["_unknown1"]=pkt['_unknown1']
		packet["Target Index"]=pkt['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=pkt['Zone']
		packet["Menu ID"]=pkt['Menu ID']
		packets.inject(packet)

		local packet = packets.new('outgoing', 0x016, {
		["Target Index"]=pkt['me'],
		})

		packets.inject(packet)

		busy = false
		
		lastpkt = pkt

		pkt = {}

		return true

		end
	end

end)

function reset_me()
		local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=lastpkt['Target']
		packet["Option Index"]=lastpkt['Option Index']
		packet["_unknown1"]="16384"
		packet["Target Index"]=lastpkt['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=lastpkt['Zone']
		packet["Menu ID"]=8500
		packets.inject(packet)
end

function reset_me1()
		local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=lastpkt['Target']
		packet["Option Index"]=lastpkt['Option Index']
		packet["_unknown1"]="16384"
		packet["Target Index"]=lastpkt['Target Index']
		packet["Automated Message"]=false
		packet["_unknown2"]=0
		packet["Zone"]=lastpkt['Zone']
		packet["Menu ID"]=8501
		packets.inject(packet)
end

function poke_npc(npc,target_index)
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=npc,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function find_sg()
	found = 0
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if string.find(v['name'],'Survival Guide') then
			found = 1
			target_index = i
			target_id = v['id']
			npc_name = v['name']
			distance = windower.ffxi.get_mob_by_id(target_id).distance
		end
	end
	return found
end


windower.register_event('load', function()
end)




