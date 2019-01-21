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

BuddyPal: Red Mage library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]
--[[ rdmParseAction() **

    * 
]]
function rdmParseAction(message, sender)
    
    local _RDMCommands = {}
    
    _RDMCommands.JA = {
        {["convert"]     = "Convert",        ["target"] = "<me>"},
        {["cspell"]      = "Chain Spell",    ["target"] = "<me>"},
        {["comp"]        = "Composure",      ["target"] = "<me>"},
        {["sabo"]        = "Sabotuer",       ["target"] = "<me>"},
        {["spon"]        = "Spontaneity",    ["target"] = sender},
        {["stym"]        = "Stymie",         ["target"] = "<me>"}}
        
    _RDMCommands.MA = {
        {["dia"]         = "Dia",           ["target"] = "<bt>"},
        {["dia2"]        = "Dia II",        ["target"] = "<bt>"},
        {["dia3"]        = "Dia III",       ["target"] = "<bt>"},
        {["bio"]         = "Bio",           ["target"] = "<bt>"},
        {["bio2"]        = "Bio II",        ["target"] = "<bt>"},
        {["bio3"]        = "Bio III",       ["target"] = "<bt>"},
        {["psn"]         = "Poison",        ["target"] = "<bt>"},
        {["psn"]         = "Poison II",     ["target"] = "<bt>"},
        {["lyze"]        = "Paralyze",      ["target"] = "<bt>"},
        {["lyze2"]       = "Paralyze II",   ["target"] = "<bt>"},
        {["slow"]        = "Slow",          ["target"] = "<bt>"},
        {["slow2"]       = "Slow II",       ["target"] = "<bt>"},
        {["blind"]       = "Blind",         ["target"] = "<bt>"},
        {["blind2"]      = "Blind II",      ["target"] = "<bt>"},
        {["grav"]        = "Gravity",       ["target"] = "<bt>"},
        {["grav2"]       = "Gravity II",    ["target"] = "<bt>"},
        {["silence"]     = "Silence",       ["target"] = "<bt>"},
        {["bind"]        = "Bind",          ["target"] = "<bt>"},
        {["inun"]        = "Inundation",    ["target"] = "<bt>"},
        {["addle"]       = "Addle",         ["target"] = "<bt>"},
        {["addle2"]      = "Addle II",      ["target"] = "<bt>"},
        {["dist"]        = "Distract",      ["target"] = "<bt>"},
        {["dist2"]       = "Distract II",   ["target"] = "<bt>"},
        {["dist3"]       = "Distract III",  ["target"] = "<bt>"},
        {["fraz"]        = "Frazzle",       ["target"] = "<bt>"},
        {["fraz2"]       = "Frazzle II",    ["target"] = "<bt>"},
        {["fraz3"]       = "Frazzle III",   ["target"] = "<bt>"},
        
        {["temp"]        = "Temper",        ["target"] = "<me>"},
        {["temp2"]       = "Temper II",     ["target"] = "<me>"},
        {["flur"]        = "Flurry",        ["target"] = sender},
        {["flur2"]       = "Flurry II",     ["target"] = sender},
        {["haste"]       = "Haste",         ["target"] = sender},
        {["haste2"]      = "Haste II",      ["target"] = sender},
        {["fresh"]       = "Refresh",       ["target"] = sender},
        {["fresh2"]      = "Refresh II",    ["target"] = sender},
        {["fresh3"]      = "Refresh III",   ["target"] = sender},
        {["phx1"]         = "Phalanx",       ["target"] = "<me>"},
        {["phx2"]        = "Phalanx II",    ["target"] = sender},
        
        {["bspikes"]     = "Blaze Spike",   ["target"] = "<me>"},
        {["ispikes"]     = "Ice Spikes",    ["target"] = "<me>"},
        {["sspikes"]     = "Shock Spikes",  ["target"] = "<me>"},
        
        {["drain"]       = "Drain",         ["target"] = "<bt>"},
        {["drain2"]      = "Drain II",      ["target"] = "<bt>"},
        {["aspir"]       = "Aspir",         ["target"] = "<bt>"},
        {["aspir2"]      = "Aspir II",      ["target"] = "<bt>"},
        
        {["raise"]       = "Raise",          ["target"] = sender},
        {["raise2"]      = "Raise II",       ["target"] = sender},
        
        {["break"]       = "Break",          ["target"] = "<bt>"},
    
        {["f1"]          = "Fire",          ["target"] = "<bt>"},
        {["f2"]          = "Fire II",       ["target"] = "<bt>"},
        {["f3"]          = "Fire III",      ["target"] = "<bt>"},
        {["f4"]          = "Fire IV",       ["target"] = "<bt>"},
        {["f5"]          = "Fire V",        ["target"] = "<bt>"},
        
        {["b1"]          = "Blizzard",      ["target"] = "<bt>"},
        {["b2"]          = "Blizzard II",   ["target"] = "<bt>"},
        {["b3"]          = "Blizzard III",  ["target"] = "<bt>"},
        {["b4"]          = "Blizzard IV",   ["target"] = "<bt>"},
        {["b5"]          = "Blizzard V",    ["target"] = "<bt>"},
        
        {["a1"]          = "Aero",          ["target"] = "<bt>"},
        {["a2"]          = "Aero II",       ["target"] = "<bt>"},
        {["a3"]          = "Aero III",      ["target"] = "<bt>"},
        {["a4"]          = "Aero IV",       ["target"] = "<bt>"},
        {["a5"]          = "Aero V",        ["target"] = "<bt>"},
        
        {["s1"]          = "Stone",         ["target"] = "<bt>"},
        {["s2"]          = "Stone II",      ["target"] = "<bt>"},
        {["s3"]          = "Stone III",     ["target"] = "<bt>"},
        {["s4"]          = "Stone IV",      ["target"] = "<bt>"},
        {["s5"]          = "Stone V",       ["target"] = "<bt>"},
        
        {["t1"]          = "Thunder",       ["target"] = "<bt>"},
        {["t2"]          = "Thunder II",    ["target"] = "<bt>"},
        {["t3"]          = "Thunder III",   ["target"] = "<bt>"},
        {["t4"]          = "Thunder IV",    ["target"] = "<bt>"},
        {["t5"]          = "Thunder V",     ["target"] = "<bt>"},
        
        {["w1"]          = "Water",         ["target"] = "<bt>"},
        {["w2"]          = "Water II",      ["target"] = "<bt>"},
        {["w3"]          = "Water III",     ["target"] = "<bt>"},
        {["w4"]          = "Water IV",      ["target"] = "<bt>"},
        {["w5"]          = "Water V",       ["target"] = "<bt>"}}
        
        
    if config._ja == true then
                
        for k, v in pairs(_RDMCommands.JA) do
            
            if _RDMCommands.JA[k][message] then
                local name   = _RDMCommands.JA[k][message]
                local target = _RDMCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_RDMCommands.MA) do
            
            if _RDMCommands.MA[k][message] then
            
            local name   = _RDMCommands.MA[k][message]
            local target = _RDMCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end