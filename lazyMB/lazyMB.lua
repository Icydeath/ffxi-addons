--[[
Copyright (c) 2016, kotodamage
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
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'lazyMB'
_addon.version = '0.3'
_addon.author = 'kotodamage'
_addon.command = 'lazyMB'

chat = require('chat')
res = require('resources')
require('tables')

-- global variables
fastcast_rate = 0.8
time_limit = 8
delay = 0
valid_jobs = {'BLM', 'RDM', 'SCH', 'GEO'}

spells = {
  fire = {
    888, -- Pyrohelix II
    496, -- Firaja
    849, -- Fire VI
    148, -- Fire V
    147, -- Fire IV
    865, -- Fira III
    176, -- Firaga III
    146, -- Fire III
    829, -- Fira II
    175, -- Firaga II
    145, -- Fire II
    828, -- Fira
    174, -- Firaga
    144, -- Fire
    281, -- Pyrohelix
  },
  water = {
    886, -- Hydrohelix II
    501, -- Waterja
    854, -- Water VI
    173, -- Water V
    172, -- Water IV
    870, -- Watera III
    201, -- Waterga III
    171, -- Water III
    838, -- Watera II
    199, -- Waterga II
    170, -- Water II
    837, -- Watera
    198, -- Waterga
    169, -- Water
    279, -- Hydrohelix
  },
  thunder = {
    890, -- Ionohelix II
    500, -- Thundaja
    853, -- Thunder VI
    168, -- Thunder V
    167, -- Thunder IV
    869, -- Thundara III
    196, -- Thundaga III
    166, -- Thunder III
    837, -- Thundara II
    195, -- Thundaga II
    165, -- Thunder II
    836, -- Thundara
    194, -- Thundaga
    164, -- Thunder
    283, -- Ionohelix
  },
  stone = {
    885, -- Geohelix II
    499, -- Stoneja
    852, -- Stone VI
    163, -- Stone V
    162, -- Stone IV
    868, -- Stonera III
    191, -- Stonega III
    161, -- Stone III
    835, -- Stonera II
    190, -- Stonega II
    160, -- Stone II
    834, -- Stonera
    189, -- Stonega
    159, -- Stone
    278, -- Geohelix
  },
  aero = {
    887, -- Anemohelix II
    498, -- Aeroja
    851, -- Aero VI
    158, -- Aero V
    157, -- Aero IV
    867, -- Aera III
    186, -- Aeroga III
    156, -- Aero III
    833, -- Aera II
    185, -- Aeroga II
    155, -- Aero II
    832, -- Aera
    184, -- Aeroga
    154, -- Aero
    280, -- Anemohelix
  },
  blizzard = {
    889, -- Cryohelix II
    497, -- Blizzaja
    850, -- Blizzard VI
    153, -- Blizzard V
    152, -- Blizzard IV
    866, -- Blizzara III
    181, -- Blizzaga III
    151, -- Blizzard III
    831, -- Blizzara II
    180, -- Blizzaga II
    150, -- Blizzard II
    830, -- Blizzara
    179, -- Blizzaga
    149, -- Blizzard
    282, -- Cryohelix
  },
  dark = {
    891, -- Noctohelix II
    219, -- Comet
    284, -- Noctohelix
  },
  light = {
    892, -- Luminohelix II
    285, -- Luminohelix
  },
  death = {
    367, -- Death
  }
}
use_aoe = true
use_helix = true
verbose = false
ignore_jobs = false
chatColor =      {
  success = 120, -- get experience
  info = 49,     -- gearswap default
  notice = 157,  -- item highlighting
  error = 38     -- dead
}

windower.register_event('addon command', function(...)
  local args = {...}
  local comm

  local current_mp
  local time = 0
  local recasts
  local buffer = ''
  local player
  local learned
  local target
  local valid, msg
  local queue = {}

  if args[1] ~= nil then
    comm = args[1]:lower()

    -- switch with subcommands
    if comm == 'cast' then
      elem = args[2]:lower()
      spellSet = spells[elem]
      if not spellSet then
        windower.add_to_chat(chatColor.error, '[lazyMB] Abort: Element ' .. elem .. ' is not found.')
        return
      end

      if args[3] then
        time_limit = tonumber(args[3])
      else
        time_limit = 8
      end

      if args[4] then
        delay = tonumber(args[4])
      else
        delay = 0
      end

      if not ignore_jobs and not table.contains(valid_jobs, windower.ffxi.get_player().main_job) then
        windower.add_to_chat(chatColor.error, '[lazyMB] Abort: Invalid main job.')
        return
      end

      target = windower.ffxi.get_mob_by_target('t')
      if not target or not target.valid_target then
        windower.add_to_chat(chatColor.error, '[lazyMB] Abort: No valid target.')
        return
      end

      player = windower.ffxi.get_player()
      current_mp = player.vitals.mp
      recasts = windower.ffxi.get_spell_recasts()
      learned = windower.ffxi.get_spells()

      for _, v in ipairs(spellSet) do
        spell = res.spells[v]
        cast_time = spell.cast_time * (1 - fastcast_rate)

        valid, msg = validate_spell(spell, player, target, current_mp, recasts, learned, time, cast_time)
        if valid then

          if time == 0 then

            if cast_time < delay then
              buffer = buffer .. 'wait ' .. delay - cast_time .. ';'
              if verbose then
                windower.add_to_chat(chatColor.info, "[lazyMB] Delay casting for " .. (delay - cast_time) .. " sec.")
              end
              time = 3.8

            else
              time = cast_time - delay + 3.8
            end

          else
            time = time + cast_time + 3.8
          end

          current_mp = current_mp - spell.mp_cost
          buffer = buffer .. 'input /ma ' .. spell.ja .. ' <t>;wait ' .. (cast_time + 3.8) .. ';'
          table.insert(queue, spell.ja)

          -- check already over time limit
          if time > time_limit then
            break
          end

        else
          -- skipping with message
          if verbose then
            windower.add_to_chat(chatColor.notice, windower.to_shift_jis(msg))
          end
        end
      end

      if buffer ~= '' then
        windower.send_command(windower.to_shift_jis(buffer))
        windower.add_to_chat(chatColor.success, windower.to_shift_jis('[lazyMB] In queue (' .. time .. ' sec): ' .. table.concat(queue, ', ')))
      end

    elseif comm == 'verbose' then
      arg = args[2]:lower()
      verbose = arg == 'on' or arg == 'enable' or arg == 'true'
      windower.add_to_chat(chatColor.info, windower.to_shift_jis('[lazyMB] verbose: ' .. tostring(verbose)))

    elseif comm == 'aoe' then
      arg = args[2]:lower()
      use_aoe = arg == 'on' or arg == 'enable' or arg == 'true'
      windower.add_to_chat(chatColor.info, windower.to_shift_jis('[lazyMB] AOE mode: ' .. tostring(use_aoe)))

    elseif comm == 'helix' then
      arg = args[2]:lower()
      use_helix = arg == 'on' or arg == 'enable' or arg == 'true'
      windower.add_to_chat(chatColor.info, windower.to_shift_jis('[lazyMB] Helix mode: ' .. tostring(use_helix)))

    elseif comm == 'ignore_jobs' then
      arg = args[2]:lower()
      ignore_jobs = arg == 'on' or arg == 'enable' or arg == 'true'
      windower.add_to_chat(chatColor.info, windower.to_shift_jis('[lazyMB] ignore_jobs: ' .. tostring(ignore_jobs)))

    else
      -- print help to chat
      windower.add_to_chat(chatColor.info, helptext)
    end
  end
end)

function is_spell_available(spell, player, learned)

  for job, lv in pairs(spell.levels) do
    if job == player.main_job_id then
      if lv > 99 then
        if lv <= player.job_points[player.main_job:lower()].jp_spent then
          return true
        end
      else
        if lv <= player.main_job_level then
          return true
        end
      end

    elseif job == player.sub_job_id then
      if lv <= player.sub_job_level then
        return true
      end
    end
  end

  return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (Not available in current job)'
end

function is_spell_aoe(spell)
  -- NOTE: lua regexp limitation:
  -- http://lua-users.org/wiki/PatternsTutorial
  return
  spell.ja == "ファイジャ" or string.match(spell.ja, "ファイガ") or string.match(spell.ja, "ファイラ") or
  spell.ja == "ブリザジャ" or string.match(spell.ja, "ブリザガ") or string.match(spell.ja, "ブリザラ") or
  spell.ja == "サンダジャ" or string.match(spell.ja, "サンダガ") or string.match(spell.ja, "サンダラ") or
  spell.ja == "エアロジャ" or string.match(spell.ja, "エアロガ") or string.match(spell.ja, "エアロラ") or
  spell.ja == "ウォタジャ" or string.match(spell.ja, "ウォタガ") or string.match(spell.ja, "ウォタラ") or
  spell.ja == "ストンジャ" or string.match(spell.ja, "ストンガ") or string.match(spell.ja, "ストンラ")
end

function in_range(target, spell)
  -- http://forums.windower.net/index.php?/topic/412-distance-and-gearswap-question/
  local range_mult = {
    [2] =  1.70,
    [3] = 1.490909,
    [4] = 1.44,
    [5] = 1.377778,
    [6] = 1.30,
    [7] = 1.20,
    [8] = 1.30,
    [9] = 1.377778,
    [10] = 1.45,
    [11] = 1.490909,
    [12] = 1.70,
  }

  local target_yalm = target.distance:sqrt()
  local spell_range = target.model_size + spell.range * range_mult[spell.range]
  return target_yalm < spell_range
end

function validate_spell(spell, player, target, current_mp, recasts, learned, time, cast_time)
  local valid, msg

  -- check whether can player cast that spell
  if not learned[spell.id] then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (Not learned)'
  end

  valid, msg = is_spell_available(spell, player, learned)
  if not valid then
    return valid, msg
  end

  -- check recast
  if (recasts[spell.recast_id] - time) > 0 then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (In recast)'
  end

  -- check MP cost
  if current_mp < spell.mp_cost then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (No MP)'
  end

  -- check can use Helix
  if not use_helix and string.match(spell.ja, '計') then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (No use Helix)'
  end

  -- check can use AOE
  if not use_aoe and is_spell_aoe(spell) then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (No use AOE)'
  end

  -- check distance
  if not in_range(target, spell) then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (Out of range)'
  end

  -- check whether the spell can hit in time limit
  if time + cast_time >= time_limit then
    return false, '[lazyMB] Skipped    ' .. spell.ja .. ' (Too long cast time)'
  end

  return true
end

helptext = [[
Usage: lazyMB <command> <args>
Note: <boolean> evaluate 'on|true|enable' as true, others false.
  lazyMB cast <element> [accept_time] [start_delay]
    -> Cast spells of <element>.
     <element>:
      fire, water, thunder, stone, aero, blizzard,
      dark, light, death
     [accept_time]: Time duration for MB. default: 8.
     [start_delay]: Time for wait for MB starts. default: 0.
  lazyMB verbose <boolean>
    -> Print verbose logs. default: false.
  lazyMB aoe <boolean>
    -> Use AoE spells if this option is true. default: true.
  lazyMB helix <boolean>
    -> Use helix if this option is true. default: true.
  lazyMB ignore_jobs <boolean>
    -> Skip checking of main job. default: false.
       If this option is false, only BLM/RDM/SCH/GEO can cast spells.
]]
