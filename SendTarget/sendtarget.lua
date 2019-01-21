_addon.name = 'SendTarget'
_addon.author = 'DiscipleOfEris'
_addon.version = '1.0.1'
_addon.commands = {'sendtarget', 'sta'}

require('tables')
require('strings')
require('logger')
packets = require('packets')
res = require('resources')
require('statics')

local spells = res.spells
local job_abilities = res.job_abilities
local weapon_skills = res.weapon_skills

local PACKET_TYPE = { ACTION = 0x01A }
local ACTION_CATEGORY = { MAGIC_CAST = 0x03, WEAPON_SKILL_USE = 0x07, JOB_ABILITY_USE = 0x09 }
local ACTION_PARAM = { MAGIC_INITIATION = 24931, MAGIC_FAILURE = 28787 }

local mirroring = false
local send_packets = true

local command_queue = T{}

windower.register_event('addon command', function(command, ...)
  command = command and command:lower()
  local args = T{...}
  
  if not command then
    -- display help
    log('Commands should look like: //sta <char_name|@others|@all> input')
    log('Can also use the !mirror, !packets, !capture <char_name|@others|@all> commands.')
    log('In a macro, you should use "/con sta" rather than "//sta".')
  elseif command == '!mirror' then
    mirroring = not mirroring
    if mirroring then log('Mirroring enabled. Will have all alts mimic this character.')
    else log('Mirroring disabled.') end
  elseif command == '!packets' then
    send_packets = not send_packets
    if send_packets then log('Packet injection enabled. This is necessary unless GearSwap is active with a profile loaded.')
    else log('Packet injection disabled. Do this for compatibility with GearSwap when you have an active profile.') end
  elseif command == '!capture' then
    if #args == 0 then
      log('!capture requires a character name to send to. Usage: //sta !capture <char_name|@others|@all>.')
      log('This will capture the next input and send it to char_name.')
      return
    end
    
    command_queue:insert({char=args[1]:lower(), ts=os.time(), handled=false})
  else
    if #args == 0 then
      log('You must provide some input to send. For example, //sta @others /ma "Cure III" <stpc>')
      return
    end
    
    local char = command
    local input = args:concat(' ')
    
    command_queue:insert({char=char, ts=os.time(), handled=false, input=input})
    
    if input:sub(1,1) == '/' then input = 'input '..input end
    windower.send_command(input)
  end
end)

windower.register_event('ipc message', function(msg)
  local args = T(msg:split(' '))
  local character = args:remove(1)
  local input = args:concat(' ')
  local player = windower.ffxi.get_player()
  
  if (player and character == player.name:lower()) or character == '@others' or character == '@all' or character == '@everyone' then
    
    if send_packets and should_inject(input) then
      handle_command(input)
    else
      if input:sub(1,1) == '/' then input = 'input '..input end
      windower.send_command(input)
    end
  end
end)

-- State machine for subtarget capturing, involves 'outgoing text' and 'prerender' events.
-- This state machine is rather convoluted, but has been reliable so far in testing.
local selecting = false
local st_target = nil
local last_st_target = nil
local last_st_command = false
local st_capture = false
local unblocking = false

