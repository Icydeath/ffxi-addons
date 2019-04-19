return { -- option: 1
	short_name = 'sg',
	long_name = 'survival guide',
	npc_names = T{
		warp = T{'Survival Guide'},
	},
	help_text = "[sw] sg [warp/w] [all/a/@all] zone name -- warp to a designated survival guide. \"all\" sends ipc to all local clients.",
	sub_zone_targets = S{},
	build_warp_packets = function(npc, zone, menu, settings)
		local p = T{}
		local packet = packets.new('outgoing', 0x05B)

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

		packet["Option Index"] = 1
		packet["_unknown1"] = settings.index
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

		packet["Option Index"] = 1
		packet["_unknown1"] = settings.index
		packet["Automated Message"] = false
		packet["_unknown2"] = 0
		packet.debug_desc = 'zone warp request'
		p:append(packet)

		return p
	end,
	["Northern San d'Oria"] = {index=0},
	["Bastok Mines"] = {index=1},
	["Port Windurst"] = {index=2},
	["Ru\'Lude Gardens"] = {index=3},
	["Tavnazian Safehold"] = {index=4},
	["Aht Urhgan Whitegate"] = {index=5},
	["West Ronfaure"] = {index=6},
	["Fort Ghelsba"] = {index=7},
	["Bostaunieux Oubliette"] = {index=8},
	["King Ranperre's Tomb"] = {index=9},
	["La Theine Plateau"] = {index=10},
	["Valkurm Dunes"] = {index=11},
	["Konschtat Highlands"] = {index=12},
	["Ordelle\'s Caves"] = {index=13},
	["Gusgen Mines"] = {index=14},
	["Carpenters\' Landing"] = {index=15},
	["Jugner Forest"] = {index=16},
	["Batallia Downs"] = {index=17},
	["Davoi"] = {index=18},
	["The Eldieme Necropolis"] = {index=19},
	["North Gustaberg"] = {index=20},
	["Zeruhn Mines"] = {index=21},
	["Korroloka Tunnel"] = {index=22},
	["Dangruf Wadi"] = {index=23},
	["Passhow Marshlands"] = {index=24},
	["Rolanberry Fields"] = {index=25},
	["Beadeaux"] = {index=26},
	["Crawlers' Nest"] = {index=27},
	["West Sarutabaruta"] = {index=28},
	["Toraimarai Canal"] = {index=29},
	["Horutoto Ruins"] = {index=30},
	["Bibiki Bay"] = {index=31},
	["Tahrongi Canyon"] = {index=32},
	["Buburimu Peninsula"] = {index=33},
	["Maze of Shakhrami"] = {index=34},
	["Labyrinth of Onzozo"] = {index=35},
	["Meriphataud Mountains"] = {index=36},
	["Sauromugue Champaign"] = {index=37},
	["Castle Oztroja"] = {index=38},
	["Garlaige Citadel"] = {index=39},
	["Beaucedine Glacier"] = {index=40},
	["Ranguemont Pass"] = {index=41},
	["Xarcabard"] = {index=42},
	["Castle Zvahl Baileys"] = {index=43},
	["Qufim Island"] = {index=44},
	["Behemoth's Dominion"] = {index=45},
	["Lower Delkfutt\'s Tower"] = {index=46},
	["The Sanctuary of Zi\'Tah"] = {index=47},
	["Ro\'Maeve"] = {index=48},
	["Dragon\'s Aery"] = {index=49},
	["Eastern Altepa Desert"] = {index=50},
	["Western Altepa Desert"] = {index=51},
	["Rabao"] = {index=52},
	["Cape Teriggan"] = {index=53},
	["Valley of Sorrows"] = {index=54},
	["Kuftal Tunnel"] = {index=55},
	["Gustav Tunnel"] = {index=56},
	["Yuhtunga Jungle"] = {index=57},
	["Sea Serpent Grotto"] = {index=58},
	["Kazham"] = {index=59},
	["Norg"] = {index=60},
	["Yhoator Jungle"] = {index=61},
	["Temple of Uggalepih"] = {index=62},
	["Ifrit\'s Cauldron"] = {index=63},
	["Ru\'Aun Gardens"] = {index=64},
	["Oldton Movalpolos"] = {index=65},
	["Lufaise Meadows"] = {index=66},
	["Misareaux Coast"] = {index=67},
	["Phomiuna Aqueducts"] = {index=68},
	["Sacrarium"] = {index=69},
	["Wajaom Woodlands"] = {index=70},
	["Mamook"] = {index=71},
	["Aydeewa Subterrane"] = {index=72},
	["Halvung"] = {index=73},
	["Nashmau"] = {index=74},
	["Arrapago Reef"] = {index=75},
	["Caedarva Mire"] = {index=76},
	["Southern San d\'Oria \[S\]"] = {index=77},
	["East Ronfaure \[S\]"] = {index=78},
	["Jugner Forest \[S\]"] = {index=79},
	["Batallia Downs \[S\]"] = {index=80},
	["The Eldieme Necropolis \[S\]"] = {index=81},
	["Bastok Market \[S\]"] = {index=82},
	["North Gustaberg \[S\]"] = {index=83},
	["Grauberg \[S\]"] = {index=84},
	["Vunkerl Inlet \[S\]"] = {index=85},
	["Pashhow Marshlands \[S\]"] = {index=86},
	["Rolanberry Fields \[S\]"] = {index=87},
	["Crawlers\' Nest \[S\]"] = {index=88},
	["Windurst Waters \[S\]"] = {index=89},
	["West Sarutabaruta \[S\]"] = {index=90},
	["Fort Karugo-Narugo \[S\]"] = {index=91},
	["Meriphataud Mountains \[S\]"] = {index=92},
	["Sauromugue Champaign \[S\]"] = {index=93},
	["Garlaige Citadel \[S\]"] = {index=94},
	["Beaucedine Glacier \[S\]"] = {index=95},
	["Castle Zvahl Baileys \[S\]"] = {index=96},
	["Eastern Adoulin"] = {index=97},
}
