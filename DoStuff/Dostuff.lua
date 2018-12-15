--[[
dostuff v1.2014.09.29
Copyright (c) 2014, Mujihina
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of castcrap2 nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mujihina BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name    = 'dostuff'
_addon.author  = 'Mujihina'
_addon.version = '1.2014.09.29'
_addon.command = 'dostuff'
_addon.commands = {'dos'}


-- Required libraries
-- luau
require ('luau')

-- Global vars
dos_enable = false
dos_cmd = ""
dos_count = 0
dos_delay = 5
dos_left = 0
dos_loop_forever = false



-- Show syntax
function show_syntax()
    windower.add_to_chat (200, 'DoStuff: Syntax is:')
    windower.add_to_chat (207, '    \'DoStuff list\' : Review current settings')
    windower.add_to_chat (207, '    \'DoStuff start\': Start doing stuff')
    windower.add_to_chat (207, '    \'DoStuff stop\' : Stop doing stuff')
    windower.add_to_chat (207, '    \'DoStuff cmd\'  : Specify command')
    windower.add_to_chat (207, '    \'DoStuff count\': Specify count (0 will loop forever)')
    windower.add_to_chat (207, '    \'DoStuff delay\': Specify delay (default is 5 secs)')
end


function tick()
    if (not dos_enable) then return end
    windower.send_command ("input %s":format(dos_cmd))
    if (dos_left > 0)  then dos_left = dos_left - 1 end
    if (dos_loop_forever or dos_left > 0) then 
        windower.send_command ("wait %d ; lua i dostuff tick":format(dos_delay))
    else
        print ("DoStuff: Done doing stuff")
        dos_enable = false
    end
end


-- Parse and process commands
function dos_command (cmd, ...)
    if (not cmd or cmd == 'help' or cmd == 'h') then
        show_syntax()
        return
    end          

    local args = L{...}

    -- Stop
    if (cmd == 'stop') then
        if (dos_enable) then
            dos_enable = false
               dos_loop_forever = false
            print ("DoStuff has been stopped")
            return
        end
        print ("DoStuff was already stopped")
        return
    end

    -- Start
    if (cmd == 'start') then
        if (dos_enable) then
            print ("DoStuff is already running")
            return
        end
        if (dos_cmd:length() < 1) then
            print ("There is no cmd to execute")
            return
        end
        if (dos_count == 0) then 
            dos_loop_forever = true
        else
            dos_loop_forever = false
            dos_left = dos_count
        end

        dos_enable = true
        print ("Starting DoStuff")
        windower.send_command ("lua i dostuff tick")
       return
    end

    -- list
    if (cmd == 'list') then
        if (dos_enable) then
            print ("Cmd: %s\nDelay: %d\nCount: %d (Current Remaining: %d)":format(dos_cmd, dos_delay, dos_count, dos_left))
        else
            print ("Cmd: %s\nDelay: %d\nCount: %d":format(dos_cmd, dos_delay, dos_count))
        end
        return
    end

    -- Need more args from here on
    if (args:length() < 1) then
        print ('DoStuff: Check your syntax')
        return
    end
    
    local input = args:concat(' ')
    
    -- cmd
    if (cmd == 'cmd') then
        dos_cmd = input
        print ("DoStuff cmd is now: %s":format(dos_cmd))
        return
    end

    -- count
    if (cmd == 'count') then
            -- only accept patterns with 0-9
            if (not windower.regex.match(input, "^[0-9]+$")) then
                print ("DoStuff: Rejecting count. Not a number")
                return
            end
        dos_count = tonumber(input)
        print ("DoStuff count is now: %d":format(dos_count))
        return
    end

    -- delay
    if (cmd == 'delay') then
            -- only accept patterns with 0-9
            if (not windower.regex.match(input, "^[0-9]+$")) then
                print ("DoStuff: Rejecting count. Not a number")
                return
            end
        dos_delay = tonumber(input)
        print ("DoStuff delay is now: %d":format(dos_delay))
        return
    end

    -- Show Syntax
    print("DoStuff: Check your syntax")
end



-- Register callbacks
windower.register_event ('addon command', dos_command)