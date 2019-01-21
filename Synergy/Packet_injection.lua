
function fire()
	target['Option Index'] = elements['fire']
	notice('Feeding Fire!!')
	poke()
end

function ice()
	target['Option Index'] = elements['ice']
	notice('Feeding ice!!')
	poke()
end

function wind()
	target['Option Index'] = elements['wind']
	notice('Feeding wind!!')
	poke()
end

function earth()
	target['Option Index'] = elements['earth']
	notice('Feeding earth!!')
	poke()
end

function thunder()
	target['Option Index'] = elements['thunder']
	notice('Feeding thunder!!')
	poke()
end

function water()
	target['Option Index'] = elements['water']
	notice('Feeding water!!')
	poke()
end

function light()
	target['Option Index'] = elements['light']
	notice('Feeding light!!')
	poke()
end

function dark()
	target['Option Index'] = elements['dark']
	notice('Feeding dark!!')
	poke()
end

function thwack()
	target['Option Index'] = furnace_functions['thwack']
	notice('Thwacking !!')
	poke()
end

function pressure()
	target['Option Index'] = furnace_functions['pressure']
	notice('pressure valve!!')
	poke()
end

function safety_lever()
	target['Option Index'] = furnace_functions['safety_lever']
	notice('safety lever!!')
	poke()
end

function repair_furnace()
	target['Option Index'] =furnace_functions['repair_furnace']
	notice('repair furnace!!')
	poke()
end

function recycle()
	target['Option Index'] = furnace_functions['recycle']
	notice('recycle!!')
	poke()
end

function end_it()
	target['Option Index'] = furnace_functions['end']
	notice('endding!!')
	poke()
end

function goldsmith_smock()
	target['Option Index'] = equipment_furnace_functions['goldsmith_smock']
	notice('Engraver\'s Touch!!')
	poke()
end

function poke()
	local distance = 0
	if windower.ffxi.get_mob_by_index(target["Target Index"]) then
		distance = windower.ffxi.get_mob_by_index(target["Target Index"]).distance
		-- turn distance into yalms to match the distance addon
		distance = distance:sqrt()
		if distance > 0 and distance < 2 then
			player = windower.ffxi.get_player()
			pkt = validate()
			local packet = packets.new('outgoing', 0x01A, {
				["Target"] = target['Target id'],
				["Target Index"] = target["Target Index"],
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
			if firstrun == true then 
				local packet = packets.new('outgoing', 0x016, {
						["Target Index"]=pkt['me'],
					})
				packets.inject(packet)
				firstrun = false
			end
		else
			error('Too far Away')
			return
		end
	end
end

function poke_engineer()
	local distance = 0
	if Synergy_Engineer_id then
		distance = windower.ffxi.get_mob_by_id(Synergy_Engineer_id).distance
		-- turn distance into yalms to match the distance addon
		distance = distance:sqrt()
		if distance > 0 and distance < 6 then
			player = windower.ffxi.get_player()
			pkt = validate()
			local packet = packets.new('outgoing', 0x01A, {
				["Target"] = Synergy_Engineer_id,
				["Target Index"] = windower.ffxi.get_mob_by_id(Synergy_Engineer_id).index,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		else
			error('Too far Away')
			return
		end
	end	
end

function validate()
	local me
	local result = {}
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == player.name then
			result['me'] = i
		end
	end
	return result 
end

function create_0x05B(target_id, target_index, option_index, zone_number, message, menu_id, unk_one, unk_two)
	
	local packet = packets.new('outgoing', 0x05B)
		packet["Target"]=			target_id
		packet["Option Index"]=		option_index
		packet["_unknown1"]=		unk_one
		packet["Target Index"]=		target_index
		packet["Menu ID"]=			menu_id
		packet["Zone"]=				zone_number
		packet["Automated Message"]=message
		packet["_unknown2"]=		unk_two
	packets.inject(packet)
	
end

function inject_0x10f()
	local packet = packets.new('outgoing', 0x10f)
	packets.inject(packet)
end
