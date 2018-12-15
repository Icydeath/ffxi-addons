_addon = {}
_addon.name = 'Herd'
_addon.version = '2.0.5'
_addon.author = 'Nifim'
_addon.commands = {'herd'}

local herd = {}

require('sets')
require('logger')
require('strings')

res = require('resources')
packets = require('packets')
state = 'stand' -- default state is stand

haj = 0
stop = 3
roam = 5
htol = 0.157



_menu = true
_sheep = true
_follow = true
_shepherd = ''
shepherd_last = {x=0, y=0}

option_ID = nil
menu_openned = false
menus = S{
  'undulating confluence', 
  'cavernous maw',
  'eschan portal #1',
  'eschan portal #2',
  'eschan portal #3',
  'eschan portal #4',
  'eschan portal #5',
  'eschan portal #6',
  'eschan portal #7', 
  'eschan portal #8',
  'eschan portal #9',
  'eschan portal #10',
  'eschan portal #11',
  'eschan portal #12',
  'eschan portal #13',
  'eschan portal #14',
  'eschan portal #15',
  'veridical conflux #00',
  'veridical conflux #01',
  'veridical conflux #02',
  'veridical conflux #03',
  'veridical conflux #04',
  'veridical conflux #05',
  'veridical conflux #06',
  'veridical conflux #07',
  'veridical conflux #08',
  'veridical conflux #09',
  'veridical conflux #10',
  'veridical conflux #12',
  'veridical conflux #13',
  'veridical conflux #13',
}

help_text = [[Herd - Commands:
1.  //herd help - Displays this help menu.
2a. //herd (s)hepherd - Will make all other boxs follow the box that sent this command
2b. //herd (s)hepherd [Name]- Will make this box follow the character with the given name
3.  //herd (j)oin - Causes box to join the herd and follow the current shepherd
4.  //herd (l)eave - Causes box to leave the herd and will no longer follow the current shepherd
5.  //herd (r)elease - Causes all boxs to leave herd and cease following
6a  //herd (m)enu - toggles auto-menu feature of herd
6b. //herd (m)enu (a)dd|(r)emove [Name] - add or remove the name of approve npc for your sheep to open the menus of if you do.
6c. //herd (m)enu (l)ist - list all npc's currently on the approved list for sheep to interact with.
7.  //herd (f)ollow - toggles auto-follow feature of herd
8.  //herd roam [start_distance] [end_distance] - sets distance to beging following shepherd and distanec to stop
 ]]	
--
-- Herd IPC Functions
function herd.recieve_ipc(raw)
  local player = windower.ffxi.get_player()
  raw = raw and raw:lower()
  msg = string.split(''..raw, ',')   
  --print(msg[1] or 'nil')
  if herd.ipc[msg[1]] then
    herd.ipc[msg[1]](msg)
  end
end
herd.ipc = {}
function herd.ipc.menu(msg)
  if msg[2] == ' true' then
    _menu = true
    notice('Auto-Menu Enabled')
  else
    _menu = false
    notice('Auto-Menus Disabled')    
  end
end
function herd.ipc.join(msg)
  if _sheep == false then
    windower.send_ipc_message('shepherd,'..player.id)
  end
end
function herd.ipc.follow(msg)
  if _follow == true then
    _follow = false
    notice('Auto-Follow Disabled')
  else
    _follow = true
    notice('Auto-Follow Enabled')
  end  
end
function herd.ipc.release(msg)
  windower.send_command('input //herd leave')
end
function herd.ipc.shepherd(msg)
  _shepherd = msg[2]
  shepName = windower.ffxi.get_mob_by_id(msg[2]).name   
  _sheep = true
  if shepName then
    notice('Sheperd - '..shepName)
  end
end
function herd.ipc.menu_open(msg)
  local tID = tonumber(msg[2],16) 
  local zID = tonumber(msg[3],16)           
  herd.menu_open(tID,zID)
end
function herd.ipc.menu_select(msg)
  local tID = tonumber(msg[2],16) 
  local zID = tonumber(msg[3],16)
  local pID = tonumber(msg[4],16)
  local oID = tonumber(msg[5],16)
  herd.menu_select(tID,zID,pID,oID)
