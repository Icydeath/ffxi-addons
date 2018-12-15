_addon.name = 'BurstMaster_addon'
_addon.author = 'Daniel_H'
_addon.version = '1.0'
_addon_description = ''
_addon.commands = { 'bm', 'burstmaster' }

-- Some of this information was borrowed from code from: Kenshi, Copyright © 2016
-- UDP connection thanks to several online tutorials

local socket = require( "socket" )

local port = 17896
local ip = "127.0.0.1"

local skillchain = { 'Light', 'Darkness', 'Gravitation', 'Fragmentation', 'Distortion', 'Fusion', 'Compression', 'Liquefaction', 'Induration', 'Reverberation', 'Transfixion', 'Scission', 'Detonation', 'Impaction', 'Radiance', 'Umbra' }; 

function send_required_string( Data )

    local CP_connect = assert( socket.udp( ))
    CP_connect:settimeout( 1 )

    assert( CP_connect:sendto( Data, ip, port ))
    
    CP_connect:close( )
end

if windower then

    -- BEGIN WINDOWER CODE ---------------------------------------------------------------------------------
    
    packets = require( "packets" ) 

    local player = windower.ffxi.get_player( )

    windower.register_event( 'action', function ( data )
        if data.category == 4 and data.target_count > 0 then 
            local actor = windower.ffxi.get_mob_by_id( data.actor_id )

            if actor.in_party or actor.in_alliance then
                if data.targets[ 1 ].actions ~= nil then
                    local action = data.targets[ 1 ].actions[ 1 ]
                    if action.has_add_effect then
                        local msgId = action.add_effect_message
                        windower.add_to_chat( 4, 'Category: '..data.category..' | Msg ID: '..msgId )
                    end
                end
            end
        end
    end )


    -- END WINDOWER CODE -----------------------------------------------------------------------------------

elseif ashita then

    -- BEGIN ASHITA CODE -----------------------------------------------------------------------------------

    require 'common'
    local party = AshitaCore:GetDataManager( ):GetParty( )

    ashita.register_event( 'incoming_packet', function( id, size, data )

        if id == 0xB then
            zoning_bool = true
        elseif id == 0xA and zoning_bool then
            zoning_bool = false
        end

        if not zoning_bool then 
            if id == 0x28 then
                actorName = "None" -- Always set to None to reset the name

                local party = AshitaCore:GetDataManager( ):GetParty( ); 
                local actor = struct.unpack( 'I', data, 6 ); 
                local category = ashita.bits.unpack_be( data, 82, 4 ); 

                if ( category == 3 ) then
                    local prop = skillchain[ ashita.bits.unpack_be( data, 272, 6 )]; 
                    
                    if prop and category == 3 then
                        for i = 0, 16 do
                            if party:GetMemberName( i ) ~= nil then
                                if ( actor == party:GetMemberServerId( i )) then
                                    actorName = party:GetMemberName( i )
                                    break
                                end
                            end
                        end
                        if actorName ~= None then
                            createdDataString = prop.."_"..os_time( )
                            send_required_string( createdDataString )
                            --print(string.format('\31\208 The following skillchain was found: '..prop.. ' '..category..' '..actor..' '..actorName)); -- ASHITA WORKING
                        end
                    end
                end
            end
        end 
        return false; 
    end ); 

    -- END ASHITA CODE -------------------------------------------------------------------------------------

end






















