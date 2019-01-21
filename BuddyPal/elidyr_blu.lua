--[[ Elidyr : Gearswap v2.3.2

V232  - 5/21/2016 :
        + Added commands for Auto-Waro Ring on accounts through commands library.

V231  - 4/21/2016 :
        + Minor adjustments, removed some test code from files.

V230  - 4/20/2016 :
        + Changes to version sequence.
        + Added functionality to support Commands.lua library.
            > Reads incoming commands sent from one character to multiple accounts on same PC.
            > Uses default self_command functionality with GearSwap to catch, and send commands.
            > Commands must be defined in main GS, then added in catchcommands list in /library/commands.lua.
            > Follows strict sequence: 1 / 2 / 3 
                * 1 = Send, or catch command. Dictates whether the command is being sent, or caught by player.
                * 2 = Start, or stop command. Dictates whether the command is starting, or stopping.
                * 3 = Name of the command that is being executed.
            

V229  - 4/18/2016 :
        + Removed logitech shortcuts for crafting, and treasure hunter sets.
        + Adjusted some keybinds locations.
        + Cleaned up some code, made it shorter / cleaner.

V228  - 3/27/2016 :
        + Changed naming scheme for library loader to use shorthand job name.

V227  - 3/6/2016 :
        + Changed naming scheme for library loader to allow support for multi-boxing accounts and using different library files.
        + Added LocalSelfCommand function in main file to separate core commands from job specific self commands.

V226  - 3/5/2016 :
        + Added aftercast check to determine status; if engaged go back to TP set, else goto idle set.

V225  - 3/4/2016 :
        + Fixed status change function cause gear to not switch back to idle sets.

V224  - 3/3/2016 :
        + Added in functions for pet events, and also adjust some function errors.

V223  - 2/23/2016 :
        + Added in quick toggles for Crafting, Kiting, Trasure Hunter, Magic Damage Taken, and Magic Evasion sets.
        + Moved core settings, key-binds, and variables in to the main GearSwap file to separate from job specific settings, key-binds, and variables.

V222  - 2/20/2016 :
        + New weaponskill logic; now automatically detects which set to use instead of having to manually insert in to core logic.

V221  - 2/07/2016 :
        + Added formulas, and stat caps to the top of the file to help when making builds.

V220  - 2/01/2016 :
        + Re-Wrote structure to include job specific functions for handling specific logic for that job. Cleaned / Added some notes to help understand code.
        + Added Dual Box toggle for enabling specific dual box features.
        + Added Debug toggle to enable extended debug information in chat log. (Is used by default in Logitech Keyboard section below.)
    
V121  - 1/25/2016 : Re-structured format to make it easier to read, and adjusted / added notes.
     
     Important Information when building sets
     
     *Gear Haste Cap        - 25%    (256/1024)
     *Magic Haste Cap       - 43.75% (448/1024)
     *Job Ability Haste     - 25%    (256/1024).
     
     *Delay Cap             - 80%
        Dual Wield    > (1 - 30% Dual Wield)×(1024 - 256 Equipment Haste - 150 Magic Haste - 101 Job Ability Haste)÷1024 = 35.3%, or 64.7% Delay reduction
        Martial Arts  > (480 Base Delay + 86 Weapon Delay - 200 Martial Arts Delay)×(1024 - 256 Equipment Haste - 150 Magic Haste - 51 Job Ability Haste)=202.6
     
     *Fast Cast Cap         - 80%    floor( [1-Fast Cast] * ( [1-Haste] * ( 1.5 * Recast ) ) )
     *Cure Potency Cap      - 50%
     *Cure Cast Time Cap    - 20%
     *Cure Received Cap     - 30%
     
     *Physical Damage Taken - 50%
        Protect V   > Increases defense by 175.
        
     *Magical Damage Taken  - 50%   Magic Damage You Take = Floor( (Magic Damage you would have Taken)×(100% (-% Magic Damage Taken -% Damage Taken) -% Aegis Magic Damage Taken )÷( 1 + MDB÷100 ) )
        Shell V     > Reduces magic damage taken by 62/256 (24%).
        
     *Breath Damage Taken   - 50%


]]--
function get_sets()
    
    -- **Keybind Settings** ^(Control) | !(Alt) | @(Windows Key)
    -- (Combat Modes)
    send_command('bind @f1 gs c _modeNA')      -- Idle while not in combat mode.
    send_command('bind @f2 gs c _modeTP')      -- Idle while engaged in combat.
    send_command('bind @f3 gs c _modeMID')     -- Equip while casting (Midcast).
    send_command('bind @f4 gs c _modeWS')      -- Set Weaponskill mode.
    
    -- (Gear-Specific Modes)
    --send_command('bind @f5 gs c ')             -- Open Command slot
    send_command('bind @f6 gs c _modeLOCKW')   -- Lock Weapon, Sub, and Ranged for Trials or No TP loss.
    send_command('bind @f7 gs c _modeLOCKG')   -- Lock Head, Body, Hands, Legs, and Feet for trials.
    send_command('bind @f8 gs c _modeLOCKC')   -- Lock Back for capacity point farming.
    
    -- (Special Toggle) -- Used with Logitech Keyboard if binds are setup.    
    send_command('bind ^!@f7 gs c _modeKITE')  -- Lock on kiting gear set.
    send_command('bind ^!@f8 gs c _modeMDTT')  -- Lock on magic damage taken gear set.
    send_command('bind ^!@f9 gs c _modeMEVT')  -- Lock on magic evasion gear set.
    
    send_command('bind ^!@f4 gs c _modeDEBUG') -- Toggle on, and off extended debug information in chat log.
    send_command('bind ^!@f5 gs c _modeDBOX')  -- Toggle on, and off dual box features.
    
    -- (Multibox Commands) -- Used for running commands to control multiple accounts.
    send_command('bind ^!@f1 gs c send start wring') -- Send Warp Ring command to all accounts in party.
    send_command('bind @f gs c send start follow')   -- Send follow command to other accounts in party.
    send_command('bind @s gs c send stop follow')    -- Send stop command to other accounts in party.
    
    -- These are mode default variables. Be careful adjusting as it may cause unwanted changes to your gearswap.
    _modeNAi     = 1;       -- Idle Sets Variable.
    _modeTPi     = 1;       -- TP Sets Variable.
    _modeMIDi    = 1;       -- Midcast Sets Variable.
    _modeWSi     = 1;       -- Weaponskill Sets Variable.
    _modeLOCKWi  = 1;       -- Lock Weapons Variable.
    _modeLOCKGi  = 1;       -- Lock All Gear Variable.
    _modeLOCKCi  = 1;       -- Lock Capacity Set Variable.
    _modeKITEi   = 1;       -- Lock Kite Set Variable.
    _modeMDTTi   = 1;       -- Lock Magic Damage Taken Set Variable.
    _modeMEVTi   = 1;       -- Lock Magic Evasion Set Variable.
    
    _DEBUG	 = false;   -- Outputs variables and info to chatlog to see whats going on with GearSwap. Useful for determining ability types and ability/spell names.
    _DBOX        = true;    -- Enables support for special dual box function using send, autoexec, and buddypal addon.
    --send_command('@ autoexec load DualBoxCommands')
    
    -- Include job-specific library.
    include('/library/' .. player.name .. player.main_job .. 'Library.lua')
    
    -- Multibox Configs.
    include('/library/Commands.lua')
    alt_names = T{'Elidyr','Lilyia','Lildyr','Cheddarz'}
     
    -- Initialize all settings from library.
    LoadSettings()
    
    -- **Unload Keybind Settings**
    function file_unload()
        
        send_command('unbind @`')
        send_command('unbind @f1')
        send_command('unbind @f2')
	send_command('unbind @f3')
	send_command('unbind @f4')
	send_command('unbind @f5')
	send_command('unbind @f6')
	send_command('unbind @f7')
	send_command('unbind @f8')
	send_command('unbind @f9')
	send_command('unbind @f10')
	send_command('unbind @f11')
	send_command('unbind @f12')
	send_command('unbind @1')
        send_command('unbind @2')
	send_command('unbind @3')
	send_command('unbind @4')
	send_command('unbind @5')
	send_command('unbind @6')
	send_command('unbind @7')
	send_command('unbind @8')
	send_command('unbind @9')
	send_command('unbind @0')
	send_command('unbind @-')
	send_command('unbind @=')
	send_command('unbind @insert')
	send_command('unbind @delete')
	send_command('unbind @home')
	send_command('unbind @end')
        
	-- [G]Keys for Logitech Keyboards (Have to match binds in Logitech Profile)
	send_command('unbind ^!@f1')
	send_command('unbind ^!@f2')
	send_command('unbind ^!@f3')
	send_command('unbind ^!@f4')
	send_command('unbind ^!@f5')
	send_command('unbind ^!@f6')
	send_command('unbind ^!@f7')
	send_command('unbind ^!@f8')
	send_command('unbind ^!@f9')
        
	send_command('unbind !@f1')
	send_command('unbind !@f2')
	send_command('unbind !@f3')
	send_command('unbind !@f4')
	send_command('unbind !@f5')
	send_command('unbind !@f6')
	send_command('unbind !@f7')
	send_command('unbind !@f8')
	send_command('unbind !@f9')
        
	send_command('unbind ^@f1')
	send_command('unbind ^@f2')
	send_command('unbind ^@f3')
	send_command('unbind ^@f4')
	send_command('unbind ^@f5')
	send_command('unbind ^@f6')
	send_command('unbind ^@f7')
	send_command('unbind ^@f8')
	send_command('unbind ^@f9')
	
	send_command('@ autoexec clear')
    
    end
    
