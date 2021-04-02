_addon.name = 'RollDistance'
_addon.version = '1.0.0'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.commands = {'rolldistance','rd'}

config = require('config')
texts = require('texts')

defaults = {
    ui = {
        pos = {
            x = 0,
            y = 0
        },
        bg = {
            alpha = 150,
            blue = 0,
            green = 0,
            red = 0,
            visible = true
        },
        padding = 8,
        text = {
            font = 'Consolas',
            size = 10
        }
    },
    luzaf = true,
    interval = 0.5,
}

settings = config.load(defaults)

ui = texts.new(settings.ui, settings)

function pad_string(str, len)
    return str .. string.rep(' ', len - #str)
end

commands = {}

commands.luzaf = function()
    settings.luzaf = not settings.luzaf
    settings:save()
    windower.add_to_chat(8, "Luzaf's Ring: " .. tostring(settings.luzaf))
end
commands.l = commands.luzaf

commands.interval = function(args)
    settings.interval = tonumber(args[1])
    settings:save()
    coroutine.close(thread)
    update()
end
commands.i = commands.interval

commands.help = function()
    windower.add_to_chat(8, 'RollDistance:')
    windower.add_to_chat(8, "  //rd luzaf - toggles whether you're using Luzaf's Ring for double range. Default: true")
    windower.add_to_chat(8, '  //rd interval <number> - sets the refresh interval to the given number of secs. Default: 0.5')
end
commands.h = commands.help

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'

    if commands[command] then
        commands[command]({...})
    else
        commands.help()
    end
end)

function update_text()
    local group = windower.ffxi.get_party()
    local party = {}
    local max_name_length = 0

    --loop over p1 - p5. p0 is you
    for i = 1, 5 do
        if not group['p' .. i] then break end
        party[i] = group['p' .. i]
        max_name_length = party[i] and #party[i].name > max_name_length and #party[i].name or max_name_length
    end

    --no party members, hide and do nothing
    if #party == 0 then
        ui:hide()
        return
    end

    local text = ''
    local all_in_range = true
    for _, party_member in ipairs(party) do
        local distance = '--'
        local colour = "\\cs(150,150,150)" --grey

        if party_member.zone == group.p0.zone then
            if not party_member.mob or not party_member.mob.valid_target then
                all_in_range = false
                distance = '??'
                colour = "\\cs(255,255,255)" --white
            else
                distance = math.ceil(math.sqrt(party_member.mob.distance))

                if settings.luzaf and distance > 16 or not settings.luzaf and distance > 8 then
                    colour = "\\cs(255,255,255)" --white
                    all_in_range = false
                else
                    colour = "\\cs(0,255,0)" --green
                end
            end
        else
            all_in_range = false
        end
        distance = tostring(distance)
        if #distance == 1 then distance = ' ' .. distance end
        text = text .. pad_string(party_member.name, max_name_length) .. ' ' .. colour .. distance .. '\\cr\n'
    end

    if all_in_range then
        ui:bg_color(0, 75, 0)
    else
        ui:bg_color(0, 0, 0)
    end
    ui:text(text)
    ui:show()
end

function update()
    update_text()
    thread = coroutine.schedule(update, settings.interval)
end

windower.register_event('load', function()
    if windower.ffxi.get_player() then
        update()
    end
end)

windower.register_event('login', function()
    update()
end)

windower.register_event('logout', function()
    coroutine.close(thread)
end)
