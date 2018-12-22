--[[Copyright © 2016, Hugh Broome
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Hugh Broome BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]--

_addon.name     = 'WKR Helper'
_addon.author   = 'Lygre'
_addon.version  = '1.0.1'
_addon.commands = {'wkr'}

require('luau')
require('pack')
require('lists')
require('logger')
require('sets')
files = require('files')
packets = require('packets')
require('chat')
res = require('resources')

local pkt = {}

local npc,target_index,zone,menu,opt_ind,gc_option,unk_1,unk_2,unk_3,x,y,z

-- local cape_name = ""
-- local aug_name = ""
-- local opt_ind = 2
-- local unk_1 = 0
-- local path_item = ''
-- local menu_params
local default = {npc=17829975,target_index=87,zone=257,menu=8700,opt_ind=2,unk_1=0,unk_2=0,unk_3=0,x=0,y=0,z=0}
function to_defaults()
	npc=default.npc
	target_index=default.target_index
	zone=default.zone
	menu=default.menu
	opt_ind=default.opt_ind
	unk_1=default.unk_1
	print(npc,target_index,zone,menu,opt_ind,unk_1)
end

to_defaults()

-- valid_zones = T{"Western Adoulin","Southern San d'Oria","Windurst Woods","Bastok Markets"}
-- valid_zones = {
-- 	[249] = {npc="Gorpa-Masorpa", menu=387}, -- Mhaura
-- 	} 
local warps = {
	['ceizak'] = 46,
	['foret'] = 47,
	['morimar'] = 48,
	['yorcia'] = 49,
	['marjami'] = 50,
	['kamihr'] = 51,
}
local zones = {
	['ceizak'] = {npc=17846769,target_index=497,zone=261,menu=2008,opt_ind=1,unk_1=0},
	['foret'] = {npc=17850899,target_index=531,zone=262,menu=2008,opt_ind=1,unk_1=1,unk_2=131596550,unk_3=16129,x= -100.00000762939,y= -350.00003051758,z= -0.22600001096725},
	['morimar'] = {npc=17863390,target_index=734,zone=265,menu=2008,opt_ind=1,unk_1=0},
	['yorcia'] = {npc=17855021,target_index=557,zone=263,menu=2008,opt_ind=1,unk_1=0},
	['marjami'] = {npc=17867160,target_index=408,zone=266,menu=2008,opt_ind=1,unk_1=0},
	['kamihr'] = {npc=17871206,target_index=358,zone=267,menu=2008,opt_ind=1,unk_1=0},
}
-- local dimmian = {
-- 	[]
-- }
local busy = false
local special_busy = false
local gate_busy = false
local cryst_busy = false
local warp_busy = false

windower.register_event('addon command', function(...)
	-- to_defaults()
	local args = T{...}
	local cmd = args[1]
	args:remove(1)
	-- for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
	-- local item = table.concat(args," "):lower()
	local lcmd = cmd:lower()
	-- to_defaults()
	if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(lcmd) then
		pkt = validate()
		unk_1 = warps[lcmd]
		warp_busy = true
		poke_warp()
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('goall '..lcmd)
		end
	elseif lcmd == 'poke' then
		if args[1] then 
			if args[1]:lower() == 'tenzen' then
				pkt = validate()
				npc = 16908419
				target_index = 131
				poke_warp()
			elseif S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(args[1]:lower()) then
				pkt = validate()
				npc = zones[args[1]:lower()].npc
				target_index = zones[args[1]:lower()].target_index
				poke_warp()
			end	
		else 
			windower.add_to_chat(10,"Invalid or missing npc selection")
		end
	elseif S{'tenzen'}:contains(lcmd) then
		pkt = validate()
		npc = 17760398
		target_index = 142
		zone = 240
		menu = 8702
		opt_ind = 2
		unk_1 = 120
		warp_busy = true
		poke_warp()
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('goall '..lcmd)
		end
	elseif S{'levi'}:contains(lcmd) then
		pkt = validate()
		npc = 17760398
		target_index = 142
		zone = 240
		menu = 8702
		
		opt_ind = 2
		unk_1 = 93
		warp_busy = true
		poke_warp()
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('goall '..lcmd)
		end
	elseif S{'ramuh'}:contains(lcmd) then
		pkt = validate()
		npc = 17760398
		target_index = 142
		zone = 240
		menu = 8702
		
		opt_ind = 2
		unk_1 = 92
		warp_busy = true
		poke_warp()

	elseif S{'qufim'}:contains(lcmd) then
		pkt = validate()
		npc = 17760398
		target_index = 142
		zone = 240
		menu = 8702
		opt_ind = 2
		unk_1 = 114
		warp_busy = true
		special_busy = false
		gate_busy = false
		poke_warp()
	elseif lcmd == 'kis' then
		pkt = validate()
		opt_ind = 14
		npc = 17830000
		unk_1 = 0
		target_index = 112
		menu = 30

		warp_busy = true
		special_busy = false
		gate_busy = false
		poke_warp()
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('goall kis')
		end
	elseif lcmd == 'warp' then
		windower.send_command('input /warp')
		if args[1] and args[1]:lower() == 'all' then
			windower.send_ipc_message('goall warp')
		end
	elseif lcmd == 'gate' then
		pkt = validate()
		npc = 16908419
		target_index = 131
		zone = 32
		menu = 32000
		opt_ind = 255
		unk_1 = 0

		gc_option = 102

		busy = false
		special_busy = false
		gate_busy = true
		poke_warp()
	elseif lcmd == 'levicryst' then
		pkt = validate()
		npc = 17641518
		target_index = 46
		zone = 211
		menu = 32000
		opt_ind = 255
		unk_1 = 0

		gc_option = 104

		busy = false
		special_busy = false
		gate_busy = false
		cryst_busy = true
		poke_warp()
		
	elseif lcmd == 'ramuhcryst' then
		pkt = validate()
		npc = 17604660
		target_index = 52
		zone = 202
		menu = 32000
		opt_ind = 255
		unk_1 = 0

		gc_option = 105

		busy = false
		special_busy = false
		gate_busy = false
		cryst_busy = true
		poke_warp()
	elseif lcmd == 'pos' then
		pkt = validate()
		print(windower.ffxi.get_mob_by_index(pkt['me'])['x'])
	-- elseif S{'poke'}:contains(lcmd) then
		-- pkt = validate()
		-- npc = 17604660
		-- target_index = 52
		-- zone = 202
		-- menu = 32000
		-- opt_ind = 255
		-- unk_1 = 0

		-- gc_option = 105
		
		-- busy = false
		-- special_busy = false
		-- gate_busy = false
		-- cryst_busy = false
		-- poke_warp()
		
	-- elseif lcmd == 'goin' then
		-- local packet = packets.new('outgoing', 0x05B)
		-- packet["Target"]=17604660
		-- packet["Option Index"]=255
		-- packet["_unknown1"]=0
		-- packet["Target Index"]=52
		-- packet["Automated Message"]=true
		-- packet["_unknown2"]=0
		-- packet["Zone"]=202
		-- packet["Menu ID"]=32000
		-- packets.inject(packet)
		
		-- busy = false
		-- special_busy = false
		-- gate_busy = false
		-- cryst_busy = false
		-- new_busy = true
	elseif lcmd == 'ki' then
		if args[1] and args[1]:lower() == 'tenzen' then
			pkt = validate()
			opt_ind = 2562
			npc = 17760501
			unk_1 = 0
			target_index = 245
			menu = 895
			zone = 240

			busy = false 
			gate_busy = false
			special_busy = true
			poke_warp()
		elseif args[1] and args[1]:lower() == 'levi' then
			pkt = validate()
			opt_ind = 3586
			npc = 17760501
			unk_1 = 0
			target_index = 245
			menu = 895
			zone = 240

			busy = false 
			gate_busy = false
			special_busy = true
			poke_warp()
		else
			windower.add_to_chat(10,"Invalid or No KI selected")
		end
	elseif lcmd == 'enter' and args[1] then
		local zpick = args[1]:lower()
		args:remove(1)
		if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(zpick) then
			pkt = validate()
			opt_ind = zones[zpick].opt_ind
			npc = zones[zpick].npc
			target_index = zones[zpick].target_index
			menu = zones[zpick].menu
			unk_1=zones[zpick].unk_1
			unk_2=zones[zpick].unk_2
			unk_3=zones[zpick].unk_3
			z=zones[zpick].z
			x=zones[zpick].x
			y=zones[zpick].y
			busy = true
			special_busy = false
			gate_busy = false
			cryst_busy = false
			poke_warp()
			print(opt_ind)
			if args[1] and args[1]:lower() == 'all' then
				windower.send_ipc_message('goall enter '..zpick)
			end
		else
			windower.add_to_chat(10,"Not a valid zone")
		end
	elseif lcmd == 'update' then
		pkt = validate()
		local packet = packets.new('outgoing', 0x016, {
		["Target Index"]=pkt['me'],
		})
		packets.inject(packet)
		busy = false
		pkt = {}
		print('hi')
		return true

	elseif lcmd == 'go' and args[1] then
		local subcmd = args[1]:lower()
		args:remove(1)
		if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(subcmd) then
			pkt = validate()
			unk_1 = warps[subcmd]
			busy = true
			poke_warp()	
		elseif S{'tenzen'}:contains(subcmd) then
			pkt = validate()
			npc = 17760398
			target_index = 142
			zone = 240
			menu = 8702
			opt_ind = 2
			unk_1 = 120
			busy = true
			poke_warp()
		elseif subcmd == 'kis' then
			pkt = validate()
			opt_ind = 14
			npc = 17830000
			unk_1 = 0
			target_index = 112
			menu = 30
			busy = true
			poke_warp()
		elseif subcmd == 'warp' then
			windower.send_command('input /warp')
		elseif subcmd == 'enter' and args[1] then
			local zpick = args[1]:lower()
			args:remove(1)
			if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(zpick) then
				pkt = validate()
				opt_ind = zones[zpick].opt_ind
				npc = zones[zpick].npc
				target_index = zones[zpick].target_index
				menu = zones[zpick].menu
				unk_1 = zones[zpick].unk_1
				busy = true
				poke_warp()
			else
				windower.add_to_chat(10,"Not a valid zone")
			end
		end
	end		
end)

function poke_warp()
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=npc,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function validate()
	-- local zone = windower.ffxi.get_info()['zone']
	local me
	local result = {}
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == windower.ffxi.get_player().name then
			result['me'] = i
		end
	end
	return result 
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if id == 0x034 or id == 0x032 then
		if busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=0
			packet["Target Index"]=target_index
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x05C)
			packet["X"]=x
			packet["Z"]=z
			packet["Y"]=y
			packet["Target ID"]=npc
			packet["Target Index"]=target_index
			packet["_unknown1"]=unk_1
			packet["_unknown2"]=unk_2
			packet["_unknown3"]=unk_3
			packets.inject(packet)

			return true
		elseif warp_busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			warp_busy = false
			pkt = {}
			return true
		elseif special_busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			return true

		elseif gate_busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=157,["_junk1"]=0,
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=174,["_junk1"]=0,
			})
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=185,["_junk1"]=0,
			})
			packets.inject(packet)

			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=0
			packet["Target Index"]=target_index
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)

			local packet = packets.new('outgoing', 0x05C)
			packet["X"]= -640.02905273438
			packet["Z"]= -231.34701538086
			packet["Y"]= 512.68005371094
			packet["Target ID"]=npc
			packet["Target Index"]=target_index
			packet["_unknown1"]=545
			packet["_unknown2"]=2097152032
			packet["_unknown3"]=48897
			packets.inject(packet)

			return true	

		elseif cryst_busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			print('packet 1')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=60,["_junk1"]=0,
			})
			packets.inject(packet)
			print('packet 2')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=61,["_junk1"]=0,
			})
			packets.inject(packet)
			print('packet 3')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=67,["_junk1"]=0,
			})
			packets.inject(packet)
			print('packet 4')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=68,["_junk1"]=0,
			})
			packets.inject(packet)
			print('packet 5')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=69,["_junk1"]=0,
			})
			packets.inject(packet)
			print('packet 6')
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=70,["_junk1"]=0,
			})
			packets.inject(packet)
			
			print('Entering')
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=true
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			
			-- {ctype='float',             label='X'},                                     -- 04
			-- {ctype='float',             label='Z'},                                     -- 08
			-- {ctype='float',             label='Y'},                                     -- 0C
			-- {ctype='unsigned int',      label='Target ID',          fn=id},             -- 10   NPC that you are requesting a warp from
			-- {ctype='unsigned int',      label='_unknown1'},                             -- 14   01 00 00 00 observed
			-- {ctype='unsigned int',      label='_unknown2'},                             -- 18   Likely contains information about the particular warp being requested, like menu ID
			-- {ctype='unsigned short',    label='Target Index',       fn=index},          -- 1C
			-- {ctype='unsigned short',    label='_unknown3'},                             -- 1E   Not zone ID
			
			local packet = packets.new('outgoing', 0x05C)
			packet["X"]=497.22702026367
			packet["Z"]=55.556003570557
			packet["Y"]= -432.93200683594
			packet["Target ID"]=17604660
			packet["Target Index"]=52
			packet["_unknown1"]=593
			packet["_unknown2"]=2097152202
			packet["_unknown3"]=38657
			packets.inject(packet)
			
			-- local packet = packets.new('outgoing', 0x05c)
			-- packet["X"]=17.27500152879
			-- packet["Z"]= -4.4440002441406
			-- packet["Y"]= -32.927001953125
			-- packet["Target ID"]=17604660
			-- packet["Target Index"]=52
			-- packet["_unknown1"]=594
			-- packet["_unknown2"]=2097152202
			-- packet["_unknown3"]=38657
			-- packets.inject(packet)
			return true		
				
		end
	elseif id == 0x055 then
		if busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			busy = false 
			pkt = {}
			return true

		elseif special_busy == true and pkt then
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			special_busy = false 
			pkt = {}
			return true

		elseif gate_busy == true and pkt then
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=gc_option
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			gate_busy = false
			pkt = {}
			return true

		elseif cryst_busy == true and pkt then
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=gc_option
			packet["_unknown1"]=unk_1
			packet["Target Index"]=target_index
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			local packet = packets.new('outgoing', 0x016, {
			["Target Index"]=pkt['me'],
			})
			packets.inject(packet)
			cryst_busy = false
			pkt = {}
			return true

		end		
	elseif id == 0x065 then
		if busy == true and pkt then
			local packet = packets.new('outgoing', 0x05B)
			packet["Target"]=npc
			packet["Option Index"]=opt_ind
			packet["_unknown1"]=0
			packet["Target Index"]=target_index
			packet["Automated Message"]=false
			packet["_unknown2"]=0
			packet["Zone"]=zone
			packet["Menu ID"]=menu
			packets.inject(packet)
			busy = false
			pkt = {}
			return true
		end
	end
