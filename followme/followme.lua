_addon.version = '0.4.1i'
_addon.name = 'followme'
_addon.author = 'yyoshisaur, modded by icy'
_addon.commands = {'followme','fm'}

-- added getting KI from SR NPC. //fm sr
-- removed mount feature; Use addon MountRoulette, it works well. "//mr" or "//send @all mr" to mount and dismount.

require('strings')
require('logger')
require('coroutine')
local bit = require('bit')
local packets = require('packets')
--local res = require('resources') -- removed resources to lessen the overhead, it was only used to mount.

local keyitems = {
	[2960] = {id=2960,en="macabre simulacrum",category="Temporary Key Items"},
}

local ionis_npcs = {
    [256] = {name = 'Fleuricette', menu = 1201},
    [257] = {name = 'Quiri-Aliri', menu = 1201},
}

local canteen_npc = {
    [291] = {name = 'Incantrix', menu = 31},
}

local sr_npc = {
    [276] = {name = 'Malobra', menu = 3},
}

local sr_cup = {
    [276] = {name = 'Infernal Transposer', menu = 5517},
}

local domain_invasion_npcs = {
    [288] = {name = 'Affi', menu = 9701, x = -2, z = 0, y = 59.50, unknown1 = 12, unknown2 = 1},
    [289] = {name = 'Dremi', menu = 9701, x = 0, z = -43.60, y = -238.00, unknown1 = 12, unknown2 = 1},
    [291] = {name = 'Shiftrix', menu = 9701, x = 641.6, z = -374.00, y = -912.2, unknown1 = 12, unknown2 = 1},
}

local is_ionis_npc_busy = false
local is_canteen_npc_busy = false
local is_di_npc_busy = false
local is_sr_npc_busy = false
local is_sr_cup_busy = false

local check = {}
local requests = {
    [0x113] = packets.new('outgoing', 0x10F),
    [0x118] = packets.new('outgoing', 0x115),
}
local bayld = 5000

local send_delay = 0.4
math.randomseed(os.clock())
math.random()
function get_delay(delay_base)
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end

    if #members == 1 then
        local delay = math.random(30)*0.1
        log('Solo: random delay = '..delay)
        return delay
    end

    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * delay_base
        end
    end
end

function get_ionis_npc()
    local zone = windower.ffxi.get_info().zone
    local ionis_npc = ionis_npcs[zone]
    local npc = nil

    if ionis_npc then
        npc = windower.ffxi.get_mob_by_name(ionis_npc.name)
    else
        log('No ionis npc found!')
        return nil
    end

    if npc and math.sqrt(npc.distance) < 6 then
        return npc
    else
        log(ionis_npc.name..' found, but too far!')
        return nil
    end
end

function start_ionis()

    local npc = get_ionis_npc()

    if npc then
        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = npc.id,
            ["Target Index"] = npc.index,
            ["Category"] = 0
        })
        packets.inject(p)
        is_ionis_npc_busy = true
    end
end

function incoming_ionis(id, data, modified, injected, blocked)
    if id == 0x034 then
        if is_ionis_npc_busy then
            local in_p = packets.parse('incoming', data)
            local npc = get_ionis_npc()

            if npc and npc.id == in_p["NPC"] then
                local p = packets.new('outgoing', 0x5b, {
                    ["Target"] = npc.id,
                    ["Option Index"] = 1,
                    ["Target Index"] = npc.index,
                    ["Automated Message"] = false,
                    ["Zone"] = in_p["Zone"],
                    ["Menu ID"] = ionis_npcs[in_p["Zone"]].menu,
                })
                packets.inject(p)
                is_ionis_npc_busy = false
                return true
            end
        end
    end
end

function get_canteen_npc()
    local zone = windower.ffxi.get_info().zone
    local npc = nil

    if canteen_npc[zone] then
        npc = windower.ffxi.get_mob_by_name(canteen_npc[zone].name)
    else
        log('No canteen npc found!')
        return nil
    end

    if npc and math.sqrt(npc.distance) < 6 then
        return npc
    else
        log(npc.name..' found, but too far!')
        return nil
    end
end

