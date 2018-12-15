local BagFactory = require('model/inventory/bag_factory')
local NilEntity = require('model/entity/nil_entity')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PlayerEntity = NilEntity:NilEntity()
PlayerEntity.__index = PlayerEntity

--------------------------------------------------------------------------------
function PlayerEntity:PlayerEntity(player)
    local o = {}
    setmetatable(o, self)
    o._id = player.id
    o._index = player.index
    o._distance = 0
    o._type = 'PlayerEntity'
    o._bag = BagFactory.CreateBag(0)
    return o
end

return PlayerEntity
