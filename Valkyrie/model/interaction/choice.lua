local NilInteraction = require('model/interaction/nil')

--------------------------------------------------------------------------------
local function CreateChoicePacket(data)
    local pkt = packets.new('outgoing', 0x05B)
    pkt['Target'] = data.target:Id()
    pkt['Target Index'] = data.target:Index()
    pkt['Option Index'] = data.choice
    pkt['_unknown1'] = data.uk1
    pkt['Automated Message'] = data.automated
    pkt['Zone'] = data.target:Zone()
    pkt['Menu ID'] = data.menu
    return pkt
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Choice = NilInteraction:NilInteraction()
Choice.__index = Choice

--------------------------------------------------------------------------------
function Choice:Choice()
    local o = NilInteraction:NilInteraction()
    setmetatable(o, self)
    o._to_send = { [1] = function(data) return {CreateChoicePacket(data)} end }
    o._idx = 1
    o._type = 'Choice'

    setmetatable(o._to_send,
        { __index = function() return function() return {} end end })

    return o
end

--------------------------------------------------------------------------------
function Choice:OnIncomingData(id, pkt)
    -- TODO failure condition? 0x052 with 5th byte set differently?
    if id == 0x052 then
        self._on_success()
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------------
function Choice:_GeneratePackets(data)
    local pkts = self._to_send[self._idx](data)
    self._idx = self._idx + 1
    return pkts
end

--------------------------------------------------------------------------------
function Choice:__call(data)
    local pkts = self:_GeneratePackets(data)
    for _, pkt in pairs(pkts) do
        packets.inject(pkt)
    end
end

return Choice