function start_canteen()
    local npc = get_canteen_npc()

    if npc then
        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = npc.id,
            ["Target Index"] = npc.index,
            ["Category"] = 0
        })
        packets.inject(p)
        is_canteen_npc_busy = true
    end
end

function has_canteen(menu_param)
    if menu_param[29]:byte() == 0x07 then
        return true
    else
        return false
    end
end

function incoming_canteen(id, data, modified, injected, blocked)
    if id == 0x034 then
        if is_canteen_npc_busy then
            local in_p = packets.parse('incoming', data)
            local npc = get_canteen_npc()

            if npc and npc.id == in_p["NPC"] then
                if has_canteen(in_p['Menu Parameters']) then
                    is_canteen_npc_busy = false
                    log('You already have Canteen!')
                    windower.send_command('wait 3;setkey escape;wait 0.5;setkey escape up;')
                    return false
                end

                local p = packets.new('outgoing', 0x5b, {
                    ["Target"] = npc.id,
                    ["Option Index"] = 3,
                    ["Target Index"] = npc.index,
                    ["Automated Message"] = false,
                    ["Zone"] = in_p["Zone"],
                    ["Menu ID"] = canteen_npc[in_p["Zone"]].menu,
                })
                packets.inject(p)
                is_canteen_npc_busy = false
                return true
            end
        end
    end
end

function sr_cup_nav()
	local cmd = 'wait 1;setkey down;wait 0.2;setkey down up;'
	cmd = cmd .. 'wait 1;setkey enter;wait 0.2;setkey enter up;'
	cmd = cmd .. 'wait 1;setkey enter;wait 0.2;setkey enter up;'
	cmd = cmd .. 'wait 1;setkey up;wait 0.2;setkey up up;'
	cmd = cmd .. 'wait 1;setkey enter;wait 0.2;setkey enter up;'
	windower.send_command(cmd)
	coroutine.sleep(7)
	is_sr_cup_busy = false
end

function sr_ki_nav()
	local cmd = 'wait 1;setkey down;wait 0.2;setkey down up;'
	cmd = cmd .. 'wait 1;setkey enter;wait 0.2;setkey enter up;'
	cmd = cmd .. 'wait 2;setkey up;wait 0.2;setkey up up;'
	cmd = cmd .. 'wait 1;setkey enter;wait 0.2;setkey enter up;'
	windower.send_command(cmd)
	coroutine.sleep(7)
	is_sr_npc_busy = false
end

function incoming_sr(id, data, modified, injected, blocked)
	if id == 0x034 then
        if is_sr_npc_busy or is_sr_cup_busy then
            local in_p = packets.parse('incoming', data)
            local npc = is_sr_npc_busy and get_sr_npc() or get_sr_cup()

            if npc and npc.id == in_p["NPC"] then
				local z = in_p["Zone"]
                if is_sr_npc_busy and has_ki('macabre simulacrum') then
                    is_sr_npc_busy = false
                    log('You already have a Macabre simulacrum!')
                    windower.send_command('wait 3;setkey escape;wait 0.5;setkey escape up;')
                    return false
				elseif is_sr_cup_busy and not has_ki('macabre simulacrum') then
                    is_sr_cup_busy = false
                    log('You need a Macabre simulacrum!')
                    windower.send_command('wait 3;setkey escape;wait 0.5;setkey escape up;')
                    return false
                end
				
				-- stop using this once the packet sequence below is figured out.
				if is_sr_npc_busy then
					sr_ki_nav()
				else
					sr_cup_nav()
				end
				
				--[[ -- fml, i can't figure out why this packet sequence isn't working...
                local p = packets.new('outgoing', 0x5b, {
                    ["Target"] = npc.id,
					["Target Index"] = npc.index,
					["Menu ID"] = sr_npc[z].menu,
                    ["Option Index"] = 1,
                    ["Automated Message"] = true,
					["_unknown1"] = 0,
					["_unknown2"] = 0,
					["Zone"] = z,
                })
				--vprint(p)
                packets.inject(p)
				
				coroutine.sleep(3)
				
				local p = packets.new('outgoing', 0x5b, {
                    ["Target"] = npc.id,
					["Target Index"] = npc.index,
					["Menu ID"] = sr_npc[z].menu,
                    ["Option Index"] = 2,
                    ["Automated Message"] = true,
					["_unknown1"] = 0,
					["_unknown2"] = 0,
					["Zone"] = z,
                })
                packets.inject(p)
								
                is_sr_npc_busy = false
                return true
				]]
            end
        end
    end
