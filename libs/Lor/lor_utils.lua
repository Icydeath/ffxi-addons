--[[
    Loader for other libraries written by Lorand.  As long as this is loaded first in other libraries, then the _libs
    table boilerplate prep is unnecessary in those libraries.
--]]

local global = gearswap and gearswap._G or _G   -- Retrieve the true _G since gearswap obfuscates it
local lor_utils = {}
lor_utils._version = '2018.05.26'
lor_utils._author = 'Ragnarok.Lorand'
lor_utils.load_order = {'functional','math','strings','tables','chat','exec','serialization','settings','argparse','packets','ffxi','position','resources','actor','advutils'}

-- Check to see if gearswap has replaced the user_env fake _G; if it has, then reset all global lib caches
global.gs_user_env = global.gs_user_env or (gearswap and global.user_env or nil)
local local_user_env = gearswap and global.user_env or nil
if local_user_env ~= global.gs_user_env then
    global.gs_user_env = local_user_env
    --noinspection GlobalCreationOutsideO
    _libs = {lor={}}
    --noinspection GlobalCreationOutsideO
    lor = {}
else
    --noinspection GlobalCreationOutsideO
    _libs = _libs or {}
    _libs.lor = _libs.lor or {}
    --noinspection GlobalCreationOutsideO
    lor = lor or {}
end


