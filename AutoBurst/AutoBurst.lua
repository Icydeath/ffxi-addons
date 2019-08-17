_addon.name = 'Auto_Burst'
_addon.author = 'Daniel_H'
_addon.version = '1.0'
_addon_description = ''
_addon.commands = { 'ab', 'autoburst' }

-- CUSTOM VARIABLES

local packets = require( "packets" )
local res = require( "resources" )
require( 'strings' )

local enable_Bursting = false
local isCasting = false

local player = windower.ffxi.get_player( )
local spell_recasts = windower.ffxi.get_spell_recasts( )
local ability_recasts = windower.ffxi.get_ability_recasts( )
local owned_spells = windower.ffxi.get_spells( )
local owned_abilitys = windower.ffxi.get_abilities( )

local knownMP_monsters = S{ "Apex Crab" }

-- USER SETTINGS MAKE SURE TO EDIT -------------------- --

local AssistedPlayer = "Icydeath" -- MAKE SURE TO EDIT THIS

burstMagic = {
  -- LEVEL 3  and 4
  ["radiance"] = "Thunder",
  ["light"] = "Thunder",
  ["umbra"] = "Blizzard",
  ["darkness"] = "Blizzard",
  -- LEVEL 2
  ["gravitation"] = "Stone",
  ["fragmentation"] = "Thunder",
  ["distortion"] = "Blizzard",
  ["fusion"] = "Fire",
  -- LEVEL 1
  ["compression"] = "Aspir",
  ["liquefaction"] = "Fire",
  ["induration"] = "Blizzard",
  ["reverberation"] = "Water",
  ["transfixion"] = "Banish",
  ["scission"] = "Stone",
  ["detonation"] = "Aero",
  ["impaction"] = "Thunder",
}

--[[
tierOrder = {
  [1] = "VI",
  [2] = "V",
  [3] = "IV",
  [4] = "III",
  [5] = "II",
  [6] = "I",
}
--]]

tierOrder = {
  [4] = "VI",
  [3] = "V",
  [2] = "IV",
  [1] = "III",
  [5] = "II",
  [6] = "I",
}

-- ---------------------------------------------------- --

function CheckIfBursting( )
  if player.main_job == "RDM" or player.main_job == "BLM" or player.main_job == "SCH" or player.main_job == "GEO" or player.main_job == "NIN" then
    enable_Bursting = true
  else
    enable_Bursting = false
  end
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

-- SKILLCHAINS TABLE

skillchains = {
  [288] = 'light', [385] = 'light',
  [289] = 'darkness', [386] = 'darkness',
  [290] = 'gravitation', [387] = 'gravitation',
  [291] = 'fragmentation', [388] = 'fragmentation',
  [292] = 'distortion', [389] = 'distortion',
  [293] = 'fusion', [390] = 'fusion',
  [294] = 'compression', [391] = 'compression',
  [295] = 'liquefaction', [392] = 'liquefaction',
  [296] = 'induration', [393] = 'induration',
  [297] = 'reverberation', [394] = 'reverberation',
  [298] = 'transfixion', [395] = 'transfixion',
  [299] = 'scission', [396] = 'scission',
  [300] = 'detonation', [397] = 'detonation',
  [301] = 'impaction', [398] = 'impaction',
  [767] = 'radiance', [769] = 'radiance',
  [770] = 'umbra', [768] = 'umbra',
}

function BuffActive( BuffID )
  if T( windower.ffxi.get_player( ).buffs ):contains( BuffID ) == true then
    return true
  else
    return false
  end

end

function playerDisabled( )
  if BuffActive( 0 ) == true then -- KO
    return true
  elseif BuffActive( 2 ) == true then -- SLEEP
    return true
  elseif BuffActive( 6 ) == true then -- SILENCE
    return true
  elseif BuffActive( 7 ) == true then -- PETRIFICATION
    return true
  elseif BuffActive( 10 ) == true then -- STUN
    return true
  elseif BuffActive( 14 ) == true then -- CHARM
    return true
  elseif BuffActive( 28 ) == true then -- TERRORIZE
    return true
  elseif BuffActive( 29 ) == true then -- MUTE
    return true
  elseif BuffActive( 193 ) == true then -- LULLABY
    return true
  elseif BuffActive( 262 ) == true then -- OMERTA
    return true
  end
  return false
end

function CanUseJobAbility( checkedname )
  abilityData = res.abilites:with( 'name', checkedname )
  if ( abilityData == nil ) or ( ability_recasts( abilityData.recast_id ) ~= 0 ) or ( playerDisabled( ) == true ) then
    return false
  else
    return true
  end
end

