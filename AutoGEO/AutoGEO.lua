_addon.author = 'Ivaar, modified by icy'
_addon.commands = {'AutoGEO','geo','ageo'}
_addon.name = 'AutoGEO'
_addon.version = '2020.5.25'

--[[ 
5/25: Some QoL changes added
	- updated the help info [//ageo]
	- added the [set] command, see help for info
	- added support for partial spell names ie: [//ageo indi attun]  will set indi to Indi-Attunement
	- saving config is now global
]]
require('luau')
texts = require('texts')
packets = require('packets')

default = {
    delay = 4.2,
    actions = false,
    active = true,
    geo = 'Geo\-Precision',
    indi = 'Indi\-Precision',
	blaze = false,
    entrust = {},
    min_ws_hp = 20,
    max_ws_hp = 99,
    buffs={haste=L{},refresh=L{}},
    recast={indi={min=20,max=25},buff={min=5,max=10}},
    aug = {lifestream=20},
    text = {text={size=10}},
	spell_sets = T{
		{name=S{'att', 'dps', 'melee'}, indi='Indi\-Haste', geo='Geo\-Frailty', entrust='Indi\-Fury'},
		{name=S{'acc'}, indi='Indi\-Haste', geo='Geo\-Torpor', entrust='Indi\-Precision'},
		{name=S{'matt'}, indi='Indi\-Acumen', geo='Geo\-Malaise', entrust='Indi\-Refresh'},
		{name=S{'macc'}, indi='Indi\-Focus', geo='Geo\-Languor', entrust='Indi\-Refresh'},
		{name=S{'pdt', 'def'}, 	indi='Indi\-Barrier', 	geo='Geo\-Wilt', entrust='Indi\-Haste'},
		{name=S{'meva'}, indi='Indi\-Attunement',geo='Geo\-Vex', entrust='Indi\-Haste'},
		{name=S{'mdt', 'mdef'}, indi='Indi\-Fend', geo='Geo\-Fade', entrust='Indi\-Haste'},
	},
}

settings = config.load(default)
last_coords = 'fff':pack(0,0,0)
is_moving = false
nexttime = os.clock()
del = 0
timers = {entrust={},haste={},refresh={}}

equipment = L{
    [27192] = 'Bagua Pants',
    [27193] = 'Bagua Pants +1',
    [27451] = 'Azimuth Gaiters',
    [27452] = 'Azimuth Gaiters +1',
    [28637] = 'Lifestream Cape',
}

geo_spells = T{
    [768] = {id=768,en="Indi-Regen",mp_cost=37,targets=5},
    [769] = {id=769,en="Indi-Poison",mp_cost=12,targets=5},
    [770] = {id=770,en="Indi-Refresh",mp_cost=63,targets=5},
    [771] = {id=771,en="Indi-Haste",mp_cost=100,targets=5},
    [772] = {id=772,en="Indi-STR",mp_cost=63,targets=5},
    [773] = {id=773,en="Indi-DEX",mp_cost=63,targets=5},
    [774] = {id=774,en="Indi-VIT",mp_cost=63,targets=5},
    [775] = {id=775,en="Indi-AGI",mp_cost=63,targets=5},
    [776] = {id=776,en="Indi-INT",mp_cost=63,targets=5},
    [777] = {id=777,en="Indi-MND",mp_cost=63,targets=5},
    [778] = {id=778,en="Indi-CHR",mp_cost=63,targets=5},
    [779] = {id=779,en="Indi-Fury",mp_cost=70,targets=5},
    [780] = {id=780,en="Indi-Barrier",mp_cost=59,targets=5},
    [781] = {id=781,en="Indi-Acumen",mp_cost=91,targets=5},
    [782] = {id=782,en="Indi-Fend",mp_cost=80,targets=5},
    [783] = {id=783,en="Indi-Precision",mp_cost=25,targets=5},
    [784] = {id=784,en="Indi-Voidance",mp_cost=17,targets=5},
    [785] = {id=785,en="Indi-Focus",mp_cost=49,targets=5},
    [786] = {id=786,en="Indi-Attunement",mp_cost=38,targets=5},
    [787] = {id=787,en="Indi-Wilt",mp_cost=161,targets=5},
    [788] = {id=788,en="Indi-Frailty",mp_cost=147,targets=5},
    [789] = {id=789,en="Indi-Fade",mp_cost=186,targets=5},
    [790] = {id=790,en="Indi-Malaise",mp_cost=174,targets=5},
    [791] = {id=791,en="Indi-Slip",mp_cost=112,targets=5},
    [792] = {id=792,en="Indi-Torpor",mp_cost=101,targets=5},
    [793] = {id=793,en="Indi-Vex",mp_cost=136,targets=5},
    [794] = {id=794,en="Indi-Languor",mp_cost=124,targets=5},
    [795] = {id=795,en="Indi-Slow",mp_cost=94,targets=5},
    [796] = {id=796,en="Indi-Paralysis",mp_cost=107,targets=5},
    [797] = {id=797,en="Indi-Gravity",mp_cost=174,targets=5},
    [798] = {id=798,en="Geo-Regen",mp_cost=74,targets=5},
    [799] = {id=799,en="Geo-Poison",mp_cost=25,targets=5},
    [800] = {id=800,en="Geo-Refresh",mp_cost=126,targets=5},
    [801] = {id=801,en="Geo-Haste",mp_cost=200,targets=5},
    [802] = {id=802,en="Geo-STR",mp_cost=126,targets=5},
    [803] = {id=803,en="Geo-DEX",mp_cost=126,targets=5},
    [804] = {id=804,en="Geo-VIT",mp_cost=126,targets=5},
    [805] = {id=805,en="Geo-AGI",mp_cost=126,targets=5},
    [806] = {id=806,en="Geo-INT",mp_cost=126,targets=5},
    [807] = {id=807,en="Geo-MND",mp_cost=126,targets=5},
    [808] = {id=808,en="Geo-CHR",mp_cost=126,targets=5},
    [809] = {id=809,en="Geo-Fury",mp_cost=140,targets=5},
    [810] = {id=810,en="Geo-Barrier",mp_cost=119,targets=5},
    [811] = {id=811,en="Geo-Acumen",mp_cost=182,targets=5},
    [812] = {id=812,en="Geo-Fend",mp_cost=161,targets=5},
    [813] = {id=813,en="Geo-Precision",mp_cost=50,targets=5},
    [814] = {id=814,en="Geo-Voidance",mp_cost=35,targets=5},
    [815] = {id=815,en="Geo-Focus",mp_cost=98,targets=5},
    [816] = {id=816,en="Geo-Attunement",mp_cost=77,targets=5},
    [817] = {id=817,en="Geo-Wilt",mp_cost=322,targets=32},
    [818] = {id=818,en="Geo-Frailty",mp_cost=294,targets=32},
    [819] = {id=819,en="Geo-Fade",mp_cost=372,targets=32},
    [820] = {id=820,en="Geo-Malaise",mp_cost=348,targets=32},
    [821] = {id=821,en="Geo-Slip",mp_cost=225,targets=32},
    [822] = {id=822,en="Geo-Torpor",mp_cost=203,targets=32},
    [823] = {id=823,en="Geo-Vex",mp_cost=273,targets=32},
    [824] = {id=824,en="Geo-Languor",mp_cost=249,targets=32},
    [825] = {id=825,en="Geo-Slow",mp_cost=189,targets=32},
    [826] = {id=826,en="Geo-Paralysis",mp_cost=215,targets=32},
    [827] = {id=827,en="Geo-Gravity",mp_cost=348,targets=32},
}

spell_ids = L{
    [57] = {id=57,enl='haste',dur=180,levels={[3]=40,[5]=48}},
    [109] = {id=109,enl='refresh',dur=150,levels={[5]=41,[22]=62}},
}

display_box = function()
    local str
    if settings.actions then
        str = ' AutoGEO [On] '
    else
        str = ' AutoGEO [Off] '
    end
    if settings.active then
        str = settings.geo and str..'\n %s ':format(settings.geo) or str
        str = settings.indi and str..'\n %s ':format(settings.indi) or str
        if settings.entrust.target then
            str = str..'\n Entrust: %s: \n  [%s] ':format(settings.entrust.target:ucfirst(),settings.entrust.ma)
        end
		if settings.blaze then
			str = str..'\n Blaze: On'
		else
			str = str..'\n Blaze: Off'
		end
        for k,v in ipairs(settings.buffs.haste) do
           str = str..'\n Haste:[%s]':format(v:ucfirst())
        end
        for k,v in ipairs(settings.buffs.refresh) do
            str = str..'\n Refresh:[%s]':format(v:ucfirst())
        end
        for k,v in pairs(settings.recast) do
            str = str..'\n Recast %s:[%d-%d]':format(k:ucfirst(),v.min,v.max)
        end
        str = str..'\n Delay:[%d] ':format(settings.delay)
    end
    return str
end

geo_status = texts.new(display_box(),settings.text,settings)

function prerender()
    if not settings.actions then return end
    local curtime = os.clock()
    if nexttime + del <= curtime then
        nexttime = curtime
        del = 0.1
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'GEO' or play.status > 1 then return end

        local buffs = calculate_buffs(play.buffs)
        if is_moving or is_casting or buffs.stun or buffs.sleep or buffs.charm or buffs.terror or buffs.petrification then return end

        local JA_WS_lock,MA_lock
        if buffs.silence or buffs.mute or buffs.omerta then return end
        if buffs.amnesia or buffs.impairment then JA_WS_lock = true end

        local spell_recasts = windower.ffxi.get_spell_recasts()
        local abil_recasts = windower.ffxi.get_ability_recasts()
        local luopan = windower.ffxi.get_mob_by_target('pet')
        local target = windower.ffxi.get_mob_by_target('bt')
        local recast = math.random(settings.recast.indi.min,settings.recast.indi.max)

        local geo = settings.geo and geo_spells:with('en', settings.geo)
        if geo and not luopan and spell_recasts[geo.id] <= 0 and play.vitals.mp >= geo.mp_cost and (geo.targets == 5 or target and target.hpp > 0) then
            if settings.blaze and abil_recasts[247] and abil_recasts[247] <= 0 then -- use blaze
				use_JA('Blaze of Glory','<me>')
			else
				use_MA(geo.en, geo.targets == 5 and '<me>' or '<bt>')
			end
            return
        end

        local indi = settings.indi and geo_spells:with('en', settings.indi)
        if indi and spell_recasts[indi.id] <= 0 and play.vitals.mp >= indi.mp_cost and (not timers.indi or timers.indi.spell ~= indi.en or os.time()-timers.indi.ts+recast>0) then
            use_MA(indi.en,'<me>')
            return
        end

        local entrust = settings.entrust.target and geo_spells:with('en', settings.entrust.ma)
        if not JA_WS_lock and entrust and valid_target(settings.entrust.target,20) and abil_recasts[93] and spell_recasts[entrust.id] <= 0 and play.vitals.mp >= entrust.mp_cost and 
            (not timers.entrust[settings.entrust.target] or timers.entrust[settings.entrust.target].spell ~= entrust.en or os.time()-timers.entrust[settings.entrust.target].ts+recast>0) then
            if buffs.entrust then
                use_MA(entrust.en,settings.entrust.target)
            elseif abil_recasts[93] <= 0 then
                use_JA('Entrust','<me>')
            end
            return
        end

        if settings.buffs.haste:length()+settings.buffs.refresh:length() ~= 0 then
            recast = math.random(settings.recast.buff.min,settings.recast.buff.max)
            for key,targets in pairs(settings.buffs) do
                local spell = get_spell(key)
                for k,targ in ipairs(targets) do
                    if targ and spell and spell.levels[play.sub_job_id] and spell_recasts[spell.id] <= 0 and valid_target(targ,20) and play.vitals.mp >= 40 and
                    (not timers[spell.enl] or not timers[spell.enl][targ] or os.time() - timers[spell.enl][targ]+recast > 0) then
                        use_MA(spell.enl,targ)
                    end
                end
            end
        end
    end
end

function get_spell(spell)
    for k,v in pairs(spell_ids) do
        if v and v.enl and string.lower(v.enl) == string.lower(spell) then
            return v
        end
    end
    return nil
end

function valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.name:lower() == targ:lower() and math.sqrt(member.mob.distance) < dst and not member.mob.charmed and member.mob.hpp > 0 then
           return true
        end
    end
    return false
end

function addon_message(str, colorid)
	colorid = tonumber(colorid) or 207
	str = str and (_addon.name..': '..str) or '\n'
	windower.add_to_chat(colorid, str)
end

function addon_command(...)
    local commands = {...}
    if commands[1] then
        commands[1] = commands[1]:lower()
        if commands[1] == 'on' then
            if not user_events then
                check_job()
            end
            settings.actions = true
        elseif commands[1] == 'off' then
            settings.actions = false
		elseif commands[1] == 'blaze' and commands[2] then
			if commands[2] == 'on' then
				settings.blaze = true
			elseif commands[2] == 'off' then
				settings.blaze = false
			end
        elseif commands[1] == 'entrust' and commands[2] then
            if commands[3] then
                local spell = geo_spells:with('en','Indi\-'..commands[3]:ucfirst())
                if spell then
                    settings.entrust = {target=commands[2]:lower(),ma=spell.en}
                    addon_message('Entrust %s with %s':format(commands[2],spell.en))
                else
                    addon_message('Invalid spell name.')
                end
            elseif commands[2] == 'off' then   
                settings.entrust = {}
                addon_message('Entrust will not be used')
            end
        elseif commands[1] == 'recast' and commands[2] and S{'buff','indi'}:contains(commands[2]) then
            if commands[3] and tonumber(commands[3]) then
                settings.recast[commands[2]]['min'] = tonumber(commands[3])
            end
            if commands[4] and tonumber(commands[4]) then
                settings.recast[commands[2]]['max'] = tonumber(commands[4])
            end
            addon_message('%s recast set to min: %s max: %s':format(commands[2],settings.recast[commands[2]]['min'],settings.recast[commands[2]]['max']))
        elseif S{'haste','refresh'}:contains(commands[1]) and commands[2] then
            local ind = settings.buffs[commands[1]]:find(commands[2])
            if not commands[3] then
                if ind then
                   settings.buffs[commands[1]]:remove(ind)
                else
                    settings.buffs[commands[1]]:append(commands[2])
                end
            elseif commands[3] == 'on' then
                settings.buffs[commands[1]]:append(commands[2])
            elseif commands[3] == 'off' then
               settings.buffs[commands[1]]:remove(ind)
            end
        elseif commands[1] == 'aug' and settings.aug[commands[2]] and commands[3] and tonumber(commands[3]) then
            settings.aug['lifestream'] = tonumber(commands[3])
            addon_message('Lifestream Cape = Indi eff. dur. +%s.':format(commands[3]))
			
			
		elseif commands[1]:lower() == 'set' then
			if commands[2] and not commands[3] then
				set_spell(nil, commands[2]) -- uses the sets spells.
			elseif commands[2] and commands[3] then
				commands[2] = commands[2]:lower()
				commands[3] = commands[3]:lower()
				if commands[2] == 'save' and not commands[4] then -- set save [name]
					settings.spell_sets:insert({name=S{commands[3]}, geo=settings.geo, indi=settings.indi, entrust=settings.entrust.ma})
					settings:save("all")
					addon_message('Saved set as [%s]':format(commands[3]))
				elseif commands[2] == 'add' then -- set add [name] [geo] [indi] [indi]
					if commands[4] and commands[5] and commands[6] then
						local gspell = geo_spells:with('en', 'Geo\-'..commands[4]:ucfirst())
						local ispell = geo_spells:with('en', 'Indi\-'..commands[5]:ucfirst())
						local enspell = geo_spells:with('en', 'Indi\-'..commands[6]:ucfirst())
						if gspell and ispell and enspell then
							settings.spell_sets:insert({name=S{commands[3]}, geo=gspell.en, indi=ispell.en, entrust=enspell.en})
							settings:save("all")
							addon_message('Added set [%s]':format(commands[3]))
						else
							addon_message('Invalid spell name.')
						end
					else
						addon_message(' //ageo set add [name] [geo-spell] [indi-spell] [indi-spell] - adds a new set')
					end
				else
					addon_message('Setting spells...')
					set_spell('geo', commands[2])
					set_spell('indi', commands[3])
				end
			else
				show_sets()
			end
			
			
        elseif type(settings[commands[1]]) == 'string' and commands[2] then
            if commands[2] == 'off' then   
                settings[commands[1]] = nil
                addon_message('%s will not be used':format(commands[1]))
            else
				local spell = geo_spells:with('en',commands[1]:ucfirst()..'\-'..commands[2]:ucfirst())
				if spell then
					settings[commands[1]] = spell.en
					addon_message('%s set to %s':format(commands[1],commands[2]))
				else
					addon_message('Invalid spell name.')
				end
            end
        elseif type(settings[commands[1]]) == 'number' and commands[2] and tonumber(commands[2]) then
            settings[commands[1]] = tonumber(commands[2])
            addon_message('%s is now set to %d':format(commands[1],settings[commands[1]]))  
        elseif type(settings[commands[1]]) == 'boolean' then
            if (not commands[2] and settings[commands[1]] == true) or (commands[2] and commands[2] == 'off') then
                settings[commands[1]] = false
            elseif (not commands[2]) or (commands[2] and commands[2] == 'on') then
                settings[commands[1]] = true
            end
            addon_message('%s %s':format(commands[1],settings[commands[1]] and 'On' or 'Off'))
        elseif commands[1] == 'save' then
            settings:save("all")
			addon_message('Settings saved.')
        elseif commands[1] == 'eval' then
            assert(loadstring(table.concat(commands, ' ',2)))()
        end
	else
		help()
    end
    geo_status:text(display_box())
   -- windower.add_to_chat(207, str)
end

function set_spell(stype, str)
	str = stype and str:ucfirst() or str
	if stype then
		local spell = geo_spells:with('en', str)
		if spell and not settings[stype]:find(spell.en) then
			settings[stype] = spell.en
			addon_message('%s is now set.':format(spell.en))
		else
			for k,v in pairs(geo_spells) do
				if v and not settings[stype]:find(v.en) and v.en:startswith(stype:ucfirst()..'\-'..str) then
					settings[stype] = v.en
					addon_message('%s is now set.':format(v.en))
				end
			end
		end
	else 
		local set = nil 
		for k,v in pairs(settings.spell_sets) do
			if v.name:contains(str) then
				set = v
				break
			end
		end
		
		if set then
			local geospell = geo_spells:with('en', set.geo)
			local indispell = geo_spells:with('en', set.indi)
			if geospell and indispell then 
				settings.geo = geospell.en 
				addon_message('%s is now set.':format(geospell.en))
				settings.indi = indispell.en 
				addon_message('%s is now set.':format(indispell.en))
			end
			if set.entrust and settings.entrust then
				local espell = geo_spells:with('en', set.entrust)
				local t = settings.entrust.target
				if espell and t then
					settings.entrust = { target=t, ma=espell.en }
					addon_message('Entrust %s with %s':format(t:ucfirst(), espell.en))
				end
			end
		else
			addon_message('Set %s not found.':format(str))
		end
	end
end

function show_sets()
	addon_message(' Available Sets:')
	for k,v in pairs(settings.spell_sets) do
		addon_message('')
		--addon_message(' %s':format(v.name:concat(' | ')))
		addon_message(' %s = [%s]  [%s]  [Entrust: %s]':format(v.name:concat(' | '), v.geo, v.indi, v.entrust))
	end
end

function help()
	addon_message('------------------------------------------------------------------------')
	addon_message('    NOTE: [spell] is the spells name without the Indi-/Geo- prefix')
	addon_message('------------------------------------------------------------------------')
	addon_message('GEO - INDI - ENTRUST', 200)
	addon_message(' //ageo geo [spell/off] - uses geo spell given, off disables geo spells')
	addon_message(' //ageo indi [spell/off] - uses indi spell given, off disables indi spells')
	addon_message(' //ageo entrust [player] [spell] - entrust player with spell')
	addon_message('    //ageo entrust off - disables using entrust')
	addon_message()
	addon_message('SET', 200)
	addon_message(' //ageo set - Shows a list of available sets')
	addon_message(' //ageo set [setname] - Sets the spells from [setname]')
	addon_message(' //ageo set add [setname] [geospell] [indispell] [indispell] - adds a new set')
	addon_message(' //ageo set save [setname] - saves currently set spells as a set.')
	addon_message(' //ageo set [spell] [spell] - Allows you to set a geo and a indi spell at the same time. ')
	addon_message()
	addon_message('RECAST - AUG', 200)
	addon_message(' //ageo recast indi [min] [max] - Recasts indi between the given secs before they wear off')
	addon_message(' //ageo recast buff [min] [max] - Recasts buffs between the given secs')
	addon_message(' //ageo aug lifestream [#] - set indi effect duration aug on lifestream cape')
	addon_message()
	addon_message('OTHER', 200)
	addon_message(' //ageo active - display settings in textbox')
	addon_message(' //ageo save -- saves settings')
	addon_message(' //ageo [on/off] -- turn actions on/off')
end

function calculate_buffs(curbuffs)
    local buffs = {}
    for i,v in pairs(curbuffs) do
        if res.buffs[v] and res.buffs[v].english then
            buffs[res.buffs[v].english:lower()] = (buffs[res.buffs[v].english:lower()] or 0) + 1
        end
    end
    return buffs
end

function use_JA(str,ta)
    windower.send_command('input /ja "%s" %s':format(str,ta))
    del = 1.2
end

function use_MA(str,ta)
    windower.send_command('input /ma "%s" %s':format(str,ta))
    del = settings.delay
end

function get_equip(slot)
    local item = windower.ffxi.get_items().equipment
    return equipment[windower.ffxi.get_items(item[slot..'_bag'],item[slot]).id] or ''
end

function check_incoming_chunk(id,original,modified,injected,blocked)
    if id == 0x028 then
        local packet = packets.parse('incoming', original)
        if packet.Actor ~= windower.ffxi.get_mob_by_target('me').id then return false end
        if packet.Category == 4 then
            -- Finish Casting
            is_casting = false
            del = settings.delay
            if packet.Param >= 768 and packet.Param <= 797 then
                local spell = geo_spells[packet.Param]
                local mult = 1
                local dur = 180 + windower.ffxi.get_player().job_points.geo.indocolure_spell_effect_dur * 2
                if get_equip('legs') == 'Bagua Pants +1' then dur = dur + 20 end
                if get_equip('legs') == 'Bagua Pants' then dur = dur + 12 end
                if get_equip('legs') == 'Azimuth Gaiters' then dur = dur + 15 end
                if get_equip('legs') == 'Azimuth Gaiters +1' then dur = dur + 20 end
                if get_equip('back') == 'Lifestream Cape' then mult = mult + settings.aug.lifestream * 0.01 end
                dur = math.floor(mult*dur)
                if packet.Actor == packet['Target 1 ID'] then
                    timers.indi = {spell=spell.en,ts=os.time()+dur}
                else
                    local target = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])
                    timers.entrust[target.name:lower()] = {spell=spell.en,ts=os.time()+dur}
                end
            elseif spell_ids[packet.Param] then
                local spell = spell_ids[packet.Param]
                local target = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])
                timers[spell.enl:lower()][target.name:lower()] = os.time()+spell.dur 
            end
        elseif L{3,5,11}:contains(packet.Category) then -- 2 Ranged Attacks
            -- Finish Casting/WS/Item Use
            is_casting = false
        elseif L{7,8,9}:contains(packet.Category) then -- 12 Ranged Attacks
            if (packet.Param == 24931) then
                --  Begin Casting/WS/Item Use
                is_casting = true
            elseif (packet.Param == 28787) then
                -- Failed Casting/WS/Item Interrupted
                is_casting = false
                del = 2.5
            end
        end
    end
