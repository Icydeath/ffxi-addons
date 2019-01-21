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

BuddyPal: Config library ** BE CAREFUL WHEN MODIFYING THIS FILE!!!!

    * 8/29/2016 | v1.0.2.1
        - Created separate configuration library.
        - Allows for easier variable calls, and easier modification of addon.
]]
local initialize    = {}

function initialize.init()
    
    --Configuration table.
    config = {}
    
    --Player data.
    config.player   = windower.ffxi.get_player()
    config.job_main = config.player.main_job
    config.job_sub  = config.player.sub_job

    --Addon commands list.
    config.ma       = S{'ma'}
    config.ja       = S{'ja'}
    config.ws       = S{'ws'}
    config.sc       = S{'sc'}
    config.auto     = S{'auto'}
    config.mb       = S{'mb'}
    config.parse    = S{'parse'}
    config.reload   = S{'rl'}

    --Addon command variables
    config._ma      = false
    config._ja      = false
    config._ws      = false
    config._sc      = false
    config._auto    = false
    config._mb      = false
    config.parse    = false
    
    --Autopilot command variables
    config.combat       = false
    config.assisting    = false
    config.assist       = ""
    config.weaponskill  = ""

    --Skillchain list by type.
    config.sc = {}
    config.sc.transfixion   = S{
    'ascetic\'s fury','evisceration','power slash','vorpal scythe','double thrust','thunder thrust','raiden thrust','vorpal thrust','skewer','drakesbane','sonic thrust','stardiver','blade: rin','blade: chi','blade: ku',
    'tachi: enpi','tachi: goten','omniscience','flaming arrow','piercing arrow','dulling arrow','sidewinder','blast arrow','empyreal arrow','refulgent arrow','apex arrow','hot shot','split shot','sniper shot','slug shot',
    'blast shot','detonator','leaden salute'}

    config.sc.compression   = S{
    'one inch punch','mandalic stab','keen edge','upheaval','nightmare scythe','insurgency','penta thrust','blade: ei','blade: kamu','tachi: kasha','tachi: ageha','tachi: shoha','black halo','cataclysm'}

    config.sc.liquefaction  = S{
    'spinning attack','asuran fists','stringing pummel','burning blade','red lotus blade','spinning axe','tachi: kagero','full swing','flaming arrow','dulling arrow','sniper shot'}

    config.sc.scission      = S{
    'wasp sting','viper bite','dancing edge','pyrric kleos','aeolian edge','exenterator','fast blade','shining blade','seraph blade','vorpal blade','savage blade','expiacion','requiescat','hard slash','crescent moon',
    'sickle moon','resolution','avalanche axe','spinning axe','rampage','calamity','bora axe','iron tempest','sturmwind','king\s justice','fell cleave','slice','nightmare scythe','spinning sctyhe','vorpal scythe',
    'sonic thrust','blade: retsu','blade: yu','tachi: enpi','tachi: jinpu','tachi: ageha','trueflight'}

    config.sc.reverberation = S{
    'combo','shijin spiral','shadow stitch','circle blade','atonement','shockwave','smash axe','decimation','primal rend','sturmwind','raging rush','dark harvest','shadow of death','spinning scythe','infernal scythe',
    'entropy','vorpal thrust','blade: teki','blade: yu','tachi: koki','tachi: gekko','brainshaker','skullbreaker','flash nova','starburst','sunburst','retribution','garland of bliss','cataclysm','piercing arrow',
    'refulgent arrow','hot shot','split shot','slug shot','last stand'}

    config.sc.detonation    = S{
    'backhand blow','gust slash','cyclone','dancing edge','aeolian edge','red lotus blade','freezebite','herculean slash','raging axe','gale axe','ruinator','steel cyclone','fell cleave','blade: to','blade: jin',
    'tachi: jinpu','tachi: yukikaze','true strike','shell crusher','sidewinder','slug shot','numbing shot'}

    config.sc.induration    = S{
    'tornado kick','frostbite','freezebite','herculean slash','smash axe','raging rush','shadow of death','guillotine','impulse drive','blade: to','tachi: hobaku','tachi: yuikikaze','tachi: rana','skullbreaker','flash nova',
    'shattersoul','blast arrow','blast shot','numbing shot'}

    config.sc.impaction     = S{
    'combo','shoulder tackle','raging fists','spinning attack','tornado kick','cyclone','aeolian edge','flat blade','circle blade','vorpal blade','sickle moon','herculean slash','raging axe','avalanche axe','spinning axe',
    'calamity','shield break','armor break','weapon break','thunder thrust','raiden thrust','leg sweep','skewer','blade: chi','blade: shun','tachi: goten','tachi: koki','shining strike','seraph strike','true strike',
    'realmrazer','heavy swing','rock crusher','earth crusher','full swing','numbing shot'}

    config.sc.gravitation   = S{
    'asuran fists','stringing pummel','evisceration','mercy stroke','swift blade','requiescat','catastrophe','entropy','impulse drive','stardiver','blade: ten','blade: ku','blade: hi','tachi: rana','retribution','omniscience',
    'shattersoul','leaden salute','wildfire'}

    config.sc.distorion     = S{
    'mordant rime','pyrric kleos','rudra\'s storm','death blossom','expiacion','chant du cygne','ground strike','torcleaver','ruinator','full break','cross reaper','quietus','geirskogul','tachi: gekko','tachi: fudo',
    'vidohunir','gate of tartarus','namas arrow'}

    config.sc.fusion        = S{
    'final heaven','ascetic\'s fury','shijin spiral','mandalic stab','knights of the round','atonement','scourge','mistral axe','decimation','metatron torment','upheaval','insurgency','wheeling thrust','drakesbane',
    'blade: shun','tachi: kasha','hexa strike','realmrazer','garland of bliss','arching arrow','empyreal arrow','jishnu\'s radiance','heavy shot','detonator','last stand'}

    config.sc.fragmentation = S{
    'dragon kick','victory smite','shark bite','mordant rime','exenterator','savage blade','death blossom','spinning slash','ground strike','resolution','dimidiation','cloudsplitter','king\'s justice','ukko\'s fury',
    'camlann\'s torment','blade: metsu','blade: kamu','tachi: kaiten','tachi: shoha','black halo','randgrith','exudation','vidohunir','apex arrow','cronach','trueflight'}

    config.sc.light         = S{
    'final heaven','victory smite','knights of the round','chant du cygne','scourge','torcleaver','dimidiation','metatron torment','ukko\'s fury','geirskogul','camlann\'s torment','tachi: kaiten','tachi: fudo',
    'randgrith','namas arrow','jishnu\'s radiance'}

    config.sc.dark          = S{
    'mercy stroke','rudra\'s storm','onslaught','cloudsplitter','catastrophe','quietus','blade: metsu','blade: hi','exudation','gate of tartarus','cronach','wildfire'}
    
end

return initialize