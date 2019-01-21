_addon.author = 'Icy'
_addon.command = 'vwbh'
_addon.name = 'VWBH'
_addon.version = '1.0'

-- Some of the information (UDP) was taken from the 'CurePlease_addon' created by Daniel_H

require('luau')
local socket = require("socket")
texts = require('texts')
files = require('files')
packets = require('packets')

local port = 19751
local ip = "127.0.0.1"

windower.register_event('incoming chunk', function(id, data)
	if id == 0x113 then -- 275 Currency Info
		local packet = packets.parse("incoming", data)
		local voidstones = packet['Voidstones']
		windower.add_to_chat(207, 'Voidstones Remaining: '..voidstones)
		send_required_string(voidstones)
	end
end)

windower.register_event('addon command', function(input, ...)
    local args = T{...}
    if args ~= nil then
      local cmd = string.lower(input)
	  if cmd == "settings" then
        if args[1] and args[2] then
          ip = args[1]
          port = args[2]
		  --windower.add_to_chat(207, "Connection: " .. ip .. ":" .. port)
        end
      end
      if cmd == "stones" then
        windower.add_to_chat(207, "Checking Voidstones...")
		local packet = packets.new('outgoing', 0x10F)
		packets.inject(packet)
      end
    end
end)
  
function send_required_string(DaTa)
  local CP_connect = assert(socket.udp())
  CP_connect:settimeout(1)
  assert(CP_connect:sendto(DaTa, ip, port))
  CP_connect:close()
end