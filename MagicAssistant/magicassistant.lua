--[[

	Many thanks to Ryan Skeldon, the creator of the Grimoire addon, and Ivaar, the creator of the Skillchains addon
	This code borrows elements and concepts from each addon but is heavily modified.

]]

_addon.version = '3.0.0'
_addon.name = 'Magic Assistant'
_addon.author = 'Valok@Asura'
_addon.commands = {'magicassistant', 'maa'}

require('coroutine')
require('tables')
require('strings')
res = require('resources')
skills = require('skills')
packets = require('packets')

--[[ ///////////  NOTES

	Elemental Priorities: Thunder > Blizzard > Fire > Water > Aero > Stone
	Transfixion and Compression are only burstable by Luminohelix and Noctohelix, respectively

	If you are getting errors, reload the addon then type 'maa log 3' in the console.
	This will log the console spam to the file Windower\console.log


]]

--[[ DEBUGGING ]]--
debug_exampleOnly = false -- Setting this to true will prevent all /maa macros from actually casting spells!!! You will only see the final output printed in the console
debug_level = 0  -- 0: Disabled, 1: user, 2: dev, 3: experimental

--[[ MAIN SETTINGS ]]--
showOthersSkillchains = false
-- Setting this to true will allow you to see skillchains created by anyone, not just the ones created by your party or alliance
-- You may want to set this to 'true' for fights like Wildskeeper Reives where anyone can attack the boss

magicBurstWindow =		  8 -- Seconds after a skillchain that you will be allowed to magic burst
burstLimitPerSkillchain = 2 -- Limits your magic bursts per skillchain to this amount. Set to 0 to disable

sidegradeBeforeDowngrade = true
-- Will cast other elemental nukes in the same tier if the skillchain allows it, instead of casting lower tiers of the primary element

considerWeather = false
considerDay = 	  false
-- Weather and day can be used to override magic element priority
-- Weather > Day > Standard Priorities. Set both to false if you would like to use the standard priorites
-- Example:
-- 	If the weather is windy and there is a light skillchain, the spell priority will be Aero > Thunder > Fire

gearswapInstalled = true
gearswapNotify = 	true
-- Sends a command to Gearswap that you can use to instruct Gearswap to perform a certain action, such as equipping magic burst gear
-- Examples:
-- A Fusion skillchain will send:  MAABurst LightFire
-- A Darkness skillchain will send: MAABurst DarkEarthWaterIce
-- A Scission skillchain will sent: MAABurst Earth

allowBurstingWithoutTarget = false
-- Uses the mob ID as a target when casting a magic burst without an active target
-- Must have Gearswap installed and gearswapInstalled must = true

mobOverrides = true
-- Experimental
-- Can prevent you from bursting Water on a crab if you could burst something better
-- Also causes a FORCED spell on an elemental to cast the strongest element it is weak against

--[[  TEXTBOX SETTINGS  ]]-- The addon can optionally show a pop-up window with information regarding any active Skillchains, their targets, and their time remaining
						  -- Type 'maa example' in the console to get a preview of the pop-up. You can click and drag it to any desired location in your FFXI window
textBox_enabled = 			true
textBox_skillchainsToShow =    1 -- Showing more than 1 is rarely going to be useful, if ever
textBox_showTimer = 	    true
textBox_showSkillchain =    true
textBox_showTargetName =    true

--[[  TIMER SETTINGS  ]]--
showTimers = false -- Allow the addon to create and remove custom timers if you are using the Timers plugin

--[[  NOTIFICATION SETTINGS  ]]--
showSkillchainInChatWindow = false -- Private notification in chat window
chatWindowColor = 				11 -- Determines which chat window the message uses and what color it is
partyAnnounce = 			 false -- Announce the skillchain in party chat when it occurs
partyAnnounceInterrupts = 	 false -- Announce any detected magic burst interruptions in party chat
partyCall =					 false -- Add a call to the party announcement
callNumber = 					20 -- Specify the call to be used

--[[ NAP MODE ]]-- Must have the Gearswap addon loaded and gearswapInstalled must == true
napMode = 						false -- Auto MB when afk. Not implemented yet.
napMaxBurstCount = 					1 -- Maximum magic burst attempts per skillchain
napDelayBetweenBurstAttempts =  	3 -- Delay between magic burst attempts

--[[ END USER-ADJUSTABLE SETTINGS ]]--


napArgs = {}
isNapModeCommand = false
napLastBurst = 0
napBurstAttemptTime = 0

skillchainTargets = {}
activeSkillchain = {}
player = nil
target = nil

sidegradeTable = {}
sidegradeIndex = 0

frameTime = 0

main_job = ''
merits = {}
jp_spent = {}

if type(callNumber) ~= 'Number' or callNumber < 1 or callNumber > 20 then
	callNumber = 20
end

validSCMessageIDs = S{2,110,161,162,185,187,317}

-- GUI STUFF
config = require('config')
texts = require('texts')
file = require('files')

display = {}
display.pos = {}
display.pos.x = 400
display.pos.y = 500
display.text = {}
display.text.font = 'Courier New'
display.text.size = 15
display.flags = {}
display.flags.bold = true
display.flags.draggable = true
display.bg = {}
display.bg.alpha = 255

elementColor = {}
elementColor.Earth =     '\\cs(153,  76,   0)'
elementColor.Wind =      '\\cs(102, 255, 102)'
elementColor.Water =     '\\cs(  0, 102, 255)'
elementColor.Fire =      '\\cs(255, 102, 102)'
elementColor.Ice =       '\\cs(  0, 255, 255)'
elementColor.Lightning = '\\cs(255,   0, 255)'
elementColor.Light =     '\\cs(255, 255, 255)'
elementColor.Dark =      '\\cs(  0,   0, 180)'

