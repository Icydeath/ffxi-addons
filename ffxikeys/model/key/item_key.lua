local NilKey = require('model/key/nil_key')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ItemKey = NilKey:NilKey()
ItemKey.__index = ItemKey

--------------------------------------------------------------------------------
function ItemKey:ItemKey(id, option)
    local o = {}
    setmetatable(o, self)
    o._id = id
    o._option = option
    o._type = 'ItemKey'
    return o
end

return ItemKey
