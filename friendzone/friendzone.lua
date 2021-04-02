_addon.name = 'Frienzone'
_addon.author = 'Lili'
_addon.version = '0.2.0'
_addon.commands = {'friendzone','fz','fim'}

require('logger')
require('tables')
require('strings')

-- Put the trusts you want in here, in the order you want them.
-- Use spell names, case sensitive.
-- You can put as many trusts as you want, when one trust is on recast the next will be called, up to how many are allowed in party.
-- It is possible to specify a trust list per zone.
-- TODO: make a settings file.

local trusts = {}
trusts.default = {"AAEV","Ayame","Joachim","Ulmia","Kupipi" }
trusts["Reisenjima"] = { }
trusts["La Theine Plateau"] = {}
trusts["Escha - Zi'Tah"] = trusts["Reisenjima"]
trusts["Escha - Ru'Aun"] = trusts["Reisenjima"]
trusts["Marjami Ravine"] = { }
trusts["Walk of Echoes [P1]"] = {} 
trusts["Walk of Echoes [P2]"] = trusts["Walk of Echoes [P1]"]

-- Special cases:
-- This list will be used when under the effect of Elvorseal.
trusts["Domain Invasion"] = { "AAEV", "Selh'teus", "Arciela II", "Ulmia", "Sylvie (UC)", "Trion", "Kupipi", "Joachim", }
-- This list will be used when under the effect of Reive Mark.
trusts["Reives"] = { "AAEV", "Selh'teus", "Arciela II", "Ulmia", "Sylvie (UC)", "Trion", "Kupipi","Joachim", }

-- TODO: add tables per job/subjob

local delay = 7

-------------------------------------------------------------------------------
------------------ No changerino the things below here mkay -------------------
-------------------------------------------------------------------------------
local active = false

local res = {}
res.buffs = require('resources').buffs
res.zones = require('resources').zones
res.trusts = {}

-- these help prevent the addon from summoning trusts immediately when loaded.
local moving = true 
local player_id = false

-- returns current zone name
local function get_zone()
    return res.zones[windower.ffxi.get_info().zone].en
end

-- returns true if current zone is a city or town. 
local in_town = function()
	local Cities = S{ 
            "Northern San d'Oria", "Southern San d'Oria", "Port San d'Oria", "Chateau d'Oraguille",
            "Bastok Markets", "Bastok Mines", "Port Bastok", "Metalworks",
            "Windurst Walls", "Windurst Waters", "Windurst Woods", "Port Windurst", "Heavens Tower",
            "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno",
            "Selbina", "Mhaura", "Kazham", "Norg", "Rabao", "Tavnazian Safehold",
            "Aht Urhgan Whitegate", "Al Zahbi", "Nashmau",
            "Southern San d'Oria (S)", "Bastok Markets (S)", "Windurst Waters (S)",
            -- "Walk of Echoes", "Provenance",
            "Western Adoulin", "Eastern Adoulin", "Celennia Memorial Library",
            "Bastok-Jeuno Airship", "Kazham-Jeuno Airship", "San d'Oria-Jeuno Airship", "Windurst-Jeuno Airship",
            "Ship bound for Mhaura", "Ship bound for Selbina", "Open sea route to Al Zahbi", "Open sea route to Mhaura",
            "Silver Sea route to Al Zahbi", "Silver Sea route to Nashmau", "Manaclipper", "Phanauet Channel",
            "Chocobo Circuit", "Feretory", "Mog Garden", 
            }
    return function()
        if Cities:contains(get_zone()) then
            return true
        end
    end
end()

-- check for Walk of Echoes
local in_woe = function()
    return windower.ffxi.get_info().zone == 182
end

-- trust checks, from less expensive to more expensive
local can_summon = function()

    -- if player_id is false then we're logged out/not logged in yet
    if not player_id then
        return false
    end
    
    -- we're logged in, but moving and/or in town
    if moving or in_town() then 
        return false 
    end
    
    local party = windower.ffxi.get_party()
    
    -- can't summon trusts with a full party *or* while in alliance
    if party.p5 or party.alliance_leader then 
        return false
    end

    -- and of course can only summon if party leader
    if party.party1_count > 1 and party.party1_leader ~= player_id then
        return false
    end
    
	local player = windower.ffxi.get_player()

    -- 0 = Idle, 1 = Engaged, anything else means no can trusts
    if player.status > 1 then
        return false
    end
    
    -- make a buffactive table identical to gearswap
	local buffactive = S(player.buffs):map(function(id) return res.buffs[id].name end)
    
    -- friendship is magic, literally
    if buffactive['silence'] or buffactive['mute'] or buffactive['Omerta']then 
        return false 
    end
    
    if player.in_combat then 
        -- Trusts allowed during Reives, Domain Invasion, and Walk of Echoes
        -- this will return false if in combat outside of those situations.
        return (buffactive['Reive Mark'] or buffactive['Elvorseal'] or in_woe())
    end
    
    return true
