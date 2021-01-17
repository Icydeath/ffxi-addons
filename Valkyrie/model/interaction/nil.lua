--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilInteraction = {}
NilInteraction.__index = NilInteraction

--------------------------------------------------------------------------------
function NilInteraction:NilInteraction()
    local o = {}
    setmetatable(o, self)
    o._on_success = function() end
    o._on_failure = function() end
    o._type = 'NilInteraction'
    return o
end

--------------------------------------------------------------------------------
function NilInteraction:SetSuccessCallback(f)
    self._on_success = f
end

--------------------------------------------------------------------------------
function NilInteraction:SetFailureCallback(f)
    self._on_failure = f
end

--------------------------------------------------------------------------------
function NilInteraction:OnIncomingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilInteraction:OnOutgoingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilInteraction:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilInteraction:__call()
    self._on_success()
end

return NilInteraction
