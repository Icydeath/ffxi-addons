_addon.name = 'PacketViewer'
_addon.author = 'Arcon'
_addon.command = 'packetviewer'
_addon.commands = {'pv'}
_addon.version = '1.0.0.0'

require('luau')
texts = require('texts')
files = require('files')
packets = require('packets')
chat = require('chat')

defaults = {}
defaults.tracker = {}
defaults.tracker.pos = {}
defaults.tracker.pos.x = 0
defaults.tracker.pos.y = 0
defaults.tracker.text = {}
defaults.tracker.text.font = 'Consolas'
defaults.tracker.text.size = 10
defaults.tracker.text.alpha = 255
defaults.tracker.text.red = 255
defaults.tracker.text.green = 255
defaults.tracker.text.blue = 255
defaults.tracker.bg = {}
defaults.tracker.bg.alpha = 192
defaults.tracker.bg.red = 0
defaults.tracker.bg.green = 0
defaults.tracker.bg.blue = 0
defaults.tracker.padding = 5
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.size = 10
defaults.display.text.alpha = 255
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.bg = {}
defaults.display.bg.alpha = 192
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.padding = 5

defaults.Mode = 'hybrid'
defaults.Show = {}
defaults.Show.Known = true
defaults.Show.Unknown = true
defaults.Show.Junk = true
defaults.CheckConst = true
defaults.LogChat = true
defaults.LogFields = false
defaults.LogTimestamp = true

settings = config.load(defaults)

mode_strings = T{
    known   = 'known',
    unknown = 'unknown',
    hybrid  = 'hybrid',
    both    = 'hybrid',
    k       = 'known',
    u       = 'unknown',
    h       = 'hybrid',
    b       = 'hybrid',
}

output_strings = T{
    console = 'console',
    chatlog = 'chatlog',
    log     = 'chatlog',
    file    = 'file',
    con     = 'console',
    c       = 'console',
    l       = 'chatlog',
    f       = 'file',
}

direction_strings = T{
    incoming    = 'incoming',
    ['in']      = 'incoming',
    i           = 'incoming',
    outgoing    = 'outgoing',
    out         = 'outgoing',
    o           = 'outgoing',
    both        = 'both',
    b           = 'both',
    all         = 'both',
    a           = 'both',
}

colors = {}
colors['hexborder'] =   '\\cs(0,255,0)'
colors['gray'] =        '\\cs(102,102,102)'
colors[0] =             '\\cs(204,204,0)'
colors[1] =             '\\cs(51,153,255)'
colors[2] =             '\\cs(51,255,153)'
colors[3] =             '\\cs(153,51,255)'
colors[4] =             '\\cs(255,51,153)'
colors[5] =             '\\cs(153,255,51)'
colors[6] =             '\\cs(255,153,51)'
colors[7] =             '\\cs(255,255,102)'
colors[8] =             '\\cs(255,102,255)'
colors[9] =             '\\cs(102,255,255)'
colors[10] =            '\\cs(102,102,255)'
colors[11] =            '\\cs(102,255,102)'
colors[12] =            '\\cs(255,102,102)'
colors[13] =            '\\cs(255,204,153)'
colors[14] =            '\\cs(204,255,153)'
colors[15] =            '\\cs(255,153,204)'
colors[16] =            '\\cs(153,204,255)'
colors[17] =            '\\cs(204,153,255)'
colors[18] =            '\\cs(153,255,204)'

byte_colors = list.range(0x200, '\\cr')
byte_colors[1] = colors.gray
byte_colors[2] = colors.gray
byte_colors[3] = colors.gray
byte_colors[4] = colors.gray

in_set = S{'i', 'in', 'incoming'}
out_set = S{'o', 'out', 'outgoing'}

-- Create files for output
file = T{}
file.full = files.new('data/logs/full.log', true)
file.incoming = files.new('data/logs/incoming.log', true)
file.outgoing = files.new('data/logs/outgoing.log', true)