end

function get_sr_cup()
    local zone = windower.ffxi.get_info().zone
    local npc = nil

    if sr_cup[zone] then
        npc = windower.ffxi.get_mob_by_name(sr_cup[zone].name)
    else
        log('SR cup not found!')
        return nil
    end

    if npc and math.sqrt(npc.distance) < 6 then
        return npc
    else
        log(npc.name..' found, but too far!')
        return nil
    end
end

function start_sr_enter()
    local npc = get_sr_cup()
	if npc then
		local p = packets.new('outgoing', 0x01A, {
			["Target"] = npc.id,
			["Target Index"] = npc.index,
			["Category"] = 0
		})
		packets.inject(p)
		is_sr_cup_busy = true
	end
end


function get_sr_npc()
    local zone = windower.ffxi.get_info().zone
    local npc = nil

    if sr_npc[zone] then
        npc = windower.ffxi.get_mob_by_name(sr_npc[zone].name)
    else
        log('SR npc not found!')
        return nil
    end

    if npc and math.sqrt(npc.distance) < 6 then
        return npc
    else
        log(npc.name..' found, but too far!')
        return nil
    end
end

function start_sr()
	search_fields('bayld')
    local npc = get_sr_npc()
	
	if bayld < 5000 then
		log('Not enough Bayld.')
	else
		if npc then
			local p = packets.new('outgoing', 0x01A, {
				["Target"] = npc.id,
				["Target Index"] = npc.index,
				["Category"] = 0
			})
			packets.inject(p)
			is_sr_npc_busy = true
		end
	end
end

function incoming_di(id, data, modified, injected, blocked)
    if id == 0x034 then
        if is_di_npc_busy then
            local in_p = packets.parse('incoming', data)
            local npc = get_di_npc()
            if npc and npc.id == in_p["NPC"] then
                local zone = in_p["Zone"]
                local get_p = packets.new('outgoing', 0x05B, {
                    ["Target"] = npc.id,
                    ["Option Index"] = 10,
                    ["Target Index"] = npc.index,
                    ["Automated Message"] = true,
                    ["Zone"] = zone,
                    ["Menu ID"] = domain_invasion_npcs[zone].menu
                })
                packets.inject(get_p)
                coroutine.sleep(1)
                local  warp_p = packets.new('outgoing', 0x05C, {
                    ["Target ID"] = npc.id,
                    ["Target Index"] = npc.index,
                    ["Zone"] = zone,
                    ["Menu ID"] = domain_invasion_npcs[zone].menu,
                    ["X"] = domain_invasion_npcs[zone].x,
                    ["Z"] = domain_invasion_npcs[zone].z,
                    ["Y"] = domain_invasion_npcs[zone].y,
                    ["_unknown1"] = domain_invasion_npcs[zone].unknown1,
                    ["_unknown2"] = domain_invasion_npcs[zone].unknown2,
                    ["Rotation"] = 0
                })
                packets.inject(warp_p)
                coroutine.sleep(3)
                windower.send_command('setkey escape;wait 0.5;setkey escape up;')
                is_di_npc_busy = false
            end
        end
    end
end

function get_di_npc()
    local zone = windower.ffxi.get_info().zone
    local di_npc = domain_invasion_npcs[zone]
    local npc = nil

    if di_npc then
        npc = windower.ffxi.get_mob_by_name(di_npc.name)
    else
        log('No DI npc found!')
        return nil
    end

    if npc and math.sqrt(npc.distance) < 6 then
        return npc
    else
        log(di_npc.name..' found, but too far!')
        return nil
    end
end

function start_di()
    local npc = get_di_npc()

    if npc then
        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = npc.id,
            ["Target Index"] = npc.index,
            ["Category"] = 0
        })
        packets.inject(p)
        is_di_npc_busy = true
    end
end


function incoming_cur(id, data, modified, injected, blocked)
	if check[id] then
        local packet = packets.parse('incoming', data)
        for field in check[id]:it() do
			bayld = tonumber(packet[field])
            log('Bayld ('..tostring(bayld)..')')
        end
        check[id] = nil
	end
