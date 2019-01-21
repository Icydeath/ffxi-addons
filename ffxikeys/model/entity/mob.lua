local NilEntity = require('model/entity/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local MobEntity = NilEntity:NilEntity()
MobEntity.__index = MobEntity

--------------------------------------------------------------------------------
function MobEntity:MobEntity(mob, zone)
    local o = NilEntity:NilEntity()
    setmetatable(o, self)
    o._id = mob.id
    o._index = mob.index
    o._zone = zone
    o._distance = mob.distance
    o._type = 'MobEntity'
    return o
end

return MobEntity
