local NilDialogue = require('model/dialogue/nil')
local NilMenu = require('model/menu/nil')
local Handshake = require('model/interaction/handshake')
local Choice = require('model/interaction/choice')
local NilInteraction = require('model/interaction/nil')
local MenuFactory = require('model/menu/factory')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local BuyDialogue = NilDialogue:NilDialogue()
BuyDialogue.__index = BuyDialogue

--------------------------------------------------------------------------------
function BuyDialogue:BuyDialogue(target, item_idx, count)
    local o = NilDialogue:NilDialogue()
    setmetatable(o, self)
    o._target = target
    o._item_idx = item_idx
    o._count = count
    o._type = 'BuyDialogue'
    o._menu = NilMenu:NilMenu()
    o._interactions = {}
    o._idx = 1

    o._end = NilInteraction:NilInteraction()
    o._end:SetSuccessCallback(function() o._on_success() end)
    o._end:SetFailureCallback(function() o._on_success() end)

    setmetatable(o._interactions, { __index = function() return o._end end })

    o:_AppendInteraction(NilInteraction:NilInteraction())
    o:_AppendInteraction(Handshake:Handshake())

    return o
end

--------------------------------------------------------------------------------
function BuyDialogue:OnIncomingData(id, pkt)
    local block = false
    if id == 0x037 then
        block = true
    elseif id == 0x034 or id == 0x032 then
        block = true
        self._menu = MenuFactory.CreateBuyMenu(pkt)
        self:_AppendInteraction(Choice:Choice())
    elseif id == 0x05C then
        block = true
        self._menu = MenuFactory.CreateExtraMenu(pkt, self._menu, self._item_idx, self._count)
        self:_AppendInteraction(Choice:Choice())
    end

    return (self._interactions[self._idx]:OnIncomingData(id, pkt) or block)
end

--------------------------------------------------------------------------------
function BuyDialogue:OnOutgoingData(id, pkt)
    return self._interactions[self._idx]:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function BuyDialogue:Start()
    self:_OnSuccess()
end

--------------------------------------------------------------------------------
function BuyDialogue:_AppendInteraction(interaction)
    interaction:SetSuccessCallback(function() self:_OnSuccess() end)
    interaction:SetFailureCallback(function() self._on_failure() end)
    table.insert(self._interactions, interaction)
end

--------------------------------------------------------------------------------
function BuyDialogue:_OnSuccess()
    self._idx = self._idx + 1
    local option = self._menu:OptionFor()
    local menu_id = self._menu:Id()
    local next = self._interactions[self._idx]

    local data = { target = self._target, menu = menu_id, choice = option.option,
        automated = option.automated, uk1 = option.uk1 }
    next(data)
end

return BuyDialogue