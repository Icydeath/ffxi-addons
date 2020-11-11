_addon.name = 'Trader'
_addon.author = 'Icy'
_addon.commands = {'trader', 'tdr', 'tra'}
_addon.version = '2020.10.27'

local attention = [[
[Trader: recommended addons]
 "Itemizer" is used for retrieving items from storage: Windower launcher > addons tab

 "FindAll" is used for printing out pop items storage location: Windower launcher > addons tab

 "TradeNPC" is used for trading pop items to NPCs:
  https://github.com/Ivaar/Windower-addons/tree/master/TradeNPC
  
  For a list of commands use: //tra help
]]

require('tables')
require('strings')
require('sets')
packets = require('packets')
--inspect = require('inspect')

pops_by_mob = require('pops_by_mob')
res_zones = require('resources').zones
res_keyitems = require('keyitems')
abj_info = require('abjuration_info')
res_items = require("resources").items
bags = S{'safe','safe2','storage','locker','inventory','satchel','sack','case'} --,'wardrobe','wardrobe2','wardrobe3','wardrobe4'

load_required_addons = true -- When true, it will attempt to load: TradeNPC & Itemizer
use_get_commands = true -- Requires addon 'Itemizer'
include_all_drops = false -- set to true to see additional loot drops when using //tdr find Items Name
force_get_all = false -- set to true to force the get commands to retrieve all found instead of the specific amount needed. 
						-- Note: When enabled, itemizer will not warn you if you don't have enough of a specific item required for spawning the mob(s).
abjuration_info_on_drop = true
abjuration_info_to_partychat = true
debugmode = false -- set to true to see detailed information.

player = nil
pop_items = nil
pop_items_cnt = 0

