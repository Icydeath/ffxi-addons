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
--------------------------------------------------------------------------------
local Lamps = {}
Lamps.Values = {}

-- Nil Lamp
Lamps.Values['']   = { id = 0000, en = '' }

-- Lamps
Lamps.Values[5413] = { id = 5413, en = 'Smouldering Lamp' }
Lamps.Values[5414] = { id = 5414, en = 'Glowing Lamp' }

--------------------------------------------------------------------------------
function Lamps.GetByProperty(key, value)
    return ByValue(tostring(key), value, Lamps.Values)
end

--------------------------------------------------------------------------------
function Lamps.GetAllByProperty(key, value)
    return AllByValue(tostring(key), value, Lamps.Values)
end

return Lamps
