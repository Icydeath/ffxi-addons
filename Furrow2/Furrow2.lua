_addon.name = 'Furrow2'
_addon.author = 'Icy'
_addon.version = '1.0'
_addon.language = 'english'
_addon.commands = {'furrow2', 'fw', 'fw2'}
-- Based off the original Furrow addon by Algar.

require('logger')
require('coroutine')
require('pack')
require('lists')
require('tables')
require('strings')
texts = require('texts')
config = require('config')

furrow_names = {
	[1] = "Garden Furrow",
	[2] = "Garden Furrow #2",
	[3] = "Garden Furrow #3"
}

-- NOTE: As of right now, its best to use all the same seed type, or seeds that have the same grow time. Otherwise furrows will sit empty until all furrows have been harvest.

-- TODO: When using mixed seeds, replant empty furrows when waiting for longer grow time seeds.

default = {
	furrows = 3,
	seeds = {
		[1] = "Revival Root", 
		[2] = "Revival Root", 
		[3] = "Revival Root"
	},
	seed_grow_times = {
		["Revival_Root"] = 1,
		["Grain_Seed"] = 6,
	},
	
	use_dung = false, -- Dung (-25% harvest time)
	use_grove_humus = false, -- Grove Humus(-25% harvest time)
	use_miracle_mulch = false, -- Miracle Mulch(-50% harvest time)
	
	-- Increase yield furtilizers
	use_crystals = false,
	use_rich_humus = false,
	
	-- R/E furtilizers
	use_acidic_humus = false, 
	use_alkaline_humus = false,
	
	drop_stone_scroll = true, -- requires treasury addon
	npc_junk = true, -- requires sellnpc addon
	sellnpc_profile = "furrow",
}

settings = config.load(default)	

-- flags used by the script to track the R/E furtilizers
usedAcidicHumus = false 
usedAlkalineHumus = false

function initialize()
	if settings.drop_stone_scroll then windower.send_command('lua load treasury;wait .5;tr drop add Stone') end
	if settings.npc_junk then windower.send_command('lua load sellnpc') end
end

-- addon tracking variable, leave this alone ^.^
running = false

-- COUNTERS
furtilizerLeft = 0
furtilizerUsed = 0

function loop()
	if running then
		plantcycle()
		coroutine.sleep(2)
		running = true
		
		-- defaulting it to 1hr (revival root) incase the settings are messed up.
		local harvest_furrow_hours = {
			[1] = 1,
			[2] = 1,
			[3] = 1,
		}
		
		-- Associating seed grow time to furrow.
		for i = 1, #settings.seeds do
			if settings.seed_grow_times[settings.seeds[i]:gsub(" ", "_")] ~= nil 
			  and settings.seed_grow_times[settings.seeds[i]:gsub(" ", "_")] ~= 0 then
				harvest_furrow_hours[i] = settings.seed_grow_times[settings.seeds[i]:gsub(" ", "_")]
			end
		end
		
		-- if the wait is the same for all of them just run the sleepcycle once and harvest all furrows.
		if harvest_furrow_hours[1] == harvest_furrow_hours[2]
		  and harvest_furrow_hours[2] == harvest_furrow_hours[3] then
			windower.add_to_chat(200, 'Furrow2: Harvest times are the same for all seeds, will harvest them after the first sleep cycle.')
			sleepcycle(harvest_furrow_hours[1])
			harvestcycle()
			coroutine.sleep(2)
			running = true
		else
			windower.add_to_chat(200, 'Furrow2: Different harvest times identified, setting harvest order.')
			local furrowsOrderedByHours = getKeysSortedByValue(harvest_furrow_hours, function(a, b) return a < b end)
			local totalHoursWaited = 0 -- keep track of how many hours we've waited
			for _, furrowKey in ipairs(furrowsOrderedByHours) do
				--print(furrowKey, harvest_furrow_hours[furrowKey])
				
				if totalHoursWaited == 0 then
					windower.add_to_chat(200, 'Furrow2: Garden Furrow #'..furrowKey..' is up first. '..harvest_furrow_hours[furrowKey]..'hr growing time.')
					sleepcycle(harvest_furrow_hours[furrowKey])
					totalHoursWaited = totalHoursWaited + harvest_furrow_hours[furrowKey]
				else
					if harvest_furrow_hours[furrowKey] > totalHoursWaited then
						local adjSleep = harvest_furrow_hours[furrowKey] - totalHoursWaited
						windower.add_to_chat(200, 'Furrow2: Garden Furrow #'..furrowKey..' still has '..adjSleep..'hr(s) remaining.')
						sleepcycle(adjSleep)
						totalHoursWaited = totalHoursWaited + adjSleep
					end
				end
				
				harvestcycle(furrowKey)
				coroutine.sleep(2)
				running = true
			end
			windower.add_to_chat(200, 'Furrow2: Total hours waiting for plants: '..totalHoursWaited)
		end

		-- sell junk items to the moogle if npc_junk is set to true.
		if settings.npc_junk then
			windower.add_to_chat(200, 'Furrow2: Starting the selling junk cycle.')
			selljunkcycle()
			coroutine.sleep(2)
			running = true
		end
		
		windower.add_to_chat(200, 'Furrow2: Restarting the loop shortly...')
		coroutine.sleep(5)
		loop()
	else
		windower.add_to_chat(200, 'Furrow2: Aborting loop. An operation is already in progress. Please use fw stop or fw abort to cancel current operations.')
	end