windower.register_event('addon command', function(...)
	if windower.ffxi.get_mob_by_target('me').status ~= 0 then return end
	
    local commands = {...}
	if #commands ~= 0 then
		local given_param
		if commands[1]:lower() == 'debug' then 
			debugmode = not debugmode
			addon_msg('Debug mode: %s':format(debugmode and 'ON' or 'OFF'))
			return 
		end
		if commands[1]:lower() == 'help' then 
			print_help() 
			return 
		end		
		if commands[1]:lower() == 'useget' then 
			use_get_commands = not use_get_commands  
			addon_msg('Use get commands before trading: %s':format(use_get_commands and 'ON' or 'OFF'))
			return
		end
		if commands[1]:lower() == 'getall' or commands[1]:lower() == 'forceall' then 
			force_get_all = not force_get_all  
			addon_msg('Force using "all" when using get: %s':format(force_get_all and 'ON' or 'OFF'))
			return
		end
		
		if commands[1]:lower() == 'need' and commands[2] then
			-- ie: //tra need <zone | mob | loot | content>
			commands[2] = windower.convert_auto_trans(commands[2])
			commands[2] = table.concat(commands, ' ', 2)
			commands[2] = commands[2]:trim()
				
			local zone, content, abjs, loot
			zone = get_zone(commands[2])
			if zone then
				report_items_needed(zone.en, true)
			else
				report_items_needed(commands[2]:lower())
			end
			
			return
		end
		
		if commands[1]:lower() == 'list' then
			if not commands[2] then
				-- ie: //tra list
				list_all()
			else 
				-- ie: //tra list <zone | mob | loot | content>
				commands[2] = windower.convert_auto_trans(commands[2])
				commands[2] = table.concat(commands, ' ', 2)
				commands[2] = commands[2]:trim()
				
				local zone, content, abjs, loot
				zone = get_zone(commands[2])
				content = get_entries_by_content(commands[2])
				abjs = get_abjurations_by_itemname(commands[2])
				for i, abj in pairs(abjs) do
					commands[2] = abj.name:split(' ')[1]
					break
				end
				loot = get_entry_by_loot(commands[2])
				
				if loot then
					list_by_loot(commands[2])
				elseif zone then
					list_by_zone(zone.en)
				elseif content:length() > 0 then
					list_by_content(content)
				else -- ie: //tra list Zerde
					list_by_mob(commands[2]:lower())
				end
			end
			return
		end
		
		local getsonly = false
		local find_pop_items = false
		local find_cmd
		if commands[1]:lower() == 'get' then
			getsonly = true
		elseif commands[1]:lower() == 'find' or commands[1]:lower() == 'findall' then
			find_pop_items = true
			find_cmd = commands[1]:lower()
		end
		
		if not getsonly and not find_pop_items then -- ie: //tra ... <-- meaning you are at the NPC and want to trade the items for the entered mob name.
			commands[1] = windower.convert_auto_trans(commands[1])
			given_param = table.concat(commands, ' ')
		else -- ie: //tra get ...   or   //tra find ...
			local abjlist = get_abjurations_by_itemname(commands[2])
			if abjlist then
				for i, abj in pairs(abjlist) do
					commands[2] = abj.name:split(' ')[1]
					break
				end
			end
			commands[2] = windower.convert_auto_trans(commands[2])
			given_param = table.concat(commands, ' ', 2)
		end
		if debugmode then addon_msg(given_param..' | '..tostring(getsonly)..' | '..tostring(find_pop_items)) end
		
		if not given_param then 
			print_help()
			return 
		end
		given_param = given_param:trim():lower()
		
		local cmd, zone, loot, content
		mob = get_entry_by_mob(given_param)
		zone = get_zone(given_param)
		content = get_entries_by_content(given_param)
		loot = get_entry_by_loot(given_param)
		
		if mob or zone or loot or content then
			if mob and getsonly then
				local entries = T{ mob }
				cmd = create_gets_for_entries(entries)
			elseif mob and find_pop_items then
				local entries = T{ mob }
				cmd = create_finds_for_entries(entries, find_cmd)
				
			elseif zone and getsonly then
				cmd = create_gets_for_zone(zone.en)
			elseif zone and find_pop_items then
				cmd = create_finds_for_zone(zone.en, find_cmd)
				
			elseif loot and getsonly then
				local entries = get_entries_by_loot(given_param)
				cmd = create_gets_for_entries(entries, true)
			elseif loot and find_pop_items then
				local entries = get_entries_by_loot(given_param)
				finds = create_finds_for_entries(entries, find_cmd)
				cmd = finds
			
			elseif content and getsonly then
				local entries = get_entries_by_content(given_param)
				cmd = create_gets_for_entries(entries, true)
			elseif content and find_pop_items then
				local entries = get_entries_by_content(given_param)
				finds = create_finds_for_entries(entries, find_cmd)
				cmd = finds
				
			else -- generate trade command
				local entries
				if mob then
					if debugmode then addon_msg('Generating trade script for mob: ' .. mob.mob) end
					entries = T{ mob }
				elseif zone then
					if debugmode then addon_msg('Generating trade script for zone: ' .. zone.en) end
					entries = get_entries_by_zone(zone.en)
				elseif loot then
					if debugmode then addon_msg('Generating trade script for loot: ' .. given_param) end
					entries = get_entries_by_loot(given_param)
				end
				
				if entries then
					local current_zone = res_zones[windower.ffxi.get_info().zone].en
					local valid = true
					for i,ent in pairs(entries) do
						if ent.zone:lower() ~= current_zone:lower() then
							valid = false
							break
						end
					end
					
					if valid or debugmode then
						cmd = create_trade_for_entries(entries)
						if use_get_commands then
							cmd = create_gets_for_entries(entries) .. 'wait 2;' .. cmd
						end
					else
						addon_msg('NPC not found or you are in the wrong zone.')
					end
				else
					addon_msg('Unable to find entry for: ' .. given_param)
				end
			end
		end
		
		if cmd then
			if debugmode then addon_msg(cmd) end
			windower.send_command(cmd)
		else
			addon_msg('An error occured. Failed to generate commands.')
		end		
	else
		print_help()
		--addon_msg(tostring(pop_items['Ashweed']))
	end
end)


--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	CREATE CMD METHOD
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
function create_trade_for_entries(entries)
	local cmds_as_script = ''
	local trades = S{}
	for i,entry in pairs(entries) do
		if not entry.opens_menu and entry.mob:lower() ~= 'warder of courage' then
			if not entry.ki or (entry.ki and not has_ki(entry.ki)) then
				-- tradenpc 3 "Ashweed" 3 "Void Grass" 1 "Vermihumus" 1 "Coalition Humus" "Shiftrix"
				local cmd = 'input /echo Trading pops for '..entry.mob..';tradenpc '
				for itm,cnt in pairs(entry.items) do
					cmd = cmd .. tostring(cnt) .. ' "' .. itm .. '" '
				end
				cmd = cmd .. '"' .. entry.npc:ucfirst() .. '"'
				trades:add(cmd)
			--else
				--trades:add('input /echo Already have key item for '..entry.mob:upper())
			end
		end
	end
	
	for cmd in pairs(trades) do
		cmds_as_script = cmds_as_script .. cmd .. ';wait 3;'
	end
	cmds_as_script = cmds_as_script .. 'input /echo Trades complete!'
	return cmds_as_script
