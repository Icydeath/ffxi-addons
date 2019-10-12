local warp_zones = S{ 232, 236, 240, 246, 243, 242 } -- ports + ru'lude and heaven's tower
local entry_zones = S{ 102, 108, 117, 118, 103, 104, 107, 106, 112 } 
local teleport_npcs = S{ "Ernst", "Ivan", "Willis", "Horst", "Kierron", "Vincent"}
local abyssea_zones = S{ 15, 45, 132, 215, 216, 217, 218, 253, 254}
return T{
	short_name = 'ab',
	long_name = 'veridical conflux',
	npc_names = T{
		warp = T{'Veridical Conflux', 'Ernst', 'Ivan', 'Willis', 'Horst', 'Kierron', 'Vincent'},
		enter = T{'Cavernous Maw'},
	},
	move_in_zone = true,
	help_text = "[sw] ab [warp/w] [all/a/@all] conflux number -- warp to a designated conflux in your current abyssea zone.\n[sw] ab [all/a/@all] enter -- enter the abyssea zone corresponding to the entrance zone.",
	sub_zone_targets =  S{'00', '0', '1', '2', '3', '4', '5', '6', '7', '8', 'Cavernous Maw'},
	auto_select_zone = function(zone)
		if zone == 15 then return 'Abyssea - Konschtat' end
		if zone == 45 then return 'Abyssea - Tahrongi' end
		if zone == 132 then return 'Abyssea - La Theine' end
		if zone == 215 then return 'Abyssea - Attohwa' end
		if zone == 216 then return 'Abyssea - Misareaux' end
		if zone == 217 then return 'Abyssea - Vunkerl' end
		if zone == 218 then return 'Abyssea - Altepa' end
		if zone == 253 then return 'Abyssea - Uleguerand' end
		if zone == 254 then return 'Abyssea - Grauberg' end
	end,
	auto_select_sub_zone = function(zone)
		if warp_zones:contains(zone) then return 'Cavernous Maw' end
	end,
	build_warp_packets = function(npc, zone, menu, settings, move_in_zone)
		local p = T{}
		local packet = nil

		if zone == settings.zone then
			-- have xyz data and within zone. must be conflux.

			-- request map
			--packet = packets.new('outgoing', 0x114)
			--packet.debug_desc = 'request map'
	        --p:append(packet)

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

			packet["Option Index"] = settings.index
			packet["_unknown1"] = 0
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet.debug_desc = 'complete menu'
			p:append(packet)
			
		else
			-- no xyz data, must be a zone warp.

			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Option Index"] = settings.index
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
			packet["Option Index"] = settings.index
			packet["_unknown1"] = 0
			packet["Target Index"] = npc.index
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet["Zone"] = zone
			packet["Menu ID"] = menu
			packet.debug_desc = 'zone warp request'
			p:append(packet)
		end

		return p
	end,
	sub_commands = {
		enter = function(npc, zone, menu, settings)
			local p = T{}
			local packet = packets.new('outgoing', 0x05B)

			-- La theine, konschtat or tahrongi, Buburimu, Valkurm, or Jugner, South Gustaberg, Xarcabard or Qufim
			if not entry_zones:contains(zone) then -- we're not in an entry zone...
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
	            packet["Option Index"] = 1
	            packet["_unknown1"] = 0
	            packet["Target Index"] = npc.index
	            packet["Automated Message"] = false
	            packet["_unknown2"] = 0
	            packet["Zone"] = zone
	            packet["Menu ID"] = menu
				packet.debug_desc = 'zone warp request'
	            p:append(packet)

				log("Entering Abyssea")
			end

			return p
		end,
	},

	['Abyssea - La Theine'] = T{
		['Cavernous Maw'] = { index = 260 }, 
		['1'] = { index = 1, zone = 132, x = -480, z = -0.4, y = 764, },
		['2'] = { index = 2, zone = 132, x = -593.811, z = -16.3, y = 30.151, },
		['3'] = { index = 3, zone = 132, x = -122.966, z = -8.6, y = -38.954, },
		['4'] = { index = 4, zone = 132, x = -54.616, z = 29.2, y = 175.25, },
		['5'] = { index = 5, zone = 132, x = 201.681, z = 23.3, y = -398.155, },
		['6'] = { index = 6, zone = 132, x = 595.377, z = 39.4, y = -507.186, },
		['7'] = { index = 7, zone = 132, x = 494.223, z = 39.6, y = 333.094, },
		['8'] = { index = 8, zone = 132, x = 215.145, z = 15.8, y = -198.918, },
	},
	['Abyssea - Konschtat'] = T{
		['Cavernous Maw'] = { index = 264 }, 
		['1'] = { index = 1, zone = 15, x = 126, z = -72.8, y = -834, },
		['2'] = { index = 2, zone = 15, x = -164, z = -32.7, y = -276, },
		['3'] = { index = 3, zone = 15, x = -644, z = -0.7, y = 124, },
		['4'] = { index = 4, zone = 15, x = 20, z = 8.7, y = 45, },
		['5'] = { index = 5, zone = 15, x = -125, z = 15.2, y = 282, },
		['6'] = { index = 6, zone = 15, x = -316, z = 47.1, y = 564, },
		['7'] = { index = 7, zone = 15, x = 476, z = 7.3, y = 124, },
		['8'] = { index = 8, zone = 15, x = 244, z = 39.2, y = 636, },
	},
	['Abyssea - Tahrongi'] = T{
		['Cavernous Maw'] = { index = 268 }, 
		['1'] = { index = 1, zone = 45, x = 7.826, z = 31.515, y = -636.834, },
		['2'] = { index = 2, zone = 45, x = 24.01, z = -16.682, y = -171.587, },
		['3'] = { index = 3, zone = 45, x = -290.784, z = -25.574, y = -171.655, },
		['4'] = { index = 4, zone = 45, x = -239.868, z = 7.47, y = 166.166, },
		['5'] = { index = 5, zone = 45, x = -56.126, z = 31.085, y = 547.426, },
		['6'] = { index = 6, zone = 45, x = -64.581, z = 36.774, y = 331.84, },
		['7'] = { index = 7, zone = 45, x = 120.149, z = 15.776, y = 155.141, },
		['8'] = { index = 8, zone = 45, x = 324.225, z = 39.661, y = 433.333, },
	},
	['Abyssea - Vunkerl'] = T{
		['Cavernous Maw'] = { index = 272 }, 
		['1'] = { index = 1, zone = 217, x = -322, z = -40.523, y = 676, },
		['2'] = { index = 2, zone = 217, x = -24.502000808716, z = -34.138999938965, y = 370.20001220703, },
		['3'] = { index = 3, zone = 217, x = 202.532, z = -31.807, y = 312.143, },
		['4'] = { index = 4, zone = 217, x = -266.898, z = -41.942, y = -111.422, },
		['5'] = { index = 5, zone = 217, x = -118.682, z = -39.894, y = -477.375, },
		['6'] = { index = 6, zone = 217, x = -100, z = -56, y = -764.016, },
		['7'] = { index = 7, zone = 217, x = -675.132, z = -45.693, y = -555.552, },
		['8'] = { index = 8, zone = 217, x = -291.04, z = -32.02, y = 282.571, },
		['00'] = { index = 9, zone = 217, x = 158, z = -38.1, y = -158, },
	},
	['Abyssea - Misareaux'] = T{
		['Cavernous Maw'] = { index = 276 }, 
		['1'] = { index = 1, zone = 216, x = 634, z = -16.5, y = 286, },
		['2'] = { index = 2, zone = 216, x = 399.449, z = -6.755, y = 33.191, },
		['3'] = { index = 3, zone = 216, x = -96.818, z = -33.828, y = 254.32, },
		['4'] = { index = 4, zone = 216, x = 141.423, z = -10.116, y = -222.391, },
		['5'] = { index = 5, zone = 216, x = -40.898, z = -24.068, y = 439.29, },
		['6'] = { index = 6, zone = 216, x = -231.253, z = -32.804, y = 208.758, },
		['7'] = { index = 7, zone = 216, x = 288.974, z = 23.489, y = -407.234, },
		['8'] = { index = 8, zone = 216, x = 648.311, z = -0.016, y = -476.111, },
		['00'] = { index = 9, zone = 216, x = 276, z = -16.342, y = 236, },
	},
	['Abyssea - Attohwa'] = T{
		['Cavernous Maw'] = { index = 280 }, 
		['1'] = { index = 1, zone = 215,  x = -140, z = 19.5, y = -200, },
		['2'] = { index = 2, zone = 215, x = -485.504, z = -3.996, y = -4.940, },
		['3'] = { index = 3, zone = 215, x = 258.909, z = 20.941, y = -21.157, },
		['4'] = { index = 4, zone = 215, x = -603.877, z = -4.321, y = 191.936, },
		['5'] = { index = 5, zone = 215, x = 466.831, z = 20.555, y = 78.005, },
		['6'] = { index = 6, zone = 215, x = -247.103, z = 13.979, y = 283.572, },
		['7'] = { index = 7, zone = 215, x = 378.845, z = 20, y = -141.945, },
		['8'] = { index = 8, zone = 215, x = 1.446, z = -3.652, y = 150.792, },
		['00'] = { index = 9, zone = 215, x = -280, z = -4.5, y = 0, },
	},
	['Abyssea - Altepa'] = T{
		['Cavernous Maw'] = { index = 284 }, 
		['1'] = { index = 1, zone = 218, x = 404, z = -0.300, y = 288, },
		['2'] = { index = 2, zone = 218, x = 639, z = 0, y = -126, },
		['3'] = { index = 3, zone = 218, x = -80, z = 0, y = 437, },
		['4'] = { index = 4, zone = 218, x = -323, z = 0.878, y = -263, },
		['5'] = { index = 5, zone = 218, x = -477, z = -1, y = -684, },
		['6'] = { index = 6, zone = 218, x = -640, z = 0, y = -242, },
		['7'] = { index = 7, zone = 218, x = -604, z = -1, y = -39, },
		['8'] = { index = 8, zone = 218, x = -826, z = -10, y = -591, },
	},
	['Abyssea - Uleguerand'] = T{
		['Cavernous Maw'] = { index = 288 }, 
		['1'] = { index = 1, zone = 253, x = -202, z = -39.900, y = -506, },
		['2'] = { index = 2, zone = 253, x = -381.055, z = -25.283, y = -169.200, },
		['3'] = { index = 3, zone = 253, x = -300.773, z = -53.509, y = -34.171, },
		['4'] = { index = 4, zone = 253, x = 137.366, z = 0.100, y = -368.519, },
		['5'] = { index = 5, zone = 253, x = 576.008, z = -36.076, y = -8.386, },
		['6'] = { index = 6, zone = 253, x = 338.860, z = -100.288, y = 500.109, },
		['7'] = { index = 7, zone = 253, x = -257.359, z = -176.335, y = 236.791, },
		['8'] = { index = 8, zone = 253, x = -582.977, z = -40.378, y = 45.543, },
	},
	['Abyssea - Grauberg'] = T{
		['Cavernous Maw'] = { index = 292 }, 
		['1'] = { index = 1, zone = 254, x = -514.000, z = 22.417, y = -756.000, },
		['2'] = { index = 2, zone = 254, x = 321.833, z = 31.439, y = -557.983, },
		['3'] = { index = 3, zone = 254, x = 423.950, z = -0.893, y = -174.130, },
		['4'] = { index = 4, zone = 254, x = -26.465, z = -0.935, y = -464.546, },
		['5'] = { index = 5, zone = 254, x = -165.414, z = -32.099, y = 405.608, },
		['6'] = { index = 6, zone = 254, x = 102.165, z = 16.462, y = 497.289, },
		['7'] = { index = 7, zone = 254, x = -323.073, z = -127.969, y = 113.653, },
		['8'] = { index = 8, zone = 254, x = 490.776, z = -5.546, y = 340.563, },
	},
}

