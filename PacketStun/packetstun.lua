_addon.command = 'ps'
_addon.version = '1.0'
_addon.author = 'Sudox, F'
_addon.name = 'Packet Stun'

res = require('resources')

require 'logger'
require 'strings'
require 'tables'
require 'sets'
packets = require 'packets'
texts = require 'texts'


-- Add NM names and spells/TP moves to be stunned here
stunList = {
        ["Lost Soul"] = S{ 	"Blood Saber", "Black Cloud", "Horror Cloud", "Hell Slash", "Aspir", "Drain", "Choke", "Frost", 
--                            "Blizzaga", "Blizzaga II", "Poison", "Flash", "Blind", "Sleepga", "Blizzard II", "Poisonga",
--                            "Water II", "Bio II", "Stonega II", "Stun", "Gravity", "Drown", "Rasp", "Ice Spikes", "Sleep",
                            "Thunder"}, 
        ["Sudox"] =	S{"Haste"},
        ["Caedarva Leech"] = S{"Acid Mist", "Drainkiss", "MP Drainkiss", "Brain Drain", "Sand Breath", "Suction", "TP Drainkiss", "Regeneration"},
}
	
-- Table to hold mobs that have acted on alliance members	
mobAlliance = {}

-- Add-on forced commands
windower.register_event('addon command', function(...)
	local args = {...}
	
	-- Stun packet construction testing
	if args[1] == 'stun' then
		stun({name='current target',id=windower.ffxi.get_mob_by_target('t').id,index=windower.ffxi.get_mob_by_target('t').index,act_name='test'})
	elseif args[1] == 'index' then -- Target index retrieval
		debug(windower.ffxi.get_mob_by_target('t').index)
	elseif args[1] == 'dist' then
		targetDistance = windower.ffxi.get_mob_by_target('t').distance
		debug('Distance from '..windower.ffxi.get_mob_by_target('t').name..' is '.. math.sqrt(targetDistance))
	elseif args[1] == 'size' then
		target = windower.ffxi.get_mob_by_target('t')
		debug(target.name..' size: '..target.model_size)
	end
end)


windower.register_event('incoming chunk', function(id,data,modified,injected,blocked)
	-- Identify packet ID, 0x028 is what we are looking for
	local packetID = id
		
	-- Pull data from incoming packet if packet contains incoming actions
	if packetID == 0x028 then

		local packet = packets.parse('incoming', data)

		-- Extract relevant data from packet 0x028
		local actor = {}
		actor.id = packet['Actor']
		actor.index = windower.ffxi.get_mob_by_id(actor.id).index
		actor.name = windower.ffxi.get_mob_by_id(actor.id).name			
		actor.target_count = packet['Target Count']
		actor.target = packet['Target 1 ID']
		actor.target_name = windower.ffxi.get_mob_by_id(actor.target).name
		actor.category = packet['Category']
		actor.param = packet['Param']     
		actToStun = packet['Target 1 Action 1 Param']
			
		-- Check if actor is not alliance member, is acting on alliance member, and does not already exist in mobAlliance
		if checkAlliance(actor.target_name) and not checkAlliance(actor.name) and not mobAlliance[actor.id] and stunList[actor.name] then
			-- Add to mobAlliance for later validation and display text box with mob name and moves/spells to be stunned
			mobAlliance[actor.id] = actor.index
			update_vars_box()
		end
					
		if actor.param == 24931 then			
			-- Check that actor is a mob
			if not windower.ffxi.get_mob_by_id(actor.id).is_npc or checkAlliance(actor.name) then
				return
			end
		
			-- Check to see if mob is in mobAlliance
			if not tableContains(mobAlliance, actor.index) then
				return
			end
		
			-- Check that action was a spell or JA, and assign name
			if actor.category/1 == 8 then
				actor.act_name = res.spells[packet['Target 1 Action 1 Param']].name
			elseif actor.category/1 == 7 then
				actor.act_name = res.monster_abilities[packet['Target 1 Action 1 Param']].name
			else
				return
			end

			-- Check that action is something we want to stun
			if not validateStun(actor.name,actor.act_name) then 
				return 
			end
			
			-- Check if mob is self-targeting
			if actor.name == actor.target_name then
				stun(actor)
			-- Check if mob is targeting player in alliance
			elseif actor.id ~= windower.ffxi.get_player().id and checkAlliance(actor.target_name) then
				stun(actor)
			else 
				debug("Invalid")
			end
		else	
			return
		end	
	end
end)

