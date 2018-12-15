--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot buff handling functions
--]]
--==============================================================================

local buffs = {
    debuffList = {},
    buffList = {},
    ignored_debuffs = {},
    action_buff_map = lor_settings.load('data/action_buff_map.lua')
}
local lc_res = _libs.lor.resources.lc_res
local ffxi = _libs.lor.ffxi

--==============================================================================
--          Local Player Buff Checking
--==============================================================================

function buffs.checkOwnBuffs()
    local player = windower.ffxi.get_player()
    if player ~= nil then
        buffs.review_active_buffs(player, player.buffs)
    end
end


function buffs.review_active_buffs(player, buff_list)
    if buff_list ~= nil then
        --Register everything that's actually active
        for _,bid in pairs(buff_list) do
            local buff = res.buffs[bid]
            if (enfeebling:contains(bid)) then
                buffs.register_debuff(player, buff, true)
            else
                buffs.register_buff(player, buff, true)
            end
        end
        
        --Double check the list of what should be active
        local checklist = buffs.buffList[player.name] or {}
        local active = S(buff_list)
        for bname,binfo in pairs(checklist) do
            if binfo.is_geo or binfo.is_indi then
                if binfo.is_geo and binfo.action then
                    local pet = windower.ffxi.get_mob_by_target('pet')
                    healer.geo.latest = healer.geo.latest or {}
                    if pet == nil then
                        buffs.register_buff(player, healer.geo.latest, false)
                    else
                        buffs.register_buff(player, healer.geo.latest, true)
                    end
                elseif binfo.is_indi and binfo.action then
                    healer.indi.info = healer.indi.info or {}
                    healer.indi.latest = healer.indi.latest or {}
                    buffs.register_buff(player, healer.indi.latest, healer.indi.info.active)
                end
            else
                if binfo.buff then                                              -- FIXME: Temporary fix for geo error
                    if not active:contains(binfo.buff.id) then
                        buffs.register_buff(player, res.buffs[binfo.buff.id], false)
                    end
                end
            end
        end
    end
end


--==============================================================================
--          Monitored Player Buff Checking
--==============================================================================


function buffs.getBuffQueue()
    local player = windower.ffxi.get_player()
    local activeBuffIds = S(player.buffs)
    local bq = ActionQueue.new()
    local now = os.clock()
    for targ, buffset in pairs(buffs.buffList) do
        for spell_name, info in pairs(buffset) do
            if (targ == healer.name) and (info.buff) then       -- FIXME: and info.buff = temp fix for geo issue
                if activeBuffIds:contains(info.buff.id) then
                    buffs.register_buff(player, res.buffs[info.buff.id], true)
                end
            end
            if (info.landed == nil) then
                if (info.attempted == nil) or ((now - info.attempted) >= 3) then
                    bq:enqueue('buff', info.action, targ, spell_name, nil)
                end
            end
        end
    end
    return bq:getQueue()
end


function buffs.getDebuffQueue()
    local dbq = ActionQueue.new()
    local now = os.clock()
    for targ, debuffs in pairs(buffs.debuffList) do
        for id, info in pairs(debuffs) do
            local debuff = res.buffs[id]
            local removalSpellName = debuff_map[debuff.en]
            if (removalSpellName ~= nil) then
                if (info.attempted == nil) or ((now - info.attempted) >= 3) then
                    local spell = res.spells:with('en', removalSpellName)
                    if healer:can_use(spell) and ffxi.target_is_valid(spell, targ) then
                        local ign = buffs.ignored_debuffs[debuff.en]
                        if not ((ign ~= nil) and ((ign.all == true) or ((ign[targ] ~= nil) and (ign[targ] == true)))) then
                            dbq:enqueue('debuff', spell, targ, debuff, ' ('..debuff.en..')')
                        end
                    end
                end
            else
                buffs.debuffList[targ][id] = nil
            end
        end
    end
    return dbq:getQueue()
end

--==============================================================================
--          Input Handling Functions
--==============================================================================


