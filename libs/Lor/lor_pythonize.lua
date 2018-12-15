--[[
    Make Lua a bit more like Python to be a bit less annoying!

    Author: Ragnarok.Lorand
--]]

local global = gearswap and gearswap._G or _G
local lor_pythonize = {_replaced = {}, _author = 'Ragnarok.Lorand', _version = '2018.05.27.2'}

require('lor/lor_utils')
_libs.lor.pythonize = lor_pythonize


local function AbstractMethodError(obj, method_name)
    error(('AbstractMethodError: %s does not have a concrete implementation of %s'):format(class(obj), method_name))
end
lor_pythonize.AbstractMethodError = AbstractMethodError


local function hasattr(obj, attr)
    if type(obj) ~= 'table' then return false end
    return obj[attr] ~= nil
end
lor_pythonize.hasattr = hasattr


local function tbl2str(tbl)
    local t, i = {}, 1
    for k, v in pairs(tbl) do
        local kfmt = (type(k) == "string") and '%q' or '%s'
        local vfmt = (type(v) == "string") and '%q' or '%s'

        if type(v) == 'table' then v = tbl2str(v) end

        local fmt = ('[%s]=%s'):format(kfmt, vfmt)
        t[i] = fmt:format(k, v)
        i = i + 1
    end
    return '{' .. table.concat(t, ', ') .. '}'
end


