local NilCommand = require('command/nil')
local EntityFactory = require('model/entity/factory')
local DialogueFactory = require('model/dialogue/factory')


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local BuyCommand = NilCommand:NilCommand()
BuyCommand.__index = BuyCommand

--------------------------------------------------------------------------------
function BuyCommand:BuyCommand(id, idx, zone, count)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._id = id
    o._idx = idx
    o._zone = zone
    o._count = count
    o._type = 'BuyCommand'

    o._dialogue = DialogueFactory.CreateBuyDialogue(EntityFactory.CreateMob(o._id, o._zone),
        EntityFactory.CreatePlayer(), o._idx, o._count)
    o._dialogue:SetSuccessCallback(function() o._on_success() end)
    o._dialogue:SetFailureCallback(function() o._on_failure() end)

    return o
end

--------------------------------------------------------------------------------
function BuyCommand:OnIncomingData(id, pkt)
    return self._dialogue:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
function BuyCommand:OnOutgoingData(id, pkt)
    return self._dialogue:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function BuyCommand:IsSimple()
    return false
end

--------------------------------------------------------------------------------
function BuyCommand:__call(state)
    self._dialogue:Start()
end

return BuyCommand