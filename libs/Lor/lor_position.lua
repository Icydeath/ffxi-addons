--[[
    Position object
    
    Author: Ragnarok.Lorand
--]]

local lor_position = {}
lor_position._author = 'Ragnarok.Lorand'
lor_position._version = '2018.05.20.0'

require('lor/lor_utils')
_libs.lor.req('ffxi')
_libs.lor.position = lor_position

local quadrants = {NW = {-1, 1}, SW = {1, -1}, NE = {0, -1}, SE = {0, 1} }
local ffxi = _libs.lor.ffxi


function lor_position.new(...)
    local self = {pos={}}
    local tempPos = {}
    local args = {...}
    if type(args[1]) == 'table' then
        tempPos = args[1]
    else
        tempPos = args
    end
    
    self.pos.x = tempPos.x or tempPos[1] or 0
    self.pos.y = tempPos.y or tempPos[2] or 0
    self.pos.z = tempPos.z or tempPos[3] or 0
    return setmetatable(self, {__index = lor_position, __eq = lor_position.equals, __tostring = lor_position.toString})
end

function lor_position.of(targ)
    local mob = ffxi.get_target(targ or 'me')
    if (mob ~= nil) then
        return lor_position.new(mob.x, mob.y, mob.z)
    end
    return nil
end

function lor_position.current_position()
    local mob = windower.ffxi.get_mob_by_target('me')
    if mob ~= nil then
        return lor_position.new(mob.x, mob.y, mob.z)
    end
    return nil
end

function lor_position:x()
    return self.pos.x
end

function lor_position:y()
    return self.pos.y
end

function lor_position:z()
    return self.pos.z
end

function lor_position:equals(other)
    if other == nil then return nil end
    return (self.pos.x == other:x()) and (self.pos.y == other:y()) and (self.pos.z == other:z())
end

function lor_position:getDistance(other)
    if other == nil then return nil end
    local dx = self.pos.x - other:x()
    local dy = self.pos.y - other:y()
    return math.sqrt((dx^2)+(dy^2))
end

local function roundPos(pos)
    return math.floor(pos*100)/100
end

function lor_position:toString()
    return ('(%s,%s,%s)'):format(roundPos(self.pos.x), roundPos(self.pos.y), roundPos(self.pos.z))
end

--[[
	Returns the quandrant in which the given point lies
--]]
local function getQuadrant(x, y)
	if (not x) or (not y) then return nil end
	local quad = (y > 0 and 'S' or 'N')
	quad = quad .. (x > 0 and 'W' or 'E')
	return quad
end


--[[
	Returns the direction in radians to face position other from this position
--]]
function lor_position:getDirRadian(other)
    if not other then return nil end
    local dx = self.pos.x - other:x()
    local dy = self.pos.y - other:y()
    local quad = getQuadrant(dx, dy)
	local theta = math.atan(math.abs(dy)/math.abs(dx))
	local phi = (math.pi * quadrants[quad][1]) + (theta * quadrants[quad][2])
	return phi
end


return lor_position

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2018, Ragnarok.Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of libs/lor nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------
