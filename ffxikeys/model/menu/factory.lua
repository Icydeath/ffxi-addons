local UseMenu = require('model/menu/use')
local NilMenu = require('model/menu/nil')
local SimpleMenu = require('model/menu/simple')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local MenuFactory = {}

--------------------------------------------------------------------------------
function MenuFactory.CreateUseMenu(pkt)
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
        return SimpleMenu:SimpleMenu(menu_id, 0, false)
    end

    return UseMenu:UseMenu(menu_id)
end

--------------------------------------------------------------------------------
function MenuFactory.CreateExtraMenu(pkt, last_menu)
    if not pkt or not last_menu or not packets then
        return NilMenu:NilMenu(0)
    end

    -- This isn't really needed until I figure out what is in these packets
    local ppkt = packets.parse('incoming', pkt)
    if not ppkt then
        return NilMenu:NilMenu(last_menu:Id())
    end

    if last_menu:Type() == 'UseMenu' then
        return SimpleMenu:SimpleMenu(last_menu:Id(), 2, true, 0)
    elseif last_menu:Type() == 'SimpleMenu' then
        return SimpleMenu:SimpleMenu(last_menu:Id(), 2, false, 0);
    end

    return NilMenu:NilMenu(last_menu:Id())
end

return MenuFactory
