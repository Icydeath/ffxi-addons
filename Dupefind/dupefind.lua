--[[
Additions by Icy

//df get put
	This command will get everything on your char to consolidate items, 
	 and then will put them all away to the set storage locations (set the storage_bags in the lua)  


//df findall get put
	This command will get everything that is duplicated across all chars and put 
	 items away on all chars that can't be merged with other characters. (set the storage_bags in the lua)  

-------------------------------------------------------------------------------
----------------------------------- README ------------------------------------
-------------------------------------------------------------------------------
dupefind: finds duplicates on current char/across all characters

usage:
//dupefind flag1 flag2 ... flagN

shorthands: //dupe, //df

dupefind by default does not display:
- items with the RARE or EXclusive tags
- items that cannot be stacked (with a stack size of 1)
- items that cannot be sent to another character on the same account
and will only disply items on the currently logged in character.

flags:
- rare: includes rare items
- ex: includes exclusive items as long as they can be sent via POL
- nostack: includes items with stack size of 1
- findall: searchs every available character instead of just current
to use the findall flag, you need to have the addon findAll installed, and have 
run it at least once on all characters

example:
//dupe nostack findall - will find all duplicate items that are not rare/ex, 
                         across every character
//dupe ex nostack      - will find all duplicate items, including Ex and items 
                         that do not stack, but excluding Rare

Changelog

0.6.3 - added put functionality
0.6.2 - fixed some condition bugs
0.6.1 - added additional output for get
0.6 - Icy added get cmd
0.5.1 - Cleanup and better help text.
0.4 - Some more cleanup.
0.3 - First release. Many thanks to Arcon for the feedback about the code.
0.2 - Cleanup. Multiple character search, toggles for stackable, rare, ex, CanSendPol.
0.1 - Initial version. Single character search and stackable toggle.

Thanks to Zohno, this addon contains code taken from his addon findAll
Thanks to Arcon, he took the time to read my original iterations and letting me know all the dumb crap I was doing
]]

_addon.name = 'dupefind'
_addon.author = 'Lili, modified by Icy'
_addon.version = '0.6.3'
_addon.commands = {'dupefind','dupe', 'df',}

--inspect = require('inspect')
require('logger')
require('tables')
require('strings')
--require('config')
res_items = require('resources').items
lang = windower.ffxi.get_info().language:lower()

function preferences()
	ignore_items = S{ 'linkshell', 'linkpearl', 'Trump Card', 'Automat. Oil +3', 'Colorless Soul', 'Azdaja\'s Horn', 'Eminent Bullet', 'Adlivun Bullet', 'Orichalc. Bullet' }
	ignore_players = S{ 'Icybst','Icylife','Cometpunches','Eldiablo','Combat','Icybreath', 'Gab' }
	ignore_findall_usable_items = true -- probably a better way, but this is used to ignore things like food, silent oils, etc...
	ignore_findall_omen_cards = true
	ignore_rare = true
	ignore_ex = true
	ignore_nostack = true
	get_dupes = false -- if true, it will send a '//get ItemName all' to stack the items in your inventory. Uses the '//send CharName ...' if using findall
	store_dupes = false -- if true, this will store dupes that can't be consolidated between characters. Set the storage_bags to the bags you want it to store
	storage_bags = {'satchel','sack','case'} -- 'safe','safe2','storage','locker','satchel','sack','case'
	
	player_only = true
	filter_by_player = true
end

bags = S{'safe','safe2','storage','locker','inventory','satchel','sack','case','wardrobe','wardrobe2','wardrobe3','wardrobe4'}
omen_cards = S{ "P. WAR Card", "P. MNK Card", "P. WHM Card", "P. BLM Card", "P. RDM Card", "P. THF Card", "P. PLD Card", "P. DRK Card", "P. BST Card", "P. BRD Card", "P. RNG Card", "P. SAM Card", "P. NIN Card", "P. DRG Card", "P. SMN Card", "P. BLU Card", "P. COR Card", "P. PUP Card", "P. DNC Card", "P. SCH Card", "P. GEO Card", "P. RUN Card"}

-------------------------------------------------------------------------------------------------------------
preferences()

ignore_items = ignore_items:map(string.lower)
ignore_ids = res_items:filter(function(item) 
		return ignore_items:contains(item.name:lower()) or ignore_items:contains(item.name_log:lower()) 
	end):keyset()

