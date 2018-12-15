----- Credit: Krystela of Asura | Last Update: 27 November 2016 ---->
---- .:: This was entirely created by me, it's not based off anyone's file ::. ---->
---- Always visit http://pastebin.com/u/KrystelaRose to look for possible updates ---->
---- .:: Please leave credit where it's due ::. ---->
---- .:: If you have any problem contact me via ffxiah: http://www.ffxiah.com/player/Asura/Krystela ::. ---->

function user_unload()
    send_command('unbind ^f1')
    send_command('unbind ^f9')	
    send_command('unbind ^f10')
    send_command('unbind ^f11')		
end	
function get_sets()
-- Binds for modes
    send_command('bind ^f1 gs c C1')
	send_command('bind ^f9 gs c C9')	
	send_command('bind ^f10 gs c C10')
	send_command('bind ^f11 gs c C11')
-- Auto Functions --
	AutoRemedy = 'OFF' -- Set to ON if you want to auto use remedies if silenced or Paralyzed, otherwise set to OFF --	
	AutoBlaze = 'ON' -- Set to ON if you want to auto use Blaze of glory on Geo- spells, otherwise set to OFF --	
	AutoEntrust = 'ON' -- Set to ON if you want to auto use Entrust when you are targetting a player other than yourself to cast indi spells, otherwise set to OFF --
-- Custom Timers --
    -- Still looking for a way to auto detect individual indi spell	timers, if you have all the gears, your duration is 5 min, load timers to see it --
	-- I will better this, this is a work in progress just like bard timers. Stay tuned! --
-- Modes --
    LuopanIndex = 1
    LuopanArray = {"Normal","Regen","Defense"} -- Press ctrl + F9 to circle through Luopan modes --
    MagicBurst = 'OFF' -- Press ctrl + F1 to circle through Magic modes --
	WeaponLock = 'OFF' -- Press ctrl + F10 for Weapon Lock--	
	Capacity = 'OFF' -- Press Ctrl +F11 to have Capacity cape locked on while Idle, Change the cape at line 28 --
-- Gears --
    gear = {} -- Fill these --
	gear.Capacity_Cape = {name="Mecisto. Mantle"} -- The cape you use for capacity --
	gear.Refresh_Head = {name="Amalric Coif"} -- Add refresh effect + head if you want to use it, it not leave {} empty --	
-- Set macro book/set --
    --send_command('input /macro book 3;wait .1;input /macro set 1') -- set macro book/set here --	
	set_lockstyle('1')
	
-- Area mapping --	
    Town = S{"Ru'Lude Gardens","Upper Jeuno","Lower Jeuno","Port Jeuno","Port Windurst","Windurst Waters","Windurst Woods","Windurst Walls","Heavens Tower",
	         "Port San d'Oria","Northern San d'Oria","Southern San d'Oria","Port Bastok","Bastok Markets","Bastok Mines","Metalworks","Aht Urhgan Whitegate",
	         "Tavnazian Safehold","Nashmau","Selbina","Mhaura","Norg","Eastern Adoulin","Western Adoulin","Kazham","Heavens Tower"}
	
---- Precast ----

    sets.precast = {}
	
	-- Base Set --
	sets.precast.FC = {
		range="Dunna",
		head="Haruspex Hat",
		legs="Geomancy Pants",
		feet="Chelona Boots",
		neck={ name="Jeweled Collar", augments={'"Fast Cast"+1','INT+2',}},
		right_ear="Loquac. Earring",
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	}
	
    sets.precast.Geomancy = set_combine(sets.precast.FC, {
	
	})	
    
	sets.precast.Indi = set_combine(sets.precast.Geomancy, {
	
	}) 		
    
	sets.precast.Cure = set_combine(sets.precast.FC, {
		back="Pahtli Cape"
	})
	
    sets.precast.Enhancing = set_combine(sets.precast.FC, {
		waist="Siegel Sash"
	})
    
	sets.precast['Stoneskin'] = set_combine(sets.precast.Enhancing, {
		head="Umuthi Hat",
	})
	
	sets.precast.Elemental = set_combine(sets.precast.FC, {
		neck="Stoicheion Medal",
		left_ear="Barkaro. Earring",
		hands="Bagua Mitaines"	
	})
	
	sets.precast['Impact'] = set_combine(sets.precast.FC, { -- Make sure to leave the head empty --
	    head=empty,
        body="Twilight Cloak"
	})	

	-- Job Abilities --
    sets.JA ={}
    sets.JA['Bolster'] = {body="Bagua Tunic"}
	sets.JA['Full Circle'] = {head="Azimuth Hood"}
    sets.JA['Life Cycle'] = {body="Geomancy Tunic", back="Nantosuelta's Cape"}
	sets.JA['Radial Arcana'] = {feet="Bagua Sandals"}

	-- Weaponskills --
	sets.WS = {} -- Your base set for ws's --
    sets.WS['Realmrazer'] = set_combine(sets.WS, {})
    sets.WS['Exudation'] = set_combine(sets.WS, {})	

