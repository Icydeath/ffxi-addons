

['incoming'] = {
	['0x034'] = {
		["NPC"] = 17743945, -- Bastok HP #2
		['Menu Parameters'] = --,
		["NPC Index"] = 73,
		["Zone"] = 236, -- port bastok
		["Menu ID"] = 8701,
		['_unknown1'] = 8,
		["_dupeZone"] = 236,
		['_junk1'] = --,
	},
	-- Packet
        -- |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF
    -- -----------------------------------------------------  ----------------------
      -- 0 | 34 1A 6F 00 49 C0 0E 01 00 00 00 00 FF FF FF EF    0 | 4.o.I...........
      -- 1 | FF FF FF FF F7 2F 2E FF FF FF FF 03 E4 8D 33 00    1 | ...../........3.
      -- 2 | FF 0F 00 00 0F 00 02 00 49 00 EC 00 FD 21 08 00    2 | ........I....!..
      -- 3 | EC 00 00 00 -- -- -- -- -- -- -- -- -- -- -- --    3 | ....------------

	-- NPC: Home Point #2
	-- Menu Parameters: 
	-- NPC Index: Home Point #2
	-- Zone: Port Bastok
	-- Menu ID: 8701
	-- _unknown1: 8
	-- _dupeZone: Port Bastok
	-- _junk1: 
},
['outgoing'] = {
	['0x05B'] = {
		["Target"] = 17743945,
		["Option Index"] = {
			[1] = 8,
		},
		["_unknown1"] = 0,
		["Target Index"] = 73,
		["Automated Message"] = true,
		["_unknown2"] = 0,
		["Zone"] = 236, -- port bastok
		["Menu ID"] = 8701,
	},
	-- Packet
        -- |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF
    -- -----------------------------------------------------  ----------------------
      -- 0 | 5B 0A 71 00 49 C0 0E 01 08 00 00 00 49 00 01 00    0 | [.q.I.......I...
      -- 1 | EC 00 FD 21 -- -- -- -- -- -- -- -- -- -- -- --    1 | ...!------------

	-- Target: Home Point #2
	-- Option Index: 8
	-- _unknown1: 0
	-- Target Index: Home Point #2
	-- Automated Message: true
	-- _unknown2: 0
	-- Zone: Port Bastok
	-- Menu ID: 8701
	['0x05B'] = {
		["Target"] = 17743945,
		["Option Index"] = {
			[1] = 2,
		},
		["_unknown1"] = 93,
		["Target Index"] = 73,
		["Automated Message"] = true,
		["_unknown2"] = 0,
		["Zone"] = 236, -- port bastok
		["Menu ID"] = 8701,
	},
	-- Packet
        -- |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF
    -- -----------------------------------------------------  ----------------------
      -- 0 | 5B 0A 89 00 49 C0 0E 01 02 00 5D 00 49 00 01 00    0 | [...I.....].I...
      -- 1 | EC 00 FD 21 -- -- -- -- -- -- -- -- -- -- -- --    1 | ...!------------

	-- Target: Home Point #2
	-- Option Index: 2
	-- _unknown1: 93
	-- Target Index: Home Point #2
	-- Automated Message: true
	-- _unknown2: 0
	-- Zone: Port Bastok
	-- Menu ID: 8701
	['0x05B'] = {
		["Target"] = 17743945,
		["Option Index"] = {
			[1] = 2,
		},
		["_unknown1"] = 93,
		["Target Index"] = 73,
		["Automated Message"] = false,
		["_unknown2"] = 0,
		["Zone"] = 236, -- port bastok
		["Menu ID"] = 8701,
	},
	-- Packet
        -- |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF
    -- -----------------------------------------------------  ----------------------
      -- 0 | 5B 0A 96 00 49 C0 0E 01 02 00 5D 00 49 00 00 00    0 | [...I.....].I...
      -- 1 | EC 00 FD 21 -- -- -- -- -- -- -- -- -- -- -- --    1 | ...!------------

	-- Target: Home Point #2
	-- Option Index: 2
	-- _unknown1: 93
	-- Target Index: Home Point #2
	-- Automated Message: false
	-- _unknown2: 0
	-- Zone: Port Bastok
	-- Menu ID: 8701
}








