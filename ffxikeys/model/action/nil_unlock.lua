--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilUnlock = {}
NilUnlock.__index = NilUnlock

--------------------------------------------------------------------------------
function NilUnlock:NilUnlock()
    local o = {}
    setmetatable(o, self)
    o._type = 'NilUnlock'
    return o
end

--------------------------------------------------------------------------------
function NilUnlock:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilUnlock:__call()
    return false
end

return NilUnlock
