GUI = {}
GUI.mouse_listeners = {}
GUI.update_objects = {}
GUI.postrender_objects = {}
GUI.signal_listeners = {}
GUI.mouse_index = 1
GUI.update_index = 1
GUI.bound = {}
GUI.bound.x = {}
GUI.bound.x.lower = 70
GUI.bound.x.upper = 1920 - 54
GUI.bound.y = {}
GUI.bound.y.lower = 80
GUI.bound.y.upper = 500
GUI.nexttime = os.clock()
GUI.delay = 1

--require('coroutine')
require('tables')

require('GUI/IconPalette')
require('GUI/IconButton')
require('GUI/ToggleButton')
require('GUI/PassiveText')
require('GUI/TextCycle')
require('GUI/PopupSlider')
require('GUI/SliderButton')
require('GUI/FunctionButton')
require('GUI/Divider')
require('GUI/TextTable')
require('GUI/IconGrid')
require('GUI/GridButton')
require('GUI/Combobox')
require('GUI/ComboSelector')
require('GUI/ScrollBar')
require('GUI/RadioButton')

function GUI.on_mouse_event(type, x, y, delta, blocked) -- sends incoming mouse events to any elements currently listening
	block = false
	--for i, listener in ipairs(GUI.mouse_listeners) do
	for i, listener in pairs(GUI.mouse_listeners) do
		block = listener:on_mouse(type, x, y, delta, blocked) or block
	end
	blocked = block
	return block
end

function GUI.register_mouse_listener(obj) -- will technically overflow eventually.  I'm not really worried about that.
	--[[GUI.mouse_listeners[GUI.mouse_index] = obj
	GUI.mouse_index = GUI.mouse_index + 1
	return GUI.mouse_index - 1]]
	GUI.mouse_listeners[tostring(obj)] = obj

end

function GUI.unregister_mouse_listener(obj)
	--GUI.mouse_listeners[index] = nil
	GUI.mouse_listeners[tostring(obj)] = nil
end

function GUI.on_prerender()
	local curtime = os.clock()
	if GUI.nexttime + GUI.delay <= curtime then
		GUI.nexttime = curtime
		GUI.delay = 1
		for i, object in pairs(GUI.update_objects) do
			object:update()
		end
	end
end

function GUI.on_postrender()
	for _, obj in pairs(GUI.postrender_objects) do
		obj:postrender()
	end
end

function GUI.subscribe_postrender(obj)
	GUI.postrender_objects[tostring(obj)] = obj
end

function GUI.unsubscribe_postrender(obj)
	GUI.postrender_objects[tostring(obj)] = nil
end

function GUI.register_update_object(obj)
	--[[GUI.update_objects[GUI.update_index] = obj
	GUI.update_index = GUI.update_index + 1
	return GUI.update_index - 1]]
	GUI.update_objects[tostring(obj)] = obj
end

function GUI.unregister_update_object(obj)--index)
	--GUI.update_objects[index] = nil
	GUI.update_objects[tostring(obj)] = nil
end

-- function will be called, and passed the signal name and signaler
function GUI.subscribe_signals(obj, func)
	GUI.signal_listeners[tostring(obj)] = func
end

function GUI.unsubscribe_signals(obj)
	GUI.signal_objects[tostring(obj)] = nil
end

function GUI.send_signal(sender, signal, ...)
	for obj, func in pairs(GUI.signal_listeners) do
		if tostring(obj) ~= tostring(sender) then
			func(sender, signal, ...)
		end
	end
end

function GUI.complete_filepath(short)
	for i, path in ipairs{
		short,
		windower.addon_path..short,
		windower.addon_path..'graphics/'..short,
		windower.addon_path..'data/graphics/'..short,
		windower.windower_path..'addons/libs/GUI/'..short,
		windower.windower_path..'addons/libs/GUI/graphics/'..short
		} do
		local f=io.open(path,"r")
		if f~=nil then
			io.close(f)
			return path
		end
	end
	print('%s not found':format(short))
end

if windower.raw_register_event then
	windower.raw_register_event('mouse', GUI.on_mouse_event)
	windower.raw_register_event('prerender', GUI.on_prerender)
	windower.raw_register_event('postrender', GUI.on_postrender)
else
	windower.register_event('mouse', GUI.on_mouse_event)
	windower.register_event('prerender', GUI.on_prerender)
	windower.register_event('postrender', GUI.on_postrender)
end
