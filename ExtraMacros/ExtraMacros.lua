_addon.author = 'Jyouya'
_addon.command = 'em'
_addon.name = 'ExtraMacros'
_addon.version = '1.0'

config = require('config')
require('strings')

settings = config.load()

current_display = nil

keys_pressed = {
	[219] = false,
	[220] = false,
	[56] = false,
	[29] = false,
	[221] = false,
}

kb_modifiers = {
	[219] = 'win',
	[220] = 'win',
	[56] = 'alt',
	[29] = 'ctrl',
	[221] = 'apps'
}

display_book = {
	win = false,
	alt = false,
	ctrl = false,
	apps = false,
}

function display_macros(dik)
	current_display = kb_modifiers[dik]
	windower.prim.set_visibility(current_display..'_book', true)
	for k, v in pairs(_G[current_display..'_text']) do
		windower.text.set_visibility(v.bind, true)
		windower.text.set_visibility(v.text, true)
	end
end

function hide_macros(dik)
	windower.prim.set_visibility(current_display..'_book', false)
	for k, v in pairs(_G[current_display..'_text']) do
		windower.text.set_visibility(v.bind, false)
		windower.text.set_visibility(v.text, false)
	end
	current_display = nil
end

windower.register_event('keyboard', function(dik, pressed, flags, blocked)
	if display_book[kb_modifiers[dik]] then
		keys_pressed[dik] = pressed
		if pressed and not current_display then	-- we need to pull up a new macrobar
			display_macros(dik)
		elseif not pressed and kb_modifiers[dik] then -- one of our modifier keys was released
			if current_display == kb_modifiers[dik] then -- the key for the window macrobook we're displaying was released
				hide_macros(dik)
				for k,v in pairs(keys_pressed) do
					if v then
						display_macros(k)
						break
					end
				end
			end
		end
	end
end)

windower.register_event('addon command', function(...)
	
end)

windower.register_event('job change', function(main_job_id, main_job_level, sub_job_id, sub_job_level)
	windower.send_command('lua r ExtraMacros')
end)

keynames = {
	backtick='`',
	minus='-',
	equals='=',
	backslash='\\',
	period='.',
	comma=',',
	lbracket='[',
	rbracket=']',
	semicolon=';',
	slash='/',
	}

function resolve_keyname(str)
	return keynames[str] or str
end

function bind_keys(mod, k, v)
	k = resolve_keyname(k)
	windower.send_command('bind %s%s %s':format({win='@',alt='!',ctrl='^',apps='#'}[mod],k,v.command))
	local bind = '%s %s':format(mod:ucfirst(),k:upper())
	_G[mod..'_text'][bind] = {text=bind..'1', bind=bind..'2'}
	
	-- Create the text object for the description
	windower.text.create(_G[mod..'_text'][bind].text)
	windower.text.set_text(_G[mod..'_text'][bind].text, v.text)
	windower.text.set_location(_G[mod..'_text'][bind].text, settings.posx + 5 + (v.x - 1) * 68, settings.posy + 1 + (v.y - 1) * 56)
	windower.text.set_color(_G[mod..'_text'][bind].text, T(
		v.color and T(v.color:chunks(2)):map(function(s) return tonumber('0x'..s) end) or
		{255, 255, 255, 255}):unpack()) -- default
		
		
	windower.text.set_bold(_G[mod..'_text'][bind].text, true)
	windower.text.set_font(_G[mod..'_text'][bind].text, 'Helvetica')
	windower.text.set_font_size(_G[mod..'_text'][bind].text, 10)
	windower.text.set_visibility(_G[mod..'_text'][bind].text, false)
	
	-- Create the text object for the keybind info
	windower.text.create(_G[mod..'_text'][bind].bind)
	windower.text.set_text(_G[mod..'_text'][bind].bind, bind)
	windower.text.set_location(_G[mod..'_text'][bind].bind, settings.posx - 6 + v.x * 68, settings.posy + 36 + (v.y - 1) * 56)
	windower.text.set_right_justified(_G[mod..'_text'][bind].bind, true)
	windower.text.set_color(_G[mod..'_text'][bind].bind, T(
		v.color and T(v.color:chunks(2)):map(function(s) return tonumber('0x'..s) end) or 
		{255, 255, 255, 255}):unpack())
	windower.text.set_bold(_G[mod..'_text'][bind].bind, true)
	windower.text.set_font(_G[mod..'_text'][bind].bind, 'Helvetica')
	windower.text.set_font_size(_G[mod..'_text'][bind].bind, 10)
	windower.text.set_visibility(_G[mod..'_text'][bind].bind, false)
	
	display_book[mod] = true
end

me = windower.ffxi.get_player()
-- Create the three macrobars
for k, v in pairs{'win','alt','ctrl','apps'} do
	windower.prim.create(v..'_book')
	windower.prim.set_visibility(v..'_book', false)
	windower.prim.set_position(v..'_book', settings.posx, settings.posy)
	--windower.prim.set_texture(v..'_book', windower.addon_path..'data/blank_macrobar.png')
	
	--windower.prim.set_fit_to_texture(v..'_book', true)
	_G[v..'_text'] = {}
	
	local x_repeat = 1
	local y_repeat = 1
	
	if settings[v] then
		for k2, v2 in pairs(settings[v]) do
			if v2.x > x_repeat then
				x_repeat = v2.x
			end
			if v2.y > y_repeat then
				y_repeat = v2.y
			end
			bind_keys(v,k2,v2)
		end
	end
	
	if settings.jobspecific and settings.jobspecific[me.main_job:lower()] then
		for k2, v2 in pairs(settings.jobspecific[me.main_job:lower()][v]) do
			if v2.x > x_repeat then
				x_repeat = v2.x
			end
			if v2.y > y_repeat then
				y_repeat = v2.y
			end
			bind_keys(v,k2,v2)
		end
		if settings.jobspecific[me.main_job:lower()][me.sub_job:lower()] then
			for k2, v2 in pairs(settings.jobspecific[me.main_job:lower()][me.sub_job:lower()][v]) do
				if v2.x > x_repeat then
					x_repeat = v2.x
				end
				if v2.y > y_repeat then
					y_repeat = v2.y
				end
				bind_keys(v,k2,v2)
			end
		end
	end

	windower.prim.set_repeat(v..'_book', x_repeat, y_repeat)
	windower.prim.set_texture(v..'_book', windower.addon_path..'data/macro_tile.png')
	windower.prim.set_fit_to_texture(v..'_book', false)
	windower.prim.set_size(v..'_book', x_repeat * 68, y_repeat * 56)

end

--[[me = windower.ffxi.get_player()

if settings.jobspecific and settings.jobspecific[me.main_job:lower()] then
	for i, mod in pairs{'win','alt','ctrl','apps'} do
		for k, v in pairs(settings.jobspecific[me.main_job:lower()][mod]) do
			bind_keys(mod,k,v)
		end
	end
	
	if settings.jobspecific[me.main_job:lower()][me.sub_job:lower()] then
		for i, mod in pairs{'win','alt','ctrl','apps'} do
			for k, v in pairs(settings.jobspecific[me.main_job:lower()][me.sub_job:lower()][mod]) do
				bind_keys(mod,k,v)
			end
		end
	end
end]]

function format_text(str)
	
end