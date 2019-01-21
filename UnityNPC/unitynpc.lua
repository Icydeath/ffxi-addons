_addon.name = 'UnityNPC'
_addon.author = 'Areint/Alzade'
_addon.version = '1.0.2'
_addon.commands = {'unpc'}

--------------------------------------------------------------------------------
require('logger')
packets = require('util/packets')
settings = require('util/settings')
resources = require('resources')

local CommandFactory = require('command/factory')
local Aliases = require('util/aliases')
local NilCommand = require('command/nil')

--------------------------------------------------------------------------------
local command = NilCommand:NilCommand()

--------------------------------------------------------------------------------
local function OnCommandFinished()
    command = NilCommand:NilCommand()
end

--------------------------------------------------------------------------------
local function OnLoad()
    settings.load()
    Aliases.Update()
end

--------------------------------------------------------------------------------
local function OnCommand(cmd, p1, p2)
    if command:Type() == 'NilCommand' then
        command = CommandFactory.CreateCommand(cmd, p1, p2)
        command:SetSuccessCallback(OnCommandFinished)
        command:SetFailureCallback(OnCommandFinished)
        command()
    else
        log('Already running a command')
    end
end

--------------------------------------------------------------------------------
local function OnIncomingData(id, _, pkt, b, i)
    return command:OnIncomingData(id, pkt)
end

--------------------------------------------------------------------------------
local function OnOutgoingData(id, _, pkt, b, i)
    return command:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
windower.register_event('load', OnLoad)
windower.register_event('addon command', OnCommand)
windower.register_event('incoming chunk', OnIncomingData)
windower.register_event('outgoing chunk', OnOutgoingData)