end



function precast(spell, act)
    
    -- DEBUG: Output precast spell information to chat log.
    if _DEBUG == true then
        send_command('@ input /echo ** Precast - Name: '..spell.name..', Type: '..spell.type..', Element: '..spell.element..' ')
        send_command('@ input /echo ** Weather Element: '..world.weather_element..' ')
        send_command('@ input /echo ** Target Type: '..player.target.type..' ')
        send_command('@ input /echo **************************************************************')
        
        if spell.skill then
            send_command('@ input /echo ** Skill Type: '..spell.skill..' ')
            send_command('@ input /echo **************************************************************')
        end
        
    end
    
    LocalPrecast(spell, act)
    
end



function midcast(spell,act)
    
    -- DEBUG: Output midcast spell information to chat log.
    if _DEBUG == true then
        send_command('@ input /echo ** Midcast - Name: '..spell.name..', Type: '..spell.type..', Element: '..spell.element..' ')
        send_command('@ input /echo ** Weather Element: '..world.weather_element..' ')
        send_command('@ input /echo ** Target Type: '..player.target.type..' ')
        send_command('@ input /echo **************************************************************')
        
        if spell.skill then
            send_command('@ input /echo ** Skill Type: '..spell.skill..' ')
            send_command('@ input /echo **************************************************************')
        end
        
    end
    
    LocalMidcast(spell, act)
    