end

-- local mount_name = windower.to_shift_jis(res.mounts[1].name) -- Raptor
-- function mount()
    -- windower.send_command('input /mount '..mount_name)
-- end

-- function dismount()
    -- windower.send_command('input /dismount')
-- end

-- //fm start
-- //fm stop

function fm_command(...)
    local args = {...}
    if args[1] == 'start' then
        local id = windower.ffxi.get_player().id
        windower.send_ipc_message('follow start '..id)
    elseif args[1] == 'stop' then
        windower.send_ipc_message('follow stop')
    elseif args[1] == 'ionis' then
        local delay = get_delay(send_delay)
        start_ionis:schedule(delay)
        windower.send_ipc_message('ionis')
    elseif args[1] == 'canteen' then
        local delay = get_delay(send_delay)
        start_canteen:schedule(delay)
        windower.send_ipc_message('canteen')
    elseif args[1] == 'di' then
        local delay = get_delay(send_delay*5)
        start_di:schedule(delay)
        windower.send_ipc_message('di')
	elseif args[1] == 'sr' then
		local delay = get_delay(send_delay*5)
		if args[2] and args[2]:lower() == 'enter' then
			start_sr_enter:schedule(delay)
		else
			start_sr:schedule(delay)
			windower.send_ipc_message('sr')
		end
    -- elseif args[1] == 'mount' then
        -- mount()
        -- windower.send_ipc_message('mount')
    -- elseif args[1] == 'dismount' then
        -- dismount()
        -- windower.send_ipc_message('dismount')
    end
end

function fm_ipc_msg(message)
    local msg = message:split(' ')
    if msg[1] == 'follow' then
        if msg[2] == 'start' then
            local id = msg[3]
            local mob = windower.ffxi.get_mob_by_id(id)
            if mob then
                local index = mob.index
                windower.ffxi.follow(index)
            end
        elseif msg[2] == 'stop' then
            -- windower.ffxi.follow(-1)
            windower.send_command('setkey numpad7 down;wait .5;setkey numpad7 up;')
        end
    elseif msg[1] == 'ionis' then
        local delay = get_delay(send_delay)
        start_ionis:schedule(delay)
    elseif msg[1] == 'canteen' then
        local delay = get_delay(send_delay)
        start_canteen:schedule(delay)
    elseif msg[1] == 'di' then
        local delay = get_delay(send_delay*5)
        start_di:schedule(delay)
	elseif msg[1] == 'sr' then
        local delay = get_delay(send_delay*5)
        start_sr:schedule(delay)
    -- elseif msg[1] == 'mount' then
        -- mount()
    -- elseif msg[1] == 'dismount' then
        -- dismount()
    end
end

function has_ki(name)
	local result = false
	if not name then
		return result
	end
	name = name:lower()
	
	local owned_kis = windower.ffxi.get_key_items()
	for _, ki_id in pairs(owned_kis) do
		local ki = keyitems[ki_id]
		if ki and ki.en:lower() == name then
			result = true
			break
		end
    end
	owned_kis = nil
	
	return result
end

function search_fields(terms)
    terms = terms:split('|'):map(string.gsub-{'[%s%p]', '.*'} .. string.lower)

    if windower.ffxi.get_info().logged_in then
        check = {}
        local results

        for id, packet in pairs(requests) do
            local fields = packets.fields('incoming', id)

            for field in fields:it() do
                if field.type ~= 'data' then
                    local str = field.label:gsub('[%s%p]', ''):lower()

                    for term in terms:it() do
                        if str:find(term) then
                            check[id] = check[id] or L{}
                            check[id]:append(field.label)
                        end
                    end
                end
            end

            if check[id] then
                packets.inject(packet)
                results = true
            end
        end
        return results
    end
end

windower.register_event('addon command', fm_command)
windower.register_event('ipc message', fm_ipc_msg)

windower.register_event('incoming chunk', incoming_ionis)

windower.register_event('incoming chunk', incoming_canteen)

windower.register_event('incoming chunk', incoming_di)

windower.register_event('incoming chunk', incoming_sr)

windower.register_event('incoming chunk', incoming_cur)