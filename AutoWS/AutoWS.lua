_addon.name = 'AutoWS'
_addon.author = 'Lorand'
_addon.commands = {'autows','aws'}
_addon.version = '0.3.1'
_addon.lastUpdate = '2016.08.01'

--[[
    TODO: Add per-mob WS settings
--]]

require('luau')
require('lor/lor_utils')
_libs.lor.req('all')
_libs.lor.debug = false

local rarr = string.char(129,168)
local bags = {[0]='inventory',[8]='wardrobe',[10]='wardrobe2',[11]='wardrobe3',[12]='wardrobe4'}

local hps, mobs
local enabled = false
local useAutoRA = false
local araDelayed = 0
local ws_cmd = ''
local autowsDelay = 0.8
local defaults = {hps = {['<']=100, ['>']=5}}
settings = _libs.lor.settings.load('data/settings.lua', defaults)
local settings_loaded = false


local function weap_type()
    local items = windower.ffxi.get_items()
    local i,bag = items.equipment.main, items.equipment.main_bag
    local skill = 'Hand-to-Hand'
    if i ~= 0 then  --0 => nothing equipped
        skill = res.skills[res.items[items[bags[bag]][i].id].skill].en
    end
    return skill
end


function save_settings()
    local player = windower.ffxi.get_player()
    local name = player.name
    local job = player.main_job
    local skill = weap_type()
    
    settings[name] = settings[name] or {}
    settings[name][job] = settings[name][job] or {}
    settings[name][job][skill] = settings[name][job][skill] or {}
    settings[name][job][skill].hps = hps
    settings[name][job][skill].mobs = mobs
    settings[name][job][skill].ws_cmd = ws_cmd
    settings:save()
end


function load_settings()
    local p = windower.ffxi.get_player()
    if p == nil then return end
    local s = settings:get_nested_value(p.name, p.main_job, weap_type()) or {}
    hps = s.hps or defaults.hps
    mobs = s.mobs or {}
    ws_cmd = s.ws_cmd or ''
    settings_loaded = true
end


local function parse_hps(arg_str)
    local srx = {['<'] = '<%s*(%d+)', ['>'] = '>%s*(%d+)', ['='] = '=%s*(%d+)'}
    local vals = map(tonumber, map(customized(string.match, arg_str), srx))
    if vals['='] ~= nil then
        if sizeof(vals) == 1 then
            vals['<'] = vals['='] + 1
            vals['>'] = vals['='] - 1
            vals['='] = nil
        else
            atc(123, 'Input Error: Only accepts HP% >/< OR =, not both!')
            return {}
        end
    end
    if sizeof(vals) < 1 then
        atc(123, 'Error: Invalid HP format; see //autows help')
    end
    return vals
end


local function valid_hp_args(args)
    local vals = {['<'] = args['<'] or hps['<'], ['>'] = args['>'] or hps['>']}
    for s,v in pairs(vals) do
        if not (-1 <= v and v <= 101) then
            atcf(123, 'Input Error: HP%% %s %s must be between 0 and 100', s, v)
            return false
        end
    end
    if vals['>'] > vals['<'] then
        atcf(123, 'Input Error: HP%% > %s must be < HP%% < %s', vals['>'], vals['<'])
        return false
    end
    return true
end


windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = T{...}
    local arg_str = windower.convert_auto_trans(' ':join(args))
	
    if S{'reload','unload'}:contains(command) then
        windower.send_command('lua %s %s':format(command, _addon.name))
	elseif S{'enable','on','start'}:contains(command) then
		enabled = true
		print_status()
	elseif S{'disable','off','stop'}:contains(command) then
		enabled = false
		print_status()
	elseif command == 'toggle' then
		enabled = not enabled
		print_status()
	elseif S{'set','use','ws'}:contains(command) then
        ws_cmd = '/ws "%s" <t>':format(arg_str)
        save_settings()
		print_status()
	elseif command == 'hp' then
        local parsed = parse_hps(arg_str)
        if sizeof(parsed) < 1 then return end
        if not valid_hp_args(parsed) then return end
        hps['<'] = parsed['<'] or hps['<']
        hps['>'] = parsed['>'] or hps['>']
		save_settings()
        print_status()
	elseif command == 'mob' then
        local mob_name = arg_str:match('[<>%d%s]*([^<>%d]+)[<>%d%s]*'):trim()
        if mob_name == nil or #mob_name < 1 then
            atc(123, 'Error: unable to parse mob name')
            return
        end
        if S{'t','<t>'}:contains(mob_name) then
            local mob = windower.ffxi.get_mob_by_target()
            if mob == nil or mob.name == nil then
                atcf(123, 'Error: Mob name was \'%s\' but no target was found!', mob_name)
                return
            end
            mob_name = mob.name
        end
        local parsed = parse_hps(arg_str)
        if sizeof(parsed) < 1 then return end
        if not valid_hp_args(parsed) then        
            atc(262, 'Note: Consider changing the defaults or providing both HP values if you left one out')
            return
        end
        local msg = {
            ['<'] = parsed['<'] or '(default)',
            ['>'] = parsed['>'] or '(default)'
        }
        atcf('WS %s %s @ %d < HP%% < %s', rarr, mob_name, msg['>'], msg['<'])
        mobs[mob_name] = {['<'] = parsed['<'], ['>'] = parsed['>']}
        save_settings()
    elseif command == 'mobs' then
        pprint_tiered(mobs)
	elseif command == 'autora' then
		local cmd = args[2] and args[2]:lower() or (useAutoRA and 'off' or 'on')
		if S{'on'}:contains(cmd) then
			useAutoRA = true
			atc('AutoWS will now resume auto ranged attacks after WSing')
		elseif S{'off'}:contains(cmd) then
			useAutoRA = false
			atc('AutoWS will no longer resume auto ranged attacks after WSing')
		else
			atc(123,'Error: invalid argument for AutoRA: '..cmd)
		end
	elseif command == 'status' then
		print_status()
    elseif S{'help','--help'}:contains(command) then
        print_help()
    elseif command == 'info' then
        if not _libs.lor.exec then
            atc(3,'Unable to parse info.  Windower/addons/libs/lor/lor_exec.lua was unable to be loaded.')
            atc(3,'If you would like to use this function, please visit https://github.com/lorand-ffxi/lor_libs to download it.')
            return
        end
        local cmd = args[1]     --Take the first element as the command
        table.remove(args, 1)   --Remove the first from the list of args
        _libs.lor.exec.process_input(cmd, args)
	else
		atc('Error: Unknown command')
	end
end)


windower.register_event('load', function()
    if not _libs.lor then
        windower.add_to_chat(39,'ERROR: .../Windower/addons/libs/lor/ not found! Please download: https://github.com/lorand-ffxi/lor_libs')
    end
    atcc(262, 'Welcome to AutoWS!  It is recommended to use HP < 100 to prevent immediate WS on engage when too far away.')
    autowsLastCheck = os.clock()
    load_settings()
end)


windower.register_event('logout', function()
    windower.send_command('lua unload autows')
end)


windower.register_event('zone change', function(new_id, old_id)
    autowsLastCheck = os.clock() + 15
end)


windower.register_event('job change', function()
    enabled = false
end)


windower.register_event('prerender', function()
    if not settings_loaded then
        if windower.ffxi.get_player() ~= nil then
            load_settings()
        end
    end
	if enabled and (ws_cmd ~= '') then
		local now = os.clock()
		if (now - autowsLastCheck) >= autowsDelay then
			local player = windower.ffxi.get_player()
			local mob = windower.ffxi.get_mob_by_target()
			if (player ~= nil) and (player.status == 1) and (mob ~= nil) then
                local hp_lt = table.get_nested_value(mobs, mob.name, '<') or hps['<']
                local hp_gt = table.get_nested_value(mobs, mob.name, '>') or hps['>']
                if player.vitals.tp > 999 then
                    if useAutoRA and (araDelayed < 2) then
                        araDelayed = araDelayed + 1
                    else
                        if hp_gt < mob.hpp and mob.hpp < hp_lt then
                            windower.send_command('input %s':format(ws_cmd))
                        end
                        araDelayed = 0
                        if useAutoRA then
                            windower.send_command('wait 4;ara start')
                        end
                    end
                end
			end
			autowsLastCheck = now
		end
	end
end)


function print_status()
	local power = enabled and 'ON' or 'OFF'
    local ws_msg = #ws_cmd > 1 and ws_cmd or '(no ws specified)'
    atcf('[AutoWS: %s] %s %s mobs @ %d < HP%% < %s', power, ws_msg, rarr, hps['>'], hps['<'])
end


function print_help()
    local help = T{
        ['[on|off|toggle]'] = 'Enable / disable autoWS',
        ['mob (>|<) (hp%) name'] = 'Set a different HP value for a specific mob name',
        ['hp (>|<) (hp%)'] = 'Set the default HP value for when weaponskills should be executed',
        ['use weaponskill_name'] = 'Set the weaponskill that should be used',
        ['autora (on|off)'] = 'Enable / disable the AutoRA addon',
    }
    --local mwwidth = max(unpack(map(string.wlen, table.keys(help))))
    local mwwidth = col_width(help:keys())
    atcc(262, 'AutoWS commands:')
    for cmd,desc in opairs(help) do
        atc(cmd:rpad(' ', mwwidth):colorize(263), desc:colorize(1))
    end
end


-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------