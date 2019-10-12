_addon.name = 'chatwindow'
_addon.author = 'from20020516'
_addon.version = '1.1'
_addon.commands = {'cw'}

require('sets')
res = require('resources')
config = require('config')
packets = require('packets')

defaults = {
  font='Yu Gothic UI',
  fontsize=12,
  time=true;
  timeformat='%H:%M:%S',
  position={
    x=0,y=350},
  rows=10,
  reverse=true,
  alert={
    regex='KEYWORDS_HERE',wav='chime.wav',},
  chatfilter={
    say=false,shout=false,tell=false,party=false,linkshell=false,linkshell2=false,emote=false,yell=false,unity=false,},
  textcolor={
    A=255,say={R=255,G=255,B=255},shout={R=255,G=153,B=153},tell={R=204,G=0,B=204},party={R=51,G=255,B=255},
    linkshell={R=153,G=255,B=153},emote={R=153,G=153,B=255},yell={R=255,G=102,B=102},linkshell2={R=0,G=153,B=0},
  unity={R=255,G=255,B=102}},
  textstroke={
    width=2,A=125,R=0,G=0,B=0},
  background={
    visible=true,A=25,R=0,G=0,B=0},}
settings = config.load(defaults)

chatbox = {}
width,height = 0,0
flag_visible = true
font_width,font_height = 0,0
local add = 0.9984

function gen_window(boxid)
  windower.text.create(boxid)
  windower.text.set_font(boxid,settings.font,'Yu Gothic UI','Meiryo','Segoe UI') --font priority
  windower.text.set_font_size(boxid,settings.fontsize)
  local stroke = settings.textstroke
  windower.text.set_stroke_color(boxid,stroke.A,stroke.R,stroke.G,stroke.B)
  windower.text.set_stroke_width(boxid,stroke.width)
end

windower.register_event('load',function()
  local X,Y = settings.position.x,settings.position.y
  for row=1,settings.rows do
    local boxid = row+add
    gen_window(boxid)
    local visibility = row <= settings.rows
      windower.text.set_visibility(boxid,visibility)
    if boxid == 1+add then
      windower.text.set_location(boxid,X,Y)
      windower.text.set_text(boxid,' ')
      coroutine.sleep(0.1)
      font_width,font_height = windower.text.get_extents(1+add) --return x,y
    else
      windower.text.set_location(boxid,X,Y+font_height*(row-1))
      --windower.text.set_text(boxid,boxid) --debug
    end
  end
end)

function in_box(name,chat,mode)
  config.reload(settings)
  if not settings.chatfilter[mode] then
    if chat:find(settings.alert.regex) then
      local wav_path = windower.addon_path..settings.alert.wav
      if windower.file_exists(wav_path) then
      windower.play_sound(wav_path)
      end
    end
    local time = settings.time and '['..os.date(settings.timeformat)..']' or ''
    local text = windower.from_shift_jis(table.concat({time,name,':',chat},' '))
    table.insert(chatbox,1,{text,mode})
    display_text()
  end
end

function display_text()
  for row=1,settings.rows do
    local boxid = row+add
    local ref = settings.reverse and row or settings.rows-(row-1)
    local text = chatbox[ref] and chatbox[ref][1]
    if chatbox[ref] then
      local color = settings.textcolor[chatbox[ref][2]]
      windower.text.set_color(boxid,settings.textcolor.A,color.R,color.G,color.B)
      windower.text.set_text(boxid,chatbox[ref][1])
      local bg = settings.background
      if bg.visible then
        windower.text.set_bg_color(boxid,bg.A,bg.R,bg.G,bg.B)
        windower.text.set_bg_visibility(boxid,true)
      end
    else
      windower.text.set_bg_visibility(boxid,false)
    end
  end
end

function change_rows(rows)
  for row=1,rows do
    local boxid = row+add
    local ref = settings.reverse and row or rows-(row-1)
    if not windower.text.get_extents(boxid) then --今ないなら生成
      gen_window(boxid)
      local X,Y = settings.position.x,settings.position.y
      windower.text.set_location(boxid,X,Y+font_height*(row-1))
    end
    windower.text.set_visibility(boxid,rows>=row)
    local text = chatbox[ref] and chatbox[ref][1] or ''
    windower.text.set_text(boxid,text)
  end
end

function change_location(X,Y)
  for row=1,settings.rows do
    windower.text.set_location(row+add,X,Y+font_height*(row-1))
  end
end

windower.register_event('addon command',function(cmd,...)
  local args = {...}
  for i,v in pairs(args) do
    if tonumber(v) then
      args[i]=v*1
    end
  end
  if cmd == 'visible' then
    flag_visible = not flag_visible
    for i=1,settings.rows do
      windower.text.set_visibility(i+add,flag_visible)
    end
  elseif cmd == 'row' then
    change_rows(math.max(args[1],settings.rows))
    settings.rows = args[1]
  elseif cmd == 'pos' then
    local pos = settings.position
    pos.x,pos.y = args[1],args[2]
    change_location(args[1],args[2])
  end
  settings:save('all')
end)

windower.register_event('incoming chunk',function(id,data)
  if S{0x017,0x05A}[id] then --chat,emote
    local p = packets.parse('incoming',data)
    if id == 0x05A and p["Type"] ~= 2 then --ignore with motion arg
      local name = windower.ffxi.get_mob_by_index(p["Player Index"]).name
      local target = p["Target ID"] > 0 and windower.ffxi.get_mob_by_index(p["Target Index"]).name or ''
      local chattext = '/'..res.emotes[p["Emote"]].command..' '..target
      in_box(name,chattext,'emote')
    elseif id == 0x017 then
      local name = p["Sender Name"]
      local chattext = windower.convert_auto_trans(p["Message"])
      local chatmode = res.chat[p["Mode"]].en
      if name ~= '' then --ignore unity leaders
        in_box(name,chattext,chatmode)
      end
    end
  end
end)

windower.register_event('outgoing chunk',function(id,data)
  if S{0x0B5,0x0B6}[id] then --speech,tell
    local p = packets.parse('outgoing',data)
    local chattext = windower.convert_auto_trans(p["Message"])
    local chatmode = res.chat[p["Mode"] or 3].en --tell
    in_box(windower.ffxi.get_player().name,chattext,chatmode)
  end
end)
