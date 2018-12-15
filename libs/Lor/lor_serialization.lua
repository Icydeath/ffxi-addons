--[[
    Serialization library to encode/decode lua objects to/from strings.
    
    Any valid lua can be loaded by this library.
    
    The table (and any sub-tables) shouldn't contain any values with types that are not one of table, string, number,
    boolean, nil.  For any other type, the tostring() function will be called, and they will be treated as strings.
    
    The top-level table is treated as a default table with no custom class.
    When decoded, the top-level table will be a T table.
    
    Preserves the class of sub-tables if their class is included in the valid_classes variable below, which for now
    contains List, Set, and Table.  Any sub-tables with a different class will be treated like a default table.
    
    Author: Ragnarok.Lorand
--]]

local global = gearswap and gearswap._G or _G
local lor_serialization = {}
lor_serialization._author = 'Ragnarok.Lorand'
lor_serialization._version = '2016.10.22.0'

require('lor/lor_utils')
_libs.lor.serialization = lor_serialization
_libs.lor.req('tables', {n='strings',v='2016.08.07'})
_libs.req('tables', 'sets')
files = require('files')

local no_quote_types = S{'number','boolean','nil'}
local valid_classes = S{'List','Set','Table'}
local list_types = S{'List','Set'}
local hash_types = S{'Table'}


--[[
    Decode the given lua_str into a lua object
--]]
function lor_serialization.decode(lua_str)
    if type(lua_str) ~= 'string' then
        return lua_str
    elseif #lua_str < 1 then
        return nil
    end
    
    local loaded = nil
    loaded = loadstring(lua_str)
    global.setfenv(loaded, _G)       --Allows loading of S{}, T{}, etc.
    loaded = loaded()
    
    if loaded == nil then
        return loaded
    elseif type(loaded) == 'table' then    
        local m = getmetatable(loaded)
        if m == nil then
            setmetatable(loaded, _meta.T)
        end
    end
    return loaded
end


--[[
    Returns the class prefix for the given table, if supported
--]]
local function t_prefix(obj)
    local oclass = class(obj)
    if valid_classes:contains(oclass) then
        return oclass:match('^%u')
    end
    return ''
end


local function is_ordered_and_len(tbl)
    local tlen = 0
    local is_ordered_list = true
    for k,_ in pairs(tbl) do
        tlen = tlen + 1
        if k ~= tlen then is_ordered_list = false end
    end
    return is_ordered_list, tlen
end


local function json_wrappers(obj)
    local obj_open, obj_close, obj_empty = '{', '}', '{}'
    if list_types:contains(class(obj)) then
        obj_open, obj_close, obj_empty = '[', ']', '[]'
    elseif hash_types:contains(class(obj)) then
        obj_open, obj_close, obj_empty = '{', '}', '{}'
    else
        local is_ordered_list, tlen = is_ordered_and_len(obj)
        if is_ordered_list then
            obj_open, obj_close, obj_empty = '[', ']', '[]'
        end
    end
    return obj_open, obj_close, obj_empty
end


