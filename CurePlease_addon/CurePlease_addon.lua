_addon.name = 'CurePlease_addon'
_addon.author = 'Daniel_H'
_addon.version = '1.0'
_addon_description = ''
_addon.commands = {'cpaddon'}

-- Some of this information was borrowed from code from: Kenshi, Copyright © 2016
-- UDP connection thanks to several online tutorials

local socket = require("socket")
require('strings')

local port = 19769
local ip = "127.0.0.1"

if windower then
  packets = require("packets")

  windower.register_event('addon command', function(input, ...)
    local args = T{...}
    if args ~= nil then
      local cmd = string.lower(input)
      if cmd == "settings" then
        if args[1] and args[2] then
          ip = args[1]
          port = args[2]
        end
      end
      if cmd == "check" then
        windower.add_to_chat(207, "Current CurePlease info: " .. "IP address: " .. ip .. " / Port number: " .. port)
      end
    end
  end)
end

if ashita then

  require 'common'

  ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args();
    if (args[1]:lower() ~= '/cpaddon') then
      return false;
    end

    if (#args >= 4 and args[2] == 'settings') then
      ip = args[3]
      port = args[4]
    end

    if (#args == 2 and args[2] == 'check') then
      print("Current CurePlease info: " .. "IP address: " .. ip .. " / Port number: " .. port)
    end
    return true;
  end);

end

local CharacterBuffData = {}

function grabName(userIndex)
  if windower then
    if userIndex ~= 9 then
      if windower.ffxi.get_mob_by_id(userIndex) == nil then
        return "NONE"
      else
        found_character = windower.ffxi.get_mob_by_id(userIndex).name
        return found_character
      end
    else
      return "NONE"
    end
  end
  if ashita then
    if userIndex ~= 9 then
      return AshitaCore:GetDataManager():GetEntity():GetName(userIndex)
    else
      return "NONE"
    end
  end
end

function send_required_string(DaTa)

  local CP_connect = assert(socket.udp())
  CP_connect:settimeout(1)

  assert(CP_connect:sendto(DaTa, ip, port))

  CP_connect:close()
end

function send_casting(state, Spellid)
  if state == 'finished' then
    send_required_string('casting-finished')
  elseif state == 'blocked' then
    send_required_string('casting-blocked')
  elseif state == 'interrupted' then
    send_required_string('casting-interrupted')
  end
end

function convert_to_data(id, data)
  if id == 0x076 then
    for k = 0, 4 do
      if ashita then
        local Uid = struct.unpack('H', data, 8 + 1 + (k * 0x30))
        if Uid ~= 0 and Uid ~= nil then
          userIndex = Uid
        else
          userIndex = 9
        end
      end
      if windower then
        local Uid = data:unpack('I', k * 48 + 5)
        if Uid ~= 0 and Uid ~= nil then
          userIndex = Uid
        else
          userIndex = 9
        end
      end

      -- FOR EACH MEMBER REMOVE PREVIOUS CHARACTERS DATA
      Buffs = ""
      member_Name = ""

      -- GRAB THE MEMBERS NAME
      member_Name = grabName(userIndex)

      -- RUN THROUGH A LOOP TO GET MEMBER BUFFS
      for i = 1, 32 do
        current_buff = data:byte(k * 48 + 5 + 16 + i - 1) + 256 * (math.floor(data:byte(k * 48 + 5 + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) % 4)
        if current_buff ~= 255 and current_buff ~= 0 then
          Buffs = Buffs..current_buff..","
        end
      end

      if member_Name ~= nil then
        processed_data = member_Name.."-"..Buffs

        if (member_Name ~= "NONE") then
          send_required_string("buffs-"..member_Name.."-"..Buffs)
        end
      end
    end
  end
end

if windower then
  -- BEGIN WINDOWER CODE ---------------------------------------------------------------------------------

  require 'tables'
  require 'sets'
  file = require 'files'
  res = require 'resources'

  local player = windower.ffxi.get_player()

  windower.register_event('action', function (data)
    if data.actor_id == windower.ffxi.get_player().id then
    if data.category == 4 then
      send_casting('finished', data.param)
    elseif data.category == 8 then
      if data.param == 28787 then
        send_casting('interrupted', data.targets[1].actions[1].param)
      elseif data.param == 24931 then
        send_casting('blocked', data.targets[1].actions[1].param)
      end
    end
  end
end)

windower.register_event('incoming chunk', function (id, data)
  if id == 0x076 then
  convert_to_data(id, data)
end
end)

-- END WINDOWER CODE -----------------------------------------------------------------------------------
end

if ashita then
-- BEGIN ASHITA CODE -----------------------------------------------------------------------------------

ashita.register_event('incoming_packet', function(id, size, data)
if id == 0xB then
zoning_bool = true
elseif id == 0xA and zoning_bool then
zoning_bool = false
end
if not zoning_bool then

if id == 0x28 then
  local actor = struct.unpack('I', data, 6);
  local category = ashita.bits.unpack_be(data, 82, 4);

  if actor == AshitaCore:GetDataManager():GetParty():GetMemberServerId(0) then
    if category == 4 then
      send_casting('finished', ashita.bits.unpack_be(data, 86, 10))
    elseif category == 8 then
      if ashita.bits.unpack_be(data, 86, 16) == 28787 then
        send_casting('interrupted', ashita.bits.unpack_be(data, 213, 10))
      elseif ashita.bits.unpack_be(data, 86, 16) == 24931 then
        send_casting('blocked', ashita.bits.unpack_be(data, 213, 10))
      end

      print ();

    end
  end
elseif id == 0x076 then
  convert_to_data(id, data)
end
end
return false;
end);

-- END ASHITA CODE -------------------------------------------------------------------------------------
end
