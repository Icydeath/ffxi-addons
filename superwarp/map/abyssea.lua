local warp_zones = S{ 232, 236, 240, 246, 243, 242 } -- ports + ru'lude and heaven's tower
local entry_zones = S{ 102, 108, 117, 118, 103, 104, 107, 106, 112 } 
local teleport_npcs = S{ "Ernst", "Ivan", "Willis", "Horst", "Kierron", "Vincent"}
local abyssea_zones = S{ 15, 45, 132, 215, 216, 217, 218, 253, 254}
return T{
    short_name = 'ab',
    long_name = 'veridical conflux',
    npc_plural = 'abyssean npcs',
    npc_names = T{
        warp = T{'Veridical Conflux', 'Ernst', 'Ivan', 'Willis', 'Horst', 'Kierron', 'Vincent'},
        enter = T{'Cavernous Maw'},
        exit = T{'Cavernous Maw'},
    },
    validate = function(menu_id, zone, current_activity)
                -- npc warps:
        if not (menu_id == 404 or --  Ernst
                menu_id == 795 or -- Ivan
                menu_id == 873 or -- Willis
                menu_id == 339 or -- Horst
                menu_id == 433 or -- Kierron
                menu_id == 10185 or -- Vincent
                -- enter: maws
                menu_id == 107 or -- Konschtat
                menu_id == 100 or -- Tahrongi
                menu_id == 218 or -- La Theine
                menu_id == 61 or -- Attohwa
                menu_id == 55 or -- Misareaux
                menu_id == 47 or -- Vunkerl
                menu_id == 914 or -- Altepa
                menu_id == 204 or -- Uleguerand
                menu_id == 908 or -- Grauberg
                -- exit: maws
                menu_id == 200 or
                -- confluxes: 
               (menu_id >= 2132 and menu_id <= 2139) or -- confluxes
                menu_id == 123) then -- conflux 00
            return "Incorrect menu detected! Menu ID: "..menu_id
        end

        if current_activity.sub_cmd == 'enter' and not entry_zones:contains(zone) then
            return "Not in an entry zone!"
        end
   
        if current_activity.sub_cmd == 'exit' and not abyssea_zones:contains(zone) then
            return "Not in an Abyssea zone!"
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bit_start = 128

        local zd = nil
        if zone == 15 then zd = warpdata[ 'Abyssea - Konschtat' ] end
        if zone == 45 then zd = warpdata[ 'Abyssea - Tahrongi' ] end
        if zone == 132 then zd = warpdata[ 'Abyssea - La Theine' ] end
        if zone == 215 then zd = warpdata[ 'Abyssea - Attohwa' ] end
        if zone == 216 then zd = warpdata[ 'Abyssea - Misareaux' ] end
        if zone == 217 then zd = warpdata[ 'Abyssea - Vunkerl' ] end
        if zone == 218 then zd = warpdata[ 'Abyssea - Altepa' ] end
        if zone == 253 then zd = warpdata[ 'Abyssea - Uleguerand' ] end
        if zone == 254 then zd = warpdata[ 'Abyssea - Grauberg' ] end
        if zd == nil then
            return nil, 'You cannot check missing destinations from here.'
        end

        for d, dd in pairs(zd) do
            if not dd.shortcut and dd.offset then
                if not has_bit(p["Menu Parameters"], unlock_bit_start + dd.offset) then
                    missing:append(z..'-'..d)
                end
            end
        end
        return missing
    end,
    help_text = "[sw] ab [warp/w] [all/a/@all] conflux number -- warp to a designated conflux in your current abyssea zone.\n[sw] ab [all/a/@all] enter -- enter the abyssea zone corresponding to the entrance zone.\n[sw] ab [all/a/@all] exit -- exit the abyssea zone.",
    sub_zone_targets =  S{'00', '0', '1', '2', '3', '4', '5', '6', '7', '8', 'Cavernous Maw'},
    auto_select_zone = function(zone)
        if zone == 15 then return 'Abyssea - Konschtat' end
        if zone == 45 then return 'Abyssea - Tahrongi' end
        if zone == 132 then return 'Abyssea - La Theine' end
        if zone == 215 then return 'Abyssea - Attohwa' end
        if zone == 216 then return 'Abyssea - Misareaux' end
        if zone == 217 then return 'Abyssea - Vunkerl' end
        if zone == 218 then return 'Abyssea - Altepa' end
        if zone == 253 then return 'Abyssea - Uleguerand' end
        if zone == 254 then return 'Abyssea - Grauberg' end
    end,
    auto_select_sub_zone = function(zone)
        if warp_zones:contains(zone) then return 'Cavernous Maw' end
    end,
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings
        if zone == destination.zone then

            -- have xyz data and within zone. must be conflux.
            local cruor = p["Menu Parameters"]:unpack('I', 29)

            debug("cruor: "..cruor)

            if cruor < 200 then
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

            local unlock_bit_start = 128

            local destination_unlocked = false
            if destination.offset ~= nil then
                destination_unlocked = has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset)
            --elseif destination.invoffset then
            --    destination_unlocked = not has_bit(p["Menu Parameters"], unlock_bit_start + destination.invoffset)
            end

            debug('zone is unlocked: '..tostring(destination_unlocked))

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
                actions:append(T{packet=packet, description='cancel menu', message='Destination Conflux is not unlocked yet!'})
                return actions
            end

            -- request map
            --packet = packets.new('outgoing', 0x114)
            --packet.debug_desc = 'request map'
            --actions:append(packet)

            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 1
            packet["_unknown1"] = destination.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, description='send options'})

            -- request in-zone warp
            packet = packets.new('outgoing', 0x05C)
            packet["Target ID"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["X"] = destination.x
            packet["Y"] = destination.y
            packet["Z"] = destination.z
            packet["_unknown1"] = destination.unknown1
            packet["Rotation"] = destination.h
            actions:append(T{packet=packet, wait_packet=0x05C, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='same-zone move request'})

            -- complete menu
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = destination.index
            packet["_unknown1"] = 0
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=false, delay=1, description='complete menu'})
            
        else
            -- no xyz data, must be a zone warp.
            local cruor = p["Menu Parameters"]:unpack('i', 5)

            debug("cruor: "..cruor)

            if cruor < 200 then
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


            local unlock_bit_start = 0

            local destination_unlocked = false
            if destination.offset ~= nil then
                destination_unlocked = has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset)
            --elseif destination.invoffset then
            --    destination_unlocked = not has_bit(p["Menu Parameters"], unlock_bit_start + destination.invoffset)
            end

            debug('zone is unlocked: '..tostring(destination_unlocked))

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
                actions:append(T{packet=packet, description='cancel menu', message='Destination Zone is not unlocked yet!'})
                return actions
            end

            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, description='update request'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = destination.index
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = destination.index
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=true, delay=1, description='send options and complete menu'})
        end

        return actions
    end,
    sub_commands = {
        enter = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p["Menu ID"]
            local npc = current_activity.npc

            
            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, description='update request'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='send options'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='complete menu', message='Entering Abyssea'})

            return actions
        end,
        exit = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p["Menu ID"]
            local npc = current_activity.npc


                -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, description='update request'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='send options'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, wait_packet=0x052, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='complete menu', message='Leaving Abyssea'})

            return actions
        end,
    },
    warpdata = T{
        ['Abyssea - La Theine'] = T{
            ['Cavernous Maw'] = { index = 260, offset=64 }, 
            ['1'] = { index = 1, zone = 132, npc = 701, offset=0, x = -480.00003051758, z = -0.40000000596046, y = 764.00006103516, h = 63, unknown1 = 65538},
            ['2'] = { index = 2, zone = 132, npc = 702, offset=1, x = -593.81103515625, z = -16.300001144409, y = 30.151000976563, h = 180, unknown1 = 131074},
            ['3'] = { index = 3, zone = 132, npc = 703, offset=2, x = -122.96600341797, z = -8.6000003814697, y = -38.954002380371, h = 31, unknown1 = 196610},
            ['4'] = { index = 4, zone = 132, npc = 704, offset=3, x = -54.61600112915, z = 29.200000762939, y = 175.25001525879, h = 244, unknown1 = 262146},
            ['5'] = { index = 5, zone = 132, npc = 705, offset=4, x = 201.68101501465, z = 23.300001144409, y = -398.15502929688, h = 100, unknown1 = 327682},
            ['6'] = { index = 6, zone = 132, npc = 706, offset=5, x = 595.37701416016, z = 39.400001525879, y = -507.18603515625, h = 10, unknown1 = 393218},
            ['7'] = { index = 7, zone = 132, npc = 707, offset=6, x = 494.22302246094, z = 39.600002288818, y = 333.0940246582, h = 112, unknown1 = 458754},
            ['8'] = { index = 8, zone = 132, npc = 708, offset=7, x = 215.14500427246, z = 15.800001144409, y = -198.91801452637, h = 53, unknown1 = 524290},
        },
        ['Abyssea - Konschtat'] = T{
            ['Cavernous Maw'] = { index = 264, offset=65 }, 
            ['1'] = { index = 1, zone = 15, npc = 538, offset=0, x = 126.00000762939, z = -72.800003051758, y = -834.00006103516, h = 223, unknown1 = 65538},
            ['2'] = { index = 2, zone = 15, npc = 539, offset=1, x = -164.00001525879, z = -32.700000762939, y = -276, h = 159, unknown1 = 131074},
            ['3'] = { index = 3, zone = 15, npc = 540, offset=2, x = -644.00006103516, z = -0.70000004768372, y = 124.00000762939, h = 159, unknown1 = 196610},
            ['4'] = { index = 4, zone = 15, npc = 541, offset=3, x = 20, z = 8.7000007629395, y = 45.000003814697, h = 191, unknown1 = 262146},
            ['5'] = { index = 5, zone = 15, npc = 542, offset=4, x = -125.00000762939, z = 15.200000762939, y = 282, h = 127, unknown1 = 327682},
            ['6'] = { index = 6, zone = 15, npc = 543, offset=5, x = -316, z = 47.100002288818, y = 564, h = 223, unknown1 = 393218},
            ['7'] = { index = 7, zone = 15, npc = 544, offset=6, x = 476.00003051758, z = 7.3000001907349, y = 124.00000762939, h = 159, unknown1 = 458754},
            ['8'] = { index = 8, zone = 15, npc = 545, offset=7, x = 244.00001525879, z = 39.200000762939, y = 636, h = 31, unknown1 = 524290},
        },
        ['Abyssea - Tahrongi'] = T{
            ['Cavernous Maw'] = { index = 268, offset=66 }, 
            ['1'] = { index = 1, zone = 45, npc = 535, offset=0, x = 7.826000213623, z = 31.515001296997, y = -636.83404541016, h = 81, unknown1 = 65538},
            ['2'] = { index = 2, zone = 45, npc = 536, offset=1, x = 24.010000228882, z = -16.682001113892, y = -171.58700561523, h = 162, unknown1 = 131074},
            ['3'] = { index = 3, zone = 45, npc = 537, offset=2, x = -290.78402709961, z = -25.574001312256, y = -171.65501403809, h = 201, unknown1 = 196610},
            ['4'] = { index = 4, zone = 45, npc = 538, offset=3, x = -239.86801147461, z = 7.4700002670288, y = 166.16600036621, h = 76, unknown1 = 262146},
            ['5'] = { index = 5, zone = 45, npc = 539, offset=4, x = -56.126003265381, z = 31.085000991821, y = 547.42602539063, h = 150, unknown1 = 327682},
            ['6'] = { index = 6, zone = 45, npc = 540, offset=5, x = -64.581001281738, z = 36.774002075195, y = 331.84002685547, h = 39, unknown1 = 393218},
            ['7'] = { index = 7, zone = 45, npc = 541, offset=6, x = 120.1490020752, z = 15.776000976563, y = 155.14100646973, h = 177, unknown1 = 458754},
            ['8'] = { index = 8, zone = 45, npc = 542, offset=7, x = 324.22500610352, z = 39.661003112793, y = 433.3330078125, h = 159, unknown1 = 524290},
        },
        ['Abyssea - Vunkerl'] = T{
            ['Cavernous Maw'] = { index = 272, offset=96 }, 
            ['1'] = { index = 1, zone = 217, npc = 647, offset=0, x = -322.00003051758, z = -40.523002624512, y = 676.00006103516, h = 127, unknown1 = 65538},
            ['2'] = { index = 2, zone = 217, npc = 648, offset=1, x = -24.502000808716, z = -34.138999938965, y = 370.20001220703, h = 95, unknown1 = 131074},
            ['3'] = { index = 3, zone = 217, npc = 649, offset=2, x = 202.53201293945, z = -31.807001113892, y = 312.14300537109, h = 159, unknown1 = 196610},
            ['4'] = { index = 4, zone = 217, npc = 650, offset=3, x = -266.89801025391, z = -41.942001342773, y = -111.42200469971, h = 63, unknown1 = 262146},
            ['5'] = { index = 5, zone = 217, npc = 651, offset=4, x = -118.68200683594, z = -39.89400100708, y = -477.37503051758, h = 0, unknown1 = 327682},
            ['6'] = { index = 6, zone = 217, npc = 652, offset=5, x = -100.00000762939, z = -56.000003814697, y = -764.01605224609, h = 159, unknown1 = 393218},
            ['7'] = { index = 7, zone = 217, npc = 653, offset=6, x = -675.13201904297, z = -45.693000793457, y = -555.55200195313, h = 223, unknown1 = 458754},
            ['8'] = { index = 8, zone = 217, npc = 654, offset=7, x = -291.04000854492, z = -32.020999908447, y = 282.5710144043, h = 127, unknown1 = 524290},
            ['00'] = { index = 9, zone = 217, npc = 666, offset=8, x = 158, z = -38.100002288818, y = -158, h = 159, unknown1 = 589826},
        },
        ['Abyssea - Misareaux'] = T{
            ['Cavernous Maw'] = { index = 276, offset=97 }, 
            ['1'] = { index = 1, zone = 216, npc = 723, offset=0, x = 634, z = -16.5, y = 286, h = 159, unknown1 = 65538},
            ['2'] = { index = 2, zone = 216, npc = 724, offset=1, x = 399.44900512695, z = -6.7550001144409, y = 33.19100189209, h = 156, unknown1 = 131074},
            ['3'] = { index = 3, zone = 216, npc = 725, offset=2, x = -96.818000793457, z = -33.828002929688, y = 254.32000732422, h = 249, unknown1 = 196610},
            ['4'] = { index = 4, zone = 216, npc = 726, offset=3, x = 141.42300415039, z = -10.116000175476, y = -222.39100646973, h = 95, unknown1 = 262146},
            ['5'] = { index = 5, zone = 216, npc = 727, offset=4, x = -40.898002624512, z = -24.068000793457, y = 439.29000854492, h = 193, unknown1 = 327682},
            ['6'] = { index = 6, zone = 216, npc = 728, offset=5, x = -231.25300598145, z = -32.804000854492, y = 208.75801086426, h = 128, unknown1 = 393218},
            ['7'] = { index = 7, zone = 216, npc = 729, offset=6, x = 288.97399902344, z = 23.489000320435, y = -407.23400878906, h = 193, unknown1 = 458754},
            ['8'] = { index = 8, zone = 216, npc = 730, offset=7, x = 648.31103515625, z = -0.016000000759959, y = -476.11102294922, h = 31, unknown1 = 524290},
            ['00'] = { index = 9, zone = 216, npc = 742, offset=8, x = 276, z = -16.342000961304, y = 236.00001525879, h = 63, unknown1 = 589826},
        },
        ['Abyssea - Attohwa'] = T{
            ['Cavernous Maw'] = { index = 280, offset=98 }, 
            ['1'] = { index = 1, zone = 215, npc = 614, offset=0, x = -140, z = 19.5, y = -200.00001525879, h = 191, unknown1 = 65538},
            ['2'] = { index = 2, zone = 215, npc = 615, offset=1, x = -485.50402832031, z = -3.996000289917, y = -4.9400000572205, h = 223, unknown1 = 131074},
            ['3'] = { index = 3, zone = 215, npc = 616, offset=2, x = 258.90902709961, z = 20.94100189209, y = -21.157001495361, h = 131, unknown1 = 196610},
            ['4'] = { index = 4, zone = 215, npc = 617, offset=3, x = -603.87701416016, z = -4.3210000991821, y = 191.93600463867, h = 0, unknown1 = 262146},
            ['5'] = { index = 5, zone = 215, npc = 618, offset=4, x = 466.83102416992, z = 20.555000305176, y = 78.005004882813, h = 191, unknown1 = 327682},
            ['6'] = { index = 6, zone = 215, npc = 619, offset=5, x = -247.10301208496, z = 13.979001045227, y = 283.57202148438, h = 62, unknown1 = 393218},
            ['7'] = { index = 7, zone = 215, npc = 620, offset=6, x = 378.84503173828, z = 20, y = -141.94599914551, h = 181, unknown1 = 458754},
            ['8'] = { index = 8, zone = 215, npc = 621, offset=7, x = 1.4460000991821, z = -3.6520001888275, y = 150.79200744629, h = 191, unknown1 = 524290},
            ['00'] = { index = 9, zone = 215, npc = 633, offset=8, x = -280, z = -4.5, y = 0, h = 191, unknown1 = 589826},
        },
        ['Abyssea - Altepa'] = T{
            ['Cavernous Maw'] = { index = 284, offset=128 }, 
            ['1'] = { index = 1, zone = 218, npc = 563, offset=0, x = 404.00003051758, z = -0.30000001192093, y = 288, h = 127, unknown1 = 65538},
            ['2'] = { index = 2, zone = 218, npc = 564, offset=1, x = 639, z = 0, y = -126.00000762939, h = 159, unknown1 = 131074},
            ['3'] = { index = 3, zone = 218, npc = 565, offset=2, x = -80, z = 0, y = 437.00003051758, h = 63, unknown1 = 196610},
            ['4'] = { index = 4, zone = 218, npc = 566, offset=3, x = -323.00003051758, z = 0.87800002098083, y = -263, h = 31, unknown1 = 262146},
            ['5'] = { index = 5, zone = 218, npc = 567, offset=4, x = -477.00003051758, z = -1, y = -684.00006103516, h = 191, unknown1 = 327682},
            ['6'] = { index = 6, zone = 218, npc = 568, offset=5, x = -640, z = 0, y = -242.00001525879, h = 79, unknown1 = 393218},
            ['7'] = { index = 7, zone = 218, npc = 569, offset=6, x = -604, z = -1, y = -39, h = 0, unknown1 = 458754},
            ['8'] = { index = 8, zone = 218, npc = 570, offset=7, x = -826.00006103516, z = -10, y = -591, h = 159, unknown1 = 524290},
        },
        ['Abyssea - Uleguerand'] = T{
            ['Cavernous Maw'] = { index = 288, offset=129 }, 
            ['1'] = { index = 1, zone = 253, npc = 563, offset=0, x = -202.00001525879, z = -39.900001525879, y = -506.00003051758, h = 31, unknown1 = 65538},
            ['2'] = { index = 2, zone = 253, npc = 564, offset=1, x = -381.05502319336, z = -25.283000946045, y = -169.20001220703, h = 204, unknown1 = 131074},
            ['3'] = { index = 3, zone = 253, npc = 565, offset=2, x = -300.77301025391, z = -53.509002685547, y = -34.171001434326, h = 58, unknown1 = 196610},
            ['4'] = { index = 4, zone = 253, npc = 566, offset=3, x = 137.36601257324, z = 0.10000000149012, y = -368.51901245117, h = 243, unknown1 = 262146},
            ['5'] = { index = 5, zone = 253, npc = 567, offset=4, x = 576.00805664063, z = -36.076000213623, y = -8.3860006332397, h = 228, unknown1 = 327682},
            ['6'] = { index = 6, zone = 253, npc = 568, offset=5, x = 338.86001586914, z = -100.28800201416, y = 500.10900878906, h = 90, unknown1 = 393218},
            ['7'] = { index = 7, zone = 253, npc = 569, offset=6, x = -257.35900878906, z = -176.33500671387, y = 236.791015625, h = 23, unknown1 = 458754},
            ['8'] = { index = 8, zone = 253, npc = 570, offset=7, x = -582.97705078125, z = -40.378002166748, y = 45.543003082275, h = 89, unknown1 = 524290},
        },
        ['Abyssea - Grauberg'] = T{
            ['Cavernous Maw'] = { index = 292, offset=130 }, 
            ['1'] = { index = 1, zone = 254, npc = 599, offset=0, x = -514, z = 22.417001724243, y = -756.00006103516, h = 63, unknown1 = 65538},
            ['2'] = { index = 2, zone = 254, npc = 600, offset=1, x = 321.8330078125, z = 31.439001083374, y = -557.98303222656, h = 93, unknown1 = 131074},
            ['3'] = { index = 3, zone = 254, npc = 601, offset=2, x = 423.95001220703, z = -0.89300006628036, y = -174.13000488281, h = 159, unknown1 = 196610},
            ['4'] = { index = 4, zone = 254, npc = 602, offset=3, x = -26.465002059937, z = -0.93500006198883, y = -464.54602050781, h = 127, unknown1 = 262146},
            ['5'] = { index = 5, zone = 254, npc = 603, offset=4, x = -165.41400146484, z = -32.099002838135, y = 405.60803222656, h = 137, unknown1 = 327682},
            ['6'] = { index = 6, zone = 254, npc = 604, offset=5, x = 102.16500854492, z = 16.461999893188, y = 497.28903198242, h = 254, unknown1 = 393218},
            ['7'] = { index = 7, zone = 254, npc = 605, offset=6, x = -323.07302856445, z = -127.96900939941, y = 113.65300750732, h = 63, unknown1 = 458754},
            ['8'] = { index = 8, zone = 254, npc = 606, offset=7, x = 490.77603149414, z = -5.5460004806519, y = 340.56301879883, h = 191, unknown1 = 524290},
        },
    },
}