end

-- check if trust has already been summoned
local have_trust = function(trustname)
	local party = windower.ffxi.get_party()
	for i = 1,5 do
		local member = party['p' .. i]
		if member then
			if member.name:lower() == trustname:lower() then
                return true 
            end
		end
        -- recall on low mp to be added here
	end

	return false
end

-- check if it's possible to call a trust.
local check_trust = function()
    if current_trusts.n < 1 then return end
    
	if can_summon() then
        local spell_recasts = windower.ffxi.get_spell_recasts()
        for i,v in ipairs(current_trusts) do
            local trust = res.trusts[v]
            if trust and spell_recasts[trust.id] < 1 and not have_trust(trust.party_name) then
                log('Calling %s':format(trust.spell_name))
                windower.chat.input('/ma "%s" <me>':format(trust.spell_name))
                return
            end
        end
    end
end

local choose_trusts = function()

    local buffs = L(windower.ffxi.get_player().buffs)
    local special = (buffs:contains(603) and 'Domain Invasion') or (buffs:contains(511) and 'Reives')

    local area = special or get_zone() -- could simplify but I like the readability

    if trusts[area] then
        current_trusts = L(trusts[area])
        if current_trusts.n < 1 then -- if a table exists but it's empty, it means we don't want trusts there.
            log('Trusts for %s are disabled.':format(area))
        else
            log('Loaded trust setup for %s.':format(area))
        end
    else
        current_trusts = L(trusts.default)
    end
    
    if not active then
        active = check_trust:loop(delay)
    end
end

windower.register_event('load','login', function()
    if not windower.ffxi.get_info().logged_in then
        player_id = false
        return false
    end
    
    player_id = windower.ffxi.get_player().id
    
    -- populate a resource table containing only the trusts that the player knows.
    res.trusts = function()
        local trust_data = T{}
        for id,t in pairs(require('resources').spells) do
            if t.type == 'Trust' and windower.ffxi.get_spells()[id] then
                trust_data[t.en] = {
                        ['id'] = t.id,
                        ['spell_name'] = t.en,
                        ['party_name'] = t.en:gsub('AA','Ark'):gsub(' %(UC%)',''):gsub(' II',''):gsub(' ','')
                    }
            end
        end
        return trust_data
    end()

    choose_trusts:schedule(delay)
end)

-- refresh trust table everytime you zone
windower.register_event('zone change',function()
    if active then
        coroutine.close(active)
        active = false
    end
    
    choose_trusts:schedule(delay)
end)

-- known issue: currently does not load domain invasion/reive tables if you load the addon while already under those buffs.
-- nvm now it do

windower.register_event('gain buff','lose buff',function(id)
    -- refresh trust list when we gain or lose Elvorseal and Reive Mark buffs.
    if id ~= 603 or id ~= 511 then
        return
    end
    choose_trusts()
end)

windower.register_event('logout',function()
    player_id = false
end)

windower.register_event('outgoing chunk',function(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        moving = lastlocation ~= modified:sub(5, 16)
        lastlocation = modified:sub(5, 16)
		wasmoving = moving
    end
end)

windower.register_event('incoming text',function(text)
    if active and string.find(text,'While inviting a party member, you must wait a while before using Trust magic.') then
        log('Trust cooldown, retrying in 30 seconds.')

        coroutine.close(active)
        active = false
        choose_trusts:schedule(30)
    end
end)

windower.register_event('addon command',function(...)
    local args = T{...}:concat(' ')
    if args == 'r' or args == 'reload' then
        windower.send_command('lua r friendzone')
        return
    elseif args == 'default' then
        log('Loading default trust list.')
        windower.send_command('lua r friendzone')
        return
    elseif args == 'check' then
        if not current_trusts or current_trusts.n < 1 then
            log('Too soon.')
            return
        end
        log('Current trusts:',current_trusts:concat(', '))
        return
    end
    
    if #args < 4 then 
        return
    end
    
    new_trusts = L{}
    for arg in args:gmatch('%s?([^,]+)') do
        if not res.trusts[arg] then
            log('Trust not found: '..arg)
        else
            new_trusts:append(arg)
        end
    end
    
    if new_trusts.n < 1 then
        log('Usage:\n//fim Trust 1, Trust 2, ..., Trust 5\nComma separated list of trusts you want.\nMake sure you know the trusts.')
        return
    end
    log('New Trusts: %s':format(new_trusts:concat(', ')))
    current_trusts = new_trusts
end)

log('Friendship is magic! Welcome.')