end
--
-- Herd Commands
function herd.command(cmd,...)
  local arg = T{...}:map(string.lower) or {}
  cmd = cmd and cmd:lower() or 'help'
  if herd.cmd[cmd] then
    herd.cmd[cmd](arg)
  end
end
herd.cmd = {}
function herd.cmd.help()
  print(help_text)
end
function herd.cmd.roam(arg)
  if #arg == 2 and tonumber(arg[1]) > tonumber(arg[2]) then
    roam = tonumber(arg[1])
    stop = tonumber(arg[2])
    notice('Follow Start Distance - '..roam..' End Distance - '..stop)
  elseif #arg == 2 and tonumber(arg[1]) <= tonumber(arg[2]) then
    notice('Follow start distance('..roam..') must be greater then end distance('..stop..')')
  end  
end
function herd.cmd.menu(arg)
  name = ''
  if arg[1] == nil then
    if _menu == true then
      _menu = false
      notice('Auto-Menus Disabled')
      windower.send_ipc_message('menu, false')
    else
      _menu = true
      notice('Auto-Menus Enabled')
      windower.send_ipc_message('menu, true')
    end  
  elseif arg[2] ~= nil and (arg[1] == 'a' or arg[1] =='add') then 
    name = arg[2]
    for i=3,#arg,1 do
      name = name..' '..arg[i]
    end
    menus:add(name)
    notice('Menu added '..name)
  elseif arg[2] ~= nil and (arg[1] == 'r' or arg[1] == 'remove') then
    name = arg[2]
    for i=3,#arg,1 do
      name = name..' '..arg[i]
    end
    menus:remove(name)
    print('Menu removed '..name)
  else
    for k in pairs(menus) do
      windower.add_to_chat(4,'Menu: k')
    end
  end
end
function herd.cmd.join(arg)
  local id = windower.ffxi.get_player().id
  windower.send_ipc_message('join,'..id)
end
function herd.cmd.leave(arg)
  _sheep = false
  _shepherd = ''	 
end
function herd.cmd.follow(arg)
  if _follow == true then
    _follow = false
    notice('Follow - Disabled')
    windower.send_ipc_message('follow, false')
  else
    _follow = true
    notice('Follow - Enabled')
    windower.send_ipc_message('follow, true')
  end
end
function herd.cmd.release(arg)
  windower.send_ipc_message('release') 
end
function herd.cmd.shepherd(arg)
  local id = windower.ffxi.get_player().id
  if arg[1] == nil then
    _sheep = false
    _shepherd = ''
    windower.send_ipc_message('shepherd,'..id)  
  else
    _sheep = true
    capped_arg = arg[1]:gsub("^%l", string.upper)
    _shepherd = windower.ffxi.get_mob_by_name(capped_arg).id  
  end
end
herd.cmd.m = herd.cmd.menu
herd.cmd.j = herd.cmd.join
herd.cmd.l = herd.cmd.leave
herd.cmd.f = herd.cmd.follow
herd.cmd.r = herd.cmd.release
herd.cmd.s = herd.cmd.shepherd
--
-- Herd States
function herd.main()
  if _shepherd ~= '' then
    herd[state]()
  end 
