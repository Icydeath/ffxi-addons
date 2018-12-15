--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilCommand = {}
NilCommand.__index = NilCommand

--------------------------------------------------------------------------------
function NilCommand:NilCommand()
    local o = {}
    setmetatable(o, self)
    o._type = 'NilCommand'
    return o
end

--------------------------------------------------------------------------------
function NilCommand:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilCommand:__call(state)
    return false
end

return NilCommand
