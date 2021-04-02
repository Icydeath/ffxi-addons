_addon.name = 'OneOffs'
_addon.author = 'Icy, based off of statsearch by Lili'
_addon.version = '0.0.2'
_addon.commands = {'oneoffs','oo'}

require('logger')
local extdata = require('extdata')
local res = require('resources')

local lang
local jobs

local loc_groups = {
	['wardrobes'] = S{"Wardrobe", "Wardrobe 2", "Wardrobe 3", "Wardrobe 4"},
	['storage'] = S{"Safe", "Safe 2", "Storage", "Locker", "Satchel", "Sack", "Case"}
}

local work = function(job, get_items, group)
    local results = {}
    local from = group and loc_groups[group] or nil
	job = job or windower.ffxi.get_player().main_job_id
    log(get_items and 'Getting' or 'Searching for', res.jobs[job].ens, 'only gear:', group and set.concat(from, ', ') or 'all storage locations')
	
    for i,bag in pairs(res.bags) do
        local items = windower.ffxi.get_items(bag.id)
        for _,item in pairs(items) do
            if type(item) == 'table' and item.id and item.id > 0 and res.items[item.id].flags['Equippable'] and res.items[item.id].jobs:length() == 1 and res.items[item.id].jobs:contains(job) then
                if not results[bag.name] then 
					results[bag.name] = T{}
				end
				results[bag.name]:append(res.items[item.id].name)
            end
        end
    end
	
	
    for i,v in pairs(results) do
		local do_loc = true
		if from and not from:contains(i) then
			do_loc = false
		end
		
		if do_loc then
			log('['..i..']')
			for _,j in ipairs(v) do
				if get_items then
					windower.send_command('get '..j)
				end
				log('\t',j)
			end
		end        
    end
end

windower.register_event('load',function()
    lang = windower.ffxi.get_info().language:lower()
    jobs = {}
    for i,v in pairs(res.jobs) do
        if i ~= 23 then --monipulator
            local short = v[lang.."_short"]:lower()
            local long = v[lang]:lower()
            local id = v.id
            jobs[short] = id
            jobs[long] = id
        end
    end
end)

windower.register_event('addon command', function(...)
    local args = T{...}
	
    local get = false
	local job = nil
	local group = nil
	
    if args[1] == 'help' then
		log('Finds gear only equippable for a specific job.')
		log('//oo [job] [get] [wardrobes | storage]')
		
		log('\t== EXAMPLES ==')
		log('//oo -- Searches for current job\'s specific gear in all locations.')
		log('//oo get -- Retrieves current job\'s specific gear from all locations.')
		
		log('//oo wardrobes -- Searches for current job\'s specific gear within wardrobes.')
		log('//oo get storage -- Retrieves current job\'s specific gear from everywhere but wardrobes.')
		
		log('//oo blu -- Searches for BLU specific gear in all locations.')
		log('//oo blu get -- Retrieves BLU specific gear from all locations')
		log('//oo blu wardrobes -- Searches for BLU specific gear within wardrobes.')
		log('//oo blu get storage -- Retrieves BLU specific gear from everywhere but wardrobes.')
        return
    elseif args[1] == 'r' then
        windower.send_command('lua r OneOffs')
        return
	elseif args[1] and jobs[args[1]:lower()] then
		job = jobs[args[1]:lower()]
	elseif args[1] and args[1]:lower() == 'get' then
		get = true
	elseif args[1] and loc_groups[args[1]:lower()] then
		group = args[1]:lower()
    end
    
	if args[2] then
		if args[2]:lower() == 'get' then
			get = true
		elseif loc_groups[args[2]:lower()] then
			group = args[2]:lower()
		end
	end
	
	if args[3] and loc_groups[args[3]:lower()] then
		group = args[3]:lower()
	end
	
    work(job, get, group)
end)