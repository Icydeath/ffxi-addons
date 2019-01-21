local SimpleMenu = require('model/menu/simple')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ItemMenu = SimpleMenu:SimpleMenu()
ItemMenu.__index = ItemMenu

--------------------------------------------------------------------------------
function ItemMenu:ItemMenu(id, idx)
    local o = SimpleMenu:SimpleMenu(id, (idx * (2^5) + 3), true, 0)
    setmetatable(o, self)
    o._type = 'ItemMenu'

    return o
end

return ItemMenu