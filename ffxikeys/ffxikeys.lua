_addon.name = 'FFXIKeys'
_addon.author = 'Areint/Alzade'
_addon.version = '1.4.0'
_addon.commands = {'keys'}

--------------------------------------------------------------------------------
require('logger')
packets = require('packets')
settings = require('settings')

local CommandFactory = require('command/command_factory')
local Aliases = require('aliases')

--------------------------------------------------------------------------------
local state = {running = false, command = nil}

--------------------------------------------------------------------------------
local function OnLoad()
    settings.load()
    Aliases.Update()
end

--------------------------------------------------------------------------------
local function OnZoneChange(_, _)
    Aliases.Update()
end

--------------------------------------------------------------------------------
local function OnCommand(cmd, param1, param2, param3)
    CommandFactory.CreateCommand(cmd, param1, param2, param3)(state)
end

--------------------------------------------------------------------------------
local function OnIncomingData(id, _, pkt, b, i)
    if not state.running then
        return false
    end

    if state.command:Type() == 'UnlockCommand' then
        if id == 0x02A then
            local pkt = packets.parse('incoming', pkt)
            if settings.config.printlinks then
                log('https://www.ffxiah.com/item/' .. pkt['Param 1'] .. '/')
            end
            if settings.config.openlinks then
                windower.open_url('https://www.ffxiah.com/item/' .. pkt['Param 1'] .. '/')
            end
            state.command(state)
        end
    elseif state.command:Type() == 'BuyCommand' then
        if id == 0x034 then
            state.command(state)
            return true
        elseif id == 0x05C then
            return true
        elseif id == 0x052 then
            return true
        end
    end
end

--------------------------------------------------------------------------------
windower.register_event('load', OnLoad)
windower.register_event('zone change', OnZoneChange)
windower.register_event('addon command', OnCommand)
windower.register_event('incoming chunk', OnIncomingData)
