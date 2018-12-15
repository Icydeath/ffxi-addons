local NilBag = require('model/inventory/nil_bag')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PlayerBag = NilBag:NilBag()
PlayerBag.__index = PlayerBag

--------------------------------------------------------------------------------
function PlayerBag:PlayerBag(items)
    local o = {}
    setmetatable(o, self)
    o._items = items
    return o
end

--------------------------------------------------------------------------------
function PlayerBag:FreeSlots()
    return self._items.max - self._items.count
end

--------------------------------------------------------------------------------
function PlayerBag:ItemCount(id)
    local count = 0
    for _, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id then
            count = count + value.count
        end
    end
    return count
end

--------------------------------------------------------------------------------
function PlayerBag:ItemIndex(id)
    for key, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id then
            return key
        end
    end
    return NilBag.ItemIndex(self, id)
end

--------------------------------------------------------------------------------
function PlayerBag:Type()
    return 'PlayerBag'
end

return PlayerBag
