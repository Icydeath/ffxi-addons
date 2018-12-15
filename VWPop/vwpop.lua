_addon.name = 'VW Popper'
_addon.author = 'Talym'
_addon.version = '1.01'
_addon.commands = {'pop', 'popper'}

require 'pack'
require 'lists'

config = require('config')

local default_settings = {}
default_settings.displacers = 0
default_settings.enabled = false
default_settings.messages = true

settings = config.load(default_settings)

function report_settings()
    local on = ''
    local m = ''
    if settings.enabled == true then on = 'Enabled' else on = 'Disabled' end
    if settings.messages == true then m = 'On' else m = 'Off' end
    windower.add_to_chat(006, _addon.name .. ': ' ..  on .. ' | Displacers: ' .. tostring(settings.displacers) .. ' | Messages: ' .. m)
end

report_settings()

windower.register_event('addon command', function(command, ...)

    command = command and command:lower() or 'help'
    local params = {...}

    if command == 'help' then
        windower.add_to_chat(204, _addon.name .. ' v' .. _addon.version .. '. Author: ' .. _addon.author)
        windower.add_to_chat(006, 'pop on/off : Enables or disable pop control')
        windower.add_to_chat(006, 'pop d [#] : Sets number of displacers to use')
        windower.add_to_chat(006, 'pop m on/off : Enables or disables pop messages')
        windower.add_to_chat(006, 'pop help : Shows help message')
    elseif command == 'on' then
        if settings.enabled ~= true then
            settings.enabled = true
            config.save(settings)
        end
        report_settings()
    elseif command == 'off' then
        if settings.enabled ~= false then
            settings.enabled = false
            config.save(settings)
        end
        report_settings()
    elseif command == 'displacers' or command == 'd' then
        if params[1] then
            if tonumber(params[1]) <= 5 then
                settings.displacers = tonumber(params[1])
            else
                windower.add_to_chat(006, _addon.name .. ': Invalid number of displacers specified.')
            end
        end
        config.save(settings)
        report_settings()
    elseif command == 'messages' or command == 'm' then
        if params[1] then
            if params[1] == 'on' then
                settings.messages = true
            elseif params[1] == 'off' then
                settings.messages = false
            end
            config.save(settings)
        end
        report_settings()
    else
        windower.add_to_chat(006, _addon.name .. ': Unrecognized command. See //pop help')
    end

end)

windower.register_event('outgoing chunk',function(id,org)
    if id == 0x5B then
        local data = org:unpack('I')
        local name = (windower.ffxi.get_mob_by_id(org:unpack('I',5)) or {}).name

        if settings.enabled == true and L{'Planar Rift'}:contains(name) then
            --windower.add_to_chat(155,"Packet A: "..org:byte(9,9)) --windower.add_to_chat(155,"Packet B: "..org:byte(10,10)) --windower.add_to_chat(155,"Packet C: "..org:byte(11,11)) --windower.add_to_chat(155,"Packet D: "..org:byte(12,12))
            local outstr = org:sub(1,8)
            local choice = org:unpack('I',9)
            local disp = (settings.displacers * 16) + 1
            if choice == 0 or choice == 0x40000000 then
                if settings.messages == true then
                    windower.add_to_chat(006, _addon.name .. ': Attempting to pop with ' .. tostring(settings.displacers) ..' displacers.')
                end
                return outstr..string.char(disp,0,0,0)..org:sub(13)
            end
        end
    end
end
)
