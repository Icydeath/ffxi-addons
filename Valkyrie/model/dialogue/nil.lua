--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilDialogue = {}
NilDialogue.__index = NilDialogue

--------------------------------------------------------------------------------
function NilDialogue:NilDialogue()
    local o = {}
    setmetatable(o, self)
    o._on_failure = function() end
    o._on_success = function() end
    o._type = 'NilDialogue'

    return o
end

--------------------------------------------------------------------------------
function NilDialogue:SetSuccessCallback(f)
    self._on_success = f
end

--------------------------------------------------------------------------------
function NilDialogue:SetFailureCallback(f)
    self._on_failure = f
end

--------------------------------------------------------------------------------
function NilDialogue:OnIncomingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilDialogue:OnOutgoingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilDialogue:Start()
    self._on_failure()
end

--------------------------------------------------------------------------------
function NilDialogue:Type()
    return self._type
end

return NilDialogue
