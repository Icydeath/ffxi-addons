--[[
Copyright © 2019, Icydeath
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of AutoPUP nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Icydeath BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.author = 'Icy'
_addon.name = 'WarpMenu'
_addon.commands = {'warpmenu', 'wm'}
_addon.version = '1.0.0.0'

require('pack')
require('lists')
require('tables')
require('strings')
texts = require('texts')
config = require('config')

default = {
	warps = L{'[ WINDOW 1 ]', 'Eastern Adoulin 2', 'Port Jeuno 2', 'Northern San d\'Oria 2'},
	warps2 = L{'[ WINDOW 2 ]','Western Adoulin 1', 'Mhaura 1', 'Windurst Walls 1'},
	warpall = true,
	box = { pos={x=10,y=402},text={font='Segoe UI Symbol',size=10,Fonts={'sans-serif'},},bg={alpha=255} },
	box2 = { pos={x=155,y=402},text={font='Segoe UI Symbol',size=10,Fonts={'sans-serif'},},bg={alpha=255} }
}

settings = config.load(default)
window = texts.new(settings.box)
window2 = texts.new(settings.box2)

function initialize()
	window:append(settings.warps:concat('\n'))
	window:show()
	
	window2:append(settings.warps2:concat('\n'))
	window2:show()
	
	windower.send_command('lua l superwarp')
end

windower.register_event('mouse', function(type, x, y, delta, blocked)
    local mx, my = texts.extents(window)
	local mx2, my2 = texts.extents(window2)
	
    local button_lines = window:text():count('\n') + 1 
	local button_lines2 = window2:text():count('\n') + 1 
    
	local hx = (x - settings.box.pos.x)
	local hx2 = (x - settings.box2.pos.x)
	
    local hy = (y - settings.box.pos.y)
	local hy2 = (y - settings.box2.pos.y)
	
    local location = {}
	local location2 = {}
	
    location.offset = my / button_lines
	location2.offset = my2 / button_lines2
	
    location[1] = {}
	location2[1] = {}
	
	location[1].ya = 1
    location2[1].ya = 1
	
    location[1].yb = location.offset
	location2[1].yb = location2.offset
	
    local count = 2
    while count <= button_lines do
         location[count] = {}
         location[count].ya = location[count - 1].yb
         location[count].yb = location[count - 1].yb + location.offset
         count = count + 1
    end
	
	count = 2
	while count <= button_lines2 do
         location2[count] = {}
         location2[count].ya = location2[count - 1].yb
         location2[count].yb = location2[count - 1].yb + location2.offset
         count = count + 1
    end
	
	if type == 2 then
        if window:hover(x, y) and window:visible() then
            for i, v in ipairs(location) do
                local switch = {}
				for cnt = 1, #settings.warps do
				  switch[cnt] = settings.warps[cnt]
				end
                if hy > location[i].ya and hy < location[i].yb then
					if switch[i] == "[ WINDOW 1 ]" then return end
					if settings.warpall == true then
						if string.match(switch[i], '%d') then
							windower.send_command("sw hp warp all "..switch[i])
						else
							windower.send_command("sw sg warp all "..switch[i])
						end
						return
					else
						if string.match(switch[i], '%d') then
							windower.send_command("sw hp warp "..switch[i])
						else
							windower.send_command("sw sg warp "..switch[i])
						end
						return
					end
                end
			end
		end
		
		if window2:hover(x, y) and window2:visible() then
			for i, v in ipairs(location2) do
				local switch = {}
				for cnt = 1, #settings.warps2 do
				  switch[cnt] = settings.warps2[cnt]
				end
				if hy2 > location2[i].ya and hy2 < location2[i].yb then
					if switch[i] == "[ WINDOW 2 ]" then return end
					if settings.warpall == true then
						if string.match(switch[i], '%d') then
							windower.send_command("sw hp warp all "..switch[i])
						else
							windower.send_command("sw sg warp all "..switch[i])
						end
						return
					else
						if string.match(switch[i], '%d') then
							windower.send_command("sw hp warp "..switch[i])
						else
							windower.send_command("sw sg warp "..switch[i])
						end
						return
					end
                end
            end
        end
    end
end)

function save_settings()
	settings:save()
	windower.add_to_chat(200, 'WarpMenu: saved settings')
	
	windower.send_command('lua r WarpMenu')
end

windower.register_event('addon command', function(...)
    local commands = {...}
    commands[1] = commands[1] and commands[1]:lower()
    if commands[1] == 'save' then
        save_settings()
	elseif commands[1] == 'reset' then
        settings = default
		save_settings()
	elseif commands[1] == 'warpall' then
        if settings.warpall then settings.warpall = false else settings.warpall = true end	
		windower.add_to_chat(200, 'WarpMenu: warpall = '..(settings.warpall and 'true' or 'false'))
		save_settings()
	elseif commands[1] == 'win' or commands[1] == 'win1' or commands[1] == 'window' or commands[1] == 'window1' then
		if commands[2] == 'a' or commands[2] == 'add' then
			local origCmd = commands[3]
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] and commands[4] then
				commands[4] = windower.convert_auto_trans(commands[4])
				for x = 4,#commands do commands[x] = commands[x]:ucfirst() end
				commands[4] = table.concat(commands, ' ', 4)
				
				settings.warps:append(commands[4]..' '..commands[3])
				save_settings()
			elseif origCmd then
				commands[3] = windower.convert_auto_trans(origCmd)
				for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
				commands[3] = table.concat(commands, ' ', 3)
				
				settings.warps:append(commands[3])
				save_settings()
			end
		elseif commands[2] == 'r' or commands[2] == 'remove' then
			local origCmd = commands[3]
			if commands[3] and commands[4] then
				commands[4] = windower.convert_auto_trans(commands[4])
				for x = 4,#commands do commands[x] = commands[x]:ucfirst() end
				commands[4] = table.concat(commands, ' ', 4)
				
				local index = 1;
				for cnt = 1, #settings.warps do
					if settings.warps[cnt] == (commands[4]..' '..commands[3]) then
						index = cnt
						break
					end
				end
				settings.warps:remove(index)
				save_settings()
			elseif origCmd then
				commands[3] = windower.convert_auto_trans(origCmd)
				for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
				commands[3] = table.concat(commands, ' ', 3)
				
				local index = 1;
				for cnt = 1, #settings.warps do
					if settings.warps[cnt] == (commands[3]) then
						index = cnt
						break
					end
				end
				settings.warps:remove(index)
				save_settings()
			end
		elseif commands[2] == 'x' then
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] then
				settings.box.pos.x = commands[3]
				save_settings()
			end
		elseif commands[2] == 'y' then 
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] then
				settings.box.pos.y = commands[3]
				save_settings()
			end
		end
	elseif commands[1] == 'win2' or commands[1] == 'window2' then
		if commands[2] == 'a' or commands[2] == 'add' then
			local origCmd = commands[3]
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] and commands[4] then
				commands[4] = windower.convert_auto_trans(commands[4])
				for x = 4,#commands do commands[x] = commands[x]:ucfirst() end
				commands[4] = table.concat(commands, ' ', 4)
				
				settings.warps2:append(commands[4]..' '..commands[3])
				save_settings()
			elseif origCmd then
				commands[3] = windower.convert_auto_trans(origCmd)
				for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
				commands[3] = table.concat(commands, ' ', 3)
				
				settings.warps2:append(commands[3])
				save_settings()
			end
		elseif commands[2] == 'r' or commands[2] == 'remove' then
			local origCmd = commands[3]
			if commands[3] and commands[4] then
				commands[4] = windower.convert_auto_trans(commands[4])
				for x = 4,#commands do commands[x] = commands[x]:ucfirst() end
				commands[4] = table.concat(commands, ' ', 4)
				
				local index = 1;
				for cnt = 1, #settings.warps2 do
					if settings.warps2[cnt] == (commands[4]..' '..commands[3]) then
						index = cnt
						break
					end
				end
				settings.warps2:remove(index)
				save_settings()
			elseif origCmd then
				commands[3] = windower.convert_auto_trans(origCmd)
				for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
				commands[3] = table.concat(commands, ' ', 3)
				
				local index = 1;
				for cnt = 1, #settings.warps2 do
					if settings.warps2[cnt] == (commands[3]) then
						index = cnt
						break
					end
				end
				settings.warps2:remove(index)
				save_settings()
			end
		elseif commands[2] == 'x' then
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] then
				settings.box2.pos.x = commands[3]
				save_settings()
			end
		elseif commands[2] == 'y' then 
			commands[3] = commands[3] and tonumber(commands[3])
			if commands[3] then
				settings.box2.pos.y = commands[3]
				save_settings()
			end
		end
	else
		showhelp()
    end