local get_flag = function(args, flag, default)
    for _, arg in ipairs(args) do
        if arg == flag then
            return false
        end
    end
    return default
end

function CanSendPol(id) return S(res_items[id].flags):contains('Can Send POL') end
function IsRare(id) return S(res_items[id].flags):contains('Rare') end
function IsExclusive(id) return S(res_items[id].flags):contains('Exclusive') or S(res_items[id].flags):contains('No PC Trade') end
function IsStackable(id) return res_items[id].stack > 1 end
function IsUsable(id) return res_items[id].category == 'Usable' end
function IsOmenCard(id) return omen_cards:contains(res_items[id].name) end

player = windower.ffxi.get_player().name
function work(...)
	args = {...}    
	
	local ignore_rare = get_flag(args, 'rare', ignore_rare) -- where `settings` is the global settings table
	local ignore_ex = get_flag(args, 'ex', ignore_ex)
	local ignore_nostack = get_flag(args, 'nostack', ignore_nostack)
	local player_only = get_flag(args, 'findall', player_only)
	local filter_by_player = get_flag(args, 'nofilter', filter_by_player)

	for _, arg in ipairs(args) do
		if arg == 'get' or arg == 'getdupes' then
			get_dupes = true
		elseif arg == 'put' or arg == 'putdupes' or arg == 'store' or arg == 'storedupes' then
			store_dupes = true
		end
	end
	
	
	local inventory = windower.ffxi.get_items()
	local storages = {}
	local getcmds = S{}
	local putcmds = S{}
	local most_items = {}
	local got_items = {}
	
	storages[player] = {}
	
	local haystack = {}
	local results = 0

	-- flatten inventory
	--Shamelessly stolen from findAll. Many thanks to Zohno.	
	for bag,_ in pairs(bags:keyset()) do 
        storages[player][bag] = T{}
		for i = 1, inventory[bag].max do
			data = inventory[bag][i]
			if data.id ~= 0 then
				local id = data.id
				storages[player][bag][id] = (storages[player][bag][id] or 0) + data.count
			end
        end
    end
	
	-- get offline storages from findAll if available. This code is also lifted almost verbatim from findAll.
	if not player_only then
		-- run a findall update
		log('Updating findall data')
		windower.send_command('findall')
		coroutine.sleep(2)
					
		local findall_data = windower.get_dir(windower.addon_path..'..\\findall\\data')
		if findall_data then
			for _,f in pairs(findall_data) do
				if f:sub(-4) == '.lua' and f:sub(1,-5) ~= player then
					local success,result = pcall(dofile,windower.addon_path..'..\\findall\\data\\'..f)
					if success then
						storages[f:sub(1,-5)] = result
					else
						warning('Unable to retrieve updated item storage for %s.':format(f:sub(1,-5)))
					end
				end
			end
		end
	end
	
	--log(inspect(storages["Rythor"]["case"]))
	
	for character,inventory in pairs(storages) do
		if not ignore_players:contains(character) then
			got_items[character] = {}
			for bag,items in pairs(inventory) do
				if bags:contains(bag) then
					for id, count in pairs(items) do
						id = tonumber(id)
						--if item is valid, stackable, not ignored, not rare, not Exclusive
						if res_items[id] and (not ignore_ids:contains(id))
							and (IsStackable(id) or not ignore_nostack)
							and (not IsRare(id) or not ignore_rare)
							and ( (not IsExclusive(id) or CanSendPol(id)) or not ignore_ex )
						then
							-- backwards logic is hurting my head... my piss poor condition workaround
							local addit = true
							if not player_only and IsOmenCard(id) and ignore_findall_omen_cards then
								addit = false
							elseif not player_only and IsUsable(id) and ignore_findall_usable_items then
								addit = false
							end
							
							if addit then
								--player str, bag str, id int, count int
								if player_only then
									location = bag
								else
									location = character..','..bag
								end
								
								if not haystack[id] then haystack[id] = {} end
								haystack[id][location] = count
							end
						end
					end
				end
			end
		end
	end
	
	--log(inspect(got_items))
	
	--print duplicates
	for id,locations in pairs(haystack) do
		if table.length(locations) > 1 then
			results = results +1
			local item_name = res_items[id].name
			
			if not get_dupes then log(item_name,'found in:') end
			
			for location,count in pairs(locations) do
				local player_name = nil
				local bag_name = location
				if string.find(location, ",") then
					local splat = S{}
					for x in string.gmatch(location, '([^,]+)') do
						splat:insert(x)
					end
					
					player_name = splat[1]
					bag_name = splat[2]
				end
				
				if not get_dupes then 
					log('  ', player_name or '', bag_name, count) 
				else
					local c = generate_getcmd(item_name, player_name, bag_name)
					if c then
						getcmds:insert(c)				
					end
					--log(inspect(got_items))					
					if not got_items[player_name or player][id] then
						got_items[player_name or player][id] = {}
						got_items[player_name or player][id]["itemname"] = item_name
						got_items[player_name or player][id]["total"] = count
						got_items[player_name or player][id][bag_name] = count
					else
						got_items[player_name or player][id].total = got_items[player_name or player][id].total + count
						if got_items[player_name or player][id][bag_name] then
							--log('= '..got_items[player_name or player][id][bag_name])
							got_items[player_name or player][id][bag_name] = got_items[player_name or player][id][bag_name] + count
						else
							got_items[player_name or player][id][bag_name] = count
						end
					end
					
				end
				
				if get_dupes and not player_only then
					local cnt_entry = {} 
					local removeItemFromPlayer = nil
					if most_items then
						if not most_items[player_name or player] then
							most_items[player_name or player] = {}
						end
						
						if most_items[player_name or player][item_name] then
							most_items[player_name or player][item_name] = most_items[player_name or player][item_name] + count
						end
						
						local hasItem = false
						for play,items in pairs(most_items) do
							for itm, cnt in pairs(items) do
								if itm == item_name then
									hasItem = true
									if count > cnt then
										most_items[player_name][item_name] = count
										removeItemFromPlayer = play
									end
								end
							end
						end
						
						if not hasItem then
							most_items[player_name] = {[item_name] = count}
						end
						
						if removeItemFromPlayer then 
							most_items[removeItemFromPlayer][item_name] = nil
						end
					end
					
				end
			end
		end
	end
	
	--log(inspect(most_items))
	
	-- run the get cmds
	if get_dupes then
		local lastitem = ''
		for i, cmd in ipairs(getcmds) do
			if cmd then -- if cmd is empty it means its already in the players inventory.
				local thisplayer = string.find(cmd, 'send') and string.match(cmd, "%s+(%S+)") or player
				local thisitem = string.match(cmd, [["([^"]+)]])
				if thisplayer ~= lastplayer and thisitem ~= lastitem then
					log('\t [GET] '..thisplayer, thisitem)
					lastitem = thisitem
					lastplayer = thisplayer
				end
				windower.send_command(cmd)
				coroutine.sleep(1.5) -- sleep to reduce the load on itemizer, it may not be needed, not sure...
			end
		end
	end
	
	--log(inspect(got_items))
	
	if store_dupes and get_dupes then 
		local temp = got_items
		
		-- identify the set storage_bags available cnt for each player that got items
		local bags = {}
		for p,itms in pairs(got_items) do		
			for __i, b in pairs(storage_bags) do
				if storages[p][b] then
					if not bags[p] then bags[p] = {} end
					local scnt = 0
					for t, r in pairs(storages[p][b]) do scnt = scnt + 1 end
					bags[p][b] = 80 - scnt
					
					-- adjust slots because items > stack size takes up additional slots.
					local adjslots = 0
					for iid, num in pairs(storages[p][b]) do
						if num > 1 then
							local numOfSlotsNeeded = math.ceil(num / res_items[tonumber(iid)].stack)
							if numOfSlotsNeeded > 1 then
								adjslots = adjslots + numOfSlotsNeeded - 1
							end
						end
					end
					bags[p][b] = bags[p][b] - adjslots
					
					-- identify if the bags we are storing to had items pulled from it, if so, adjust that numb of free slots
					for itemid, item in pairs(itms) do
						if item[b] then
							local calcslots = math.ceil(item[b] / res_items[itemid].stack)
							bags[p][b] = bags[p][b] + calcslots
						end
					end
				end
			end
		end
		
		-- identify which items can't be merged with other characters and generate a put cmd
		for p,itms in pairs(got_items) do	
			for id, inf in pairs(itms) do
			
				-- identify if anyone else has this item, if not, create put cmd
				local genputcmd = true
				for tp,ti in pairs(temp) do
					for titm, tinf in pairs(ti) do
						if tp ~= p and tinf.itemname == inf.itemname then
							genputcmd = false
						end
					end
				end
				
				if genputcmd then
					local bag_used,slots_used,c = generate_putcmd(id, inf.itemname, inf.total, p, bags)
					if c then
						putcmds:insert(c)				
						-- update the bags available space.
						if bag_used and slots_used then
							bags[p][bag_used] = bags[p][bag_used] - slots_used
						end
					end
				end
			end
		end
		--log(inspect(bags))
		if putcmds:length() >= 1 then
			if not player_only then 
				log(' Attempting to put away items that cannot be merged with another character')
			else
				log(' Attempting to store consolidated items')
			end
			
			for z, cm in ipairs(putcmds) do
				windower.send_command(cm)
				log('\t [PUT] '..cm)
				coroutine.sleep(1.5)
			end
		end
	end
	
	--log(inspect(got_items))
	
	local displayed_MostItems = false
	-- report who holds the most of the retrieved items.
	if get_dupes and not player_only and most_items then
		--log(inspect(most_items))
		log()
		--log('\t', 'MOST', '>>>', 'ITEM', '>>>', 'OTHERS')
		for p,itms in pairs(most_items) do
			for itm, cnt in pairs(itms) do
				displayed_MostItems = true
				local appendChars = ''
				for character,gotitems in pairs(got_items) do
					for itmid, itminfo in pairs(gotitems) do
						--log(character,inspect(itminfo))
						if p ~= character and itminfo.itemname == itm then
							if appendChars ~= '' then
								appendChars = appendChars..','..character
							else
								appendChars = character
							end
						end
					end
				end
				
				log('\t', p, '\t'..itm..'('..cnt..')\t'..'['..appendChars..']')
			end
		end
		if displayed_MostItems then
			log()
			log('Above is a list of characters that holds the greatest number of duplicates found.')
			log(' - 1st Column: Character with the most\n\t - 2nd Column: Name of the Item(count)\n\t\t - 3rd Column: Other characters with the item')
			log()
		end
	end
	
	
	
	
	if results >= 1 then
		log(results,'found.')
	else
		log('No duplicates found. Congratulations!')
	end
	
	preferences()
