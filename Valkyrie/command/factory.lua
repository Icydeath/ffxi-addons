local NilCommand = require('command/nil')
local RegisterCommand = require('command/register')
local EnterCommand = require('command/enter')
local DropCommand = require('command/drop')
local Chambers = require('data/chambers')
local Lamps = require('data/lamps')
local Npcs = require('data/npcs')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CommandFactory = {}

--------------------------------------------------------------------------------
function CommandFactory.CreateCommand(cmd, p1)
    if cmd == 'register' then
        local lamp = Lamps.GetByProperty('en', 'Smouldering Lamp')
        if lamp.id == 0 then
            log('Unknown lamp')
            return NilCommand:NilCommand()
        end
        local chamber = Chambers.GetByProperty('en', windower.convert_auto_trans(p1) or p1)
        if chamber.idx == 0 then
            log('Unknown chamber')
            return NilCommand:NilCommand()
        end
        local npc = Npcs.GetClosest()
        return RegisterCommand:RegisterCommand(npc.id, chamber, lamp.id)
    elseif cmd == 'enter' then
        local lamp = Lamps.GetByProperty('en', 'Glowing Lamp')
        if lamp.id == 0 then
            log('Unknown lamp')
            return NilCommand:NilCommand()
        end
        local npc = Npcs.GetClosest()
        return EnterCommand:EnterCommand(npc.id, lamp.id)
    elseif cmd == 'drop' then
        local lamp = Lamps.GetByProperty('en', 'Glowing Lamp')
        if lamp.id == 0 then
            log('Unknown lamp')
            return NilCommand:NilCommand()
        end
        return DropCommand:DropCommand(lamp)
    end

    return NilCommand:NilCommand()
end

return CommandFactory