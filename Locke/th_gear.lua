-- expermential stuff, not being used in main lua.
local th = {}

th_gear = { 
	[21537] = {slot="weapon", name="Assassin's Knife", th=1},
	[21574] = {slot="weapon", name="Plun. Knife", th=2},
	[21575] = {slot="weapon", name="Gandring", th=3},
	[20618] = {slot="weapon", name="Sandung", th=1},
	[20596] = {slot="weapon", name="Taming Sari", th=1},
	[16480] = {slot="weapon", name="Thief's Knife", th=1},

	[23713] = {slot="head", name="Volte Cap", th=1},
	[25679] = {slot="head", name="White Rarab Cap +1", th=1},

	[23717] = {slot="body", name="Volte Jupon", th=2},

	[15107] = {slot="hands", name="Assassin's Armlets", th=1},
	[14914] = {slot="hands", name="Assassin's Armlets +1", th=1},
	[10695] = {slot="hands", name="Assassin's Armlets +2", th=2},
	[26986] = {slot="hands", name="Plunderer's Armlets", th=2},
	[26987] = {slot="hands", name="Plunderer's Armlets +1", th=3},
	[23202] = {slot="hands", name="Plunderer's Armlets +2", th=3},
	[23537] = {slot="hands", name="Plunderer's Armlets +3", th=4},
	[23721] = {slot="hands", name="Volte Bracers", th=1},

	[23725] = {slot="legs", name="Volte Hose", th=1},

	[11149] = {slot="feet", name="Raider's Poulaines +2", th=1},
	[27421] = {slot="feet", name="Skulker's Poulaines", th=2},
	[27422] = {slot="feet", name="Skulker's Poulaines +1", th=3},
	[23729] = {slot="feet", name="Volte Boots", th=1},

	[27585] = {slot="ring", name="Gorney Ring", th=1},
	[26197] = {slot="ring", name="Gorney Ring +1", th=1},

	[28450] = {slot="waist", name="Chaac Belt", th=1},
	[13212] = {slot="waist", name="Tarutaru Sash", th=1},
}

-- th_sets = T{
	-- [8] = { -- +5 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="head", name="Wh. Rarab Cap +1"}, -- TH+1
		-- {slot="waist", name="Chaac Belt"}, -- TH+1
	-- },
	-- [9] = { -- +6 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="head", name="Dampening Tam"}, -- replaces the previous piece used for TH
		-- {slot="hands", name="Plunderer's Armlets +1"}, -- TH+3
		-- {slot="waist", name="Kentarch Belt"}, -- replaces the previous piece used for TH 
	-- },
	-- [10] = { -- +7 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="hands", name="Plunderer's Armlets +1"}, -- TH+3
		-- {slot="waist", name="Chaac Belt"}, -- TH+1
	-- },
	-- [11] = { -- +8 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="head", name="Wh. Rarab Cap +1"}, -- TH+1
		-- {slot="hands", name="Plunderer's Armlets +1"}, -- TH+3
		-- {slot="waist", name="Chaac Belt"}, -- TH+1
	-- },
	-- [12] = { -- +9 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="head", name="Dampening Tam"}, -- replaces the previous piece used for TH
		-- {slot="hands", name="Plunderer's Armlets +1"}, -- TH+3
		-- {slot="feet", name="Skulk. Poulaines +1"}, -- TH+3
	-- },
	-- [13] = { -- +10 TH from gear
		-- {slot="sub", name="Gandring"}, -- TH+3
		-- {slot="hands", name="Plunderer's Armlets +1"}, -- TH+3
		-- {slot="waist", name="Chaac Belt"}, -- TH+1
		-- {slot="feet", name="Skulk. Poulaines +1"}, -- TH+3
	-- }
-- }

-- th_sets = T{
	-- [8]="sets.TreasureHunter8", 
	-- [9]="sets.TreasureHunter9",
	-- [10]="sets.TreasureHunter10",
	-- [11]="sets.TreasureHunter11",
	-- [12]="sets.TreasureHunter12",
	-- [13]="sets.TreasureHunter13"
-- }

function th.get_equipped_gear()
	local equipment = windower.ffxi.get_items().equipment
	
	local results = {}
	results.main = windower.ffxi.get_items(equipment.main_bag, equipment.main).id
	results.sub = windower.ffxi.get_items(equipment.sub_bag, equipment.sub).id
	results.range = windower.ffxi.get_items(equipment.range_bag, equipment.range).id
	results.ammo = windower.ffxi.get_items(equipment.ammo_bag, equipment.ammo).id
	results.head = windower.ffxi.get_items(equipment.head_bag, equipment.head).id
	results.neck = windower.ffxi.get_items(equipment.neck_bag, equipment.neck).id
	results.ear1 = windower.ffxi.get_items(equipment.left_ear_bag, equipment.left_ear).id
	results.ear2 = windower.ffxi.get_items(equipment.right_ear_bag, equipment.right_ear).id
	results.body = windower.ffxi.get_items(equipment.body_bag, equipment.body).id
	results.hands = windower.ffxi.get_items(equipment.hands_bag, equipment.hands).id
	results.ring1 = windower.ffxi.get_items(equipment.left_ring_bag, equipment.right_ring).id
	results.ring2 = windower.ffxi.get_items(equipment.right_ring_bag, equipment.left_ring).id
	results.back = windower.ffxi.get_items(equipment.back_bag, equipment.back).id
	results.waist = windower.ffxi.get_items(equipment.waist_bag, equipment.waist).id
	results.legs = windower.ffxi.get_items(equipment.legs_bag, equipment.legs).id
	results.feet = windower.ffxi.get_items(equipment.feet_bag, equipment.feet).id
	
	return results
end

function th.equip_th_amount(totalamount)
	th_equipped = 0
	for slot,id in pairs(th.get_equipped_gear()) do
		if th_gear[id] then
			th_equipped = th_equipped + th_gear[id].th
		end
	end
	log(th_equipped)
	if th_equipped == totalamount then return end
	
	
end

return th