_addon.name = 'CRB_addon'
_addon.author = 'Daniel_H'
_addon.version = '1.2'
_addon_description = ''
_addon.commands = {'CorsairRollBot'}


local socket = require("socket")

local port = 19701
local ip = "127.0.0.1"

function send_required_string(data_string)

  local CRB_connect = assert(socket.udp())
  CRB_connect:settimeout(1)

  assert(CRB_connect:sendto(data_string, ip, port))

  CRB_connect:close()
end

-- ONCE LOADED SEND A COMMAND TO AUTHENTICATE CONNECTION
validated = false

if validated == false then
  validated = true
  send_required_string('crb validated')
end

if windower then

  -- BEGIN WINDOWER CODE ---------------------------------------------------------------------------------

  windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
    local args = {...}
    if cmd == "verify" then
      send_required_string('crb validated')
    end
  end)

  local player = windower.ffxi.get_player()

  windower.register_event('action', function (data)
    if data.target_count > 0 and data.category == 6 then
    if data.actor_id == player.id then
      current_roll = data.targets[1].actions[1].param;
      send_required_string('crollbot_addon ' .. current_roll)
    end
  end
end)

-- END WINDOWER CODE -----------------------------------------------------------------------------------

elseif ashita then

-- BEGIN ASHITA CODE -----------------------------------------------------------------------------------

require 'common'

ashita.register_event('command', function(command, ntype)
  -- Get the arguments of the command..
  local args = command:args();
  if (args[1]:lower() ~= '/CorsairRollBot') then
    return false;
  end
  if (#args >= 4 and args[2] == 'verify') then
    send_required_string('crb validated')
  end
  return true;
end);

ashita.register_event('incoming_packet', function(id, size, data)
  if id == 0xB then
  zoning_bool = true
elseif id == 0xA and zoning_bool then
  zoning_bool = false
end

if not zoning_bool then
  if id == 0x28 then
    local party = AshitaCore:GetDataManager():GetParty();
    local actor = struct.unpack('I', data, 6);
    local category = ashita.bits.unpack_be(data, 82, 4);
    local effect = ashita.bits.unpack_be(data, 213, 17);

    if category == 6 and effect then
      if (actor == party:GetMemberServerId(0)) then
        send_required_string('crollbot_addon ' .. effect);
      end
    end
  end
end
return false;
end);

-- END ASHITA CODE -------------------------------------------------------------------------------------

end
