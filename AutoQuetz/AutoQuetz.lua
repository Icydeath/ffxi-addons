-- Inspired by Kaotic's 'Quetz' addon.

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

_addon.author   = 'Icy'
_addon.version  = '1.0'
_addon.commands = {'autoquetz, aq'}

require('pack')
require('lists')
require('tables')
require('strings')
require('logger')
require('coroutine')
packets = require('packets')
res = require('resources')
texts = require('texts')
config = require('config')

default = {
	active = true,
    trusts = L{'Selh\'teus','King of Hearts', 'Qultada', 'Joachim', 'Apururu (UC)'},
    text = {text = {size=10}},
	target = 'Quetzalcoatl',
}

settings = config.load(default)

local display_box = function()
    return 'AutoQuetz [O%s]\nTarget: %s\nTrusts:\n - %s\n - %s\n - %s\n - %s\n - %s':format(actions and 'n' or 'ff', settings.target, settings.trusts[1], settings.trusts[2], settings.trusts[3], settings.trusts[4], settings.trusts[5])
end

aq_status = texts.new(display_box(),settings.text,setting)
aq_status:show()



windower.register_event('prerender',function ()
    if not actions then return end
	
	
end)

function showhelp()
	windower.add_to_chat(207, '== AutoQuetz Help | //aq help ==')
	windower.add_to_chat(205, 'COMMANDS:')
	windower.add_to_chat(207, ' //aq [on|off]')
	windower.add_to_chat(207, ' //aq [target|t] "mob_name"')
	windower.add_to_chat(207, ' //aq [save]')
end

function reset()
    actions = false
    buffs = {}
end

function status_change(new,old)
    if new > 1 and new < 4 then
        reset()
		aq_status:text(display_box())
    end
end

function zone_change()
	reset()
	aq_status:text(display_box())
end

windower.register_event('load', function()
	
end)

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
	elseif commands[1] == 'target' or commands[1] == 't' then
		if commands[2] then
			settings.target = commands[2]
		end
	elseif commands[1] == 'save' then
        settings:save()
		windower.add_to_chat(8, 'AutoQuetz: settings saved')
	end
	
	aq_status:text(display_box())
end)

windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', zone_change)