---- Midcast ----

	sets.midcast = {}
    -- Base Set --	
    sets.midcast.Recast = set_combine(sets.precast.FC, {})

	-- Healing Magic --
    sets.midcast.Cure = {
		main="Tefnut Wand"
	}
	sets.midcast.Cure.Weather = set_combine(sets.midcast.Cure, {
		
	})
    sets.midcast.Cure.WeaponLock = set_combine(sets.midcast.Cure, {
		
	})
	sets.midcast['Cursna'] = set_combine(sets.midcast.Cure, {
	
	})
	
    -- Enhancing Magic --		
	sets.midcast.Duration = {
		main="Bolelabunga",
		head="Umuthi Hat"
	}
    sets.midcast['Phalanx'] = set_combine(sets.midcast.Duration, {})				
    sets.midcast['Stoneskin'] = set_combine(sets.midcast.Duration, {})	
    sets.midcast['Aquaveil'] = set_combine(sets.midcast.Duration, {
		main="Vadose Rod", 
		head="Amalric Coif"
	})
	
	-- Enfeebling Magic --	
    sets.midcast.Enfeebling = { -- Full skill set for frazzle/distract/Poison -- 
		main="Eosuchus Club",
		sub="Genbu's Shield",
		range="Dunna",
		head="Azimuth Hood",
		body="Azimuth Coat",
		hands="Azimuth Gloves",
		legs="Azimuth Tights",
		feet={ name="Bagua Sandals", augments={'Enhances "Radial Arcana" effect',}},
		neck="Eddy Necklace",
		waist="Yamabuki-no-Obi",
		left_ear="Barkaro. Earring",
		right_ear="Gwati Earring",
		left_ring="Perception Ring",
		right_ring="Balrahn's Ring",
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	}
		
	sets.midcast.Enfeebling.Macc = set_combine(sets.midcast.Enfeebling, {})	-- For Silence/Dispel/Sleep/Break/Gravity that arent affect by full enfeeb set or effect gears --		
    sets.midcast.Enfeebling.MND = set_combine(sets.midcast.Enfeebling, {}) -- For Paralyze/Slow who's potency/macc is enhanced by MND --
    sets.midcast.Enfeebling.INT = set_combine(sets.midcast.Enfeebling, {}) -- For Blind/Bind who's Macc is enhanced by INT --	

	-- Dark Magic --
    sets.midcast.Bio = { -- For Bio, you want a full Dark magic skill set for potency -- 
		main="Eosuchus Club",
		sub="Genbu's Shield",
		range="Dunna",
		head={ name="Bagua Galero", augments={'Enhances "Primeval Zeal" effect',}},
		body="Geomancy Tunic",
		hands="Yaoyotl Gloves",
		legs="Azimuth Tights",
		feet={ name="Bagua Sandals", augments={'Enhances "Radial Arcana" effect',}},
		neck="Eddy Necklace",
		waist="Fucho-no-Obi",
		left_ear="Barkaro. Earring",
		right_ear="Gwati Earring",
		left_ring="Perception Ring",
		right_ring="Acumen Ring",
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	}
    sets.midcast.Dark = set_combine(sets.midcast.Bio, { -- For Aspir/Drain -- 

	})
    sets.midcast['Stun']  = set_combine(sets.midcast.Bio, {})	

	-- Elemental Magic --
    sets.midcast.Elemental = { -- Normal Nukes --
		main="Eosuchus Club",
		sub="Genbu's Shield",
		range="Dunna",
		head="Geomancy Galero",
		body="Azimuth Coat",
		hands="Yaoyotl Gloves",
		legs="Azimuth Tights",
		feet="Umbani Boots",
		neck="Eddy Necklace",
		waist="Yamabuki-no-Obi",
		left_ear="Barkaro. Earring",
		right_ear="Hecate's Earring",
		left_ring="Perception Ring",
		right_ring="Acumen Ring",
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	} 
    sets.midcast.Elemental.MB = set_combine(sets.midcast.Elemental, { -- For when MB mode is turned on --
		left_ring="Locus Ring",
	})		
    sets.midcast.Elemental.Weather = set_combine(sets.midcast.Elemental, { -- For normal nukes with weather on/appropriate day --

	})	
    sets.midcast.Elemental.MB.Weather = set_combine(sets.midcast.Elemental.MB, { -- For MB nukes with weather on/appropriate day --

	})
	sets.midcast['Impact'] = set_combine(sets.midcast.Elemental, {  -- Make sure to leave the head empty --
	    head=empty,
	    body="Twilight Cloak"
	})		

	-- Geomancy Magic --
    sets.midcast.Geomancy = {
		range="Dunna",
		head="Azimuth Hood",
		body={ name="Bagua Tunic", augments={'Enhances "Bolster" effect',}},
		hands="Geomancy Mitaines",
		legs={ name="Bagua Pants", augments={'Enhances "Mending Halation" effect',}},
		feet="Azimuth Gaiters",
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	}
	sets.midcast.Indi = set_combine(sets.midcast.Geomancy, {
		
	}) 	

