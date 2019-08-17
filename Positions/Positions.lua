_addon.author = 'Jyouya'
_addon.command = 'pos'
_addon.name = 'Positions'
_addon.version = '1.0'

require('strings')
require('GUI')
config = require('config')

settings = config.load()

target = nil
target_mode = settings.target_mode or 'battle target' -- 'target' 'target of target' 'battle target'
tolerance = settings.tolerance or 0.2
distance = settings.distance or 20.5
prerender_id = nil
timeout_delay = settings.timeout or 5
timeout = nil

follow_target = nil
follow_target_id = nil
follow_distance = 1
follow_id = nil
nexttime = os.clock()
delay = .1
following = false

pos_x = nil -- Where we're running to
pos_y = nil

require('tables')
require('queues')

function goto_position()
	if os.clock() > timeout then stop() return end
	local me = windower.ffxi.get_mob_by_target('me')
	local dist =  math.sqrt((pos_x - me.x)^2 + (pos_y - me.y)^2)
	if dist > tolerance then -- too far
		if windower.ffxi.get_player().target_locked then 
			windower.send_command("input /lockon")
		end
		windower.ffxi.run(pos_x - me.x, pos_y - me.y)
	else
		stop()
	end
end

function stop()
	windower.ffxi.run(false)
	windower.unregister_event(prerender_id)
	prerender_id = nil
	windower.send_command('@wait 0.5;pos turn')
end

function follow()
	--local curtime = os.clock()
	--if nexttime + delay <= curtime and follow_target then
		nexttime = curtime
	--	delay = 0.1
		local me = windower.ffxi.get_mob_by_target('me')
		local t = windower.ffxi.get_mob_by_name(follow_target)
		if not t then return end
		
		if windower.ffxi.get_player().target_locked then 
			windower.send_command("input /lockon")
		end
		
		dTarget = math.sqrt(t.distance)
		
		if follow_distance < dTarget and math.abs(math.sqrt((t.x - me.x)^2 + (t.y - me.y)^2) - dTarget) < .01 then
			windower.ffxi.run(t.x - me.x, t.y - me.y)
		else
			windower.ffxi.run(false)
		end
	--end
end

function start_following()
	if prerender_id then -- cancel an active 'go' command
		stop()
	end
	
	if not follow_id then -- only register if we're not currently following something
		follow_id = windower.register_event('prerender',follow)
	end
	following = true
end

function stop_following()
	if follow_id then
		windower.ffxi.run(false)
		windower.unregister_event(follow_id)
		follow_id = nil
	end
	following = false
end

function HeadingTo(X,Y)
	local X = X - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).x
	local Y = Y - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).y
	local H = math.atan2(X,Y)
	return H - 1.5708
end

function get_target_position() -- returns the coords for 
	local t = (target and windower.ffxi.get_mob_by_name(target)) or nil
	--if not t then return end
	if target_mode == 'target' and t then
		return {x=t.x, y=t.y}
	elseif target_mode == 'target of target' and t then
		t = windower.ffxi.get_mob_by_index(windower.ffxi.get_mob_by_id(t.id).target_index)
		return {x=t.x, y=t.y}
	elseif target_mode == 'battle target' then
		t = windower.ffxi.get_mob_by_target('bt')
		if t then
			return {x=t.x, y=t.y}
		end
	end
end

