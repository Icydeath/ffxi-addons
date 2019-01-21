local ActionMenu = require('model/menu/action')
local CountMenu = require('model/menu/count')
local ItemMenu = require('model/menu/item')
local NilMenu = require('model/menu/nil')
local SimpleMenu = require('model/menu/simple')
local WarpMenu = require('model/menu/warp')
local BuyMenu = require('model/menu/buy')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local MenuFactory = {}

--------------------------------------------------------------------------------
function MenuFactory.CreateWarpMenu(pkt)
    if not pkt or not packets then
        return NilMenu:NilMenu()
    end

    local ppkt = packets.parse('incoming', pkt)
    if not ppkt then
        return NilMenu:NilMenu()
    end

    local menu_id = ppkt['Menu ID']
    if not menu_id or menu_id == 0 then
        return NilMenu:NilMenu()
    end

    local params = ppkt['Menu Parameters']
    if not params then
        return SimpleMenu:SimpleMenu(menu_id, 0, false, 0)
    end

    return SimpleMenu:SimpleMenu(menu_id, 10, true, 0)
end

--------------------------------------------------------------------------------
function MenuFactory.CreateBuyMenu(pkt)
    if not pkt or not packets then
        return NilMenu:NilMenu()
    end

    local ppkt = packets.parse('incoming', pkt)
    if not ppkt then
        return NilMenu:NilMenu()
    end

    local menu_id = ppkt['Menu ID']
    if not menu_id or menu_id == 0 then
        return NilMenu:NilMenu()
    end

    local params = ppkt['Menu Parameters']
    if not params then
        return SimpleMenu:SimpleMenu(menu_id, 0, false, 0)
    end

    return BuyMenu:BuyMenu(menu_id)
end

--------------------------------------------------------------------------------
function MenuFactory.CreateExtraMenu(pkt, last_menu, v1, v2)
    if not pkt or not last_menu or not packets then
        return NilMenu:NilMenu()
    end

    -- This isn't really needed until I figure out what is in these packets
    local ppkt = packets.parse('incoming', pkt)
    if not ppkt then
        return NilMenu:NilMenu(last_menu:Id())
    end

    if last_menu:Type() == 'SimpleMenu' then
        return ActionMenu:ActionMenu(last_menu:Id())
    elseif last_menu:Type() == 'ActionMenu' then
        if not v1 then
            return NilMenu:NilMenu(last_menu:Id())
        else
            return WarpMenu:WarpMenu(last_menu:Id(), { v1 });
        end
    end

    if last_menu:Type() == 'BuyMenu' then
        if not v1 then
            return NilMenu:NilMenu(last_menu:Id())
        else
            return ItemMenu:ItemMenu(last_menu:Id(), v1)
        end
    elseif last_menu:Type() == 'ItemMenu' then
        if not v1 or not v2 then
            return NilMenu:NilMenu(last_menu:Id())
        else
            return CountMenu:CountMenu(last_menu:Id(), v1, v2)
        end
    end

    return NilMenu:NilMenu(last_menu:Id())
end

return MenuFactory
