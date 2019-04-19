--[[
Copyright © 2019, Myrchee of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Treasury Buddy nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


-- This requires the Treasury addon to function. I put this together since
-- that addon has a tendency to nuke itself on my machine with multiple instances
-- of FFXI running.


_addon.name = 'Treasury Buddy'
_addon.author = 'Myrchee'
_addon.version = '1.0'
_addon.command = 'tbuddy'


require('logger')
require('strings')
require('tables')
require('lists')
require('sets')
require('maths')
require('functions')
require('chat')
res = require('resources')
packets = require('packets')

--chat color
cc = 2

DumpsterFire = T{
	--Add to this list as needed.
	[1] = "Aqua Geode",
	[2] = "Breeze Geode",
	[3] = "Flame Geode",
	[4] = "Light Geode",
	[5] = "Shadow Geode",
	[6] = "Snow Geode",
	[7] = "Soil Geode",
	[8] = "Thunder Geode",
	[9] = "Titanite",
	[10] = "Garudite",
	[11] = "Shivite",
	[12] = "Ifritite",
	[13] = "Leviatite",
	[14] = "Ramuite",
	[15] = "Carbite",
	[16] = "Fenrite"
}

DynamisArmor = T{
	--for -1 versions, just concact a "-1" to command
	[1] = "Warrior's Mask",
	[2] = "Warrior's Lorica",
	[3] = "Warrior's Mufflers",
	[4] = "Warrior's Cuisses",
	[5] = "Warrior's Calligae",
	[6] = "Melee Crown",
	[7] = "Melee Cyclas",
	[8] = "Melee Gloves",
	[9] = "Melee Hose",
	[10] = "Melee Gaiters",
	[11] = "Cleric's Cap",
	[12] = "Cleric's Briault",
	[13] = "Cleric's Mitts",
	[14] = "Cleric's Pantaloons",
	[15] = "Cleric's Duckbills",
	[16] = "Sorcerer's Petasos",
	[17] = "Sorcerer's Coat",
	[18] = "Sorcerer's Gloves",
	[19] = "Sorcerer's Tonban",
	[20] = "Sorcerer's Sabots",
	[21] = "Duelist's Chapeau",
	[22] = "Duelist's Tabard",
	[23] = "Duelist's Gloves",
	[24] = "Duelist's Tights",
	[25] = "Duelist's Boots",
	[26] = "Assassin's Bonnet",
	[27] = "Assassin's Vest",
	[28] = "Assassin's Armlets",
	[29] = "Assassin's Culottes",
	[30] = "Assassin's Poulaines",
	[31] = "Valor Coronet",
	[32] = "Valor Surcoat",
	[33] = "Valor Gauntlets",
	[34] = "Valor Breeches",
	[35] = "Valor Leggings",
	[36] = "Abyss Burgeonet",
	[37] = "Abyss Cuirass",
	[38] = "Abyss Gauntlets",
	[39] = "Abyss Flanchard",
	[40] = "Abyss Sollerets",
	[41] = "Monster Helm",
	[42] = "Monster Jackcoat",
	[43] = "Monster Gloves",
	[44] = "Monster Trousers",
	[45] = "Monster Gaiters",
	[46] = "Bard's Roundlet",
	[47] = "Bard's Justaucorps",
	[48] = "Bard's Cuffs",
	[49] = "Bard's Cannions",
	[50] = "Bard's Slippers",
	[51] = "Scout's Beret",
	[52] = "Scout's Jerkin",
	[53] = "Scout's Bracers",
	[54] = "Scout's Braccae",
	[55] = "Scout's Socks",
	[56] = "Saotome Kabuto",
	[57] = "Saotome Domaru",
	[58] = "Saotome Kote",
	[59] = "Saotome Haidate",
	[60] = "Saotome Sune-Ate",
	[61] = "Koga Hatsuburi",
	[62] = "Koga Chainmail",
	[63] = "Koga Tekko",
	[64] = "Koga Hakama",
	[65] = "Koga Kyahan",
	[66] = "Wyrm Armet",
	[67] = "Wyrm Mail",
	[68] = "Wyrm Finger Gauntlets",
	[69] = "Wyrm Brais",
	[70] = "Wyrm Greaves",
	[71] = "Summoner's Horn",
	[72] = "Summoner's Doublet",
	[73] = "Summoner's Bracers",
	[74] = "Summoner's Spats",
	[75] = "Summoner's Pigaches",
	[76] = "Mirage Keffiyeh",
	[77] = "Mirage Jubbah",
	[78] = "Mirage Bazubands",
	[79] = "Mirage Shalwar",
	[80] = "Mirage Charuqs",
	[81] = "Commodore Tricorne",
	[82] = "Commodore Frac",
	[83] = "Commodore Gants",
	[84] = "Commodore Trews",
	[85] = "Commodore Bottes",
	[86] = "Pantin Taj",
	[87] = "Pantin Dastanas",
	[88] = "Pantin Churidars",
	[89] = "Pantin Tobe",
	[90] = "Pantin Babouches",
	[91] = "Etoile Tiara",
	[92] = "Etoile Casaque",
	[93] = "Etoile Bangles",
	[94] = "Etoile Tights",
	[95] = "Etoile Shoes",
	[96] = "Argute Mortarboard",
	[97] = "Argute Gown",
	[98] = "Argute Bracers",
	[99] = "Argute Pants",
	[100] = "Argute Loafers"
}

DynamisGarbage = T{
	[1] = "Warrior's Stone",
	[2] = "Melee Cape",
	[3] = "Cleric's Belt",
	[4] = "Sorcerer's Belt",
	[5] = "Duelist's Belt",
	[6] = "Assassin's Cape",
	[7] = "Valor Cape",
	[8] = "Abyss Cape",
	[9] = "Monster Belt",
	[10] = "Bard's Cape",
	[11] = "Scout's Belt",
	[12] = "Sao. Koshi-Ate",
	[13] = "Koga Sarashi",
	[14] = "Wyrm Belt",
	[15] = "Summoner's Cape",
	[16] = "Mirage Mantle",
	[17] = "Commodore Belt",
	[18] = "Pantin Cape",
	[19] = "Etoile Cape",
	[20] = "Argute Belt"
}

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'general' then
			
			drop(DumpsterFire)
		elseif cmd:lower() == 'dynamis' then
			drop(DynamisGarbage)
			drop(DynamisArmor)
			dropMinusOne(DynamisArmor)
		elseif cmd:lower() == 'all' then
			drop(DumpsterFire)
			drop(DynamisGarbage)
			drop(DynamisArmor)
			dropMinusOne(DynamisArmor)
		else
		windower.add_to_chat(cc,'No valid command detected.')
		end
	
	end
	
end)

function drop(itemTable)
	for i,v in pairs(itemTable) do
		windower.send_command('input //tr drop add '..v)
	end
end

function dropMinusOne(itemTable)
	for i,v in pairs(itemTable) do
		windower.send_command('input //tr drop add '..v..' -1')
	end
end