end



function aftercast(spell, act)
    
    -- Equip selected TP set if engaged on a mob.
    if player.status == 'Engaged' then
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
    
    -- Not engaged then default back to Idle set.
    else 
        equip(sets.NA[sets.NA.Mode[_modeNAi]])
    
    end
    
    LocalAftercast(spell, act)
    
end



function status_change(new, old)
    
    -- FOR DEBUG PURPOSES ONLY!
    if _DEBUG == true then
        send_command('@ input /echo ** Status - New: '..new..', Old: '..old..' ')
        send_command('@ input /echo **************************************************************')
    end
    
    -- Equip selected TP set if engaged on a mob.
    if player.status == 'Engaged' then
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
    
    -- Not engaged then default back to Idle set.
    else 
        equip(sets.NA[sets.NA.Mode[_modeNAi]])
    
    end
    
   LocalStatusChange(new, old)
    
end



function buff_change(name, gain)
    
    -- FOR DEBUG PURPOSES ONLY!
    if _DEBUG == true then
        
        if gain then 
            send_command('@ input /echo ** Buff - Name: '..name..', Buff Gained! ')
            send_command('@ input /echo **************************************************************')
        else
            send_command('@ input /echo ** Buff - Name: '..name..', Buff Lost! ')
            send_command('@ input /echo **************************************************************')
        end
        
    end
    
    LocalBuffChange(name, gain)
    
end



function pet_change(pet, gain)
    
    LocalPetChange(pet, gain)
    
end



function pet_midcast(spell)
    
    LocalPetMidcast(spell)
    
end



function pet_aftercast(spell)
    
    LocalPetAftercast(spell)
    
end



function pet_status_change(new, old)
    
    LocalPetStatusChange(new, old)
    
end



