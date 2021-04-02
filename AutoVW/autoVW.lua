_addon.version = '3.14'
_addon.name = 'autovw'
_addon.author = 'F'
_addon.commands = {'autovw','vw'}

-- 12/21/2018 by Icy - Some modifications...
--[[--------------------------------------------------------

    This addon requires the Intercede and Dialog addons.
    
--]]--------------------------------------------------------


require('tables')
require('sets')
require('strings')
packets = require('packets')
require('luau')
-- 12/21/2018 by Icy - Added use of lor_utils 
require('lor/lor_utils')
_libs.lor.req('all')

autovw = false
pop = false
phase = 5 --1-5, false for none
rubicund = false

fight = false -- Set true if you want to proc initial_actions when VW starts
fighters = S{""}
ws = nil -- Set to nil if you don't want to auto-WS
-- Stuff that happens when mob pops
initial_actions = ''

debug = true

acting = false
spoils = false
popped = true
poptries = 0
boxtries = 0

windower.register_event('addon command',function (command,...)
	local args = T{...}
	local arg_str = windower.convert_auto_trans(' ':join(args))
	
	if S{"run","on","start"}:contains(command) then
		autovw = true
		-----------------------------------------
		-- 12/21/2018 by Icy
		-- Attempt to load the required addons
		windower.send_command("intercede")
		windower.send_command("dialog")
		-----------------------------------------
		windower.add_to_chat(200,'AutoVW:: On')
	elseif S{"stop","off","end"}:contains(command) then
		autovw = false
        acting = false
        windower.add_to_chat(200,'AutoVW:: Off')
    elseif S{"pop"}:contains(command) then
        if pop then pop = false windower.add_to_chat(200,'AutoVW::Pop Disabled')
        else pop = true acting = false windower.add_to_chat(200,'AutoVW::Pop Enabled') end
    elseif S{"fight"}:contains(command) then
        if fight then fight = false windower.add_to_chat(200,'AutoVW::Fight Disabled')
        else fight = true windower.add_to_chat(200,'AutoVW::Fight Enabled') end   
    elseif S{"box"}:contains(command) then
        open_box()
	elseif S{"ws"}:contains(command) then
	---------------------------------
	-- 12/21/2018 by Icy | added command to toggle auto wsing;
		ws = arg_str
		if ws == "" then 
			ws = nil
			windower.add_to_chat(200,'AutoVW::WS Disabled')
        else
			windower.add_to_chat(200,'AutoVW::WS = '..ws)
        end
	---------------------------------
	end
end)

windower.register_event('prerender',function ()
    if autovw then
        for i,v in pairs(windower.ffxi.get_mob_array()) do
            if v.valid_target and math.sqrt(v.distance)<6 then 
                if v.name=="Planar Rift" and acting ~= 'planar' then
                    debug('Planar Rift Found')
					popped = false
                    acting = 'planar'               
                    if rubicund then    
                        windower.send_command('wait 1;setkey f8 down; wait .2;setkey f8 up;int trade cell')
                        coroutine.sleep(1) 
                    end
                    if pop then
                        if type(phase)=='number' then
                            for i=1,phase do
                                windower.send_command('wait 1;int trade phase')
                                coroutine.sleep(1)
                            end
                        end
						pop_mob()
                    end
                    break
                elseif v.name=="Riftworn Pyxis" and acting ~= 'riftworn' then
                    debug('Riftworn Pyxis Found')
                    acting = 'riftworn'
                    coroutine.sleep(5)
                    open_box()
                    break
                end
            end
        end
    end
	coroutine.sleep(1)
end)

function pop_mob()
	windower.send_command('wait 1;int poke rift;wait 2;setkey escape down;wait .2;setkey escape up;')
	coroutine.sleep(10)
	
	if not popped and  poptries < 3 then
		windower.add_to_chat(200, "AutoVW::Didn't pop mob. Retrying")
		poptries = poptries + 1
		pop_mob()
	elseif poptries > 2 then
		windower.play_sound(''..windower.addon_path..'Error.wav')
		windower.add_to_chat(123, "AutoVW::Failed to pop three times!")
		coroutine.sleep(1)
		poptries = 0
	else
		coroutine.sleep(1)
		poptries = 0
    end
end
	
function open_box()
	windower.send_command('setkey f8 down; wait .2;setkey f8 up;wait 1;int poke chest;wait 2;setkey escape down;wait .2;setkey escape up;wait 1;setkey escape down;wait .2;setkey escape up;')
	coroutine.sleep(6)
	
	if not spoils and boxtries < 3 then
		windower.add_to_chat(200, "AutoVW::Didn't get chest. Retrying")
		boxtries = boxtries + 1
		open_box()
	elseif not spoils and boxtries > 2 then
		windower.play_sound(''..windower.addon_path..'Error.wav')
		windower.add_to_chat(123, "AutoVW::Failed to obtain spoils three times!")
		coroutine.sleep(1)
		boxtries = 0
	else
		coroutine.sleep(1)
		boxtries = 0
	end
end

windower.register_event('gain buff', function(id)
	if id == 475 then -- Voidwatcher status
		popped = true
        if autovw and fight and initial_actions then
            debug('Voidwatch Started')
			spoils = false
            windower.send_command(initial_actions)
        end
	end
end)

windower.register_event('tp change', function(new, old)
    if autovw and fight and ws and fighters:contains(windower.ffxi.get_player().name) and windower.ffxi.get_player().status== 1 then
        if new > 999 then
            windower.send_command('input /ws "'..ws..'" <t>')
        end 
	end
end)

windower.register_event('status change', function(newstatus, oldstatus)
    if autovw and fight and ws and fighters:contains(windower.ffxi.get_player().name) and newstatus == 1 then
        if windower.ffxi.get_player().tp > 999 then
            windower.send_command('input /ws "'..ws..'" <t>')
        end 
	end
end)

windower.register_event('incoming text', function(original, modified)
    if original:lower():contains("box") then
        open_box()
    elseif original:contains("You have obtained all spoils.") or original:contains("You are not eligible for spoils.") then
        spoils = true
    end
end)

function debug(msg)
    if debug then windower.add_to_chat(200,'AutoVW:: '..msg) end
end