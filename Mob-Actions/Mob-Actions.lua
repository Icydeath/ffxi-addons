-- Copyright (c) 2014, Sebyg666
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Gametime nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'Mob-Actions'
_addon.version = '1.02 (update: added alert sound)'
_addon.author = 'Sebyg666'
_addon.command = 'MobAct'

--files required to run
require 'maths'
require 'strings'
require 'tables'
require 'lists'
require 'sets'
require 'chat'
require 'logger'
file = require 'files'
texts = require 'texts'
config = require 'config'
res = require 'resources'

local message = {}
local defaults = {}
local mob_name = nil
local mes = {}
--mes.mob_name = mob_name
local mob_abil_name = nil
--mes.mob_abil_name = mob_abil_name
path = windower.addon_path..'Libs/Alarm.wav'

-- set to true (on) or false (off) to see the debug message
defaults.show_debug = false
-- set to true (on) or false (off) to see the echo in chat log of who and what needed stunning
defaults.show_echo = true
-- set to true (on) or false (off) hear a sound for what needs stunning
defaults.play_sound = true

--message box settings
defaults.message_box = {}
defaults.message_box.pos = {}
defaults.message_box.pos.x = 750
defaults.message_box.pos.y = 300
defaults.message_box.bg = {}
defaults.message_box.bg.alpha = 150
defaults.message_box.bg.red = 255
defaults.message_box.bg.green = 255
defaults.message_box.bg.blue = 255
defaults.message_box.text = {}
defaults.message_box.text.size = 24
defaults.message_box.text.font = 'Arial'
defaults.message_box.text.alpha = 255
defaults.message_box.text.red = 255
defaults.message_box.text.green = 17
defaults.message_box.text.blue = 23

settings = config.load(defaults)

--basic message notification on screen
message_string = 'STUN'
mes = texts.new(message_string,settings.message_box)