end
function herd.stand()
  local shepherd = windower.ffxi.get_mob_by_id(_shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if shepherd ~= nil then
    local x = shepherd.x - sheep.x
    local y = shepherd.y - sheep.y     
    hto = sheep.facing
    if _follow == true and shepherd.distance:sqrt() > roam and (shepherd.x ~= shepherd_last.x or shepherd.y ~= shepherd_last.y) then
      state = 'follow'
    end
    shepherd_last = shepherd
  end
end
function herd.follow()
  local shepherd = windower.ffxi.get_mob_by_id(_shepherd)
  local sheep = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
  if (shepherd ~= nil and shepherd.distance:sqrt() > stop) then
    local h = herd.get_heading(shepherd, sheep)
    --check for if heading needs to be adjusted
    if hto ~= h and math.abs(math.abs(hto) - math.abs(h)) > htol then    
      herd.turn_around(h)
      if hto > h then
        herd.turn_left(h)
      elseif hto < h then
        herd.turn_right(h)
      end
    else
      windower.ffxi.run(hto)
    end
  else
    state = 'stand'
    haj = 0
    windower.ffxi.run(false) 
  end
end
--
-- Turning Functions
function herd.get_heading(shepherd, sheep)
  local x = shepherd.x - sheep.x
  local y = shepherd.y - sheep.y 
  local h = math.atan2(x, y)			
  if haj == 0 then
    haj = 0.0559244155884 + math.random(-0.0000000000003, 0.0000000000006)
  end
  --Adjust heading 90 degrees i dont know why but its needed -1.5707963267948966192313216916398 
  if h < -math.pi/2 then
    --headings in the sw quad need to be handled properly
    h = math.pi - (math.abs(h - (math.pi/2)) - math.pi)
  else
    --headings in the remaining quads are handled like so
    h = h - (math.pi/2)
  end
  return h
end
function herd.turn_around(h)
  htolo = hto-(math.pi*0.75)
  htohi = hto-(math.pi*1.25) 
  if htolo < -math.pi then
    htolo = math.pi - math.abs(htolo + math.pi)
  end
  if htohi < -math.pi then
    htohi = math.pi - math.abs(htohi + math.pi)
  end
  if htolo < htohi and h > 0 then
    htolo = math.pi + (htolo + math.pi)
  elseif htolo < htohi and h < 0 then
    htohi = -math.pi + (htohi - math.pi)
  end    
  if h < htolo and h > htohi then 
    hto = hto-math.pi       
    if hto < -math.pi then
      hto = math.pi - math.abs(hto + math.pi)
    end
    windower.ffxi.turn(hto)
  end 
end
function herd.turn_left(h)   
  --this handles 0 corssing to continue with the correct heading adjustment
  if hto > 0 and  0 > h and hto > 2 then
    hto = hto + 0.0559244155884002
  else
    hto = hto - 0.0559244155884002
  end
  --this handles the actual pi crossing when hto is greater then pi
  if hto > math.pi then
    hto = -math.pi + (hto - math.pi)
  end
end
function herd.turn_right(h)
  if hto < 0 and 0 < h and hto < -2 then
    hto = hto - 0.0559244155884002
  else
    hto = hto + 0.0559244155884002
  end
  if hto < -math.pi then
    hto = math.pi + (hto + math.pi)
  end
end
--
-- Menu Functions
function herd.menu(id, data, modified)
  if _sheep then
    if id == 0x05b then -- HP menu
      local p = packets.parse('outgoing', data)
      p2 = packets.parse('outgoing', data)
      if p["Option Index"] == 0 and p["_unknown1"] == 16384 and option_ID then      
        p, p2 = herd.warp_packets(p, p2)
        option_ID = nil
        menu_openned = false
        return packets.build(p)
      elseif p["Option Index"] == 8 and p["_unknown1"] == 0 then   
        menu_openned = true
      elseif p["Option Index"] == 0 and p["_unknown1"] == 16384 then
        menu_openned = false
      end
    end
  elseif _menu == true then
    herd.menu_id(id, data)
  end 
end
function packet_2()
  packets.inject(p2)
  p2 = nil
end
function herd.warp_packets(packet, packet2)
  local p_target = windower.ffxi.get_mob_by_id(packet['Target'])
  if string.match(p_target.name, 'Home Point') then
    packet["Option Index"] = 2
    packet["_unknown1"] = option_ID
    packet["Automated Message"] = true  
    packet2["Option Index"] = 2
    packet2["_unknown1"] = option_ID        
    packet2["Automated Message"] = false
    if packet["_unknown1"] ~= 16384 then
      coroutine.schedule(packet_2,7)
    end
  elseif string.match(p_target.name, 'Undulating Confluence') then
    packet["Option Index"] = 0
    packet["_unknown1"] = option_ID
    packet["Automated Message"] = true  
    packet2["Option Index"] = 1
    packet2["_unknown1"] = option_ID        
    packet2["Automated Message"] = false
    if packet["_unknown1"] ~= 16384 then
      coroutine.schedule(packet_2,10)
    end
  elseif string.match(p_target.name, 'Cavernous Maw') then
    packet["Option Index"] = 0
    packet["_unknown1"] = option_ID
    packet["Automated Message"] = true  
    packet2["Option Index"] = 1
    packet2["_unknown1"] = option_ID        
    packet2["Automated Message"] = false
    if packet["_unknown1"] ~= 16384 then
      coroutine.schedule(packet_2,8)
    end
  elseif string.match(p_target.name, 'Eschan Portal') then
    packet["Option Index"] = 1
    packet["_unknown1"] = option_ID
    packet["Automated Message"] = true  
    packet2["Option Index"] = 2
    packet2["_unknown1"] = option_ID        
    packet2["Automated Message"] = false
    if packet["_unknown1"] ~= 16384 then
      coroutine.schedule(packet_2,7)
    end
  elseif string.match(p_target.name, 'Ethereal Igress') then
    packet["Option Index"] = 0
    packet["_unknown1"] = option_ID
    packet["Automated Message"] = true  
    packet2["Option Index"] = 1
    packet2["_unknown1"] = option_ID        
    packet2["Automated Message"] = false
    if packet["_unknown1"] ~= 16384 then
      coroutine.schedule(packet_2,7)
    end
  end
  return packet, packet2
end
function herd.menu_open(tID, zID)
  world = windower.ffxi.get_info()
  if zID == world.zone then
    menu_target = windower.ffxi.get_mob_by_id(tID)
    if menu_target and menu_target.distance:sqrt() <= 5.2 then
      local p = packets.new('outgoing', 0x01a, {
          ["Target"] = menu_target.id,
          ["Target Index"] = menu_target.index,
        })
      packets.inject(p)
    end
  end
end
function herd.menu_select(tID,zID,pID,oID)
  world = windower.ffxi.get_info()
  target = windower.ffxi.get_mob_by_id(tID)
  base = windower.packets.last_outgoing(0x05B)
  if menu_openned == true then
    menu_openned = false
    option_ID = oID
    windower.send_command('wait 0.1; setkey escape down; wait 0.1; setkey escape up')  
  end
end
function herd.menu_id(pid, data)
  local menu = ""
  if pid == 0x05B then
    bytes = {}
    for i=1, #data do
      bytes[i] = string.format('%x',string.byte(data:sub(i,i)))
      if #bytes[i] == 1 then bytes[i] = '0'..bytes[i] end
    end
    mID = tonumber(bytes[20]..bytes[19],16)
    if mID >= 8700 and mID <= 8704 then
      menu = 'home_point'    
    elseif mID == 9100 then
      --menu = 'eschan_portal'    
    elseif S{1,4,14,65}:contains(mID) then
      menu = 'confluence'        
    elseif S{55,200}:contains(mID) then
      menu = 'cavernous'
    end       
    if menu ~= '' then
      herd[menu](pid, bytes)
    end
  elseif pid == 0x01A then    
    local w = windower.ffxi.get_info()
    local p = packets.parse('outgoing', data)    
    if _menu == true and menus:contains(string.lower(windower.ffxi.get_mob_by_id(p['Target']).name)) then
      local tid = string.format('%x', p['Target'])
      local zid = string.format('%x', w.zone)
      windower.send_ipc_message('menu_open,'..tid..','..zid)
    end
  end
end

function herd.home_point(pID, bytes)
  if _sheep == false then   
    oID = bytes[12]..bytes[11]                       -- build option id
    zID = bytes[18]..bytes[17]                       --  ''   zone id 
    oIndex = tonumber(bytes[10]..bytes[9],16)        --  ''   option Index
    tID = bytes[8]..bytes[7]..bytes[6]..bytes[5]     --  ''   target id 
    automsg = bytes[15]                              --  ''   automated message
    if oIndex == 8 then                              -- if menu has been openned command sheep to open menu as well
      windower.send_ipc_message('menu_open,'..tID..','..zID)
    elseif S{0,1,2}:contains(oIndex) then                          -- if a selection has been made command sheep to make the same selection
      windower.send_ipc_message('menu_select,'..tID..','..zID..','..pID..','..oID)      
    end
  end
end
herd.eschan_portal = herd.home_point -- currently not supported ; ;
herd.confluence = herd.home_point
herd.cavernous = herd.home_point
--
-- Windower Events
windower.register_event('ipc message', herd.recieve_ipc)
windower.register_event('addon command', herd.command)
windower.register_event('postrender', herd.main)
windower.register_event('outgoing chunk', herd.menu)
