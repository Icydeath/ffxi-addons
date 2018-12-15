--[[
    Resource info

    Author: Ragnarok.Lorand
--]]

local lor_resources = {}
lor_resources._author = 'Ragnarok.Lorand'
lor_resources._version = '2018.05.20.0'

require('lor/lor_utils')
_libs.lor.req('chat')
_libs.lor.resources = lor_resources

local action_resource_types = {'spells', 'job_abilities', 'weapon_skills' }
local res = require('resources')


local function get_lc_resources()
    --[[
        Returns a mapping of action_resource_type:{lower_case_name:action_info}
    --]]
    local lc_resources = {}
    for _,target in pairs(action_resource_types) do
        lc_resources[target] = {}
        for id,action in pairs(res[target]) do
            local action_name = action.en:lower()
            lc_resources[target][action_name] = action
            lc_resources[target][action_name].ja = nil
        end
    end
    return lc_resources
end
lor_resources.lc_res = get_lc_resources()


function lor_resources.action_for(action_name)
    --[[
        Returns the resource information for the given spell or ability name
    --]]
    local lower_name = action_name:lower()
    for _,artype in pairs(action_resource_types) do
        local action = lor_resources.lc_res[artype][lower_name]
        if action ~= nil then
            atcd(('%s %s %s[%s]: %s'):format(action_name, string.char(129,168), artype, action.id, action.en))
            return action
        end
    end
    return nil
end


return lor_resources

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2018, Ragnarok.Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of libs/lor nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------
