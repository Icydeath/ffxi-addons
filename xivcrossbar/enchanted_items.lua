local enchanted_items = {}

-- Register an enchanted item for future use
function enchanted_items:register(name, warmup, use_time, cooldown)
    if (self.items == nil) then
        self.items = {}
    end

    self.items[name] = {}
    self.items[name]['warmup'] = warmup
    self.items[name]['last_equip_time'] = nil
    self.items[name]['use_time'] = use_time
    self.items[name]['last_use_time'] = nil
    self.items[name]['cooldown'] = cooldown
end

-- Mark an enchanted item as equipped
function enchanted_items:equip(name)
    local item = self.items[name]
    if item ~= nil then
        item.last_equip_time = os.time()
    end
end

-- Get % of warmup time that has passed
function enchanted_items:get_warmup_fraction(name)
    local item = self.items[name]
    if item ~= nil and item.last_equip_time ~= nil then
        local seconds_elapsed = os.time() - item.last_equip_time
        local fraction = seconds_elapsed / item.warmup
        if fraction > 1 then
            return 1
        else
            return fraction
        end
    else
        return 0
    end
end

-- Get the warmup time in seconds
function enchanted_items:get_warmup_time(name)
    local item = self.items[name]
    if item ~= nil then
        return item.warmup
    end
end

-- Mark an enchanted item as used
function enchanted_items:use(name)
    local item = self.items[name]
    if item ~= nil then
        item.last_use_time = os.time() + item.use_time
    end
end

-- Get % of cooldown time that still needs to pass
function enchanted_items:get_cooldown_fraction(name)
    local item = self.items[name]
    if item ~= nil then
        if item.last_use_time ~= nil then
            local seconds_elapsed = os.time() - item.last_use_time
            local fraction = 1 - seconds_elapsed / item.cooldown
            if fraction > 1 then
                return 1
            elseif fraction < 0 then
                return 0
            else
                return fraction
            end
        else
            return 0
        end
    else
        return 1
    end
end

-- Get the cooldown time in seconds
function enchanted_items:get_cooldown_time(name)
    local item = self.items[name]
    if item ~= nil then
        return item.cooldown
    end
end

return enchanted_items