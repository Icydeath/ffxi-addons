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
    * Neither the name of HomePoint nor the
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

_addon.name = 'HomePoint'

_addon.author = 'Sammeh'

_addon.version = '1.0.7'

_addon.command = 'hp'


-- 1.0.2 - fixed if you mistyped one
-- 1.0.3 - fixed up some naming of home points in map
-- 1.0.4 - fix bug when not in a zone with a HP
-- 1.0.5 - fix homepoint name of Marjami Ravine to "Marjami Ravine 1"
-- 1.0.6 - Added a reset option - which will reset a locked NPC transaction.
-- 1.0.7 - Added //hp set  to set HomePoint to closest hp.

-- Usage  //hp warp <Location> <# of HomePoint>   
-- Examples:  //hp warp Mhaura 1
--			  //hp warp Ru'Aun Gardens 5


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


pkt = {}

found = 0
hpset = 0

defaults = {}

settings = config.load(defaults)

busy = false

windower.register_event('addon command', function(...)

    local args = T{...}
    local cmd = args[1]
	args:remove(1)
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	local item = table.concat(args," "):lower()
	if cmd == 'warp' then
		hpset = 0
		local validatehp = fetch_db(item)
		local findhp = find_homepoint()
		if findhp == 1 then 
			if validatehp then
				windower.add_to_chat(10,"Warping to: "..item)
				if not busy then
					pkt = validate(item)
					if pkt then
						busy = true
						poke_npc(pkt['Target'],pkt['Target Index'])
					end
				end
			else 
				windower.add_to_chat(10,"Could not find Home Point: "..item)
			end
		elseif cmd == 'test' then
			hpset = 0
			test = 1
			if not busy then
				pkt = validate(item)
				if pkt then
					busy = true
					poke_npc(pkt['Target'],pkt['Target Index'])
				end
			end
		else
			windower.add_to_chat(10,"No Home Point found.  Are you near one?")
		end
	elseif cmd == 'set' then
		hpset = 1
		local findhp = find_homepoint()
		local validatehp = fetch_db(item)
		if findhp == 1 then 
			if not busy then
				pkt = validate(item)
				if pkt then
					busy = true
					poke_npc(pkt['Target'],pkt['Target Index'])
				end
			end
		else
			windower.add_to_chat(10,"No Home Point found.  Are you near one?")
		end
	elseif cmd == 'reset' then
		reset_me()	
	end
end)


function validate(item)

	local zone = windower.ffxi.get_info()['zone']

	local me,target_index,target_id,distance,found
	
	local result = {}

	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == windower.ffxi.get_player().name then
			result['me'] = i
		elseif string.find(v['name'],'Home Point') then
			found = 1
			target_index = i
			target_id = v['id']
			npc_name = v['name']
			if string.find(npc_name,'1') then 
				result['Menu ID'] = 8700
			elseif string.find(npc_name,'2') then 
				result['Menu ID'] = 8701
			elseif string.find(npc_name,'3') then 
				result['Menu ID'] = 8702
			elseif string.find(npc_name,'4') then 
				result['Menu ID'] = 8703
			elseif string.find(npc_name,'5') then 
				result['Menu ID'] = 8704
			end
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
			result['Option Index'] = 2
			result['_unknown1'] = item
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
		if hpset == 1 then
			result['Target'] = target_id
			result['Option Index'] = 8
			result['_unknown1'] = 0
			result['Target Index'] = target_index
			result['Zone'] = zone 
		end
		
	else
		windower.add_to_chat(10,"Found Home Point - but too far! Get within 6 yalms")
		result = nil
	end
	
	else 
	  windower.add_to_chat(10,"No Home Point Found")
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
		
		if hpset == 1 then 
			hpset = 0
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
			packet["Option Index"]=1
			packet["_unknown1"]=0
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			
		else 
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
		
			packet["Target"]=pkt['Target']
			packet["Option Index"]=pkt['Option Index']
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
		end
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
		packet["Menu ID"]=lastpkt['Menu ID']
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


function find_homepoint()
	found = 0
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if string.find(v['name'],'Home Point') then
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




