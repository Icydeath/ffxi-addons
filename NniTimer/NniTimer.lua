--[[ Addon is based off ZoneTimer
 1.0.0.3
	> added another logic case for catching effects applied on jumps.
	
 1.0.0.2
	> Cleaned up text layout.
	> White base text, turns green when floor is completed.
	> Now shows + and - effects received.
	
 1.0.0.1
 	> 18, 38, 58, 78, 98 changes the text to yellow to indicate a boss floor is close
 	> 19, 39, 59, 79, 99 changes the text to orange to indicate a boss floor is next	
]]
_addon.name = 'NniTimer'
_addon.author = 'Icy'
_addon.version = '1.0.0.3'
_addon.command = 'nnitimer'

require('logger')
config = require('config')
texts = require('texts')
 
defaults = {}
defaults.show_effects_received = true
defaults.unload_zonetimer = false

defaults.pos = {}
defaults.pos.x = 600
defaults.pos.y = 0

defaults.bg = {}
defaults.bg.alpha = 165

defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.red = 255
defaults.text.blue = 255
defaults.text.green = 255
defaults.text.size = 12
 
settings = config.load(defaults)
times = texts.new(settings)
start_time = os.time()
floorNum = 0
objective = ""
secObjective = ""
status = ""
pEffect = ""
nEffect = ""

windower.register_event('zone change', function(new_zone, old_zone)
	start_time = os.time()
	start_time = start_time - 20 -- adding 20 sec buffer due to zone animation.
	
	if new_zone == 77 then -- 77 = Nyzul Isle
		if settings.unload_zonetimer then
			windower.send_command("lua u zonetimer")
		end
		
		status = ""
		secObjective = ""
		objective = ""
		
		times:show()
	else
		times:hide()
	end
end)

windower.register_event('prerender', function()
    local info = windower.ffxi.get_info()
    if not info.logged_in then
        times:hide()
        return
    end
	
	seconds = os.time() - start_time
	times:text(" "..os.date('!%H:%M:%S', seconds).." • Floor "..floorNum.." • "..pEffect.." | "..nEffect.." • "..objective.." • "..secObjective.."  "..status)
	--times:text(display)
end)

windower.register_event('addon command', function(...)
	local param = L{...}
	local command = param[1]
	if command == 'help' then
		log("'nnitimer fontsize #' to change the font size" )
		log("'nnitimer posX #' to change the x position")
		log("'nnitimer posY #' to change the y position")
		log("'nnitimer show' shows the timer/info.")
		log("'nnitimer hide' hides the timer/info.")
		log("'nnitimer zonetimer' auto unloads the zonetimer addon when entering nyzul.")
		
	elseif command == 'fontsize' or command == 'posX' or command == 'posY' then
		
		if command == 'fontsize' then
			settings.text.size = param[2]
		elseif command == 'posX' then
			settings.pos.x = param[2]
		elseif command == 'posY' then
			settings.pos.y = param[2]
		end

		config.save(settings, 'all')
		times:visible(false)
		times = texts.new(settings)
		
	elseif command == 'print' then
		print(start_time .. " " .. os.time())
		
	elseif command == 'test' then
		start_time = start_time - 60
		times:show()
		
	elseif command == 'reset' then
		start_time = os.time()
	
	elseif command == 'hide' then
		times:hide()
		
	elseif command == 'show' then
		times:show()
	
	elseif command == 'zonetimer' then
		settings.unload_zonetimer = true
		config.save(settings, 'all')
		
	end
end)

windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
	if(windower.wc_match(original, "*Time limit has been reduced by 1 minute.*")) then
		start_time = start_time - 60
		
	elseif(windower.wc_match(original, "*Welcome to Floor*")) then
		split_original = original:split(' ')
		floorNum = split_original[table.getn(split_original)]:split('.')[1]
		status = ""
		secObjective = ""
		pEffect = ""
		nEffect = ""
		
		local fnum = tonumber(floorNum)
		if fnum then
			if fnum == 18 or fnum == 38 or fnum == 58 or fnum == 78 or fnum == 98 then
				times:color(255, 239, 0)
			elseif fnum == 19 or fnum == 39 or fnum == 59 or fnum == 79 or fnum == 99 then
				times:color(255, 165, 0)
			else
				times:color(255, 255, 255)
			end
		else
			times:color(255, 255, 255)
		end
		
	elseif(windower.wc_match(original, "*Objective:*")) then
		--objective = original:split(':')[2]
		if(windower.wc_match(original, "*Eliminate enemy leader.*")) then
			objective = "® Enemy leader ®"
		elseif(windower.wc_match(original, "*Eliminate all enemies.*")) then
			objective = "∞ All enemies ∞"
		elseif(windower.wc_match(original, "*Eliminate specified enemy.*")) then
			objective = "(1) Specified enemy (1)"
		elseif(windower.wc_match(original, "*Eliminate specified enemies.*")) then
			objective = "♀ Family ♀"
		elseif(windower.wc_match(original, "*Activate all lamps.*")) then
			objective = "☼ Lamps ☼"
		elseif(windower.wc_match(original, "*Rune of Transfer activated.*")) then
			objective = "☺☺☺ Free floor ☺☺☺"
		end
		
	elseif(windower.wc_match(original, "*Rune of Transfer activated.*")) then
		status = " √ COMPLETE √ "
		local fnum = tonumber(floorNum)
		if fnum then
			if fnum ~= 18 and fnum ~= 38 and fnum ~= 58 and fnum ~= 78 and fnum ~= 98 
			  and fnum ~= 19 and fnum ~= 39 and fnum ~= 59 and fnum ~= 79 and fnum ~= 99 then
				times:color(0, 255, 0)
			end
		else
			times:color(0, 255, 0)
		end
		
	elseif (windower.wc_match(original, "*Avoid discovery by archaic gears!*")) then
		secObjective = "GEARS » Avoid discovery‼"
		
	elseif (windower.wc_match(original, "*Do not destroy archaic gears!*")) then
		secObjective = "GEARS » Don't destroy‼"

	elseif (windower.wc_match(original, "*activated at the same time.*")) and (not windower.wc_match(objective, "*SAME TIME.*")) then
		objective = objective .. " » SAME TIME."
		
	elseif (windower.wc_match(original, "*activated in a specific order...*")) and (not windower.wc_match(objective, "*ORDER.*")) then
		objective = objective .. " » ORDER."
	
	elseif (windower.wc_match(original, "*code has been registered.*")) and (not windower.wc_match(objective, "*CODE.*")) then
		objective = objective .. " » CODE."
	
	-- positive effects
	elseif settings.show_effects_received and (windower.wc_match(original, "*Received *")) then
		split_original = original:split(' ')
		if pEffect ~= "" then
			pEffect = pEffect..", +"..split_original[2]:split('.')[1]
		else
			pEffect = "+"..split_original[2]:split('.')[1]
		end
		
	-- negative effects
	elseif settings.show_effects_received and (windower.wc_match(original, "*Afflicted by *")) then
		split_original = original:split('by')
		if nEffect ~= "" then
			nEffect = nEffect..", -"..split_original[2]:split('.')[1]
		else
			nEffect = "-"..split_original[2]:split('.')[1]
		end
	
	elseif settings.show_effects_received and (windower.wc_match(original, "*is restricted.*")) then
		split_original = original:split('is')
		if nEffect ~= "" then
			nEffect = nEffect..", -"..split_original[1]:gsub('y', '', 1)
		else
			nEffect = "-"..split_original[1]:gsub('y', '', 1)
		end
	
	elseif settings.show_effects_received and (windower.wc_match(original, "*are restricted.*")) then
		split_original = original:split('are')
		if nEffect ~= "" then
			nEffect = nEffect..", -"..split_original[1]:gsub('y', '', 1)
		else
			nEffect = "-"..split_original[1]:gsub('y', '', 1)
		end
	
	-- syncs up the time based off msgs received from the instance.
	elseif (windower.wc_match(original, "*Time Remaining: 1 minute (Earth time).*")) then -- 1 min warning: 1740
		start_time = os.time() - 1740
	
	elseif (windower.wc_match(original, "*Time Remaining: 3 minutes (Earth time).*")) then -- 3 min warning: 1620
		start_time = os.time() - 1620
		
	elseif (windower.wc_match(original, "*Time Remaining: 5 minutes (Earth time).*")) then -- 5 min warning: 1500
		start_time = os.time() - 1500
		
	elseif (windower.wc_match(original, "*Time Remaining: 10 minutes (Earth time).*")) then -- 10 min warning: 1200
		start_time = os.time() - 1200
		
	end
end)