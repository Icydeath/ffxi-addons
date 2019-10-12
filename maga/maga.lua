-- Copyright © 2017, Cair
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of MAGA nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cair BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'MAGA'
_addon.author = 'Cair'
_addon.commands = {'MAGA'}
_addon.version = '1.0.0.4'

packets = require('packets')
texts = require('texts')
config = require('config')
extdata = require('extdata')
require('logger')


defaults = {
	delay = .75,
	debug = false,
	pellucid = true,
	taupe = true,
	fern = true,
	style = "",
	profiles = {
		default = {}
	}
}
history = L{}
augments = L{{}}

defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.size = 10
defaults.display.text.alpha = 255
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.bg = {}
defaults.display.bg.alpha = 192
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.padding = 3

text_base_string = L{
    'Augment #: ${_index|-}',
    '${_augment|-}',
    }:concat('\n')
    
settings = config.load(defaults)

maga_tb = texts.new(text_base_string,settings.display)
maga_tb._index = history:length()
maga_tb._augment = nil

maga_tb:show()

status = {

taupe = 0,
fern = 0,
pellucid = 0,
gear = nil,
paused = false,
finished = false,
waiting_for_augment = false
}

constants = {
    style = {["melee"] = 0x0008, ["ranged"] = 0x0108, ["magic"] = 0x0208, ["familiar"] = 0x0308, ["healing"] = 0x0408},
    stone = {["pellucid"] = 0x0000, ["fern"] = 0x0001, ["taupe"] = 0x0002},
    gear = {
        [0] = L{"melee","magic"},
        [1] = L{"melee","magic"},
        [2] = L{"melee","magic"},
        [3] = L{"melee","magic"},
        [4] = L{"melee","magic"},
        [5] = L{"melee","familiar"},
        [6] = L{"melee","familiar"},
        [7] = L{"melee","familiar"},
        [8] = L{"melee","familiar"},
        [9] = L{"melee","familiar"},
        [10] = L{"melee","ranged","magic","familiar"},
        [11] = L{"melee","ranged","magic","familiar"},
        [12] = L{"melee","ranged","magic","familiar"},
        [13] = L{"melee","ranged","magic","familiar"},
        [14] = L{"melee","ranged","magic","familiar"},
        [15] = L{"magic", "familiar"},
        [16] = L{"magic", "familiar"},
        [17] = L{"magic", "familiar"},
        [18] = L{"magic", "familiar"},
        [19] = L{"magic", "familiar"},
        [20] = L{"melee", "healing"},
        [21] = L{"melee", "healing"},
        [22] = L{"melee", "healing"},
        [23] = L{"melee", "healing"},
        [24] = L{"melee", "healing"},
        [25] = L{"melee", "familiar"},
        [26] = L{"melee", "magic"},
        [27] = L{"melee", "magic"},
        [28] = L{"melee"},
        [29] = L{"melee", "familiar"},
        [30] = L{"melee"},
        [31] = L{"melee"},
        [32] = L{"melee"},
        [33] = L{"melee"},
        [34] = L{"melee"},
        [35] = L{"melee", "magic"},
        [36] = L{"magic", "familiar"},
        [37] = L{"ranged"},
        [38] = L{"ranged"},
    }
}

