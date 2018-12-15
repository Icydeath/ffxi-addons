_addon.name = 'Pricer'
_addon.author = 'Brax'
_addon.version = '1.0'
_addon.command = 'price'

require('chat')
http = require('socket.http')
res = require('resources')
epoc = os.time{year=1970, month=1, day=1, hour=0}


function get_sales(item,stack)
	local sales = {}
	local history = {}
	local header = {}
	header['cookie'] = "sid=12"
	local result_table = {};
		http.request{ 
		url = "http://www.ffxiah.com/item/"..item..stack, 
		sink = ltn12.sink.table(result_table),
		headers = header
	}

	result = table.concat(result_table)
	local r = (string.gmatch(result,"<title>(.-)%s%-%sFFXIAH.com</title>"))
	for word in r do title = word end


	local t = string.match(result,'Item.sales = %[(.-)}%];')
	sales = string.gmatch(t,"{(.-)}")

	if stack ~= "" then stack = " x12 " end
	windower.add_to_chat(123,"["..title..stack.."]")
	max = 0
	for word in sales do
		history['saleon'] = string.match(word,'"saleon":(%d+),')
		history['seller_name'] = string.match(word,'"seller%_name":"(%w+)",')
		history['price'] = string.match(word,'"price":(%d+),')
		history['buyer_name'] = string.match(word,'"buyer%_name":"(%w+)",')
		windower.add_to_chat(123,'('..os.date("%d %b., %Y %H:%M:%S",epoc+history['saleon'])..') '..history['seller_name']..string.char(0x81, 0xA8)..history['buyer_name']..' ['..comma_value(history['price'])..'G]')
		max = max +1
		if max > 5 then break end
	end
end

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function get_item_id(name)
local result = nil 
 for i,v in pairs(res.items) do
	if string.lower(v.name) == string.lower(name) or string.lower(v.enl) == string.lower(name) then
	 result = v.id
	end
 end
 return result
end

windower.register_event('addon command', function(...)
    local args = T{...}
	local stack = ""
	for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	local item = table.concat(args," "):lower()

	if string.sub(item,-6) == "-stack" then
		stack="/?stack=1"
		item = string.sub(item,1,-8)
		print(item)
	end
	
	local id = get_item_id(item)
	if id then
		get_sales(id,stack)
	else
		print("Not Found")
	end
	if cmd == 'buy' then
	end
end)