--[[
    Prepare the given table to be converted to a string.  Recursive for sub-tables. Returns a list of strings, where
    each entry is a line of output.
    
    If all entries have numeric keys, the first key is 1, and those keys are in sequential order, then the table is
    treated like a list (i.e., no key value is stored).  Otherwise, entries are stored as key: value.  Strings are
    enclosed in quotation marks and escaped if necessary via the enquote() lor_strings method.
--]]
local function prepare_json(t, indent, collapse)
    local res = {}
    local is_ordered_list, tlen = is_ordered_and_len(t)
    local kfmt = collapse and '%s:' or '%s: '
    
    local i = 1
    for _k,_v in opairs(t) do
        local k,v = '',_v
        if class(t) == 'Set' then   --Values are stored as {key1=true,key2=true}, but the
            v = _k                  --constructor is S{key1,key2}, so treat keys as values
        elseif not is_ordered_list then
            k = tostring(_k)
            if not no_quote_types:contains(type(_k)) then
                k = k:enquote()
            end
            k = kfmt:format(k)
        end
        
        if type(v) == 'table' then
            local st_open, st_close, st_empty = json_wrappers(v)
            local sub_table = prepare_json(v, indent, collapse)
            if #sub_table < 1 then
                res[#res+1] = ('%s%s'):format(k, st_empty)
            else
                --Encorporate the subtable into the result, adding a level of indentation
                res[#res+1] = ('%s%s'):format(k, st_open)
                for _,line in opairs(sub_table) do
                    res[#res+1] = ('%s%s'):format(indent, line)
                end
                res[#res+1] = st_close
            end
        else
            local val = tostring(v)
            if not no_quote_types:contains(type(v)) then
                val = val:enquote()
            end
            res[#res+1] = ('%s%s'):format(k, val)
        end
        
        if i < tlen then
            res[#res] = res[#res]..','
        end
        i = i + 1
    end
    return res
end


--[[
    Encode the given object as a lua string.
    indent: (optional) string or number of spaces to use (default: none)
    line_end: (optional) newline character for each line (default: none)
--]]
function lor_serialization.json_dumps(obj, indent, line_end)
    indent = (type(indent) == 'number') and (' '):rep(indent) or indent
    indent = (type(indent) == 'string') and indent or ''
    line_end = (type(line_end) == 'string') and line_end or ''
    
    if type(obj) == 'string' then
        return obj:enquote()
    elseif no_quote_types:contains(type(obj)) then
        return tostring(obj)
    end
    
    local prepared = prepare_json(obj, indent, true)
    if prepared == nil then
        error('Unexpected error occurred while preparing output')
        return
    end
    
    local obj_open, obj_close, obj_empty = json_wrappers(obj)
    local json_str = ('%s%s'):format(obj_open, line_end)
    for _,line in pairs(prepared) do
        json_str = ('%s%s%s%s'):format(json_str, indent, line, line_end)
    end
    return ('%s%s%s'):format(json_str, obj_close, line_end)
end


--[[
    Prepare the given table to be converted to a string.  Recursive for
    sub-tables. Returns a list of strings, where each entry is a line of output.
    
    If all entries have numeric keys, the first key is 1, and those keys are in
    sequential order, then the table is treated like a list (i.e., no key value
    is stored).  Otherwise, entries are stored as [key] = value.  Strings are
    enclosed in quotation marks and escaped if necessary via the enquote()
    lor_strings method.
--]]
local function prepare(t, indent, collapse)
    local res = {}
    local is_ordered_list, tlen = is_ordered_and_len(t)
    local kfmt = collapse and '[%s]=' or '[%s] = '
    
    local i = 1
    for _k,_v in opairs(t) do
        local k,v = '',_v
        if class(t) == 'Set' then   --Values are stored as {key1=true,key2=true}, but the
            v = _k                  --constructor is S{key1,key2}, so treat keys as values
        elseif not is_ordered_list then
            k = tostring(_k)
            if not no_quote_types:contains(type(_k)) then
                k = k:enquote()
            end
            k = kfmt:format(k)
        end
        
        if type(v) == 'table' then
            local class_prefix = t_prefix(v)
            local sub_table = prepare(v, indent, collapse)
            if #sub_table < 1 then
                res[#res+1] = ('%s%s{}'):format(k, class_prefix)
            else
                --Encorporate the subtable into the result, adding a level of indentation
                res[#res+1] = ('%s%s{'):format(k, class_prefix)
                for _,line in opairs(sub_table) do
                    res[#res+1] = ('%s%s'):format(indent, line)
                end
                res[#res+1] = '}'
            end
        else
            local val = tostring(v)
            if not no_quote_types:contains(type(v)) then
                val = val:enquote()
            end
            res[#res+1] = ('%s%s'):format(k, val)
        end
        
        if i < tlen then
            res[#res] = res[#res]..','
        end
        i = i + 1
    end
    return res
end


--[[
    Encode the given object as a lua string.
    indent: (optional) string or number of spaces to use (default: none)
    line_end: (optional) newline character for each line (default: none)
--]]
function lor_serialization.encode(obj, indent, line_end)
    indent = (type(indent) == 'number') and (' '):rep(indent) or indent
    indent = (type(indent) == 'string') and indent or ''
    line_end = (type(line_end) == 'string') and line_end or ''
    
    if type(obj) == 'string' then
        return ('return %s'):format(obj:enquote())
    elseif no_quote_types:contains(type(obj)) then
        return ('return %s'):format(tostring(obj))
    end
    
    local prepared = prepare(obj, indent, true)
    if prepared == nil then
        error('Unexpected error occurred while preparing output')
        return
    end
    
    local lua_str = 'return {'..line_end
    for _,line in pairs(prepared) do
        lua_str = lua_str..indent..line..line_end
    end
    lua_str = lua_str..'}'..line_end
    return lua_str
end


return lor_serialization

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
