

function default_post_precast(spell, spellMap, eventArgs)
	if not eventArgs.handled then
		if spell.type == 'WeaponSkill' then
			if state.Capacity.value == true then 
				equip(sets.Capacity)
			end
		end
	end
end

function default_post_midcast(spell, spellMap, eventArgs)
	if not eventArgs.handled then
		if state.Capacity.value == true then
			if set.contains(spell.targets, 'Enemy') then
		
				if spell.skill == 'Elemental Magic' or spell.skill == 'Blue Magic' or spell.action_type == 'Ranged Attack' then
					equip(sets.Capacity)
				end
			end
		end
	end
end

function default_post_pet_midcast(spell, spellMap, eventArgs)
	if state.Capacity.value == true then
		equip(sets.Capacity)
	end
end

-- CAPACITY MODE FUNTIONS
function get_item_next_use(name)--returns time that you can use the item again
    for _,n in pairs({"inventory","wardrobe","wardrobe2","wardrobe3","wardrobe4"}) do
        for _,v in pairs(gearswap.items[n]) do
            if type(v) == "table" and v.id ~= 0 and res.items[v.id].english:lower() == name:lower() then
                return extdata.decode(v)
            end
        end
    end
end

function cp_ring_equip(ring)--equips given ring
	enable("left_ring")
    gearswap.equip_sets('equip_command',nil,{left_ring=ring})
    disable("left_ring")
end

