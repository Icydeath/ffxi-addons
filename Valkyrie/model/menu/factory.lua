local NilMenu = require('model/menu/nil')
local SimpleMenu = require('model/menu/simple')
local ConfirmMenu = require('model/menu/confirm')
local WarpMenu = require('model/menu/warp')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local MenuFactory = {}

--------------------------------------------------------------------------------
function MenuFactory.CreateRegisterMenu(pkt, idx)
    if not pkt or not idx or not packets then
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
        return NilMenu:NilMenu(menu_id)
    end

    return SimpleMenu:SimpleMenu(menu_id, idx, true, 0)
end

--------------------------------------------------------------------------------
function MenuFactory.CreateEnterMenu(pkt)
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
        return NilMenu:NilMenu(menu_id)
    end

    return WarpMenu:WarpMenu(menu_id)
end

--------------------------------------------------------------------------------
function MenuFactory.CreateExtraMenu(pkt, last_menu, idx)
    if not pkt or not last_menu or not packets then
        return NilMenu:NilMenu()
    end

    -- This isn't really needed until I figure out what is in these packets
    local ppkt = packets.parse('incoming', pkt)
    if not ppkt then
        return NilMenu:NilMenu(last_menu:Id())
    end

    -- I don't know what these values mean, but this is what is sent when you are currently timed out from
    -- entering Einherjar
    if ppkt['Param 1'] == 1 and ppkt['Param 2'] == 23 and ppkt['Param 3'] == 2964 and ppkt['Param 4'] == 1
            and ppkt['Message ID'] == 40799 and ppkt['_unknown1'] == 6 then
        return NilMenu:NilMenu(last_menu:Id())
    end

    if last_menu:Type() == 'SimpleMenu' then
        if not idx then
            return NilMenu:NilMenu(last_menu:Id())
        else
            return ConfirmMenu:ConfirmMenu(last_menu:Id(), idx)
        end
    end

    if last_menu:Type() == 'WarpMenu' then
        return SimpleMenu:SimpleMenu(last_menu:Id(), 1, false, 0)
    end

    return NilMenu:NilMenu(last_menu:Id())
end

return MenuFactory