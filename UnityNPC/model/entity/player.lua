local BagFactory = require('model/inventory/factory')
local NilEntity = require('model/entity/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PlayerEntity = NilEntity:NilEntity()
PlayerEntity.__index = PlayerEntity

--------------------------------------------------------------------------------
function PlayerEntity:PlayerEntity(player)
    local o = NilEntity:NilEntity()
    setmetatable(o, self)
    o._id = player.id
    o._index = player.index
    o._distance = 0
    o._type = 'PlayerEntity'
    o._bag = BagFactory.CreateInventory(0)
    return o
end

return PlayerEntity
