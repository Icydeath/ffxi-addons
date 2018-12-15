local ValidPurchase = require('model/action/valid_purchase')
local NilPurchase = require('model/action/nil_purchase')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PurchaseFactory = {}

--------------------------------------------------------------------------------
function PurchaseFactory.CreatePurchase(key, vendor, zone, count)
    if key:Type() == 'NilKey' then
        if log then
            log('Unknown key')
        end
        return NilPurchase:NilPurchase()
    end
    if vendor:Type() == 'NilLock' then
        if log then
            log('Unknown vendor')
        end
        return NilPurchase:NilPurchase()
    end
    if not count or not zone then
        if log then
            log('Invalid param or zone')
        end
        return NilPurchase:NilPurchase()
    end
    if key:Entity():Bag():FreeSlots() <= 0 then
        if log then
            log('Inventory full')
        end
        return NilPurchase:NilPurchase()
    end

    return ValidPurchase:ValidPurchase(key, vendor, zone, count)
end

return PurchaseFactory
