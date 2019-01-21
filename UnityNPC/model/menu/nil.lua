--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilMenu = {}
NilMenu.__index = NilMenu

--------------------------------------------------------------------------------
function NilMenu:NilMenu(id)
    local o = {}
    setmetatable(o, self)
    o._id = id
    o._option = { option = 0, automated = false, uk1 = 0 }
    o._type = 'NilMenu'
    return o
end

--------------------------------------------------------------------------------
function NilMenu:Id()
    return self._id
end

--------------------------------------------------------------------------------
function NilMenu:OptionFor(_)
    return self._option
end

--------------------------------------------------------------------------------
function NilMenu:Type()
    return self._type
end

return NilMenu
