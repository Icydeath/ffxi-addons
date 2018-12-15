local ValidUnlock = require('model/action/valid_unlock')
local NilUnlock = require('model/action/nil_unlock')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local UnlockFactory = {}

--------------------------------------------------------------------------------
function UnlockFactory.CreateUnlock(key, lock)
    if key:Type() == 'NilKey' or lock:Type() == 'NilLock' then
        return NilUnlock:NilUnlock()
    end

    if key:Entity():Type() == 'NilEntity' then
        if log then
            log('Unable to find key')
        end
        return NilUnlock:NilUnlock()
    end

    -- Require two free slots as a workaround for a bug.
    if key:Entity():Bag():FreeSlots() <= 1 then
        if log then
            log('Inventory full')
        end
        return NilUnlock:NilUnlock()
    end

    if key:Entity():Bag():ItemCount(key:Item()) <= 0 then
        if log then
            log('No keys')
        end
        return NilUnlock:NilUnlock()
    end

    return ValidUnlock:ValidUnlock(key, lock)
end

return UnlockFactory
