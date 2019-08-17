package.path = "./?.lua;./spec/mock/?.lua"

local match = require("luassert.match")
local any = match._

resources = nil

describe("Empyrean Tracker", function()
	local get_addon = function()
		return require("empyreantracker")
	end

	local sent_chats
	local registered_events
	local nm_data
	local nm_files
	local character_kis
	local character_items

	local trigger_event = function(event_name, ...)
		local events = registered_events[event_name]
		if not events then
			error('Event "' .. event_name .. '" not registered and cannot be triggered')
		end

		for _, v in pairs(events) do
			v(...)
		end
	end

	before_each(function()
		_G._addon = {}
		package.loaded.empyreantracker = nil
		package.loaded.resources = nil
		package.loaded.files = nil
		config = require("config")
		texts = require("texts")
		file = require("files")
		resources = require("resources")
		registered_events = {}
		sent_chats = {}
		character_kis = {}
		character_items = {}
		_G.windower = {}
		_G.windower.register_event = function(...)
			local args = {...}
			for i = 1, #args - 1, 1 do
				if registered_events[args[i]] then
					table.insert(registered_events[args[i]], args[#args])
				else
					registered_events[args[i]] = {args[#args]}
				end
			end
		end
		_G.windower.add_to_chat = function(mode, text)
			table.insert(sent_chats, { mode, text })
		end
		_G.windower.ffxi = {}
		_G.windower.ffxi.get_key_items = function()
			return character_kis
		end
		_G.windower.ffxi.get_items = function()
			return {
				inventory = character_items
			}
		end
		nm_data = {
			name = "Mock NM",
			pops = { {
				id = 1,
				type = "key item",
				dropped_from = {
					name = "Mock Sub NM",
					pops = { {
						id = 1,
						type = "item",
						dropped_from = { name = "Jaculus (Timed, 10-15 mins, (I-8/I-9))" }
					}, {
						id = 2,
						type = "item",
						dropped_from = {
							name = "Minaruja (Forced, (I-9))",
							pops = { {
								id = 3,
								type = "item",
								dropped_from = { name = "Faunus Wyvern (I-9/I-10)" }
							} }
						} 
					} }
				}
			} }
		}
		nm_files = { "mock.lua" }

		stub(io, "popen", function(arg)
			if arg == "nms" then
				return nm_files
			else
				return {}
			end
		end)

		stub(file, 'exists', function(file_name)
			local exists = false
			for _, nm_file in pairs(nm_files) do
				local file_location = 'nms/' .. nm_file
				if file_location == file_name then
					exists = true
					break
				end
			end
			return exists
		end)
	end)

	it("sets the _addon name to Empyrean Tracker", function()
		get_addon()

		assert.is.equal("Empyrean Tracker", _G._addon.name)
	end)

	it("sets the _addon author as Dean James (Xurion of Bismarck)", function()
		get_addon()

		assert.is.equal("Dean James (Xurion of Bismarck)", _G._addon.author)
	end)

	it("sets the available _addon commands to be empyreantracker, empytracker and empy", function()
		get_addon()

		assert.are.same({ "empyreantracker", "empytracker", "empy" }, _G._addon.commands)
	end)

	it("sets the _addon version", function()
		get_addon()

		assert.is.truthy(_G._addon.version)
	end)

	it("creates/loads settings from the config and passes the text config it to a new instance of text", function()
		local config_data = {
			text = "text config",
			other = "other config"
		}
		stub(config, "load", config_data)
		spy.on(texts, "new")

		get_addon()

		assert.stub(config.load).was.called(1)
		assert.spy(texts.new).was.called_with(config_data.text, config_data)
	end)

	it("stores the settings from the config loader to EmpyreanTracker.settings", function()
		local config_data = {
			text = "text config",
			other = "other config"
		}
		stub(config, "load", config_data)
		
		local addon = get_addon()

		assert.equal(config_data, addon.settings)
	end)

-- 	it("sets the new instance of text as a reference on EmpyreanTracker", function()
-- 		local new_text = {}
-- 		stub(texts, "new", function() return new_text end)

-- 		local addon = get_addon()
-- print('empyreantracker_spec.lua:143', addon.text)
-- 		assert.equal(new_text, addon.text)
-- 	end)

	it("sets a default text x and y setting of 0", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(0, config.load.calls[1].vals[1].text.pos.x)
		assert.are.same(0, config.load.calls[1].vals[1].text.pos.y)
	end)

	it("sets a default text alpha background setting of 150", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(150, config.load.calls[1].vals[1].text.bg.alpha)
	end)

	it("sets default text rgb background settings to black (0, 0, 0)", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(0, config.load.calls[1].vals[1].text.bg.blue)
		assert.are.same(0, config.load.calls[1].vals[1].text.bg.green)
		assert.are.same(0, config.load.calls[1].vals[1].text.bg.red)
	end)

	it("sets a default text visible background setting to true", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(true, config.load.calls[1].vals[1].text.bg.visible)
	end)

	it("sets a default text padding setting to 8", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(8, config.load.calls[1].vals[1].text.padding)
	end)

	it("sets a default text font setting to Consolas", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same("Consolas", config.load.calls[1].vals[1].text.text.font)
	end)

	it("sets a default text size setting to 10", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(10, config.load.calls[1].vals[1].text.text.size)
	end)

	it("sets a default tracking setting to briareus", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same("briareus", config.load.calls[1].vals[1].tracking)
	end)

	describe("add_to_chat(message)", function()
		it("throws an error if the message arg is not a string", function()
			local addon = get_addon()

			assert.has_error(function()
				addon.add_to_chat({})
			end, "add_to_chat requires the message arg to be a string")
		end)

		it("passes the given message arg to windower.add_to_chat under mode 8", function()
			local addon = get_addon()
			spy.on(_G.windower, 'add_to_chat')

			addon.add_to_chat('Sup')

			assert.spy(_G.windower.add_to_chat).was_called_with(8, 'Sup')
		end)
	end)

	describe("generate_info(nm, key_items, items)", function()
		it("throws an error if the nm arg is not a table", function()
			local addon = get_addon()

			assert.has_error(function()
				addon.generate_info(nil, {}, {})
			end, "generate_info requires the nm arg to be a table")
		end)

		it("returns a table with a has_all_kis property set to false when the key_items arg does not contain all of the entries of the nm arg", function()
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = 'a' }
			}, {
				id = 2,
				dropped_from = { name = 'b' }
			}, {
				id = 3,
				dropped_from = { name = 'c' }
			}}
			local key_items = { 1, 3 } --missing KI 2

			local result = addon.generate_info(nm_data, key_items, {})

			assert.equal(false, result.has_all_kis)
		end)

		it("returns a table with a has_all_kis property set to true when the key_items arg contains all of the entries of the nm arg", function()
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = 'a' }
			}, {
				id = 2,
				dropped_from = { name = 'b' }
			}, {
				id = 3,
				dropped_from = { name = 'c' }
			}}
			local key_items = { 1, 2, 3 }

			local result = addon.generate_info(nm_data, key_items, {})

			assert.equal(true, result.has_all_kis)
		end)

		it("returns a table with a text property that starts with the name from the nm arg", function()
			local addon = get_addon()
			local key_items = {}
			nm_data.name = "Bennu"

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Bennu", lines[1])
		end)

		it("returns a table with a text property that contains a spacer line followed by the name of the nm that drops the key item in the nm arg", function()
			local addon = get_addon()
			nm_data.pops[1].dropped_from = { name = "Sub Mob" }

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("", lines[2])
			assert.equal("Sub Mob", lines[3])
		end)

		it("returns a table with a text property that contains the name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "Bennu Pop KI"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "Bennu Sub NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Bennu Pop KI", strip_indent_from_string(lines[4]))
		end)

		it("returns a table with a text property that contains the capitalised name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "the pop key item"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("The Pop Key Item", strip_indent_from_string(lines[4]))
		end)

		it("returns a table with a text property that contains the indented name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "Indented Pop KI"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			local indent = get_indent_from_string(lines[4])
			assert.equal(2, #indent)
		end)

		it('returns a table with a text property that contains the name of the key item as "Unknown KI" if the KI ID is not found in Windower Resources', function()
			resources.key_items[10] = nil
			local addon = get_addon()
			nm_data.pops = {{
				id = 10,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Unknown KI", strip_indent_from_string(lines[4]))
		end)
	end)

	describe("list command", function()
		it('sends "Trackable NMs:" as the first message to the chat log', function()
			local addon = get_addon()
			nm_files = { "nm.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "list")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal("Trackable NMs:", addon.add_to_chat.calls[1].vals[1])
		end)

		it("lists the files in the nms directory with capitalised first letter and no file extension", function()
			local addon = get_addon()
			nm_files = { "nm.lua", "another.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "list")

			assert.spy(addon.add_to_chat).was_called()
			assert.is.equal("Nm", addon.add_to_chat.calls[2].vals[1])
			assert.is.equal("Another", addon.add_to_chat.calls[3].vals[1])
		end)

		it("lists the files in the nms directory with capitalised first letter and no file extension", function()
			local addon = get_addon()
			nm_files = { "nm.lua", "another-nm.lua" }

			trigger_event("addon command", "list")

			assert.is.equal(8, sent_chats[2][1])
			assert.is.equal("Nm", sent_chats[2][2])
			assert.is.equal(8, sent_chats[3][1])
			assert.is.equal("Another Nm", sent_chats[3][2])
		end)

		it("does not list files in the nms directory that are not .lua", function()
			local addon = get_addon()
			nm_files = { "nm.txt", "another-nm.lua", "third-nm" }

			trigger_event("addon command", "list")

			assert.is.equal("Another Nm", sent_chats[2][2])
			assert.is_nil(sent_chats[3])
		end)
	end)

	describe("track command", function()
		it('sends "Now tracking: [nm name]" to the chat log', function()
			local addon = get_addon()
			nm_files = { "feanorsof.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "track", "Feanorsof")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal("Now tracking: Feanorsof", addon.add_to_chat.calls[1].vals[1])
		end)

		it('sends "Now tracking: [nm name]" to the chat log with the first capitalised first letter', function()
			local addon = get_addon()
			nm_files = { "feanorsof.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "track", "feanorsof")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal("Now tracking: Feanorsof", addon.add_to_chat.calls[1].vals[1])
		end)

		it('sends "Now tracking: [nm name]" to the chat log even when there is an inconsitent case match', function()
			local addon = get_addon()
			nm_files = { "feanorsof.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "track", "FeAnOrSoF")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal("Now tracking: Feanorsof", addon.add_to_chat.calls[1].vals[1])
		end)

		it('sets the tracking setting to the lower case equivalent of the given nm name', function()
			local addon = get_addon()
			nm_files = { "laylina.lua" }

			trigger_event("addon command", "track", "lAyLInA")

			assert.equal("laylina", addon.settings.tracking)
		end)

		it('sets the tracking setting to the lower case equivalent of the partially-matching given nm name', function()
			local addon = get_addon()
			nm_files = { "laylina.lua" }

			trigger_event("addon command", "track", "lAy")

			assert.equal("laylina", addon.settings.tracking)
		end)

		it('logs a message to the chat log when a partially-matching nm name matches two different files', function()
			local addon = get_addon()
			nm_files = { "laylina.lua", "laylin0rz.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "track", "lay")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal('"lay" matches 2 files. Please be more explicit:', addon.add_to_chat.calls[1].vals[1])
			assert.equal('  Match 1: Laylina', addon.add_to_chat.calls[2].vals[1])
			assert.equal('  Match 2: Laylin0rz', addon.add_to_chat.calls[3].vals[1])
			assert.equal(3, #addon.add_to_chat.calls)
		end)

		it('logs a message to the chat log when the nm name does not partially match any files', function()
			local addon = get_addon()
			nm_files = { "not-laylina.lua" }
			spy.on(addon, 'add_to_chat')

			trigger_event("addon command", "track", "lay")

			assert.spy(addon.add_to_chat).was_called()
			assert.equal('Unable to find NMs using: "lay"', addon.add_to_chat.calls[1].vals[1])
			assert.equal(1, #addon.add_to_chat.calls)
		end)
	end)

	describe("update()", function()
		it('sets the text component as visible', function()
			local addon = get_addon()
			spy.on(addon.text, 'visible')

			addon.update()

			assert.spy(addon.text.visible).was_called_with(addon.text, true)
		end)

		it('calls generate_info with the currently tracked NM', function()
			local addon = get_addon()
			addon.settings.tracking = 'leananshee'
			spy.on(addon, 'generate_info')

			addon.update()

			assert.spy(addon.generate_info).was_called_with('leananshee', any, any)
		end)

		it('calls generate_info with the characters key_items', function()
			local addon = get_addon()
			character_kis = {6}
			spy.on(addon, 'generate_info')

			addon.update()

			assert.spy(addon.generate_info).was_called_with(any, {6}, any)
		end)

		it('calls generate_info with the characters items from their inventory', function()
			local addon = get_addon()
			character_items = {44}
			spy.on(addon, 'generate_info')

			addon.update()

			assert.spy(addon.generate_info).was_called_with(any, any, {44})
		end)

		it('updates the text component with the text property from generate_info', function()
			local addon = get_addon()
			stub(addon, 'generate_info', function()
				return {text = 'generated info text'}
			end)
			spy.on(addon.text, 'update')

			addon.update()

			assert.spy(addon.text.update).was_called_with(addon.text, 'generated info text')
		end)

		it('sets the text component background to green if generate_info states the character has all the KIs needed', function()
			local addon = get_addon()
			stub(addon, 'generate_info', function()
				return {has_all_kis = true}
			end)
			spy.on(addon.text, 'bg_color')

			addon.update()

			assert.spy(addon.text.bg_color).was_called_with(addon.text, 0, 75, 0)
		end)

		it('sets the text component background to black if generate_info states the character does have all the KIs needed', function()
			local addon = get_addon()
			stub(addon, 'generate_info', function()
				return {has_all_kis = false}
			end)
			spy.on(addon.text, 'bg_color')

			addon.update()

			assert.spy(addon.text.bg_color).was_called_with(addon.text, 0, 0, 0)
		end)
	end)

	describe('load event', function()
		it('calls the update function', function()
			local addon = get_addon()
			spy.on(addon, 'update')

			trigger_event('load')

			assert.spy(addon.update).was_called()
		end)
	end)

	describe('incoming text event', function()
		it('calls the update function', function()
			local addon = get_addon()
			spy.on(addon, 'update')

			trigger_event('incoming text')

			assert.spy(addon.update).was_called()
		end)
	end)

	describe('remove item event', function()
		it('calls the update function', function()
			local addon = get_addon()
			spy.on(addon, 'update')

			trigger_event('remove item')

			assert.spy(addon.update).was_called()
		end)
	end)
end)

function get_lines_from_string(str)
	local lines = {}
	for line in str:gmatch("([^\r\n]*)") do
		table.insert(lines, line)
	end
	return lines
end

function get_indent_from_string(str)
	return str:match("^(%s*)")
end

function strip_indent_from_string(str) 
	return str:match("^%s*(.+)")
end

function print_r(t)
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if print_r_cache[tostring(t)] then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						print(
							indent .. "[" .. pos .. "] => " .. tostring(
								t
							) .. " {"
						)
						sub_print_r(
							val,
							indent .. string.rep(" ", string.len(pos) + 8)
						)
						print(
							indent .. string.rep(
								" ",
								string.len(pos) + 6
							) .. "}"
						)
					elseif (type(val) == "string") then
						print(indent .. "[" .. pos .. '] => "' .. val .. '"')
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end

	if (type(t) == "table") then
		print(tostring(t) .. " {")
		sub_print_r(t, "  ")
		print("}")
	else
		sub_print_r(t, "  ")
	end
	print()
end
