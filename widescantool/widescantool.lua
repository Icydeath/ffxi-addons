--[[
widescantool v1.1

Copyright © 2019, Mujihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of widescantool nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mujihina BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name    = 'widescantool'
_addon.author  = 'Mujihina, modified by Icy'
_addon.version = '1.2i'
_addon.command = 'widescantool'
_addon.commands = {'wst'}

--[[ 
1.2i: 
 - added auto target '//wst target'
 - switched the <call> to play a sound instead
 - '//wst quiet' now toggles between on/off
]]

-- Required libraries
-- luau
-- config
-- packets
-- resources.zones
-- texts
require ('luau')
lib = {}
lib.config = require ('config')
lib.texts = require ('texts')
lib.packets = require ('packets')
lib.zones = require ('resources').zones


-- Load Defaults
function load_defaults()
    -- Do not load anything if we are not logged in
    if (not windower.ffxi.get_info().logged_in) then return end

    -- Skip if defaults have been loaded already
    if (global) then return end
    
    -- Main global structure
    global = {}
    global.defaults = {}
    global.defaults.worldalerts = S{}
    global.defaults.worldfilters = S{}
    global.defaults.area = T{}
    global.defaults.filter_pets = true
    -- alert textbox
    global.defaults.alertbox = {}
    global.defaults.alertbox.pos = {}
    global.defaults.alertbox.pos.x = (windower.get_windower_settings().ui_x_res / 2) - 50
    global.defaults.alertbox.pos.y = 100
    global.defaults.alertbox.text = {}
    global.defaults.alertbox.text.font = 'Consolas'
    global.defaults.alertbox.text.size = 15
    global.defaults.alertbox.text.alpha = 255
    global.defaults.alertbox.text.red = 255
    global.defaults.alertbox.text.green = 0
    global.defaults.alertbox.text.blue = 0
    global.defaults.alertbox.bg = {}
    global.defaults.alertbox.bg.alpha = 192
    global.defaults.alertbox.bg.red = 0
    global.defaults.alertbox.bg.green = 0
    global.defaults.alertbox.bg.blue = 0
    global.defaults.alertbox.padding = 5
    global.defaults.alertbox_default_string = "!ALERT!"

    global.player_name = windower.ffxi.get_player().name
    global.settings_file = "data/%s.xml":format(global.player_name)
    -- most common mob pet names
    global.pet_filters = S{"'s bat", "'s leech", "'s bats", "'s elemental", "'s spider", "'s tiger", "'s bee", "'s beetle", "'s rabbit"}
   
    -- Load previous settings
    global.settings = config.load(global.settings_file, global.defaults)

    -- Hack: Required since config loads 'sets' as 'strings'
    for _, i in global.settings.area:it() do
        if (type (global.settings.area[i].alerts) == 'string') then
            --print ("wst: adjusting alerts: strings -> set")
            global.settings.area[i].alerts = S(global.settings.area[i].alerts:split(','))
        elseif (class (global.settings.area[i].alerts) == 'Table') then
            --print ("wst: adjusting alerts: table -> set")
            local temp_set = S{}
            for i,_ in pairs(global.settings.area[i].alerts) do
                temp_set:add(i)
            end
            global.settings.area[i].alerts = temp_set
        end
        if (type (global.settings.area[i].filters) == 'string') then
            print ("wst: adjusting filters: strings -> sets")
            global.settings.area[i].filters = S(global.settings.area[i].filters:split(','))
        elseif (class (global.settings.area[i].filters) == 'Table') then
            --print ("wst: adjusting filters: table -> set")
            local temp_set = S{}
            for i,_ in pairs(global.settings.area[i].filters) do
                temp_set:add(i)
            end
            global.settings.area[i].filters = temp_set            
        end        
    end
    if (type (global.settings.worldfilters) == 'string') then
        --print ("wst: adjusting world filters: string -> set")
        global.settings.worldfilters = S(global.settings.worldfilters:split(','))
    end
    if (type (global.settings.worldalerts) == 'string') then
        --print ("wst: adjusting world alerts: string -> set")
        global.settings.worldalerts = S(global.settings.worldalerts:split(','))
    end        
       
    global.alertbox = lib.texts.new (global.defaults.alertbox_default_string, global.settings.alertbox)

    -- Performane configurables
    -- Only display global.max_memory_alerts on screen
    global.max_memory_alerts = 20
    -- only look at mob array once every global.skip_memory_scans
    global.skip_memory_scans = 2

    -- Extra Info
    global.show_index      = false
    global.show_invalid    = false
	global.auto_target     = true
	
    global.combined_alerts = S{}
    global.combined_filters = S{}
    global.zone_name = ""
    global.zone_id = 0
    global.enable_mode = true
    global.quiet_mode = true
    global.quiet_timer = 0
    -- iterator
    global.memory_scan_i = global.skip_memory_scans - 1
    
	show_common_cmds()
	
    update_area_info()
end

function show_common_cmds()
	windower.add_to_chat (200, 'wst: Commonly used commands:')
	windower.add_to_chat (207, '    \'wst quiet\': Enable/Disable playing a sound on alerts')
	windower.add_to_chat (207, '    \'wst target\': Enable/Disable auto targeting')
	windower.add_to_chat (207, '    \'wst aaa <name or pattern>\': Add Area Alert')
    windower.add_to_chat (207, '    \'wst raa <name or pattern>\': Remove Area Alert')
	windower.add_to_chat (207, '    \'wst aga <name or pattern>\': Add Global Alert')
    windower.add_to_chat (207, '    \'wst rga <name or pattern>\': Remove Global Alert')
	windower.add_to_chat (207, '\'wst help\': Shows all available commands')
end

-- Save settings
function save_settings()
    update_settings()
    lib.config.save(global.settings, 'all')
end


-- Change settings back to default
function reset_to_default()
    global.enable_mode = true
    global.settings:reassign(global.defaults)
    lib.config.save(global.settings, 'all')
    global.settings = lib.config.load(global.settings_file, global.defaults)
    update_settings()
    windower.add_to_chat (167, 'wst: All current and saved settings have been cleared')
end


function logout()
    if (global.alertbox) then
        global.alertbox:hide()
        global.alertbox:destroy()
    end
    -- To avoid weird things when switching characters
    --global.clear()
    global = nil
end

-- Show syntax
function show_syntax()
    windower.add_to_chat (200, 'wst: Syntax is:')
    windower.add_to_chat (207, '    \'wst lg\': List Global settings')
    windower.add_to_chat (207, '    \'wst la\': List settings for current Area')
    windower.add_to_chat (207, '    \'wst lc\': List the combined (global+area) filters/alerts currently being applied')
    windower.add_to_chat (207, '    \'wst laaf\': List All Area Filters')
    windower.add_to_chat (207, '    \'wst laaa\': List All Area Alerts')
    windower.add_to_chat (207, '    \'wst agf <name or pattern>\': Add Global Filter')
    windower.add_to_chat (207, '    \'wst rgf <name or pattern>\': Remove Global Filter')
    windower.add_to_chat (207, '    \'wst aga <name or pattern>\': Add Global Alert')
    windower.add_to_chat (207, '    \'wst rga <name or pattern>\': Remove Global Alert')
    windower.add_to_chat (207, '    \'wst aaf <name or pattern>\': Add Area Filter')
    windower.add_to_chat (207, '    \'wst raf <name or pattern>\': Remove Area Filter')
    windower.add_to_chat (207, '    \'wst aaa <name or pattern>\': Add Area Alert')
    windower.add_to_chat (207, '    \'wst raa <name or pattern>\': Remove Area Alert')
    windower.add_to_chat (207, '    \'wst defaults\': Reset to default settings')
    windower.add_to_chat (207, '    \'wst toggle\': Enable/Disable all filters/alerts temporarily')
    windower.add_to_chat (207, '    \'wst pet\': Enable/Disable filtering of common mob pets')
	windower.add_to_chat (207, '    \'wst target\': Enable/Disable auto targeting')
    windower.add_to_chat (207, '    \'wst quiet\': Enable/Disable playing a sound on alerts')
    --windower.add_to_chat (207, '    \'wst noquiet\': Use call alerts')
end


-- Parse and process commands
function wst_command (cmd, ...)
    if (not cmd or cmd == 'help' or cmd == 'h') then
        show_syntax()
        return
    end
	cmd = cmd:lower()
	
    -- Force a zone update. Mostly for debugging.
    if (cmd == 'u') then update_area_info() return end
    
    if (cmd == 'index') then 
        print ("wst: toggling show_index")
        global.show_index = not global.show_index
        return
    end
    
    if (cmd == 'invalid') then 
        print ("wst: toggling show_invalid")
        global.show_invalid = not global.show_invalid
        return
    end
    
    
    local args = L{...}
    
    -- Set to defaults
    if (cmd == 'defaults') then
        global.alertbox:hide()
        reset_to_default()
        return
    end

	-- Toggle auto targeting
	if (cmd == 'target' or cmd == 'auto') then
		global.auto_target = not global.auto_target
		windower.add_to_chat (200, global.auto_target and 'wst: auto targeting is now enabled' or 'wst: auto targeting is now disabled')
		save_settings()
		return
	end

    -- Toggle enable mode
    if (cmd == 'toggle') then
        global.enable_mode = not global.enable_mode
        if (global.enable_mode) then
            windower.add_to_chat (167, 'wst: filters/alerts have been re-enabled')
            -- check where we are
            update_area_info()
        else
            windower.add_to_chat (167, 'wst: filters/alerts are temporarily disabled')
            global.alertbox:hide()
        end
        return
    end

   -- Quiet mode
    if (cmd == 'quiet') then
        global.quiet_mode = not global.quiet_mode
        windower.add_to_chat (207, 'Alerting with sound: '..(global.quiet_mode and 'OFF' or 'ON'))
        return
    end

   -- Noquiet mode
    if (cmd == 'noquiet') then
        global.quiet_mode = false
        print('wst: quiet mode OFF')
        return
    end

    -- Toggle pet filter
    if (cmd == 'pet') then
        global.settings.filter_pets = not global.settings.filter_pets
        if (global.settings.filter_pets) then
            windower.add_to_chat(167, 'wst pet: filtering of common mob pets has been re-enabled')
        else
            windower.add_to_chat(167, 'wst pet: filtering of common mob pets has been disabled')
        end
        save_settings()
        return
    end


    -- List All Global settings
    if (cmd == 'lg') then
        windower.add_to_chat (207, 'wst lg: Global filters: %s':format(global.settings.worldfilters:tostring()))
        windower.add_to_chat (207, 'wst lg: Global alerts: %s':format(global.settings.worldalerts:tostring()))
        return
    end
    
    -- List combined settings
    if (cmd == 'lc') then
        windower.add_to_chat (207, 'wst lc: combined filters applied to %s: %s':format(global.zone_name, global.combined_filters:tostring()))
        windower.add_to_chat (207, 'wst lc: combined alerts applied to %s: %s':format(global.zone_name, global.combined_alerts:tostring()))
        return
    end
    
    -- List All settings in current area
    if (cmd == 'la') then
        if (global.settings.area[global.zone_index].filters) then
            windower.add_to_chat (207, 'wst la: Filters for %s: %s':format (global.zone_name, global.settings.area[global.zone_index].filters:tostring()))
        else
            print ("wst: zone id %d not found in config file":format(global.zone_id))
        end
        if (global.settings.area[global.zone_index].alerts) then
            windower.add_to_chat (207, 'wst la: Alerts for %s: %s':format (global.zone_name, global.settings.area[global.zone_index].alerts:tostring()))
        else
            print ("wst: zone id %d not found in config file":format(global.zone_id))
        end
        return
    end
    
    -- List All Area Filters
    if (cmd == 'laaf') then
        windower.add_to_chat (200, 'wst laaf: Listing ALL area Filters')
        for _, i in global.settings.area:it() do
            local area_name = lib.zones[i].name
            windower.add_to_chat (207, 'wst laaf: Filters for %s: %s':format(area_name, global.settings.area['zone' .. i].filters:tostring()))
        end
        return
    end
    
    -- List All Area Alerts
    if (cmd == 'laaa') then
        windower.add_to_chat (200, 'wst laaa: Listing ALL area Alerts')
        for _, i in global.settings.area:it() do
            log (i, type(i))
            local area_name = lib.zones[i].name
            windower.add_to_chat (207, 'wst laaa: Alerts for %s: %s':format(area_name, global.settings.area['zone' .. i].alerts:tostring()))
        end
        return
    end
    
    -- Need more args from here on
    if (args:length() < 1) then
        windower.add_to_chat (167, 'wst: Check your syntax')
        return
    end
    
    -- Name or pattern to use
    -- concat for multi word names, remove ',' and '"', remove extra spaces
    local input = args:concat(' '):lower():stripchars(',"'):spaces_collapse()
    
    -- only accept patterns with a-z, A-Z,0-9, spaces, "'", "-" and "."
    if (input == nil or not windower.regex.match(input, "^[a-zA-Z0-9 '-.?]+$")) then
        windower.add_to_chat (167, "wst: Rejecting pattern. Invalid characters in pattern")
        return
    end
    
    local pattern = "%s":format(input)
    
    -- Add Global Filter
    if (cmd == 'agf') then
        windower.add_to_chat (200, 'wst agf: Adding: \"%s\" to Global Filters':format(pattern))
        global.settings.worldfilters:add("%s":format(pattern))
        windower.add_to_chat (207, 'wst agf: Current global filters: %s':format(global.settings.worldfilters:tostring()))
        save_settings()
        return
    end
    -- Remove Global Filter
    if (cmd == 'rgf') then
        windower.add_to_chat (200, 'wst rgf: Removing \"%s\" from Global Filters':format(pattern))
        global.settings.worldfilters:remove("%s":format(pattern))
        windower.add_to_chat (207, 'wst rgf: Current global filters: %s':format(global.settings.worldfilters:tostring()))
        save_settings()
        return
    end
    -- Add Global Alert
    if (cmd == 'aga') then
        windower.add_to_chat (200, 'wst aga: Adding: \"%s\" to Global Alerts':format(pattern))
        global.settings.worldalerts:add("%s":format(pattern))
        windower.add_to_chat (207, 'wst aga: Current global alerts: %s':format(global.settings.worldalerts:tostring()))
        save_settings()
        return
    end
    -- Remove Global Alert
    if (cmd == 'rga') then
        windower.add_to_chat (200, 'wst rga: Removing \"%s\" from Global Alerts':format(pattern))
        global.settings.worldalerts:remove("%s":format(pattern))
        windower.add_to_chat (207, 'wst rga: Current global alerts: %s':format(global.settings.worldalerts:tostring()))
        save_settings()
        return
    end
    -- Add Area Filter
    if (cmd == 'aaf') then
        windower.add_to_chat (200, 'wst aaf: Adding: \"%s\" to area Filters for %s':format(pattern, global.zone_name))
        if (not global.settings.area[global.zone_index]) then
            print ("wst: Adding %s to config file":format(global.zone_name))
            global.settings.area[global.zone_index] = T{}
            global.settings.area[global.zone_index].alerts  = S{}
            global.settings.area[global.zone_index].filters = S{}
            global.settings.area[global.zone_index].name = global.zone_name
            
        end
        global.settings.area[global.zone_index].filters:add("%s":format(pattern))
        windower.add_to_chat (207, 'wst aaf: Current filters for %s: %s':format(global.zone_name, global.settings.area[global.zone_index].filters:tostring()))
        save_settings()
        return
    end
    -- Remove Area Filter
    if (cmd == 'raf') then
        windower.add_to_chat (200, 'wst raf: Removing: \"%s\" from area Filters for %s':format(pattern, global.zone_name))
        if (global.settings.area[global.zone_index] and global.settings.area[global.zone_index].filters) then
            global.settings.area[global.zone_index].filters:remove("%s":format(pattern))
            windower.add_to_chat (207, 'wst raf: Current filters for %s: %s':format(global.zone_name, global.settings.area[global.zone_index].filters:tostring()))
            save_settings()
        end
        return
    end
    -- Add Area Alert
    if (cmd == 'aaa') then
        windower.add_to_chat (200, 'wst aaa: Adding: \"%s\" to area Alerts for %s':format(pattern, global.zone_name))
        if (not global.settings.area[global.zone_index]) then
            print ("wst: Adding %s to config file":format(global.zone_name))
            global.settings.area[global.zone_index] = T{}
            global.settings.area[global.zone_index].alerts  = S{}
            global.settings.area[global.zone_index].filters = S{}
            global.settings.area[global.zone_index].name = global.zone_name
        end
        global.settings.area[global.zone_index].alerts:add("%s":format(pattern))
        windower.add_to_chat (207, 'wst aaa: Current alerts for %s: %s':format(global.zone_name, global.settings.area[global.zone_index].alerts:tostring()))
        save_settings()
        return
    end
    -- Remove Area Alert
    if (cmd == 'raa') then
        windower.add_to_chat(200, 'wst raa: Removing: \"%s\" from area Alerts for %s':format(pattern, global.zone_name))
        if (global.settings.area[global.zone_index] and global.settings.area[global.zone_index].alerts) then
            global.settings.area[global.zone_index].alerts:remove("%s":format(pattern))
            windower.add_to_chat (207, 'wst raa: Current alerts for %s: %s':format(global.zone_name, global.settings.area[global.zone_index].alerts:tostring()))
            save_settings()
        end
        return
    end

    
    -- Show Syntax
    windower.add_to_chat (167, 'wst: Check your syntax')
end


-- calculate new sets with new area
function update_settings()
    global.combined_alerts = global.settings.worldalerts
    global.combined_filters = global.settings.worldfilters

    if (global.settings.area[global.zone_index]) then
        if (global.settings.area[global.zone_index].alerts) then
            global.combined_alerts = global.combined_alerts + global.settings.area[global.zone_index].alerts
        end
        if (global.settings.area[global.zone_index].filters) then
            global.combined_filters = global.combined_filters + global.settings.area[global.zone_index].filters
        end
    end
    if (global.settings.filter_pets) then
        global.combined_filters = global.pet_filters + global.combined_filters
    end
end

-- update area location
function update_area_info()
    -- Load defaults if needed
    if (not global) then load_defaults() return end

    global.zone_id =  windower.ffxi.get_info().zone
    global.zone_name = lib.zones[global.zone_id].name
    global.zone_index = 'zone' .. global.zone_id
    update_settings()
end

--Cribbed from SetTarget.lua at https://github.com/Windower/Lua/tree/live/addons/SetTarget
function set_target(id)
    id = tonumber(id)
    if id == nil then
        return
    end

    local target = windower.ffxi.get_mob_by_id(id)
    if not target then
        return
    end

	local current_target = windower.ffxi.get_mob_by_target('t')
	if current_target and current_target.id == id then
		return
	end

	-- distance check
	local target_distance = math.sqrt(target.distance)
	if target_distance > 48 then
		return
	end
	
    local player = windower.ffxi.get_player()

    lib.packets.inject(lib.packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = target.id,
        ['Player Index'] = player.index,
    }))
