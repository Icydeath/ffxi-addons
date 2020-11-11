return T{
    short_name = 'pwp',
    long_name = 'proto-waypoint',
    npc_plural = 'proto-waypoints',
    npc_names = T{
        warp = T{'Proto-Waypoint'},
    },
    validate = function(menu_id, zone, current_activity)
        if not (menu_id == 10209 or -- Ru'Lude Gardens
               menu_id == 10012 or -- Selbina
               menu_id == 345 or -- Mhaura
               menu_id == 266 or -- Norg
               menu_id == 141) then -- Rabao
            return "Incorrect menu detected! Menu ID: "..menu_id
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bit_start = 0

        for z, zd in pairs(warpdata) do
            if not zd.shortcut then
                if zd.offset then
                    if not has_bit(p["Menu Parameters"], unlock_bit_start + zd.offset) then
                        missing:append(z)
                    end
                end
            end
        end
        return missing
    end,
    help_text = "[sw] pwp [warp/w] [all/a/@all] zone name -- warp to a designated geomagnetic fount. \"all\" sends ipc to all local clients.",
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local kinetic_units_stock = p["Menu Parameters"]:unpack('H', 13)
        local unlock_bit_start = 0

        local destination_unlocked = false
        if destination.offset ~= nil then
            destination_unlocked = has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset)
        end

        debug('geomagnetic fount is unlocked: '..tostring(destination_unlocked))

        if not destination_unlocked then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Destination Geomagnetic Fount is not unlocked yet!'})
            return actions
        end

        debug('Kinetic Units stock: '..kinetic_units_stock)

        if destination.cost > kinetic_units_stock then

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Not enough Kinetic Units'})

            return actions
        end

        -- menu change
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        packet["Option Index"] = destination.index
        packet["_unknown1"] = 0
        packet["Automated Message"] = true
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options'})


        -- request warp
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        packet["Option Index"] = destination.index
        packet["_unknown1"] = 0
        packet["Automated Message"] = false
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options and complete menu'})


        return actions
    end,
    warpdata = T{
        ["Ru'lude Gardens"] = { index = 4, offset = 0, zone = 243, cost = 30, },
        ["Selbina"] = { index = 5, offset = 1, zone = 248, cost = 30, },
        ["Mhaura"] = { index = 6, offset = 2, zone = 249, cost = 30, },
        ["Rabao"] = { index = 7, offset = 3, zone = 247, cost = 30, },
        ["Norg"] = { index = 8, offset = 4, zone = 252, cost = 30, },
        ["West Ronfaure"] = { index = 9, offset = 5, zone = 100, cost = 100, },
        ["North Gustaberg"] = { index = 10, offset = 6, zone = 106, cost = 100, },
        ["West Sarutabaruta"] = { index = 11, offset = 7, zone = 115, cost = 100, },
        ["La Theine Plateau"] = { index = 12, offset = 8, zone = 102, cost = 100, },
        ["Konschtat Highlands"] = { index = 13, offset = 9, zone = 108, cost = 100, },
        ["Tahrongi Canyon"] = { index = 14, offset = 10, zone = 117, cost = 100, },
        ["Jugner Forest"] = { index = 15, offset = 11, zone = 104, cost = 100, },
        ["Pashhow Marshlands"] = { index = 16, offset = 12, zone = 109, cost = 100, },
        ["Meriphataud Mountains"] = { index = 17, offset = 13, zone = 119, cost = 100, },
        ["Attohwa Chasm"] = { index = 18, offset = 14, zone = 7, cost = 100, },
        ["Uleguerand Range"] = { index = 19, offset = 15, zone = 5, cost = 100, },
        ["Davoi"] = { index = 20, offset = 16, zone = 149, cost = 300, },
        ["Beadeaux"] = { index = 21, offset = 17, zone = 147, cost = 300, },
        ["Castle Oztroja"] = { index = 22, offset = 18, zone = 151, cost = 300, },
        ["Quicksand Caves"] = { index = 23, offset = 19, zone = 208, cost = 300, },
        ["Sea Serpent Grotto"] = { index = 24, offset = 20, zone = 176, cost = 300, },
        ["Temple of Uggalepih"] = { index = 25, offset = 21, zone = 159, cost = 300, },
        ["The Boyahda Tree"] = { index = 26, offset = 22, zone = 153, cost = 300, },
        ["Oldton Movalpolos"] = { index = 27, offset = 23, zone = 11, cost = 300, },
        ["Riverne - Site #B01"] = { index = 28, offset = 24, zone = 29, cost = 300, },
        ["Castle Zvahl Keep"] = { index = 29, offset = 25, zone = 162, cost = 300, },
    },
}
