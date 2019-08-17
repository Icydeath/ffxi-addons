_addon.name = 'tonic'
_addon.author = 'ybot'
_addon.version = '1.0'
_addon.commands = {'tonic', 'ton'}

require('tables')
require('logger')
require('functions')
require('coroutine')
config = require('config')
items = require('items')
buffs = require('buffup')

local defaults = {
	debug = false,
	send_all_delay = 0.4,
}

local settings = config.load(defaults)

local state = {
	loop_count = nil,
}

function debug(msg)
	if settings.debug then
		log('debug: '..msg)
	end
end

local function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    for k, v in pairs(members) do
        if v == self then
            return (k - 1) * settings.send_all_delay
        end
    end
end

local function check_shortcut(item)
  for k,v in pairs(items) do
    if k == item then
      return v.name
    end
  end
  return item
end

local function quotify(str)
  return '"'..str..'"'
end

local function drink(item)
  if item ~= nil then
    local cmd = '/item '..item..' <me>'
    debug(cmd)
    windower.chat.input(cmd)
  else
    log("Unknown item: "..item)
  end
end

local function buffup()
  log("Using all buff items")
  local use_delay = 3.5
  for k,v in pairs(buffs) do
    drink(quotify(v.name))
    coroutine.sleep(use_delay)
  end
end

local function handle_drink(item, args)
  debug("Handling drink")
  local all = item:lower() == 'all' or item:lower() == 'a' or item:lower() == '@all'
  local do_buffup = args[1] == 'buffup' or item:lower() == 'buffup'
  if all then
    args:remove(0)
    debug('sending tonic to all.')
    local ipc = check_shortcut(args:concat(' '))
    debug(ipc)
		windower.send_ipc_message(ipc)

		local delay = get_delay()
		handle_drink:schedule(delay, args:concat(' '), args)
		return
  end

  if do_buffup then
    buffup()
    return
  end

  item = check_shortcut(item)
  drink(quotify(item))
end

local function handle_help()
	log("//tonic <item> -- Uses the specified item. Use quotes and spell it correctly")
	log("//tonic <shortcut> -- Uses the specific item that has a shortcut. Shortcuts are:")
	for k,v in pairs(items) do
		-- todo: this should be alphabetical
		log(k..": "..v.name)
	end
	log("//tonic buffup -- uses all the items defined in buffs.lua in sequence.")
	log("//tonic a <command> -- Send the command to all boxes that have tonic enabled, eg `//tonic a reraise`")
end

local function handle_command(cmd, ...)
  local args = T{...}
	if "help" == cmd then
		handle_help()
	else
	  handle_drink(cmd, args)
	end
end

-- handle ipc message
windower.register_event('ipc message', function(msg)
	local delay = get_delay()
	debug('received ipc: '..msg..'. executing in '..tostring(delay)..'s.')
	handle_drink:schedule(delay, msg, "")
end)

windower.register_event('addon command', handle_command)