end


function create_gets_for_entries(entries, all)
	local get_cmds
	local joined = {}
	for i,entry in pairs(entries) do
		for itm,cnt in pairs(entry.items) do
			if not itm:lower():contains('nazar') then
				joined[itm] = joined[itm] and joined[itm] + cnt or cnt
			end 
		end
	end
	for item,cnt in pairs(joined) do
		if force_get_all or all then cnt = 'all' end
		get_cmds = get_cmds and get_cmds..'wait .5;get "'..item..'" '..cnt..';' or 'get "'..item..'" '..cnt..';'
	end
	
	return get_cmds..'wait 1;input /echo Gets complete!;'
end

function create_gets_for_zone(name)
	local get_cmds
	local joined = {}
	for i,entry in pairs(pops_by_mob) do
		if entry.zone:lower() == name:lower() then
			for itm,cnt in pairs(entry.items) do
				if not itm:lower():contains('nazar') then
					joined[itm] = joined[itm] and joined[itm] + cnt or cnt
				end
			end
		end
	end
	for item,cnt in pairs(joined) do
		if force_get_all then cnt = 'all' end
		get_cmds = get_cmds and get_cmds..'wait .5;get "'..item..'" '..cnt..';' or 'get "'..item..'" '..cnt..';'
	end
	
	return get_cmds..'wait 1;input /echo Get commands complete!'
end


function create_finds_for_zone(name, find_cmd)
	addon_msg(name)
	local finds
	local joined = S{}
	for i,entry in pairs(pops_by_mob) do
		if entry.zone:lower() == name:lower() then
			for itm,cnt in pairs(entry.items) do
				if not joined:contains(itm) then
					joined:add(itm)
				end
			end
		end
	end
	for item,b in pairs(joined) do
		finds = (finds or '')..find_cmd..' "'..item..'";wait 1;'
	end
	
	return finds
end

function create_finds_for_entries(entries, find_cmd)
	local finds
	local joined = S{}
	for i,entry in pairs(entries) do
		for itm,cnt in pairs(entry.items) do
			if not joined:contains(itm) then
				joined:add(itm)
			end
		end
	end
	for item,b in pairs(joined) do
		finds = (finds or '')..find_cmd..' "'..item..'";wait 1;'
	end
	
	return finds
end


--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	GET METHODS
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
function get_entry_by_mob(name)
	if not name then
		return
	end
	name = name:lower()
	
	local entry = pops_by_mob:with('mob', name)
	if not entry then
		for i,e in pairs(pops_by_mob) do
			if e.mob:startswith(name) then
				entry = e
				break
			end
		end
	end
	return entry
end

function get_entries_by_zone(name)
	local results = T{}
	for i,ent in pairs(pops_by_mob) do
		if ent.zone:lower() == name:lower() then
			results:insert(ent)
		end
	end
	return results
end

function get_entry_by_loot(name)
	local entry
	for i,ent in pairs(pops_by_mob) do
		for num,item in ipairs(ent.loot) do
			if item ~= "" and (item:lower() == name:lower() or item:lower():startswith(name:lower())) then
				entry = ent
				break
			end
		end
	end
	return entry
end

function get_entries_by_loot(name)
	addon_msg(name, 206)
	local results = T{}
	for i,ent in pairs(pops_by_mob) do
		for num,item in ipairs(ent.loot) do
			if item ~= "" and (item:lower() == name:lower() or item:lower():startswith(name:lower())) then
				results:insert(ent)
				break
			end
		end
	end
	return results
end

function get_entries_by_content(name)
	local results = T{}
	if not name then
		return results
	end
	name = name:lower()
	
	for i,ent in pairs(pops_by_mob) do
		if ent.content:lower() == name then
			results:insert(ent)
		end
	end
	
	if results:length() == 0 then
		for i,ent in pairs(pops_by_mob) do
			if (ent.content:lower()):startswith(name) then
				results:insert(ent)
			end
		end
	end
	
	return results
end

