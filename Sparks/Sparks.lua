_addon.name = 'Sparks'

_addon.author = 'Brax(orig) - Sammeh Modified - v 2.0.0.2'

_addon.version = '2.0.0.2'

_addon.command = 'sparks'


-- 2.0.0.2  Added version for my plugin.  Added in //sparks reset  and cleaned up some output 

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

all_temp_items = {}

current_temp_items = {}



valid_zones = T{"Western Adoulin","Southern San d'Oria","Windurst Woods","Bastok Markets","Escha - Ru'Aun","Escha - Zi'Tah","Reisinjima"}

valid_zones = {

	[256] = {npc="Eternal Flame", menu=5081}, -- Western Adoulin

	[230] = {npc="Rolandienne", menu=995}, -- Southern San d'Oria

	[235] = {npc="Isakoth", menu=26}, -- Bastok Markets

	[241] = {npc="Fhelm Jobeizat", menu=850}, -- Windurst Woods
	
	[288] = {npc="Affi", menu=9701},  -- Escha Zitah
	
	[289] = {npc="Dremi", menu=9701},  -- Escha RuAun
	
	[291] = {npc="Shiftrix", menu=9701},  -- Reisinjima
	
	}
	




defaults = {}

settings = config.load(defaults)




busy = false




windower.register_event('addon command', function(...)
    local args = T{...}
    local cmd = args[1]
	args:remove(1)
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	local item = table.concat(args," "):lower()
	ki = 0
	if cmd == 'buy' then
		if not busy then
			pkt = validate(item)
			if pkt then
				busy = true
				--print(pkt['Target'].."-"..pkt['Target Index'])
				poke_npc(pkt['Target'],pkt['Target Index'])
			else 
				windower.add_to_chat(2,"Can't find item in menu")
			end
		else
			windower.add_to_chat(2,"Still buying last item")
		end
	elseif cmd == 'buyall' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 241 or currentzone == 230 or currentzone == 235 or currentzone == 256 then 
			count_inv()
			windower.add_to_chat(2,"You have "..freeslots.." free slots, buying "..item.. " until full") 
			local currentloop = 0
			while currentloop < freeslots do
				currentloop = currentloop + 1
				windower.add_to_chat(8,"Buying Item: "..item.." Loop: "..currentloop)
				if not busy then
					pkt = validate(item)
					if pkt then
						busy = true
						poke_npc(pkt['Target'],pkt['Target Index'])
					else 
						windower.add_to_chat(2,"Can't find item in menu")
					end
				else
					windower.add_to_chat(2,"Still buying last item")
				end
				sleepcounter = 0
				while busy and sleepcounter < 5 do
					coroutine.sleep(1)
					sleepcounter = sleepcounter + 1
					if sleepcounter == "4" then
						windower.add_to_chat(2,"Probably lost a packet, waited too long!")
					end
				end
			end
		else 
			windower.add_to_chat(2,"You are not currently in a zone with a sparks NPC")
		end
	elseif cmd == 'buyki' then
		if not busy then
			ki = 1
			windower.add_to_chat(8,"Buying KI: "..item)
			pkt = validate(item)
			if pkt then
				busy = true
				--print(pkt['Target'].."-"..pkt['Target Index'])
				poke_npc(pkt['Target'],pkt['Target Index'])
			else 
				windower.add_to_chat(2,"Can't find item in menu")
			end
		else
			windower.add_to_chat(2,"Still buying last item")
		end

	elseif cmd == 'find' then
		table.vprint(fetch_db(item))
		
	elseif cmd == 'buyalltemps' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then 
			find_current_temp_items()
			find_missing_temp_items()
			number_of_missing_items = 0
			for countmissing,countitems in pairs(missing_temp_items) do
			    number_of_missing_items = number_of_missing_items +1
			end
			windower.add_to_chat(8,'Number of Missing Items: '..number_of_missing_items)
			if number_of_missing_items ~= 0 then 
				for keya,itema in pairs(missing_temp_items) do
					for keyb,itemb in pairs(db) do
						if itemb.TempItem == 1 then
							if keyb == itema then
								local item = itemb.Name:lower()
								windower.add_to_chat(8,'Buying Temp Item:'..item)
								if not busy then
									pkt = validate(item)
									if pkt then
										busy = true
										poke_npc(pkt['Target'],pkt['Target Index'])
									else 
										windower.add_to_chat(2,"Can't find item in menu")
									end
								else
									windower.add_to_chat(2,"Still buying last item")
								end
								sleepcounter = 0
								while busy and sleepcounter < 5 do
									coroutine.sleep(1)
									sleepcounter = sleepcounter + 1
									if sleepcounter == "4" then
										windower.add_to_chat(2,"Probably lost a packet, waited too long!")
									end
								end
							end
						end
					end
				end
			end
		else 
		  windower.add_to_chat(8,'You are not in a Gaes Fete Area')
		end
	
	elseif cmd == 'listtemp' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then 
			find_current_temp_items()
			find_missing_temp_items()
			number_of_missing_items = 0
			for countmissing,countitems in pairs(missing_temp_items) do
			    number_of_missing_items = number_of_missing_items +1
			end
			windower.add_to_chat(8,'Number of Missing Items: '..number_of_missing_items)
		else 
			windower.add_to_chat(8,'You are not in a Gaes Fete Area')
		end
	
	elseif cmd == 'listki' then
		find_missing_ki()
		--for id,ki in pairs(missing_ki) do
		--	windower.add_to_chat(8,"Missing KI:"..ki)
		--end
		
		if found_mollifier == 0 then 
			windower.add_to_chat(8,"Mollifier: Missing")
		else
			windower.add_to_chat(8,"Mollifier: Check")
		end
		if found_radialens == 0 then 
			windower.add_to_chat(8,"Radialens: Missing")
		else
			windower.add_to_chat(8,"Radialens: Check")
		end
		if found_tribulens == 0 then 
			windower.add_to_chat(8,"Tribulens: Missing")
		else
			windower.add_to_chat(8,"Tribulens: Check")
		end
		
	elseif cmd == 'reset' then
		reset_me()	
	elseif cmd == 'buyallki' then
		local currentzone = windower.ffxi.get_info()['zone']
		if currentzone == 291 or currentzone == 289 or currentzone == 288 then 
			find_missing_ki()
			number_of_missing_items = 0
			for countmissing,countitems in pairs(missing_ki) do
			    number_of_missing_items = number_of_missing_items +1
			end
			windower.add_to_chat(8,'Number of Missing Items: '..number_of_missing_items)
			if number_of_missing_items ~= 0 then 
				for keya,itema in pairs(missing_ki) do
					for keyb,itemb in pairs(db) do
						if itemb.TempItem == 2 then
							if itemb.Name:lower() == itema:lower() then
								local item = itemb.Name:lower()
								windower.add_to_chat(8,'Buying Temp Item:'..item)
								if not busy then
									pkt = validate(item)
									if pkt then
										busy = true
										poke_npc(pkt['Target'],pkt['Target Index'])
									else 
										windower.add_to_chat(2,"Can't find item in menu")
									end
								else
									windower.add_to_chat(2,"Still buying last item")
								end
								sleepcounter = 0
								while busy and sleepcounter < 5 do
									coroutine.sleep(1)
									sleepcounter = sleepcounter + 1
									if sleepcounter == "4" then
										windower.add_to_chat(2,"Probably lost a packet, waited too long!")
									end
								end
							end
						end
					end
				end
			end
		else 
		  windower.add_to_chat(8,'You are not in a Gaes Fete Area')
		end
	end
end)




