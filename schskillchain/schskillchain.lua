--[[
Copyright © 2019, yyoshisaur
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of schskillchain nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL yyoshisaur BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.name = 'schskillchain'
_addon.version = '0.9.0.0'
_addon.author = 'yyoshisaur'
_addon.command = 'ssc'

bit = require('bit')
chat = require('chat')
config = require('config')
res = require('resources')

local help_text = [[
schskillchain(ssc)
*commnad
//ssc skillchain order [sc_tier] [mb] [mb_tier]
    skillchain = f[fire],b[blizzard],a[aero],s[stone],t[thunder],w[water],l[light],d[dark],
                 f2[fire2],b2[blizzard2],a2[aero2],s2[stone2],t2[thunder2],w2[water2],l2[light2],d2[dark2]
    order = o[open],c[close],a[all] (all = both open and close)
    sc_tier = 1,2,3,4,5,h,h2
    mb (cast elemental magic or helix after skillchain)
    mb_tier = 1,2,3,4,5,h,h2 
*settings.xml
wait:
    immanence_wait: waiting time after use immanence
    skillchain_wait: waiting time between skillchan (when order = all)
    skillchain_wait_helix: waiting time between opening and closing if spell opening skillchain were helix (when order = all)
    mb_wait: casting waiting time of casting mb spell after skillchain 
    mb_wait_helix: waiting time of casting mb spell afert helix skillchain
target:
    type: spell target (t, bt, etc.)
auto_dark_arts:
    use dark arts if you don't use dark arts.
]]

local magic_tier = S{'1','2','3','4','5','h','h2'}
local stratagems = {
    immanance = {English = 'Immanence', Japanese = '震天動地の章', id = 317, recast_id = 231},
    dark_arts = {English = 'Dark Arts', Japanese = '黒のグリモア', id = 359, recast_id = 232},
    addendum_black = {English = 'Addendum: Black', Japanese = '黒の補遺', id = 402, recast_id = 231},
}
local auto_translate_param = {
    English = {lang = 'en', lang_type = '0x02',},
    Japanese = {lang = 'ja', lang_type = '0x01',}
}

windower.register_event('load', function()
    defaults = {
        wait = {
            ['immanence_wait'] = 1.5,
            ['skillchain_wait'] = 4,
            ['skillchain_wait_helix'] = 5,
            ['mb_wait'] = 4,
            ['mb_wait_helix'] = 5,
        },
        target = {
            ['type'] = 't',
        },
        auto_dark_arts = true,
    }
    settings = config.load(defaults)
    local lang = windower.ffxi.get_info().language
    skillchain = require('skillchain')[lang]
    immanance = stratagems.immanance[lang]
    dark_arts = stratagems.dark_arts[lang]
    addendum_black = stratagems.addendum_black[lang]
    at_param = auto_translate_param[lang]
end)

function parse_param(cmd)
    local param = {
        sc = 'fire',
        order = 'all',
        sc_tier = 1,
        is_mb = false,
        mb_tier = 5,
        sc_wait = 4,
        mb_wait = 4,
    }

    param.sc_wait = settings.wait.skillchain_wait

    if cmd[1] then
        local sc = string.lower(cmd[1])
        if sc == 'fire' or sc == 'f' then
            param.sc = 'fire'
        elseif sc == 'blizzard' or sc == 'b' then
            param.sc = 'blizzard'
        elseif sc == 'aero' or sc == 'a' then
            param.sc = 'aero'
        elseif sc == 'stone' or sc == 's' then
            param.sc = 'stone'
        elseif sc == 'thunder' or sc == 't' then
            param.sc = 'thunder'
        elseif sc == 'water' or sc == 'w' then
            param.sc = 'water'
        elseif sc == 'light' or sc == 'l' then
            param.sc = 'light'
            param.sc_wait = settings.wait.skillchain_wait_helix
        elseif sc == 'dark' or sc == 'd' then
            param.sc = 'dark'
        elseif sc == 'fire2' or sc == 'f2' then
            param.sc = 'fire2'
        elseif sc == 'blizzard2' or sc == 'b2' then
            param.sc = 'blizzard2'
            param.sc_wait = settings.wait.skillchain_wait_helix
        elseif sc == 'aero2' or sc == 'a2' then
            param.sc = 'aero2'
        elseif sc == 'stone2' or sc == 's2' then
            param.sc = 'stone2'
        elseif sc == 'thunder2' or sc == 't2' then
            param.sc = 'thunder2'
        elseif sc == 'water2' or sc == 'w2' then
            param.sc = 'water2'
            param.sc_wait = settings.wait.skillchain_wait_helix
        elseif sc == 'light2' or sc == 'l2' then
            param.sc = 'light2'
        elseif sc == 'dark2' or sc == 'd2' then
            param.sc = 'dark2'
        else
            return nil
        end
    else
        return nil
    end

    if cmd[2] then
        local order = string.lower(cmd[2])
        if order == 'open' or order == 'o' then
            param.order = 'open'
        elseif order == 'close' or order == 'c' then
            param.order = 'close'
        elseif order == 'all' or order == 'a' then
            param.order = 'all'
        else
            return nil
        end 
    end

    if cmd[3] and string.lower(cmd[3]) == 'mb' then
        param.is_mb = true
        if magic_tier:contains(cmd[4]) then
            param.mb_tier = cmd[4]
        else
            return nil
        end
    else
        if cmd[3] then
            param.sc_tier = cmd[3]
            if cmd[3] == 'h' or cmd[3] == 'h2' then
                    param.mb_wait = settings.wait.mb_wait_helix
                else
                    param.mb_wait = settings.wait.mb_wait
            end
        end

        if cmd[4] and string.lower(cmd[4]) == 'mb' then
            param.is_mb = true
            if magic_tier:contains(cmd[5]) then
                param.mb_tier = cmd[5]
            else
                return nil
            end
        end
    end

    if cmd[3] then
        if string.lower(cmd[3]) == 'mb' then
            param.is_mb = true
            if magic_tier:contains(cmd[4]) then
                param.mb_tier = cmd[4]
            else
                return nil
            end
        else
            param.sc_tier = cmd[3]
            if cmd[3] == 'h' or cmd[3] == 'h2' then
                    param.mb_wait = settings.wait.mb_wait_helix
            else
                    param.mb_wait = settings.wait.mb_wait
            end

            if cmd[4] and string.lower(cmd[4]) == 'mb' then
                param.is_mb = true
                if magic_tier:contains(cmd[5]) then
                    param.mb_tier = cmd[5]
                else
                    return nil
                end
            end
        end
    end

    return param
end

function set_magic_tier(spell, magic_tier)
    if magic_tier == '1' then
        spell = spell
    elseif magic_tier == '2' then 
        spell = spell..'II'
    elseif magic_tier == '3' then 
        spell = spell..'III'
    elseif magic_tier == '4' then 
        spell = spell..'IV'
    elseif magic_tier == '5' then 
        spell = spell..'V'
    end

    return spell
end

function get_spell(sc, order, tier)
    local spell =  nil
    if tier == 'h' then
        spell = set_magic_tier(skillchain[sc][order]['hel'], '1')
    elseif tier == 'h2' then
        spell = set_magic_tier(skillchain[sc][order]['hel'], '2')
    else
        if skillchain[sc][order]['ele'] then
            spell = set_magic_tier(skillchain[sc][order]['ele'], tier)
        else
            spell = set_magic_tier(skillchain[sc][order]['hel'], '1')
        end
    end
    return spell
end

function get_text_command_immanance()
    return 'input /ja "'..immanance..'" <me>;'
end

function get_text_command_spell(spell, target)
    return 'input /ma "'..spell..'" <'..target..'>;'
end

function get_text_command_wait(wait)
    return 'wait '..tostring(wait)..';'
end

function get_text_commnad_dark_arts()
    return 'input /ja "'..dark_arts..'" <me>;'
end

function get_current_stratagems_count(job_points)
    local stratagems_recast_id = stratagems.immanance.recast_id
    local stratagems_recast = windower.ffxi.get_ability_recasts()[stratagems_recast_id]
    local charge_time = 48
    local max_stratagems_charge = 5

    if job_points >= 550 then
        charge_time = 33
    end

    return math.floor(max_stratagems_charge - max_stratagems_charge * stratagems_recast / (max_stratagems_charge * charge_time))
end

function get_dark_arts_recast()
    local dark_arts_recast_id = stratagems.dark_arts.recast_id
    return windower.ffxi.get_ability_recasts()[dark_arts_recast_id]
end

function check_dark_arts(buffs)
    if S(buffs):contains(stratagems.dark_arts.id) then
        return true
    else
        return false
    end
end

function check_addendum_black(buffs)
    if S(buffs):contains(stratagems.addendum_black.id) then
        return true
    else
        return false
    end
end

function get_auto_translate_char_squence(lang, phrase)
    local at_start = 0xFD
    local at_end = 0xFD
    local at_type = 0x02

    local at_lang
    if lang == 'ja' then
        at_lang = 0x01
    else
        at_lang = 0x02
    end

    local phrase_id = res.auto_translates:with(lang, phrase).id

    if phrase_id then
        local phrase_id_upper = bit.band(bit.rshift(phrase_id, 8), 0xFF)
        local phrase_id_lower = bit.band(phrase_id, 0xFF)
        return string.char(at_start, at_type, at_lang, phrase_id_upper, phrase_id_lower, at_end)
    end
    return nil
end

function open_skillchain_message(sc, target)
    local sc_msg = get_auto_translate_char_squence(at_param.lang, skillchain[sc]['at']['sc_name'])
    local start_msg = get_auto_translate_char_squence('ja', '連携準備オッケー！')

    return 'input /party Opening:'.. sc_msg..start_msg..'-> <'..target..'>;'
end

function close_skillchain_message(sc, target)
    local sc_msg = get_auto_translate_char_squence(at_param.lang, skillchain[sc]['at']['sc_name'])
    local end_msg = get_auto_translate_char_squence('ja', '全力で攻撃だ！')

    local msg = 'input /party Closing:'..sc_msg..'MB:'

    for i, v in ipairs(skillchain[sc]['at']['sc_ele']) do
        msg = msg..get_auto_translate_char_squence(at_param.lang, v)
    end

    msg = msg..end_msg..'-> <'..target..'>;'

    return msg
end

windower.register_event('addon command', function(...)
    local cmd = {...}

    local player = windower.ffxi.get_player()
    local main_job = string.lower(player.main_job)
    
    if main_job ~= 'sch' then
         windower.add_to_chat(209, _addon.name..': '..get_auto_translate_char_squence('ja', 'ジョブチェンジ')..get_auto_translate_char_squence('ja', '学者')..get_auto_translate_char_squence('ja', 'はい。お願いします。'))
         return
    end

    local param = parse_param(cmd)
    if param == nil then
        windower.add_to_chat(209, help_text)
        return
    end

    -- windower.add_to_chat(209, 'sc='..param.sc..' order='..param.order..' sc_tier='..param.sc_tier..' mb='..tostring(param.is_mb)..' mb_tier='..param.mb_tier..' target='..settings.target.type)

    local current_stratagems_charge = get_current_stratagems_count(player.job_points[main_job].jp_spent)
    local spell_1, spell_2 = nil
    if param.order == 'all' then
        spell_1 = get_spell(param.sc, 'open', '1')
        spell_2 = get_spell(param.sc, 'close', param.sc_tier)
        if current_stratagems_charge < 2 then
            windower.add_to_chat(209, _addon.name..': '..get_auto_translate_char_squence('ja', '戦術魔道書')..get_auto_translate_char_squence('ja', '持っていますか？'))
            windower.send_command('input /echo '.._addon.name..': <recast='..get_auto_translate_char_squence('ja', '戦術魔道書')..'>')
        end
    else
        spell_1 = get_spell(param.sc, param.order, param.sc_tier)
        if current_stratagems_charge < 1 then
            windower.add_to_chat(209, _addon.name..': '..get_auto_translate_char_squence('ja', '戦術魔道書')..get_auto_translate_char_squence('ja', '持っていますか？'))
            windower.send_command('input /echo '.._addon.name..': <recast='..get_auto_translate_char_squence('ja', '戦術魔道書')..'>')
        end
    end

    local spell_mb = nil
    if param.is_mb then
        spell_mb = get_spell(param.sc, 'mb', param.mb_tier)
    end

    local sc_msg = nil
    if param.order == 'close' then
        sc_msg = close_skillchain_message(param.sc, settings.target.type)
    else
        sc_msg = open_skillchain_message(param.sc, settings.target.type)
    end

    local text_command = nil
    text_command = sc_msg..
                   windower.to_shift_jis(get_text_command_immanance())..
                   get_text_command_wait(settings.wait.immanence_wait)..
                   windower.to_shift_jis(get_text_command_spell(spell_1, settings.target.type))

    if param.order == 'all' then
        text_command = text_command..
                       get_text_command_wait(param.sc_wait)..
                       close_skillchain_message(param.sc, settings.target.type)..
                       windower.to_shift_jis(get_text_command_immanance())..
                       get_text_command_wait(settings.wait.immanence_wait)..
                       windower.to_shift_jis(get_text_command_spell(spell_2, settings.target.type))
    end
    
    if param.is_mb then
        text_command = text_command ..
                       get_text_command_wait(param.mb_wait)..
                       windower.to_shift_jis(get_text_command_spell(spell_mb, settings.target.type))
    end
    
    -- windower.add_to_chat(123,text_command)

    if check_dark_arts(player.buffs) or check_addendum_black(player.buffs) then
        windower.send_command(text_command)
    else
        if settings.auto_dark_arts then
            local dark_arts_recast = get_dark_arts_recast()
            if dark_arts_recast == 0 then
                text_command = windower.to_shift_jis(get_text_commnad_dark_arts())..
                               get_text_command_wait(settings.wait.immanence_wait)..
                               text_command
                windower.send_command(text_command)
            else
                windower.add_to_chat(209, _addon.name..': '..get_auto_translate_char_squence('ja', '黒のグリモア')..get_auto_translate_char_squence('ja', '持っていますか？'))
                windower.send_command('input /echo '.._addon.name..': <recast='..get_auto_translate_char_squence('ja', '黒のグリモア')..'>')
            end
        else
            windower.add_to_chat(209, _addon.name..': '..get_auto_translate_char_squence('ja', '黒のグリモア')..get_auto_translate_char_squence('ja', '持っていますか？'))
        end
    end
end)