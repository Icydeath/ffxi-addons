--[[

Copyright © 2016, Elidyr
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

################################################################################################

BuddyPal: Built to aid in dual boxing with multiple jobs.
    
    * 8/08/2016 | v1.0.2.0
        - Added the ability to display skillchain properties when closing skillchains.
        - Added list for all skillchain properties for automatically skillchaining with highest tier.
        - Added Bolter's Roll and Double-Up for Corsair.
        @ In Progress - more in depth commands for future functions. (Set back-up weaponskill, and set skillchain properties.)
    
    * 7/31/2016 | v1.0.1.6
        - Added more spells, and abilities. (WAR/COR) Now able to disable, and enable functionality of commands. 
    
    * 4/03/2016 | v1.0.1.5
        - Started complete overhaul on addon. New function design, support for all jobs to use abilities, magic, and utilities.

    * 3/06/2016 - Added SAM weaponskills, and utility functions

    * 2/18/2016 - BLM Nukes, and RDM abilities added in parser functions.

    * 2/16/2016 - Ability to buff, selfbuff, raise, cure, cast songs, and use WHM abilities added in parser functions.

    * 1/11/2016 - First mock-up of addon, overall layout of addon and core functions for add-on.
]]
	

require('luau')
require('tables')
require('strings')
packets   = require('packets')
resources = require('resources')

_addon.name 	 = 'BuddyPal'
_addon.author 	 = 'Elidyr'
_addon.command   = 'bp'
_addon.version   = '1.0.2.0'

config           = {}

config.nukes     = S{
    'f1','f2','f3','f4','f5','f6','fg1','fg2','fg3','fja',
    'b1','b2','b3','b4','b5','b6','bg1','bg2','bg3','bja',
    'a1','a2','a3','a4','a5','a6','ag1','ag2','ag3','aja',
    's1','s2','s3','s4','s5','s6','sg1','sg2','sg3','sja',
    't1','t2','t3','t4','t5','t6','tg1','tg2','tg3','tja',
    'w1','w2','w3','w4','w5','w6','wg1','wg2','wg3','wja',
    }

config.magic              = S{'magic'}
config.abilities          = S{'ability'}
config.weaponskills       = S{'ws'}
config.autoattack         = S{'attack'}
config.autoburst          = S{'burst'}
config.messages           = S{'msg'}
config.reload             = S{'rl'}

config._magic             = false
config._ability           = false
config._ws                = false
config._msg               = false
config._attack            = false
config._burst             = false

config.list = {}
config.list.transfixion   = S{
'ascetic\'s fury','evisceration','power slash','vorpal scythe','double thrust','thunder thrust','raiden thrust','vorpal thrust','skewer','drakesbane','sonic thrust','stardiver','blade: rin','blade: chi','blade: ku',
'tachi: enpi','tachi: goten','omniscience','flaming arrow','piercing arrow','dulling arrow','sidewinder','blast arrow','empyreal arrow','refulgent arrow','apex arrow','hot shot','split shot','sniper shot','slug shot',
'blast shot','detonator','leaden salute'}
config.list.compression   = S{
'one inch punch','mandalic stab','keen edge','upheaval','nightmare scythe','insurgency','penta thrust','blade: ei','blade: kamu','tachi: kasha','tachi: ageha','tachi: shoha','black halo','cataclysm'}
config.list.liquefaction  = S{
'spinning attack','asuran fists','stringing pummel','burning blade','red lotus blade','spinning axe','tachi: kagero','full swing','flaming arrow','dulling arrow','sniper shot'}
config.list.scission      = S{
'wasp sting','viper bite','dancing edge','pyrric kleos','aeolian edge','exenterator','fast blade','shining blade','seraph blade','vorpal blade','savage blade','expiacion','requiescat','hard slash','crescent moon',
'sickle moon','resolution','avalanche axe','spinning axe','rampage','calamity','bora axe','iron tempest','sturmwind','king\s justice','fell cleave','slice','nightmare scythe','spinning sctyhe','vorpal scythe',
'sonic thrust','blade: retsu','blade: yu','tachi: enpi','tachi: jinpu','tachi: ageha','trueflight'}
config.list.reverberation = S{
'combo','shijin spiral','shadow stitch','circle blade','atonement','shockwave','smash axe','decimation','primal rend','sturmwind','raging rush','dark harvest','shadow of death','spinning scythe','infernal scythe',
'entropy','vorpal thrust','blade: teki','blade: yu','tachi: koki','tachi: gekko','brainshaker','skullbreaker','flash nova','starburst','sunburst','retribution','garland of bliss','cataclysm','piercing arrow',
'refulgent arrow','hot shot','split shot','slug shot','last stand'}
config.list.detonation    = S{
'backhand blow','gust slash','cyclone','dancing edge','aeolian edge','red lotus blade','freezebite','herculean slash','raging axe','gale axe','ruinator','steel cyclone','fell cleave','blade: to','blade: jin',
'tachi: jinpu','tachi: yukikaze','true strike','shell crusher','sidewinder','slug shot','numbing shot'}
config.list.induration    = S{
'tornado kick','frostbite','freezebite','herculean slash','smash axe','raging rush','shadow of death','guillotine','impulse drive','blade: to','tachi: hobaku','tachi: yuikikaze','tachi: rana','skullbreaker','flash nova',
'shattersoul','blast arrow','blast shot','numbing shot'}
config.list.impaction     = S{
'combo','shoulder tackle','raging fists','spinning attack','tornado kick','cyclone','aeolian edge','flat blade','circle blade','vorpal blade','sickle moon','herculean slash','raging axe','avalanche axe','spinning axe',
'calamity','shield break','armor break','weapon break','thunder thrust','raiden thrust','leg sweep','skewer','blade: chi','blade: shun','tachi: goten','tachi: koki','shining strike','seraph strike','true strike',
'realmrazer','heavy swing','rock crusher','earth crusher','full swing','numbing shot'}

