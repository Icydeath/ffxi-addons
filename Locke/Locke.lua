_addon.name = 'Locke'
_addon.author = 'Icy'
_addon.commands = {'locke','thf','th'}
_addon.version = '2021.4.14'

-- This addon was built to test Rufuso's TH Theory: https://www.youtube.com/watch?v=r1pLv_aF7-s
-- Removed the usage of GS, wasn't consistent enough for what I'm trying to accomblish.
--[[ 
Locke now it utilizes the games native equipment sets:
1) Create 6 equipment sets in game that has +5 TH, TH +6, TH +7, TH +8, TH +9, TH +10
2) Adjust the equipset_map table below
--]]

require('logger')
require('strings')
require('tables')
require('sets')
texts = require('texts')
config = require('config')
packets = require('packets')

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
active = false
debug_mode = false
thf_status = texts.new('Locke: OFF', settings)

-- remember that thf has a base of +3 TH, so a equipment set that has +5 takes your total to +8 TH.
equipset_map = T{
	-- Change the equipset # to your ingame equipment set #
	{ th=8, 	equipset=8 },
	{ th=9, 	equipset=9 },
	{ th=10, 	equipset=10 },
	{ th=11, 	equipset=11 },
	{ th=12, 	equipset=12 },
	{ th=13, 	equipset=13 },
}

equip_th_set = nil
tagged_mobs = T{}

windower.register_event('addon command', function(...)
	local commands = {...}
	if #commands ~= 0 then
		if commands[1]:lower() == "on" then
			active = true
			windower.send_command('lua u gearswap;wait .7;input /equipset '..equipset_map:with('th', 8).equipset)
			thf_status:text('Locke: awaiting proc...')
		elseif commands[1]:lower() == "off" then
			active = false
			windower.send_command('lua l gearswap')
			thf_status:text('Locke: OFF')
		elseif commands[1]:lower() == "debug" then
			debug_mode = not debug_mode
			log("Debug Mode: "..(debug_mode and "ON" or "OFF"))
		else
			active = not active
			if active then 
				windower.send_command('lua u gearswap;wait .7;input /equipset '..equipset_map:with('th', 8).equipset)
			else
				windower.send_command('lua l gearswap')
			end
			thf_status:text('Locke: %s':format(active and 'awaiting proc...' or 'OFF'))
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
					if proc_num then
						local set = equipset_map:with('th', proc_num)
						if set then
							equip_th_set = set.equipset
						elseif tonumber(proc_num) and tonumber(proc_num) > 13 then
							equip_th_set = nil
						else
							equip_th_set = equipset_map:with('th', 8).equipset
						end
					end
					tagged_mobs[target.id] = proc_num
					thf_status:text('Locke: '..target.name..' → '..proc_num..' → equipset '..equip_th_set)
					equip(equip_th_set)
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

function equip(setnum)
	if setnum then
		if debug_mode then log("Equipping set:", setnum) end
		cmd = 'input /equipset '..tostring(setnum)
		windower.send_command(cmd)
	else
		equip_th_set = nil
	end
end

function reset()
	active = false
	tagged_mobs:clear()
	equip_th_set = nil
	thf_status:text('Locke: OFF')
	windower.send_command('lua l gearswap')
end

function loaded()
	windower.send_command('lua u Thfknife;lua u thtracker;')
	check_job()
end

function unload()
	windower.send_command('lua l gearswap')
	player = windower.ffxi.get_player()
	if player and player.main_job:lower() == 'thf' then
		windower.send_command('lua l Thfknife;')
	end
end

function check_job()
    player = windower.ffxi.get_player()
    if player and player.main_job:lower() == 'thf' then
		reset()
		windower.send_command('lua u Thfknife;lua u thtracker;')
		thf_status:show()
    else
        reset()
		thf_status:hide()
    end
end

function target_changed(idx)
	if not active then return end
	
	player = windower.ffxi.get_player()
	local target_id = windower.ffxi.get_mob_by_index(idx)
	target_id = target_id and target_id.id or nil
	if not target_id then return end
	
	if player.status == 1 then
		if tagged_mobs[target_id] then
			equip_th_set = equipset_map:with('th', tagged_mobs[target_id]).equipset
		else
			equip_th_set = equipset_map:with('th', 8).equipset
			tagged_mobs[target_id] = 8
		end
		equip(equip_th_set)
	end
end

function status_changed(new, old)
	if not active then return end
	
	player = windower.ffxi.get_player()
	if new == 1 then
		local target = windower.ffxi.get_mob_by_target('t')
		if target and not tagged_mobs[target.id] then
			equip_th_set = equipset_map:with('th', 8).equipset
			tagged_mobs[target.id] = 8
		elseif target and tagged_mobs[target.id] then
			equip_th_set = equipset_map:with('th', tagged_mobs[target_id]).equipset or equipset_map:with('th', 8).equipset
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
windower.register_event('unload', unload)
windower.register_event('load', loaded)
windower.register_event('logout', 'zone change', reset)