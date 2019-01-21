--[[
Copyright © 2016, Inuyushi (Asura)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

_addon.name = 'Prickly_Melee'
_addon.author = 'Inuyushi (Melee Adjustment Daniel_H) (Further Adjustment Flamethrower)'
_addon.version = '0.0.0.1'
_addon.commands = { 'prick', 'prickly' }
_addon.language = 'english'

running = false
keeprunningwhencapped = false -- change this to keep popping even if you are capped on sparks
poptarget = "Ethereal Junction"
nmname = "Prickly Pitriv"
useitemname = "Pitriv's Coffer"
weaponskill = 'None'
WarpType = "ring"

coffercount = 0

function check_incoming_text( original )
    local org = original:lower( )

    if org:find( 'sparks of eminence, and now possess a total of 99999' ) ~= nil and not keeprunningwhencapped then
        running = false
    elseif org:find( 'one or more party/alliance members do not have the required 200 unity accolades to join the fray' ) ~= nil then
        running = false
    end
end

function buff_loss( lb )
    if lb == 431 then
        favor = false
    end
end

function check( )
    windower.send_command( 'setkey ESCAPE down' )
    coroutine.sleep( 0.5 )
    windower.send_command( 'setkey ESCAPE up' )
    coroutine.sleep( 0.1 )
    windower.chat.input( "/targetnpc" )
    coroutine.sleep( 2 )

    if running == true then

        player = windower.ffxi.get_player( )

        if windower.ffxi.get_mob_by_target( 't' ) == nil then
            windower.add_to_chat( 167, 'No target found. Running check again.' )
            coroutine.sleep( 10 )
            check( )
        elseif windower.ffxi.get_mob_by_target( 't' ).name == nmName then
            if player.status ~= 1 then
                windower.chat.input( "/attack" )
                coroutine.sleep( 2 )
                check( )
            elseif player.status == 1 then
                if player.vitals[ 'tp' ] > 1000 and weaponskill ~= "None" then
                    windower.chat.input( "/ws "..weaponskill.." <t>" )
                end
                coroutine.sleep( 2 )
                check( )
            end

        elseif windower.ffxi.get_mob_by_target( 't' ).name == poptarget then
            prick( )
        else
            windower.add_to_chat( 167, 'Invalid target. Escaping and rechecking.' )
            windower.send_command( 'setkey ESCAPE down' )
            coroutine.sleep( 0.5 )
            windower.send_command( 'setkey ESCAPE up' )
            coroutine.sleep( 1.5 )
            check( )
        end
    else
        windower.add_to_chat( 167, 'Running is false during check()' )

        if WarpType == "ring" then
            windower.chat.input( "/equip ring1 \"Warp Ring\"" )
            coroutine.sleep( 12 )
            windower.chat.input( "/item \"Warp Ring\" <me>" )
        elseif WarpType == "spell" then
            windower.chat.input( "/ma \"Warp II\" <me>" )
        elseif WarpType == "scroll" then
            windower.chat.input( "/item \"Instant Warp\" <me>" )
        else
            windower.add_to_chat( 167, 'Warp type is wrong, use either ring, scroll or spell. Currently: '..WarpType )
        end
    end
end

function prick( )
    windower.send_command( 'setkey enter down' )
    coroutine.sleep( 0.5 )
    windower.send_command( 'setkey enter up' )
    coroutine.sleep( 1.5 )

    windower.send_command( 'setkey up down' )
    coroutine.sleep( 0.5 )
    windower.send_command( 'setkey up up' )
    coroutine.sleep( 0.5 )

    windower.send_command( 'setkey enter down' )
    coroutine.sleep( 0.5 )
    windower.send_command( 'setkey enter up' )
    coroutine.sleep( 5 )

    windower.chat.input( "/targetnpc" )
    coroutine.sleep( 0.5 )
    windower.chat.input( "/attack" )

    if running == true then
        coroutine.sleep( 5 )
        check( )
    else
        windower.add_to_chat( 167, 'Stopping Prickly during prick()' )
        windower.chat.input( "/ma \"Warp II\" <me>" )
    end
end

function unloadcoffer( )
    if coffercount > 0 then
        coffercount = coffercount - 1
        windower.chat.input( "/item \""..useitemname.."\" <me>" )
        coroutine.sleep( 3 )
        unloadcoffer( )
    else
        windower.add_to_chat( 200, 'All coffers used.' )
    end
end

function prick_command( ... )
    if #arg > 5 then
        windower.add_to_chat( 167, 'Invalid command. //prick help for valid options.' )
    elseif #arg == 1 and arg[ 1 ]:lower( ) == 'start' then
        if running == false then
            running = true
            windower.add_to_chat( 200, 'Prickly - START' )
            check( )
        else
            windower.add_to_chat( 200, 'Prickly is already running.' )
        end
    elseif #arg == 1 and arg[ 1 ]:lower( ) == 'stop' then
        if running == true then
            running = false
            windower.add_to_chat( 200, 'Prickly - STOP' )
        else
            windower.add_to_chat( 200, 'Prickly is not running.' )
        end
    elseif #arg == 2 and arg[ 1 ]:lower( ) == 'unload' then
        coffercount = tonumber( arg[ 2 ])
        unloadcoffer( )
    elseif #arg == 2 or #arg == 3 or #arg == 4 and arg[ 1 ] == 'weaponskill' then
        if #arg == 4 then
            weaponskill = arg[ 2 ] .. " "..arg [ 3 ] .. " "..arg [ 4 ] 
        elseif #arg == 3 then
            weaponskill = arg[ 2 ] .. " "..arg [ 3 ] 
        else
            weaponskill = arg [ 2 ]
        end
        windower.add_to_chat( 200, '  Weaponskill set to: '..weaponskill )

    elseif #arg == 1 and arg[ 1 ]:lower( ) == 'help' then
        windower.add_to_chat( 200, 'Available Options:' )
        windower.add_to_chat( 200, '  //prick weaponskill # - Sets the weaponskill to use when in combat' )
        windower.add_to_chat( 200, '  //prick warp # - Sets the Warp type, echoices: spell, ring, scroll (DEFAULT: Ring)' )
        windower.add_to_chat( 200, '  //prick start - turns on Prickly and starts trying to kill' )
        windower.add_to_chat( 200, '  //prick stop - turns off Prickly' )
        windower.add_to_chat( 200, '  //prick unload # - uses a specified amount of coffers' )
        windower.add_to_chat( 200, '  //prick help - displays this text' )
    end
end

windower.register_event( 'lose buff', buff_loss )
windower.register_event( 'addon command', prick_command )
windower.register_event( 'incoming text', function( new, old )
    local info = windower.ffxi.get_info( )
    if not info.logged_in then
        return
    else
        check_incoming_text( new )
    end
end )


