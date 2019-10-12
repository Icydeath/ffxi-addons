_addon.author   = 'Kate'
_addon.version  = '1.0.6'
_addon.commands = {'Quetz'}

require('logger')
require('coroutine')
require('tables')
require('chat')
require('functions')
packets = require('packets')
res = require('resources')
json  = require('json')
files = require('files')
config = require('config')

local conditions = {

	running = false,
	quetzAlive = false,
	quetzDead = false,
	
}

npc_name = ""
pkt = {}
ipcflag = false
busy=false
busy2=false
busy3=false
menuid=0
zone=""
tp={}

valid_zones = T{"Reisinjima"}

valid_zones = {
	
	[291] = {npc="Shiftrix", menu=9701},
}

currentPC=windower.ffxi.get_player()

settings = config.load(defaults)
--------------

function stop()
	
	log('Stopping Quetz!!!')
	if ipcflag == false then
		ipcflag = true
		windower.send_ipc_message('quetz_stop')
	end
	coroutine.sleep(3)
	windower.send_command('lua u autows')
	windower.send_command('lua r healbot')
	coroutine.sleep(1)
	windower.send_command('lua r gearswap')
	windower.send_command('lua unload quetz')
	
end

function begin(namearg)

	currentPC=windower.ffxi.get_player()
	-- Here change whatever commands you want your addons to use.
	-- If IPC false means your party leader commands, no assist.
	if ipcflag == false then
		log('Starting up Quetz and loading addon commands for party leader or single PC!')
		ipcflag = true
		windower.send_ipc_message('quetz_start ' .. currentPC.name)
		
		windower.send_command('lua r healbot')
		windower.send_command('lua r autows')
		windower.send_command('lua r settarget')
		windower.send_command('lua r anchor')
		coroutine.sleep(1.0)
		
	-- Commands here for alts that aren't party leaders.
	elseif ipcflag == true then
	
		log('Starting Quetz for alts!')
		windower.send_command('lua r healbot')
		windower.send_command('lua r autows')
		windower.send_command('lua r settarget')
		windower.send_command('lua r anchor')
		coroutine.sleep(1.0)
		windower.send_command('hb assist ' .. namearg .. '')
		windower.send_command('hb assist attack')
		windower.send_command('hb follow ' .. namearg .. '')
		windower.send_command('hb follow dist 4')
	end
		
	if currentPC.main_job == 'PLD' then
		windower.send_command('hb mincure 4')
		windower.send_command('aws use savage blade')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'WAR' then
		windower.send_command('hb buff ' .. currentPC.name .. ' berserk')
		windower.send_command('hb buff ' .. currentPC.name .. ' retaliation')
		windower.send_command('hb buff ' .. currentPC.name .. ' restraint')
		windower.send_command('hb buff ' .. currentPC.name .. ' blood rage')
		windower.send_command('aws use impulse drive')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'WHM' then
		windower.send_command('hb bufflist whm ' .. currentPC.name .. '')
		windower.send_command('hb buff ' .. currentPC.name .. ' auspice')
		windower.send_command('hb buff ' .. currentPC.name .. ' boost-dex')
		windower.send_command('hb buff ' .. currentPC.name .. ' baraera')
		windower.send_command('hb buff ' .. currentPC.name .. ' barsilencera')
		-- WHM buffs haste on party

		for k, v in pairs(windower.ffxi.get_party()) do
			if type(v) == 'table' then
				if v.name ~= currentPC.name then
					windower.send_command('hb buff ' .. v.name .. ' haste')
				end
			end
		end
		
		windower.send_command('aws use hexa strike')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
		
		--DW subs for whm to get more points faster
		if currentPC.sub_job == 'NIN' or currentPC.sub_job == 'DNC' then
			windower.send_command('gs disable main')
			windower.send_command('gs disable sub')
			windower.send_command('input /equip main \'Bolelabunga\'; wait 1.0; input /equip sub \'Queller Rod\'')
		end
	elseif currentPC.main_job == 'GEO' then
		windower.send_command('lua r autogeo')
		coroutine.sleep(1.0)
		windower.send_command('geo geo frailty')
		windower.send_command('geo indi haste')
		windower.send_command('geo entrust off')
		windower.send_command('hb buff ' .. currentPC.name .. ' haste')
		windower.send_command('hb mincure 4')
		windower.send_command('aws use hexa strike')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'COR' then
		windower.send_command('lua r roller')
		coroutine.sleep(1.0)
		windower.send_command('roller roll1 chaos')
		windower.send_command('roller roll2 samurai')
		windower.send_command('aws use Savage Blade')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'THF' then
		windower.send_command('aws use rudra\'s storm')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'NIN' then
		windower.send_command('aws use Blade: Ten')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'SAM' then
		windower.send_command('hb buff ' .. currentPC.name .. ' hasso')
		windower.send_command('aws use Tachi: Fudo')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'MNK' then
		windower.send_command('aws use Victory Smite')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'DRG' then
		windower.send_command('aws use Stardiver')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'DRK' then
		windower.send_command('aws use Torcleaver')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws tpgt 1249')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'BLU' then
		windower.send_command('aws use Chant Du Cygne')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	elseif currentPC.main_job == 'BRD' then
		windower.send_command('hb disable cure')
		windower.send_command('hb disable na')
		windower.send_command('aws use Evisceration')
		windower.send_command('aws hp > 0 < 99')
		windower.send_command('aws on')
	end
	
	-- Sub job abilities
	if currentPC.sub_job == 'WAR' then
		windower.send_command('hb buff ' .. currentPC.name .. ' berserk')
		windower.send_command('hb buff ' .. currentPC.name .. ' aggressor')
	elseif currentPC.sub_job == 'SAM' then
		windower.send_command('hb buff ' .. currentPC.name .. ' hasso')
	end
	
	ipcflag = false
	
	coroutine.sleep(7)

	local arewelead = windower.ffxi.get_party()
	
	if arewelead.party1_leader == currentPC.id then
		--Custom addon commands
		windower.send_command('multi fon')
		coroutine.sleep(3)
		windower.send_command('multi on')
		coroutine.sleep(5)
	elseif arewelead.party1_leader == nil then
		-- Single player
		windower.send_command('hb on')
		coroutine.sleep(5)
	end

	start()
