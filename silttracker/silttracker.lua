--Copyright (c) 2019, Lili
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--[[
    Tracks silt and beads earnings in a box. Updates each time you zone.
]]

texts = require 'texts'
config = require 'config'
require 'tables'
packets = require('packets')
require('logger')

_addon.name = 'silttracker'
_addon.author = 'Lili'
_addon.version = '0.1.0'
_addon.command = 'strack'

--settings = config.load('data\\settings.xml',default_settings)
--config.register(settings,initialize)

text_box_settings = {
	pos = {x = 1600, y = 1000,},
	bg = {
		alpha = 255,
		red = 0,
		green = 0,
		blue = 0,
		visible = true
	},
	flags = {
		right = false,
		bottom = false,
		bold = false,
		italic = false
	},
	padding = 0,
	text = {
		size = 11,
		font = 'Consolas',
		fonts = {},
		alpha = 255,
		red = 255,
		green = 255,
		blue = 255
	}
}

box = texts.new('${content}',text_box_settings)
box.content = ''
box:show()

function initialize() 
	frame_count = 0
	current_silt = 0
	previous_silt = 0
	current_beads = 0
	previous_beads = 0
	recently_zoned = false
	first_check = true
	earnings = T{}
	content = ''
	coroutine.schedule(get_points,0.5)
end

function get_points()
	local packet = packets.new('outgoing', 0x115, {})
	packets.inject(packet)
end

initialize()

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if is_injected then return end
	if id == 0x118 then
		p = packets.parse('incoming',org)
		current_silt = p["Escha Silt"]
		current_beads = p["Escha Beads"]

		if first_check then
			earnings[#earnings+1] = string.format('Started with: %s silt and %s beads',current_silt,current_beads)
			previous_silt = current_silt
			previous_beads = current_beads
			first_check = false
		
		elseif recently_zoned then
			local earned_silt = current_silt - previous_silt
			local earned_beads = current_beads - previous_beads

			if earned_silt > 0 or earned_beads > 0 then
				local now = os.date('%X')
				earnings[#earnings+1] = string.format('%s - Earned: %s silt and %s beads',now,earned_silt,earned_beads)
				previous_silt = current_silt
				previous_beads = current_beads
			end

			recently_zoned = false
		end
		
		update_box()

	end
		
end)

windower.register_event('zone change',function(new,old)
	recently_zoned = true
	coroutine.schedule(get_points,15)
end)

windower.register_event('addon command',function(...)
    local commands = {...}
    local first_cmd = table.remove(commands,1):lower()
    if first_cmd == 'reload' or first_cmd == 'r' then
        windower.send_command('lua r silttracker')
    elseif first_cmd == 'unload' or first_cmd == 'u' then
        windower.send_command('lua u silttracker')
    elseif first_cmd == 'reset' then
        initialize()
    elseif first_cmd == 'eval' then
        assert(loadstring(table.concat(commands, ' ')))()
    end
end)

windower.register_event('prerender',function()
    if frame_count%30 == 0 and box:visible() then
		frame_count = 0
        update_box()
    end
    frame_count = frame_count + 1
end)

function update_box()
	
	content = ''
    
	if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_player() then
        box.content = ''
        return
    end

	if #earnings > 0 then 
		if #earnings > 5 then 
			earnings = earnings:slice(#earnings-4,#earnings)
		end
		content = earnings:concat('\n')..'\n'
	end
	
	local now = os.date('%X')
	content = content .. string.format('%s - Current: %s silt - %s beads.',now,current_silt,current_beads)
    
    if box.content ~= content then
        box.content = content
    end

end