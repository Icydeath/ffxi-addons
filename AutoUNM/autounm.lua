_addon.name = "autounm"
_addon.author = "Darkdoom/Uwu/Icy"
_addon.version = "3.2"
_addon.command = "unm"
_addon.commands = {'start', 'stop', 'status'}
_addon.language = 'English'

res = require 'resources'
packets = require 'packets'
files = require 'files'
texts = require 'texts'
config = require 'config'

require 'strings'
require 'actions'
require 'tables'
require 'sets'
require 'chat'
require 'pack'
require 'logger'

--Textbox defaults

default_settings = {}
default_settings.pos = {}
default_settings.pos.x = 144
default_settings.pos.y = 144
default_settings.text = {}
default_settings.text.font = 'Constantia'
default_settings.text.size = 12
default_settings.text.alpha = 255
default_settings.text.red = 100
default_settings.text.green = 200
default_settings.text.blue = 200
default_settings.text.set_stroke_width = 1
default_settings.bg = {}
default_settings.bg.alpha = 160
default_settings.bg.red = 3
default_settings.bg.green = 1
default_settings.bg.blue = 1
settings = config.load('data\\settings.xml',default_settings)

--Variables
Bot_Status = "None"
Char_Status = "None"
Current_Target = "None"
Junction_Status = "None"
UNM_Name = nil
Sparks = 0
Accolades = 0
Menu_Open = 0
In_Combat = 0
Spam_Delay = 1
Spam_Prevention = os.clock()
Inject_Protection = os.clock()
Menu_Protection = os.clock()
Prerender_Delay = os.clock()
Controller_Protection = os.clock()
Update_Protection = os.clock()
Junction_Delay = os.clock()
Status = 0
Running = false
text_box = texts.new(settings)

--Info and Display functions

function GetInfo()
	local GameInfo = windower.ffxi.get_info()
	local CharacterInfo = windower.ffxi.get_player()

	if GameInfo.logged_in == true then
		Menu_Open = GameInfo.menu_open
		In_Combat = CharacterInfo.in_combat
		Status = CharacterInfo.status
	elseif GameInfo.logged_in == false then

	end
end

function check_incoming_text(original)
  local org = original:lower()
	if org:find('sparks of eminence, and now possess a total of 99999') ~= nil then
		Bot_Status = "Sparks Capped"
		Running = false
	elseif org:find('one or more party/alliance members do not have the required') ~= nil then
		Bot_Status = "Out of Accolades"
		Running = false
	end
end

function DisplayBox()
	new_text = 
		(tostring(Bot_Status)) .. " [Bot Status]\n"
		.. (tostring(Junction_Status)) .. " [Junction Status]\n" 
		.. (tostring(Current_Target)) .. " [Current Target]\n"
		.. (tostring(Sparks)) .. " [Sparks of Eminence]\n"
		.. (tostring(Accolades)) .. " [Unity Accolades]\n"
		text_box:text(new_text)
		text_box:visible(true)
end
  
function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end  
 
function CurrencyUpdate()
	if os.clock() - Spam_Prevention > 5 then
		windower.packets.inject_outgoing(0x10f,'0000')
		Spam_Prevention = os.clock()
	end
end

windower.register_event("incoming chunk", function(id, data)
	if id == 0x113 then
		local p = packets.parse('incoming', data)
		Sparks = p['Sparks of Eminence']
		Accolades = p['Unity Accolades']
	end
end)  

function JunctionFinder()
	local Junction = windower.ffxi.get_mob_by_name('Ethereal Junction')
	local Mob = windower.ffxi.get_mob_by_name(UNM_Name)
	
	if os.clock() - Junction_Delay > 5 then
		Bot_Status = "Waiting for Respawn"
		if Junction.valid_target == true and Menu_Open == false then
			Junction_Status = "Spawned"
			Bot_Status = "Junction Spawned"
			
		elseif Junction.valid_target == false then    
			Bot_Status = "Waiting on Respawn"
			Junction_Status = "Despawned"
			Current_Target = "None"
			
		elseif Menu_Open == true then
			Bot_Status = "In Menu"    
		end
	end
