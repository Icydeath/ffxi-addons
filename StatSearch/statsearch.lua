_addon.name = 'Statsearch'
_addon.author = 'Lili'
_addon.version = '0.0.8'
_addon.command = 'statsearch'

require('logger')
local extdata = require('extdata')
local res = require('resources')

local lang
local jobs

local work = function(str, job)
    log('Searching gear with:',str)
    local results = {}
    
    job = job or windower.ffxi.get_player().main_job_id
    
    for i,bag in pairs(res.bags) do

        local items = windower.ffxi.get_items(bag.id)
        
        for _,item in pairs(items) do
            if type(item) == 'table' and item.id and item.id > 0 and res.items[item.id].flags['Equippable'] and res.items[item.id].jobs:contains(job) then
                local match = false
                local item_desc = res.item_descriptions[item.id] and res.item_descriptions[item.id][lang]:gsub('\n',' '):lower() or ' '
                if item_desc:find(str) then
                    match = true
                else
                    local augments = extdata.decode(item).augments
                    if type(augments) == 'table' then
                        for _,v in pairs(augments) do
                            if v and v:lower():find(str) then
                                match = true
                                break
                            end
                        end
                    end
                end
                if match then
                    if not results[bag.name] then 
                        results[bag.name] = T{}
                    end
                    results[bag.name]:append(res.items[item.id].name)                
                end
            end
        end
    end
    for i,v in pairs(results) do
        log('Found in', i)
        for _,j in ipairs(v) do
            log('\t',j)
        end
    end
end

windower.register_event('load',function()
    lang = windower.ffxi.get_info().language:lower()
    jobs = {}
    for i,v in pairs(res.jobs) do
        if i ~= 23 then --monipulator
            local short = v[lang.."_short"]:lower()
            local long = v[lang]:lower()
            local id = v.id
            jobs[short] = id
            jobs[long] = id
        end
    end
end)

windower.register_event('addon command', function(...)
    local args = T{...}
    
    if not args[1] or args[1] == 'help' then
        log('//statsearch [job] <string>')
        log('Finds all items equippable by your current job (or job provided in command) that have <string> in their description or augments.')
        return
    elseif args[1] == 'r' then
        windower.send_command('lua r statsearch')
        return
    elseif args[1] and jobs[args[1]:lower()] then
        work(args:slice(2):concat(' '):lower(), jobs[args[1]:lower()])
        return
    end
    
    work(args:concat(' '):lower())
end)