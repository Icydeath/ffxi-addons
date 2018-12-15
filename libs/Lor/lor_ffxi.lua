--[[
    Resource info

    Author: Ragnarok.Lorand
--]]

local lor_ffxi = {}
lor_ffxi._author = 'Ragnarok.Lorand'
lor_ffxi._version = '2018.05.20.0'

require('lor/lor_utils')
_libs.lor.ffxi = lor_ffxi


function lor_ffxi.get_target(targ)
    if targ == nil then
        return nil
    elseif istable(targ) then
        return targ
    elseif tonumber(targ) and (tonumber(targ) > 255) then
        return windower.ffxi.get_mob_by_id(tonumber(targ))
    elseif S{'<me>', 'me'}:contains(targ) then
        return windower.ffxi.get_mob_by_target('me')
    elseif targ == '<t>' then
        return windower.ffxi.get_mob_by_target()
    elseif isstr(targ) then
        local target = windower.ffxi.get_mob_by_name(targ)
        return target or windower.ffxi.get_mob_by_name(targ:ucfirst())
    end
    return nil
end


function lor_ffxi.target_is_valid(action, target)
    -- Returns true if the given target's type is included in the list of valid targets for the given spell/ability.
    if (type(target) == 'string') then
        target = lor_ffxi.get_target(target)
    end
    if target == nil then return false end
    local stype = target.spawn_type

    local targetType = 'None'
    if target.is_npc and (stype ~= 14) then
        targetType = 'Enemy'
    elseif target.in_alliance then
        if target.in_party then
            local player = windower.ffxi.get_player()
            targetType = (player.name == target.name) and 'Self' or 'Party'
        else
            targetType = 'Ally'
        end
    else
        --targetType = 'Player'
        targetType = 'Ally' --Workaround for incorrect entries in resources
    end
    return S(action.targets):contains(targetType)
end


function lor_ffxi.party_member_names()
    local pt = windower.ffxi.get_party()
    local party = S{}
    for i = 0, 5 do
        local member = pt['p'..i]
        if member ~= nil then
            party:add(member.name)
        end
    end
    return party
end


function lor_ffxi.get_party_member(name)
    local party = windower.ffxi.get_party()
    for _,pmember in pairs(party) do
        if (type(pmember) == 'table') and (pmember.name == name) then
            return pmember
        end
    end
    return nil
end


return lor_ffxi

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
