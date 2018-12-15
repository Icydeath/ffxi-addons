local NilEntity = require('model/entity/nil_entity')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilKey = {}
NilKey.__index = NilKey

--------------------------------------------------------------------------------
function NilKey:NilKey()
    local o = {}
    setmetatable(o, self)
    o._id = 0
    o._option = 0
    o._entity = NilEntity:NilEntity()
    o._type = 'NilKey'
    return o
end

--------------------------------------------------------------------------------
function NilKey:Item()
    return self._id
end

--------------------------------------------------------------------------------
function NilKey:Option()
    return self._option
end

--------------------------------------------------------------------------------
function NilKey:Entity()
    return self._entity
end

--------------------------------------------------------------------------------
function NilKey:Type()
    return self._type
end

return NilKey
