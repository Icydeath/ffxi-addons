local spellsThatRequireJA = {}
local spellSet = {}
-- BLU - Unbridled Learning/Wisdom
spellSet['absolute terror'] = true
spellSet['bilgestorm'] = true
spellSet['blistering roar'] = true
spellSet['bloodrake'] = true
spellSet['carcharian verve'] = true
spellSet['cesspool'] = true
spellSet['crashing thunder'] = true
spellSet['cruel joke'] = true
spellSet['droning whirlwind'] = true
spellSet['gates of hades'] = true
spellSet['harden shell'] = true
spellSet['mighty guard'] = true
spellSet['polar roar'] = true
spellSet['pyric bulwark'] = true
spellSet['tearing gust'] = true
spellSet['thunderbolt'] = true
spellSet['tourbillion'] = true
spellSet['uproot'] = true
-- SCH - Tabula Rasa
spellSet['embrava'] = true
spellSet['kaustra'] = true
-- SCH - Addendum: White
spellSet['poisona'] = true
spellSet['paralyna'] = true
spellSet['blindna'] = true
spellSet['silena'] = true
spellSet['cursna'] = true
spellSet['erase'] = true
spellSet['reraise'] = true
spellSet['viruna'] = true
spellSet['stona'] = true
spellSet['raise ii'] = true
spellSet['reraise ii'] = true
spellSet['raise iii'] = true
spellSet['reraise iii'] = true
-- SCH - Addendum: Black
spellSet['sleep'] = true
spellSet['dispel'] = true
spellSet['sleep ii'] = true
spellSet['stone iv'] = true
spellSet['water iv'] = true
spellSet['aero iv'] = true
spellSet['fire iv'] = true
spellSet['blizzard iv'] = true
spellSet['thunder iv'] = true
spellSet['stone v'] = true
spellSet['water v'] = true
spellSet['aero v'] = true
spellSet['fire v'] = true
spellSet['blizzard v'] = true
spellSet['thunder v'] = true

function spellsThatRequireJA:contains(spellName)
    return spellSet[spellName]
end

return spellsThatRequireJA