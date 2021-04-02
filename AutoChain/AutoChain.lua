_addon.author = 'Icy, core code from Ivaar\'s SkillChains.lua'
_addon.commands = {'autochain', 'ac'}
_addon.name = 'AutoChain'
_addon.version = '1.0.0.0'

require('luau')
require('pack')
texts = require('texts')
skills = require('skills')

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}

default = {}
default.use_ws = 'on'
default.show_display = true
default.min_sc_lvl = 2
default.Show = {burst=_static, pet=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.2
default.aeonic = false
default.color = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0},bg={visible=true}}

settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
aeonic_ids = S{20515,20594,20695,20843,20890,20935,20977,21025,21082,21147,21485,21694,21753,22117}
message_ids = S{2,110,161,162,185,187,317}
buff_dur = {[163]=40,[164]=30,[470]=60}
pet_commands = {[110]=true,[317]=true}
info = {member = {}}
resonating = {}
buffs = {}
distance_msg_enabled = true

colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(0,0,204)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(0,0,255)'
colors.Earth =         '\\cs(153,76,0)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning

skillchain = {'Light','Darkness','Gravitation','Fragmentation','Distortion','Fusion','Compression','Liquefaction','Induration','Reverberation','Transfixion','Scission','Detonation','Impaction','Radiance','Umbra'}

sc_info = {
    Radiance = {ele={'Fire','Wind','Lightning','Light'}, lvl=4},
    Umbra = {ele={'Earth','Ice','Water','Dark'}, lvl=4},
    Light = {ele={'Fire','Wind','Lightning','Light'}, Light='Light', aeonic='Radiance', lvl=3},
    Darkness = {ele={'Earth','Ice','Water','Dark'}, Darkness='Darkness', aeonic='Umbra', lvl=3},
    Gravitation = {ele={'Earth','Dark'}, Distortion='Darkness', Fragmentation='Fragmentation', lvl=2},
    Fragmentation = {ele={'Wind','Lightning'}, Fusion='Light', Distortion='Distortion', lvl=2},
    Distortion = {ele={'Ice','Water'}, Gravitation='Darkness', Fusion='Fusion', lvl=2},
    Fusion = {ele={'Fire','Light'}, Fragmentation='Light', Gravitation='Gravitation', lvl=2},
    Compression = {ele={'Darkness'}, Transfixion='Transfixion', Detonation='Detonation', lvl=1},
    Liquefaction = {ele={'Fire'}, Impaction='Fusion', Scission='Scission', lvl=1},
    Induration = {ele={'Ice'}, Reverberation='Fragmentation', Compression='Compression', Impaction='Impaction', lvl=1},
    Reverberation = {ele={'Water'}, Induration='Induration', Impaction='Impaction', lvl=1},
    Transfixion = {ele={'Light'}, Scission='Distortion', Reverberation='Reverberation', Compression='Compression', lvl=1},
    Scission = {ele={'Earth'}, Liquefaction='Liquefaction', Reverberation='Reverberation', Detonation='Detonation', lvl=1},
    Detonation = {ele={'Wind'}, Compression='Gravitation', Scission='Scission', lvl=1},
    Impaction = {ele={'Lightning'}, Liquefaction='Liquefaction', Detonation='Detonation', lvl=1},
    }

local aeonic_weapon = {}

for id in pairs(aeonic_ids) do
    aeonic_weapon[id] = res.items[id].english
end
    
