--[[
 	Copyright © 2019, Renee Koecher
 	All rights reserved.
 
 	Redistribution and use in source and binary forms, with or without
 	modification, are permitted provided that the following conditions are met :
 
 	* Redistributions of source code must retain the above copyright
 	  notice, this list of conditions and the following disclaimer.
 	* Redistributions in binary form must reproduce the above copyright
 	  notice, this list of conditions and the following disclaimer in the
 	  documentation and/or other materials provided with the distribution.
 	* Neither the name of XIPivot nor the
 	  names of its contributors may be used to endorse or promote products
 	  derived from this software without specific prior written permission.
 
 	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 	DISCLAIMED.IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'XIPivot'
_addon.author = 'Heals'
_addon.version = '0.2.0'
_addon.command = 'pivot'

config = require('config')
require('pack')
require('lists')

-- package.cpath somehow doesn't appreciate backslashes
local addon_path = windower.addon_path:gsub('\\', '/')

defaults = T{}
defaults.root_path = addon_path .. 'data/DATs'
defaults.overlays  = L{}

settings = config.load(defaults)
config.save(settings, 'all')
	
package.cpath = package.cpath .. ';' .. addon_path .. '/libs/?.dll'
require('_XIPivot')

config.register(settings, function(_settings)
	_XIPivot.disable()
	-- try to unload any active overlays in case this is not the first call
	for _,overlay in ipairs(_XIPivot.diagnostics()['overlays']) do
		_XIPivot.remove_overlay(overlay)
	end

	-- setup things
	_XIPivot.set_root_path(_settings.root_path)
	for i,path in ipairs(_settings.overlays) do
		if _XIPivot.add_overlay(path) == false then
			windower.add_to_chat(8, 'failed to register overlay "' .. path .. '"')
		end
	end

	-- and finally (re)enable
	_XIPivot.enable()
end)

windower.register_event('unload', function()
	_XIPivot.disable()
end)

windower.register_event('addon command', function(command, ...)
	command = command and command:lower() or 'help'
	local args = L{...}

	if command == 'help' or command == 'h' then
		windower.add_to_chat(8, _addon.name .. ' v.' .. _addon.version)
		windower.add_to_chat(8, '   add overlay_dir - Adds a path to be searched for DAT overlays')
		windower.add_to_chat(8, '   remove overlay_dir - Removes a path from the DAT overlays')
		windower.add_to_chat(8, '   status - Print status and diagnostic info')

	elseif command == 'add' or command == 'a' then
		if not args[1] then
			error('Invalid syntax: //pivot add <relative overlay path>')
			return
		end

		if _XIPivot.add_overlay(args[1]) == true then
			list.append(settings.overlays, args[1])
			config.save(settings)
		else
			windower.add_to_chat(8, 'failed to add "' .. args[1] .. '"')
		end
	elseif command == 'remove' or command == 'r' then
		if not args[1] then
			error('Invalid syntax: //pivot remove <relative overlay path>')
			return
		end

		_XIPivot.remove_overlay(args[1])
		for i,path in ipairs(settings.overlays) do
			if path == args[1] then
				list.remove(settings.overlays, i)
				break
			end
		end
		config.save(settings)

	elseif command == 'status' or command == 's' then
		local stats = _XIPivot.diagnostics()
		windower.add_to_chat(127,'- diagnostics')
		if stats['enabled'] then
			windower.add_to_chat(127, '-  enabled  : true')
		else
			windower.add_to_chat(127'-  enabled  : false')
		end
		windower.add_to_chat(127, '-  root_path: "' .. stats['root_path'] .. '"')
		windower.add_to_chat(127, '-  overlays :')
		for prio, path in ipairs(stats['overlays']) do
			windower.add_to_chat(127, '-      [' .. prio .. ']: ' .. path)
		end
	end
end)

