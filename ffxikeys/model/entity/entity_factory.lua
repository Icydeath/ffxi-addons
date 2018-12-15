local MobEntity = require('model/entity/mob_entity')
local NilEntity = require('model/entity/nil_entity')
local PlayerEntity = require('model/entity/player_entity')

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

    return MobEntity:MobEntity(mob)
end

return EntityFactory