end

function sleepcycle(hours)
	if not hours then
		hours = 1
	end
	
	windower.add_to_chat(200, 'Furrow2: Sleeping for '..hours..' hour(s) before the harvest.')
	local seconds = hours * 60 * 60
	local notices = seconds / 600
	
	local timeremaining = seconds
	for i=1, notices do
		coroutine.sleep(600)
		timeremaining = timeremaining - 600
		local remainingMin = timeremaining / 60
		windower.add_to_chat(200, 'Reminder: Furrow2 will commence harvest in '..remainingMin..' minutes. Use fw abort or fw stop to cancel.')
	end
end

function target(targetname)
	windower.send_command('setkey TAB down')
    coroutine.sleep(0.5)
    windower.send_command('setkey TAB up')
    coroutine.sleep(0.5)
		
	player = windower.ffxi.get_player()
	if windower.ffxi.get_mob_by_target( 't' ) == nil then
		windower.add_to_chat(200, 'Furrow2: No target, cycling.' )
		coroutine.sleep (0.5)
		target(targetname)
	elseif windower.ffxi.get_mob_by_target('t').name == targetname then
		windower.add_to_chat(200, 'Furrow2: Found '..targetname)
	else
		coroutine.sleep(0.5)
		target(targetname)
	end
end

function selljunk()
	windower.add_to_chat(200, 'Furrow2: Selling the junk to the moogle.')
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey down down')
		coroutine.sleep(0.1)
		windower.send_command('setkey down up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey escape down')
		coroutine.sleep(0.5)
		windower.send_command('setkey escape up')
		coroutine.sleep(0.5)
end

function plant(item)
		windower.add_to_chat(200, 'Furrow2: Trading a '..item)
		windower.chat.input("/item \""..item.."\" <t>")
		coroutine.sleep(5)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey escape down')
		coroutine.sleep(0.5)
		windower.send_command('setkey escape up')
		coroutine.sleep(0.5)
end		

function harvest()
		windower.add_to_chat(200, 'Furrow2: Harvesting the furrow.')
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(2)
		windower.send_command('setkey enter down')
		coroutine.sleep(0.5)
		windower.send_command('setkey enter up')
		coroutine.sleep(5)
		windower.send_command('setkey escape down')
		coroutine.sleep(0.5)
		windower.send_command('setkey escape up')
		coroutine.sleep(0.5)
end

function harvestcycle(num)
	if running == true then
		if num ~= nil then
			windower.add_to_chat(200, 'Furrow2: Searching for '..furrow_names[num])
			target(furrow_names[num])
			coroutine.sleep(2)
			harvest()
			coroutine.sleep(2)		
		else
			for i = 1, settings.furrows do
				windower.add_to_chat(200, 'Furrow2: Searching for '..furrow_names[i])
				target(furrow_names[i])
				coroutine.sleep(2)
				harvest()
				coroutine.sleep(2)		
			end
		end
		
		running = false
		windower.add_to_chat(200, 'Furrow2: Harvesting Complete!')
	else
		windower.add_to_chat(200, 'Furrow2: Something went wrong! Please try your command again after reloading Furrow2.')
	end
