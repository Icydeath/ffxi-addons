--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot cure handling functions
--]]
--==============================================================================

local cu = {cure_types={'cure','waltz','curaga','waltzga'} }
local Pos = _libs.lor.position
local ffxi = _libs.lor.ffxi

--==============================================================================
--                  Static Cure Information
--==============================================================================
cu.cure = {
    [1] = {id=1,    en='Cure',              res=res.spells[1]},
    [2] = {id=2,    en='Cure II',           res=res.spells[2]},
    [3] = {id=3,    en='Cure III',          res=res.spells[3]},
    [4] = {id=4,    en='Cure IV',           res=res.spells[4]},
    [5] = {id=5,    en='Cure V',            res=res.spells[5]},
    [6] = {id=6,    en='Cure VI',           res=res.spells[6]}
}
cu.curaga = {
    [1] = {id=7,    en='Curaga',            res=res.spells[7]},
    [2] = {id=8,    en='Curaga II',         res=res.spells[8]},
    [3] = {id=9,    en='Curaga III',        res=res.spells[9]},
    [4] = {id=10,   en='Curaga IV',         res=res.spells[10]},
    [5] = {id=11,   en='Curaga V',          res=res.spells[11]}
}
cu.waltz = {
    [1] = {id=190,  en='Curing Waltz',      res=res.job_abilities[190]},
    [2] = {id=191,  en='Curing Waltz II',   res=res.job_abilities[191]},
    [3] = {id=192,  en='Curing Waltz III',  res=res.job_abilities[192]},
    [4] = {id=193,  en='Curing Waltz IV',   res=res.job_abilities[193]},
    [5] = {id=311,  en='Curing Waltz V',    res=res.job_abilities[311]}
}
cu.waltzga = {
    [1] = {id=195,  en='Divine Waltz',      res=res.job_abilities[195]},
    [2] = {id=262,  en='Divine Waltz II',   res=res.job_abilities[262]}
}

function cu.init_cure_potencies()
    local potency_table = hb.config.cure_potency[healer.name] and hb.config.cure_potency[healer.name][healer.main_job] or hb.config.cure_potency.default
    for spell_group,_ in pairs(potency_table) do
        for spell_tier,_ in pairs(cu[spell_group]) do
            cu[spell_group][spell_tier].hp = potency_table[spell_group][spell_tier]
        end
    end
end


function cu.getDangerLevel(hpp)
    if (hpp <= 20) then
        return 3
    elseif (hpp <= 40) then
        return 2
    elseif (hpp <= 60) then
        return 1
    end
    return 0
end


--[[
    Returns a table with party members and how much hp they are missing
--]]
function cu.get_missing_hps()
    local targets = hb.getMonitoredPlayers()
    local hpTable = {}
    for _,trg in pairs(targets) do
        local hpMissing = 0
        if (trg.hp ~= nil) then
            hpMissing = math.ceil((trg.hp/(trg.hpp/100))-trg.hp)
        else --If the player doesn't have a hp field, guesstimate how much they are missing
            hpMissing = 1500 - math.ceil((trg.hpp/100)*1500)
        end
        hpTable[trg.name] = {['missing']=hpMissing, ['hpp']=trg.hpp}
    end
    return hpTable
end


function cu.injured_pt_members()
    local party_members = ffxi.party_member_names()
    local injured = {}
    for _,trg in pairs(hb.getMonitoredPlayers()) do
        if trg.hpp < 95 and party_members:contains(trg.name) then
            local _hp = trg.hp or 1500   --Guesstimate if no value available
            local _missing
            if trg.hp ~= nil then
                _missing = math.ceil(((_hp/(trg.hpp/100))) - _hp)
            else
                _missing = _hp - math.ceil((trg.hpp/100)*_hp)
            end
            injured[trg.name] = {
                name = trg.name, hp = _hp, missing = _missing, hpp = trg.hpp,
                pos = Pos.of(trg.name),
                danger = cu.getDangerLevel(trg.hpp)
            }
        end
    end
    return injured
end


function cu.get_weighted_curaga_hp(members_info, names)
    local hp, missing, c = 0, 0, 0
    local name_set = S(names)
    for name, minfo in pairs(members_info) do
        if name_set:contains(name) then
            local d = minfo.danger + 1
            missing = missing + (minfo.missing * d)
            hp = hp + (minfo.hp * d)
            c = c + d
        end
    end
    return missing / c, hp / c
end


