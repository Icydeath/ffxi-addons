

function find_missing_kis(zone_id)
	
	if npcs[zone_id] then
		local toons_kis = windower.ffxi.get_key_items()
		local matching_kis = {}
		local missing_kis = {}
		
		-- ki's you do have
		for i,d in pairs(toons_kis) do
			-- i = table index
			-- d = ki id
			-- ki's you need
			for k, v in pairs(key_items) do
				-- k = ki id
				-- v = table contents
				if d == k then
					table.insert(matching_kis, d)
				end
			end
		end
		if table.length(matching_kis) == 20 then
			notice('You already posess all High-tier mission battlefield KI\'s. Will not create commands.')
			return
		end
		for k, v in pairs(key_items) do
			-- k = ki id
			-- v = table contents
			if not table.contains(matching_kis, k) then
				table.insert(missing_kis, k)
				log('Found missing KI \"' .. key_items[k]['KI Name'] .. '\"')
			end
		end
		
		local buy_number = 1
		for k, v in pairs(missing_kis) do
			local ki = false
			if number_of_merits >= key_items[v]['Merit Cost'] then
				for i, j in pairs(key_items[v]) do
					if i == "Option Index" then
						generate_ki_commands(buy_number,v)
						buy_number = buy_number + 1
						ki = true
						break
					end
				end
				if ki == false then
					warning('Lack of packet information to buy KI: \"' .. (key_items[v]['KI Name']):color(215) .. '\". Will not create command.')
				end
			else
				notice('You do not have enought merits to buy \"' .. (key_items[v]['KI Name']):color(215) .. '\". Will not create command.')
			end
		end
	else
		error('You are not in a zone with an available KI NPC!')
	end
end

function check_zone_for_battlefield(zone_id)
	if zones[zone_id] then
		log('Checking potential battlefields!')
		local toons_kis = windower.ffxi.get_key_items()
		local matching_kis = {}
		local current_zone_kis = {}
		-- ki's you do have
		for i,d in pairs(toons_kis) do
			-- i = table index
			-- d = ki id
			-- ki's you need
			for k, v in pairs(key_items) do
				-- k = ki id
				-- v = table contents
				if d == k then
					table.insert(matching_kis, d)
				end
			end
		end
		for k,v in pairs(zones[zone_id]) do
			if k ~= nil and type(k) == 'number' then
				-- k = ki id
				-- v = table contents
				if table.contains(matching_kis, k) then
					table.insert(current_zone_kis, k)
				end
			end
		end
		if table.length(current_zone_kis) == 0 then
			warning('You have no KI\'s for this zone.')
			return
		end
		for k, v in pairs(current_zone_kis) do
			generate_commands(k,v,zone_id)
		end
		first_poke = true
	else
		error('Not in a BCNM zone!')
	end

end