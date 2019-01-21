local NilCommand = require('command/nil')
local EntityFactory = require('model/entity/factory')
local DialogueFactory = require('model/dialogue/factory')


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local UseCommand = NilCommand:NilCommand()
UseCommand.__index = UseCommand

--------------------------------------------------------------------------------
function UseCommand:UseCommand(id, item_id, zone)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._id = id
    o._item_id = item_id
    o._zone = zone
    o._type = 'UseCommand'

    o:Reset()

    return o
end

--------------------------------------------------------------------------------
function UseCommand:OnIncomingData(id, pkt)
    return self._dialogue:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
function UseCommand:OnOutgoingData(id, pkt)
    return self._dialogue:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function UseCommand:Reset()
    self._dialogue = DialogueFactory.CreateUseDialogue(
        EntityFactory.CreateMob(self._id, self._zone),
        EntityFactory.CreatePlayer(), self._item_id)
    self._dialogue:SetSuccessCallback(function(reward) self._on_success(reward) end)
    self._dialogue:SetFailureCallback(function() self._on_failure() end)
end

--------------------------------------------------------------------------------
function UseCommand:IsSimple()
    return false
end

--------------------------------------------------------------------------------
function UseCommand:IsRepeatable()
    return true
end

--------------------------------------------------------------------------------
function UseCommand:__call(state)
    self._dialogue:Start()
end

return UseCommand