function validate(item)
	local zone = windower.ffxi.get_info()['zone']
	local me,target_index,target_id,distance
	local result = {}

	if valid_zones[zone] then
		for i,v in pairs(windower.ffxi.get_mob_array()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = i
			elseif v['name'] == valid_zones[zone].npc then
				target_index = i
				target_id = v['id']
				npc_name = v['name']
				result['Menu ID'] = valid_zones[zone].menu
				distance = windower.ffxi.get_mob_by_id(target_id).distance
			end
		end

		if math.sqrt(distance)<6 then
            local ite = fetch_db(item)
			if ite then
				result['Target'] = target_id
				result['Option Index'] = ite['Option']
				result['_unknown1'] = ite['Index']
				result['Target Index'] = target_index
				result['Zone'] = zone 
			end
		else
		windower.add_to_chat(10,"Too far from npc")
		end
	else
	windower.add_to_chat(10,"Not in a zone with sparks npc")
	end
	if result['Zone'] == nil then result = nil end
	return result
end




function fetch_db(item)

 for i,v in pairs(db) do

  if string.lower(v.Name) == string.lower(item) then

	return v

  end

 end

end

function find_all_tempitems()
	for i,v in pairs(db) do
		if v.TempItem == 1 then
			all_temp_items[#all_temp_items+1] = i
		end
	end
end


function find_current_temp_items()
 count = 0
 current_temp_items = {}
 tempitems = windower.ffxi.get_items().temporary
 for key,item in pairs(tempitems) do
-- print(key,item)
 if key ~= 'max' and key ~= 'count'  and key ~= 'enabled' then
 	for ida,itema in pairs(item) do
		if itema ~= 0 and ida == 'id' then 
			count = count + 1
			current_temp_items[#current_temp_items+1] = itema
		end
	end
 end
 end
 
end

function find_missing_temp_items()
 missing_temp_items = {}
 for key,item in pairs(all_temp_items) do
	itemmatch = 0
	for keya,itema in pairs(current_temp_items) do
		if item == itema then
			itemmatch = 1
		end
	end
	if itemmatch == 0 then
		missing_temp_items[#missing_temp_items+1] = item
		-- print(db[item].Name)
	end
 end
 --print(table.concat(missing_temp_items, ', '))
end

function find_missing_ki()
	missing_ki = {}
 	found_mollifier = 0
	found_radialens = 0
	found_tribulens = 0
	local keyitems = windower.ffxi.get_key_items()
	for id,ki in pairs(keyitems) do
		if ki == 3032 then
			found_mollifier = 1
		elseif ki == 3031 then
			found_radialens = 1
		elseif ki == 2894 then
			found_tribulens = 1
		end
	end
	if found_mollifier == 0 then
		missing_ki[#missing_ki+1] = "mollifier"
	end
	if found_tribulens == 0 then
		missing_ki[#missing_ki+1] = "tribulens"
	end
	if found_radialens == 0 then
		missing_ki[#missing_ki+1] = "radialens"
	end
	--print(table.concat(missing_ki, ', '))
end


windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)

	if id == 0x034 or id == 0x032 then

	 if busy == true and pkt then

		local packet = packets.new('outgoing', 0x05B)

		-- request item
		packet["Target"]=pkt['Target']

		if npc_name ~= 'Dremi' and npc_name ~= 'Affi' and npc_name ~= 'Shiftrix' then
			packet["Option Index"]=pkt['Option Index']
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=pkt['Target']
			packet["Option Index"]=0
			packet["_unknown1"]=16384
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			
		else  -- reisinjima does it different....
			packet["Option Index"]=pkt['Option Index']
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			if ki == 0 then
				packet["Target"]=pkt['Target']
				packet["Option Index"]=14
				packet["_unknown1"]=pkt['_unknown1']
				packet["Target Index"]=pkt['Target Index']
				packet["Automated Message"]=true
				packet["_unknown2"]=0
				packet["Zone"]=pkt['Zone']
				packet["Menu ID"]=pkt['Menu ID']
				packets.inject(packet)
			elseif ki == 1 then 
				packet["Target"]=pkt['Target']
				packet["Option Index"]=3
				packet["_unknown1"]=pkt['_unknown1']
				packet["Target Index"]=pkt['Target Index']
				packet["Automated Message"]=true
				packet["_unknown2"]=0
				packet["Zone"]=pkt['Zone']
				packet["Menu ID"]=pkt['Menu ID']
				packets.inject(packet)
			end 
		-- send exit menu
			packet["Target"]=pkt['Target']
			packet["Option Index"]=0
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
		end
		
		-- print(npc_name)
--		print(pkt['Target'])
--		print(pkt['Option Index'])
--		print(pkt['_unknown1'])
--		print(pkt['Target Index'])
--		print(pkt['Zone'])
--		print(pkt['Menu ID'])
--		print("sent")


		local packet = packets.new('outgoing', 0x016, {["Target Index"]=pkt['me'],})
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

function count_inv()
	local playerinv = windower.ffxi.get_items().inventory
	freeslots = playerinv.max - playerinv.count
	print(freeslots)

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



windower.register_event('load', function()
	find_all_tempitems()
end)







--[[

]]