end


function start()

	log('Waiting for pop.')
	local quetz = windower.ffxi.get_mob_by_name('Quetzalcoatl')
	
	quetzDead = true
	while quetzDead do
		if quetz.hpp > 0 then
			quetzDead = false
		end
		coroutine.sleep(.25)
		quetz = windower.ffxi.get_mob_by_name('Quetzalcoatl')
	end

	-- target quetz and follow and attack if calling function from main
	--if currentPC.name == settings.main1 then
	
	local arewelead = windower.ffxi.get_party()
	
	if (arewelead.party1_leader == currentPC.id or arewelead.party1_leader == nil) then
		
		
		log('Targetting Quetz for main PC!')
		
		windower.send_command('input /autotarget on')
		coroutine.sleep(1)
		quetzstring = tostring(windower.ffxi.get_mob_by_name('Quetzalcoatl').id)
		coroutine.sleep(1)
		windower.send_command('settarget ' .. quetzstring .. '')
		coroutine.sleep(1)
		
		windower.ffxi.run(true)

		conditions['running'] = true
			while conditions['running'] do
				local distance
				distance = windower.ffxi.get_mob_by_name('Quetzalcoatl').distance
				if math.sqrt(distance)<6 then
					conditions['running'] = false
				end
				coroutine.sleep(0.3)
			end

		coroutine.sleep(3)
		windower.ffxi.run(false)
		windower.send_command('input /attack on')
		coroutine.sleep(0.7)
		windower.send_command('input /attack on')
		coroutine.sleep(0.7)
		windower.send_command('input /attack on')
		coroutine.sleep(1)

	end
	

	log('Quetz appeared!')
	fight()
end


-- Actual fight, both main/alts are same
function fight()
	coroutine.sleep(3)
	log('Fighting now.')
	local quetz = windower.ffxi.get_mob_by_name('Quetzalcoatl')
	
	quetzAlive = true
	while quetzAlive do
		if quetz.hpp == 0 or quetz.valid_target == false then
			quetzAlive = false
		end

		coroutine.sleep(.25)
		quetz = windower.ffxi.get_mob_by_name('Quetzalcoatl')
	end
	exitArena()
end

