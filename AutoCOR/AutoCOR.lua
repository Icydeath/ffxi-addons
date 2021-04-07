_addon.author = 'Ivaar, modified by icy'
_addon.name = 'AutoCOR'
_addon.commands = {'cor'}
_addon.version = '2021.4.7'

-- 4/7/21: fixed fold and snake eye issues being used when it shouldn't be.
-- 1/11/21: Added toggle settings for fold and snake eye
-- 10/24/20: Will now automatically turn off when you leave a battle field

require('pack')
require('lists')
require('tables')
require('strings')
texts = require('texts')
config = require('config')

default = {
    roll = L{'Ninja Roll','Corsair\'s Roll'},
    active = true,
	snake_eye = true,
	fold = true,
    crooked_cards = 1,
	roll_while_engaged = true, -- when false, it will not roll while engaged.
    text = {text = {size=10}},
    }

settings = config.load(default)
actions = false
nexttime = os.clock()
del = 0
buffs = {}
finish_act = L{2,3,5}
start_act = L{7,8,9,12}
ignore_buff_loss_zones = L{291, 289, 288}
zone = windower.ffxi.get_info().zone

rolls = T{
    [98] = {id=98,buff=310,en="Fighter's Roll",lucky=5,unlucky=9,bonus="Double Attack Rate",job='War'},
    [99] = {id=99,buff=311,en="Monk's Roll",lucky=3,unlucky=7,bonus="Subtle Blow",job='Mnk'},
    [100] = {id=100,buff=312,en="Healer's Roll",lucky=3,unlucky=7,bonus="Cure Potency Received",job='Whm'},
    [101] = {id=101,buff=313,en="Wizard's Roll",lucky=5,unlucky=9,bonus="Magic Attack",job='Blm'},
    [102] = {id=102,buff=314,en="Warlock's Roll",lucky=4,unlucky=8,bonus="Magic Accuracy",job='Rdm'},
    [103] = {id=103,buff=315,en="Rogue's Roll",lucky=5,unlucky=9,bonus="Critical Hit Rate",job='Thf'},
    [104] = {id=104,buff=316,en="Gallant's Roll",lucky=3,unlucky=7,bonus="Defense",job='Pld'},
    [105] = {id=105,buff=317,en="Chaos Roll",lucky=4,unlucky=8,bonus="Attack",job='Drk'},
    [106] = {id=106,buff=318,en="Beast Roll",lucky=4,unlucky=8,bonus="Pet Attack",job='Bst'},
    [107] = {id=107,buff=319,en="Choral Roll",lucky=2,unlucky=6,bonus="Spell Interruption Rate",job='Brd'},
    [108] = {id=108,buff=320,en="Hunter's Roll",lucky=4,unlucky=8,bonus="Accuracy",job='Rng'},
    [109] = {id=109,buff=321,en="Samurai Roll",lucky=2,unlucky=6,bonus="Store TP",job='Sam'},
    [110] = {id=110,buff=322,en="Ninja Roll",lucky=4,unlucky=8,bonus="Evasion",job='Nin'},
    [111] = {id=111,buff=323,en="Drachen Roll",lucky=4,unlucky=7,bonus="Pet Accuracy",job='Drg'},
    [112] = {id=112,buff=324,en="Evoker's Roll",lucky=5,unlucky=9,bonus="Refresh",job='smn'},
    [113] = {id=113,buff=325,en="Magus's Roll",lucky=2,unlucky=6,bonus="Magic Defense",job='Blu'},
    [114] = {id=114,buff=326,en="Corsair's Roll",lucky=5,unlucky=9,bonus="Experience Points",job='Cor'},
    [115] = {id=115,buff=327,en="Puppet Roll",lucky=3,unlucky=8,bonus="Pet Magic Accuracy Attack",job='Pup'},
    [116] = {id=116,buff=328,en="Dancer's Roll",lucky=3,unlucky=7,bonus="Regen",job='Dnc'},
    [117] = {id=117,buff=329,en="Scholar's Roll",lucky=2,unlucky=6,bonus="Conserve MP",job='Sch'},
    [118] = {id=118,buff=330,en="Bolter's Roll",lucky=3,unlucky=9,bonus="Movement Speed"},
    [119] = {id=119,buff=331,en="Caster's Roll",lucky=2,unlucky=7,bonus="Fast Cast"},
    [120] = {id=120,buff=332,en="Courser's Roll",lucky=3,unlucky=9,bonus="Snapshot"},
    [121] = {id=121,buff=333,en="Blitzer's Roll",lucky=4,unlucky=9,bonus="Attack Delay"},
    [122] = {id=122,buff=334,en="Tactician's Roll",lucky=5,unlucky=8,bonus="Regain"},
    [302] = {id=302,buff=335,en="Allies' Roll",lucky=3,unlucky=10,bonus="Skillchain Damage"},
    [303] = {id=303,buff=336,en="Miser's Roll",lucky=5,unlucky=7,bonus="Save TP"},
    [304] = {id=304,buff=337,en="Companion's Roll",lucky=2,unlucky=10,bonus="Pet Regain and Regen"},
    [305] = {id=305,buff=338,en="Avenger's Roll",lucky=4,unlucky=8,bonus="Counter Rate"},
    [390] = {id=390,buff=339,en="Naturalist's Roll",lucky=3,unlucky=7,bonus="Enhancing Magic Duration",job='Geo'},
    [391] = {id=391,buff=600,en="Runeist's Roll",lucky=4,unlucky=8,bonus="Magic Evasion",job='Run'},
    }

