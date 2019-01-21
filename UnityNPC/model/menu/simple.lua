local NilMenu = require('model/menu/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local SimpleMenu = NilMenu:NilMenu()
SimpleMenu.__index = SimpleMenu

--------------------------------------------------------------------------------
function SimpleMenu:SimpleMenu(id, option, automated, uk1)
    local o = NilMenu:NilMenu(id)
    setmetatable(o, self)

    o._option = { option = option, automated = automated, uk1 = uk1 }
    o._type = 'SimpleMenu'

    return o
end

return SimpleMenu