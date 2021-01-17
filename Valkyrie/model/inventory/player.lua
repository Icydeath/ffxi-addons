local NilInventory = require('model/inventory/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PlayerInventory = NilInventory:NilInventory()
PlayerInventory.__index = PlayerInventory

--------------------------------------------------------------------------------
function PlayerInventory:PlayerInventory(items)
    local o = NilInventory:NilInventory()
    setmetatable(o, self)
    o._items = items
    return o
end

--------------------------------------------------------------------------------
function PlayerInventory:FreeSlots()
    return self._items.max - self._items.count
end

--------------------------------------------------------------------------------
function PlayerInventory:ItemCount(id)
    local count = 0
    for _, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id then
            count = count + value.count
        end
    end
    return count
end

--------------------------------------------------------------------------------
function PlayerInventory:ItemIndex(id)
    for key, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id then
            return key
        end
    end
    return NilInventory.ItemIndex(self, id)
end

--------------------------------------------------------------------------------
function PlayerInventory:ItemExtData(idx)
    return extdata.decode(self._items[idx])
end

--------------------------------------------------------------------------------
function PlayerInventory:Type()
    return 'PlayerInventory'
end

return PlayerInventory
