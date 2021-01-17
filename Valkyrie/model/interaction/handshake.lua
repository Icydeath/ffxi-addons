local NilInteraction = require('model/interaction/nil')

--------------------------------------------------------------------------------
local function CreateActionPacket(data)
    local pkt = packets.new('outgoing', 0x01A)
    pkt['Target'] = data.target:Id()
    pkt['Target Index'] = data.target:Index()
    return pkt
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Handshake = NilInteraction:NilInteraction()
Handshake.__index = Handshake

--------------------------------------------------------------------------------
function Handshake:Handshake()
    local o = NilInteraction:NilInteraction()
    setmetatable(o, self)
    o._to_send = { [1] = function(data) return {CreateActionPacket(data)} end }
    o._idx = 1
    o._type = 'Handshake'

    setmetatable(o._to_send,
        { __index = function() return function() return {} end end })
    return o
end

--------------------------------------------------------------------------------
function Handshake:OnIncomingData(id, _)
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
function Handshake:_GeneratePackets(data)
    local pkts = self._to_send[self._idx](data)
    self._idx = self._idx + 1
    return pkts
end

--------------------------------------------------------------------------------
function Handshake:__call(data)
    local pkts = self:_GeneratePackets(data)
    for _, pkt in pairs(pkts) do
        packets.inject(pkt)
    end
end

return Handshake