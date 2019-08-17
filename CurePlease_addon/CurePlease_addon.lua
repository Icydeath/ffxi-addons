_addon.name = 'CurePlease_addon'
_addon.author = 'Daniel_H'
_addon.version = '1.2 Windower'
_addon_description = 'Allows for PARTY DEBUFF Checking and Casting Data'
_addon.commands = {'cpaddon'}

local port = 19769
local ip = "127.0.0.1"

local socket = require("socket")
require ('packets')

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function Run_Buff_Function(id, data)
  for k = 0, 4 do
    local Uid = data:unpack('I', k * 48 + 5)
    if Uid ~= 0 and Uid ~= nil then
      userIndex = Uid
    else
      userIndex = nil
    end
    -- FOR EACH MEMBER REMOVE PREVIOUS CHARACTERS DATA
    Buffs = {}
    CharacterName = nil
    formattedString = nil
    intIndex = 1
    -- GRAB THE MEMBERS NAME
    if userIndex ~= nil then
      if windower.ffxi.get_mob_by_id(userIndex) ~= nil then
        CharacterName = windower.ffxi.get_mob_by_id(userIndex).name;
      end
    end
    if CharacterName ~= nil then
      for i = 1, 32 do
        current_buff = data:byte(k * 48 + 5 + 16 + i - 1) + 256 * (math.floor(data:byte(k * 48 + 5 + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4)
        if current_buff ~= 255 and current_buff ~= 0 then
          table.insert(Buffs, current_buff)
        end
      end
      -- COUNT TOTAL NUMBER OFF BUFFS LOCATED AND BUILD THE BUFF STRING
      formattedString = "CUREPLEASE_buffs_"..CharacterName.."_"
      for index, value in pairs(Buffs) do
        formattedString = formattedString .. value
        if intIndex ~= tablelength(Buffs) then
          formattedString = formattedString ..","
        end
        intIndex = intIndex + 1
      end
      -- COMPLETED BUILDING THE BUFFS TABLE AND GRABBING THE CHARACTER NAME, SEND THE DATA VIA THE LOCAL NETWORK USING SOCKETS
      local CP_connect = assert(socket.udp())
      CP_connect:settimeout(1)
      assert(CP_connect:sendto(formattedString, ip, port))
      CP_connect:close()
    else
      return
    end
  end
end

windower.register_event('incoming chunk', function (id, data)
  if id == 0x076 then
  Run_Buff_Function(id, data)
end
end)

windower.register_event('addon command', function(input, ...)
local args = {...}
if args ~= nil then
  local cmd = string.lower(input)
  if cmd == "settings" then
    if args[1] and args[2] then
      ip = args[1]
      port = args[2]
      windower.add_to_chat(1, ('\31\200[\31\05Cure Please Addon\31\200]\31\207 '.. "NETWORK UPDATE:  IP address: " .. ip .. " / Port number: " .. port))
    end
  elseif cmd == "check" then
    windower.add_to_chat(1, ('\31\200[\31\05Cure Please Addon\31\200]\31\207 '.. " IP address: " .. ip .. " / Port number: " .. port))
  elseif cmd == "verify" then
    local CP_connect = assert(socket.udp())
    CP_connect:settimeout(1)
    assert(CP_connect:sendto("CUREPLEASE_confirmed", ip, port))
    CP_connect:close()
  elseif cmd == "cmd" then
    local CP_connect = assert(socket.udp())
    CP_connect:settimeout(1)
    assert(CP_connect:sendto("CUREPLEASE_command_"..args[1]:lower(), ip, port))
    CP_connect:close()
  end

end
end)

windower.register_event('action', function (data)
casting = nil
if data.actor_id == windower.ffxi.get_player().id then
  if data.category == 4 then
    casting = 'CUREPLEASE_casting_finished'
  elseif data.category == 8 then
    if data.param == 28787 then
      casting = 'CUREPLEASE_casting_interrupted'
    elseif data.param == 24931 then
      casting = 'CUREPLEASE_casting_blocked'
    end
  end
  if casting ~= nil then
    local CP_connect = assert(socket.udp())
    CP_connect:settimeout(1)
    assert(CP_connect:sendto(casting, ip, port))
    CP_connect:close()
  end
end
end)
