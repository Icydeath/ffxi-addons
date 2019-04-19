require('chat')
require('logger')
require('tables')
config = require('config')
res = require('resources')
packets = require('packets')

_addon.name = 'lazy'
_addon.author = 'Brax'
_addon.version = '0.5'
_addon.commands = {'lazy'}

Start_Engine = true
isCasting = false
isBusy = 0
buffactive = {}
Action_Delay = 2

buffactive = {}

defaults = {}
defaults.spell = ""
defaults.spell_active = false
defaults.weaponskill = ""
defaults.weaponskill_active = false
defaults.autotarget = false
defaults.target = ""

settings = config.load(defaults)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
			if action_message["Target 1 Action 1 Message"] == 0 then
				isCasting = false
				isBusy = Action_Delay
			end
		end
	end
end)

windower.register_event('outgoing chunk', function(id, data)
    if id == 0x015 then
        local action_message = packets.parse('outgoing', data)
		PlayerH = action_message["Rotation"]
	end
end)

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	if args[1] == nil or args[1] == "help" then
		print("Help Info")
	elseif args[1] == "start" then
		windower.add_to_chat(2,"....Starting Lazy Helper....")
		Start_Engine = true
		Engine()
	elseif args[1] == "stop" then
		windower.add_to_chat(2,"....Stopping Lazy Helper....")
		Start_Engine = false
	elseif args[1] == "reload" then
		windower.add_to_chat(2,"....Reloading Config....")
		config.reload(settings)
	elseif args[1] == "save" then
		config.save(settings,windower.ffxi.get_player().name)
	elseif args[1] == "test" then
		test()
	elseif args[1] == "show" then
		windower.add_to_chat(11,"Autotarget: "..tostring(settings.autotarget))
		windower.add_to_chat(11,"Spell: "..settings.spell)
		windower.add_to_chat(11,"Use Spell "..tostring(settings.spell_active))
		windower.add_to_chat(11,"Weaponskill: "..settings.weaponskill)
		windower.add_to_chat(11,"Use Weaponskill: "..tostring(settings.weaponskill_active))
		windower.add_to_chat(11,"Target:"..settings.target)
	elseif args[1] == "autotarget" then
		if args[2] == "on" then
			settings.autotarget = true
			windower.add_to_chat(3,"Autotarget: True")
		else
			settings.autotarget = false
			windower.add_to_chat(3,"Autotarget: False")
		end
	elseif args[1] == "target" then
		settings.target = args[2]
	end
end)

function HeadingTo(X,Y)
	local X = X - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).x
	local Y = Y - windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id).y
	local H = math.atan2(X,Y)
	return H - 1.5708
end

function TurnToTarget()
	local destX = windower.ffxi.get_mob_by_target('t').x
	local destY = windower.ffxi.get_mob_by_target('t').y
	local direction = math.abs(PlayerH - math.deg(HeadingTo(destX,destY)))
	if direction > 10 then
		windower.ffxi.turn(HeadingTo(destX,destY))
	end
end

function Find_Nearest_Target(target)
	local id_targ = -1
	local dist_targ = -1
	local marray = windower.ffxi.get_mob_array()
	for key,mob in pairs(marray) do
		if string.lower(mob["name"]) == string.lower(target) and mob["valid_target"] and mob["hpp"] == 100 then
			if dist_targ == -1 then
				id_targ = key
				dist_targ = math.sqrt(mob["distance"])
			elseif math.sqrt(mob["distance"]) < dist_targ then
				id_targ = key
				dist_targ = math.sqrt(mob["distance"])
			end
		end
	end
	return(id_targ)
end

function Check_Distance()
	local distance = windower.ffxi.get_mob_by_target('t').distance:sqrt()
	if distance > 3 then
		TurnToTarget()
		windower.ffxi.run()
	else
		windower.ffxi.run(false)
	end
end

function test()
end

function Engine()
	Buffs = windower.ffxi.get_player()["buffs"]
    table.reassign(buffactive,convert_buff_list(Buffs))
	
	if isBusy < 1 then
		Combat()
	else
		isBusy = isBusy -1
	end
	if Start_Engine then
		coroutine.schedule(Engine,1)
	end
end

function Combat()
	-- is Engaged / combat
	if windower.ffxi.get_player().status == 1 then
		TurnToTarget()
		Check_Distance()
		if windower.ffxi.get_player().vitals.tp >1000 and settings.weaponskill_active == true and windower.ffxi.get_mob_by_target('t').distance:sqrt() < 3.0 then
			windower.send_command(settings.weaponskill)
			isBusy = Action_Delay
		elseif Can_Cast_Spell(settings.spell) and settings.spell_active == true then
			Cast_Spell(settings.spell)
		end
	elseif settings.autotarget == true then
		if Find_Nearest_Target(settings.target) > 0 then
			windower.ffxi.follow(Find_Nearest_Target(settings.target))
			if math.sqrt(windower.ffxi.get_mob_by_index(Find_Nearest_Target(settings.target)).distance) < 3 then
				windower.send_command("input /targetbnpc")
				windower.send_command("input /attack on")
			end
		end
	end
end

function Can_Cast_Spell(spell)
	local result = false
	local myspell = res.spells:with('name',spell)
	Recasts = windower.ffxi.get_spell_recasts()
	if (Recasts[myspell.id] == 0) and (not isCasting) and (windower.ffxi.get_player().vitals.mp >= myspell.mp_cost) and (isBusy == 0) then
		result = true
	end
	return result
end

function Can_Cast_Ability(ability)
	local result = false
	local myability = res.job_abilities:with('name',ability)
	Recasts = windower.ffxi.get_ability_recasts()
	print("Checking:"..myability.name)
	if (Recasts[myability.recast_id] == 0) and (not isCasting) and (isBusy == 0) then
		result = true
	end
	return result
end

function Cast_Spell(spell)
	Recasts = windower.ffxi.get_spell_recasts()
	local myspell = res.spells:with('name',spell)
	if Recasts[myspell.id] == 0 and not isCasting then
		windower.send_command(myspell.name)
		isBusy = Action_Delay
	end
end

function Cast_Ability(ability)
	Recasts = windower.ffxi.get_ability_recasts()
	local myability = res.job_abilities:with('name',ability)
	if Recasts[myability.recast_id] == 0 and not isCasting then
		windower.send_command(myability.name)
		isBusy = Action_Delay
	end
end


function convert_buff_list(bufflist)
    local buffarr = {}
    for i,v in pairs(bufflist) do
        if res.buffs[v] then -- For some reason we always have buff 255 active, which doesn't have an entry.
            local buff = res.buffs[v].english
            if buffarr[buff] then
                buffarr[buff] = buffarr[buff] +1
            else
                buffarr[buff] = 1
            end
            
            if buffarr[v] then
                buffarr[v] = buffarr[v] +1
            else
                buffarr[v] = 1
            end
        end
    end
    return buffarr
end
