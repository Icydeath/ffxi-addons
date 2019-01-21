--[[ Elidyr : Template Library ]]--
-- /GearSwap/data/library/ is where this file needs to go along with Commands.lua library file.

-- All main settings for file located here. Initiates all key bind functions, and set default variables.
function LoadSettings()
    
    -- **Keybind Settings** ^(Control) | !(Alt) | @(Windows Key)
    
    -- (Job Specific Key Binds)
    send_command('bind @f9 gs c ')             -- Open Command slot
    send_command('bind @f10 gs c ')            -- Open Command slot
    send_command('bind @f11 gs c ')            -- Open Command slot
    send_command('bind @f12 gs c ')            -- Open Command slot
    
    -- Job specific key binds.
    send_command('bind @insert input /ja "Name" <me>')  -- Description of key bind.
    
    -- These are job-specific variables. Be careful adjusting as it may cause unwanted changes to your gearswap.
    
    -- ** List of all Job Ability sets. Will always equip this set when the assigned Job Ability is used. 
    sets.JobAbility = {}
        
        sets.JobAbility['JA NAME'] = {}
    
    -- ** List of all idle sets. Will always equip this set when engaged, and not performing any other actions.
    sets.NA = {}
    sets.NA.Mode = {'IDLE','PDT','MDT'}
    
        -- Idle Build
        sets.NA.IDLE = 
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
 
        -- Physical Damage Taken Build
        sets.NA.PDT =
        {}
        
        -- Magical Damage Taken Build
        sets.NA.MDT =
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
        {}
    
        sets.Magic.PreHealing =
        {}
    
        sets.Magic.PreEnfeebling =
        {}
    
        sets.Magic.PreStoneskin =
        {}
    
    -- ** List of all sets that target a specific action. Must be manually setup in functions below.
    sets.Stoneskin =
    {}
    
    sets.Capacity =
    {ring2 = "Trizek Ring",
     back  = "Mecisto. Mantle"}
    
    sets.Crafting =
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
    
    sets.Treasure =
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
    
    end
    
end

function LocalAftercast(spell, act)
    
    -- Equip selected TP set if engaged on a mob.
    if player.status == 'Engaged' then
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
    
    -- If not engaged then default back to Idle set.
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