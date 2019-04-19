--[[

Copyright © 2018, Wiener
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of EschaWarp nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

_addon.name = 'EschaWarp'
_addon.author = 'Wiener'
_addon.version = '1.1.1'
_addon.command = 'ew'

require('tables')
local packets = require('packets')
local _portals = require('portals')

local _targetPortal = nil
local _entryPortal = nil
local _packet = nil
local _lastPacket = nil
local _warping = false

windower.register_event('addon command', function(...)
    local args = T{...}
    local cmd = args[1]

    if cmd == "reset" then
        ResetDialogue()
    elseif cmd == "z" or cmd == "zone" then
        local info = windower.ffxi.get_info()
        if info then
            _entryPortal = _portals[info.zone]
            if _entryPortal then
                _packet = VerifyZone(info.zone)
                if _packet then
                    _warping = true
                    _lastPacket = _packet
                    EngageDialogue(_packet['Target'], _packet['Target Index'])
                end
            else
                windower.add_to_chat(10, string.format("Zone #%d not setup!", info.zone))
            end
        else
            windower.add_to_chat(10, "Windower info nil.")
        end
    else
        local targetPortalNumber = tonumber(cmd)
        if type(targetPortalNumber) == 'number' then
            targetPortalNumber = math.floor(targetPortalNumber)
            local info = windower.ffxi.get_info()
            if info then
                _packet = VerifyWarp(info.zone)
                if _packet then
                    local zonePortals = _portals[info.zone]
                    if zonePortals then
                        if targetPortalNumber >= 1 and targetPortalNumber <= #zonePortals then
                            _targetPortal = zonePortals[targetPortalNumber]
                            if _targetPortal then
                                _warping = true
                                _lastPacket = _packet
                                EngageDialogue(_packet['Target'], _packet['Target Index'])
                            else
                                windower.add_to_chat(10, string.format("Portal #%d not setup!", targetPortalNumber))
                            end
                        else
                            windower.add_to_chat(10, string.format("Portal #%d not found in zone!", targetPortalNumber))
                        end
                    else
                        windower.add_to_chat(10, "Not in Escha zone!")
                    end
                end
            else
                windower.add_to_chat(10, "Windower info nil.")
            end
        else
            windower.add_to_chat(10, "Portal number must be a...number.")
        end
    end
end)

function EngageDialogue(target, targetIndex)
	if target and targetIndex then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=target,
			["Target Index"]=targetIndex,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
    if id == 0x034 or id == 0x032 then
        if _warping and _packet then
            if _targetPortal then
                local p = packets.parse('incoming',data)
    		    if p['Menu ID'] == 9100 then
                    packets.inject(packets.new('outgoing', 0x114))

                    local dpacket = packets.new('outgoing', 0x05B)
                    dpacket["Target"]=_packet['Target']
                    dpacket["Option Index"]=_targetPortal.doi
                    dpacket["_unknown1"]=_targetPortal.du1
                    dpacket["Target Index"]=_packet['Target Index']
                    dpacket["Automated Message"]=true
                    dpacket["_unknown2"]=0
                    dpacket["Zone"]=_packet['Zone']
                    dpacket["Menu ID"]=p['Menu ID']
                    packets.inject(dpacket)

                    local wpacket = packets.new('outgoing', 0x05C)
                    wpacket["X"]=_targetPortal.x
                    wpacket["Z"]=_targetPortal.z
                    wpacket["Y"]=_targetPortal.y
                    wpacket["Target ID"]=_packet['Target']
                    wpacket["_unknown1"]=_targetPortal.wu1
                    wpacket["Target Index"]=_packet['Target Index']
                    wpacket["_unknown3"]=_targetPortal.wu3
                    wpacket["Zone"]=_packet['Zone']
                    wpacket["Menu ID"]=p['Menu ID']
                    packets.inject(wpacket)

                    dpacket["Target"]=_packet['Target']
                    dpacket["Option Index"]=2
                    dpacket["_unknown1"]=0
                    dpacket["Target Index"]=_packet['Target Index']
                    dpacket["Automated Message"]=false
                    dpacket["_unknown2"]=0
                    dpacket["Zone"]=_packet['Zone']
                    dpacket["Menu ID"]=p['Menu ID']
                    packets.inject(dpacket)

            		_packet = nil
                    _targetPortal = nil
                    _warping = false
            		return true
                end
            elseif _entryPortal then
                local p = packets.parse('incoming',data)
                if p['Menu ID'] == _entryPortal.menuId then
                    local dpacket = packets.new('outgoing', 0x05B)

                    dpacket["Target"]=_packet['Target']
                    dpacket["Option Index"]=0
                    dpacket["_unknown1"]=0
                    dpacket["Target Index"]=_packet['Target Index']
                    dpacket["Automated Message"]=true
                    dpacket["_unknown2"]=0
                    dpacket["Zone"]=_packet['Zone']
                    dpacket["Menu ID"]=p['Menu ID']
                    packets.inject(dpacket)

                    dpacket["Target"]=_packet['Target']
                    dpacket["Option Index"]=_entryPortal.oi
                    dpacket["_unknown1"]=0
                    dpacket["Target Index"]=_packet['Target Index']
                    dpacket["Automated Message"]=false
                    dpacket["_unknown2"]=0
                    dpacket["Zone"]=_packet['Zone']
                    dpacket["Menu ID"]=p['Menu ID']
                    packets.inject(dpacket)

            		_packet = nil
                    _entryPortal = nil
                    _warping = false
            		return true
                end
            end
        end
	end
end)

function GetBasePortalPacket(zoneId, portalName)
    local playerMob = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
    for i,v in pairs(windower.ffxi.get_mob_array()) do
        if string.find(v.name, portalName) then
            local distance = GetDistance(playerMob.x, playerMob.y, playerMob.z, v.x, v.y, v.z)
            if distance < 6 then
                windower.add_to_chat(10,'Found: '..v.name..'  Distance:'..string.format("%.2f", distance))
                local basePacket = {}
                basePacket['me'] = windower.ffxi.get_player().index
                basePacket['Target'] = v['id']
                basePacket['Target Index'] = i
                basePacket['Zone'] = zoneId
                return basePacket
            end
        end
    end
    return nil
end

function VerifyWarp(zoneId)
    local portalName = 'Eschan Portal'
    if zoneId == 291 then
        portalName = 'Ethereal Ingress'
    end

    local basePacket = GetBasePortalPacket(zoneId, portalName)
    if basePacket then
        basePacket['Menu ID'] = 9100
        return basePacket
    else
        windower.add_to_chat(10, "Not near a portal to warp!")
        return nil
    end
end

function VerifyZone(zoneId)
    local portalName = 'Undulating Confluence'
    if zoneId == 102 or zoneId == 108 or zoneId == 117 then
        portalName = 'Dimensional Portal'
    end

    local basePacket = GetBasePortalPacket(zoneId, portalName)
    if basePacket then
        basePacket['Menu ID'] = _entryPortal.menuId
        basePacket['_unknown1'] = 8
        return basePacket
    else
        windower.add_to_chat(10, "Not near an Escha entry to warp!")
        return nil
    end
end

function GetDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt(sq(x2-x1) + sq(y2-y1) + sq(z2-z1))
end

function sq(num)
    return num * num
end

function ResetDialogue()
	if _warping and _packet then
		local resetPacket = packets.new('outgoing', 0x05B)
		resetPacket["Target"]=_lastPacket['Target']
		resetPacket["Option Index"]="0"
		resetPacket["_unknown1"]="16384"
		resetPacket["Target Index"]=_lastPacket['Target Index']
		resetPacket["Automated Message"]=false
		resetPacket["_unknown2"]=0
		resetPacket["Zone"]=_lastPacket['Zone']
		resetPacket["Menu ID"]=_lastPacket['Menu ID']
		packets.inject(resetPacket)

		_warping = false
		windower.add_to_chat(10, 'Reset sent.')
	else
		windower.add_to_chat(10, 'Not in middle of warp.')
	end
end
