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

local world_mt = {
    __index = function (_, k)
        return k == 'zone_id' and windower.ffxi.get_info().zone or nil
    end,
}

return setmetatable({}, world_mt)