end

-- Process incoming packets
function wst_process_packets (id, original, modified, injected, blocked)
    if ((not global) or (not global.enable_mode)) then return end
    
    -- Process widescan replies
    if (id==0xF4) then
        local p = lib.packets.parse ('incoming', original)
        local short_name = p['Name']
        local index = p['Index']
        local ID = 0x01000000 + (4096 * global.zone_id) + index
        local official_name = windower.ffxi.get_mob_name(ID) or short_name

        if (official_name == nil) then return end
        local name_to_match = official_name:lower()
            
        -- Process filters
        for i in global.combined_filters:it() do
            if (name_to_match:match('%s':format(i))) then
                return true
            end
        end
        
        -- Process alerts
        for i in global.combined_alerts:it() do
            if (name_to_match:match('%s':format(i))) then
                local extra = ''
                local pos = '(%d,%d)':format(p['X Offset'], p['Y Offset'])
                if (global.show_index) then extra = "(%.3X)":format(index) end
                windower.add_to_chat(167, 'wst alert: %s detected!! %s %s':format(name_to_match, extra, pos))
                return
            end
            if i:startswith('0x') then
            	local hex_search = tonumber(i)
            	local pos = '(%d,%d)':format(p['X Offset'], p['Y Offset'])
            	--log('comparing %s, "%s", %.3X, "%s"':format(short_name, hex_search, index, index))
            	if hex_search == index then
            		windower.add_to_chat(167, 'wst alert: %s detected by id (%.3X) %s!!':format(name_to_match, index, pos))
            	end
            end
        end
    end
    
	local target_id
    -- Process memory alerts
    if (id==0xE) then 
        -- Only look at 1 memory table every global.skip_memory_scans
        global.memory_scan_i  = global.memory_scan_i + 1
        if (global.memory_scan_i % global.skip_memory_scans ~= 0) then return end

        local mob_array = windower.ffxi.get_mob_array()
        local alert_count = 0
        local alert_list = L{}
        for _,v in pairs(mob_array) do
            if (alert_count > global.max_memory_alerts) then break end
            local mob_name = v['name']
            if (mob_name and (global.show_invalid or (v['valid_target'] and v['status'] == 0))) then
                for i in global.combined_alerts:it() do
                	local hex_search = tonumber(i)
                    if mob_name:lower():match("%s":format(i)) or v['index'] == hex_search then
						target_id = v['id']
						
                        alert_count = alert_count + 1
                        if not global.quiet_mode then
                        	if global.quiet_timer > 0 then
                        		global.quiet_timer = global.quiet_timer - 1
                        	else
                        		global.quiet_timer = 60
								windower.play_sound(windower.addon_path..'sounds/doublebass.wav')
                        		--windower.send_command('input /p %s <call>':format(mob_name))
                        	end
                        end
                        -- If too many, just stop.
                        if (alert_count > global.max_memory_alerts) then
                            alert_list:append("+")
                            --return
                            break
                        end
                        local index_string = ""
                        if (global.show_index) then index_string = "(%.3X) ":format(v['index']) end
                        local invalid_string = ""
                        if (global.show_invalid and not v['valid_target']) then invalid_string = "(I)" end
                        alert_list:append ("%s %s[%d]%s":format(mob_name, index_string, v['distance']:sqrt(), invalid_string))
                        break
                    end
                end
            end
        end
        if (alert_count < 1) then
            global.alertbox:hide()
        else
            global.alertbox:clear()
            global.alertbox:text ("%s\n%s":format(global.defaults.alertbox_default_string, alert_list:concat ('\n')))
            global.alertbox:show()
        end
    end
	
	if global.auto_target and target_id then
		set_target(target_id)
	end
end

-- Register callbacks
windower.register_event ('addon command', wst_command)
windower.register_event ('incoming chunk', wst_process_packets)
windower.register_event ('zone change', update_area_info)
windower.register_event ('load', 'login', load_defaults)
windower.register_event ('logout', logout)