function get_abjurations_by_itemname(name)
	local results = T{}
	if not name then return results end
	name = name:lower()
	
	for i, a in pairs(abj_info) do
		local nq = a.nq
		if nq and (nq:lower() == name or nq:lower():startswith(name)) then
			results:insert(a)
		end
	end
	
	return results
end

function output_abjuration_info(item_id)
	local abjuration = abj_info:with('id', item_id)
	if abjuration then
		if abjuration_info_to_partychat and is_partyleader() then
			windower.send_command('input /p '..abjuration.name..' ('..abjuration.nq..'): '..abjuration.jobs)
		else
			addon_msg(abjuration.name..' ('..abjuration.nq..'): '..abjuration.jobs)
			--addon_msg('  '..abjuration.nq..' ('..abjuration.nqcursed..') | '..abjuration.hq..' ('..abjuration.hqcursed..')')
		end
	end
end

--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	REPORT INFO METHODS
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
function report_items_needed(name, is_zone)
	if not name then return end
	addon_msg('Reporting missing items for: '..name, 206)
	name = name:lower()
	
	local tempcnt = 0
	local temp = {}
	for i,e in pairs(pops_by_mob) do
		if (is_zone and e.zone:lower() == name) or (e.mob == name or e.mob:startswith(name)) then
			local haski = e.ki and has_ki(e.ki) or nil
			if not haski then -- dont have the ki or ki is not required.
				tempcnt = tempcnt + 1
				for itm,cnt in pairs(e.items) do
					if temp[itm] then
						temp[itm] = temp[itm] + cnt
					else
						temp[itm] = cnt
					end
				end
			end
		end
	end
	if tempcnt == 0 then 
		addon_msg('You have the required item(s). To see more detail use //tra list '..name)
	else	
		addon_msg(' (missing)Item Name ', 020)
		addon_msg('----------------------', 020)
		for itm,total_needed in pairs(temp) do
			local havecnt = has_item(pop_items[itm])
			if not havecnt and itm:lower():contains('nazar') then
				havecnt = has_ki(itm) and 1 or nil
			end
			havecnt = havecnt and havecnt or 0
			local remaining = total_needed - havecnt
			if remaining > 0 then
				local altcolor = 250
				if havecnt > 0 then altcolor = 059 end
				addon_msg(' ('..remaining..')'..itm, altcolor)
				--addon_msg(' '..havecnt..'/'..total_needed..'('..remaining..')'..itm, altcolor)
			end
		end
		addon_msg('For more details use //tra list '..name:capitalize())
	end
end

--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	LIST INFO METHODS
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
function list_all()
	addon_msg('LIST OF ALL MOBS', 206)
	for i,e in pairs(pops_by_mob) do
		local altcolor = 250
		if e.ki and has_ki(e.ki) then
			altcolor = 204
		end
		addon_msg(' '..e.mob:upper()..' ['..(e.content and e.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or "")..'] > '..(e.zone and e.zone:capitalize() or '')..(e.pos and e.pos or '')..' - '..e.npc:capitalize(), altcolor)
		if e.ki then addon_msg('  KI: '..e.ki, altcolor) end

		output_popitem_info(e.items)
		
		addon_msg()
	end
end

function list_by_mob(name)
	addon_msg('Search param: '..name, 206)
	local e = get_entry_by_mob(name)
	if e then
		local altcolor = 250
		if e.ki and has_ki(e.ki) then
			altcolor = 204
		end
		addon_msg(' '..e.mob:upper()..' ['..(e.content and e.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or "")..'] > '..(e.zone and e.zone:capitalize() or '')..(e.pos and e.pos or '')..' - '..e.npc:capitalize(), altcolor)
		if e.ki then addon_msg('  KI: '..e.ki, altcolor) end
		
		output_popitem_info(e.items)
	else
		addon_msg('  Unable to find ['..name..']', 186)
	end
end

