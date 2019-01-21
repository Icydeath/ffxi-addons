local SimpleMenu = require('model/menu/simple')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local UseMenu = SimpleMenu:SimpleMenu()
UseMenu.__index = UseMenu

--------------------------------------------------------------------------------
function UseMenu:UseMenu(id)
    local o = SimpleMenu:SimpleMenu(id, 1, true, 0)
    setmetatable(o, self)
    o._type = 'UseMenu'

    return o
end

return UseMenu