local display_box = function()
    return 'AutoCOR [%s]\nRoll 1: [%s]\nRoll 2: [%s]\nSnake Eye: [%s]\nFold: [%s]\nRoll while engaged: [%s]':format(actions and 'On' or 'Off', settings.roll[1], settings.roll[2], settings.snake_eye and 'On' or 'Off', settings.fold and 'On' or 'Off', settings.roll_while_engaged and 'On' or 'Off')
end

cor_status = texts.new(display_box(),settings.text,setting)
cor_status:show()

last_coords = 'fff':pack(0,0,0)
is_moving = false

windower.register_event('outgoing chunk',function(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        is_moving = last_coords ~= modified:sub(5, 16)
        last_coords = modified:sub(5, 16)
    end
end)

windower.register_event('prerender',function ()
    if not actions then return end
    local curtime = os.clock()
    if nexttime + del <= curtime then
        nexttime = curtime
        del = 0.5
        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'COR' or play.status > 1 or (play.status == 1 and not settings.roll_while_engaged) then return end
		
        local abil_recasts = windower.ffxi.get_ability_recasts()
        if buffs[16] or is_moving then return end
        if settings.fold and player_has_buff(309) then --buffs[309]
            if abil_recasts[198] and abil_recasts[198] == 0 then
                use_JA('/ja "Fold" <me>')
            end
            return
        end
        for x = 1,2 do
            local roll = rolls:with('en',settings.roll[x])
            if not buffs[roll.buff] then
                if abil_recasts[193] == 0 then
                    if x == settings.crooked_cards and abil_recasts[96] and abil_recasts[96] == 0 then
                        use_JA('/ja "Crooked Cards" <me>')
                    else
                        use_JA('/ja "%s" <me>':format(roll.en))
                    end
                end
                return
            elseif buffs[308] and buffs[308] == roll.id and buffs[roll.buff] ~= roll.lucky and buffs[roll.buff] ~= 11 then
                if settings.snake_eye and abil_recasts[197] and abil_recasts[197] == 0 and not player_has_buff(357) and L{roll.unlucky,roll.lucky-1,10}:contains(buffs[roll.buff]) then
                    use_JA('/ja "Snake Eye" <me>')
                elseif abil_recasts[194] and abil_recasts[194] == 0 and (player_has_buff(357) or buffs[roll.buff] < 7) then
                    use_JA('/ja "Double-Up" <me>')
                end
                return
            end
        end
    end
end)

windower.register_event('addon command', function(...)
    local commands = {...}
    commands[1] = commands[1] and commands[1]:lower()
    if not commands[1] then
        actions = not actions
    elseif commands[1] == 'on' then
        actions = true
    elseif commands[1] == 'off' then
        actions = false
	elseif commands[1] == 'fold' then
        settings.fold = not settings.fold
	elseif commands[1] == 'se' then
        settings.snake_eye = not settings.snake_eye
    elseif commands[1] == 'cc' then
        if settings.crooked_cards == 1 then
            settings.crooked_cards = 0
        else
            settings.crooked_cards = 1
        end
    elseif commands[1] == 'roll' then
        commands[2] = commands[2] and tonumber(commands[2])
        if commands[2] and commands[3] then
            commands[3] = windower.convert_auto_trans(commands[3])
			for x = 3,#commands do commands[x] = commands[x]:ucfirst() end
			commands[3] = table.concat(commands, ' ',3)
			set_roll(commands[2], commands[3])
        end
	elseif commands[1] == 'rolls' then
		if commands[2] then
			set_roll(1, commands[2])
			if commands[3] then
				set_roll(2, commands[3])
			end
		end
	elseif commands[1] == 'engaged' or commands[1] == 'e' then
		settings.roll_while_engaged = not settings.roll_while_engaged
			
    elseif commands[1] == 'save' then
        settings:save()
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
    cor_status:text(display_box())
    --windower.add_to_chat(207, str)
end)

function set_roll(num, str)
	str = str:ucfirst()
	local roll = rolls:with('job',str) or rolls:with('en',str)
	if roll and not settings.roll:find(roll.en) then
		settings.roll[num] = roll.en
		--print(roll.en,roll.bonus,roll.job and roll.job:upper())
	else
		for k,v in pairs(rolls) do
			if v and not settings.roll:find(v.en) and v.en:startswith(str) then
				settings.roll[num] = v.en
				--print(v.en,v.bonus,v.job and v.job:upper())
			end
		end
	end
end

function use_JA(str)
    del = 1.2
    windower.chat.input(str)
end

windower.register_event('incoming chunk', function(id,data,modified,is_injected,is_blocked)
    if id == 0x028 then
        if data:unpack('I', 6) ~= windower.ffxi.get_mob_by_target('me').id then return false end
        local category, param = data:unpack( 'b4b16', 11, 3)
        local recast, targ_id = data:unpack('b32b32', 15, 7)
        local effect, message = data:unpack('b17b10', 27, 6)
        if category == 6 then                       -- Use Job Ability
            if message == 420 then                  -- Phantom Roll
                buffs[rolls[param].buff] = effect
                buffs[308] = param
            elseif message == 424 then              -- Double-Up
                buffs[rolls[param].buff] = effect
            elseif message == 426 then              -- Bust
                buffs[rolls[param].buff] = nil
				--buffs[309] = param
            end
        elseif category == 4 then                   -- Finish Casting
            del = 4.2
            is_casting = false
        elseif finish_act:contains(category) then   -- Finish Range/WS/Item Use
            is_casting = false
        elseif start_act:contains(category) then
            del = category == 7 and recast or 1
            if param == 24931 then                  -- Begin Casting/WS/Item/Range
                is_casting = true
            elseif param == 28787 then              -- Failed Casting/WS/Item/Range
                is_casting = false
            end
        end
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff = data:unpack('H', n*2+7)
            if buff == 255 then break end
            if (buff >= 308 and buff <= 339) or (buff == 600) then
                set_buff[buff] = buffs[buff] and buffs[buff] or 11
            else
                set_buff[buff] = (set_buff[buff] or 0) + 1
            end
        end
        buffs = set_buff
    end
end)

function player_has_buff(buff)
	local player = windower.ffxi.get_player()
	if player and table.contains(player.buffs, buff) then
		return true
	end
	return false
end

function reset()
	zone = windower.ffxi.get_info().zone
    actions = false
    is_casting = false
    buffs = {}
	cor_status:text(display_box())
end

function status_change(new,old)
    --is_casting = false
    if new > 1 and new < 4 then
        reset()
	end
end

function lose_buff(buff_id)
	if buff_id == 143 and not ignore_buff_loss_zones:contains(zone) then
		reset()
	end
end

windower.register_event('lose buff', lose_buff)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', reset)

