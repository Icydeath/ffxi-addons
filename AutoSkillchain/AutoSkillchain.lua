_addon.name = 'AutoSkillchain'
_addon.author = 'Ameilia'
_addon.commands = {'autosc','asc','autoskillchain'}
_addon.version = '0.9.0'
_addon.lastUpdate = '2018.07.02'

require('luau')
require('lor/lor_utils')
files = require('files')
_libs.lor.req('all')
_libs.lor.debug = false

local rarr = string.char(129,168)
local bags = {[0]='inventory',[8]='wardrobe',[10]='wardrobe2',[11]='wardrobe3',[12]='wardrobe4'}
local enabled = false
local wsDelay = 4
local chains

local player = windower.ffxi.get_player()
local job = player.main_job
local selected_chain_index = 1
local chain_index = 1
local activeChain
local chain_name


windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = T{...}
	local arg_str = windower.convert_auto_trans(' ':join(args))
	local player = windower.ffxi.get_player()
	local job = player.main_job
	
	if S{'reload','unload'}:contains(command) then
		windower.send_command('lua %s %s':format(command, _addon.name))
	elseif S{'enable','on','start'}:contains(command) then
		enabled = true
		chain_index = 1
		print_status()
	elseif S{'disable','off','stop'}:contains(command) then
		enabled = false
		print_status()
	elseif command == 'toggle' then
		enabled = not enabled
		chain_index = 1
		print_status()
	elseif command == 'status' then
		print_status()
	elseif command == 'cycle_chain' then
		selected_chain_index = (selected_chain_index % #chains) + 1
		set_chain(selected_chain_index)
	elseif command == 'refresh' then
		refresh_from_file()
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
	atcc(262, 'Welcome to AutoSkillChain!')
	
	refresh_from_file()
	set_chain(1)
	
	autowsLastCheck = os.clock()
	
	windower.send_command('unbind ^k')
	windower.send_command('unbind !k')
	windower.send_command('unbind @k')
	windower.send_command('bind ^k asc toggle')
	windower.send_command('bind !k asc cycle_chain')
	windower.send_command('bind @k asc refresh')
end)

windower.register_event('status change', function()
	chain_index = 1
end)


windower.register_event('zone change', function(new_id, old_id)
	autowsLastCheck = os.clock() + 15
	refresh_from_file()
end)


windower.register_event('job change', function()
	player = windower.ffxi.get_player()
	job = player.main_job
	enabled = false
	refresh_from_file()
	set_chain(1)
end)

windower.register_event('prerender', function()
	if enabled then
		local now = os.clock()
		if (now - autowsLastCheck) >= wsDelay then
			local player = windower.ffxi.get_player()
			local mob = windower.ffxi.get_mob_by_target()
			if (player ~= nil) and (player.status == 1) and (mob ~= nil) then
				if player.vitals.tp > 999 then
					handle_chain()
					autowsLastCheck = now
				end
			end
		end
	end
end)

function set_chain(chindex)
	if not chains_defined() then
		no_chains()
		return
	end

	if chindex <= #chains then
		chain_index = 1
		activeChain = chains[chindex]
		chain_name = activeChain['name']
	end
	print_status()
end
	
function handle_chain()
	local stop = false
	if chain_index == #activeChain['ws'] and not activeChain['repeat'] then
		stop = true
	end	
	
	local ws = activeChain['ws'][chain_index]
	--atcc(262, 'AutoSkillChain would perform '..ws)
	windower.send_command('input /ws %s <t>':format(ws))
	chain_index = (chain_index % #activeChain['ws']) + 1
	
	if stop then
		enabled = false
		atcc(17, 'Reached the end of the chain. Stopping AutoSC.')
	end
end

function chains_defined() 
	return #chains > 0
end
function no_chains()
	local player = windower.ffxi.get_player()
	local job = player.main_job
	local skill = weap_type()
	atcc(263,'No skillchains defined for '..job..' '..skill)
end

function weap_type()
	local items = windower.ffxi.get_items()
	local i,bag = items.equipment.main, items.equipment.main_bag
	local skill = 'Hand-to-Hand'
	if i ~= 0 then  --0 => nothing equipped
		skill = res.skills[res.items[items[bags[bag]][i].id].skill].en
	end
	return skill
end

function refresh_from_file()
	player = windower.ffxi.get_player()
	job = player.main_job
	local skill = weap_type()
	chains = _libs.lor.settings.load('data/'..job..'/'..skill..'.lua', {})
end

function print_status()
	if not chains_defined() then
		no_chains()
		return
	end
	
	local power = enabled and 'ON' or 'OFF'
	local msg = '[AutoSC: %s] %s ':format(power, chain_name)
	if enabled then
		msg = msg..rarr..' '..activeChain['ws']:tostring()
	end
	
	if activeChain['repeat'] then
		msg = msg..' REPEATING'
	end

	atcc(50, msg)
end

function print_help()
	local help = T{
		['[on|off|toggle]'] = 'Enable / disable autoSkillchain',
		['CTRL-K'] = 'Toggle autoSkillchain enabled/disabled',
		['ALT-K'] = 'Cycle through ',
		['Windows-K'] = 'Refresh job/weapon type information',
	}
	--local mwwidth = max(unpack(map(string.wlen, table.keys(help))))
	local mwwidth = col_width(help:keys())
	atcc(262, 'AutoSkillChain commands:')
	for cmd,desc in opairs(help) do
		atc(cmd:rpad(' ', mwwidth):colorize(263), desc:colorize(1))
	end
end


-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2018, Ameilia
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------