display.textColors = {}
display.textColors.White =  '\\cs(222, 222, 222)'
display.textColors.Gray =   '\\cs(128, 128, 128)'
display.textColors.Black =  '\\cs(  0,   0,   0)'
display.textColors.Green =  '\\cs(  0, 255,   0)'
display.textColors.Yellow = '\\cs(255, 255,   0)'
display.textColors.Orange = '\\cs(255, 165,   0)'
display.textColors.Red =    '\\cs(255,   0,   0)'
display.textColors.Light = elementColor.Wind ..'L' .. elementColor.Fire .. 'i' .. elementColor.Lightning .. 'gh' .. elementColor.Light .. 't'
display.textColors.Darkness = elementColor.Earth .. 'Da' .. elementColor.Water .. 'rk' .. elementColor.Ice .. 'ne' .. elementColor.Dark .. 'ss'
display.textColors.Gravitation = elementColor.Earth .. 'Gravi' .. elementColor.Dark .. 'tation'
display.textColors.Fragmentation = elementColor.Wind .. 'Fragmen' .. elementColor.Lightning .. 'tation'
display.textColors.Distortion = elementColor.Water .. 'Disto' .. elementColor.Ice .. 'rtion'
display.textColors.Fusion = elementColor.Fire .. 'Fus' .. elementColor.Light .. 'ion'
display.textColors.Compression = elementColor.Dark .. 'Compression'
display.textColors.Liquefaction = elementColor.Fire .. 'Liquefaction'
display.textColors.Induration = elementColor.Ice .. 'Induration'
display.textColors.Reverberation = elementColor.Water .. 'Reverberation'
display.textColors.Transfixion = elementColor.Light .. 'Transfixion'
display.textColors.Scission = elementColor.Earth .. 'Scission'
display.textColors.Detonation = elementColor.Wind .. 'Detonation'
display.textColors.Impaction = elementColor.Lightning .. 'Impaction'
display.textColors.Radiance = elementColor.Wind ..'Ra' .. elementColor.Fire .. 'di' .. elementColor.Lightning .. 'an' .. elementColor.Light .. 'ce'
display.textColors.Umbra = elementColor.Earth .. 'U' .. elementColor.Water .. 'm' .. elementColor.Ice .. 'br' .. elementColor.Dark .. 'a'

settings = config.load(display)
settings:save()

skillchainsInProgress = 0
displayTextSetup = ''

if textBox_enabled and (textBox_showTimer or textBox_showSkillchain or textBox_showTargetName) then
	for i = 1, textBox_skillchainsToShow do
		if i > 1 then displayTextSetup = displayTextSetup .. '\n' end

		if textBox_showTimer then
			displayTextSetup = displayTextSetup .. ' ${SC' .. i .. 'TimeRemaining} '
		end

		if textBox_showSkillchain then
			if textBox_showTimer then
				displayTextSetup = displayTextSetup .. '${SC' .. i .. 'Name} '
			else
				displayTextSetup = displayTextSetup .. ' ${SC' .. i .. 'Name} '
			end
		end

		if textBox_showTargetName then
			if textBox_showSkillchain then
				displayTextSetup = displayTextSetup .. '${SC' .. i .. 'TargetName} '
			else
				if textBox_showTimer then
					displayTextSetup = displayTextSetup .. '${SC' .. i .. 'TargetName} '
				else
					displayTextSetup = displayTextSetup .. ' ${SC' .. i .. 'TargetName} '
				end
			end	
		end
	end
end

textBox = texts.new(displayTextSetup, settings)
if textBox_enabled then textBox:show() end

math.randomseed(os.time())

