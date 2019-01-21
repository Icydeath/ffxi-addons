--[[

Copyright © 2016, Elidyr
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

################################################################################################

BuddyPal: White Mage library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]
--[[ whmParseAction() **

    * 
]]
function whmParseAction(message, sender)
    
    local _WHMCommands = {}
    
    _WHMCommands.JA = {
        {["bene"]        = "Benediction",       ["target"] = "<me>"},
        {["dseal"]       = "Divine Seal",       ["target"] = "<bt>"},
        {["devote"]      = "Devotion",          ["target"] = "<me>"},
        {["solace"]      = "Afflatus Solace",   ["target"] = "<me>"},
        {["misery"]      = "Afflatus Misery",   ["target"] = sender},
        {["caress"]      = "Divine Caress",     ["target"] = "<me>"},
        {["sancro"]      = "Sacrosanctity",     ["target"] = "<me>"},
        {["asylum"]      = "Asylum",            ["target"] = sender}}
        
    _WHMCommands.MA = {
        {["dia1"]           = "Dia",            ["target"] = "<bt>"},
        {["dia2"]           = "Dia II",         ["target"] = "<bt>"},
        {["diaga"]          = "Dia II",         ["target"] = "<bt>"},
        {["lyze"]           = "Paralyze",       ["target"] = "<bt>"},
        {["slow"]           = "Slow",           ["target"] = "<bt>"},
        {["silence"]        = "Silence",        ["target"] = "<bt>"},
        {["addle"]          = "Addle",          ["target"] = "<bt>"},
        {["repose"]         = "Repose",         ["target"] = "<bt>"},
        {["holy1"]          = "Holy",           ["target"] = "<bt>"},
        {["holy2"]          = "Holy II",        ["target"] = "<bt>"},
        {["banish1"]        = "Banish",         ["target"] = "<bt>"},
        {["banish2"]        = "Banish II",      ["target"] = "<bt>"},
        {["banish2"]        = "Banish III",     ["target"] = "<bt>"},
        {["banishga1"]      = "Banishga",       ["target"] = "<bt>"},
        {["banishga2"]      = "Banishga II",    ["target"] = "<bt>"},
        {["flash"]          = "Flash",          ["target"] = "<bt>"},
        
        {["haste"]          = "Haste",          ["target"] = sender},
        {["erase"]          = "Erase",          ["target"] = sender},        
        {["poisona"]        = "Poisona",        ["target"] = sender},
        {["poison"]         = "Poisona",        ["target"] = sender},
        {["poisoned"]       = "Poisona",        ["target"] = sender},        
        {["Silena"]         = "Silena",         ["target"] = sender},
        {["silenced"]       = "Silena",         ["target"] = sender},        
        {["blindna"]        = "Blindna",        ["target"] = sender},
        {["blind"]          = "Blindna",        ["target"] = sender},
        {["blinded"]        = "Blindna",        ["target"] = sender},        
        {["paralyna"]       = "Paralyna",       ["target"] = sender},
        {["para"]           = "Paralyna",       ["target"] = sender},
        {["paralyze"]       = "Paralyna",       ["target"] = sender},        
        {["cursna"]         = "Cursna",         ["target"] = sender},
        {["curse"]          = "Cursna",         ["target"] = sender},
        {["cursed"]         = "Cursna",         ["target"] = sender},
        {["doom"]           = "Cursna",         ["target"] = sender},        
        {["viruna"]         = "Viruna",         ["target"] = sender},
        {["virus"]          = "Viruna",         ["target"] = sender},        
        {["stona"]          = "Stona",          ["target"] = sender},
        {["stoned"]         = "Stona",          ["target"] = sender},
        {["pet"]            = "Stona",          ["target"] = sender},
        {["petra"]          = "Stona",          ["target"] = sender},        
        {["sacri"]          = "Sacrifice",      ["target"] = sender},        
        
        {["aqua"]           = "Aquaveil",       ["target"] = "<me>"},
        {["blink"]          = "Blink",          ["target"] = "<me>"},
        {["skin"]           = "Stoneskin",      ["target"] = "<me>"},
        {["auspice"]        = "Auspice",        ["target"] = "<me>"},
        {["boostdex"]       = "Boost-DEX",      ["target"] = "<me>"},
        {["booststr"]       = "Boost-STR",      ["target"] = "<me>"},
        {["boostagi"]       = "Boost-AGI",      ["target"] = "<me>"},
        {["boostvit"]       = "Boost-VIT",      ["target"] = "<me>"},
        {["boostchr"]       = "Boost-CHR",      ["target"] = "<me>"},
        {["boostint"]       = "Boost-INT",      ["target"] = "<me>"},
        {["boostmnd"]       = "Boost-MND",      ["target"] = "<me>"},
        
        {["cura1"]          = "Cura",           ["target"] = "<me>"},
        {["cura2"]          = "Cura II",        ["target"] = "<me>"},
        {["cura3"]          = "Cura III",       ["target"] = "<me>"},
        
        {["bars"]           = "Barstonra",      ["target"] = "<me>"},
        {["barsleep"]       = "Barsleepra",     ["target"] = "<me>"},
        {["barw"]           = "Barwatera",      ["target"] = "<me>"},
        {["barpoison"]      = "Barpoisonra",    ["target"] = "<me>"},
        {["barpara"]        = "Barparalyna",    ["target"] = "<me>"},
        {["bara"]           = "Baraera",        ["target"] = "<me>"},
        {["barf"]           = "Barfira",        ["target"] = "<me>"},
        {["barblind"]       = "Barblindra",     ["target"] = "<me>"},
        {["barb"]           = "Barblizzara",    ["target"] = "<me>"},
        {["barsilence"]     = "Barsilencera",   ["target"] = "<me>"},
        {["bart"]           = "Barthundara",    ["target"] = "<me>"},
        {["barvira"]        = "Barvira",        ["target"] = "<me>"},
        {["barpetra"]       = "Barpetra",       ["target"] = "<me>"},
        {["baramne"]        = "Baramnesra",     ["target"] = "<me>"},
        
        {["tele-dem"]       = "Teleport-Dem",   ["target"] = "<me>"},
        {["tele-hol"]       = "Teleport-Holla", ["target"] = "<me>"},
        {["tele-mea"]       = "Teleport-Mea",   ["target"] = "<me>"},
        {["tele-alt"]       = "Teleport-Altep", ["target"] = "<me>"},
        {["tele-yho"]       = "Teleport-Yhoat", ["target"] = "<me>"},
        {["tele-vah"]       = "Teleport-Vahzl", ["target"] = "<me>"},
        {["recall-jug"]     = "Recall-Jugner",  ["target"] = "<me>"},
        {["recall-mer"]     = "Recall-Meriph",  ["target"] = "<me>"},
        {["recall-pas"]     = "Recall-Pashh",   ["target"] = "<me>"},
        
        {["protectra"]      = "Protectra V",    ["target"] = "<me>"},
        {["shellra"]        = "Shellra V",      ["target"] = "<me>"},
        
        {["c1"]             = "Cure",           ["target"] = sender},
        {["c2"]             = "Cure II",        ["target"] = sender},
        {["c3"]             = "Cure III",       ["target"] = sender},
        {["c4"]             = "Cure IV",        ["target"] = sender},
        {["c5"]             = "Cure V",         ["target"] = sender},
        {["c6"]             = "Cure VI",        ["target"] = sender},
        {["cg1"]            = "Curaga",         ["target"] = sender},
        {["cg2"]            = "Curaga II",      ["target"] = sender},
        {["cg3"]            = "Curaga III",     ["target"] = sender},
        {["cg4"]            = "Curaga IV",      ["target"] = sender},
        {["cg5"]            = "Curaga V",       ["target"] = sender},
        {["fullcure"]       = "Full Cure",      ["target"] = sender},
        
        {["pro1"]           = "Protect",        ["target"] = sender},
        {["pro2"]           = "Protect II",     ["target"] = sender},
        {["pro3"]           = "Protect III",    ["target"] = sender},
        {["pro4"]           = "Protect IV",     ["target"] = sender},
        {["pro5"]           = "Protect V",      ["target"] = sender},
        {["shell1"]         = "Shell",          ["target"] = sender},
        {["shell2"]         = "Shell II",       ["target"] = sender},
        {["shell3"]         = "Shell III",      ["target"] = sender},
        {["shell4"]         = "Shell IV",       ["target"] = sender},
        {["shell5"]         = "Shell V",        ["target"] = sender},
        
        {["regen1"]         = "Regen",          ["target"] = sender},
        {["regen2"]         = "Regen II",       ["target"] = sender},
        {["regen3"]         = "Regen III",      ["target"] = sender},
        {["regen4"]         = "Regen IV",       ["target"] = sender},
        
        {["raise1"]         = "Raise",          ["target"] = sender},
        {["raise2"]         = "Raise II",       ["target"] = sender},
        {["raise3"]         = "Raise II",       ["target"] = sender},
        {["arise"]          = "Arise",          ["target"] = sender}}
        
        
    if config._ja == true then
                
        for k, v in pairs(_WHMCommands.JA) do
            
            if _WHMCommands.JA[k][message] then
                local name   = _WHMCommands.JA[k][message]
                local target = _WHMCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_WHMCommands.MA) do
            
            if _WHMCommands.MA[k][message] then
            
            local name   = _WHMCommands.MA[k][message]
            local target = _WHMCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end