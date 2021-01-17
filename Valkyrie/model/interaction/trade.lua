local NilInteraction = require('model/interaction/nil')

--------------------------------------------------------------------------------
local function CreateItemPacket(data)
    local pkt = packets.new('outgoing', 0x036)
    pkt['Target'] = data.target:Id()
    pkt['Target Index'] = data.target:Index()
    pkt['Item Count 1'] = 1
    pkt['Item Index 1'] = data.player:Bag():ItemIndex(data.item_id)
    pkt['Number of Items'] = 1
    return pkt
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Trade = NilInteraction:NilInteraction()
Trade.__index = Trade

--------------------------------------------------------------------------------
function Trade:Trade()
    local o = NilInteraction:NilInteraction()
    setmetatable(o, self)
    o._to_send = { [1] = function(data) return {CreateItemPacket(data)} end }
    o._idx = 1
    o._type = 'Trade'

    setmetatable(o._to_send,
        { __index = function() return function() return {} end end })
    return o
end

--------------------------------------------------------------------------------
function Trade:OnIncomingData(id, _)
    if id == 0x052 then
        self._on_failure()
        return true
    elseif id == 0x034 or id == 0x032 then
        self._on_success()
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------------
function Trade:_GeneratePackets(data)
    local pkts = self._to_send[self._idx](data)
    self._idx = self._idx + 1
    return pkts
end

--------------------------------------------------------------------------------
function Trade:__call(data)
    local pkts = self:_GeneratePackets(data)
    for _, pkt in pairs(pkts) do
        packets.inject(pkt)
    end
end

return Trade