return { -- option: 2
	short_name = 'hp',
	long_name = 'homepoint',
	npc_names = T{
		warp = T{'Home Point'},
		set = T{'Home Point'},
	},
	help_text = "[sw] hp [warp/w] [all/a/@all] zone name [homepoint_number] -- warp to a designated homepoint. \"all\" sends ipc to all local clients.\n[sw] hp [all/a/@all] set -- set the closest homepoint as your return homepoint",
	sub_zone_targets = S{'entrance', 'mog house', 'auction house', '1', '2', '3', '4', '5', '6', '7', '8', '9', },
	build_warp_packets = function(npc, zone, menu, settings)
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

		packet["Option Index"] = 8
		packet["_unknown1"] = 0
		packet["Automated Message"] = true
		packet["_unknown2"] = 0
		packet.debug_desc = 'menu change'
		p:append(packet)

		-- menu change
		packet = packets.new('outgoing', 0x05B)
		packet["Target"] = npc.id
		packet["Target Index"] = npc.index
		packet["Zone"] = zone
		packet["Menu ID"] = menu

		packet["Option Index"] = 2
		packet["_unknown1"] = 0
		packet["Automated Message"] = true
		packet["_unknown2"] = 0
		packet.debug_desc = 'menu change'
		p:append(packet)
	
		-- request warp
		packet = packets.new('outgoing', 0x05B)
		packet["Target"] = npc.id
		packet["Target Index"] = npc.index
		packet["Zone"] = zone
		packet["Menu ID"] = menu

		packet["Option Index"] = 2
		packet["_unknown1"] = settings.index
		packet["Automated Message"] = false
		packet["_unknown2"] = 0
		packet.debug_desc = 'zone warp request'
		p:append(packet)
		return p
	end,
	sub_commands = {
		set = function(npc, zone, menu, settings)
			local p = T{}
			local packet = nil
			
			-- menu change
			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["Option Index"] = 8
			packet["_unknown1"] = 0
			packet["Automated Message"] = true
			packet["_unknown2"] = 0
		    p:append(packet)
			
			-- select "set HP"
			packet = packets.new('outgoing', 0x05B)
			packet["Target"] = npc.id
			packet["Target Index"] = npc.index
			packet["Zone"] = zone
			packet["Menu ID"] = menu

			packet["Option Index"] = 1
			packet["_unknown1"] = 0
			packet["Automated Message"] = false
			packet["_unknown2"] = 0
			packet.debug_desc = 'hp set request'
			p:append(packet)

			return p
		end,
	},
	['Southern San d\'Oria'] = {
		['1'] = {index=0},
		['Entrance'] = {index=0},
		['2'] = {index=1},
		['Auction House'] = {index=1},
		['3'] = {index=2},
		['Mog House'] = {index=2},
		['4'] = {index=97},},
	['Northern San d\'Oria'] = {
		['1'] = {index=3},
		['Entrance'] = {index=3},
		['2'] = {index=4},
		['3'] = {index=5},
		['Mog House'] = {index=5},
		['4'] = {index=98},},
	['Port San d\'Oria'] = {
		['1'] = {index=6},
		['Mog House'] = {index=7},
		['2'] = {index=7},
		['Auction House'] = {index=8},
		['3'] = {index=8},},
	['Bastok Mines'] = {
		['1'] = {index=9},
		['Auction House'] = {index=9},
		['2'] = {index=10},
		['Mog House'] = {index=10},
		['3'] = {index=99},},
	['Bastok Markets'] = {
		['1'] = {index=11},
		['Entrance'] = {index=11},
		['2'] = {index=12},
		['Auction House'] = {index=12},
		['3'] = {index=13},
		['Mog House'] = {index=13},
		['4'] = {index=100},},
	['Port Bastok'] = {
		['Entrance'] = {index=14},
		['1'] = {index=14},
		['2'] = {index=15},
		['Mog House'] = {index=15},
		['3'] = {index=101},},
	['Metalworks'] = {
		['1'] = {index=16},
		['2'] = {index=102},},
	['Windurst Waters'] = {
		['1'] = {index=17},
		['Entrance'] = {index=17},
		['2'] = {index=18},
		['Mog House'] = {index=18},
		['3'] = {index=103},
		['4'] = {index=118},},
	['Windurst Walls'] = {
		['1'] = {index=19},
		['2'] = {index=20},
		['Mog House'] = {index=20},
		['3'] = {index=21},
		['Auction House'] = {index=21},},
	['Port Windurst'] = {
		['1'] = {index=22},
		['2'] = {index=23},
		['Entrance'] = {index=23},
		['3'] = {index=24},
		['Mog House'] = {index=24},},
	['Windurst Woods'] = {
		['1'] = {index=25},
		['2'] = {index=26},
		['Entrance'] = {index=26},
		['3'] = {index=27},
		['Mog House'] = {index=27},
		['4'] = {index=28},
		['Auction House'] = {index=28},
		['5'] = {index=119},},
	['Ru\'Lude Gardens'] = {
		['1'] = {index=29},
		['2'] = {index=30},
		['Mog House'] = {index=30},
		['3'] = {index=31},
		['Auction House'] = {index=31},},
	['Upper Jeuno'] = {
		['1'] = {index=32},
		['Entrance'] = {index=32},
		['2'] = {index=33},
		['Mog House'] = {index=33},
		['3'] = {index=34},
		['Auction House'] = {index=34},},
	['Lower Jeuno'] = {
		['1'] = {index=35},
		['Entrance'] = {index=35},
		['2'] = {index=36},
		['Mog House'] = {index=36},},
	['Port Jeuno'] = {
		['1'] = {index=37},
		['Entrance'] = {index=37},
		['2'] = {index=38},
		['Mog House'] = {index=38},},
	['Kazham'] = {index=39},
	['Mhaura'] = {index=40},
	['Norg'] = {
		['1'] = {index=41},
		['Entrance'] = {index=41},
		['2'] = {index=104},
		['Auction House'] = {index=104},},
	['Rabao'] = {
		['1'] = {index=42},
		['Entrance'] = {index=42},
		['2'] = {index=105},},
	['Selbina'] = {index=43},
	['Western Adoulin'] = {
		['1'] = {index=44},
		['Auction House'] = {index=44},
		['Entrance'] = {index=44},
		['2'] = {index=109},
		['Mog House'] = {index=109},},
	['Eastern Adoulin'] = {
		['1'] = {index=45},
		['2'] = {index=110},
		['Auction House'] = {index=110},
		['Mog House'] = {index=110},},
	['Ceizak Battlegrounds'] = {index=46},
	['Foret de Hennetiel'] = {index=47},
	['Morimar Basalt Fields'] = {index=48},
	['Yorcia Weald'] = {index=49},
	['Marjami Ravine'] = {index=50},
	['Kamihr Drifts'] = {index=51},
	['Yughott Grotto'] = {index=52},
	['Palborough Mines'] = {index=53},
	['Giddeus'] = {index=54},
	['Fei\'Yin'] = {
		['1'] = {index=55},
		['2'] = {index=94},},
	['Quicksand Caves'] = {
		['1'] = {index=56},
		['2'] = {index=96},},
	['Den of Rancor'] = {
		['1'] = {index=57},
		['2'] = {index=93},},
	['Castle Zvahl Keep'] = {index=58},
	['Ru\'Aun Gardens'] = {
		['1'] = {index=59},
		['2'] = {index=60},
		['3'] = {index=61},
		['4'] = {index=62},
		['5'] = {index=63},},
	['Tavnazian Safehold'] = {
		['1'] = {index=64},
		['2'] = {index=120},
		['3'] = {index=121},},
	['Aht Urhgan Whitegate'] = {
		['1'] = {index=65},
		['2'] = {index=106},
		['3'] = {index=107},
		['Auction House'] = {index=107},
		['4'] = {index=108},
		['Mog House'] = {index=108},},
	['Nashmau'] = {index=66},
	--['Al Zahbi'] = {index=67},
	['Southern San d\'Oria \[S\]'] = {index=68},
	['Bastok Markets \[S\]'] = {index=69},
	['Windurst Waters \[S\]'] = {index=70},
	['Upper Delkfutt\'s Tower'] = {index=71},
	['The Shrine of Ru\'Avitau'] = {index=72},
	['Riverne - Site \#B01'] = {index=73},
	['Bhaflau Thickets'] = {index=74},
	['Caedarva Mire'] = {index=75},
	['Uleguerand Range'] = {
		['1'] = {index=76},
		['2'] = {index=77},
		['3'] = {index=78},
		['4'] = {index=79},
		['5'] = {index=80},},
	['Attohwa Chasm'] = {index=81},
	['Pso\'Xja'] = {index=82},
	['Newton Movalpolos'] = {index=83},
	['Riverne - Site #A01'] = {index=84},
	['Al\'Taieu'] = {
		['1'] = {index=85},
		['2'] = {index=86},
		['3'] = {index=87},},
	['Grand Palace of Hu\'Xzoi'] = {index=88},
	['The Garden of Ru\'Hmet'] = {index=89},
	['Mount Zhayolm'] = {index=90},
	['Cape Teriggan'] = {index=91},
	['The Boyahda Tree'] = {index=92},
	['Ifrit\'s Cauldron'] = {index=95},
	['Xarcabard \[S\]'] = {index=111},
	['Leafallia'] = {index=112},
	['Castle Zvahl Keep \[S\]'] = {index=113},
	['Qufim Island'] = {index=114},
	['Toraimarai Canal'] = {index=115},
	['Ra\'Kaznar Inner Court'] = {index=116},
	['Misareaux Coast'] = {index=117},
}
