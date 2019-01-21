--[[Copyright © 2016, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of InvSpace nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Kenshi BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'InvSpace'
_addon.author = 'Kenshi'
_addon.version = '3.0'


require('luau')
texts = require('texts')

-- Config

defaults = {}
defaults.ShowInventory = true
defaults.ShowSatchel = false
defaults.ShowSack = false
defaults.ShowCase = false
defaults.ShowWardrobe = false
defaults.ShowWardrobe2 = false
defaults.ShowWardrobe3 = false
defaults.ShowWardrobe4 = false
defaults.ShowSafe = false
defaults.ShowSafe2 = false
defaults.ShowStorage = false
defaults.ShowLocker = false
defaults.ShowTemporary = false
defaults.ShowGil = false
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.bg.visible = false
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 10
defaults.display.text.stroke = {}
defaults.display.text.stroke.width = 2
defaults.display.text.stroke.alpha = 255
defaults.display.text.stroke.red = 0
defaults.display.text.stroke.green = 0
defaults.display.text.stroke.blue = 0

settings = config.load(defaults)

bags_text = texts.new(settings.display, settings)

local bag_names = T{'Inventory', 'Satchel', 'Sack', 'Case', 'Wardrobe', 'Wardrobe2', 'Wardrobe3', 'Wardrobe4', 'Safe', 'Safe2', 'Storage', 'Locker', 'Temporary'}
for i = 1, 13 do
    if defaults['Show'..bag_names[i]] then
        bags_text:appendline(' ${current_'..i..'|0}${max_'..i..'|0}${diff_'..i..'|0}')
    end
end
--bags_text:appendline(' ${gil|0}')

-- Function to comma the gils

function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

windower.register_event('incoming chunk',function(id)
    if id == 0xB and bags_text:visible() then
        zoning_bool = true
    elseif id == 0xA and zoning_bool then
        zoning_bool = nil
    end
end)

-- Events

windower.register_event('prerender', function()
    local bags = windower.ffxi.get_bag_info()
    local giles = windower.ffxi.get_items().gil
    if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_player() then
        bags_text:hide()
        return
    end
    if zoning_bool then
        bags_text:hide()
        return
    else
        local info = S{}
        for i = 1, 13 do
            local color = bags[bag_names[i]:lower()].max - bags[bag_names[i]:lower()].count
            info['current_'..i] = (
                color == 0 and
                    '\\cs(255,0,0)' .. ((bag_names[i]..': '):rpad(' ', 11)..bags[bag_names[i]:lower()].count:string():lpad(' ', 2))
                or color > 10 and
                    '\\cs(0,255,0)' .. ((bag_names[i]..': '):rpad(' ', 11)..bags[bag_names[i]:lower()].count:string():lpad(' ', 2))
                or 
                    '\\cs(255,128,0)' .. ((bag_names[i]..': '):rpad(' ', 11)..bags[bag_names[i]:lower()].count:string():lpad(' ', 2))).. '\\cr'
            info['max_'..i] = (
                color == 0 and
                    '\\cs(255,0,0)' .. ('/'..bags[bag_names[i]:lower()].max:string():lpad(' ', 2))
                or color > 10 and
                    '\\cs(0,255,0)' .. ('/'..bags[bag_names[i]:lower()].max:string():lpad(' ', 2))
                or 
                    '\\cs(255,128,0)' .. ('/'..bags[bag_names[i]:lower()].max:string():lpad(' ', 2))) .. '\\cr'
            info['diff_'..i] = (
                color == 0 and
                    '\\cs(255,0,0)' .. (' → ' .. (bags[bag_names[i]:lower()].max - bags[bag_names[i]:lower()].count):string():lpad(' ', 2))
                or color > 10 and
                    '\\cs(0,255,0)' .. (' → ' .. (bags[bag_names[i]:lower()].max - bags[bag_names[i]:lower()].count):string():lpad(' ', 2))
                or 
                    '\\cs(255,128,0)' .. (' → '.. (bags[bag_names[i]:lower()].max - bags[bag_names[i]:lower()].count):string():lpad(' ', 2))) .. '\\cr'
        end
        if ShowGil then
			local gil = comma_value(giles)
			info.gil = (
				comma_value(giles) == 0 and
					'\\cs(255,0,0)' .. ('Gil: ' .. comma_value(giles):lpad(' ', 16))
				or
					'\\cs(255,255,0)' .. ('Gil: ' .. comma_value(giles):lpad(' ', 16))) .. '\\cr'
		end
        bags_text:update(info)
        bags_text:show()
    end
end)