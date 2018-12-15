local EntityFactory = require('model/entity/entity_factory')
local NilLock = require('model/lock/nil_lock')
local GameLock = require('model/lock/game_lock')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local LockFactory = {}

--------------------------------------------------------------------------------
function LockFactory.CreateLock(id, menu)
    if not id or not menu then
        return NilLock:NilLock()
    end

    local entity = EntityFactory.CreateMob(id)
    if entity:Type() == 'NilEntity' then
        if log then
            log('Unable to find npc')
        end
        return NilLock:NilLock()
    end

    if tonumber(entity:Distance()) > tonumber(settings.config.maxdistance) then
        if log then
            log('Too far away')
        end
        return NilLock:NilLock()
    end


    return GameLock:GameLock(id, menu, entity)
end

return LockFactory
