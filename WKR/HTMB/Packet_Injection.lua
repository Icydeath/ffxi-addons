
-- now requires a valid zone number that exists in the zone_info.lua and also requires to be within range of the BCNM entrance
function poke_warp(zone_number,ki_id)

	local distance = 0
	if windower.ffxi.get_mob_by_index(zones[zone_number][ki_id]['0x05B']["Target Index"]) then
		distance = windower.ffxi.get_mob_by_index(zones[zone_number][ki_id]['0x05B']["Target Index"]).distance
		-- turn distance into yalms to match the distance addon
		distance = distance:sqrt()
		if distance > 0 and distance < 5 then
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=zones[zone_number][ki_id]['0x05B']["Target"],
				["Target Index"]=zones[zone_number][ki_id]['0x05B']["Target Index"],
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			first_poke = true
			notice('Attempting to entre BCNM, sending poke!')
			packets.inject(packet)
		else
			activate_by_addon = false
			error('You are too far away from the entrance!')
		end
	else
		activate_by_addon = false
		error('Cureently no information regarding High-Tier Mission Battlefields in this zone')
	end
end

-- now requires a valid zone number that exists in the zone_info.lua and also requires to be within range of the BCNM entrance
function poke_npc(zone_number,ki_id)

	local distance = 0
	if windower.ffxi.get_mob_by_index(npcs[zone_number]['NPC Index']) then
		distance = windower.ffxi.get_mob_by_index(npcs[zone_number]['NPC Index']).distance
		-- turn distance into yalms to match the distance addon
		distance = distance:sqrt()
		if distance > 0 and distance < 5 then
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=npcs[zone_number]['NPC'],
				["Target Index"]=npcs[zone_number]['NPC Index'],
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			notice('Attempting to buy KI, sending poke!')
			packets.inject(packet)
		else
			activate_by_addon_npc = false
			error('You are too far away from the NPC!')
		end
	else
		activate_by_addon_npc = false
		error('Cureently no information regarding KI NPC\'s in this zone')
	end
end

function poke_warp_HP(current_zone)
	local distance = 0
	if HPs[current_zone] then
		for k, v in pairs(HPs[current_zone]) do
			if type(v) == 'table' and table.length(v) > 0 then
				if windower.ffxi.get_mob_by_index(v["Target Index"]) then
					distance = windower.ffxi.get_mob_by_index(v["Target Index"]).distance
					distance = distance:sqrt()
					if distance > 0 and distance < 5 then
						current_HP_number = k
						local packet = packets.new('outgoing', 0x01A, {
							["Target"]=v["Target"],
							["Target Index"]=v["Target Index"],
							["Category"]=0,
							["Param"]=0,
							["_unknown1"]=0})
						notice('Attempting to poke '.. windower.ffxi.get_mob_by_index(v["Target Index"]).name ..'!')
						packets.inject(packet)
						return true
					else
						activate_by_addon_npc = false
						error('You are too far away from the Home Point!')
					end
				end
			end	
		end
	else
		error('You have no data for Home Points in this zone')
	end
end

-- function to inject anomylous packets associated with first time click on BCNM
function inject_anomylus_packets(zone_number)
	
	for k,v in pairs(zones[zone_number][current_ki_id]['0x016']) do
		if v ~= nil and type(v) == 'number' then
			local packet = packets.new('outgoing', 0x016, {
				["Target Index"]=v,
			})
			packets.inject(packet)
		end	
	end

end

-- function to send menu choice bassed on zone id
function create_0x05B(zone_number,option_index,message)

	local info = zones[zone_number][current_ki_id]['0x05B']
	
	local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=			info["Target"]
		packet["Option Index"]=		info["Option Index"][option_index]
		packet["_unknown1"]=		info["_unknown1"]
		packet["Target Index"]=		info["Target Index"]
		packet["Menu ID"]=			info["Menu ID"]
		packet["Zone"]=				zone_number
		packet["Automated Message"]=message
		packet["_unknown2"]=		0
	packets.inject(packet)
	
end

-- function to send menu choice to buy ki bassed on zone id
-- create_0x05B_ki(current_zone,j[1],true,current_ki_id)
function create_0x05B_ki(zone_number,option_index,message,ki_id)

	local info = npcs[zone_number]['0x05B']
	
	local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=			info["Target"]
		packet["Option Index"]=		key_items[ki_id]["Option Index"][option_index]
		packet["_unknown1"]=		info["_unknown1"]
		packet["Target Index"]=		info["Target Index"]
		packet["Menu ID"]=			info["Menu ID"]
		packet["Zone"]=				zone_number
		packet["Automated Message"]=message
		packet["_unknown2"]=		0
	packets.inject(packet)
	
end

function create_0x05B_HP(zone_number,option_index,message,HP_number,unknown_number)

	local info = HPs[zone_number][HP_number]
	
	local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=			info["Target"]
		packet["Option Index"]=		info["Option Index"][option_index]
		packet["_unknown1"]=		info["_unknown1"][unknown_number]
		packet["Target Index"]=		info["Target Index"]
		packet["Menu ID"]=			8701
		packet["Zone"]=				zone_number
		packet["Automated Message"]=message
		packet["_unknown2"]=		0
	packets.inject(packet)
	
end

-- function to request entry to BCNM bassed on the current zone id
function create_0x05C(packet_table)

	local packet = packets.new('outgoing', 0x05C)
		packet["X"]= 			packet_table["X"]
		packet["Z"]=			packet_table["Z"]
		packet["Y"]= 			packet_table["Y"]
		packet["Target ID"]=	packet_table["Target ID"]
		packet["Target Index"]=	packet_table["Target Index"]
		packet["_unknown1"]=	packet_table["_unknown1"]
		packet["_unknown2"]=	packet_table["_unknown2"]
		packet["_unknown3"]=	packet_table["_unknown3"]
	packets.inject(packet)
	
end