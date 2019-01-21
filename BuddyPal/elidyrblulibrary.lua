--[[ Elidyr : Template Library ]]--

-- All main settings for file located here. Initiates all key bind functions, and set default variables.
function LoadSettings()
    
    -- **Keybind Settings** ^(Control) | !(Alt) | @(Windows Key)
    
    -- (Job Specific Key Binds)
    send_command('bind @f5 gs c _modeLEARN')                                    -- Enable gear for learning Blue Magic spells.
    
    send_command('bind @f9 input //azuresets spellset dps-max')                 -- MAX DPS Spellset.
    send_command('bind @f10 input //azuresets spellset dps-mab')                -- MAX MAB Spellset.
    send_command('bind @f11 input //azuresets spellset farming')                -- Farming Spellset.
    send_command('bind @f12 input //azuresets spellset hybrid1')                -- Hybrid Spellset.
    
    -- Job specific key binds.
    send_command('bind @1 input /ja "Chain Affinity" <me>')                     -- CA.
    send_command('bind @2 input /ja "Efflux" <me>')                             -- Efflux.
    send_command('bind @3 input /ja "Burst Affinity" <me>')                     -- BA.
    send_command('bind @0 input /ja "Diffusion" <me>')                          -- Diffusion.
    send_command('bind @insert input /ja "Unbridled Learning" <me>')            -- Unbridled Learning.
    send_command('bind @delete input /ja "Unbridled Wisdom" <me>')              -- Unbridled Wisdom.
    
    -- These are job-specific variables. Be careful adjusting as it may cause unwanted changes to your gearswap.
    _modeLEARNi  = 1;
    
    -- ** List of all Job Ability sets. Will always equip this set when the assigned Job Ability is used. 
    sets.JobAbility = {}
        
        sets.JobAbility['Chain Affinity']   = {head = "Hashishin Kavuk", feet = "Assimilator's Charuqs +1"}
        sets.JobAbility['Burst Affinity']   = {}
        sets.JobAbility['Efflux']           = {legs = "Hashishin Tayt +1"}
        sets.JobAbility['Diffusion']        = {feet = "Luhlaza Charuqs +1"}
        sets.JobAbility['Azure Lore']       = {}
    
    -- ** List of all idle sets. Will always equip this set when engaged, and not performing any other actions.
    sets.NA = {}
    sets.NA.Mode = {'IDLE','PDT','MDT'}
    
        -- Idle Build
        sets.NA.IDLE = 
        {ammo  = "Brigantia Pebble",
         head  = "Iuitl Headgear +1",
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Handler's Earring +1",
         body  = "Hagondes Coat +1",
         hands = "Serpentes Cuffs",
         ring1 = "Paguroidea Ring",
         ring2 = "Sheltered Ring",
         back  = "Umbra Cape",
         waist = "Flume Belt",
         legs  = "Carmine Cuisses",
         feet  = "Serpentes Sabots"}
 
        -- Physical Damage Taken Build
        sets.NA.PDT =
        {ammo  = "Brigantia Pebble",
         head  = { name="Iuitl Headgear +1", augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Dbl.Atk."+1',}},
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Handler's Earring +1",
         body  = "Emet Harness +1",
         hands = { name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Store TP"+5','DEX+8','Accuracy+9','Attack+12',}},
         ring1 = "Defending Ring",
         ring2 = { name="Dark Ring", augments={'Magic dmg. taken -4%','Phys. dmg. taken -4%',}},
         back  = "Umbra Cape",
         waist = "Flume Belt",
         legs  = { name="Herculean Trousers", augments={'Phys. dmg. taken -5%','CHR+10','Accuracy+15',}},
         feet  = { name="Herculean Boots", augments={'Accuracy+9 Attack+9','"Triple Atk."+3','Accuracy+12','Attack+11',}}}
        
        -- Magical Damage Taken Build
        sets.NA.MDT =
        {ammo  = "Brigantia Pebble",
         head  = "Iuitl Headgear +1",
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "",
         body  = "Emet Harness +1",
         hands = "Iuitl Wristbands +1",
         ring1 = "Defending Ring",
         ring2 = "Dark Ring", augments={'Magic Dmg. Taken -4%','Phys. Dmg. Taken -4%'},
         back  = "Umbra Cape",
         waist = "Flume Belt",
         legs  = "Hagondes Pants +1",
         feet  = "Iuitl Gaiters +1"}
    
    -- ** List of all melee sets. Will always equip this set when engaged, and not performing any other actions.
    sets.TP = {}
    sets.TP.Mode = {'TP1','TP2','TP3','PDT','MDT'}			
    
        -- Low Accuracy Build
        sets.TP.TP1 =
        {ammo  = "Ginsen",
         head  = "Adhemar Bonnet",
         neck  = "Asperity Necklace",
         ear1  = "Brutal Earring",
         ear2  = "Suppanomimi",
         body  = "Adhemar Jacket",
         hands = "Adhemar Wristbands",
         ring1 = "Petrov Ring",
         ring2 = "Epona's Ring",
         back  = "Bleating Mantle",
         waist = "Windbuffet Belt +1",
         legs  = "Samnuha Tights",
         feet  = "Herculean Boots"}
    
        -- Mid Accuracy Build
        sets.TP.TP2 =
        {ammo  = "Ginsen",
         head  = "Adhemar Bonnet",
         neck  = "Asperity Necklace",
         ear1  = "Dudgeon Earring",
         ear2  = "Heartseeker Earring",
         body  = "Adhemar Jacket",
         hands = "Adhemar Wristbands",
         ring1 = "Rajas Ring",
         ring1 = "Petrov Ring",
         back  = "Grounded Mantle",
         waist = "Windbuffet Belt +1",
         legs  = "Samnuha Tights",
         feet  = "Herculean Boots"}
    
        -- High Accuracy Build
        sets.TP.TP3 =
        {ammo  = "Falcon Eye",
         head  = "Carmine Mask",
         neck  = "Iqabi Necklace",
         ear1  = "Dudgeon Earring",
         ear2  = "Heartseeker Earring",
         body  = "Adhemar Jacket",
         hands = "Adhemar Wristbands",
         ring1 = "Rajas Ring",
         ring2 = "Ramuh Ring",
         back  = "Grounded Mantle",
         waist = "Kentarch Belt",
         legs  = "Carmine Cuisses",
         feet  = "Herculean Boots", augments={'Accuracy+9 Attack+9','"Triple Atk."+3','Accuracy+12','Attack+11',}}
    
        -- Physical Damage Taken Build
        sets.TP.PDT =
        {ammo  = "Brigantia Pebble",
         head  = { name="Iuitl Headgear +1", augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Dbl.Atk."+1',}},
         neck  = "Twilight Torque",
         ear1  = "Ethereal Earring",
         ear2  = "Handler's Earring +1",
         body  = "Emet Harness +1",
         hands = { name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Store TP"+5','DEX+8','Accuracy+9','Attack+12',}},
         ring1 = "Defending Ring",
         ring2 = { name="Dark Ring", augments={'Magic dmg. taken -4%','Phys. dmg. taken -4%',}},
         back  = "Umbra Cape",
         waist = "Flume Belt",
         legs  = { name="Herculean Trousers", augments={'Phys. dmg. taken -5%','CHR+10','Accuracy+15',}},
         feet  = { name="Herculean Boots", augments={'Accuracy+9 Attack+9','"Triple Atk."+3','Accuracy+12','Attack+11',}}}
    
        -- Magical Damage Taken Build
        sets.TP.MDT =
        {ammo  = "Brigantia Pebble",
         head  = "Iuitl Headgear +1",
         neck  = "Twilight Torque",
         ear1  = "Handler's Earring",
         ear2  = "Suppanomimi",
         body  = "Emet Harness +1",
         hands = "Rawhide Gloves",
         ring1 = "Defending Ring",
         ring2 = "Dark Ring", augments={'Magic Dmg. Taken -4%','Phys. Dmg. Taken -4%'},
         back  = "Umbra Cape",
         waist = "Flume Belt",
         legs  = "Samnuha Tights",
         feet  = "Herculean Boots"}
    
    -- ** List of all midcasting sets. Will always midcast in this set when casting elemental magic.
    sets.MID = {}
    sets.MID.Mode = {'MAB','ACC','BURST','BURSTACC'}
    
        -- Magic Attack Bonus Build
        sets.MID.MAB =
        {ammo  = "Ghastly Tathlum +1",
         head  = "Amalric Coif",
         neck  = "Eddy Necklace",
         ear1  = "Hecate's Earring",
         ear2  = "Friomisi Earring",
         body  = "Amalric Doublet",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Fenrir Ring +1",
         back  = "Toro Cape",
         waist = "Aswang Sash",
         legs  = "Hagondes Pants +1",
         feet  = "Helios Boots"}
    
        -- Magic Accuracy Build
        sets.MID.ACC =
        {ammo  = "Ghastly Tathlum +1",
         head  = "Amalric Coif",
         neck  = "Eddy Necklace",
         ear1  = "Hecate's Earring",
         ear2  = "Friomisi Earring",
         body  = "Amalric Doublet",
         hands = "Helios Gloves",
         ring1 = "Fenrir Ring +1",
         ring2 = "Fenrir Ring +1",
         back  = "Toro Cape",
         waist = "Aswang Sash",
         legs  = "Hagondes Pants +1",
         feet  = "Helios Boots"}
        
        -- Magic Burst Build
        sets.MID.BURST =
        {ammo  = "Ghastly Tathlum +1",
         head  = "Amalric Coif",
         neck  = "Eddy Necklace",
         ear1  = "Hecate's Earring",
         ear2  = "Friomisi Earring",
         body  = "Amalric Doublet",
         hands = "Amalric Gages",
         ring1 = "Locus Ring",
         ring2 = "Mujin Band",
         back  = "Seshaw Cape",
         waist = "Aswang Sash",
         legs  = "Hagondes Pants +1",
         feet  = "Helios Boots"}
        
        -- Magic Burst Accuracy Build
        sets.MID.BURSTACC =
        {ammo  = "Ghastly Tathlum +1",
         head  = "Amalric Coif",
         neck  = "Eddy Necklace",
         ear1  = "Hecate's Earring",
         ear2  = "Friomisi Earring",
         body  = "Amalric Doublet",
         hands = "Helios Gloves",
         ring1 = "Fenrir Ring +1",
         ring2 = "Fenrir Ring +1",
         back  = "Toro Cape",
         waist = "Aswang Sash",
         legs  = "Hagondes Pants +1",
         feet  = "Helios Boots"}
    
    -- ** List of all weaponskill sets. Will always weaponskill in default unless specific set is made.
    sets.WSATT = {}
        
        sets.WSATT['Default'] =
        {ammo  = "Jukukik Feather",
         head  = "Adhemar Bonnet",
         neck  = "Light Gorget",
         ear1  = "Brutal Earring",
         ear2  = "Bladeborn Earring",
         body  = "Adhemar Jacket",
         hands = "Adhemar Wristbands",
         ring1 = "Ramuh Ring",
         ring2 = "Epona's Ring",
         back  = "Rancorous Mantle",
         waist = "Light Belt",
         legs  = "Samnuha Tights",
         feet  = "Adhemar Gamashes"}
         
        sets.WSATT['Savage Blade'] =
        {ammo  = "Amar Cluster",
         head  = { name="Herculean Helm", augments={'Accuracy+14 Attack+14','STR+12','Attack+9',}},
         neck  = "Caro Necklace",
         ear1  = "Ishvara Earring",
         ear2  = "Bladeborn Earring",
         body  = "Adhemar Jacket",
         hands = { name="Herculean Gloves", augments={'STR+8','Accuracy+19 Attack+19',}},
         ring1 = "Apate Ring",
         ring2 = "Ifrit's Ring +1",
         back  = "Buquwik Cape",
         waist = "Prosilio Belt +1",
         name  = "Carmine Cuisses",
         feet =  { name="Herculean Boots", augments={'Weapon skill damage +4%','STR+6','Attack+15',}}}
         
        sets.WSATT['Chant du Cygne'] =
        {ammo  = "Jukukik Feather",
         head  = "Adhemar Bonnet",
         neck  = "Light Gorget",
         ear1  = "Steelflash Earring",
         ear2  = "Bladeborn Earring",
         body  = "Adhemar Jacket",
         hands = "Adhemar Wristbands",
         ring1 = "Apate Ring",
         ring2 = "Epona's Ring",
         back  = { name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+1','Crit.hit rate+10',}},
         waist = "Light Belt",
         legs  = "Samnuha Tights",
         feet  = "Adhemar Gamashes"}
         
        sets.WSATT['Sanguine Blade'] =
        {ammo  = "Ghastly Tathlum +1",
         head  = "Amalric Coif",
         neck  = "Eddy Necklace",
         ear1  = "Hecate's Earring",
         ear2  = "Friomisi Earring",
         body  = "Amalric Doublet",
         hands = "Amalric Gages",
         ring1 = "Fenrir Ring +1",
         ring2 = "Fenrir Ring +1",
         back  = "Toro Cape",
         waist = "Aswang Sash",
         legs  = "Hagondes Pants +1",
         feet  = "Helios Boots"}
         
        sets.WSATT['Requiescat'] =
        {ammo  = "Amar Cluster",
         head  = { name="Herculean Helm", augments={'Accuracy+14 Attack+14','STR+12','Attack+9',}},
         neck  = "Caro Necklace",
         ear1  = "Ishvara Earring",
         ear2  = "Bladeborn Earring",
         body  = "Adhemar Jacket",
         hands = { name="Herculean Gloves", augments={'STR+8','Accuracy+19 Attack+19',}},
         ring1 = "Apate Ring",
         ring2 = "Ifrit's Ring +1",
         back  = "Buquwik Cape",
         waist = "Prosilio Belt +1",
         name  = "Carmine Cuisses",
         feet =  { name="Herculean Boots", augments={'Weapon skill damage +4%','STR+6','Attack+15',}}}
        
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
        {head  = "Carmine Mask",
         neck  = "Orunmila's Torque",
         ear1  = "",
         ear2  = "Loquac. Earring",
         body  = "Telchine Chas.",
         hands = "Leyline Gloves",
         ring1 = "Prolix Ring",
         ring2 = "Weather. Ring",
         back  = "Swith Cape +1",
         waist = "Witful Belt",
         legs  = "Psycloth Lappas",
         feet  = "Herculean Boots"}
    
        sets.Magic.PreHealing =
        {}
    
        sets.Magic.PreEnfeebling =
        {}
    
        sets.Magic.PreStoneskin =
        {}
        
        sets.Magic.PreBlueMagic =
        {head  = "Carmine Mask",
         neck  = "Orunmila's Torque",
         ear1  = "",
         ear2  = "Loquac. Earring",
         body  = "Telchine Chas.",
         hands = "Leyline Gloves",
         ring1 = "Prolix Ring",
         ring2 = "Weather. Ring",
         back  = "Swith Cape +1",
         waist = "Witful Belt",
         legs  = "Psycloth Lappas",
         feet  = "Herculean Boots"}
    
    -- ** List of all sets that target a specific action. Must be manually setup in functions below.
    sets.Learning =
    {ammo  = "Mavi Tathlum",
     head  = "Iuitl Headgear +1",
     neck  = "Twilight Torque",
     ear1  = "Brutal Earring",
     ear2  = "Suppanomimi",
     body  = "Assim. Jubbah +1",
     hands = "Assim. Bazu. +1",
     ring1 = "Rajas Ring",
     ring2 = "Epona's Ring",
     back  = "Cornflower Cape",
     waist = "Flume Belt",
     legs  = "Mavi Tayt +2",
     feet  = "Luhlaza Charuqs +1"}
     
    sets.PhysicalBlue =
    {ammo  = "Falcon Eye",
     head  = "Adhemar Bonnet",
     neck  = "Caro Necklace",
     ear1  = "Bladeborn Earring",
     ear2  = "Steelflash Earring",
     body  = "Adhemar Jacket",
     hands = "Adhemar Wristbands",
     ring1 = "Ifrit Ring",
     ring2 = "Ifrit Ring +1",
     back  = "Cornflower Cape",
     waist = "Prosilio Belt +1",
     legs  = "Samnuha Tights",
     feet  = "Adhemar Gamashes"}
     
    sets.BlankGaze =
    {ammo  = "Mavi Tathlum",
     head  = "Carmine Mask",
     neck  = "Eddy Necklace",
     ear1  = "Gwati Earring",
     ear2  = "Friomisi Earring",
     body  = "Assim. Jubbah +1",
     hands = "Rawhide Gloves",
     ring1 = "Weather. Ring",
     ring2 = "Fenrir Ring +1",
     back  = "Cornflower Cape",
     waist = "Aswang Sash",
     legs  = "Mavi Tayt +2",
     feet  = "Helios Boots"}
     
    sets.BloodSaber =
    {ammo  = "Mavi Tathlum",
     head  = "Carmine Mask",
     neck  = "",
     ear1  = "Gwati Earring",
     ear2  = "",
     body  = "Assim. Jubbah +1",
     hands = "Rawhide Gloves",
     ring1 = "Fenrir Ring +1",
     ring2 = "Evanescence Ring",
     back  = "Cornflower Cape",
     waist = "Fucho-No-Obi",
     legs  = "Mavi Tayt +2",
     feet  = "Helios Boots"}
    
    sets.Stoneskin =
    {head  = "Umuthi Hat",
     ear1  = "Earthcry Earring",
     ear2  = "Andoaa Earring",
     hands = "Carapacho Cuffs",
     waist = "Olympus Sash",
     legs  = "Haven Hose"}
    
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
     legs  = "Carmine Cuisses",
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
     waist = "Chaac Belt",
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
    
    -- How to find Specific spells.
    --if string.find(spell.name:lower(), 'stoneskin') then
    -- Handles all logic before a spell is cast.		
    if spell.skill == "Divine Magic" then
        equip(sets.Magic.Precast)
        
    elseif spell.skill == "Enhancing Magic" then        
        
        if string.find(spell.name:lower(), 'stoneskin') then 
            equip(sets.Stoneskin)
            
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
        equip(sets.Magic.PreBlueMagic)
        
    elseif spell.skill == "Ninjutsu" then
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
    
    -- Handles all logic after a spell is cast.
    if spell.skill == "Divine Magic" then
        equip(sets.Magic.PreEnfeebling)
        
    elseif spell.skill == "Enhancing Magic" then
        
        if string.find(spell.name:lower(), 'stoneskin') then
            equip(sets.Stoneskin)
            
        else
            equip(sets.Magic.EnhancingMagic)
            
        end
        
    elseif spell.skill == "Elemental Magic" then
        
    elseif spell.skill == "Singing Magic" then
        
    elseif spell.skill == "Wind Magic" then
        
    elseif spell.skill == "Healing Magic" then
        
    elseif spell.skill == "Enfeebling Magic" then
        
    elseif spell.skill == "Dark Magic" then
        
    elseif spell.skill == "String Magic" then
        
    elseif spell.skill == "Blue Magic" then
        
        -- Determine which midcast set to equip based on spell type (element).
        if spell.element == "None" then
            equip(sets.PhysicalBlue)
            
            --Debug: Hard check if spell is physical element.
            if _DEBUG == 1 then
                send_command('@ input /echo ** Midcast - Spell Type: Physical')
            end
            
        else
            
            if string.find(spell.name:lower(), 'blank gaze') then
                equip(sets.BlankGaze)
                
            elseif string.find(spell.name:lower(), 'blood saber') then
                equip(sets.BloodSaber)
                
            else
                equip(sets.MID[sets.MID.Mode[_modeMIDi]])    
            end
            
            --Debug: Hard check if spell is magical element.
            if _DEBUG == 1 then
                send_command('@ input /echo ** Midcast - Spell Type: Magical')
            end
            
        end
        
    elseif spell.skill == "Ninjutsu" then
    
    end
    
end

function LocalAftercast(spell, act)
    
    -- Equip selected TP set if engaged on a mob.
    if player.status == 'Engaged' then
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
        
        --Capacity Point Farming Only!!!
        --send_command('@ input /item "Trizek Ring" <me>')
        send_command('@ input //send Lilyia /item "Trizek Ring" <me>')
    
    -- Not engaged then default back to Idle set.
    else 
        equip(sets.NA[sets.NA.Mode[_modeNAi]])
    
    end
    
    if string.find(spell.name:lower(), 'chain affinity') then
        send_command('@ input /p ** Blue Mage: Self-SC going! **')
    end
    
end

function LocalStatusChange(new, old)
    
    send_command('@ input /item "Trizek Ring" <me>')
    
end

function LocalBuffChange(name, gain)
    
    --Handle logic for gaining and loosing buffs.
    if gain then
	
        -- Handle Diffusion logic when buff is gained.
        if name == 'Diffusion' then
            equip(sets.JobAbility['Diffusion'])
            disable('feet')
            
            
            -- Handle Efflux logic when buff is gained.
        elseif name == 'Efflux' then
            equip(sets.JobAbility['Efflux'])
            disable('legs')
            
            
            -- Handle Chain Affinity logic when buff is gained.
        elseif name == 'Chain Affinity' then
            equip(sets.JobAbility['Chain Affinity'])
            disable('head','feet')
        end
        
    else
        
        -- Handle Diffusion logic when buff is lost.
        if name == 'Diffusion' then
            enable('feet')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
            end	
            
            
            -- Handle Efflux logic when buff is lost.
        elseif name == 'Efflux' then
            enable('legs')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
            end	
            
            
            -- Handle Chain Affinity logic when buff is lost.
        elseif name == 'Chain Affinity' then
            enable('head','feet')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
            end	
            
        end
        
    end
    
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
    
    --Toggle for locking into Blue Mage spell learning mode.
    if command == '_modeLEARN' then
        
        if _modeLEARNi < 2 then	_modeLEARNi = _modeLEARNi + 1 else _modeLEARNi = 1 end        
        
        if _modeLEARNi == 1 then
            add_to_chat(600, '** Spell Learning Mode Disabled!')
            enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
            end	
            
        elseif _modeLEARNi == 2 then
            
            add_to_chat(600, '** Spell Learning Mode Enabled!')
            equip(sets.Learning)
            disable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
            
        end
        
    end
    
end