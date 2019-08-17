_addon.name = 'JRoller'
_addon.version = '2'
_addon.author = 'Jyouya'
_addon.commands = {'roller'}

require('queues')
require('tables')
require('sets')
require('Modes')
require('GUI')
res = require('resources')
config = require('config')

actions = T(require('Actions'))
shortcuts = T(require('FuzzyNames'))

defaults = {
	x=1200,
	y=800,
	roll1='Chaos Roll',
	roll2='Samurai Roll',
	language='en',
}
settings = config.load(defaults)

enabled = false
rollQ = Q{}
pending = false
timeout = nil
global_cooldown = 0
roll_window = nil
asleep = false

active_rolls = {0,0}
rolls = {
	M{['description']='Roll 1',
	'Warlock\'s Roll',
	'Fighter\'s Roll',
	'Monk\'s Roll',
	'Healer\'s Roll',
	'Wizard\'s Roll',
	'Rogue\'s Roll',
	'Gallant\'s Roll',
	'Chaos Roll',
	'Beast Roll',
	'Choral Roll',
	'Hunter\'s Roll',
	'Samurai Roll',
	'Ninja Roll',
	'Drachen Roll',
	'Magus\'s Roll',
	'Corsair\'s Roll',
	'Puppet Roll',
	'Dancer\'s Roll',
	'Scholar\'s Roll',
	'Bolter\'s Roll',
	'Courser\'s Roll',
	'Blitzer\'s Roll',
	'Tactician\'s Roll',
	'Allies\' Roll',
	'Miser\'s Roll',
	'Companion\'s Roll',
	'Avenger\'s Roll',
	'Naturalist\'s Roll',
	'Runeist\'s Roll'
	},
	M{['description']='Roll 2',
	'Warlock\'s Roll',
	'Fighter\'s Roll',
	'Monk\'s Roll',
	'Healer\'s Roll',
	'Wizard\'s Roll',
	'Rogue\'s Roll',
	'Gallant\'s Roll',
	'Chaos Roll',
	'Beast Roll',
	'Choral Roll',
	'Hunter\'s Roll',
	'Samurai Roll',
	'Ninja Roll',
	'Drachen Roll',
	'Magus\'s Roll',
	'Corsair\'s Roll',
	'Puppet Roll',
	'Dancer\'s Roll',
	'Scholar\'s Roll',
	'Bolter\'s Roll',
	'Courser\'s Roll',
	'Blitzer\'s Roll',
	'Tactician\'s Roll',
	'Allies\' Roll',
	'Miser\'s Roll',
	'Companion\'s Roll',
	'Avenger\'s Roll',
	'Naturalist\'s Roll',
	'Runeist\'s Roll'
	},
}

-- Set defaults
rolls[1]:set(settings.roll1)
rolls[2]:set(settings.roll2)

function build_GUI()

	roll1label = PassiveText{
		x = settings.x,
		y = settings.y + 2 + 52,
		text = 'Roll 1:'
	}
	roll1label:draw()
	
	roll2label = PassiveText{
		x = settings.x,
		y = settings.y + 2 + 84,
		text = 'Roll 2:'
	}
	roll2label:draw()
	
	statuslabel = PassiveText{
		x = settings.x + 54,
		y = settings.y,
		text = 'Status:'
	}
	statuslabel:draw()
	statusdisplay = PassiveText({
		x = settings.x + 208,
		y = settings.y,
		text = '%s',
		align = 'right'},
		function()
			if asleep then
				return 'Sleeping'
			elseif rollQ:peek() then
				return rollQ:peek().en
			else
				return 'Idle'
			end
		end
	)
	statusdisplay:draw()
	
	roll2combo = Combobox{
		x = settings.x + 68,
		y = settings.y + 84,
		size = 10,
		var = rolls[2],
		width = 140
	}
	roll2combo:draw()
	
	roll1combo = Combobox{
		x = settings.x + 68,
		y = settings.y + 52,
		size = 10,
		var = rolls[1],
		width = 140
	}
	roll1combo:draw()
	
	enablebutton = ToggleButton{
		x = settings.x,
		y = settings.y,
		var = 'enabled',
		iconUp = 'Off.png',
		iconDown = 'On.png',
		command = wake_up
	}
	enablebutton:draw()
end

current_roll = ''

ignore_ids = T{177,178,96,133}

