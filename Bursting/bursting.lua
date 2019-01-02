--[[

	Many thanks to Ryan Skeldon, the creator of the addon Grimoire.
	This code borrows elements from his addon but is heavily modified.

]]

_addon.version = '1.0.0'
_addon.name = 'Bursting'
_addon.author = 'Valok@Asura, psykad'
_addon.commands = {'bursting', 'mb'}

require 'tables'
require 'strings'

res = require('resources')

local debug = true--false
local manualOverrides = true
local napMode = false

local skillchains = {
	[288] = {english='Light', elements={'Light', 'Fire', 'Thunder', 'Wind'}},
	[289] = {english='Darkness', elements={'Dark', 'Earth', 'Water', 'Ice'}},
	[290] = {english='Gravitation', elements={'Dark', 'Earth'}},
	[291] = {english='Fragmentation', elements={'Thunder', 'Wind'}},
	[292] = {english='Distortion', elements={'Water', 'Ice'}},
	[293] = {english='Fusion', elements={'Light', 'Fire'}},
	[294] = {english='Compression', elements={'Dark'}},
	[295] = {english='Liquefaction', elements={'Fire'}},
	[296] = {english='Induration', elements={'Ice'}},
	[297] = {english='Reverberation', elements={'Water'}},
	[298] = {english='Transfixion', elements={'Light'}},
	[299] = {english='Scission', elements={'Earth'}},
	[300] = {english='Detonation', elements={'Wind'}},
	[301] = {english='Impaction', elements={'Thunder'}},
	[302] = {english='AnyElement', elements={'Fire', 'Thunder', 'Wind', 'Earth', 'Water', 'Ice'}}
}

local spell_tiers = {
	'',
	' II',
	' III',
	' IV',
	' V',
	' VI',
}

local spell_priorities = {
	'Thunder',
	'Ice',
	'Fire',
	'Wind',
	'Water',
	'Earth',
	'Dark',
	'Light',
}

local spell_strengths = {
	['Fire'] = {weakness = 'Water'},
	['Ice'] = {weakness = 'Fire'},
	['Wind'] = {weakness = 'Ice'},
	['Earth'] = {weakness = 'Wind'},
	['Thunder'] = {weakness = 'Earth'},
	['Water'] = {weakness = 'Thunder'},
	['Dark'] = {weakness = 'Thunder'},
	['Light'] = {weakness = 'Ice'},
}


local storms = { 
	{name = 'Firestorm', weather = 'Fire'}, 
	{name = 'Hailstorm', weather = 'Ice'}, 
	{name = 'Windstorm', weather = 'Wind'}, 
	{name = 'Sandstorm', weather = 'Earth'}, 
	{name = 'Thunderstorm', weather = 'Thunder'}, 
	{name = 'Rainstorm', weather = 'Water'}, 
	{name = 'Aurorastorm', weather = 'Light'}, 
	{name = 'Voidstorm', weather = 'Dark'},
}

local elements = {
	['Thunder'] = {spell = 'Thunder', helix = 'Ionohelix', ga = 'Thundaga', ja = 'Thundaja', ra = 'Thundara',},
	['Ice'] = {spell = 'Blizzard', helix = 'Cryohelix', ga = 'Blizzaga', ja = 'Blizzaja', ra = 'Blizzara'},
	['Fire'] = {spell = 'Fire', helix = 'Pyrohelix', ga = 'Firaga', ja = 'Firaja', ra = 'Fira'},
	['Wind'] = {spell = 'Aero', helix = 'Anemohelix', ga = 'Aeroga', ja = 'Aeroja', ra = 'Aera'},
	['Water'] = {spell = 'Water', helix = 'Hydrohelix', ga = 'Waterga', ja = 'Waterja', ra = 'Watera'},
	['Earth'] = {spell = 'Stone', helix = 'Geohelix', ga = 'Stonega', ja = 'Stoneja', ra = 'Stonera'},
	['Dark'] = {spell = nil, helix = 'Noctohelix', ga = nil, ja = nil, ra = nil},
	['Light'] = {spell = nil, helix = 'Luminohelix', ga = nil, ja = nil, ra = nil},
}

local activeSkillchain = nil
local activeSkillchainStartTime = 1

