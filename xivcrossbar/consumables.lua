local action_categories = {
    SPELL = 4,
    ITEM = 5,
    ABILITY_TYPE_1 = 3,
    ABILITY_TYPE_2 = 6,
    ABILITY_TYPE_3 = 14
}

local INVENTORY_BAG = 0

local consumables = {}

function consumables:setup()
    local player = windower.ffxi.get_player()
    self.player_id = player.id
    self.has_updated = false

    -- Ninja Tools Section
    self.is_ninja_main = player.main_job == 'NIN'

    self.item_counts = T{}
end

function consumables:on_action(action)
    if (action.actor_id == self.player_id) then
        if (action.category == action_categories.SPELL) then
            consumables:handle_spell(action.param)
        elseif (action.category == action_categories.ITEM) then
            consumables:handle_item(action.param)
        end
    end
end

local polling_handle = windower.register_event('time change', (function() consumables:poll_for_inventory() end))
windower.register_event('action', (function(action) consumables:on_action(action) end))
windower.register_event('add item', (function(bag, index, id, count) consumables:on_add_item(bag, index, id, count) end))
windower.register_event('remove item', (function(bag, index, id, count) consumables:on_remove_item(bag, index, id, count) end))

-- NIN

local toolbag_lookup = {
    [5308] = 1161, -- Toolbag -> Uchitake
    [5309] = 1164, -- Toolbag -> Tsurara
    [5310] = 1167, -- Toolbag -> Kawahori-ogi
    [5311] = 1170, -- Toolbag -> Makibishi
    [5312] = 1173, -- Toolbag -> Hiraishin
    [5313] = 1176, -- Toolbag -> Mizu-Deppo
    [5314] = 1179, -- Toolbag -> Shihei
    [5315] = 1182, -- Toolbag -> Jusatsu
    [5316] = 1185, -- Toolbag -> Kaginawa
    [5317] = 1188, -- Toolbag -> Sairui-ran
    [5318] = 1191, -- Toolbag -> Kodoku
    [5319] = 1194, -- Toolbag -> Shinobi-Tabi
    [5417] = 2553, -- Toolbag -> Sanjaku-Tenugui
    [5734] = 2555, -- Toolbag -> Soshi
    [5863] = 2642, -- Toolbag -> Kabenro
    [5864] = 2643, -- Toolbag -> Jinko
    [5865] = 2644, -- Toolbag -> Ryuno
    [5866] = 2970, -- Toolbag -> Mokujin
    [5867] = 2971, -- Toolbag -> Inoshishinofuda
    [5868] = 2972, -- Toolbag -> Shikanofuda
    [5869] = 2973, -- Toolbag -> Chonofuda
    [6265] = 8803, -- Toolbag -> Ranka
    [6266] = 8804, -- Toolbag -> Furusumi
}