end

function plantcycle()
	if running == true then
		windower.add_to_chat(200, 'Furrow2: Starting the planting cycle.')
		
		for i = 1, settings.furrows do
			windower.add_to_chat(200, 'Furrow2: Searching for '..furrow_names[i])
			target(furrow_names[i])
			coroutine.sleep(2)
			plant(settings.seeds[i])
			coroutine.sleep(2)		
		end
		
		running = false
		windower.add_to_chat(200, 'Furrow2: Planting Complete!')
	else
		windower.add_to_chat(200, 'Furrow2: Something went wrong! Please try your command again after reloading Furrow2.')
	end
end

function furtilizecycle()
	if running == true then
		for i = 1, settings.furrows do
			windower.add_to_chat(200, 'Furrow2: Searching for '..furrow_names[i])
			target(furrow_names[i])
			coroutine.sleep(2)
			
			--TODO Identify what furtilizer the user set in the settings.
			-- check if they have it in there inventory and keep track of how much they have
			-- keep track of how many we use.
			-- if they usecrystals is set, make sure we recount how many crystals there are because they can be harvested up.
			
			plant(furtName) -- plant method can be used to add the furtilizer.
			coroutine.sleep(2)		
		end
		
		running = false
		windower.add_to_chat(200, 'Furrow2: Furtilizing Complete!')
	else
		windower.add_to_chat(200, 'Furrow2: Something went wrong! Please try your command again after reloading Furrow2.')
	end
end

function selljunkcycle()
	if running == true then
		windower.add_to_chat(200, 'Furrow2: Adding junk to SellNPC queue.')
		windower.send_command("sellnpc "..settings.sellnpc_profile)
		--for i, v in ipairs(junk) do
			--windower.send_command('sellnpc '..v)
			--coroutine.sleep(.5)
		--end
		coroutine.sleep(2)
		
		windower.add_to_chat(200, 'Furrow2: Searching for Green Thumb Moogle.')
		target("Green Thumb Moogle")
		coroutine.sleep(2)
		
		selljunk()
		coroutine.sleep(2)
		
		running = false
		windower.add_to_chat(200, 'Furrow2: Selling junk complete!')
	else
		windower.add_to_chat(200, 'Furrow2: Something went wrong! Please try your command again after reloading Furrow2.')
	end
end

function save_settings()
	settings:save()
	windower.add_to_chat(200, 'Furrow2: Settings Saved!')
end

function furrow_command(...)
	if running then
		windower.add_to_chat(167, 'Command cancelled. Furrow2 is currently running. Use fw stop or fw abort to stop the current operation.')
		return
	end
	
	if #arg > 0 then
		if #arg > 1 then
			if arg[1]:lower() == 'target' and arg[2] ~= nil then  -- tested, works
				target(arg[2])
			end
		end
		
		if arg[1]:lower() == 'start' then
			windower.add_to_chat(200, 'Furrow2: Begin loop: Plant > Furtialize > Wait > Harvest > Sell > repeat')
			running = true
			loop()
			
		elseif arg[1]:lower() == 'stop' or arg[1]:lower() == 'abort' then  -- tested, works
			windower.add_to_chat(200, 'Furrow2: Aborting all actions and reloading.')
			windower.send_command('lua reload furrow2')
		
		elseif arg[1]:lower() == 'harvest' then -- tested, works
			running = true
			harvestcycle()
		
		elseif arg[1]:lower() == 'plant' then -- tested, works
			running = true
			plantcycle()
		
		elseif arg[1]:lower() == 'selljunk' then -- tested, works
			running = true
			selljunkcycle()
		
		elseif arg[1]:lower() == 'sleepcycle' then  -- tested, works
			running = true
			sleepcycle()
			
		end
	end
end

function showhelp()
	windower.add_to_chat(200, 'Furrow2 commands: start stop abort plant harvest furtilize selljunk.')
end

windower.register_event('addon command', furrow_command)

windower.register_event('load', function()
	initialize()
end)

function getKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)

  return keys
end