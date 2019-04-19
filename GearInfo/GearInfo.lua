_addon.name = 'GearInfo'
_addon.author = 'Sebyg666'
_addon.version = '1.7.2.10'
_addon.commands = {'gi','gearinfo'}


require('tables')
require('lists')
require('strings')
require('logger')
require('pack')

DW_Gear = require('res/DW_Gear')
Unity_rank = require('res/Unity_Gear')
Martial_Arts_Gear = require('res/Martial_Arts_Gear')
Set_bonus_by_Set_ID= require('res/Set_bonus_by_Set_ID')
Set_bonus_by_item_id = require('res/Set_bonus_by_item_id')
Blu_spells = require('res/Blue_Mage_Spells')
Gifts = require('res/Gifts')
Cor_Rolls = require('res/Cor_Rolls')
Bard_Songs = require('res/Bard_Songs')
Geo_Spells = require('res/Geo_Spells')

res = require('resources')
skills_from_resources = res.skills
Extdata = require("extdata")
config = require('config')
files = require('files')
blu_spells = res.spells:type('BlueMagic')
timer = require('timeit')
packets = require('packets')
bit = require('bit')
chat = require('chat')
chars = require('chat.chars')

require 'Statics'
require 'Gear_Processing'
require 'Calculator'
require 'Action_Processing'
require 'Buff_Processing'
require 'Packet_parsing'
require 'Image_processing'

windower.register_event('load', function()
	if windower.ffxi.get_player() then
		options_load()
		--text_box:show()
		
		if files.exists('data\\'..player.name..'_temp_party.lua') then
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_party.lua','r')
			local t = f:read("*all")
			t = assert(loadstring(t))()
			f:close()
			member_table = t
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_party.lua','w')
			f:write('return {}')
			f:close()
		end
		if files.exists('data\\'..player.name..'_temp_buffs.lua') then
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_buffs.lua','r')
			local t = f:read("*all")
			t = assert(loadstring(t))()
			f:close()
			_ExtraData.player.buff_details = t
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_buffs.lua','w')
			f:write('return {}')
			f:close()
		end
		
	end
end)

windower.register_event('logout', function()
	
	player = {}
	player.equipment = T{}
	buff = 0
	full_gear_table_from_file = T{}
	
	manual_stp = 0
	manual_dw = 0
	manual_ghaste = 0
	WSTP = 0
	
end)

windower.register_event('login',function ()
	windower.send_command('lua r gearinfo;')
end)

function options_load()
	
	if windower.ffxi.get_player() then
	
		notice('please note since version \'1.7.2.2\' onwards the settings file structure changed in a manner user intervention is required.')
		notice('please either delete your GearInfo Data folder or the \"player name\"_settings.xml files within it and reload the addon.')
		notice('I apologize for the inconvenience.')
		
		settings = config.load('data\\'..windower.ffxi.get_player().name..'_settings.xml',defaults)
		settings:save('all')
		sections.background = ImageBlock.New(0,'background','')
		--sections.logo = ImageBlock.New(1,'logo','')
		player = windower.ffxi.get_player()
		update_party()
		local this_file = files.new('data\\'..player.name..'_data.lua',true)
		
		if not files.exists('data\\'..player.name..'_data.lua') then
			this_file:create()
			local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w')
			f:write('return {\n}')
			f:close()
			print(player.name..'_data.lua created by GearInfo')
			parse_inventory()
		else
			full_gear_table_from_file = get_equipment_from_file()
		end
		
		manual_stp = 0
		manual_dw = 0
		manual_ghaste = 0
		initialize_packet_parsing()
	end
	
end