windower.register_event('prerender', function(...)

	-- Call to clean mobAlliance
	cleanMobAlliance()	
	
end)

-- Stun function
function stun(actor)
    if not actor then return end

    debug('Stunning: '..actor.act_name..' | '..actor.name) 		

    -- Construct/Inject Stun packet
    local stunPacket = packets.new('outgoing', 0x01A, {
        ['Category'] = 0x03, 
        ['Target'] = actor.id,
        ['Target Index'] = actor.index,
        ['Param'] = 252,	--Stun		
    })
    packets.inject(stunPacket)	
end

-- Function to check if mob is stunnable
function validateStun(mobName, moveName)	
	if stunList[mobName] and stunList[mobName]:contains(moveName) then
        return true
    end
	return false
end

-- Function to determine if target is in alliance
function checkAlliance(targetName)
	local alliance = windower.ffxi.get_party()   
    if not alliance then
        return false
    end
    for __,ally in pairs(alliance) do
		if type(ally)=='table' and ally.name==targetName then
            return true
        end
    end
	return false
end

-- Debug function to print to log
function debug(msg)
    if debug then windower.add_to_chat(200, '' ..msg) end
end

-- Function to check if table contains element
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Function to clear mobAlliance from entries that no longer exist in get_mob_array
function cleanMobAlliance()
	local found
	
	-- Get mob array
	local mobArray = windower.ffxi.get_mob_array()
	
	-- Check if mobAlliance has entries not in mobArray
	for id,ind in pairs(mobAlliance) do
		for __,mob in pairs(mobArray) do
			-- Keep mob in mobAlliance if it continues to exist in mobArray
			if mob.id==id and mob.index==ind and windower.ffxi.get_mob_by_id(id).valid_target then
				found = true		
			end
		end
		-- Remove mob from mobAlliance if no longer in mobArray
		if not found then 
			mobAlliance[id] = nil
		end
		found = false
	end
	update_vars_box()
end

-- Initialize text box
function init_vars_box(settings)
    text_settings = {
        pos={x=settings.x,y=settings.y},
        text={font='Segoe UI Symbol',fonts={'sans-serif'},size=10,stroke={width=1,alpha=255,red=0,green=0,blue=0}},
        padding=6,
        bg={visible=true,alpha=100,red=0,green=0,blue=0},
        flags={draggable=true,right=settings.right_align or false,bottom=settings.bottom_align or false,bold=true},
    } 
    vars = texts.new(text_settings)
    vars:show()
    update_vars_box()
end

-- Update text box
function update_vars_box()
    local tags = L{}
    local info = {}

	for id,ind in pairs(mobAlliance) do	
		-- Check if mob is within stun range
		if math.sqrt(windower.ffxi.get_mob_by_id(id).distance) <= 21 then
			-- Text is white if mob is within stun range
			label = '[\\cs(255,255,255)'..windower.ffxi.get_mob_by_index(ind).name..' | '..stunList[windower.ffxi.get_mob_by_index(ind).name]:concat(', ')..'\\cr]'
			tags:append(label)
		else
		-- Text is red if mob is out of stun range
			label = '[\\cs(255,0,0)'..windower.ffxi.get_mob_by_index(ind).name..' | '..stunList[windower.ffxi.get_mob_by_index(ind).name]:concat(', ')..'\\cr]'
			tags:append(label)
		end
	end
    
    vars:clear()	
	
	if tags:concat() == '' then
        vars:hide() return
    end
    	
	vars:show()
    vars:append(tags:concat('\n'))
    vars:update(info)
end

init_vars_box({x=-200,y=-500,right_align=true,bottom_align=true,draggable=true})