windower.register_event('outgoing text', function(_, modified, blocked, typed, a, b)
  if #command_queue == 0 or not typed or modified:sub(1,1) ~= '/' or (command_queue[#command_queue].handled and not command_queue[#command_queue].st) then return end
  if modified == unblocking then return end
  
  local args = T(modified:split(' '))
  if #args == 1 then return end
  local t_arg = args:remove(#args)
  local command = args:concat(' ')
  
  if not st_actions:contains(args[1]) then return end
  
  if st_targs:contains(t_arg) then
    if selecting or st_target then
      -- already selecting.
      command_queue:remove(#command_queue)
      return
    end
    selecting = 1
    last_st_command = command
    command_queue[#command_queue].handled = true
    command_queue[#command_queue].st = true
    return
  elseif t_arg:sub(1,1) == '<' then
    local target = windower.ffxi.get_mob_by_target(t_arg)
    if not target then return end
    local cmd = command_queue:remove(#command_queue)
    
    return send_message(cmd.char, command..' '..target.id) and '' or false
  end
  
  if selecting and command == last_st_command and tonumber(t_arg) then
    if not st_target then
      -- begin
      selecting = 2
    elseif selecting == 2 then
      -- end
      selecting = 3
      st_capture = modified
      if not should_send_self(command_queue[1].char) then
        if blocked then 
          windower.add_to_chat(0, 'SendTarget: Another addon is blocking commands; SendTarget must be loaded first. If you have GearSwap, put "lua reload GearSwap" after "lua load SendTarget" in your init.txt script.')
        end
        
        return true
      end
    end
  end
end)

windower.register_event('prerender', function()
  st_target = windower.ffxi.get_mob_by_target('st')
  
  if #command_queue and last_st_target and not st_target then
    if selecting and selecting == 3 then
      -- chosen
      send_message(command_queue[1].char, st_capture)
    else
      -- cancelled
    end
    selecting = false
    last_st_command = false
    command_queue:remove(1)
  elseif last_st_target and st_target and st_capture and #command_queue and command_queue[1].st then
    -- unblocking
    selecting = 2
    windower.send_command('@input '..st_capture)
    unblocking = st_capture
  end
  
  st_capture = false
  
  if not last_st_target and st_target then
    if selecting == 2 then
      -- capturing
    end
  end
  
  last_st_target = st_target
end)

-- Mirror spells and abilities to other alts.
windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
  if not mirroring or id ~= PACKET_TYPE.ACTION then return end

  local packet = packets.parse('outgoing', modified)
  
  if packet.Category == ACTION_CATEGORY.MAGIC_CAST then
    local spell = spells[packet.Param]
    windower.send_ipc_message('@others /ma "'..spell.en..'" '..packet.Target)
  elseif packet.Category == ACTION_CATEGORY.WEAPON_SKILL_USE then
    local ws = spells[packet.Param]
    windower.send_ipc_message('@others /ws "'..spell.en..'" '..packet.Target)
  elseif packet.Category == ACTION_CATEGORY.JOB_ABILITY_USE then
    local ja = job_abilities[packet.Param]
    windower.send_ipc_message('@others /ja "'..ja.en..'" '..packet.Target)
  end
end)

-- returns true if this should NOT be sent to self as well (i.e. block it)
function send_message(character, msg)
  local player = windower.ffxi.get_player()
  if not player or character ~= player.name:lower() then
    windower.send_ipc_message(character..' '..msg)
    
    return character ~= '@all' and character ~= '@everyone'
  end
end

function should_send_self(character)
  local player = windower.ffxi.get_player()
  
  if not player then return false end
  
  if character == player.name:lower() or character == '@all' or character == '@everyone' then return true end
  
  return false
end

function should_inject(input)
  if not send_packets then return false end
  local args = T(input:split(' '))
  
  local prefix = args[1]
  -- /bstpet has arguments that would be too complicated to inject, and only allows <me> as target anyway.
  if prefix == '/bstpet' or not st_actions:contains(prefix) then return false end
  
  local target = args[#args]
  if tonumber(target) then return true end
  
  return false
end

-- Assumes should_inject() was already true.
function handle_command(input)
  local args = T(input:split(' '))
  local prefix = args:remove(1)
  
  local t_arg = tonumber(args:remove(#args))
  
  local name = args:concat(' '):gsub('"', '')
  if name:sub(1,1) == "'" then name = name:sub(2) end
  if name:sub(#name) == "'" then name = name:sub(1,-1) end
  
  local target = t_arg
  local self = windower.ffxi.get_player()
  
  if not self then return end
  
  self = self.id
  local self_only = S{'Self'}
  
  if spell_prefixes:contains(prefix) then
    local spell = spells:with('en', name)
    if spell.targets:equals(self_only) then target = self end
    
    inject_action_packet(ACTION_CATEGORY.MAGIC_CAST, spell, target)
  elseif job_ability_prefixes:contains(prefix) then
    local ja = job_abilities:with('en', name)
    if ja.targets:equals(self_only) then target = self end
    
    inject_action_packet(ACTION_CATEGORY.WEAPON_SKILL_USE, ws, target)
  elseif weapon_skill_prefixes:contains(prefix) then
    local ws = weapon_skills:with('en', name)
    if ws.targets:equals(self_only) then target = self end
    
    inject_action_packet(ACTION_CATEGORY.JOB_ABILITY_USE, ja, target)
  end
  -- TODO: /attack, /range, /check, /assist, /follow, emotes
end

function inject_action_packet(category, ability, target_id)
  local target = windower.ffxi.get_mob_by_id(target_id)
  local packet = packets.new('outgoing', PACKET_TYPE.ACTION, {
    ['Target']=target.id,
    ['Target Index']=target.index,
    ['Category']=category,
    ['Param']=ability.id
  })
  
  packets.inject(packet)
end