---- Aftercast ----

    sets.aftercast = {}
	-- Player Idle sets --
    sets.aftercast.Idle = {
		main="Bolelabunga",
		sub="Genbu's Shield",
		range="Dunna",
		head="Azimuth Hood",
		body="Artsieq Jubbah",
		hands={ name="Bagua Mitaines", augments={'Enhances "Curative Recantation" effect',}},
		legs="Wayfarer Slops",
		feet={ name="Bagua Sandals", augments={'Enhances "Radial Arcana" effect',}},
		neck={ name="Jeweled Collar", augments={'"Fast Cast"+1','INT+2',}},
		waist="Fucho-no-Obi",
		left_ear="Zennaroi Earring",
		right_ear="Loquac. Earring",
		left_ring={ name="Dark Ring", augments={'Phys. dmg. taken -6%','Breath dmg. taken -3%',}},
		right_ring={ name="Dark Ring", augments={'Phys. dmg. taken -5%','Magic dmg. taken -3%','Breath dmg. taken -4%',}},
		back={ name="Lifestream Cape", augments={'Geomancy Skill +10','Indi. eff. dur. +12','Pet: Damage taken -2%',}},
	}
    sets.aftercast.Refresh = set_combine(sets.aftercast.Idle, { -- Refresh gears goes here --
	
	})       	
	-- Pet Idle sets --
    sets.aftercast.Luopan =  set_combine(sets.aftercast.Idle, { -- When you want refresh wile luopan is out --

	})	
    sets.aftercast.Luopan.Regen =  set_combine(sets.aftercast.Luopan, { -- Luopan Regen gears --

	})			
    sets.aftercast.Luopan.Defense = set_combine(sets.aftercast.Luopan, { -- When YOU need to stand in range --

	})
    sets.aftercast.Town = set_combine(sets.aftercast.Idle, {}) -- For town --
    sets.resting = {}
---- Melee ----
    sets.engaged = {}
    sets.engaged.DualWield = {}	
end	

---- .::Pretarget Functions::. ---->
function pretarget(spell,action)
    -- Auto Remedy --
	if AutoRemedy == 'ON' then
        if buffactive['Silence'] or buffactive['Paralysis'] then
            if spell.action_type == 'Magic' or spell.type == 'JobAbility' then 	
                cancel_spell()
                send_command('input /item "Remedy" <me>')
            end				
		end	
	end
-- Auto Blaze of Glory --	
	if AutoBlaze == 'ON' then	
	    if string.find(spell.english, 'Geo-') then
            if not buffactive['Bolster'] and not buffactive['Amnesia'] and not pet.isvalid and windower.ffxi.get_ability_recasts()[247] < 1	then
		        cancel_spell()
			    send_command('@input /ja "Blaze of Glory" <me>;wait 2;input /ma "'..spell.english..'" <t>')
	        end
		end
    end		
