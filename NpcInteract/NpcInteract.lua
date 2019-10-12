_addon.name = 'NpcInteract'
_addon.author = 'DiscipleOfEris'
_addon.version = '1.2.0'
_addon.command = 'npc'

require('logger')
require('tables')
require('strings')
local packets = require('packets')
require('coroutine')
local res = require('resources')
res.chat[6] = {id=6,en='system'}

config = require('config')
texts = require('texts')

defaults = {}
defaults.show = true
defaults.mirror = false
defaults.fade = 10
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 127
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 10

settings = config.load(defaults)
box = texts.new("", settings.display, settings)

local report_info = T{}

local PACKET_INC = { ZONE_OUT = 0x00B, INCOMING_CHAT = 0x017, NPC_INTERACT_1 = 0x032, NPC_INTERACT_2 = 0x034, NPC_RELEASE = 0x052, DIALOG_INFORMATION = 0x05C, KEY_ITEM = 0x02A, UPDATE_CHAR = 0x037, }
local PACKET_OUT = { ACTION = 0x01A, DIALOG_CHOICE = 0x05B, WARP_REQUEST = 0x05C, }
local ACTION_CATEGORY = { NPC_INTERACTION = 0 }
local CHAT_MODE = { SYSTEM = 6 }

-- NPC interactions sometimes fail. Only clone interactions with NPC_INTERACT_1, NPC_INTERACT_2, or ZONE_OUT response.
-- For NPC_INTERACT_1 and NPC_INTERACT_2, we must track UPDATE_CHAR's Status == 4 (Event). Interaction ends with Status = 0 (Idle).
-- For ZONE_OUT, we just need to catch it within a few seconds of NPC_RELEASE.

-- Sometimes receive packet 0x02A for KIs.

local injecting = false
local attempts = 0
local npc
local npc_id = 0
local last_packet = nil
local last_idle_packet = nil
local last_broadcast = nil
local status = 0
local prev_status = 0
local busy = false
local success = false
local response_id
local out = T{}
local inc = 0
local menu_id = 0

local last_update_time = os.clock()
local fade_duration = 2

local MAX_ATTEMPTS = 20

local menus = T{}
local resetting = false

packets.raw_fields.incoming[PACKET_INC.NPC_RELEASE] = L{
  {ctype='int',      label='_unknown1'},
}

windower.register_event('login', function()
  last_update_time = os.clock()
  coroutine.sleep(5)
  if settings.mirror then log('Mirroring enabled. Other chars will attempt to clone interactions.') end
end)

windower.register_event('addon command', function(command, ...)
  args = T{...}
  command = command:lower()
  
  if not command or command == 'help'  then
    log('npc mirror [on/off] -- Toggle/enable/disable mirroring, causing all other alts to mirror this one.')
    log('npc report [on/off] -- Toggle/enable/disable reporting, showing when alts successfully mirror the main.')
    log('npc fade <duration> -- Set how long it takes the report box to fade.')
    log('npc retry -- Retry the last NPC interaction.')
    log('npc reset -- Try this if alts get frozen when attempting to interact with an NPC.')
  elseif command == 'mirror' then
    if not args[1] then
      settings.mirror = not settings.mirror
    elseif args[1] == 'on' then
      settings.mirror = true
    elseif args[1] == 'off' then
      settings.mirror = false
    end
    
    if settings.mirror then log('Mirroring enabled. Other chars will attempt to clone interactions.')
    else log('Mirroring disabled.') end
    config.save(settings)
  elseif command == 'reset' then
    reset()
  elseif command == 'retry' then
    log('retry', last_broadcast)
    if settings.mirror and last_broadcast then
      windower.send_ipc_message(last_broadcast)
    elseif last_broadcast then
      local outs = last_broadcast:split(' out ')
      local pre = outs:remove(1):split(' ')
      npc_id = tonumber(pre[2])
      inc = tonumber(pre[3])
      menu_id = tonumber(pre[4])
      out = outs
      inject()
    end
  elseif command == 'report' then
    if not args[1] then
      settings.show = not settings.show
    elseif args[1] == 'on' then
      settings.show = true
    elseif args[2] == 'off' then
      settings.show = false
    end
    
    config.save(settings)
  elseif command == 'fade' then
    local fade_time = tonumber(args[1])
    if fade_time and fade_time > 0 then
      settings.fade = fade_time
    else
      settings.fade = 0
    end
    
    config.save(settings)
  end
end)

