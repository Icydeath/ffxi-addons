local NilInteraction = require('model/interaction/nil')

--------------------------------------------------------------------------------
local function CreateWarpPacket(data)
    local pkt = packets.new('outgoing', 0x05C)
    pkt['X'] = data.chamber.x
    pkt['Z'] = data.chamber.z
    pkt['Y'] = data.chamber.y
    pkt['Target ID'] = data.target:Id()
    pkt['_unknown1'] = data.uk1
    pkt['Zone'] = data.target:Zone()
    pkt['Menu ID'] = data.menu
    pkt['Target Index'] = data.target:Index()
    pkt['_unknown3'] = data.chamber.uk3
    return pkt
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Warp = NilInteraction:NilInteraction()
Warp.__index = Warp

--------------------------------------------------------------------------------
function Warp:Warp()
    local o = NilInteraction:NilInteraction()
    setmetatable(o, self)
    o._to_send = { [1] = function(data) return {CreateWarpPacket(data)} end }
    o._idx = 1
    o._type = 'Warp'

    setmetatable(o._to_send,
        { __index = function() return function() return {} end end })

    return o
end

--------------------------------------------------------------------------------
function Warp:OnIncomingData(id, pkt)
    -- TODO failure condition? 0x052 with 5th byte set differently?
    if id == 0x052 then
        self._on_success()
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------------
function Warp:_GeneratePackets(data)
    local pkts = self._to_send[self._idx](data)
    self._idx = self._idx + 1
    return pkts
end

--------------------------------------------------------------------------------
function Warp:__call(data)
    local pkts = self:_GeneratePackets(data)
    for _, pkt in pairs(pkts) do
        packets.inject(pkt)
    end
end

return Warp
