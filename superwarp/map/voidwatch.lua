local past_warp_zones = S{80,84,87,91,94,98}
local menu_ids = S{962, 1023, 264, 16, 316, 49, 627, 24, 7, 6, -- present
                   79, 657, 46, 25, 8, 15} -- shadowreign
return T{ --  index: 1
    short_name = 'vw',
    long_name = 'voidwatch',
    npc_plural = 'atmacite refiners',
    npc_names = T{
        warp = T{"Atmacite Refiner"},
    },
    validate = function(menu_id, zone, current_activity)
        local destination = current_activity.activity_settings
        if not menu_ids:contains(menu_id) then 
            return "Incorrect menu detected! Menu ID: "..menu_id
        end
        if past_warp_zones:contains(zone) ~= destination.shadowreign then
            return "Cannot teleport from here."
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bits = p["Menu Parameters"]:unpack('I', 21)

        for z, zd in pairs(warpdata) do
            if not zd.shortcut then
                if zd.unlocked then
                    if bit.band(unlock_bits, zd.unlocked) == 0 then
                        missing:append(z)
                    end
                end
            end
        end
        return missing
    end,
    help_text = "[sw] vw [warp/w] [all/a/@all] zone name -- warp to a designated voidwatch zone. \"all\" sends ipc to all local clients.",
    sub_zone_targets = S{},
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local vw_unlocked = p['Menu Parameters']:unpack('b', 1, 2)
        local cruor = p["Menu Parameters"]:unpack('i', 17)
        local unlock_bits = p["Menu Parameters"]:unpack('I', 21)
        local expac_flags = p['Menu Parameters']:sub(29)

        if not vw_unlocked then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Voidwatch content is not unlocked yet!'})
            return actions
        end

        local destination_unlocked = true
        if destination.unlocked then
            destination_unlocked = bit.band(unlock_bits, destination.unlocked) ~= 0
        end

        debug('voidwatch warp is unlocked: '..tostring(destination_unlocked))

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
            actions:append(T{packet=packet, description='cancel menu', message='Destination is not unlocked yet!'})
            return actions
        end

        debug("cruor: "..cruor)
        if cruor < 1000 then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Not enough cruor!'})
            return actions
        end

        if destination.expac then
            debug('destination expac: '..destination.expac..'. has access? '..tostring(has_bit(expac_flags, destination.expac or 0)))
            if not has_bit(expac_flags, destination.expac) then
                packet = packets.new('outgoing', 0x05B)
                packet["Target"] = npc.id
                packet["Option Index"] = 0
                packet["_unknown1"] = 16384
                packet["Target Index"] = npc.index
                packet["Automated Message"] = false
                packet["_unknown2"] = 0
                packet["Zone"] = zone
                packet["Menu ID"] = menu
                actions:append(T{packet=packet, description='cancel menu', message='You do not have access to that expansion!'})
                return actions
            end
        end

        --if settings.debug then
        --    packet = packets.new('outgoing', 0x05B)
        --    packet["Target"] = npc.id
        --    packet["Option Index"] = 0
        --    packet["_unknown1"] = 16384
        --    packet["Target Index"] = npc.index
        --    packet["Automated Message"] = false
        --    packet["_unknown2"] = 0
        --    packet["Zone"] = zone
        --    packet["Menu ID"] = menu
        --    actions:append(T{packet=packet, description='cancel menu', message='Debug stop'})
        --    return actions
        --end

        local popMessage = nil
        if destination.z and destination.pops then
            popMessage = "Pops located at: "..destination.z.." "..destination.pops
        end

        -- update request
        --packet = packets.new('outgoing', 0x016)
        --packet["Target Index"] = windower.ffxi.get_player().index
        --actions:append(T{packet=packet, description='update request'})
    
        -- request warp
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        packet["Option Index"] = 2
        packet["_unknown1"] = destination.index
        packet["Automated Message"] = false
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send  indexs and complete menu', message=popMessage})

        return actions
    end,
    warpdata = T{
        ['East Ronfaure'] = { index = 1, unlocked = 0x000000F, },
        ['East Ronfaure [S]'] = { index = 2, unlocked = 0x000000F, shadowreign = true, },
        ['Ordelle\'s Caves'] = { index = 3, unlocked = 0x000000E, },
        ['Jugner Forest'] = { index = 4, unlocked = 0x000000C, },
        ['Jugner Forest [S]'] = { index = 5, unlocked = 0x000000C, shadowreign = true, },
        ['King Ranperre\'s Tomb'] = { index = 6, unlocked = 0x0000008, },
        ['North Gustaberg'] = { index = 7, unlocked = 0x00000F0, },
        ['North Gustaberg [S]'] = { index = 8, unlocked = 0x00000F0, shadowreign = true, },
        ['Gusgen Mines'] = { index = 9, unlocked = 0x00000E0, },
        ['Pashhow Marshlands'] = { index = 10, unlocked = 0x00000C0, },
        ['Pashhow Marshlands [S]'] = { index = 11, unlocked = 0x00000C0, shadowreign = true, },
        ['Dangruf Wadi'] = { index = 12, unlocked = 0x0000080, },
        ['West Sarutabaruta'] = { index = 13, unlocked = 0x0000F00, },
        ['West Sarutabaruta [S]'] = { index = 14, unlocked = 0x0000F00, shadowreign = true, },
        ['Maze of Shakhrami'] = { index = 15, unlocked = 0x0000E00, },
        ['Meriphataud Mountains'] = { index = 16, unlocked = 0x0000C00, },
        ['Meriphataud Mountains [S]'] = { index = 17, unlocked = 0x0000C00, shadowreign = true, },
        ['Outer Horutoto Ruins'] = { index = 18, unlocked = 0x0000800, },
        ['Batallia Downs'] = { index = 19, unlocked = 0x0707000, zone = 105, },
        ['Batallia Downs [S]'] = { index = 20, unlocked = 0x0707000, zone = 854, shadowreign = true, },
        ['Rolanberry Fields'] = { index = 21, unlocked = 0x0707000, zone = 110, },
        ['Rolanberry Fields [S]'] = { index = 22, unlocked = 0x0707000, zone = 91, shadowreign = true, },
        ['Sauromugue Champaign'] = { index = 23, unlocked = 0x0707000, zone = 120, },
        ['Sauromugue Champaign [S]'] = { index = 24, unlocked = 0x0707000, zone = 98, shadowreign = true, },
        ['Eldieme Necropolis'] = { index = 25, unlocked = 0x0706000, },
        ['Eldieme Necropolis [S]'] = { index = 26, unlocked = 0x0706000, shadowreign = true, },
        ['Crawlers\' Nest'] = { index = 27, unlocked = 0x0706000, },
        ['Crawlers\' Nest [S]'] = { index = 28, unlocked = 0x0706000, shadowreign = true, },
        ['Garlaige Citadel'] = { index = 29, unlocked = 0x0706000, },
        ['Garlaige Citadel [S]'] = { index = 30, unlocked = 0x0706000, shadowreign = true, },
        ['Qufim Island'] = { index = 31, unlocked = 0x0704000, zone = 126, },
        ['Delkfutt\'s Tower'] = { index = 32, unlocked = 0x0704000, },
        ['Behemoth\'s Dominion'] = { index = 33, unlocked = 0x0704000, },
        ['Yuhtunga Jungle'] = { index = 34, unlocked = 0x0068000, expac = 0, },
        ['Ifrit\'s Cauldron'] = { index = 35, unlocked = 0x0068000, expac = 0, },
        ['Temple of Uggalepih'] = { index = 36, unlocked = 0x0068000, expac = 0, },
        ['Western Altepa Desert'] = { index = 37, unlocked = 0x0070000, expac = 0, },
        ['Kuftal Tunnel'] = { index = 38, unlocked = 0x0070000, expac = 0, },
        ['Quicksand Caves'] = { index = 39, unlocked = 0x0070000, expac = 0, },
        ['The Sanctuary of Zi\'Tah'] = { index = 40, unlocked = 0x0060000, expac = 0, },
        ['The Boyahda Tree'] = { index = 41, unlocked = 0x0060000, expac = 0, },
        ['Ro\'Maeve'] = { index = 42, unlocked = 0x0060000, expac = 0, },
        ['The Hall of the Gods'] = { index = 43, unlocked = 0x0040000, expac = 0, },
        ['West Ronfaure'] = { index = 44, unlocked = 0x0700000, },
        ['South Gustaberg'] = { index = 45, unlocked = 0x0700000, },
        ['East Sarutabaruta'] = { index = 46, unlocked = 0x0700000, },
        ['La Theine Plateau'] = { index = 47, unlocked = 0x0600000, },
        ['Konschtat Highlands'] = { index = 48, unlocked = 0x0600000, },
        ['Tahrongi Canyon'] = { index = 49, unlocked = 0x0600000, },
        ['Vunkerl Inlet [S]'] = { index = 50, unlocked = 0x0400000, shadowreign = true, },
        ['Grauberg [S]'] = { index = 51, unlocked = 0x0400000, shadowreign = true, },
        ['Fort Karugo-Narugo [S]'] = { index = 52, unlocked = 0x0400000, shadowreign = true, },
        ['Valkurm Dunes'] = { index = 53, unlocked = 0x0400000, },
        ['Buburimu Peninsula'] = { index = 54, unlocked = 0x0400000, },
        ['Beaucedine Glacier'] = { index = 55, unlocked = 0x0400000, },
        ['Lufaise Meadows'] = { index = 56, unlocked = 0x1800000, expac = 1, },
        ['Misareaux Coast'] = { index = 57, unlocked = 0x1800000, expac = 1, },
        ['Uleguerand Range'] = { index = 58, unlocked = 0x1800000, expac = 1, },
        ['Attohwa Chasm'] = { index = 59, unlocked = 0x1800000, expac = 1, },
        ['Bibiki Bay'] = { index = 60, unlocked = 0x1000000, expac = 1, },
        ['Arrapago Reef'] = { index = 61, unlocked = 0x6000000, expac = 2, },
        ['Mount Zhayolm'] = { index = 62, unlocked = 0x6000000, expac = 2, },
        ['Mamook'] = { index = 63, unlocked = 0x6000000, expac = 2, },
        ['Caedarva Mire'] = { index = 64, unlocked = 0x6000000, expac = 2, },
        ['Aydeewa Subterrane'] = { index = 65, unlocked = 0x4000000, expac = 2, },
    },
}