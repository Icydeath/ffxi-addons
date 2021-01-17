_addon.name    = 'triggers'
_addon.author  = 'Mujihina'
_addon.version = '1.0'
_addon.command = 'triggers'
_addon.commands = {'triggers', 'tg'}

require('luau')
require('chat')

local enable_mode = false
local trigger_text = nil
local response_text = nil
local count = 0

-- Show syntax
function show_syntax()
	print ('tg: Syntax is:')	
	print ('    tg status: Display status')
	print ('    tg start: Resume')
	print ('    tg stop: Pause')
	print ('    tg reset: Set counter back to 0')
	print ('    tg trigger <x>: Set trigger')
	print ('    tg response <x>: Set response')
end


-- Parse and process commands
function triggers_command(cmd, ...)
	if (not cmd or cmd == 'help' or cmd == 'h') then
		show_syntax()
		return
	end
	-- start
	if cmd == 'start' then
		if trigger_text and response_text then
			print('tg: starting')
			enable_mode = true
			return
		end
		print('tg: cannot restart if trigger and response are not set')
		return
	end

	-- stop
	if cmd == 'stop' then
		enable_mode = false
		print('tg: stopping')
		return
	end

    -- status
    if (cmd == 'status') then
        print('Enabled: %s\nTrigger: "%s"\nResponse: "%s"\nCount: %d':format(tostring(enable_mode), trigger_text or 'Not set', response_text or 'Not set', count))

        return
    end
	
	if cmd == 'reset' then
		count = 0
		print('tg: coutner set to 0')
		return
	end

	local args = L{...}
	-- Need more args from here on
    if (args:length() < 1) then
        print('tg: Check your syntax')
        show_syntax()
        return
    end

	local input = args:concat(' '):spaces_collapse()
	
	if cmd == 'trigger' then
		input = input:lower()
		trigger_text = input
		print('tg: Trigger set to "%s"':format(trigger_text))
		return
	end

	if cmd == 'response' then
		response_text = input
		print('tg: Response set to "%s"':format(response_text))
		return
	end
	show_syntax()
end

-- Process incoming texts
function process_text (original, modified, original_mode, modified_mode, blocked)
	if not enable_mode then return end

	--  ignore mode 200, so we dont trigger things with our own output
	if original_mode == 207 or original_mode == 200 then return end
    -- Process alerts
    original = string.strip_format(original)
    if original:lower():match(trigger_text) then
    	count = count + 1
    	print('tg: Trigger matched: %d':format(count))
    	windower.send_command ("input %s":format(response_text))
    end
end


-- Register callbacks
windower.register_event ('addon command', triggers_command)
windower.register_event ('incoming text', process_text)