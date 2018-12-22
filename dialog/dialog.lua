--[[
		Commands:
		//d m [mission name] :	Toggles the status flag. If status flag is true, it will automatically send the mission's packet 
								when you talk to NPC without manually selecting any of the NPC's options.
								NOTE: You can only have one of each "type" set to true; all others will be set to false. For example, 
								only one homepoint or voidwatch mission.
		//d [mission name] : Initiates dialogue with the NPC of the appropriate mission, then exits out of the menu.
		//d echo : Toggles echo on/off. Prints "choice" string to console when interacting with NPCs.
]]


_addon.version = '2.800'
_addon.name = 'dialog'
_addon.author = 'People'
_addon.commands = {'dialog','d'}

require 'pack'
require 'sets'
require 'lists'
require 'tables'
require 'strings'

echo = false
follow = true
messageColor = 200

history = {}

missions = {
    shield = {desc="Acheron Shield", type="roe", choice = string.char(9,0,0x29,0), status=false},
	buckler = {desc="Darksteel Buckler", type="roe", choice = string.char(8,0,36,0), status=false},
    
    rubicund = {desc="Rubicund Cells x 12", type="vw", choice = string.char(2,0,2,3), status=true},
	cobalt = {desc="Cobalt Cells x 12", type="vw", choice = string.char(2,0,1,3), status=false},
	voidstone = {desc="Voidstones x 6", type="vw", choice = string.char(1,0,0,0), status=false},	
	
	voidwrought = {desc="Voidwrought Teleport", type="vw_port", choice = string.char(2,0,0x12,0), status=false},	
	celaeno = {type="vw_port", choice = string.char(2,0,12,0), status=false},	
	morta = {type="vw_port", choice = string.char(2,0,0x41,0), status=false},		
	akvan = {type="vw_port", choice = string.char(2,0,0x20,0), status=false},
	hahava = {type="vw_port", choice = string.char(2,0,6,0), status=false},
	pil = {type="vw_port", choice = string.char(2,0,0x21,0), status=false},
	bismarck = {type="vw_port", choice = string.char(2,0,0x3C,0), status=false},
	
	pop_vw = {type="rift", choice = string.char(1,0,0,0), status=false},
	vw3 = {type="rift", choice = string.char(0x31,0,0,0), status=true},
	vw5 = {type="rift", choice = string.char(0x51,0,0,0), status=false},
	
	roma = {type="sg", choice = string.char(1,1,0x30,0), status=false},
	
	pjeuno1 = {desc="Port Jeuno Exit", type="hp", choice = string.char(2,0,0x25,0), status=false},
	pjeuno2 = {desc="Port Jeuno Moghouse", type="hp", choice = string.char(2,0,0x26,0), status=false},	
	upjeuno1 = {desc="Upper Jeuno Exit", type="hp", choice = string.char(2,0,0x20,0), status=false},	
	rulude1 = {desc="Ru'Lude Palace", type="hp", choice = string.char(2,0,0x1D,0), status=false},	
	psandy2 = {desc="Port San d'Oria Moghouse", type="hp", choice = string.char(2,0,7,0), status=false},			
	ssandy1 = {desc="South San d'Oria Exit (to West Ronfaure)", type="hp", choice = string.char(2,0,0,0), status=false},	
	nsandy2 = {desc="North San d'Oria (Merit point)", type="hp", choice = string.char(2,0,4,0), status=false},	
	nsandy4 = {desc="North San d'Oria (Guild)", type="hp", choice = string.char(2,0,0x62,0), status=false},
	sandys = {desc="San d'Oria [S]", type="hp", choice = string.char(2,0,0x44,0), status=false},
	pbastok1 = {desc="Port Bastok", type="hp", choice = string.char(2,0,0x0F,0), status=false},		
	diabolos = {desc="Pso X'ja", type="hp", choice = string.char(2,0,0x52,0), status=false},	
	woe = {desc="WoE", type="hp", choice = string.char(2,0,0x6F,0), status=false},
	rulude = {desc="Ru'Lude Gardens", type="hp", choice = string.char(2,0,0x1E,0), status=false},
	--Port Windurst Moghouse 2 0 18 0 
	wwoods2 = {desc="Windurst Woods Exit", type="hp", choice = string.char(2,0,0x1A,0), status=false},	
	tav = {desc="Tavnazia", type="hp", choice = string.char(2,0,0x40,0), status=false},	
	norg = {desc="Norg", type="hp", choice = string.char(2,0,0x29,0), status=false},		
	wadoulin1 = {desc="West Adoulin AH", type="hp", choice = string.char(2,0,0x2C,0), status=false},		
	eadoulin1 = {desc="East Adoulin (Ionis NPC)", type="hp", choice = string.char(2,0,0x2D,0), status=false},	
	qufim = {desc="Qufim (Escha-Zi'Tah)", type="hp", choice = string.char(2,0,0x72,0), status=false},					
	zvahl1 = {desc="Zvahl", type="hp", choice = string.char(2,0,0x3A,0), status=false},		
	balga = {desc="Balga Dais", type="hp", choice = string.char(2,0,0x36,0), status=false},						
	oracles = {desc="Chamber of Oracles", type="hp", choice = string.char(2,0,0x38,0), status=false},												
	aagk = {desc="Ru'Aun (Ark Angel GK)", type="hp", choice = string.char(2,0,0x3F,0), status=false},												
	misa = {desc="Misareaux (Escha-Ru'Aun)", type="hp", choice = string.char(2,0,0x75,0), status=false},	
	rancorden1 = {desc="Den of Rancor", type="hp", choice = string.char(2,0,0x39,0), status=false},
	ramuh = {desc="Ramuh BC", type="hp", choice = string.char(2,0,0x5C,0), status=false},		
	mova = {desc="Newton", type="hp", choice = string.char(2,0,0x53,0), status=false},
	feiyin = {desc="Fei'Yin 1", type="hp", choice = string.char(2,0,0x37,0), status=false},
	rulude = {desc="Ru'Lude Gardens", type="hp", choice = string.char(2,0,0x1E,0), status=false},
	delk = {desc="Upper Delfutt's Tower", type="hp", choice = string.char(2,0,0x47,0), status=false},
	ruhmet = {desc="Garden of Ru'Hmet", type="hp", choice = string.char(2,0,0x59,0), status=false},
	
	yorcia = {type="wp", choice = string.char(0x47,0,0,0), status=false},						
	foret4 = {type="wp", choice = string.char(0x37,0,0,0), status=false},		
	marjami4 = {type="wp", choice = string.char(0x55,0,0,0), status=false},	
	
	uleg = {type="abyssea_port", choice = string.char(0x20,1,0,0), status=false},	
	graub = {type="abyssea_port", choice = string.char(0x24,1,0,0), status=false},	
	atto = {type="abyssea_port", choice = string.char(0x18,1,0,0), status=false},
	misa = {type="abyssea_port", choice = string.char(0x14,0x1,0,0), status=false},
		
	traverser = {type="traverser", choice = string.char(6,0,0,0), status=true},	
	ionis = {type="ionis", choice = string.char(1,0,0,0), status=true},	
	signet = {type="signet", choice = string.char(1,0,0,0), status=true},
	cruorbuffs = {type="cruor", choice = string.char(4,0,0x0B,0), status=true},	
	
	macro = {type="orb", choice = string.char(0x0F,0,0,0), status=false},	
	
	sr = {type="sr", choice = string.char(2,0,0,0), status=true},
	
	obtainchest = {type="chest", choice=string.char(0xA,0,0,0), status =true},
	
	displacer = {type="vw_displacer", choice=string.char(0x1,0,0x5,0), status =false},
	
	--zitah6 = {desc="Escha-Zitah #6", type="ethereal", choice= string.char(), status=false},
	
	
	-- SURVIVAL GUIDE: Need to figure out how to distinguish between spending points and gil
	--qilin = {desc="Ru'Aun Survival Guide", type="sg", choice = string.char(1,0,0,0), status=false},       
}

