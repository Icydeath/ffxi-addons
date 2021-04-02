res = require('resources')
local bags = {'Sack','Case','Satchel'}
local folder_path = windower.windower_path .. '/scripts/export_items/'

if not windower.dir_exists(folder_path) then
    windower.create_dir(folder_path)
end

local make_file = io.open(folder_path .. 'export_items.lua', 'w')

make_file:write('return {\n')

for _,bag in pairs(bags) do
    make_file:write('    %s = {\n':format(bag:lower()))
    for index, item in ipairs(windower.ffxi.get_items(bag)) do
        if item and item.id ~= 0 then
            make_file:write('        %s,\n':format(res.items[item.id].name))
        end
    end
    make_file:write('    },')
end

make_file:write('}\n')
make_file:close()
