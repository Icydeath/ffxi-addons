--[[
    Some functional programming functions
    Author: Ragnarok.Lorand
--]]

local global = gearswap and gearswap._G or _G
local lor_func = {}
lor_func._author = 'Ragnarok.Lorand'
lor_func._version = '2018.05.26'

require('lor/lor_utils')
_libs.req('functions')
_libs.lor.functional = lor_func


max = math.max
min = math.min

lor = lor or {}
lor.fn_and = function(a,b) return a and b end
lor.fn_or = function(a,b) return a or b end
lor.fn_add = function(a,b) return a + b end
lor.fn_sub = function(a,b) return a - b end
lor.fn_mul = function(a,b) return a * b end
lor.fn_div = function(a,b) return a / b end
lor.fn_eq = function(a,b) return a == b end
lor.fn_neq = function(a,b) return a ~= b end
lor.fn_lt = function(a,b) return a < b end
lor.fn_gt = function(a,b) return a > b end
lor.fn_lte = function(a,b) return a <= b end
lor.fn_gte = function(a,b) return a >= b end
lor.fn_get = function(t,k) return t[k] end
lor.fn_in = function(d,k) return d[k] ~= nil end
lor.fn_keqv = function(d,k) return d[k] == k end
lor.fn_knev = function(d,k) return d[k] ~= k end
lor.fn_true = function(...) return true end
lor.fn_false = function(...) return false end

lor.fn_tget = function(t) return function(k) return t[k] end end


local trace = {}

--[[
    Returns a customized copy of the given function fn, such that future calls of the returned function will always pass
    the given value val to fn in position pos, along with any additional arguments provided.  Written based on the
    desire to emulate the 'if' portion of list/dict comprehension in Python, such as in the following:
        list = [val for key,val in dict.items() if key in equip_bags]

    Example usage:
        local equip_bags = map(customized(lor.fn_get, player), equip_bag_names)
--]]
function customized(fn, val, pos)
    local p = pos or 1
    return function(...)
        local args = {...}
        table.insert(args, p, val)
        return fn(unpack(args))
    end
end


function all_eq(val, ...)
    --Returns true iff every argument is equal to val
    for _,arg in pairs({...}) do
        if arg ~= val then return false end
    end
    return true
end


function any_eq(val, ...)
    --Returns true if one or more aguments are equal to val
    for _,arg in pairs({...}) do
        if arg == val then return true end
    end
    return false
end


function trace.reduce(fn, ...)
    local args = {...}
    local res = args[1]
    local i = 2
    while i <= #args do
        res = fn(res, args[i])
        i = i + 1
    end
    return res
end

--[[
    Returns the first truthy (possibly non-nil) value.  Unpack tables before
    passing them to this function.
--]]
function lazy_or(...)
    local args = {...}
    local res = args[1]
    local i = 2
    while (i <= #args) and (not res) do
        res = res or args[i]
        i = i + 1
    end
    return res
end


--[[
    Unpack tables before passing them to this function.
--]]
function lazy_and(...)
    local args = {...}
    local res = args[1]
    local i = 2
    while (i <= #args) and res do
        res = res and args[i]
        i = i + 1
    end
    return res
end


--[[
    Returns the result of applying function fn to every value in tbl without
    modifying tbl.
--]]
function trace.map(fn, tbl)
    local rtbl = {}
    for k,v in pairs(tbl) do
        rtbl[k] = fn(v)
    end
    return rtbl
end


--[[
    Returns the result of applying function fn to the value at every index in
    tbl without modifying tbl.
--]]
function trace.imap(fn, tbl)
    local r = {}
    for i = 1, #tbl do
        r[i] = fn(tbl[i])
    end
    return r
end


--[[
    Returns the result of applying function fn to every key in tbl without
    modifying tbl.
--]]
function trace.kmap(fn, tbl)
    local rtbl = {}
    for k,v in pairs(tbl) do
        rtbl[fn(k)] = v
    end
    return rtbl
end


--[[
    Returns the result of applying function fn to every key and value in
    tbl without modifying tbl.  Useful for applying tostring() to both.
--]]
function trace.dmap(fn, tbl)
    local rtbl = {}
    for k,v in pairs(tbl) do
        rtbl[fn(k)] = fn(v)
    end
    return rtbl
end


--[[
    Interprets the given string to perform list/dict comprehension using the given content.
    Acceptable format: 'output_key:output_val for k,v in table if condition'
--]]
function pycomp(comp_str, locals)
    local f_start,f_end = comp_str:find(' for ')
    local outputs = comp_str:sub(1,f_start):trim()
    local _outs = outputs:psplit('[:,]')
    local ok,ov = _outs[1],_outs[2]
    comp_str = comp_str:sub(f_end)
    local in_start,in_end = comp_str:find(' in ')
    local vars = comp_str:sub(1,in_start):trim()
    local _vars = vars:split(',')
    local vk,vv = _vars[1],_vars[2]
    comp_str = comp_str:sub(in_end)
    local t_start,t_end = comp_str:mfind('if|where')
    local input, predicate
    if t_start then
        input = comp_str:sub(1,t_start-1):trim()
        predicate = comp_str:sub(t_end+1):trim()
    else
        input = comp_str
    end
    local p_start,p_end = input:find('pairs%(')
    if p_start then
        input = input:sub(p_end+1,#input-1)
    end
    if ov == nil then
        ov = ok
        ok = '#_rtbl+1'
    end
    local cmd_lines = {
        'local _rtbl = {}\n',
        string.format('for %s,%s in pairs(%s) do\n',vk,vv,input),
        string.format('    if (%s) then\n',predicate or 'true'),
        string.format('        _rtbl[%s] = %s\n',ok,ov),
        '    end\nend\nreturn _rtbl'
    }
    local cmd = ''
    for _,l in pairs(cmd_lines) do
        cmd = cmd..l
    end
    local loaded = loadstring(cmd)
    local fenv = _G
    locals = locals or {}
    for k,v in pairs(locals) do
        fenv[k] = v
    end
    global.setfenv(loaded, fenv)
    return loaded()
end


function lambda(args, body, locals)
    args = (args ~= nil) and args or ''
    if body == nil then
        local _, _, _args, _body = args:find('([^:]-):%s+(.*)')
        args, body = _args or '', _body
    end
    local loaded = loadstring(('return function(%s) return (%s) end'):format(args, body))
    local fenv = _G
    locals = locals or {}
    for k, v in pairs(locals) do
        fenv[k] = v
    end
    setfenv(loaded, fenv)
    return loaded()
end


--Add the traceable versions of the functions marked to be so to the environment
for fname,fn in pairs(trace) do
    _G[fname] = traceable(fn)
end


return lor_func

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
