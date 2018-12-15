local BuyCommand = require('command/buy_command')
local ConfigCommand = require('command/config_command')
local NilCommand = require('command/nil_command')
local StopCommand = require('command/stop_command')
local UnlockCommand = require('command/unlock_command')
local Keys = require('data/keys')
local Locks = require('data/locks')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CommandFactory = {}

--------------------------------------------------------------------------------
function CommandFactory.CreateCommand(cmd, p1, p2, p3)
    if not cmd then
        return NilCommand:NilCommand()
    end

    if cmd == 'stop' then
        return StopCommand:StopCommand()
    elseif cmd == 'unlock' then
        if not p1 or not p2 then
            if log then
                log('Invalid Arguments')
            end
            return NilCommand:NilCommand()
        end

        local key = Keys.GetKey(p1)
        local lock = Locks.GetGobbieMysteryBoxByName(p2)
        return UnlockCommand:UnlockCommand(key.id, lock.id)
    elseif cmd == 'buy' then
        if not p1 or not p2 or not p3 then
            if log then
                log('Invalid Arguments')
            end
            return NilCommand:NilCommand()
        end

        local key = Keys.GetKey(p1)
        local lock = Locks.GetUnityByName(p2)
        local count = p3 and tonumber(p3) or nil
        return BuyCommand:BuyCommand(key.id, lock.id, key.option, lock.menu, lock.zone, count)
    elseif cmd == 'printlinks' or cmd == 'openlinks' then
        if log then
            log('Settings Saved')
        end
        return ConfigCommand:ConfigCommand(cmd)
    end

    return NilCommand:NilCommand()
end

return CommandFactory
