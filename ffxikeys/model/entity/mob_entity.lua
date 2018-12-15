local NilEntity = require('model/entity/nil_entity')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local MobEntity = NilEntity:NilEntity()
MobEntity.__index = MobEntity

--------------------------------------------------------------------------------
function MobEntity:MobEntity(mob)
    local o = {}
    setmetatable(o, self)
    o._id = mob.id
    o._index = mob.index
    o._distance = mob.distance
    o._type = 'MobEntity'
    return o
end

return MobEntity
