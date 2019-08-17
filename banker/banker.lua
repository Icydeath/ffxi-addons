_addon.name = 'banker'
_addon.version = '1.0'
_addon.author = 'ybot'
_addon.commands = {'banker', 'bank'}

require('luau')
packets = require('packets')
texts = require('texts')
images = require('images')
config = require('config')
fields = require('packets/fields')

local curr1 = fields.incoming[0x113]
local curr2 = fields.incoming[0x118]

defaults = {}

defaults.chestImage = {}
defaults.chestImage.color = {}
defaults.chestImage.color.alpha = 255
defaults.chestImage.color.red = 255
defaults.chestImage.color.green = 255
defaults.chestImage.color.blue = 255
defaults.chestImage.visible = true

defaults.mode = 'zone'
defaults.alert = false
defaults.balance = S{'Coalition Imprimaturs', 'Bayld', 'Escha Silt', 'Escha Beads'}
defaults.alerts = T{['Coalition_Imprimaturs'] = 15}
defaults.x_pos = 1902
defaults.y_pos = 0
defaults.alerts_x_pos = 480
defaults.alerts_y_pos = 540

local settings = config.load(defaults)

settings.chestImage.texture = {}
settings.chestImage.texture.path = windower.addon_path..'coins.png'
settings.chestImage.texture.fit = false
settings.chestImage.size = {}
settings.chestImage.size.height = 16
settings.chestImage.size.width = 16
settings.chestImage.draggable = false
settings.chestImage.repeatable = {}
settings.chestImage.repeatable.x = 1
settings.chestImage.repeatable.y = 1

local bankBox

function init_banker_ui()

  if bankBox then bankBox:destroy() end

  local windower_settings = windower.get_windower_settings()
  local x,y
  x,y = windower_settings["ui_x_res"] - 18, 0  -- -18, -0

  local font = displayfont or 'Arial'
  local size = displaysize or 8
  local bold = displaybold or true
  local bg = displaybg or 0
  local strokewidth = displaystroke or 2
  local stroketransparancy = displaytransparancy or 120
  local clr = {
        h='\\cs(167, 121, 168)', -- Yellow for active booleans and non-default modals
        w='\\cs(255,255,255)', -- White for labels and default modals
        n='\\cs(192,192,192)', -- White for labels and default modals
        s='\\cs(96,96,96)' -- Gray for inactive booleans
  }
  chest_image = images.new(settings.chestImage)
  chest_image:pos(x, y-2)
  chest_image:show()

  bankBox = texts.new('${items1} ${items2}')
  bankBox:pos(x,y)
  bankBox:font(font)--Arial
  bankBox:size(size)
  bankBox:bold(bold)
  bankBox:bg_alpha(bg)--128
  bankBox:right_justified(true)
  bankBox:stroke_width(strokewidth)
  bankBox:stroke_transparency(stroketransparancy)
  bankBox:show()

  local last_menu1 = windower.packets.last_incoming(0x113)
  local last_menu2 = windower.packets.last_incoming(0x118)
  if last_menu1 then
    update_banker_info(0x113,last_menu1)
  end
  if last_menu2 then
    update_banker_info(0x118,last_menu2)
  end
  if ( last_menu1 == nil or last_menu2 == nil ) and settings.mode ~= 'manual'  then
    banker_menu_interact()
  end
end

function update_banker_ui(str, slot)
  local str = str or ''
  if slot == 1 then
    bankBox.items1 = str
  else
    bankBox.items2 = str
  end
end

function check_banker_command(...)
  cmd = {...}
  if cmd[1] ~= nil then
    cmd[1] = cmd[1]:lower()
  end

  if cmd[1] == nil or cmd[1] == "status" then
    log("Currently watching: %s":format(settings.balance:format('csv')))
  end

  if cmd[1] == "refresh" then
    banker_menu_interact()
  end

  if cmd[1] == "mode" and cmd[2] ~= nil then
    local new_mode = string.lower(cmd[2])
    if new_mode == "manual" or new_mode == "auto" or new_mode == "zone" then
      settings.mode = new_mode
      log("Mode is now: %s":format(new_mode))
    else
      log("'%s' is not a valid mode. Valid Modes: auto, zone, manual":format(new_mode))
    end
  elseif cmd[1] == "mode" and cmd[2] == nil then
    log("Mode: %s":format(settings.mode))
  end

  if (cmd[1] == "add" or cmd[1] == "a" or cmd[1] == "+") and cmd[2] ~= nil then
    local currency = cmd[2]
    if cmd[3] ~= nil then
      currency = currency.." "..cmd[3]
      if cmd[4] ~= nil then
        currency = currency.." "..cmd[4]
      end
    end
    bankBox.items1 = ''
    bankBox.items2 = ''
    add_item(currency)
    if settings.mode ~= 'manual' then
      banker_menu_interact()
    end
  end

  if (cmd[1] == "remove" or cmd[1] == "rem" or cmd[1] == "delete" or cmd[1] == "del" or cmd[1] == "d" or cmd[1] == "-") and cmd[2] ~= nil then
    local currency = cmd[2]
    if cmd[3] ~= nil then
      currency = currency.." "..cmd[3]
      if cmd[4] ~= nil then
        currency = currency.." "..cmd[4]
      end
    end
    remove_item(currency)
    if settings.mode ~= 'manual' then
      banker_menu_interact()
    end
  end

  if cmd[1] == "alert" and cmd[2] ~= nil then
    if cmd[2] == "true" then
      settings.alert = true
      log("Alert: true")
    else
      settings.alert = false
      log("Alert: false")
    end
    if settings.mode ~= 'manual' then
      banker_menu_interact()
    end
  end
  config.save(settings)
