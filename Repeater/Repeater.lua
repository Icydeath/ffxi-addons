--Copyright (c) 2016, Selindrile
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of RollTracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'Repeater'
_addon.version = '1.1'
_addon.author = 'Selindrile, thanks to: Balloon and Lorand and Mujihina'
_addon.commands = {'repeat','repeater'}

require('luau')
chat = require('chat')
chars = require('chat.chars')
packets = require('packets')

repeatdelay = 10
line = 'input /echo Command to repeat has not been set.'
count = 'Forever'

windower.register_event('addon command',function (...)
    cmd = {...}
	 if cmd[1] ~= nil then
		cmd[1] = cmd[1]:lower()
	end
	
	if cmd[1] == nil or cmd[1] == "status" then
		if autorepeat == true then
			windower.add_to_chat(7,'Repeating is ON.')
		else
			windower.add_to_chat(7,'Repeating is OFF.')
		end

		windower.add_to_chat(7,'Delay in seconds: '..repeatdelay..'')
		windower.add_to_chat(7,'Command to repeat: '..line..'')
		windower.add_to_chat(7,'Repeat count: '..count..'')
		
    elseif cmd[1] == "help" then
		windower.add_to_chat(7,'To start or stop repeating use //repeater repeat')
		windower.add_to_chat(7,'To set command type the winder command you want to use after //repeater command')
		windower.add_to_chat(7,'To set your repeat delay //repeater delay')
		windower.add_to_chat(7,'To set your repeat count //repeater count')
		
	elseif cmd[1] == "rollcall" then

		if autorepeat == true and ((type(count) == 'string' and count == 'Forever') or (windower.regex.match(count, "^[0-9]+$") and count > 0)) then
			windower.send_command(''..line..'') 
			windower.send_command('@wait '..repeatdelay..';repeater rollcall')
			if count ~= 'Forever' then
				count = count -1
				windower.add_to_chat(7,'Repeats remaining: '..count..'')
			end
		end
	elseif cmd[1] == "repeat" then
		if autorepeat == false then
			autorepeat = true
			windower.add_to_chat(7,'Enabling Repeater.')
			windower.send_command('repeater rollcall')
		elseif autorepeat == true then
			autorepeat = false 
			windower.add_to_chat(7,'Disabling Repeater.')
		end
	elseif cmd[1] == "on" or cmd[1] == "start" or cmd[1] == "begin" or cmd[1] == "go" or cmd[1] == "enable" or cmd[1] == "resume" or cmd[1] == "engage" then
		if autorepeat == false then
			autorepeat = true
			windower.add_to_chat(7,'Enabling Repeater.')
			windower.send_command('repeater rollcall')
		else
			windower.add_to_chat(7,'Repeater already enabled.')
		end
	elseif cmd[1] == "off" or cmd[1] == "stop" or cmd[1] == "end" or cmd[1] == "quit" or cmd[1] == "pause" or cmd[1] == "disable"  or cmd[1] == "disengage" then
		if autorepeat == true then
			autorepeat = false
			windower.add_to_chat(7,'Disabling Repeater.')
		else
			windower.add_to_chat(7,'Repeater already disabled.')
		end
	elseif cmd[1] == "command" or cmd[1] == "cmd" then
		table.remove(cmd, 1)
		line = table.concat(cmd, ' ')
		windower.add_to_chat(122,'Your command to repeat has been set to: '..line..'.')
		
	elseif cmd[1] == "reload" then
		windower.send_command('lua reload repeater')
		
	elseif cmd[1] == "unload" then
		windower.send_command('lua unload repeater')

	elseif cmd[1] == "delay" then
		if windower.regex.match(cmd[2], "^[0-9]+$") then
			repeatdelay = cmd[2]
			windower.add_to_chat(122,'Your repeat delay has been set to: '..repeatdelay..'.')
		else
			windower.add_to_chat(122,'Delay must be input in numerals.')
		end
	elseif cmd[1] == "count" then
		if cmd[2]:ucfirst() == 'Forever' then
			count = 'Forever'
			windower.add_to_chat(122,'Your repeat count has been set to: '..count..'.')
		elseif windower.regex.match(cmd[2], "^[0-9]+$") then
			count = tonumber(cmd[2])
			windower.add_to_chat(122,'Your repeat count has been set to: '..count..'.')
		else
			windower.add_to_chat(122,'Delay must be input in numerals.')
		end
    end
end)

windower.register_event('load', function()
	autorepeat = false
end)

windower.register_event('zone change', function()
	autorepeat = false
end)