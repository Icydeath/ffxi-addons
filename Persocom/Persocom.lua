--[[
Copyright © 2017, 

mocoloco@gmail.com

This LUA script is written to be used with Chobits Healer 
If you want to use this please provide credit to me. And do no tchange any of the content.

Mahalo nui (Thank you!)

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'Persocom'
_addon.author = 'mocoloco'
_addon.version = '1.0.0.0'
_addon.command = 'Persocom'


local packets = require('packets')
require('pack')
require('tables')


local socket = require("socket")


function sendToCortana(msg, msgtype)
    outmsg = msgtype .. "|" .. msg 
    
    local udp = assert(socket.udp())
    udp:settimeout(1000)

    --Static port to send communicate reset with
    assert(udp:sendto(outmsg, "127.0.0.1",11014))
    assert(udp:close())
end



windower.register_event('incoming chunk', function(id, data)
    
        
    local ptmembers = {'p1','p2','p3','p4','p5'}
    local name_table = T{}
    
    if id == 0x076 then
        ptbuffs = ""
        packtosend = ""
        
        local pts = windower.ffxi.get_party()  
            
        for p = 1, #ptmembers do
           if pts[ptmembers[p]] ~= nil then
                local tInfo = windower.ffxi.get_mob_by_name(pts[ptmembers[p]].name)
                if tInfo ~= nil then
                    name_table:append(tInfo.id)
                    name_table[tInfo.id] = tInfo.name
                end
            end 
        end
            
        for  k = 0, 4 do
            
            local id = data:unpack('I', k*48+5)
            
            if id ~= 0 then
                    
                    
                
                for i = 1, 32 do
                    
                   
                    ptbuffs =  "{" .. data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) .. "}" .. ptbuffs
                end
                if  name_table:contains(id) then
                    packtosend = name_table[id] .. "," .. ptbuffs .. ";" .. packtosend
                else
                    packtosend = id .. ptbuffs .. ";" .. packtosend
                end
                ptbuffs = ""
                
            end
            
            --Enable to debug
            --print(id .. " - Buff data:" .. ptbuffs )
        end
        if packtosend ~= "" then
            sendToCortana(packtosend, "STATUSEFFECT")    
        end
    end
    
end)
