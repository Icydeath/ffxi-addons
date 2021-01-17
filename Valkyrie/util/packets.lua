local Packets = require('packets')

local last_packets = {}
local tracking = {[0x034] = true, [0x032] = true, [0x05C] = true, [0x052] = true, [0x036] = true, [0x02A] = true}

--------------------------------------------------------------------------------
-- Interprets a section of data as a number.
--
-- param [in] dat_string - The data to interpret.
-- param [in] start      - The index of the first bit to interpret.
-- param [in] stop       - The index of the last bit to interpret.
--
-- Returns the interpreted number.
--
function Packets.get_bit_packed(dat_string, start, stop)
    -- Copied from Battlemod
    local newval = 0
    local c_count = math.ceil(stop/8)
    while c_count >= math.ceil((start+1)/8) do
        local cur_val = dat_string:byte(c_count)
        local scal = 256
        if c_count == math.ceil(stop/8) then
            cur_val = cur_val%(2^((stop-1)%8+1))
        end
        if c_count == math.ceil((start+1)/8) then
            cur_val = math.floor(cur_val/(2^(start%8)))
            scal = 2^(8-start%8)
        end
        newval = newval*scal + cur_val
        c_count = c_count - 1
    end
    return newval
end

--------------------------------------------------------------------------------
function Packets.is_duplicate(id, pkt)
    if tracking[id] then
        local pid = Packets.get_bit_packed(pkt, 0, 32)
        if last_packets[id] and last_packets[id] == pid then
            return true
        end
        last_packets[id] = pid
    end
    return false
end

return Packets