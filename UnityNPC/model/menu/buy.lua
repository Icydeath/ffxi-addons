local SimpleMenu = require('model/menu/simple')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local BuyMenu = SimpleMenu:SimpleMenu()
BuyMenu.__index = BuyMenu

--------------------------------------------------------------------------------
function BuyMenu:BuyMenu(id)
    local o = SimpleMenu:SimpleMenu(id, 10, true, 0)
    setmetatable(o, self)
    o._type = 'BuyMenu'

    return o
end

return BuyMenu