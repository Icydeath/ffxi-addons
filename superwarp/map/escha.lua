return T{
	short_name = 'ew',
	long_name = 'eschan portal',
	npc_names = T{
		warp = T{'Eschan Portal', 'Ethereal Ingress'},
		enter = T{'Undulating Confluence', 'Dimensional Portal'},
	},
	move_in_zone = true,
	help_text = "[sw] ew [warp/w] [all/a/@all] portal number -- warp to a designated portal in your current escha zone.\n[sw] ew [all/a/@all] enter -- enter the eschan zone corresponding to the entrance zone.",
	sub_zone_targets =  S{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14','15' },
	auto_select_zone = function(zone)
		if zone == 288 then return 'Escha Zi\'tah' end
		if zone == 289 then return 'Escha Ru\'an' end
		if zone == 291 then return 'Reisenjima' end
	end,
	build_warp_packets = function(npc, zone, menu, settings, move_in_zone)
		local p = T{}
		local packet = nil

		if zone == settings.zone then
			-- request map
			packet = packets.new('outgoing', 0x114)
			packet.debug_desc = 'request map'
	        p:append(packet)

			-- menu change
			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["Option Index"] = 1
			packet["_unknown1"] = settings.index
			packet["Automated Message"] = true
			packet["_unknown2"] = 0
			packet.debug_desc = 'menu change'
			p:append(packet)

			-- request in-zone warp
			packet = packets.new('outgoing', 0x05C)
			packet["Target ID"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["X"] = settings.x
			packet["Y"] = settings.y
			packet["Z"] = settings.z
			packet["_unknown1"] = 0
			packet["_unknown3"] = 0
			packet.debug_desc = 'same-zone move request'
			p:append(packet)

			-- complete menu
			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["Option Index"] = 2
			packet["_unknown1"] = 0
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet.debug_desc = 'complete menu'
			p:append(packet)
		else
			packet["Target"] = npc.id
			packet["Option Index"] = 0
			packet["_unknown1"] = 16384
			packet["Target Index"] = npc.index
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet["Zone"] = zone
			packet["Menu ID"] = menu
			packet.debug_desc = 'cancel menu'
			p:append(packet)
			log('WARNING: not in correct zone!')
		end

		return p
	end,
	sub_commands = {
		enter = function(npc, zone, menu, settings)
			local p = T{}
			local packet = packets.new('outgoing', 0x05B)

			local oi = 0

			-- qufim or misareaux
			if zone == 126 or zone == 25 then oi = 1 end
			-- La theine, konschtat or tahrongi
			if zone == 102 or zone == 108 or zone == 117 then oi = 2 end

			if oi == 0 then -- we're not in an entry zone...
				-- send the cancel menu packet.
				packet["Target"] = npc.id
				packet["Option Index"] = 0
				packet["_unknown1"] = 16384
				packet["Target Index"] = npc.index
				packet["Automated Message"] = false
				packet["_unknown2"] = 0
				packet["Zone"] = zone
				packet["Menu ID"] = menu
				packet.debug_desc = 'cancel menu'
				p:append(packet)
				log('WARNING: not in an entry zone!')
			else
				packet["Target"] = npc.id
	            packet["Option Index"] = 0
	            packet["_unknown1"] = 0
	            packet["Target Index"] = npc.index
	            packet["Automated Message"] = true
	            packet["_unknown2"] = 0
	            packet["Zone"] = zone
	            packet["Menu ID"] = menu
				packet.debug_desc = 'menu change'
	            p:append(packet)

				packet = packets.new('outgoing', 0x05B)
	            packet["Target"] = npc.id
	            packet["Option Index"] = oi
	            packet["_unknown1"] = 0
	            packet["Target Index"] = npc.index
	            packet["Automated Message"] = false
	            packet["_unknown2"] = 0
	            packet["Zone"] = zone
	            packet["Menu ID"] = menu
				packet.debug_desc = 'zone warp request'
	            p:append(packet)

				log("Entering Escha")
			end

			return p
		end,
	},
    ['Escha Zi\'tah'] = T{
        ['1'] = { index = 0, zone = 288, x = -343.00, z = -0.07, y = -172.00, },
        ['2'] = { index = 1, zone = 288, x = -303, z = -0.03, y = 308, },
        ['3'] = { index = 2, zone = 288, x = -261, z = 0.67, y = -16, },
        ['4'] = { index = 3, zone = 288, x = -110.00, z = 0.12, y = -241.00, },
        ['5'] = { index = 4, zone = 288, x = 245.00, z = 0.27, y = -148, },
        ['6'] = { index = 5, zone = 288, x = 452.00, z = 1.39, y = -344.00, },
        ['7'] = { index = 6, zone = 288, x = 191.00, z = 0.20, y = -318, },
        ['8'] = { index = 7, zone = 288, x = -134, z = 1.80, y = -454.00, },
    },
    ['Escha Ru\'an'] = T{
        ['1'] = { index = 8, zone = 289, x = 10, z = -34, y = -464.00, },
        ['2'] = { index = 9, zone = 289, x = -275.5, z = -40.50, y = -378.50, },
        ['3'] = { index = 10, zone = 289, x = -454.00, z = -3.50, y = -147.5, },
        ['4'] = { index = 11, zone = 289, x = -452.50, z = -71.42, y = -307.5, },
        ['5'] = { index = 12, zone = 289, x = -444.50, z = -40.50, y = 144, },
        ['6'] = { index = 13, zone = 289, x = -280.5, z = -3.50, y = 386.50, },
        ['7'] = { index = 14, zone = 289, x = -431.50, z = -71.85, y = 335.50, },
        ['8'] = { index = 15, zone = 289, x = 0, z = -40.50, y = 466.50, },
        ['9'] = { index = 16, zone = 289, x = 278.5, z = -3.63, y = 384.00, },
        ['10'] = { index = 17, zone = 289, x = 186.00, z = -71.85, y = 514.5, },
        ['11'] = { index = 18, zone = 289, x = 444.50, z = -40, y = 144, },
        ['12'] = { index = 19, zone = 289, x = 454.50, z = -3.60, y = -147.5, },
        ['13'] = { index = 20, zone = 289, x = 546.5, z = -71.5, y = -17, },
        ['14'] = { index = 21, zone = 289, x = 275, z = -40.50, y = -377.50, },
        ['15'] = { index = 22, zone = 289, x = -1.20, z = -52.00, y = -581.5, },
    },
	['Reisenjima'] = T{
        ['1'] = { index = 23, zone = 291, x = -495.44, z = -19, y = -476.48, },
        ['2'] = { index = 24, zone = 291, x = -404.00, z = -55.00, y = 86.00, },
        ['3'] = { index = 25, zone = 291, x = -530.4, z = -50.0, y = 399.75, },
        ['4'] = { index = 26, zone = 291, x = -554.40, z = -48.75, y = 602, },
        ['5'] = { index = 27, zone = 291, x = 107.0, z = -75.4, y = 599, },
        ['6'] = { index = 28, zone = 291, x = 243.5, z = -87.4, y = 106.0, },
        ['7'] = { index = 29, zone = 291, x = 641.6, z = -374.00, y = -912.2, },
        ['8'] = { index = 30, zone = 291, x = -368.72, z = -113.3, y = 212.45, },
        ['9'] = { index = 31, zone = 291, x = -581, z = -417.4, y = -1065, },
        ['10'] = { index = 32, zone = 291, x = -390.22, z = -439.71, y = -835.13, },
    },
}