initialize = function(text, settings)
    if not windower.ffxi.get_info().logged_in then
        return
    end
    if not info.job then
        local player = windower.ffxi.get_player()
        info.job = player.main_job
        info.player = player.id
    end
    local properties = L{}
	if settings.use_ws == 'on' then
		properties:append(' [AutoChain] Enabled (Lv.${min_sc_lvl})')
	else
		properties:append(' [AutoChain] Disabled')
	end
    if settings.Show.timer[info.job] then
        properties:append('${timer}')
    end
    if settings.Show.step[info.job] then
        properties:append('Step: ${step} → ${en}')
    end
    if settings.Show.props[info.job] then
        properties:append('[${props}] ${elements}')
    elseif settings.Show.burst[info.job] then
        properties:append('${elements}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
end
skill_props:register_event('reload', initialize)

function update_weapon()
    if not settings.Show.weapon[info.job] then
        return
    end
    local main_weapon = windower.ffxi.get_items(info.main_bag, info.main_weapon).id
    if main_weapon ~= 0 then
        info.aeonic = aeonic_weapon[main_weapon] or info.range and aeonic_weapon[windower.ffxi.get_items(info.range_bag, info.range).id]
        return
    end
    if not check_weapon or coroutine.status(check_weapon) ~= 'suspended' then
        check_weapon = coroutine.schedule(update_weapon, 10)
    end
end

function aeonic_am(step)
    for x=270,272 do
        if buffs[info.player][x] then
            return 272-x < step
        end
    end
    return false
end

function aeonic_prop(ability, actor)
    if ability.aeonic and (info.aeonic == ability.en and actor == info.player or settings.aeonic and info.player ~= actor) then
        return {ability.skillchain[1], ability.skillchain[2], ability.aeonic}
    end
    return ability.skillchain
end

function check_props(old, new)
    local n = #old < 4 and #new or 1
    for k=1,#old do
        for i=1,n do local v = sc_info[old[k]][new[i]]
            if v then
                return sc_info[v].lvl == 3 and old[k] == new[i] and 4 or sc_info[v].lvl, v
            end
        end
    end
end

function add_skills(t, abilities, active, cat, aeonic)
    local tt = {{},{},{},{}}
    for k=1,#abilities do 
		local ability = skills[cat][abilities[k]]
        if ability then
            local lv, prop = check_props(active, aeonic_prop(ability, info.player))
            if prop then
                prop = aeonic and lv == 4 and sc_info[prop].aeonic or prop
                tt[lv][#tt[lv]+1] = settings.color and
                    '%-16s → Lv.%d %s%-14s\\cr':format(ability.en, lv, colors[prop], prop) or
                    '%-16s → Lv.%d %-14s':format(ability.en, lv, prop)
            end
        end
    end
    for x=4,1,-1 do
        for k=#tt[x],1,-1 do
            t[#t+1] = tt[x][k]
        end
    end
    return t
end

function check_results(reson)
    local t = {}
    if settings.Show.spell[info.job] and info.job == 'SCH' then
        t = add_skills(t, {1,2,3,4,5,6,7,8}, reson.active, 20)
    elseif settings.Show.spell[info.job] and info.job == 'BLU' then
        t = add_skills(t, windower.ffxi.get_mjob_data().spells, reson.active, 4)
    elseif settings.Show.pet[info.job] and windower.ffxi.get_mob_by_target('pet') then
        t = add_skills(t, windower.ffxi.get_abilities().job_abilities, reson.active, 13)
    end
    if settings.Show.weapon[info.job] then
        t = add_skills(t, windower.ffxi.get_abilities().weapon_skills, reson.active, 3, info.aeonic and aeonic_am(reson.step))
    end
    return _raw.table.concat(t, '\n')
end

function colorize(t)
    local temp
    if settings.color then
        temp = {}
        for k=1,#t do
            temp[k] = '%s%s\\cr':format(colors[t[k]], t[k])
        end
    end
    return _raw.table.concat(temp or t, ',')
end

function distance_check(player, mob) --, wstype
	-- TODO: pass in the Weaponskill type (ranged or melee) in.
	local max_distances = {['melee'] = 4.95, ['ranged'] = 21.99}
	if mob.distance:sqrt() > max_distances['melee'] then 
		if(distance_msg_enabled) then
			atcc(263, 'AutoSkillChain: Out of range, holding weapon skill '..activeChain['ws'][chain_index])
			distance_msg_enabled = false --don't spam the screen with the distance message.
		end
		return false
	end
	distance_msg_enabled = true
	return true
end

function do_stuff()
	local player = windower.ffxi.get_player()
    local targ = windower.ffxi.get_mob_by_target('t', 'bt')
    local now = os.time()
    for k,v in pairs(resonating) do
        if v.ts and now-v.ts > v.dur then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] and resonating[targ.id].dur-(now-resonating[targ.id].ts) > 0 then
        local timediff = now-resonating[targ.id].ts
        local timer = resonating[targ.id].dur-timediff
        if not resonating[targ.id].closed then
            resonating[targ.id].disp_info = resonating[targ.id].disp_info or check_results(resonating[targ.id])
            resonating[targ.id].timer = timediff < resonating[targ.id].wait and 
                '\\cs(255,0,0)Wait  %d\\cr':format(resonating[targ.id].wait-timediff) or
                '\\cs(0,255,0)Go!   %d\\cr':format(timer)
			
			-- AutoChain code.
			if settings.use_ws == 'on' and timediff >= resonating[targ.id].wait then
				if (player ~= nil) and (player.status == 1) and (targ ~= nil) then
					if player.vitals.tp > 999 and distance_check(player, targ) then
						if resonating[targ.id].disp_info then
							-- Ugly I know...
							local splat = resonating[targ.id].disp_info:split('\n')
							local top = splat[1]:split('→')[1]:trim()
							local lvl = splat[2]:split('.')[2]:split(' ')[1]
							if top and top ~= '' and tonumber(lvl) and tonumber(lvl) >= tonumber(settings.min_sc_lvl) then
								windower.send_command('input /ws '..top..' <t>')
							end
						end
					end
				end
			end
			
        elseif settings.Show.burst[info.job] then
            resonating[targ.id].disp_info = ''
            resonating[targ.id].timer = 'Burst %d':format(timer)
        else
            resonating[targ.id] = nil
            return
        end
        resonating[targ.id].props = resonating[targ.id].props or
            not resonating[targ.id].bound and colorize(resonating[targ.id].active) or 'Chainbound Lv.%d':format(resonating[targ.id].bound)
        resonating[targ.id].elements = resonating[targ.id].elements or
            resonating[targ.id].step > 1 and settings.Show.burst[info.job] and '(%s)':format(colorize(sc_info[resonating[targ.id].active[1]].ele)) or ''
        skill_props:update(resonating[targ.id])
        skill_props:show()
    elseif not visible then
        skill_props:hide()
    end
end

function check_buff(t, i)
    if t[i] == true or t[i] - os.time() > 0 then
        return true
    end
    t[i] = nil
end

function chain_buff(t)
    local i = t[164] and 164 or t[470] and 470
    if i and check_buff(t, i) then
        t[i] = nil
        return true
    end
    return t[163] and check_buff(t, 163)
end

windower.register_event('incoming chunk', function(id, data)
    if id == 0x28 then
        local actor,targets,category,param = data:unpack('Ib10b4b16', 6)
        local effect = data:unpack('b17', 27, 6)
        local msg = data:unpack('b10', 29, 7)
        local prop = skillchain[data:unpack('b6', 35)]
        category = pet_commands[msg] and 13 or category
        local ability = skills[category] and skills[category][param]

        if ability and (category ~= 4 or buffs[actor] and chain_buff(buffs[actor]) or prop) then
            local mob = data:unpack('b32', 19, 7)
            if prop then
                local step = (resonating[mob] and resonating[mob].step or 1) + 1
                local closed = step > 5 or sc_info[prop].lvl > 2 and 
                    (sc_info[prop].lvl == 4 or resonating[mob] and check_props(resonating[mob].active, aeonic_prop(ability, actor)) == 4)
                resonating[mob] = {en=ability.en, active={prop}, ts=os.time(), dur=11-step, wait=3, step=step, closed=closed}
            elseif message_ids[msg] then
                resonating[mob] = {en=ability.en, active=aeonic_prop(ability, actor), ts=os.time(), dur=10, wait=3, step=1}
            elseif msg == 529 then
                resonating[mob] = {en=ability.en, active=ability.skillchain, ts=os.time(), dur=ability.dur, wait=1, step=1, bound=effect}
            end
        elseif category == 6 and buff_dur[effect] then
            buffs[actor] = buffs[actor] or {}
            buffs[actor][effect] = buff_dur[effect] + os.time()
        end
    elseif id == 0x29 and data:unpack('H', 25) == 206 and data:unpack('I', 9) == info.player then
        buffs[info.player][data:unpack('H', 13)] = nil
    elseif id == 0x50 and data:byte(6) == 0 then
        info.main_weapon = data:byte(5)
        info.main_bag = data:byte(7)
        update_weapon()
    elseif id == 0x50 and data:byte(6) == 2 then
        info.range = data:byte(5)
        info.range_bag = data:byte(7)
        update_weapon()
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff = data:unpack('H', n*2+7)
            if buff_dur[buff] or buff > 269 and buff < 273 then
                set_buff[buff] = true
            end
        end
        buffs[info.player] = set_buff
    end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower()
    if cmd == 'move' then
        visible = not visible
        if visible and not skill_props:visible() then
            skill_props:update({disp_info='     --- AutoChain ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
        elseif not visible then
            skill_props:hide()
        end
	elseif cmd == 'on' or cmd == 'off' then
		settings.use_ws = cmd
	elseif cmd == 'display' then
		settings.show_display = not settings.show_display
		if settings.show_display then
			windower.send_command('lua unload Skillchains')
		end
	elseif cmd == 'level' or cmd == 'lvl' then
		local args = {...}
		if args[1] and tonumber(args[1]) then
			settings.min_sc_lvl = args[1]
			windower.add_to_chat(207, 'AutoChain: Min. Skillchain Level = '..args[1])
		end
		
    elseif cmd == 'save' then
        local arg = ... and ...:lower() == 'all' and 'all'
        config.save(settings, arg)
        windower.add_to_chat(207, '%s: settings saved to %s character%s.':format(_addon.name, arg or 'current', arg and 's' or ''))
    elseif default.Show[cmd] then
        if not default.Show[cmd][info.job] then
            return error('unable to set %s on %s.':format(cmd, info.job))
        end
        local key = settings.Show[cmd][info.job]
        if not key then
            settings.Show[cmd]:add(info.job)
        else
            settings.Show[cmd]:remove(info.job)
        end
        config.save(settings)
        config.reload(settings)
        windower.add_to_chat(207, '%s: %s info will no%s be displayed on %s.':format(_addon.name, cmd, key and ' longer' or 'w', info.job))--'t' or 'w'
    elseif type(default[cmd]) == 'boolean' then
        settings[cmd] = not settings[cmd]
        windower.add_to_chat(207, '%s: %s %s':format(_addon.name, cmd, settings[cmd] and 'on' or 'off'))
    elseif cmd == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    else
        windower.add_to_chat(207, '%s: valid commands [on | off | save | display | move | burst | weapon | spell | pet | props | step | timer | color | aeonic]':format(_addon.name))
    end
end)

windower.register_event('job change', function(job, lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
    end
end)

windower.register_event('zone change', function()
    resonating = {}
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        local equip = windower.ffxi.get_items('equipment')
        info.main_weapon = equip.main
        info.main_bag = equip.main_bag
        info.range = equip.range
        info.range_bag = equip.range_bag
        update_weapon()
        buffs[info.player] = {}
		if settings.show_display then
			windower.send_command('lua unload Skillchains')
		end
    end
    do_loop = do_stuff:loop(settings.UpdateFrequency)
end)

windower.register_event('unload', function()
	windower.send_command('lua load Skillchains')
    coroutine.close(check_weapon)
    coroutine.close(do_loop)
end)

windower.register_event('logout', function()
    coroutine.close(check_weapon)
    check_weapon = nil
    info = {member = {}}
    resonating = {}
    buffs = {}
end)