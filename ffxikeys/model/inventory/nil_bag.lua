--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilBag = {}
NilBag.__index = NilBag
NilBag.INVALID_INDEX = -1

--------------------------------------------------------------------------------
function NilBag:NilBag()
    local o = {}
    setmetatable(o, self)
    return o
end

--------------------------------------------------------------------------------
function NilBag:FreeSlots()
    return 0
end

--------------------------------------------------------------------------------
function NilBag:ItemCount(id)
    return 0
end

--------------------------------------------------------------------------------
function NilBag:ItemIndex(id)
    return NilBag.INVALID_INDEX
end

--------------------------------------------------------------------------------
function NilBag:Type()
    return 'NilBag'
end

return NilBag