windower.register_event('addon command', function(...)
	local args = T{...}
	local cmd = args[1]:lower()
	args:remove(1)
	if cmd == 'go' then -- Calculate where we want to go, and bind goto_position() to prerender as prerender_id
		if type(tonumber(args[1])) == 'number' then
			distance = tonumber(args[1])
		end
		if follow_id then
			stop_following() -- stop following
		end
		if prerender_id then -- if we're already performing go, stop that before starting a new one
			windower.unregister_event(prerender_id)
			windower.ffxi.run(false)
			prerender_id = nil
		end
		
		local me = windower.ffxi.get_mob_by_target('me')
		local t = get_target_position()
		if not t then return end -- don't continue if we have no target

		local D = math.sqrt((me.x - t.x)^2 + (me.y - t.y)^2)
		pos_x = (distance * (me.x - t.x) / D) + t.x
		pos_y = (distance * (me.y - t.y) / D) + t.y
	
		timeout = os.clock() + timeout_delay
	
		prerender_id = windower.register_event('prerender', goto_position)
	elseif cmd == 'target' or cmd == 't' then
		if args[1] then
			target = table.concat(args," ")
		end
		windower.add_to_chat(200, 'Current target is: %s':format(target))
	elseif cmd == 'targetmode' or cmd == 'tm' then
		if not args[1] then
		elseif args[1] == 'target' or args[1] == 't' then
			target_mode = 'target'
		elseif args[1] == 'targetoftarget' or args[1] == 'tt' then
			target_mode = 'target of target'
		elseif args[1] == 'battletarget' or args[1] == 'bt' then
			target_mode = 'battle target'
		else
			windower.add_to_chat(200, 'Invalid Argument')
		end
		windower.add_to_chat(200, 'Target mode is currently %s':format(target_mode))
	elseif cmd == 'distance' or cmd == 'dist' then
		if args[1] then
			distance = args[1]
		end
		windower.add_to_chat(200, 'Distance is currently %s':format(distance))
	elseif cmd == 'turn' then
		local t = get_target_position()
		windower.ffxi.turn(HeadingTo(t.x,t.y))
	elseif cmd == 'follow' then
		local cmd2 = args[1]
		if not cmd2 then -- no arguments //pos follow
			if follow_target then
				start_following()
				windower.add_to_chat(200, 'Now following %s':format(follow_target))
			else
				windower.add_to_chat(200, 'No follow target set')
			end
		elseif cmd2:lower():startswith('dist') then
			if tonumber(args[2]) then
				follow_distance = tonumber(args[2])
				windower.add_to_chat(200, 'Follow distance set to %d':format(follow_distance))
			else
				windower.add_to_chat(200, 'Follow distance remains at %d':format(follow_distance))
			end
		elseif cmd2:lower() == 'off' then
			stop_following()
		else
			follow_target = table.concat(args," ")
			windower.add_to_chat(200, 'Now following %s':format(follow_target))
			start_following()	
		end
	elseif cmd == 'save' then
		config.save(settings)
	elseif cmd == 'movegui' then -- move the GUI
		if args[2] then

			settings.x = tonumber(args[1])
			settings.y = tonumber(args[2])
		end
	end
end)

function update()
	if following then
		start_following()
	else
		stop_following()
	end
end

function build_UI()
	POS_GUI = {}
	POS_GUI.follow_target = PassiveText({
		x = settings.x + 0,
		y = settings.y + 0,
		text = 'Following:',
		align = 'left'}
	)
	POS_GUI.follow_target:draw()
	POS_GUI.follow_target2 = PassiveText({
		x = settings.x + 162,
		y = settings.y + 0,
		align = 'right'},
		'follow_target'
	)
	POS_GUI.follow_target2:draw()
	
	POS_GUI.button = ToggleButton{
		x = settings.x + 166,
		y =	settings.y + 0,
		var = 'following',
		iconUp = 'Follow Off.png',
		iconDown = 'Follow On.png',
		command = update
	}
	POS_GUI.button:draw()
	
	POS_GUI.follow_distance = PassiveText({
		x = settings.x + 0,
		y = settings.y + 16,
		text = 'Follow Distance:',
		align = 'left'}
	)
	POS_GUI.follow_distance:draw()
	POS_GUI.follow_distance2 = PassiveText({
		x = settings.x + 162,
		y = settings.y + 16,
		align = 'right'},
		'follow_distance'
	)
	POS_GUI.follow_distance2:draw()
	
	POS_GUI.pos_mode = PassiveText({
		x = settings.x + 0,
		y = settings.y + 46,
		text = 'Position Mode:',
		align = 'left'}
		--'target_mode'
	)
	POS_GUI.pos_mode:draw()
	POS_GUI.pos_mode2 = PassiveText({
		x = settings.x + 208,
		y = settings.y + 46,
		--text = '%s',
		align = 'right'},
		'target_mode'
	)
	POS_GUI.pos_mode2:draw()
	
	POS_GUI.pos_target = PassiveText({
		x = settings.x + 0,
		y = settings.y + 62,
		text = 'Position Target:',
		align = 'left'}
		--'target_mode'
	)
	POS_GUI.pos_target:draw()
	POS_GUI.pos_target2 = PassiveText({
		x = settings.x + 208,
		y = settings.y + 62,
		--text = '%s',
		align = 'right'},
		'target'
	)
	POS_GUI.pos_target2:draw()
	
	POS_GUI.pos_dist = PassiveText({
		x = settings.x + 0,
		y = settings.y + 78,
		text = 'Position Distance:',
		align = 'left'}
		--'target_mode'
	)
	POS_GUI.pos_dist:draw()
	POS_GUI.pos_dist = PassiveText({
		x = settings.x + 208,
		y = settings.y + 78,
		--text = '%s',
		align = 'right'},
		'distance'
	)
	POS_GUI.pos_dist:draw()
end

build_UI()