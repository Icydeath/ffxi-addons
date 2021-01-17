--------------------------------------------------------------------------------
local function ByValue(name, search_value, domain)
    for _, value in pairs(domain) do
        if value[name] == search_value then
            return value
        end
    end

    return domain['']
end

--------------------------------------------------------------------------------
local function AllByValue(name, search_value, domain)
    local matches = {}
    for _, value in pairs(domain) do
        if value[name] == search_value then
            table.insert(matches, value)
        end
    end

    table.insert(matches, domain[''])
    return matches
end

--------------------------------------------------------------------------------
local Npcs = {}

Npcs.Values = {}
Npcs.Values['']       = { id = 00000000, en = '',             zone = 000 }
Npcs.Values[17097342] = { id = 17097342, en = 'Entry Gate',   zone = 078 }

--------------------------------------------------------------------------------
function Npcs.GetByProperty(key, value)
    return ByValue(tostring(key), value, Npcs.Values)
end

--------------------------------------------------------------------------------
function Npcs.GetAllByProperty(key, value)
    return AllByValue(tostring(key), value, Npcs.Values)
end

--------------------------------------------------------------------------------
function Npcs.GetClosest()
    local npcs = Npcs.GetAllByProperty('zone', windower.ffxi.get_info().zone)

    local mobs = {}
    for key, value in pairs(npcs) do
        mobs[key] = windower.ffxi.get_mob_by_id(value.id)
    end

    local distances = {}
    for key, value in pairs(mobs) do
        distances[key] = value.distance
    end

    local closest_key
    local closest_dis
    for key, value in pairs(distances) do
        if not closest_dis or closest_dis > value then
            closest_key = key
            closest_dis = value
        end
    end

    return closest_key and npcs[closest_key] or npcs[#npcs]
end

return Npcs