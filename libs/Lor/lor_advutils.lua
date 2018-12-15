--[[
    Misc. "advanced" utilities that require functionality provided in other lor libs
    
    Author: Ragnarok.Lorand
--]]

local lor_advutils = {}
lor_advutils._author = 'Ragnarok.Lorand'
lor_advutils._version = '2016.10.02.0'

require('lor/lor_utils')
_libs.lor.advutils = lor_advutils
_libs.lor.req('serialization')


--[[
    Wrapper for functions with only 1 argument to cache return values
--]]
function lor_advutils.scached(fn)
    return setmetatable({}, {
        __index = function(self, k)
            local v = fn(k)
            self[k] = v
            return v
        end
    })
end


--[[
    Wrapper for functions with multiple arguments to cache return values
--]]
function lor_advutils.cached(fn)
    local cache = {}
    return function(...)
        local args = {...}
        local k = _libs.lor.serialization.encode(args)
        if cache[k] == nil then
            cache[k] = fn(unpack(args))
        end
        return cache[k]
    end
end


--[[
    Wrapper for functions with no arguments to cache return values for a specified amount of time
--]]
function lor_advutils.tcached(expiration, fn)
    local cached = nil
    local last_time = nil
    return function()
        local now = os.clock()
        if last_time == nil or ((now - last_time) > expiration) then
            last_time = now
            cached = fn()
        end
        return cached
    end
end


return lor_advutils

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Ragnarok.Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of libs/lor nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------