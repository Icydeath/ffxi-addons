_addon.name = 'FFXIKeys'
_addon.author = 'Areint/Alzade'
_addon.version = '2.3.2'
_addon.commands = {'keys'}

--------------------------------------------------------------------------------
require('logger')
packets = require('packets')
settings = require('util/settings')

local CommandFactory = require('command/factory')
local Aliases = require('util/aliases')
local FileLogger = require('util/logger')
local NilCommand = require('command/nil')

--------------------------------------------------------------------------------
local state = {}
state.command = NilCommand:NilCommand()

--------------------------------------------------------------------------------
local function OnReward(reward)
    if reward then
        if settings.config.printlinks then
            log('https://www.ffxiah.com/item/' .. reward .. '/')
        end
        if settings.config.openlinks then
            windower.open_url('https://www.ffxiah.com/item/' .. reward .. '/')
        end
        if settings.config.logitems then
            FileLogger.AddItem(reward)
        end
        return true
    end
    return false
end

--------------------------------------------------------------------------------
local function OnCommandSuccess(reward)
    if OnReward(reward) and settings.config.loop and state.command:IsRepeatable() then
        state.command:Reset()
        state.command(state)
    else
        state.command = NilCommand:NilCommand()
        FileLogger.Flush()
    end
end

--------------------------------------------------------------------------------
local function OnCommandFailure(reward)
    OnReward(reward)

    state.command = NilCommand:NilCommand()
    FileLogger.Flush()
end

--------------------------------------------------------------------------------
local function OnLoad()
    settings.load()
    Aliases.Update()
end

--------------------------------------------------------------------------------
local function OnIncomingData(id, _, pkt, b, i)
    return state.command:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
local function OnOutgoingData(id, _, pkt, b, i)
    return state.command:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
local function OnCommand(cmd, name)
    local new_command = CommandFactory.CreateCommand(cmd, name)
    if new_command:IsSimple() then
        new_command(state)
    elseif state.command:IsSimple() then
        state.command = new_command
        state.command:SetSuccessCallback(OnCommandSuccess)
        state.command:SetFailureCallback(OnCommandFailure)
        state.command(state)
    else
        log('Already running a complex command')
    end
end

--------------------------------------------------------------------------------
windower.register_event('load', OnLoad)
windower.register_event('zone change', OnLoad)
windower.register_event('addon command', OnCommand)
windower.register_event('incoming chunk', OnIncomingData)
windower.register_event('outgoing chunk', OnOutgoingData)