config.list.gravitation   = S{
'asuran fists','stringing pummel','evisceration','mercy stroke','swift blade','requiescat','catastrophe','entropy','impulse drive','stardiver','blade: ten','blade: ku','blade: hi','tachi: rana','retribution','omniscience',
'shattersoul','leaden salute','wildfire'}
config.list.distorion     = S{
'mordant rime','pyrric kleos','rudra\'s storm','death blossom','expiacion','chant du cygne','ground strike','torcleaver','ruinator','full break','cross reaper','quietus','geirskogul','tachi: gekko','tachi: fudo',
'vidohunir','gate of tartarus','namas arrow'}
config.list.fusion        = S{
'final heaven','ascetic\'s fury','shijin spiral','mandalic stab','knights of the round','atonement','scourge','mistral axe','decimation','metatron torment','upheaval','insurgency','wheeling thrust','drakesbane',
'blade: shun','tachi: kasha','hexa strike','realmrazer','garland of bliss','arching arrow','empyreal arrow','jishnu\'s radiance','heavy shot','detonator','last stand'}
config.list.fragmentation = S{
'dragon kick','victory smite','shark bite','mordant rime','exenterator','savage blade','death blossom','spinning slash','ground strike','resolution','dimidiation','cloudsplitter','king\'s justice','ukko\'s fury',
'camlann\'s torment','blade: metsu','blade: kamu','tachi: kaiten','tachi: shoha','black halo','randgrith','exudation','vidohunir','apex arrow','cronach','trueflight'}

config.list.light         = S{
'final heaven','victory smite','knights of the round','chant du cygne','scourge','torcleaver','dimidiation','metatron torment','ukko\'s fury','geirskogul','camlann\'s torment','tachi: kaiten','tachi: fudo',
'randgrith','namas arrow','jishnu\'s radiance'}
config.list.dark          = S{
'mercy stroke','rudra\'s storm','onslaught','cloudsplitter','catastrophe','quietus','blade: metsu','blade: hi','exudation','gate of tartarus','cronach','wildfire'}

-- #############################################################################
-- Parses for incoming chat to register specific events.

-- #############################################################################
windower.register_event('incoming chunk', function(id, data)
    if id == 0x017 then -- Incoming Chat Packet
        local chat      = packets.parse('incoming', data)
        local mode      = chat['Mode']
        local sender    = chat['Sender Name']
        local message   = chat['Message']
        
        if mode == 4 or mode == 3 then
            local player = windower.ffxi.get_player()
            
            if config._magic == true then
                ParseMagicCommands(message, sender)
                
            end
            
            if config._ability == true then
                ParseAbilityCommands(message, sender)
                
            end
            
            ParseUtilityCommands(message, sender)
            
        end
                
    end
    
end)

-- #############################################################################
-- Parses for closing weapon skill information to register specific events.

