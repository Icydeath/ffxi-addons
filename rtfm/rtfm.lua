--[[
Read The Fucking Move - rtfm

-Register mob abilities as they happen
-Display mob abilities in text box
-Indicate damage potential and critial status ailments
-Display other notes regarding mob ability



Copyright © 2020, Rialya
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of rtfm nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Rialya BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--


_addon.name    = 'rtfm'
_addon.author  = 'rialya'
_addon.version = '0.1.1'
_addon.command = 'rtfm'
_addon.commands = {'help'}

tables = require('tables')
res = require('resources')
texts = require('texts')
config = require('config')

local default_settings = T{}
default_settings.font_size = 10
default_settings.font = 'Verdana'
default_settings.bg_alpha = 255
default_settings.pos_x = 200
default_settings.pos_y = 700


settings = config.load(default_settings)

recent_move_table = {'---', '---', '---', '---', '---', '---'}

mobmove_box = texts.new("mobmove_box")
str = 'Recent Mob Moves: \n${fifth_recent_move|---}\n${fourth_recent_move|---}\n${third_recent_move|---}\n${second_recent_move|---}\n${first_recent_move|---}\n\nIncoming Move:\n${incoming_move|---}'

texts.size(mobmove_box, settings.font_size)
texts.font(mobmove_box, settings.font)
texts.bg_alpha(mobmove_box, settings.bg_alpha)
texts.pos(mobmove_box, settings.pos_x, settings.pos_y)

mobmove_box:text(str)
mobmove_box:show()

function help_commands()
	print('RTFM COMMANDS')
	print('rtfm alpha # : change transparency 0 to 255 (higher value = more opaque)')
end


windower.register_event('addon command', function (command, ...)
	local params = {...}

	if command == 'help' then
		help_commands()

	elseif command == 'alpha' then
		settings.bg_alpha = tonumber(params[1])
		settings:save()
		texts.bg_alpha(mobmove_box, settings.bg_alpha)
		print('alpha set to ' .. settings.bg_alpha)
	else
		help_commands()
	end
	

end)
windower.register_event('action', function(act)
	local actor = windower.ffxi.get_mob_by_id(act.actor_id)
	local targets = act.targets
	--local self = windower.ffxi.get_player()
	if actor.spawn_type == 16 then --check if actor is an enemy (16)
		if (act['category'] == 7  or act['category'] == 8) and act['param'] == 24931 and (windower.ffxi.get_mob_by_id(act.targets[1].id).in_alliance == true or windower.ffxi.get_mob_by_id(act.targets[1].id).name == actor.name) then --check for spell/ability initiation
			recent_move_table[6] = recent_move_table[5]
			recent_move_table[5] = recent_move_table[4]
			recent_move_table[4] = recent_move_table[3]
			recent_move_table[3] = recent_move_table[2]
			recent_move_table[2] = recent_move_table[1]
			if act['category'] == 7 then --check if monster is using tp move
				recent_move_table[1] = ('%s -> %s -> %s':format(actor.name, res.monster_abilities[targets[1].actions[1].param].en, windower.ffxi.get_mob_by_id(act.targets[1].id).name))
			elseif act['category'] == 8 then --check if monster is casting spell
				recent_move_table[1] = ('%s -> %s -> %s':format(actor.name, res.spells[targets[1].actions[1].param].en, windower.ffxi.get_mob_by_id(act.targets[1].id).name))
			end
			mobmove_box.incoming_move = recent_move_table[1]
			mobmove_box.first_recent_move = recent_move_table[2]
			mobmove_box.second_recent_move = recent_move_table[3]
			mobmove_box.third_recent_move = recent_move_table[4]
			mobmove_box.fourth_recent_move = recent_move_table[5]
			mobmove_box.fifth_recent_move = recent_move_table[6]
			windower.play_sound(windower.addon_path..'sounds_alert/default_alert.wav')
		end
	end
end)
