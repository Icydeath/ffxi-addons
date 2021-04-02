require("lists")
require("tables")
texts = require('texts')
images = require('images')

local selectable_list = {}

local BORDER_PADDING = 10
local COLUMN_WIDTH = 170
local ROW_HEIGHT = 50

function selectable_list:setup(theme_options, base_x, base_y, max_width, max_height)
    self.theme_options = theme_options
    self.frame_image_path = windower.addon_path..'/themes/' .. (theme_options.frame_theme:lower()) .. '/frame.png'
    self.base_x = base_x or 150
    self.base_y = base_y or 150
    local temp_width = max_width or (windower.get_windower_settings().ui_x_res - 300)
    local temp_height = max_height or (windower.get_windower_settings().ui_y_res - 300)
    self.max_row = math.floor((temp_height - 2 * BORDER_PADDING) / ROW_HEIGHT)
    self.max_col = math.floor((temp_width - 2 * BORDER_PADDING) / COLUMN_WIDTH)
    self.width = 2 * BORDER_PADDING + self.max_col * COLUMN_WIDTH
    self.height = 2 * BORDER_PADDING + self.max_row * ROW_HEIGHT
    self.fields = L{}
    self.field_coords = {}
    self.selected_row = 1
    self.selected_col = 1
    self.images = L{}
    self.current_page = 1
    self.is_prev_button_showing = false
    self.is_next_button_showing = false

    windower.prim.create('selectablelist_selection_highlight')
    windower.prim.set_color('selectablelist_selection_highlight', 255, 171, 252, 252)
    windower.prim.set_position('selectablelist_selection_highlight', 0, 0)
    windower.prim.set_size('selectablelist_selection_highlight', COLUMN_WIDTH, ROW_HEIGHT)
    windower.prim.set_visibility('selectablelist_selection_highlight', false)

    windower.prim.create('prev_page_button')
    windower.prim.set_color('prev_page_button', 200, 0, 0, 0)
    windower.prim.set_position('prev_page_button', 0, 0)
    windower.prim.set_size('prev_page_button', COLUMN_WIDTH, ROW_HEIGHT)
    windower.prim.set_visibility('prev_page_button', false)

    windower.prim.create('next_page_button')
    windower.prim.set_color('next_page_button', 200, 0, 0, 0)
    windower.prim.set_position('next_page_button', 0, 0)
    windower.prim.set_size('next_page_button', COLUMN_WIDTH, ROW_HEIGHT)
    windower.prim.set_visibility('next_page_button', false)
end

function selectable_list:reset_state()
    self.is_showing = false
    self.current_page = 1
    self.current_options = L{}
    windower.prim.set_visibility('prev_page_button', false)
    windower.prim.set_visibility('next_page_button', false)
    for index, field in ipairs(self.fields) do
        field:hide()
    end
    for index, image in ipairs(self.images) do
        image:hide()
    end
    self.fields = L{}
    self.field_coords = {}
    self.selected_row = 1
    self.selected_col = 1
end

function selectable_list:export_selection_state()
    return {page = self.current_page, row = self.selected_row, col = self.selected_col}
end

function selectable_list:import_selection_state(selection_state)
    self.current_page = selection_state.page
    self.selected_row = selection_state.row
    self.selected_col = selection_state.col
    self:highlight_selection()
end

function selectable_list:set_page(page)
    self.current_page = page
end

function selectable_list:increment_page()
    self.current_page = self.current_page + 1
    self:display_options(self.current_options)
    if (self.is_next_button_showing) then
        self.selected_row = self.max_row + 1
        self.selected_col = self.max_col
        self:highlight_selection()
    else
        self.selected_row = self.max_row + 1
        self.selected_col = 1
        self:highlight_selection()
    end
end

function selectable_list:decrement_page()
    self.current_page = self.current_page - 1
    self:display_options(self.current_options)
    if (self.is_prev_button_showing) then
        self.selected_row = self.max_row + 1
        self.selected_col = 1
        self:highlight_selection()
    else
        self.selected_row = self.max_row + 1
        self.selected_col = self.max_col
        self:highlight_selection()
    end
end

function selectable_list:increment_row()
    local new_row = self.selected_row + 1
    if (self.field_coords[self.selected_col][new_row] ~= nil) then
        self.selected_row = new_row
        self:highlight_selection()
    elseif (self.field_coords[self.selected_col][self.max_row + 1] ~= nil) then
        -- handling the "Previous Page" button
        self.selected_row = self.max_row + 1
        self:highlight_selection()
    end
