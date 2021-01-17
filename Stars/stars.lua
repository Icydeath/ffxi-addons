_addon.name = 'stars'
_addon.version = '0.11'
_addon.author = 'Chiaia (Asura), modded by Icy'
_addon.commands = {'stars', '***'}

--[[ 8/23/2020
	added settings: blackListUsers & reloadOnAlts
	added commands: blist, alts, help
]]
packets = require('packets')
config = require('config')

default = {}
default.reloadOnAlts = true -- when true it will reload stars.lua on your alts
default.blackListedUsers = S{}
settings = config.load(default)

-- I could do a general digit check on JP instead of set 500/2100 values but atm I feel it's not needed. Will see if they change thier tactics.
-- If you want to learn more about "Magical Characters" or Patterns in Lua: <a href="https://riptutorial.com/lua/example/20315/lua-pattern-matching" rel="nofollow">https://riptutorial.com/lua/example/20315/lua-pattern-matching</a>
local blackListedWords = T{string.char(0x81,0x99),string.char(0x81,0x9A),'1%-99','Job Point.*2100','Job Point.*500','Job Points.*2100','Job Points.*500','JP.*2100','JP.*500','Capacity Point.*2100','Capacity Point.*500','CP.*2100','CP.*500','★','★,', 'AFK Leech', '0*2100'} -- First two are '☆' and '★' symbols.
 
windower.register_event('incoming chunk', function(id,data)
    if id == 0x017 then -- 0x017 Is incoming chat.
        local chat = packets.parse('incoming', data)
        local cleaned = windower.convert_auto_trans(chat['Message']):lower()
 
        if settings.blackListedUsers:contains(chat['Sender Name']) then -- Blocks any message from X user in any chat mode.
            return true
        elseif (chat['Mode'] == 3 or chat['Mode'] == 1 or chat['Mode'] == 26) then -- RMT checks in tell, shouts, and yells. Years ago they use to use tells to be more stealthy about gil selling.
            for k,v in ipairs(blackListedWords) do
                if cleaned:match(v:lower()) then
                    return true
                end
            end
        end
    end
end)

function print_help()
	windower.add_to_chat(208, "STARS - COMMANDS")
	windower.add_to_chat(207, "//stars blist <name> (adds or removes the name from the list)")
	windower.add_to_chat(207, "//stars alts (reloads stars on all alts)")
end

windower.register_event('addon command', function(...)
	local args = T{...}
	if args[1] then
		if args[1]:lower() == "help" then
			print_help()
			return
		end
		
		if args[1]:lower() == "alts" then
			settings.reloadOnAlts = not settings.reloadOnAlts
			settings:save('all')
			windower.add_to_chat(207, 'stars: reloadOnAlts: '..tostring(settings.reloadOnAlts))
			return
		end
		
		if args[1]:lower() == "blist" then
			if args[2] then
				local modified = false
				if not settings.blackListedUsers:contains(args[2]) then
					settings.blackListedUsers:add(args[2])
					settings:save('all')
					windower.add_to_chat(207,'stars: "'..args[2]..'" ADDED to blist.')
					modified = true
				elseif args[1]:lower() == "blist" and settings.blackListedUsers:contains(args[2]) then
					for name,v in pairs(settings.blackListedUsers) do
						if name:lower() == args[2]:lower() then
							settings.blackListedUsers:remove(name)
							settings:save('all')
							windower.add_to_chat(207, 'stars: "'..args[2]..'" REMOVED from blist.')
							modified = true
						end
					end
				end
				
				if modified and settings.reloadOnAlts then
					windower.send_command('send @others lua r stars')
				end
			else
				windower.add_to_chat(207, '[blist]')
				for name,v in pairs(settings.blackListedUsers) do
					windower.add_to_chat(207, '  '..name)
				end
			end
		end
	else
		print_help()
	end
end)

