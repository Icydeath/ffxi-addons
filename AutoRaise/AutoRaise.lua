--[[
AutoRaise version 0.1
@Shoopi#3557 
------------------------------------------------------------------------------
AutoRaise - Auto raise KO party members
 
This add on causes one party member to monitor the party for KO and will
automatically raise them. A secondary function allows for a support 
job to monitor the primary raiser, in case they get KO.
 
-- Setup: -------------------------
    1. Extract all files to /addons/autoraise/
    2. Run //lua load autoraise
        //ar start   -- on primary raiser
        //ar support -- on secondary raiser
    3.  To stop, just /heal or //lua unload autoraise
 
------------------------------------------------------------------------------
 
]]
_addon.name = 'AutoRaise'
_addon.author = 'Shoopi'
_addon.version = '0.1'
_addon.commands = {'ar','autoraise'}
 
require('logger')
 
-- Configs:------------------------
local check_delay = 5 -- time between KO checks
local raise_delay = 10 -- time to cast raise and delay before resuming
local silentmode = false -- Will silence intro or status messages
local sound_alert = false; -- plays a ping sound when a dead member is detected
local healer = 'Saerae' -- Name of primary raiser, who the support member will monitor.
-----------------------------------
 
function triage()
    local player = windower.ffxi.get_player()
    if player.status == 3 then 
        notice('Resting detected: Aborting')
        return true;
    end
    if not player then return end
    local party = windower.ffxi.get_party()
    if party.party1_count == 1 then
        notice('No party members detected. Aborting.')
    else
        for i = 1,party.party1_count-1 do
            member = windower.ffxi.get_mob_by_name(party['p'..i].name)                      
             if member and member.status == 2 then
                if not silentmode then warning(member.name .. ' is dead. Attempting to raise.') end 
                if (sound_alert) then windower.play_sound(windower.addon_path..'sounds/iseedeadpeople.wav') end
                windower.chat.input('/ma Arise ' .. member.name)
                coroutine.sleep(raise_delay)
            end
        end
        coroutine.sleep(check_delay)
        triage()
        return false
    end
end
function triage_healer()
    local player = windower.ffxi.get_player()
    if player.status == 3 then 
        notice('Resting detected: Aborting')
        return true;
    end
    if not player then return end
    member = windower.ffxi.get_mob_by_name(healer)
    if member.status == 2 and not raise_target then
        warning(member.name .. ' is dead. Attempting to raise.')
        if (sound_alert) then windower.play_sound(windower.addon_path..'sounds/iseedeadpeople.wav') end
        windower.chat.input('/ma Arise ' .. member.name)
        coroutine.sleep(raise_delay)
    end
    coroutine.sleep(check_delay)
    triage_healer()
    return false
end
 
windower.register_event('addon command', function(...)
    local args = {...}
    local cmd = args[1]:lower()
    if cmd == "start" or cmd == "on" then 
        if (not silentmode) then notice('Active') end
        triage()
    elseif cmd == "support" then
        if (not silentmode) then notice('Support Mode Active') end
        triage_healer()
    end
end)