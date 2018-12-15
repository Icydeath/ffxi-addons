--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot action queue building & handling functions
--]]
--==============================================================================

local compFunc = {}
ActionQueue = {}


function ActionQueue.new()
    local self = {queue=Q({})}
    return setmetatable(self, {__index = ActionQueue})
end


function ActionQueue:getQueue()
    return self.queue
end


function ActionQueue:enqueue(actionType, action, name, secondary, msg)
    --atcf('ActionQueue:enqueue(%s, %s, %s, %s, %s)', tostring(actionType), tostring(action), tostring(name), tostring(secondary), tostring(msg))
    local is_cure = actionType:startswith('cur')
    local secLabel = is_cure and 'hpp' or actionType
    local pprio = getPlayerPriority[name]
    if is_cure and actionType == 'curaga' then
        pprio = pprio + 2
    end
    local qable = {['type']=actionType,['action']=action,['name']=name,[secLabel]=secondary,['msg']=msg,['prio']=pprio}
    if self.queue:empty() then
        self.queue:insert(1,qable)
    else
        local highestAbove = 999
        for index = 1, self.queue:length() do
            local qi = self.queue[index]
            local qprio = getPlayerPriority[qi.name]
            local higher = compFunc[actionType](-1, pprio, secondary, index, qprio, qi[secLabel])
            if (higher == -1) and (index < highestAbove) then
                highestAbove = index
            end
        end
        if (highestAbove ~= 999) then
            self.queue:insert(highestAbove,qable)
        else
            local last = self.queue:length()+1
            self.queue:insert(last,qable)
        end
    end
end


function compFunc.default(index1, pa1, pb1, index2, pa2, pb2)
--local function _default(index1, pa1, pb1, index2, pa2, pb2)
    --atcf('compFunc.default(%s, %s, %s, %s, %s, %s)', tostring(index1), tostring(pa1), tostring(pb1), tostring(index2), tostring(pa2), tostring(pb2))
    if (pa1 < pa2) then         --p1 is higher priority
        if (pb2 < pb1) then     --action 2 is higher priority
            return index2
        else                    --action 2 is same or lower priority
            return index1
        end
    elseif (pa1 > pa2) then     --p2 is higher priority
        if (pb1 < pb2) then     --action 1 is higher priority
            return index1
        else                    --action 1 is same or lower priority
            return index2
        end
    else                        --same priority
        if (pb2 < pb1) then     --action 2 is higher priority
            return index2
        else                    --action 2 is same or lower priority
            return index1
        end
    end
end
--compFunc.default = traceable(_default)


function compFunc.buff(index1, prio1, buff1, index2, prio2, buff2)
    --atcf('compFunc.buff(%s, %s, %s, %s, %s, %s)', tostring(index1), tostring(prio1), tostring(buff1), tostring(index2), tostring(prio2), tostring(buff2))
    local bp1 = getBuffPriority(buff1)
    local bp2 = getBuffPriority(buff2)
    return compFunc.default(index1, prio1, bp1, index2, prio2, bp2)
end


function compFunc.debuff(index1, prio1, debuff1, index2, prio2, debuff2)
    --atcf('compFunc.debuff(%s, %s, %s, %s, %s, %s)', tostring(index1), tostring(prio1), tostring(debuff1), tostring(index2), tostring(prio2), tostring(debuff2))
    local rp1 = getRemovalPriority(debuff1)
    local rp2 = getRemovalPriority(debuff2)
    return compFunc.default(index1, prio1, rp1, index2, prio2, rp2)
end


function compFunc.debuff_mob(index1, prio1, debuff1, index2, prio2, debuff2)
    --atcf('compFunc.debuff_mob(%s, %s, %s, %s, %s, %s)', tostring(index1), tostring(prio1), tostring(debuff1), tostring(index2), tostring(prio2), tostring(debuff2))
    local dbp1 = getDebuffPriority(debuff1)
    local dbp2 = getDebuffPriority(debuff2)
    return compFunc.default(index1, prio1, dbp1, index2, prio2, dbp2)
end


function compFunc.cure(index1, prio1, hpp1, index2, prio2, hpp2)
    local d1 = CureUtils.getDangerLevel(hpp1)
    local d2 = CureUtils.getDangerLevel(hpp2)
    if (prio1 < prio2) then     --p1 is higher priority
        if (d2 > d1) then       --p2 is in more danger
            return index2
        else                    --p2 is in same or less danger
            return index1
        end
    elseif (prio1 > prio2) then --p2 is higher priority
        if (d1 > d2) then       --p1 is in more danger
            return index1
        else                    --p1 is in same or less danger
            return index2
        end
    else                        --same priority
        if (d2 > d1) then       --p2 is in more danger
            return index2
        elseif (d1 > d2) then   --p1 is in more danger
            return index1
        else                    --same danger
            if (hpp1 < hpp2) then
                return index1
            else
                return index2
            end
        end
    end
end


local function _getPlayerPriority(tname)
    if (tname == healer.name) then
        return 1
    end
    local prios = hb.config.priorities
    local player_mob = windower.ffxi.get_mob_by_name(tname)
    if player_mob == nil then
        return prios.default
    end
    if player_mob.spawn_type == 14 then     --Trust
        return prios.default + 1
    end
    local pmInfo = hb.partyMemberInfo[tname]
    local jobprio = prios.default
    if pmInfo ~= nil then
        jobprio = prios.jobs[pmInfo.job] or prios.jobs[pmInfo.job:lower()] or jobprio
    end
    local playerprio = prios.players[tname] or prios.players[tname:lower()] or prios.default
    return math.min(jobprio, playerprio)
end
getPlayerPriority = _libs.lor.advutils.scached(_getPlayerPriority)


function getBuffPriority(buff)
--local function _getBuffPriority(buff)
    --atcf('getBuffPriority(%s)', tostring(buff))
    local nbuff = buffs.buff_for_action(buff)
    local prios = hb.config.priorities

    if nbuff == nil then
        atcfs('Was unable to retrieve buff for action for %s', buff)
        return prios.default
    end

    return prios.buffs[nbuff.en] or prios.buffs[nbuff.enn] or prios.default
end
--getBuffPriority = traceable(_getBuffPriority)


function getRemovalPriority(ailment)
    local debuff = utils.normalize_action(ailment, 'buffs')
    local prios = hb.config.priorities
    return prios.status_removal[debuff.en] or prios.status_removal[debuff.enn] or prios.default
end


function getDebuffPriority(debuff)
    local ndebuff = utils.normalize_action(debuff, 'buffs')
    local prios = hb.config.priorities
    return prios.debuffs[ndebuff.en] or prios.debuffs[ndebuff.enn] or prios.default
end


--======================================================================================================================
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the
      following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
      following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
--]]
--======================================================================================================================