windower.register_event('addon command', function(command, ...)
	local args = {...}
    command = command and command:lower()
    if command then
        if command:lower() == 'parse' then
			log('Parsing all inventories to file')
			parse_inventory()
		elseif command:lower() == 'rank' then
			--table.vprint(args)
			if type(tonumber(args[1])) == 'number'  then
				settings.player.rank = tonumber(args[1])
				log('Changed \'Unity Rank\' to '..tonumber(args[1])..'. Don\'t forget to \"//gi parse\" to apply new values to your gear.')
				settings:save('all')
			else
				log('Your current \'Unity Rank\' setting is: '..settings.player.rank..'.')
			end
			settings:save('all')
		elseif command:lower() == 'stp' and type(tonumber(args[1])) == 'number' then
			manual_stp = tonumber(args[1])
			log('Set maunal Store TP to ' .. tostring(manual_stp))
		elseif command:lower() == 'dw' and type(tonumber(args[1])) == 'number' then
			manual_dw = tonumber(args[1])
			log('Set maunal Dual Wield to ' .. tostring(manual_dw))
		elseif command:lower() == 'ghaste' and type(tonumber(args[1])) == 'number' then
			manual_ghaste = tonumber(args[1])
			log('Set maunal Gear Haste to ' .. tostring(manual_ghaste))
		elseif command:lower() == 'mhaste' and type(tonumber(args[1])) == 'number' then
			manual_mhaste = tonumber(args[1])
			log('Set maunal Magic Haste to ' .. tostring(manual_mhaste))
		elseif command:lower() == 'jahaste' and type(tonumber(args[1])) == 'number' then
			manual_jahaste = tonumber(args[1])
			log('Set maunal Job Ability Haste to ' .. tostring(manual_jahaste))
		elseif command:lower() == 'dwn' and type(tonumber(args[1])) == 'number' then	
			manual_dw_needed = tonumber(args[1])
			log('Set maunal DW needed to ' .. tostring(manual_dw_needed))
		elseif command:lower() == 'r' or command:lower() == 'reload' then
			
			local new_item = member_table
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_party.lua','w')
			f:write('return ' .. T(new_item):tovstring())
			f:close()
			
			local new_item = _ExtraData.player.buff_details
			local f = io.open(windower.addon_path..'data/'..player.name..'_temp_buffs.lua','w')
			f:write('return ' .. T(new_item):tovstring())
			f:close()
			notice('Buffs and party saved to temp file. Reloading GI.')

			windower.send_command('lua r gearinfo;')
		elseif command:lower() == 'save' or command:lower() == 's' then
			if args[1]:lower() == 'wstp' then
				WSTP = get_tp_per_hit(player.equipment).tp_per_hit_melee
			else
				log('Misstype: use //gi save wstp')
			end
		elseif command:lower() == 'delete' or command:lower() == 'd' then
			if args[1]:lower() == 'wstp' then
				WSTP = 0
			else
				log('Misstype: use //gi delete wstp')
			end	
		elseif command:lower() == 'hide' then
			settings.player.show_logo = false
			settings.player.show_total_haste = false
			settings.player.show_tp_Stuff = false
			settings.player.show_acc_Stuff = false
			settings.player.show_dt_Stuff = false
			settings.player.show_att_Stuff = false
			settings.player.show_Evasion = false
			settings.player.show_Defence = false
			settings.player.show_STP = false
			settings.player.show_DW_Stuff = false
			settings.player.show_MA_Stuff = false
			log('All display settings set to false to hide display.')
			settings:save('all')
		elseif command:lower() == 'update' then
			update_gs(DW, (DW_needed + manual_dw_needed), get_total_haste())
		elseif command:lower() == 'updategs' or command:lower() == 'ugs' then
			if args[1] == nil then
				if settings.player.update_gs == false then
					settings.player.update_gs = true
				elseif settings.player.update_gs then
					settings.player.update_gs = false
				end
			elseif args[1]:lower() == 'true' then
				settings.player.update_gs = true
			elseif args[1]:lower() == 'false' then
				settings.player.update_gs = false
			end
			log('Auto update Gearswap = '..tostring(settings.player.update_gs))
			settings:save('all')
		elseif command:lower() == 'brd' then
			if type(tonumber(args[1])) == 'number' then
				manual_bard_duration_bonus = tonumber(args[1])
				log('Set Brd song+ bonus to ' .. tostring(manual_bard_duration_bonus) .. '.')
			elseif args[1]:lower() == 'add' and type(tostring(args[2])) == 'string' and type(tonumber(args[3])) == 'number' then
				settings.Bards[args[2]:lower()] = default_bard_settings
				settings.Bards[args[2]:lower()]['song_bonus']['all_songs'] = tonumber(args[3])
				settings:save('all')
				log('Added ' .. tostring(args[2]:lower()) .. ' as a known bard with +'.. tonumber(args[3]) .. ' to all songs.')
				notice('For advanced users: You may go into the settings file for your character and edit the bards in a more detailed manner.')
			elseif args[1]:lower() == 'delete' and type(tostring(args[2])) == 'string' then
				settings.Bards[tostring(args[2]):lower()] = nil
				settings:save('all')
				log('Removed ' .. tostring(args[2]:lower()) .. ' as a known bard!')
			end
		elseif command:lower() == 'cor' then
			if type(tonumber(args[1])) == 'number' then
				manual_COR_bonus = tonumber(args[1])
				log('Set Phantom Roll bonus to ' .. tostring(manual_COR_bonus) .. '.')
			elseif args[1]:lower() == 'add' and type(tostring(args[2])) == 'string' and type(tonumber(args[3])) == 'number' then
				settings.Cors[args[2]:lower()] = tonumber(args[3])
				settings:save('all')
				log('Added ' .. tostring(args[2]:lower()) .. ' as a known COR with +' .. tonumber(args[3]) .. ' Phantom Roll !')
			elseif args[1]:lower() == 'delete' and type(tostring(args[2])) == 'string' then
				settings.Cors[tostring(args[2]):lower()] = nil
				settings:save('all')
				log('Removed ' .. tostring(args[2]:lower()) .. ' as a known COR!')
			end
		elseif command:lower() == 'geo' then
			if type(tonumber(args[1])) == 'number' then
				manual_GEO_bonus = tonumber(args[1])
				log('Set Geomancy bonus to ' .. tostring(manual_GEO_bonus) .. '.')
			elseif args[1]:lower() == 'add' and type(tostring(args[2])) == 'string' and type(tonumber(args[3])) == 'number' then
				settings.Geos[args[2]:lower()] = args[3]
				settings:save('all')
				log('Added ' .. tostring(args[2]:lower()) .. ' as a known GEO with +' .. tonumber(args[3]) .. ' Geomancy!')
			elseif args[1]:lower() == 'delete' and type(tostring(args[2])) == 'string' then
				settings.Geos[tostring(args[2]):lower()] = nil
				settings:save('all')
				log('Removed ' .. tostring(args[2]:lower()) .. ' as a known GEO!')
			end
		elseif command:lower() == 'dnc' then
			if dancer_main then
				dancer_main = false
			else
				dancer_main = true
			end
			log('toggled DNC buff from main job to -> ' .. tostring(dancer_main) .. '.')
		elseif command:lower() == 'show' then
			
			if args[1]:lower() == 'haste' then
				if settings.player.show_total_haste == false then
					settings.player.show_total_haste = true
				elseif settings.player.show_total_haste then
					settings.player.show_total_haste = false
				end
				log('Show Haste = '..tostring(settings.player.show_total_haste))
			elseif args[1]:lower() == 'logo' then
				if settings.player.show_logo == false then
					settings.player.show_logo = true
				elseif settings.player.show_logo then
					settings.player.show_logo = false
				end
				log('Show Logo = '..tostring(settings.player.show_logo))
			elseif args[1]:lower() == 'eva' then
				if settings.player.show_Evasion == false then
					settings.player.show_Evasion = true
				elseif settings.player.show_Evasion then
					settings.player.show_Evasion = false
				end
				log('Show Evasion calculations = '..tostring(settings.player.show_Evasion))	
			elseif args[1]:lower() == 'def' then
				if settings.player.show_Defence == false then
					settings.player.show_Defence = true
				elseif settings.player.show_Defence then
					settings.player.show_Defence = false
				end
				log('Show Defence calculations = '..tostring(settings.player.show_Defence))		
			elseif args[1]:lower() == 'att' then
				if settings.player.show_att_Stuff == false then
					settings.player.show_att_Stuff = true
				elseif settings.player.show_att_Stuff then
					settings.player.show_att_Stuff = false
				end
				log('Show Attack calculations = '..tostring(settings.player.show_att_Stuff))	
			elseif args[1]:lower() == 'tp' then
				if settings.player.show_tp_Stuff == false then
					settings.player.show_tp_Stuff = true
				elseif settings.player.show_tp_Stuff then
					settings.player.show_tp_Stuff = false
				end
				log('Show Tp calculations = '..tostring(settings.player.show_tp_Stuff))
			elseif args[1]:lower() == 'stp' then
				if settings.player.show_STP== false then
					settings.player.show_STP = true
				elseif settings.player.show_STP then
					settings.player.show_STP = false
				end
				log('Show Store TP = '..tostring(settings.player.show_STP))
			elseif args[1]:lower() == 'dw' then
				if settings.player.show_DW_Stuff == false then
					settings.player.show_DW_Stuff = true
				elseif settings.player.show_DW_Stuff then
					settings.player.show_DW_Stuff = false
				end
				log('Show Duel Wield calculations = '..tostring(settings.player.show_DW_Stuff))
			elseif args[1]:lower() == 'ma' then
				if settings.player.show_MA_Stuff == false then
					settings.player.show_MA_Stuff = true
				elseif settings.player.show_MA_Stuff then
					settings.player.show_MA_Stuff = false
				end
				log('Show Martial Arts calculations = '..tostring(settings.player.show_MA_Stuff))
			elseif args[1]:lower() == 'acc' then
				if settings.player.show_acc_Stuff == false then
					settings.player.show_acc_Stuff = true
				elseif settings.player.show_acc_Stuff then
					settings.player.show_acc_Stuff = false
				end
				-- log('Currently dissabled, in testing.')
				log('Show Total Acc = '..tostring(settings.player.show_acc_Stuff))
			elseif args[1]:lower() == 'dt' then
				if settings.player.show_dt_Stuff == false then
					settings.player.show_dt_Stuff = true
				elseif settings.player.show_dt_Stuff then
					settings.player.show_dt_Stuff = false
				end
				-- log('Currently dissabled, in testing.')
				log('Show Defence = '..tostring(settings.player.show_dt_Stuff))
			elseif args[1]:lower() == 'cor' then
				if settings.player.show_COR_messages == false then
					settings.player.show_COR_messages = true
				elseif settings.player.show_COR_messages then
					settings.player.show_COR_messages = false
				end
				log('Cor Chat log messages set to '..tostring(settings.player.show_COR_messages))
			elseif args[1]:lower() == 'all' then
				settings.player.show_logo = true
				settings.player.show_total_haste = true
				settings.player.show_tp_Stuff = true
				settings.player.show_acc_Stuff = true
				settings.player.show_dt_Stuff = true
				settings.player.show_att_Stuff = true
				settings.player.show_Evasion = true
				settings.player.show_Defence = true
				settings.player.show_STP = true
				settings.player.show_DW_Stuff = true
				settings.player.show_MA_Stuff = true
				log('All display settings set to true to shall all the display.')
			end
			settings:save('all')
		elseif command:lower() == 'theme' then

			if windower.dir_exists(windower.addon_path..'textures/'..args[1]:lower()) then
				if not files.exists('textures\\'..args[1]:lower() ..'\\blue.png') then
					error('textures\\'..args[1]:lower()..' is missing blue.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\dark-blue.png') then
					error('textures\\'..args[1]:lower()..' is missing dark-blue.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\green.png') then
					error('textures\\'..args[1]:lower()..' is missing green.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\red.png') then
					error('textures\\'..args[1]:lower()..' is missing red.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\grey.png') then
					error('textures\\'..args[1]:lower()..' is missing grey.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\light-green.png') then
					error('textures\\'..args[1]:lower()..' is missing light-green.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\orange.png') then
					error('textures\\'..args[1]:lower()..' is missing orange.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\pink.png') then
					error('textures\\'..args[1]:lower()..' is missing pink.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\purple.png') then
					error('textures\\'..args[1]:lower()..' is missing purple.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\yellow.png') then
					error('textures\\'..args[1]:lower()..' is missing yellow.png.')
				elseif not files.exists('textures\\'..args[1]:lower() ..'\\logo.png') then
					error('textures\\'..args[1]:lower()..' is missing logo.png.')
				else
				
					settings.image_folder_name = args[1]:lower()
					settings:save('all')
					log('Image folder path changed to  --> textures/'..args[1]:lower())
					log('Refreshing display.')
					
					sections.logo:delete()
					
					for k, v in pairs(sections.block) do
						sections.block[k]:delete()
					end
					
				end
			else
				error('the folder '..args[1]:lower()..' does not exist.')
			end
		elseif command:lower() == 'test' then
			
			-- table.vprint(player['merits']['aggressive_aim'])
			-- for skill_name, value in pairs(player_base_skills) do
				-- if skill_name:contains('eva') then
					-- print(skill_name, value)
				-- end
			-- end
			-- if player_base_skills['evasion'] then print(player_base_skills['evasion']) end
			-- local current_equip = check_equipped()
			 
			 
			 -- for k,v in pairs(current_equip) do
			 -- --25613
				-- if v.id == 25613 then
					-- local ext = Extdata.decode(k)
					-- print(ext.type)
				-- end
				-- if v.id == 25449 then
					-- local ext = Extdata.decode(k)
					-- print(ext.type)
				-- end
			 -- end
			 
			 
			-- local Gear_info = get_equip_stats(current_equip)
			-- print(Gear_info['Evasion skill'])
			--settings.Cors['ewellina'] = nil
			-- table.vprint(_ExtraData.player.buff_details)
			--table.vprint(windower.ffxi.get_mob_by_target('t'))
			--table.vprint(member_table)
			--table.vprint(player_base_skills)
			-- local stat_table = get_equip_stats(check_equipped())
			-- local player_Acc = get_player_acc(stat_table)
			-- table.vprint(stat_table.range)
			-- log(player_Acc.agi.. '  '..stat_table["Throwing skill"] .. '  '..stat_table['Ranged Accuracy'])
			-- table.vprint( player_Acc )
			-- log(player_base_skills['hand_to_hand'])
			-- player_base_skills = player.skills
			-- get_player_skill_in_gear(check_equipped())
			--player.stats = get_packet_data_base_stats()
			-- get_packet_data()
			-- Total_acc = get_player_acc(check_equipped())
			-- log(player.stats.DEX .. ' '.. Total_acc.dex .. ' '.. Total_acc.main.. ' '.. Total_acc.sub)
			-- log(player.stats.AGI .. ' '.. Total_acc.agi .. ' '.. Total_acc.range.. ' '.. Total_acc.ammo)
		elseif command:lower() == 'debug' then
			if debug_mode == false then
				debug_mode = true
			else
				debug_mode = false
			end
			log('Toggled Debug Mode to '..tostring(debug_mode))
		elseif command:lower() == 'help' then
			
			local chat_purple = string.char(0x1F, 200)
			local chat_grey = string.char(0x1F, 160)
			local chat_red = string.char(0x1F, 167)
			local chat_white = string.char(0x1F, 001)
			local chat_green = string.char(0x1F, 214)
			local chat_yellow = string.char(0x1F, 036)
			local chat_d_blue = string.char(0x1F, 207)
			local chat_pink = string.char(0x1E, 5)
			local chat_l_blue = string.char(0x1E, 6)
			
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_white.. 	'                         --------------------------' )
			windower.add_to_chat(6, chat_d_blue.. 	'                         Welcome to GearInfo help!' )
			windower.add_to_chat(6, chat_white.. 	'                         --------------------------' )
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_d_blue.. 	'Commands available:' )
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_l_blue.. 	'\'\/\/gi parse\'' .. chat_white .. '  --  Will reload your inventory to file (eg. after changing unity rank).')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi rank\'' .. chat_white .. '   --  Shows current unity rank setting.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi rank #\'' .. chat_white .. '  --  Change # to your unity rank, anything under 5 is set to 5.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi stp #\'' .. chat_white .. '  --  Change # to + or - \'Store TP\' manually. eg. ' .. chat_yellow .. ' \/\/gs stp +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs stp 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dw #\'' .. chat_white .. '  --  Change # to + or - \'Dual Wield\' manually. eg. ' .. chat_yellow .. ' \/\/gs dw +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs dw 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi ghaste #\'' .. chat_white .. '  --  Change # to + or - \'Haste\' manually. eg. ' .. chat_yellow .. ' \/\/gs ghaste +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs ghaste 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi mhaste #\'' .. chat_white .. '  --  Change # to + or - \'Haste\' manually. eg. ' .. chat_yellow .. ' \/\/gs mhaste +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs mhaste 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi jahaste #\'' .. chat_white .. '  --  Change # to + or - \'Haste\' manually. eg. ' .. chat_yellow .. ' \/\/gs jahaste +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs jahaste 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dwn #\'' .. chat_white .. '  --  Change # to + or - \'DW needed\'. eg. ' .. chat_yellow .. ' \/\/gs dwn +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs dwn 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi save/s wstp\'' .. chat_white .. '  --  saves current tp/hit into new line.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi delete/d wstp\'' .. chat_white .. '  --  deletes previously created line.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi brd #\'' .. chat_white .. '  --  Change # to equal your parties BRD max March Bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          add \'name\' \'bonus\'' .. chat_white .. '  --  Save the bard with name and Bonus for future use.')
			windower.add_to_chat(6, chat_yellow..	'eg. \/\/gi brd add bob 7' .. chat_white .. '  --  This will add bob to the list with +7 March Bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          delete \'name\'' .. chat_white .. '  --  Delete a bard from the list.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi cor #\'' .. chat_white .. '  --  Change # to equal your parties COR "Phantom Roll +#" bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          add \'name\' \'bonus\'' .. chat_white .. '  --  Save the COR with name and Bonus for future use.')
			windower.add_to_chat(6, chat_yellow..	'eg. \/\/gi cor add bob 3' .. chat_white .. '  --  This will add bob to the list with Phantom Roll +3. eg "Merirosvo Ring"')
			windower.add_to_chat(6, chat_l_blue..	'          delete \'name\'' .. chat_white .. '  --  Delete a COR from the list.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi geo #\'' .. chat_white .. '  --  Change # to equal your parties GEO "Geomancy +#" bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          add \'name\' \'bonus\'' .. chat_white .. '  --  Save the GEO with name and Bonus for future use.')
			windower.add_to_chat(6, chat_yellow..	'eg. \/\/gi geo add bob 5' .. chat_white .. '  --  This will add bob to the list with Geomancy +5. eg "Duna"')
			windower.add_to_chat(6, chat_l_blue..	'          delete \'name\'' .. chat_white .. '  --  Delete a GEO from the list.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dnc\'' .. chat_white .. '  --  Toggle if your party is getting Haste Samba from a main DNC or not.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi hide\'' .. chat_white .. '  --  Hide all display (not a toggle).')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi show\'' .. chat_white .. '  --  add subcommand.')
			windower.add_to_chat(6, chat_l_blue..	'              \'haste\'' .. chat_white .. '  --  Toggle hide Total haste.')
			windower.add_to_chat(6, chat_l_blue..	'              \'tp\'' .. chat_white .. '  --  Toggle hide TP Calculator.')
			windower.add_to_chat(6, chat_l_blue..	'              \'acc\'' .. chat_white .. '  --  Toggle hide Accuracy Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'eva\'' .. chat_white .. '  --  Toggle hide Evasion Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'def\'' .. chat_white .. '  --  Toggle hide Defence Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'att\'' .. chat_white .. '  --  Toggle hide Attack Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'stp\'' .. chat_white .. '  --  Toggle hide Store TP.')
			windower.add_to_chat(6, chat_l_blue..	'              \'dw\'' .. chat_white .. '  --  Toggle hide DW Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'ma\'' .. chat_white .. '  --  Toggle hide MA Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'dt\'' .. chat_white .. '  --  Toggle hide DT Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'              \'all\'' .. chat_white .. '  --  Toggle all display options on.')
			windower.add_to_chat(6, chat_l_blue..	'              \'cor\'' .. chat_white .. '  --  Toggle rollTracker chat display.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi help\'' .. chat_white .. '  --  This command or any mistakes will show this menu.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi updategs'.. chat_white ..' or ' .. chat_l_blue .. 'ugs\'' .. chat_white .. '  --  toggle Send info to GearSwap for use, Can add true / false')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi update\'' .. chat_white .. '  --  forces 1 update to gearswap')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi debug\'' .. chat_white .. '  --  toggle debug mode')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi r'.. chat_white ..' or ' .. chat_l_blue .. 'reload\'' .. chat_white .. '  --  Reload addon GearInfo.')
			windower.add_to_chat(6, ' ')

		-- elseif command:lower() == 'test' then	
			-- check_none_existant_ids()
		else
			windower.send_command('gi help')
		end
	else
		windower.send_command('gi help')
	end
