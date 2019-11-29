--[[
Copyright © 2019, Icydeath
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of AutoPUP nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Icydeath BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.author = 'Icy'
_addon.name = 'AutoPUP'
_addon.commands = {'autopup','pup'}
_addon.version = '1.1.0.0'

-- 1.1.0.0: Auto deploy and auto activate added. Will now auto equip +3 oils before attempting to repair.

require('pack')
require('lists')
require('tables')
require('strings')
texts = require('texts')
config = require('config')

default = {
    man = L{'Light Maneuver','Fire Maneuver', 'Wind Maneuver'},
    active = true,
    text = {text = {size=10}},
	sets = T{
		['caitdd'] = {'Light Maneuver', 'Fire Maneuver', 'Dark Maneuver'},
		['caitdd_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Dark Maneuver'},
		
		['caittank'] = {'Light Maneuver', 'Fire Maneuver', 'Light Maneuver'},
		['caittank_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		
		['default'] = {'Light Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		['default_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		
		['dd'] = {'Light Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		['dd_overdrive'] = {'Light Maneuver','Fire Maneuver', 'Thunder Maneuver'},
		
		['ddtank'] = {'Light Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		['ddtank_overdrive'] = {'Light Maneuver','Fire Maneuver', 'Thunder Maneuver'},
		
		['turtle'] = {'Light Maneuver', 'Fire Maneuver', 'Water Maneuver'},
		['turtle_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Water Maneuver'},
		
		['mdttank'] = {'Light Maneuver', 'Fire Maneuver', 'Water Maneuver'},
		['mdttank_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		
		['sstank'] = {'Light Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		['sstank_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		
		['spamdd'] = {'Wind Maneuver', 'Wind Maneuver', 'Wind Maneuver'},
		['spamdd_overdrive'] = {'Wind Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		
		['ranger'] = {'Wind Maneuver', 'Wind Maneuver', 'Wind Maneuver'},
		['ranger_overdrive'] = {'Wind Maneuver', 'Fire Maneuver', 'Fire Maneuver'},
		
		['boneslayer'] = {'Light Maneuver', 'Fire Maneuver', 'Wind Maneuver'},
		['boneslayer_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		
		['whm'] = {'Light Maneuver', 'Light Maneuver', 'Dark Maneuver'},
		['whm_overdrive'] = {'Light Maneuver', 'Light Maneuver', 'Dark Maneuver'},
		
		['rdm'] = {'Light Maneuver', 'Dark Maneuver', 'Ice Maneuver'},
		['rdm_overdrive'] = {'Light Maneuver', 'Dark Maneuver', 'Ice Maneuver'},
		
		['blm'] = {'Light Maneuver', 'Dark Maneuver', 'Ice Maneuver'},
		['blm_overdrive'] = {'Light Maneuver', 'Dark Maneuver', 'Ice Maneuver'},
		
		['od'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
		['od_overdrive'] = {'Light Maneuver', 'Fire Maneuver', 'Thunder Maneuver'},
	},
	repair = true,
	repairhpp = 40,
	set = 'default',
	deploy = false,
	activate = false,
}
settings = config.load(default)

multiman = ""
multimanCnt = 0

buffs = {}

nexttime = os.clock()
del = 0


pup_buffs = T{
	[166] = {id=166,en="Overdrive"},
	[299] = {id=299,en="Overload"},
    [300] = {id=300,en="Fire Maneuver"},
    [301] = {id=301,en="Ice Maneuver"},
    [302] = {id=302,en="Wind Maneuver"},
    [303] = {id=303,en="Earth Maneuver"},
    [304] = {id=304,en="Thunder Maneuver"},
    [305] = {id=305,en="Water Maneuver"},
    [306] = {id=306,en="Light Maneuver"},
    [307] = {id=307,en="Dark Maneuver"},
}

--[[ these are here just for id referencing
pup_maneuvers = T{
    [135] = {id=135,en="Overdrive",recast_id=0},
    [136] = {id=136,en="Activate",recast_id=205},
    [137] = {id=137,en="Repair",recast_id=206},
    [138] = {id=138,en="Deploy",recast_id=207},
    [139] = {id=139,en="Deactivate",recast_id=208},
    [140] = {id=140,en="Retrieve",recast_id=209},
    [141] = {id=141,en="Fire Maneuver",recast_id=210},
    [142] = {id=142,en="Ice Maneuver",recast_id=210},
    [143] = {id=143,en="Wind Maneuver",recast_id=210},
    [144] = {id=144,en="Earth Maneuver",recast_id=210},
    [145] = {id=145,en="Thunder Maneuver",recast_id=210},
    [146] = {id=146,en="Water Maneuver",recast_id=210},
    [147] = {id=147,en="Light Maneuver",recast_id=210},
    [148] = {id=148,en="Dark Maneuver",recast_id=210},
	[309] = {id=309,en="Cooldown",recast_id=114},
    [310] = {id=310,en="Deus Ex Automata",recast_id=115},
} ]]

local display_box = function()
    return 'AutoPUP [O%s]\nSet [%s]\nMan 1 [%s]\nMan 2 [%s]\nMan 3 [%s]\nRepair [%s] <= [%s]\nActivate [%s]\nDeploy [%s]':format(actions and 'n' or 'ff', settings.set, settings.man[1], settings.man[2], settings.man[3], tostring(settings.repair), settings.repairhpp..'%', tostring(settings.activate), tostring(settings.deploy))
end

pup_status = texts.new(display_box(),settings.text,setting)
pup_status:show()

windower.register_event('prerender',function ()
    if not actions then return end
	
	local play = windower.ffxi.get_player()
	if not play or play.main_job ~= 'PUP' or play.status > 1 then return end
	
    local curtime = os.clock()
    if nexttime + del <= curtime then
        nexttime = curtime
        del = 2
		local abil_recasts = windower.ffxi.get_ability_recasts()
		
		-- Activate
		local pet = windower.ffxi.get_mob_by_target('pet')
		if pet == nil then 
			if settings.activate then
				if abil_recasts[205] == 0 then
					use_JA('/ja "Activate" <me>')
				elseif abil_recasts[115] == 0 then
					use_JA('/ja "Deus Ex Automata" <me>')
				end
			end
			return 
		end
		
		local petdistance = pet.distance:sqrt()
		-- Repair
		if pet and settings.repair and pet.hpp <= settings.repairhpp and petdistance < 23 then
			if abil_recasts[206] and abil_recasts[206] == 0 then
				windower.send_command("input /equip ammo 'Automat. Oil +3';wait .5;input /ja 'Repair' <me>")
				--use_JA('/ja "Repair" <me>')
				return
			end
		end
		
		buffs = play.buffs
		--windower.add_to_chat(207, dump(buffs))
		-- set overdrive maneuver set
		if table.contains(buffs, 166) and not settings.set:contains('_overdrive') then
			windower.send_command('pup set '..settings.set..'_overdrive')
			return
		end
		if not table.contains(buffs, 166) and settings.set:contains('_overdrive') then
			settings.set = settings.set:gsub('_overdrive', '')
			windower.send_command('pup set '..settings.set)
			return
		end
		
		--return if: sleep, petrified, stun, charm, amnesia, charm, sleep
        if table.contains(buffs, 2) or table.contains(buffs, 7) or table.contains(buffs, 10) or table.contains(buffs, 14) 
			or table.contains(buffs, 16) or table.contains(buffs, 17) or table.contains(buffs, 19) then return end
		
        if table.contains(buffs, 299) and petdistance < 25 then -- Overload
            if abil_recasts[114] and abil_recasts[114] == 0 then
                use_JA('/ja "Cooldown" <me>')
            end
            return
        end
		
		if abil_recasts[210] and abil_recasts[210] == 0 then
			for x = 1, #settings.man do
				local man = pup_buffs:with('en', settings.man[x])
				if man then
					if not table.contains(buffs, man.id) then
						use_JA('/ja "%s" <me>':format(man.en))
						break
					end
					
					if multiman == settings.man[x] and countNumOfManeuvers(man.id) < multimanCnt then
						use_JA('/ja "%s" <me>':format(man.en))
						break
					end
				else
					windower.add_to_chat(9, 'Unknown maneuver: $s':format(settings.man[x]))
				end
			end
			return
		end
		
		local target = windower.ffxi.get_mob_by_target('bt')
		if settings.deploy and pet.status == 0 and (target and target.hpp > 0) and abil_recasts[207] == 0 then
			use_PET('Deploy', '<bt>')
			return
		end
    end
end)

function countNumOfManeuvers(manBuffId)
	local count = 0
	for z = 1, #buffs do
		if buffs[z] == manBuffId then
			count = count + 1
		end
	end
	return count
end

windower.register_event('addon command', function(...)
    local commands = {...}
    commands[1] = commands[1] and commands[1]:lower()
    if not commands[1] then
        actions = not actions
	elseif commands[1] == 'help' then
		showhelp()
    elseif commands[1] == 'on' then
        actions = true
    elseif commands[1] == 'off' then
        actions = false
	elseif commands[1] == 'deploy' then
        if settings.deploy == true then
			settings.deploy = false
		else
			settings.deploy = true
		end
		windower.add_to_chat(8, 'AutoPUP: Deploy = '..tostring(settings.deploy))
	elseif commands[1] == 'activate' then
        if settings.activate == true then
			settings.activate = false
		else
			settings.activate = true
		end
		windower.add_to_chat(8, 'AutoPUP: Activate = '..tostring(settings.activate))
	elseif commands[1] == 'repair' then
        if settings.repair == true then
			settings.repair = false
		else
			settings.repair = true
		end
		windower.add_to_chat(8, 'AutoPUP: Repair = '..tostring(settings.repair))
	elseif commands[1] == 'repairhpp' then
		commands[2] = commands[2] and tonumber(commands[2])
        if commands[2] then
			settings.repairhpp = command[2]
		end
	elseif commands[1] == 'set' then
		if commands[2] then
			--print(dump(settings.sets))
			local newset = settings.sets[tostring(commands[2])]
			if newset then
				settings.set = tostring(commands[2])
				settings.man = newset
				setupMultiman(settings.man)
				windower.add_to_chat(8, 'AutoPUP: '..settings.set..' set loaded.')
			end
			
		end
    elseif commands[1] == 'man' then
        commands[2] = commands[2] and tonumber(commands[2])
        if commands[2] and commands[3] then
            commands[3] = windower.convert_auto_trans(commands[3])
            for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
            commands[3] = table.concat(commands, ' ', 3)
            
			local m = pup_buffs:with('en', commands[3])
            if m then
                settings.man[commands[2]] = m.en
                windower.add_to_chat(8, 'AutoPUP: '..m.en)
            else
                for k,v in pairs(pup_buffs) do
                    if v and v.en:startswith(commands[3]) then
                        settings.man[commands[2]] = v.en
                        windower.add_to_chat(8, 'AutoPUP: '..v.en)
                    end
                end
            end
			
			setupMultiman(settings.man)
        end
    elseif commands[1] == 'save' then
        settings:save()
		windower.add_to_chat(8, 'AutoPUP: saved settings')
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    else
        showhelp()
    end
    pup_status:text(display_box())
end)

windower.register_event('load', function()
	setupMultiman(settings.man)
	windower.add_to_chat(8, "AutoPUP: for commands use //pup help")
end)

function setupMultiman(arr)
	for _, m in ipairs(arr) do
		local tempcnt = 0
		for _, v in ipairs(arr) do
			if m == v then tempcnt = tempcnt + 1 end
		end
		if tempcnt > 1 then 
			multiman = m
			multimanCnt = tempcnt
			break
		else
			multiman = ''
			multimanCnt = 0
		end
	end
	--print('Multi Man:', multiman, multimanCnt)
end

function use_JA(str)
    del = 1.2
    windower.chat.input(str)
end
function use_PET(str,ta)
    windower.send_command('input /pet "%s" %s':format(str,ta))
    del = 1.2
end

function showhelp()
	windower.add_to_chat(205, '    == AutoPUP :: HELP ==')
	windower.add_to_chat(207, ' //pup - toggles addon on/off')
	windower.add_to_chat(205, 'COMMAND: MAN')
	windower.add_to_chat(207, ' //pup man {#} {maneuver}')
	windower.add_to_chat(207, '   ex: //pup man 1 fire maneuver')
	windower.add_to_chat(207, '   ex: //pup man 2 wind')
	windower.add_to_chat(207, '   ex: //pup man 3 {Thunder Maneuver}')
	windower.add_to_chat(205, 'COMMAND: SET')
	windower.add_to_chat(207, ' //pup set {setname}')
	windower.add_to_chat(207, '   ex: //pup set spamdd')
	windower.add_to_chat(205, 'COMMAND: REPAIR')
	windower.add_to_chat(207, ' //pup repair - turns auto repair on/off')
	windower.add_to_chat(207, ' //pup repairhpp {#}')
	windower.add_to_chat(205, 'COMMAND: ACTIVATE & DEPLOY')
	windower.add_to_chat(207, ' //pup activate - turns auto activate on/off')
	windower.add_to_chat(207, ' //pup deploy - turns auto deploy on/off -- uses <bt>')
	windower.add_to_chat(205, 'COMMAND: SAVE')
	windower.add_to_chat(207, ' //pup save')
end

function reset()
    actions = false
    buffs = {}
end

function status_change(new,old)
    if new > 1 and new < 4 then
        reset()
		pup_status:text(display_box())
    end
end

function zone_change()
	reset()
	pup_status:text(display_box())
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o..'\n')
    end
end

windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', zone_change)