-- Auto Entrust --	
	if AutoEntrust == 'ON' then	
	    if string.find(spell.english, 'Indi-') then	
            if spell.target.type == 'PLAYER' and windower.ffxi.get_ability_recasts()[93] < 1 and not buffactive['Entrust'] and not buffactive['Amnesia']  then
                cancel_spell()
                send_command('@input /ja "entrust" <me>;wait 1.5;input /ma "'..spell.english..'" '..spell.target.name..';')		
		    end
		end	
	end
end	
---- .::Precast Functions::. ---->
function precast(spell)	
    if spell.action_type == 'Magic' then
		-- Healing Magic --
	    if string.find(spell.english, 'Cure') or string.find(spell.english, 'Cura') then
		    equip(sets.precast.Cure)
		-- Enhancing Magic --	
		elseif spell.skill == 'Enhancing Magic' then
         	equip(sets.precast.Enhancing)
		-- Elemental Magic --	
		elseif spell.skill == 'Elemental Magic' then
		    if spell.english == 'Impact' then
			    equip(sets.precast[spell.english])
			else	
         	    equip(sets.precast.Elemental)
			end	
        -- Geomancy Magic --		
        elseif spell.skill == 'Geomancy' then
			if string.find(spell.english, 'Indi') then
			    if buffactive['Entrust'] then
                    equip(sets.precast.Indi, {main="Solstice"})
				else 
                    equip(sets.precast.Indi)				
                end
            else
                equip(sets.precast.Geomancy)			
			end
        -- Everything that have a specific name set --	
		elseif sets.precast[spell.english] then
	        equip(sets.precast[spell.english])				
        -- Everything else that doesn't have a specific set for it --					
        else
		    equip(sets.precast.FC)
        end		
    -- Job Abilities --	
    elseif spell.type == 'JobAbility' then
		if spell.english == 'Radial Arcana' then
		    equip(sets.JA[spell.english])
			disable('feet')
		else
            equip(sets.JA[spell.english])		
		end			
    -- Weaponskills --
    elseif spell.type == 'WeaponSkill' then
        if sets.WS[spell.english] then	
            equip(sets.WS[spell.english])
	    else
		    equip(sets.WS)
		end	
    end		
end	
---- .::Midcast Functions::. ---->
function midcast(spell)
    if spell.action_type == 'Magic' then
		-- Healing Magic --
	    if string.find(spell.english, 'Cure') or string.find(spell.english, 'Cura') then
		    if WeaponLock == 'ON' then
			    equip(sets.midcast.Cure.WeaponLock)
	        elseif spell.element == world.weather_element or spell.element == world.day_element then
                equip(sets.midcast.Cure.Weather)	
			else
                equip(sets.midcast.Cure)
			end
        -- Enhancing Magic --			
        elseif string.find(spell.english,'Haste') or string.find(spell.english,'Reraise') or string.find(spell.english,'Flurry') then
            equip(sets.midcast.Duration)
        elseif spell.english == 'Refresh' then
            equip(sets.midcast.Duration, {head=gear.Refresh_Head})		
        -- Enfeebling Magic --			
	    elseif string.find(spell.english, 'Frazzle') or string.find(spell.english, 'Distract') or string.find(spell.english, 'Poison') then				
            equip(sets.midcast.Enfeebling)			
	    elseif string.find(spell.english, 'Dispel') or string.find(spell.english, 'Silence') or string.find(spell.english, 'Gravity') or string.find(spell.english, 'Sleep') or string.find(spell.english, 'Break') then
            equip(sets.midcast.Enfeebling.Macc)	
	    elseif string.find(spell.english, 'Paralyze') or string.find(spell.english, 'Slow') or string.find(spell.english, 'Addle') then
            equip(sets.midcast.Enfeebling.MND)			
		elseif string.find(spell.english, 'Blind') or spell.english == 'Bind' then
            equip(sets.midcast.Enfeebling.INT)
