--[[
Copyright 2019 Seth VanHeulen

This file is part of lockpick.

lockpick is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

lockpick is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with lockpick.  If not, see <https://www.gnu.org/licenses/>.
--]]

-- luacheck: std luajit, globals windower

-- extra libraries
local config = require('config')

local options
local defaults = {client_path='C:/Program Files (x86)/PlayOnline/SquareEnix/FINAL FANTASY XI/'}

local windower_mt = {
    __index = function (_, k)
        if k == 'client_path' then
            if windower.ffxi.get_info().logged_in then
                if not options then
                    options = config.load('data/client_path.xml', defaults)
                end
                return options.client_path
            end
            return defaults.client_path
        end
    end,
}

return setmetatable({}, windower_mt)