windower.register_event('incoming chunk', function(id,data)
    if id == 0x34 then
        local p = packets.parse('incoming',data)
        
        local mob = windower.ffxi.get_mob_by_index(p['NPC Index'])
        
        if mob and mob.name == "Oseem" then
        
            status.pellucid = p['Menu Parameters']:byte(1)
            status.fern = p['Menu Parameters']:byte(2)
            status.taupe = p['Menu Parameters']:byte(3)
            
            if p['Menu ID'] == 9507 then
                status.gear = p['Menu Parameters']:byte(5)
                warning('The menu has been disabled for trading. If you attempt to act without first exiting this interaction appropriately, you may soft lock!')
                notice('Type //maga style [magic|melee|familiar|healing|ranged] to select an augmentation style.')
                notice('Type //maga start to begin augmenting.')
                notice('Type //maga stop to stop at any time.')
                return true
            
            end
        end
    elseif id == 0x5c and status.gear and status.waiting_for_augment then
        status.waiting_for_augment = false
        
        local p = packets.parse('incoming', data)
        
        local newAugs = p['Menu Parameters']:sub(21)
        local results = extdata.decode(newAugs)
        
        history:append(results)
        update_display()
        
        if compare_augments(results) then
			windower.play_sound(windower.addon_path..'sounds/chime.wav')
            notice("Stopped augmenting for the following: ")
            for k,v in pairs(results) do
                log(k .. ' ' .. v)
            end
            notice("Type //maga accept, //maga continue, or //maga cancel.")
        elseif settings.debug then
            notice("Didn't match the following: ")
            for k,v in pairs(results) do
                log(k .. ' ' .. v)
            end
        else
            status.paused = false
        end
    end
end)

function update_display(index)
    if not index then
        index = history:length()
    end
    
    maga_tb._index = index
    maga_tb._augment = history[tonumber(index)]

end

function compare_augments(comparison)

    local result = false

    for augment_set in augments:it() do 
        result = result or compare_augment_set(augment_set,comparison)
    end
    
    return result

end

function compare_augment_set(augment_set,comparison)
        
    for k,v in pairs(augment_set) do
    
        if not comparison:containskey(k) then
            return false
        else
            local val = comparison[k]
            
            if val >= 0 then
                if val < v then
                    return false
                end
            else
                if val > v then
                    return false
                end
            end
    
        end
    
    end

    return true

end


function start(style)
    if status.started then
        error('You have already started an augmentation process.')
        return
    end

        
    if not status.gear then return end
    
    status.started = true

    if style and L{"melee","magic","familiar","ranged","healing"}:contains(style:lower()) then
        settings.style = style:lower()
    end

    status.finished = false
    status.paused = false
    
    notice("Starting augmentation process (%s)!":format(settings.style))
    notice("Pellucid [%s], Fern [%s], Taupe [%s]":format(tostring(settings.pellucid), tostring(settings.fern), tostring(settings.taupe)))
    
    while true do
        if status.finished then break end
    
        if not status.paused then
            if constants.gear[status.gear]:contains(settings.style) then 
                
                if settings.pellucid and status.pellucid > 0 then
                    if status.pellucid % 25 == 0 then notice("Stones remaining: Pellucid[%d], Fern[%d], Taupe[%d]":format(status.pellucid, status.fern, status.taupe)) end
                    internal_augment(settings.style, "pellucid")
                elseif settings.fern and status.fern > 0 then
                    if status.fern % 25 == 0 then notice("Stones remaining: Pellucid[%d], Fern[%d], Taupe[%d]":format(status.pellucid, status.fern, status.taupe)) end
                    internal_augment(settings.style, "fern")
                elseif settings.taupe and status.taupe > 0 then
                    if status.taupe % 25 == 0 then notice("Stones remaining: Pellucid[%d], Fern[%d], Taupe[%d]":format(status.pellucid, status.fern, status.taupe)) end
                    internal_augment(settings.style, "taupe")
                else
					windower.play_sound(windower.addon_path..'sounds/doublebass.wav')
                    notice("You ran out of stones!")
                    cancel()
                    break
                end            
                coroutine.sleep(settings.delay)
            else
                notice("The selected gear cannot be augmented with : ".. settings.style ..'. Choose a valid style and start again.')
                cancel()
                break
            end
        else
            coroutine.sleep(.5)
        end
    end
    
    status.started = false

end

function stop()
    notice("Stopping augmentation process! Type //maga cancel to receive your original item or //maga accept to receive the most recent augment.")
    status.finished = true
end

