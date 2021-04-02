--[[    BSD License Disclaimer
        Copyright © 2018, Hando
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of where nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Hando BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
		
		This program was made with reference to zonename made by sylandro. Thank you very much.
]]

_addon.name = 'where'
_addon.author = 'Hando'
_addon.version = '0.6'
_addon.command = 'where'
_addon.commands = {'wh'}

config = require('config')
texts = require('texts')
res = require('resources')
region_zones = require('regionZones')

local LOGIN_ZONE_PACKET = 0x0A
local LOGOUT_ZONE_PACKET = 0x0B

defaults = {}
defaults.zonename = {}
defaults.zonename.pos = {}
defaults.zonename.pos.x = 0
defaults.zonename.pos.y = 0
defaults.zonename.bg = {}
defaults.zonename.bg.alpha = 255
defaults.zonename.bg.red = 0
defaults.zonename.bg.green = 0
defaults.zonename.bg.blue = 0
defaults.zonename.bg.visible = false
defaults.zonename.flags = {}
defaults.zonename.flags.bottom = false
defaults.zonename.flags.bold = true
defaults.zonename.flags.italic = false
defaults.zonename.padding = 0
defaults.zonename.text = {}
defaults.zonename.text.size = 10
defaults.zonename.text.font = '源ノ明朝'
defaults.zonename.text.fonts = {'MS ゴシック', 'MS Gothic', 'メイリオ'}
--defaults.zonename.text.alpha = 255
defaults.zonename.text.red = 255
defaults.zonename.text.green = 255
defaults.zonename.text.blue = 193
defaults.zonename.text.stroke = {}
defaults.zonename.text.stroke.width = 2
--defaults.zonename.text.stroke.alpha = 255
defaults.zonename.text.stroke.red = 51
defaults.zonename.text.stroke.green = 47
defaults.zonename.text.stroke.blue = 38
defaults.zonename.text.visible = true
defaults.zonename.replaceAbbreviations = false
defaults.zonename.format = '%s'
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
defaults.regionName.flags.bottom = false
defaults.regionName.flags.bold = true
defaults.regionName.flags.italic = false
defaults.regionName.padding = 0
defaults.regionName.text = {}
defaults.regionName.text.size = 10
defaults.regionName.text.font = '源ノ明朝'
defaults.regionName.text.fonts = {'MS ゴシック', 'MS Gothic', 'メイリオ'}
--defaults.regionName.text.alpha = 255
defaults.regionName.text.red = 255
defaults.regionName.text.green = 255
defaults.regionName.text.blue = 193
defaults.regionName.text.stroke = {}
defaults.regionName.text.stroke.width = 2
--defaults.regionName.text.stroke.alpha = 255
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
defaults.language = 0
defaults.postype = 0


local settings = config.load(defaults)
config.save(settings)

settings.zonename.text.draggable = true
settings.regionName.text.draggable = true

local last_update = 0
local zone_text = texts.new(settings.zonename)
local region_text = texts.new(settings.regionName)
local pos_type = settings.postype

windower.register_event('login',function()
    local settings = config.load(defaults)
    config.save(settings)
    init()
end)

function init()
    settings.zonename.text.draggable = true
    settings.regionName.text.draggable = true

    windower_settings = windower.get_windower_settings()
    xRes = windower_settings.ui_x_res
    yRes = windower_settings.ui_y_res
    fade_millis = settings.fadeTime * 75
    zone_fade_step = 255 / fade_millis
    region_fade_step = 255 / fade_millis
    pos_type = settings.postype
end



-- config.register(settings, function(settings)
--     windower_settings = windower.get_windower_settings()
--     xRes = windower_settings.ui_x_res
--     yRes = windower_settings.ui_y_res
--     local fade_millis = settings.fadeTime * 75
--     zone_fade_step = 255 / fade_millis
--     region_fade_step = 255 / fade_millis
--     -- zone_fade_step = settings.zonename.text.alpha / fade_millis
--     -- region_fade_step = settings.regionName.text.alpha / fade_millis
-- end)



windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        start_display()
    end
	if (id == LOGOUT_ZONE_PACKET) then
		hide()
	end
end)



windower.register_event("addon command", function(command,arg1)
	if command == 'help' then
		local t = {}
		t[#t+1] = "where(wh)" .. "Ver." .._addon.version .. "/posttype:" .. settings.postype
		t[#t+1] = "<Commands>" 
		t[#t+1] = " //where jp  	:Japanese"
		t[#t+1] = " //where en  	:English" 
		t[#t+1] = " //where postype n\n0=top-left 1=bottom-left 2=top-right 3=bottom-right 4-free"
		t[#t+1] = " //where update　"
		for tk,tv in pairs(t) do
			windower.add_to_chat(207, windower.to_shift_jis(tv))
		end

	elseif command == 'jp' then
		settings.language = 0
		printFF11("where:Japanese mode")

	elseif command == 'en' then
		settings.language = 1
		printFF11("where:English mode")
	elseif command == 'postype' then
		settings.postype = tonumber(arg1 )
		pos_type = settings.postype
		printFF11("postype is " .. arg1 )
    elseif command == 'update' then
        printFF11("where:update.")
        init()
        start_display()
    end
    
	config.save(settings)
end)

function start_display()
    info = windower.ffxi.get_info()
    if not info.mog_house then
        setup_names(info.zone)
        ready_display()
	else
		hide()
    end
end

function ready_display()
    setup_text(zone_text,zone_name)
    setup_text(region_text,region_name)
    ready = true
    last_update = os.clock() + settings.waitTime
    coroutine.schedule(refresh_display, 0.100 + settings.waitTime)
    coroutine.schedule(setpos_text, 0.150 + settings.waitTime)
end

function setup_names(zone_id)
    setup_zone_name(zone_id)
    setup_region_name(zone_id)
end

function setup_zone_name(zone_id)
    zone_name = ''
    local zone_table = res.zones[zone_id]
    if (zone_table ~= nil) then
		if settings.language == 1 then
			zone_name = zone_table.en
		else
			zone_name = zone_table.ja
		end
        replace_zone_abbreviations()
        zone_name = string.format(settings.zonename.format,zone_name)
    end
end

function replace_zone_abbreviations()
    if (settings.zonename.replaceAbbreviations) then
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
			if settings.language == 1 then
				region_name = res.regions[i].en
			else
				region_name = res.regions[i].ja
			end
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

function setpos_text()
	local adjustFactor = windower_settings.x_res / windower_settings.ui_x_res
	local zone_text_width, zone_text_height = zone_text:extents() 
	local region_text_width, region_text_height = region_text:extents() 
	local x = 0
	local y = 0
	zone_text_height = zone_text_height-- * adjustFactor
	zone_text_width = zone_text_width-- * adjustFactor
	region_text_height = region_text_height-- * adjustFactor
    region_text_width = region_text_width-- * adjustFactor
    
	if pos_type == 0 then
		x = 0
		y = 0
	elseif pos_type == 1 then
		x = 0
		y = yRes - zone_text_height
	elseif pos_type == 2 then
		x = xRes - region_text_width - zone_text_width - (10 / adjustFactor)
		y = 0
	elseif pos_type == 3 then
		x = xRes - region_text_width - zone_text_width - (10 / adjustFactor)
        y = yRes - zone_text_height
    end
    if pos_type ~= 4 then
        region_text:pos(x,y)
        zone_text:pos(x + region_text_width + (10 / adjustFactor),y)
    else
        region_text:pos(settings.regionName.pos.x,settings.regionName.pos.y)
        zone_text:pos(settings.zonename.pos.x,settings.zonename.pos.y)
    end
end

windower.register_event("mouse",function(type,x,y,delta,blocked)
	if type == 1 then
		mouseON = 1
	end
	if type == 2 then
        mouseON = 0
		config.save(settings)
	end
end)

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
	if (time <= settings.fadeTime) then
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

function printFF11( text )
	windower.add_to_chat(207, windower.to_shift_jis(text))
end