-- Text box setup
text_base_string = L{
    'ID:   ${_id|-} (${_hexid|0xXXX})    Name:     ${_name|-}',
    'Size: ${_size|-} bytes${_display_padding|  }    Received: ${_time|-}',
    '',
    '${_hextable}'
    }:concat('\n')
display_base_string = L{
    'ID:   ${_id|-} (${_hexid|0xXXX})    Name:     ${_name|-}',
    'Size: ${_size|-} bytes${_display_padding|  }    Received: ${_time|-}',
    '\\cs(255,0,0)#${_current}/#${_total}\\cr',
    '${_hextable}'
    }:concat('\n')

tracker = texts.new(text_base_string, settings.tracker, settings)
display = texts.new(display_base_string, settings.display, settings)

-- Running data
tracking = T{
    incoming = S{},
    outgoing = S{},
}
logging = T{}
scan = T{
    active = true,
    mode = 'unknown',
    value = nil,
}

saved_packets = L{}

function cap(val, min, max)
    return val > max and max or val < min and min or val
end

-- Scroll through display packets
windower.register_event('mouse', function(type, x, y, delta)
    if type == 10 and display:hover(x, y) then
        local index = cap(displayed - delta, 1, saved_packets.n)
        display_packet(index)
    end
end)

do
    -- Precompute hex string tables for lookups, instead of constant computation.
    local top_row = ('    |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF\n' .. '-':rep((16+1)*3 + 2) .. '  ' .. '-':rep(16 + 6) .. '\n'):enclose(colors['hexborder'], '\\cr')

    local chars = {}
    for i = 0x00, 0xFF do
        if i >= 0x20 and i < 0x7F then
            chars[i] = i:char()
        else
            chars[i] = '.'
        end
    end
    chars[0x5C] = '\\\\'
    chars[0x25] = '%%'

    local line_replace = {}
    for i = 0x01, 0x10 do
        line_replace[i] = colors.hexborder .. '%%%%3X |' .. ' %%s%.2X':rep(i) .. colors.gray .. ' --':rep(0x10 - i) .. colors.hexborder .. '  %%%%3X | ' .. '%%%%%%%%s\n'
    end
    local short_replace = {}
    for i = 0x01, 0x10 do
        short_replace[i] = '%%s%s':rep(i) .. (i < 0x10 and colors.gray .. '-':rep(0x10 - i) or '')
    end

    -- Receives a byte string and returns a table-formatted string with 16 columns.
    string.hexformat = function(str)
        local length = #str
        local str_table = {}
        local from = 1
        local to = 16
        for i = 0, ((length - 1)/0x10):floor() do
            local partial_str = {str:byte(from, to)}
            local partial_col = byte_colors:slice(from, to)
            local char_table = {
                [0x01] = chars[partial_str[0x01]],
                [0x02] = chars[partial_str[0x02]],
                [0x03] = chars[partial_str[0x03]],
                [0x04] = chars[partial_str[0x04]],
                [0x05] = chars[partial_str[0x05]],
                [0x06] = chars[partial_str[0x06]],
                [0x07] = chars[partial_str[0x07]],
                [0x08] = chars[partial_str[0x08]],
                [0x09] = chars[partial_str[0x09]],
                [0x0A] = chars[partial_str[0x0A]],
                [0x0B] = chars[partial_str[0x0B]],
                [0x0C] = chars[partial_str[0x0C]],
                [0x0D] = chars[partial_str[0x0D]],
                [0x0E] = chars[partial_str[0x0E]],
                [0x0F] = chars[partial_str[0x0F]],
                [0x10] = chars[partial_str[0x10]],
            }
            local bytes = (length - from + 1):min(16)
            str_table[i + 1] = line_replace[bytes]
                :format(unpack(partial_str))
                :format(partial_col:unpack())
                :format(i, i)
                :format(short_replace[bytes]:format(unpack(char_table))
                :format(partial_col:unpack()))
            from = to + 1
            to = to + 0x10
        end
        return '%s%s\\cr':format(top_row, table.concat(str_table))
    end
