--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot packet handling functions
--]]
--==============================================================================

local messages_blacklist = _libs.lor.packets.messages_blacklist
local messages_initiating = _libs.lor.packets.messages_initiating
local messages_completing = _libs.lor.packets.messages_completing

local get_action_info = _libs.lor.packets.get_action_info
local parse_char_update = _libs.lor.packets.parse_char_update


--[[
    Analyze the data contained in incoming packets for useful info.
    :param int id: packet ID
    :param data: raw packet contents
--]]
function handle_incoming_chunk(id, data)
    if S{0x28,0x29}:contains(id) then   --Action / Action Message
        local monitored_ids = hb.getMonitoredIds()
        local ai = get_action_info(id, data)
        healer:update_status(id, ai)
        if id == 0x28 then
            processAction(ai, monitored_ids)
        elseif id == 0x29 then
            processMessage(ai, monitored_ids)
        end
    elseif (id == 0x037) then
        healer.indi.info = parse_char_update(data)
    elseif (id == 0x0DD) then           --Party member update
        local parsed = packets.parse('incoming', data)
        local pmName = parsed.Name
        local pmJobId = parsed['Main job']
        local pmSubJobId = parsed['Sub job']
        hb.partyMemberInfo[pmName] = hb.partyMemberInfo[pmName] or {}
        hb.partyMemberInfo[pmName].job = res.jobs[pmJobId].ens
        hb.partyMemberInfo[pmName].subjob = res.jobs[pmSubJobId].ens
        --atc('Caught party member update packet for '..parsed.Name..' | '..parsed.ID)
    elseif (id == 0x0DF) then
        local player = windower.ffxi.get_player()
        local parsed = packets.parse('incoming', data)
        if (player ~= nil) and (player.id ~= parsed.ID) then
            local person = windower.ffxi.get_mob_by_id(parsed.ID)
            --atc('Caught char update packet for '..person.name)
        end
    end
end