function check_cpring()
--	local CurrentTime = (os.time(os.date("!*t", os.time())) + time_offset)
	local CurrentTime = (os.time(os.date('!*t')) + time_offset)
	
	if player.main_job_level < 99 then
			if player.equipment.head and player.equipment.head == 'Sprout Beret' and get_item_next_use(player.equipment.head).usable then
				send_command('input /item "'..player.equipment.head..'" <me>')
				cp_delay = 0
				return true
			   
			elseif item_available('Sprout Beret') and ((get_item_next_use('Sprout Beret').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Sprout Beret').charges_remaining > 0) then
				enable("head")
				gearswap.equip_sets('equip_command',nil,{head="Sprout Beret"})
				disable("head")
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Echad Ring' and get_item_next_use('Echad Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Echad Ring') and ((get_item_next_use('Echad Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Echad Ring')
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Caliber Ring' and get_item_next_use('Caliber Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Caliber Ring') and ((get_item_next_use('Caliber Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Caliber Ring')
				cp_delay = 10
				return true
			   
			elseif player.equipment.left_ring == 'Emperor Band' and get_item_next_use('Emperor Band').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Emperor Band') and ((get_item_next_use('Emperor Band').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Emperor Band')
				cp_delay = 10
				return true
				
			elseif player.equipment.left_ring == 'Empress Band' and get_item_next_use('Empress Band').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Empress Band') and ((get_item_next_use('Empress Band').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Empress Band')
				cp_delay = 10
				return true
				
			elseif player.equipment.left_ring == 'Resolution Ring' and get_item_next_use('Resolution Ring').usable then
				send_command('input /item "'..player.equipment.left_ring..'" <me>')
				cp_delay = 0
				return true
			elseif item_available('Resolution Ring') and ((get_item_next_use('Resolution Ring').next_use_time) - CurrentTime) < 15 then
				cp_ring_equip('Resolution Ring')
				cp_delay = 10
				return true
	 
			else
				cp_delay = 0
				return false
			end
		
	elseif cprings:contains(player.equipment.left_ring) and get_item_next_use(player.equipment.left_ring).usable then
		send_command('input /item "'..player.equipment.left_ring..'" <me>')
		cp_delay = 0
		return true
	
	elseif player.equipment.head and player.equipment.head == 'Guide Beret' and get_item_next_use(player.equipment.head).usable then
		send_command('input /item "'..player.equipment.head..'" <me>')
		cp_delay = 0
		return true
		
	elseif item_available('Guide Beret') and ((get_item_next_use('Guide Beret').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Guide Beret').charges_remaining > 0) then
		enable("head")
		gearswap.equip_sets('equip_command',nil,{head="Guide Beret"})
		disable("head")
		cp_delay = 10
		return true
  
  elseif item_available('Endorsement Ring') and ((get_item_next_use('Endorsement Ring').next_use_time) - CurrentTime) < 15 then
		cp_ring_equip('Endorsement Ring')
		cp_delay = 10
		return true
		
	elseif item_available('Trizek Ring') and ((get_item_next_use('Trizek Ring').next_use_time) - CurrentTime) < 15 then
		cp_ring_equip('Trizek Ring')
		cp_delay = 10
		return true
		
	elseif item_available('Capacity Ring') and ((get_item_next_use('Capacity Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Capacity Ring').charges_remaining > 0) then
		cp_ring_equip('Capacity Ring')
		cp_delay = 10
		return true
			
	elseif item_available('Vocation Ring') and ((get_item_next_use('Vocation Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Vocation Ring').charges_remaining > 0) then
		cp_ring_equip('Vocation Ring')
		cp_delay = 10
		return true
	
	elseif item_available('Facility Ring') and ((get_item_next_use('Facility Ring').next_use_time) - CurrentTime) < 15 and (get_item_next_use('Facility Ring').charges_remaining > 0) then
		cp_ring_equip('Facility Ring')
		cp_delay = 10
		return true
	
	elseif player.equipment.head and player.equipment.head == 'Guide Beret' and (((get_item_next_use(player.equipment.head).next_use_time) - CurrentTime) > 15 or (get_item_next_use(player.equipment.head).charges_remaining == 0)) then
		enable("head")
		handle_equipping_gear(player.status)
		cp_delay = 19
		return true
		
	elseif cprings:contains(player.equipment.left_ring) and (((get_item_next_use(player.equipment.left_ring).next_use_time) - CurrentTime) > 15 or (get_item_next_use(player.equipment.left_ring).charges_remaining == 0)) then
		enable("left_ring")
		handle_equipping_gear(player.status)
		cp_delay = 19
		return true
	
	end
	
	cp_delay = 0
	return false
end

function check_cpring_buff()-- returs true if you do not have the buff from xp cp ring
	cp_delay = cp_delay + 1
	
	if time_test then
		local CurrentTime = (os.time(os.date("!*t", os.time())) + time_offset)
		windower.add_to_chat(123,"Capacity Ring Next Use: "..(get_item_next_use('Capacity Ring').next_use_time - CurrentTime).."")
	end
	
	if state.Capacity.value and cp_delay > 20 and not moving and not areas.Cities:contains(world.area) then
	
		if player.satchel['Mecisto. Mantle'] then send_command('get "Mecisto. Mantle" satchel;wait 2;gs c update') end
		if player.satchel['Endorsement Ring'] then send_command('get "Endorsement Ring" satchel') end
		if player.satchel['Trizek Ring'] then send_command('get "Trizek Ring" satchel') end
		if player.satchel['Capacity Ring'] then send_command('get "Capacity Ring" satchel') end
		if player.satchel['Vocation Ring'] then send_command('get "Vocation Ring" satchel') end
		if player.satchel['Facility Ring'] then send_command('get "Facility Ring" satchel') end
		if player.satchel['Guide Beret'] then send_command('get "Guide Beret" satchel') end
		if player.satchel['Echad Ring'] and player.main_job_level < 99 then send_command('get "Echad Ring" satchel') end
	
		if buffactive['Commitment'] then
			return false
		elseif buffactive['Dedication'] == 2 then
			return false
		elseif not buffactive['Dedication'] then
			if check_cpring() then
				return true
			else
				return false
			end
		elseif buffactive['Dedication'] == 1 then
			if have_trust("Kupofried") then
				if check_cpring() then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	else
		return false
	end
	return false	
end