windower.register_event('addon command', function(...)
	if #arg == 0 then
		return
	elseif #arg == 1 and arg[1] == 'force' then
		arg[2] = arg[1]
		arg[1] = 'Spell'
	end

	local forced = false

	if arg[1] == 'force' then
		forced = true
		activeSkillchain = skillchains[302] -- SET to 302 after testing!!!
		
		for i = 1, #arg - 1 do
			arg[i] = arg[i + 1]
		end

		table.remove(arg, #arg)
	end



	-- FOR TESTING
	--activeSkillchain = skillchains[289]
	--activeSkillchainStartTime = os.time() - 3



	local spell_selectedType = arg[1]
	local spell_selectedTier = tonumber(arg[2])

	if (os.time() - activeSkillchainStartTime > 8 or not activeSkillchain) and not forced then
		print('No Magic Burst Possible')
		return
	elseif not spell_selectedType or not T{'spell', 'helix', 'ga', 'ja', 'ra'}:contains(spell_selectedType) then
		print('Spelltype "' .. spell_selectedType .. '" is invalid. Valid options are: spell, helix, ga, ja, and ra')
		return
	elseif not spell_selectedTier then -- or not T{'6', '5', '4', '3', '2', '1'}:contains(spell_selectedTier)then
		print('Invalid Spell Tier')
		return
	end

	if debug then print('Skillchain: ' .. activeSkillchain.english) end

	local weather_element = nil
	local day_element = nil
	local priority_element = nil
	local skillchain_element = nil
	local spellToCast = nil
	local player = windower.ffxi.get_player()
	local buff_name = ''

	-- Get weather. SCH Weather buff takes priority
	if #player.buffs > 0 then
		for i = 1, #player.buffs do
			buff_name = res.buffs[player.buffs[i]].name

			for o = 1, #storms do
				if buff_name == storms[o].name then
					weather_element = storms[i].weather
					if debug then print('SCH Weather Found: ' .. weather_element) end
					break
				end
			end

			if weather_element then
				break
			end
		end
	end

	if not weather_element then
		weather_element = res.elements[res.weather[windower.ffxi.get_info().weather].element].en
		if debug then print('Weather Found: ' .. weather_element) end
	end

	if weather_element == 'Lightning' then
		if debug then print('Changing weather from Lightning to Thunder') end
		weather_element = 'Thunder'
	end



	-- FOR TESTING
	--weather_element = 'Water'



	-- Get day element
	local day_element = res.elements[res.days[windower.ffxi.get_info().day].element].en
	if not day_element then
		if debug then print('day_element is nil') end
	elseif day_element == 'Lightning' then
		if debug then print('Changing day from Lightning to Thunder') end
		day_element = 'Thunder'
	end

	-- Determine which benefits the spell most; Weather, day, or priority
	if weather_element and T(activeSkillchain.elements):contains(weather_element) then
		skillchain_element = weather_element
		if debug then print('Bursting weather element: ' .. skillchain_element) end
	elseif day_element ~= nil and elements[day_element][spell_selectedType] and T(activeSkillchain.elements):contains(day_element) then
		skillchain_element = day_element
		if debug then print('Bursting day element ' .. skillchain_element) end
	else -- If weather or day provide no benefit, just go by priority
		for i = 1, #spell_priorities do
			if T(activeSkillchain.elements):contains(spell_priorities[i]) then
				--print(spell_priorities[i] .. ' has priority in ' .. activeSkillchain.english)
				skillchain_element = spell_priorities[i]
				if debug then print('Bursting priority element: ' .. skillchain_element) end
				break
			end
		end
	end

	if not skillchain_element then
		print('No skillchain_element found for ' .. activeSkillchain.english)
		return
	end

	skillchain_element = mobExceptions(skillchain_element, forced)
	
	
	if elements[skillchain_element][spell_selectedType] then
		spellToCast = elements[skillchain_element][spell_selectedType] .. spell_tiers[spell_selectedTier]
	end
	
	if spellToCast then
		if debug then print('Casting: ' .. spellToCast) end
		windower.send_command('input /ma "' .. spellToCast .. '" <t>')
	else
		print('No valid spell for ' .. skillchain_element)
	end
end)

function mobExceptions(skillchain_element, forced)
	local battle_target = windower.ffxi.get_mob_by_target('t')
	if debug then print('Target: ' .. battle_target.name) end

	if not battle_target then
		return skillchain_element
	end
	
	if battle_target.name:contains(' Crab') and skillchain_element == 'Water' and (activeSkillchain.english == 'Distortion' or activeSkillchain.english == 'Darkness' or forced) then
		if debug then print('Water detected on crab: Changing to Blizzard') end
		return 'Ice'
	elseif battle_target.name:contains(' Elemental') then
		if forced then
			if debug then print(skillchain_element .. ' forced on ' .. skillchain_element .. ' Elemental. Changing to weakness') end
			
			if battle_target.name == 'Air Elemental' then
				battle_target.name = 'Wind Elemental'
			end

			return spell_strengths[string.sub(battle_target.name, 1, string.find(battle_target.name, ' ') - 1)].weakness
		else

		end
	end

	return skillchain_element
end

windower.register_event('incoming chunk', function(id, orig)
	if id == 0x28 then
		local packet = windower.packets.parse_action(orig)
		
		for _, target in pairs(packet.targets) do
			local battle_target = windower.ffxi.get_mob_by_target("bt")
			
			if battle_target ~= nil and target.id == battle_target.id then
				for _, action in pairs(target.actions) do
					if action.add_effect_message > 287 and action.add_effect_message < 302 then
						if os.time() - activeSkillchainStartTime <= 8 then
							windower.send_command('timers d "MAGIC BURST: ' .. activeSkillchain.english .. '"')
						end

						activeSkillchain = skillchains[action.add_effect_message]
						activeSkillchainStartTime = os.time()
						windower.send_command('timers c "MAGIC BURST: ' .. activeSkillchain.english .. '" 8 down')

						if debug then
							windower.add_to_chat(8, 'Skillchain ' .. action.add_effect_message .. ': ' .. activeSkillchain.english)
						end
					else
						if debug then
							if action.add_effect_message > 0 then
								--print(action.add_effect_message)
							end
						end
					end
				end
			end			
		end
	end
end)

function dump(o)   -- print a table to console  :   print(dump(table))
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end