windower.register_event('load', function()
	---------------------------------------------------
	-- List of mobs to look out for (case sensitive) --
	---------------------------------------------------
    mob_table = T{ 
	---------------------------------------------------
	--                  list start				     --
	--  '--' = comment (this means line is omitted)	 -- 
	---------------------------------------------------
	
	-- Morimar Basalt Fields Delve Fracture monster list
	--	 	'Volatile Matamata'  		-- NOTE: NM #1 has nothing to be watched
			'Perdurable Raptor',		-- NOTE: NM #2
			'Shimmering Tarichuk',		-- NOTE: NM #3 
			'Tutewehiwehi',				-- NOTE: NM #4
			'Kurma',					-- NOTE: NM #5
			'Tojil',					-- NOTE: Mega Boss
		
	-- Foret de Hennetiel Delve Fracture monster list
	--		'Faded Craklaw'  			-- NOTE: NM #1
	--		'Aberrant Uragnite',		-- NOTE: NM #2
	--		'Divagating Jagil',			-- NOTE: NM #3 
	--		'Nerrivik',					-- NOTE: NM #4
	--		'Krabakarpo',				-- NOTE: NM #5
			'Dakuwaqa',					-- NOTE: Mega Boss
		
	-- Ceizak Battlegrounds Delve Fracture monster list
	-- 		'Unfettered Twitherym'  	-- NOTE: NM #1 
			'Supernal Chapuli',			-- NOTE: NM #2
			'Transcendent Scorpion',	-- NOTE: NM #3 
			'Mastop',					-- NOTE: NM #4
			"Tax'et",					-- NOTE: NM #5
			'Muyingwa',					-- NOTE: Mega Boss
		
		
	-- Tester mobs
		-- 'Blanched Mandragora' 	
		-- 'Ominous Weapon'			
	
	
	} -- list end
	
	--------------------------------------------------------------
	--list of TP moves or spells you want to get prompted about --
	--------------------------------------------------------------
	
	-- Morimar Basalt Fields Delve Fracture monster ability/spell lists
	-- mob_table['Volatile Matamata'] = 		T{}
	mob_table['Perdurable Raptor'] = 		T{'Whirling Inferno'}
	mob_table['Shimmering Tarichuk'] = 		T{'Geist Wall'}
	mob_table['Tutewehiwehi'] = 			T{'Calcifying Mist','Grim Glower','Oppressive Glare'}
	mob_table['Kurma'] = 					T{'Testudo Tremor','Tortoise Stomp'}
	mob_table['Tojil'] = 					T{'Incinerating Lahar','Blistering Roar','Volcanic Stasis','Batholithic Shell','Breakga','Meteor'}
	
	-- Foret de Hennetiel Delve Fracture monster ability/spell lists
	mob_table['Faded Craklaw'] = 			T{}
	mob_table['Aberrant Uragnite'] = 		T{}
	mob_table['Divagating Jagil'] = 		T{}
	mob_table['Nerrivik'] = 				T{}
	mob_table['Krabakarpo'] = 				T{}
	mob_table['Dakuwaqa'] = 				T{'Pelagic Cleaver', 'Carcharian Verve','Tidal Guillotine'}
	
	-- Ceizak Battlegrounds Delve Fracture monster ability/spell lists
	mob_table['Unfettered Twitherym'] = 	T{}
	mob_table['Supernal Chapuli'] = 		T{"Nature's Meditation",'Tegmina Buffet','Orthopterror','Aeroga IV','Aeroga V'}
	mob_table['Transcendent Scorpion'] = 	T{'Death Scissors','Hell Scissors'}
	mob_table['Mastop'] = 					T{'Bombilation'}
	mob_table["Tax'et"] = 					T{'Fire Break','Benumbing Blaze','Erosion Dust'}
	mob_table['Muyingwa'] = 				T{'Droning Whirlwind','Incisive Apotheosis','Vespine Hurricane'}
	
	-- Tester mobs
	mob_table['Ominous Weapon']	=		T{'Aero II','Blink','Stone III', 'Haste', 'Regen', 'Poison II','Water II','Bio II',
										'Thunder II','Blizzard II','Smite of Rage'}
	mob_table['Blanched Mandragora'] = 	T{'Dream Flower','Head Butt','Leaf Dagger','Photosynthesis','Scream','Wild Oats',
										'Demonic Flower','Petal Pirouette','Fatal Scream','Tepal Twist'}
		
end)