function exitArena()
	
	coroutine.sleep(5)
	currentPC=windower.ffxi.get_player()
	coroutine.sleep(3)
	-- If dead, reraise and continue next fight.
	if currentPC.vitals.hp == 0 then
		log('You died.  Auto Reraise!')
		coroutine.sleep(20)
		windower.send_command('setkey enter down')
		coroutine.sleep(.05)
		windower.send_command('setkey enter up')
		coroutine.sleep(.05)
	else
		log('You lived! Waiting delay')
		coroutine.sleep(20)
	end

	log("Fight's over, teleporting in 5 minutes!")
	-- Prepare to warp out and stop running if running.
	-- This part is only for party leader.
	windower.ffxi.run(false)
	local arewelead = windower.ffxi.get_party()
	
	if (arewelead.party1_leader == currentPC.id or arewelead.party1_leader == nil) then
		coroutine.sleep(5)
		windower.send_command('multi off')
		coroutine.sleep(15)			
		windower.send_command('multi foff')
		coroutine.sleep(5)
		windower.send_command('input /heal')
		coroutine.sleep(2.5)
		windower.send_command('input /heal')
		coroutine.sleep(2.5)
		windower.send_command('input /lockstyle off')
	else
		-- Non leads delay
		coroutine.sleep(30)
	end

	coroutine.sleep(215)
	windower.send_command('gs disable ring2 ')
	coroutine.sleep(5)
	windower.send_command('input /equip ring2 ' .. settings.ring1 .. '')
	coroutine.sleep(15)
	windower.send_command('input /item ' .. settings.ring1 .. ' <me>')
	coroutine.sleep(45)
	windower.send_command('gs enable ring2 ')
	
	zone = windower.ffxi.get_info()['zone']
	
	while (zone ~= 117 and zone ~= 102 and zone ~= 108) do
		log('Could not teleport, trying again...')
		windower.send_command('gs disable ring2 ')
		coroutine.sleep(5)
		windower.send_command('input /equip ring2 ' .. settings.ring1 .. '')
		coroutine.sleep(15)
		windower.send_command('input /item ' .. settings.ring1 .. ' <me>')
		coroutine.sleep(45)
		windower.send_command('gs enable ring2 ')
		zone = windower.ffxi.get_info()['zone']
	end

	enterReisen()

end


function enterReisen()

	log('Entering Reisenjima soon.')

	
	
	coroutine.sleep(35)
	
	--Checking leader
	local arewelead = windower.ffxi.get_party()
	
	if (arewelead.party1_leader == currentPC.id or arewelead.party1_leader == nil) then
		windower.send_command('input /lockstyleset ' .. settings.lockset)
	end
	
	-- Sleep for party members until it's your turn 
	coroutine.sleep(get_running_delay())
	
	tp = windower.ffxi.get_mob_by_name('Dimensional Portal')
	coroutine.sleep(5)
	windower.ffxi.run(true)
	
	conditions['running'] = true
	while conditions['running'] do
		local distance
		distance = windower.ffxi.get_mob_by_name('Dimensional Portal').distance
		if math.sqrt(distance)<4 then
			conditions['running'] = false
		end
		coroutine.sleep(0.3)
	end
	

	windower.ffxi.run(false)
	
	coroutine.sleep(1)
	windower.send_command('setkey escape down')
	coroutine.sleep(.5)
	windower.send_command('setkey escape up')
	
	coroutine.sleep(5)
	
	-- Enter via packets
	------------------------------------
	
	

	-- Use SW
	zone = windower.ffxi.get_info()['zone']
	while (zone == 117 or zone == 102 or zone == 108) do
	
		local distance
		distance = windower.ffxi.get_mob_by_name('Dimensional Portal').distance
		if math.sqrt(distance)<5.7 then
			coroutine.sleep(get_delay())
			windower.send_command('sw ew enter')
		end
		zone = windower.ffxi.get_info()['zone']
		coroutine.sleep(15)
	end
	
	coroutine.sleep(20)
	
	getVorseal()

end

function getVorseal()

	log('Getting Vorseal shortly.')
	
	coroutine.sleep(35)
	
	-- Sleep for party members until it's your turn 
	coroutine.sleep(get_running_delay())

		got_vorseal = 0
		busy=false
 
		while got_vorseal == 0 do
		
			coroutine.sleep(5)
			
			if got_vorseal == 0 then
				if not busy then
					
					pkt = validate()
					if pkt then
						busy = true
						poke_npc(pkt['Target'],pkt['Target Index'])
					else
						log('Packet failed')
					end
				end
			else
				windower.add_to_chat(8,"Vorseal already obtained.")
			end
			
			-- Sleep for time to detect buffs
			coroutine.sleep(15)
			CurBuffs = windower.ffxi.get_player()["buffs"]
				
			
			for key,val in pairs(CurBuffs) do
				if val == 603 then
					got_vorseal = 1
				end
			end
			
		end

	coroutine.sleep(15)
	enterArena()
	
