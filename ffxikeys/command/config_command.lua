local NilCommand = require('command/nil_command')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ConfigCommand = NilCommand:NilCommand()
ConfigCommand.__index = ConfigCommand

--------------------------------------------------------------------------------
function ConfigCommand:ConfigCommand(setting)
    local o = {}
    setmetatable(o, self)
    o._setting = tostring(setting)
    o._type = 'ConfigCommand'
    return o
end

--------------------------------------------------------------------------------
function ConfigCommand:__call(_)
    settings.config[self._setting] = not settings.config[self._setting]
    settings.save()
    return true
end

return ConfigCommand
