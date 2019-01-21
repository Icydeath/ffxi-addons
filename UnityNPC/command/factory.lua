local NilCommand = require('command/nil')
local WarpCommand = require('command/warp')
local BuyCommand = require('command/buy')
local Npcs = require('data/npcs')
local Warps = require('data/warps')
local Items = require('data/items')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CommandFactory = {}

--------------------------------------------------------------------------------
local function StringToZoneId(name)
    local zone = resources.zones:with('en', windower.convert_auto_trans(name))
    if zone then
        return zone.id
    else
        return 0
    end
end

--------------------------------------------------------------------------------
function CommandFactory.CreateCommand(cmd, p1, p2)
    if cmd == 'warp' then
        if not p1 then
            log('Zone must be provided')
            return NilCommand:NilCommand()
        end

        local warp = Warps.GetByProperty('zone', StringToZoneId(p1))
        local npc = Npcs.GetForCurrentZone()

        return WarpCommand:WarpCommand(npc.id, warp.idx)
    elseif cmd == 'buy' then
        local key = Items.GetByProperty('en', p1)
        if key.id == 0 then
            log('Invalid item argument')
            return NilCommand:NilCommand()
        end
        if not p2 or not tonumber(p2) then
            log('Invalid count argument')
            return NilCommand:NilCommand()
        end
        local npc = Npcs.GetForCurrentZone()
        return BuyCommand:BuyCommand(npc.id, key.idx, npc.zone, tonumber(p2))
    else
        log('Unknown command')
        return NilCommand:NilCommand()
    end
end

return CommandFactory