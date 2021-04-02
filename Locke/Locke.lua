_addon.name = 'Locke'
_addon.author = 'Icy'
_addon.commands = {'locke','thf','th'}
_addon.version = '2020.10.27'

require('logger')
require('strings')
require('tables')
--require('lists')
require('sets')
--require('functions')
texts = require('texts')
config = require('config')
packets = require('packets')
--[[
	track status
	track poked targets
	track TH procs
	
	Base equipment set should have +5 TH. (+3 TH from job traits for a total of +8 TH)
	
	when engaged/hit the mob. (base th applied)
		> Equip 1 more +TH
		
	when th procs.
		> Equip 1 more +TH
	
	
	
]]

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 200
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30

settings = config.load(defaults)
active = true
debug_mode = false
thf_status = texts.new('Locke: -', settings)
thf_status:show()

th_sets = T{
	[8]="sets.TreasureHunter8", 
	[9]="sets.TreasureHunter9",
	[10]="sets.TreasureHunter10",
	[11]="sets.TreasureHunter11",
	[12]="sets.TreasureHunter12",
	[13]="sets.TreasureHunter13"
}
equip_th_set = nil
tagged_mobs = T{}

windower.register_event('addon command', function(...)
	local commands = {...}
	if #commands ~= 0 then
		if commands[1]:lower() == "on" then
			active = true
			thf_status:text('Locke: -')
			log("ON")
		elseif commands[1]:lower() == "off" then
			active = false
			thf_status:text('Locke: OFF')
			log("OFF")
		elseif commands[1]:lower() == "debug" then
			debug_mode = not debug_mode
			log("Debug Mode "..(debug_mode and "ON" or "OFF"))
		else
			active = not active
			log(active and "ON" or "OFF")
			thf_status:text('Locke: ' .. (active and '-' or 'OFF'))
		end
		
	end
end)


function handle_incoming_chunk(id, data)
	if active and id == 0x028 then
		local packet = packets.parse('incoming', data)
        local target = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])
		if packet.Category == 1 and check_actor(packet) then
			if packet['Target 1 Action 1 Has Added Effect'] then
                if packet['Target 1 Action 1 Added Effect Message'] == 603 then
					local proc_num = packet['Target 1 Action 1 Added Effect Param']
					if th_sets[proc_num] then
						equip_th_set = th_sets[proc_num]
					else
						equip_th_set = th_sets[8]
					end
					tagged_mobs[target.id] = proc_num
					equip(equip_th_set)
					thf_status:text('Locke: '..target.name..' → '..proc_num..' → '..equip_th_set)
                end
            end
		end
	elseif active and id == 0x29 then
        local target_id = data:unpack('I',0x09)
        local message_id = data:unpack('H',0x19)%32768
		
        -- Remove mobs that die from our tagged mobs list.
		-- 	6 == actor defeats target
		-- 	20 == target falls to the ground
        if message_id == 6 or message_id == 20 then
            if tagged_mobs[target_id] then
                if debug_mode then log('Mob '..target_id..' died. Removing from tagged mobs table.') end
                tagged_mobs[target_id] = nil
            end
        end
	end
end

function check_actor(packet)
	local key_indices = {'p0','p1','p2','p3','p4','p5','a10','a11','a12','a13','a14','a15','a20','a21','a22','a23','a24','a25'}
    local party = windower.ffxi.get_party()
    local actor = windower.ffxi.get_mob_by_id(packet['Actor'])
    for i = 1, 18 do
        local member = party[key_indices[i]]
        if member and actor and member.mob and member.mob.id == actor.id then
            return true
        end
    end
    return false
end

function equip(set)
	if set then
		if debug_mode then log("Equipping set:", set) end
		windower.send_command('gs enable all;gs equip '..set..';gs disable all')
	else
		if debug_mode then log("Enabling gear slots") end
		equip_th_set = nil
		windower.send_command('gs enable all;gs c forceequip')
	end
end

function reset()
	thf_status:text('Locke: -')
	tagged_mobs:clear()
	windower.send_command('gs enable all;gs c forceequip')
end

function loaded()
	windower.send_command('lua u Thfknife;lua u thtracker')
	check_job()
end

function check_job()
    player = windower.ffxi.get_player()
    if p and p.main_job == 'THF' then
		thf_status:text('Locke: -')
		active = true
		log("ON")
    else
        reset()
		thf_status:text('Locke: OFF')
		active = false
    end
end

function target_changed(idx)
	player = windower.ffxi.get_player()
	local target_id = windower.ffxi.get_mob_by_index(idx)
	target_id = target_id and target_id.id or nil
	if not target_id then return end
	
	if player.status == 1 then
		if tagged_mobs[target_id] then
			equip_th_set = th_sets[tagged_mobs[target_id]]
		else
			equip_th_set = th_sets[8]
			tagged_mobs[target_id] = 8
		end
	end
end

function status_changed(new, old)
	player = windower.ffxi.get_player()
	if new == 1 then
		local target = windower.ffxi.get_mob_by_target('t')
		if target and not tagged_mobs[target.id] then
			equip_th_set = th_sets[8]
			tagged_mobs[target.id] = 8
		elseif target and tagged_mobs[target.id] then
			equip_th_set = th_sets[tagged_mobs[target.id]] or th_sets[8]
		end
		equip(equip_th_set)
	elseif new == 0 then
		equip()
	end
end

function zone_change(new, old)
	reset()
end

windower.register_event('incoming chunk', handle_incoming_chunk)
windower.register_event('status change', status_changed)
--windower.register_event('target change', target_changed)
windower.register_event('job change', 'login', check_job)
windower.register_event('load', loaded)
windower.register_event('logout', 'zone change', reset)