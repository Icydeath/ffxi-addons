-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

	state.Buff.Entrust = buffactive.Entrust or false
	state.Buff['Blaze of Glory'] = buffactive['Blaze of Glory'] or false

    LowTierNukes = S{'Stone', 'Water', 'Aero', 'Fire', 'Blizzard', 'Thunder',
        'Stone II', 'Water II', 'Aero II', 'Fire II', 'Blizzard II', 'Thunder II',
        'Stonega', 'Waterga', 'Aeroga', 'Firaga', 'Blizzaga', 'Thundaga'}

	state.RecoverMode = M('35%', '60%', 'Always', 'Never')

	autows = 'Realmrazer'
	autofood = 'Miso Ramen'
	autoindi = 'Torpor'
	autoentrust = 'Fury'
	autoentrustee = '<p1>'
	autogeo = 'Frailty'
	last_indi = nil
	last_geo = nil
	blazelocked = false

	state.ShowDistance = M(true, 'Show Geomancy Buff/Debuff distance')
	state.AutoEntrust = M(false, 'AutoEntrust Mode')
	state.CombatEntrustOnly = M(true, 'Combat Entrust Only Mode')

    indi_timer = ''
    indi_duration = 180

	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode","AutoBuffMode"},{"Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","RecoverMode","ElementalMode","CastingMode","TreasureMode",})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.

function job_filtered_action(spell, eventArgs)

end

function job_filter_precast(spell, spellMap, eventArgs)

	if spell.english:startswith('Geo-') and pet.isvalid then
		eventArgs.cancel = true
		windower.chat.input('/ja "Full Circle" <me>')
		windower.chat.input:schedule(2,'/ma "'..spell.english..'" '..spell.target.raw..'')
	end

end

function job_pretarget(spell, spellMap, eventArgs)
    if spell.type == 'Geomancy' then
		if spell.name:startswith('Indi') then
			if state.Buff.Entrust then
				if spell.target.type == 'SELF' then
					add_to_chat(204, 'Entrust active - You can\'t entrust yourself.')
					eventArgs.cancel = true
				end
			elseif spell.target.type ~= 'SELF' then
				if state.AutoEntrust.value and ((spell.target.type == 'PLAYER' and not spell.target.charmed) or (spell.target.type == 'NPC')) and spell.target.in_party then
					local spell_recasts = windower.ffxi.get_spell_recasts()
					local abil_recasts = windower.ffxi.get_ability_recasts()
					eventArgs.cancel = true

					if spell_recasts[spell.recast_id] > 1.5 then
						add_to_chat(123,'Abort: ['..spell.english..'] waiting on recast. ('..seconds_to_clock(spell_recasts[spell.recast_id]/60)..')')
					elseif abil_recasts[93] > 0 then
						add_to_chat(123,'Abort: [Entrust] waiting on recast. ('..seconds_to_clock(abil_recasts[93])..')')
					else
						send_command('@input /ja "Entrust" <me>; wait 1.1; input /ma "'..spell.name..'" '..spell.target.name)
					end
				elseif spell.target.raw == '<t>' then
					change_target('<me>')
				end
			end
		elseif spell.name:startswith('Geo') then
			if set.contains(spell.targets, 'Enemy') then
				if ((spell.target.type == 'PLAYER' and not spell.target.charmed) or (spell.target.type == 'NPC' and spell.target.in_party)) then
					eventArgs.cancel = true
				end
			elseif not ((spell.target.type == 'PLAYER' and not spell.target.charmed and spell.target.in_party) or (spell.target.type == 'NPC' and spell.target.in_party) or (spell.target.raw == '<stpt>' or spell.target.raw == '<stal>' or spell.target.raw == '<st>')) then
				change_target('<me>')
			end
		end
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, spellMap, eventArgs)

	if spell.action_type == 'Magic' then
		if spellMap == 'Cure' or spellMap == 'Curaga' then
			gear.default.obi_back = gear.obi_cure_back
			gear.default.obi_waist = gear.obi_cure_waist
		elseif spell.skill == 'Elemental Magic' then
			if LowTierNukes:contains(spell.english) then
				gear.default.obi_back = gear.obi_low_nuke_back
				gear.default.obi_waist = gear.obi_low_nuke_waist
			else
				gear.default.obi_back = gear.obi_high_nuke_back
				gear.default.obi_waist = gear.obi_high_nuke_waist
			end
		end

        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        end
	elseif buffactive.Bolster and (spell.english == 'Blaze of Glory' or spell.english == 'Ecliptic Attrition') then
		eventArgs.cancel = true
		add_to_chat(123,'Abort: Bolster maxes the strength of bubbles.')
    end
