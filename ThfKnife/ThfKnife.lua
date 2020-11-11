--Copyright © 2018, Rufus0
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of thfknife nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL RUFUS0 BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


_addon.name = 'ThfKnife'
_addon.author = 'Rufus0'
_addon.version = 1.0
_addon.commands = {'thfknife', 'knife'}

config = require 'config'
texts = require 'texts'
packets = require 'packets'
require('logger')

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 200
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30

settings = config.load(defaults)

th = texts.new('TH: 0', settings)
th:show()

windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local args = {...}

    if command == 'pos' then
        local posx, posy = tonumber(params[2]), tonumber(params[3])
        if posx and posy then
            th:pos(posx, posy)
        end
    elseif command == "hide" then
        th:hide()
    elseif command == 'show' then
        th:show()
    else
        print('knife help : Shows help message')
        print('knife pos <x> <y> : Positions the list')
        print('knife hide : Hides the box')
        print('knife show : Shows the box')
    end
end)

-- 0x028 TH Additional effect PacketViewer

windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 then
		local packet = packets.parse('incoming', data)
        local target = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])
		if packet.Category == 1 and check_actor(packet) then
			if packet['Target 1 Action 1 Has Added Effect'] then
                if packet['Target 1 Action 1 Added Effect Message'] == 603 then
                    th:text('TH: '..target.name..' → '..packet['Target 1 Action 1 Added Effect Param'])
                end
            end
		end
	end

end)

function check_actor(packet)
	local key_indices = {'p0','p1','p2','p3','p4','p5','a10','a11','a12','a13','a14','a15','a20','a21','a22','a23','a24','a25'}
    local party = windower.ffxi.get_party()
    local actor = windower.ffxi.get_mob_by_id(packet['Actor'])
    for i = 1, 18 do
        local member = party[key_indices[i]]
        if member and actor and member.mob and member.mob.id == actor.id then
            return true
        end
    end
    return false
end

windower.register_event('zone change', function()
	th:text('TH: 0')
end)