end

do
    -- Precompute hex string tables for lookups, instead of constant computation.
    local top_row = '        |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF\n    ' .. '-':rep((16+1)*3 + 2) .. '  ' .. '-':rep(16 + 6) .. '\n'

    local chars = {}
    for i = 0x00, 0xFF do
        if i >= 0x20 and i < 0x7F then
            chars[i] = i:char()
        else
            chars[i] = '.'
        end
    end
    chars[0x5C] = '\\\\'
    chars[0x25] = '%%'

    local line_replace = {}
    for i = 0x01, 0x10 do
        line_replace[i] = '    %%%%3X |' .. ' %.2X':rep(i) .. ' --':rep(0x10 - i) .. '  %%%%3X | ' .. '%%s\n'
    end
    local short_replace = {}
    for i = 0x01, 0x10 do
        short_replace[i] = '%s':rep(i) .. '-':rep(0x10 - i)
    end

    -- Receives a byte string and returns a table-formatted string with 16 columns.
    string.hexformat_file = function(str, byte_colors)
        local length = #str
        local str_table = {}
        local from = 1
        local to = 16
        for i = 0, ((length - 1)/0x10):floor() do
            local partial_str = {str:byte(from, to)}
            local char_table = {
                [0x01] = chars[partial_str[0x01]],
                [0x02] = chars[partial_str[0x02]],
                [0x03] = chars[partial_str[0x03]],
                [0x04] = chars[partial_str[0x04]],
                [0x05] = chars[partial_str[0x05]],
                [0x06] = chars[partial_str[0x06]],
                [0x07] = chars[partial_str[0x07]],
                [0x08] = chars[partial_str[0x08]],
                [0x09] = chars[partial_str[0x09]],
                [0x0A] = chars[partial_str[0x0A]],
                [0x0B] = chars[partial_str[0x0B]],
                [0x0C] = chars[partial_str[0x0C]],
                [0x0D] = chars[partial_str[0x0D]],
                [0x0E] = chars[partial_str[0x0E]],
                [0x0F] = chars[partial_str[0x0F]],
                [0x10] = chars[partial_str[0x10]],
            }
            local bytes = (length - from + 1):min(16)
            str_table[i + 1] = line_replace[bytes]
                :format(unpack(partial_str))
                :format(short_replace[bytes]:format(unpack(char_table)))
                :format(i, i)
            from = to + 1
            to = to + 0x10
        end
        return '%s%s':format(top_row, table.concat(str_table))
    end
end

-- Returns true if the
function filter_settings(field)
    return field.label:startswith('_junk') and settings.Show.Junk
        or field.label:startswith('_unknown') and settings.Show.Unknown
        or settings.Show.Known
end