function list_by_loot(name)
	addon_msg('Search param: '..name, 206)
	for i,ent in pairs(pops_by_mob) do
		local matched_item
		for num,item in ipairs(ent.loot) do
			if item ~= "" and (item:lower() == name:lower() or item:lower():startswith(name:lower())) then
				matched_item = item
				break
			end
		end
		
		if matched_item then
			local subname = ''
			local abj = abj_info:with('name', matched_item)
			if abj then subname = '('..abj.nq..') ' end
			addon_msg('['..matched_item..'] '..subname, 207)
			
			local altcolor = 250
			if ent.ki and has_ki(ent.ki) then
				altcolor = 204
			end
			addon_msg(' '..ent.mob:upper()..' ['..(ent.content and ent.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or "")..'] > '..(ent.zone and ent.zone:capitalize() or '')..(ent.pos and ent.pos or '')..' - '..ent.npc:capitalize(), altcolor)
			if ent.ki then addon_msg('  KI: '..ent.ki, altcolor) end
			
			output_popitem_info(ent.items)
			
			if include_all_drops then
				addon_msg('   also drops: '..table.concat(ent.loot, ' | '):gsub(matched_item..' | ', ''):gsub(' | '..matched_item, ''), 186)
			end
			addon_msg(' ', 186)
		end
	end
end

function list_by_zone(name)
	addon_msg('Search param: '..name, 206)
	for i,e in pairs(pops_by_mob) do
		if e.zone:lower() == name:lower() then
			local altcolor = 250
			if e.ki and has_ki(e.ki) then
				altcolor = 204
			end
			addon_msg(' '..e.mob:upper()..' ['..(e.content and e.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or "")..'] > '..(e.zone and e.zone:capitalize() or '')..(e.pos and e.pos or '')..' - '..e.npc:capitalize(), altcolor)
			if e.ki then addon_msg('  KI: '..e.ki, altcolor) end

			output_popitem_info(e.items)
			
			addon_msg()
		end
	end
end

function list_by_content(entries)
	if not entries then
		addon_msg('Content not found.', 200)
		return
	end
	local content = ''
	for i,li in pairs(entries) do
		content = li.content
		break
	end
	addon_msg('Search param: '..content, 206)
	
	for i,e in pairs(entries) do
		local items_str = ''
		for itm,cnt in pairs(e.items) do
			items_str = items_str..' ('..tostring(cnt)..')'..itm:capitalize()
		end
		local altcolor = 250
		if e.ki and has_ki(e.ki) then
			altcolor = 204
		end
		addon_msg(' '..e.mob:upper()..' ['..(e.content and e.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or "")..'] > '..(e.zone and e.zone:capitalize() or '')..(e.pos and e.pos or '')..' - '..e.npc:capitalize(), altcolor)
		if e.ki then addon_msg('  KI: '..e.ki, altcolor) end
		
		output_popitem_info(e.items)
		
		--addon_msg(' '..e.mob:upper()..' ['..(e.content and e.content:gsub(' iii',' 3'):gsub(' ii',' 2'):gsub(' i',' 1'):capitalize() or '')..']'..(e.pos and e.pos or '')..':'..items_str..' '..(e.ki and '> "'..e.ki..'"' or ''), altcolor)
		addon_msg()
	end
end

function output_popitem_info(items)
	for itm,cnt in pairs(items) do
		local total = has_item(pop_items[itm])
		total = total and total or 0
		if total == 0 and itm:lower():contains('nazar') then
			total = has_ki(itm) and 1 or 0
		end
		
		if total >= cnt then altcolor = 204
		elseif total > 0 then altcolor = 059
		else altcolor = 250 end
		addon_msg('   ('..tostring(cnt)..')'..itm:capitalize(), altcolor)
	end
end


--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	OTHER METHODS
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
function has_item(item_id)
	local storages = get_player_items()
	local total = nil
	--addon_msg(inspect(storages[player.name]['inventory']))
	
	for bagname,bagitems in pairs(storages[player.name]) do
		for id,count in pairs(bagitems) do
			if id == item_id then
				if not total then
					total = count
				else
					total = total + count
				end
			end
		end
	end
	
	return total
end

function get_player_items()
	local inventory = windower.ffxi.get_items()
	local storages = {}
	storages[player.name] = {}
	
	-- flatten inventory > Shamelessly stolen from findAll. Many thanks to Lili. > Shamelessly stolen from findAll. Many thanks to Zohno.	
	for bag,_ in pairs(bags:keyset()) do 
        storages[player.name][bag] = T{}
		for i = 1, inventory[bag].max do
			data = inventory[bag][i]
			if data.id ~= 0 then
				local id = data.id
				storages[player.name][bag][id] = (storages[player.name][bag][id] or 0) + data.count
			end
        end
    end
	
	return storages
end

function is_partyleader()
	local player = windower.ffxi.get_player()
	local party = windower.ffxi.get_party()
	
	if party.p1 and party.party1_leader ~= player.id then 
		return false -- we are not leader so return false
	end
	
	return true
