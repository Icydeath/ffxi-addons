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
local Chambers = {}
Chambers.Values = {}

-- Nil Chamber
Chambers.Values['']   = { idx = 0, en = '' }

-- Chambers
Chambers.Values[01] = { idx = 01, tier = 01, uk3 = 40705, x =  447.6451953, y = -9.379000664,   z = -217.3540039, en = 'Rossweisse\'s Chamber' }
Chambers.Values[02] = { idx = 02, tier = 01, uk3 = 24321, x =  207.358017,  y =  007.738000393, z = -197.3540039, en = 'Grimgerde\'s Chamber' }
Chambers.Values[03] = { idx = 03, tier = 01, uk3 = 24321, x =  127.2450027, y = -232.8470154,   z = -177.3540039, en = 'Siegrune\'s Chamber' }
Chambers.Values[04] = { idx = 04, tier = 02, uk3 = 24321, x = -151.4430084, y = -393.2810059,   z = -147.3540039, en = 'Helmwige\'s Chamber' }
Chambers.Values[05] = { idx = 05, tier = 02, uk3 = 40705, x = -391.1300049, y = -328.1620178,   z = -127.3540039, en = 'Schwertleite\'s Chamber' }
Chambers.Values[06] = { idx = 06, tier = 02, uk3 = 40705, x = -632.1830444, y = -167.1180115,   z = -107.3540039, en = 'Waltraute\'s Chamber' }
Chambers.Values[07] = { idx = 07, tier = 03, uk3 = 57089, x = -527.6430054, y =  111.163002,    z = -67.35400391, en = 'Ortlinde\'s Chamber' }
Chambers.Values[08] = { idx = 08, tier = 03, uk3 = 57089, x = -406.4190635, y =  350.4610291,   z = -47.35400391, en = 'Gerhilde\'s Chamber' }
Chambers.Values[09] = { idx = 09, tier = 03, uk3 = 07937, x = -129.6670074, y =  289.6010132,   z = -7.354000568, en = 'Brunhilde\'s Chamber' }

--------------------------------------------------------------------------------
function Chambers.GetByProperty(key, value)
    return ByValue(tostring(key), value, Chambers.Values)
end

--------------------------------------------------------------------------------
function Chambers.GetAllByProperty(key, value)
    return AllByValue(tostring(key), value, Chambers.Values)
end

return Chambers