--[[
    Process the information that was parsed from an action message packet
    :param ai: parsed action info
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function processMessage(ai, monitored_ids)
    if monitored_ids[ai.actor_id] or monitored_ids[ai.target_id] then
        if not (messages_blacklist:contains(ai.message_id)) then
            local target = windower.ffxi.get_mob_by_id(ai.target_id)
            
            if hb.modes.showPacketInfo then
                local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
                local msg = res.action_messages[ai.message_id] or {en='???'}
                local params = (', '):join(tostring(ai.param_1), tostring(ai.param_2), tostring(ai.param_3))
                atcfs('[0x29]Message(%s): %s { %s } %s %s | %s', ai.message_id, actor.name, params, rarr, target.name, msg.en)
            end
            
            if messages_wearOff:contains(ai.message_id) then
                if enfeebling:contains(ai.param_1) then
                    buffs.register_debuff(target, res.buffs[ai.param_1], false)
                else
                    buffs.register_buff(target, res.buffs[ai.param_1], false)
                end
            end
        end--/message ID not on blacklist
    end--/monitoring actor or target
end


--[[
    Process the information that was parsed from an action packet
    :param ai: parsed action info
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function processAction(ai, monitored_ids)
    for _,targ in pairs(ai.targets) do
        if monitored_ids[ai.actor_id] or monitored_ids[targ.id] then
            local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
            local target = windower.ffxi.get_mob_by_id(targ.id)
            
            for _,tact in pairs(targ.actions) do
                if not messages_blacklist:contains(tact.message_id) then
                    if (tact.message_id == 0) and (ai.actor_id == healer.id) then
                        if indi_spell_ids:contains(ai.param) then
                            healer.indi.latest = {spell = res.spells[ai.param], landed = os.clock(), is_indi = true}
                            buffs.register_buff(target, healer.indi.latest, true)
                        elseif geo_spell_ids:contains(ai.param) then
                            healer.geo.latest = {spell = res.spells[ai.param], landed = os.clock(), is_geo = true}
                            buffs.register_buff(target, healer.geo.latest, true)
                        end
                    end
                
                    -- if (tact.message_id == 0) and (actor.name == healer.name) then
                        -- local spell = res.spells[ai.param]
                        -- if spell ~= nil then
                            -- if spell.type == 'Geomancy' then
                                -- register_action(spell.type, ai.param)
                            -- end
                        -- end
                    -- end
                
                    if hb.modes.showPacketInfo then
                        local msg = res.action_messages[tact.message_id] or {en='???'}
                        atcfs('[0x28]Action(%s): %s { %s } %s %s { %s } | %s', tact.message_id, actor.name, ai.param, rarr, target.name, tact.param, msg.en)
                    end
                    
                    registerEffect(ai, tact, actor, target, monitored_ids)
                end--/message ID not on blacklist
            end--/loop through targ's actions
        end--/monitoring actor or target
    end--/loop through action's targets
end


--[[
    Register the effects that were discovered in an action packet
    :param ai: parsed action info
    :param tact: the subaction on a target
    :param actor: the PC/NPC initiating the action
    :param target: the PC/NPC that is the target of the action
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function registerEffect(ai, tact, actor, target, monitored_ids)
    local targ_is_enemy = (target.spawn_type == 16)
    if messages_magicDamage:contains(tact.message_id) then      --ai.param: spell; tact.param: damage
        local spell = res.spells[ai.param]
        if S{230,231,232,233,234}:contains(ai.param) then
            buffs.register_debuff(target, 'Bio', true, spell)
        elseif S{23,24,25,26,27,33,34,35,36,37}:contains(ai.param) then
            buffs.register_debuff(target, 'Dia', true, spell)
        end
    elseif messages_gainEffect:contains(tact.message_id) then   --ai.param: spell; tact.param: buff/debuff
        --{target} gains the effect of {buff} / {target} is {debuff}ed
        local cause = nil
        if msg_gain_abil:contains(tact.message_id) then
            cause = res.job_abilities[ai.param]
        elseif msg_gain_spell:contains(tact.message_id) then
            cause = res.spells[ai.param]
        elseif msg_gain_ws:contains(tact.message_id) then
            cause = res.weapon_skills[ai.param]
        end
        
        local buff = res.buffs[tact.param]
        if enfeebling:contains(tact.param) then
            buffs.register_debuff(target, buff, true, cause)
        else
            buffs.register_buff(target, buff, true, cause)
        end
    elseif messages_loseEffect:contains(tact.message_id) then   --ai.param: spell; tact.param: buff/debuff
        --{target}'s {buff} wore off
        local buff = res.buffs[tact.param]
        if enfeebling:contains(tact.param) then
            buffs.register_debuff(target, buff, false)
        else
            buffs.register_buff(target, buff, false)
        end
    elseif messages_noEffect:contains(tact.message_id) then     --ai.param: spell; tact.param: buff/debuff
        --Spell had no effect on {target}
        local spell = res.spells[ai.param]
        if (spell ~= nil) then
            if spells_statusRemoval:contains(spell.id) then
                --The debuff must have worn off or have been removed already
                local debuffs = removal_map[spell.en]
                if (debuffs ~= nil) then
                    for _,debuff in pairs(debuffs) do
                        buffs.register_debuff(target, debuff, false)
                    end
                end
            elseif spells_buffs:contains(spell.id) then
                --The buff must already be active, or there must be some debuff preventing the buff from landing
                local buff = buffs.buff_for_action(spell)
                if (buff == nil) then
                    atc(123, 'ERROR: No buff found for spell: '..spell.en)
                else
                    buffs.register_buff(target, buff, false)
                    if S{'Haste','Flurry'}:contains(buff.en) then
                        buffs.register_debuff(target, 'slow', true)
                    end
                end
            elseif spell_debuff_idmap[spell.id] ~= nil and targ_is_enemy then
                --The debuff already landed from someone else
                local debuff_id = spell_debuff_idmap[spell.id]
                buffs.register_debuff(target, debuff_id, true)
            end
        end
    elseif messages_specific_debuff_gain[tact.message_id] ~= nil then
        local gained_debuffs = messages_specific_debuff_gain[tact.message_id]
        for _,gained_debuff in pairs(gained_debuffs) do
            buffs.register_debuff(target, gained_debuff, true)
        end
    elseif messages_specific_debuff_lose[tact.message_id] ~= nil then
        local lost_debuffs = messages_specific_debuff_lose[tact.message_id]
        for _,lost_debuff in pairs(lost_debuffs) do
            buffs.register_debuff(target, lost_debuff, false)
        end
    elseif S{185}:contains(tact.message_id) then    --${actor} uses ${weapon_skill}.${lb}${target} takes ${number} points of damage.
        local mabil = res.monster_abilities[ai.param]
        if (mabil ~= nil) then
            if (hb.config.mabil_debuffs[mabil.en] ~= nil) then
                for dbf,_ in pairs(hb.config.mabil_debuffs[mabil.en]) do
                    buffs.register_debuff(target, dbf, true)
                end
            end
        end
    elseif S{655}:contains(tact.message_id) and targ_is_enemy then    --${actor} casts ${spell}.${lb}${target} completely resists the spell.
        offense.register_immunity(target, res.buffs[tact.param])
    elseif messages_paralyzed:contains(tact.message_id) then
        buffs.register_debuff(actor, 'paralysis', true)
    end--/message ID checks
end

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of healBot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------
