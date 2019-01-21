local NilCommand = require('command/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local ConfigCommand = NilCommand:NilCommand()
ConfigCommand.__index = ConfigCommand

--------------------------------------------------------------------------------
function ConfigCommand:ConfigCommand(setting, value)
    local o = NilCommand:NilCommand()
    setmetatable(o, self)
    o._setting = setting
    o._value = value
    o._type = 'ConfigCommand'
    return o
end

--------------------------------------------------------------------------------
function ConfigCommand:__call(state)
    settings.config[self._setting] = self._value
    settings.save()
    log(self._setting .. ' is now ' .. (self._value and 'on' or 'off'))
end

return ConfigCommand