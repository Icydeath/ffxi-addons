-- /GearSwap/data/library/ is where this file needs to go along with all my library files.

--Sends command to all accounts regardless of who sent it.
function SendCommandAll(sendCommand, alt_names)
    
    if #sendCommand > 0 then
            
        for i,v in pairs(alt_names) do
                send_command('send ' .. v .. ' gs c ' .. sendCommand)
            
	end
        
    end
    
end

--Sends command to all accounts excluding player that sent the command.
function SendCommandOthers(sendCommand, alt_names)
    
    if #sendCommand > 0 then
            
        for i,v in pairs(alt_names) do
                
            if v ~= player.name then
                send_command('send ' .. v .. ' gs c ' .. sendCommand .. '')
                
            end
            
	end
        
    end
    
end

--[[ ---------------------------------------------------------------------------
--------------------------------------------------------------------------------
 All conditional information on how to handle a command when sent by a player to
 to be caught by library must be handled in here. 
    
    * 1 = Send, or catch command. Dictates whether the command is being sent, or caught by player.
    * 2 = Start, or stop command. Dictates whether the command is starting, or stopping.
    * 3 = Name of the command that is being executed.
    
So for instance if you would like to catch a sent command from another account asking for sneak.
The command would look like this:
    
    * catch start sneak
    
Now you can add in as a "elseif" using the following format:

    elseif catchCommand == 'catch start sneak' then
        -- Logic goes here.

Will add more notes as the functionality of this library develops.
--------------------------------------------------------------------------------
--]] ---------------------------------------------------------------------------
function catchCommands(catchCommand, alt_names)
    
    tCommands = processCatch(catchCommand)
    
    if isCatch(tCommands) == true then
        
        -- All command logic for starting a command goes here.
        if isStart(tCommands) == true then
            
            if getAction(tCommands) == 'follow' then
                send_command('follow ' .. getPlayerName(tCommands))
                
            else
                return false
                
            end
            
        -- All command logic for stopping a command goes here.
        else
            
            if getAction(tCommands) == 'follow' then 
                send_command('setkey numpad7 down; wait 0.1; setkey numpad7 up')
                
            else
                return false
                
            end
            
        end
        
    end
    
end

-- Take a catch command, and process it in to a table.
function processCatch(catchCommand)
    tCommands = catchCommand:split(' ')
    return tCommands
    
end

-- Determine from command table if send, or catch. TREU for catch.
function isCatch(tCommands)
    
    if tCommands[1] == 'catch' then
        return true
    end
    
end

-- Determine from command table if start, or stop execution. TRUE for start.
function isStart(tCommands)
    
    if tCommands[2] == 'start' then
        return true
    end
    
end

-- Determine from command table what action to execute.
function getAction(tCommands)
    
    if tCommands[3] then
        return tCommands[3]
    end
    
end

-- Get the sending players name from the command table.
function getPlayerName(tCommands)
    
    if tCommands[4] then
        return tCommands[4]
    end
    
end