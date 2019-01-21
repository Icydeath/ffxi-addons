local config = require('config')

local settings = {}
settings.config = {}

--------------------------------------------------------------------------------
-- Generate default values for the addon.
--
-- Returns a dicitionary with defaulted values.
--
local function defaults()
    local defaults = {}
    defaults.maxdistance = 25.0

    return defaults
end

--------------------------------------------------------------------------------
-- Load addon configuration.
--
function settings.load()
    settings.config = config.load('data\\settings.xml', defaults())
end

--------------------------------------------------------------------------------
-- Saves addon configuration.
--
function settings.save()
    config.save(settings.config)
end

return settings