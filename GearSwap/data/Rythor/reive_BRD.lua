--[[
 CREATOR: Zubrin [ffxiah.com user]
 Thread: http://www.ffxiah.com/forum/topic/40125/brd-script-skill-up/
 

 A BRD skillup gearswap lua. 
 This gearswap lua is meant to be used to target Lair Reives or any other attackable stationary target that can give skillups.
 
 To load the file use the following command:
 //gs load reive_BRD.lua
 
 To toggle it on and off use the following command:
 //gs c Skill
 
 
 **** Don't forget Ionis/Moogle trust/Food (B.E.W. Pitaru) ***
 ]]

function get_sets()

	SkillUp = 'OFF'
	
	sets.precast= {}
	
	sets.precast.FC = {
		main="Felibre's Dague",
		range="Terpander",
		head="Fili Calot",
		body="Praeco Doublet",
		hands="Bewegt Cuffs",
		legs="Fili Rhingrave",
		feet="Fili Cothurnes",
		neck="Aoidos' Matinee",
		waist="Witful Belt",
		left_ear="Aoidos' Earring",
		right_ear="Loquac. Earring",
		back="Ogapepo Cape",
	}
		
	sets.midcast = {}
		
	sets.midcast.Skill = {body="Temachtiani Shirt",hands="Temachtiani Gloves"}

end

function precast(spell)

	equip(sets.precast.FC)

end

function midcast(spell)

	if SkillUp == 'ON' then
		equip(sets.midcast.Skill)
	end

end

function aftercast(spell)

	if SkillUp == 'ON' then
		if spell.english == 'Fire Threnody' then
			if not buffactive['food'] then
				send_command('@wait 3;input /item "B.E.W. Pitaru" <me>;wait 5; input /ma "Ice Threnody" <t>')
			else
				send_command('@wait 3;input /ma "Ice Threnody" <t>')
			end
		elseif spell.english == 'Ice Threnody' then
			send_command('@wait 3;input /ma "Wind Threnody" <t>')
		elseif spell.english == 'Wind Threnody' then
			send_command('@wait 3;input /ma "Earth Threnody" <t>')
		elseif spell.english == 'Earth Threnody' then
			send_command('@wait 3;input /ma "Ltng. Threnody" <t>')
		elseif spell.english == 'Ltng. Threnody' then
			send_command('@wait 3;input /ma "Water Threnody" <t>')
		elseif spell.english == 'Water Threnody' then
			send_command('@wait 3;input /ma "Light Threnody" <t>')
		elseif spell.english == 'Light Threnody' then
			send_command('@wait 3;input /ma "Dark Threnody" <t>')
		elseif spell.english == 'Dark Threnody' then
			send_command('@wait 3;input /ma "Fire Threnody" <t>')
		end
	end
		

end

function self_command(command)

	if command == 'Skill' then
		if SkillUp == 'OFF' then
			SkillUp = 'ON' 
			add_to_chat(158,'Skill Mode: ['..SkillUp..']')
			send_command('@input /ma "Fire Threnody" <t>')
		else
			SkillUp = 'OFF'
			add_to_chat(158,'Skill Mode: ['..SkillUp..']')	
		end
	end

end