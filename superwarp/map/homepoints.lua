return T{ -- option: 2
    short_name = 'hp',
    long_name = 'homepoint',
    npc_plural = 'homepoints',
    npc_names = T{
        warp = T{'Home Point'},
        set = T{'Home Point'},
    },
    validate = function(menu_id, zone, current_activity)
        if not(menu_id >= 8700 and menu_id <= 8704) then
            return "Incorrect menu detected! Menu ID: "..menu_id
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bit_start = 32

        for z, zd in pairs(warpdata) do
            if not zd.shortcut then
                if not zd.index then
                    for d, dd in pairs(zd) do
                        if not dd.shortcut then
                            if not has_bit(p["Menu Parameters"], unlock_bit_start + dd.index) then
                                missing:append(z..'-'..d)
                            end                            
                        end
                    end
                else
                    if not has_bit(p["Menu Parameters"], unlock_bit_start + zd.index) then
                        missing:append(z)
                    end
                end
            end
        end
        return missing
    end,
    help_text = "[sw] hp [warp/w] [all/a/@all] zone name [homepoint_number] -- warp to a designated homepoint. \"all\" sends ipc to all local clients.\n[sw] hp [all/a/@all] set -- set the closest homepoint as your return homepoint",
    sub_zone_targets = S{'entrance', 'mog house', 'auction house', '1', '2', '3', '4', '5', '6', '7', '8', '9', },
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local gil = p["Menu Parameters"]:unpack('i', 21)
        local unlock_bit_start = 32

        debug('homepoint is unlocked: '..tostring(has_bit(p["Menu Parameters"], unlock_bit_start + destination.index)))

        if not has_bit(p["Menu Parameters"], unlock_bit_start + destination.index) then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Destination Homepoint is not unlocked yet!'})
            return actions
        end

        debug('gil: '..gil)

        if gil < 1000 then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Not enough Gil!'})
            return actions
        end

        local expac_flags = p['Menu Parameters']:sub(0x19)
        debug('destination expac: '..destination.expac..'. has access? '..tostring(has_bit(expac_flags, destination.expac)))
        if destination.expac and not has_bit(expac_flags, destination.expac) then
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

        if settings.enable_same_zone_teleport and zone == destination.zone and destination.x and destination.y and destination.z then

            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='update request'})

            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 8
            packet["_unknown1"] = 0
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, description='menu change'})

            -- request map
            packet = packets.new('outgoing', 0x114)
            actions:append(T{packet=packet, wait_packet=0x05C, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='request map'})

            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 2
            packet["_unknown1"] = destination.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, delay=0.2, description='send options'})

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
            actions:append(T{packet=packet,  wait_packet=0x05C, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='same-zone move request'})

            -- complete menu
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 3
            packet["_unknown1"] = 0
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=false, delay=1, description='complete menu'})

        else

            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='update request'})

            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 8
            packet["_unknown1"] = 0
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, description='menu change'})
            
            -- request map
            packet = packets.new('outgoing', 0x114)
            actions:append(T{packet=packet, wait_packet=0x05C, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='request map'})

            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 2
            packet["_unknown1"] = destination.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, delay=0.2, description='menu change'})
        
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
            actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options and complete menu'})
        end

        return actions
    end,
    sub_commands = {
        set = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p["Menu ID"]
            local npc = current_activity.npc
            
            -- menu change
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 8
            packet["_unknown1"] = 0
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, description='menu change'})
            
            -- select "set HP"
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, wait_packet=0x052, expecting_zone=false, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='hp set request'})

            return actions
        end,
    },
    warpdata = T{
        ['Southern San d\'Oria'] = {
            ['Entrance'] = { shortcut = '1' },
            ['Auction House'] = { shortcut = '2' },
            ['Mog House'] = { shortcut = '3' },
            ['1'] = { index = 0,  expac = 0, zone = 230, npc = 135, x = -84.468002319336, z = 1, y = -65.454002380371, h = 95, unknown1 = 3},
            ['2'] = { index = 1,  expac = 0, zone = 230, npc = 136, x = 45.000003814697, z = 2, y = -34, h = 63, unknown1 = 65539},
            ['3'] = { index = 2,  expac = 0, zone = 230, npc = 137, x = 140, z = -2, y = 124.00000762939, h = 63, unknown1 = 131075},
            ['4'] = { index = 97, expac = 0, zone = 230, npc = 138, x = -164.00001525879, z = -1, y = 11.000000953674, h = 127, unknown1 = 6356995},},
        ['Northern San d\'Oria'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '3', },
            ['1'] = { index = 3,  expac = 0, zone = 231, npc = 112, x = -179.10101318359, z = 4, y = 71.279006958008, h = 0, unknown1 = 196611},
            ['2'] = { index = 4,  expac = 0, zone = 231, npc = 113, x = 10, z = -0.20000000298023, y = 94.000007629395, h = 191, unknown1 = 262147},
            ['3'] = { index = 5,  expac = 0, zone = 231, npc = 114, x = 69, z = -0.20000000298023, y = 9, h = 223, unknown1 = 327683},
            ['4'] = { index = 98, expac = 0, zone = 231, npc = 115, x = -134, z = 12.000000953674, y = 195.00001525879, h = 0, unknown1 = 6422531},},
        ['Port San d\'Oria'] = {
            ['Mog House'] = { shortcut = '2', },
            ['Auction House'] = { shortcut = '3', },
            ['1'] = { index = 6, expac = 0, zone = 232, npc = 86, x = -38, z = -4, y = -64, h = 191, unknown1 = 393219},
            ['2'] = { index = 7, expac = 0, zone = 232, npc = 87, x = 49.000003814697, z = -12.000000953674, y = -106.00000762939, h = 159, unknown1 = 458755},
            ['3'] = { index = 8, expac = 0, zone = 232, npc = 88, x = -6.0000004768372, z = -13.000000953674, y = -151, h = 191, unknown1 = 524291},},
        ['Bastok Mines'] = {
            ['Auction House'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 9,  expac = 0, zone = 234, npc = 68, x = 38.189002990723, z = 0, y = -42.618003845215, h = 0, unknown1 = 589827},
            ['2'] = { index = 10, expac = 0, zone = 234, npc = 69, x = 117.00000762939, z = 1, y = -58.000003814697, h = 0, unknown1 = 655363},
            ['3'] = { index = 99, expac = 0, zone = 234, npc = 70, x = 86.000007629395, z = 7.0000004768372, y = 1, h = 0, unknown1 = 6488067},},
        ['Bastok Markets'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Auction House'] = { shortcut = '2', },
            ['Mog House'] = { shortcut = '3', },
            ['1'] = { index = 11,  expac = 0, zone = 235, npc = 84, x = -343.00003051758, z = -10, y = -156, h = 159, unknown1 = 720899},
            ['2'] = { index = 12,  expac = 0, zone = 235, npc = 85, x = -329.00003051758, z = -12.000000953674, y = -33, h = 0, unknown1 = 786435},
            ['3'] = { index = 13,  expac = 0, zone = 235, npc = 86, x = -189.00001525879, z = -8, y = 27.000001907349, h = 63, unknown1 = 851971},
            ['4'] = { index = 100, expac = 0, zone = 235, npc = 87, x = -190.00001525879, z = -6.0000004768372, y = -68, h = 95, unknown1 = 6553603},},
        ['Port Bastok'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 14,  expac = 0, zone = 236, npc = 72, x = 125.00000762939, z = 8.5, y = 7.0000004768372, h = 223, unknown1 = 917507},
            ['2'] = { index = 15,  expac = 0, zone = 236, npc = 73, x = 41.000003814697, z = 8.5, y = -238.00001525879, h = 127, unknown1 = 983043},
            ['3'] = { index = 101, expac = 0, zone = 236, npc = 74, x = -126.00000762939, z = -6.0000004768372, y = 11.000000953674, h = 95, unknown1 = 6619139},},
        ['Metalworks'] = {
            ['1'] = { index = 16,  expac = 0, zone = 237, npc = 213, x = 45.000003814697, z = -14.000000953674, y = -18, h = 63, unknown1 = 1048579},
            ['2'] = { index = 102, expac = 0, zone = 237, npc = 214, x = -77, z = 2, y = 3.0000002384186, h = 127, unknown1 = 6684675},},
        ['Windurst Waters'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 17,  expac = 0, zone = 238, npc = 152, x = -33.022003173828, z = -5, y = 131.74101257324, h = 0, unknown1 = 1114115},
            ['2'] = { index = 18,  expac = 0, zone = 238, npc = 153, x = 137, z = 0, y = -14.000000953674, h = 0, unknown1 = 1179651},
            ['3'] = { index = 103, expac = 0, zone = 238, npc = 154, x = 4, z = -4, y = -175.00001525879, h = 0, unknown1 = 6750211},
            ['4'] = { index = 118, expac = 0, zone = 238, npc = 155, x = -92.000007629395, z = -2, y = 53.000003814697, h = 191, unknown1 = 7733251},},
        ['Windurst Walls'] = {
            ['Mog House'] = { shortcut = '2', },
            ['Auction House'] = { shortcut = '3', },
            ['1'] = { index = 19, expac = 0, zone = 239, npc = 103, x = -73.069999694824, z = -5.0130000114441, y = 124.78400421143, h = 0, unknown1 = 1245187},
            ['2'] = { index = 20, expac = 0, zone = 239, npc = 104, x = -212.00001525879, z = 0, y = -100.00000762939, h = 191, unknown1 = 1310723},
            ['3'] = { index = 21, expac = 0, zone = 239, npc = 105, x = 31.000001907349, z = -6.5000004768372, y = -39, h = 63, unknown1 = 1376259},},
        ['Port Windurst'] = {
            ['Entrance'] = { shortcut = '2', },
            ['Mog House'] = { shortcut = '3', },
            ['1'] = { index = 22, expac = 0, zone = 240, npc = 140, x = -188.00001525879, z = -4, y = 100.00000762939, h = 191, unknown1 = 1441795},
            ['2'] = { index = 23, expac = 0, zone = 240, npc = 141, x = -208.00001525879, z = -8.1600008010864, y = 209.00001525879, h = 223, unknown1 = 1507331},
            ['3'] = { index = 24, expac = 0, zone = 240, npc = 142, x = 179.00001525879, z = -12.000000953674, y = 226.00001525879, h = 0, unknown1 = 1572867},},
        ['Windurst Woods'] = {
            ['Entrance'] = { shortcut = '2', },
            ['Mog House'] = { shortcut = '3', },
            ['Auction House'] = { shortcut = '4', },
            ['1'] = { index = 25,  expac = 0, zone = 241, npc = 184, x = 10.088000297546, z = -2.5, y = 0.61700004339218, h = 95, unknown1 = 1638403},
            ['2'] = { index = 26,  expac = 0, zone = 241, npc = 185, x = 108.00000762939, z = -5, y = -56.000003814697, h = 127, unknown1 = 1703939},
            ['3'] = { index = 27,  expac = 0, zone = 241, npc = 186, x = -92.000007629395, z = -5, y = 63.000003814697, h = 63, unknown1 = 1769475},
            ['4'] = { index = 28,  expac = 0, zone = 241, npc = 187, x = 75, z = -7.5000004768372, y = -139, h = 127, unknown1 = 1835011},
            ['5'] = { index = 119, expac = 0, zone = 241, npc = 188, x = -44.500003814697, z = 0, y = -145, h = 0, unknown1 = 7798787},},
        ['Ru\'Lude Gardens'] = {
            ['Mog House'] = { shortcut = '2', },
            ['Auction House'] = { shortcut = '3', },
            ['1'] = { index = 29, expac = 0, zone = 243, npc = 255, x = -6.0000004768372, z = 3.0000002384186, y = -1, h = 191, unknown1 = 1900547},
            ['2'] = { index = 30, expac = 0, zone = 243, npc = 256, x = 53.000003814697, z = 9, y = -56.000003814697, h = 63, unknown1 = 1966083},
            ['3'] = { index = 31, expac = 0, zone = 243, npc = 257, x = -67, z = 6.0000004768372, y = -26.000001907349, h = 191, unknown1 = 2031619},},
        ['Upper Jeuno'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['Auction House'] = { shortcut = '3', },
            ['1'] = { index = 32, expac = 0, zone = 244, npc = 87, x = -99.981002807617, z = 0, y = 167.56901550293, h = 0, unknown1 = 2097155},
            ['2'] = { index = 33, expac = 0, zone = 244, npc = 88, x = 31.000001907349, z = -1, y = -44.000003814697, h = 0, unknown1 = 2162691},
            ['3'] = { index = 34, expac = 0, zone = 244, npc = 89, x = -52.000003814697, z = 1, y = 15.000000953674, h = 191, unknown1 = 2228227},},
        ['Lower Jeuno'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 35, expac = 0, zone = 245, npc = 137, x = -99.588005065918, z = 0, y = -183.416015625, h = 0, unknown1 = 2293763},
            ['2'] = { index = 36, expac = 0, zone = 245, npc = 138, x = 19, z = -1, y = 53.000003814697, h = 159, unknown1 = 2359299},},
        ['Port Jeuno'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 37, expac = 0, zone = 246, npc = 57, x = 36.076000213623, z = 0, y = 8.831000328064, h = 0, unknown1 = 2424835},
            ['2'] = { index = 38, expac = 0, zone = 246, npc = 58, x = -155, z = -1, y = -3.0000002384186, h = 63, unknown1 = 2490371},},
        ['Kazham'] = { index = 39, expac = 1, zone = 250, npc = 89},
        ['Mhaura'] = { index = 40, expac = 0, zone = 249, npc = 41},
        ['Norg'] = {
            ['Entrance'] = { shortcut = '1', },
            ['Auction House'] = { shortcut = '2', },
            ['1'] = { index = 41,  expac = 1, zone = 252, npc = 52, x = -25.910001754761, z = 0.2960000038147, y = -46.164001464844, h = 95, unknown1 = 2686979},
            ['2'] = { index = 104, expac = 1, zone = 252, npc = 53, x = -65, z = -5.2000002861023, y = 54.000003814697, h = 127, unknown1 = 6815747},},
        ['Rabao'] = {
            ['Entrance'] = { shortcut = '1', },
            ['1'] = { index = 42,  expac = 1, zone = 247, npc = 27, x = -29.276000976563, z = 0, y = -77.585006713867, h = 191, unknown1 = 2752515},
            ['2'] = { index = 105, expac = 1, zone = 247, npc = 28, x = -21.000001907349, z = 8.1300001144409, y = 111.00000762939, h = 63, unknown1 = 6881283},},
        ['Selbina'] = { index = 43, expac = 0, zone = 248, npc = 45},
        ['Western Adoulin'] = {
            ['Auction House'] = { shortcut = '1', },
            ['Entrance'] = { shortcut = '1', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 44,  expac = 11, zone = 256, npc = 115, x = -85.435005187988, z = 3.9990000724792, y = -31.303001403809, h = 31, unknown1 = 2883587},
            ['2'] = { index = 109, expac = 11, zone = 256, npc = 116, x = 30.950000762939, z = 0, y = -163.00001525879, h = 31, unknown1 = 7143427},},
        ['Eastern Adoulin'] = {
            ['Auction House'] = { shortcut = '2', },
            ['Mog House'] = { shortcut = '2', },
            ['1'] = { index = 45,  expac = 11, zone = 257, npc = 87, x = -52.857002258301, z = -0.15000000596046, y = 58.877002716064, h = 223, unknown1 = 2949123},
            ['2'] = { index = 110, expac = 11, zone = 257, npc = 88, x = -50.500003814697, z = -0.15000000596046, y = -95.500007629395, h = 95, unknown1 = 7208963},},
        ['Ceizak Battlegrounds'] = { index = 46, expac = 11, zone = 261, npc = 587},
        ['Foret de Hennetiel'] = { index = 47, expac = 11, zone = 262, npc = 611},
        ['Morimar Basalt Fields'] = { index = 48, expac = 11, zone = 265, npc = 838},
        ['Yorcia Weald'] = { index = 49, expac = 11, zone = 263, npc = 637},
        ['Marjami Ravine'] = { index = 50, expac = 11, zone = 266, npc = 469},
        ['Kamihr Drifts'] = { index = 51, expac = 11, zone = 267, npc = 370},
        ['Yughott Grotto'] = { index = 52, expac = 0, zone = 142, npc = 246},
        ['Palborough Mines'] = { index = 53, expac = 0, zone = 143, npc = 433},
        ['Giddeus'] = { index = 54, expac = 0, zone = 145, npc = 480},
        ['Fei\'Yin'] = {
            ['1'] = { index = 55, expac = 0, zone = 204, npc = 477, x = 242.00001525879, z = -24.500001907349, y = 62.000003814697, h = 0, unknown1 = 3604483},
            ['2'] = { index = 94, expac = 0, zone = 204, npc = 478, x = 102.34400177002, z = -0.11300000548363, y = 269.36199951172, h = 191, unknown1 = 6160387},},
        ['Quicksand Caves'] = {
            ['1'] = { index = 56, expac = 1, zone = 208, npc = 593, x = -984.00006103516, z = 17, y = -290, h = 191, unknown1 = 3670019},
            ['2'] = { index = 96, expac = 1, zone = 208, npc = 594, x = 573, z = 8.9500007629395, y = -500.00003051758, h = 191, unknown1 = 6291459},},
        ['Den of Rancor'] = {
            ['1'] = { index = 57, expac = 1, zone = 160, npc = 520, x = -79, z = 46.000003814697, y = 62.000003814697, h = 127, unknown1 = 3735555},
            ['2'] = { index = 93, expac = 1, zone = 160, npc = 521, x = 182.00001525879, z = 34.470001220703, y = -62.000003814697, h = 223, unknown1 = 6094851},},
        ['Castle Zvahl Keep'] = { index = 58, expac = 0, zone = 162, npc = 334},
        ['Ru\'Aun Gardens'] = {
            ['1'] = { index = 59, expac = 0, zone = 130, npc = 421, x = 5, z = -42.000003814697, y = 525, h = 191, unknown1 = 3866627},
            ['2'] = { index = 60, expac = 0, zone = 130, npc = 422, x = -311, z = -42.000003814697, y = -421.00003051758, h = 95, unknown1 = 3932163},
            ['3'] = { index = 61, expac = 0, zone = 130, npc = 423, x = -498.00003051758, z = -42.000003814697, y = 167.00001525879, h = 127, unknown1 = 3997699},
            ['4'] = { index = 62, expac = 0, zone = 130, npc = 424, x = 499.00003051758, z = -42.000003814697, y = 158, h = 0, unknown1 = 4063235},
            ['5'] = { index = 63, expac = 0, zone = 130, npc = 425, x = 304, z = -42.000003814697, y = -426.00003051758, h = 31, unknown1 = 4128771},},
        ['Tavnazian Safehold'] = {
            ['1'] = { index = 64,  expac = 2, zone = 26, npc = 89, x = -2.25, z = -27.907001495361, y = 106.42500305176, h = 223, unknown1 = 4194307},
            ['2'] = { index = 120, expac = 2, zone = 26, npc = 90, x = 13.000000953674, z = -10, y = -5, h = 0, unknown1 = 7864323},
            ['3'] = { index = 121, expac = 2, zone = 26, npc = 91, x = 74.590003967285, z = -36.150001525879, y = 38.870002746582, h = 127, unknown1 = 7929859},},
        ['Aht Urhgan Whitegate'] = {
            ['Auction House'] = { shortcut = '3', },
            ['Mog House'] = { shortcut = '4', },
            ['1'] = { index = 65,  expac = 3, zone = 50, npc = 38, x = -20.130001068115, z = 0, y = -19.944000244141, h = 95, unknown1 = 4259843},
            ['2'] = { index = 106, expac = 3, zone = 50, npc = 39, x = 129, z = 0, y = -16, h = 0, unknown1 = 6946819},
            ['3'] = { index = 107, expac = 3, zone = 50, npc = 40, x = -107.00000762939, z = -6.0000004768372, y = 108.00000762939, h = 127, unknown1 = 7012355},
            ['4'] = { index = 108, expac = 3, zone = 50, npc = 41, x = -98.000007629395, z = 0, y = -68, h = 127, unknown1 = 7077891},},
        ['Nashmau'] = { index = 66, expac = 3, zone = 53, npc = 28},
        --['Al Zahbi'] = { index = 67, },
        ['Southern San d\'Oria \[S\]'] = { index = 68, expac = 4, zone = 80, npc = 479},
        ['Bastok Markets \[S\]'] = { index = 69, expac = 4, zone = 87, npc = 509},
        ['Windurst Waters \[S\]'] = { index = 70, expac = 4, zone = 94, npc = 468},
        ['Upper Delkfutt\'s Tower'] = { index = 71, expac = 4, zone = 158, npc = 187},
        ['The Shrine of Ru\'Avitau'] = { index = 72, expac = 1, zone = 178, npc = 529},
        ['Riverne - Site #B01'] = { index = 73, expac = 2, zone = 29, npc = 250},
        ['Bhaflau Thickets'] = { index = 74, expac = 3, zone = 52, npc = 410},
        ['Caedarva Mire'] = { index = 75, expac = 3, zone = 79, npc = 551},
        ['Uleguerand Range'] = {
            ['1'] = { index = 76, expac = 2, zone = 5, npc = 455, x = 64, z = -196.50001525879, y = 181.00001525879, h = 0, unknown1 = 4980739},
            ['2'] = { index = 77, expac = 2, zone = 5, npc = 456, x = 380.00003051758, z = 23.000001907349, y = -62.600002288818, h = 127, unknown1 = 5046275},
            ['3'] = { index = 78, expac = 2, zone = 5, npc = 457, x = 424.00003051758, z = -32.5, y = 221.00001525879, h = 63, unknown1 = 5111811},
            ['4'] = { index = 79, expac = 2, zone = 5, npc = 458, x = 64, z = -96.500007629395, y = 461.00003051758, h = 63, unknown1 = 5177347},
            ['5'] = { index = 80, expac = 2, zone = 5, npc = 459, x = -220.00001525879, z = -1, y = -62.000003814697, h = 0, unknown1 = 5242883},},
        ['Attohwa Chasm'] = { index = 81, expac = 2, zone = 7, npc = 495},
        ['Pso\'Xja'] = { index = 82, expac = 2, zone = 9, npc = 487},
        ['Newton Movalpolos'] = { index = 83, expac = 2, zone = 12, npc = 260},
        ['Riverne - Site #A01'] = { index = 84, expac = 2, zone = 30, npc = 303},
        ['Al\'Taieu'] = {
            ['1'] = { index = 85, expac = 2, zone = 33, npc = 612, x = 7.0000004768372, z = 0, y = 708.00006103516, h = 191, unknown1 = 5570563},
            ['2'] = { index = 86, expac = 2, zone = 33, npc = 613, x = -531, z = 0, y = 447.00003051758, h = 127, unknown1 = 5636099},
            ['3'] = { index = 87, expac = 2, zone = 33, npc = 614, x = 569, z = 0, y = 409.00003051758, h = 191, unknown1 = 5701635},},
        ['Grand Palace of Hu\'Xzoi'] = { index = 88, expac = 2, zone = 34, npc = 460},
        ['The Garden of Ru\'Hmet'] = { index = 89, expac = 2, zone = 35, npc = 562},
        ['Mount Zhayolm'] = { index = 90, expac = 3, zone = 61, npc = 553},
        ['Cape Teriggan'] = { index = 91, expac = 1, zone = 113, npc = 465},
        ['The Boyahda Tree'] = { index = 92, expac = 1, zone = 153, npc = 511},
        ['Ifrit\'s Cauldron'] = { index = 95, expac = 1, zone = 205, npc = 379},
        ['Xarcabard \[S\]'] = { index = 111, expac = 4, zone = 137, npc = 891},
        ['Leafallia'] = { index = 112, expac = 11, zone = 281, npc = 59},
        ['Castle Zvahl Keep \[S\]'] = { index = 113, expac = 4, zone = 155, npc = 707},
        ['Qufim Island'] = { index = 114, expac = 0, zone = 126, npc = 515},
        ['Toraimarai Canal'] = { index = 115, expac = 0, zone = 169, npc = 416},
        ['Ra\'Kaznar Inner Court'] = { index = 116, expac = 11, zone = 276, npc = 550},
        ['Misareaux Coast'] = { index = 117, expac = 2, zone = 25, npc = 394},
    },
}