end

function selectable_list:decrement_row()
    local new_row = self.selected_row - 1
    if (self.field_coords[self.selected_col][new_row] ~= nil) then
        self.selected_row = new_row
        self:highlight_selection()
    elseif (self.field_coords[self.selected_col][self.selected_row].id == 'PREV') then
        -- handling jumping from the "Previous Page" button to the last row with entries
        while (self.field_coords[self.selected_col][new_row] == nil) do
            new_row = new_row - 1
        end
        self.selected_row = new_row
        self:highlight_selection()
    end
end

function selectable_list:increment_col()
    local new_col = self.selected_col + 1
    if (self.field_coords[new_col] ~= nil and self.field_coords[new_col][self.selected_row] ~= nil) then
        self.selected_col = new_col
        self:highlight_selection()
    elseif (self.field_coords[self.selected_col][self.selected_row].id == 'PREV' and self.is_next_button_showing) then
        -- handle "jumping" from the Previous Page button to the Next Page button
        self.selected_col = self.max_col
        self:highlight_selection()
    end
end

function selectable_list:decrement_col()
    local new_col = self.selected_col - 1
    if (self.field_coords[new_col] ~= nil and self.field_coords[new_col][self.selected_row] ~= nil) then
        self.selected_col = new_col
        self:highlight_selection()
    elseif (self.field_coords[self.selected_col][self.selected_row].id == 'NEXT' and self.is_prev_button_showing) then
        -- handle "jumping" from the Next Page button to the Previous Page button
        self.selected_col = 1
        self:highlight_selection()
    end
end

function selectable_list:hide()
    self.is_showing = false
    windower.prim.set_visibility('selectablelist_selection_highlight', false)
    windower.prim.set_visibility('prev_page_button', false)
    windower.prim.set_visibility('next_page_button', false)
    for index, field in ipairs(self.fields) do
        field:hide()
    end
    for index, image in ipairs(self.images) do
        image:hide()
    end
end

function selectable_list:show()
end

function selectable_list:create_text(text_string, row, col)
    local text = texts.new({flags = {draggable = false}})
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(self.theme_options.font)
    text:size(self.theme_options.font_size + 2)
    text:color(self.theme_options.font_color_red, self.theme_options.font_color_green, self.theme_options.font_color_blue)
    text:stroke_transparency(self.theme_options.font_stroke_alpha)
    text:stroke_color(self.theme_options.font_stroke_color_red, self.theme_options.font_stroke_color_green, self.theme_options.font_stroke_color_blue)
    text:stroke_width(self.theme_options.font_stroke_width)

    local x, y = self:get_pos(row, col)
    text:pos(x + 50, y + 18)
    text:text(text_string)
    text:show()
    return text
end

function selectable_list:highlight_selection()
    local x, y = self:get_pos(self.selected_row, self.selected_col)
    windower.prim.set_position('selectablelist_selection_highlight', x, y)
    windower.prim.set_visibility('selectablelist_selection_highlight', true)
end

function selectable_list:draw_prev_page_button(row, col)
    local x, y = self:get_pos(row, col)
    windower.prim.set_position('prev_page_button', x, y)
    windower.prim.set_visibility('prev_page_button', true)
end

function selectable_list:draw_next_page_button(row, col)
    local x, y = self:get_pos(row, col)
    windower.prim.set_position('next_page_button', x, y)
    windower.prim.set_visibility('next_page_button', true)
end

function selectable_list:get_pos(row, col)
    local x = self.base_x + BORDER_PADDING + (col - 1) * COLUMN_WIDTH
    local y = self.base_y + BORDER_PADDING + (row - 1) * ROW_HEIGHT
    return x, y
end

function selectable_list:get_row_col_from_pos(x, y)
    local row = math.floor((y - (self.base_y + BORDER_PADDING)) / ROW_HEIGHT) + 1
    local col = math.floor((x - (self.base_x + BORDER_PADDING)) / COLUMN_WIDTH) + 1
    return row, col
end

function selectable_list:get_row_col(index)
    local row = math.ceil((index + 1) / self.max_col)
    local col = (index % self.max_col) + 1
    return row, col
end

