--[[
Copyright 2019 Seth VanHeulen

This file is part of lockpick.

lockpick is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

lockpick is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with lockpick.  If not, see <https://www.gnu.org/licenses/>.
--]]

-- luacheck: std luajit, globals windower

-- built-in libraries
local string = require('string')
-- extra libraries
require('pack')

local incoming_callbacks = {}

windower.register_event('incoming chunk', function (id, original)
    local callback = incoming_callbacks[id]
    if callback then
        local packet = {}
        if id == 0x02A then
            packet.player_id, packet.param_1, packet.param_2, packet.param_3 = string.unpack(original, 'IIII', 5)
            packet.message_id = string.unpack(original, 'I', 27) % 0x8000
        elseif id == 0x034 then
            packet.npc = string.unpack(original, 'I', 5)
            packet.params = string.sub(original, 9, 41)
        elseif id == 0x05b then
            packet.entity_id = string.unpack(original, 'I', 17)
        end
        callback(packet)
    end
end)

local incoming_mt = {
    __index = function (_, k)
        return {
            register = function (_, fn)
                incoming_callbacks[k] = fn
            end,
        }
    end,
}

local packets = {
    incoming = setmetatable({}, incoming_mt),
}

return packets