local ninja_tool_lookup = {
    [318] = 2553, -- Monomi: Ichi -> Sanjaku-Tenugui
    [319] = 2555, -- Aisha: Ichi -> Soshi
    [320] = 1161, -- Katon: Ichi -> Uchitake
    [321] = 1161, -- Katon: Ni -> Uchitake
    [322] = 1161, -- Katon: San -> Uchitake
    [323] = 1164, -- Hyoton: Ichi -> Tsurara
    [324] = 1164, -- Hyoton: Ni -> Tsurara
    [325] = 1164, -- Hyoton: San -> Tsurara
    [326] = 1167, -- Huton: Ichi -> Kawahori-ogi
    [327] = 1167, -- Huton: Ni -> Kawahori-ogi
    [328] = 1167, -- Huton: San -> Kawahori-ogi
    [329] = 1170, -- Doton: Ichi -> Makibishi
    [330] = 1170, -- Doton: Ni -> Makibishi
    [331] = 1170, -- Doton: San -> Makibishi
    [332] = 1173, -- Raiton: Ichi -> Hiraishin
    [333] = 1173, -- Raiton: Ni -> Hiraishin
    [334] = 1173, -- Raiton: San -> Hiraishin
    [335] = 1176, -- Suiton: Ichi -> Mizu-Deppo
    [336] = 1176, -- Suiton: Ni -> Mizu-Deppo
    [337] = 1176, -- Suiton: San -> Mizu-Deppo
    [338] = 1179, -- Utsusemi: Ichi -> Shihei
    [339] = 1179, -- Utsusemi: Ni -> Shihei
    [340] = 1179, -- Utsusemi: San -> Shihei
    [341] = 1182, -- Jubaku: Ichi -> Jusatsu
    [342] = 1182, -- Jubaku: Ni -> Jusatsu
    [343] = 1182, -- Jubaku: San -> Jusatsu
    [344] = 1185, -- Hojo: Ichi -> Kaginawa
    [345] = 1185, -- Hojo: Ni -> Kaginawa
    [346] = 1185, -- Hojo: San -> Kaginawa
    [347] = 1188, -- Kurayami: Ichi -> Sairui-ran
    [348] = 1188, -- Kurayami: Ni -> Sairui-ran
    [349] = 1188, -- Kurayami: San -> Sairui-ran
    [350] = 1191, -- Dokumori: Ichi -> Kodoku
    [351] = 1191, -- Dokumori: Ni -> Kodoku
    [352] = 1191, -- Dokumori: San -> Kodoku
    [353] = 1194, -- Tonko: Ichi -> Shinobi-Tabi
    [354] = 1194, -- Tonko: Ni -> Shinobi-Tabi
    [505] = 8803, -- Gekka: Ichi -> Ranka
    [506] = 8804, -- Yain: Ichi -> Furusumi
    [507] = 2642, -- Myoshu: Ichi -> Kabenro
    [508] = 2643, -- Yurin: Ichi -> Jinko
    [509] = 2644, -- Kakka: Ichi -> Ryuno
    [510] = 2970, -- Migawari: Ichi -> Mokujin
}

local ability_tool_lookup = {
    -- COR
    ['fire-shot'] = 2176, -- Fire Shot -> Fire Card
    ['ice-shot'] = 2177, -- Ice Shot -> Ice Card
    ['wind-shot'] = 2178, -- Wind Shot -> Wind Card
    ['earth-shot'] = 2179, -- Earth Shot -> Earth Card
    ['thunder-shot'] = 2180, -- Thunder Shot -> Thunder Card
    ['water-shot'] = 2181, -- Water Shot -> Water Card
    ['light-shot'] = 2182, -- Light Shot -> Light Card
    ['dark-shot'] = 2183, -- Dark Shot -> Dark Card
}

local master_tool_lookup = {
    -- NIN
    [1179] = 2972, -- Shihei -> Shikanofuda
    [1194] = 2972, -- Shinobi-Tabi -> Shikanofuda
    [2553] = 2972, -- Sanjaku-Tenugui -> Shikanofuda
    [2642] = 2972, -- Kabenro -> Shikanofuda
    [8804] = 2972, -- Furusumi -> Shikanofuda
    [2970] = 2972, -- Mokujin -> Shikanofuda
    [8803] = 2972, -- Ranka -> Shikanofuda
    [2644] = 2972, -- Ryuno -> Shikanofuda
    [1182] = 2973, -- Jusatsu -> Chonofuda
    [1185] = 2973, -- Kaginawa -> Chonofuda
    [1191] = 2973, -- Kodoku -> Chonofuda
    [1188] = 2973, -- Sairui-Ran -> Chonofuda
    [2555] = 2973, -- Soshi -> Chonofuda
    [1173] = 2971, -- Hiraishin -> Inoshishinofuda
    [1167] = 2971, -- Kawahori-Ogi -> Inoshishinofuda
    [1170] = 2971, -- Makibishi -> Inoshishinofuda
    [1176] = 2971, -- Mizu-Deppo -> Inoshishinofuda
    [1164] = 2971, -- Tsurara -> Inoshishinofuda
    [1161] = 2971, -- Uchitake -> Inoshishinofuda
    -- COR
    [2176] = 2974, -- Fire Card -> Trump Card
    [2177] = 2974, -- Ice Card -> Trump Card
    [2178] = 2974, -- Wind Card -> Trump Card
    [2179] = 2974, -- Earth Card -> Trump Card
    [2180] = 2974, -- Thunder Card -> Trump Card
    [2181] = 2974, -- Water Card -> Trump Card
    [2182] = 2974, -- Light Card -> Trump Card
    [2183] = 2974, -- Dark Card -> Trump Card
}