windower.register_event('ipc message', function(msgStr)
  --log('start', msgStr)
  
  local args = T(msgStr:split(' '))
  local command = args:remove(1)
  
  if command == 'action' then
    --log('action')
  elseif command == 'dialog' then
    --log('dialog')
  elseif command == 'broadcast' then
    last_broadcast = msgStr
    local outs = msgStr:split(' out ')
    local pre = outs:remove(1):split(' ')
    npc_id = tonumber(pre[2])
    inc = tonumber(pre[3])
    menu_id = tonumber(pre[4])
    out = outs
    coroutine.sleep(math.random()*2.5)
    inject()
  elseif command == 'success' then
    local name = args[1]
    local id = args[2]
    
    report_info[name] = true
    if settings.mirror then last_update_time = os.clock() end
  elseif command == 'failure' then
    local name = args[1]
    local id = args[2]
    
    report_info[name] = false
    if settings.mirror then last_update_time = os.clock() end
  end
end)

windower.register_event('prerender', function()
  updateInfo()
  doFade()
end)

windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
  --[[if     id == PACKET_OUT.ACTION then log('action')
  elseif id == PACKET_OUT.DIALOG_CHOICE then log('dialog choice', packets.parse('outgoing', modified))
  elseif id == PACKET_OUT.WARP_REQUEST then log('warp request')
  end--]]
  
  if id == PACKET_OUT.ACTION then
    packet = packets.parse('outgoing', modified)
    npc = windower.ffxi.get_mob_by_id(packet.Target)
    --log('action', success, busy)
    
    if packet.Category == ACTION_CATEGORY.NPC_INTERACTION and settings.mirror and not (injecting and injected) then
      busy = true
      success = false
      out = T{}
      inc = false
      npc_id = packet.Target
      npc = windower.ffxi.get_mob_by_id(packet.Target)
      if settings.mirror then last_update_time = os.clock() end
    end
  elseif id == PACKET_OUT.DIALOG_CHOICE then
    packet = packets.parse('outgoing', modified)
    last_packet = packet
    --log('dialog', success, busy)
    
    if settings.mirror and not (injecting and injected) then
      local self = windower.ffxi.get_player()
      local target_id = packet['Target']
      local target_idx = packet['Target Index']
      if self and target_id == self.id then target_id = 'me' end
      if self and target_idx == self.index then target_idx = 'me' end
      
      out:insert(T{id, target_id, packet['Option Index'], packet['_unknown1'], packet['Target Index'], tostring(packet['Automated Message']), packet['_unknown2'], packet['Zone'], packet['Menu ID']})
      last_update_time = os.clock()
    end
  elseif id == PACKET_OUT.WARP_REQUEST then
    packet = packets.parse('outgoing', modified)
    last_packet = packet
    --log('warp request', success, busy)
    
    if settings.mirror and not (injecting and injected) then
      success = 2
      local self = windower.ffxi.get_player()
      local target_id = packet['Target ID']
      local target_idx = packet['Target Index']
      if self and target_id == self.id then target_id = 'me' end
      if self and target_idx == self.index then target_idx = 'me' end
      
      out:insert(T{id, packet.X, packet.Z, packet.Y, target_id, packet._unknown1, packet.Zone, packet['Menu ID'], target_idx, packet._unknown3})
    end
  end
