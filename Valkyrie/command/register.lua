local NilCommand = require('command/nil')
local EntityFactory = require('model/entity/factory')
local DialogueFactory = require('model/dialogue/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local RegisterCommand = NilCommand:NilCommand()
RegisterCommand.__index = RegisterCommand

--------------------------------------------------------------------------------
function RegisterCommand:RegisterCommand(id, chamber, lamp)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._id = id
    o._chamber = chamber
    o._lamp = lamp
    o._type = 'RegisterCommand'
    o._dialogue = DialogueFactory.CreateRegisterDialogue(
        EntityFactory.CreateMob(o._id),
        EntityFactory.CreatePlayer(), o._chamber, o._lamp)
    o._dialogue:SetSuccessCallback(function() o._on_success() end)
    o._dialogue:SetFailureCallback(function() o._on_failure() end)
    return o
end

--------------------------------------------------------------------------------
function RegisterCommand:OnIncomingData(id, pkt)
    return self._dialogue:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
function RegisterCommand:OnOutgoingData(id, pkt)
    return self._dialogue:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function RegisterCommand:__call(state)
    self._dialogue:Start()
end

return RegisterCommand
