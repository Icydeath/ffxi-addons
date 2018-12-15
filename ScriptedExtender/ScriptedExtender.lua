_addon.name = 'ScriptedExtender'
_addon.author = 'Scripted'
_addon.version = '1.0'
last_sent = 0

if windower then
    windower.register_event('incoming chunk', function (id, data, modified, injected, blocked)
        local sendstr = "Scripted extravariables "
        local updatescripted = false
        if id == 0x037 then
            local indi = data:byte(0x59)
            if last_sent ~= indi then
                sendstr = sendstr.."INDI:"..indi
                last_sent = indi
                updatescripted = true
            end
        end
        if updatescripted then
            windower.send_command(sendstr)
        end
    end)
end

if ashita then
    ashita.register_event('incoming_packet', function(id, size, packet)
        local sendstr = "//Scripted extravariables "
        local updatescripted = false
        if id == 0x037 then
            local indi = packet:byte(0x59)
            if last_sent ~= indi then
                sendstr = sendstr.."INDI:"..indi
                last_sent = indi
                updatescripted = true
            end
        end
        if updatescripted then
            AshitaCore:GetChatManager():QueueCommand(sendstr,1)
        end
        return false
    end )
end