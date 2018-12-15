--[[
Gearswap rules to perform a skillchain solo
@author : Pulsahr (Carbuncle server)

Don't ask me to enhance it to repeat itself until mob's death. This is botting to me, and I don't do this shit. Don't ever ask.

-- #########################
-- INSTALLATION
-- #########################

1. INCLUDES
include this file in your SCH gearswap by copying it in addons/GearSwap/data/ and put at the bottom of your main SCH file :
include('SCH_soloSC.lua')


2. ADDING FUNCTIONS
If you don't have the following functions, copy paste them as is :
(hint : paste it in your main sch file, so if you later get an update to this file, you won't have to edit it)
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
    local fullRechargeTime = 4*60 -- change 60 with 40 if you have unlocked the job point gift about stratagem recast
    local currentCharges = math.floor(maxStratagems - maxStratagems * stratsRecast / fullRechargeTime)
    return currentCharges
end

--------------------------------------
-- ERRLOG
--------------------------------------
function errlog(msg) 
	add_to_chat(167,msg)
end


3. EDITING SYSTEM FUNCTIONS

--------------------------------------
-- JOB SELF COMMAND
--------------------------------------
You need to add the custom command for calling the solo skillchain function.
Find the "job_self_command" in your main script. If it doesn't exist, create it as follow :
function job_self_command(cmdParams, eventArgs)
-- insert code here
end

Code to insert :

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

--------------------------------------
-- JOB AFTERCAST
--------------------------------------  
Create the function job_aftercast, or if it already exists, edit it and insert the inner code at the end of the function (just before the "end").
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
-- JOB STATUS CHANGE
--------------------------------------  
This one is not mandatory, but will be helpful
function job_status_change(new_status, old_status)
  if (new_status=='resting') and (soloSC.active==true) then
    soloSkillchainAbort()
  end
end
 

-- #########################
-- WHAT YOU NEED TO EDIT HERE
-- #########################

Make sure you adjusted the constants in the last function getSpellsForSC.
the constants part looks like this :

--**************************************************
-- CONSTANTS
some variables to adjust
--**************************************************

The constants in this function are very important : they define the wait time before casting the next spell, respecting the MB window. So be as accurate as possible.
If you're not sure, prefer longer cast time or default values. Default is 4s for tier1, and 8s for helix.


-- #########################
-- KNOWN ISSUES
-- #########################

1. Why Distortion doesn't always work ?
Im' not sure about this, but I have an hypothesis : it needs the first tick of dot before the next immannenced spell lands. Didn't check. Don't plan to. Feel free to !

2. Sometimes my Gravitation fails
You probably tried a Gravitation while Noctohelix was still on recast.

3. getStratagems function doesn't work correctly
You probably have a decreased recast time on your stratagems. If you leave it as is, you won't have error, but might be incorrectly rejected for a lack of stratagems. Replace the 60 with 40 as said in the comment on the desired line.

3. The last skillchain didn't happen
You probably made a long skillchain combo (3 ?), and the last one was a bit off the skillchain window. Reduce your number of SC if this persists.

1. I made the first cast instant and nothing happens
That problem is gearswap specific : when a instant spell occurs, some "events" are not triggered, like the job_aftercast used to step forward in the solo skillchain process. I'm working on a fix, but it needs time.
--]]

--------------------------------------
-- SOLO SKILLCHAIN
--------------------------------------
--[[
@param integer|string nbSC : Number of SkillChains to do, between 1 and 3 or "max".
@param string elementEnd : final SC element (Fusion, Scission, ...).
@param bool MB : if true, will cast the tier V corresponding to the MB. Default is false.
@param bool STFU : if true, no message in party. Default is false.

Usage example : 
/console gs c soloSC 1 Fusion
=> will do 1 skillchain, ending with Fusion : Fire, Thunder. Equivalent to /console gs c soloSC 1 Fusion false false
/console gs soloSC 3 Fragmentation
=> will do 3 skillchains, ending with Fragmentation : Stone, Water, Blizzard, Water
/console gs soloSC max Fusion
=> will spend all stratagems to perform skillchains, ending with Fusion
/console gs c soloSC 1 Fusion true
=> will do 1 SC Fusion, and cast Fire V for magic burst
/console gs c soloSC 1 Fusion true true
=> will do 1 SC Fusion and cast Fire V for magic burst, with no information displayed in party chat
--]]
soloSC = {}
soloSC.step = {}
soloSC.params = {}

function soloSkillchain(nbSC,elementEnd,MB,STFU)
add_to_chat(200,'========== soloSkillchain ==========')

  elementEnd = tostring(elementEnd)
  if not STFU then
    STFU=false
  elseif STFU=='true' then
    STFU=true
  else
    STFU=false
  end
  
  if not MB then
    MB=false
  elseif MB=='true' then
    MB=true
  else
    MB=false
  end

  local plural = ''

-- Checking parameters
  if not elementEnd then
    errlog("Shitty parameters : soloSkillchain("..tostring(nbSC)..","..tostring(elementEnd)..")")
    return
  elseif elementEnd=='' then
    errlog("Shitty parameters : soloSkillchain("..tostring(nbSC)..","..tostring(elementEnd)..")")
  end --if not elementEnd

  if not info.skillchain.tier1:contains(elementEnd) and not info.skillchain.tier2:contains(elementEnd) then
    errlog('Finale SC not recognized : '..elementEnd)
    return
  end -- if not info.skillchain.tier1:contains(elementEnd) ...  

  local nbStrat = getNbStratagems()

  if not nbSC then
    errlog("Shitty parameters : soloSkillchain("..tostring(nbSC)..","..tostring(elementEnd)..")")
    return
  else
    if nbSC == 'max' then
      nbSC = nbStrat-1
      if buffactive["Tabula Rasa"] then nbSC = 4 end
	end

    nbSC = tonumber(nbSC)
	if nil==nbSC then
      errlog("Shitty parameters : nbSC isn't a number")
      return
    else
      if nbSC>1 then plural='s' end

      if nbSC>4 then
        errlog("Shitty parameters : soloSkillchain("..tostring(nbSC)..","..tostring(elementEnd)..")")
        return
	  elseif (nbSC >= nbStrat) then
        errlog("Not enough stratagems for "..tostring(nbSC).." skillchain"..plural.." : "..tostring(nbStrat)..'/'..tostring(nbSC+1))
        return
      end --if nbSC>4
	end --if nil==nbSC then
  end --else [if not nbSC]

-- Parameters OK.

-- Retrieving lists of spells needed
  spellsSC = getSpellsForSC(nbSC,elementEnd)

 
  -- Checking you didn't forget Dark Arts
  state.Buff["Dark Arts"] = buffactive["Dark Arts"] or false
  state.Buff["Addendum: Black"] = buffactive["Addendum: Black"] or false
  if not state.Buff["Dark Arts"] and not state.Buff["Addendum: Black"] then
    local spellRecasts = windower.ffxi.get_ability_recasts()
    -- recast id for "Dark Arts" = 232
    if spellRecasts[232] > 0 then
      errlog("ABORT : 'Dark Arts' required and not ready")
      return
    else
      soloSC.darkArtsCast = true
      send_command('input /ja "Dark Arts" <me>')
    end
  end


    -- If twice the same helix is used : abort
  local helixUsed = {}
  helixUsed.light = false
  helixUsed.dark = false
  
  -- let's make a loop to check that there's no trouble with helix used too much
  for i=0,nbSC,1 do
    if spellsSC[i].magic =='Luminohelix' then
      if helixUsed.light==true then
	      errlog("Recast problem : Luminohelix required more than once, aborting.")
	      return
      else
        helixUsed.light=true
      end
    end -- if spellsSC[i].magic =='Luminohelix'

    if spellsSC[i].magic =='Noctohelix' then
      if helixUsed.dark==true then
	      errlog("Recast problem : Noctohelix required more than once, aborting.")
	      return
      else
        helixUsed.dark=true
      end --if helixUsed.dark==true
    end --if spellsSC[i].magic =='Noctohelix'
  end
  

------------
-- OK we're good, everything is checked, let's start this shit

if (soloSC.active==true) then
  --aborting another soloSC if any
  soloSC.params.STFU = true -- let's not inform the party that we abort the previous, it is confusing.
  soloSkillchainResetParameters('starting a new one')
end

  soloSC.active = true
  soloSC.spells = spellsSC
  soloSC.step.current = 0
  soloSC.params.nbSC = nbSC
  soloSC.params.elementEnd = elementEnd
  soloSC.params.MB = MB
  soloSC.params.STFU = STFU
  
  -- Building the first party sentence
  local commandSoloSC = ''
  if not STFU then
    commandSoloSC = commandSoloSC..'input /p Starting '..tostring(nbSC)..' Skillchain'..plural..' : '
	for i=1,nbSC,1 do
	  if i>1 then commandSoloSC = commandSoloSC..',' end
	  commandSoloSC = commandSoloSC..'['..spellsSC[i].SC..']'
	end -- for
	send_command(commandSoloSC..' <call20>;input /jobemote run')
  end --if not STFU
  
  soloSkillchainStep()
end

--------------------------------------
-- SOLO SKILLCHAIN STEP
--------------------------------------
--[[
Called first by soloSkillchain, then by job_aftercast
This function actually send the inputs for JA and magic
Depending on original options, it can input information in party chat
Parameters were initialized by soloSkillchain, and are stored in : 
soloSC.params.nbSC
soloSC.params.elementEnd
soloSC.params.MB
soloSC.params.STFU

Other useful stuff is in : 
soloSC.active = true
soloSC.spells = spellsSC
soloSC.step.current = 0
soloSC.step.spell = ''
soloSC.timeLanded = 0
--]]
function soloSkillchainStep()
  -- canceling situations
  if soloSC.active~=true then return end

  local wait = {}
  wait.postImmanence = 1.5
  wait.precast = 3 -- you need a little wait after the previous job_aftercast or you will have "unable to use job ability." or "unable to cast spell at this time."
  
  -- if we are at a step after a SC, we inform the party that MB is on now
  if (not STFU) and (soloSC.step.current > 1) then
    send_command('wait 0.5;input /p MB window up NOW !')
  end
  
  --add_to_chat(200,'step num '..tostring(soloSC.step.current)) -- ########## for debug purpose

  if (soloSC.step.current <= soloSC.params.nbSC) then

    -- We build a one step full command
    commandStep = ''
    if(soloSC.step.current > 0) then
      commandStep = 'wait '..tostring(wait.precast)..';'
    else
      if(soloSC.darkArtsCast == true) then
        -- we need a wait between Dark Arts and the very first spell.
        commandStep = 'wait 1.5;'
      end
    end

    -- calculating waiting times
    -- the higher the SC, the shorter the SC window
    wait.windowMB = 7
    if (soloSC.step.current==3) then
      wait.windowMB = 6
    elseif (soloSC.step.current==4) then
      wait.windowMB = 4
    end
    
    -- Special actions are required once the SC is fully started
    wait.beforeNextSpell = 0
    if(soloSC.step.current > 1) then
      
      -- how long do we have to wait before starting casting the next spell ?
      wait.beforeNextSpell = math.max(1,(wait.windowMB - spellsSC[soloSC.step.current].castTime - wait.postImmanence))
      
      commandStep = commandStep..'wait '..tostring(wait.beforeNextSpell)..';'
    end -- if(soloSC.step.current > 1)
    
    -- Cast the spell
    commandStep = commandStep..'input /ja Immanence <me>;wait '..tostring(wait.postImmanence)..';'
    commandStep = commandStep..'input /ma '..spellsSC[soloSC.step.current].magic..' <t>;'
    soloSC.step.spell = spellsSC[soloSC.step.current].magic
    
    
    -- SC info for party
    if (not soloSC.params.STFU) and (soloSC.step.current > 0) then
      commandStep = commandStep..'input /p ['..spellsSC[soloSC.step.current].SC..'] in '..tostring(spellsSC[soloSC.step.current].castTime)..'s'
      commandStep = commandStep..' MB '..info.skillchain[ spellsSC[soloSC.step.current].SC ].MB
      if (soloSC.step.current < soloSC.params.nbSC) then -- we're not done yet, we inform the pt
        commandStep = commandStep..' (next SC : ['..spellsSC[soloSC.step.current+1].SC..'] in ~'..tostring(wait.beforeNextSpell + wait.postImmanence + spellsSC[soloSC.step.current+1].castTime)..'s)'
      end --if i<nbSC
      commandStep = commandStep..';'
    end -- if not STFU and i>0
    
    --add_to_chat(200,commandStep) -- ########### For debug purpose
    send_command(commandStep)

    -- We are ready for the next step
    soloSC.step.current = soloSC.step.current + 1


  else -- [if (soloSC.step.current <= soloSC.params.nbSC)]
    add_to_chat(200,'========== DONE ==========')
    
    if (soloSC.params.MB==true) then
      local spellMB = ''
      if soloSC.params.elementEnd=='Fusion' or soloSC.params.elementEnd=='Liquefaction' then
        spellMB = 'Fire V'
      elseif soloSC.params.elementEnd=='Gravitation' or soloSC.params.elementEnd=='Scission' then
        spellMB = 'Stone V'
      elseif soloSC.params.elementEnd=='Distortion' or soloSC.params.elementEnd=='Induration' then
        spellMB = 'Blizzard V'
      elseif soloSC.params.elementEnd=='Fragmentation' or soloSC.params.elementEnd=='Impaction' then
        spellMB = 'Thunder V'
      elseif soloSC.params.elementEnd=='Reverberation' then
        spellMB = 'Water V'
      elseif soloSC.params.elementEnd=='Detonation' then
        spellMB = 'Aero V'
      end

      if spellMB~='' then 
        add_to_chat(200,'starting MB with '..spellMB)
        send_command('wait '..tostring(wait.precast)..';input /ma "'..spellMB..'" <t>')
      end

    end -- if (soloSC.params.MB==true)
    
    soloSkillchainResetParameters() -- poof
  end -- ELSE [if (soloSC.step.current <= soloSC.params.nbSC)]


end -- function soloSkillchainStep


--------------------------------------
-- SOLO SKILLCHAIN ABORT & RESET PARAMETERS
--------------------------------------
--[[
this function purpose is only to abort an ongoing SC : reset parameters and display an error message
--]]
function soloSkillchainAbort(reason)
  if (soloSC.active == true) then
      local msgReason=''
      if reason==nil then reason='unknown' end
      msgReason = ': '..reason
      add_to_chat(167,'aborting current soloSkillchain : '..msgReason)

    if (not soloSC.params.STFU) then
      -- we inform the party we abort the SC
      send_command("input /p Skillchain ABORTED")
    end
  end

  soloSkillchainResetParameters()
end

function soloSkillchainResetParameters()
  soloSC.active = false
  soloSC.timeLanded = 0
  soloSC.spells = {}
  soloSC.step.current = 0
  soloSC.step.spell = ''
  soloSC.darkArtsCast = false

  soloSC.params.nbSC = 0
  soloSC.params.elementEnd = ''
  soloSC.params.MB = false
  soloSC.params.STFU = false
  
end

soloSkillchainResetParameters() -- will set default values to parameters


--------------------------------------
-- GET SPELLS FOR SC
--------------------------------------
-- Returns the spells required for the SC
-- do not call this function alone. It has to be called from soloSC and only there.
-- @param nbSC : number of SC to do
-- @param elementSCFinale : ex 'Liquefaction' /!\ NO CHECKING, 'Light' => non handled error
-- @return tabSpells
function getSpellsForSC(nbSC,elementSCFinale)
  nbSC = tonumber(nbSC)
  if nbSC>4 then nbSC=4 end
  if nbSC<1 then
    errlog('Dafuq ? '..tostring(nbSC)..' SC ?')
	return spellsSC
  end
  
  local spellsSC = {}
  spellsSC[0] = {}
  spellsSC[0].magic = 'undefined'
  spellsSC[0].castTime = -1
  spellsSC[0].SC = ''
  
  spellsSC[1] = {}
  spellsSC[1].magic = 'undefined'
  spellsSC[1].castTime = -1
  spellsSC[1].SC = ''
  
  spellsSC[2] = {}
  spellsSC[2].magic = 'undefined'
  spellsSC[2].castTime = -1
  spellsSC[2].SC = ''
  
  spellsSC[3] = {}
  spellsSC[3].magic = 'undefined'
  spellsSC[3].castTime = -1
  spellsSC[3].SC = ''
  
  spellsSC[4] = {}
  spellsSC[4].magic = 'undefined'
  spellsSC[4].castTime = -1
  spellsSC[4].SC = ''


  local wait = {}
  wait.postImmanence = 1
  local castTime = {}
  
  --**************************************************
  -- CONSTANTS
  -- tune this according to your cast time
  castTime.helix = 7
  castTime.tier1 = 3
  --**************************************************


  -- Wall of shit defining all the elements used for SC.
  local dataSC = {}
  local el = '' -- For reading convenience, will store current SC element.
    
  -- Tier 1
  el = 'Transfixion'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Noctohelix'
  dataSC[el].open.SC = 'Compression'
  dataSC[el].open.castTime = castTime.helix
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Luminohelix'
  dataSC[el].close.castTime = castTime.helix

  el = 'Compression'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Luminohelix'
  dataSC[el].open.SC = 'Transfixion'
  dataSC[el].open.castTime = castTime.helix
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Noctohelix'
  dataSC[el].close.castTime = castTime.helix
  
  -- some of the following settings are arbitrary : let's prioritize elemental to light/dark, and focus on most powerful ones : fire/blizzard/thunder
  el = 'Liquefaction'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Thunder'
  dataSC[el].open.SC = 'Impaction'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Fire'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Scission'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Fire'
  dataSC[el].open.SC = 'Liquefaction'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Stone'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Reverberation'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Stone'
  dataSC[el].open.SC = 'Scission'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Water'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Detonation'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Thunder'
  dataSC[el].open.SC = 'Impaction'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Aero'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Induration'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Water'
  dataSC[el].open.SC = 'Reverberation'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Blizzard'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Impaction'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Blizzard'
  dataSC[el].open.SC = 'Induration'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Thunder'
  dataSC[el].close.castTime = castTime.tier1
 
 
  -- Tier 2
  
  el = 'Fusion'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Fire'
  dataSC[el].open.SC = 'Liquefaction'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Thunder'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Gravitation'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Aero'
  dataSC[el].open.SC = 'Detonation'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Noctohelix'
  dataSC[el].close.castTime = castTime.helix
  
  el = 'Fragmentation'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Blizzard'
  dataSC[el].open.SC = 'Induration'
  dataSC[el].open.castTime = castTime.tier1
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Water'
  dataSC[el].close.castTime = castTime.tier1
  
  el = 'Distortion'
  dataSC[el] = {}
  dataSC[el].open = {}
  dataSC[el].open.magic = 'Luminohelix'
  dataSC[el].open.SC = 'Transfixion'
  dataSC[el].open.castTime = castTime.helix
  dataSC[el].close = {}
  dataSC[el].close.magic = 'Stone'
  dataSC[el].close.castTime = castTime.tier1

  
  local elementSC = {} -- SC element for each step
  elementSC[1] = ''
  elementSC[2] = ''
  elementSC[3] = ''
  elementSC[4] = ''
  
  elementSC[nbSC] = elementSCFinale
  
  -- Now we define the spells to chain. Warning, wall of code incoming.
  local step
  local elementSCEnCours

  for step=nbSC,1,-1 do
    -- Retrieving the SC element for this step.
    elementSCEnCours = elementSC[step]
	-- Retrieving spell.
	spellsSC[step].SC	= elementSCEnCours
	spellsSC[step].magic= dataSC[elementSCEnCours].close.magic
	spellsSC[step].castTime	= dataSC[elementSCEnCours].close.castTime

	-- Let's define the SC required for previous step.
	if step>1 then
	  elementSC[step-1] = dataSC[elementSCEnCours].open.SC
	end
  end

  spellsSC[0].magic= dataSC[ elementSC[1] ].open.magic
  spellsSC[0].castTime = dataSC[ elementSC[1] ].open.castTime
  -- Oh look, we're already done ! I'm a genius. #hohoho

  return spellsSC
end -- function getSpellsForSC