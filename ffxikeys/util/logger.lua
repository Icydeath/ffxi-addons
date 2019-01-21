local Resources = require('resources')

--------------------------------------------------------------------------------
local function CreateHeader(time, count)
    local dt = os.date('%m/%d/%Y - %H:%M:%S', time)
    local sc = string.format('%03d', count)
    local header = '\n'
    header = header .. '//////////////////////////////////////\n'
    header = header .. '// ' .. dt .. ' - ' .. sc .. ' Keys //\n'
    header = header .. '//////////////////////////////////////\n'
    return header
end

--------------------------------------------------------------------------------
local function CreateLine(time, item)
    local dt = os.date('[%H:%M:%S]', time)
    return dt .. ' ' .. tostring(item) .. '\n'
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Logger = {}
Logger.items = {}

--------------------------------------------------------------------------------
function Logger.AddItem(item_id)
    local item = Resources.items:with('id', item_id)
    if item then
        table.insert(Logger.items, { time = os.time(), text = item.en })
    else
        log('Unable to find an item with id: ' .. tostring(item_id))
    end
end

--------------------------------------------------------------------------------
function Logger.Flush()
    if #Logger.items > 0 then
        local file = io.open(windower.addon_path .. '/data/items.log', 'a+')
        file:write(CreateHeader(Logger.items[1].time, #Logger.items))
        for _, value in pairs(Logger.items) do
            file:write(CreateLine(value.time, value.text))
        end
        file:close()
    end
    Logger.items = {}
end

return Logger
