--[[    BSD License Disclaimer
        Copyright © 2018, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of zonename nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'zonename'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'
_addon.command = 'zonename'
_addon.commands = {'zn'}

config = require('config')
texts = require('texts')
res = require('resources')
region_zones = require('regionZones')

local LOGIN_ZONE_PACKET = 0x0A

defaults = {}
defaults.zoneName = {}
defaults.zoneName.pos = {}
defaults.zoneName.pos.x = 0
defaults.zoneName.pos.y = 0
defaults.zoneName.bg = {}
defaults.zoneName.bg.alpha = 255
defaults.zoneName.bg.red = 0
defaults.zoneName.bg.green = 0
defaults.zoneName.bg.blue = 0
defaults.zoneName.bg.visible = false
defaults.zoneName.flags = {}
defaults.zoneName.flags.right = false
defaults.zoneName.flags.bottom = false
defaults.zoneName.flags.bold = true
defaults.zoneName.flags.italic = false
defaults.zoneName.padding = 0
defaults.zoneName.text = {}
defaults.zoneName.text.size = 34
defaults.zoneName.text.font = 'Century Schoolbook'
defaults.zoneName.text.fonts = {'sans-serif', 'Arial', 'Trebuchet MS'}
defaults.zoneName.text.alpha = 235
defaults.zoneName.text.red = 255
defaults.zoneName.text.green = 255
defaults.zoneName.text.blue = 193
defaults.zoneName.text.stroke = {}
defaults.zoneName.text.stroke.width = 3
defaults.zoneName.text.stroke.alpha = 30
defaults.zoneName.text.stroke.red = 51
defaults.zoneName.text.stroke.green = 47
defaults.zoneName.text.stroke.blue = 38
defaults.zoneName.text.visible = true
defaults.zoneName.replaceAbbreviations = false
defaults.zoneName.format = '%s'
defaults.regionName = {}
defaults.regionName.pos = {}
defaults.regionName.pos.x = 0
defaults.regionName.pos.y = 0
defaults.regionName.bg = {}
defaults.regionName.bg.alpha = 255
defaults.regionName.bg.red = 0
defaults.regionName.bg.green = 0
defaults.regionName.bg.blue = 0
defaults.regionName.bg.visible = false
defaults.regionName.flags = {}
defaults.regionName.flags.right = false
defaults.regionName.flags.bottom = false
defaults.regionName.flags.bold = true
defaults.regionName.flags.italic = false
defaults.regionName.padding = 0
defaults.regionName.text = {}
defaults.regionName.text.size = 16
defaults.regionName.text.font = 'Century Schoolbook'
defaults.regionName.text.fonts = {'Lucida Console', 'sans-serif', 'Arial', 'Trebuchet MS'}
defaults.regionName.text.alpha = 235
defaults.regionName.text.red = 255
defaults.regionName.text.green = 255
defaults.regionName.text.blue = 193
defaults.regionName.text.stroke = {}
defaults.regionName.text.stroke.width = 3
defaults.regionName.text.stroke.alpha = 30
defaults.regionName.text.stroke.red = 51
defaults.regionName.text.stroke.green = 47
defaults.regionName.text.stroke.blue = 38
defaults.regionName.text.visible = true
defaults.regionName.format = '- %s -'
defaults.regionName.replaceNationNames = true
defaults.centered = true
defaults.fadeTime = 1
defaults.displayTime = 5
defaults.waitTime = 2

local settings = config.load(defaults)
config.save(settings)

settings.zoneName.text.draggable = false
settings.regionName.text.draggable = false

local last_update = 0
local zone_text = texts.new(settings.zoneName)
local region_text = texts.new(settings.regionName)

config.register(settings, function(settings)
    windower_settings = windower.get_windower_settings()
    xRes = windower_settings.ui_x_res
    yRes = windower_settings.ui_y_res
    local fade_millis = settings.fadeTime * 75
    zone_fade_step = settings.zoneName.text.alpha / fade_millis
    zone_stroke_fade_step = settings.zoneName.text.stroke.alpha / fade_millis
    region_fade_step = settings.regionName.text.alpha / fade_millis
    region_stroke_fade_step = settings.zoneName.text.stroke.alpha / fade_millis
end)

windower.register_event('addon command',function(command, regionName, zoneName)
    if command == 'd' then
        start_display()
    elseif command == 'f' then
        region_name = string.format(settings.regionName.format,regionName)
        zone_name = string.format(settings.zoneName.format,zoneName)
        ready_display()
    else
        windower.add_to_chat('8','zonename:\n\'d\': displays the current zone name.\n\'f\' <regionName> <zoneName>: displays the provided arguments..')
    end
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        start_display()
    end
end)

function start_display()
    info = windower.ffxi.get_info()
    if not info.mog_house then
        setup_names(info.zone)
        ready_display()
    end
end

function ready_display()
    setup_text(zone_text,zone_name)
    setup_text(region_text,region_name)
    ready = true
    last_update = os.clock() + settings.waitTime
    coroutine.schedule(refresh_display, 0.100 + settings.waitTime)
    coroutine.schedule(center_text, 0.150 + settings.waitTime)
end

function setup_names(zone_id)
    setup_zone_name(zone_id)
    setup_region_name(zone_id)
end

function setup_zone_name(zone_id)
    zone_name = ''
    local zone_table = res.zones[zone_id]
    if (zone_table ~= nil) then
        zone_name = zone_table.en
        replace_zone_abbreviations()
        zone_name = string.format(settings.zoneName.format,zone_name)
    end
end

function replace_zone_abbreviations()
    if (settings.zoneName.replaceAbbreviations) then
        if string.match(zone_name,'%[S]') then
            zone_name = string.gsub(zone_name,'%[S]','(Shadowreign)')
        elseif string.match(zone_name,'%[U]') then
            zone_name = string.gsub(zone_name,'%[U]','(Skirmish)')
        elseif string.match(zone_name,'%[D]') then
            zone_name = string.gsub(zone_name,'%[D]','(Divergence)')
        end
    end
end

function setup_region_name(zone_id)
    region_name = ''
    for i,v in pairs(region_zones.map) do
        if v:contains(zone_id) then
            region_name = res.regions[i].en
        end
    end
    if (region_name ~= '') then
        replace_region_nations()
        region_name = string.format(settings.regionName.format,region_name)
    end
end

function replace_region_nations()
    if (settings.regionName.replaceNationNames) then
        if (region_name == 'San d\'Oria') then
            region_name = 'The Kingdom of San d\'Oria'
        elseif (region_name == 'Bastok') then
            region_name = 'The Republic of Bastok'
        elseif (region_name == 'Windurst') then
            region_name = 'The Federation of Windurst'
        elseif (region_name == 'Jeuno') then
            region_name = 'The Grand Duchy of Jeuno'
        end
    end
end

function center_text()
    if (settings.centered) then
        local adjustFactor = windower_settings.x_res / windower_settings.ui_x_res
        local zone_text_width, zone_text_height = zone_text:extents()
        local region_text_width, region_text_height = region_text:extents()
        local full_height = zone_text_height + region_text_height
        region_text:pos(
            (xRes/2)-(region_text_width/2) * adjustFactor,
            (yRes/2) - full_height - 5
        )
        zone_text:pos(
            (xRes/2)-(zone_text_width/2) * adjustFactor,
            (yRes/2) - (full_height - region_text_height)
        )
    end
end

function setup_text(textbox,text)
    textbox:text(text)
    textbox:alpha(0)
    textbox:stroke_alpha(0)
    textbox:show()
end

function refresh_display()
    if ready then
        update_banner()
        coroutine.schedule(refresh_display, 0.010)

    end
end

function update_banner()
    local time = os.clock() - last_update
    if (time > (settings.fadeTime * 2) + settings.displayTime) then
        hide()
    elseif (time > settings.fadeTime + settings.displayTime) then
        fade_out()
    elseif (time <= settings.fadeTime) then
        fade_in()
    end
end

function hide()
    ready = false
    zone_text:hide()
    region_text:hide()
end

function fade_in()
    add_alpha(zone_text:alpha() + zone_fade_step,zone_text)
    add_stroke_alpha(zone_text:stroke_alpha() + zone_fade_step,zone_text)
    add_alpha(region_text:alpha() + region_fade_step,region_text)
    add_stroke_alpha(region_text:stroke_alpha() + region_fade_step,region_text)
end

function add_alpha(alpha,textbox)
    if (alpha < 255) then
        textbox:alpha(alpha)
    end
end

function add_stroke_alpha(alpha,textbox)
    if (alpha < 255) then
        textbox:stroke_alpha(alpha)
    end
end

function fade_out()
    substract_alpha(zone_text:alpha() - zone_fade_step,zone_text)
    substract_stroke_alpha(zone_text:stroke_alpha() - zone_fade_step,zone_text)
    substract_alpha(region_text:alpha() - region_fade_step,region_text)
    substract_stroke_alpha(region_text:stroke_alpha() - region_fade_step,region_text)
end

function substract_alpha(alpha,textbox)
    if (alpha >= 0) then
        textbox:alpha(alpha)
    end
end

function substract_stroke_alpha(alpha,textbox)
    if (alpha >= 0) then
        textbox:stroke_alpha(alpha)
    end
end
