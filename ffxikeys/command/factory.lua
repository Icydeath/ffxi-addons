local ConfigCommand = require('command/config')
local NilCommand = require('command/nil')
local StopCommand = require('command/stop')
local UseCommand = require('command/use')
local Keys = require('data/keys')
local Goblins = require('data/goblins')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CommandFactory = {}

--------------------------------------------------------------------------------
local ConfigCommands = {}
ConfigCommands['loop'] = true
ConfigCommands['printlinks'] = true
ConfigCommands['openlinks'] = true
ConfigCommands['logitems'] = true
setmetatable(ConfigCommands,
    { __index = function() return false end })

--------------------------------------------------------------------------------
function CommandFactory.CreateCommand(cmd, p1)
    if cmd == 'use' then
        local key = Keys.GetByProperty('en', p1)
        if key.id == 0 then
            log('Invalid key argument')
            return NilCommand:NilCommand()
        end
        local npc = Goblins.GetClosest()
        return UseCommand:UseCommand(npc.id, key.id, npc.zone)
    elseif cmd == 'stop' then
        return StopCommand:StopCommand()
	elseif cmd == 'help' then
		Help()
        return StopCommand:StopCommand()
    elseif ConfigCommands[cmd] then
        return ConfigCommand:ConfigCommand(cmd, not (settings.config[cmd]))
    end
	
	Help()
	
    return NilCommand:NilCommand()
end

function Help()
	local txt = [[
{ffxikeys commands}
  //keys use <key>  -  uses the specified key (wrap it in quotes)
  //keys printlinks  -  Toggle Printing Links
  //keys openlinks  -  Toggle Opening Links
  //keys logitems  -  Toggle Logging Items 
  //keys loop  -  Toggle Looping
{ffxikeys aliases}
  //usekeys and //usekeyssp -  Use SP Gobbie Key
  //usekeysab  -  Use Dial Key #AB
  //usekeysfo  -  Use Dial Key #FO
  //usekeysanv  -  Use Dial Key #ANV
]]
	windower.add_to_chat(100, txt)
end

return CommandFactory