end

function generate_getcmd(item_name, player_name, bag_name)
	if item_name and bag_name then
		if bag_name:lower() == 'inventory' then return nil end
		
		if player_name and player_name ~= player then
			return 'send '..player_name..' get "'..item_name..'" '..bag_name..' all'
		else
			return 'get "'..item_name..'" '..bag_name..' all'
		end
	end
	
	return nil
end

function generate_putcmd(item_id, item_name, item_count, player_name, bags)
	if item_id and item_name and item_count and player_name and bags then
		
		-- identify what bag with the most free slots.
		-- Note: this asumes all 80 slots are available.
		local storage_bag = nil
		for bag, free in pairs(bags[player_name]) do
			if not storage_bag then
				storage_bag = {
					["name"] = bag,
					["free"] = free
				}
			elseif free > storage_bag.free then
				storage_bag = {
					["name"] = bag,
					["free"] = free
				}
			end
		end
		--log(inspect(storage_bag))
		if storage_bag.free == 0 then return nil end -- means we don't have any space to put stuff
		
		local slots_needed = math.ceil(item_count / res_items[item_id].stack)
		if storage_bag.free < slots_needed then return nil end -- not enough space to fit it all, so leave it in there inventory
		
		if player_name ~= player then
			return storage_bag.name, slots_needed, 'send '..player_name..' put "'..item_name..'" '..storage_bag.name..' all'
		else
			return storage_bag.name, slots_needed, 'put "'..item_name..'" '..storage_bag.name..' all'
		end
		
	end
	
	return nil
end

function handle_commands(...)
	args = {...}
	if args[1] == 'r' then -- shorthand for easy reloading
		windower.send_command('lua r '.._addon.name)
	else
		work(...)
	end
end
windower.register_event('addon command',handle_commands)


--[[
Copyright © Lili, 2019
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of dumperino nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]