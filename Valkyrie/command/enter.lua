local NilCommand = require('command/nil')
local EntityFactory = require('model/entity/factory')
local DialogueFactory = require('model/dialogue/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local EnterCommand = NilCommand:NilCommand()
EnterCommand.__index = EnterCommand

--------------------------------------------------------------------------------
function EnterCommand:EnterCommand(id, lamp)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._id = id
    o._lamp = lamp
    o._type = 'EnterCommand'
    o._dialogue = DialogueFactory.CreateEnterDialogue(
        EntityFactory.CreateMob(o._id),
        EntityFactory.CreatePlayer(), o._lamp)
    o._dialogue:SetSuccessCallback(function() o._on_success() end)
    o._dialogue:SetFailureCallback(function() o._on_failure() end)
    return o
end

--------------------------------------------------------------------------------
function EnterCommand:OnIncomingData(id, pkt)
    return self._dialogue:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
function EnterCommand:OnOutgoingData(id, pkt)
    return self._dialogue:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function EnterCommand:__call(state)
    self._dialogue:Start()
end

return EnterCommand
