local database = {}

database.spells = {}
database.abilities = {}

-- import skills from xml files
function database:import()
    self:parse_abilities()
    self:parse_spells()

    return true
end

function database:parse_abilities()
	
	-- Job Abilities
	for key, entry in pairs(resources.job_abilities) do
		local new_abil = {}
		
		-- handle values not set in job abilities
		new_abil.skillChainA = ""
		new_abil.skillChainB = ""
		new_abil.skillChainC = ""
		new_abil.cast = "0"
		new_abil.recast = "0"
		
		for attr, val in pairs(entry) do
            if attr == 'id' then
                new_abil.id = tostring(val)
            elseif attr == 'recast_id' then -- job_abilities icons are mapped using the recast_id and not the icon_id
                new_abil.icon = tostring(val) 
            elseif attr == 'en' then
                new_abil.name = val
            elseif attr == 'mp_cost' then
                new_abil.mpcost = tostring(val)
            elseif attr == 'tp_cost' then
                new_abil.tpcost = tostring(val)
			elseif attr == 'element' then
				new_abil.element = resources.elements[val].en
			elseif attr == 'type' then
                new_abil.type = val
            -- elseif attr == 'casttime' then
                -- new_abil.cast = val
            -- elseif attr == 'recast' then 
                -- new_abil.recast = val
            -- elseif attr == 'wsA' then
                -- new_abil.skillChainA = val
            -- elseif attr == 'wsB' then
                -- new_abil.skillChainB = val
            -- elseif attr == 'wsC' then
                -- new_abil.skillChainC = val
            
            end
        end
		
		self.abilities[(new_abil.name):lower()] = new_abil
	end
	
	-- Weapon Skills
	for key, entry in pairs(resources.weapon_skills) do
		local new_abil = {}
		
		-- handle values not set in weapon_skills
		new_abil.cast = "0"
		new_abil.recast = "0"
		new_abil.type = "WeaponSkill"
		new_abil.tpcost = "0"
		new_abil.mpcost = "0"
		
		for attr, val in pairs(entry) do
            if attr == 'id' then
                new_abil.id = tostring(val)
            elseif attr == 'icon_id' then
                new_abil.icon = tostring(val)
            elseif attr == 'en' then
                new_abil.name = val
			elseif attr == 'element' then
				new_abil.element = resources.elements[val].en
            elseif attr == 'skillchain_a' then
                new_abil.skillChainA = val
            elseif attr == 'skillchain_b' then
                new_abil.skillChainB = val
            elseif attr == 'skillchain_c' then
                new_abil.skillChainC = val
			-- elseif attr == 'mp_cost' then
                -- new_abil.mpcost = val
            -- elseif attr == 'tp_cost' then
                -- new_abil.tpcost = val
			-- elseif attr == 'type' then
                -- new_abil.type = val
            -- elseif attr == 'casttime' then
                -- new_abil.cast = val
            -- elseif attr == 'recast' then 
                -- new_abil.recast = val
            end
        end
		
		self.abilities[(new_abil.name):lower()] = new_abil
	end
end

-- parse spells xml
function database:parse_spells()
    for key, entry in pairs(resources.spells) do
        local new_spell = {}

        for attr, val in pairs(entry) do
            if attr == 'id' then
                new_spell.id = tostring(val)
				new_spell.icon = tostring(val)
            --elseif attr == 'icon_id' then
				--new_spell.icon = tostring(val)
            elseif attr == 'en' then
                new_spell.name = val
            elseif attr == 'mp_cost' then
                new_spell.mpcost = tostring(val)
            elseif attr == 'cast_time' then
                new_spell.cast = tostring(val)
            elseif attr == 'element' then
                new_spell.element = resources.elements[val].en
            elseif attr == 'recast' then
                new_spell.recast = tostring(val)
            elseif attr == 'type' then
                new_spell.type = val
            end
        end

        self.spells[(new_spell.name):lower()] = new_spell
    end
end

return database