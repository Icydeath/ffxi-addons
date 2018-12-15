local BagFactory = require('model/inventory/bag_factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilEntity = {}
NilEntity.__index = NilEntity
NilEntity.MAX_DISTANCE = 2^32

--------------------------------------------------------------------------------
function NilEntity:NilEntity()
    local o = {}
    setmetatable(o, self)
    o._id = 0
    o._index = 0
    o._distance = NilEntity.MAX_DISTANCE
    o._type = 'NilEntity'
    o._bag = BagFactory.CreateBag()
    return o
end

--------------------------------------------------------------------------------
function NilEntity:Id()
    return self._id
end

--------------------------------------------------------------------------------
function NilEntity:Index()
    return self._index
end

--------------------------------------------------------------------------------
function NilEntity:Distance()
    return self._distance
end

--------------------------------------------------------------------------------
function NilEntity:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilEntity:Bag()
    return self._bag
end

return NilEntity