-- Main packet tracker handler
-- Gets packet information, displays the packet in the track text box.
function track_packet(dir, id, data, modified, injected, blocked)
    if tracking.once then
        tracking.once = false
    end

    local packet = packets.parse(dir, data)
    if not tracking.filter:empty() then
        for value, key in tracking.filter:it() do
            if packet[key] ~= value then
                return
            end
        end
    end

    local fields = packets.fields(dir, id, data)

    -- Determine colors for the respective bytes.
    -- Only necessary if the fields are different from the previously calculated.
    packet._lines = L{}
    -- Reset display settings.
    tracker:clear()
    packet._lines:append('')

    byte_colors = list.range(#data + 1, '\\cr')
    byte_colors[1] = colors.gray
    byte_colors[2] = colors.gray
    byte_colors[3] = colors.gray
    byte_colors[4] = colors.gray

    tracking.fields = fields

    if fields then
        local pos = 5
        -- Hack to display colors somewhat correctly for bit fields
        local bitoffset = 0
        local coloroffset = 0
        local color = colors[1]

        -- Process individual fields
        for field, index in fields:it() do
            local filter_pass = filter_settings(field)
            local color = filter_pass and colors[index % #colors] or colors.gray

            -- Set the color of the relevant bytes
            local from = (field.index / 8):floor() + 1
            local to = ((field.index + field.length) / 8):ceil()
            for i = from, to do
                if byte_colors[i] == '\\cr' then
                    byte_colors[i] = color
                end
            end
            byte_colors[to + 1] = '\\cr'

            -- Add the line to the tracker
            if filter_pass then
                packet._lines:append('%s: %s${%s|-}%s\\cr':format(field.label, color, field.label, (field.fn and '${_f_%s}':format(field.label) or '')))
            end
        end

        -- Check for const violations
        if settings.CheckConst then
            for field in fields:it() do
                if field.const and field.const ~= packet[field.label] then
                    print('Const violation found in %s packet 0x%.3X, field %s: %s ≠ %s':format(packet._dir, packet._id, field.label, tostring(packet[field.label]), tostring(field.const)))
                end
            end
        end

        for field in fields:filter(filter_settings):filter(boolean._exists .. table.get-{'fn'}):it() do
            local val = field.fn(packet[field.label], packet._raw)
            if val ~= nil then
                packet['_f_' .. field.label] = ' (' .. tostring(val) .. ')'
            end
        end

        for field in fields:filter(filter_settings):filter(string.startswith-{'data'} .. table.get-{'ctype'}):it() do
            packet[field.label] = '…'
        end
    end

    for line in packet._lines:it() do
        tracker:append('\n' .. line)
    end

    tracking.byte_colors = byte_colors
    if not tracking.byte_colors then
        tracking.byte_colors = list.range(4, colors['gray'])
    end

    -- Determine various display-related values.
    packet._hexid = '0x%.3X':format(id)
    packet._hextable = packet._raw:hexformat(tracking.byte_colors) -- The fully colored hex table

    packet._display_padding = ' ':rep(packet._id:log(10):floor() - packet._size:log(10):floor() + 2)
    packet._time = os.date('%H:%M:%S')

    tracker:update(packet)

    if recording then
        saved_packets:append(packet)
        if display:visible() then
            display_packet(displayed)
        end
    end
end

-- Main packet logger handler
-- Gets packet data and decides whether and where to log it.
do
    local mods = {
        [true] = {
            [true] = ' (Injected, Blocked)',
            [false] = ' (Injected)',
        },
        [false] = {
            [true] = ' (Blocked)',
            [false] = '',
        },
    }
    local dirs = {incoming = 'Incoming', outgoing = 'Outgoing'}

    local header_str = '%s packet 0x%.3X%s:'

    log_packet = function(dir, id, data, modified, injected, blocked)
        local name = packets.data[dir][id].name
        if not force and (logging.mode ~= 'hybrid' and (logging.mode == 'known' and name == 'Unknown' or logging.mode == 'unknown' and name ~= 'Unknown')) then
            return
        end

        local mod_str = mods[injected][blocked]
        local header = header_str:format(dirs[dir], id, mod_str)

        if logging.output == 'chatlog' then
            log(header .. ' ' .. data:hex(' '))
        elseif logging.output == 'console' then
            print(header .. ' ' .. data:hex(' '))
        elseif logging.output == 'file' then
            local hex_data = data:hexformat_file()

            local field_data = ''
            if settings.LogFields then
                local fields = packets.fields(dir, id, data)

                if fields then
                    field_data = '\n'
                    local packet = packets.parse(dir, data)

                    for field in fields:filter(filter_settings):it() do
                        field_data = field_data .. '%s: %s%s\n':format(field.label, tostring(packet[field.label]), field.fn and ' (%s)':format(field.fn(packet[field.label], data)) or '')
                    end
                end
            end

            local timestamp = settings.LogTimestamp and '[%s] ':format(os.date('%Y-%m-%d %X')) or ''
            file.full:append('%s%s\n%s%s\n':format(timestamp, header, hex_data, field_data))
            file[dir]:append('%s%s\n%s%s\n':format(timestamp, 'Packet 0x%.3X%s':format(id, mod_str), hex_data, field_data))
            files.new('data/logs/%s/0x%.3X.log':format(dir, id), true):append('%s%s\n%s%s\n':format(timestamp, mod_str, hex_data, field_data))
        end
    end
end

-- Main packet scanner handler
scan_packet = function(dir, id, data, modified, injected, blocked)
    local mode = packets.raw_fields[dir][id] and 'known' or 'unknown'
    if scan.mode ~= 'hybrid' and scan.mode ~= mode then
        return
    end

    local from, to = data:sub(5):find(scan.value, pos, true)
    if not from then
        return
    end
    from = from + 3

    print('Match found for %s in %s packet %u (0x%.3X) at byte %u (0x%.2X).':format(tostring(scan.value:unpack(scan.pack)), dir, id, id, from, from))
end

-- Called on every packet, both incoming and outgoing. Further filtering done inside based on packet category and mode.
register_packet = function(dir, id, data, modified, injected, blocked)
    -- This part is executed if a certain packet is currently being tracked.
    if tracking.active and tracking[dir]:contains(id) and (tracking.once == nil or tracking.once == true) then
        track_packet(dir, id, data, modified, injected, blocked)
    end

    -- This part is executed if a certain packet matches the current logging critera.
    if logging.output and (logging.direction == 'both' or dir == logging.direction) and logging.filter:contains(id) then
        log_packet(dir, id, data, modified, injected, blocked)
    end

    -- Run the scanner on each packet.
    if scan.active and scan.value then
        scan_packet(dir, id, data, modified, injected, blocked)
    end
end

function display_packet(index)
    if index > saved_packets.n then
        if saved_packets.n == 0 then
            error('No packets recorded.')
        else
            error('Only %u packet%s recorded.':format(saved_packets.n, saved_packets.n > 1 and 's' or ''))
        end

        return
    end

    local packet = saved_packets[index]
    packet._current = index
    packet._total = saved_packets.n

    display:clear()
    for line in packet._lines:it() do
        display:appendline(line)
    end

    display:update(packet)
    display:show()

    displayed = index
end

windower.register_event('incoming chunk', register_packet+{'incoming'})
windower.register_event('outgoing chunk', register_packet+{'outgoing'})

parse_track_command = function(args)
    if args:length() < 2 then
        error('Specify a packet direction and ID to track: //pv track <<i> <ids>|<o> <ids>> [filters ...]')
        return
    end

    local direction = direction_strings[args:remove(1)]
    if not direction then
        error('Specify a packet direction and ID to track: //pv track <<i> <ids>|<o> <ids>> [filters ...]')
        return
    end

    local ids = args:remove(1):split('|')
    if not ids:all(string.number) then
        error('Specify a packet direction and ID to track: //pv track <<i> <ids>|<o> <ids>> [filters ...]')
        return
    end

    tracking[direction] = S(ids:map(string.number))
end

windower.register_event('addon command', function(command, ...)
    command = command or 'help'
    args = L{...}

    if command == 'track' or command == 't' then
        if args[1] == 'stop' or args[1] == 's' then
            tracking = T{
                incoming = S{},
                outgoing = S{},
            }
            tracker:hide()
            return

        elseif args[1] == 'pause' or args[1] == 'p' then
            tracking.active = false
            return

        elseif args[1] == 'resume' or args[1] == 'r' then
            tracking.active = true
            return

        elseif args[1] == 'hide' or args[1] == 'h' then
            tracker:hide()
            return

        elseif args[1] == 'once' then
            tracking.once = true
            args:remove(1)

        end

        repeat
            parse_track_command(args)
        until not direction_strings[args[1]]

        tracking.filter = T{}
        for i = 1, args:length() / 2 do
            local key = args[i]
            local value = args[i + 1]
            value = value:number()
                or value == 'true' and true
                or value ~= 'false' and value
                or false
            tracking.filter[key] = value
        end

        tracker:clear()
        tracker:show()

        tracking.active = true

    elseif command == 'eval' or command == 'e' then
        assert(loadstring(L{...}:concat(' ')))()

    elseif command == 'show' then
        if not (args[1] and args[2]) then
            error('Specify a category and value: //pv show <junk|known|unknown> <true|false>')
        end
        settings.Show[args[1]:lower():capitalize()] = args[2] ~= 'false'
        config.save(settings)

    elseif command == 'scan' or command == 's' then
        if not args[1] then
            error('Specify a command: //pv scan incoming|outgoing|both <val> or //pv scan start|stop')
            return
        end

        if not args[2] and direction_strings[args[1]] then
            error('Specify an argument to scan for: //pv scan incoming|outgoing|both [known|unknown|hybrid] <val>')
            return
        end

        if args[1] == 'start' then
            scan.active = true

        elseif args[1] == 'stop' then
            scan.active = false

        elseif args[1] == 'mode' or args[1] == 'm' then
            scan.mode = mode_strings[args[2]] or scan.mode

        else
            local dir = direction_strings[args[1]]
            local mode = mode_strings[args[2]]
            local arg = table.concat(args, ' ', mode and 3 or 2)
            mode = mode or 'hybrid'

            if tonumber(arg) then
                arg = tonumber(arg)
            end

            local pack_str
            if type(arg) == 'number' then
                if arg < 2^8 then
                    pack_str = 'b'
                elseif arg < 2^16 then
                    pack_str = 'H'
                elseif arg < 2^32 then
                    pack_str = 'I'
                else
                    error('Number too big to scan for.')
                    return
                end
            else
                pack_str = 'A'
            end

            scan.pack = pack_str
            scan.value = pack_str:pack(arg)
            scan.dir = dir
            scan.mode = mode
            scan.active = true

        end

    elseif command == 'filter' or command == 'f' then

    elseif command == 'clear' or command == 'c' then

    elseif command == 'next' or command == 'n' then

    elseif command == 'mode' or command == 'm' then

    elseif command == 'reload' or command == 'r' then

    elseif command == 'record' or command == 'rec' then
        if args[1] == 'start' then
            recording = true
        elseif args[1] == 'stop' then
            recording = false
        else
            recording = not recording
        end

    elseif command == 'log' or command == 'l' then
        if args[1] == 'stop' or args[1] == 's' then
            logging = T{}
            return
        end

        logging.output = args[1] and output_strings[args[1]] or 'console'
        logging.direction = args[2] and direction_strings[args[2]] or 'both'
        logging.mode = args[3] and mode_strings[args[3]] or settings.mode
        local offset = 0
        if args[3] and mode_strings[args[3]] then
            offset = 1
        end
        if not args[3 + offset] or args[3 + offset] == 'not' then
            logging.filter = S(list.range(0x1FF)) - S(args:slice(4 + offset):map(tonumber))
        else
            logging.filter = S(args:slice(3 + offset):map(tonumber))
        end

    elseif command == 'save' or command == 's' then

    elseif command == 'list' or command == 'l' then

    elseif command == 'display' or command == 'u' then
        if args[1] == 'show' or args[1] == 's' then
            display:show()

        elseif args[1] == 'hide' or args[1] == 'h' then
            display:hide()

        elseif args[1]:number() then
            display_packet(args[1]:number())

        else
            error('Specify an argument to display: //pv display <show|hide|#>')

        end

    elseif command == 'tag' then

    elseif command == 'freeze' then

    elseif command == 'continue' then

    elseif command == 'pos' then

    elseif command == 'save' then
        settings:save('all')

    elseif command == 'help' then
        print('Something')

    end

end)

--[[
This code is in the public domain.
]]
