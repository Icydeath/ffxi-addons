_addon.version = '0.0.1'
_addon.name = 'attackid'
_addon.author = 'yyoshisaur'
_addon.commands = {'attackid','atkid'}

packets = require('packets')

windower.register_event('addon command', function(...)
    local args = {...}

    if args[1] then

        local id = tonumber(args[1])

        if not id then
            -- error
            return
        end

        local target = windower.ffxi.get_mob_by_id(id)

        if not target then
            -- error
            return
        end

        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = target.id,
            ["Target Index"] = target.index,
            ["Category"] = 0x02 -- Engage Monster
        })

        packets.inject(p)

    else
        -- error
    end
end)