function buffs.registerNewBuff(args, use)
    local targetName = args[1] and args[1] or ''
    table.remove(args, 1)
    local arg_string = table.concat(args,' ')
    local snames = arg_string:split(',')
    for index,sname in pairs(snames) do
        if (tostring(index) ~= 'n') then
            buffs.registerNewBuffName(targetName, sname:trim(), use)
        end
    end
end


function buffs.registerNewBuffName(targetName, bname, use)
    local spellName = utils.formatActionName(bname)
    if (spellName == nil) then
        atc('Error: Unable to parse spell name')
        return
    end
    
    local me = windower.ffxi.get_player()
    local target = ffxi.get_target(targetName)
    if target == nil then
        atc('Unable to find buff target: '..targetName)
        return
    end
    local action = buffs.getAction(spellName, target)
    if (action == nil) then
        atc('Unable to cast or invalid: '..spellName)
        return
    end
    if not ffxi.target_is_valid(action, target) then
        atc(target.name..' is an invalid target for '..action.en)
        return
    end
    
    local monitoring = hb.getMonitoredPlayers()
    if (not (monitoring[target.name])) then
        monitorCommand('watch', target.name)
    end
    
    buffs.buffList[target.name] = buffs.buffList[target.name] or {}
    local buff = buffs.buff_for_action(action)
    if (buff == nil) then
        atc('Unable to match the buff name to an actual buff: '..bname)
        return
    end
    
    if use then
        buffs.buffList[target.name][action.en] = {['action']=action, ['maintain']=true, ['buff']=buff}
        if action.type == 'Geomancy' then
            if indi_spell_ids:contains(action.id) then
                buffs.buffList[target.name][action.en].is_indi = true
            elseif geo_spell_ids:contains(action.id) then
                buffs.buffList[target.name][action.en].is_geo = true
            end
        end
        atc('Will maintain buff: '..action.en..' '..rarr..' '..target.name)
    else
        buffs.buffList[target.name][action.en] = nil
        atc('Will no longer maintain buff: '..action.en..' '..rarr..' '..target.name)
    end
end


function buffs.registerIgnoreDebuff(args, ignore)
    local targetName = args[1] and args[1] or ''
    table.remove(args, 1)
    local arg_string = table.concat(args,' ')
    
    local msg = ignore and 'ignore' or 'stop ignoring'
    
    local dbname = debuff_casemap[arg_string:lower()]
    if (dbname ~= nil) then
        if S{'always','everyone','all'}:contains(targetName) then
            buffs.ignored_debuffs[dbname] = {['all']=ignore}
            atc('Will now '..msg..' '..dbname..' on everyone.')
        else
            local trgname = utils.getPlayerName(targetName)
            if (trgname ~= nil) then
                buffs.ignored_debuffs[dbname] = buffs.ignored_debuffs[dbname] or {['all']=false}
                if (buffs.ignored_debuffs[dbname].all == ignore) then
                    local msg2 = ignore and 'ignoring' or 'stopped ignoring'
                    atc('Ignore debuff settings unchanged. Already '..msg2..' '..dbname..' on everyone.')
                else
                    buffs.ignored_debuffs[dbname][trgname] = ignore
                    atc('Will now '..msg..' '..dbname..' on '..trgname)
                end
            else
                atc(123,'Error: Invalid target for ignore debuff: '..targetName)
            end
        end
    else
        atc(123,'Error: Invalid debuff name to '..msg..': '..arg_string)
    end
end


function buffs.getAction(actionName, target)
    local me = windower.ffxi.get_player()
    local action = nil
    local spell = res.spells:with('en', actionName)
    if (spell ~= nil) and healer:can_use(spell) then
        action = spell
    elseif (target ~= nil) and (target.id == me.id) then
        local abil = res.job_abilities:with('en', actionName)
        if (abil ~= nil) and healer:can_use(abil) then
            action = abil
        end
    end
    return action
end


