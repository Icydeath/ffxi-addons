-- Universal items that are the same for all characters, and logic to determine which item choices from quests have been made.
sets.TrizekRing = {ring2="Trizek Ring"}
sets.EchadRing = {ring2="Echad Ring"}
sets.FacilityRing = {ring2="Facility Ring"}
sets.CapacityRing = {ring2="Capacity Ring"}
sets.VocationRing = {ring2="Vocation Ring"}
sets.HollaRing = {ring2="Dim. Ring (Holla)"}
sets.DemRing = {ring2="Dim. Ring (Dem)"}
sets.MeaRing = {ring2="Dim. Ring (Mea)"}
sets.Nexus = {back="Nexus Cape"}
sets.Warp = {ring2="Warp Ring"}
sets.RREar = {ear2="Reraise Earring"}
sets.BehemothSuit = {body="Behemoth Suit +1",hands=empty,legs=empty,feet=empty}

if player.inventory["Adoulin's Refuge +1"] or player.safe["Adoulin's Refuge +1"] or player.safe2["Adoulin's Refuge +1"] or player.storage["Adoulin's Refuge +1"] or player.locker["Adoulin's Refuge +1"] or player.satchel["Adoulin's Refuge +1"] or player.sack["Adoulin's Refuge +1"] or player.case["Adoulin's Refuge +1"] or player.wardrobe["Adoulin's Refuge +1"] or player.wardrobe2["Adoulin's Refuge +1"] or player.wardrobe3["Adoulin's Refuge +1"] or player.wardrobe4["Adoulin's Refuge +1"] then
	sets.Reive = {neck="Adoulin's Refuge +1"}
elseif player.inventory["Arciela's Grace +1"] or player.safe["Arciela's Grace +1"] or player.safe2["Arciela's Grace +1"] or player.storage["Arciela's Grace +1"] or player.locker["Arciela's Grace +1"] or player.satchel["Arciela's Grace +1"] or player.sack["Arciela's Grace +1"] or player.case["Arciela's Grace +1"] or player.wardrobe["Arciela's Grace +1"] or player.wardrobe2["Arciela's Grace +1"] or player.wardrobe3["Arciela's Grace +1"] or player.wardrobe4["Arciela's Grace +1"] then
	sets.Reive = {neck="Arciela's Grace +1"}
elseif player.inventory["Ygnas's Resolve +1"] or player.safe["Ygnas's Resolve +1"] or player.safe2["Ygnas's Resolve +1"] or player.storage["Ygnas's Resolve +1"] or player.locker["Ygnas's Resolve +1"] or player.satchel["Ygnas's Resolve +1"] or player.sack["Ygnas's Resolve +1"] or player.case["Ygnas's Resolve +1"] or player.wardrobe["Ygnas's Resolve +1"] or player.wardrobe2["Ygnas's Resolve +1"] or player.wardrobe3["Ygnas's Resolve +1"] or player.wardrobe4["Ygnas's Resolve +1"] then
	sets.Reive = {neck="Ygnas's Resolve +1"}
else
	sets.Reive = {}
end