-- #############################################################################
windower.register_event('action', function(action)
    
    local player       = windower.ffxi.get_player()
    local mob          = windower.ffxi.get_mob_by_id(action['targets'][1]['id'])
    local actorId      = windower.ffxi.get_mob_by_id(action['actor_id'])
    local skillchainID = action['targets'][1]['actions'][1]['add_effect_animation']
    
    --table.vprint(action)
    --log(mob['distance'])
    
    --Light Skillchain
    if skillchainID == 1 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Light --> (Fire|Wind|Thunder|Light) >>")
        
        if player['main_job'] == "BLM" then
            
        elseif player['main_job'] == "BLU" then
            
            if player['vitals']['tp'] > 1000 and mob['distance'] < 20 then
                windower.send_command('input /echo 1; wait 3.5; input /ws "Chant du Cygne" <bt>; wait 3; input /ma "Anvil Lightning" <bt>')
            
            end
            
            
            
        end
        
    --Dark Skillchain
    elseif skillchainID == 2 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Dark --> (Ice|Earth|Water|Dark) >>")
        
        if player['main_job'] == "BLM" then
            
        elseif player['main_job'] == "BLU" then
            
            if player['vitals']['tp'] > 1000 and mob['distance'] < 20 then
                windower.send_command('input /echo 1; wait 3.5; input /ws "Requiescat" <bt>')
            
            end
            
        end
        
    --Gravitation Skillchain
    elseif skillchainID == 3 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Gravitation --> Gravitation --> (Earth|Dark) >>")
        
        if player['main_job'] == "BLM" then
            
        elseif player['main_job'] == "BLU" then
            
            if player['vitals']['tp'] > '1000' and mob['distance'] < '20' then
                windower.send_command('@ input /ws "Chant du Cygne" <bt>')
            end
            
        end
        
    --Fragmentation Skillchain
    elseif skillchainID == 4 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Fragmentation --> (Wind|Thunder) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Distorion Skillchain
    elseif skillchainID == 5 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Distorion --> (Ice|Water) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Fusion Skillchain
    elseif skillchainID == 6 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Fusion --> (Fire|Light) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Compression Skillchain
    elseif skillchainID == 7 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Compression --> (Dark) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Liquefaction Skillchain
    elseif skillchainID == 8 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Liquefaction --> (Fire) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Induration Skillchain
    elseif skillchainID == 9 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Induration --> (Ice) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Reverberation Skillchain
    elseif skillchainID == 10 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Reverberation --> (Water) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Transfixion Skillchain
    elseif skillchainID == 11 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Transfixion --> (Light) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Scission Skillchain | Earth
    elseif skillchainID == 12 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Scission --> (Earth) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Detonation Skillchain
    elseif skillchainID == 13 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Detonation --> (Wind) >>")
        
        if player['main_job'] == "BLM" then
            
        end
        
    --Impaction Skillchain
    elseif skillchainID == 14 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Impaction --> (Thunder) >>")
        
        if player['main_job'] == "BLM" then
            
        end
    
    end
    
end)

-- #############################################################################
-- Register all commands, and shortcuts for enabling, and disabling features.

