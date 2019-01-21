--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local NilCommand = {}
NilCommand.__index = NilCommand

--------------------------------------------------------------------------------
function NilCommand:NilCommand()
    local o = {}
    setmetatable(o, self)
    o._on_success = function() end
    o._on_failure = function() end
    o._type = 'NilCommand'
    return o
end

--------------------------------------------------------------------------------
function NilCommand:SetSuccessCallback(f)
    self._on_success = f
end

--------------------------------------------------------------------------------
function NilCommand:SetFailureCallback(f)
    self._on_failure = f
end

--------------------------------------------------------------------------------
function NilCommand:OnIncomingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilCommand:OnOutgoingData(id, pkt)
    return false
end

--------------------------------------------------------------------------------
function NilCommand:Type()
    return self._type
end

--------------------------------------------------------------------------------
function NilCommand:__call()
    self._on_success()
    self._on_success = function() end
    self._on_failure = function() end
end

return NilCommand