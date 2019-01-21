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
    send_command('bind @1 input /ma "Reprisal" <me>')                           -- Reprisal
    send_command('bind @2 input /ma "Enlight II" <me>')                         -- Enlight
    send_command('bind @3 input /ma "Crusade" <me>')                            -- Crusade
    send_command('bind @0 input /ma "Phalanx" <me>')                            -- Phalanx
    send_command('bind @= input /ma "Palisade" <me>')                           -- Palisade
    send_command('bind @insert input /ma "Sentinel" <me>')                      -- Sentinel
    send_command('bind @delete input /ma "Rampart" <me>')                       -- Rampart
    send_command('bind @home input /ma "Cover" <st>')                           -- Cover
    send_command('bind @end input /ma "Chivalry" <t>')                          -- Intervene
    send_command('bind @\ input /ma "Invincible" <me>')                         -- Invicible
    
    -- These are job-specific variables. Be careful adjusting as it may cause unwanted changes to your gearswap.
    
    -- ** List of all Job Ability sets. Will always equip this set when the assigned Job Ability is used. 
    sets.JobAbility = {}
        
        sets.JobAbility['Invincible']       = {}
        sets.JobAbility['Shield Bash']      = {}
        sets.JobAbility['Holy Circle']      = {}
        sets.JobAbility['Sentinel']         = {}
        sets.JobAbility['Rampart']          = {}
        sets.JobAbility['Felty']            = {}
        sets.JobAbility['Chivalry']         = {}
        sets.JobAbility['Divine Emblem']    = {}
        sets.JobAbility['Sepulcher']        = {}
        sets.JobAbility['Palisade']         = {}
        sets.JobAbility['Intervene']        = {}
    
    -- ** List of all idle sets. Will always equip this set when engaged, and not performing any other actions.
    sets.NA = {}
    sets.NA.Mode = {'IDLE','PDT','MDT'}
    
        -- Idle Build
        sets.NA.IDLE = 
        {ammo  = "Vanir Battery",
         head  = "Rabid Visor",
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Infused Earring",
         body  = "Souveran Cuirass",
         hands = "Souv. Handschuhs",
         ring1 = "Vocane Ring",
         ring2 = "Petrov Ring",
         back  = "Weard Mantle",
         waist = "Flume Belt",
         legs  = "Souveran Diechlings",
         feet  = "Amm Greaves"}
 
        -- Physical Damage Taken Build
        sets.NA.PDT =
        {ammo  = "Vanir Battery",
         head  = "Rabid Visor",
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Handler's Earring +1",
         body  = "Souveran Cuirass",
         hands = "Chev. Gauntlets +1",
         ring1 = "Vocane Ring",
         ring2 = "Petrov Ring",
         back  = "Weard Mantle",
         waist = "Flume Belt",
         legs  = "Chev. Cuisses +1",
         feet  = "Amm Greaves"}
        
        -- Magical Damage Taken Build
        sets.NA.MDT =
        {}
    
    -- ** List of all melee sets. Will always equip this set when engaged, and not performing any other actions.
    sets.TP = {}
    sets.TP.Mode = {'TP1','TP2','TP3','PDT','MDT'}			
    
        -- Low Accuracy Build
        sets.TP.TP1 =
        {ammo  = "Ginsen",
         head  = "Yorium Barbuta",
         neck  = "Asperity Necklace",
         ear1  = "Steelflash Earring",
         ear2  = "Bladeborn Earring",
         body  = "Yorium Cuirass",
         hands = "Founder's Gauntlets",
         ring1 = "Apate Ring",
         ring2 = "Petrov Ring",
         back  = "Bleating Mantle",
         waist = "Kentarch Belt +1",
         legs  = "Odyssean Cuisses",
         feet  = "Amm Greaves"}
    
        -- Mid Accuracy Build
        sets.TP.TP2 =
        {}
    
        -- High Accuracy Build
        sets.TP.TP3 =
        {}
    
        -- Physical Damage Taken Build
        sets.TP.PDT =
        {ammo  = "Vanir Battery",
         head  = "Rabid Visor",
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Handler's Earring +1",
         body  = "Souveran Cuirass",
         hands = "Chev. Gauntlets +1",
         ring1 = "Vocane Ring",
         ring2 = "Petrov Ring",
         back  = "Weard Mantle",
         waist = "Flume Belt",
         legs  = "Chev. Cuisses +1",
         feet  = "Amm Greaves"}
    
        -- Magical Damage Taken Build
        sets.TP.MDT =
        {}
    
    -- ** List of all midcasting sets. Will always midcast in this set when casting elemental magic.
    sets.MID = {}
    sets.MID.Mode = {'MAB','ACC','BURST','BURSTACC'}
    
        -- Magic Attack Bonus Build
        sets.MID.MAB =
        {}
    
        -- Magic Accuracy Build
        sets.MID.ACC =
        {}
        
        -- Magic Burst Build
        sets.MID.BURST =
        {}
        
        -- Magic Burst Accuracy Build
        sets.MID.BURSTACC =
        {}
    
    -- ** List of all weaponskill sets. Will always weaponskill in default unless specific set is made.
    sets.WSATT = {}
        
        sets.WSATT['Default'] =
        {}
        
        sets.WSATT['Savage'] =
        {}
        
        sets.WSATT['Chant du Cygne'] =
        {}
        
        sets.WSATT['Sanguine Blade'] =
        {}
        
        sets.WSATT['Aeolian Edge'] =
        {}
        
    sets.WSACC = {}
        
        sets.WSACC['Default'] =
        {}
        
        sets.WSACC['Savage'] =
        {}
        
        sets.WSACC['Chant du Cygne'] =
        {}
        
        sets.WSACC['Sanguine Blade'] =
        {}
        
        sets.WSACC['Aeolian Edge'] =
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
        {ammo  = "Sapience Orb",
         head  = "",
         neck  = "",
         ear1  = "Loquac. Earring",
         ear2  = "Etiolation Earring",
         body  = "",
         hands = "Leyline Gloves",
         ring1 = "",
         ring2 = "Prolix Ring",
         back  = "",
         waist = "Witful Belt",
         legs  = "",
         feet  = "Odyssean Greaves"}
    
        sets.Magic.PreHealing =
        {}
    
        sets.Magic.PreEnfeebling =
        {}
    
        sets.Magic.PreStoneskin =
        {}
    
    -- ** List of all sets that target a specific action. Must be manually setup in functions below.
    sets.Enmity =
    {ammo  = "Sapience Orb",
     head  = "Cizin Helm +1",
     neck  = "Sanctity Necklace",
     ear1  = "Ethereal Earring",
     ear2  = "Friomisi Earring",
     body  = "Emet Harness",
     hands = "Yorium Gauntlets",
     ring1 = "Apeile Ring +1",
     ring2 = "Apeile Ring",
     back  = "Weard Mantle",
     waist = "Trance Belt",
     legs  = "Souveran Diechlings",
     feet  = "Yorium Sabatons"}
    
    sets.Flash =
    {ammo  = "Sapience Orb",
     head  = "Cizin Helm +1",
     neck  = "Sanctity Necklace",
     ear1  = "Friomisi Earring",
     ear2  = "Etiolation Earring",
     body  = "Souveran Cuirass",
     hands = "Yorium Gauntlets",
     ring1 = "Apeile Ring +1",
     ring2 = "Apeile Ring",
     back  = "Weard Mantle",
     waist = "Trance Belt",
     legs  = "Souveran Diechlings",
     feet  = "Yorium Sabatons"}
    
    sets.Reprisal =
    {ammo  = "Sapience Orb",
     head  = "Cizin Helm +1",
     neck  = "Sanctity Necklace",
     ear1  = "Ethereal Earring",
     ear2  = "Friomisi Earring",
     body  = "Souveran Cuirass",
     hands = "Yorium Gauntlets",
     ring1 = "Apeile Ring +1",
     ring2 = "Apeile Ring",
     back  = "Weard Mantle",
     waist = "Trance Belt",
     legs  = "Souveran Diechlings",
     feet  = "Yorium Sabatons"}
    
    sets.Phalanx =
    {}
    
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
     feet  = ""}
    
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
        
         if string.find(spell.name:lower(), 'provoke') then
            equip(sets.Enmity)
           
        elseif string.find(spell.name:lower(), 'warcry') then
            equip(sets.Enmity)
           
        elseif sets.JobAbility[spell.english] then
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
        
        if string.find(spell.name:lower(), 'flash') then
            equip(sets.Flash)
           
        else
            equip(sets.Magic.Precast)
            
        end
        
    elseif spell.skill == "Enhancing Magic" then        
        
        -- Stoneskin Precast
        if string.find(spell.name:lower(), 'stoneskin') then
            equip(sets.Magic.Precast, sets.PreStoneskin)
           
            -- Stoneskin Precast
        elseif string.find(spell.name:lower(), 'phalanx') then
            equip(sets.Magic.Precast, sets.Phalanx)
           
            -- Stoneskin Precast
        elseif string.find(spell.name:lower(), 'reprisal') then
            equip(sets.Magic.Precast, sets.Reprisal)
           
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
        
    end
     
end

function LocalMidcast(spell, act)
    
    -- Handles all logic if Job Ability is used.
    if spell.type == 'JobAbility' then	
        
        if string.find(spell.name:lower(), 'provoke') then
            equip(sets.Enmity)
           
        elseif string.find(spell.name:lower(), 'warcry') then
            equip(sets.Enmity)
           
        elseif sets.JobAbility[spell.english] then
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
        
        -- Stoneskin Midcast
        if string.find(spell.name:lower(), 'stoneskin') then
            equip(sets.Magic.EnhancingMagic, sets.Stoneskin)
           
        -- Phalanx Precast
        elseif string.find(spell.name:lower(), 'phalanx') then
            equip(sets.Magic.EnhancingMagic, sets.Phalanx)
           
        -- Reprisal Precast
        elseif string.find(spell.name:lower(), 'reprisal') then
            equip(sets.Magic.EnhancingMagic, sets.Reprisal)
           
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