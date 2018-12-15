--[[
    String functions
    Author: Ragnarok.Lorand
--]]

local lor_str = {}
lor_str._author = 'Ragnarok.Lorand'
lor_str._version = '2018.05.26'

require('lor/lor_utils')
_libs.req('strings')
_libs.lor.req('functional', 'math')
_libs.lor.strings = lor_str


local char_widths = {
    [' '] = 7,  ['!'] = 7,  ['"'] = 7,  ['#'] = 10, ['$'] = 8,  ['%'] = 13, 
    ['&'] = 11, ['('] = 8,  [')'] = 8,  ['*'] = 9,  [','] = 5,  ['.'] = 5,
    ['/'] = 7,  [':'] = 5,  [';'] = 5,  ['?'] = 9,  ['@'] = 11, ['['] = 8,
    ['\\'] = 8, ['\''] = 5, ['-'] = 8,  [']'] = 8,  ['^'] = 9,  ['_'] = 9,
    ['`'] = 7,  ['{'] = 7,  ['|'] = 6,  ['}'] = 7,  ['~'] = 12, ['+'] = 9,
    ['='] = 9,  ['0'] = 9,  ['1'] = 9,  ['2'] = 9,  ['3'] = 9,  ['4'] = 9,  
    ['5'] = 9,  ['6'] = 9,  ['7'] = 9,  ['8'] = 9,  ['9'] = 9,  ['A'] = 11,
    ['a'] = 9,  ['B'] = 11, ['b'] = 9,  ['C'] = 10, ['c'] = 9,  ['D'] = 10,
    ['d'] = 9,  ['E'] = 10, ['e'] = 9,  ['f'] = 7,  ['F'] = 9,  ['G'] = 11,
    ['g'] = 9,  ['H'] = 10, ['h'] = 9,  ['i'] = 5,  ['I'] = 6,  ['j'] = 6,
    ['J'] = 9,  ['K'] = 11, ['k'] = 9,  ['L'] = 10, ['l'] = 5,  ['M'] = 12,
    ['m'] = 12, ['N'] = 10, ['n'] = 9,  ['o'] = 10, ['O'] = 11, ['P'] = 10,
    ['p'] = 9,  ['Q'] = 12, ['q'] = 9,  ['R'] = 11, ['r'] = 6,  ['S'] = 10,
    ['s'] = 8,  ['T'] = 10, ['t'] = 7,  ['U'] = 10, ['u'] = 9,  ['V'] = 11,
    ['v'] = 9,  ['w'] = 11, ['W'] = 14, ['X'] = 11, ['x'] = 9,  ['Y'] = 11,
    ['y'] = 9,  ['Z'] = 11, ['z'] = 8
}


function string.findall(s, p)
    local r = {}
    local i = 1
    while i <= #s do
        local a,b = s:find(p,i)
        if a then
            r[#r+1] = {a,b}
            i = a
        end
        i = i + 1
    end
    return r
end


function string.all_matches(s, p)
    local matches = {}
    local i = 1
    while i <= #s do
        local m = s:match(p, i)
        if m then
            i = i + #m
            matches[#matches+1] = m:trim()
        else
            break
        end
    end
    return matches
end


local function char_counts(s)
    local tbl = {}
    for c in tostring(s):gmatch('.') do
        tbl[c] = (tbl[c] or 0) + 1
    end
    return tbl
end


local function colorFor(col)
    local cstr = ''
    if not ((S{256,257}:contains(col)) or (col<1) or (col>511)) then
        if (col <= 255) then
            cstr = string.char(0x1F)..string.char(col)
        else
            cstr = string.char(0x1E)..string.char(col - 256)
        end
    end
    return cstr
end


function string.colorize(str, new_col, reset_col)
    return colorFor(new_col or 1)..str..colorFor(reset_col or 1)
end


function string.px_len(s)
    local wl = 0
    for chr, cnt in pairs(char_counts(s)) do
        wl = wl + ((char_widths[chr] or 9) * cnt)
    end
    return wl
end


--[[
    Returns a weighted length for the given string given that FFXI's chat
    log font is not fixed-width.
    Max weighted line width after timestamp is about 192 at 1600x900 game window
--]]
function string.wlen(s)
    return math.floor((string.px_len(s) / 7)+0.5)
end


function string.fmts(fmt, ...)
    return string.format(fmt, unpack(map(tostring, {...})))
end


function string.join(jstr, ...)
    --Somewhat equivalent to Python's str.join(iterable)
    local tbl = {...}
    local building = {}
    for i=1, #tbl do
        local ele = tbl[i]
        if type(ele) == 'table' then
            if class(ele) == 'Set' then
                local stbl = {}
                for k,_ in pairs(ele) do
                    stbl[#stbl+1] = k
                end
                ele = jstr:join(unpack(stbl))
            else
                ele = jstr:join(unpack(ele))
            end
        end
        building[i] = tostring(ele)
    end
    return table.concat(building, jstr)
end


function string.isnum(s)
    return (tonumber(s) ~= nil)
end


function string.xmlify(s)
    return s:lower():gsub('[ -]', '_'):gsub('%.', '')
end


function string.unquote(s)
    local unquoted = s:match('^"([^"]+)"$')
    if unquoted then return unquoted end
    unquoted = s:match("^'([^']+)'$")
    if unquoted then return unquoted end
    return s
end


--[[
    Enclose the given string in quotation marks.  Prefers single quotes; if the
    string contains single quotes, double quotes are used; if the string
    contains both, then single quotes are escaped and used.
--]]
function string.enquote(s)
    return ('%q'):format(s)
--    if s:match("'") == nil then
--        return ("'%s'"):format(s)
--    elseif s:match('"') == nil then
--        return ('"%s"'):format(s)
--    end
--    return ("'%s'"):format(s:gsub("'","\\'"))
end

--[[
function string.startswith(s, ...)
    -- Returns true if this string starts with one of the given strings, false otherwise
    for _, val in pairs({...}) do
        if s:find('^'..val) ~= nil then return true end
    end
    return false
end

function string.endswith(s, ...)
    -- Returns true if this string ends with one of the given strings, false otherwise
    for _, val in pairs({...}) do
        if s:find(val..'$') ~= nil then return true end
    end
    return false
end
--]]

local str_format = string.format
function string.format(s, ...)
    -- Fix lua's poor handling of nil values passed to string.format
    local fmt_args = {}
    local args = {...}
    for i=1, #args do
        local arg = args[i]
        --print(str_format('[%s] (%s) %s', i, type(arg), tostring(arg)))
        if type(arg) == 'table' then
            fmt_args[i] = tostring(arg)
        else
            fmt_args[i] = arg or 'nil'
        end
    end
    return str_format(s, unpack(fmt_args))
end


return lor_str

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
