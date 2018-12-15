_addon.name = 'AssistMe'
_addon.version = '4.20.69'
_addon.author = 'DarkKeevon'
_addon.command = 'ass'
 
require 'tables'
require 'strings'
require 'actions'
packets = require('packets')

windower.register_event('load',function ()
    assist_target = "Icydeath"
	assist_target2 = "Rythor"
    current_target = 0
    print("Current assist target: "..assist_target)
	print("Alternate assist target: "..assist_target2)
    windower.send_command("input /autotarget off")
end)

windower.register_event('addon command', function(command, ...)
    local args = T{...}

    if command:contains('switch') then
        for i,v in pairs(windower.ffxi.get_party()) do
            if type(v) == 'table' then
                if tostring(args[1]):lower() == v.name:lower() then
                    windower.send_command("input /p New Assist = "..v.name)
                    windower.send_command("ass "..v.name)
                end
            end
        end
    elseif windower.ffxi.get_mob_by_name(command) and windower.ffxi.get_mob_by_name(command).in_alliance then
        assist_target = command
        print("Current assist target: "..assist_target)
    end
end)

windower.register_event('chat message', function(message, player, mode, is_gm)
    if player == "Enuri" and message:contains('New Assist = ') then
        for i,v in pairs(windower.ffxi.get_party()) do
            if type(v) == 'table' then
                if message:contains("= "..v.name) then
                    windower.send_command("ass "..v.name)
                end
            end
        end
    end
end)

windower.register_event('outgoing chunk',function(id,original,modified,is_injected,is_blocked)
    if id == 0x015 then
        local player = windower.ffxi.get_player()
        local assist = windower.ffxi.get_mob_by_name(assist_target)
        local target = windower.ffxi.get_mob_by_id(current_target)

        if not player or not assist or not target then return end

        if not target.valid_target or target.hpp == 0 then
            current_target = 0
        end

        if player.status == 0 or (player.status == 1 and target.id ~= current_target) then
            if player.name ~= assist_target and can_engage() and target.distance:sqrt() < 30 and assist.status == 1 then
                engage(current_target)
            end
        end
    end
end)

windower.register_event('action',function (act)
    local player = windower.ffxi.get_player()
    local assist = windower.ffxi.get_mob_by_name(assist_target)

    if not player or not assist then return end

    --Melee/ranged
	if (act.category == 1 or act.category == 12 or act.category == 7) and act.actor_id == assist.id then
		current_target = act.targets[1].id
    end
end)

--If your target dies
windower.register_event('incoming chunk', function(id, data)
	if id == 0x029 then
		local p = packets.parse('incoming',data)
		if (p["Message"] == 6 or p["Message"] == 20) and p["Target"] == current_target then
			current_target = 0
		end
	end
end)

function engage(id)

	packets.inject(packet)
end

function can_engage()
	local player = windower.ffxi.get_player()

	for i,v in pairs(player.buffs) do
		if v == 1 or v == 64 or v == 204 or v == 350 or v == 531 then
			return false
		end
	end
	return true
end	