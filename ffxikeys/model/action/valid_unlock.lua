local NilUnlock = require('model/action/nil_unlock')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ValidUnlock = NilUnlock:NilUnlock()
ValidUnlock.__index = ValidUnlock

--------------------------------------------------------------------------------
function ValidUnlock:ValidUnlock(key, lock)
    local o = {}
    setmetatable(o, self)
    o._type = 'ValidUnlock'
    o._key = key
    o._lock = lock
    return o
end

--------------------------------------------------------------------------------
function ValidUnlock:__call()
    local pkt = packets.new('outgoing', 0x036)
    pkt['Target'] = self._lock:Npc()
    pkt['Item Count 1'] = 1
    pkt['Item Index 1'] = self._key:Entity():Bag():ItemIndex(self._key:Item())
    pkt['Target Index'] = self._lock:Entity():Index()
    pkt['Number of Items'] = 1

    packets.inject(pkt)

    return true
end

return ValidUnlock