end

function job_post_precast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))

		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if sets.MaxTP and get_effective_player_tp(spell, WSset) > 3200 then
				equip(sets.MaxTP[spell.english] or sets.MaxTP)
			end
		end
	end
end

function job_post_midcast(spell, spellMap, eventArgs)

	if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
		if state.MagicBurstMode.value ~= 'Off' then
			if state.CastingMode.value:contains('Resistant') and sets.ResistantMagicBurst then
				equip(sets.ResistantMagicBurst)
			else
				equip(sets.MagicBurst)
			end
		end
		if spell.element == world.weather_element or spell.element == world.day_element then
			if state.CastingMode.value == 'Fodder' then
				-- if item_available('Twilight Cape') and not LowTierNukes:contains(spell.english) and not state.Capacity.value then
					-- sets.TwilightCape = {back="Twilight Cape"}
					-- equip(sets.TwilightCape)
				-- end
				if spell.element == world.day_element then
					if item_available('Zodiac Ring') then
						sets.ZodiacRing = {ring2="Zodiac Ring"}
						equip(sets.ZodiacRing)
					end
				end
			end
		end

		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end

		if state.RecoverMode.value ~= 'Never' and (state.RecoverMode.value == 'Always' or tonumber(state.RecoverMode.value:sub(1, -2)) > player.mpp) then
			if state.MagicBurstMode.value ~= 'Off' then
				if state.CastingMode.value:contains('Resistant') and sets.ResistantRecoverBurst then
					equip(sets.ResistantRecoverBurst)
				elseif sets.RecoverBurst then
					equip(sets.RecoverBurst)
				end
			elseif sets.RecoverMP then
				equip(sets.RecoverMP)
			end
		end

    elseif spell.skill == 'Geomancy' then
		if spell.english:startswith('Geo-') then
			if state.Buff['Blaze of Glory'] and sets.buff['Blaze of Glory'] then
				equip(sets.buff['Blaze of Glory'])
				disable('head')
				blazelocked = true
			end
		elseif state.Buff.Entrust and spell.english:startswith('Indi-') then
			if sets.midcast.Geomancy.main == 'Idris' and item_available('Solstice') then
				equip({main="Solstice"})
			end
		end
    end

end