if not _libs.lor.utils then
    if not gearswap then require('luau') end
    _libs.lor.utils = lor_utils
    _libs.strings = _libs.strings or require('strings')

    local xpcall = global.xpcall
    lor.watc = global.windower.add_to_chat
    
    --Implementation/imitation of Python's os.path =====================================================================

    os.path = {
        exists = function(path) return global.windower.file_exists(path) or global.windower.dir_exists(path) end,
        mkdir = global.windower.create_dir,
        join = function(root, ...)
            local result = root or '/'
            local subs = {...}
            for _,p in ipairs(subs) do
                local trailing = result:endswith('/')
                local leading = p:startswith('/')
                local s = (trailing or leading) and '' or '/'
                result = ('%s%s%s'):format(result, s, p)
            end
            return result
        end,
        split = function(path)
            local parts = path:psplit('[\\\\/]')
            local result = T{}
            for _,p in ipairs(parts) do
                if #p > 0 then
                    result:append(p)
                end
            end
            return result
        end,
        mkdirs = function(root, path)
            local parts = os.path.split(path)
            local cwd = root
            for _,p in ipairs(parts) do
                cwd = os.path.join(cwd, p)
                if not global.windower.dir_exists(cwd) then
                    os.path.mkdir(cwd)
                end
            end
        end,
        parent = function(path)
            local parts = os.path.split(path)
            parts[#parts] = nil
            return os.path.join(unpack(parts))
        end
    }
    
    --Function wrappers, including error handling ======================================================================
    
    local function _handler(err)
        --[[
        Error handler to print the stack trace of the error.  Example use:
            local fmt = nil
            local status = xpcall(function() fmt = '%-'..tostring(longest_wstr(stbl:keys()))..'s  :  %s' end, _handler)
            if status then return nil end
        --]]
        local st_re = '([^/]+/[^/]+%.lua:.*)'
        local tb = debug.traceback():gsub('\t', '    '):gsub('%[C%]: ', ''):split('\n'):slice(2):reverse()
        tb = T({'stack traceback:'}):extend(tb):append(err)
        for _,tl in pairs(tb) do
            local trunc_line = tl:match(st_re)
            if trunc_line then
                lor.watc(167, '    ' .. trunc_line)
            else
                lor.watc(167, tl)
            end
        end
    end

    --noinspection GlobalCreationOutsideO
    function traceable(fn)
        --[[
        Wrapper for functions so that calls to them resulting in exceptions will generate stack traces.
        --]]
        return function(...)
            local args, res = {...}, nil
            local status = xpcall(function() res = fn(unpack(args)) end, _handler)
            return res
        end
    end
    
    local function _silentHandler(err) end

    --noinspection GlobalCreationOutsideO
    function try(fn)
        return function(...)
            local args, res = {...}, nil
--            local status = xpcall(function() res = fn(unpack(args)) end, _handler)
            local status = xpcall(function() res = fn(unpack(args)) end, _silentHandler)
            return status, res
        end
    end
    
    --Type checking and manipulation functions =========================================================================

    --noinspection GlobalCreationOutsideO
    function bool(obj)
        if type(obj) == 'boolean' then
            return obj
        elseif type(obj) == 'string' then
            return obj:lower() == 'true'
        end
        return obj
    end

    --noinspection GlobalCreationOutsideO
    function cast(obj, type_name)
        if type(obj) == type_name then
            return obj
        elseif type_name == 'string' then
            return tostring(obj)
        elseif (type_name == 'number') or (type_name == 'int') or (type_name == 'float') then
            return tonumber(obj)
        elseif (type_name == 'bool') or (type_name == 'boolean') then
            return bool(obj)
        end
        error(('Unable to cast %s to type %s'):format(tostring(obj), type_name))
    end

    --noinspection GlobalCreationOutsideO
    function isfunc(obj) return type(obj) == 'function' end
    --noinspection GlobalCreationOutsideO
    function isstr(obj) return type(obj) == 'string' end
    --noinspection GlobalCreationOutsideO
    function istable(obj) return type(obj) == 'table' end
    --noinspection GlobalCreationOutsideO
    function isnum(obj) return type(obj) == 'number' end
    --noinspection GlobalCreationOutsideO
    function isbool(obj) return type(obj) == 'boolean' end
    --noinspection GlobalCreationOutsideO
    function isnil(obj) return type(obj) == 'nil' end
    --noinspection GlobalCreationOutsideO
    function isuserdata(obj) return type(obj) == 'userdata' end
    --noinspection GlobalCreationOutsideO
    function isthread(obj) return type(obj) == 'thread' end
    --noinspection GlobalCreationOutsideO
    function class(obj)
        local m = getmetatable(obj)
        return m and (m.__class or m.__class__) or type(obj)
    end
    
    --Module loading functions =========================================================================================
    
    local try_req = try(require)

    --noinspection GlobalCreationOutsideO
    function yyyymmdd_to_num(date_str)
        local y,m,d,o = date_str:match('^(%d%d%d%d)[^0-9]*(%d%d)[^0-9]*(%d%d)[^0-9]*(.*)')
        local x = (#o > 0) and (tonumber(o) or 1) or 0
        return os.time({year=y,month=m,day=d}) + x
    end
    
    local function load_lor_lib(lname, version)
        if _libs.lor[lname] == nil then
            local success, result = try_req('lor/lor_'..lname)
            if success then
                _libs.lor[lname] = result
            else
                error(('lor_%s not found!  Please update from https://github.com/lorand-ffxi/lor_libs'):format(lname, lib_version, version))
            end
        end
        if _libs.lor[lname] ~= nil then
            local lib_version = _libs.lor[lname]._version
            local req_version = version and isstr(version) and yyyymmdd_to_num(version) or 0
            if req_version > yyyymmdd_to_num(lib_version) then
                error(('lor_%s version %s < %s (required) - Please update from https://github.com/lorand-ffxi/lor_libs'):format(lname, lib_version, version))
            end
        end
    end
    
    --[[
        Loads the given libs/lor lib or list of libs, optionally requiring a
        specific version.  It is possible to load all, and specify the version
        for particular libs.
    --]]
    _libs.lor.req = function(...)
        local args = {...}
        local targs = {}
        for _,arg in pairs(args) do
            local targ = istable(arg) and arg or {n=arg,v=0}
            targs[targ.n:lower()] = targ.v
        end

        local load_all = targs['all'] ~= nil
        for _,lname in pairs(lor_utils.load_order) do
            if load_all or (targs[lname] ~= nil) then
                load_lor_lib(lname, targs[lname])
            end
        end
    end
    
    _libs.req = function(...)
        for _,lname in pairs({...}) do
            if not _libs[lname] then
                local success, result = try_req(lname)
                if success then
                    _libs[lname] = _libs[lname] or result
                else
                    error(('Error loading "%s" (or it was not found in package.path: %s)'):format(lname, global.package.path))
                end
            end
        end
    end

    global.collectgarbage()
end

return lor_utils

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