end


function enterArena()

	log('Warping via portal #1')
	coroutine.sleep(10)
	-- Warp via eschan portal
	tp = windower.ffxi.get_mob_by_name('Ethereal Ingress #1')

	-- Sleep for party members until it's your turn 
	coroutine.sleep(get_running_delay())

	
	-- Make sure we aren't targetting ourselves
	windower.send_command('setkey escape down')
	coroutine.sleep(.5)
	windower.send_command('setkey escape up')
	coroutine.sleep(3)
	
	windower.ffxi.turn(-1.05)
	
	coroutine.sleep(5)
	
	-- Run to portal
	windower.ffxi.run(true)
	
	conditions['running'] = true
	while conditions['running'] do
		local distance
		distance = windower.ffxi.get_mob_by_name('Ethereal Ingress #1').distance
		if math.sqrt(distance)<3 then
			conditions['running'] = false
		end
		coroutine.sleep(0.5)
	end
	
	windower.ffxi.run(false)
	
	coroutine.sleep(1)
	windower.send_command('setkey escape down')
	coroutine.sleep(.5)
	windower.send_command('setkey escape up')
	
	
	-- Enter via packets
	------------------------------------
	
	-- Use SW
	local distance
	distance = windower.ffxi.get_mob_by_name('Ethereal Ingress #1').distance
	if math.sqrt(distance)<5.7 then
		coroutine.sleep(get_delay())
		windower.send_command('ew warp 7')
	end
	

	coroutine.sleep(30)
	moveToLocation()
	
end


function moveToLocation()

	--Checking leader
	local arewelead = windower.ffxi.get_party()
	
	if (arewelead.party1_leader == currentPC.id or arewelead.party1_leader == nil) then

		log('Summon trusts.')
		coroutine.sleep(20)
		if settings.trust1 ~= '"None"' then
			windower.send_command('input /ma ' .. settings.trust1 .. ' <me>')
			coroutine.sleep(9)
		end
		if settings.trust2 ~= '"None"' then
			windower.send_command('input /ma ' .. settings.trust2 .. ' <me>')
			coroutine.sleep(9)
		end
		if settings.trust3 ~= '"None"' then
			windower.send_command('input /ma ' .. settings.trust3 .. ' <me>')
			coroutine.sleep(9)
		end		
		if settings.trust4 ~= '"None"' then
			windower.send_command('input /ma ' .. settings.trust4 .. ' <me>')
			coroutine.sleep(9)
		end		
		if settings.trust5 ~= '"None"' then
			windower.send_command('input /ma ' .. settings.trust5 .. ' <me>')
			coroutine.sleep(9)
		end		

		
		--Check if all party members present before continuing due to teleport issues.
	
		--[[
		local wegood = checkpartymembers()
		while wegood == false do
			log('Waiting for party members to ready.')
			coroutine.sleep(5)
			wegood = checkpartymembers()
		end
		--]]
		
		--Everyone here
		log('All members present, continuing')
		
		coroutine.sleep(30)
		windower.ffxi.turn(-3.95)
		coroutine.sleep(.5)
		log('Moving to pull location.')
		windower.ffxi.run(true)
		coroutine.sleep(9.3)
		windower.ffxi.run(false)
		windower.ffxi.run(false)
		windower.send_command('input /heal')
		coroutine.sleep(5)
		windower.send_command('input /heal')
		windower.ffxi.run(false)
		windower.ffxi.run(false)

		log('Arrived at pull location.')
		coroutine.sleep(5)
				
		windower.send_command('multi fon')
		coroutine.sleep(3)
		windower.send_command('multi on')
		coroutine.sleep(5)
		log('Turning on addon for single PC, no difference between single and in trust leader')
		windower.send_command('hb on')
		windower.send_command('roller on')
		windower.send_command('autogeo on')
		windower.send_command('singer on')
		coroutine.sleep(5)
	
	else

		--[[
		local wegoodalt = checkpartymembers()
		while wegoodalt == false do
			log('Waiting for party members to ready.')
			coroutine.sleep(5)
			wegoodalt = checkpartymembers()
		end
		--]]
		
		log('Waiting for main to follow to pull location.')
		coroutine.sleep(125)
	end
	
	start()