-- TODO: Add support for food/usable items, and (stackable) tradable items

function consumables:poll_for_inventory()
    if (not self.has_updated) then
        local inventory = windower.ffxi.get_items(INVENTORY_BAG)
        self:build_item_cache(inventory)

        if (self.has_updated) then
            windower.unregister_event(polling_handle)
        end
    end
end

function consumables:handle_spell(spell_id)
    local tool_id = ninja_tool_lookup[spell_id]
    if (tool_id ~= nil) then
        self:update_cache()
    end
end

function consumables:handle_item(item_id)
    self:update_cache()
end

function consumables:on_add_item(bag, index, id, count)
    if (master_tool_lookup[id] ~= nil or bag == INVENTORY_BAG) then
        local inventory = windower.ffxi.get_items(INVENTORY_BAG)
        self:build_item_cache(inventory)
    end
end

function consumables:on_remove_item(bag, index, id, count)
    if (self.item_counts[id] ~= nil) then
        local inventory = windower.ffxi.get_items(INVENTORY_BAG)
        self:build_item_cache(inventory)
    end
end

function consumables:update_cache()
    coroutine.schedule((function()
        local inventory = windower.ffxi.get_items(INVENTORY_BAG)
        self:build_item_cache(inventory)
    end), 0.5)
end

function consumables:get_ninja_spell_info(spell_id)
    local tool_id = ninja_tool_lookup[spell_id]
    if (tool_id ~= nil) then
        return self:get_ninja_tool_info(tool_id)
    else
        return nil
    end
end

function consumables:get_ninja_tool_info(tool_id)
    local master_tool_id = master_tool_lookup[tool_id]
    local tool_count = self.item_counts[tool_id]
    local master_tool_count = self.item_counts[master_tool_id]
    return {
        tool_count = self.item_counts[tool_id],
        master_tool_count = self.item_counts[master_tool_id]
    }
end

function consumables:get_ability_info_by_name(ability_name)
    local tool_id = ability_tool_lookup[kebab_casify(ability_name)]
    if (tool_id ~= nil) then
        return self:get_ability_tool_info(tool_id)
    else
        return nil
    end
end

function consumables:get_ability_tool_info(tool_id)
    local master_tool_id = master_tool_lookup[tool_id]
    local tool_count = self.item_counts[tool_id]
    if (master_tool_id) then
        local master_tool_count = self.item_counts[master_tool_id]
        return {
            tool_count = self.item_counts[tool_id],
            master_tool_count = self.item_counts[master_tool_id]
        }
    else
        return {
            tool_count = self.item_counts[tool_id],
            master_tool_count = 0
        }
    end
end

function consumables:get_item_count_by_name(name)
    return self.item_counts[snake_casify(name)]
end

function consumables:build_item_cache(inventory)
    if (inventory) then
        self.has_updated = true
        local ignore_indices = {max = true, count = true, enabled = true}
        local total_counts = T{}

        for i, inv_item in pairs(inventory) do
            if ((not ignore_indices[i]) and inv_item.id ~= 0) then
                local is_stackable = res.items[inv_item.id].stack > 1
                if (is_stackable) then
                    if (total_counts[inv_item.id] == nil) then
                        total_counts[inv_item.id] = inv_item.count
                    else
                        total_counts[inv_item.id] = total_counts[inv_item.id] + inv_item.count
                    end

                    local item_name = snake_casify(res.items[inv_item.id].en)
                    if (total_counts[item_name] == nil) then
                        total_counts[item_name] = inv_item.count
                    else
                        total_counts[item_name] = total_counts[item_name] + inv_item.count
                    end
                end
            end
        end

        self.item_counts = total_counts
    end
end

function snake_casify(str)
    return str:lower():gsub(' ', '_')
end

return consumables
