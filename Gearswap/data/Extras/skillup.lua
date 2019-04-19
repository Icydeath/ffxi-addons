packets = require('packets')
res = require 'resources'
--version 2.0.0.0 final
----------USER IN CODE SETTINGS----------
---Put the spells you want to use in these tables
---Example: for healing Healing = T{'Cure','Cure II'},
---If you cant use the spell it will not use it
---You need to have a minimum of 2 spells in your list
user_settings = {
    user_spells = {
        Healing = T{},
        Geomancy = T{},
        Enhancing = T{},
        Ninjutsu = T{},
        Singing = T{},
        Blue = T{},
        Summoning = T{}},
    save_settings = false} --change this to true if you wish to save the last position of your skillup window
sets.brd = {
    wind_inst = {
        range="Cornette"},--put your wind instrument here
    string_inst = {
        range="Lamia Harp"},}--put your string instrument here
sets.Idle = {
    right_ear="Liminus Earring",
    head="Tema. Headband",
    body="Temachtiani Shirt",
    hands="Temachtiani Gloves",
    legs="Temachtiani Pants",
    feet="Temachtiani Boots",
    }
sets.Resting = {
    main="Dark Staff",
    left_ear="Relaxing Earring",
    ammo="Clarus Stone",
    neck="Eidolon pendant",
    right_ear="Boroka Earring",
    }
--DO NOT CHANGE ANY THING BELOW THIS LINE--
function get_sets()
    skilluprun = false
    gs_skill = {skillup_table = {"Healing","Geomancy","Enhancing","Ninjutsu","Singing","Blue","Summoning"},skillup_type = 'None',skillup_spells = T{},
        skillup_count=1,bluspellulid = {['Harden Shell']=737,['Pyric Bulwark']=741,['Carcharian Verve']=745},skill_up_item = T{5889,5890,5891,5892}}
    end_skillup = {shutdown = false,logoff = false,stoptype = "Stop"}
    gs_skillup = {color={GEO=true,HEL=true,ENH=true,NIN=true,SIN=true,BLU=true,SMN=true,STOP=true,DOWN=true,LOG=true,TRUST=true,TEST=true,REF=true,ITEM=true},
                skill_ups={},total_skill_ups=0,skill={},use_trust=false,use_item=false,use_geo=false,test_mode=false,test_brd="Wind",skipped_spells=T{}}
    gs_skillup.box={pos={x=211,y=402},text={font='Segoe UI Symbol',size=12,Fonts={'sans-serif'},},bg={alpha=255}}
    gs_skillup.boxa={pos={x=gs_skillup.box.pos.x - 145,y=gs_skillup.box.pos.y},text={font='Segoe UI Symbol',size=9},bg={alpha=255}}
    if gearswap.pathsearch({'Saves/skillup_data.lua'}) then
        include('Saves/skillup_data.lua')
    end
    button = texts.new(gs_skillup.boxa)
    window = texts.new(gs_skillup.box)
    initialize(button, gs_skillup.boxa, 'button')
    initialize(window, gs_skillup.box, 'window')
    button:show()
    window:show()
end
function file_unload()
    if user_settings.save_settings then
        file_write()
    end
    window:destroy()
    button:destroy()
