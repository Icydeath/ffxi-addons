local SimpleMenu = require('model/menu/simple')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ActionMenu = SimpleMenu:SimpleMenu()
ActionMenu.__index = ActionMenu

--------------------------------------------------------------------------------
function ActionMenu:ActionMenu(id)
    local o = SimpleMenu:SimpleMenu(id, 7, true, 0)
    setmetatable(o, self)
    o._type = 'ActionMenu'

    return o
end

return ActionMenu