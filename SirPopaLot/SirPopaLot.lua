--[[

Copyright © 2020, DaneBlood
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of SirPopaLot nor the
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

_addon.name = 'SirPopaLot'
_addon.author = 'Daneblood'
_addon.version = '21.2.21'
_addon.command = 'pop'

require('coroutine')
require('sets')
--require('resources')
--res_items = require('resources').items

local Var_IonisNPC    = S{'Fleuricette', 'Quiri-Aliri'}
local Var_SigilNPC    = S{'Miliart, T.K.', 'Millard, I.M.', 'Mindala-Andola, C.C.'}
local Var_SanctionNPC = S{'Asrahd', 'Famatarthen', 'Falzuuk', 'Nabihwah'}
local Var_SignetNPC   = S{'Flying Axe, I.M.', 'Rabid Wolf, I.M.', 'Crying Wind, I.M.', 'Arpevion, T.K.', 'Aravoge, T.K.', 'Achantere, T.K.', 'Milma-Hapilma, W.W.', 'Puroiko-Maiko, W.W.', 'Harara, W.W.', 'Kochahy-Muwachahy', 'Alrauverat', 'Emitt', 'Morlepiche'}
local Var_GobBoxNPC   = S{'Mystrix', 'Habitox', 'Bountibox', 'Specilox', 'Arbitrix', 'Funtrox', 'Priztrix', 'Sweepstox', 'Wondrix', 'Rewardox', 'Winrix'}





windower.register_event('addon command', function(...)
	target = windower.ffxi.get_mob_by_target('t')

	if not target then
		windower.send_command('input /targetnpc')
		coroutine.sleep(0.5)
		target = windower.ffxi.get_mob_by_target('t')
	end
	TradeIt()
end)



--	windower.register_event('incoming text', function(original, modified, mode)
--
--	if os.time() - OldTime < SkipTime then
--
--		if mode == 150 or mode == 151 then
--			modified = modified:gsub(string.char(0xa7F, 0x31), '')
--		end
--	end
	
--	return modified
--end)





function TradeIt()

	if target.name == '???' then		
		local var_thiszone = windower.ffxi.get_info()['zone']

		if var_thiszone == 15 then 			-- Abyssea-Konschtat 
			windower.send_command('TradeNPC 1 "Giant Bugard Tusk"')	-- Kukulkan
			windower.send_command('TradeNPC 1 "Armored Dragonhorn"')
			windower.send_command('TradeNPC 1 "Clouded Lens"')
			windower.send_command('TradeNPC 1 "Tiny Morbol Vine"') 	-- Misc
			
		elseif var_thiszone == 45 then		-- Abyssea-Tahrongi
			if math.modf(target.x) == -234 then		-- Chloris
				windower.send_command('TradeNPC 1 "H.Q. Cli. Wing"')	
			elseif math.modf(target.x) == -44 then
				windower.send_command('TradeNPC 1 "H.Q. Lim. Pincer"')
			elseif math.modf(target.x) == -195 then
				windower.send_command('TradeNPC 1 "Bloodshot Hecteye" 1 "Shriveled Wing" 1 "Tarnished Pincer"')
			elseif math.modf(target.x) == 184 then
				windower.send_command('TradeNPC 1 "Exorcised Skull" 1 "Bloody Fang"')
			elseif math.modf(target.x) == -354 then
				windower.send_command('TradeNPC 1 "Baleful Skull"')
			elseif math.modf(target.x) == -280 then
				windower.send_command('TradeNPC 1 "Acidic Humus" 1 "V. Scorp. Stinger"')
			elseif math.modf(target.x) == -40 then	-- Glavoid
				windower.send_command('TradeNPC 1 "Quiv. Eft Egg" 1 "Ctrice. Tailmeat"')
			else
				windower.send_command('TradeNPC 1 "Alkaline Humus"')
				windower.send_command('TradeNPC 1 "Eft Egg"')	-- Glavoid
				windower.send_command('TradeNPC 1 "Shocking Whisker"')			
				windower.send_command('TradeNPC 1 "Smooth Whisker" 1 "Resilient Mane"')
			end
			
		elseif var_thiszone == 132 then		-- Abyssea-La_Theine
			if math.modf(target.x) == -716 then
				windower.send_command('TradeNPC 1 "Trophy Shield"')	-- Briareus
			elseif math.modf(target.x) == -357 then
				windower.send_command('TradeNPC 1 "Oversized Sock"')
			elseif math.modf(target.x) == -398 then
				windower.send_command('TradeNPC 1 "Massive Armband"')
			elseif math.modf(target.x) == 81 then
				windower.send_command('TradeNPC 1 "Tr. Insect Wing"')	-- Carabosse
			elseif math.modf(target.x) == -731 then
				windower.send_command('TradeNPC 1 "Piceous Scale"')	
			else
				windower.send_command('TradeNPC 1 "Raw Mutton Chop')	-- Misc
				windower.send_command('TradeNPC 1 "Gargantuan Black Tiger Fang"')	
			end
		elseif var_thiszone == 215 then		-- Abyssea-Attohwa 
			if math.modf(target.x) == 281 then
				windower.send_command('TradeNPC 1 "Blanched Silver"')
			elseif math.modf(target.x) == 401 then
				windower.send_command('TradeNPC 1 "Withered Cocoon"')
			elseif math.modf(target.x) == 410 then
				windower.send_command('TradeNPC 1 "Withered Bud"')
			elseif math.modf(target.x) == 481 then
				windower.send_command('TradeNPC 1 "Great Root"')
			else
				windower.send_command('TradeNPC 1 "Eruca Egg"')
				windower.send_command('TradeNPC 1 "Undying Ooze"')
				windower.send_command('TradeNPC 1 "Bone Chips"')
				windower.send_command('TradeNPC 1 "Wailing Rags"')
				windower.send_command('TradeNPC 1 "Cracked Dragonscale"')
				windower.send_command('TradeNPC 1 "Mangled Cockatrice Skin"')
				windower.send_command('TradeNPC 1 "Coeurl Round"')
				windower.send_command('TradeNPC 1 "Gory Pincer"')
				windower.send_command('TradeNPC 1 "Extended Eyestalk"')
			end
		
		elseif var_thiszone == 216 then		-- Abyssea-Misareaux
			if math.modf(target.x) == -161 then
				windower.send_command('TradeNPC 1 "Orbn. Cheekmeat"')
			elseif math.modf(target.x) == 521 then
				windower.send_command('TradeNPC 1 "Bewitching Tusk"')
			elseif math.modf(target.x) == 346 then
				windower.send_command('TradeNPC 1 "Handful of molt scraps"')
			else
				windower.send_command('TradeNPC 1 "Apkallu Down"')
				windower.send_command('TradeNPC 1 "Avian Remex"')
				windower.send_command('TradeNPC 1 "Spheroid Plate"')
				windower.send_command('TradeNPC 1 "High-quality crab meat"')
				windower.send_command('TradeNPC 1 "High-Quality Rock Salt"')
				windower.send_command('TradeNPC 1 "Mocking Beak"')
				windower.send_command('TradeNPC 1 "Hardened Raptor Skin"')
				windower.send_command('TradeNPC 1 "Worm-Eaten Bud"')
				windower.send_command('TradeNPC 1 "Black Rabbit Tail"')
				windower.send_command('TradeNPC 1 "Spotted Flyfrond "')
			end
		
		elseif var_thiszone == 217 then		-- Abyssea-Vunkerl
			if math.modf(target.x) == -344 then
				windower.send_command('TradeNPC 1 "H.Q. Rabbit Hide"')
			else
				windower.send_command('TradeNPC 1 "Gargouille Stone"')
				windower.send_command('TradeNPC 1 "Gnarled Taurus Horn"')
				windower.send_command('TradeNPC 1 "Dented Skull"')
				windower.send_command('TradeNPC 1 "Stiffened Tentacle"')
				windower.send_command('TradeNPC 1 "Black Whisker"')
				windower.send_command('TradeNPC 1 "Moonbeam Clam"')
			end

		elseif var_thiszone == 218 then		-- Abyssea-Altepa
			if math.modf(target.x) == -558 then 
				windower.send_command('TradeNPC 1 "High-Quality Dhalmel Hide" 1 "Sharabha Hide" 1 "Tiger King\'s Hide"')
			elseif math.modf(target.x) == -314 then 
				windower.send_command('TradeNPC 1 "Sand-caked fang"')
			elseif math.modf(target.x) == -877 then 
				windower.send_command('TradeNPC 1 "Sandy Shard"')
			else
				windower.send_command('TradeNPC 1 "Sabulous Clay"')
				windower.send_command('TradeNPC 1 "High-quality Cockatrice Skin"')
				windower.send_command('TradeNPC 1 "Oasis Water" 1 "Giant Mistletoe"')
				windower.send_command('TradeNPC 1 "Smoldering Arm" 1 "Tablilla Mercury"')
				windower.send_command('TradeNPC 1 "Vadleany Fluid" 1 "High-Quality Scorpion Claw"')
				windower.send_command('TradeNPC 1 "Ladybird Leaf"')
				windower.send_command('TradeNPC 1 "Puppet\'s Blood"')
			end

		elseif var_thiszone == 253 then		-- Abyssea-Uleguerand 
			if math.modf(target.x) == -281 then 
				windower.send_command('TradeNPC 1 "High-Quality Marid Hide" 1 "Sisyphus Fragment" 1 "Snow God Core"')
			elseif  math.modf(target.x) == -213 then
				windower.send_command('TradeNPC 1 "Gelid Arm"')
			else
				windower.send_command('TradeNPC 1 "Whiteworm Clay"')
				windower.send_command('TradeNPC 1 "High-Quality Buffalo Horn"')
				windower.send_command('TradeNPC 1 "Trade Rimed Wing" 1 "Benumbed Eye"')
				windower.send_command('TradeNPC 1 "Imp Sentry\'s Horn"')
				windower.send_command('TradeNPC 1 "Bevel Gear" 1 "Gear Fluid"')
				windower.send_command('TradeNPC 1 "Helical Gear"')
				windower.send_command('TradeNPC 1 "Ice Wyvern Scale"')
				windower.send_command('TradeNPC 1 "High-Quality Black Tiger Hide" 1 "Audumbla Hide"')
			end

		elseif var_thiszone == 254 then		-- Abyssea-Grauberg 
			if math.modf(target.x) == 502 then 
				windower.send_command('TradeNPC 1 "Teekesselchen Fragment" 1 "Darkflame Arm"')
			elseif math.modf(target.x) == 320 then 
				windower.send_command('TradeNPC 1 "Bubbling Oil"')
			else
				windower.send_command('TradeNPC 1 "Goblin Oil" 1 "Goblin Gunpowder"')
				windower.send_command('TradeNPC 1 "Goblin Rope"')
				windower.send_command('TradeNPC 1 "High-Quality Pugil Scale"')
				windower.send_command('TradeNPC 1 "Fay Teardrop"')
				windower.send_command('TradeNPC 1 "Pursuer\'s Wing"')
				windower.send_command('TradeNPC 1 "High-Quality Wivre Hide" 1 "Jaculus Wing" 1 "Minaruja Skull"')

				windower.send_command('TradeNPC 1 "Unseelie Eye" 1 "Naiad\'s Lock"')
				windower.send_command('TradeNPC 1 "Decaying Molar"')
			end


		
		elseif var_thiszone == 51 then		-- Wajaom_Woodlands
			windower.send_command('TradeNPC 1 "Hellcage Butterfly"')
			windower.send_command('TradeNPC 1 "Senorita pamama"')
			windower.send_command('TradeNPC 1 "Sheep Botfly"')
		elseif var_thiszone == 52 then		-- Bhaflau_Thickets
			windower.send_command('TradeNPC 1 "Olzhiryan Cactus"')
		elseif var_thiszone == 54 then		-- Arrapago_Reef
			windower.send_command('TradeNPC 1 "Golden Teeth"')
			windower.send_command('TradeNPC 1 "Greenling"')
			windower.send_command('TradeNPC 1 "Merrow No. 11 Molting"')
			windower.send_command('TradeNPC 1 "Rose Scampi"')
		elseif var_thiszone == 61 then		-- Mount_Zhayolm
			windower.send_command('TradeNPC 1 "Pectin"')
			windower.send_command('TradeNPC 1 "Raw Buffalo"')
			windower.send_command('TradeNPC 1 "Shadeleaf"')
			windower.send_command('TradeNPC 1 "Vinegar Pie"')
		elseif var_thiszone == 65 then		-- Mamook
			windower.send_command('TradeNPC 1 "Floral Nectar"')	
			windower.send_command('TradeNPC 1 "Samariri Corpsehair"')
		elseif var_thiszone == 68 then		--  Aydeewa_Subterrane
			windower.send_command('TradeNPC 1 "Pure Blood"')	
			windower.send_command('TradeNPC 1 "Spoilt Blood"')	
		elseif var_thiszone == 72 then		-- Alzadaal_Undersea_Ruins
			windower.send_command('TradeNPC 1 "Cog Lubricant"')
			windower.send_command('TradeNPC 1 "Ferrite"')
			windower.send_command('TradeNPC 1 "Opalus Gem" ')
			windower.send_command('TradeNPC 1 "Rodent Cheese"')
		elseif var_thiszone == 79 then		-- Caedarva_Mire
			windower.send_command('TradeNPC 1 "Exorcism Treatise"')


		elseif var_thiszone == 130 then		-- Ru'Aun Gardens
			if math.modf(target.x) == 569 then
				windower.send_command('TradeNPC 1 "Gem of the East" 1 "Springstone"')
			elseif math.modf(target.x) == -510 then
				windower.send_command('TradeNPC 1 "Gem of the South" 1 "Summerstone"')
			elseif math.modf(target.x) == -411 then
				windower.send_command('TradeNPC 1 "Gem of the West" 1 "Autumnstone"')
			elseif math.modf(target.x) == 253 then
				windower.send_command('TradeNPC 1 "Gem of the North" 1 "Winterstone"')
			end

		elseif var_thiszone == 178 then	
			if math.modf(target.x) == -79 then
				windower.send_command('TradeNPC 1 "Seal Of Genbu" 1 "Seal Of Seiryu" 1 "Seal Of Byakko" 1 "`Seal Of Suzaku"')
			end


		elseif var_thiszone == 270 then		-- Cirdas Caverns
			if math.modf(target.x) == -559 then
				windower.send_command('TradeNPC 1 "Slashed Vine"')
			end


		elseif var_thiszone == 39 then		-- Dynamis Valkurm
			if math.modf(target.x) == 63 then
				windower.send_command('TradeNPC 1 "Creeper\'s Juju"')
			end
		

		elseif var_thiszone == 134 then		-- Dynamis Beaucedine
			if math.modf(target.x) == -90 then
				windower.send_command('TradeNPC 1 "Sadist\'s Fortune"')
			end
		


		elseif var_thiszone == 127 then		-- Behemoth Dominion
			windower.send_command('TradeNPC 1 "Savory Shank"')
		end
	

	elseif target.name == 'Lootblox' then
		windower.send_command('TradeNPC 100 "O. Bronzepiece"')
	elseif target.name == 'Antiqix' then
		windower.send_command('TradeNPC 100 "T. Whiteshell"')
	elseif target.name == 'Haggleblix' then
		windower.send_command('TradeNPC 100 "1 Byne Bill"')



	elseif target.name == 'Rune of Release' then
		local var_thiszone = windower.ffxi.get_info()['zone']

		if var_thiszone == 55 then			-- Ilrusi Atoll
			windower.send_command('TradeNPC 1 "Ilrusi Ledger"')
		elseif var_thiszone == 56 then		-- Periqia
			windower.send_command('TradeNPC 1 "Periqia Diary"')
		elseif var_thiszone == 63 then		-- Lebros Cavern
			windower.send_command('TradeNPC 1 "Lebros Chronicle"')
		elseif var_thiszone == 66 then		-- Mamool Ja Training Grounds
			windower.send_command('TradeNPC 1 "Mamool Ja Journal"')
		elseif var_thiszone == 69 then		-- Leujaoam Sanctum
			windower.send_command('TradeNPC 1 "Leujaoam Log"')
		end

	elseif target.name == 'Kilusha' then
		windower.send_command('TradeNPC 1000 "Gil"')

	elseif target.name == 'Entry Gate' then
		windower.send_command('TradeNPC 1 "Glowing Lamp"')

	elseif target.name == 'Planar Rift' then
		windower.send_command('TradeNPC 1 "Cobalt cell"')
		windower.send_command('TradeNPC 1 "Rubicund cell"')
		windower.send_command('TradeNPC 1 "Jade Cell"')
		windower.send_command('TradeNPC 1 "Xanthous cell"')


	elseif target.name == 'Sturdy Pyxis' then
		windower.send_command('TradeNPC 1 "Forbidden Key"')

	elseif target.name == 'Chest' then
		if var_thiszone == 298 then
			windower.send_command('TradeNPC 1 "Skeleton Key"')
			windower.send_command('TradeNPC 1 "Living Key"')
		elseif var_thiszone == 279  then
			windower.send_command('TradeNPC 1 "Skeleton Key"')
			windower.send_command('TradeNPC 1 "Living Key"')
		end

	elseif target.name == 'Coffer' then
		if var_thiszone == 298 then			-- Newton_Movalpolos
			windower.send_command('TradeNPC 1 "Skeleton Key"')
			windower.send_command('TradeNPC 1 "Living Key"')
		elseif var_thiszone == 279  then
			windower.send_command('TradeNPC 1 "Skeleton Key"')
			windower.send_command('TradeNPC 1 "Living Key"')
		end

	elseif target.name == 'Treasure Coffer' then
		local var_thiszone = windower.ffxi.get_info()['zone']
		
		if var_thiszone == 12 then			-- Newton_Movalpolos
			windower.send_command('TradeNPC 1 "Newton Coffer Key"')
		elseif var_thiszone == 147 then		-- Beadeaux
			windower.send_command('TradeNPC 1 "Beadeaux Coffer Key"')
		elseif var_thiszone == 130 then		-- Ru'Aun_Gardens 
			windower.send_command('TradeNPC 1 "Ru\'Aun Coffer Key "')
		elseif var_thiszone == 150 then		-- Monastic_Cavern
			windower.send_command('TradeNPC 1 "Davoi Coffer Key"')
		elseif var_thiszone == 151 then		-- Castle_Oztroja
			windower.send_command('TradeNPC 1 "Oztroja Coffer Key"')
		elseif var_thiszone == 153 then		-- The_Boyahda_Tree
			windower.send_command('TradeNPC 1 "Boyahda Coffer Key"')
		elseif var_thiszone == 160 then		-- Den_of_Rancor 
			windower.send_command('TradeNPC 1 "Den Coffer Key"')
		elseif var_thiszone == 161 then		-- Castle_Zvahl_Baileys
			windower.send_command('TradeNPC 1 "Zvahl Coffer Key"')
		elseif var_thiszone == 169 then		-- Toraimarai_Canal  
			windower.send_command('TradeNPC 1 "Toraimarai Coffer Key"')
		elseif var_thiszone == 174 then		--  Kuftal_Tunnel 
			windower.send_command('TradeNPC 1 "Kuftal Coffer Key"')
		elseif var_thiszone == 176 then		-- Sea_Serpent_Grotto 
			windower.send_command('TradeNPC 1 "Grotto Coffer Key')
		elseif var_thiszone == 177 then		-- Ve'Lugannon_Palace
			windower.send_command('TradeNPC 1 "Ve\'Lugannon Coffer Key"')
		elseif var_thiszone == 195 then		-- The_Eldieme_Necropolis 
			windower.send_command('TradeNPC 1 "Eldieme Coffer Key"')
		elseif var_thiszone == 197 then		-- Crawlers_Nest
			windower.send_command('TradeNPC 1 "Nest Coffer Key"')
		elseif var_thiszone == 200 then		-- Garlaige_Citadel  
			windower.send_command('TradeNPC 1 "Garlaige Coffer Key"')
		elseif var_thiszone == 205 then		-- Ifrits_Cauldron 
			windower.send_command('TradeNPC 1 "Cauldron Coffer Key"')
		elseif var_thiszone == 208 then		-- Quicksand_Caves 
			windower.send_command('TradeNPC 1 "Quicksand Coffer Key"')
		elseif var_thiszone == 259 then		-- Temple_of_Uggalepih  
			windower.send_command('TradeNPC 1 "Uggalepih Coffer Key"')
		end


	elseif target.name == 'Delivery Crate' then
		windower.send_command('TradeNPC 1 "Warrior\'s Mask" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Warrior\'s Lorica" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Warrior\'s Mufflers" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Warrior\'s Cuisses" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Warrior\'s Calligae" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Melee Crown" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Melee Cyclas" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Melee Gloves" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Melee Hose" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Melee Gaiters" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Cleric\'s Cap" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Cleric\'s Briault" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Cleric\'s Mitts" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Cleric\'s Pantaloons" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Cleric\'s Duckbills" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Sorcerer\'s Petasos" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Sorcerer\'s Coat" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Sorcerer\'s Gloves" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Sorcerer\'s Tonban" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Sorcerer\'s Sabots" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Duelist\'s Chapeau" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Duelist\'s Tabard" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Duelist\'s Gloves" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Duelist\'s Tights" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Duelist\'s Boots" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Assassin\'s Bonnet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Assassin\'s Vest" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Assassin\'s Armlets" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Assassin\'s Culottes" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Assassin\'s Poulaines" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Valor Coronet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Valor Surcoat" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Valor Gauntlets" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Valor Breeches" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Valor Leggings" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Valor Coronet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Valor Surcoat" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Valor Gauntlets" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Valor Breeches" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Valor Leggings" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Valor Coronet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Valor Surcoat" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Valor Gauntlets" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Valor Breeches" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Valor Leggings" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Bard\'s Roundlet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Bard\'s Justaucorps" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Bard\'s Cuffs" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Bard\'s Cannions" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Bard\'s Slippers" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Scout\'s Beret" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Scout\'s Jerkin" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Scout\'s Bracers" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Scout\'s Braccae" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Scout\'s Socks" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Saotome Kabuto" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Saotome Domaru" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Saotome Kote" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Saotome Haidate" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Saotome Sune-Ate" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Koga Hatsuburi" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Koga Chainmail" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Koga Tekko" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Koga Hakama" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Koga Kyahan" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Wyrm Armet" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Wyrm Mail" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Wyrm Finger Gauntlets" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Wyrm Brais" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Wyrm Greaves" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Summoner\'s Horn" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Summoner\'s Doublet" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Summoner\'s Bracers" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Summoner\'s Spats" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Summoner\'s Pigaches" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Mirage Keffiyeh" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Mirage Jubbah" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Mirage Bazubands" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Mirage Shalwar" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Mirage Charuqs" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Commodore Tricorne" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Commodore Frac" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Commodore Gants" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Commodore Trews" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Commodore Bottes" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Commodore Tricorne" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Commodore Frac" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Commodore Gants" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Commodore Trews" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Commodore Bottes" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Etoile Tiara" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Etoile Casaque" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Etoile Bangles" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Etoile Tights" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Etoile Toe Shoes" 50 "Forgotten Step"')
		windower.send_command('TradeNPC 1 "Argute Mortarboard" 50 "Forgotten Thought"')
		windower.send_command('TradeNPC 1 "Argute Gown" 50 "Forgotten Hope"')
		windower.send_command('TradeNPC 1 "Argute Bracers" 50 "Forgotten Touch"')
		windower.send_command('TradeNPC 1 "Argute Pants" 50 "Forgotten Journey"')
		windower.send_command('TradeNPC 1 "Argute Loafers" 50 "Forgotten Step"')

		windower.send_command('TradeNPC 1 "Mozu" 50 "Helm of Briareus"')
		windower.send_command('TradeNPC 1 "Kannagi" 50 "Sobek\'s Skin"')
		windower.send_command('TradeNPC 1 "Albion" 50 "carabosse\'s Gem"')
		windower.send_command('TradeNPC 1 "Caladbolg" 50 "Cirein. Lantern"')
	


	elseif Var_IonisNPC:contains(target.name) then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up;wait 0.3;setkey up down;wait 0.1;setkey up up;wait 0.1;setkey enter down;wait 0.1;setkey enter up');	
	elseif Var_SanctionNPC:contains(target.name) then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up;wait 0.3;setkey enter down;wait 0.1;setkey enter up')
	elseif Var_SigilNPC:contains(target.name) then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up;wait 0.3;setkey enter down;wait 0.1;setkey enter up')
	elseif Var_SignetNPC:contains(target.name) then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up')

	elseif Var_GobBoxNPC:contains(target.name) then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up;wait 1; setkey down down;wait 2;setkey down up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;')

	elseif target.name == 'Incantrix' then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey enter down;wait 0.1;setkey enter up')
	elseif target.name == 'Cruor Prospector' then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;wait 0.2;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;wait 0.2;setkey up down;wait 0.1;setkey up up;wait 0.1;setkey enter down;wait 0.1;setkey enter up')
	elseif target.name == 'Atma Infusionist' then
		windower.send_command('setkey enter down;wait 0.1;setkey enter up;wait 2;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;wait 0.3;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey down down;wait 0.1;setkey down up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;wait 0.3;setkey up down;wait 0.1;setkey up up;wait 0.1;setkey enter down;wait 0.1;setkey enter up;wait 0.3;')	



	elseif target.name == 'Trisvain' then
		windower.send_command('htmb')



	elseif target.name == 'Dimensional Portal' then
		windower.send_command('ew z')
	elseif target.name == 'Undulating Confluence' then
		windower.send_command('ew z')



	elseif target.name == 'Bonanza Moogle' then
		windower.send_command('TradeNPC 1 "Bonanza Marble"')

	elseif target.name == 'Festive Moogle' then
		windower.add_to_chat(chatColor, 'test')
		windower.send_command('TradeNPC 1 "Mog Pell (Green)"')
		windower.send_command('TradeNPC 1 "Mog Pell (Red)"')
		windower.send_command('TradeNPC 1 "Mog Pell (silver)"')


	elseif target.name == 'Legion Tome' then
		windower.send_command('TradeNPC 1 "Legion Pass"')

	elseif target.name == 'Mayuyu' then
		windower.send_command('TradeNPC 1 "Lofty Trophy" 1 "Mired Trophy" 1 "Soaring Trophy" 1 "Veiled Trophy"')

	elseif  target.name == 'Maze Mongers Shopfront' then
		windower.send_command('TradeNPC 1 "Maze Tabula M01"')


	elseif target.name == 'Fay Spring' then
		windower.send_command('TradeNPC "Bottled Pixie"')

	elseif target.name == 'Dodmos' then
		windower.send_command('TradeNPC 1 "Mini Fork of Fire"')
	elseif target.name == 'Ferrol' then
		windower.send_command('TradeNPC 1 "Mini Fork of Earth"')
	elseif target.name == 'Lacia' then
		windower.send_command('TradeNPC 1 "Mini Fork of Ltn."')
	elseif target.name == 'Verctissa' then
		windower.send_command('TradeNPC 1 "Mini Fork of Wtr."')
	elseif target.name == 'Rahi Fohlatti' then
		windower.send_command('TradeNPC 1 "Mini Fork of Wind"')
	elseif target.name == 'Castilchat' then
		windower.send_command('TradeNPC 1 "Mini Fork of Ice"')

	elseif target.name == 'Kuu Mohzolh' then
		windower.send_command('TradeNPC 1 "Marguerite"')
	elseif target.name == 'Valah Molkot' then
		windower.send_command('TradeNPC 1 "Amaryllis"')
	elseif target.name == 'Ojha Rhawash' then
		windower.send_command('TradeNPC 1 "Lilac"')
	elseif target.name == 'Zona Shodhun' then
		windower.send_command('TradeNPC 1 "Yellow Rock"')

	end
end