function buffs.buff_for_action(action)
    local action_str = action
    if type(action) == 'string' then
        if action:startswith('Geo-') or action:startswith('Indi-') then
            action = lc_res.spells[action:lower()]
        end
    end
    if type(action) == 'table' then
        if action.type == 'Geomancy' then
            --This is a hack since there isn't a 1:1 relationship between geo spells and buffs
            return {id=-action.id, en=action.en, enl=action.en}
        end
    
        if buffs.action_buff_map[action.type] ~= nil then
            local mapped_id = buffs.action_buff_map[action.type][action.id]
            if mapped_id ~= nil then
                return res.buffs[mapped_id]
            end
        end
        if (action.type == 'JobAbility') then
            return res.buffs:with('en', action.en)
        end
        action_str = action.en
    end
    
    if (buff_map[action_str] ~= nil) then
        if isnum(buff_map[action_str]) then
            return res.buffs[buff_map[action_str]]
        else
            return res.buffs:with('en', buff_map[action_str])
        end
    elseif action_str:match('^Protectr?a?%s?I*V?$') then
        return res.buffs[40]
    elseif action_str:match('^Shellr?a?%s?I*V?$') then
        return res.buffs[41]
    else
        local buff = res.buffs:with('en', action_str)
        if buff ~= nil then
            return buff
        end
        buff = utils.normalize_action(action_str, 'buffs')
        if buff ~= nil then
            return buff
        end
        local buffName = action_str
        local spLoc = action_str:find(' ')
        if (spLoc ~= nil) then
            buffName = action_str:sub(1, spLoc-1)
        end
        return res.buffs:with('en', buffName)
    end
end


--==============================================================================
--          Buff Tracking Functions
--==============================================================================


--[[
    Register a debuff gain/loss on the given target, optionally with the action
    that caused the debuff
--]]
function buffs.register_debuff(target, debuff, gain, action)
    debuff = utils.normalize_action(debuff, 'buffs')
    
    if debuff == nil then
        return              --hack
    end
    
    if debuff.enn == 'slow' then
        buffs.register_buff(target, 'Haste', false)
        buffs.register_buff(target, 'Flurry', false)
    end
    local tid, tname = target.id, target.name
    local is_enemy = (target.spawn_type == 16)
    if is_enemy then
        offense.mobs[tid] = offense.mobs[tid] or {}
    else
        buffs.debuffList[tname] = buffs.debuffList[tname] or {}
    end
    local debuff_tbl = is_enemy and offense.mobs[tid] or buffs.debuffList[tname]
    local msg = is_enemy and 'mob 'or ''
    
    if gain then
        if is_enemy then
            if offense.ignored[debuff.enn] ~= nil then return end
        else
            local ignoreList = ignoreDebuffs[debuff.en]
            local pmInfo = hb.partyMemberInfo[tname]
            if (ignoreList ~= nil) and (pmInfo ~= nil) then
                if ignoreList:contains(pmInfo.job) and ignoreList:contains(pmInfo.subjob) then
                    atcd(('Ignoring %s on %s because of their job'):format(debuff.en, tname))
                    return
                end
            end
        end
        debuff_tbl[debuff.id] = {landed = os.clock()}
        if is_enemy and hb.modes.mob_debug then
            atc(('Detected %sdebuff: %s %s %s [%s]'):format(msg, debuff.en, rarr, tname, tid))
        end
        atcd(('Detected %sdebuff: %s %s %s [%s]'):format(msg, debuff.en, rarr, tname, tid))
    else
        debuff_tbl[debuff.id] = nil
        if is_enemy and hb.modes.mob_debug then
            atc(('Detected %sdebuff: %s wore off %s [%s]'):format(msg, debuff.en, tname, tid))
        end
        atcd(('Detected %sdebuff: %s wore off %s [%s]'):format(msg, debuff.en, tname, tid))
    end
end


-- local last_action = {}
-- function register_action(atype, aid)
    -- last_action.type = atype
    -- last_action.id = aid
-- end

-- windower.register_event('gain buff', function(buff_id)
    -- atcfs('Gained: %s %s [Type: %s]', buff_id, res.buffs[buff_id].en, last_action.type)
    -- if last_action.type == 'Geomancy' then
        -- buffs.action_buff_map[last_action.type] = buffs.action_buff_map[last_action.type] or {}
        -- if buffs.action_buff_map[last_action.type][last_action.id] == nil then
            -- buffs.action_buff_map[last_action.type][last_action.id] = buff_id
            -- buffs.action_buff_map:save(true)
        -- end
    -- end
-- end)


