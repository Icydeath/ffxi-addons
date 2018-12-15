function get_sets()
  -- Load and initialize the include file.
  mote_include_version = 2
  include('Mote-Include.lua')
  include('SCH_soloSC.lua')
end


function job_setup()

end

function file_unload()
  if binds_on_unload then
    binds_on_unload()
  end
end

function user_setup()

end

function user_unload()

end

function init_gear_sets()
end

function errlog(msg) 
	add_to_chat(167,msg)
end

function job_self_command(cmdParams, eventArgs)
-- maybe some other stuff
  if cmdParams[1] == 'soloSC' then
    if not cmdParams[2] or not cmdParams[3] then
      errlog('missing required parameters for function soloSkillchain')
      return
    else
      soloSkillchain(cmdParams[2],cmdParams[3],cmdParams[4],cmdParams[5])
    end
  end
  
  if cmdParams[1] == 'stopSoloSC' then
    soloSkillchainAbort('abort from command')
  end
-- maybe some other stuff
end

function job_aftercast(spell, action, spellMap, eventArgs)
  -- soloSC stuff
  if (soloSC.active==true) and (spell.english==soloSC.step.spell or spell.english=='Immanence') then
    if (spell.english==soloSC.step.spell) then
      if (not spell.interrupted) then
        soloSkillchainStep()
      else
        soloSkillchainAbort('interrupted')
      end
    end
    
    if (spell.english=='Immanence') then
      state.Buff["Immanence"] = buffactive["Immanence"] or false
      if (not state.Buff["Immanence"]) and spell.interrupted then
        soloSkillchainAbort('Immanence failed')
      end
    end
  end
  -- end of soloSC stuff
end


--------------------------------------
-- GET NB STRATAGEMS
--------------------------------------
-- Gets the current number of available strategems based on the recast remaining
-- and the level of the sch.
-- Source : SCH file found in https://github.com/Kinematics/GearSwap-Jobs
function getNbStratagems()
    -- returns recast in seconds.
    local allRecasts = windower.ffxi.get_ability_recasts()
    local stratsRecast = allRecasts[231]
    local maxStratagems = math.floor((player.main_job_level + 10) / 20)
    local fullRechargeTime = 4*60 -- 4*40 after unlocking job point bonus
    local currentCharges = math.floor(maxStratagems - maxStratagems * stratsRecast / fullRechargeTime)
    return currentCharges
end

--------------------------------------
-- ERRLOG
--------------------------------------
function errlog(msg) 
	add_to_chat(167,msg)
end