end)

windower.register_event('ipc message',function (msg)
	local broken = split(msg, ' ')

	local command = table.remove(broken, 1)

	if #broken < 1 then return end

	local qual = table.remove(broken,1)
	local param = table.remove(broken,1)
	-- print(command,qual)
	if command == 'goall' and qual then
		local ipc_cmd = qual:lower()
		if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(ipc_cmd) then
			windower.send_command('wait 2;wkr go '..ipc_cmd)
		elseif S{'tenzen'}:contains(ipc_cmd) then
			windower.send_command('wait 2;wkr go '..ipc_cmd)
		elseif ipc_cmd == 'kis' then
			windower.send_command('wait 2;wkr go kis')
		elseif ipc_cmd == 'warp' then
			windower.send_command('wkr go warp')
		elseif ipc_cmd == 'enter' and param then
			local ipc_param = param:lower() 
			if S{'yorcia','marjami','kamihr','ceizak','morimar','foret'}:contains(ipc_param) then
				windower.send_command('wait 2;wkr go enter '..ipc_param)
			else 
				windower.add_to_chat(10,"Not a valid zone")
			end
		end
	end
end)

windower.register_event('zone change',function(new_id, old_id)
	local busy = false
	local special_busy = false
	local gate_busy = false
	local cryst_busy = false
end)

function split(msg, match)
	if msg == nil then return '' end
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end