windower.register_event('action', function(act)
	if act.category == 6 then
		if table.with(actions, 'param', act.param) then -- only execute on rolling related actions
			local player = windower.ffxi.get_player()
			if act.actor_id == player.id then
				if pending and act.param == rollQ:peek().param then
					action_complete()
				elseif not rollQ:empty() then -- if we didn't do the action, empty the queue and restrategize
					--print('Clearing Queue Action Event')
					rollQ = Q{}
					roll_strategy()
				end
				-- ignore abilities that don't modify our roll values
				if ignore_ids:contains(act.param) then
					return
				end
				rollNum = act.targets[1].actions[1].param
				if rollNum == 12 then -- Bust
					--print('Bust')
					finish_roll()
					rollQ = Q{}
					roll_strategy()
				end
			end
		end
	end
end)

function action_complete()
	local act = rollQ:pop()
	pending = false
	timeout = nil
	global_cooldown = os.time()
	if act.on_completion then
		act.on_completion(act)
	end
end

function action_timeout()
	--print('Clearing Queue timeout on '..rollQ:peek().en)
	rollQ = Q{}
	roll_strategy()
	pending = false
	timeout = nil
end

function finish_roll()
	roll_window = nil
end

function roll_strategy() -- Qeues actions, or can close the current roll by setting roll_window to nil
	recasts = windower.ffxi.get_ability_recasts()
	-- if we have a roll going, figure out what to do with it
	if roll_window then
		if rollNum == 11 or rollNum == actions[current_roll].lucky then
			roll_window = nil
			return
		end
		if not snakeeye() then
			if not doubleup() then
				-- close the window if our roll is done
				finish_roll()
			end
		end
	else
		--print('do newroll')
		do_newroll()
	end
end

function do_next()
	-- if next action is off cd, then do it
	local cd = windower.ffxi.get_ability_recasts()[rollQ:peek().id]
	if cd == 0 then
		windower.chat.input('/ja "%s" <me>':format(rollQ:peek()[settings.language]))
		pending = true
		timeout = os.time()
	elseif roll_window and os.time() + cd > roll_window then
	-- if something happens and we can't do what we want, re-evaluate
		--print('Clearing Queue do_next')
		rollQ = Q{}
		roll_strategy()
	elseif not roll_window and cd > 10 then-- prevent things getting stuck in queue
		rollQ = Q{}
		roll_strategy()
	end
end

function new_roll(act) -- called when we do a new roll
	roll_window = os.time() + 45
	-- Push off the oldest roll, track the time the current and previous rolls were rolled
	active_rolls[2] = active_rolls[1]
	active_rolls[1] = os.time()
	actions:doubleup(act.en) -- set double-up's param value to the current roll
	current_roll = act.en
end

for k, v in pairs(actions) do
	if k:contains(' Roll') then
		v.on_completion = new_roll
	end
end

function snakeeye()
	local current = actions[current_roll]
	if	(rollNum == (current.lucky - 1)) or  -- lucky - 1
		(rollNum == 10) or -- 10
		(rollNum == 9 and (current.unlucky ~= 10)) or -- 9 and 10 isn't unlucky
		(rollNum == current.unlucky and (current.unlucky >= 8)) or
		(rollNum == 8 and ((os.time() - active_rolls[2]) <= 270) and current.unlucky ~= 9 and recasts[198] < 30)
	then
		if recasts[197] < (roll_window - os.time() - 5) then -- snake eye is coming up in our double up window
			--print('Snake Eye on '..rollNum)
			rollQ:push(actions['Snake Eye'])
			rollQ:push(actions['Double-Up'])
			return true
		elseif recasts[196] == 0 then
			rollQ:push(actions['Random Deal'])
			return true
		else -- we want to snake eye, but we can't
			return false
		end
	end
	return false
end

function doubleup()
	local current = actions[current_roll]
	if	(rollNum == current.unlucky) or
		(rollNum < 8) or
		(rollNum == 8 and current.unlucky < 8) or
		(rollNum == 8 and (recasts[197] < (roll_window - os.time() - 5)))
	then
		--print('Doubling up on '..rollNum)
		rollQ:push(actions['Double-Up'])
		return true
	end
end

