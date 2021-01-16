-- Credit: 
-- 	Semmeh (original creator)
--	AkadenTK (Windower5 conversion)

_addon.name = 'Job Change'
_addon.author = 'Sammeh, modded by icy'
_addon.version = '1.0.4'
_addon.command = 'jc'

require('tables')
packets = require('packets')
res = require ('resources')
config = require('config')

defaults = {
	show_logging = true
}
settings = config.load(defaults)

local temp_jobs = L{13, 19, 1, 2, 3, 4, 5}
local moogle_zones = S{'Selbina', 'Mhaura', 'Tavnazian Safehold', 'Nashmau', 'Rabao', 'Kazham', 'Norg'}
local moogle_names = S{'Moogle', 'Nomad Moogle', 'Green Thumb Moogle'}

function jobchange(job, main)
	job_type = main and 'Main Job' or 'Sub Job'
    if job and job_type then 
        local packet = packets.new('outgoing', 0x100, {
            [job_type] = job,
        })
        packets.inject(packet)
    end    
	
	coroutine.sleep(0.5)
end

windower.register_event('addon command', function(...)
	local args = {...}
	args[1] = args[1] and args[1]:lower()
	args[2] = args[2] and args[2]:lower()
	
	local player = windower.ffxi.get_player()
	
	local mj = ''
	local sj = ''
	if args[1] == "h" or args[1] == "help" then
		print_help()
		return
	elseif args[1] == 'main' then
		mj = args[2]
	elseif args[1] == 'sub' then
		sj = args[2]
	elseif args[1] == 'reset' or args[1] == 'r' then
		logger("Resetting subjob")
		solve_jobchange(mainid, player.sub_job_id, player)
		return
	else
		if args[1] and args[2] then -- setting both main and sub
			mj = args[1]
			sj = args[2]
		elseif args[1] then
			mj = args[1]
			if mj:contains('/') then
				local splat = mj:split('/')
				mj = splat[1]
				sj = splat[2]
			end
		else
			print_help()
			return
		end
	end
	
	handle_jobchange(mj, sj, player)
end)

function print_help()
	windower.add_to_chat(204, "JobChange ".._addon.version)
	windower.add_to_chat(204, " Change MAIN: //jc war       [or]    //jc main war")
	windower.add_to_chat(204, " Change SUB: //jc /sam       [or]    //jc sub sam")
	windower.add_to_chat(204, " Change BOTH: //jc war/sam  [or]    //jc war sam")
	windower.add_to_chat(204, " Reset subjob: //jc (r)eset")
end

function logger(msg)
	if settings.show_logging then
		windower.add_to_chat(4, "JobChange: "..msg)
	end
end

function handle_jobchange(main, sub, player)
	local mainid = find_job(main, player)	
	if main ~= '' and mainid == nil then 
        logger("Could not change main job to "..main:upper().." ---Mistype|NotUnlocked")
        return
    end
    local subid = find_job(sub, player)
    if sub ~= '' and subid == nil then 
        logger("Could not change sub job to "..sub:upper().." ---Mistype|NotUnlocked")
        return
    end

    if mainid == player.main_job_id then 
        mainid = nil 
    end
	
    if subid == player.sub_job_id then 
        subid = nil 
    end
  
	if mainid == nil and subid == nil then
        logger("No change required.")
        return
    end
	
    solve_jobchange(mainid, subid, player)
end

function solve_jobchange(mainid, subid, player)
	local changes = T{}
	
	if mainid ~= nil and mainid == player.sub_job_id then
        if subid ~= nil and subid == player.main_job_id then
            changes:insert({job=find_temp_job(player), conflict=true, main=false})
            changes:insert({job=mainid, main=true})
            changes:insert({job=subid, main=false})
        else
            if subid ~= nil then
                changes:insert({job=subid, main=false})
            else
                changes:insert({job=find_temp_job(player), conflict=true, main=false})
            end
            changes:insert({job=mainid, main=true})
        end
    elseif subid ~= nil and subid == player.main_job_id then
        if mainid ~= nil then
            changes:insert({job=mainid, main=true})
        else
            changes:insert({job=find_temp_job(player), conflict=true, main=true})
        end
        changes:insert({job=subid, main=false})
    else
        if mainid ~= nil then
            if mainid == player.main_job_id then
                changes:insert({job=find_temp_job(player), conflict=true, main=true})
            end
            changes:insert({job=mainid, main=true})
        end
        if subid ~= nil then
            if subid == player.sub_job_id then
                changes:insert({job=find_temp_job(player), conflict=true, main=false})
            end
            changes:insert({job=subid, main=false})
        end
    end
  
    local npc = find_job_change_npc()
    if npc then
        for i, change in ipairs(changes) do
            if change.conflict then
                logger("Conflict with "..(change.main and 'main' or 'sub')..' job. Changing to: '..res.jobs[change.job].ens)
            else
                logger("Changing "..(change.main and 'main' or 'sub').." job to: "..res.jobs[change.job].ens)
            end
            jobchange(change.job, change.main)
  
            coroutine.sleep(1)
        end
    else
        logger("Not close enough to a Moogle!")
    end
end

function find_conflict(job, self)
    if self.main_job_id == job then
        return "main"
    end
    if self.sub_job_id == job then
        return "sub"
    end
end

function find_temp_job(self)
    for _, i in pairs(temp_jobs) do -- check temp jobs (nin, dnc, war, mnk, whm, blm, rdm, thf)
        if not find_conflict(i, self) then 
            return i
        end
    end
end

function find_job(job, self)
    local jobLevel = self.jobs[job:upper()]
    for index,value in pairs(res.jobs) do
        if value.ens:lower() == job and jobLevel > 0 then 
            return index
        end
    end
end

function find_job_change_npc()
    local info = windower.ffxi.get_info()
    if not (info.mog_house or moogle_zones:contains(res.zones[info.zone].english)) then
        logger("Not in a zone with a Change NPC")
        return
    end

    for i, v in pairs(windower.ffxi.get_mob_array()) do
        if v.distance < 36 and moogle_names:contains(v.name) then
            return v
        end
    end
end