function job_aftercast(spell, spellMap, eventArgs)
    if not spell.interrupted then
        if spell.english:startswith('Indi-') then
            if spell.target.type == 'SELF' then
                last_indi = string.sub(spell.english,6)
            end
            if not classes.CustomIdleGroups:contains('Indi') then
                classes.CustomIdleGroups:append('Indi')
            end
			if state.UseCustomTimers.value then
				send_command('@timers d "'..spell.target.name..': '..indi_timer..'"')
				indi_timer = spell.english
				send_command('@timers c "'..spell.target.name..': '..indi_timer..'" '..indi_duration..' down spells/00136.png')
			end
		elseif spell.english:startswith('Geo-') or spell.english == "Mending Halation" or spell.english == "Radial Arcana" then
			eventArgs.handled = true
			if spell.english:startswith('Geo-') then
				last_geo = string.sub(spell.english,5)
			end
        elseif state.UseCustomTimers.value and spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif state.UseCustomTimers.value and spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 90 down spells/00220.png')
        elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
            state.MagicBurstMode:reset()
			if state.DisplayMode.value then update_job_states()	end
		end
    end

	if not player.indi then
        classes.CustomIdleGroups:clear()
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)

    if player.indi and not classes.CustomIdleGroups:contains('Indi') then
        classes.CustomIdleGroups:append('Indi')
        if not midaction () then handle_equipping_gear(player.status) end
    elseif classes.CustomIdleGroups:contains('Indi') and not player.indi then
        classes.CustomIdleGroups:clear()
        if not midaction () then handle_equipping_gear(player.status) end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function job_get_spell_map(spell, default_spell_map)

	if  default_spell_map == 'Cure' or default_spell_map == 'Curaga'  then
		if world.weather_element == 'Light' then
                return 'LightWeatherCure'
		elseif world.day_element == 'Light' then
                return 'LightDayCure'
        end

	elseif spell.skill == "Enfeebling Magic" then
		if spell.english:startswith('Dia') then
			return "Dia"
		elseif spell.type == "WhiteMagic" or spell.english:startswith('Frazzle') or spell.english:startswith('Distract') then
			return 'MndEnfeebles'
		else
			return 'IntEnfeebles'
		end

	elseif spell.skill == 'Geomancy' then
		if spell.english:startswith('Indi') then
			return 'Indi'
		end

    elseif spell.skill == 'Elemental Magic' then
		if default_spell_map == 'ElementalEnfeeble' or spell.english:contains('helix') then
			return
        elseif LowTierNukes:contains(spell.english) then
            return 'LowTierNuke'
        else
            return 'HighTierNuke'
        end
	end

end

function job_customize_idle_set(idleSet)
    if player.mpp < 51 and (state.IdleMode.value == 'Normal' or state.IdleMode.value == 'Sphere') and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    return idleSet
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    classes.CustomIdleGroups:clear()
    if player.indi then
        classes.CustomIdleGroups:append('Indi')
    end

end

-- Function that watches pet gain and loss.
function job_pet_change(pet, gain)
    if blazelocked then
		enable('head')
		blazelocked = false
	end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

function job_self_command(commandArgs, eventArgs)
	local lowerCommand = commandArgs[1]:lower()
	if lowerCommand == 'autoindi' and commandArgs[2] then
		autoindi = commandArgs[2]:ucfirst()
		add_to_chat(122,'Your Auto Indi- spell is set to '..autoindi..'.')
		if state.DisplayMode.value then update_job_states()	end
	elseif lowerCommand == 'autogeo' and commandArgs[2] then
		autogeo = commandArgs[2]:ucfirst()
		add_to_chat(122,'Your Auto Geo- spell is set to '..autogeo..'.')
		if state.DisplayMode.value then update_job_states()	end
	elseif lowerCommand == 'autoentrust' and commandArgs[2] then
		autoentrust = commandArgs[2]:ucfirst()
		add_to_chat(122,'Your Auto Entrust Indi- spell is set to '..autoentrust..'.')
		if state.DisplayMode.value then update_job_states()	end
	elseif lowerCommand:contains('trustee') and commandArgs[2] then
		autoentrustee = commandArgs[2]:ucfirst()
		add_to_chat(122,'Your Auto Entrustee target is set to '..autoentrustee..'.')
		if state.DisplayMode.value then update_job_states()	end
	elseif lowerCommand == 'elemental' then
		handle_elemental(commandArgs)
		eventArgs.handled = true
	end
end