function cu.pick_best_curaga_possibility()
    local too_few = settings.healing.curaga_min_targets
    local members = cu.injured_pt_members()
    local member_count = sizeof(members)
    if member_count < too_few then return nil end
    local best = {}
    local coverage, distances = LT(), LT()
    for memberA, a in pairs(members) do
        if a then
            coverage[memberA] = LT{memberA}
            distances[memberA] = LT()
            for memberB, b in pairs(members) do
                if b then
                    if memberA ~= memberB then
                        local dist = a.pos:getDistance(b.pos)
                        distances[memberA]:insert(dist)
                        if dist < 10 then
                            coverage[memberA]:insert(memberB)
                        end
                    end
                end
            end
            local furthest = distances[memberA]:max()
            local avg_dist = distances[memberA]:sum() / distances[memberA]:size()
            local farA = {memberA, furthest}
            local avgA = {memberA, avg_dist}
            local covA = {memberA, coverage[memberA]}
            best.far = best.far or farA
            best.far = (furthest < best.far[2]) and farA or best.far
            best.avg = best.avg or avgA
            best.avg = (avg_dist < best.avg[2]) and avgA or best.avg
            best.cov = best.cov or covA
            best.cov = (coverage[memberA]:size() > best.cov[2]:size()) and covA or best.cov
            if furthest < 10 then break end    --Everyone is close enough
        end
    end
    if best.cov[2]:size() < too_few then return nil end
    local best_cov_count = best.cov[2]:size()
    local best_target
    if coverage[best.far[1]]:size() == best_cov_count then
        best_target = best.far[1]
    elseif coverage[best.avg[1]]:size() == best_cov_count then
        best_target = best.avg[1]
    else
        best_target = best.cov[1]
    end
    local w_missing, w_hpp = cu.get_weighted_curaga_hp(members, coverage[best_target])
    local tier = cu.get_cure_tier_for_hp(w_missing, settings.healing.modega)
    local min_hpp = 100
    for _,name in pairs(coverage[best_target]) do
        min_hpp = min(min_hpp, members[name].hpp)
    end
    min_hpp = min_hpp * 0.7 --add extra weight
    local target = {name=best_target, missing=w_missing, hpp=min_hpp}
    return cu.get_usable_cure(tier, settings.healing.modega), target
end


function cu.get_cure_queue()
    local cq = ActionQueue.new()
    local hp_table = cu.get_missing_hps()
    for name,p in pairs(hp_table) do
        if p.hpp < 95 then
            local tier = cu.get_cure_tier_for_hp(p.missing, settings.healing.mode)
            if tier >= settings.healing.min[settings.healing.mode] then
                local spell = cu.get_usable_cure(tier, settings.healing.mode)
                if spell ~= nil then
                    cq:enqueue('cure', spell, name, p.hpp, (' (%s)'):format(p.missing))
                end
            end
        end
    end
    if (not settings.disable.curaga) and (settings.healing.max[settings.healing.modega] > 0) then
        local spell, p = cu.pick_best_curaga_possibility()
        if spell ~= nil then
            cq:enqueue('cure', spell, p.name, p.hpp, (' (%s)'):format(p.missing))
        end
    end
    return cq:getQueue()
end

--[[
    Determines the MP/TP multiplier in effect for the given cure_type based on job and active buffs.
--]]
function cu.get_multiplier(cure_type)
    local mult = 1
    if cure_type:startswith('waltz') then
        if healer:buff_active('Trance') then
            mult = 0
        end
    else --it starts with 'cur'
        local p = windower.ffxi.get_player()
        if (p.main_job == 'BLM') and healer:buff_active('Manafont') then
            mult = 0
        elseif healer:buff_active('Manawell') then
            mult = 0
        elseif S{p.main_job, p.sub_job}:contains('SCH') then
            if healer:buff_active('Light Arts','Addendum: White') then
                mult = healer:buff_active('Penury') and 0.5 or 0.9
            elseif healer:buff_active('Dark Arts','Addendum: Black') then
                mult = 1.1
            end
        end
    end
    return mult
end


--[[
    Determines the tier of cure_type to use for the given amount of missing HP.
    Whether or not to accept this tier, based on settings.healing.min[cure_type], is handled elsewhere.
--]]
function cu.get_cure_tier_for_hp(hp_missing, cure_type)
    local tier = settings.healing.max[cure_type]
    while tier > 1 do
        local potency = cu[cure_type][tier].hp
        local pdelta = potency - cu[cure_type][tier-1].hp
        local threshold = potency - (pdelta * 0.5)
        if hp_missing >= threshold then
            break
        end
        tier = tier - 1
    end
    return tier
end


--[[
    Returns resource info for the chosen cure/waltz tier
--]]
function cu.get_usable_cure(orig_tier, cure_type)
    if orig_tier < settings.healing.min[cure_type] then return nil end
    
    local player = windower.ffxi.get_player()
    local mult = cu.get_multiplier(cure_type)
    local _p, recasts
    if cure_type:startswith('waltz') then
        _p = 'tp'
        recasts = windower.ffxi.get_ability_recasts()
    else --it starts with 'cur'
        _p = 'mp'
        recasts = windower.ffxi.get_spell_recasts()
    end
    
    local tier = orig_tier
    while tier > 1 do
        local action = cu[cure_type][tier].res
        local rctime = recasts[action.recast_id] or 0               --Cooldown remaining for current tier
        local mod_cost = action[_p..'_cost'] * mult                 --Modified cost of current tier in MP/TP
        if (mod_cost <= player.vitals[_p]) and (rctime == 0) then   --Sufficient MP/TP and cooldown is ready
            return action
        end
        tier = tier - 1
    end
    return nil
end


--[[
    Returns the tier of the highest usable spell of type cure_type
--]]
function cu.highest_tier(cure_type)
    local highest = 0
    for tier,spell in pairs(cu[cure_type]) do
        if healer:can_use(spell.res) then
            highest = (tier > highest) and tier or highest
        end
    end
    return highest
end


return cu

--==============================================================================
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
--==============================================================================