end
function status_change(new,old)
    if sets[new] then
        equip(sets[new])
    end
    if new=='Idle' then
        if skilluprun then
            send_command('wait 1.0;input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
        end
    elseif new=='Resting' then
        coroutine.schedule(go_to_idle_gear, 30)
    end
end
function go_to_idle_gear()
    equip(sets.Idle)
end
function filtered_action(spell)
    if check_skill_cap() or not skilluprun then cancel_spell() shutdown_logoff() return end
    if gs_skill.bluspellulid[spell.en] then
        if windower.ffxi.get_ability_recasts()[81] and windower.ffxi.get_ability_recasts()[81] == 0 then
            cancel_spell()
            send_command('input /ja "'..res.job_abilities[298][gearswap.language]..'" <me>')
        elseif windower.ffxi.get_ability_recasts()[254] and windower.ffxi.get_ability_recasts()[254] == 0 then
            cancel_spell()
            send_command('input /ja "'..res.job_abilities[338][gearswap.language]..'" <me>')
        else
            cancel_spell()
            gs_skill.skillup_count = (gs_skill.skillup_count % #gs_skill.skillup_spells) + 1
            send_command('input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
        end
        return
    elseif spell.skill == "Ninjutsu" then
        local tool = nin_tool_open(spell)
        cancel_spell()
        if tool then
            send_command('input /item "'..tool..'" <me>')
        end
        return
    elseif S{"Avatar's Favor","Elemental Siphon"}:contains(spell.en) then
        cancel_spell()
        send_command('input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
    end
    if spell.name == gs_skill.skillup_spells[gs_skill.skillup_count] then
        if gs_skill.skillup_spells:contains(spell.name) then
            gs_skill.skillup_spells:delete(spell.name)
        end
        cancel_spell()
        gs_skill.skillup_count = (gs_skill.skillup_count % #gs_skill.skillup_spells) + 1
        send_command('input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
    end
end
function precast(spell)
    if pet.isvalid and S{"Release","Full Circle"}:contains(spell.en) then
        if spell.en == "Release" then
            if not pet.isvalid then
                cancel_spell()
                send_command('input /heal on')
            end
            local recast = windower.ffxi.get_ability_recasts()[spell.recast_id]
            if (recast > 0) then
                cancel_spell()
                send_command('wait '..tostring(recast+0.5)..';input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
            end
            return
        else
            return
        end
    elseif not pet.isvalid and S{"Release","Avatar's Favor","Elemental Siphon"}:contains(spell.en) then
        cancel_spell()
        send_command('input /heal on')
        return
    end
    if check_skill_cap() or not skilluprun then cancel_spell() shutdown_logoff() return end
    if gs_skill.skillup_type == "Singing" then
        if (gs_skillup.test_mode and gs_skillup.test_brd == "String") or not gs_skillup.skill['Stringed Instrument Capped'] then
            equip(sets.brd.string_inst)
        elseif (gs_skillup.test_mode and gs_skillup.test_brd == "Wind") or not gs_skillup.skill['Wind Instrument Capped'] then
            equip(sets.brd.wind_inst)
        end
    end
    if spell.en == "Avatar's Favor" then
        if (windower.ffxi.get_ability_recasts()[spell.recast_id] > 0) or buffactive["Avatar's Favor"] then
            cancel_spell()
            send_command('input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
            return
        end
    end
    if spell.en == "Elemental Siphon" then
        if (windower.ffxi.get_ability_recasts()[spell.recast_id] > 0) or player.mpp > 75 then
            cancel_spell()
            send_command('input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
            return
        end
    end
    if spell and spell.mp_cost > player.mp then
        if gs_skillup.skipped_spells:contains(spell.name) then
            gs_skillup.skipped_spells:clear()
            cancel_spell()
            send_command('input /heal on')
            return
        end
        cancel_spell()
        gs_skillup.skipped_spells:append(spell.name)
        gs_skill.skillup_count = (gs_skill.skillup_count % #gs_skill.skillup_spells) + 1
        send_command('input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
        return
    end
    if gs_skillup.use_trust and party.count == 1 and spell_usable(res.spells[931]) then
        if spell.en ~= "Moogle" then
            cancel_spell()
            send_command('input /ma "'..res.spells[931][gearswap.language]..'" <me>')
            return
        end
    end
    if gs_skillup.use_item and spell.type ~= "Item" and not buffactive[251] then
        for i,v in ipairs(gs_skill.skill_up_item) do
            if player.inventory[res.items[v][gearswap.language]] then
                cancel_spell()
                send_command('input /item "'..res.items[v][gearswap.language]..'" <me>')
                return
            end
        end
    elseif gs_skillup.use_geo then
        if player.main_job == "GEO" and spell_usable(res.spells[800]) and not pet.isvalid then
            if spell.en ~= "Geo-Refresh" then
                cancel_spell()
                send_command('input /ma "'..res.spells[800][gearswap.language]..'" <me>')
                return
            end
            return
        elseif player.sub_job == "GEO" and spell_usable(res.spells[770]) and buffactive[541] ~= (gs_skillup.use_trust and 2 or 1) then
            if spell.en ~= "Indi-Refresh" then
                cancel_spell()
                send_command('input /ma "'..res.spells[770][gearswap.language]..'" <me>')
                return
            end
        end
    end
    if spell.name == gs_skill.skillup_spells[gs_skill.skillup_count] then
        if not spell_usable(spell) then
            cancel_spell()
            gs_skill.skillup_count = (gs_skill.skillup_count % #gs_skill.skillup_spells) + 1
            send_command('input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
        else
            gs_skill.skillup_count = (gs_skill.skillup_count % #gs_skill.skillup_spells) + 1
        end
    end
end
function aftercast(spell)
    if pet.isvalid and check_skill_cap() then
        if pet.name == "Luopan" then
            send_command('wait 1.0;input /ja "'..res.job_abilities[345][gearswap.language]..'" <me>')
        else
            send_command('wait 1.0;input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
        end
        return
    end
    if check_skill_cap() then
        shutdown_logoff() return 
    elseif spell.interrupted then
        if spell.en == "Release" then
            send_command('wait 0.5;input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
            return
        else
            send_command('wait 3.0;input /ma "'..spell.name..'" <me>')
            return
        end
    elseif spell.type == "SummonerPact" then
        local spell_element = (type(spell.element)=='number' and res.elements[spell.element][gearswap.language] or spell.element)
        if spell.en:contains('Spirit') and (spell_element == world.weather_element or spell_element == world.day_element) then
            send_command('wait 4.0;input /ja "'..res.job_abilities[232][gearswap.language]..'" <me>')
        elseif not spell.en:contains('Spirit') then
            send_command('wait 4.0;input /ja "'..res.job_abilities[250][gearswap.language]..'" <me>')
        else
            send_command('wait 3.0;input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
        end
    elseif spell.en == "Avatar's Favor" then
        send_command('wait 1.0;input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
    elseif spell.en == "Elemental Siphon" then
        send_command('wait 1.0;input /ja "'..res.job_abilities[90][gearswap.language]..'" <me>')
    else
        send_command('wait 3.0;input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
    end
end
function self_command(command)
    local commandArgs = command
    if #commandArgs:split(' ') >= 2 then
        commandArgs = T(commandArgs:split(' '))
    end
    if type(commandArgs) == 'table' and commandArgs[1] == 'start' then
        for i,v in ipairs(gs_skill.skillup_table) do
            if v:lower() == commandArgs[2]:lower() then
                gs_skill.skillup_type = v
                skilluprun = true
                if #gs_skill.skillup_spells > 0 then
                    gs_skill.skillup_spells:clear()
                end
                local skill_id = {["Healing"]=33,["Enhancing"]=34,["Summoning"]=38,["Ninjutsu"]=39,["Singing"]=40,["Blue"]=43,["Geomancy"]=44}
                local spells_have = windower.ffxi.get_spells()
                for i,v in pairs(res.spells) do
                    if v.skill == skill_id[gs_skill.skillup_type] and spell_valid(v) and spells_have[v.id] then
                        if #user_settings.user_spells[gs_skill.skillup_type] > 0 then
                            if user_settings.user_spells[gs_skill.skillup_type]:contains(v.name) then
                                gs_skill.skillup_spells:append(v[gearswap.language])
                            end
                        else
                            gs_skill.skillup_spells:append(v[gearswap.language])
                        end
                    end
                end
                if not (#gs_skill.skillup_spells > 0) then
                    add_to_chat(123,"Current Job Can Not Use Spells From "..gs_skill.skillup_type)
                    skilluprun = false
                    return
                end
                send_command('input /ma "'..gs_skill.skillup_spells[gs_skill.skillup_count]..'" <me>')
            end
        end
    end
    if command == "skillstop" then
        skilluprun = false
    elseif command == 'aftershutdown' then
        end_skillup.stoptype = "Shutdown"
        end_skillup.shutdown = true
        end_skillup.logoff = false
    elseif command == 'afterlogoff' then
        end_skillup.stoptype = "Logoff"
        end_skillup.shutdown = false
        end_skillup.logoff = true
    elseif command == 'afterStop' then
        end_skillup.stoptype = "Stop"
        end_skillup.shutdown = false
        end_skillup.logoff = false
    elseif command == 'settrust' then
        gs_skillup.use_trust = not gs_skillup.use_trust
    elseif command == 'setitem' then
        gs_skillup.use_item = not gs_skillup.use_item
    elseif command == 'setgeo' then
        gs_skillup.use_geo = not gs_skillup.use_geo
    elseif command == 'changeinstrament' then
        gs_skillup.test_brd = (gs_skillup.test_brd=="Wind" and "String" or "Wind")
    end
    initialize(window, gs_skillup.box, 'window')
    updatedisplay()
end
function spell_usable(spell)
    if windower.ffxi.get_spells()[spell.id] and windower.ffxi.get_spell_recasts()[spell.recast_id] == 0 then
        return true
    end
end
function check_skill_cap()
    if S{'Healing','Enhancing','Blue','Summoning'}:contains(gs_skill.skillup_type) then
        if gs_skillup.skill[gs_skill.skillup_type..' Magic Capped'] and not gs_skillup.test_mode then
            skilluprun = false
            return true
        end
    elseif gs_skill.skillup_type == "Ninjutsu" then
        if gs_skillup.skill[gs_skill.skillup_type..' Capped'] and not gs_skillup.test_mode then
            skilluprun = false
            return true
        end
    elseif gs_skill.skillup_type == "Geomancy" then
        if gs_skillup.skill['Geomancy Capped'] and gs_skillup.skill['Handbell Capped'] and not gs_skillup.test_mode then
            skilluprun = false
            return true
        end
    elseif gs_skill.skillup_type == "Singing" then
        if gs_skillup.skill['Singing Capped'] and gs_skillup.skill['Stringed Instrument Capped'] and gs_skillup.skill['Wind Instrument Capped'] and not gs_skillup.test_mode then
            skilluprun = false
            return true
        end
    else
        return false
    end
end
function spell_valid(tab)
    if (tab.levels[player.main_job_id] and tab.levels[player.main_job_id] <= player.main_job_level or tab.levels[player.sub_job_id] and tab.levels[player.sub_job_id] <= player.main_job_level) and tab.targets:contains('Self') and
        not tab.en:wmatch('Teleport-*|Warp*|Tractor*|Retrace|Escape|Geo-*|Sacrifice|Odin|Alexander|Recall-*') then
        return true
    end
end
function shutdown_logoff()
    add_to_chat(123,"Stoping skillup")
    if end_skillup.logoff then
        send_command('wait 3.0;input /logout')
    elseif end_skillup.shutdown then
        send_command('wait 3.0;input /shutdown')
    end
    initialize(window, gs_skillup.box, 'window')
    updatedisplay()
end
function nin_tool_open(spell)
    local bag_id = {['Sanjaku-Tenugui']=5417,['Soshi']=5734,['Uchitake']=5308,['Tsurara']=5309,['Kawahori-Ogi']=5310,['Makibishi']=5311,['Hiraishin']=5312,
        ['Mizu-Deppo']=5313,['Shihei']=5314,['Jusatsu']=5315,['Kaginawa']=5316,['Sairui-Ran']=5317,['Kodoku']=5318,['Shinobi-Tabi']=5319,['Ranka']=6265,
        ['Furusumi']=6266,['Kabenro']=5863,['Jinko']=5864,['Ryuno']=5865,['Mokujin']=5866,["Chonofuda"]=5869,["Inoshishinofuda"]=5867,["Shikanofuda"]=5868}
    local t = gearswap.tool_map[spell.en].en
    local ut = gearswap.universal_tool_map[spell.en].en
    local tb = res.items[bag_id[t]][gearswap.language]
    local utb = res.items[bag_id[ut]][gearswap.language]
    if #gs_skill.skillup_spells > 0 then
        if player.inventory[tb] ~= nil then
            return tb
        elseif player.inventory[utb] ~= nil then
            return utb
        else
            gs_skill.skillup_spells:delete(spell.name)
            return false
        end
    else
        skilluprun = false
        cancel_spell()
        add_to_chat(7,"No Tools Available To Cast Any Ninjutsu")
    end
end
function initialize(text, settings, a)
    if a == 'window' then
        local properties = L{}
        if gs_skillup.test_mode then
            properties:append('--TEST MODE--')
            properties:append('Bard item = ${barditem|Wind}')
        end
        properties:append('--Skill Up--')
        if gs_skillup.use_trust then
            properties:append('\\crUsing Moogle Trust')
        end
        if gs_skillup.use_geo then
            properties:append("\\crUsing Geo's Refresh")
        end
        if gs_skillup.use_item then
            properties:append('\\crUsing Skill Up Item')
        end
        properties:append('Mode :\n   ${mode}')
        if gs_skill.skillup_type == 'Singing' then
            properties:append('\\crCurrent Singing Skill LVL:\n   ${skillssing|0}')
            properties:append('\\crCurrent String Skill LVL:\n   ${skillstring|0}')
            properties:append('\\crCurrent Wind Skill LVL:\n   ${skillwind|0}')
        elseif gs_skill.skillup_type == 'Geomancy' then
            properties:append('\\crCurrent Geomancy Skill LVL:\n   ${skillgeo|0}')
            properties:append('\\crCurrent Handbell Skill LVL:\n   ${skillbell|0}')
        else
            properties:append('\\crCurrent Skilling LVL:\n   ${skillbulk|0}')
        end
        if end_skillup.shutdown then
            properties:append('\\crWill Shutdown When Skillup Done')
        elseif end_skillup.logoff then
            properties:append('\\crWill Logoff When Skillup Done')
        else
            properties:append('\\crWill Stop When Skillup Done')
        end
        properties:append('\\crSkillup ${start|\\cs(255,0,0)Stoped}')
        properties:append("\\crSkillup's Per Hour \\cs(255,255,0)${skill_ph|0}")
        properties:append("\\crTotal Skillup's \\cs(255,255,0)${skill_total|0}")
        text:clear()
        text:append(properties:concat('\n'))
    end
    if a == 'button' then
        local properties = L{}
        properties:append('${TRUSTc}')
        properties:append('${REFc}')
        properties:append('${ITEMc}')
        properties:append('${HELc}')
        properties:append('${ENHc}')
        properties:append('${NINc}')
        properties:append('${SINc}')
        properties:append('${BLUc}')
        properties:append('${SMNc}')
        properties:append('${GEOc}')
        properties:append('${STOPc}')
        properties:append('${DOWNc}')
        properties:append('${LOGc}')
        if gs_skillup.test_mode then
            properties:append('${TESTc}')
        end
        text:clear()
        text:append(properties:concat('\n'))
    end
end
function updatedisplay()
    local info = {}
        info.mode = gs_skill.skillup_type
        info.modeb = skilluprun and info.mode or 'None'
        info.start = (skilluprun and '\\cs(0,255,0)Started' or '\\cs(255,0,0)Stoped')
        info.skillssing = (gs_skillup.skill['Singing Capped'] and "Capped" or gs_skillup.skill['Singing Level'])
        info.skillstring = (gs_skillup.skill['Stringed Instrument Capped'] and "Capped" or gs_skillup.skill['Stringed Instrument Level'])
        info.skillwind = (gs_skillup.skill['Wind Instrument Capped'] and "Capped" or gs_skillup.skill['Wind Instrument Level'])
        info.skillgeo = (gs_skillup.skill['Geomancy Capped'] and "Capped" or gs_skillup.skill['Geomancy Level'])
        info.skillbell = (gs_skillup.skill['Handbell Capped'] and "Capped" or gs_skillup.skill['Handbell Level'])
        info.skill = {}
        info.skill.Healing = (gs_skillup.skill['Healing Magic Capped'] and "Capped" or gs_skillup.skill['Healing Magic Level'])
        info.skill.Enhancing = (gs_skillup.skill['Enhancing Magic Capped'] and "Capped" or gs_skillup.skill['Enhancing Magic Level'])
        info.skill.Summoning = gs_skillup.skill['Summoning Magic Capped'] and "Capped" or gs_skillup.skill['Summoning Magic Level']
        info.skill.Ninjutsu = (gs_skillup.skill['Ninjutsu Capped'] and "Capped" or gs_skillup.skill['Ninjutsu Level'])
        info.skill.Blue = (gs_skillup.skill['Blue Magic Capped'] and "Capped" or gs_skillup.skill['Blue Magic Level'])
        info.skillbulk = info.skill[info.mode]
        info.type = end_skillup.stoptype
        info.skill_ph = (get_rate(gs_skillup.skill_ups) or 0) / 10
        info.skill_total = (gs_skillup.total_skill_ups or 0) / 10
        info.GEOc = (gs_skillup.color.GEO and 'Start GEO' or '\\cs(255,0,0)Start GEO\\cr')
        info.HELc = (gs_skillup.color.HEL and 'Start Healing' or '\\cs(255,0,0)Start Healing\\cr')
        info.ENHc = (gs_skillup.color.ENH and 'Start Enhancing' or '\\cs(255,0,0)Start Enhancing\\cr')
        info.NINc = (gs_skillup.color.NIN and 'Start Ninjutsu' or '\\cs(255,0,0)Start Ninjutsu\\cr')
        info.SINc = (gs_skillup.color.SIN and 'Start Singing' or '\\cs(255,0,0)Start Singing\\cr')
        info.BLUc = (gs_skillup.color.BLU and 'Start Blue Magic' or '\\cs(255,0,0)Start Blue Magic\\cr')
        info.SMNc = (gs_skillup.color.SMN and 'Start Summoning Magic  ' or '\\cs(255,0,0)Start Summoning Magic\\cr  ')
        info.STOPc = (gs_skillup.color.STOP and 'Stop Skillups' or '\\cs(255,0,0)Stop Skillups\\cr')
        info.DOWNc = (gs_skillup.color.DOWN and 'Shutdown After Skillup' or '\\cs(255,0,0)Shutdown After Skillup\\cr')
        info.LOGc = (gs_skillup.color.LOG and  'Logoff After Skillup' or '\\cs(255,0,0)Logoff After Skillup\\cr')
        info.TRUSTc = (gs_skillup.color.TRUST and  'Use Moogle Trust' or '\\cs(255,0,0)Use Moogle Trust\\cr')
        info.REFc = (gs_skillup.color.REF and  "Use Geo's Refresh" or "\\cs(255,0,0)Use Geo's Refresh\\cr")
        info.ITEMc = (gs_skillup.color.ITEM and  'Use Skill Up Item' or '\\cs(255,0,0)Use Skill Up Item\\cr')
        info.TESTc = (gs_skillup.color.TEST and  'Change Bard Item' or '\\cs(255,0,0)Change Bard Item\\cr')
        info.barditem = gs_skillup.test_brd
        button:update(info)
        button:show()
        window:update(info)
        window:show()
end
function file_write()
    if not windower.dir_exists(lua_base_path..'data/'..player.name..'/Saves') then
        windower.create_dir(lua_base_path..'data/'..player.name..'/Saves')
    end
    local file = io.open(lua_base_path..'data/'..player.name..'/Saves/skillup_data.lua',"w")
    file:write(
        'gs_skillup.box.pos.x = '..tostring(gs_skillup.box.pos.x)..
        '\ngs_skillup.box.pos.y = '..tostring(gs_skillup.box.pos.y)..
        '\ngs_skillup.boxa.pos.x = '..tostring(gs_skillup.boxa.pos.x)..
        '\ngs_skillup.boxa.pos.y = '..tostring(gs_skillup.boxa.pos.y)..
        '')
    file:close() 
end
function set_color(name)
    for i, v in pairs(gs_skillup.color) do
        if i == name then
            gs_skillup.color[i] = false
        else
            gs_skillup.color[i] = true
        end
    end
end
function get_rate(tab)
    local t = os.clock()
    local running_total = 0
    for ts,points in pairs(tab) do
        local time_diff = t - ts
        if t - ts > 3600 then
            tab[ts] = nil
        else
            running_total = running_total + points
        end
    end
    return running_total
end
windower.raw_register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x062 then
        local packet = packets.parse('incoming', data)
        gs_skillup.skill = packet
        updatedisplay()
    end
    if id == 0x0DF and skilluprun then
        if data:unpack('I', 0x0D) == player.max_mp and skilluprun then
            windower.send_command('input /heal off')
        end
    end
end)
windower.raw_register_event('mouse', function(type, x, y, delta, blocked)
    local mx, my = texts.extents(button)
    local button_lines = button:text():count('\n') + 1 
    local hx = (x - gs_skillup.boxa.pos.x)
    local hy = (y - gs_skillup.boxa.pos.y)
    local location = {}
    location.offset = my / button_lines
    location[1] = {}
    location[1].ya = 1
    location[1].yb = location.offset
    local count = 2
    while count <= button_lines do
         location[count] = {}
         location[count].ya = location[count - 1].yb
         location[count].yb = location[count - 1].yb + location.offset
         count = count + 1
    end
    if type == 0 then
        if window:hover(x, y) and window:visible() then
            button:pos((gs_skillup.box.pos.x - 145), gs_skillup.box.pos.y)
            set_color("none")
            updatedisplay()
        elseif button:hover(x, y) and button:visible() then
            window:pos((gs_skillup.boxa.pos.x + 145), gs_skillup.boxa.pos.y)
            for i, v in ipairs(location) do
                local switch = {[1]="TRUST",[2]='REF',[3]='ITEM',[4]="HEL",[5]="ENH",[6]="NIN",[7]="SIN",[8]="BLU",[9]="SMN",[10]="GEO",[11]="STOP",[12]="DOWN",
                                [13]="LOG",[14]="TEST"}
                if hy > location[i].ya and hy < location[i].yb then
                    set_color(switch[i])
                    updatedisplay()
                end
            end
        else
            set_color("none")
            updatedisplay()
        end
    elseif type == 2 then
        if button:hover(x, y) and button:visible() then
            for i, v in ipairs(location) do
                local switchb = {[1]="settrust",[2]="setgeo",[3]="setitem",[4]="start Healing",[5]="start Enhancing",[6]="start Ninjutsu",
                                [7]="start Singing",[8]="start Blue",[9]="start Summoning",[10]="start Geomancy",[11]="skillstop",[12]="aftershutdown",
                                [13]="afterlogoff",[14]="changeinstrament"}
                if hy > location[i].ya and hy < location[i].yb then
                    send_command("gs c "..switchb[i])
                    updatedisplay()
                end
            end
        end
    end
end)
windower.raw_register_event('action message', function(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    if message_id == 38 and target_id == player.id then
        local ts = os.clock()
        gs_skillup.total_skill_ups = gs_skillup.total_skill_ups + param_2
        gs_skillup.skill_ups[ts] = param_2
    end
    updatedisplay()
end)
frame_count = 0
windower.raw_register_event('prerender',function()
    if frame_count%30 == 0 and window:visible() then
        updatedisplay()
    end
    frame_count = frame_count + 1
end)