_addon.name = 'noknock'

require('actions')

function inc_action(_, act)
    if act.category ~= 11 then
        return
    end

    for x = 1, act.target_count do
        for n = 1, act.targets[x].action_count do
            act.targets[x].actions[n].stagger = 0
        end
    end
    return act
end

ActionPacket.open_listener(inc_action)
