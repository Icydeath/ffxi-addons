return T{ -- option: 1
    short_name = 'sg',
    long_name = 'survival guide',
    npc_plural = 'survival guides',
    npc_names = T{
        warp = T{'Survival Guide'},
    },
    validate = function(menu_id, zone, current_activity)
        if not(menu_id == 8500 or menu_id == 8501) then
            return "Incorrect menu detected! Menu ID: "..menu_id
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bit_start = 12*8

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
    help_text = "[sw] sg [warp/w] [all/a/@all] zone name -- warp to a designated survival guide. \"all\" sends ipc to all local clients.",
    sub_zone_targets = S{},
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local gil = p["Menu Parameters"]:unpack('I', 9)
        local valor = p["Menu Parameters"]:unpack('H', 7)    

        local thrifty_transit = menu == 8501

        local unlock_bit_start = 12*8

        debug('guide is unlocked: '..tostring(has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset)))

        if not has_bit(p["Menu Parameters"], unlock_bit_start + destination.offset) then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Destination Survival Guide is not unlocked yet!'})
            return actions
        end

        debug('gil: '..gil.." valor: "..valor)

        local currency_stock = gil
        local currency_name = 'gil'
        local currency_minimum = 200
        -- during Thrifty Transit, the gil packet is used, but no gil is removed.
        local use_tabs_at_survival_guides = not thrifty_transit and settings.use_tabs_at_survival_guides
        if use_tabs_at_survival_guides then
            if valor < 10 then
                log("Valor point stock is too low to use. Using gil instead.")
                use_tabs_at_survival_guides = false
            else
                currency_stock = valor
                currency_name = 'valor points'
                currency_minimum = 10
            end
        end

        if currency_stock < currency_minimum then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Not enough '..currency_name..'!'})
            return actions
        end

        -- update request
        packet = packets.new('outgoing', 0x016)
        packet["Target Index"] = windower.ffxi.get_player().index
        actions:append(T{packet=packet, description='update request'})

        -- menu change
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        packet["Option Index"] = 7
        packet["_unknown1"] = 0
        packet["Automated Message"] = true
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='menu change'})

        -- request map
        packet = packets.new('outgoing', 0x114)
        actions:append(T{packet=packet, wait_packet=0x05C, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='request map'})

        -- menu change
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        packet["Option Index"] = 1
        packet["_unknown1"] = 0
        packet["Automated Message"] = true
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, delay=0.2, description='menu change'})
    
        -- request warp
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Target Index"] = npc.index
        packet["Zone"] = zone
        packet["Menu ID"] = menu

        if use_tabs_at_survival_guides then
            packet["Option Index"] = 257
        else
            packet["Option Index"] = 1
        end
        packet["_unknown1"] = destination.index
        packet["Automated Message"] = false
        packet["_unknown2"] = 0
        actions:append(T{packet=packet, wait_packet=0x05C, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='send options and complete menu'})

        return actions
    end,
    warpdata = T{
        ["Northern San d'Oria"] = {index =  0, offset = 24, zone = 231, },
        ["Bastok Mines"] = {index =  1, offset = 25, zone = 234, },
        ["Port Windurst"] = {index =  2, offset = 26, zone = 240, },
        ["Ru'Lude Gardens"] = {index =  3, offset = 27, zone = 243, },
        ["Tavnazian Safehold"] = {index =  4, offset = 83, zone = 26, },
        ["Aht Urhgan Whitegate"] = {index =  5, offset = 84, zone = 50, },
        ["West Ronfaure"] = {index =  6, offset =  0, zone = 100, },
        ["Fort Ghelsba"] = {index =  7, offset = 34, zone = 141, },
        ["Bostaunieux Oubliette"] = {index =  8, offset = 19, zone = 167, },
        ["King Ranperre's Tomb"] = {index =  9, offset = 41, zone = 190, },
        ["La Theine Plateau"] = {index = 10, offset = 28, zone = 102, },
        ["Valkurm Dunes"] = {index = 11, offset =  1, zone = 103, },
        ["Konschtat Highlands"] = {index = 12, offset = 30, zone = 108, },
        ["Ordelle's Caves"] = {index = 13, offset = 44, zone = 193, },
        ["Gusgen Mines"] = {index = 14, offset = 45, zone = 196, },
        ["Carpenters' Landing"] = {index = 15, offset = 55, zone = 2, },
        ["Jugner Forest"] = {index = 16, offset =  2, zone = 104, },
        ["Batallia Downs"] = {index = 17, offset = 29, zone = 105, },
        ["Davoi"] = {index = 18, offset = 36, zone = 149, },
        ["The Eldieme Necropolis"] = {index = 19, offset = 21, zone = 195, },
        ["North Gustaberg"] = {index = 20, offset =  3, zone = 106, },
        ["Zeruhn Mines"] = {index = 21, offset = 96, zone = 172, },
        ["Korroloka Tunnel"] = {index = 22, offset = 50, zone = 173, },
        ["Dangruf Wadi"] = {index = 23, offset = 42, zone = 191, },
        ["Pashhow Marshlands"] = {index = 24, offset =  4, zone = 109, },
        ["Rolanberry Fields"] = {index = 25, offset = 31, zone = 110, },
        ["Beadeaux"] = {index = 26, offset = 35, zone = 147, },
        ["Crawlers' Nest"] = {index = 27, offset = 22, zone = 197, },
        ["West Sarutabaruta"] = {index = 28, offset =  5, zone = 115, },
        ["Toraimarai Canal"] = {index = 29, offset = 20, zone = 169, },
        ["Inner Horutoto Ruins"] = {index = 30, offset = 43, zone = 192, },
        ["Bibiki Bay"] = {index = 31, offset = 56, zone = 4, },
        ["Tahrongi Canyon"] = {index = 32, offset = 32, zone = 117, },
        ["Buburimu Peninsula"] = {index = 33, offset =  6, zone = 118, },
        ["Maze of Shakhrami"] = {index = 34, offset = 46, zone = 198, },
        ["Labyrinth of Onzozo"] = {index = 35, offset = 54, zone = 213, },
        ["Meriphataud Mountains"] = {index = 36, offset = 10, zone = 119, },
        ["Sauromugue Champaign"] = {index = 37, offset = 33, zone = 120, },
        ["Castle Oztroja"] = {index = 38, offset = 37, zone = 151, },
        ["Garlaige Citadel"] = {index = 39, offset = 23, zone = 200, },
        ["Beaucedine Glacier"] = {index = 40, offset =  7, zone = 111, },
        ["Ranguemont Pass"] = {index = 41, offset = 39, zone = 166, },
        ["Xarcabard"] = {index = 42, offset =  8, zone = 112, },
        ["Castle Zvahl Baileys"] = {index = 43, offset = 38, zone = 161, },
        ["Qufim Island"] = {index = 44, offset =  9, zone = 126, },
        ["Behemoth's Dominion"] = {index = 45, offset = 92, zone = 127, },
        ["Lower Delkfutt's Tower"] = {index = 46, offset = 40, zone = 184, },
        ["The Sanctuary of Zi'Tah"] = {index = 47, offset = 11, zone = 121, },
        ["Ro'Maeve"] = {index = 48, offset = 47, zone = 122, },
        ["Dragon's Aery"] = {index = 49, offset = 93, zone = 154, },
        ["Eastern Altepa Desert"] = {index = 50, offset = 12, zone = 114, },
        ["Western Altepa Desert"] = {index = 51, offset = 48, zone = 125, },
        ["Rabao"] = {index = 52, offset = 82, zone = 247, },
        ["Cape Teriggan"] = {index = 53, offset = 13, zone = 113, },
        ["Valley of Sorrows"] = {index = 54, offset = 94, zone = 128, },
        ["Kuftal Tunnel"] = {index = 55, offset = 51, zone = 174, },
        ["Gustav Tunnel"] = {index = 56, offset = 53, zone = 212, },
        ["Yuhtunga Jungle"] = {index = 57, offset = 14, zone = 123, },
        ["Sea Serpent Grotto"] = {index = 58, offset = 52, zone = 176, },
        ["Kazham"] = {index = 59, offset = 80, zone = 250, },
        ["Norg"] = {index = 60, offset = 81, zone = 252, },
        ["Yhoator Jungle"] = {index = 61, offset = 15, zone = 124, },
        ["Temple of Uggalepih"] = {index = 62, offset = 49, zone = 159, },
        ["Ifrit's Cauldron"] = {index = 63, offset = 95, zone = 205, },
        ["Ru'Aun Gardens"] = {index = 64, offset = 17, zone = 130, },
        ["Oldton Movalpolos"] = {index = 65, offset = 18, zone = 11, },
        ["Lufaise Meadows"] = {index = 66, offset = 16, zone = 24, },
        ["Misareaux Coast"] = {index = 67, offset = 57, zone = 25, },
        ["Phomiuna Aqueducts"] = {index = 68, offset = 58, zone = 27, },
        ["Sacrarium"] = {index = 69, offset = 59, zone = 28, },
        ["Wajaom Woodlands"] = {index = 70, offset = 60, zone = 51, },
        ["Mamook"] = {index = 71, offset = 61, zone = 65, },
        ["Aydeewa Subterrane"] = {index = 72, offset = 62, zone = 68, },
        ["Halvung"] = {index = 73, offset = 91, zone = 62, },
        ["Nashmau"] = {index = 74, offset = 85, zone = 53, },
        ["Arrapago Reef"] = {index = 75, offset = 90, zone = 54, },
        ["Caedarva Mire"] = {index = 76, offset = 89, zone = 79, },
        ["Southern San d'Oria [S]"] = {index = 77, offset = 86, zone = 80, },
        ["East Ronfaure [S]"] = {index = 78, offset = 63, zone = 81, },
        ["Jugner Forest [S]"] = {index = 79, offset = 64, zone = 82, },
        ["Batallia Downs [S]"] = {index = 80, offset = 66, zone = 84, },
        ["The Eldieme Necropolis [S]"] = {index = 81, offset = 79, zone = 175, },
        ["Bastok Markets [S]"] = {index = 82, offset = 87, zone = 87, },
        ["North Gustaberg [S]"] = {index = 83, offset = 67, zone = 88, },
        ["Grauberg [S]"] = {index = 84, offset = 68, zone = 89, },
        ["Vunkerl Inlet [S]"] = {index = 85, offset = 65, zone = 83, },
        ["Pashhow Marshlands [S]"] = {index = 86, offset = 69, zone = 90, },
        ["Rolanberry Fields [S]"] = {index = 87, offset = 70, zone = 91, },
        ["Crawlers' Nest [S]"] = {index = 88, offset = 78, zone = 171, },
        ["Windurst Waters [S]"] = {index = 89, offset = 88, zone = 94, },
        ["West Sarutabaruta [S]"] = {index = 90, offset = 71, zone = 95, },
        ["Fort Karugo-Narugo [S]"] = {index = 91, offset = 72, zone = 96, },
        ["Meriphataud Mountains [S]"] = {index = 92, offset = 73, zone = 97, },
        ["Sauromugue Champaign [S]"] = {index = 93, offset = 74, zone = 98, },
        ["Garlaige Citadel [S]"] = {index = 94, offset = 77, zone = 164, },
        ["Beaucedine Glacier [S]"] = {index = 95, offset = 75, zone = 136, },
        ["Castle Zvahl Baileys [S]"] = {index = 96, offset = 76, zone = 138, },
        ["Eastern Adoulin"] = {index = 97, offset = 97, zone = 257, },
    },
}