function do_newroll()
	if Cities:contains(res.zones[windower.ffxi.get_info().zone].english) then return end
	if not enabled or haveBuff('amnesia') or haveBuff('impairment') then return end
	local status = windower.ffxi.get_player().status
	if not (status <= 1) then return end
	if haveBuff('Sneak') or haveBuff('Invisible') then return end
	if haveBuff('Bust') then
		--print('have bust fold recast: '..recasts[198])
		if recasts[198] == 0 then
			rollQ:push(actions['Fold'])
			return
		elseif recasts[196] < 30 then
			rollQ:push(actions['Random Deal'])
			return
		end
	end
	if recasts[193] > 10 then
		sleep()
		return
	end	
	if not haveBuff(rolls[1].value) then
		if recasts[96] < 30 then
			rollQ:push(actions['Crooked Cards'])
		end
		rollQ:push(actions[rolls[1].value])
	elseif not (haveBuff(rolls[2].value) or haveBuff('Bust')) then
		rollQ:push(actions[rolls[2].value])
	else
		sleep()
	end
end

function set_roll(slot, text)
	local name = (function(text)
		for k, v in pairs(shortcuts) do
			for _, j in ipairs(v) do
				if text:startswith(j) then
					return k
				end
			end
		end
	end)(text:lower())
	if name then
		-- If the new roll is already set in the other slot, swap them
		if rolls[slot%2 + 1].value == name then
			rolls[slot%2 + 1]:set(rolls[slot].value)
			_G['roll'..(slot%2+1)..'combo']:update()
		end
		windower.add_to_chat(200, 'Roll %i set to %s':format(slot, name))
		rolls[slot]:set(name)
		_G['roll'..slot..'combo']:update()
		wake_up()
	end
end

function sleep()
	--print('sleeping')
	windower.unregister_event(prerender)
	asleep = true
	last_active = os.time()
	windower.send_command('@wait 10;roller wake')
end

function wake_up(...)
	--print('waking up')
	if asleep then
		prerender = windower.register_event('prerender', main_loop)
		asleep = false
	end
end

function main_loop()
	if not enabled then
		sleep()
		return
	end
	local now = os.time()
	
	-- don't do actions too close together to give the server time to respond
	if now - global_cooldown < 1 then
		return
	end
	
	-- if our pending action has been pending for too long
	if pending and now - timeout > 5 then
		action_timeout()
	end
	
	-- If we have run out of time on the current roll
	if roll_window and roll_window < os.time() then
		--print('Clearing Queue Prerender')
		rollQ = Q{}
		pending = false
		finish_roll()
	end
	
	-- nothing queued, 
	if rollQ:empty() then
		--print('Queue Empty')
		roll_strategy()
	-- things queued, but nothing pending
	elseif not pending then
		do_next()
	end
end

windower.register_event('addon command', function(...)
	args = T{...}
	if #args == 0 then
		return
	end
	cmd = args:remove(1)
	if cmd == 'wake' then
		if os.time() >= last_active + 10 then
			wake_up()
		end
	elseif table.contains({'start', 'go', 'on', 'enable'}, cmd:lower()) then
		wake_up()
		enabled = true
		rollQ = Q{}
	elseif table.contains({'stop', 'quit', 'off', 'disable'}, cmd:lower()) then
		enabled = false
	elseif cmd:lower() == 'roll1' then
		if #args > 0 then
			set_roll(1, table.concat(args, ' '))
		else
			windower.add_to_chat(200, 'Roll 1: '..rolls[1].value)
		end
	elseif cmd:lower() == 'roll2' then
		if #args > 0 then
			set_roll(2, table.concat(args, ' '))
		else
			windower.add_to_chat(200, 'Roll 2: '..rolls[2].value)
		end
	end
end)

windower.register_event('lose buff', wake_up)

windower.register_event('zone change', function()
	enabled = false
	sleep()
end)


-- Wrapper to make code more readable
function _libs.queues.peek(q)
	return q[1]
end

function haveBuff(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				return true
			end
		end
	end
	return false
end

Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
	"Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
	"The Colosseum",
    "Tavanazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
	"Rabao",
    "Norg",
    "Kazham",
    "Eastern Adoulin",
    "Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia"
}

function translate()
	for k, v in pairs(actions) do
		if type(v) ~= 'function' then
			v.ja = table.with(res.job_abilities,'en',k).ja
		end
	end
end

translate()

build_GUI()

prerender = windower.register_event('prerender', main_loop)