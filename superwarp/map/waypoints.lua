return T{
    short_name = 'wp',
    long_name = 'waypoint',
    npc_plural = 'waypoints',
    npc_names = T{
        warp = T{'Waypoint'},
    },
    validate = function(menu_id, zone, current_activity)
        if not ((menu_id >= 5000 and menu_id <= 5008) or menu_id == 10121) then
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
                    -- has sub-destinations
                    for d, dd in pairs(zd) do
                        if not dd.shortcut then
                            if dd.offset ~= nil and not has_bit(p["Menu Parameters"], unlock_bit_start + dd.offset) then
                                missing:append(z..'-'..d)
                            elseif dd.invoffset ~= nil and has_bit(p["Menu Parameters"], unlock_bit_start + dd.invoffset) then
                                missing:append(z..'-'..d)
                            end                            
                        end
                    end
                else
                    if zd.offset ~= nil and not has_bit(p["Menu Parameters"], unlock_bit_start + zd.offset) then

                        missing:append(z)
                    elseif zd.invoffset ~= nil and has_bit(p["Menu Parameters"], unlock_bit_start + zd.invoffset) then
                        missing:append(z)
                    end
                end
            end
        end
        return missing
    end,
    help_text = "[sw] wp [warp/w] [all/a/@all] zone name [waypoint_number] -- warp to a designated waypoint. \"all\" sends ipc to all local clients.",
    sub_zone_targets =  S{'frontier station', 'platea', 'triumphus', 'couriers', 'pioneers', 'mummers', 'inventors', 'auction house', 'mog house', 'bridge', 'airship', 'docks', 'waterfront', 'peacekeepers', 'scouts', 'statue', 'goddess', 'wharf', 'yahse', 'sverdhried', 'hillock', 'coronal', 'esplanade', 'castle', 'gates', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'enigmatic device'},
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local kinetic_units_stock = p["Menu Parameters"]:unpack('H', 3)
        local current_waypoint_index = p["Menu Parameters"]:unpack('b8', 1)
        local unlock_bit_start = 32

        local destination_unlocked = false
        if destination.offset ~= nil then
            destination_unlocked = has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset)
        elseif destination.invoffset then
            destination_unlocked = not has_bit(p["Menu Parameters"], unlock_bit_start + destination.invoffset)
        end

        debug('waypoint is unlocked: '..tostring(destination_unlocked))

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
            actions:append(T{packet=packet, description='cancel menu', message='Destination Waypoint is not unlocked yet!'})
            return actions
        end

        local courier_edi_level = p['Menu Parameters']:unpack('b4', 2, 4)

        debug('Kinetic Units stock: '..kinetic_units_stock..', current waypoint: '..current_waypoint_index..', couriers: '.. courier_edi_level)

        -- request map
        packet = packets.new('outgoing', 0x114)
        actions:append(T{packet=packet, description='request map'})

        local teleport_cost = 1
        if zone == 256 or zone == 257 then -- in Adoulin
            if destination.zone == 256 or destination.zone == 257 then -- to Adoulin
                teleport_cost = 1
            elseif destination.zone == 246 then -- to Jeuno
                teleport_cost = 15
            elseif destination.zone == 999 or destination.zone == 258 or destination.zone == 270 or destination.zone == 274 then -- to enigmatic
                teleport_cost = 150
            elseif destination.index >= 200 and destination.index <= 210 then -- rune
                teleport_cost = 100
            else
                teleport_cost = 50
            end
        elseif zone == 246 then -- in Jeuno
            if destination.zone == 256 or destination.zone == 257 then -- to Adoulin
                teleport_cost = 15
            else
                teleport_cost = 0 -- can't go there
            end
        else -- in Ulbuka
            if destination.zone == 256 or destination.zone == 257 then -- to Adoulin
                teleport_cost = 15
            elseif destination.zone == zone then -- to same zone
                teleport_cost = 2
            else -- to Ulbuka
                teleport_cost = 0 -- can't go there
            end
        end

        if teleport_cost <= 0 then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Can\'t teleport from here.'})

            return actions
        elseif teleport_cost > kinetic_units_stock then

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

        debug('teleport cost, calculated: '..teleport_cost)

        if settings.enable_same_zone_teleport and destination.zone == zone and destination.x and destination.y and destination.z  then

            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='update request'})

            -- send options and KU cost
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = 'b7b4b3':pack(current_waypoint_index, destination.op_z, destination.op_i):unpack('b14')
            packet["_unknown1"] = 'b5b8':pack(0, teleport_cost):unpack('b13')
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options'})

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

            --print(packets.build(packet):hex())

            -- complete menu
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Target Index"] = npc.index
            packet["Zone"] = zone
            packet["Menu ID"] = menu

            packet["Option Index"] = destination.sz_oi
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

            packet["Option Index"] = 'b7b4b3':pack(current_waypoint_index, destination.op_z, destination.op_i):unpack('b14')
            packet["_unknown1"] = 'b5b8':pack(0, teleport_cost):unpack('b13')
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
        end

        return actions
    end,
    warpdata = T{
        ['Western Adoulin'] = {
            ['Platea'] = { shortcut = '1' },
            ['Triumphus'] = { shortcut = '1' },
            ['Couriers'] = { shortcut = '1' },
            ['Pioneers'] = { shortcut = '2' },
            ['Mummers'] = { shortcut = '3' },
            ['Inventors'] = { shortcut = '4' },
            ['Auction House'] = { shortcut = '5' },
            ['Mog House'] = { shortcut = '6' },
            ['Bridge'] = { shortcut = '7' },
            ['Airship'] = { shortcut = '8' },
            ['Docks'] = { shortcut = '8' },
            ['Waterfront'] = { shortcut = '9' },
            ['1'] = { index = 1, offset = 0, zone = 256, npc = 180, op_z = 1, op_i = 1, sz_oi = 0, x = 4.8960003852844, z = 0, y = -4.7890000343323, h = 33, unknown1 = 0},
            ['2'] = { index = 2, offset = 1, zone = 256, npc = 181, op_z = 1, op_i = 2, sz_oi = 0, x = -110.50000762939, z = 3.8500001430511, y = -13.482000350952, h = 191, unknown1 = 0},
            ['3'] = { index = 3, offset = 2, zone = 256, npc = 182, op_z = 1, op_i = 3, sz_oi = 0, x = -20.982000350952, z = -0.15000000596046, y = -79.891006469727, h = 127, unknown1 = 0},
            ['4'] = { index = 4, offset = 3, zone = 256, npc = 183, op_z = 1, op_i = 4, sz_oi = 0, x = 91.45100402832, z = -0.15000000596046, y = -49.013000488281, h = 0, unknown1 = 0},
            ['5'] = { index = 5, offset = 4, zone = 256, npc = 184, op_z = 1, op_i = 5, sz_oi = 0, x = -68.099006652832, z = 4, y = -73.672004699707, h = 28, unknown1 = 0},
            ['6'] = { index = 6, offset = 5, zone = 256, npc = 185, op_z = 1, op_i = 6, sz_oi = 0, x = 5.7310004234314, z = 0, y = -123.04300689697, h = 127, unknown1 = 0},
            ['7'] = { index = 7, offset = 6, zone = 256, npc = 186, op_z = 1, op_i = 7, sz_oi = 0, x = 174.78300476074, z = 3.8500001430511, y = -35.78800201416, h = 63, unknown1 = 0},
            ['8'] = { index = 8, offset = 7, zone = 256, npc = 187, op_z = 1, op_i = 8, sz_oi = 0, x = 14.586000442505, z = 0, y = 162.60800170898, h = 191, unknown1 = 0},
            ['9'] = { index = 9, offset = 8, zone = 256, npc = 188, op_z = 1, op_i = 9, sz_oi = 0, x = 51.09400177002, z = 32, y = 126.29900360107, h = 191, unknown1 = 0},
        },
        ['Eastern Adoulin'] = {
            ['Peacekeepers'] = { shortcut = '1' },
            ['Scouts'] = { shortcut = '2' },
            ['Statue'] = { shortcut = '3' },
            ['Goddess'] = { shortcut = '3' },
            ['Wharf'] = { shortcut = '4' },
            ['Yahse'] = { shortcut = '4' },
            ['Mog House'] = { shortcut = '5' },
            ['Auction House'] = { shortcut = '6' },
            ['Sverdhried'] = { shortcut = '7' },
            ['Hillock'] = { shortcut = '7' },
            ['Hill'] = { shortcut = '7' },
            ['Coronal'] = { shortcut = '8' },
            ['Esplanade'] = { shortcut = '8' },
            ['Castle'] = { shortcut = '9' },
            ['Gates'] = { shortcut = '9' },
            ['1'] = { index = 21, offset = 15, zone = 257, npc = 126, op_z = 2, op_i = 1, sz_oi = 0, x = -101.2740020752, z = -0.15000000596046, y = -10.726000785828, h = 191, unknown1 = 0},
            ['2'] = { index = 22, offset = 16, zone = 257, npc = 127, op_z = 2, op_i = 2, sz_oi = 0, x = -77.944000244141, z = -0.15000000596046, y = -63.926002502441, h = 0, unknown1 = 0},
            ['3'] = { index = 23, offset = 17, zone = 257, npc = 128, op_z = 2, op_i = 3, sz_oi = 0, x = -46.838001251221, z = -0.075000002980232, y = -12.767000198364, h = 63, unknown1 = 0},
            ['4'] = { index = 24, offset = 18, zone = 257, npc = 129, op_z = 2, op_i = 4, sz_oi = 0, x = -57.773002624512, z = -0.15000000596046, y = 85.237007141113, h = 127, unknown1 = 0},
            ['5'] = { index = 25, offset = 19, zone = 257, npc = 130, op_z = 2, op_i = 5, sz_oi = 0, x = -61.865001678467, z = -0.15000000596046, y = -120.81000518799, h = 127, unknown1 = 0},
            ['6'] = { index = 26, offset = 20, zone = 257, npc = 131, op_z = 2, op_i = 6, sz_oi = 0, x = -42.065002441406, z = -0.15000000596046, y = -89.97900390625, h = 191, unknown1 = 0},
            ['7'] = { index = 27, offset = 21, zone = 257, npc = 132, op_z = 2, op_i = 7, sz_oi = 0, x = 11.681000709534, z = -22.150001525879, y = 29.976001739502, h = 127, unknown1 = 0},
            ['8'] = { index = 28, offset = 22, zone = 257, npc = 133, op_z = 2, op_i = 8, sz_oi = 0, x = 27.124000549316, z = -40.150001525879, y = -60.84400177002, h = 127, unknown1 = 0},
            ['9'] = { index = 29, offset = 23, zone = 257, npc = 134, op_z = 2, op_i = 9, sz_oi = 0, x = 95.994003295898, z = -40.150001525879, y = -74.541000366211, h = 0, unknown1 = 0},
        },
        ['Yahse Hunting Grounds'] = {
            ['Frontier Station'] = { index = 31, offset = 70, zone = 260, npc = 517, op_z = 4, op_i = 1, sz_oi = 1002, x = 321, z = 0, y = -199.80000305176, h = 127, unknown1 = 0},
            ['1'] =                { index = 32, offset = 71, zone = 260, npc = 518, op_z = 4, op_i = 2, sz_oi = 1002, x = 86.500007629395, z = 0, y = 1.5000001192093, h = 0, unknown1 = 0},
            ['2'] =                { index = 33, offset = 72, zone = 260, npc = 519, op_z = 4, op_i = 3, sz_oi = 1002, x = -286.5, z = 0, y = 43.500003814697, h = 127, unknown1 = 0},
            ['3'] =                { index = 34, offset = 73, zone = 260, npc = 520, op_z = 4, op_i = 4, sz_oi = 1002, x = -162.40000915527, z = 0, y = -272.80001831055, h = 191, unknown1 = 0},
        },
        ['Ceizak Battlegrounds'] = {
            ['Frontier Station'] = { index = 41, offset = 64, zone = 261, npc = 524, op_z = 3,    op_i = 1, sz_oi = 1002, x = 365.00003051758, z = 0.60000002384186, y = 190.00001525879, h = 127, unknown1 = 0},
            ['1'] =                   { index = 42, offset = 65, zone = 261, npc = 525, op_z = 3, op_i = 2, sz_oi = 1002, x = -6.8790001869202, z = 0, y = -117.51100921631, h = 63, unknown1 = 0},
            ['2'] =                   { index = 43, offset = 66, zone = 261, npc = 526, op_z = 3, op_i = 3, sz_oi = 1002, x = -42.000003814697, z = 0, y = 155, h = 191, unknown1 = 0},
            ['3'] =                   { index = 44, offset = 67, zone = 261, npc = 527, op_z = 3, op_i = 4, sz_oi = 1002, x = -442.00003051758, z = 0, y = -247.00001525879, h = 191, unknown1 = 0},
        },
        ['Foret de Hennetiel'] = {
            ['Frontier Station'] = { index = 51, offset = 96, zone = 262, npc = 533, op_z = 5,  op_i = 1, sz_oi = 1002, x = 398.11001586914, z = -2, y = 279.11001586914, h = 0, unknown1 = 0},
            ['1'] =                { index = 52, offset = 97, zone = 262, npc = 534, op_z = 5,  op_i = 2, sz_oi = 1002, x = 12.60000038147, z = -2.4000000953674, y = 342.00003051758, h = 0, unknown1 = 0},
            ['2'] =                { index = 53, offset = 98, zone = 262, npc = 535, op_z = 5,  op_i = 3, sz_oi = 1002, x = 505.00003051758, z = -2.25, y = -303.5, h = 127, unknown1 = 0},
            ['3'] =                { index = 54, offset = 99, zone = 262, npc = 536, op_z = 5,  op_i = 4, sz_oi = 1002, x = 103.00000762939, z = -2.2000000476837, y = -92.300003051758, h = 63, unknown1 = 0},
            ['4'] =                { index = 55, offset = 100, zone = 262, npc = 537, op_z = 5, op_i = 5, sz_oi = 1002, x = -251.80001831055, z = -2.3700001239777, y = -39.25, h = 63, unknown1 = 0},
        },
        ['Morimar Basalt Fields'] = {
            ['Frontier Station'] = { index = 61, offset = 102, zone = 265, npc = 736, op_z = 6, op_i = 1, sz_oi = 1002, x = 443.72802734375, z = -16, y = -325.4280090332, h = 191, unknown1 = 0},
            ['1'] =                { index = 62, offset = 103, zone = 265, npc = 737, op_z = 6, op_i = 2, sz_oi = 1002, x = 368.00003051758, z = -16, y = 37.5, h = 127, unknown1 = 0},
            ['2'] =                { index = 63, offset = 104, zone = 265, npc = 738, op_z = 6, op_i = 3, sz_oi = 1002, x = 112.80000305176, z = -0.483000010252, y = 324.40002441406, h = 63, unknown1 = 0},
            ['3'] =                { index = 64, offset = 105, zone = 265, npc = 739, op_z = 6, op_i = 4, sz_oi = 1002, x = 175.50001525879, z = -15.581000328064, y = -318.20001220703, h = 127, unknown1 = 0},
            ['4'] =                { index = 65, offset = 106, zone = 265, npc = 740, op_z = 6, op_i = 5, sz_oi = 1002, x = -323.00003051758, z = -32, y = 2, h = 63, unknown1 = 0},
            ['5'] =                { index = 66, offset = 107, zone = 265, npc = 741, op_z = 6, op_i = 6, sz_oi = 1002, x = -78.200004577637, z = -47.284000396729, y = 303, h = 191, unknown1 = 0},
        },
        ['Yorcia Weald'] = {
            ['Frontier Station'] = { index = 71, offset = 128, zone = 263, npc = 564, op_z = 7, op_i = 1, sz_oi = 1002, x = 353.30001831055, z = 0.20000000298023, y = 153.30000305176, h = 223, unknown1 = 0},
            ['1'] =                { index = 72, offset = 129, zone = 263, npc = 565, op_z = 7, op_i = 2, sz_oi = 1002, x = -40.499000549316, z = 0.36700001358986, y = 296.36700439453, h = 0, unknown1 = 0},
            ['2'] =                { index = 73, offset = 130, zone = 263, npc = 566, op_z = 7, op_i = 3, sz_oi = 1002, x = 122.13200378418, z = 0.14600001275539, y = -287.73101806641, h = 127, unknown1 = 0},
            ['3'] =                { index = 74, offset = 131, zone = 263, npc = 567, op_z = 7, op_i = 4, sz_oi = 1002, x = -274.77600097656, z = 0.3570000231266, y = 85.376007080078, h = 127, unknown1 = 0},
            ['Enigmatic Device'] = { index = 302, offset = 162, zone = 999, op_z = 11, op_i = 3 },
        },
        ['Marjami Ravine'] = {
            ['Frontier Station'] = { index = 81, offset = 134, zone = 266, npc = 414, op_z = 8, op_i = 1, sz_oi = 1002, x = 358.00003051758, z = -60.000003814697, y = 165.00001525879, h = 63, unknown1 = 0},
            ['1'] =                { index = 82, offset = 135, zone = 266, npc = 415, op_z = 8, op_i = 2, sz_oi = 1002, x = 323.00003051758, z = -20, y = -79, h = 0, unknown1 = 0},
            ['2'] =                { index = 83, offset = 136, zone = 266, npc = 416, op_z = 8, op_i = 3, sz_oi = 1002, x = 6.808000087738, z = 0, y = 78.437004089355, h = 191, unknown1 = 0},
            ['3'] =                { index = 84, offset = 137, zone = 266, npc = 417, op_z = 8, op_i = 4, sz_oi = 1002, x = -318.7080078125, z = -20, y = -127.27500915527, h = 63, unknown1 = 0},
            ['4'] =                { index = 85, offset = 138, zone = 266, npc = 418, op_z = 8, op_i = 5, sz_oi = 1002, x = -326.02200317383, z = -40.023002624512, y = 201.09600830078, h = 191, unknown1 = 0},
        },
        ['Kamihr Drifts'] = {
            ['Frontier Station'] = { index = 91, offset = 166, zone = 267, npc = 364, op_z = 9, op_i = 1, sz_oi = 1002, x = 439.40301513672, z = 63.000003814697, y = -272.55401611328, h = 63, unknown1 = 0},
            ['1'] =                { index = 92, offset = 167, zone = 267, npc = 365, op_z = 9, op_i = 2, sz_oi = 1002, x = -42.574001312256, z = 43.000003814697, y = -71.319000244141, h = 0, unknown1 = 0},
            ['2'] =                { index = 93, offset = 168, zone = 267, npc = 366, op_z = 9, op_i = 3, sz_oi = 1002, x = 8.2400007247925, z = 43.000003814697, y = -283.01699829102, h = 191, unknown1 = 0},
            ['3'] =                { index = 94, offset = 169, zone = 267, npc = 367, op_z = 9, op_i = 4, sz_oi = 1002, x = 9.2400007247925, z = 23.000001907349, y = 162.8030090332, h = 63, unknown1 = 0},
            ['4'] =                { index = 95, offset = 170, zone = 267, npc = 368, op_z = 9, op_i = 5, sz_oi = 1002, x = -228.94201660156, z = 3.5670001506805, y = 364.51202392578, h = 127, unknown1 = 0},
        },
        ['Jeuno'] = {
            ['Enigmatic Device'] = { index = 100, offset = 100, zone = 246, op_z = 10, op_i = 0, cost_out = 100 },
        },
        ['Rala Waterways'] = {
            ['Enigmatic Device'] = { index = 300, offset = 160, zone = 258, op_z = 11, op_i = 1, cost_out = 100 },
        },
        ['Cirdas Caverns'] = {
            ['Enigmatic Device'] = { index = 301, offset = 161, zone = 270, op_z = 11, op_i = 2 },
        },
        ['Outer Ra\'Kaznar'] = {
            ['Enigmatic Device'] = { index = 303, offset = 163, zone = 274, op_z = 11, op_i = 4 },
        },
        ['Northern San d\'Oria'] = { index = 200, invoffset = 33, op_z = 12, op_i = 1 }, 
        ['Bastok Markets'] = { index = 201, invoffset = 34, op_z = 12, op_i = 2 }, 
        ['Windurst Woods'] = { index = 202, invoffset = 35, op_z = 12, op_i = 3 }, 
        ['Selbina'] = { index = 203, invoffset = 36, op_z = 12, op_i = 4 }, 
        ['Mhaura'] = { index = 204, invoffset = 37, op_z = 12, op_i = 5 }, 
        ['Kazham'] = { index = 205, invoffset = 38, op_z = 12, op_i = 6 }, 
        ['Rabao'] = { index = 206, invoffset = 39, op_z = 12, op_i = 7 }, 
        ['Norg'] = { index = 207, invoffset = 40, op_z = 12, op_i = 8 }, 
        ['Tavnazian Safehold'] = { index = 208, invoffset = 41, op_z = 12, op_i = 9 }, 
        ['Aht Urhgan Whitegate'] = { index = 209, invoffset = 42, op_z = 12, op_i = 10 }, 
        ['Nashmau'] = { index = 210, invoffset = 43, op_z = 12, op_i = 11 }, 
    },
}