-- Dark Magic --		
		-- Dark Magic --	
		elseif string.find(spell.english, 'Bio') then
            equip(sets.midcast.Bio)				
	    elseif string.find(spell.english, 'Aspir') or string.find(spell.english, 'Drain') then
            equip(sets.midcast.Dark)
        -- Elemental Magic --			
        elseif spell.skill == 'Elemental Magic' then
		    if spell.english == 'Impact' then
			    equip(sets.midcast[spell.english])
            elseif MagicBurst == 'ON' then
	            if spell.element == world.weather_element or spell.element == world.day_element then  			
                    equip(sets.midcast.Elemental.MB.Weather)
                else
                    equip(sets.midcast.Elemental.MB)
                end
	        elseif spell.element == world.weather_element or spell.element == world.day_element then  
                equip(sets.midcast.Elemental.Weather)
            else
                equip(sets.midcast.Elemental)
			end
        -- Geomancy Magic --		
        elseif spell.skill == 'Geomancy' then
            if string.find(spell.english, 'Indi-') then			
			    if buffactive['Entrust'] then
				    equip(sets.midcast.Indi, {main="Solstice"})
       			    windower.send_command('timers c "Entrust Indi-Spell" 255')					
				else
                    equip(sets.midcast.Indi)
       			    windower.send_command('timers c "Indi-Spell" 255')					
				end	
			else	
                equip(sets.midcast.Geomancy)									
			end	
        -- Everything that have a specific name set --	
		elseif sets.midcast[spell.english] then
	        equip(sets.midcast[spell.english])				
		-- Everything else that doesn't have a specific set for it --			
		else
            equip(sets.midcast.Recast)		
	    end
	end		
end	
---- .::Aftercast Sets::. ---->
function aftercast(spell,action)
	status_change(player.status)	
end	
---- .::Player Status Changes Functions::. ---->
function status_change(new,tab,old)
    -- Idle --
    if new == 'Idle' then
	    if Town:contains(world.zone) then
            equip(sets.aftercast.Town)	
	    elseif pet.isvalid then
	        if LuopanArray[LuopanIndex] == 'Normal' then
                equip(sets.aftercast.Luopan)		
            elseif LuopanArray[LuopanIndex] == 'Regen' then	
                equip(sets.aftercast.Luopan.Regen)				
            elseif LuopanArray[LuopanIndex] == 'Defense' then	
                equip(sets.aftercast.Luopan.Defense)				
		    end
	    elseif player.mpp <80 then
            equip(sets.aftercast.Refresh)
        else
            equip(sets.aftercast.Idle)		
		end	
	-- Resting --	
	elseif new == 'Resting' then
        equip(sets.Resting)	
    -- Engaged --		
    elseif new == 'Engaged' then
	    if player.sub_job == 'DNC' or player.sub_job == 'NIN' then
            equip(sets.engaged.DualWield)	
		else	
            equip(sets.engaged)	
		end	
    end		
end 
--- ..:: Pet Status change ::.. --->
function pet_change(pet,gain_or_loss)
    status_change(player.status)
    if not gain_or_loss then
        enable('feet')
		send_command('input /echo ..:: Luopan died ::..')
    end	
end
--- ..::Self Commands functions::.. --->
function self_command(command)
    status_change(player.status)	
	-- Magic burst --
    if command == 'C1' then
        if MagicBurst == 'ON' then
            MagicBurst = 'OFF'			
            add_to_chat(123,'Magic Burst Set: [OFF]')
        else
            MagicBurst = 'ON'		
            add_to_chat(158,'Magic Burst Set: [ON]')
        end
        status_change(player.status)
    -- Luopan Idle Cycle --			
	elseif command == 'C9' then 	
        LuopanIndex = (LuopanIndex % #LuopanArray) + 1
        add_to_chat(158,'Luopan Idle Set: ' .. LuopanArray[LuopanIndex])
        status_change(player.status)
    -- Weapon Lock --		
    elseif command == 'C10' then
        if WeaponLock == 'ON' then
            WeaponLock = 'OFF'
            enable('main', 'sub' ,'range')				
            add_to_chat(123,'Weapon Lock Set: [OFF]')
        else
            WeaponLock = 'ON'
            disable('main', 'sub' ,'range')			
            add_to_chat(158,'Weapon Lock Set: [ON]')
        end	
    -- Capacity --		
    elseif command == 'C11' then
        if Capacity == 'ON' then
            Capacity = 'OFF'
            enable('back')				
            add_to_chat(123,'Capacity Cape Set: [OFF]')
        else
            Capacity = 'ON'
			equip({back=gear.Capacity_Cape})
			disable('back')
            add_to_chat(158,'Capacity Cape Set: [ON]')
        end
	end	
end	
-- Automatically changes Idle gears if you zone in or out of town --
windower.register_event('zone change', function()
	status_change(player.status)
	if Town:contains(world.zone) then	
        equip(sets.aftercast.Town)
    else
        equip(sets.aftercast.Idle)		
    end	
end)

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end