npcs = {
	hp = S{'Home Point #1', 'Home Point #2', 'Home Point #3', 'Home Point #4', 'Home Point #5', 'Home Point #6'},
	wp = S{"Waypoint"},
	roe = S{'Eternal Flame','Rolandienne','Isakoth','Fhelm Jobeizat'},
	vw = S{'Voidwatch Officer', 'Owain', 'Hildegarde'},
	vw_port = S{'Atmacite Refiner'},
	vw_displacer = S{'Ardrick'},
	rift = S{'Planar Rift'},
	gt = S{'Grounds Tome'},
	sg = S{'Survival Guide'},
--	tribulens = S{'Affi', 'Dremi', 'Shiftrix'},
	signet = S{'Kochahy-Muwachahy'}, -- Missing a lot of NPCs from this
	ionis = S{'Fleuricette','Quiri-Aliri'},
	cruor = S{'Cruor Prospector'},
	traverser = S{'Joachim'},
	abyssea_port = S{"Horst","Vincent"},
	orb = S{"Shami"},
	unity = S{},
	ethereal = S{"Ethereal Radiance"},
	sr = S{"Malobra"},
	chest = S{"Riftworn Pyxis"},
}

windower.register_event('addon command', function(...)
    local args = {...}
    if args[1] == 'mission' or args[1] == 'm' then	
		if args[2] and missions[args[2]] then	--setting mission	
			local desc = missions[args[2]].desc or args[2]
			
			if missions[args[2]].status then
				missions[args[2]].status = false
				message('Disabled: '..desc)
			else	
				new_mission = missions[args[2]]
				for m_name,m_table in pairs(missions) do
					if m_table.status and m_table.type == new_mission.type then
						m_table.status = false
						local m_desc = m_table.desc or m_name
						message('Disabled: '..m_desc)
					end
				end				
				missions[args[2]].status = true
				message('Enabled: '..desc)
			end
		elseif args[2] then
			
		else	--printing current missions
			for m_name,m_table in pairs(missions) do
				if m_table.status then
					local m_desc = m_table.desc or m_name
					message('Currently Enabled: '..m_desc)
				end
			end
		end
	elseif missions[args[1]] then
		npc_routine(args[1])
	elseif args[1] == 'echo' then
		if echo then echo = false message('Dialog Echo: Off') else echo = true message('Dialog Echo: On') end
	elseif args[1] == 'color' then
		for i=1,255,1 do
			windower.add_to_chat(i,i..' test')
		end
	end
end )

