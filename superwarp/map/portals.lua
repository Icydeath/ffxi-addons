return T{
    short_name = 'po',
    long_name = 'runic portal',
    npc_plural = 'runic portals',
    npc_names = T{
        warp = T{'Runic Portal'},
        ['return'] = T{'Runic Portal'},
        assault = T{'Runic Portal'},
    },
    validate = function(menu_id, zone, current_activity)
        if (current_activity.sub_cmd == nil or current_activity.sub_cmd == 'assault') and zone ~= 50 then
            return "Not in Whitegate!"
        end
        if current_activity.sub_cmd == 'return' and not S{79, 52, 61, 54, 72}:contains(zone) then
            return "Not in an assault staging point!"
        end
        if not (menu_id == 101 or -- no assaults

               (menu_id >= 120 and menu_id <= 215) or -- assaults.

               menu_id == 131 or -- Leujaoam
               menu_id == 134 or -- Periqia
               menu_id == 109 or -- mamool Ja
               menu_id == 109 or -- Lebros
               menu_id == 109 or -- Ilrusi
               menu_id == 117 or menu_id == 118) then -- Nyzul 
            return "Incorrect menu detected! Menu ID: "..menu_id
        end

        if current_activity.sub_cmd == nil and menu_id ~= 101 then
            return "Assault orders active. Use \"po assault\" to be taken to your assault destination."
        end
        if current_activity.sub_cmd == 'assault' and menu_id == 101 then
            return "No assault orders active."
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        local unlock_bit_start = 32

        if zone ~= 50 then
            return nil, 'You cannot check missing destinations from here.'
        end

        for z, zd in pairs(warpdata) do
            if not zd.shortcut then
                if zd.index then
                    if not has_bit(p["Menu Parameters"], unlock_bit_start + zd.index) then
                        missing:append(z)
                    end
                end
            end
        end
        return missing
    end,
    help_text = "[sw] po [warp/w] [all/a/@all] staging point -- warp to a designated staging point.\n[sw] po [all/a/@all] return -- Return to Whitegate from the staging point.\n[sw] po [all/a/@all] assault -- Head to your current assault tag location.\n[sw] ew [all/a/@all] domain return -- return Elvorseal.\n[sw] ew [all/a/@all] exit -- leave escha.",
    sub_zone_targets =  nil,
    auto_select_zone = function(zone)
    end,
    build_warp_packets = function(current_activity, zone, p, settings)
        local actions = T{}
        local packet = nil
        local menu = p["Menu ID"]
        local npc = current_activity.npc
        local destination = current_activity.activity_settings

        local is_stock = p["Menu Parameters"]:unpack('i', 13)
        local captain = p["Menu Parameters"]:unpack('b4', 17) == 1
        local unlock_bit_start = 32

        local portal_unlocked = has_bit(p["Menu Parameters"], unlock_bit_start + destination.index)
        debug('portal unlocked: '..tostring(portal_unlocked))

        if not portal_unlocked then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Destination Runic Portal is not unlocked yet!'})
            return actions
        end

        debug('captain: '..tostring(captain)..' imperial standing: '..is_stock)
        if not captain and is_stock < 200 then
            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 16384
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='cancel menu', message='Not enough Imperial Standing!'})
            return actions
        end

        local option = destination.index
        if not captain then
            option = option + 1000 -- use IS if not captain.
        end
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Option Index"] = option
        packet["_unknown1"] = 0
        packet["Target Index"] = npc.index
        packet["Automated Message"] = false
        packet["_unknown2"] = 0
        packet["Zone"] = zone
        packet["Menu ID"] = menu
        actions:append(T{packet=packet, delay=1+wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='warp to staging point'})

        return actions
    end,
    sub_commands = {
        ['return'] = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p['Menu ID']
            local npc = current_activity.npc

            log("Returning to Whitegate...")

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 0
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='change menu'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, delay=1+wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='warp to whitegate'})

            return actions
        end,
        assault = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p['Menu ID']
            local npc = current_activity.npc

            log("Warping to assault orders staging point...")            

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, delay=1+wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='warp to staging point'})
            
            return actions
        end,
    },
    warpdata = T{
        ['Azouph Isle'] = T{ index = 1},
        ['Leujaoam Sanctum'] = T{ index = 1},

        ['Dvucca Isle'] = T{ index = 2},
        ['Periqia'] = T{ index = 2},

        ['Mamool Ja Training Grounds'] = T{ index = 3},

        ['Halvung'] = T{ index = 4},
        ['Lebros Caverns'] = T{ index = 4},

        ['Ilrusi Atoll'] = T{ index = 5},

        ['Nyzul Isle'] = T{ index = 6},
    },
}