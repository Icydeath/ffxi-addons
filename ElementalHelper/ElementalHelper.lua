--Copyright (c) 2018, Ameilia
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of ElementalHelper nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Ameilia BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'luau'

_addon.name = 'ElementalHelper'
_addon.version = '1.0'
_addon.author = 'Ameilia'
_addon.commands = {'eh','elementalhelper','elehelper'}

elements = {'Stone','Water','Aero','Fire','Blizzard','Thunder'}
ancient = {'Quake','Flood','Tornado','Flare','Freeze','Burst'}
helices = {'Geo','Hydro','Anemo','Pyro','Cryo','Iono'}
storms = {'Sand','Rain','Wind','Fire','Hail','Thunder'}
gas = {'Stone','Water','Aero','Fira','Blizza','Thunda'}
ras = {'Stone','Wate','Ae','Fi','Blizza','Thunda'}
sc1 = {'Aero','Stone','Stone','Stone','Water','Water'}
sc2 = {'Stone','Water','Aero','Fire','Blizzard','Thunder'}
shots = {'Earth','Water','Wind','Fire','Ice','Thunder'}
brd = {'Earth','Water','Wind','Fire','Ice','Lightning'}
runes = {'Tellus','Unda','Flabra','Ignis','Gelus','Sulpor'}
nin = {'Doton','Suiton','Huton','Katon','Hyoton','Raiton'}

eleIndex = 1

function handle_spell(spelltype, cmdParams)
	local target = '<t>'
    local tier = ''
	local spellstr = elements[eleIndex]

	if cmdParams[1] then
        tier = cmdParams[1]:upper()	
		if(tier == 'I') then
			tier = ''
		end
    end
	
	if(S{'ga','ja'}:contains(spelltype)) then
		spellstr = gas[eleIndex] .. spelltype
	elseif spelltype == 'ancient' then
		spellstr = ancient[eleIndex]
	elseif spelltype == 'ra' then
		spellstr = ras[eleIndex] .. spelltype
	elseif spelltype == 'helix' then
		spellstr = helices[eleIndex] .. spelltype
	elseif spelltype == 'storm' then
		spellstr = storms[eleIndex] .. spelltype
		target = '<stpt>'
	elseif S{'carol','threnody'}:contains(spelltype) then
		local brdspell = brd[eleIndex]
		if(spelltype == 'threnody') then
			target = '<t>'
			if brdspell == 'Lightning' then
				brdspell = 'Ltng.'
			end
		else
			target = '<stpc>'
		end
		spellstr = brdspell .. ' ' .. spelltype
	elseif spelltype == 'nin' then
		spellstr = nin[eleIndex] .. ': '
	elseif spelltype == 'sc1' then
		spellstr = sc1[eleIndex]
		windower.send_command('input /ja "Immanence" <me>;wait 1;input /p '..elements[eleIndex]..' Skillchain #1 (Fast>Fast)')
	elseif spelltype == 'sc2' then
		spellstr = sc2[eleIndex]
		windower.send_command('input /ja "Immanence" <me>;wait 1;input /p '..elements[eleIndex]..' Skillchain #2 (Fast)')
	end
    	
	local spell = spellstr..' '..tier	
	windower.send_command('@input /ma "'..spell..'" '..target)
end

function handle_ja(jatype)
	local target = '<t>'
	local jastr = ''
	
	if jatype == 'rune' then
		jastr = runes[eleIndex]
		target = '<me>'
	elseif jatype == 'shot' then 
		jastr = shots[eleIndex]..' '..'Shot'
	end
	
	windower.send_command('@input /ja "'..jastr..'" '..target)
end

windower.register_event('addon command',function(...)
    local args = {...}
    local first = table.remove(args,1):lower()

	if first then
		if first == 'cycle' then
			eleIndex = (eleIndex % #elements) + 1
			report_nuke()
			windower.send_command('ank setnuke '..elements[eleIndex])
		elseif S{'storm','nuke','n','helix','ga','ja','ra','sc1','sc2','threnody','carol','ancient','nin'}:contains(first) then
			handle_spell(first, args)
		elseif S{'shot','rune'}:contains(first) then
			handle_ja(first)
		elseif S{'unload','reload'}:contains(first) then
			windower.send_command('lua %s %s':format(first, _addon.name))
		elseif first == 'set' then
			local found = false
			local el = args[1]:lower()
			for i,v in ipairs(elements) do
				if v:lower() == el then
					eleIndex = i
					found = true
				end
			end
			if found then
				report_nuke()
			else 
				windower.add_to_chat(39, 'Could not find Element '..args[1])
			end
		elseif first == 'help' then
			print_help()
		else
			windower.add_to_chat(39, 'Error: Unknown Command')
		end
	end
end)

windower.register_event('load', function()
	windower.add_to_chat(50, 'Welcome to ElementalHelper')
	report_nuke()
end)

function report_nuke()
	windower.add_to_chat(50, 'ElementalHelper Element: '..elements[eleIndex])
end

function print_help()
	windower.add_to_chat(50, 'ElementalHelper usage (//eh):')
	windower.add_to_chat(50, '   cycle - Cycles the element')
	windower.add_to_chat(50, '   set (element) - Sets the element directly')
	windower.add_to_chat(50, '   nuke/n (I,II,III,IV,V) - Cast (element) (tier)')
	windower.add_to_chat(50, '   ancient (I,II) - Cast AM (tier)')
	windower.add_to_chat(50, '   ga (I,II,III) - Cast (element)ga (tier)')
	windower.add_to_chat(50, '   ja - Cast (element)ja')
	windower.add_to_chat(50, '   helix (I,II) - Cast (element)helix (tier)')
	windower.add_to_chat(50, '   storm (I,II) - Cast (element)storm (tier)')
	windower.add_to_chat(50, '   threnody (I,II) - Cast (element)threnody (tier)')
	windower.add_to_chat(50, '   carol (I,II) - Cast (element)carol (tier)')
	windower.add_to_chat(50, '   shot - use (element) quickdraw')
	windower.add_to_chat(50, '   rune - use (element) rune')
	windower.add_to_chat(50, '   sc1 - Open SCH tier1 skillchain for (element)')
	windower.add_to_chat(50, '   sc2 - Close SCH tier1 skillchain for (element)')
end
