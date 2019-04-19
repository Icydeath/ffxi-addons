_addon.name = "autoRing"
_addon.author = "Godchain"
_addon.version = "1.0"
_addon.commands = {"autoRing", "ar"}

require("logger")
extdata = require("extdata")

lang = string.lower(windower.ffxi.get_info().language)
item_info = {
    [1]={id=27557,japanese='',english='"Trizek Ring"',slot=13},
    [2]={id=26165,japanese='',english='"Facility Ring"',slot=13},
	[3]={id=28563,japanese='',english='"Vocation Ring"',slot=13},
    [4]={id=28546,japanese='',english='"Capacity Ring"',slot=13}
}

function search_item()
    local item_array = {}
    local bags = {0, 8, 10, 11, 12} --inventory,wardrobe1-4
    local get_items = windower.ffxi.get_items
    for i = 1, #bags do
        for _, item in ipairs(get_items(bags[i])) do
            if item.id > 0 then
                item_array[item.id] = item
                item_array[item.id].bag = bags[i]
            end
        end
    end
    for index, stats in pairs(item_info) do
        local item = item_array[stats.id]
        local set_equip = windower.ffxi.set_equip
        if item then
            local ext = extdata.decode(item)
            local charges = ext.charges_remaining
            local enchant = ext.type == "Enchanted Equipment"
            local recast = enchant and charges > 0 and math.max(ext.next_use_time + 18000 - os.time(), 0)
            local usable = recast and recast == 0
            if (charges == 0) then
                log(stats[lang] .. ": out of charges.")
            elseif (recast > 0) then
                log(stats[lang] .. ": " .. recast .. " sec. on recast.")
            else
                log(stats[lang] .. ": equipped (" .. charges .. " left).")
            end
            if usable or ext.type == "General" then
                if enchant and item.status ~= 5 then --not equipped
                    set_equip(item.slot, stats.slot, item.bag)
                    log_flag = true
                    repeat --waiting cast delay
                        coroutine.sleep(1)
                        local ext = extdata.decode(get_items(item.bag, item.slot))
                        local delay = ext.activation_time + 18000 - os.time()
                        if delay > 0 then
                            log(delay)
                        elseif log_flag then
                            log_flag = false
                            log("Using " .. stats[lang] .. ".")
                        end
                    until ext.usable or delay > 10
                end
                windower.chat.input('/item "' .. windower.to_shift_jis(stats[lang]) .. '" <me>')
                break
            end
        else
            log("You don't have " .. stats[lang] .. ".")
        end
    end
end

windower.register_event(
    "addon command",
    function()
        local player = windower.ffxi.get_player()
        local get_spells = windower.ffxi.get_spells()
        search_item()
    end
)
