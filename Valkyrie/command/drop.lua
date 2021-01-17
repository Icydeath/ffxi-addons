local NilCommand = require('command/nil')
local EntityFactory = require('model/entity/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local DropCommand = NilCommand:NilCommand()
DropCommand.__index = DropCommand

--------------------------------------------------------------------------------
function DropCommand:DropCommand(lamp)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._lamp = lamp
    o._type = 'DropCommand'
    return o
end

--------------------------------------------------------------------------------
function DropCommand:OnIncomingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function DropCommand:OnOutgoingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function DropCommand:__call(state)
    log('Dropping ' .. self._lamp.en)
    local player = EntityFactory.CreatePlayer()
    while player:Bag():ItemCount(self._lamp.id) > 0 do
        local idx = player:Bag():ItemIndex(self._lamp.id)
        local pkt = packets.new('outgoing', 0x028)
        pkt.Count = 1
        pkt.Bag = 0
        pkt['Inventory Index'] = idx
        packets.inject(pkt)

        coroutine.sleep(1)

        player = EntityFactory.CreatePlayer()
    end
    self._on_success()
end

return DropCommand
