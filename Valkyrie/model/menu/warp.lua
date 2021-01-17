local NilMenu = require('model/menu/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local WarpMenu = NilMenu:NilMenu()
WarpMenu.__index = WarpMenu

--------------------------------------------------------------------------------
function WarpMenu:WarpMenu(id)
    local o = NilMenu:NilMenu(id)
    setmetatable(o, self)
    o._option = { option = 0, automated = false, uk1 = 1 }
    o._type = 'WarpMenu'
    return o
end

return WarpMenu