windower.register_event('outgoing chunk', function(id,original)     	
	if id == 0x5B then
		local a,b,c,d = string.byte(original:sub(9)), string.byte(original:sub(10)), string.byte(original:sub(11)), string.byte(original:sub(12))
		
		if echo then
			local str = string.format( '0x%X 0x%X 0x%X 0x%X', a, b, c, d )	
			print(string.format('Dialog Index: [%s]',str))
		end	
	
		local target = (windower.ffxi.get_mob_by_id(original:unpack('I',5)) or {}).name
		local original_choice = original:unpack('I',9)

		if original_choice == 0 or original_choice == 0x40000000 then
			for m_name,m_table in pairs(missions) do
				if m_table.status then
					local valid_targets = npcs[m_table.type]
					
					if valid_targets[target] then
						local new_choice = m_table.choice --get global variable
						local new_packet = original:sub(1,8) .. new_choice .. original:sub(13)
						return new_packet
					end
				end
			end
		elseif a == 8 and npcs.hp[target] then
			for m_name,m_table in pairs(missions) do
				if m_table.type=="hp" and m_table.status then
					local desc = m_table.desc or m_name
					message("Dialog Destination: "..desc)
				end
			end
		end
	elseif id == 0x1A then
		-- print(original:unpack('I',5))
		-- print(original:unpack('I',6))
		-- print(original:unpack('I',7))
		-- print(original:unpack('I',8))
		-- local mob_array = windower.ffxi.get_mob_array()
		-- for i,mob in pairs(mob_array) do
			-- if (mob.name=="Home Point #2") then
				-- if tonumber(math.sqrt(mob.distance,1)) <= 6 then
					-- print(mob.id)       	
				-- end
			-- end
		-- end
    end
end)

function npc_routine(mission)
	npc_send_packet(mission)
	--if hp						esc
	--if wp						esc
	--if roe					esc
	--if vw
	--if vw_port				enter 
	--if rift
	--if gt						esc
	--if sg
	--if tribulens				esc
	--if signet					enter
	--if ionis					esc
	--if cruor					esc
	--if atma					esc
	--if traverser				right > right > right > enter
	--if abyssea_port			right > right > enter
	--if orb					esc
	--if sr						esc
end

function npc_send_packet(mission)
	local npc_id, npc_index = npc_info(mission)
	send_npc_init_packet(npc_id, npc_index)
end

function npc_info(mission)
	local mob_array = windower.ffxi.get_mob_array()
    for i,mob in pairs(mob_array) do
        if npcs[missions[mission].type]:contains(mob.name) then
			if tonumber(math.sqrt(mob.distance,1)) <= 6 then
				return mob.id, mob.index       	
			end
        end
    end
    return false
end

function send_npc_init_packet(npc_id, npc_index)    
    -- init packet
	local packet = {}
	for i=1,28 do
		packet[i] = 0x00
	end
	
	-- converts the given id into a table of hex packets
    local id_result = { }
    local id_n = math.ceil( select( 2, math.frexp( npc_id ) ) / 8 )
    for x = id_n, 1, -1 do
        local mul = 2 ^ ( 8 * ( x - 1 ) )
        id_result[x] = math.floor( npc_id / mul )
        npc_id = npc_id - id_result[x] * mul
    end
	
	-- converts the given index into a table of hex packets
	local index_result = { }
    local index_n = math.ceil( select( 2, math.frexp( npc_index ) ) / 8 )
    for x = index_n, 1, -1 do
        local mul = 2 ^ ( 8 * ( x - 1 ) )
        index_result[x] = math.floor( npc_index / mul )
        npc_index = npc_index - index_result[x] * mul
    end

	-- set the id bytes
	packet[5] = id_result[1] or 0
	packet[6] = id_result[2] or 0
	packet[7] = id_result[3] or 0
	packet[8] = id_result[4] or 0
	
	-- set the index bytes
	packet[9] = index_result[1] or 0
	packet[10] = index_result[2] or 0
	
	-- set the param/category
	packet[11] = 0x00; --param/category

    --local strPacket = string.char(0x1A,packet[1],packet[2],packet[3],packet[4],packet[5],packet[6],packet[7],packet[8],packet[9],packet[10],packet[11],packet[12],packet[13],packet[14],packet[15],packet[16],packet[17],packet[18],packet[19],packet[20],packet[21],packet[22],packet[23],packet[24],packet[25],packet[26],packet[27],packet[28])
	local strPacket = 0x1A
	for k, v in pairs(packet) do
        strPacket = strPacket .. v
    end

	--windower.packets.inject_outgoing(0x1A,strPacket)
end

function message(message)
	windower.add_to_chat(messageColor,'Dialog:: '..tostring(message)..'')
end