_addon.name = 'S-Mart'
_addon.author = 'Talym'
_addon.version = '1.01'
_addon.commands = {'sm'}

require 'pack'
require 'lists'

config = require('config')

local default_settings = {}
default_settings.displacers = false
default_settings.sparks = 'off'

settings = config.load(default_settings)

function report_settings()
    local disp = ''
    if settings.displacers == true then disp = 'On' else disp = 'Off' end
    windower.add_to_chat(006, _addon.name .. ':: Displacers: ' .. disp .. ' | Sparks: ' .. settings.sparks)
end

windower.register_event('addon command', function(command, ...)

    command = command and command:lower() or 'help'
    local params = {...}

    if command == 'help' then
        windower.add_to_chat(204, _addon.name .. ' v' .. _addon.version .. '. Author: ' .. _addon.author)
        windower.add_to_chat(006, 'sm displacer on/off : Manage voidwatch displacer purchasing')
        windower.add_to_chat(006, 'sm sparks [off/acheron/darksteel] : Manage sparks item purchasing')
        windower.add_to_chat(006, 'sm help : Shows help message')
    elseif command == 'displacer' or command == 'd' then
        if params[1] then
            if params[1]:lower() == 'on' then
                settings.displacers = true
            elseif params[1]:lower() == 'off' then
                settings.displacers = false
            end
        end
        config.save(settings)
        report_settings()
    elseif command == 'sparks' or command == 's' then
        if params[1] then
            if L{'off','acheron','darksteel'}:contains(params[1]:lower()) then
                settings.sparks = params[1]:lower()
            else
                windower.add_to_chat(006, 'S-Mart:: Unrecognized sparks item')
            end
        end
        config.save(settings)
        report_settings()
    end
end)

windower.register_event('outgoing chunk',function(id,org)
    if id == 0x5B then

        local name = (windower.ffxi.get_mob_by_id(org:unpack('I',5)) or {}).name

        if settings.displacers == true and L{'Ardrick'}:contains(name) then
            return menu_packet(org,1,0,0x05,0)
        elseif L{'Eternal Flame','Rolandienne','Isakoth','Fhelm Jobeizat'}:contains(name) then
            if settings.sparks == 'acheron' then
                return menu_packet(org,9,0,0x29,0)
            elseif settings.sparks == 'darksteel' then
                return menu_packet(org,8,0,0x24,0)
            end
        end
    end
end)

function menu_packet(org,a,b,c,d)
    local outstr = org:sub(1,8)
    local choice = org:unpack('I',9)
    if choice == 0 or choice == 0x40000000 then
        return outstr..string.char(a,b,c,d)..org:sub(13)
    end
end