function internal_augment(style,stone)
    
    if not style or not stone then error("Function augment(style,stone) was missing one or more arguments.") return false end
    
    local a = constants.style[style]
    local b = constants.stone[stone]
    
    if not settings.debug then
        if not status.gear then error("No gear has been traded. How did you get here?") return false end
        if not constants.gear[status.gear]:contains(style) then error("That augment style is not supported by this type of armor.") return false end
        if status[stone] <= 0 then error("You do not have enough of that type of stone") return false end
        if not a or not b then error("The selected augment style or stone were invalid.") return false end
    end
    
    status.paused = true
    status.waiting_for_augment = true
    
    status[stone] = status[stone] - 1
    
    local inject = packets.new("outgoing", 0x5b, {
                ['Target'] = 17809550,
                ['Option Index'] = a,
                ['_unknown1'] = b,
                ['Target Index'] = 142,
                ['Automated Message'] = true,
                ['Zone'] = 252,
                ['Menu ID'] = 9507
    })
            
    packets.inject(inject)
    return true

end

function continue()
    status.paused = false
end

function cancel()
    status.finished = true

    if status.gear then 
        status.gear = nil
    
        local inject = packets.new("outgoing", 0x5b, {
                ['Target'] = 17809550,
                ['Option Index'] = 0x0000,
                ['_unknown1'] = 0x4000,
                ['Target Index'] = 142,
                ['Automated Message'] = false,
                ['Zone'] = 252,
                ['Menu ID'] = 9507
            })
        packets.inject(inject)

        notice("Your item has been returned to you unchanged.")
    end

end

function accept()
    status.finished = true
    
    if status.gear then 
        status.gear = nil
    
        notice("Accepting the most recently obtained augment...")

        local inject = packets.new("outgoing", 0x5b, {
                ['Target'] = 17809550,
                ['Option Index'] = 0x0009,
                ['_unknown1'] = 0x0000,
                ['Target Index'] = 142,
                ['Automated Message'] = false,
                ['Zone'] = 252,
                ['Menu ID'] = 9507
            })
        packets.inject(inject)
    
    end
    
end

function pellucid(bool)

    if bool then
        if L{"true","t","yes","y"}:contains(bool) then
            settings.pellucid = true
        elseif L{"false","f","no","n"}:contains(bool) then
            settings.pellucid = false
        end
    else
        settings.pellucid = not settings.pellucid
    end
    
    notice("Using pellucid stones: %s":format(tostring(settings.pellucid)))
    
    settings:save('all')
end

function fern(bool)

    if bool then
        if L{"true","t","yes","y"}:contains(bool) then
            settings.fern = true
        elseif L{"false","f","no","n"}:contains(bool) then
            settings.fern = false
        end
    else
        settings.fern = not settings.fern
    end
    
    notice("Using fern stones: %s":format(tostring(settings.fern)))
    
    settings:save('all')
end

function taupe(bool)

    if bool then
        if L{"true","t","yes","y"}:contains(bool) then
            settings.taupe = true
        elseif L{"false","f","no","n"}:contains(bool) then
            settings.taupe = false
        end
    else
        settings.taupe = not settings.taupe
    end
    
    notice("Using taupe stones: %s":format(tostring(settings.taupe)))
    
    settings:save('all')
end

function style(str)
    
    str = str and str:lower() or ""
    
    if L{"melee","magic","familiar","ranged","healing"}:contains(str) then
        settings.style = str
        notice("Using augmentation style : %s":format(str))
    else
        error("Please specify one of the valid augmenting styles: [magic,melee,familiar,ranged,healing]")
    end
    
    settings:save('all')

end

function search(str)

    str = str or ""

    local augs = extdata.search_aug(str:lower())
    
    notice("Matched the following augments: " .. augs:concat(", "))
    

end

function add_aug(aug,val,set)
    
    if not augments[set] then error('Augment set #%d does not currently exist.':format(set)) return end

    if augments:length() >= 6 and not augments:containskey(aug) then
        error("No more than 6 augments can be compared.")
    else
        augments[set][aug] = val
        notice("Augment Set #%d : [%s] = %s":format(set,aug,val))
    end

end

