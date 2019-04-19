return { -- option: 1
	short_name = 'un',
	long_name = 'unity npc',
	npc_names = T{
		warp = T{"Igsli", "Urbiolaine", "Teldro-Kesdrodo", "Yonolala", "Nunaarl Bthtrogg"},
	},
	help_text = "[sw] un [warp/w] [all/a/@all] zone name -- warp to a designated unity zone. \"all\" sends ipc to all local clients.",
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

		packet["Option Index"] = 10
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

		packet["Option Index"] = 7
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

		packet["Option Index"] = settings.index
		packet["_unknown1"] = 0
		packet["Automated Message"] = false
		packet["_unknown2"] = 0
		packet.debug_desc = 'zone warp request'
		p:append(packet)

		if settings.z and settings.pops then
			log("Pops located at: "..settings.z.." "..settings.pops)
		end

		return p
	end,
	-- some of these are duplicates. They've been commented out.
	['East Ronfaure'] = { index = 1, },
	['South Gustaberg'] = { index = 33, },
	['East Sarutabaruta'] = { index = 65, },
	['La Theine Plateau'] = { index = 97, },
	['Konschtat Highlands'] = { index = 129, },
	['Tahrongi Canyon'] = { index = 161, },
	['Valkurm Dunes'] = { index = 193, },
	['Buburimu Peninsula'] = { index = 225, },
	['Qufim Island'] = { index = 257, },
	['Bibiki Bay'] = { index = 289, },
	['Carpenters\' Landing'] = { index = 321, },
	['Yuhtunga Jungle'] = { index = 353, },
	['Lufaise Meadows'] = { index = 385, },
	['Jugner Forest'] = { index = 417, },
	['Pashhow Marshlands'] = { index = 449, },
	['Meriphataud Mountains'] = { index = 481, },
	['Eastern Altepa Desert'] = { index = 513, },
	['Yhoator Jungle'] = { index = 545, },
	['The Sanctuary of Zi\'Tah'] = { index = 577, },
	['Misareaux Coast'] = { index = 609, },
	['Labyrinth of Onzozo'] = { index = 641, },
	['Bostaunieux Oubliette'] = { index = 673, },
	['Batallia Downs'] = { index = 705, },
	['Rolanberry Fields'] = { index = 737, },
	['Sauromugue Champaign'] = { index = 769, },
	['Beaucedine Glacier'] = { index = 801, },
	['Xarcabard'] = { index = 833, },
	['Ro\'Maeve'] = { index = 865, },
	['Western Altepa Desert'] = { index = 897, },
	['Attohwa Chasm'] = { index = 929, },
	['Garlaige Citadel'] = { index = 961, },
	['Ifrit\'s Cauldron'] = { index = 993, },
	['The Boyahda Tree'] = { index = 1025, },
	['Kuftal Tunnel'] = { index = 1057, },
	['Sea Serpent Grotto'] = { index = 1089, },
	['Temple of Uggalepih'] = { index = 1121, },
	['Quicksand Caves'] = { index = 1153, },
	['Wajaom Woodlands'] = { index = 1185, },
	['Lufaise Meadows'] = { index = 1217, },
	['Cape Teriggan'] = { index = 1249, },
	['Uleguerand Range'] = { index = 1313, },
	['Den of Rancor'] = { index = 1345, },
	['Fei\'Yin'] = { index = 1377, },
	['Alzadaal Undersea Ruins'] = { index = 1441, },
	--['Misareaux Coast'] = { index = 1473, },
	['Mount Zhayolm'] = { index = 1505, },
	['Gustav Tunnel'] = { index = 1537, },
	['Behemoth\'s Dominion'] = { index = 1569, },
	--['The Boyahda Tree'] = { index = 1601, },
	['Valley of Sorrows'] = { index = 1633, },
	--['Wajaom Woodlands'] = { index = 1665, },
	--['Mount Zhayolm'] = { index = 1697, },
	['Caedarva Mire'] = { index = 1729, },
	['Aydeewa Subterrane'] = { index = 1761, },

	-- organized by NM:
	['Bounding Belinda'] = { index = 33, z = "South Gustaberg", pops = "(E-7), (G-7), (G-8)", },
	['Hugemaw Harold'] = { index = 1, z = "East Ronfaure", pops = "(H-9), (J-8), (J-10)", },
	['Prickly Pitriv'] = { index = 65, z = "East Sarutabaruta", pops = "(G-9), (I-7), (J-9)", },
	['Ironhorn Baldurno'] = { index = 97, z = "La Theine Plateau", pops = "(G-8), (G-9), (I-9)", },
	['Sleepy Mabel'] = { index = 129, z = "Konschtat Highlands", pops = "(F-5), (G-9), (H-8)", },
	['Serpopard Ninlil'] = { index = 161, z = "Tahrongi Canyon", pops = "(E-9), (H-8), (I-9)", },
	['Abyssdiver'] = { index = 225, z = "Buburimu Peninsula", pops = "(H-7), (K-6), (K-9)", },
	['Immanibugard'] = { index = 385, z = "Lufaise Meadows", pops = "(G-7), (J-9), (K-9)", },
	['Intuila'] = { index = 289, z = "Bibiki Bay", pops = "(G-8), (H-10), (I-6)", },
	['Jester Malatrix'] = { index = 257, z = "Qufim Island", pops = "(G-7), (G-8), (I-8)", },
	['Orcfeltrap'] = { index = 321, z = "Carpenters' Landing", pops = "(H-9), (I-9), (I-11)", },
	['Sybaritic Samantha'] = { index = 353, z = "Yuhtunga Jungle", pops = "(F-11), (F-10), (I-6)", },
	['Valkurm Imperator'] = { index = 193, z = "Valkurm Dunes", pops = "(D-6), (E-8), (K-9)", },
	['Cactrot Veloz'] = { index = 513, z = "Eastern Altepa Desert", pops = "(G-10), (I-5), (J-9)", },
	['Emperor Arthro'] = { index = 417, z = "Jugner Forest", pops = "(I-6), (I-9), (J-11)", },
	['Garbage Gel'] = { index = 673, z = "Bostaunieux Oubliette", pops = "(J-7), (J-10), (F-8)", },
	['Joyous Green'] = { index = 449, z = "Pashhow Marshlands", pops = "(H-9), (I-6), (J-9)", },
	['Keeper of Heiligtum'] = { index = 577, z = "The Sanctuary of Zi'Tah", pops = "(J-11), (K-9), (J-10)", },
	['Tiyanak'] = { index = 609, z = "Misareaux Coast", pops = "(G-8), (F-8), (I-11)", },
	['Voso'] = { index = 641, z = "Labyrinth of Onzozo", pops = "(G-6), (H-7), (I-5)", },
	['Warblade Beak'] = { index = 481, z = "Meriphataud Mountains", pops = "(G-9), (I-9), (K-11)", },
	['Woodland Mender'] = { index = 545, z = "Yhoator Jungle", pops = "(G-10), (H-7), (I-10)", },
	['Arke'] = { index = 769, z = "Sauromugue Champaign", pops = "(G-8), (J-9), (L-7)", },
	['Ayapec'] = { index = 1025, z = "The Boyahda Tree", pops = "(D-6), (I-10), (H-6)", },
	['Azure-toothed Clawberry'] = { index = 1121, z = "Temple of Uggalepih", pops = "Map 1 : (J-8), Map 2 :(H-9), (F-7)", },
	['Bakunawa'] = { index = 1089, z = "Sea Serpent Grotto", pops = "(J-8), (I-10), (D-9)", },
	['Beist'] = { index = 833, z = "Xarcabard", pops = "(I-7), (I-8), (I-9)", },
	['Centurio XX-I'] = { index = 1153, z = "Quicksand Caves", pops = "Map 1 : (H-12), (I-5), (I-9)", },
	['Coca'] = { index = 993, z = "Ifrit's Cauldron", pops = "(I-7), (F-10), (H-6)", },
	['Douma Weapon'] = { index = 865, z = "Ro'Maeve", pops = "(I-10), (G-11), (C-9)", },
	['King Uropygid'] = { index = 897, z = "Western Altepa Desert", pops = "(F-10), (F-8), (J-6)", },
	['Kubool Ja\'s Mhuufya'] = { index = 1185, z = "Wajaom Woodlands", pops = "(K-9), (I-9), (I-8)", },
	['Largantua'] = { index = 801, z = "Beaucedine Glacier", pops = "(J-7), (K-8), (K-9)", },
	['Lumber Jill'] = { index = 705, z = "Batallia Downs", pops = "(E-5), (H-9), (J-7)", },
	['Mephitas'] = { index = 961, z = "Garlaige Citadel", pops = "(I-6), (G-7), (H-8)", },
	['Muut'] = { index = 929, z = "Attohwa Chasm", pops = "(F-7), (E-8), (G-9)", },
	['Specter Worm'] = { index = 1057, z = "Kuftal Tunnel", pops = "(F-9), (H-5), (J-11)", },
	['Strix'] = { index = 737, z = "Rolanberry Fields", pops = "(E-11), (F-8), (J-8)", },
	['Vermillion Fishfly'] = { index = 385, z = "Lufaise Meadows", pops = "(G-7), (J-9), (K-9)", },
	['Azrael'] = { index = 1345, z = "Den of Rancor", pops = "(H-5), (G-10), (G-9)", },
	['Borealis Shadow'] = { index = 1377, z = "Fei'Yin", pops = "(I-7), (J-8), (F-9)", },
	['Camahueto'] = { index = 1313, z = "Uleguerand Range", pops = "(G-10), (D-9), (D-8)", },
	['Carousing Celine'] = { index = 1377, z = "Fei'Yin", pops = "Map 1 : (I-7), (J-8), (F-9)", },
	['Grand Grenade'] = { index = 1505, z = "Mount Zhayolm", pops = "(D-5), (C-6), (E-7)", },
	['Vedrfolnir'] = { index = 1249, z = "Cape Teriggan", pops = "(I-7), (H-8), (I-8)", },
	['Vidmapire'] = { index = 1441, z = "Alzadaal Undersea Ruins", pops = "Map 5: (F-7), (F-10), (I-10)", },
	['Volatile Cluster'] = { index = 609, z = "Misareaux Coast", pops = "(G-8), (F-8), (I-11)", },
	['Glazemane'] = { index = 1249, z = "Cape Teriggan", pops = "(I-7), (H-8), (I-8)", },
	['Wyvernhunter Bambrox'] = { index = 1537, z = "Gustav Tunnel", pops = "Map 2 : (H-6), (G-8), (F-7)", },
	['Hidhaegg'] = { index = 1025, z = "The Boyahda Tree", pops = "Map 1 : (D-6), Map 2 : (I-10), Map 3 : (F-6)", },
	['Sovereign Behemoth'] = { index = 1569, z = "Behemoth's Dominion", pops = "(E-8), (G-8), (J-9)", },
	['Tolba'] = { index = 1633, z = "Valley of Sorrows", pops = "(G-8), (F-9), (G-9)", },
	['Thu\'ban'] = { index = 1185, z = "Wajaom Woodlands", pops = "(K-9), (I-8), (I-9)", },
	['Sarama'] = { index = 1505, z = "Mount Zhayolm", pops = "(D-5), (C-6), (E-7)", },
	['Shedu'] = { index = 1729, z = "Caedarva Mire", pops = "Map 4 : (H-7), (G-8), (I-7)", },
	['Tumult Curator'] = { index = 1761, z = "Aydeewa Subterrane", pops = "Map 2 : (J-9), (K-7), (L-8)", },
}