end

function banker_menu_interact()
  local player = windower.ffxi.get_player()
  if player ~= nil and settings.mode ~= 'menu' then
    windower.packets.inject_outgoing(0x115,string.char(0x36,0x20,0,0))
    windower.packets.inject_outgoing(0x10F,string.char(0x36,0x20,0,0))
  else
    log("Player not Loaded or in Menu mode")
  end
end

function update_banker_info(id, data)
  if id == 0x118 then
    -- Currencies 2
    banker_balance( data, 2 )
  elseif id == 0x113 then
    -- Currencies 1
    banker_balance( data, 1 )
  end
end

function banker_balance( data, slot )
  local string = ''
  local packet = packets.parse('incoming', data)
  for item,index in pairs(settings.balance) do
    for currency,value in pairs(packet) do
      if item:lower() == currency:lower() then
        string = string.." "..item..": "..value
        -- check if we should alert
        banker_should_alert(item, value)
      end
    end
  end
  update_banker_ui(string, slot)
end

function banker_handle_zone_change()
  banker_menu_interact()
end

-- Adds names/items to a given list type.
function add_item(...)
    local search = ...
    search = string.gsub(" "..search, "%W%l", search.upper):sub(2)
    local items = S{search} -- make a set out of the string we send in
    local doubles = items * settings.balance -- intersection of two sets
    local valid = banker_valid_label(search)
    if valid == true then
      if not doubles:empty() then
        notice('Item':plural(doubles)..' '..doubles:format()..' already on list.')
      end
      local new = items - settings.balance
      if not new:empty() then
          settings.balance = settings.balance + new
          log('Added '..new:format()..' to the balance sheet.')
          config.save(settings)
      end
    else
      notice('Item name is not valid.')
    end
end

-- Removes names/items from a given list type.
function remove_item(...)
    local search = ...
    search = string.gsub(" "..search, "%W%l", search.upper):sub(2)
    local items = S{search} -- make a set out of the string we send in
    local dummy = items - settings.balance
    if not dummy:empty() then
      notice('Item':plural(dummy)..' '..dummy:format()..' not found on list.')
    end
    local item_to_remove = items * settings.balance
    if not item_to_remove:empty() then
        settings.balance = settings.balance - item_to_remove
        log('Removed '..item_to_remove:format()..' from the balance sheet.')
    end
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function banker_valid_label(search)
  for key = 1, curr1.n do
      local table = rawget(curr1,key)
      if table.label == search then
        return true
      end
  end
  for key = 1, curr2.n do
      local table = rawget(curr2,key)
      if table.label == search then
        return true
      end
  end
  return false
end

function banker_translate_spaces_to_underscores(str)
  return string.gsub(str,' ','_')
end

function banker_add_alert( item, value )
  if banker_valid_label( item ) then
    settings.alerts[banker_translate_spaces_to_underscores(item)] = value
    config.save(settings)
    log("Added '"..item.."' to the alert list.")
  else
    log(item.." is not a valid currency.")
  end
end

function banker_should_alert( item, value )
  local thresh = settings.alerts[banker_translate_spaces_to_underscores(item)];
  local match = settings.alerts[banker_translate_spaces_to_underscores(item)]
  if match ~= nil and value >= thresh then
    banker_alert( item, value )
  end
end

function banker_alert( item, value )
  if settings.alert ~= true then
    return false
  end
  log( "ALERT! "..item.." : "..value )
  local msg = ""..item.." : "..value
  local alertbox = texts.new(msg)
  local windower_settings = windower.get_windower_settings()
  local x,y
  local x,y
  x,y = windower_settings["ui_x_res"], windower_settings["ui_y_res"] / 2  -- -18, -0

  local font = displayfont or 'Arial'
  local size = displaysize or 30
  local bold = displaybold or true
  local bg = displaybg or 0
  local strokewidth = displaystroke or 0
  local stroketransparancy = displaytransparancy or 255

  alertbox:pos(x,y)
  alertbox:font(font)--Arial
  alertbox:size(size)
  alertbox:bold(bold)
  alertbox:bg_alpha(bg)--128
  alertbox:stroke_width(strokewidth)
  alertbox:stroke_transparency(stroketransparancy)
  alertbox:color(255,0,0)
  alertbox:show()
  coroutine.schedule(function()
    -- have to delay so extents can actually get a value
    local w,h = texts.extents(alertbox);
    alertbox:pos( windower_settings["ui_x_res"] / 2 - (w / 2),y)
    --play sound
    local sound = 'alert.wav'
    local path = ''..windower.addon_path..'/'..sound
    windower.play_sound(path)

    coroutine.schedule(
      function ()
        local i = 255
        while i > 0 do
          alertbox:alpha(math.floor(255*(1-i)))
          coroutine.sleep(0.1)
          -- alertbox:stroke_transparency(math.floor(255*(1-i)))
          i = i - 9
        end
        alertbox:destroy()
      end, 3)
  end, 0.5)

end

windower.register_event('incoming chunk', update_banker_info)
windower.register_event('addon command', check_banker_command)
windower.register_event('load', init_banker_ui)
windower.register_event('zone change', banker_handle_zone_change)