-- #############################################################################
windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local args = T{...}
    
    if config.magic:contains(command) then
        
        if args[1] and args[1] == "on" then
            
            config._magic = true
            windower.chat.input("/echo Magic commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._magic = false
            windower.chat.input("/echo Magic commands now disabled.")
            
        else
            
            log("Valid Magic commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end
        
    elseif config.abilities:contains(command) then
        
        if args[1] and args[1] == "on" then
            
            config._ability = true
            windower.chat.input("/echo Ability commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._ability = false
            windower.chat.input("/echo Ability commands now disabled.")
            
        else
            
            log("Valid Ability commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end
        
    elseif config.weaponskills:contains(command) then
        
        if args[1] and args[1] == "on" then
            
            config._ws = true
            windower.chat.input("/echo Weaponskill commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._ws = false
            windower.chat.input("/echo Weaponskill commands now disabled.")
            
        else
            
            log("Valid Weaponskill commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end        
        
    elseif config.messages:contains(command) then
        
        if args[1] and args[1] == "on" then
            
            config._msg = true
            windower.chat.input("/echo Message commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._msg = false
            windower.chat.input("/echo Message commands now disabled.")
            
        else
            
            log("Valid Message commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end        
        
    elseif config.autoattack:contains(command) then
                
            if args[1] and args[1] == "on" then
            
            config._attack = true
            windower.chat.input("/echo Auto-Attack commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._attack = false
            windower.chat.input("/echo Auto-Attack commands now disabled.")
            
        else
            
            log("Valid Auto-Attack commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end
        
    elseif config.autoburst:contains(command) then
        
        if args[1] and args[1] == "on" then
            
            config._burst = true
            windower.chat.input("/echo Auto-Burst commands now enabled.")
            
        elseif args[1] and args[1] == "off" then
            
            config._burst = false
            windower.chat.input("/echo Auto-Burst commands now disabled.")
            
        else
            
            log("Valid Auto-Burst commands are:")
            log("************************************************")
            log("On")
            log("Off")
            log("************************************************")
        
        end        
    
    elseif config.reload:contains(command) then
        windower.send_command('lua reload buddypal')
        
    else    
        log("Valid BuddyPal commands are:")
        log("************************************************")
        log("Magic - //bp Magic (on / off)")
        log("Abilities - //bp Ability (on / off)")
        log("Weaponskills - //bp WS (on / off)")
        log("AutoAttack - //bp Attack (on / off)")
        log("AutoBurst - //bp Burst (on / off)")
        log("Messages - //bp MSG (on / off)")
        log("Reload - //bp RL (on / off)")
        log("************************************************")
        
    end
    
end)

-- #############################################################################
-- Run parse for all magic commands.

-- #############################################################################
function ParseMagicCommands(message, sender)
    
    _MagicCommands = {}
    _MagicCommands.Cures          = S{'c1','c2','c3','c4','c5','c6','cg1','cg2','cg3','cg4','cg5','fullc'}
    _MagicCommands.Buffs          = S{'prot','shel','hast','rege','snea','invi'}
    _MagicCommands.Debuffs        = S{'doom','curse','pet','petrify','stona','stoned','erase','para','slow','sile','blind','bind','grav','z','pois'}
    _MagicCommands.Selfbuffs      = S{'stones','aqua','ausp','bstr','bdex','bint','bvit','bchr','bmnd','bagi','barf','bara','barw','bart','bars','barb','reraise','srefr','shast'}
    _MagicCommands.Nukes          = S{
    'f1','f2','f3','f4','f5','f6','fg1','fg2','fg3','fja',
    'b1','b2','b3','b4','b5','b6','bg1','bg2','bg3','bja',
    'a1','a2','a3','a4','a5','a6','ag1','ag2','ag3','aja',
    's1','s2','s3','s4','s5','s6','sg1','sg2','sg3','sja',
    't1','t2','t3','t4','t5','t6','tg1','tg2','tg3','tja',
    'w1','w2','w3','w4','w5','w6','wg1','wg2','wg3','wja',
    }
    _MagicCommands.Utility        = S{'raise'}
    
    if windower.regex.match(message, "c1") then
        local found = windower.regex.match(message, "c1")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "c3") then
        local found = windower.regex.match(message, "c3")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure III" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "c4") then
        local found = windower.regex.match(message, "c4")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure IV" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "c5") then
        local found = windower.regex.match(message, "c5")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure V" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "c6") then
        local found = windower.regex.match(message, "c6")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure VI" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cg1") then
        local found = windower.regex.match(message, "cg1")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cg2") then
        local found = windower.regex.match(message, "cg2")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga II" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cg3") then
        local found = windower.regex.match(message, "cg3")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga III" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cg4") then
        local found = windower.regex.match(message, "cg4")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga IV" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cg5") then
        local found = windower.regex.match(message, "cg5")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga V" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "fullc") then
        local found = windower.regex.match(message, "fullc")
        if _MagicCommands.Cures:contains(found[1][0]) then
            windower.send_command('@ input /ma "Full Cure" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "prot.*?") then
        local found = windower.regex.match(message, "prot.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Protect V" ' .. sender ..'')
            windower.send_command('@ input /ma "Protect IV" ' .. sender ..'')
            windower.send_command('@ input /ma "Protect III" ' .. sender ..'')
            windower.send_command('@ input /ma "Protect II" ' .. sender ..'')
            windower.send_command('@ input /ma "Protect I" ' .. sender ..'')
        end            
        
    elseif windower.regex.match(message, "shel.*?") then
        local found = windower.regex.match(message, "shel.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Shell V" ' .. sender ..'')
            windower.send_command('@ input /ma "Shell IV" ' .. sender ..'')
            windower.send_command('@ input /ma "Shell III" ' .. sender ..'')
            windower.send_command('@ input /ma "Shell II" ' .. sender ..'')
            windower.send_command('@ input /ma "Shell I" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "hast.*?") then
        local found = windower.regex.match(message, "hast.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Haste II" ' .. sender ..'')
            windower.send_command('@ input /ma "Haste" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "rege.*?") then
        local found = windower.regex.match(message, "rege.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Regen V" ' .. sender ..'')
            windower.send_command('@ input /ma "Regen IV" ' .. sender ..'')
            windower.send_command('@ input /ma "Regen III" ' .. sender ..'')
            windower.send_command('@ input /ma "Regen II" ' .. sender ..'')
            windower.send_command('@ input /ma "Regen" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "snea.*?") then
        local found = windower.regex.match(message, "snea.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Sneak" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "invi.*?") then
        local found = windower.regex.match(message, "invi.*?")
        if _MagicCommands.Buffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Invisible" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "zz.*?") then
        local found = windower.regex.match(message, "zz.*?")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Curaga" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "cursna") then
        local found = windower.regex.match(message, "cursna")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cursna" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "doom") then
        local found = windower.regex.match(message, "doom")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cursna" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "curse") then
        local found = windower.regex.match(message, "curse")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cursna" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "stona") then
        local found = windower.regex.match(message, "stona")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Stona" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "stoned") then
        local found = windower.regex.match(message, "stoned")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Stona" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "para") then
        local found = windower.regex.match(message, "para")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Paralyna" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "erase") then
        local found = windower.regex.match(message, "erase")
        if _MagicCommands.Debuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Erase" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "stones") then
        local found = windower.regex.match(message, "stones")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Stoneskin" <me>')
        end
        
    elseif windower.regex.match(message, "aqua") then
        local found = windower.regex.match(message, "aqua")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aquaveil" <me>')
        end
        
    elseif windower.regex.match(message, "ausp") then
        local found = windower.regex.match(message, "ausp")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Auspice" <me>')
        end
        
    elseif windower.regex.match(message, "bstr") then
        local found = windower.regex.match(message, "bstr")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Boost-STR" <me>')
        end
        
    elseif windower.regex.match(message, "bdex") then
        local found = windower.regex.match(message, "bdex")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Boost-DEX" <me>')
        end
        
    elseif windower.regex.match(message, "bint") then
        local found = windower.regex.match(message, "bint")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Boost-INT" <me>')
        end
        
    elseif windower.regex.match(message, "barf") then
        local found = windower.regex.match(message, "barf")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Barfira" <me>')
        end
        
    elseif windower.regex.match(message, "bara") then
        local found = windower.regex.match(message, "bara")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Baraera" <me>')
        end
        
    elseif windower.regex.match(message, "barw") then
        local found = windower.regex.match(message, "barw")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Barwatera" <me>')
        end
        
    elseif windower.regex.match(message, "bart") then
        local found = windower.regex.match(message, "bart")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Barthundra" <me>')
        end
        
    elseif windower.regex.match(message, "bars") then
        local found = windower.regex.match(message, "bars")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Barstonra" <me>')
        end
        
    elseif windower.regex.match(message, "barb") then
        local found = windower.regex.match(message, "barb")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Barblizzara" <me>')
        end
        
    elseif windower.regex.match(message, "reraise") then
        local found = windower.regex.match(message, "reraise")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Reraise IV" <me>')
            windower.send_command('@ input /ma "Reraise III" <me>')
            windower.send_command('@ input /ma "Reraise II" <me>')
            windower.send_command('@ input /ma "Reraise" <me>')
        end
        
    elseif windower.regex.match(message, "shast.*?") then
        local found = windower.regex.match(message, "shast.*?")
        if _MagicCommands.Selfbuffs:contains(found[1][0]) then
            windower.send_command('@ input /ma "Haste II" <me>')
            windower.send_command('@ input /ma "Haste" <me>')
        end
        
    elseif windower.regex.match(message, "raise") then
        local found = windower.regex.match(message, "raise")
        if _MagicCommands.Utility:contains(found[1][0]) then
            windower.send_command('@ input /ma "Arise" ' .. sender ..'')
            windower.send_command('@ input /ma "Raise III" ' .. sender ..'')
            windower.send_command('@ input /ma "Raise II" ' .. sender ..'')
            windower.send_command('@ input /ma "Raise" ' .. sender ..'')
        end
        
    elseif windower.regex.match(message, "f1") then
        local found = windower.regex.match(message, "f1")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire" <bt>')
        end
        
    elseif windower.regex.match(message, "f2") then
        local found = windower.regex.match(message, "f2")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire II" <bt>')
        end
        
    elseif windower.regex.match(message, "f3") then
        local found = windower.regex.match(message, "f3")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire III" <bt>')
        end
        
    elseif windower.regex.match(message, "f4") then
        local found = windower.regex.match(message, "f4")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire IV" <bt>')
        end
        
    elseif windower.regex.match(message, "f5") then
        local found = windower.regex.match(message, "f5")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire V" <bt>')
        end
        
    elseif windower.regex.match(message, "b1") then
        local found = windower.regex.match(message, "b1")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Blizzard" <bt>')
        end
        
    elseif windower.regex.match(message, "b2") then
        local found = windower.regex.match(message, "b2")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Blizzard II" <bt>')
        end
        
    elseif windower.regex.match(message, "b3") then
        local found = windower.regex.match(message, "b3")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Blizzard III" <bt>')
        end
        
    elseif windower.regex.match(message, "b4") then
        local found = windower.regex.match(message, "b4")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Blizzard IV" <bt>')
        end
        
    elseif windower.regex.match(message, "b5") then
        local found = windower.regex.match(message, "b5")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Blizzard V" <bt>')
        end
        
    elseif windower.regex.match(message, "a1") then
        local found = windower.regex.match(message, "a1")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aero" <bt>')
        end
        
    elseif windower.regex.match(message, "a2") then
        local found = windower.regex.match(message, "a2")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aero II" <bt>')
        end
        
    elseif windower.regex.match(message, "a3") then
        local found = windower.regex.match(message, "a3")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aero III" <bt>')
        end
        
    elseif windower.regex.match(message, "a4") then
        local found = windower.regex.match(message, "a4")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aero IV" <bt>')
        end
        
    elseif windower.regex.match(message, "a5") then
        local found = windower.regex.match(message, "a5")
        if _MagicCommands.Nukes:contains(found[1][0]) then
            windower.send_command('@ input /ma "Aero V" <bt>')
        end
        
    end
    
end

-- #############################################################################
-- Parse for all incoming ability commands.

-- #############################################################################
function ParseAbilityCommands(message, sender)
    
    _AbilityCommands = {}
    _AbilityCommands.WAR = S{'mighty','serk','wcry','defend','gressor','voke','wcharge','toma','retal','straint','brage','brazen'}
    _AbilityCommands.MNK = S{}
    _AbilityCommands.WHM = S{}
    _AbilityCommands.BLM = S{}
    _AbilityCommands.RDM = S{}
    _AbilityCommands.THF = S{}
    _AbilityCommands.PLD = S{}
    _AbilityCommands.DRK = S{}
    _AbilityCommands.BST = S{}
    _AbilityCommands.BRD = S{}
    _AbilityCommands.RNG = S{}
    _AbilityCommands.SMN = S{}
    _AbilityCommands.NIN = S{}
    _AbilityCommands.DRG = S{}
    _AbilityCommands.SAM = S{}
    _AbilityCommands.BLU = S{}
    _AbilityCommands.COR = S{'fires','ices','winds','earths','thunders','waters','lights','darks','chopchop','double'}
    _AbilityCommands.PUP = S{}
    _AbilityCommands.DNC = S{}
    _AbilityCommands.SCH = S{}
    _AbilityCommands.GEO = S{}
    _AbilityCommands.RUN = S{}
    
    
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- WARRIOR ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    if windower.regex.match(message, "mighty") then
        local found = windower.regex.match(message, "mighty")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Mighty Strikes" <me>')
        end
        
    elseif windower.regex.match(message, "serk") then
        local found = windower.regex.match(message, "serk")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Berserk" <me>')
        end
        
    elseif windower.regex.match(message, "wcry") then
        local found = windower.regex.match(message, "wcry")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Warcry" <me>')
        end
        
    elseif windower.regex.match(message, "defend") then
        local found = windower.regex.match(message, "defend")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Defender" <me>')
        end
        
    elseif windower.regex.match(message, "gressor") then
        local found = windower.regex.match(message, "gressor")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Aggressor" <me>')
        end
        
    elseif windower.regex.match(message, "voke") then
        local found = windower.regex.match(message, "voke")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Provoke" <bt>')
        end
        
    elseif windower.regex.match(message, "wcharge") then
        local found = windower.regex.match(message, "wcharge")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Warrior\'s Charge" <bt>')
        end
        
    elseif windower.regex.match(message, "toma") then
        local found = windower.regex.match(message, "toma")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Tomahawk" <bt>')
        end
        
    elseif windower.regex.match(message, "retal") then
        local found = windower.regex.match(message, "retal")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Retaliation" <me>')
        end
        
    elseif windower.regex.match(message, "straint") then
        local found = windower.regex.match(message, "straint")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Restraint" <me>')
        end
        
    elseif windower.regex.match(message, "brage") then
        local found = windower.regex.match(message, "brage")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Blood Rage" <me>')
        end
        
    elseif windower.regex.match(message, "brazen") then
        local found = windower.regex.match(message, "brazen")
        if _AbilityCommands.WAR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Brazen Rush" <me>')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- MONK ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.MNK:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- WHITE MAGE ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.WHM:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- BLACK MAGE ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.BLM:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- RED MAGE ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.RDM:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- THIEF ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.THF:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- PALADIN ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.PLD:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- DARK KNIGHT ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.DRK:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- BEASTMASTER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.BST:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- BARD ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.BRD:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- RANGER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.RNG:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- SUMMONER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.SMN:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- NINJA ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.NIN:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- DRAGOON ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.DRG:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- SAMURAI ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.SAM:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- BLUE MAGE ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.BLU:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- CORSAIR ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "fires") then
        local found = windower.regex.match(message, "fires")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Fire Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "ices") then
        local found = windower.regex.match(message, "ices")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Ice Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "winds") then
        local found = windower.regex.match(message, "winds")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Wind Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "earths") then
        local found = windower.regex.match(message, "earths")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Earth Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "thunders") then
        local found = windower.regex.match(message, "thunders")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Thunder Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "waterss") then
        local found = windower.regex.match(message, "waterss")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Water Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "lights") then
        local found = windower.regex.match(message, "lights")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Light Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "darks") then
        local found = windower.regex.match(message, "darks")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ma "Dark Shot" <bt>')
        end
        
    elseif windower.regex.match(message, "chopchop") then
        local found = windower.regex.match(message, "chopchop")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Bolter\'s Roll" <me>')
        end
        
    elseif windower.regex.match(message, "double") then
        local found = windower.regex.match(message, "double")
        if _AbilityCommands.COR:contains(found[1][0]) then
            windower.send_command('@ input /ja "Double-Up" <me>')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- PUPPET MASTER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.PUP:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- DANCER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.DNC:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- SCHOLAR ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.SCH:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- GEOMANCER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.GEO:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    -- RUNE FENCER ABILITIES
    -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    elseif windower.regex.match(message, "c2") then
        local found = windower.regex.match(message, "c2")
        if _AbilityCommands.RUN:contains(found[1][0]) then
            windower.send_command('@ input /ma "Cure II" ' .. sender ..'')
        end
        
    end
    
end

-- #############################################################################
-- Parse for all incoming utility commands.

-- #############################################################################
function ParseUtilityCommands(message, sender)
    
    _UtilityCommands = {}
    _UtilityCommands.Utility        = S{'add','join','follow','jump'}
    
        -- Invite Event
    if windower.regex.match(message, "add") then
        local found = windower.regex.match(message, "add")
        if _UtilityCommands.Utility:contains(found[1][0]) then
            windower.send_command('@ input /pcmd add ' .. sender ..'')
        end
        
        -- Join Event
    elseif windower.regex.match(message, "join") then
        local found = windower.regex.match(message, "join")
        if _UtilityCommands.Utility:contains(found[1][0]) then
            windower.send_command('@ input /join')
        end
        
        -- Follow Event
    elseif windower.regex.match(message, "follow") then
        local found = windower.regex.match(message, "follow")
        if _UtilityCommands.Utility:contains(found[1][0]) then
            windower.send_command('@ input /follow ' .. sender ..'')
        end
        
        -- Jump Event
    elseif windower.regex.match(message, "jump") then
        local found = windower.regex.match(message, "jump")
        if _UtilityCommands.Utility:contains(found[1][0]) then
            windower.send_command('@ input /jump')
        end
        
    end
    
end