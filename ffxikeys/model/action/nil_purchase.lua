--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilPurchase = {}
NilPurchase.__index = NilPurchase

--------------------------------------------------------------------------------
function NilPurchase:NilPurchase()
    local o = {}
    setmetatable(o, self)
    o._type = 'NilPurchase'
    return o
end

--------------------------------------------------------------------------------
function NilPurchase:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilPurchase:__call()
    return false
end

return NilPurchase
