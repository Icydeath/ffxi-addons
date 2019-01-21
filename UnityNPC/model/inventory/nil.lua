--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilInventory = {}
NilInventory.__index = NilInventory
NilInventory.INVALID_INDEX = -1

--------------------------------------------------------------------------------
function NilInventory:NilInventory()
    local o = {}
    setmetatable(o, self)
    return o
end

--------------------------------------------------------------------------------
function NilInventory:FreeSlots()
    return 0
end

--------------------------------------------------------------------------------
function NilInventory:ItemCount(id)
    return 0
end

--------------------------------------------------------------------------------
function NilInventory:ItemIndex(id)
    return NilInventory.INVALID_INDEX
end

--------------------------------------------------------------------------------
function NilInventory:Type()
    return 'NilInventory'
end

return NilInventory