-- Handling Elemental spells within Gearswap.
-- Format: gs c elemental <nuke, helix, skillchain1, skillchain2, weather>
function handle_elemental(cmdParams)
    -- cmdParams[1] == 'elemental'
    -- cmdParams[2] == ability to use

    if not cmdParams[2] then
        add_to_chat(123,'Error: No elemental command given.')
        return
    end
    local command = cmdParams[2]:lower()

    if command == 'nuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()

		if state.ElementalMode.value == 'Light' then
			if spell_recasts[29] < spell_latency and actual_cost(get_spell_table_by_name('Banish II')) < player.mp then
				windower.chat.input('/ma "Banish II" <t>')
			elseif spell_recasts[28] < spell_latency and actual_cost(get_spell_table_by_name('Banish')) < player.mp then
				windower.chat.input('/ma "Banish" <t>')
			else
				add_to_chat(123,'Abort: Banishes on cooldown or not enough MP.')
			end

		else
			if player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 99 and spell_recasts[get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..' V').id] < spell_latency and actual_cost(get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..' V')) < player.mp then
				windower.chat.input('/ma "'..elements.nuke[state.ElementalMode.value]..' V" <t>')
			else
				local tiers = {' IV',' III',' II',''}
				for k in ipairs(tiers) do
					if spell_recasts[get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
						windower.chat.input('/ma "'..elements.nuke[state.ElementalMode.value]..''..tiers[k]..'" <t>')
						return
					end
				end
				add_to_chat(123,'Abort: All '..elements.nuke[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')
			end
		end

	elseif command == 'ninjutsu' then
		windower.chat.input('/ma "'..elements.ninnuke[state.ElementalMode.value]..': Ni" <t>')

	elseif command == 'smallnuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()

		local tiers = {' II',''}
		for k in ipairs(tiers) do
			if spell_recasts[get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(elements.nuke[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
				windower.chat.input('/ma "'..elements.nuke[state.ElementalMode.value]..''..tiers[k]..'" <t>')
				return
			end
		end
		add_to_chat(123,'Abort: All '..elements.nuke[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')

	elseif command:contains('tier') then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierlist = {['tier1']='',['tier2']=' II',['tier3']=' III',['tier4']=' IV',['tier5']=' V',['tier6']=' VI'}

		windower.chat.input('/ma "'..elements.nuke[state.ElementalMode.value]..tierlist[command]..'" <t>')

	elseif command:contains('ara') then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierkey = {'ara3','ara2','ara'}
		local tierlist = {['ara3']='ra III',['ara2']='ra II',['ara']='ra'}
		if command == 'ara' then
			for i in ipairs(tierkey) do
				if spell_recasts[get_spell_table_by_name(elements.nukera[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(elements.nukera[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'')) < player.mp then
					windower.chat.input('/ma "'..elements.nukera[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'" <t>')
					return
				end
			end
		else
			windower.chat.input('/ma "'..elements.nukera[state.ElementalMode.value]..tierlist[command]..'" <t>')
		end

	elseif command == 'aga' then
		windower.chat.input('/ma "'..elements.nukega[state.ElementalMode.value]..'ga" <t>')

	elseif command == 'helix' then
		windower.chat.input('/ma "'..elements.helix[state.ElementalMode.value]..'helix" <t>')

	elseif command == 'enfeeble' then
		windower.chat.input('/ma "'..elements.enfeeble[state.ElementalMode.value]..'" <t>')

	elseif command == 'bardsong' then
		windower.chat.input('/ma "'..elements.threnody[state.ElementalMode.value]..' Threnody" <t>')

	elseif command == 'spikes' then
		windower.chat.input('/ma "'..elements.spikes[state.ElementalMode.value]..' Spikes" <me>')

	elseif command == 'enspell' then
			windower.chat.input('/ma "En'..elements.enspell[state.ElementalMode.value]..'" <me>')

	--Leave out target, let shortcuts auto-determine it.
	elseif command == 'weather' then
		if player.sub_job == 'RDM' then
			windower.chat.input('/ma "Phalanx" <me>')
		else
			local spell_recasts = windower.ffxi.get_spell_recasts()
			if (player.target.type == 'SELF' or not player.target.in_party) and buffactive[elements.storm_of[state.ElementalMode.value]] and not buffactive['Klimaform'] and spell_recasts[287] < spell_latency then
				windower.chat.input('/ma "Klimaform" <me>')
			else
				windower.chat.input('/ma "'..elements.storm_of[state.ElementalMode.value]..'"')
			end
		end

    else
        add_to_chat(123,'Unrecognized elemental command.')
    end

end

function job_tick()
	if check_geo() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end

function check_geo()
	if state.AutoBuffMode.value and not areas.Cities:contains(world.area) then
		if autoindi ~= 'None' and ((not player.indi) or last_indi ~= autoindi) then
			windower.chat.input('/ma "Indi-'..autoindi..'" <me>')
			tickdelay = os.clock() + 2.1
			return true
		elseif autoentrust ~= 'None' and windower.ffxi.get_ability_recasts()[93] < latency and (player.in_combat or state.CombatEntrustOnly.value == false) then
			send_command('@input /ja "Entrust" <me>; wait 1.1; input /ma "Indi-'..autoentrust..'" '..autoentrustee)
			tickdelay = os.clock() + 3.5
			return true
		elseif pet.isvalid then
			local pet = windower.ffxi.get_mob_by_target("pet")
			if pet.distance:sqrt() > 50 then --If pet is greater than detectable.
				windower.chat.input('/ja "Full Circle" <me>')
				tickdelay = os.clock() + 1.8
				return true
			else
				return false
			end
		elseif not pet.isvalid and autogeo ~= 'None' and (windower.ffxi.get_mob_by_target('bt') or geo_buffs:contains(autogeo)) then
			windower.chat.input('/ma "Geo-'..autogeo..'" <bt>')
			tickdelay = os.clock() + 3.1
			return true
		else
			return false
		end
	else
		return false
	end
end

--Luopan Distance Tracking
debuff_list = S{'Gravity','Paralysis','Slow','Languor','Vex','Torpor','Slip','Malaise','Fade','Frailty','Wilt','Poison'}
ignore_list = S{'SlipperySilas','HareFamiliar','SheepFamiliar','FlowerpotBill','TigerFamiliar','FlytrapFamiliar','LizardFamiliar','MayflyFamiliar','EftFamiliar','BeetleFamiliar','AntlionFamiliar','CrabFamiliar','MiteFamiliar','KeenearedSteffi','LullabyMelodia','FlowerpotBen','SaberSiravarde','FunguarFamiliar','ShellbusterOrob','ColdbloodComo','CourierCarrie','Homunculus','VoraciousAudrey','AmbusherAllie','PanzerGalahad','LifedrinkerLars','ChopsueyChucky','AmigoSabotender','NurseryNazuna','CraftyClyvonne','PrestoJulio','SwiftSieghard','MailbusterCetas','AudaciousAnna','TurbidToloi','LuckyLulush','DipperYuly','FlowerpotMerle','DapperMac','DiscreetLouise','FatsoFargann','FaithfulFalcorr','BugeyedBroncha','BloodclawShasra','GorefangHobs','GooeyGerard','CrudeRaphie','DroopyDortwin','SunburstMalfik','WarlikePatrick','ScissorlegXerin','RhymingShizuna','AttentiveIbuki','AmiableRoche','HeraldHenry','BrainyWaluis','SuspiciousAlice','HeadbreakerKen','RedolentCandi','CaringKiyomaro','HurlerPercival','AnklebiterJedd','BlackbeardRandy','FleetReinhard','GenerousArthur','ThreestarLynn','BraveHeroGlenn','SharpwitHermes','AlluringHoney','CursedAnnabelle','SwoopingZhivago','BouncingBertha','MosquitoFamilia','Ifrit','Shiva','Garuda','Fenrir','Carbuncle','Ramuh','Leviathan','CaitSith','Diabolos','Titan','Atomos','WaterSpirit','FireSpirit','EarthSpirit','ThunderSpirit','AirSpirit','LightSpirit','DarkSpirit','IceSpirit', 'Azure','Cerulean','Rygor','Firewing','Delphyne','Ember','Rover','Max','Buster','Duke','Oscar','Maggie','Jessie','Lady','Hien','Raiden','Lumiere','Eisenzahn','Pfeil','Wuffi','George','Donryu','Qiqiru','Karav-Marav','Oboro','Darug Borug','Mikan','Vhiki','Sasavi','Tatang','Nanaja','Khocha','Nanaja','Khocha','Dino','Chomper','Huffy','Pouncer','Fido','Lucy','Jake','Rocky','Rex','Rusty','Himmelskralle','Gizmo','Spike','Sylvester','Milo','Tom','Toby','Felix','Komet','Bo','Molly','Unryu','Daisy','Baron','Ginger','Muffin','Lumineux','Quatrevents','Toryu','Tataba','Etoilazuree','Grisnuage','Belorage','Centonnerre','Nouvellune','Missy','Amedeo','Tranchevent','Soufflefeu','Etoile','Tonnerre','Nuage','Foudre','Hyuh','Orage','Lune','Astre','Waffenzahn','Soleil','Courageux','Koffla-Paffla','Venteuse','Lunaire','Tora','Celeste','Galja-Mogalja','Gaboh','Vhyun','Orageuse','Stellaire','Solaire','Wirbelwind','Blutkralle','Bogen','Junker','Flink','Knirps','Bodo','Soryu','Wanaro','Totona','Levian-Movian','Kagero','Joseph','Paparaz','Coco','Ringo','Nonomi','Teter','Gigima','Gogodavi','Rurumo','Tupah','Jyubih','Majha','Luron','Drille','Tournefoux','Chafouin','Plaisantin','Loustic','Histrion','Bobeche','Bougrion','Rouleteau','Allouette','Serenade','Ficelette','Tocadie','Caprice','Foucade','Capillotte','Quenotte','Pacotille','Comedie','Kagekiyo','Toraoh','Genta','Kintoki','Koumei','Pamama','Lobo','Tsukushi','Oniwaka','Kenbishi','Hannya','Mashira','Nadeshiko','E100','Koume','X-32','Poppo','Asuka','Sakura','Tao','Mao','Gadget','Marion','Widget','Quirk','Sprocket','Cogette','Lecter','Coppelia','Sparky','Clank','Calcobrena','Crackle','Ricochet','Josette','Fritz','Skippy','Pino','Mandarin','Jackstraw','Guignol','Moppet','Nutcracker','Erwin','Otto','Gustav','Muffin','Xaver','Toni','Ina','Gerda','Petra','Verena','Rosi','Schatzi','Warashi','Klingel','Clochette','Campanello','Kaiserin','Principessa','Butler','Graf','Caro','Cara','Mademoiselle','Herzog','Tramp','V-1000','Hikozaemon','Nine','Acht','Quattro','Zero','Dreizehn','Seize','Fukusuke','Mataemon','Kansuke','Polichinelle','Tobisuke','Sasuke','Shijimi','Chobi','Aurelie','Magalie','Aurore','Caroline','Andrea','Machinette','Clarine','Armelle','Reinette','Dorlote','Turlupin','Klaxon','Bambino','Potiron','Fustige','Amidon','Machin','Bidulon','Tandem','Prestidige','Purute-Porute','Bito-Rabito','Cocoa','Totomo','Centurion','A7V','Scipio','Sentinel','Pioneer','Seneschal','Ginjin','Amagatsu','Dolly','Fantoccini','Joe','Kikizaru','Whippet','Punchinello','Charlie','Midge','Petrouchka','Schneider','Ushabti','Noel','Yajirobe','Hina','Nora','Shoki','Kobina','Kokeshi','Mame','Bishop','Marvin','Dora','Data','Robin','Robby','Porlo-Moperlo','Paroko-Puronko','Pipima','Gagaja','Mobil','Donzel','Archer','Shooter','Stephen','Mk.IV','Conjurer','Footman','Tokotoko','Sancho','Sarumaro','Picket','Mushroom','Shantotto','Naji','Kupipi','Excenmille','Ayame','NanaaMihgo','Curilla','Volker','Ajido-Marujido','Trion','Zeid','Lion','Tenzen','MihliAliapoh','Valaineral','Joachim','NajaSalaheem','Prishe','Ulmia','ShikareeZ','Cherukiki','IronEater','Gessho','Gadalar','Rainemard','Ingrid','LehkoHabhoka','Nashmeira','Zazarg','Ovjang','Mnejing','Sakura','Luzaf','Najelith','Aldo','Moogle','Fablinix','Maat','D.Shantotto','StarSibyl','Karaha-Baruha','Cid','Gilgamesh','Areuhat','SemihLafihna','Elivira','Noillurie','LhuMhakaracca','FerreousCoffin','Lilisette','Mumor','UkaTotlihn','Klara','RomaaMihgo','KuyinHathdenna','Rahal','Koru-Moru','Pieuje','InvincibleShld','Apururu','JakohWahcondalo','Flaviria','Babban','Abenzio','Rughadjeen','Kukki-Chebukki','Margret','Chacharoon','LheLhangavo','Arciela','Mayakov','Qultada','Adelheid','Amchuchu','Brygid','Mildaurion','Halver','Rongelouts','Leonoyne','Maximilian','Kayeel-Payeel','Robel-Akbel','Kupofried','Selh\'teus','Yoran-Oran','Sylvie','Abquhbah','Balamor','August','Rosulatia','Teodor','Ullegore','Makki-Chebukki','KingOfHearts','Morimar','Darrcuiln','ArkHM','ArkEV','ArkMR','ArkTT','ArkGK','Iroha','Ygnas','Excenmille','Ayame','Maat','Aldo','NajaSalaheem','Lion','Zeid'}

luopantxt = {}
luopantxt.pos = {}
luopantxt.pos.x = -200
luopantxt.pos.y = 175
luopantxt.text = {}
luopantxt.text.font = 'Arial'
luopantxt.text.size = 12
luopantxt.flags = {}
luopantxt.flags.right = true

luopan = texts.new('${value}', luopantxt)

luopan:bold(true)
luopan:bg_alpha(0)--128
luopan:stroke_width(2)
luopan:stroke_transparency(192)

bt_color = '\\cs(230,118,116)'

windower.raw_register_event('prerender', function()
    local s = windower.ffxi.get_mob_by_target('me')
    if windower.ffxi.get_mob_by_target('pet') then
        myluopan = windower.ffxi.get_mob_by_target('pet')
    else
        myluopan = nil
    end
    local luopan_txtbox = ''
    local indi_count = 0
    local geo_count = 0
    local battle_target = windower.ffxi.get_mob_by_target('bt') or false
    if myluopan and last_geo then
        luopan_txtbox = luopan_txtbox..' \\cs(0,255,0)Geo-'..last_geo..':\\cs(255,255,255)\n'
        for i,v in pairs(windower.ffxi.get_mob_array()) do
            local DistanceBetween = ((myluopan.x - v.x)*(myluopan.x-v.x) + (myluopan.y-v.y)*(myluopan.y-v.y)):sqrt()
            if DistanceBetween < (6 + v.model_size) and not (v.status == 2 or v.status == 3) and v.name and v.name ~= '' and v.name ~= "Luopan" and v.valid_target and v.model_size > 0 then
                if debuff_list:contains(last_geo) then
					if v.is_npc and not (v.in_party or ignore_list:contains(v.name)) then
						if battle_target and battle_target.id == v.id then
							luopan_txtbox = luopan_txtbox..' '..bt_color..v.name.." "..string.format("%.2f",DistanceBetween).."\\cs(255,255,255)\n"
						else
							luopan_txtbox = luopan_txtbox..' '..v.name.." "..string.format("%.2f",DistanceBetween).."\n"
						end
						geo_count = geo_count + 1
					end
                else
					if v.in_party then
						luopan_txtbox = luopan_txtbox..' '..v.name.." "..string.format("%.2f",DistanceBetween).."\n"
						geo_count = geo_count + 1
					end
                end
            end
        end
    end

    if buffactive['Colure Active'] and last_indi then
		if myluopan then
			luopan_txtbox = luopan_txtbox..'\n'
		end
		luopan_txtbox = luopan_txtbox..' \\cs(0,255,0)Indi-'..last_indi..':\\cs(255,255,255)\n'
		for i,v in pairs(windower.ffxi.get_mob_array()) do
			local DistanceBetween = ((s.x - v.x)*(s.x-v.x) + (s.y-v.y)*(s.y-v.y)):sqrt()
			if DistanceBetween < (6 + v.model_size) and (v.status == 1 or v.status == 0) and v.name and v.name ~= '' and v.name ~= "Luopan" and v.name ~= s.name and v.valid_target and v.model_size > 0 then
				if debuff_list:contains(last_indi) then
					if v.is_npc and not (v.in_party or ignore_list:contains(v.name)) then
						if battle_target and battle_target.id == v.id then
							luopan_txtbox = luopan_txtbox..' '..bt_color..v.name.." "..string.format("%.2f",DistanceBetween).."\\cs(255,255,255)\n"
						else
							luopan_txtbox = luopan_txtbox..' '..v.name.." "..string.format("%.2f",DistanceBetween).."\n"
						end
						indi_count = indi_count + 1
					end
				else
					if v.in_party then
						luopan_txtbox = luopan_txtbox..' '..v.name.." "..string.format("%.2f",DistanceBetween).."\n"
						indi_count = indi_count + 1
					end
				end
			end
		end
    end

    luopan.value = luopan_txtbox
    if state.ShowDistance and state.ShowDistance.value and ((myluopan and geo_count ~= 0) or (buffactive['Colure Active'] and indi_count ~= 0)) then
        luopan:visible(true)
    else
        luopan:visible(false)
    end

end)

function check_buff()
	if state.AutoBuffMode.value and not areas.Cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		for i in pairs(buff_spell_lists['Auto']) do
			if not buffactive[buff_spell_lists['Auto'][i].Buff] and (buff_spell_lists['Auto'][i].When == 'Always' or (buff_spell_lists['Auto'][i].When == 'Combat' and (player.in_combat or being_attacked)) or (buff_spell_lists['Auto'][i].When == 'Engaged' and player.status == 'Engaged') or (buff_spell_lists['Auto'][i].When == 'Idle' and player.status == 'Idle') or (buff_spell_lists['Auto'][i].When == 'OutOfCombat' and not (player.in_combat or being_attacked))) and spell_recasts[buff_spell_lists['Auto'][i].SpellID] < latency and silent_can_use(buff_spell_lists['Auto'][i].SpellID) then
				windower.chat.input('/ma "'..buff_spell_lists['Auto'][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
	else
		return false
	end
end

function check_buffup()
	if buffup ~= '' then
		local needsbuff = false
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) then
				needsbuff = true
				break
			end
		end

		if not needsbuff then
			add_to_chat(217, 'All '..buffup..' buffs are up!')
			buffup = ''
			return false
		end

		local spell_recasts = windower.ffxi.get_spell_recasts()

		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) and spell_recasts[buff_spell_lists[buffup][i].SpellID] < latency then
				windower.chat.input('/ma "'..buff_spell_lists[buffup][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end

		return false
	else
		return false
	end
end

buff_spell_lists = {
	Auto = {
		{Name='Haste',		Buff='Haste',		SpellID=57,		When='Always'},
		{Name='Refresh',	Buff='Refresh',		SpellID=109,	When='Always'},
		{Name='Stoneskin',	Buff='Stoneskin',	SpellID=54,		When='Always'},
	},

	Default = {
		{Name='Haste',		Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Refresh',	Buff='Refresh',		SpellID=109,	Reapply=false},
		{Name='Aquaveil',	Buff='Aquaveil',	SpellID=55,		Reapply=false},
		{Name='Stoneskin',	Buff='Stoneskin',	SpellID=54,		Reapply=false},
		{Name='Blink',		Buff='Blink',		SpellID=53,		Reapply=false},
		{Name='Regen',		Buff='Regen',		SpellID=108,	Reapply=false},
		{Name='Phalanx',	Buff='Phalanx',		SpellID=106,	Reapply=false},
	},
}
