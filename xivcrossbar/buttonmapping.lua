local buttonmapping = {}

function buttonmapping:write()
    windower.send_command('[XIVCrossbar] here')
    if (not self:validate()) then
        windower.send_command('[XIVCrossbar] here too')
        return false
    end

    local output_file = file.new('config.ini')
    local output_string = '[ButtonMap]\n'

    output_string = output_string .. 'ButtonLayout=' .. buttonmapping.button_layout:upper() .. '\n'
    output_string = output_string .. 'ConfirmButton=' .. buttonmapping.confirm_button:upper() .. '\n'
    output_string = output_string .. 'CancelButton=' .. buttonmapping.cancel_button:upper() .. '\n'
    output_string = output_string .. 'MainMenuButton=' .. buttonmapping.mainmenu_button:upper() .. '\n'
    output_string = output_string .. 'ActiveWindowButton=' .. buttonmapping.activewindow_button:upper() .. '\n'

    windower.send_command('[XIVCrossbar] output_string = ' .. output_string)

    local status, error_msg = output_file:write(output_string, true)
    if (status ~= nil) then
        return true
    else
        windower.send_command('[XIVCrossbar] ' .. error_msg)
        return false
    end
end

function buttonmapping:read()
    local input_file = file.new('config.ini')

    if (input_file:exists()) then
        local button_mappings_raw = input_file:read() .. '\n'

        for match in button_mappings_raw:lower():gmatch("buttonlayout=(.-)\n") do
            buttonmapping.button_layout = match
        end
        for match in button_mappings_raw:lower():gmatch("confirmbutton=(.-)\n") do
            buttonmapping.confirm_button = match
        end
        for match in button_mappings_raw:lower():gmatch("cancelbutton=(.-)\n") do
            buttonmapping.cancel_button = match
        end
        for match in button_mappings_raw:lower():gmatch("mainmenubutton=(.-)\n") do
            buttonmapping.mainmenu_button = match
        end
        for match in button_mappings_raw:lower():gmatch("activewindowbutton=(.-)\n") do
            buttonmapping.activewindow_button = match
        end
    end
end

function buttonmapping:validate()
    local button_layout_correct = buttonmapping.button_layout == 'gamecube' or
        buttonmapping.button_layout == 'xbox' or
        buttonmapping.button_layout == 'playstation' or
        buttonmapping.button_layout == 'nintendo'

    local confirm_button_correct = false
    if (buttonmapping.button_layout == 'playstation') then
        confirm_button_correct = buttonmapping.confirm_button == 'cross' or
            buttonmapping.confirm_button == 'circle' or
            buttonmapping.confirm_button == 'square' or
            buttonmapping.confirm_button == 'triangle'
    else
        confirm_button_correct = buttonmapping.confirm_button == 'a' or
            buttonmapping.confirm_button == 'b' or
            buttonmapping.confirm_button == 'x' or
            buttonmapping.confirm_button == 'y'
    end

    local cancel_button_correct = false
    if (buttonmapping.button_layout == 'playstation') then
        cancel_button_correct = buttonmapping.cancel_button == 'cross' or
            buttonmapping.cancel_button == 'circle' or
            buttonmapping.cancel_button == 'square' or
            buttonmapping.cancel_button == 'triangle'
    else
        cancel_button_correct = buttonmapping.cancel_button == 'a' or
            buttonmapping.cancel_button == 'b' or
            buttonmapping.cancel_button == 'x' or
            buttonmapping.cancel_button == 'y'
    end

    local mainmenu_button_correct = false
    if (buttonmapping.button_layout == 'playstation') then
        mainmenu_button_correct = buttonmapping.mainmenu_button == 'cross' or
            buttonmapping.mainmenu_button == 'circle' or
            buttonmapping.mainmenu_button == 'square' or
            buttonmapping.mainmenu_button == 'triangle'
    else
        mainmenu_button_correct = buttonmapping.mainmenu_button == 'a' or
            buttonmapping.mainmenu_button == 'b' or
            buttonmapping.mainmenu_button == 'x' or
            buttonmapping.mainmenu_button == 'y'
    end

    local activewindow_button_correct = false
    if (buttonmapping.button_layout == 'playstation') then
        activewindow_button_correct = buttonmapping.activewindow_button == 'cross' or
            buttonmapping.activewindow_button == 'circle' or
            buttonmapping.activewindow_button == 'square' or
            buttonmapping.activewindow_button == 'triangle'
    else
        activewindow_button_correct = buttonmapping.activewindow_button == 'a' or
            buttonmapping.activewindow_button == 'b' or
            buttonmapping.activewindow_button == 'x' or
            buttonmapping.activewindow_button == 'y'
    end

    return button_layout_correct and confirm_button_correct and cancel_button_correct and mainmenu_button_correct and activewindow_button_correct
end

buttonmapping:read()

return buttonmapping
