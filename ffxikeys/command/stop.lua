local NilCommand = require('command/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local StopCommand = NilCommand:NilCommand()
StopCommand.__index = StopCommand

--------------------------------------------------------------------------------
function StopCommand:StopCommand()
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._type = 'StopCommand'
    return o
end

--------------------------------------------------------------------------------
function StopCommand:__call(state)
    log('Stopping')
    state.command._on_success = state.command._on_failure
end

return StopCommand