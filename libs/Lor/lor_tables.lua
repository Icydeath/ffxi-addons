--[[
    Table functions.
    Sorted table iteration based on: http://lua-users.org/wiki/SortedIteration
    Author: Ragnarok.Lorand
]]

local lor_tables = {}
lor_tables._author = 'Ragnarok.Lorand'
lor_tables._version = '2016.10.31.0'

require('lor/lor_utils')
_libs.req('tables')
_libs.lor.req('functional')
_libs.lor.tables = lor_tables


--Prepare LT in a OO manner such that LT has class properties and methods
LT = {__class = 'LorTable'}
LT.__init = function(_,t)   --1st arg to __call() is the table used to call it, i.e., LT
    local r = t or {}
    local m = getmetatable(r)
    if m == nil then
        m = {}
        setmetatable(r, m)
    end
    if m.__class ~= LT.__class then
        m.__index = function(t, i)
            if t ~= table then
                if table[i] then
                    return table[i]
                elseif isnum(i) then
                    if i < 0 then
                        return rawget(t, #t+i+1)
                    end
                end
            end
            return rawget(t, i)
        end
        m.__add = table.add
        m.__class = LT.__class
    end
    return r
end
LT.__meta = {__call = LT.__init}    --Use LT() as a constructor for LT objects
setmetatable(LT, LT.__meta)


function table.getval(t, i)
    if t ~= table then
        if table[i] then
            return table[i]
        elseif isnum(i) then
            if i < 0 then
                return rawget(t, #t+i+1)
            end
        end
    end
    return rawget(t, i)
end


function table.add(t, o)
    local r = {}
    if table.is_array(t) and table.is_array(o) then
        for _,v in ipairs(t) do r[#r+1] = v end
        for _,v in ipairs(o) do r[#r+1] = v end
    else
        for k,v in pairs(t) do r[k] = v end
        for k,v in pairs(o) do r[k] = v end
    end
    return r
end


--[[
    Merges table t with table o; values with the same key from o will overwrite
    values from t.  Optionally filters keys or values using functions or tables.
    If a provided filter is a table instead of function, it is converted into a
    function.  Only k:v pairs where kf(k) and vf(v) are truthy are included in
    the results.
--]]
function table.merge(t, o, kf, vf)
    local r = {}
    kf = kf and (isfunc(kf) and kf or lor.fn_tget(kf)) or lor.fn_true
    vf = vf and (isfunc(vf) and vf or lor.fn_tget(vf)) or lor.fn_true
    for k,v in pairs(t) do if kf(k) and vf(v) then r[k] = v end end
    for k,v in pairs(o) do if kf(k) and vf(v) then r[k] = v end end
    return r
end


--[[
    Set the value for fields in table t to the value from the field in table o
    if there is not already a value for that field in table t.
    Equivalent to a chain of `t[field] = t[field] or o[field]` lines.
--]]
function table.update_if_not_set(t, o)
    for k,v in pairs(o) do
        if istable(v) then
            t[k] = t[k] or {}
            table.update_if_not_set(t[k], o[k])
        else
            t[k] = t[k] or v
        end
    end
    return t
end


function table.keys(t)
    local r = {}
    for k,_ in pairs(t) do r[#r+1] = k end
    return r
end

function table.strkeys(t)
    local r = {}
    for k,_ in pairs(t) do r[#r+1] = tostring(k) end
    return r
end

function table.keylens(t)
    return map(len, table.strkeys(t))
end

function table.size(t)
    return #table.keys(t)
end


function sizeof(tbl)
    local c = 0
    for _,_ in pairs(tbl) do c = c + 1 end
    return c
end


function table.intersects(tbla, tblb)
    for _,v1 in pairs(tbla) do
        for _,v2 in pairs(tblb) do
            if v1 == v2 then return true end
        end
    end
    return false
end


function table.val_for_first_valid_key(tbl, keys)
    for _,key in pairs(keys) do
        if tbl[key] then return tbl[key] end
    end
    return nil
end


function table.first_key(tbl)
    if (type(tbl) ~= 'table') or (sizeof(tbl) == 0) then return nil end
    for k,v in pairs(tbl) do return k end
end


function table.first_value(tbl)
    if (type(tbl) ~= 'table') or (sizeof(tbl) == 0) then return nil end
    for k,v in pairs(tbl) do return v end
end


function table.first_pair(tbl)
    if (type(tbl) ~= 'table') or (sizeof(tbl) == 0) then return nil, nil end
    for k,v in pairs(tbl) do return k,v end
end


function table.values(t)
    local r = {}
    for _,v in pairs(t) do
        r[#r+1] = v
    end
    return r
end


function table.invert(t)
    local r = {}
    for k,v in pairs(t) do 
        r[v] = k
    end
    return r
end


function table.expanded_invert(t)
    local r = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            for _,sv in pairs(v) do
                r[sv] = k
            end
        else
            r[v] = k
        end
    end
    return r
end


--[[
    Returns true if the type of any value in t is table or function.
--]]
function table.has_nested(t)
    for k,v in pairs(t) do
        if any_eq(type(v), 'table', 'function') then
            return true
        end
    end
    return false
end


function table.is_array(t)
    if type(t) ~= 'table' then return false end
    for k,v in pairs(t) do
        if (type(k) ~= 'number') or (not ((1 <= k) and (k <= #t))) then
            return false
        end
    end
    return true
end


local function sesc(v)
    return isstr(v) and (v:find("'") and '"'..v..'"' or "'"..v.."'") or tostring(v)
end


function table.kv_strings(t)
    local r = {}
    for k,v in opairs(t) do
        local skey = sesc(k)
        local sval
        if type(v) == 'string' then
            sval = sesc(v)
        elseif (type(v) == 'table') and (sizeof(v) == 0) then
            sval = '{}'
        else
            sval = tostring(v)
        end
        r[#r+1] = ('%s: %s'):format(skey, sval)
    end
    return r
end

function table.str(t) return ('{%s}'):format((', '):join(map(tostring, t))) end


--[[
    Returns the value for the given keys of arbitrary depth.
    If a table is provided for any given level, the first available value is
    chosen as the key for that level.  Fails fast if a given level does not have
    a value for that level's key.
    Returns t[k1][k2]...[kN] or nil if any sub-table does not contain the key
    provided for that level.
--]]
function table.get_nested_value(t, ...)
    if t == nil then return nil end
    local nested = {...}
    local sub_t = t
    for _,k in pairs(nested) do
        if istable(k) then
            for _,sk in pairs(k) do
                if sub_t[sk] ~= nil then
                    sub_t = sub_t[sk]
                    break
                end
            end
        else
            sub_t = sub_t[k]
        end
        if sub_t == nil then return nil end
    end
    return sub_t
end

--[[
    Tests whether or not table t has a value at a given key of arbitrary depth.
    If a table is provided for any given level, the first available value is
    chosen as tehkey for that level.  Fails fast if a given level does not have
    a value for that level's key.
    Returns true if t[k1][k2]...[kN] ~= nil
--]]
function table.has_nested_key(t, ...)
    if t == nil then return false end
    local nested = {...}
    local sub_t = t
    for _,k in pairs(nested) do
        if istable(k) then
            for _,sk in pairs(k) do
                if sub_t[sk] ~= nil then
                    sub_t = sub_t[sk]
                    break
                end
            end
        else
            sub_t = sub_t[k]
        end
        if sub_t == nil then return false end
    end
    return true
end


--[[
    Treats each value in t as a regex pattern to match against the plain text
    string val.  Returns the match if found, otherwise returns nil.
--]]
function table.matches(t, val)
    for _,rx in pairs(t) do
        local m = val:match(rx)
        if m then return m end
    end
    return nil
end


local function cmp(obj1, obj2)
    --Compare obj1 to obj2
    local t1, t2 = type(obj1), type(obj2)
    if t1 ~= t2 then
        --Type mismatch: compare types
        return t1 < t2
    --If not a type mismatch, t1 == t2, so only t1 will be used going forward
    elseif t1 == "boolean" then
        return obj1
    elseif any_eq(t1, "number", "string") then
        return obj1 < obj2
    else
        return tostring(obj1) < tostring(obj2)
    end
end


local function ordered_indices(t) local r = table.keys(t); table.sort(r, cmp); return r end


function opairs(tbl)
    local i = 0
    local ordered = ordered_indices(tbl)
    return function()
        i = i + 1
        local key = ordered[i]
        return key, tbl[key]
    end
end


return lor_tables

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
