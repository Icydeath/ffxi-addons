--[[
Gearswap rules to launch a buffWatcher, recasting a list of defined buffs.
@author : Pulsahr (Carbuncle server)

Watch over a list of buff you want to recast.
Casts only the ones missing.
Doesn't wait uselessly after an instant or shortened cast.

-- #########################
-- INSTALLATION
-- #########################


1. INCLUDES

include this file in your SCH gearswap by copying it in addons/GearSwap/data/ and put at the bottom of your job_setup function :
include('caster_buffWatcher.lua')


2. CUSTOM COMMAND

You need to add the custom command for calling the buffWatcher function.
Find the "job_self_command" in your main script. If it doesn't exist, create it as follow :
function job_self_command(cmdParams, eventArgs)
-- insert code here
end

Insert the following code at the start of the function :

  if cmdParams[1] == 'buffWatcher' then
	  buffWatch(cmdParams[2])
  end
  if cmdParams[1] == 'stopBuffWatcher' then
	  stopBuffWatcher()
  end
  

3. EDITING EXISTING FUNCTION

- edit or add the function job_buff_change(buff, gain), and add the following 6 lines :

  for index,value in pairs(buffWatcher.watchList) do
    if index==buff then
      buffWatch()
      break
    end
  end

  
4. SETTING THE WATCH LIST
 
 See the CONFIGURATION section, below, when the code starts, you won't miss it.
 
 
-- #########################
-- USAGE EXAMPLES
-- #########################
/console gs c buffWatcher true
=> will start your buffWatcher routine.
/console gs c buffWatcher
=> will act like an automatic call from job_buff_change. Only useful if you interrupted a spell cast by the buff watcher. Don't bother using this, make only one macro like the first example.

 

-- #########################
-- INFORMATION
-- #########################
This file contains only the functions required for the buffWatcher command :
buffWatcher required variables
function buffWatch
function stopBuffWatcher



-- #########################
-- KNOWN ISSUES
-- #########################
1. If you get interrupted while casting a buff launched by buffWatcher, nothing happens anymore.
Solutions : use buffWatcher false to step forward, or don't bother and reuse your general buffWatcher macro.

2. The order is not like I entered it
Bad news : I can't change anything to this, or I need the user to make two arrays, and I need to add lots of boring controls.
Technical reason : the way LUA manage arrays indexed with names (instead of numeric index), is not well controlled, and seems dependent on where the free memory is. If you do some stuff in game, and reload gearwap, and recall your buffWatcher, the order might change, despite the fact you changed nothing in the files. Yep.
If anyone comes with a simple solution, feel free to contact me, I'll gladly implement it and give credit.
--]]




buffWatcher = {}
buffWatcher.active = false

--------------------------------------
-- CONFIGURATION
--------------------------------------
--[[
You can add/remove buffs to your liking.
Each buff to watch must be present here like : ["buff name"]="spell to cast",

MULTIPLE JOBS :
if you want to use buffWatcher on multiple jobs, and have different watchlists, copy the buffWatcher.watchList definition below to your job file, right after your include('caster_buffWatcher.lua'), in the job_setup function.
For instance, in your SCH job file :
include('caster_buffWatcher.lua')
buffWatcher.watchList = {
  ["Protect"]="Protect V"
}

and in your WHM file :
include('caster_buffWatcher.lua')
buffWatcher.watchList = {
  ["Protect"]="Protectra V"
}

You can leave the following lines for a default value.
--]]
buffWatcher.watchList = {
                        ["Aquaveil"]="Aquaveil",
                        ["Haste"]="Haste",
                        ["Stoneskin"]="Stoneskin",
                        --["Phalanx"]="Phalanx",
                        --["Protect"]="Protect V",
                        --["Shell"]="Shell V",
                        }


--------------------------------------
-- buffWatch
--------------------------------------
--[[
If you don't like the informations displayed in ingame chat, comment the lines starting with "add_to_chat".

@param bool startWatching : if true, start the buffWatch routine from the beginning. If false or no value, acts like an auto update.
--]]
function buffWatch(startWatching)
-- panic cancel, or cannot cast, we stop right there
  if(player.status=='Resting') then
    stopBuffWatcher()
    return
  end

  if not startWatching then
    startWatching=false
  elseif startWatching=='true' then
    startWatching=true
  else
    startWatching=false
  end
  
-- INTIALIZE
  local infobuffs = ''
  if(startWatching==true) then 
    add_to_chat(200,'========== BUFF WATCHER activated ==========')
    buffWatcher.todo = {}
    buffWatcher.active = true
    infobuffs = 'Watch list :'
    for buff,spell in pairs(buffWatcher.watchList) do
      table.insert(buffWatcher.todo,buff)
      infobuffs = infobuffs..' '..buff
    end

    
    add_to_chat(200,infobuffs)
  else
    -- called with job_buff_change
    if buffWatcher.active == false then
      return
    end
  end

-- let's loop on todo list
  local active = false -- true if the buff is already active
  local goCast = false -- true if we want the spell to be cast
  

  buff = table.remove(buffWatcher.todo,1)
  local iteration = 1
  while (buff~=nil) do
    goCast = false
    active = buffactive[buff] or false

    if(not active) then
      goCast = true
    end

    if(goCast==true) then
    add_to_chat(200,'casting '..buffWatcher.watchList[buff])
      -- we gonna cast this shit
      if (startWatching==true) then
        send_command('input /ma "'..buffWatcher.watchList[buff]..'" <me>;') -- no wait for the first spell
      else
        send_command('wait 2;input /ma "'..buffWatcher.watchList[buff]..'" <me>;')
      end

      return -- we stop here, next step will be called when this buff we are casting is on
    end

  buff = table.remove(buffWatcher.todo,1)
  iteration = iteration+1
  if(iteration>10) then return end -- failsafe for excessive amount of watched buffs
  end -- LOOP
  
  -- Sublimation for SCH or /SCH
  if (player.main_job=='SCH') or (player.sub_job=='SCH') then
    state.Buff['Sublimation: Activated'] = buffactive['Sublimation: Activated'] or false
    state.Buff['Sublimation: Complete'] = buffactive['Sublimation: Complete'] or false
    state.Buff['Weakness'] = buffactive['Weakness'] or false
    if ((not state.Buff['Sublimation: Activated'])
        and (not state.Buff['Sublimation: Complete'])
        and (player.hpp > 51)
        and (not state.Buff['Weakness'])) then
      send_command('wait 2;input /ja Sublimation <me>;')
    end
  end
  

  add_to_chat(200,'========== BUFF WATCHER done ==========')
  buffWatcher.active=false
  

end -- manageBuffs

-- to stop the buffWatcher
function stopBuffWatcher()
  add_to_chat(182,'buffWatcher canceled')
  buffWatcher.todo = {}
  buffWatcher.active = false
end
--]]