local c_next = pairs({})    -- First return value is always the c implementation of next()
local function iter(...)
    local args = {...}
    if (#args == 2) and ((c_next == args[1]) and type(args[2] == 'table')) then
        return unpack(args)
    elseif #args == 0 then
        return nil
    end

    local iterable
    if #args == 1 then
        iterable = args[1]
        local iter_type = type(iterable)
        if hasattr(iterable, '__iter__') then
            return iterable:__iter__()
        elseif iter_type == 'function' then
            return iterable
        elseif iter_type == 'string' then
            return string.gmatch(iterable, '.')
        elseif iter_type ~= 'table' then
            iterable = {iterable}
        end
    else
        iterable = args
    end

    local key = nil
    return function()
        key = next(iterable, key)
        if key ~= nil then return iterable[key] end
    end
end
lor_pythonize.iter = iter


local function _to_table(...)
    local args = {...}
    local tbl = {}
    local i = 1

    if (#args == 2) and ((c_next == args[1]) and type(args[2] == 'table')) then
        for k, v in unpack(args) do tbl[k] = v end
    else
        if #args == 0 then
            return tbl
        elseif #args == 1 then
            local iterable = args[1]
            local iter_type = type(iterable)
            if hasattr(iterable, '__iter__') then
                for v in iter(iterable) do
                    tbl[i] = v
                    i = i + 1
                end
            elseif iter_type == 'function' then
                for k, v in iterable do
                    if v == nil then
                        tbl[i] = k
                        i = i + 1
                    else
                        tbl[k] = v
                    end
                end
            elseif iter_type == 'table' then
                for k, v in pairs(iterable) do tbl[k] = v end
            else
                return {iterable}
            end
        else
            return args
        end
    end
    return tbl
end


local function sorted(...)
    local tbl = _to_table(...)
    table.sort(tbl)
    return iter(tbl)
end
lor_pythonize.sorted = sorted


local function reversed(...)
    local rev = _to_table(...)
    local i = 1
    for j=#rev, #rev/2 + 1, -1 do
        rev[i], rev[j] = rev[j], rev[i]
        i = i + 1
    end
    return iter(rev)
end
lor_pythonize.reversed = reversed


local function imap(fn, ...)
    local val = nil
    local iterable = iter(...)
    return function()
        val = iterable()
        if val then
            return fn(val)
        end
    end
end
lor_pythonize.imap = imap


local function sum(...)
    local total = 0
    for val in iter(...) do
        total = total + val
    end
    return total
end
lor_pythonize.sum = sum


local function max(...)
    return math.max(unpack(_to_table(...)))
end
lor_pythonize.max = max


local function min(...)
    return math.min(unpack(_to_table(...)))
end
lor_pythonize.min = min


local function mro(obj)
    local order = {}
    local order_set = {}
    local i = 1

    local meta = getmetatable(obj)
    if not meta then
        return iter(order)
    elseif not meta.__bases__ then
        if meta.__cls__ then
            obj = meta.__cls__
            meta = getmetatable(obj)
        end
    end

    if meta and meta.__bases__ then
        for _,cls in pairs(meta.__bases__) do
            order_set[cls] = true
            order[i] = cls
            i = i + 1
            if cls ~= obj then
                for bcls in mro(cls) do
                    if not order_set[bcls] then
                        order_set[bcls] = true
                        order[i] = bcls
                        i = i + 1
                    end
                end
            end
        end
    end
    return iter(order)
end
lor_pythonize.mro = mro


local Class = {
    -- General helper methods for classes
    __name__ = 'Class',
    init = function(meta)
        local function __init__(cls, ...)
            local self = setmetatable({}, meta)
            local _init = self.__init__
            if not _init then
                error(('TypeError: Cannot instantiate abstract class %s'):format(cls.__name__))
            end
            _init(self, ...)
            return self
        end
        return __init__
    end,
    index = function(obj, key)
        local val = rawget(obj, key)
        if val ~= nil then return val end
        for cls in mro(obj) do
            val = cls[key]
            if val ~= nil then
                --if key ~= '__name__' then print(('%s.%s => %s.%s'):format(obj.__name__, key, cls.__name__, key)) end
                return val
            end
        end
    end,
    str = function(cls)
        return ('<class %s>'):format(cls and cls.__name__)
    end,
}
local _type = {__name__='type'}
local _type_meta = {__tostring=Class.str, __cls__=_type}
setmetatable(_type, _type_meta)
setmetatable(Class, {__tostring=Class.str, __cls__=_type})


local function class(cls, ...)
    --[[
    -- Construct a new class, or get an existing object's class, or get a Windower lib object's class name.
    -- In order to be backwards-compatible with the 'class' function expected by Windower libs, all classes to be
    -- defined by this function must include a value for __name__.
    --]]
    local meta = getmetatable(cls)
    if meta then
        if meta.__cls__ then
            return meta.__cls__
        end
        return meta.__class     -- Windower lib class name style
    elseif (type(cls) ~= 'table') or (cls.__name__ == nil) then
        return type(cls)
    end

    local bases = {...}
    table.insert(bases, 1, cls)

    local inst_meta = {__index=Class.index, __cls__=cls}
    local class_meta = {__call=Class.init(inst_meta), __bases__=bases, __tostring=Class.str, __cls__=Class}

    setmetatable(cls, class_meta)

    for bcls in reversed(mro(cls)) do
        for func_name, func in pairs(bcls) do
            if func_name:startswith('__') then
                inst_meta[func_name] = func
            end
        end
    end
    return cls
end
lor_pythonize.class = class


local function isinstance(obj, ...)
    local args = {...}
    local obj_type = type(obj)
    for val in iter(args) do
        if obj_type == val then return true end
    end
    if obj_type == 'nil' then return false end  -- nil would have been caught above if it was specified

    local meta = getmetatable(obj)
    local obj_class = class(obj)
    local obj_classname = obj_class and obj_class.__name__
    if obj_class then
        for val in iter(args) do
            if (obj_class == val) or (obj_classname == val) then return true end
        end
    end

    if meta then
        for cls in mro(obj) do
            for val in iter(args) do
                if (cls == val) or (cls.__name__ == val) then return true end
            end
        end
    end
    return false
end
lor_pythonize.isinstance = isinstance


local ABC = {}
ABC.Iterable = class{
    __name__ = 'Iterable',
    __iter__ = function(self)
        return AbstractMethodError(self, '__iter__')
    end
}
ABC.Sized = class{
    __name__ = 'Sized',
    __len = function(self)
        local c = 0
        for k, v in pairs(self) do c = c + 1 end
        return c
    end
}
ABC.Container = class{
    __name__ = 'Container',
    contains = function(self, item)
        return AbstractMethodError(self, 'contains')
    end
}
ABC.Set = class(
    {
        __name__ = 'Set',
        __eq = function(self, other)
            if other.__name__ ~= self.__name__ then return false end
            local own_len = 0
            for val in iter(self) do
                own_len = own_len + 1
                if not other[val] then return false end
            end
            return own_len == #other
        end,
        __tostring = function(self)
            local t, i = {}, 1
            for k in iter(self) do
                local fmt = (type(k) == 'string') and '%q' or '%s'
                t[i] = fmt:format(k)
                i = i + 1
            end
            return ('%s{'):format(class(self).__name__) .. table.concat(t, ', ') .. '}'
        end,
        isdisjoint = function(self, other)
            -- Return true if two sets have a null intersection (no common values).
            for value in iter(other) do
                if self:contains(value) then return false end
            end
            return true
        end
    },
    ABC.Iterable, ABC.Sized, ABC.Container
)
ABC.MutableSet = class(
    {
        __name__ = 'MutableSet',
        add = function(self, value)
            -- Add an element
            return AbstractMethodError(self, 'add')
        end,
        discard = function(self, value)
            -- Remove an element.  Do not raise an exception if absent
            return AbstractMethodError(self, 'discard')
        end,
        remove = function(self, value)
            -- Remove an element.  If not a member, raise a KeyError
            assert(self:contains(value), ('KeyError: %'..((type(value) == 'string') and 'q' or 's')):format(value))
            self:discard(value)
        end,
        pop = function(self)
            for val in iter(self) do
                self:discard(val)
                return val
            end
        end,
        clear = function(self)
            local val = self:pop()
            while val do
                val = self:pop()
            end
        end,
        update = function(self, ...)
            for k, v in iter(...) do
                if v == nil then self:add(k) else self:add(v) end
            end
        end
    },
    ABC.Set
)
ABC.Mapping = class(
    {
        __name__ = 'Mapping',
        __eq = function(self, other)
            if other.__name__ ~= self.__name__ then return false end
            local own_len = 0
            for k,v in pairs(self) do
                own_len = own_len + 1
                if other[k] ~= v then return False end
            end
            return own_len == #other
        end,
        __tostring = function(self)
            local t, i = {}, 1
            for k, v in pairs(self) do
                local kfmt = (type(k) == 'string') and '%q' or '%s'
                local vfmt = (type(v) == 'string') and '%q' or '%s'
                local fmt = ('[%s]=%s'):format(kfmt, vfmt)
                t[i] = fmt:format(k, v)
                i = i + 1
            end
            return ('%s{'):format(class(self).__name__) .. table.concat(t, ', ') .. '}'
        end,
        contains = function(self, item)
            return self[item] ~= nil
        end,
        get = function(self, key, default)
            local val = self[key]
            if val == nil then return default else return val end
        end,
        __iter__ = function(self)
            local key = nil
            return function()
                key = next(self, key)
                return key
            end
        end,
        keys = function(self)
            local key = nil
            return function()
                key = next(self, key)
                return key
            end
        end,
        items = function(self)
            local key = nil
            return function()
                key = next(self, key)
                return key, self[key]
            end
        end,
        values = function(self)
            local key = nil
            return function()
                key = next(self, key)
                return self[key]
            end
        end
    },
    ABC.Iterable, ABC.Sized, ABC.Container
)
ABC.MutableMapping = class(
    {
        __name__ = 'MutableMapping',
        pop = function(self, key)
            local val = self[key]
            self[key] = nil
            return val
        end,
        popitem = function(self)
            for key in iter(self) do
                local val = self[key]
                self[key] = nil
                return key, val
            end
        end,
        setdefault = function(self, key, default)
            local val = self[key]
            if val == nil then
                self[key] = default
                return default
            end
            return val
        end,
        clear = function(self)
            for i,_ in pairs(self) do self[i] = nil end
        end
    },
    ABC.Mapping
)
ABC.Sequence = class(
    {
        __name__ = 'Sequence',
        __iter__ = function(self)
            local key = nil
            return function()
                key = next(self, key)
                if key ~= nil then return self[key] end
            end
        end,
        __eq = function(self, other)
            if other.__name__ ~= self.__name__ then return false end
            local own_len = 0
            for i,v in ipairs(self) do
                own_len = own_len + 1
                if other[i] ~= v then return false end
            end
            return own_len == #other
        end,
        __tostring = function(self)
            local t, i = {}, 1
            for val in iter(self) do
                local fmt = (type(val) == 'string') and '%q' or '%s'
                t[i] = fmt:format(val or 'nil')
                i = i + 1
            end
            return ('%s{'):format(class(self).__name__) .. table.concat(t, ', ') .. '}'
        end,
        contains = function(self, item)
            for val in iter(self) do
                if val == item then return true end
            end
            return false
        end,
        index = function(self, value)
            for i,v in pairs(self) do
                if v == value then
                    return i
                end
            end
        end,
        count = function(self, value)
            local c = 0
            for _,v in pairs(self) do
                if v == value then c = c + 1 end
            end
            return c
        end,
    },
    ABC.Iterable, ABC.Sized, ABC.Container
)
ABC.MutableSequence = class(
    {
        __name__ = 'MutableSequence',
        insert = function(self, index, value)
            index = (index <= #self) and index or #self + 1
            table.insert(self, index, value)
        end,
        append = function(self, value)
            table.insert(self, value)
        end,
        extend = function(self, ...)
            local i = #self + 1
            for k, v in iter(...) do
                if v == nil then self[i] = k else self[i] = v end
                i = i + 1
            end
        end,
        pop = function(self, index)
            index = (index ~= nil) and index or #self
            local val = self[index]
            self[index] = nil
            return val
        end,
        remove = function(self, value)
            for i,v in pairs(self) do
                if v == value then
                    table.remove(self, i)
                    return
                end
            end
        end,
        clear = function(self)
            for i,_ in pairs(self) do self[i] = nil end
        end
    },
    ABC.Sequence
)
lor_pythonize.ABC = ABC


local list = class({
    __name__ = 'list',
    __init__ = function(self, ...)
        self:extend(...)
    end,
    __newindex = function(self, index, value)
        assert(type(index) == 'number', ('TypeError: list indices must be integers, not %s'):format(type(index)))
        assert(index == math.floor(index), 'TypeError: list indices must be integers')
        local last = #self + 1
        if index < 0 then index = last + index end
        assert((0 <= index) and (index <= last) and (0 ~= index), ('IndexError: list assignment index out of range: %s'):format(index))
        rawset(self, index, value)
    end,
    sort = function(self)
        table.sort(self)
    end,
    reverse = function(self)
        local i = 1
        for j=#self, #self/2 + 1, -1 do
            self[i], self[j] = self[j], self[i]
            i = i + 1
        end
    end,
}, ABC.MutableSequence)
lor_pythonize.list = list


local set = class({
    __name__ = 'set',
    __init__ = function(self, ...)
        rawset(self, '_values', {})
        self:update(...)
    end,
    __iter__ = function(self)
        local key = nil
        return function()
            key = next(self._values, key)
            return key
        end
    end,
    __index = function(self, key)
        for cls in mro(self) do
            local val = cls[key]
            if val ~= nil then return val end
        end
        error(('TypeError: \'%s\' object does not support indexing'):format(class(self).__name__))
    end,
    __newindex = function(self, index, value)
        error(('TypeError: \'%s\' object does not support item assignment'):format(class(self).__name__))
    end,
    __pairs = function(self)
        local key = nil
        return function()
            key = next(self._values, key)
            return key, key
        end
    end,
    to_table = function(self)
        local t, i = {}, 1
        for k,_ in pairs(self._values) do t[i] = k; i = i + 1 end
        return t
    end,
    add = function(self, item)
        self._values[item] = true
    end,
    discard = function(self, item)
        self._values[item] = nil
    end,
    contains = function(self, item)
        return self._values[item] ~= nil
    end,
}, ABC.MutableSet)
lor_pythonize.set = set


local dict = class({
    __name__ = 'dict',
    __init__ = function(self, ...)
        self:update(...)
    end,
    update = function(self, ...)
        local args = {...}
        assert(#args <= 2, ('%s.update() expected 1-2 args, found: %s'):format(class(self).__name__, #args))
        if #args == 2 then      -- Special case for pairs(tbl) => (next, tbl, nil)
            for k, v in unpack(args) do self[k] = v end
        else
            local iterable = args[1] or {}
            if type(iterable) == 'function' then
                for k, v in iterable do self[k] = v end
            else
                for k, v in pairs(iterable) do self[k] = v end
            end
        end
    end,
}, ABC.MutableMapping)
lor_pythonize.dict = dict


local Counter = class({
    __name__ = 'Counter',
    update = function(self, ...)
        for val in iter(...) do
            self[val] = (self[val] or 0) + 1    -- Only nil and false evaluate to false
        end
    end
}, dict)
lor_pythonize.Counter = Counter


local function dir(cls)
    local attrs = list()
    local c = 1
    for cls in reversed(mro(cls)) do
        for func_name, func in pairs(cls) do
            attrs[c] = func_name
            c = c + 1
        end
    end
    return attrs
end
lor_pythonize.dir = dir


function lor_pythonize.make_global()
    for k, v in pairs(lor_pythonize) do
        if (k ~= 'make_global') and not k:startswith('_') then
            global[k] = v
        end
    end
end


return lor_pythonize

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