end)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  local packet = nil
  
  --[[if     id == PACKET_INC.NPC_RELEASE then log('release')
  elseif id == PACKET_INC.DIALOG_INFORMATION then log('dialog information')
  elseif id == PACKET_INC.NPC_INTERACT_1 then log('npc interact 1')
  elseif id == PACKET_INC.NPC_INTERACT_2 then log('npc interact 2')
  end--]]
  
  if id == PACKET_INC.NPC_RELEASE and resetting then
    print('reset success')
    resetting = false
    return
  end
  
  if id == PACKET_INC.UPDATE_CHAR then
    packet = packets.parse('incoming', modified)
    status = packet.Status
    --log('status', status)
  end
  
  if id == PACKET_INC.NPC_INTERACT_1 or id == PACKET_INC.NPC_INTERACT_2 then
    packet = packets.parse('incoming', modified)
    
    menus:insert({packet_id=id, npc=packet['NPC'], npc_index=packet['NPC Index'], zone=packet['Zone'], menu_id=packet['Menu ID']})
    --print('0x%03x menu:':format(id), packet['Menu ID'], packet['Zone'])
  end
  
  if id == 0x00A then
    packet = packets.parse('incoming', modified)
    if packet['Menu ID'] and packet['Menu ID'] > 0 then
      --print('0x00A menu: ', packet['Menu ID'], packet['Menu Zone'])
    end
  end
  
  if not busy and not injecting and not success then return end
  
  if id == PACKET_INC.NPC_INTERACT_1 or id == PACKET_INC.NPC_INTERACT_2 then
    --local packet = packets.parse('incoming', modified)
    --log('npc interact', (id == PACKET_INC.NPC_INTERACT_1 and 1 or 2), success, busy)
    if not injecting and settings.mirror then
      success = 1
      inc = id
      menu_id = packet['Menu ID']
    elseif packet['Menu ID'] == menu_id and injecting and injecting ~= 1 then
      success = 1
      busy = false
      for _, o in ipairs(out) do
        o = o:split(' ')
        local out_id = tonumber(o:remove(1))
        
        --log(out_id, PACKET_OUT.DIALOG_CHOICE, out_id == PACKET_OUT.DIALOG_CHOICE)
        
        if out_id == PACKET_OUT.DIALOG_CHOICE then
          local target_id = o[1]
          local target_idx = o[4]
          local zone = tonumber(o[7])
          local automated = false
          if o[5] == 'true' then automated = true end
          
          local self = windower.ffxi.get_mob_by_target('me')
          
          if target_id == 'me' then target_id = self.id
          else target_id = tonumber(target_id) end
          if target_idx == 'me' then target_idx = self.index
          else target_idx = tonumber(target_idx) end
          
          local packet = packets.new('outgoing', PACKET_OUT.DIALOG_CHOICE, {
            ['Target'] = target_id,
            ['Option Index'] = tonumber(o[2]),
            ['_unknown1'] = o[3],
            ['Target Index'] = target_idx,
            ['Automated Message'] = automated,
            ['_unknown2'] = tonumber(o[6]),
            ['Zone'] = zone,
            ['Menu ID'] = tonumber(o[8]),
          })
          
          --log('dialog', packet)
          last_packet = packet
          packets.inject(packet)
        elseif out_id == PACKET_OUT.WARP_REQUEST then
          local target_id = o[4]
          local target_idx = o[8]
          local zone = tonumber(o[6])
          
          local self = windower.ffxi.get_mob_by_target('me')
          
          if target_id == 'me' then target_id = self.id
          else target_id = tonumber(target_id) end
          if target_idx == 'me' then target_idx = self.index
          else target_idx = tonumber(target_idx) end
          
          local packet = packets.new('outgoing', PACKET_OUT.WARP_REQUEST, {
            ['X'] = tonumber(o[1]),
            ['Z'] = tonumber(o[2]),
            ['Y'] = tonumber(o[3]),
            ['Target'] = target_id,
            ['_unknown1'] = o[5],
            ['Zone'] = zone,
            ['Menu ID'] = tonumber(o[7]),
            ['Target Index'] = target_idx,
            ['_unknown3'] = tonumber(o[9]),
          })
          
          --log('warp request', packet)
          last_packet = packet
          packets.inject(packet)
        end
        --log('inject 0x%0.3x':format(out_id))
      end
      injecting = 1
      return true
    elseif packet['Menu ID'] == menu_id and injecting then
      return true
    elseif injecting then
      local self = windower.ffxi.get_player()
      if self then windower.send_ipc_message('failure '..self.name) end
    end
  elseif id == PACKET_INC.DIALOG_INFORMATION then
    if injecting then return true end
    --log('dialog information', success, busy)
    success = 2
  elseif id == PACKET_INC.INCOMING_CHAT then
    --log('chat', success, busy)
    if npc and (npc.name == 'Goblin Footprint' or npc.name == 'Ramblix') then
      local packet = packets.parse('incoming', modified)
      if packet.Mode == CHAT_MODE.SYSTEM then
        busy = false
        success = true
        inc = id
      end
    end
  elseif id == PACKET_INC.ZONE_OUT then
    busy = false
    success = true
    inc = id
  elseif id == PACKET_INC.KEY_ITEM then
    busy = false
    success = true
    inc = id
  elseif id == PACKET_INC.UPDATE_CHAR then
    local packet = packets.parse('incoming', modified)
    status = packet.Status
    
    --log('status', status)
    
    if (status == 0 or status == 5) and prev_status == 4 then
      if success and settings.mirror and not busy then
        broadcast()
        success = false
      end
      
      busy = false
      injecting = false
    end
    prev_status = status
  elseif id == PACKET_INC.NPC_RELEASE then
    released = os.time()
    --log('release', success, busy, status)
    if success == 2 and settings.mirror then
      success = true
      return
    end
    coroutine.sleep(1)
    --log('sleep', success, busy, status)
    if success and injecting then
      injecting = false
      success = false
      local self = windower.ffxi.get_player()
      if self then windower.send_ipc_message('success '..self.name) end
    elseif not success and injecting and attempts < MAX_ATTEMPTS then
      attempts = attempts + 1
      retry()
    elseif not success and injecting then
      local self = windower.ffxi.get_player()
      if self then windower.send_ipc_message('failure '..self.name) end
    elseif success == 1 and settings.mirror then
      success = true
      if status == 0 or status == 5 then busy = false end
    elseif success and settings.mirror and (status == 0 or status == 5) and not busy then
      broadcast()
      success = false
      busy = false
    end
  end