windower.register_event('addon command', function(...)
	for i = 1, #arg do
		arg[i] = string.lower(arg[i])
	end

	activeSkillchain = nil

	if #arg == 0 then

	elseif arg[1] == 'help' then
		print('- MagicAssistant (maa) main commands -')
		print('-  maa ["spell base name"] [tier]                Example:  maa Fire 4,        maa Cure 3 t,   maa Aspir 3 bt')
		print('-  maa mb [spell/helix/ga/ja/ra/nin] [tier]      Example:  maa mb spell 4 t,    maa mb nin 2,    maa mb helix 2')
		print('-  maa force [spell/helix/ga/ja/ra/nin] [tier]   Example:  maa force spell 4, maa force nin 3, maa force helix 2')
		print(' - Other commands: maa [example], ')
	elseif arg[1] == 'example' then
		local sc  = math.random(1, 16)

		if sc > 2 then
			sc = 285 + sc
		else
			sc = 766 + sc
		end

		skillchainTargets[math.random(100000, 200000)] = { --[windower.ffxi.get_mob_by_target('t').id] = {
			index = 123, --windower.ffxi.get_mob_by_target('t').index,
			name = 'Click and Drag', --windower.ffxi.get_mob_by_target('t').name,
			skillchain = sc,
			startTime = os.clock(),
			burstCount = 0,
			valid = true,
			interrupted = false,
			isExample = true,
		}

		return
	elseif arg[1] == 'log' then
		if #arg == 1 then
			debug_level = 0
			windower.send_command('console_log 0')
			windower.add_to_chat(chatWindowColor, 'MAA: Logging Disabled')
		elseif arg[2] then
			debug_level = tonumber(arg[2])
			windower.send_command('console_log 1')
			windower.add_to_chat(chatWindowColor, 'MAA: Logging Level ' .. debug_level .. ' Enabled')
		end
	elseif arg[1] == 'nap' then
		if #arg == 1 then
			if not napMode and #napArgs == 2 then
				napMode = true
			else
				napMode = false
			end
		elseif #arg == 3 then
			if not T({'spell', 'helix', 'ga', 'ja', 'ra', 'nin'}):contains(arg[2]) then
				print('MAA: Invalid Spelltype. Valid options: spell, helix, ga, ja, ra, nin')
				napMode = false
			elseif not T({1, 2, 3, 4, 5, 6}):contains(tonumber(arg[3])) then
				print('MAA: Invalid Tier. Valid options: 1, 2, 3, 4, 5, 6')
				napMode = false
			else
				napArgs = {arg[2], arg[3]}
				napMode = true
			end
		end

		if napMode and gearswapInstalled then
			windower.add_to_chat(chatWindowColor, 'MAA: NapMode Enabled. Command: maa mb ' .. napArgs[1] .. ' ' .. napArgs[2])
		else
			if not gearswapInstalled then
				windower.add_to_chat(chatWindowColor, 'MAA: gearswapInstalled must be set to True to use napMode')
			else
				windower.add_to_chat(chatWindowColor, 'MAA: NapMode Disabled')
			end

			napMode = false
		end
	elseif #arg == 2 or (#arg == 3 and arg[1] ~= 'mb' and arg[1] ~= 'force') then
		if #arg == 2 then
			arg[3] = 't'
		end

		if not T(validMacroTargets):contains(arg[3]) then
			print('MAA: Invalid Target. Valid options: me, t, bt, ht, ft, st, stpc, stpt, stal, stnpc, lastst, r, pet, scan, p#, a#')
		elseif not T({1, 2, 3, 4, 5, 6}):contains(tonumber(arg[2])) then
			print('MAA: Invalid Tier. Valid options: 1, 2, 3, 4, 5, 6')
		else
			downgradeSpell(arg[1], tonumber(arg[2]), arg[3], false)
		end
	elseif (arg[1] == 'mb' or arg[1] == 'force') and #arg == 3 or #arg == 4 then
		if not T({'spell', 'helix', 'ga', 'ja', 'ra', 'nin'}):contains(arg[2]) then
			print('MAA: Invalid Spelltype. Valid options: spell, helix, ga, ja, ra, nin')
		elseif not T({1, 2, 3, 4, 5, 6}):contains(tonumber(arg[3])) then
			print('MAA: Invalid Tier. Valid options: 1, 2, 3, 4, 5, 6')
		else
			if #arg == 3 then
				arg[4] = 't'
			end

			if not isNapModeCommand and not T(validMBMacroTargets):contains(arg[4]) then
				print('MAA: Invalid Target. Valid options: t, bt, ht, scan')
			else
				if arg[1] == 'force' then
					if not activeSkillchain then
						activeSkillchain = anyNuke
					end

					MBOrBestOffer(arg[2], tonumber(arg[3]), true, arg[4])
				else
					if isNapModeCommand then
						isNapModeCommand = false
						target = windower.ffxi.get_mob_by_id(arg[4])	
					else
						target = windower.ffxi.get_mob_by_target(arg[4])
					end

					if not target and allowBurstingWithoutTarget and gearswapInstalled then
						debug(2, 'No target, searching for best ID')
						local tempArray = {}

						for k, v in pairs(skillchainTargets) do
							table.insert(tempArray, skillchainTargets[k].startTime)
						end

						table.sort(tempArray)

						for i = 1, #tempArray do
							for k, v in pairs(skillchainTargets) do
								if skillchainTargets[k].startTime == tempArray[i] and os.clock() - skillchainTargets[k].startTime > 3 and skillchainTargets[k].valid and not skillchainTargets[target.id].interrupted then
									target = windower.ffxi.get_mob_by_id(skillchainTargets[k])
								end
								
								if target then break end
							end

							if target then break end
						end
					end

					if target and skillchainTargets[target.id] and skillchainTargets[target.id].valid and not skillchainTargets[target.id].interrupted then
						activeSkillchain = skillchains[skillchainTargets[target.id].skillchain]
						MBOrBestOffer(arg[2], tonumber(arg[3]), false, arg[4])
					else
						debug(1, 'MAA: No Skillchain detected on target. MB Aborted')
					end
				end
			end
		end
	else
		local badCommand = 'maa '

		for i = 1, #arg do
			badCommand = badCommand .. arg[i] .. ' '
		end

		print('MAA: Invalid Command: ' .. badCommand)
	end

	local receivedCommand = 'maa '

	for i = 1, #arg do
		receivedCommand = receivedCommand .. arg[i] .. ' '
	end

	--debug(2, 'MAA: Final Command Received: Args: ' .. #arg .. ' Cmd: ' .. receivedCommand) end
end)

function updateDisplay()
	local skillchainCount = 1
	local timerColor = {}
	local tempArray = {}

	for k, v in pairs(skillchainTargets) do
		table.insert(tempArray, skillchainTargets[k].startTime)
	end

	table.sort(tempArray)
--[[
	local i, o = 1, #tempArray

	while i < o do
		tempArray[i], tempArray[o] = tempArray[o], tempArray[i]

		i = i + 1
		o = o - 1
	end
]]
	--for i = #tempArray, 1, -1 do
	for i = 1, #tempArray do
		for k, v in pairs(skillchainTargets) do
			if skillchainTargets[k].startTime == tempArray[i] and skillchainTargets[k].valid then
				timerColor = {red = 0, blue = 0, green = 0}
				timeElapsed = os.clock() - skillchainTargets[k].startTime

				if magicBurstWindow - timeElapsed > .75 * magicBurstWindow then -- Green to Yellow  0, 255, 0 - 255, 255, 0
					timerColor.red = 255 - round(255 * (1 - (4 - ((magicBurstWindow - timeElapsed) / (magicBurstWindow / 4)))), 0)
					timerColor.green = 255
					timerColor.blue = 0
				elseif magicBurstWindow - timeElapsed > .5 * magicBurstWindow then -- Yellow to Orange  255, 255, 0 - 255, 165, 0
					timerColor.red = 255
					timerColor.green = 165 + round(90 * (1 - (3 - ((magicBurstWindow - timeElapsed) / (magicBurstWindow / 4)))), 0)
					timerColor.blue = 0
				elseif magicBurstWindow - timeElapsed > .25 * magicBurstWindow then -- Orange to Red  255, 165, 0 - 255, 0, 0
					timerColor.red = 255
					timerColor.green = round(165 * (1 - (2 - ((magicBurstWindow - timeElapsed) / (magicBurstWindow / 4)))), 0)
					timerColor.blue = 0
				elseif magicBurstWindow - timeElapsed > 0 * magicBurstWindow then -- Red to Black  255, 0 0, - 0, 0, 0
					timerColor.red = round(255 * (1 - (1 - ((magicBurstWindow - timeElapsed) / (magicBurstWindow / 4)))), 0)
					timerColor.green = 0
					timerColor.blue = 0
				end
				
				timerColor = '\\cs('.. timerColor.red .. ', ' .. timerColor.green .. ', ' .. timerColor.blue .. ')'
	
				if skillchainTargets[k].interrupted then
					local flashColor = ''
		
					if (os.clock() - skillchainTargets[k].startTime) % 1 < 0.5 then
						flashColor = display.textColors.Red
					else
						flashColor = display.textColors.Yellow
					end

					if textBox_showTimer then textBox['SC' .. skillchainCount .. 'TimeRemaining'] = timerColor .. string.format("%2.1f", magicBurstWindow - (os.clock() - skillchainTargets[k].startTime)) end
					if textBox_showSkillchain then textBox['SC' .. skillchainCount .. 'Name'] = flashColor .. skillchains[skillchainTargets[k].skillchain].english end
					if textBox_showTargetName then textBox['SC' .. skillchainCount .. 'TargetName'] = flashColor .. 'Interrupted!' end
				else
					if textBox_showTimer then textBox['SC' .. skillchainCount .. 'TimeRemaining'] = timerColor .. string.format("%2.1f", magicBurstWindow - (os.clock() - skillchainTargets[k].startTime)) end
					if textBox_showSkillchain then textBox['SC' .. skillchainCount .. 'Name'] = display.textColors[skillchains[skillchainTargets[k].skillchain].english] end
					if textBox_showTargetName then textBox['SC' .. skillchainCount .. 'TargetName'] = display.textColors.Gray ..  skillchainTargets[k].name end
				end
				
				textBox:show()
				skillchainCount = skillchainCount + 1

				if skillchainCount > textBox_skillchainsToShow then break end
			end
		end
	end
end

function downgradeSpell(spell_original, maxTier, targ, isMagicBurst, spell_selectedType)
	debug(1, 'downgradeSpell: ' .. spell_original)
	local tiers = spellTiers

	if not isValidSpell(spell_original) then
		if T(ninjutsu):contains(string.lower(spell_original)) then
			tiers = ninjutsuTiers
		else
			print('MAA: Invalid Spell: ' .. spell_original)
			return
		end
	end

	maxTier = math.min(maxTier, #tiers)
	local spellToCast = find_spell_by_name(spell_original .. tiers[maxTier])

	while not spellToCast and maxTier > 0 do
		maxTier = maxTier - 1
		debug(1, 'Checking if Valid: ' .. spell_original .. tiers[maxTier])
		spellToCast = find_spell_by_name(spell_original .. tiers[maxTier])
	end

	if not spellToCast then
		print('MAA: Invalid Spell: ' .. spell_original)
		return
	else
		debug(1, 'First Valid Spell: ' .. spellToCast.english)
	end

	local player = windower.ffxi.get_player()
	local player_spells = windower.ffxi.get_spells()
	local recasts = windower.ffxi.get_spell_recasts()
	local tierTable = {}
	local spellBase = string.lower(string.mgsub(spell_original, "%s.+", ""))
	local spellSuccess = false

	main_job = string.lower(windower.ffxi.get_player().main_job)
	merits = windower.ffxi.get_player().merits
	jp_spent = windower.ffxi.get_player().job_points[main_job].jp_spent

	if spellToCast.type == 'Ninjutsu' then
		if spellToCast.english:endswith("San") then
			tierTable = {': Ichi', ': Ni', ': San'}
		elseif spellToCast.english:endswith("Ni") then
			tierTable = {': Ichi', ': Ni'}
		else
			tierTable = {': Ichi'}
		end
	else
		if spellToCast.english:endswith(" VI") then
			tierTable = {"", " II", " III", " IV", " V", " VI"}
		elseif spellToCast.english:endswith(" V") then
			tierTable = {"", " II", " III", " IV", " V"}
		elseif spellToCast.english:endswith(" IV") then
			tierTable = {"", " II", " III", " IV"}
		elseif spellToCast.english:endswith(" III") then
			tierTable = {"", " II", " III"}
		elseif spellToCast.english:endswith(" II") then
			tierTable = {"", " II"}
		else
			tierTable = {""}
		end
	end

	if isMagicBurst and sidegradeBeforeDowngrade and activeSkillchain and activeSkillchain.english ~= 'AnyElement' then
		for i = 1, #sidegradeTable do
			debug(2, 'Sidegrade Check: ' .. elementSpellTypes[sidegradeTable[i].element][spell_selectedType] .. sidegradeTable[i].tier)

			if elementSpellTypes[sidegradeTable[i].element][spell_selectedType] then
				spellToCast = find_spell_by_name(elementSpellTypes[sidegradeTable[i].element][spell_selectedType] .. sidegradeTable[i].tier)

				if spellToCast then
					debug(2, spellToCast.english .. ' is valid. Checking castability')

					if recasts[spellToCast.recast_id] == 0 and -- Spell is off cooldown
							spellToCast.mp_cost <= player.vitals.mp and -- player has enough MP
							((spellToCast.levels[player.main_job_id] and spellToCast.levels[player.main_job_id] <= player.main_job_level) or -- main job is high enough to cast it
							(spellToCast.levels[player.sub_job_id] and spellToCast.levels[player.sub_job_id] <= player.sub_job_level) or -- sub job is high enough to cast it
							spellUnlocked(spellToCast.english)) and -- player has unlocked it through job or merit points
							player_spells[spellToCast.id] then -- the player has learned the spell. IGNORES JOB!
								
						if napMode then
							targ = targ
						else
							targ = '<' .. targ .. '>'
						end

						if debug_exampleOnly then
							print('MAA: Command: /ma "' .. spellToCast.english .. '" ' .. targ)
						else
							windower.send_command('input /ma "' .. spellToCast.english .. '" ' .. targ)
						end

						spellSuccess = true
						debug(2, spellToCast.english .. ' has been selected and is being cast.')
						break
					end
				end
			end
		end
	else
		for i = #tierTable, 1, -1 do
			spellToCast = find_spell_by_name(spellBase .. tierTable[i])

			if spellToCast then
				if recasts[spellToCast.recast_id] == 0 and -- Spell is off cooldown
						spellToCast.mp_cost <= player.vitals.mp and -- player has enough MP
						((spellToCast.levels[player.main_job_id] and spellToCast.levels[player.main_job_id] <= player.main_job_level) or -- main job is high enough to cast it
						(spellToCast.levels[player.sub_job_id] and spellToCast.levels[player.sub_job_id] <= player.sub_job_level) or -- sub job is high enough to cast it
						spellUnlocked(spellToCast.english)) and -- player has unlocked it through job or merit points
						player_spells[spellToCast.id] then -- the player has learned the spell. IGNORES JOB!
							
					if napMode then
						targ = targ
					else
						targ = '<' .. targ .. '>'
					end
							
					if debug_exampleOnly then
						print('MAA: Command: /ma "' .. spellToCast.english .. '" ' .. targ)
					else
						windower.send_command('input /ma "' .. spellToCast.english .. '" ' .. targ)
					end

					spellSuccess = true
					break
				end
			end
			
		end
	end

	if not spellSuccess and debug_level > 0 then
		if recasts[spellToCast.recast_id] ~= 0 then
			windower.add_to_chat(4, 'MAA: All ' .. spellBase .. ' spells on cooldown.')
		elseif spellToCast.mp_cost > player.vitals.mp then
			windower.add_to_chat(4, 'MAA: Not enough MP to cast ' .. spellBase .. '.')
		elseif not spellToCast.levels[player.main_job_id] and not spellToCast.levels[player.sub_job_id] then
			windower.add_to_chat(4, 'MAA: ' .. player.main_job .. '/' .. player.sub_job .. ' cannot cast ' .. spellBase .. '.')
		elseif spellToCast.levels[player.main_job_id] and spellToCast.levels[player.main_job_id] > player.main_job_level then
			windower.add_to_chat(4, 'MAA: Job not high enough to cast ' .. spellBase .. '.')
		elseif not spellToCast.levels[player.sub_job_id] or spellToCast.levels[player.sub_job_id] > player.sub_job_level then
			windower.add_to_chat(4, 'MAA: Subjob not high enough to cast ' .. spellBase .. '.')
		elseif not player_spells[spellToCast.id] then
			windower.add_to_chat(4, 'You have not learned, or your job cannot cast, ' .. spellBase)
		elseif not spellUnlocked(spellToCast.english) then
			windower.add_to_chat(4, 'MAA: Not merited or not enough job points to unlock ' .. spellBase .. '.')
		else
			windower.add_to_chat(4, 'MAA: ' .. spellBase .. ' failed for an unknown reason.')
		end
	end
end

function spellUnlocked(spellName)
	if jobPointUnlocks[main_job] and jobPointUnlocks[main_job][spellName] and jobPointUnlocks[main_job][spellName] <= jp_spent then
		return true
	else
		for k, v in pairs(merits) do
			if meritUnlocks[main_job] and meritUnlocks[main_job][k] then
				if v ~= 0 then
					return true
				end
			end
		end
	end

	return false
end

function MBOrBestOffer(spell_selectedType, spell_selectedTier, forced, targ)
	local weather_element = nil
	local day_element = nil
	local priority_element = nil
	local skillchain_element = nil
	local spellToCast = nil
	local player = windower.ffxi.get_player()
	local buff_name = ''
	local tiers = spellTiers

	if spell_selectedType == 'nin' then
		tiers = ninjutsuTiers
	end

	spell_selectedTier = math.min(spell_selectedTier, #tiers)

	-- Get weather. SCH Weather buff takes priority
	if considerWeather or forced then
		if #player.buffs > 0 then
			for i = 1, #player.buffs do
				buff_name = res.buffs[player.buffs[i]].name

				for o = 1, #storms do
					if buff_name == storms[o].name then
						weather_element = storms[o].weather
						debug(1, 'SCH Weather Buff Found: ' .. weather_element)
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
			debug(1, 'Weather Found: ' .. weather_element)
		end
	end

	-- Get day element
	if considerDay or forced then
		day_element = res.elements[res.days[windower.ffxi.get_info().day].element].en

		if not day_element then
			debug(2, 'day_element is nil')
		else

			debug(1, 'Day Found: ' .. day_element)
		end
	end

	-- Determine if weather or day will benefit the spell
	if weather_element and T(activeSkillchain.elements):contains(weather_element) then
		skillchain_element = weather_element
		debug(1, 'Casting weather element: ' .. skillchain_element)
	elseif day_element and elementSpellTypes[day_element][spell_selectedType] and T(activeSkillchain.elements):contains(day_element) then
		skillchain_element = day_element
		debug(1, 'Casting day element: ' .. skillchain_element)
	else -- If weather or day provide no benefit, just go by priority
		for i = 1, #spell_priorities do
			if T(activeSkillchain.elements):contains(spell_priorities[i]) then
				skillchain_element = spell_priorities[i]
				debug(1, 'Casting priority element: ' .. skillchain_element)
				break
			end
		end
	end

	if not skillchain_element then
		debug(1, 'MAA: No skillchain_element found for ' .. activeSkillchain.english)
		return
	end

	sidegradeTable = {}
	sidegradeIndex = 0

	if sidegradeBeforeDowngrade then --and not forced then
		for i = spell_selectedTier, 1, -1 do
			sidegradeIndex = sidegradeIndex + 1
			sidegradeTable[sidegradeIndex] = {['element'] = skillchain_element, ['tier'] = spellTiers[i]} 

			for o = 1, #spell_priorities do
				if T(activeSkillchain.elements):contains(spell_priorities[o]) and spell_priorities[o] ~= skillchain_element then
					sidegradeIndex = sidegradeIndex + 1
					sidegradeTable[sidegradeIndex] = {['element'] = spell_priorities[o], ['tier'] = spellTiers[i]}
				end
			end
		end
	end

	skillchain_element = mobOverrides(skillchain_element, forced)
	
	if elementSpellTypes[skillchain_element][spell_selectedType] then
		spellToCast = elementSpellTypes[skillchain_element][spell_selectedType] .. tiers[spell_selectedTier]
	end
	
	if spellToCast then
		debug(1, 'MAA: Spell Suggestion: ' .. spellToCast)

		if gearswapInstalled and gearswapNotify and not forced then
			local tempelements = ''

			for i = 1, #activeSkillchain.elements do
				tempelements = tempelements .. activeSkillchain.elements[i]
			end

			windower.send_command('gs c MAABurst ' .. tempelements)
		end

		if forced then
			downgradeSpell(elementSpellTypes[skillchain_element][spell_selectedType], spell_selectedTier, targ, false, spell_selectedType)
		else
			downgradeSpell(elementSpellTypes[skillchain_element][spell_selectedType], spell_selectedTier, targ, true, spell_selectedType)
		end
	else
		debug(1, 'MAA: No valid or useful spell for ' .. skillchain_element)
	end
end

function mobOverrides(skillchain_element, forced, target)
	if not mobOverrides or not target then return skillchain_element end

	debug(2, 'Target: ' .. target.name)

	if target.name:contains(' Crab') or target.name:contains(' Jagil') or target.name:contains(' Tarichuk') and skillchain_element == 'Water' and (activeSkillchain.skillchain.english == 'Distortion' or activeSkillchain.skillchain.english == 'Darkness' or forced) then
		debug(0, 'Water detected on crab: Changing to Ice')
		return 'Ice'
	elseif target.name:contains(' Elemental') then
		if forced then
			debug(2, skillchain_element .. ' forced on ' .. skillchain_element .. ' Elemental. Changing to weakness')
			
			if target.name == 'Air Elemental' then
				target.name = 'Wind Elemental'
			elseif target.name == 'Thunder Elemental' then
				target.name = 'Lightning Elemental'
			elseif target.name == 'Ice Elemental' then
				target.name = 'Blizzard Elemental'
			end

			return spell_strengths[string.sub(target.name, 1, string.find(target.name, ' ') - 1)].weakness
		else

		end
	end

	return skillchain_element
end

windower.register_event('incoming chunk', function(id, orig)
	if id == 0x28 then
		local packet = windower.packets.parse_action(orig)
		
		if not T({3, 4, 11, 13, 14, 20}):contains(packet.category) then -- Valid categories, according to Skillchains addon: 3, 4, 11, 13, 14, 20
			
			return
		elseif #packet.targets ~= 1 then
			return
		end

		local badMessages = T({
			2, -- A non-bursted spell
			110, -- Some kind of ability use?
			161,
			162,
			--185, -- Weaponskill that hits
			--187, -- Weaponskill that hits and drains HP?
			317, -- Jump and Super Jump, at least.
		})
		
		if badMessages:contains(packet.targets[1].actions[1].message) then

		 -- action_messages.lua: [317] = {id=317,en="${actor} uses ${ability}.${lb}${target} takes ${number} points of damage.",color="D"},
			debug(2, 'Unknown Message: ' .. packet.targets[1].actions[1].message)
			return
		end
		
		if #packet.targets == 1 and packet.targets[1].actions[1].message == 252 then -- Magic Burst
			player = windower.ffxi.get_player()

			if player and player.id == packet.actor_id then
				local packet_target = windower.ffxi.get_mob_by_id(packet.targets[1].id)

				if res.spells[packet.param] then
					debug(2, 'MAA: Magic Burst detected! ' .. res.spells[packet.param].en .. ': ' .. packet.targets[1].actions[1].param .. ' damage!')
				end
				
				if skillchainTargets[packet_target.id] then
					skillchainTargets[packet_target.id].burstCount = skillchainTargets[packet_target.id].burstCount + 1
					napLastBurst = os.clock()
				end
			end

			return
		end

		if validSCMessageIDs[packet.targets[1].actions[1].message] then  -- S{2,110,161,162,185,187,317}  185 is WS hit, not sure what the others are. This should be something that can either open or close a skillchain
			local packet_skillchainID = packet.targets[1].actions[1].add_effect_message
			local packet_target = windower.ffxi.get_mob_by_id(packet.targets[1].id)
			local ability = skills[packet.category] and skills[packet.category][packet.param]

			if packet_skillchainID ~= 0 and packet_target.hpp > 0 then -- If an ability hit that closes a skillchain, add_effect_message will contain the skillchain ID
				if showTimers and skillchainTargets[packet_target.id] then -- Check the table to see if there is already an active on the target. Replace it if so, add it if not
					windower.send_command('timers d "' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ': ' .. skillchainTargets[packet_target.id].name .. '"')
				end

				local closerInfo = windower.ffxi.get_mob_by_id(packet.actor_id)

				skillchainTargets[packet_target.id] = {
					index = packet_target.index,
					name = packet_target.name,
					skillchain = packet_skillchainID,
					startTime = os.clock(),
					burstCount = 0,
					valid = closerInfo.in_party or closerInfo.in_alliance or showOthersSkillchains,
					interrupted = false,
					isExample = false,
				}

				if not showOthersSkillchains and partyAnnounce then
					if partyCall then
						windower.send_command('input /party Skillchain: ' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. '!  <call' .. callNumber .. '>')
					else
						windower.send_command('input /party Skillchain: ' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. '!')
					end
				elseif showSkillchainInChatWindow then
					windower.add_to_chat(chatWindowColor, 'MAA Skillchain: ' .. skillchains[skillchainTargets[packet_target.id].skillchain].english)
				else
					debug(1, 'MAA: ' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ' Skillchain on ' .. packet_target.id)
				end

				if showTimers and skillchainTargets[packet_target.id].valid then
					--windower.send_command('timers d "' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ': ' .. skillchainTargets[packet_target.id].name .. '"')
					windower.send_command('timers c "' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ': ' .. skillchainTargets[packet_target.id].name .. '" ' .. magicBurstWindow .. ' down')
					debug(3, 'Creating Timer: ' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ': ' .. skillchainTargets[packet_target.id].name)
				end
			elseif packet_skillchainID == 0 and skillchainTargets[packet_target.id] then -- If an ability hits that does not close a skillchain. This includes skillchain openers and weaponskills that mess up the magic burst
				-- 
				-- Normal spells are ending skillchains.  Skills[4] contains normal spells. Commented them out for testing. Learn more about Scholar JA

				local actor = windower.ffxi.get_mob_by_id(packet.actor_id)
				local ability = skills[packet.category] and skills[packet.category][packet.param]

				if actor then
					debug(2, 'Interrupting Actor Detected')

					if ability then
						ability = ability.en
					else
						debug(2, '----- Packet Dump Start ------')
						if debug_level >= 2 then print(dump(packet)) end
						debug(2, 'Category: ' .. packet.category)
						debug(2, 'Actor ID: ' .. packet.actor_id)
						debug(2, 'Param: ' .. packet.param)
						debug(2, 'Target ID: ' .. packet.targets[1].id) -- if there is only 1 target
						debug(2, 'Message: ' .. packet.targets[1].actions[1].message) -- if there is only 1 target
						debug(2, '------Packet Dump End ------')

						ability = 'Unknown'
					end

					if not showOthersSkillchains and partyAnnounceInterrupts then
						if partyCall then
							windower.send_command('input /party ' .. actor.name .. ' interrupted the MB by using ' .. ability .. ' <call5>')
						else
							windower.send_command('input /party ' .. actor.name .. ' interrupted the MB by using ' .. ability)
						end
					elseif showSkillchainInChatWindow then
						windower.add_to_chat(chatWindowColor, actor.name .. ' interrupted the MB by using ' .. ability)
					else
						debug(1, 'MAA: Magic burst interrupted by ' .. actor.name .. ' with ' .. ability)
					end
				else
					debug(2, 'No Interrupting Actor Detected')
					debug(2, '----- Packet Dump Start ------')
					if debug_level >= 2 then print(dump(packet)) end
					debug(2, 'Category: ' .. packet.category)
					debug(2, 'Actor ID: ' .. packet.actor_id)
					debug(2, 'Param: ' .. packet.param)
					if ability then debug(2, 'Ability: ' .. ability.en) end
					debug(2, 'Target ID: ' .. packet.targets[1].id) -- if there is only 1 target
					debug(2, 'Message: ' .. packet.targets[1].actions[1].message) -- if there is only 1 target
					debug(2, '------Packet Dump End ------')
				end

				skillchainTargets[packet_target.id].interrupted = os.clock()

				if showTimers then
					debug(2, 'Removing Interrupted Timer from ' .. skillchainTargets[packet_target.id].name)
					windower.send_command('timers d "' .. skillchains[skillchainTargets[packet_target.id].skillchain].english .. ': ' .. skillchainTargets[packet_target.id].name .. '"')
				end
			end
		end
	end
end)

windower.register_event('prerender',function()
	local clock = os.clock()

	if os.clock() - frameTime >= 0.1 then
		frameTime = clock
		local skillchainsActive = 0

		for k, v in pairs(skillchainTargets) do
			skillchainsActive = skillchainsActive + 1

			if os.clock() - skillchainTargets[k].startTime >= magicBurstWindow then
				removeSkillchain(k, 'Natural Expiration')
			elseif not napMode and burstLimitPerSkillchain > 0 and skillchainTargets[k].burstCount >= burstLimitPerSkillchain then
				removeSkillchain(k, 'Burst # ' .. skillchainTargets[k].burstCount)
			elseif napMode and skillchainTargets[k].burstCount >= napMaxBurstCount then
				removeSkillchain(k, 'NapMode burst # ' .. skillchainTargets[k].burstCount)
			elseif not skillchainTargets[k].isExample and (not windower.ffxi.get_mob_by_id(k) or windower.ffxi.get_mob_by_id(k).hpp == 0) then
				removeSkillchain(k, 'Target invalid or dead')
			elseif napMode and skillchainTargets[k] and os.clock() - napLastBurst >= napDelayBetweenBurstAttempts then
				debug(2, 'Nap nuke now: maa mb ' .. napArgs[1] .. ' ' .. napArgs[2] .. ' ' .. k)
				napLastBurst = os.clock()
				isNapModeCommand = true
				--skillchainTargets[k].burstCount = skillchainTargets[k].burstCount + 1
				windower.send_command('maa mb ' .. napArgs[1] .. ' ' .. napArgs[2] .. ' ' .. k)
			end
		end
		
		if textBox_enabled then
			for i = skillchainsActive + 1, textBox_skillchainsToShow do -- Rid the textbox of any removed skillchains
				if textBox_showTimer then textBox['SC' .. i .. 'TimeRemaining'] = '' end
				if textBox_showSkillchain then textBox['SC' .. i .. 'Name'] = '' end
				if textBox_showTargetName then textBox['SC' .. i .. 'TargetName'] = '' end
			end

			if skillchainsActive > 0 then
				updateDisplay()
			else
				textBox:hide()
			end
		end
	end
end)

function removeSkillchain(id, reason)
	if skillchainTargets[id] then
		debug(2, 'Remove Skillchain: Reason: ' .. reason .. '  -  ' .. skillchains[skillchainTargets[id].skillchain].english .. ': ' .. skillchainTargets[id].name)

		if showTimers then
			windower.send_command('timers d "' .. skillchains[skillchainTargets[id].skillchain].english .. ': ' .. skillchainTargets[id].name .. '"')
		end

		skillchainTargets[id] = nil
	end
end

function isValidSpell(spellName)
	for i = 1, #res.spells do
		if res.spells[i] then
			if string.lower(spellName) == string.lower(res.spells[i].en) and res.spells[i].type ~= 'Trust' and res.spells[i].type ~= 'SummonerPact' then
				return true
			end
		end
	end

	return false
end

function spellReadyToUse(spellname)
	local cooldowns = windower.ffxi.get_spell_recasts()
	
	if cooldowns[find_spell_recast_id_by_name(spellname)] == 0 then
		return true
	end

	return false
end

function find_spell_recast_id_by_name(spellname)
    for spell in res.spells:it() do
        if spell['english']:lower() == spellname:lower() then
            return spell['recast_id']
        end
	end
	
    return nil
end

function find_spell_by_name(spellname)
	for spell in res.spells:it() do
		if spell['english']:lower() == spellname:lower() then
            return spell
        end
	end
	
    return nil
end

function round(num, numDecimalPlaces)
	if numDecimalPlaces and numDecimalPlaces > 0 then
	  local mult = 10 ^ numDecimalPlaces

	  return math.floor(num * mult + 0.5) / mult
	end

	return math.floor(num + 0.5)
end

function debug(level, text)
	if debug_level >= level then
		print(level .. ': ' .. text)
	end
end

function dump(o)   -- print a table to console  :   print(dump(table))
	if type(o) == 'table' then
		local s = '{ '

		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end

		return s .. '} '
	else
		return tostring(o)
	end
end

jobPointUnlocks = {
	blm = {
		['Stone VI'] = 100,
		['Water VI'] = 100,
		['Aero VI'] = 100,
		['Fire VI'] = 100,
		['Blizzard VI'] = 100,
		['Thunder VI'] = 100,
		['Aspir III'] = 550,
		['Death'] = 1200,
	},

	rdm = {
		['Stone V'] = 100,
		['Water V'] = 100,
		['Aero V'] = 100,
		['Fire V'] = 100,
		['Blizzard V'] = 100,
		['Thunder V'] = 100,
		['Addle II'] = 550,
		['Distract III'] = 550,
		['Frazzle III'] = 550,
		['Refresh III'] = 1200,
		['Temper II'] = 1200,
	},

	drk = {
		['Drain III'] = 550,
	},

	nin = {
		['Utsusemi: San'] = 100,
	},

	sch = {
		['Geohelix II'] = 1200,
		['Hydrohelix II'] = 1200,
		['Anemohelix II'] = 1200,
		['Pyrohelix II'] = 1200,
		['Cryohelix II'] = 1200,
		['Ionohelix II'] = 1200,
		['Noctohelix II'] = 1200,
		['Luminohelix II'] = 1200,
	},

	geo = {
		['Stone V'] = 100,
		['Water V'] = 100,
		['Aero V'] = 100,
		['Fire V'] = 100,
		['Blizzard V'] = 100,
		['Thunder V'] = 100,
		['Aspir III'] = 550,
		['Stonera III'] = 1200,
		['Watera III'] = 1200,
		['Aera III'] = 1200,
		['Fira III'] = 1200,
		['Blizzara III'] = 1200,
		['Thundara III'] = 1200,
	},
}

meritUnlocks = {
	blm = {
		['quake_ii'] = {name = 'Quake II'},
		['burst_ii'] = {name = 'Burst II'},
		['freeze_ii'] = {name = 'Freeze II'},
		['flare_ii'] = {name = 'Flare II'},
		['tornado_ii'] = {name = 'Tornado II'},
		['flood_ii'] = {name = 'Flood II'},
	},

	rdm = {
		['slow_ii'] = {name = 'Slow II'},
		['phalanx_ii'] = {name = 'Phalanx II'},
		['dia_iii'] = {name = 'Dia III'},
		['paralyze_ii'] = {name = 'Paralyze II'},
		['bio_iii'] = {name = 'Bio III'},
		['blind_ii'] = {name = 'Blind II'},
	},

	nin = {
		['hyoton_san']  = {name = 'Hyoton: San'},
		['huton_san'] = {name = 'Huton: San'},
		['katon_san'] = {name = 'Katon: San'},
		['doton_san'] = {name = 'Doton: San'},
		['raiton_san'] = {name = 'Raiton: San'},
		['suiton_san'] = {name = 'Suiton: San'},
	}
}

spellTiers = {
	[1] = '',
	[2] = ' II',
	[3] = ' III',
	[4] = ' IV',
	[5] = ' V',
	[6] = ' VI',
}

ninjutsuTiers = {
	[1] = ': Ichi',
	[2] = ': Ni',
	[3] = ': San',
}

ninjutsu = {
	'tonko',
	'utsusemi',
	'katon',
	'suiton',
	'doton',
	'hyoton',
	'huton',
	'raiton',
	'kurayami',
	'hojo',
	'monomi',
	'dokumori',
	'jubaku',
	'aisha',
	'yurin',
	'myoshu',
	'migawari',
	'gekko',
	'yain',
	'kakka',
}

skillchains = { -- Radiance and Umbra untested
	[288] = {english = 'Light', elements = {'Lightning', 'Fire', 'Wind', 'Light'}},
	[289] = {english = 'Darkness', elements = {'Ice', 'Water', 'Earth', 'Dark'}},
	[290] = {english = 'Gravitation', elements = {'Earth', 'Dark'}},
	[291] = {english = 'Fragmentation', elements = {'Lightning', 'Wind'}},
	[292] = {english = 'Distortion', elements = {'Ice', 'Water'}},
	[293] = {english = 'Fusion', elements = {'Fire', 'Light'}},
	[294] = {english = 'Compression', elements = {'Dark'}},
	[295] = {english = 'Liquefaction', elements = {'Fire'}},
	[296] = {english = 'Induration', elements = {'Ice'}},
	[297] = {english = 'Reverberation', elements = {'Water'}},
	[298] = {english = 'Transfixion', elements = {'Light'}},
	[299] = {english = 'Scission', elements = {'Earth'}},
	[300] = {english = 'Detonation', elements = {'Wind'}},
	[301] = {english = 'Impaction', elements = {'Lightning'}},
	[767] = {english = 'Radiance', elements = {'Lightning', 'Fire', 'Wind', 'Light'}},
	[768] = {english = 'Umbra', elements = {'Ice', 'Water', 'Earth', 'Dark'}},
}

anyNuke = {
	english = 'AnyElement', elements = {'Lightning', 'Ice', 'Fire', 'Wind', 'Water', 'Earth'}
}

spell_priorities = {
	'Lightning',
	'Ice',
	'Fire',
	'Wind',
	'Water',
	'Earth',
	'Dark',
	'Light',
}

spell_strengths = {
	['Fire'] = {weakness = 'Water'},
	['Ice'] = {weakness = 'Fire'},
	['Wind'] = {weakness = 'Ice'},
	['Earth'] = {weakness = 'Wind'},
	['Lightning'] = {weakness = 'Earth'},
	['Water'] = {weakness = 'Lightning'},
	['Dark'] = {weakness = 'Lightning'},
	['Light'] = {weakness = 'Ice'},
}

storms = { 
	{name = 'Firestorm', weather = 'Fire'}, 
	{name = 'Hailstorm', weather = 'Ice'}, 
	{name = 'Windstorm', weather = 'Wind'}, 
	{name = 'Sandstorm', weather = 'Earth'}, 
	{name = 'Thunderstorm', weather = 'Lightning'}, 
	{name = 'Rainstorm', weather = 'Water'}, 
	{name = 'Aurorastorm', weather = 'Light'}, 
	{name = 'Voidstorm', weather = 'Dark'},
}

elementSpellTypes = {
	['Lightning'] = {spell = 'Thunder', helix = 'Ionohelix', ga = 'Thundaga', ja = 'Thundaja', ra = 'Thundara', nin = 'Raiton'},
	['Ice'] = {spell = 'Blizzard', helix = 'Cryohelix', ga = 'Blizzaga', ja = 'Blizzaja', ra = 'Blizzara', nin = 'Hyoton'},
	['Fire'] = {spell = 'Fire', helix = 'Pyrohelix', ga = 'Firaga', ja = 'Firaja', ra = 'Fira', nin = 'Katon'},
	['Wind'] = {spell = 'Aero', helix = 'Anemohelix', ga = 'Aeroga', ja = 'Aeroja', ra = 'Aera', nin = 'Huton'},
	['Water'] = {spell = 'Water', helix = 'Hydrohelix', ga = 'Waterga', ja = 'Waterja', ra = 'Watera', nin = 'Suiton'},
	['Earth'] = {spell = 'Stone', helix = 'Geohelix', ga = 'Stonega', ja = 'Stoneja', ra = 'Stonera', nin = 'Doton'},
	['Dark'] = {spell = nil, helix = 'Noctohelix', ga = nil, ja = nil, ra = nil, nin = nil},
	['Light'] = {spell = nil, helix = 'Luminohelix', ga = nil, ja = nil, ra = nil, nin = nil},
}

validMBMacroTargets = {
	't', 'bt', 'ht', 'scan'
}

validMacroTargets = {
	'me', 't', 'bt', 'ht', 'ft', 'st', 'stpc', 'stpt', 'stal', 'stnpc', 'lastst', 'r', 'pet', 'scan',
	'p0', 'p1', 'p2', 'p3', 'p4', 'p5',
	'a10', 'a11', 'a12', 'a13', 'a14', 'a15',
	'a20', 'a21', 'a22', 'a23', 'a24', 'a25',
}

--[[
		--print('----- Packet Dump Start ------')
		--print(dump(packet))
		--print('Category: ' .. packet.category)
		--print('Actor ID: ' .. packet.actor_id)
		--print('Param: ' .. packet.param)
		--print('Ability: ' .. ability.en)
		--print('Target ID: ' .. packet.targets[1].id) -- if there is only 1 target
		--print('Message: ' .. packet.targets[1].actions[1].message) -- if there is only 1 target
		--print('------Packet Dump End ------')
]]