windower.register_event('action', function(act)
	-------------------------------
	--         variables         --
	-------------------------------
	
	local mob_abil_id
	local mob_targets = T{}
	local party_list = T{}
	local j = windower.ffxi.get_party()
	local message = nil
	local player = windower.ffxi.get_player()
	local spell_start = 24931
	local spell_interupt = 28787
	local claim_id
	local claim_name
	local stunned_message_id = {127, 141, 645}
	local stunned
	
	------------------------------
	-- 		  Core Coding		--
	------------------------------
	
	-- check to see if the act isn't empty
	if act.actor_id then
		-- make sure what we are checking is not nil
		if windower.ffxi.get_mob_by_id(act.actor_id).name ~= nil then
			-- check to see if the mob performing an action is in our list
			if mob_table:contains(windower.ffxi.get_mob_by_id(act.actor_id).name) then
				
				-- get the mobs name using its id
				mob_name = windower.ffxi.get_mob_by_id(act.actor_id).name
				
				-- method to get the id of the target who claimed the mob, 0 if mob is unclaimed
				claim_id = windower.ffxi.get_mob_by_id(act.actor_id).claim_id
				if claim_id == 0 then
					claim_name = 'no-one'
				else
					claim_name = windower.ffxi.get_mob_by_id(claim_id).name
				end
				
				-- create a list of who is in party every time an action occurs
				for index, party_member in pairs(j) do
					if type(party_member) == "table" then
						-- print("index: " ..index)
						-- print("party_member: " ..party_member.mob.name)
						-- print(windower.ffxi.get_mob_by_id(party_member.mob.id).name)
						if party_member.mob then
							party_list:append(party_member.mob.id)
						end
					end
				end
				
				-- if the party list does not include yourself then delete party list
				if not party_list:contains(player.id) then
					party_list:clear()
				end
				
				-- if the action being performed is an ability being ready or a spell being started then continue
				-- 7 = ability or tp move || 8 = spell being started or interrupted
				if act.category == 7 and act.param == spell_start or act.category == 8 and act.param == spell_start then
					
					-- find the target of the action being performed (player or the mob itself)
					for index, targets_key in pairs(act.targets) do
						mob_abil_id = targets_key.actions[index].param
						stunned = targets_key.actions[index].message
						mob_targets:append(targets_key.id)
					end
					
					-- depending on weather its an ability or spell, use its id to find its name via the resources files
					if act.category == 7 and act.param == spell_start then
						mob_abil_name = res.monster_abilities[mob_abil_id].english
					elseif act.category == 8 and act.param == spell_start then
						mob_abil_name = res.spells[mob_abil_id].english
					end
					
					-- check if the party list contains the target of the action, includes the mob itself
					for index, targets_key in pairs(mob_targets) do
						if party_list:contains(targets_key) or act.actor_id == targets_key then
							-- double check that a list of actions was created for the mob
							if mob_table[mob_name] ~= nil then	
								if mob_table[mob_name]:contains(mob_abil_name) then
									message = '\n **************** STUN! **************** \n'
									if defaults.show_echo then
										windower.add_to_chat(123,mob_name..' is using '..mob_abil_name..'. '..message)
									end
									if defaults.play_sound then
										windower.play_sound(path)
									end
									-- mes.mob_name = mob_name
									-- mes.mob_abil_name = mob_abil_name
									mes:update()
									mes:show()
								else
									message = 'NOT IN LIST TO STUN'
								end
							
							-- message in-case mob exists in list but does not have a list of actions to be watched
							else
								windower.add_to_chat(123,'The monster "'..mob_name..'" does not have a list of actions to be watched. \n The name of the monster must be correctly spelt and is case sencitive as are its actions to be watched.')
							end
						end
					end
					
					-- debug message if set to true
					if defaults.show_debug then
						windower.add_to_chat(123,mob_name..' is using '..mob_abil_name..'. '..message..'. claim id: '..claim_id..': '..claim_name..', player id:'..player.id)
					end
				
				-- if the action or spell is not interrupted i.e. the mob finishes its ability / spell (4 = spells)
				elseif act.category == 11 or act.category == 3 or act.category == 4 then
					if defaults.show_echo then
						if mob_table[mob_name] ~= nil then	
							if mob_table[mob_name]:contains(mob_abil_name) then
								if act.category == 4 then
									windower.add_to_chat(123,'Mob-Actions Message:\n*** '..mob_name..'\'s spell: "'..mob_abil_name..'" was not interupted! ***\n --->>> FAILED <<<---')
								else
									windower.add_to_chat(123,'Mob-Actions Message:\n*** '..mob_name..'\'s ability: "'..mob_abil_name..'" was not interupted! ***\n --->>> FAILED <<<---')
								end
							end
						end
					end
					mes:hide()
				elseif act.category == 8 and act.param == spell_interupt or act.category == 7 and act.param == spell_interupt then
					-- message for interrupted spells or abilities if set to true
					if defaults.show_echo then
						if mob_table[mob_name] ~= nil then	
							if mob_table[mob_name]:contains(mob_abil_name) then
								local failure = ''
								if act.category == 7 and act.param == spell_interupt then
									failure = '\'s TP move: "'..mob_abil_name..'" was interrupted! ***\n --->>> SUCCESS <<<---'
								elseif act.category == 8 and act.param == spell_interupt then
									failure = '\'s spell "'..mob_abil_name..'" was interupted successfully ***\n --->>> SUCCESS <<<---'
								end
								windower.add_to_chat(123,'Mob-Actions Message:\n*** '..mob_name..''..failure)
							end
						end
					end
					mes:hide()
				end
			end
		end
	end
	-- clear the mob_target list and the party_list list
	mob_targets:clear()
	party_list:clear()
end)