end)

function broadcast()
  if not npc_id then return end
  
  local outs = T{}
  for _, v in ipairs(out) do
    outs:insert(type(v) == 'string' and v or v:concat(' '))
  end
  
  local msg = 'broadcast '..npc_id..' '..inc..' '..menu_id..' out '..outs:concat(' out ')
  
  --print(msg)
  --log(msg)
  report_info = T{}
  windower.send_ipc_message(msg)
  last_broadcast = msg
  last_npc = npc
  last_update_time = os.clock()
  menu_id = 0
end

function inject()
  local npc = windower.ffxi.get_mob_by_id(npc_id)
  local self = windower.ffxi.get_mob_by_target('me')
  
  success = false
  busy = false
  attempts = 0
  
  if not self or not npc or distance(self, npc) > 6.0 then
    coroutine.sleep(1)
    npc = windower.ffxi.get_mob_by_id(npc_id)
    self = windower.ffxi.get_mob_by_target('me')
    if not self or not npc or distance(self, npc) > 6.0 then
      if self then windower.send_ipc_message('failure '..self.name) end
      return
    end
  end
  
  injecting = true
  
  local packet = packets.new('outgoing', PACKET_OUT.ACTION, {
    ['Target'] = npc_id,
    ['Target Index'] = npc.index,
    ['Category'] = ACTION_CATEGORY.NPC_INTERACTION,
    ['Param'] = 0
  })
  
  --log('action')
  packets.inject(packet)
