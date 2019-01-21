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

BuddyPal: Geomancer library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]
--[[ geoParseAction() **

    * 
]]
function geoParseAction(message, sender)
    
    local _GEOCommands = {}
    
    _GEOCommands.JA = {
        {["bolster"]           = "Bolster",                ["target"] = "<me>"},
        {["fcircle"]           = "Full Circle",            ["target"] = "<me>"},
        {["lasting"]           = "Lasting Emanation",      ["target"] = "<me>"},
        {["eclip"]             = "Ecliptic Attrition",     ["target"] = "<me>"},
        {["fervor"]            = "Collimated Fervor",      ["target"] = "<me>"},
        {["lcycle"]            = "Life Cycle",             ["target"] = "<me>"},
        {["BOG"]               = "Blaze of Glory",         ["target"] = "<me>"},
        {["dema"]              = "Dematerialize",          ["target"] = "<me>"},
        {["entrust"]           = "Entrust",                ["target"] = "<me>"},
        {["radial"]            = "Radial Arcana",          ["target"] = "<me>"},
        {["tfocus"]            = "Theurgic Focus",         ["target"] = "<me>"},
        {["cpulse"]            = "Concentric Pulse",       ["target"] = "<me>"},
        {["wcompass"]          = "Widened Compass",        ["target"] = "<me>"}}
        
    _GEOCommands.MA = {
        {["ipoison"]     = "Indi-Poison",           ["target"] = "<me>"},
        {["ivoid"]       = "Indi-Voidance",         ["target"] = "<me>"},
        {["iprec"]       = "Indi-Precision",        ["target"] = "<me>"},
        {["iregen"]      = "Indi-Regen",            ["target"] = "<me>"},
        {["iattune"]     = "Indi-Attunement",       ["target"] = "<me>"},
        {["ifocus"]      = "Indi-Focus",            ["target"] = "<me>"},
        {["ibarr"]       = "Indi-Barrier",          ["target"] = "<me>"},
        {["ifresh"]      = "Indi-Refresh",          ["target"] = "<me>"},
        {["ichr"]        = "Indi-CHR",              ["target"] = "<me>"},
        {["imnd"]        = "Indi-MND",              ["target"] = "<me>"},
        {["ifury"]       = "Indi-Fury",             ["target"] = "<me>"},
        {["iint"]        = "Indi-INT",              ["target"] = "<me>"},
        {["iagi"]        = "Indi-AGI",              ["target"] = "<me>"},
        {["ifend"]       = "Indi-Fend",             ["target"] = "<me>"},
        {["ivit"]        = "Indi-VIT",              ["target"] = "<me>"},
        {["idex"]        = "Indi-DEX",              ["target"] = "<me>"},
        {["iacum"]       = "Indi-Acumen",           ["target"] = "<me>"},
        {["istr"]        = "Indi-STR",              ["target"] = "<me>"},
        {["islow"]       = "Indi-Slow",             ["target"] = "<me>"},
        {["itorp"]       = "Indi-Torpor",           ["target"] = "<me>"},
        {["islip"]       = "Indi-Slip",             ["target"] = "<me>"},
        {["ilang"]       = "Indi-Languor",          ["target"] = "<me>"},
        {["ipara"]       = "Indi-Paralysis",        ["target"] = "<me>"},
        {["ivex"]        = "Indi-Vex",              ["target"] = "<me>"},
        {["ifrail"]      = "Indi-Frailty",          ["target"] = "<me>"},
        {["iwilt"]       = "Indi-Wilt",             ["target"] = "<me>"},
        {["igrav"]       = "Indi-Gravity",          ["target"] = "<me>"},
        {["imala"]       = "Indi-Malaise",          ["target"] = "<me>"},
        {["ihaste"]      = "Indi-Haste",            ["target"] = "<me>"},
        {["ifade"]       = "Indi-Fade",             ["target"] = "<me>"},
        
        {["gpoison"]     = "Geo-Poison",            ["target"] = "<bt>"},
        {["gvoid"]       = "Geo-Voidance",          ["target"] = "<bt>"},
        {["gprec"]       = "Geo-Precision",         ["target"] = "<bt>"},
        {["gregen"]      = "Geo-Regen",             ["target"] = "<bt>"},
        {["gattune"]     = "Geo-Attunement",        ["target"] = "<bt>"},
        {["gfocus"]      = "Geo-Focus",             ["target"] = "<bt>"},
        {["gbarr"]       = "Geo-Barrier",           ["target"] = "<bt>"},
        {["gfresh"]      = "Geo-Refresh",           ["target"] = "<bt>"},
        {["gchr"]        = "Geo-CHR",               ["target"] = "<bt>"},
        {["gmnd"]        = "Geo-MND",               ["target"] = "<bt>"},
        {["gfury"]       = "Geo-Fury",              ["target"] = "<bt>"},
        {["gint"]        = "Geo-INT",               ["target"] = "<bt>"},
        {["gagi"]        = "Geo-AGI",               ["target"] = "<bt>"},
        {["gfend"]       = "Geo-Fend",              ["target"] = "<bt>"},
        {["gvit"]        = "Geo-VIT",               ["target"] = "<bt>"},
        {["gdex"]        = "Geo-DEX",               ["target"] = "<bt>"},
        {["gacum"]       = "Geo-Acumen",            ["target"] = "<bt>"},
        {["gstr"]        = "Geo-STR",               ["target"] = "<bt>"},
        {["gslow"]       = "Geo-Slow",              ["target"] = "<bt>"},
        {["gtorp"]       = "Geo-Torpor",            ["target"] = "<bt>"},
        {["gslip"]       = "Geo-Slip",              ["target"] = "<bt>"},
        {["glang"]       = "Geo-Languor",           ["target"] = "<bt>"},
        {["gpara"]       = "Geo-Paralysis",         ["target"] = "<bt>"},
        {["gvex"]        = "Geo-Vex",               ["target"] = "<bt>"},
        {["gfrail"]      = "Geo-Frailty",           ["target"] = "<bt>"},
        {["gwilt"]       = "Geo-Wilt",              ["target"] = "<bt>"},
        {["ggrav"]       = "Geo-Gravity",           ["target"] = "<bt>"},
        {["gmala"]       = "Geo-Malaise",           ["target"] = "<bt>"},
        {["ghaste"]      = "Geo-Haste",             ["target"] = "<bt>"},
        {["gfade"]       = "Geo-Fade",              ["target"] = "<bt>"},
        
        {["epoison"]     = "Indi-Poison",           ["target"] = sender},
        {["evoid"]       = "Indi-Voidance",         ["target"] = sender},
        {["eprec"]       = "Indi-Precision",        ["target"] = sender},
        {["eregen"]      = "Indi-Regen",            ["target"] = sender},
        {["eattune"]     = "Indi-Attunement",       ["target"] = sender},
        {["efocus"]      = "Indi-Focus",            ["target"] = sender},
        {["ebarr"]       = "Indi-Barrier",          ["target"] = sender},
        {["efresh"]      = "Indi-Refresh",          ["target"] = sender},
        {["echr"]        = "Indi-CHR",              ["target"] = sender},
        {["emnd"]        = "Indi-MND",              ["target"] = sender},
        {["efury"]       = "Indi-Fury",             ["target"] = sender},
        {["eint"]        = "Indi-INT",              ["target"] = sender},
        {["eagi"]        = "Indi-AGI",              ["target"] = sender},
        {["efend"]       = "Indi-Fend",             ["target"] = sender},
        {["evit"]        = "Indi-VIT",              ["target"] = sender},
        {["edex"]        = "Indi-DEX",              ["target"] = sender},
        {["eacum"]       = "Indi-Acumen",           ["target"] = sender},
        {["estr"]        = "Indi-STR",              ["target"] = sender},
        {["eslow"]       = "Indi-Slow",             ["target"] = sender},
        {["etorp"]       = "Indi-Torpor",           ["target"] = sender},
        {["eslip"]       = "Indi-Slip",             ["target"] = sender},
        {["elang"]       = "Indi-Languor",          ["target"] = sender},
        {["epara"]       = "Indi-Paralysis",        ["target"] = sender},
        {["evex"]        = "Indi-Vex",              ["target"] = sender},
        {["efrail"]      = "Indi-Frailty",          ["target"] = sender},
        {["ewilt"]       = "Indi-Wilt",             ["target"] = sender},
        {["egrav"]       = "Indi-Gravity",          ["target"] = sender},
        {["emala"]       = "Indi-Malaise",          ["target"] = sender},
        {["ehaste"]      = "Indi-Haste",            ["target"] = sender},
        {["efade"]       = "Indi-Fade",             ["target"] = sender},
        
        {["gtpoison"]     = "Geo-Poison",            ["target"] = sender},
        {["gtvoid"]       = "Geo-Voidance",          ["target"] = sender},
        {["gtprec"]       = "Geo-Precision",         ["target"] = sender},
        {["gtregen"]      = "Geo-Regen",             ["target"] = sender},
        {["gtattune"]     = "Geo-Attunement",        ["target"] = sender},
        {["gtfocus"]      = "Geo-Focus",             ["target"] = sender},
        {["gtbarr"]       = "Geo-Barrier",           ["target"] = sender},
        {["gtfresh"]      = "Geo-Refresh",           ["target"] = sender},
        {["gtchr"]        = "Geo-CHR",               ["target"] = sender},
        {["gtmnd"]        = "Geo-MND",               ["target"] = sender},
        {["gtfury"]       = "Geo-Fury",              ["target"] = sender},
        {["gtint"]        = "Geo-INT",               ["target"] = sender},
        {["gtagi"]        = "Geo-AGI",               ["target"] = sender},
        {["gtfend"]       = "Geo-Fend",              ["target"] = sender},
        {["gtvit"]        = "Geo-VIT",               ["target"] = sender},
        {["gtdex"]        = "Geo-DEX",               ["target"] = sender},
        {["gtacum"]       = "Geo-Acumen",            ["target"] = sender},
        {["gtstr"]        = "Geo-STR",               ["target"] = sender},
        {["gtslow"]       = "Geo-Slow",              ["target"] = sender},
        {["gttorp"]       = "Geo-Torpor",            ["target"] = sender},
        {["gtslip"]       = "Geo-Slip",              ["target"] = sender},
        {["gtlang"]       = "Geo-Languor",           ["target"] = sender},
        {["gtpara"]       = "Geo-Paralysis",         ["target"] = sender},
        {["gtvex"]        = "Geo-Vex",               ["target"] = sender},
        {["gtfrail"]      = "Geo-Frailty",           ["target"] = sender},
        {["gtwilt"]       = "Geo-Wilt",              ["target"] = sender},
        {["gtgrav"]       = "Geo-Gravity",           ["target"] = sender},
        {["gtmala"]       = "Geo-Malaise",           ["target"] = sender},
        {["gthaste"]      = "Geo-Haste",             ["target"] = sender},
        {["gtfade"]       = "Geo-Fade",              ["target"] = sender},
        
        {["sleep"]       = "Sleep",         ["target"] = "<bt>"},
        {["sleep2"]      = "Sleep II",      ["target"] = "<bt>"},
        
        {["drain"]       = "Drain",         ["target"] = "<bt>"},
        {["drain2"]      = "Drain II",      ["target"] = "<bt>"},
        {["aspir"]       = "Aspir",         ["target"] = "<bt>"},
        {["aspir2"]      = "Aspir II",      ["target"] = "<bt>"},
        {["aspir3"]      = "Aspir III",     ["target"] = "<bt>"},
        
        {["f1"]          = "Fire",          ["target"] = "<bt>"},
        {["f2"]          = "Fire II",       ["target"] = "<bt>"},
        {["f3"]          = "Fire III",      ["target"] = "<bt>"},
        {["f4"]          = "Fire IV",       ["target"] = "<bt>"},
        {["f5"]          = "Fire V",        ["target"] = "<bt>"},
        {["f6"]          = "Fire VI",       ["target"] = "<bt>"},
        {["fra1"]        = "Fira",          ["target"] = "<bt>"},
        {["fra2"]        = "Fira II",       ["target"] = "<bt>"},
        {["fra3"]        = "Fira III",      ["target"] = "<bt>"},
        
        {["b1"]          = "Blizzard",      ["target"] = "<bt>"},
        {["b2"]          = "Blizzard II",   ["target"] = "<bt>"},
        {["b3"]          = "Blizzard III",  ["target"] = "<bt>"},
        {["b4"]          = "Blizzard IV",   ["target"] = "<bt>"},
        {["b5"]          = "Blizzard V",    ["target"] = "<bt>"},
        {["b6"]          = "Blizzard VI",   ["target"] = "<bt>"},
        {["bra1"]        = "Blizzara",      ["target"] = "<bt>"},
        {["bra2"]        = "Blizzara II",   ["target"] = "<bt>"},
        {["bra3"]        = "Blizzara III",  ["target"] = "<bt>"},
        
        {["a1"]          = "Aero",          ["target"] = "<bt>"},
        {["a2"]          = "Aero II",       ["target"] = "<bt>"},
        {["a3"]          = "Aero III",      ["target"] = "<bt>"},
        {["a4"]          = "Aero IV",       ["target"] = "<bt>"},
        {["a5"]          = "Aero V",        ["target"] = "<bt>"},
        {["a6"]          = "Aero VI",       ["target"] = "<bt>"},
        {["ara1"]        = "Aera",          ["target"] = "<bt>"},
        {["ara2"]        = "Aera II",       ["target"] = "<bt>"},
        {["ara3"]        = "Aera III",      ["target"] = "<bt>"},
        
        {["s1"]          = "Stone",         ["target"] = "<bt>"},
        {["s2"]          = "Stone II",      ["target"] = "<bt>"},
        {["s3"]          = "Stone III",     ["target"] = "<bt>"},
        {["s4"]          = "Stone IV",      ["target"] = "<bt>"},
        {["s5"]          = "Stone V",       ["target"] = "<bt>"},
        {["s6"]          = "Stone VI",      ["target"] = "<bt>"},
        {["sra1"]        = "Stonera",       ["target"] = "<bt>"},
        {["sra2"]        = "Stonera II",    ["target"] = "<bt>"},
        {["sra3"]        = "Stonera III",   ["target"] = "<bt>"},
        
        {["t1"]          = "Thunder",       ["target"] = "<bt>"},
        {["t2"]          = "Thunder II",    ["target"] = "<bt>"},
        {["t3"]          = "Thunder III",   ["target"] = "<bt>"},
        {["t4"]          = "Thunder IV",    ["target"] = "<bt>"},
        {["t5"]          = "Thunder V",     ["target"] = "<bt>"},
        {["t6"]          = "Thunder VI",    ["target"] = "<bt>"},
        {["tra1"]        = "Thundara",      ["target"] = "<bt>"},
        {["tra2"]        = "Thundara II",   ["target"] = "<bt>"},
        {["tra3"]        = "Thundara III",  ["target"] = "<bt>"},
        
        {["w1"]          = "Water",         ["target"] = "<bt>"},
        {["w2"]          = "Water II",      ["target"] = "<bt>"},
        {["w3"]          = "Water III",     ["target"] = "<bt>"},
        {["w4"]          = "Water IV",      ["target"] = "<bt>"},
        {["w5"]          = "Water V",       ["target"] = "<bt>"},
        {["w6"]          = "Water VI",      ["target"] = "<bt>"},
        {["wra1"]        = "Watera",        ["target"] = "<bt>"},
        {["wra2"]        = "Watera II",     ["target"] = "<bt>"},
        {["wra3"]        = "Watera III",    ["target"] = "<bt>"}}
        
        
    if config._ja == true then
                
        for k, v in pairs(_GEOCommands.JA) do
            
            if _GEOCommands.JA[k][message] then
                local name   = _GEOCommands.JA[k][message]
                local target = _GEOCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_GEOCommands.MA) do
            
            if _GEOCommands.MA[k][message] then
            
            local name   = _GEOCommands.MA[k][message]
            local target = _GEOCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end