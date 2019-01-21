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

BuddyPal: Warrior library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
]]
--[[ warParseAction() **

    * 
]]
function warParseAction(message, sender)
    
    local _WARCommands = {}
    
    _WARCommands.JA = {
        {["mighty"]    = "Mighty Strikes",       ["target"] = "<me>"},
        {["voke"]      = "Provoke",              ["target"] = "<bt>"},
        {["serk"]      = "Berserk",              ["target"] = "<me>"},
        {["defe"]      = "Defender",             ["target"] = "<me>"},
        {["warc"]      = "Warcry",               ["target"] = "<me>"},
        {["aggr"]      = "Aggressor",            ["target"] = "<me>"},
        {["retal"]     = "Retaliation",          ["target"] = "<me>"},
        {["wcharge"]   = "Warrior\'s Charge",    ["target"] = "<me>"},
        {["toma"]      = "Tomahawk",             ["target"] = "<bt>"},
        {["rest"]      = "Restraint",            ["target"] = "<me>"},
        {["brage"]     = "Blood Rage",           ["target"] = "<me>"},
        {["brush"]     = "Brazen Rush",          ["target"] = "<bt>"}}
        
    _WARCommands.MA = {}
        
        
    if config._ja == true then
                
        for k, v in pairs(_WARCommands.JA) do
            
            if _WARCommands.JA[k][message] then
                local name   = _WARCommands.JA[k][message]
                local target = _WARCommands.JA[k]["target"]
            
                windower.send_command('@ input /ja "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
    if config._ma == true then
                
        for k, v in pairs(_WARCommands.MA) do
            
            if _WARCommands.MA[k][message] then
            
            local name   = _WARCommands.MA[k][message]
            local target = _WARCommands.MA[k]["target"]
            
            windower.send_command('@ input /ma "' .. name .. '" ' .. target .. '')
            
            end
            
        end    
    
    end
    
end