end

function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * settings.send_all_delay
        end
    end
end

function get_running_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * 4
        end
    end
end


function checkpartymembers()
	
	allmemberspresent = true
	tempflag = false
	members = windower.ffxi.get_party()
	
    for k, v in pairs(members) do
		if type(v) == 'table' then
			if v.name ~= currentPC.name then
				ptymember = windower.ffxi.get_mob_by_name(v.name)
				-- check if party member in same zone.
				if v.mob == nil then
					allmemberspresent = false
				else
					--Do distance check
					if math.sqrt(ptymember.distance) < 15 then
						tempflag = true
					else
						tempflag = false
					end
					-- If only 1 party member further, then false.
					if tempflag == false then
						allmemberspresent = false
					end
				end
			end
		end
	end

	return allmemberspresent
end


windower.register_event('ipc message', function(msg) 

	local args = msg:split(' ')
	local cmd = args[1]
	local cmd2 = args[2]
	args:remove(1)

	local delay = get_delay()
	
	if cmd == 'quetz_start' then
		log('IPC Quetz START')
		coroutine.sleep(delay)
		ipcflag = true
		begin(cmd2)
	elseif cmd == 'quetz_stop' then
		log('IPC Quetz STOP!')
		coroutine.sleep(delay)
		ipcflag = true
		stop()
	end
	
end)

windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
	local args = {...}
	
	if cmd == 'stop' then
		stop()
    elseif cmd == 'start' then
		begin()
	elseif cmd == 'debugtest' then
		enterReisen()
    end
end)

windower.register_event('load', function()
	log('Attempting to load necessary addons.')
	log('\r')
	log('WARNING:  If you do not have these addons, Quetz will not work correctly!')
	log('--- Superwarp, SetTarget, Anchor, AutoWS, HealBot ---')
	log('These are available at my github page which are forked from originals')
	log('\r')
	log('If you are multiboxing and in same party, you must have multictrl!')
	log('Quetz is intended to use with multibox within same party, leader calling the shots.')
	coroutine.sleep(1)
	windower.send_command('lua l superwarp')
	windower.send_command('lua l settarget')
	windower.send_command('lua l anchor')
	windower.send_command('lua l autows')
	windower.send_command('lua l healbot')
	--windower.send_command('lua l multictrl')
end)


function validate()
	local zone = windower.ffxi.get_info()['zone']
	local me,target_index,target_id,distance
	local result = {}

	if valid_zones[zone] then
		for i,v in pairs(windower.ffxi.get_mob_array()) do
			if v['name'] == windower.ffxi.get_player().name then
				result['me'] = i
			elseif v['name'] == valid_zones[zone].npc then
				target_index = i
				target_id = v['id']
				npc_name = v['name']
				result['Menu ID'] = valid_zones[zone].menu
				distance = windower.ffxi.get_mob_by_id(target_id).distance
			end
		end

		if math.sqrt(distance)<6 then
			result['Target'] = target_id
			result['Option Index'] = 10
			result['_unknown1'] = 0
			result['Target Index'] = target_index
			result['Zone'] = zone 
		else
			windower.add_to_chat(10,"Too far from npc")
		end
	else
		windower.add_to_chat(10,"Not in a zone with proper npc")
	end
	if result['Zone'] == nil then result = nil end
	return result
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)

	if id == 0x034 or id == 0x032 then

		if busy == true and pkt then

			local packet = packets.new('outgoing', 0x05B)

			packet["Target"]=pkt['Target']
			packet["Option Index"]=pkt['Option Index']
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			
			packet["Target"]=pkt['Target']
			packet["Option Index"]=14
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)
			
			-- send exit menu
			packet["Target"]=pkt['Target']
			packet["Option Index"]=0
			packet["_unknown1"]=pkt['_unknown1']
			packet["Target Index"]=pkt['Target Index']
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=pkt['Zone']
			packet["Menu ID"]=pkt['Menu ID']
			packets.inject(packet)

			local packet = packets.new('outgoing', 0x016, {["Target Index"]=pkt['me'],})
			packets.inject(packet)
			busy = false
			lastpkt = pkt
			pkt = {}
			return true
		end
	end

end)


function poke_npc(npc,target_index)
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=npc,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end