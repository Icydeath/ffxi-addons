local NilBag = require('model/inventory/nil_bag')
local PlayerBag = require('model/inventory/player_bag')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local BagFactory = {}

--------------------------------------------------------------------------------
function BagFactory.CreateBag(bag_num)
    if not bag_num then
        return NilBag:NilBag()
    end

    local items = windower.ffxi.get_items(bag_num)
    if not items then
        return NilBag:NilBag()
    end

    return PlayerBag:PlayerBag(items)
end

return BagFactory