end)

function showhelp()
	windower.add_to_chat(205, '~~~~~~~~~~~~~ WarpMenu ~~~~~~~~~~~~~')
	windower.add_to_chat(203, '====================================')
	windower.add_to_chat(203, ' *NOTICE* Requires addon: superwarp')
	windower.add_to_chat(203, '====================================')
	windower.add_to_chat(205, '[warpmenu|wm] [window#|win#] [a|add|r|remove] [hp#] [zone name]')
	
	windower.add_to_chat(202, '  > auto translated zone names is acceptable')
	windower.add_to_chat(202, '  > you can move the windows by dragging the windows header [ WINDOW # ],')
	windower.add_to_chat(202, '     then use "//wm save" when done.')
	
	windower.add_to_chat(207, 'ADDING|REMOVING HOMEPOINT WARP TO WINDOW')
	windower.add_to_chat(205, '  //wm window1 add 2 lower jeuno')
	windower.add_to_chat(205, '  //wm window2 remove 1 western adoulin')
	windower.add_to_chat(207, 'ADDING|REMOVING SURVIVAL GUIDE WARP TO WINDOW')
	windower.add_to_chat(205, '  //wm win1 a gusgen mines')
	windower.add_to_chat(205, '  //wm win1 r gusgen mines')
	windower.add_to_chat(207, 'TOGGLE WARPALL')
	windower.add_to_chat(205, '  //wm warpall')
	windower.add_to_chat(207, 'SETTINGS [...\\WarpMenu\\data\\settings.xml]')
	windower.add_to_chat(205, '  //wm save')
end

windower.register_event('load', function()
	initialize()
end)