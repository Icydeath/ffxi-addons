local NilDialogue = require('model/dialogue/nil')
local NilMenu = require('model/menu/nil')
local Trade = require('model/interaction/trade')
local Choice = require('model/interaction/choice')
local NilInteraction = require('model/interaction/nil')
local MenuFactory = require('model/menu/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local RegisterDialogue = NilDialogue:NilDialogue()
RegisterDialogue.__index = RegisterDialogue

--------------------------------------------------------------------------------
local function ParseError(pkt)
    local error = packets.get_bit_packed(pkt, 32, 40)
    if error == 0 then
        log('Chamber free')
    else
        log('Chamber occupied')
    end
    return error
end

--------------------------------------------------------------------------------
function RegisterDialogue:RegisterDialogue(target, player, chamber, lamp_id)
    local o = NilDialogue:NilDialogue()
    setmetatable(o, self)
    o._target = target
    o._player = player
    o._chamber = chamber
    o._lamp = lamp_id
    o._error = 0
    o._type = 'RegisterDialogue'
    o._menu = NilMenu:NilMenu()
    o._interactions = {}
    o._idx = 1

    o._end = NilInteraction:NilInteraction()
    o._end:SetSuccessCallback(function() o._on_success() end)
    o._end:SetFailureCallback(function() o._on_success() end)

    setmetatable(o._interactions, { __index = function() return o._end end })

    o:_AppendInteraction(NilInteraction:NilInteraction())
    o:_AppendInteraction(Trade:Trade())

    return o
end

--------------------------------------------------------------------------------
function RegisterDialogue:OnIncomingData(id, pkt)
    local block = false
    if id == 0x037 then
        block = true
    elseif id == 0x034 or id == 0x032 then
        block = true
        self._menu = MenuFactory.CreateRegisterMenu(pkt, self._chamber.idx)
        self:_AppendInteraction(Choice:Choice())
    elseif id == 0x05C then
        block = true
        self._menu = MenuFactory.CreateExtraMenu(pkt, self._menu, self._chamber.idx)
        self:_AppendInteraction(Choice:Choice())
        self._error = ParseError(pkt)
    elseif id == 0x02A then
        block = false
        if MenuFactory.CreateExtraMenu(pkt, self._menu, self._chamber.idx):Type() == 'NilMenu' then
            self._on_success()
        end
    end

    return (self._interactions[self._idx]:OnIncomingData(id, pkt) or block)
end

--------------------------------------------------------------------------------
function RegisterDialogue:OnOutgoingData(id, pkt)
    return self._interactions[self._idx]:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function RegisterDialogue:Start()
    log('Registering for ' .. self._chamber.en)
    self:_OnSuccess()
end

--------------------------------------------------------------------------------
function RegisterDialogue:_AppendInteraction(interaction)
    interaction:SetSuccessCallback(function() self:_OnSuccess() end)
    interaction:SetFailureCallback(function() self._on_failure() end)
    table.insert(self._interactions, interaction)
end

--------------------------------------------------------------------------------
function RegisterDialogue:_OnSuccess()
    self._idx = self._idx + 1
    local option = self._menu:OptionFor(self._error)
    local menu_id = self._menu:Id()
    local next = self._interactions[self._idx]

    local data = { target = self._target, menu = menu_id, choice = option.option,
        automated = option.automated, uk1 = option.uk1, player = self._player,
        item_id = self._lamp }
    next(data)
end

return RegisterDialogue