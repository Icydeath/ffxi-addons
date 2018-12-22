--[[
Copyright 2014 Seth VanHeulen

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

_addon.name = 'sprint'
_addon.version = '1.0.0'
_addon.command = 'sprint'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

require('pack')

enabled = false
speed = 80
prev_update = nil

function check_incoming_chunk(id, original, modified, injected, blocked)
    if id == 0x37 then
        prev_update = original
        if enabled then
            return original:sub(1, 44) .. 'C':pack(speed) .. original:sub(46)
        end
    end
end

function speed_command(...)
    if #arg ~= 1 then
        return
    end
    local temp_speed = tonumber(arg[1]:lower())
    if temp_speed and temp_speed > 0 and temp_speed <= 255 then
        speed = math.floor(temp_speed)
    elseif arg[1]:lower() == 'toggle' then
        enabled = not enabled
    elseif arg[1]:lower() == 'on' then
        enabled = true
    elseif arg[1]:lower() == 'off' then
        enabled = false
    else
        return
    end
    if prev_update then
        windower.packets.inject_incoming(0x37, prev_update:sub(1, 64) .. 'I':pack(os.time() - 1009806839) .. prev_update:sub(69))
    else
        windower.add_to_chat(207, '---- \31\167waiting for char update\30\1 ----')
    end
    windower.add_to_chat(207, '---- sprint enabled: %s, speed: \31\200%s\30\1 ----':format(enabled and '\31\204yes\30\1' or '\31\167no\30\1', speed))
end

windower.register_event('incoming chunk', check_incoming_chunk)
windower.register_event('addon command', speed_command)
