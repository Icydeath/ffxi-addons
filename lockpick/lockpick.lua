--[[
Copyright 2019 Seth VanHeulen

This file is part of lockpick.

lockpick is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

lockpick is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with lockpick.  If not, see <https://www.gnu.org/licenses/>.
--]]

-- luacheck: std luajit, globals _addon windower

-- built-in libraries
local bit = require('bit')
local io = require('io')
local math = require('math')
local string = require('string')
local table = require('table')

local function join_path(...)
    return string.gsub(string.gsub(table.concat({...}, '/'), '\\', '/'), '/+', '/')
end

if _addon then
    local package = require('package')
    package.path = join_path(windower.addon_path, 'wrapper/?.lua;') .. package.path
    _addon.windower = 4
end

local _addon = _addon or {windower=5}
_addon.name = 'lockpick'
_addon.author = 'Seth VanHeulen'
_addon.version = '2.0.0.0'

-- core libraries
local chat = require('core.chat')
local windower = require('core.windower')
-- extra libraries
local entities = require('entities')
require('pack')
local packets = require('packets')
local world = require('world')

local MESSAGE_INFO = 207
local MESSAGE_WARN = 200

local function message(text, level)
    chat.add_text(string.format('[%s] %s', _addon.name, text), level or MESSAGE_INFO)
end

local casket_by_id = {}

local default_casket = {
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
}

