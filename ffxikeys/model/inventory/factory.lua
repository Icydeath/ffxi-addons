local NilInventory = require('model/inventory/nil')
local PlayerInventory = require('model/inventory/player')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local InventoryFactory = {}

--------------------------------------------------------------------------------
function InventoryFactory.CreateInventory(bag_num)
    if not bag_num then
        return NilInventory:NilInventory()
    end

    local items = windower.ffxi.get_items(bag_num)
    if not items then
        return NilInventory:NilInventory()
    end

    return PlayerInventory:PlayerInventory(items)
end

return InventoryFactory
