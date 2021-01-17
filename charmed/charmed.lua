-- modified from TParty.lua by wes (v0.3)
-- modded by icy(v0.3i): Now shows charm image(data/icons/17.png) instead of textbox

_addon.name = 'charmed'
_addon.author = 'wes, mod by icy'
_addon.version = '0.3i'

require('sets')
require('functions')
require('lists')
require('strings')
images = require('images')

test_display = false -- set to true to test the icons.

charm_icon = string.format('%s/data/icons/%s.png', windower.addon_path, '17')

alliance = T{}
new_charms = L{}
new_uncharms = L{}

-- only update every <interval> seconds
interval = 0.5

local x_pos = windower.get_windower_settings().ui_x_res - 17
local y_pos = windower.get_windower_settings().ui_y_res + 2

for i = 0, 17 do
    local party = (i / 6):floor() + 1
    local key = {'p%i', 'a1%i', 'a2%i'}[party]:format(i % 6)
    local pos_base = {-42, -397, -296}
    alliance[key] = T{
        x = x_pos,
        y = pos_base[party] + 16 * (i % 6),
        box = nil,
		img = nil
    }
end

key_indices = {p0 = 1, p1 = 2, p2 = 3, p3 = 4, p4 = 5, p5 = 6}
pt_y_pos = {}
for i = 1, 6 do
    pt_y_pos[i] = -42 - 20 * (6 - i)
end

function update()
    local party = T(windower.ffxi.get_party())
    new_charms:clear()
    new_uncharms:clear()

    for slot, key in alliance:it() do
        local member = party[key]
        if member and member.mob and member.mob.valid_target then
            if test_display or (member.mob.charmed and not member.mob.is_npc) then
                -- Adjust position for party member count
                if key:startswith('p') then
                    slot.y = pt_y_pos[key_indices[key] + 6 - party.party1_count]
                end
				
				if slot.img == nil then
					slot.img = images.new({ draggable = false, visible = false })
					slot.img:path(charm_icon)
					slot.img:pos(slot.x, y_pos + slot.y)
					slot.img:fit(false)
					slot.img:size(15, 15)
					slot.img:show()
					new_charms:append(member.name)
				else 
					slot.img:pos(slot.x, y_pos + slot.y)
				end
            else
				if slot.img ~= nil then
					slot.img:hide()
					slot.img:destroy()
					slot.img = nil
					new_uncharms:append(member.name)
				end
            end
        else
			if slot.img ~= nil then
				slot.img:hide()
                slot.img:destroy()
				slot.img = nil
			end
        end
    end
    if not new_charms:empty() then
        windower.add_to_chat(123, 'CHARM <3 CHARM <3 CHARM <3 CHARM <3 CHARM')
        windower.add_to_chat(123, '  ' .. new_charms:sort():concat(', '))
        windower.add_to_chat(123, 'CHARM <3 CHARM <3 CHARM <3 CHARM <3 CHARM')
    end
    if not new_uncharms:empty() then
        windower.add_to_chat(121, 'uncharmed: ' .. new_uncharms:sort():concat(' '))
    end
end

update_thread = update:loop(interval)
