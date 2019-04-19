return T{
	short_name = 'wp',
	long_name = 'waypoint',
	npc_names = T{
		warp = T{'Waypoint'},
	},
	move_in_zone = true,
	help_text = "[sw] wp [warp/w] [all/a/@all] zone name [waypoint_number] -- warp to a designated waypoint. \"all\" sends ipc to all local clients.",
	sub_zone_targets =  S{'frontier station', 'platea', 'triumphus', 'couriers', 'pioneers', 'mummers', 'inventors', 'auction house', 'mog house', 'bridge', 'airship', 'docks', 'waterfront', 'peacekeepers', 'scouts', 'statue', 'goddess', 'wharf', 'yahse', 'sverdhried', 'hillock', 'coronal', 'esplanade', 'castle', 'gates', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'enigmatic device'},
	build_warp_packets = function(npc, zone, menu, settings, move_in_zone)
		local p = T{}
		local packet = nil

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

		packet["Option Index"] = settings.index
		packet["_unknown1"] = 0
		packet["Automated Message"] = true
		packet["_unknown2"] = 0
		packet.debug_desc = 'menu change'
		p:append(packet)

		if move_in_zone and settings.zone == zone and settings.x and settings.y and settings.z  then
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

			packet["Option Index"] = 0
			packet["_unknown1"] = 0
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet.debug_desc = 'complete menu'
			p:append(packet)
		else

			-- request warp
			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["Option Index"] = settings.index
			packet["_unknown1"] = 0
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet.debug_desc = 'zone warp request'
			p:append(packet)			
		end

		return p
	end,
	['Western Adoulin'] = {
		['Platea'] = { shortcut = '1' },
		['Triumphus'] = { shortcut = '1' },
		['Couriers'] = { shortcut = '1' },
		['Pioneers'] = { shortcut = '2' },
		['Mummers'] = { shortcut = '3' },
		['Inventors'] = { shortcut = '4' },
		['Auction House'] = { shortcut = '5' },
		['Mog House'] = { shortcut = '6' },
		['Bridge'] = { shortcut = '7' },
		['Airship'] = { shortcut = '8' },
		['Docks'] = { shortcut = '8' },
		['Waterfront'] = { shortcut = '9' },
		['1'] = { index = 1, zone = 256, x = 4.896, z = 0, y = -4.789, },
		['2'] = { index = 2, zone = 256, x = -110.5, z = 3.85, y = -13.482, },
		['3'] = { index = 3, zone = 256, x = -20.982, z = -0.15, y = -79.891, },
		['4'] = { index = 4, zone = 256, x = 91.451, z = -0.15, y = -49.013, },
		['5'] = { index = 5, zone = 256, x = -68.099, z = 4, y = -73.672, },
		['6'] = { index = 6, zone = 256, x = 5.731, z = 0, y = -123.043, },
		['7'] = { index = 7, zone = 256, x = 174.783, z = 3.85, y = -35.788, },
		['8'] = { index = 8, zone = 256, x = 14.586, z = 0, y = 162.608, },
		['9'] = { index = 9, zone = 256, x = 51.094, z = 32, y = 126.299, },
	},
	['Eastern Adoulin'] = {
		['Peacekeepers'] = { shortcut = '1' },
		['Scouts'] = { shortcut = '2' },
		['Statue'] = { shortcut = '3' },
		['Goddess'] = { shortcut = '3' },
		['Wharf'] = { shortcut = '4' },
		['Yahse'] = { shortcut = '4' },
		['Mog House'] = { shortcut = '5' },
		['Auction House'] = { shortcut = '6' },
		['Sverdhried'] = { shortcut = '7' },
		['Hillock'] = { shortcut = '7' },
		['Hill'] = { shortcut = '7' },
		['Coronal'] = { shortcut = '8' },
		['Esplanade'] = { shortcut = '8' },
		['Castle'] = { shortcut = '9' },
		['Gates'] = { shortcut = '9' },
		['1'] = { index = 21, zone = 257, x = -101.274, z = -0.15, y = -10.726, },
		['2'] = { index = 22, zone = 257, x = -77.944, z = -0.15, y = -63.926, },
		['3'] = { index = 23, zone = 257, x = -46.838, z = -0.075, y = -12.767, },
		['4'] = { index = 24, zone = 257, x = -57.773, z = -0.15, y = 85.237, },
		['5'] = { index = 25, zone = 257, x = -61.865, z = -0.15, y = -120.81, },
		['6'] = { index = 26, zone = 257, x = -42.065, z = -0.15, y = -89.979, },
		['7'] = { index = 27, zone = 257, x = 11.681, z = -22.15, y = 29.976, },
		['8'] = { index = 28, zone = 257, x = 27.124, z = -40.15, y = -60.844, },
		['9'] = { index = 29, zone = 257, x = 95.994, z = -40.15, y = -74.541, },
	},
	['Yahse Hunting Grounds'] = {
		['Frontier Station'] = { index = 31, zone = 260, x = 321, z = 0, y = -199.8, },
		['1'] = { index = 32, zone = 260, x = 86.5, z = 0, y = 1.5, },
		['2'] = { index = 33, zone = 260, x = -286.5, z = 0, y = 43.5, },
		['3'] = { index = 34, zone = 260, x = -162.4, z = 0, y = -272.8, },
	},
	['Ceizak Battlegrounds'] = {
		['Frontier Station'] = { index = 41, zone = 261, x = 365, z = 0, y = 190, },
		['1'] = { index = 42, zone = 261, x = -6.879, z = 0, y = -117.511, },
		['2'] = { index = 43, zone = 261, x = -42, z = 0, y = 155, },
		['3'] = { index = 44, zone = 261, x = -442, z = 0, y = -247, },
	},
	['Foret de Hennetiel'] = {
		['Frontier Station'] = { index = 51, zone = 262, x = 398.11, z = -2, y = 279.11, },
		['1'] = { index = 52, zone = 262, x = 12.6, z = -2.4, y = 342, },
		['2'] = { index = 53, zone = 262, x = 505, z = -2.25, y = -303.5, },
		['3'] = { index = 54, zone = 262, x = 103, z = -2.2, y = -92.3, },
		['4'] = { index = 55, zone = 262, x = -251.8, z = -2.37, y = -39.25, },
	},
	['Morimar Basalt Fields'] = {
		['Frontier Station'] = { index = 61, zone = 265, x = 443.728, z = -16, y = -325.428, },
		['1'] = { index = 62, zone = 265, x = 368, z = -16, y = 37.5, },
		['2'] = { index = 63, zone = 265, x = 112.8, z = -0.483, y = 324.4, },
		['3'] = { index = 64, zone = 265, x = 175.5, z = -15.581, y = -318.2, },
		['4'] = { index = 65, zone = 265, x = -323, z = -32, y = 2, },
		['5'] = { index = 66, zone = 265, x = -78.2, z = -47.284, y = 303, },
	},
	['Yorcia Weald'] = {
		['Frontier Station'] = { index = 71, zone = 263, x = 353.3, z = 0.2, y = 153.3, },
		['1'] = { index = 72, zone = 263, x = -40.499, z = 0.367, y = 296.367, },
		['2'] = { index = 73, zone = 263, x = 122.132, z = 0.146, y = -287.731, },
		['3'] = { index = 74, zone = 263, x = -274.776, z = 0.357, y = 85.376, },
		['Enigmatic Device'] = { index = 302 },
	},
	['Marjami Ravine'] = {
		['Frontier Station'] = { index = 81, zone = 266, x = 358, z = -60, y = 165, },
		['1'] = { index = 82, zone = 266, x = 323, z = -20, y = -79, },
		['2'] = { index = 83, zone = 266, x = 6.808, z = 0, y = 78.437, },
		['3'] = { index = 84, zone = 266, x = -318.708, z = -20, y = -127.275, },
		['4'] = { index = 85, zone = 266, x = -326.022, z = -40.023, y = 201.096, },
	},
	['Kamihr Drifts'] = {
		['Frontier Station'] = { index = 91, zone = 267, x = 439.403, z = 63, y = -272.554, },
		['1'] = { index = 92, zone = 267, x = -42.574, z = 43, y = -71.319, },
		['2'] = { index = 93, zone = 267, x = 8.24, z = 43, y = -283.017, },
		['3'] = { index = 94, zone = 267, x = 9.24, z = 23, y = 162.803, },
		['4'] = { index = 95, zone = 267, x = -228.942, z = 3.567, y = 364.512, },
	},
	['Jeuno'] = {
		['Enigmatic Device'] = { index = 100 },
	},
	['Rala Waterways'] = {
		['Enigmatic Device'] = { index = 300 },
	},
	['Cirdas Caverns'] = {
		['Enigmatic Device'] = { index = 301 },
	},
	['Outer Ra\'Kaznar'] = {
		['Enigmatic Device'] = { index = 303 },
	},
}