function selectable_list:display_options(options)
    local current_page = self.current_page
    self:reset_state()
    self.is_showing = true
    self.current_options = options
    self.current_page = current_page
    local first_row = (self.current_page - 1) * self.max_row + 1
    local last_row = self.current_page * self.max_row
    local entries_to_skip = (self.current_page - 1) * self.max_row * self.max_col + 1

    local newlines = 0
    local col_offset = 0

    local count = 0
    for i, value in ipairs(options) do		
        count = count + 1
        local option_id = value.id
        local option_caption = value.name

        local data = value.data

        local abs_row, abs_col = self:get_row_col(i - 1)
        if (first_row <= abs_row and abs_row <= last_row) then
            local row, col = self:get_row_col(i - entries_to_skip)
            row = row + newlines
            if (option_caption == 'newline') then
                newlines = newlines + 1
                col_offset = col % self.max_col
            else
                col = col - col_offset
                if (row == self.selected_row and col == self.selected_col) then
                    self:highlight_selection()
                end
                self.fields:append(self:create_text(option_caption, row, col))

                local icon = images.new({draggable = false})
                local icon_path = windower.addon_path .. '/images/' .. value.icon
                local x, y = self:get_pos(row, col)
                x = x + 5
                y = y + 5
                setup_image(icon, icon_path)
                local icon_offset = value.icon_offset or 0
                icon:pos(x + icon_offset, y + icon_offset)
                self.images:append(icon)

                local frame = images.new({draggable = false})
                setup_image(frame, self.frame_image_path)
                frame:pos(x, y)
                self.images:append(frame)

                -- populate the "collision" map for dpad navigation
                local field_col = self.field_coords[col] or {}
				if data and data.target_type['None'] then
					if value.icon:contains('home-point') or value.icon:contains('survival-guide') then
						local splat = value.icon:split('/')
						local last = #splat
						local icon_name = splat[last]
						if icon_name then icon_name = icon_name:gsub('.png','') end
						field_col[row] = {['id'] = option_id, ['text'] = option_caption, ['data'] = data, ['icon'] = icon_name}
					else
						field_col[row] = {['id'] = option_id, ['text'] = option_caption, ['data'] = data, ['icon'] = value.name}
					end
				else
					field_col[row] = {['id'] = option_id, ['text'] = option_caption, ['data'] = data}
				end
                self.field_coords[col] = field_col
            end
        end
    end

    if (count > self.current_page * self.max_row * self.max_col) then
        self.is_next_button_showing = true
        local row = self.max_row + 1
        local col = self.max_col

        -- display "next" button
        self.fields:append(self:create_text('Next Page', row, col))
        if (row == self.selected_row and col == self.selected_col) then
            windower.prim.set_visibility('next_page_button', false)
            self:highlight_selection()
        else
            self:draw_next_page_button(row, col)
        end

        -- populate the "collision" map for dpad navigation
        local field_col = self.field_coords[self.max_col] or {}
        field_col[row] = {['id'] = 'NEXT', ['text'] = 'Next Page'}
        self.field_coords[col] = field_col
    else
        self.is_next_button_showing = false
    end

    if (self.current_page > 1) then
        self.is_prev_button_showing = true
        local row = self.max_row + 1
        local col = 1

        -- display "prev" button
        self.fields:append(self:create_text('Previous Page', row, col))
        if (row == self.selected_row and col == self.selected_col) then
            windower.prim.set_visibility('prev_page_button', false)
            self:highlight_selection()
        else
            self:draw_prev_page_button(row, col)
        end

        -- populate the "collision" map for dpad navigation
        local field_col = self.field_coords[col] or {}
        field_col[row] = {['id'] = 'PREV', ['text'] = 'Previous Page'}
        self.field_coords[col] = field_col
    else
        self.is_prev_button_showing = false
    end
end

function selectable_list:submit_selected_option()
    local option = self.field_coords[self.selected_col][self.selected_row]
    if (option.id ~= 'PREV' and option.id ~= 'NEXT') then
        self:hide()
        self:reset_state()
    end
    return option
end

function selectable_list:is_valid_row_col(row, col)
    return selectable_list.field_coords and selectable_list.field_coords[col] ~= nil and selectable_list.field_coords[col][row] ~= nil
end

function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:alpha(255)
    image:show()
end

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    if (selectable_list.is_showing) then
        -- Mouse drag (0) or left click (1)
        if (type == 0 or type == 1) then
            local row, col = selectable_list:get_row_col_from_pos(x, y)
            if (selectable_list:is_valid_row_col(row, col)) then
                selectable_list.selected_row = row
                selectable_list.selected_col = col
                selectable_list:highlight_selection()
                return true
            end
        -- Mouse left release
        elseif type == 2 then
        end
    end
end)

return selectable_list
