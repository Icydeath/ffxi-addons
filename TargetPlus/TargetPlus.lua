--Enhancing Targetting, aka Better F8
-- https://pastebin.com/Kqbq1YeF

--[[
Commands are 
"//tar" - nearest mob - think F8, but 360 degrees
"//tar spider" nearest spider mob
"//tar not spider" nearest mob that isn't a spider
"//tar next" nearest mob that isn't your current target
]]

packets = require('packets')

windower.register_event("load", function (...)
	--windower.send_command('bind sysrq lua c TargetPlus')
	windower.send_command('alias tar lua c TargetPlus')
end)

windower.register_event("unload", function (...)
	--windower.send_command('unbind sysrq')
	print("TargetPlus: Goodbye!")
end)

windower.register_event("addon command", function (...)

    local params = {...}
    names = {}
    ignore_names = {}
    ignore_index = None
    use_ignore_list = false
    --No params, ie "//tar" will pick the closest mob with no filter - effectively F8, but can target behind you.
    for _,param in pairs(params) do
    	if string.lower(param) == "next" then
            --Ignore current target, and pick the closest other.
            --This would be for a dynamis Main assist to use. i.e. "tar next not tombstone effigy idol golem 's" to avoid any statues and avatars/pets.
    		ignore_index = windower.ffxi.get_player()['target_index']
    	elseif string.lower(param) == "not" then
            --Any strings after "not" will be excluded, i.e. "tar Schah's not Mantri" for pulling adds off on Schah
    		use_ignore_list = true
    	elseif not use_ignore_list then
            --Add a name to the match list
            names[#names+1] = param
    	else
            --Add a name to the ignore list
            ignore_names[#ignore_names+1] = param
    	end
    end

    closest_index = get_nearest_index(names,ignore_names,ignore_index)

	if closest_index ~= None then
		--tprint(windower.ffxi.get_mob_by_index(closest_index))
		--print("TargetPlus: Attempting to target -"..windower.ffxi.get_mob_by_index(closest_index)['name'].."-")
		set_target(windower.ffxi.get_mob_by_index(closest_index)['id'])
	else
		print("TargetPlus: Unable to find a matching target")
	end
end)

function get_nearest_index(names, ignore_names, ignore_index)
	mob_array = windower.ffxi.get_mob_array()
	min_distance = 2500 --50 in 'real' distance, the maximum targetable range
	closest_index = None

	for _,v in pairs(mob_array) do
        --A pile of (possibly?) redundant checks to find the nearest living monster that isn't ignored
		if v['distance'] < min_distance and v['distance'] > 0 and v['is_npc'] and v['hpp'] > 0 and v['valid_target'] and v['name'] ~= "" and v['index'] ~= ignore_index and v['spawn_type'] == 16 then
            if next(names) == nil and not check_name_match(ignore_names, v['name']) then
				min_distance = v['distance']
				closest_index = v['index']
			elseif check_name_match(names, v['name']) and not check_name_match(ignore_names, v['name']) then
				min_distance = v['distance']
				closest_index = v['index']
			end
		end
	end
	return closest_index
end

--Cribbed from SetTarget.lua at https://github.com/Windower/Lua/tree/live/addons/SetTarget
function set_target(id)
    id = tonumber(id)
    if id == nil then
        return
    end

    local target = windower.ffxi.get_mob_by_id(id)
    if not target then
        return
    end

    local player = windower.ffxi.get_player()

    packets.inject(packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = target.id,
        ['Player Index'] = player.index,
    }))
end

function check_name_match(names, name)
    for _,value in pairs(names) do
        if string.match(string.lower(name), string.lower(value)) then
        	return true
        end
    end
	return false
end

function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		else
			print(formatting .. tostring(v))
		end
	end
end