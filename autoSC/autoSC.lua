_addon.name = "autoSC"
_addon.author = "Godchain"
_addon.version = "1.0"
_addon.commands = {"autoSC", "asc"}

res = require("resources")

enabled = true
player = windower.ffxi.get_player()
step = 1
ws_timing = 11
-- weapon_skills = {"Catastrophe", "Exenterator", "Cross Reaper", "Leaden Salute", "Catastrophe"}
-- weapon_skills = {"Burning Blade", "Slice", "Burning Blade", "Slice", "Burning Blade", "Slice", "Burning Blade"}
weapon_skills = {"Tachi: Fudo", "Tachi: Kasha", "Tachi: Shoha", "Tachi: Rana"}
ws_cache = {
    name = "N/A",
    damage = 0,
    time = -1
}

windower.register_event(
    "addon command",
    function(cmd, ...)
        if cmd == "start" then
            windower.add_to_chat(207, "AutoSC started.")
            enabled = true
            loop()
        elseif cmd == "stop" then
            windower.add_to_chat(207, "AutoSC stopped.")
            enabled = false
        end
    end
)

windower.register_event(
    "action",
    function(act)
        local target = windower.ffxi.get_mob_by_target("t") and windower.ffxi.get_mob_by_target("t").id or nil

        if (not enabled) or (not target) then
            return
        end

        if act.category == 3 and act.targets[1].id == target then
            local name = res.weapon_skills[act.param].name
            local damage = act.targets[1].actions[1].param

            if damage == 0 then
                -- WS missed
                windower.add_to_chat(207, name .. " missed - not updating time.")
            else
                -- WS hit - update cache
                ws_cache.name = name
                ws_cache.damage = damage
                ws_cache.time = os.time()

                -- Update step only if it was the right WS
                if name == weapon_skills[step] then
                    step = step < #weapon_skills and step + 1 or 1
                else
                    step = 1
                end
            end
        end
    end
)

function loop()
    local time_since_last = os.time() - ws_cache.time
    local playerTP = windower.ffxi.get_player().vitals.tp

    if step > 1 and time_since_last > (ws_timing - step) then
        -- Took too long for next step
        windower.add_to_chat(207, "SC failed - took too long (" .. time_since_last .. " secs)")
        step = 1
    end

    if playerTP > 1000 then
        if time_since_last > 3 and player_has_ws(weapon_skills[step]) then
            -- In SC window and player has next WS in line
            windower.add_to_chat(207, weapon_skills[step] .. " (step " .. step .. ")")
            windower.send_command('input /ws "' .. weapon_skills[step] .. '" <t>')
            windower.add_to_chat(207, 'input /ws "' .. weapon_skills[step] .. '" <t>')
        end
    end

    if enabled then
        coroutine.schedule(loop, 0.5)
    end
end

function player_has_ws(ws)
    for i, playerWS in ipairs(windower.ffxi.get_abilities().weapon_skills) do
        if res.weapon_skills[playerWS].name == ws then
            windower.add_to_chat(207, "returned true")
            return true
        end
    end

    return false
end
