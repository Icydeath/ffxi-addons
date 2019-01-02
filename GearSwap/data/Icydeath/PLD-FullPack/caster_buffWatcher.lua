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
Same for status info file :
include('common_info.status.lua')


2. ADDING FUNCTIONS

the function errlog is required to display some error in the ingame chat. If you don't have it, paste the following lines at the bottom of your JOB.lua file.
--------------------------------------
-- ERRLOG
--------------------------------------
function errlog(msg) 
	add_to_chat(167,msg)
end


3. CUSTOM COMMAND

You need to add the custom command for calling the buffWatcher function.
Find the "job_self_command" in your main script. If it doesn't exist, create it as follow :
function job_self_command(cmdParams, eventArgs)
-- insert code here
end

Insert the following code at the start of the function :

  if cmdParams[1] == 'buffWatcher' then
	  buffWatch(cmdParams[2],cmdParams[3])
  end
  if cmdParams[1] == 'stopBuffWatcher' then
	  stopBuffWatcher()
  end
  

4. EDITING EXISTING FUNCTION

- edit or add the function job_buff_change(buff, gain), and add the following 6 lines :

  for index,value in pairs(buffWatcher.watchList) do
    if index==buff then
      buffWatch()
      break
    end
  end

  
5. SETTING THE WATCH LIST
 
 See the CONFIGURATION section, below, when the code starts, you won't miss it.
 
 
-- #########################
-- USAGE EXAMPLES
-- #########################
/console gs c buffWatcher true
=> will start your buffWatcher routine, without canceling nor overwriting existing buffs.
/console gs c buffWatcher true cancel
=> will start your buffWatcher routine, canceling each buff on the watch list.
/console gs c buffWatcher true overwrite
=> will start your buffWatcher routine, overwriting spells without canceling.
/!\ Warning : overwriting doesn't trigger buff change nor buffWatch, use "//gs c buffWatch" to move forward. That's an option requested, I don't recommand using it.

 

-- #########################
-- INFORMATION
-- #########################
This file contains only the functions required for the buffWatcher command :
buffWatcher variables required
function buffWatch
function stopBuffWatcher



-- #########################
-- KNOWN ISSUES
-- #########################
1. If you get interrupted while casting a buff launched by buffWatcher, nothing happens anymore.
Solutions : relaunch your buffWatcher macro or wait for a buff to be added (cast it ?) or to wear off. buffWatcher waits for a buff update to go next step.
--]]




buffWatcher = {}
buffWatcher.active = false
buffWatcher.option = ''

--------------------------------------
-- CONFIGURATION
--------------------------------------
--[[
You can add/remove buffs to your liking.
Each buff to watch must be present here like : ["buff name"]="spell to cast",
Make sure you have the id in the common_info.status.lua file, or the cancel option won't cancel it (it might be a way to prevent canceling some buffs too).

MULTIPLE JOBS :
if you want to use buffWatcher on multiple jobs, and have different watchlists, copy the buffWatcher.watchList definition below to your job file, right after your include('caster_buffWatcher.lua'), in the job_setup function.
For instance, in your SCH job file :
buffWatcher.watchList = {["Protect"]="Protect V"}
and in your WHM file :
buffWatcher.watchList = {["Protect"]="Protectra V"}

You can leave the following lines for a default value.
--]]
-- buffWatcher.watchList = 

--------------------------------------
-- buffWatch
--------------------------------------
--[[
If you don't like the chat informations ingame, comment the lines starting with "add_to_chat".

@param bool startWatching : if true, start the buffWatch routine. If false, acts like an auto update.
@param bool option : 'overwrite' | 'cancel' : if you plan to use cancel option, be sure to have id status in common_info.status.lua for every watched spell you want to cancel.
                                              if you use overwrite, the spell will be added to the todo list, but overwriting doesn't trigger next step. Use "//gs c buffWatch" to move forward.
--]]
function buffWatch(startWatching, option)
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
  
  if not option then
    option=''
  else
    option = tostring(option)
  end

-- INTIALIZE
  local infobuffs = ''
  if(startWatching==true) then 
    add_to_chat(200,'========== BUFF WATCHER activated ==========')
    buffWatcher.todo = {}
    buffWatcher.active = true
    buffWatcher.option = option
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
    else
      option = buffWatcher.option
    end
  end

-- let's loop on todo list
  local active = false -- true if the buff is already active
  local goCast = false -- true if we want the spell to be cast
  
  local todoSize = 0
  if(buffWatcher.todo ~= nil) then
    todoSize = table.getn(buffWatcher.todo)
  else return
  end

  buff = table.remove(buffWatcher.todo)
  local iteration = 1
  while (buff~=nil) do
    goCast = false
    active = buffactive[buff] or false

    if(active) and (option=='cancel') and (info.status[buff]~=nil) then
      windower.ffxi.cancel_buff(info.status[buff])
      goCast = true
    end
    if(not active) or (option=='overwrite') then
      goCast = true
    end

    if(goCast==true) then
    add_to_chat(200,'casting '..buffWatcher.watchList[buff])
      -- we gonna cast this shit
      if (startWatching==true) then
        send_command('input /ma "'..buffWatcher.watchList[buff]..'" <me>;') -- no wait for the first spell
      else
        send_command('wait 3;input /ma "'..buffWatcher.watchList[buff]..'" <me>;')
      end

      return -- we stop here, next step will be called when this buff we are casting is on
    end

  buff = table.remove(buffWatcher.todo)
  iteration = iteration+1
  if(iteration>10) then return end
  end -- WHILE

  add_to_chat(200,'========== BUFF WATCHER done ==========')
  buffWatcher.active=false

end -- manageBuffs

-- to stop the buffWatcher
function stopBuffWatcher()
  add_to_chat(debug.color.warn,'buffWatcher canceled')
  buffWatcher.todo = {}
  buffWatcher.active = false
end
--]]