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

BuddyPal: Scholar library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]
--[[ schParseAction() **

    * 
]]
function schParseAction(message, sender)
    
    local _SCHCommands = {}
    
    _SCHCommands.JA = {
        {["wcard"]          = "Wild Card",              ["target"] = "<me>"},
        {[""]               = "Double-Up",              ["target"] = "<me>"},
        {["hcircle"]        = "Random Deal",            ["target"] = "<me>"},
        {["sent"]           = "Snake Eye",              ["target"] = "<me>"},
        {["cover"]          = "Fold",                   ["target"] = "<me>"},
        {["ramp"]           = "Triple Shot",            ["target"] = "<me>"},
        {["fealty"]         = "Crooked Cards",          ["target"] = "<me>"},
        {["chivalry"]       = "Cutting Cards",          ["target"] = "<me>"},
        
        {["chopchop"]       = "Bolter\'s Roll",         ["target"] = "<bt>"},
        
        {["fires"]          = "Fire Shot",              ["target"] = "<bt>"},
        {["ices"]           = "Ice Shot",               ["target"] = "<bt>"},
        {["winds"]          = "Wind Shot",              ["target"] = "<bt>"},
        {["earths"]         = "Earth Shot",             ["target"] = "<bt>"},
        {["thunders"]       = "Lightning Shot",         ["target"] = "<bt>"},
        {["waters"]         = "Water Shot",             ["target"] = "<bt>"},
        {["lights"]         = "Light Shot",             ["target"] = "<bt>"},
        {["darks"]          = "Dark Shot",              ["target"] = "<bt>"}}
        
    _SCHCommands.MA = {
        }
        
        
    if config._ja == true then
                
        for k, v in pairs(_SCHCommands.JA) do
            
            if _SCHCommands.JA[k][message] then
                local name   = _SCHCommands.JA[k][message]
                local target = _SCHCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_SCHCommands.MA) do
            
            if _SCHCommands.MA[k][message] then
            
            local name   = _SCHCommands.MA[k][message]
            local target = _SCHCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end