function buffs.register_buff(target, buff, gain, action)
    if not target then return end
--local function _register_buff(target, buff, gain, action)
    --atcfs("%s -> %s [gain: %s]", buff, target.name, gain)
    if not isstr(buff) then
        if buff.is_indi or buff.is_geo then
            buffs.buffList[target.name] = buffs.buffList[target.name] or {}
            buffs.buffList[target.name][buff.spell.en] = buffs.buffList[target.name][buff.spell.en] or {}
            buffs.buffList[target.name][buff.spell.en] = buffs.buffList[target.name][buff.spell.en] or {}
            if gain then
                buffs.buffList[target.name][buff.spell.en].landed = os.clock()
            else
                buffs.buffList[target.name][buff.spell.en].landed = nil
            end
            return
        end
    end
    
    local nbuff = utils.normalize_action(buff, 'buffs')
    if nbuff == nil then
        atcfs(123,'Error normalizing buff: %s', buff)
    end
    
    if action ~= nil then
        buffs.action_buff_map[action.type] = buffs.action_buff_map[action.type] or {}
        if buffs.action_buff_map[action.type][action.id] == nil then
            buffs.action_buff_map[action.type][action.id] = nbuff.id
            buffs.action_buff_map:save(true)
        end
    end
    
    local tid, tname = target.id, target.name
    local is_enemy = (target.spawn_type == 16)
    local bkey, msg = nbuff.id, ''
    if is_enemy then
        offense.mobs[tid] = offense.mobs[tid] or {}
        msg = 'mob '
    else
        buffs.buffList[tname] = buffs.buffList[tname] or {}
        for spell_name, info in pairs(buffs.buffList[tname]) do
            if info.buff then                                       -- FIXME: Temporary fix for geo error
                if info.buff.id == nbuff.id then
                    bkey = spell_name
                    break
                end
            end
        end
    end
    local buff_tbl = is_enemy and offense.mobs[tid] or buffs.buffList[tname]
    if is_enemy and offense.dispel[bkey] or buff_tbl[bkey] then
        buff_tbl[bkey] = buff_tbl[bkey] or {}
        if gain then
            buff_tbl[bkey].landed = os.clock()
            if is_enemy and hb.modes.mob_debug then
                atc(('Detected %sbuff: %s %s %s [%s]'):format(msg, nbuff.en, rarr, tname, tid))
            end
            atcd(('Detected %sbuff: %s %s %s [%s]'):format(msg, nbuff.en, rarr, tname, tid))
        else
            buff_tbl[bkey].landed = nil
            if is_enemy and hb.modes.mob_debug then
                atc(('Detected %sbuff: %s wore off %s [%s]'):format(msg, nbuff.en, tname, tid))
            end
            atcd(('Detected %sbuff: %s wore off %s [%s]'):format(msg, nbuff.en, tname, tid))
        end
    end 
end
--buffs.register_buff = traceable(_register_buff)


function buffs.resetDebuffTimers(player)
    if (player == nil) then
        atc(123,'Error: Invalid player name passed to buffs.resetDebuffTimers.')
    elseif (player == 'ALL') then
        buffs.debuffList = {}
    else
        buffs.debuffList[player] = {}
    end
end

function buffs.resetBuffTimers(player, exclude)
    if (player == nil) then
        atc(123,'Error: Invalid player name passed to buffs.resetBuffTimers.')
        return
    elseif (player == 'ALL') then
        for p,l in pairs(buffs.buffList) do
            buffs.resetBuffTimers(p)
        end
        return
    end
    buffs.buffList[player] = buffs.buffList[player] or {}
    for buffName,_ in pairs(buffs.buffList[player]) do
        if exclude ~= nil then
            if not (exclude:contains(buffName)) then
                buffs.buffList[player][buffName]['landed'] = nil
            end
        else
            buffs.buffList[player][buffName]['landed'] = nil
        end
    end
end

return buffs

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
