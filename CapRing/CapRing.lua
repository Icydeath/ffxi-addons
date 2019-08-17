--[[
Modified the addon MyHome created by from20020516 to use CP rings instead.
All credit goes to from20020516
1/4/19 Extended this addon to handle XP rings
to use an exp ring do: //capring xp
to use a cp ring do: //capring
]]

_addon.name = 'CapRing'
_addon.author = 'from20020516|Modified by Icy'
_addon.version = '1.0'
_addon.commands = {'capring'}

require('logger')
res = require('resources')
extdata = require('extdata')

lang = string.lower(windower.ffxi.get_info().language)
item_info = {
	[1]={id=28469,japanese='',english='"Endorsement Ring"',slot=13},
    [2]={id=27557,japanese='',english='"Trizek Ring"',slot=13},
    [3]={id=26165,japanese='',english='"Facility Ring"',slot=13},
	[4]={id=28563,japanese='',english='"Vocation Ring"',slot=13},
    [5]={id=28546,japanese='',english='"Capacity Ring"',slot=13}}

xp_item_info = {
    [1]={id=27556,japanese='',english='"Echad Ring"',slot=13}, -- 150%, 120min
	[2]={id=14671,japanese='',english='"Allied Ring"',slot=13}, -- 150%, 15min
	[3]={id=26164,japanese='',english='"Caliber Ring"',slot=13}, -- 150%, 15min
	
	[4]={id=11666,japanese='',english='"Novennial Ring"',slot=13}, -- 100%, 60min
	[5]={id=15793,japanese='',english='"Anniversary Ring"',slot=13}, -- 100%, 60min
	[6]={id=10796,japanese='',english='"Decennial Ring"',slot=13}, -- 100%, 60min
	[7]={id=28528,japanese='',english='"Undecennial Ring"',slot=13}, -- 100%, 60min
	[8]={id=28562,japanese='',english='"Duodecennial Ring"',slot=13}, -- 100%, 60min
	[9]={id=15840,japanese='',english='"Kupofried\'s Ring"',slot=13}, -- 100%, 15min
	
	[10]={id=15761,japanese='',english='"Chariot Band"',slot=13}, -- 75%, 15min
	[11]={id=28569,japanese='',english='"Expertise Ring"',slot=13}, -- 75%, 15min
	
	[12]={id=15762,japanese='',english='"Empress Band"',slot=13}, -- 50%, 15min
    [13]={id=15763,japanese='',english='"Emperor Band"',slot=13}, -- 50%, 15min
	[14]={id=28568,japanese='',english='"Resolution Ring"',slot=13}, -- 50%, 15min
}	
	
function search_item(ringtype)
    local item_array = {}
    local bags = {0,8,10,11,12} --inventory,wardrobe1-4
    local get_items = windower.ffxi.get_items
    for i=1,#bags do
        for _,item in ipairs(get_items(bags[i])) do
            if item.id > 0 then
                item_array[item.id] = item
                item_array[item.id].bag = bags[i]
            end
        end
    end
	
	local items
	if ringtype == 'cp' then
		items = item_info
	else
		items = xp_item_info
	end
	
    for index,stats in pairs(items) do
        local item = item_array[stats.id]
        local set_equip = windower.ffxi.set_equip
        if item then
            local ext = extdata.decode(item)
            local enchant = ext.type == 'Enchanted Equipment'
            local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(),0)
            local usable = recast and recast == 0
            log(stats[lang],usable and '' or recast and recast..' sec recast.')
            if usable or ext.type == 'General' then
                if enchant and item.status ~= 5 then --not equipped
                    set_equip(item.slot,stats.slot,item.bag)
                    log_flag = true
                    repeat --waiting cast delay
                        coroutine.sleep(1)
                        local ext = extdata.decode(get_items(item.bag,item.slot))
                        local delay = ext.activation_time+18000-os.time()
                        if delay > 0 then
                            log(stats[lang],delay)
                        elseif log_flag then
                            log_flag = false
                            log('Item use within 3 seconds..')
                        end
                    until ext.usable or delay > 10
                end
                windower.chat.input('/item '..windower.to_shift_jis(stats[lang])..' <me>')
                break;
            end
        else
            log('You don\'t have '..stats[lang]..'.')
        end
    end
end

function get_rings(ringtype)
	-- use itemizer to get the items out of the non-equipable bags that are available outside of the moghouse into your inventory.
	
	-- make sure inventory is not full before trying to put the rings in it.
	local invBag = windower.ffxi.get_bag_info(0)
	if invBag.max - invBag.count == 0 then return end
	
	-- get all the items in the bags into an array.
	local item_array = {}
    local bags = {5,6,7} --ID's: satchel=5, sack=6, case=7
    local get_items = windower.ffxi.get_items
    for i=1,#bags do
        for _,item in ipairs(get_items(bags[i])) do
            if item.id > 0 then
                item_array[item.id] = item
                item_array[item.id].bag = bags[i]
            end
        end
    end
	
	local items
	if ringtype == 'cp' then
		items = item_info
	else
		items = xp_item_info
	end
	
	-- check if any of the items in the array is what we need in our inventory.
	for arrayIndex,item in pairs(item_array) do
		for index,info in pairs(items) do
			if arrayIndex == info.id then
				log('Retrieving '..info[lang])
				windower.send_command('get '..info[lang])
				coroutine.sleep(2)
			end
		end
	end
end

--[[
windower.register_event('load',function()
    debug_log:write('CapRing loaded at '..os.date()..'\n')

    if debugging then windower.debug('load') end
	
	-- Auto load itemizer so it can grab the items out of the satchel, sack, and case?
    --windower.send_command('lua l itemizer')
end)
]]
buffactive = {}

windower.register_event('addon command', function(...)
	local commands = {...}
    commands[1] = commands[1] and commands[1]:lower()
	
	local ringtype = 'cp'
	local Buffs = windower.ffxi.get_player()["buffs"]
	if commands[1] == 'xp' then
		ringtype = 'xp'
		table.reassign(buffactive, convert_buff_list(Buffs))
		if check_buffs('Dedication') then 
			log('Dedication already active. Cancelling using XP Ring') 
			return
		end
	else
		table.reassign(buffactive, convert_buff_list(Buffs))
		if check_buffs('Commitment') then 
			log('Commitment already active. Cancelling using CP Ring') 
			return
		end
	end
	
	get_rings(ringtype)
	search_item(ringtype)
end)

function check_buffs(...)
    --[[ Function Author: Arcon
            Simple check before attempting to auto activate Job Abilities that
            check active buffs and debuffs ]]
    return table.any({...}, table.get+{buffactive})
end

function convert_buff_list(bufflist)
    local buffarr = {}
    for i,v in pairs(bufflist) do
        if res.buffs[v] then -- For some reason we always have buff 255 active, which doesn't have an entry.
            local buff = res.buffs[v].english
            if buffarr[buff] then
                buffarr[buff] = buffarr[buff] +1
            else
                buffarr[buff] = 1
            end
            
            if buffarr[v] then
                buffarr[v] = buffarr[v] +1
            else
                buffarr[v] = 1
            end
        end
    end
    return buffarr
end