function self_command(command)    
    
    -- Toggle for Idle Mode.
    if command == '_modeNA' then
        
        -- Keeps track of variable.
        if _modeNAi < 3 then _modeNAi = _modeNAi + 1 else _modeNAi = 1 end
        
        add_to_chat(200, '<< Current Idle Mode: '..sets.NA.Mode[_modeNAi]..'. >>')
        equip(sets.NA[sets.NA.Mode[_modeNAi]])
    
    -- Toggle for TP Mode.
    elseif command == '_modeTP' then
        
        -- Keeps track of variable.
        if _modeTPi < 5 then _modeTPi = _modeTPi + 1 else _modeTPi = 1 end
        
        add_to_chat(200, '<< Current TP Mode: '..sets.TP.Mode[_modeTPi]..'. >>')
        equip(sets.TP[sets.TP.Mode[_modeTPi]])
    
    -- Toggle for Midcasting Mode.
    elseif command == '_modeMID' then
        
        -- Keeps track of variable.
        if _modeMIDi < 4 then _modeMIDi = _modeMIDi + 1 else _modeMIDi = 1 end
        
        add_to_chat(200, '<< Current Midcast Mode: '..sets.MID.Mode[_modeMIDi]..'. >>')
        equip(sets.MID[sets.MID.Mode[_modeMIDi]])
    
    -- Toggle for Weaponskill Mode.
    elseif command == '_modeWS' then
        
        -- Keeps track of variable.
        if _modeWSi < 2 then _modeWSi = _modeWSi + 1 else _modeWSi = 1 end
        
        if _modeWSi == 1 then
            add_to_chat(200, '<< Weaponskill mode: Attack. >>')
            
        elseif _modeWSi == 2 then
            add_to_chat(200, '<< Weaponskill mode: Accuracy. >>')
            
        end
    
    -- Toggle for locking weapons while doing trials or no TP Loss.
    elseif command == '_modeLOCKW' then
        
        if _modeLOCKWi < 2 then _modeLOCKWi = _modeLOCKWi + 1 else _modeLOCKWi = 1 end        
        
        if _modeLOCKWi == 1 then
            add_to_chat(200, '<< Weapon|Sub|Ranged slots are now Unlocked. >>')
            enable('main','sub','range')
            
        elseif _modeLOCKWi == 2 then
            add_to_chat(200, '<< Weapon|Sub|Ranged slots are now Locked. >>')
            disable('main','sub','range')
            
        end
    
    -- Lock all equipment slots.
    elseif command == '_modeLOCKG' then
        
        -- Keeps track of variable.
        if _modeLOCKGi < 2 then _modeLOCKGi = _modeLOCKGi + 1 else _modeLOCKGi = 1 end
        
        if _modeLOCKGi == 1 then            
            add_to_chat(200, '<< Gear Lock Mode: Disabled. >>')
            enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
                
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
                
            end	
            
        elseif _modeLOCKGi == 2 then
            add_to_chat(200, '<< Gear Lock Mode: Enabled. >>')
            disable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
            
        end
    
    -- Lock back slot, and ring for Capacity Point farming.
    elseif command == '_modeLOCKC' then
        
        -- Keeps track of variable.
        if _modeLOCKCi < 2 then _modeLOCKCi = _modeLOCKCi + 1 else _modeLOCKCi = 1 end
        
        if _modeLOCKCi == 1 then            
            add_to_chat(200, '<< Capacity Mode: Disabled. >>')
            enable('back','ring2')
            
            if player.status == 'Engaged' then
                equip(sets.TP[sets.TP.Mode[_modeTPi]])
                
            else 
                equip(sets.NA[sets.NA.Mode[_modeNAi]])
                
            end	
            
        elseif _modeLOCKCi == 2 then
            add_to_chat(200, '<< Capacity Mode: Enabled. >>')
            equip(sets.Capacity)
            disable('back','ring2')
            
        end
    
    -- Lock all current gear for kiting, or increased speed.
    elseif command == '_modeKITE' then
        add_to_chat(200, '<< Kite Mode: Triggered. >>')
        equip(sets.Kite)
    
    -- Lock all current gear for magic damage taken.
    elseif command == '_modeMDTT' then
        add_to_chat(200, '<< MDT Mode: Triggered. >>')
        equip(sets.MDT)
    
    -- Lock all current gear for magic evasion.
    elseif command == '_modeMEVT' then
        add_to_chat(200, '<< Magic Evasion Mode: Triggered. >>')
        equip(sets.MEV)
    
    -- Toggle dual box mode on, and off.
    elseif command == '_modeDBOX' then
        
        -- Keeps track of variable.
        if _DBOX == false then
            _DBOX = true
            add_to_chat(200, '<< Dual Box Mode Enabled. >>')
            
        elseif _DBOX == true then
            _DBOX = false
            add_to_chat(200, '<< Dual Box Mode Disabled. >>')
            
        end
    
    -- Toggle debug mode on, and off.
    elseif command == '_modeDEBUG' then
        
        -- Keeps track of variable.
        if _DEBUG == false then
            _DEBUG = true
            add_to_chat(200, '<< Debug Mode Enabled. >>')
            
        elseif _DEBUG == true then
            _DEBUG = false
            add_to_chat(200, '<< Debug Mode Disabled. >>')
            
        end
        
    end
    
    LocalSelfCommand(command)
    
    -- ***********************************************************************
    -- All self commands for sending information to other accounts starts here.
    -- ***********************************************************************
    
    -- Start follow on all accounts.
    if command == 'send start follow' then
        sendCommand = 'catch start follow ' .. player.name
        SendCommandOthers(sendCommand, alt_names)
        
    -- Start Warp Ring on all accounts.
    elseif command == 'send start wring' then
        sendCommand = 'catch start wring'
        SendCommandAll(sendCommand, alt_names)
        send_command('input /p Warping out.')
        
    -- Cancel follow on all accounts.
    elseif command == 'send stop follow' then
        sendCommand = 'catch stop follow ' .. player.name
        SendCommandOthers(sendCommand, alt_names)
        
    -- ***********************************************************************
    -- All self commands for catching information to from other accounts starts here.
    -- ***********************************************************************
    
    elseif #command > 0 then
        catchCommands(command, alt_names)
        
    end
            
end