end

function has_ki(name)
	local result = false
	if not name then
		return result
	end
	name = name:lower()
	
	local owned_kis = windower.ffxi.get_key_items()
	for _, ki_id in pairs(owned_kis) do
		local ki = res_keyitems[ki_id]
		if ki then
			if ki.en:lower() == name then
				result = true
				break
			end
		end
    end
	owned_kis = nil
	
	return result
end

function get_zone(name)
	local entry = res_zones:with('en', name)
	if not entry then
		for i,z in pairs(res_zones) do
			if z and z.en:lower():startswith(name:lower()) then
				entry = z
				break
			end
		end
	end
	return entry
end

function normalize_data(data)
	-- make all string fields lowercase to make it easier to search.
	local temp = T{}
	for i,e in pairs(data) do
		temp:insert({
			mob = e.mob:lower(), 
			npc = e.npc and e.npc:lower() or "", 
			items = e.items, 
			content = e.content and e.content:lower() or "",
			zone = e.zone and e.zone:lower() or "",
			pos = e.pos,
			loot = e.loot,
			opens_menu = e.opens_menu,
			ki = e.ki
		})
	end
	return temp
end

function setup_pop_items_list()
	pop_items = {}
	
	for i,e in pairs(pops_by_mob) do
		for itm_name,cnt in pairs(e.items) do
			if not pop_items[itm_name] then
				pop_items[itm_name] = get_itemid_by_name(itm_name) or -1
				pop_items_cnt = pop_items_cnt + 1
			end
		end
	end
	
	res_items = nil
end

function get_itemid_by_name(str)
	if not res_items or not str then return end
	
	str = str:lower()
	for id,item in pairs(res_items) do
		if str == item.en:lower() or str == item.enl:lower() then
			return item.id
		end
	end
end

function addon_msg(msg, clr)
	if not clr then clr = 207 end
	if not msg or msg == ' ' then
		windower.add_to_chat(clr, ' ')
	else
		--windower.add_to_chat(clr, '['.._addon.name..'] '..msg)
		windower.add_to_chat(clr, msg)
	end
end

function print_help()
	addon_msg('tra <mob name | zone name | item name> ~ creates and executes the TradeNPC command(s)', 250)
	addon_msg('tra list ~ lists all mobs info in pops_by_mob.lua', 250)
	addon_msg('tra list <mob name | zone name | item name | content> ~ lists info for the listed mobs.', 250)
	addon_msg('tra need <mob name | zone name | item name | content> ~ lists the remaining items needed for the listed mobs.', 250)
	addon_msg('tra get <mob name | zone name | item name | content> ~ creates and executes the get commands for the listed mobs pop items.', 250)
	addon_msg('tra find | findall <mob name | zone name | item name> ~ creates and executes the find commands for the listed mobs pop items.', 250)
	addon_msg('tra useget ~ (default: true) when enabled, get commands are executed before the tradenpc command.', 250)
	addon_msg('tra getall ~ (default: false) when enabled, the get commands will use "all" instead of # needed.', 250)
	addon_msg('  * partial spelling and auto-trans is allowed. ie: \'Yil\' will result in \'Yilan\'', 250)
	addon_msg('  * Green text means you have the items.', 204)
	addon_msg('  * Yellow text means you have some the items.', 053)
	addon_msg('  * White text means you do not have the item.', 250)
end

--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~
	EVENT METHODS
~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
windower.register_event('load', function() 
	addon_msg(attention, 260)
	player = windower.ffxi.get_player()
	
	if load_required_addons then
		local txt = 'Attempting to load addon TradeNPC'
		addon_msg(use_get_commands and txt..' & Itemizer' or txt, 258)
		windower.send_command(use_get_commands and "lua load TradeNPC;wait 1;lua load Itemizer" or "lua load TradeNPC")
	end
	--coroutine.sleep(1)
	--addon_msg('Trader: Initializing lists...')
	--coroutine.sleep(1)
	pops_by_mob = normalize_data(pops_by_mob)
	setup_pop_items_list()
	--addon_msg('Trader: Complete. '..tostring(pop_items_cnt)..' items initialized.')
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x0D2 and abjuration_info_on_drop then 
        local treasure = packets.parse('incoming', data)
		output_abjuration_info(treasure.Item)
	end
end)