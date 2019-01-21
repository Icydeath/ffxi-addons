--[[

Copyright © 2016, Elidyr
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

################################################################################################

BuddyPal: Helper functions library **

    * 8/29/2016 | v1.0.2.1
        - Created separate actions library.
        - Added all main functions from initial build in to this library.
]]

local helpers = {}

--[[ loadJobFunctions(main, subj) **
    Autoloads the libraries for current job.
    
    * main: job name short. (WAR)
    * subj: sub job name short. (WAR)
        
]]
function helpers.loadJobFunctions(main, subj)
    
    local main = string.lower(main)
    local subj = string.lower(subj)
        
    local file1 = "job." .. main
    local file2 = "job." .. subj
        
    require(file1)
    require(file2)
    require("job.utility")
    
end

--[[ executeJobFunction(func, ...) **
    Execute parse function based on current job
        
]]
function helpers.executeJobFunction(job, message, sender)    
    job.parseAction(message, sender)
    
end

--------------------------------------------------------------------------------
--[[ Name: incomingChatMode(int modeId)
    Returns a string based on incoming chat ID.
    
    * Modes:
        - 0   : Say
        - 1   : Shout
        - 3   : Tell
        - 4   : Party
        - 5   : LS1
        - 26  : Yell
        - 27  : LS2
        - 33  : Unity
]] -----------------------------------------------------------------------------
-- @param modeId        - ID of the current chat mode.
-- @return              - Returns a string based on modeID @param.

function helpers.getIncomingChatMode(modeId)
    
    local _mode
    
    if modeId == 0 then
        _mode = "say"
        
    elseif modeId == 1 then
        _mode = "shout"
        
    elseif modeId == 3 then
        _mode = "tell"
        
    elseif modeId == 4 then
        _mode = "party"
        
    elseif modeId == 5 then
        _mode = "ls1"
        
    elseif modeId == 26 then
        _mode = "yell"
        
    elseif modeId == 27 then
        _mode = "ls2"
        
    elseif modeId == 33 then
        _mode = "unity"
        
    else
        _mode = nil
        
    end
    
    return _mode
    
end
--------------------------------------------------------------------------------
--[[ handleSkillchains(int skillchainId, bool displayChat) **
    Handles detection of skillchain based on incoming packet ID.
  
    * ID List:
        - 1  : Light
        - 2  : Dark
        - 3  : Gravitation
        - 4  : Fragmentation
        - 5  : Distorion
        - 6  : Fusion
        - 7  : Compression
        - 8  : Liquefaction
        - 9  : Induration
        - 10 : Reverberation
        - 11 : Transfixion
        - 12 : Scission
        - 13 : Detonation
        - 14 : Impaction
]] -----------------------------------------------------------------------------
-- @param skillchainId      - Incoming Skillchain ID to be converted to String.
-- @param displayChat       - Enable, or disable display of skillchain info in chat log.
-- @return                  - Returns a string based on incoming skillchainId.
--------------------------------------------------------------------------------
function helpers.handleSkillchains(skillchainId)
    
    --Light Skillchain
    if skillchainID == 1 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Light --> (Fire|Wind|Thunder|Light) >>")
        
    --Dark Skillchain
    elseif skillchainID == 2 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Dark --> (Ice|Earth|Water|Dark) >>")
        
    --Gravitation Skillchain
    elseif skillchainID == 3 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Gravitation --> Gravitation --> (Earth|Dark) >>")
        
    --Fragmentation Skillchain
    elseif skillchainID == 4 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Fragmentation --> (Wind|Thunder) >>")
        
    --Distorion Skillchain
    elseif skillchainID == 5 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Distorion --> (Ice|Water) >>")
        
    --Fusion Skillchain
    elseif skillchainID == 6 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Fusion --> (Fire|Light) >>")
        
    --Compression Skillchain
    elseif skillchainID == 7 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Compression --> (Dark) >>")
        
    --Liquefaction Skillchain
    elseif skillchainID == 8 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Liquefaction --> (Fire) >>")
        
    --Induration Skillchain
    elseif skillchainID == 9 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Induration --> (Ice) >>")
        
    --Reverberation Skillchain
    elseif skillchainID == 10 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Reverberation --> (Water) >>")
        
    --Transfixion Skillchain
    elseif skillchainID == 11 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Transfixion --> (Light) >>")
        
    --Scission Skillchain | Earth
    elseif skillchainID == 12 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Scission --> (Earth) >>")
        
    --Detonation Skillchain
    elseif skillchainID == 13 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Detonation --> (Wind) >>")
        
    --Impaction Skillchain
    elseif skillchainID == 14 then
        windower.chat.input("/p << " .. actorId['name'] .. ": Closed Impaction --> (Thunder) >>")
    
    end
    
end

--------------------------------------------------------------------------------
--[[ Name: getStatusChange(int modeId)
    Returns a string based on incoming chat ID.
    
    * Modes:
        - 0   : Say
        - 1   : Engaged
        - 3   : Tell
        - 4   : Party
        - 5   : LS1
]] -----------------------------------------------------------------------------
-- @param modeId        - ID of the current chat mode.
-- @return              - Returns a string based on modeID @param.
function helpers.getStatusChange(modeId)
    
    local _mode
    
    if modeId == 0 then
        _mode = "Idle"
        
    elseif modeId == 1 then
        _mode = "Engaged"
        
    elseif modeId == 2 then
        _mode = "???"
        
    elseif modeId == 3 then
        _mode = "???"
        
    elseif modeId == 4 then
        _mode = "???"
        
    else
        _mode = nil
        
    end
    
    return _mode
    
end

return helpers