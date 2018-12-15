local NilPurchase = require('model/action/nil_purchase')

--------------------------------------------------------------------------------
local function CreateActionPacket(target)
    local pkt = packets.new('outgoing', 0x01A)
    pkt['Target'] = target:Npc()
    pkt['Target Index'] = target:Entity():Index()
    return pkt
end

--------------------------------------------------------------------------------
local function CreateDialogChoicePacket(target, option, zone, automated)
    local pkt = packets.new('outgoing', 0x05B)
    pkt['Target'] = target:Npc()
    pkt['Option Index'] = option
    pkt['Target Index'] = target:Entity():Index()
    pkt['Automated Message'] = automated
    pkt['Zone'] = zone
    pkt['Menu ID'] = target:Menu()
    return pkt
end

--------------------------------------------------------------------------------
local function CreateDialogChoicePackets(target, item, zone, count)
    local to_send = {}
    to_send[1] = CreateDialogChoicePacket(target, 10, zone, true)
    to_send[2] = CreateDialogChoicePacket(target, item:Option(), zone, true)
    to_send[3] = CreateDialogChoicePacket(target, count * (2^13) + item:Option() + 1, zone, true)
    to_send[4] = CreateDialogChoicePacket(target, 0, zone, false)
    return to_send
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ValidPurchase = NilPurchase:NilPurchase()
ValidPurchase.__index = ValidPurchase

--------------------------------------------------------------------------------
function ValidPurchase:ValidPurchase(key, vendor, zone, count)
    local o = {}
    setmetatable(o, self)
    o._type = 'ValidPurchase'
    o._index = 1
    o._packets = {[1] = {CreateActionPacket(vendor)}, [2] = CreateDialogChoicePackets(vendor, key, zone, count), [3] = {}}
    return o
end

--------------------------------------------------------------------------------
function ValidPurchase:_get_packets()
    local pkts = self._packets[self._index]
    self._index = math.min(self._index + 1, 3)
    return pkts
end

--------------------------------------------------------------------------------
function ValidPurchase:__call()
    for _, pkt in pairs(self:_get_packets()) do
        packets.inject(pkt)
    end
    return self._index < 3
end

return ValidPurchase
