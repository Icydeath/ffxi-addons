local NilMenu = require('model/menu/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local WarpMenu = NilMenu:NilMenu()
WarpMenu.__index = WarpMenu

--------------------------------------------------------------------------------
function WarpMenu:WarpMenu(id, choices)
    local o = NilMenu:NilMenu()
    setmetatable(o, self)

    o._id = id
    o._choices = {}
    o._type = 'WarpMenu'

    for _, value in pairs(choices) do
        o._choices[value] = { option = value * (2^5) + 1, automated = false, uk1 = 0 }
    end

    setmetatable(o._choices,
        { __index = function() return NilMenu.OptionFor(o) end })

    return o
end

--------------------------------------------------------------------------------
function WarpMenu:OptionFor(id)
    return self._choices[id]
end

return WarpMenu