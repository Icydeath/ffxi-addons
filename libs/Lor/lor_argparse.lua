--[[
    Functions for parsing key, value pairs from user input.
    
    I am working on a clone of Python's argparse as well, but that is not included here.
    
    Author: Ragnarok.Lorand
--]]

local lor_argparse = {}
lor_argparse._author = 'Ragnarok.Lorand'
lor_argparse._version = '2016.09.24.0'

require('lor/lor_utils')


function lor_argparse.extract_kvpairs(args, do_lower)
    if do_lower == nil then do_lower = true end
    local kv_pairs = {}
    for i = 1, #args do
        if args[i]:startswith('-') then
            local k = args[i]:match('^%-*(.+)')
            k = do_lower and k:lower() or k
            if args[i+1] == nil or args[i+1]:startswith('-') then
                kv_pairs[k] = true
            else
                kv_pairs[k] = args[i+1]
                i = i + 1
            end
        end
    end
    return kv_pairs
end


function lor_argparse.parse_kvargs(defaults, ...)
    local args = {...}
    local params = {}
    for i = 1, #defaults do
        local k, v
        for _k, _v in pairs(defaults[i]) do --There should only be one k,v pair per default
            k, v = _k, _v
        end
        
        --Done this way to prevent conflicts if values/defaults are boolean
        if args[i] ~= nil then
            params[k] = args[i]
        elseif args[k] ~= nil then
            params[k] = args[k]
        else
            params[k] = v
        end
    end
    
    --Catch any other kvargs that weren't specified in defaults
    for k, v in pairs(args) do
        if params[k] == nil then
            params[k] = v
        end
    end
    return params
end


--[[
    Wrapper to specify deault parameters for a function
--]]
function lor_argparse.param_func(arg_defaults, fn)
    return function(...)
        local args = {...}
        local params = {}
        for i = 1, #arg_defaults do
            local k, v
            for _k, _v in pairs(arg_defaults[i]) do --There should only be one k,v pair per arg_default
                k, v = _k, _v
            end
            params[i] = args[i] or args[k] or v
        end
        return fn(unpack(params, 1, #arg_defaults))
    end
end

return lor_argparse