end)

function save_table_to_file(item_table)

	local new_item = item_table
	
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w')
	f:write('return ' .. T(new_item):tovstring())
    f:close()
	notice('File Saved')
end

function get_equipment_from_file()

	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

function parse_inventory()
	
	local items_in_bag = T{}
	local full_gear_table_rw = T{}
	for k,v in pairs(res.bags) do
		for i,n in pairs(windower.ffxi.get_items(v.id)) do
			items_in_bag[#items_in_bag +1] = n
		end
	end
	for k,v in pairs(items_in_bag) do
		if v ~= nil and type(v) == 'table' then
			if v.id ~= 0 then
				local this_item = find_all_values(v)
				if this_item ~= nil then
					full_gear_table_rw[#full_gear_table_rw +1] = this_item
				end
			end
		end	
	end
	
	full_gear_table_from_file = full_gear_table_rw
	save_table_to_file(full_gear_table_from_file)
end

function parse_new_single_item(item)

	if item ~= nil and type(item) == 'table' then
		if item.id ~= 0 then
			local this_item = find_all_values(item)
			if this_item ~= nil then
				full_gear_table_from_file[#full_gear_table_from_file +1] = this_item
			end
			
			save_table_to_file(full_gear_table_from_file)
			
			return this_item
		end
	end
end

function check_equipped()

	local new_gear_table = T{}
	local local_gear_table = T{}
	local items_equipped = windower.ffxi.get_items().equipment
	
	local default_slot = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist', 'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
	default_slot[0]= 'main'	
	
	if items_equipped then
		for id,name in pairs(default_slot) do
			items_equipped[name] = {
                    slot = items_equipped[name],
                    bag = items_equipped[name..'_bag']
                    }
                    items_equipped[name..'_bag'] = nil
			
		end
	end
	
	for k,v in pairs(items_equipped) do
		if v.slot == 0 then
			new_gear_table[k] = {count = 0 ,status = 0,id = 0,slot = 0,bazaar = 0,extdata = ''}
		else
			new_gear_table[k] = windower.ffxi.get_items(v.bag, v.slot)
		end
	end

	local sloted_items = new_gear_table
	for k,v in pairs(new_gear_table) do
		if v.count > 0 then
			local item_has_augment = Extdata.decode(v)
			local no_match = true
			local temp_item = new_gear_table[k]
			
			for x,y in pairs(full_gear_table_from_file) do
				if v.id == y.id then
					if type(item_has_augment.augments) == 'table' and table.length(item_has_augment.augments) > 0 then
						for i, j in pairs(y) do
							local int = 0
							if i == 'augments' then
								for a,b in pairs(item_has_augment.augments) do
									if j[a]:contains(b) then
										int = int +1
									end
								end
								if int == table.length(item_has_augment.augments) then
									y.augments = item_has_augment.augments
									local_gear_table[#local_gear_table +1] = y
									sloted_items[k] = local_gear_table[#local_gear_table]
									no_match = false
									break
								end
							end
						end
					else
                        no_match = false
						local_gear_table[#local_gear_table+1] = y
						sloted_items[k] = local_gear_table[#local_gear_table]
					end
				end	
			end

			if no_match == true then

				local_gear_table[#local_gear_table+1] = parse_new_single_item(temp_item)
				sloted_items[k] = local_gear_table[#local_gear_table]
				no_match = false
			end			
		else
			local_gear_table[#local_gear_table+1] = {id = 0, en = '', category = '', delay = 0, haste = 0, dual_wield = 0, stp = 0, augments = '' }
			sloted_items[k] = local_gear_table[#local_gear_table]
		end
	end
	
	--log(table.length(local_gear_table) .. ' ' .. table.length(sloted_items))
	
	player.equipment = sloted_items
	
	return sloted_items
end

--options_load()
			
-- windower.register_event('job change',function()
	-- player = windower.ffxi.get_player()
	-- -- get_player_skill_in_gear(check_equipped())
	-- -- player.stats = get_packet_data_base_stats()
    -- --initialize(text_box,settings)
-- end)

function incoming_chunk(id,data,modified,injected,blocked)
        
    if not injected and parse.i[id] then
        parse.i[id](data,blocked)
    end
end

function outgoing_chunk(id,original,data,injected,blocked)
    
    if not blocked and parse.o[id] then
        parse.o[id](data,injected)
    end
end

--table.vprint(windower.get_windower_settings())

function update()
	local inform = {}
						
	if windower.ffxi.get_info().logged_in == false then
		return
	else
		
		if manual_hide == true then
			--text_box:hide()
		else
			-- if windower.ffxi.get_info().zone == 0 then
				-- text_box:hide()
			-- else
				-- text_box:show()
			-- end
		end
	
		local white = '(220,220,220)'
		local blue = '(150,150,235)'
		local red = '(255,0,0)'
		
		----------------------------------------------------- Haste Stuff ------------------------------------------
		local current_equip = check_equipped()
		Gear_info = get_equip_stats(current_equip)
		Total_haste = get_total_haste()
		
		if settings.player.show_logo == true then
			if not sections.logo then sections.logo = ImageBlock.New(1,'logo','') end
		else
			if sections.logo then sections.logo:delete() end
		end
		
		if settings.player.show_total_haste ==  true then
			if not sections.block[1] then sections.block[1] = ImageBlock.New(2,'block','red', 'Gear.H', 00) end
			if not sections.block[2] then sections.block[2] = ImageBlock.New(3,'block','red', 'Magic.H', 00) end
			if not sections.block[3] then sections.block[3] = ImageBlock.New(4,'block','red', 'JA.H', 00) end
			if not sections.block[4] then sections.block[4] = ImageBlock.New(5,'block','red', 'Total.H', 00) end
			
			windower.text.set_text(sections.block[1].text[2].name, (Gear_info['Haste'] + Buffs_inform['g_haste'] ))
			if (Gear_info['Haste'] + Buffs_inform['g_haste'] ) > 256 then
				windower.text.set_color(sections.block[1].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[1].text[2].name, 255, 255, 255, 255)
			end
			
			windower.text.set_text(sections.block[2].text[2].name,  (Buffs_inform['ma_haste'] + manual_mhaste))
			if (Buffs_inform['ma_haste'] + manual_mhaste) > 448 then
				windower.text.set_color(sections.block[2].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[2].text[2].name, 255, 255, 255, 255)
			end
			
			windower.text.set_text(sections.block[3].text[2].name,  (Buffs_inform['ja_haste'] + manual_jahaste))
			if (Buffs_inform['ja_haste'] + manual_jahaste) > 256 then
				windower.text.set_color(sections.block[3].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[3].text[2].name, 255, 255, 255, 255)
			end
			
			windower.text.set_text(sections.block[4].text[2].name,  Total_haste)
			if Total_haste > 820 then
				windower.text.set_color(sections.block[4].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[4].text[2].name, 255, 255, 255, 255)
			end
		else
			if sections.block[1] then sections.block[1]:delete() end
			if sections.block[2] then sections.block[2]:delete() end
			if sections.block[3] then sections.block[3]:delete() end
			if sections.block[4] then sections.block[4]:delete() end
		end
		
		-------------------------------------------------------------- DT stuff ---------------------------------------------------------------
		
		if settings.player.show_dt_Stuff == true then
			if not sections.block[5]  then sections.block[5] = ImageBlock.New(6,'block','purple', 'DT', 00) end
			if not sections.block[6]  then sections.block[6] = ImageBlock.New(7,'block','purple', 'PDT', 00) end
			if not sections.block[7]  then sections.block[7] = ImageBlock.New(8,'block','purple', 'MDT', 00) end
			if not sections.block[8]  then sections.block[8] = ImageBlock.New(9,'block','purple', 'BDT', 00) end
			
			local dt = (Gear_info['DT']*(-1))
			if dt == -0 then dt = 0 end
			windower.text.set_text(sections.block[5].text[2].name, dt)
			if Gear_info['DT'] < (-51) then
				windower.text.set_color(sections.block[5].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[5].text[2].name, 255, 255, 255, 255)
			end
			
			if Gear_info['PDT2'] < 0 then
				local combined_pdt = (Gear_info['PDT'] + Gear_info['DT'] + Gear_info['PDT2']) * (-1)
				if (-50 + Gear_info['PDT2']) < -87.6 then 
					cap = -87.6 
				else 
					cap = (-50 + Gear_info['PDT2']) 
				end
				if combined_pdt == -0 then combined_pdt = 0 end
				windower.text.set_text(sections.block[6].text[2].name, combined_pdt)
				if (Gear_info['PDT'] + Gear_info['DT'] + Gear_info['PDT2']) < cap then
					windower.text.set_color(sections.block[6].text[2].name, 255, 255, 0, 0)
				else
					windower.text.set_color(sections.block[6].text[2].name, 255, 255, 255, 255)
				end
			elseif Gear_info['PDT2'] == 0 then
				local pdt = (Gear_info['PDT'] + Gear_info['DT'])*(-1)
				if pdt == -0 then pdt = 0 end
				windower.text.set_text(sections.block[6].text[2].name, pdt)
				if (Gear_info['PDT']+ Gear_info['DT']) < -51 then
					windower.text.set_color(sections.block[6].text[2].name, 255, 255, 0, 0)
				else
					windower.text.set_color(sections.block[6].text[2].name, 255, 255, 255, 255)
				end
			end
			
			if Gear_info['MDT2'] < 0 then
				local combined_mdt = (Gear_info['MDT'] + Gear_info['DT'] + Gear_info['MDT2'])*(-1)
				local cap = 0
				if (-50 + Gear_info['MDT2']) < -87.6 then 
					cap = -87.6 
				else 
					cap = (-50 + Gear_info['MDT2']) 
				end
				if combined_mdt == -0 then combined_mdt = 0 end
				windower.text.set_text(sections.block[7].text[2].name, combined_mdt)
				if (Gear_info['MDT'] + Gear_info['DT'] + Gear_info['MDT2']) < cap then
					windower.text.set_color(sections.block[7].text[2].name, 255, 255, 0, 0)
				else
					windower.text.set_color(sections.block[7].text[2].name, 255, 255, 255, 255)
				end
			elseif Gear_info['MDT2'] == 0 then
				local mdt = (Gear_info['MDT'] + Gear_info['DT'])*(-1)
				if mdt == -0 then mdt = 0 end
				windower.text.set_text(sections.block[7].text[2].name, mdt)
				if (Gear_info['MDT']+ Gear_info['DT']) < -51 then
					windower.text.set_color(sections.block[7].text[2].name, 255, 255, 0, 0)
				else
					windower.text.set_color(sections.block[7].text[2].name, 255, 255, 255, 255)
				end
			end
			
			local bdt = (Gear_info['BDT'] + Gear_info['DT'])*(-1)
			if bdt == -0 then bdt = 0 end
			windower.text.set_text(sections.block[8].text[2].name, bdt)
			if (Gear_info['BDT'] + Gear_info['DT']) < -51 then
				windower.text.set_color(sections.block[8].text[2].name, 255, 255, 0, 0)
			else
				windower.text.set_color(sections.block[8].text[2].name, 255, 255, 255, 255)
			end
			
		else
		
			if sections.block[5] then sections.block[5]:delete() end
			if sections.block[6] then sections.block[6]:delete() end
			if sections.block[7] then sections.block[7]:delete() end
			if sections.block[8] then sections.block[8]:delete() end
			
		end
		
		----------------------------------------------- TP calc Stuff ------------------------------------------
		
		if settings.player.show_tp_Stuff == true then 
			Gear_TP = get_tp_per_hit()
			if not sections.block[9] then sections.block[9] = ImageBlock.New(10,'block','yellow', 'TP/h', 00) end
			if not sections.block[10]  then sections.block[10] = ImageBlock.New(11,'block','yellow', 'to WS', 00) end
			windower.text.set_text(sections.block[9].text[2].name, Gear_TP.tp_per_hit_melee)
			windower.text.set_text(sections.block[10].text[2].name, (math.ceil(10000/Gear_TP.tp_per_hit_melee)/10))
			
			if Gear_TP.tp_per_hit_range > 0 then
				if not sections.block[16] then sections.block[16] = ImageBlock.New(17,'block','green', 'R.TP/h', 00) end
				if not sections.block[17] then sections.block[17] = ImageBlock.New(18,'block','green', 'R.to WS', 00) end
				windower.text.set_text(sections.block[16].text[2].name,  Gear_TP.tp_per_hit_range )
				windower.text.set_text(sections.block[17].text[2].name,  (math.ceil(10000/Gear_TP.tp_per_hit_range)/10) )
			else
				if sections.block[16] then sections.block[16]:delete() end
				if sections.block[17] then sections.block[17]:delete() end
			end
			
			if WSTP > 0 then
				if not sections.block[11] then sections.block[11] = ImageBlock.New(12,'block','yellow', 'aft WS', 00) end
				windower.text.set_text(sections.block[10].text[1].name, 'for WS' )
				windower.text.set_text(sections.block[10].text[2].name, WSTP)
				windower.text.set_text(sections.block[9].text[2].name, (math.ceil((10000 - (WSTP *10))/Gear_TP.tp_per_hit_melee)/10) )
				if Gear_TP.tp_per_hit_range > 0 then
					if not sections.block[18] then sections.block[18] = ImageBlock.New(19,'block','green', 'R.Aft WS', 00) end
					windower.text.set_text(sections.block[17].text[1].name, 'R.for WS' )
					windower.text.set_text(sections.block[17].text[2].name, WSTP)
					windower.text.set_text(sections.block[16].text[2].name, (math.ceil((10000 - (WSTP *10))/Gear_TP.tp_per_hit_range)/10) )
				end
			else
				windower.text.set_text(sections.block[10].text[1].name, 'to WS' )
				if sections.block[11] then sections.block[11]:delete() end
				if sections.block[18] then sections.block[18]:delete() end
			end
		else
			if sections.block[9] then sections.block[9]:delete() end
			if sections.block[10] then sections.block[10]:delete() end
			if sections.block[11] then sections.block[11]:delete() end
			if sections.block[16] then sections.block[16]:delete() end
			if sections.block[17] then sections.block[17]:delete() end
			if sections.block[18] then sections.block[18]:delete() end
		end
		
		----------------------------------------------------- ACC Stuff ------------------------------------------
		
		if settings.player.show_acc_Stuff == true then
			local Total_acc = get_player_acc(Gear_info)
			if Total_acc.sub > 0 then
				if not sections.block[12] then
					sections.block[12] = ImageBlock.New(13,'block','yellow', 'Acc.1', 00)
				end
				if not sections.block[13] then
					sections.block[13] = ImageBlock.New(14,'block','yellow', 'Acc.2', 00)
				end
				windower.text.set_text(sections.block[12].text[2].name, Total_acc.main)
				windower.text.set_text(sections.block[13].text[2].name, Total_acc.sub)
			else
				if not sections.block[12] then
					sections.block[12] = ImageBlock.New(13,'block','yellow', 'Acc.', 00)
				end
				windower.text.set_text(sections.block[12].text[2].name, Total_acc.main)
				if sections.block[13] then sections.block[13]:delete() end
			end
			if Total_acc.range > 0 then
				if not sections.block[19] then
					sections.block[19] = ImageBlock.New(20,'block','green', 'R.Acc.', 00)
				end
				windower.text.set_text(sections.block[19].text[2].name, Total_acc.range)
			elseif Total_acc.range == 0 and Total_acc.ammo > 0 then
				if not sections.block[19] then
					sections.block[19] = ImageBlock.New(20,'block','green', 'R.Acc.', 00)
				end
				windower.text.set_text(sections.block[19].text[2].name, Total_acc.ammo)
			else
				if sections.block[19] then sections.block[19]:delete() end
			end
		else
			if sections.block[12] then sections.block[12]:delete() end
			if sections.block[13] then sections.block[13]:delete() end
			if sections.block[20] then sections.block[20]:delete() end
		end
		
		----------------------------------------------------- ATT Stuff ------------------------------------------
		
		if settings.player.show_att_Stuff == true then
			local Total_att = get_player_att(Gear_info)
			if Total_att.sub > 0 then
				if not sections.block[14] then
					sections.block[14] = ImageBlock.New(15,'block','yellow', 'Att.1', 00)
				end
				if not sections.block[15] then
					sections.block[15] = ImageBlock.New(16,'block','yellow', 'Att.2', 00)
				end
				windower.text.set_text(sections.block[14].text[2].name, Total_att.main)
				windower.text.set_text(sections.block[15].text[2].name, Total_att.sub)
			else
				if not sections.block[14] then
					sections.block[14] = ImageBlock.New(15,'block','yellow', 'Att.', 00)
				end
				windower.text.set_text(sections.block[14].text[2].name, Total_att.main)
				if sections.block[15] then sections.block[15]:delete() end
			end
			if Total_att.range > 0 then
				if not sections.block[21] then
					sections.block[21] = ImageBlock.New(22,'block','green', 'R.Att.', 00)
				end
				windower.text.set_text(sections.block[21].text[2].name, Total_att.range)
			elseif Total_att.range == 0 and Total_att.ammo > 0 then
				if not sections.block[21] then
					sections.block[21] = ImageBlock.New(22,'block','green', 'R.Att.', 00)
				end
				windower.text.set_text(sections.block[21].text[2].name, Total_att.ammo)
			else
				if sections.block[21] then sections.block[21]:delete() end
			end
		else
			if sections.block[14] then sections.block[14]:delete() end
			if sections.block[15] then sections.block[15]:delete() end
			if sections.block[21] then sections.block[21]:delete() end
		end
		
		------------------------------------------- Evasion ------------------------------------------------------
		
		local Total_eva = get_player_evasion(Gear_info)
		if settings.player.show_Evasion == true then
			if not sections.block[22] then sections.block[22] = ImageBlock.New(23,'block','yellow', 'Eva.', '') end
			windower.text.set_text(sections.block[22].text[2].name, tostring(Total_eva))
		else
			if sections.block[22] then sections.block[22]:delete() end
		end
		
		------------------------------------------- Defence ------------------------------------------------------
		
		local Total_def = get_player_defence(Gear_info)
		if settings.player.show_Defence == true then
			if not sections.block[23] then sections.block[23] = ImageBlock.New(24,'block','yellow', 'Def.', '') end
			windower.text.set_text(sections.block[23].text[2].name, tostring(Total_def))
		else
			if sections.block[23] then sections.block[23]:delete() end
		end
		
		----------------------------------------------------------- DW stuff ----------------------------------------------
		DW_needed = dual_wield_needed()
		if settings.player.show_DW_Stuff == true then
			
			if player.equipment.sub.category == 'Weapon' then 
				if player.equipment.sub.damage then
					DW = true
					
					if not sections.block[24] then sections.block[24] = ImageBlock.New(25,'block','blue', 'DW', 00) end
					if not sections.block[25] then sections.block[25] = ImageBlock.New(26,'block','blue', 'Needed', 00) end
					
					windower.text.set_text(sections.block[24].text[2].name, Gear_info['Dual Wield'])
					windower.text.set_text(sections.block[25].text[2].name, (DW_needed + manual_dw_needed))
					if (DW_needed + manual_dw_needed) < 0 then
						windower.text.set_color(sections.block[25].text[2].name, 255, 255, 0, 0)
					else
						windower.text.set_color(sections.block[25].text[2].name, 255, 255, 255, 255)
					end
				else
					if sections.block[24] then sections.block[24]:delete() end
					if sections.block[25] then sections.block[25]:delete() end
				end
			else
				if sections.block[24] then sections.block[24]:delete() end
				if sections.block[25] then sections.block[25]:delete() end
			end
		else
			if sections.block[24] then sections.block[24]:delete() end
			if sections.block[25] then sections.block[25]:delete() end
		end
		
		----------------------------------------------------------- MA stuff ----------------------------------------------
		if settings.player.show_MA_Stuff == true then
			local total_ma , MA_needed = martial_arts_needed()
			
			if player.equipment.main.skill == "Hand-to-Hand" or player.equipment.main.en == '' then
			
				if not sections.block[26] then sections.block[26] = ImageBlock.New(27,'block','pink', 'MA', 00) end
				if not sections.block[27] then sections.block[27] = ImageBlock.New(28,'block','pink', 'Needed', 00) end
				
				windower.text.set_text(sections.block[26].text[2].name, total_ma)
				windower.text.set_text(sections.block[27].text[2].name, MA_needed)
				if (MA_needed) < 0 then
					windower.text.set_color(sections.block[27].text[2].name, 255, 255, 0, 0)
				else
					windower.text.set_color(sections.block[27].text[2].name, 255, 255, 255, 255)
				end
			else
				if sections.block[26] then sections.block[26]:delete() end
				if sections.block[27] then sections.block[27]:delete() end
			end
		else
			if sections.block[26] then sections.block[26]:delete() end
			if sections.block[27] then sections.block[27]:delete() end
		end
			
		----------------------------------------------------------- Store TP stuff ----------------------------------------------
		if settings.player.show_STP == true then
			if not sections.block[28] then sections.block[28] = ImageBlock.New(29,'block','orange', 'STP', 00) end
			windower.text.set_text(sections.block[28].text[2].name, Gear_info['Store TP'] + Buffs_inform['Store TP'])
		else
			if sections.block[28] then sections.block[28]:delete() end
		end		

		-------------------------------------------------------------- update GS ---------------------------------------------------------------
		if not sections.block[29] then sections.block[29] = ImageBlock.New(30,'block','grey', 'UGS', '') end
		if settings.player.update_gs == true then
			windower.text.set_text(sections.block[29].text[2].name, tostring(settings.player.update_gs))
			windower.text.set_color(sections.block[29].text[2].name, 255, 255, 255, 255)
		else
			windower.text.set_text(sections.block[29].text[2].name, tostring(settings.player.update_gs))
			windower.text.set_color(sections.block[29].text[2].name, 255, 255, 0, 0)
		end
			
		-- if old_inform ~= inform then
			-- --text_box:update(inform)
			-- old_inform = inform
		-- end
		--log(DW_needed)
		if settings.player.update_gs == true then
			local new_dw = DW_needed + manual_dw_needed
			local total_ma , MA_needed = martial_arts_needed()
			local MA = false
			
			if player.equipment.main.skill == "Hand-to-Hand" or player.equipment.main.en == '' then
				MA = true
			end
			update_gs(DW, new_dw, Total_haste, MA, MA_needed)
			old_DW_needed = new_dw
		end
	end
	--print('updating')
end


loop_count = 0
frame_count = 0
windower.register_event('prerender',function()
	if frame_count%2 == 0 and windower.ffxi.get_info().logged_in then
		centre_all_text()
	end
    if frame_count%15 == 0 and windower.ffxi.get_info().logged_in then
        local temp_equip = player.equipment
        local temp_stats = player.stats
		local temp_pos = player.position
        player = windower.ffxi.get_player()
        player.equipment = temp_equip
		-- get_player_skill_in_gear(check_equipped())
        player.stats = temp_stats
		player.position = temp_pos
		player.is_moving = check_player_movement(player)
		check_buffs()
		update_party()
		calculate_total_haste()
        update()
		loop_count = loop_count + 1
    end
    frame_count = frame_count + 1
end)

windower.register_event('incoming chunk',incoming_chunk)
windower.register_event('outgoing chunk',outgoing_chunk)

windower.register_event('incoming text', function(old, new, color)
    --Hides Battlemod
	if settings.player.show_COR_messages then
		if old:match("Roll.* The total.*") or old:match('.*Roll.*' .. string.char(0x81, 0xA8)) or old:match('.*uses Double.*The total') and color ~= 123 then
			return true
		end

		--Hides normal
		if old:match('.* receives the effect of .* Roll.') ~= nil then
			return true
		end

		--Hides Older Battlemod versions --Antiquated
		if old:match('%('..'%w+'..'%).* Roll ') then
			new = old
		end

		return new, color
	-- else
		-- return old, color
	end
end)

function update_gs(DW, Total_DW_needed, haste, MA, MA_needed)
	if DW == true then
		windower.send_command('gs c gearinfo '..Total_DW_needed .. ' ' .. haste ..' '.. tostring(player.is_moving)..' '..tostring(MA))
	elseif DW == false then
		if MA then
			windower.send_command('gs c gearinfo '.. tostring(DW).. ' ' .. haste ..' '.. tostring(player.is_moving)..' '..MA_needed)
		else
			windower.send_command('gs c gearinfo '..Total_DW_needed .. ' ' .. haste ..' '.. tostring(player.is_moving)..' '..tostring(MA))
		end
	end
end

windower.register_event('unload', function()

end)