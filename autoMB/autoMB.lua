local skillchains = {
    [288] = {id = 288, english = "Light", elements = {"Light", "Fire", "Thunder", "Wind"}},
    [289] = {id = 289, english = "Darkness", elements = {"Dark", "Earth", "Water", "Ice"}},
    [290] = {id = 290, english = "Gravitation", elements = {"Dark", "Earth"}},
    [291] = {id = 291, english = "Fragmentation", elements = {"Thunder", "Wind"}},
    [292] = {id = 292, english = "Distortion", elements = {"Water", "Ice"}},
    [293] = {id = 293, english = "Fusion", elements = {"Light", "Fire"}},
    [294] = {id = 294, english = "Compression", elements = {"Dark"}},
    [295] = {id = 295, english = "Liquefaction", elements = {"Fire"}},
    [296] = {id = 296, english = "Induration", elements = {"Ice"}},
    [297] = {id = 297, english = "Reverberation", elements = {"Water"}},
    [298] = {id = 298, english = "Transfixion", elements = {"Light"}},
    [299] = {id = 299, english = "Scission", elements = {"Earth"}},
    [300] = {id = 300, english = "Detonation", elements = {"Wind"}},
    [301] = {id = 301, english = "Impaction", elements = {"Thunder"}}
}

windower.register_event(
    "incoming chunk",
    function(id, original)
        if id == 0x28 then
            local action_packet = windower.packets.parse_action(original)

            for _, target in pairs(action_packet.targets) do
                local battle_target = windower.ffxi.get_mob_by_target("t")

                if battle_target ~= nil and target.id == battle_target.id then
                    for _, action in pairs(target.actions) do
                        if action.add_effect_message > 287 and action.add_effect_message < 302 then
                            last_skillchain = skillchains[action.add_effect_message]

                            if last_skillchain.english == "Darkness" and battle_target.hpp > 5 then
                                local recasts = windower.ffxi.get_spell_recasts()
                                local absorbacc = 242
                                local absorbstr = 266

                                if (recasts[absorbstr] == 0) then
                                    windower.send_command("wait 3; input /absorbacc")
                                else
                                    windower.send_command("input /echo Everything was on cooldown :(")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)