function display()
    
    local count = 1
    
    for augment_set in augments:it() do
    
    log("Augment set #%d: ":format(count))
    
        for k,v in pairs(augment_set) do
            log(' * ' .. k , v)
        end
        
    count = count + 1
    
    end

end

function add(aug,minval,set)
    set = set and tonumber(set) or 1
    aug = aug and aug:lower() or ""
    minval = minval and tonumber(minval) or 0
    
    if extdata.match(aug) then
        add_aug(aug,minval,set)
    else
        error("The specified augment was not found.")
    end    

end

function remove(aug, set)

    set = set and tonumber(set) or 1
    aug = aug and aug:lower() or ""
    
    if augments[set] then
        if augments[set][aug] then
            augments[set][aug] = nil
            notice("%s removed from the augment list.":format(aug))
        end
    end

end

function newset()

    augments:append({})
    notice("Added augment set #%d":format(augments:length()))

end

function delset(num)
    
    num = num and tonumber(num) or nil
    
    if not num then
    
    elseif num > augments:length() or num ==  1 then
    
    else
        augments:delete(num)
        notice('Deleted augments set #%d.':format(num))
    end


end

local helpers = {}

function helpers.to_xml_table(tab)

    local rettab = {}
    
    for t in tab:it() do
        local inner = {}
        for k,v in pairs(t) do
            inner[#inner + 1] = { name = k, val = v}
        end
        rettab[#rettab + 1] = inner
    end

    return rettab
end

function helpers.from_xml_table(tab)

    local rettab = L{}

    for k,v in pairs(tab) do
        local inner = {}
        for j,x in pairs(v) do
            inner[x.name] = x.val
        end
        rettab:append(inner)
    end
    
    return rettab

end

function save(name)

    name = name and name:lower() or nil
    
    if not name then
        error("Specify a profile name to save to.")
    else
        settings.profiles[name] = helpers.to_xml_table(augments)
        notice("Saved current augments to the profile '%s'":format(name))
    end
    
    settings:save('all')

end

function load(name)

    name = name and name:lower() or nil
    
    if not name then
        error("Specify a profile name to load.")
    else
        if not settings.profiles[name] then
            error("Could not find a profile named %s":format(name))
        else
            augments = helpers.from_xml_table(settings.profiles[name])
            display()
            notice("Loaded profile: %s":format(name))
        end
    end

end

function debug()
    settings.debug = not settings.debug
    notice("Debug mode: %s":format(tostring(settings.debug)))
end

function delay(del)

    del = del and tonumber(del) or nil
    
    if del then
        settings.delay = math.min(math.abs(del),5)
        notice("Delay between augments set to %.2f.":format(settings.delay))
        settings:save('all')
    end

end

function help()

    print('MAGA will automatically augment items for you after you trade them to Oseem.')
    print('No menu will appear, don\'t panic!')
    print('Command listing: ')
    print(' - help   : displays this help text')
    print(' - start  : begins augmenting an item after traded')
    print(' - stop   : stops the augmentation loop')
    print(' - cancel : returns your item to you unchanged')
    print(' - accept : accepts the most recent augment')
    print(' - display : lists augments to match')
    print(' - style <augment style> : the type of augment to choose (magic, melee, ranged, familiar, healing)')
    print(' - add <augment name> <minimum value>')
    print(' - remove <augment name>')
    


end



handlers = {
    cancel = cancel,
    continue = continue,
    accept = accept,
    start = start,
    stop = stop,
    pellucid = pellucid,
    taupe = taupe,
    fern = fern,
    style = style,
    search = search,
    add = add,
    remove = remove,
    display = display,
    help = help,
    save = save,
    history = update_display,
    newset = newset,
    delset = delset,
    delay = delay,
    load = load,
    debug = debug
}


windower.register_event('unload', cancel)

windower.register_event('addon command', function (...)
    local cmd  = (...) and (...):lower()
    local args = {select(2, ...)}
    if handlers[cmd] then
        local msg = handlers[cmd](unpack(args))
        if msg then
            log('Result: ' .. msg)
        end
    else
        error("unknown command %s":format(cmd or ""))
    end
end)