function CanUseSpell( spellName )
  -- FIRST CHECK THAT YOU CAN ACTUALLY CAST SPELL ( IE YOU HAVE REQUIRED LEVELS/JP/LEARNED )
  spell = res.spells:with( 'en', spellName )

  -- IF player, spell OR spell.levels IS NIL OR PLAYER IS DISABLED ( Stunned, Silenced, Petrified ETC ) THEN RETURN false AND CANCEL SPELL
  if ( player == nil ) or ( spell == nil ) or ( spell.levels[player.main_job_id] == nil ) or ( playerDisabled( ) == true ) then return false end

  -- CHECK IF SPELL IS A JOB POINTED ONE IF NOT THEN JUST COMPARE LEVELS AND CHECK YOU OWN THE SPELL
  if spell.levels[player.main_job_id] == 100 then -- IS A JOB POINT SPELL THAT REQUIRES 100 JOB POINTS BEING SPENT
    if S{ "Thunder VI", "Blizzard VI", "Fire VI", "Stone VI", "Water VI", "Aero VI" }:contains( spell.en ) and player.job_points.blm.jp_spent >= 100 then
      return true
    elseif S{ "Thunder V", "Blizzard V", "Fire V", "Stone V", "Water V", "Aero V" }:contains( spell.en ) and ( player.job_points.rdm.jp_spent >= 100 or player.job_points.geo.jp_spent >= 100 ) then
      return true
    end
  elseif spell.levels[player.main_job_id] == 550 then -- IS A JOB POINT SPELL THAT REQUIRES 550 JOB POINTS BEING SPENT
    if spell.en == "Aspir III" and ( player.job_points.blm.jp_spent >= 550 or player.job_points.geo.jp_spent >= 550 ) then
      return true
    end
  elseif spell.levels[player.main_job_id] == 1200 then -- IS A JOB POINT SPELL THAT REQUIRES 1200 JOB POINTS BEING SPENT
    if spell.en == "Death" and player.job_points.blm.jp_spent >= 1200 then
      return true
    end
  else -- IS NOT A JOB POINT SPELL
    if spell.levels[player.main_job_id] >= player.main_job_level then -- YOU ARE THE REQUIRED LEVEL OR ABOVE IT
      if windower.ffxi.get_spells( )[spell.id] then -- YOU POSSESS THE SPELL IE YOU USED A SCROLL TO LEARN IT OR SPENT MERIT POINTS
        if player.mp > spellData.mp_cost and spell_recasts( spell.recast_id ) == 0 then -- RECAST IS AVAILABLE AND YOU HAVE THE REQUIRED MP
          return true
        end
      end
    end
  end

  -- IF YOU DON'T GET TRUE ELSEWHERE RETURN FALSE
  return false
end


function castSpell(spell, burst)

  target = windower.ffxi.get_mob_by_target( 't' )

  windower.add_to_chat(1, ('\31\200\31\05Burst located:\31\200\31\207 '.. firstToUpper(burst) .." Attempting cast: \31\200\31\05"..spell..'\31\200\31\207 '))

  if target ~= nil and target.is_npc then
    windower.send_command('wait 2; input /ma "'..spell..'" <t>')
  else
    windower.send_command('wait 2; input /ma "'..spell..'" <bt>')
  end
end

function run_burst(skillchain)

  CheckIfBursting( )

  if (AssistedPlayer ~= "") then
    windower.send_command( 'input /assist '..AssistedPlayer )
    coroutine.sleep(1)
  end


  if skillchain == nil then return end

  completed_Spell = ""
  generated_spell = burstMagic[skillchain]

  -- Scan through tier order and check what spell you can use following said order

  target = windower.ffxi.get_mob_by_target( 't' )


  if S{'darkness', 'umbra', 'compression', 'gravitation'}:contains(skillchain) and player.vitals.mpp < 20 and target ~= nil and knownMP_monsters:contains( target.name ) then
    windower.add_to_chat(1, ('\31\200\31\05Low MP Notice: \31\200\31\207 Attempting to recover MP with Aspir.'))
    if CanUseSpell( "Aspir III" ) then
      completed_Spell = "Aspir III"
    elseif CanUseSpell( "Aspir II" ) then
      completed_Spell = "Aspir II"
    elseif CanUseSpell( "Aspir" ) then
      completed_Spell = "Aspir"
    end
  else
    for i, v in ipairs(tierOrder) do
      if v == "I" then
        if CanUseSpell( generated_spell ) == true then
          completed_Spell = generated_spell
          break
        end
      else
        if CanUseSpell( generated_spell.." "..v ) == true then
          completed_Spell = generated_spell.." "..v
          break
        end
      end
    end
  end

  if completed_Spell ~= "" then
    castSpell(completed_Spell, skillchain)
  end
end

windower.register_event( 'incoming chunk', function( id, data )
  if id == 0x028 then
  local action_message = packets.parse( 'incoming', data )
  if action_message["Category"] == 4 then
    isCasting = false
  elseif action_message["Category"] == 8 then
    isCasting = true
    if action_message["Target 1 Action 1 Message"] == 0 then
      isCasting = false
      isBusy = Action_Delay
    end
  end
end
end)

windower.register_event('addon command', function(input, ...)
local args = {...}
if args ~= nil then
  local cmd = string.lower(input)
  if cmd == "assist" then
    AssistedPlayer = args[1]
  end
end
end)

windower.register_event( 'action', function ( data )
player = windower.ffxi.get_player( )
if data.category == 3 or data.category == 4 or data.category == 11 or data.category == 13 then
  if data.target_count > 0 then
    actor = windower.ffxi.get_mob_by_id( data.actor_id ) -- GRAB ACTOR DATA
    if actor ~= nil and ( actor.in_party or actor.in_alliance ) then
      if data.targets[1].actions ~= nil then
        local action = data.targets[1].actions[1]
        if action.has_add_effect then
          run_burst( skillchains[action.add_effect_message] )
        end
      end
    end
  end
end
end )
