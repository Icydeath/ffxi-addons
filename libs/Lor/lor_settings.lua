--[[
    Settings library that saves settings as a lua file instead of XML.  The config library is too inflexible for storing
    k,v pairs when keys contain invalid xml tags, and XML is very verbose.  This was easier than finding or writing a
    JSON writer since the included JSON library is for reading only.
    
    Any valid lua can be loaded by this library.
    
    The table (and any sub-tables) shouldn't contain any values with types that are not one of table, string, number,
    boolean, nil.  When preparing to save, for any other type, the tostring() function will be called, and they will be
    treated as strings.
    
    The top-level table is treated / saved as a default table with no custom class.  When loaded, the top-level table
    will have the same metatable as the given defaults table if provided / it has one, otherwise it will be a T table.
    Additional settings-related methods will be included as well to provide settings_tbl:save() functionality, for
    example.
    
    Preserves the class of sub-tables if their class is included in the valid_classes variable below, which for now
    contains List, Set, and Table.  Any sub-tables with a different class will be treated like a default table.
    
    Author: Ragnarok.Lorand
--]]

local global = gearswap and gearswap._G or _G
local lor_settings = {}
lor_settings._author = 'Ragnarok.Lorand'
lor_settings._version = '2018.05.20.0'

require('lor/lor_utils')
_libs.lor.settings = lor_settings
_libs.lor.req('chat', 'tables', 'strings')
_libs.req('tables', 'sets')
local files = require('files')

local no_quote_types = S{'number','boolean','nil'}
local valid_classes = S{'List','Set','Table'}
local converting = false

--[[
    Convenience method to convert the config file (presumably an XML created by
    the config library) at the given original_path to a new lua settings file at
    the given new_path.
    
    This should only ever need to be run once for the given file - after the new
    file is generated, remove the line from your code that calls this method,
    and you can delete the old XML file.
    
    Note: When loading an ordered list, the config library returns a dict with
    keys that are string representations of the index numbers.  It is up to you
    to fix them in the resulting lua file.
--]]
function lor_settings.convert_config(original_path, new_path)
    converting = true
    local config = require('config')
    if config == nil then
        atc(123, 'Unable to load the config library! Unable to convert!')
        return
    end
    local original = config.load(original_path)
    if original == nil then
        atcf(123, 'Original config not found: %s', original_path)
        return
    end
    
    local filepath = os.path.join(windower.addon_path, new_path)
    local suffix = ''
    local backup_path = filepath
    while windower.file_exists(backup_path) do
        backup_path = ('%s.backup%s'):format(filepath, suffix)
        suffix = (suffix == '') and 0 or (suffix + 1)
    end
    
    if backup_path ~= filepath then
        local result, msg = os.rename(filepath, backup_path)
        if not result then
            atcfs('Settings not converted - error backing up original file: %s', msg)
            return
        else
            atcfs('Backed up existing file: %s', backup_path)
        end
    end
    
    setmetatable(original, nil)     --remove the config library's metatable
    local converted = lor_settings.load(new_path, original)
    converted:save()
    return converted
end


--[[
    Load the settings file with the given path (relative to the calling addon's
    directory), and an optional table of default values.  If the file doesn't
    exist, then it is created and populated with the default values.
--]]
function lor_settings.load(filepath, defaults)
    if type(filepath) ~= 'string' then
        filepath, defaults = 'data/settings.lua', filepath
    end
    local loaded = nil
    local fcontents = files.read(filepath)
    if (fcontents ~= nil) then
        loaded = loadstring(fcontents)
        global.setfenv(loaded, _G)       --Allows loading of S{}, T{}, etc.
        loaded = loaded()
    end
    
    local do_save = false
    if loaded == nil then
        loaded = defaults or {}
        do_save = true
    end
    
    local d_meta = getmetatable(defaults) or _meta.T
    local m = getmetatable(loaded)
    if m == nil then
        m = {}
        setmetatable(loaded, m)
    end
    m.__settings_path = filepath
    m.__class = 'Settings'
    m.__index = function(t, k)
        if lor_settings[k] ~= nil then
            return lor_settings[k]
        end
        return d_meta.__index[k]
    end
    
    if do_save then
        lor_settings.save(loaded)
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


--[[
    Prepare the given table to be written to file.  Recursive for sub-tables.
    Returns a list of strings, where each entry is a line of output.
    
    Every key=value pair / entry is placed on a separate line.
    
    If all entries have numeric keys, the first key is 1, and those keys are in
    sequential order, then the table is treated like a list (i.e., no key value
    is stored).  Otherwise, entries are stored as [key] = value.  Strings are
    enclosed in quotation marks and escaped if necessary via the enquote()
    lor_strings method.
--]]
local function prepare(t, indent)
    local pair_fn = converting and pairs or opairs
    local res = {}
    local tlen = 0
    local is_ordered_list = true
    for k,_ in pairs(t) do
        tlen = tlen + 1
        if k ~= tlen then is_ordered_list = false end
    end
    local is_set = (class(t) == 'Set')
    
    local i = 1
    for _k,_v in pair_fn(t) do
        local k,v = '',_v
        if is_set then  --Values are stored as {key1=true,key2=true}, but the
            v = _k      --constructor is S{key1,key2}, so treat keys as values
        elseif not is_ordered_list then
            k = tostring(_k)
            if not no_quote_types:contains(type(_k)) then
                k = k:enquote()
            end
            k = ('[%s] = '):format(k)
        end
        
        if type(v) == 'table' then
            local class_prefix = t_prefix(v)
            local sub_table = prepare(v, indent)
            if #sub_table < 1 then
                res[#res+1] = ('%s%s{}'):format(k, class_prefix)
            else
                --Encorporate the subtable into the result, adding a level of indentation
                res[#res+1] = ('%s%s{'):format(k, class_prefix)
                for _,line in pair_fn(sub_table) do
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
    Save the settings table to the path provided when it was loaded.
    quiet: (optional) boolean whether or not to hide the saved message
    indent: (optional) string or number of spaces to use (default: 4 spaces)
    line_end: (optional) newline character for each line (default: \n)
--]]
function lor_settings.save(settings_tbl, quiet, indent, line_end)
    indent = (type(indent) == 'number') and (' '):rep(indent) or indent
    indent = (type(indent) == 'string') and indent or '    '
    line_end = (type(line_end) == 'string') and line_end or '\n'
    
    local m = getmetatable(settings_tbl)
    if m == nil or m.__settings_path == nil then
        error('Invalid argument passed to settings.save: '..tostring(settings_tbl))
        return
    end
    
    local prepared = prepare(settings_tbl, indent)
    if prepared == nil then
        error('Unexpected error occurred while preparing output')
        return
    end
    
    local filepath = os.path.join(windower.addon_path, m.__settings_path)
    os.path.mkdirs(windower.addon_path, os.path.parent(m.__settings_path))
    
    local f = io.open(filepath, 'wb')   --'w' -> \r\n; 'wb' -> \n
    f:write('return {', line_end)
    for _,line in pairs(prepared) do
        f:write(indent, line, line_end)
    end
    f:write('}', line_end)
    f:close()
    
    if not quiet then
        windower.add_to_chat(1, 'Saved settings to: '..filepath)
    end
end


return lor_settings

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
