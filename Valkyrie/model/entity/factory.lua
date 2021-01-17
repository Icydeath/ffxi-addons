local MobEntity = require('model/entity/mob')
local NilEntity = require('model/entity/nil')
local PlayerEntity = require('model/entity/player')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local EntityFactory = {}

--------------------------------------------------------------------------------
function EntityFactory.CreatePlayer()
    local player = windower.ffxi.get_player()
    if not player then
        return NilEntity:NilEntity()
    end

    local mob = windower.ffxi.get_mob_by_id(player.id)
    if not mob then
        return NilEntity:NilEntity()
    end

    return PlayerEntity:PlayerEntity(mob)
end

--------------------------------------------------------------------------------
function EntityFactory.CreateMob(mob_id)
    if not mob_id then
        return NilEntity:NilEntity()
    end

    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then
        return NilEntity:NilEntity()
    end

    local info = windower.ffxi.get_info()
    if not info or not info.zone then
        return NilEntity:NilEntity()
    end

    return MobEntity:MobEntity(mob, info.zone)
end

return EntityFactory