local is_message
do
    local message_id_by_zone = {}

    local message_dat_by_zone = {
        [100]='ROM/24/37.DAT',
        [101]='ROM/24/38.DAT',
        [102]='ROM/24/39.DAT',
        [103]='ROM/24/40.DAT',
        [104]='ROM/24/41.DAT',
        [105]='ROM/24/42.DAT',
        [106]='ROM/24/43.DAT',
        [107]='ROM/24/44.DAT',
        [108]='ROM/24/45.DAT',
        [109]='ROM/24/46.DAT',
        [110]='ROM/24/47.DAT',
        [111]='ROM/24/48.DAT',
        [112]='ROM/24/49.DAT',
        [113]='ROM2/17/46.DAT',
        [114]='ROM2/17/47.DAT',
        [115]='ROM/24/52.DAT',
        [116]='ROM/24/53.DAT',
        [117]='ROM/24/54.DAT',
        [118]='ROM/24/55.DAT',
        [119]='ROM/24/56.DAT',
        [120]='ROM/24/57.DAT',
        [121]='ROM2/17/54.DAT',
        [122]='ROM2/17/55.DAT',
        [123]='ROM2/17/56.DAT',
        [124]='ROM2/17/57.DAT',
        [125]='ROM2/17/58.DAT',
        [126]='ROM/24/63.DAT',
        [127]='ROM/24/64.DAT',
        [128]='ROM2/17/61.DAT',
        [130]='ROM2/17/63.DAT',
        [153]='ROM2/17/86.DAT',
        [158]='ROM/24/95.DAT',
        [159]='ROM2/17/92.DAT',
        [160]='ROM2/17/93.DAT',
        [166]='ROM/24/103.DAT',
        [167]='ROM/24/104.DAT',
        [169]='ROM/24/106.DAT',
        [172]='ROM/24/109.DAT',
        [173]='ROM2/17/106.DAT',
        [174]='ROM2/17/107.DAT',
        [176]='ROM2/17/109.DAT',
        [177]='ROM2/17/110.DAT',
        [178]='ROM2/17/111.DAT',
        [190]='ROM/24/127.DAT',
        [191]='ROM/25/0.DAT',
        [192]='ROM/25/1.DAT',
        [193]='ROM/25/2.DAT',
        [194]='ROM/25/3.DAT',
        [195]='ROM/25/4.DAT',
        [196]='ROM/25/5.DAT',
        [197]='ROM/25/6.DAT',
        [198]='ROM/25/7.DAT',
        [200]='ROM/25/9.DAT',
        [204]='ROM/25/13.DAT',
        [205]='ROM2/18/10.DAT',
        [208]='ROM2/18/13.DAT',
        [212]='ROM2/18/17.DAT',
        [213]='ROM2/18/18.DAT',
    }

    local function read_file(path)
        local handle = io.open(path, 'rb')
        if handle then
            local contents = handle:read('*a')
            handle:close()
            return contents
        end
    end

    local base_message = string.char(
        0xd9,0xef,0xf5,0xa0,0xe8,0xe1,0xf6,0xe5,0xa0,0xe1,0xa0,0xe8,0xf5,0xee,0xe3,0xe8,
        0xa0,0xf4,0xe8,0xe1,0xf4,0xa0,0xf4,0xe8,0xe5,0xa0,0xec,0xef,0xe3,0xeb,0xa7,0xf3,
        0xa0,0xe3,0xef,0xed,0xe2,0xe9,0xee,0xe1,0xf4,0xe9,0xef,0xee,0xa0,0xe9,0xf3,0xa0,
        0x8c,0x81,0xdb,0xe7,0xf2,0xe5,0xe1,0xf4,0xe5,0xf2,0xaf,0xec,0xe5,0xf3,0xf3,0xdd,
        0xa0,0xf4,0xe8,0xe1,0xee,0xa0,0x8a,0x80,0xae,0xff,0xb1,0x80,0x87
    )

    local function format_offset(offset)
        offset = string.pack('i', bit.bxor(offset - 5, 0x80808080))
        return string.gsub(offset, '([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
    end

    local function find_message_id()
        local zone_id = world.zone_id
        if not message_id_by_zone[zone_id] then
            local message_dat = message_dat_by_zone[zone_id]
            if message_dat then
                local message_dat_path = join_path(windower.client_path, message_dat)
                local message_dat_file = read_file(message_dat_path)
                if not message_dat_file then
                    return false
                end
                local offset = string.find(message_dat_file, base_message)
                local index = string.find(message_dat_file, format_offset(offset))
                message_id_by_zone[zone_id] = (index - 5) / 4
            else
                message_id_by_zone[zone_id] = true
            end
        end
        return message_id_by_zone[zone_id]
    end

    local message_id_offsets = {
        greater_less=0, failed=1, succeeded=3, even_odd_2=4, even_odd_1=5,
        range=6, less=7, greater=8, equal=9, equal_2=10, equal_1=11,
    }

    function is_message(name, message_id)
        return find_message_id() == message_id - message_id_offsets[name]
    end
end

local function greater_less_than(id, value, greater)
    local new = {}
    for _, v in pairs(casket_by_id[id] or default_casket) do
        if greater and v > value or not greater and v < value then
            table.insert(new, v)
        end
    end
    return new
end

local function even_odd(id, remainder, divisor)
    local new = {}
    for _, v in pairs(casket_by_id[id] or default_casket) do
        if math.floor(v / divisor) % 2 == remainder then
            table.insert(new, v)
        end
    end
    return new
end

local function equal(id, value)
    local new = {}
    for _, v in pairs(casket_by_id[id] or default_casket) do
        if math.floor(v / 10) == value or v % 10 == value then
            table.insert(new, v)
        end
    end
    return new
end

local function multiple(id, value1, value2, value3, divisor)
    local new = {}
    for _, v in pairs(casket_by_id[id] or default_casket) do
        local test = math.floor(v / divisor) % 10
        if test == value1 or test == value2 or test == value3 then
            table.insert(new, v)
        end
    end
    return new
end

local function display_combination_info(id, remaining_attempts)
    local casket = casket_by_id[id] or default_casket
    if #casket == 90 then
        message('possible combinations = 10-99')
    else
        message(string.format('possible combinations = %s', table.concat(casket, ',')))
    end
    local middle = math.ceil(#casket / 2)
    local final_count = #casket
    for _ = 2, remaining_attempts do
        final_count = (final_count - 1) / 2
    end
    local chance = 1 / math.max(1, final_count) * 100
    message(string.format('best guess = %d (%d%%)', casket[middle], chance))
end

packets.incoming[0x00B]:register(function ()
    casket_by_id = {}
end)

packets.incoming[0x02A]:register(function (packet)
    if is_message('greater_less', packet.message_id) then
        casket_by_id[packet.player_id] = greater_less_than(packet.player_id, packet.param_1, packet.param_2 == 0)
    elseif is_message('even_odd_2', packet.message_id) then
        casket_by_id[packet.player_id] = even_odd(packet.player_id, packet.param_1, 1)
    elseif is_message('even_odd_1', packet.message_id) then
        casket_by_id[packet.player_id] = even_odd(packet.player_id, packet.param_1, 10)
    elseif is_message('range', packet.message_id) then
        casket_by_id[packet.player_id] = greater_less_than(packet.player_id, packet.param_1, true)
        casket_by_id[packet.player_id] = greater_less_than(packet.player_id, packet.param_2, false)
    elseif is_message('less', packet.message_id) then
        casket_by_id[packet.player_id] = greater_less_than(packet.player_id, packet.param_1, false)
    elseif is_message('greater', packet.message_id) then
        casket_by_id[packet.player_id] = greater_less_than(packet.player_id, packet.param_1, true)
    elseif is_message('equal', packet.message_id) then
        casket_by_id[packet.player_id] = equal(packet.player_id, packet.param_1)
    elseif is_message('equal_2', packet.message_id) then
        casket_by_id[packet.player_id] = multiple(packet.player_id, packet.param_1, packet.param_2, packet.param_3, 1)
    elseif is_message('equal_1', packet.message_id) then
        casket_by_id[packet.player_id] = multiple(packet.player_id, packet.param_1, packet.param_2, packet.param_3, 10)
    elseif is_message('failed', packet.message_id) or is_message('succeeded', packet.message_id) then
        casket_by_id[packet.player_id] = nil
    end
end)

packets.incoming[0x034]:register(function (packet)
    local entity = entities.npcs:by_id(packet.npc)
    if entity.name == 'Treasure Casket' then
        local remaining_attempts = string.byte(packet.params, 1)
        if remaining_attempts > 0 and remaining_attempts < 7 then
            display_combination_info(packet.npc, remaining_attempts)
        end
    end
end)

packets.incoming[0x05B]:register(function (packet)
    casket_by_id[packet.entity_id] = nil
end)

message(string.format('loaded v%s in windower %d', _addon.version, _addon.windower), MESSAGE_WARN)

