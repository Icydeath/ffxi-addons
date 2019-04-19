_addon.name     = 'mymooglebish'
_addon.author   = 'Elidyr'
_addon.version  = '1.5162018'
_addon.command  = 'mmb'

packets         = require('packets')
res             = require('resources')
trades          = require('trades')

local function handle_command(command, ...)
    
    local cmd       = (command) and (command):lower()
    local args      = {...}
    local moogles   = {17797256,17739948,17723669,17760464,17780978,17809527,17821671,16994436,17793136}
    local jobs      = T{"war","mnk","whm","blm","rdm","thf","pld","drk","bst","brd","rng","sam","nin","drg","smn","blu","cor","pup","dnc","sch","geo","run"}
    
    if cmd then
        
        if cmd:sub(1,1) == 'g' then
            
            if cmd:sub(2,2) then
                
                if cmd:sub(2,2) == 'a' then
                    
                    if cmd:sub(3,3) == '0' then
                    
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 15'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 16'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 24'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '3' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 25'])
                            
                        end
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                elseif cmd:sub(2,2) == 'r' then
                    
                    if cmd:sub(3,3) == '0' then
                    
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 17'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 18'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 26'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '3' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 27'])
                            
                        end
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                elseif cmd:sub(2,2) == 'e' then
                    
                    if cmd:sub(3,3) == '0' then
                    
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 20'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades['Slip 21'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' then
                        windower.add_to_chat(22, 'Empyrean +2 does not exist!')
                        
                    elseif cmd:sub(3,3) == '3' then
                        windower.add_to_chat(22, 'Empyrean +3 does not exist!')
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                else
                    windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                    
                end
                
            else
                windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                
            end
            
        elseif cmd:sub(1,1) == 'p' then
            
            if cmd:sub(2,2) then
                
                if cmd:sub(2,2) == 'a' and args[1] then
                    
                    if cmd:sub(3,3) == '0' and jobs:contains(args[1]:lower()) then
                    
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF10'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' and jobs:contains(args[1]:lower()) then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF11'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' and jobs:contains(args[1]:lower()) then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF12'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '3' and jobs:contains(args[1]:lower()) then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF13'])
                            
                        end
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                elseif cmd:sub(2,2) == 'r' and args[1] then
                    
                    if cmd:sub(3,3) == '0' and jobs:contains(args[1]:lower()) then

                    
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF20'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' and jobs:contains(args[1]:lower()) then

                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF21'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' and jobs:contains(args[1]:lower()) then

                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF22'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '3' and jobs:contains(args[1]:lower()) then

                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF23'])
                            
                        end
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                elseif cmd:sub(2,2) == 'e' and args[1] then
                    
                    if cmd:sub(3,3) == '0' and jobs:contains(args[1]:lower()) then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF30'])
                            
                        end
                    
                    elseif cmd:sub(3,3) == '1' and jobs:contains(args[1]:lower()) then
                        
                        if findMoogle(moogles) then
                            
                            local mog = findMoogle(moogles)
                            tradeNPC(mog, trades[args[1]:upper() .. ' AF31'])
                            
                        end
                        
                    elseif cmd:sub(3,3) == '2' and jobs:contains(args[1]:lower()) then
                        windower.add_to_chat(22, 'Empyrean +2 does not exist!')
                        
                    elseif cmd:sub(3,3) == '3' and jobs:contains(args[1]:lower()) then
                        windower.add_to_chat(22, 'Empyrean +3 does not exist!')
                        
                    else
                        windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                        
                    end
                    
                else
                    windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                    
                end
                
            else
                windower.add_to_chat(22, 'Error: Invalid command! //mmb help - for more information.')
                
            end
        
        elseif cmd == 'help' or cmd == 'h' then
                 windower.add_to_chat(22, 'Commands: (format: //mmb {g | p} {a | r | e} {0 | 1 | 1 | 3} {JOB}')
                 windower.add_to_chat(22, 'Commands: (format: {g | p} = get / put')
                 windower.add_to_chat(22, 'Commands: (format: {a | r | e} = artifact / relic / empyrean')
                 windower.add_to_chat(22, 'Commands: (format: {0 | 1 | 2 | 3} = 109 / 119 / +2 / +3')
                 windower.add_to_chat(22, 'Commands: (format: {JOB} = Job of gear you want to put away.')
                 windower.add_to_chat(22, 'Commands: (Example: //mmb pa0 war')
                
        elseif cmd == 'reload' or cmd == 'rl' then
                windower.send_command('lua reload mymooglebish') 
            
        end
    
    else
        error("Unknown command.")
    
    end

