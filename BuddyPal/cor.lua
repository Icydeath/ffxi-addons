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

BuddyPal: Paladin library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]

 
--------------------------------------------------------------------------------
-- Name: corParseAction(String message, String sender)
-- Runs Black Mage chat parser, for multiboxing. 
--------------------------------------------------------------------------------
-- @param message   - String to be parsed for in chat log to trigger event.
-- @param sender    - Name of the player that sent action request.
--------------------------------------------------------------------------------

function corParseAction(message, sender)
    
    local _CORCommands = {}
    
    _CORCommands.JA = {
        {["wcard"]          = "Wild Card",              ["target"] = "<me>"},
        {["doubleup"]       = "Double-Up",              ["target"] = "<me>"},
        {["random"]         = "Random Deal",            ["target"] = "<me>"},
        {["snake"]          = "Snake Eye",              ["target"] = "<me>"},
        {["fold"]           = "Fold",                   ["target"] = "<me>"},
        {["triple"]         = "Triple Shot",            ["target"] = "<me>"},
        {["crook"]          = "Crooked Cards",          ["target"] = "<me>"},
        {["cutting"]        = "Cutting Cards",          ["target"] = "<me>"},
        
        {["chopchop"]       = "Bolter\'s Roll",         ["target"] = "<me>"},
        
        {["fires"]          = "Fire Shot",              ["target"] = "<bt>"},
        {["ices"]           = "Ice Shot",               ["target"] = "<bt>"},
        {["winds"]          = "Wind Shot",              ["target"] = "<bt>"},
        {["earths"]         = "Earth Shot",             ["target"] = "<bt>"},
        {["thunders"]       = "Lightning Shot",         ["target"] = "<bt>"},
        {["waters"]         = "Water Shot",             ["target"] = "<bt>"},
        {["lights"]         = "Light Shot",             ["target"] = "<bt>"},
        {["darks"]          = "Dark Shot",              ["target"] = "<bt>"}}
        
    _CORCommands.MA = {
    
        }
        
    _CORCommands.WS = {
        {["hotshot"]        = "Hot Shot",               ["target"] = "<bt>"},
        {["splitshot"]      = "Split Shot",             ["target"] = "<bt>"},
        {["snipershot"]     = "Sniper Shot",            ["target"] = "<bt>"},
        {["slugshot"]       = "Slug Shot",              ["target"] = "<bt>"},
        {["detonator"]      = "Detonator",              ["target"] = "<bt>"},
        {["leaden"]         = "Leaden Salute",          ["target"] = "<bt>"},
        {["numbing"]        = "Numbing Shot",           ["target"] = "<bt>"},
        {["wf"]             = "Wildfire",               ["target"] = "<bt>"},
        {["lstand"]         = "Last Stand",             ["target"] = "<bt>"},
        
        {["savage"]         = "Savage Blade",           ["target"] = "<bt>"},
        {["evisc"]          = "Evisceration",           ["target"] = "<bt>"}}
        
        
    if config._ja == true then
                
        for k, v in pairs(_CORCommands.JA) do
            
            if _CORCommands.JA[k][message] then
                local name   = _CORCommands.JA[k][message]
                local target = _CORCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_CORCommands.MA) do
            
            if _CORCommands.MA[k][message] then
            
            local name   = _CORCommands.MA[k][message]
            local target = _CORCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ws == true then
                
        for k, v in pairs(_CORCommands.WS) do
            
            if _CORCommands.WS[k][message] then
            
            local name   = _CORCommands.WS[k][message]
            local target = _CORCommands.WS[k]["target"]
            
            windower.send_command('@ input /ws "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end