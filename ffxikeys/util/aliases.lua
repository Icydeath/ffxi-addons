--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Aliases = {}

--------------------------------------------------------------------------------
function Aliases.Update()
    windower.send_command('alias usekeys input //keys use "SP Gobbie Key"')
	windower.send_command('alias usekeyssp input //keys use "SP Gobbie Key"')
	windower.send_command('alias usekeysab input //keys use "Dial Key #Ab"')
	windower.send_command('alias usekeysfo input //keys use "Dial Key #Fo"')
	windower.send_command('alias usekeysanv input //keys use "Dial Key #ANV"')
end

return Aliases