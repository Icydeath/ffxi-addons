_addon.name = 'Targeter'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.commands = {'targeter', 'targ'}
_addon.version = '0.0.1'

config = require('config')
packets = require('packets')

settings = config.load({
    targets = L{},
    add_to_chat_mode = 8,
    sets = {},
})

function target_nearest(target_names)
    local mobs = windower.ffxi.get_mob_array()
    local closest
    for _, mob in pairs(mobs) do
        if mob.valid_target and mob.hpp > 0 and target_names:contains(mob.name:lower()) then
            if not closest or mob.distance < closest.distance then
                closest = mob
            end
        end
    end

    if not closest then
        windower.add_to_chat(settings.add_to_chat_mode, 'Cannot find valid target')
        return
    end

    local player = windower.ffxi.get_player()

    packets.inject(packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = closest.id,
        ['Player Index'] = player.index,
    }))

    if player.status == 1 then
        windower.send_command('wait 0.5; input /attack <t>')
    end
end

commands = {}

commands.save = function(set_name)
    if not set_name then
        windower.add_to_chat(settings.add_to_chat_mode, 'A saved target set needs a name: //targ save <set>')
        return
    end

    settings.sets[set_name] = L{settings.targets:unpack()}
    settings:save()
    windower.add_to_chat(settings.add_to_chat_mode, set_name .. ' saved')
end

commands.load = function(set_name)
    if not set_name or not settings.sets[set_name] then
        windower.add_to_chat(settings.add_to_chat_mode, 'Unknown target set: //targ load <set>')
        return
    end

    settings.targets = L{settings.sets[set_name]:unpack()}
    settings:save()
    windower.add_to_chat(settings.add_to_chat_mode, set_name .. ' target set loaded')
end

commands.add = function(...)
    local target = T{...}:sconcat()
    if target == 'nil' then return end

    if target == '' then
        local selected_target = windower.ffxi.get_mob_by_target('t')
        if not selected_target then return end
        target = selected_target.name
    end

    target = target:lower()
    if not settings.targets:contains(target) then
        settings.targets:append(target)
        settings.targets:sort()
        settings:save()
    end

    windower.add_to_chat(settings.add_to_chat_mode, target .. ' added')
end
commands.a = commands.add

commands.remove = function(...)
    local target = T{...}:sconcat()

    if target == '' then
        local selected_target = windower.ffxi.get_mob_by_target('t')
        if not selected_target then return end
        target = selected_target.name
    end

    target = target:lower()
    local new_targets = L{}
    for k, v in ipairs(settings.targets) do
        if v ~= target then
            new_targets:append(v)
        end
    end
    settings.targets = new_targets
    settings:save()
    windower.add_to_chat(settings.add_to_chat_mode, target .. ' removed')
end
commands.r = commands.remove

commands.removeall = function()
    settings.targets = L{}
    settings:save()
    windower.add_to_chat(settings.add_to_chat_mode, 'All targets removed')
end
commands.ra = commands.removeall

commands.list = function()
    if #settings.targets == 0 then
        windower.add_to_chat(settings.add_to_chat_mode, 'There are no targets set')
        return
    end

    windower.add_to_chat(settings.add_to_chat_mode, 'Targets:')
    for _, target in ipairs(settings.targets) do
        windower.add_to_chat(settings.add_to_chat_mode, '  ' .. target)
    end
end
commands.l = commands.list

commands.target = function()
    target_nearest(settings.targets)
end
commands.t = commands.target

commands.once = function(...)
    local target = T{...}:sconcat()
    if target == '' then return end
    target_nearest(T{target})
end
commands.o = commands.once

commands.help = function()
    windower.add_to_chat(settings.add_to_chat_mode, 'Targeter:')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ add <target name> - add a target to the list')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ remove <target name> - remove a target from the list')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ removeall - remove all targets from the list')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ target - target the nearest target from the list')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ once <target name> - target an enemy once')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ save <set> - save current targets as a target set')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ load <set> - load a previously saved target set')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ list - list current targets')
    windower.add_to_chat(settings.add_to_chat_mode, '  //targ help - display this help')
    windower.add_to_chat(settings.add_to_chat_mode, '(For more detailed information, see the readme)')
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'

    if commands[command] then
        commands[command](...)
    else
        commands.help()
    end
end)
