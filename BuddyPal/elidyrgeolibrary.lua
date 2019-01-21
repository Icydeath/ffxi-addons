--[[ Elidyr : Template Library ]]--

-- All main settings for file located here. Initiates all key bind functions, and set default variables.
function LoadSettings()
    
    -- **Keybind Settings** ^(Control) | !(Alt) | @(Windows Key)
    
    -- (Job Specific Key Binds)
    send_command('bind @f9 gs c ')             -- Open Command slot
    send_command('bind @f10 gs c ')            -- Open Command slot
    send_command('bind @f11 gs c ')            -- Open Command slot
    send_command('bind @f12 gs c ')            -- Open Command slot
    
    -- Job specific key binds.
    send_command('bind @` input /ja "Full Circle" <me>')                        -- Full Circle
    send_command('bind @1 input /ja "Blaze of Glory" <me>')                     -- Blaze of Glory
    send_command('bind @- input /ja "Life Cycle" <me>')                         -- Life Cycle
    send_command('bind @= input /ja "Dematerialize" <me>')                      -- Dematerialize
    send_command('bind @insert input /ja "Lasting Emanation" <me>')             -- Lasting Emanation
    send_command('bind @delete input /ja "Ecliptic Attrition" <me>')            -- Ecliptic Attrition
    send_command('bind @home input /ja "Radial Arcana" <me>')                   -- Radial Arcana
    send_command('bind @end input /ja "Concentric Pulse" <me>')                 -- Concentric Pulse
    
    -- These are job-specific variables. Be careful adjusting as it may cause unwanted changes to your gearswap.
    
    -- ** List of all Job Ability sets. Will always equip this set when the assigned Job Ability is used. 
    sets.JobAbility = {}
        
        sets.JobAbility['JA NAME'] = {}
    
    -- ** List of all idle sets. Will always equip this set when engaged, and not performing any other actions.
    sets.NA = {}
    sets.NA.Mode = {'IDLE','PETDT','PDT'}
    
        -- Idle Build
        sets.NA.IDLE = 
        {main  = "Bolelabunga",
         sub   = "Genbu's Shield",
         range = "Dunna",
         head  = { name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12',}},
         neck  = "Warder's Charm +1",
         ear1  = "Handler's Earring",
         ear2  = "Handler's Earring +1",
         body  = "Telchine Chas.",
         hands = "Bagua Mitaines",
         ring1 = "Defending Ring",
         ring2 = "Patricius Ring",
         back  = "Cheviot Cape",
         waist = "Fucho-No-Obi",
         legs  = "Assid. Pants +1",
         feet  = "Geomancy Sandals"}
         
        -- Pet Damage-Taken Build
        sets.NA.PETDT = 
        {main  = "Bolelabunga",
         sub   = "Genbu's Shield",
         range = "Dunna",
         head  = "Azumith Hood",
         neck  = "Warder's Charm +1",
         ear1  = "Handler's Earring",
         ear2  = "Handler's Earring +1",
         body  = "Telchine Chas.",
         hands = "Telchine Gloves",
         ring1 = "Defending Ring",
         ring2 = "Patricius Ring",
         back  = "Nantosuelta's Cape",
         waist = "Isa Belt",
         legs  = "Telchine Braconi",
         feet  = "Bagua Sandals"}
 
        -- Physical Damage Taken Build
        sets.NA.PDT =
        {}
    
    -- ** List of all melee sets. Will always equip this set when engaged, and not performing any other actions.
    sets.TP = {}
    sets.TP.Mode = {'TP1','TP2','TP3','PDT','MDT'}			
    
        -- Low Accuracy Build
        sets.TP.TP1 =
        {}
    
        -- Mid Accuracy Build
        sets.TP.TP2 =
        {}
    
        -- High Accuracy Build
        sets.TP.TP3 =
        {}
    
        -- Physical Damage Taken Build
        sets.TP.PDT =
        {}
    
        -- Magical Damage Taken Build
        sets.TP.MDT =
        {}
    
    -- ** List of all midcasting sets. Will always midcast in this set when casting elemental magic.
    sets.MID = {}
    sets.MID.Mode = {'MAB','ACC','BURST','BURSTACC'}
    
        -- Magic Attack Bonus Build
        sets.MID.MAB =
        {main  = "Marin Staff +1",
         sub   = "Niobid Strap",
         ammo  = "Ghastly Tathlum",
         head  = { name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12'}},
         neck  = "Eddy Necklace",
         ear1  = "Friomisi Earring",
         ear2  = "Gwati Earring",
         body  = "Azumith Coat",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Shiva Ring",
         back  = "Toro Cape",
         waist = "Channeler's Stone",
         legs  = { name="Merlinic Shalwar", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst mdg.+1%','Mag. Acc.+3','"Mag.Atk.Bns."+13',}},
         feet  = { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+10','Mag. Acc.+4','"Mag.Atk.Bns."+15',}}}
    
        -- Magic Accuracy Build
        sets.MID.ACC =
        {main  = "Marin Staff +1",
         sub   = "Niobid Strap",
         ammo  = "Ghastly Tathlum",
         head  = { name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12'}},
         neck  = "Eddy Necklace",
         ear1  = "Friomisi Earring",
         ear2  = "Gwati Earring",
         body  = "Azumith Coat",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Shiva Ring",
         back  = "Toro Cape",
         waist = "Channeler's Stone",
         legs  = { name="Merlinic Shalwar", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst mdg.+1%','Mag. Acc.+3','"Mag.Atk.Bns."+13',}},
         feet  = { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+10','Mag. Acc.+4','"Mag.Atk.Bns."+15',}}}
        
        -- Magic Burst Build
        sets.MID.BURST =
        {main  = "Marin Staff +1",
         sub   = "Niobid Strap",
         ammo  = "Ghastly Tathlum",
         head  = { name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12'}},
         neck  = "Eddy Necklace",
         ear1  = "Friomisi Earring",
         ear2  = "Gwati Earring",
         body  = "Azumith Coat",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Shiva Ring",
         back  = "Toro Cape",
         waist = "Channeler's Stone",
         legs  = { name="Merlinic Shalwar", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst mdg.+1%','Mag. Acc.+3','"Mag.Atk.Bns."+13',}},
         feet  = { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+10','Mag. Acc.+4','"Mag.Atk.Bns."+15',}}}
        
        -- Magic Burst Accuracy Build
        sets.MID.BURSTACC =
        {main  = "Marin Staff +1",
         sub   = "Niobid Strap",
         ammo  = "Ghastly Tathlum",
         head  = { name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Occult Acumen"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12'}},
         neck  = "Eddy Necklace",
         ear1  = "Friomisi Earring",
         ear2  = "Gwati Earring",
         body  = "Azumith Coat",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Shiva Ring",
         back  = "Toro Cape",
         waist = "Channeler's Stone",
         legs  = { name="Merlinic Shalwar", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst mdg.+1%','Mag. Acc.+3','"Mag.Atk.Bns."+13',}},
         feet  = { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+10','Mag. Acc.+4','"Mag.Atk.Bns."+15',}}}
    
    -- ** List of all weaponskill sets. Will always weaponskill in default unless specific set is made.
    sets.WSATT = {}
        
        sets.WSATT['Default'] =
        {}
        
    sets.WSACC = {}
        
        sets.WSACC['Default'] =
        {}
    
    -- ** List of all magic sets to be used during midcast. Must setup appropriately.
    sets.Magic = {}
    
        sets.Magic.HealingMagic =
        {}
    
        sets.Magic.HealingMagicMax =
        {}
        
        sets.Magic.HealingMagicSelf =
        {}
    
        sets.Magic.EnhancingMagic =
        {}
    
        sets.Magic.EnfeeblingMagic =
        {}
    
        sets.Magic.DarkMagic =
        {}
    
        -- ** List of all magic sets to be used during precast. Must setup appropriately.
        sets.Magic.Precast =
        {main  = { name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
         sub   = "Genbu's Shield",
         range = "Dunna",
         head  = "Merlinic Hood",
         neck  = "",
         ear1  = "Loquac. Earring",
         ear2  = "",
         body  = "Rosette Jaseran",
         hands = "",
         ring1 = "",
         ring2 = "",
         back  = "Lifestream Cape",
         waist = "Witful Belt",
         legs  = "Geo. Pants +1",
         feet  = "Merlinic Crackows"}
    
        sets.Magic.PreHealing =
        {}
    
        sets.Magic.PreEnfeebling =
        {}
    
        sets.Magic.PreStoneskin =
        {}
    
    -- ** List of all sets that target a specific action. Must be manually setup in functions below.
    sets.Geomancy =
    {main  = { name="Solstice", augments={'Mag. Acc.+20','Pet: Damage taken -4%','"Fast Cast"+5',}},
     sub   = "Genbu's Shield",
     range = "Dunna",
     head  = "Azimuth Hood",
     neck  = "Reti Pendant",
     ear1  = "Magnetic Earring",
     ear2  = "Handler's Earring +1",
     body  = "Bagua Tunic",
     hands = "Geomancy Mitaines",
     ring1 = "Stikini Ring",
     ring2 = "Renaye Ring",
     back  = "Lifestream Cape",
     waist = "Kobi Obi",
     legs  = "Bagua Pants",
     feet  = "Azimuth Gaiters +1"}
    
    sets.Stoneskin =
    {}
    
    sets.Capacity =
    {ring2 = "Trizek Ring",
     back  = "Mecisto. Mantle"}
    
    sets.Kite =
    {ammo  = "",
     head  = "",
     neck  = "",
     ear1  = "",
     ear2  = "",
     body  = "",
     hands = "",
     ring1 = "",
     ring2 = "",
     back  = "",
     waist = "",
     legs  = "",
     feet  = "Geomancy Sandals"}
    
    sets.MDT =
    {ammo  = "",
     head  = "",
     neck  = "",
     ear1  = "",
     ear2  = "",
     body  = "",
     hands = "",
     ring1 = "",
     ring2 = "",
     back  = "",
     waist = "",
     legs  = "",
     feet  = ""}
    
    sets.MEV =
    {ammo  = "",
     head  = "",
     neck  = "",
     ear1  = "",
     ear2  = "",
     body  = "",
     hands = "",
     ring1 = "",
     ring2 = "",
     back  = "",
     waist = "",
     legs  = "",
     feet  = ""}
    
    enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    
end

function LocalPrecast(spell, act)
    
    -- Handles all logic if Job Ability is used.
    if spell.type == 'JobAbility' then
        
        if sets.JobAbility[spell.english] then
            equip(sets.JobAbility[spell.english])
            
        end
        
    end
    
    
    -- Handles all logic if Ranged Attack is used.
    if spell.name == 'Ranged' then
        
    end
    
    
    -- Handles all logic if a Weaponskill is used.
    if spell.type == 'WeaponSkill' then
        
        if _modeWSi == 1 then
            
            if sets.WSATT[spell.name] then
                equip(sets.WSATT[spell.name])
            
            else
                equip(sets.WSATT['Default'])
                
            end
            
        elseif _modeWSi == 2 then
            
            if sets.WSACC[spell.name] then
                equip(sets.WSACC[spell.name])
            
            else
                equip(sets.WSACC['Default'])
                
            end
            
        end
        
    end
    
    -- Handles all logic before a spell is cast.		
    if spell.skill == "Divine Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Enhancing Magic" then        
        
        if string.find(spell.name:lower(), 'stoneskin') then
            equip(sets.Magic.Precast, sets.Magic.PreStoneskin)
            
        else
            equip(sets.Magic.Precast)
            
        end
        
    elseif spell.skill == "Elemental Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Singing Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Wind Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Healing Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Enfeebling Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Dark Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "String Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Blue Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Geomancy" then
        equip(sets.Magic.Precast)
        
    end
     
end

function LocalMidcast(spell, act)
    
    -- Handles all logic if Job Ability is used.
    if spell.type == 'JobAbility' then	
        
        if sets.JobAbility[spell.english] then
            equip(sets.JobAbility[spell.english])
            
        end
        
    end
    
    
    -- Handles all logic if Ranged Attack is used.
    if spell.name == 'Ranged' then
        
    end
    
    
    -- Handles all logic if a Weaponskill is used.
    if spell.type == 'WeaponSkill' then
        
        if _modeWSi == 1 then
            
            if sets.WSATT[spell.name] then
                equip(sets.WSATT[spell.name])
            
            else
                equip(sets.WSATT['Default'])
                
            end
            
        elseif _modeWSi == 2 then
            
            if sets.WSACC[spell.name] then
                equip(sets.WSACC[spell.name])
            
            else
                equip(sets.WSACC['Default'])
                
            end
            
        end
        
    end
    
     -- Handles all logic during the casting of a spell.
    if spell.skill == "Divine Magic" then
        
    elseif spell.skill == "Enhancing Magic" then
        
        if string.find(spell.name:lower(), 'stoneskin') then
            equip(sets.Magic.EnhancingMagic, sets.Stoneskin)
            
        elseif string.find(spell.name:lower(), 'aquaveil') then
            equip(sets.Magic.EnhancingMagic, sets.Aquaveil)
            
        elseif string.find(spell.name:lower(), 'regen') then
            equip(sets.Magic.EnhancingMagic, sets.Regen)
            
        else
            equip(sets.Magic.EnhancingMagic)
            
        end
        
    elseif spell.skill == "Elemental Magic" then
        equip(sets.MID[sets.MID.Mode[_modeMIDi]])
        
    elseif spell.skill == "Singing Magic" then
        
    elseif spell.skill == "Wind Magic" then
        
    elseif spell.skill == "Healing Magic" then
        
        if buffactive['Aurorastorm'] then
            
            if spell.target.type == 'SELF' then
                equip(sets.Magic.HealingMagicSelf)
                
            else
                equip(sets.Magic.HealingMagicMax)
                
            end
            
        else
            equip(sets.Magic.HealingMagic)
        
        end
        
    elseif spell.skill == "Enfeebling Magic" then
        equip(sets.Magic.EnfeeblingMagic)
        
    elseif spell.skill == "Dark Magic" then
                    
        if string.find(spell.name:lower(), 'drain') then
            equip(sets.MID[sets.MID.Mode[_modeMIDi]], sets.Drain)
            
        elseif string.find(spell.name:lower(), 'aspir') then
            equip(sets.MID[sets.MID.Mode[_modeMIDi]], sets.Aspir)
            
        elseif string.find(spell.name:lower(), 'bio') then
            equip(sets.MID[sets.MID.Mode[_modeMIDi]], sets.Bio)
            
        end
        
    elseif spell.skill == "String Magic" then
        
    elseif spell.skill == "Blue Magic" then
        
    elseif spell.skill == "Geomancy" then
        equip(sets.Geomancy)
    
    end
    
end

function LocalAftercast(spell, act)
    
    -- Equip selected TP set if engaged on a mob.
    if player.status == 'Engaged' then
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
    
    -- Not engaged then default back to Idle set.
    else 
        equip(sets.NA[sets.NA.Mode[_modeNAi]])
    
    end
    
end

function LocalStatusChange(new, old)
    
end

function LocalBuffChange(name, gain)
    
end

function LocalPetChange(pet, gain)
    
end

function LocalPetMidcast(spell)
    
end

function LocalPetAftercast(spell)
    
end

function LocalPetStatusChange(new, old)
    
end

function LocalSelfCommand(command)
    
end