end

function check_outgoing_chunk(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        is_moving = last_coords ~= modified:sub(5, 16)
        last_coords = modified:sub(5, 16)
    end
end

function reset()
    settings.actions = false
    is_casting = false
    timers = {entrust={},haste={},refresh={}}
    geo_status:text(display_box())
end

function status_change(new,old)
    is_casting = false
    if new == 2 or new == 3 then
        reset()
    end
end

function load_chunk_event()
    incoming_chunk = windower.register_event('incoming chunk', check_incoming_chunk)
    outgoing_chunk = windower.register_event('outgoing chunk', check_outgoing_chunk)
end

function unload_chunk_event()
    windower.unregister_event(incoming_chunk)
    windower.unregister_event(outgoing_chunk)
end

function unloaded()
    if user_events then
        reset()
        for _,event in pairs(user_events) do
            windower.unregister_event(event)
        end
        geo_status:hide()
        user_events = nil
        coroutine.schedule(unload_chunk_event,0.1)
    end
end

function loaded()
    if not user_events then
        user_events = {}
        user_events.prerender = windower.register_event('prerender', prerender)
        user_events.zone_change = windower.register_event('zone change', reset)
        user_events.status_change = windower.register_event('status change', status_change)
        geo_status:text(display_box())
        geo_status:show()
        coroutine.schedule(load_chunk_event,0.1)
    end
end

function check_job()
    local play = windower.ffxi.get_player()
    if play and play.main_job == 'GEO' then
        loaded()
    else
        unloaded()
    end
end

windower.register_event('addon command', addon_command)
windower.register_event('job change','login','load', check_job)
windower.register_event('logout', unloaded)