end

windower.register_event('addon command', handle_command)

---------------------------------------------------------------------------
-- Find Nearest moogle.
---------------------------------------------------------------------------
-- @param moogles
-- @return mog

function findMoogle(moogles)
    
    for i, v in ipairs(moogles) do
        
       if windower.ffxi.get_mob_by_id(v) then
           return windower.ffxi.get_mob_by_id(v)
           
        end
    
    end

    return false

end

---------------------------------------------------------------------------
-- Trade to NPC.
---------------------------------------------------------------------------
-- @param npc
-- @param items
-- @param count

function tradeNPC(npc, items)
    
    if npc and items then
        
        local _L = {}
            
            _L.itemcount1 = 0
            _L.itemcount2 = 0
            _L.itemcount3 = 0
            _L.itemcount4 = 0
            _L.itemcount5 = 0
            _L.itemcount6 = 0
            _L.itemcount7 = 0
            _L.itemcount8 = 0
            _L.itemcount9 = 0
            _L.itemindex1 = 0
            _L.itemindex2 = 0
            _L.itemindex3 = 0
            _L.itemindex4 = 0
            _L.itemindex5 = 0
            _L.itemindex6 = 0
            _L.itemindex7 = 0
            _L.itemindex8 = 0
            _L.itemindex9 = 0
            _L.quantity   = 0
    
        for i, v in ipairs(items) do
            
            if v ~= 0 then
                
                local index, count, itemid = findItem(v)
                
                if index and count then
                    
                    _L['quantity']       = _L['quantity'] + 1
                    
                    local q = tostring(_L.quantity)
                    
                    _L['itemcount' .. q] = count
                    _L['itemindex' .. q] = index
                    
                end
                
            end
            
        end
        
        local p = packets.new('outgoing', 0x036, {
            ['Target']          = npc.id,
            ['Item Count 1']    = _L.itemcount1,
            ['Item Count 2']    = _L.itemcount2,
            ['Item Count 3']    = _L.itemcount3,
            ['Item Count 4']    = _L.itemcount4,
            ['Item Count 5']    = _L.itemcount5,
            ['Item Count 6']    = _L.itemcount6,
            ['Item Count 7']    = _L.itemcount7,
            ['Item Count 8']    = _L.itemcount8,
            ['Item Count 9']    = _L.itemcount9,
            ['Item Index 1']    = _L.itemindex1,
            ['Item Index 2']    = _L.itemindex2,
            ['Item Index 3']    = _L.itemindex3,
            ['Item Index 4']    = _L.itemindex4,
            ['Item Index 5']    = _L.itemindex5,
            ['Item Index 6']    = _L.itemindex6,
            ['Item Index 7']    = _L.itemindex7,
            ['Item Index 8']    = _L.itemindex8,
            ['Item Index 9']    = _L.itemindex9,
            ['Target Index']    = npc.index,
            ['Number of Items'] = _L.quantity,
        })
    
        packets.inject(p)
    
    end

end

---------------------------------------------------------------------------
-- Find item from item ID.
---------------------------------------------------------------------------
-- @param itemId
-- @return index, itemcount

function findItem(itemId)
    
    local items = windower.ffxi.get_items(0)
    
    for index, item in ipairs(items) do
        
        if item and item.id == itemId and item.status == 0 then
            return index, item.count, item.id
            
        
        end
    
    end
    
    return false

end