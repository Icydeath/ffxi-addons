local NilMenu = require('model/menu/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ConfirmMenu = NilMenu:NilMenu()
ConfirmMenu.__index = ConfirmMenu

--------------------------------------------------------------------------------
function ConfirmMenu:ConfirmMenu(id, idx)
    local o = NilMenu:NilMenu(id)
    setmetatable(o, self)
    o._type = 'ConfirmMenu'
    o._option = {}
    o._option[1] = { option = 64 + idx, automated = false, uk1 = 0 }

    setmetatable(o._option, { __index = function()
        return { option = 32 + 16 + idx, automated = false, uk1 = 0 }
    end })

    return o
end

--------------------------------------------------------------------------------
function ConfirmMenu:OptionFor(i)
    return self._option[i + 1]
end

return ConfirmMenu