end

function retry()
  local npc = windower.ffxi.get_mob_by_id(npc_id)
  local self = windower.ffxi.get_mob_by_target('me')
  
  if not self or not npc or distance(self, npc) > 6.0 then return end
  
  injecting = true
  
  local packet = packets.new('outgoing', PACKET_OUT.ACTION, {
    ['Target'] = npc_id,
    ['Target Index'] = npc.index,
    ['Category'] = ACTION_CATEGORY.NPC_INTERACTION,
    ['Param'] = 0
  })
  
  --log('retry', attempts)
  packets.inject(packet)
end

function reset()
  -- Resetting against last poked npc.
  local self = windower.ffxi.get_mob_by_target('me')
  local zone = windower.ffxi.get_info().zone
  resetting = true
  
  --log(menus)
  
  ArrayRemove(menus, function(t, i, j)
    return t[i].zone == zone
  end)
  
  if #menus == 0 then 
    windower.add_to_chat(10,'You are not listed as in a menu interaction. Ignoring.')
    return
  end
  
  while #menus > 0 and resetting do
    local packet = packets.new('outgoing', PACKET_OUT.DIALOG_CHOICE, {
      ['Target'] = menus[#menus].npc,
      ['Option Index'] = '0',
      ['_unknown1'] = '16384',
      ['Target Index'] = menus[#menus].npc_index,
      ['Automated Message'] = false,
      ['_unknown2'] = 0,
      ['Zone'] = menus[#menus].zone,
      ['Menu ID'] = menus[#menus].menu_id
    })
    
    packets.inject(packet)
    
    menus:remove(#menus)
    
    log('Attempting to reset...')
    coroutine.sleep(2)
  end
  
  if resetting then
    captionlog(nil, 10, 'Failed to reset?')
  else
    captionlog(nil, 10, 'Should be reset now. Please try again.')
  end
  
  resetting = false
end

function updateInfo()
  box:visible(settings.show)
  local lines = T{}
  for name, status in pairs(report_info) do
    if status then lines:insert(name..' √')
    else           lines:insert(name..' ×') end
  end
  local maxWidth = math.max(1, table.reduce(lines, function(a, b) return math.max(a, #b) end, '1'))
  for i,line in ipairs(lines) do lines[i] = lines[i]:lpad(' ', maxWidth) end
  
  if not npc then lines:insert(1, 'Mirroring '..(settings.mirror and 'enabled' or 'disabled'))
  else
    if success then
      lines = T{'NPC: '..npc.name, 'Interacting...'}
    elseif last_npc and last_npc.id == npc_id then
      if #lines == 0 then lines:insert('Broadcasting...') end
      lines:insert(1, 'NPC: '..last_npc.name)
    else
      lines = T{}
    end
  end
  
  box:text(lines:concat('\n'))
end

function doFade()
  local opacity = 1
  local diff = os.clock() - last_update_time
  
  if diff < settings.fade then
    opacity = 1
  elseif diff < settings.fade + fade_duration then
    opacity = 1 - (diff-settings.fade) / fade_duration
  else
    opacity = 0
  end
  
  box:alpha(opacity*defaults.display.text.alpha)
  box:bg_alpha(opacity*defaults.display.bg.alpha)
  
  if opacity == 0 then box:visible(false) end
end

function distance(A, B)
  return math.sqrt((A.x - B.x)^2 + (A.y - B.y)^2)
end

function ArrayRemove(t, fnKeep)
  local j, n = 1, #t;

  for i=1,n do
    if (fnKeep(t, i, j)) then
      -- Move i's kept value to j's position, if it's not already there.
      if (i ~= j) then
        t[j] = t[i];
        t[i] = nil;
      end
      j = j + 1; -- Increment position of where we'll place the next kept value.
    else
      t[i] = nil;
    end
  end

  return t;
end