end

function unm_command(...)
	if #arg > 3 then
		windower.add_to_chat(167, 'Invalid command. //unm help for valid options.')
		
	elseif arg[1] and arg[2] and arg[1]:lower() == 'mob' then
		UNM_Name = arg[2]
		windower.add_to_chat(200, 'UNM set to '..UNM_Name)
		
	elseif #arg == 1 and arg[1]:lower() == 'start' then
		if Running == false then
			Running = true
			windower.add_to_chat(200, 'UNM - START')
		else
			windower.add_to_chat(200, 'UNM is already running.')
		end

	elseif #arg == 1 and arg[1]:lower() == 'stop' then
		if Running == true then
			Running = false
			windower.add_to_chat(200, 'UNM - STOP')
		else
			windower.add_to_chat(200, 'UNM is not running.')
		end

	elseif #arg == 1 and arg[1]:lower() == 'help' then
		windower.add_to_chat(200, 'Available Options:')
		windower.add_to_chat(200, '  //unm start - turns on UNM and starts trying to spawn')
		windower.add_to_chat(200, '  //unm stop - turns off UNM')  
		windower.add_to_chat(200, '  //unm help - displays this text')
	end
end

windower.register_event('addon command', unm_command)
windower.register_event('incoming text', function(new, old)
	local info = windower.ffxi.get_info()
	if not info.logged_in then
		return
	else
		check_incoming_text(new)
	end
end)

----Main Bot functions
function Controller()
	if os.clock() - Controller_Protection > Spam_Delay then
		if In_Combat == true then
			Bot_Status = "In Combat"
			Junction_Status = "Despawned"
			
		elseif Junction_Status == "Despawned" then
			Target = windower.ffxi.get_mob_by_target('t')
			if Target ~= nil then
				Current_Target = Target.name
			end
			
			local p = windower.ffxi.get_player()
			if UNM_Name and p.status == 0 then
				EngageUnm()
			end
			
		elseif Bot_Status == "Junction Spawned" and In_Combat == false then
			OpenMenu()
		
		elseif Bot_Status == "In Menu" and In_Combat == false then
			Menu()
		end
		
		Controller_Protection = os.clock()
	end
end

function EngageUnm()
	local t = windower.ffxi.get_mob_by_name(UNM_Name)
	if t and t.hpp > 0 and Menu_Open == false and In_Combat == false then 
		verbose_msg('Engaging > '..t.name)
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=t.id,
			["Target Index"]=t.index,
			["Category"]=2,
			["Param"]=0,
			["_unknown1"]=0
		})
		packets.inject(packet)
	end
end

function OpenMenu()
	local Junction = windower.ffxi.get_mob_by_name('Ethereal Junction')
	if Junction then
		if os.clock() - Inject_Protection > 4 and Menu_Open == false and In_Combat == false then
			local p = packets.new('outgoing', 0x01A, {
				['Target'] = Junction.id,
				['Target Index'] = Junction.index,
			})    
			packets.inject(p)
			Bot_Status = "In Menu"
			Inject_Protection = os.clock()
		end
	end
end  

function Menu()
	if os.clock() - Menu_Protection > 2 and Menu_Open == true then
		windower.send_command('setkey enter down; wait 0.3; setkey enter up')
		windower.send_command('setkey up down; wait 0.3; setkey up up')
		windower.send_command('setkey enter down; wait 0.3; setkey enter up') 
		Menu_Protection = os.clock()      
	end
end

windower.register_event('prerender', function()  
	if Running == true then
		if os.clock() - Prerender_Delay > Spam_Delay then
			DisplayBox()
			CurrencyUpdate()
			GetInfo()
			JunctionFinder()
			Controller()
			Prerender_Delay = os.clock()
		end
	end
end)


