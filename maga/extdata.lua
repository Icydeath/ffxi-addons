-- Extdata lib first pass

_libs = _libs or {}
_libs.actions = true
_libs.tables = _libs.tables or require 'tables'
local res = require 'resources'
_libs.strings = _libs.strings or require 'strings'
_libs.functions = _libs.functions or require 'functions'
require 'pack'


-- MASSIVE LOOKUP TABLES AND OTHER CONSTANTS

local decode = {}

function augment_filter(tab,key)
    local check = rawget(tab, key)
    return check or -1
end

local augment_meta = { 
    __index =   function(tab,key)
                    return rawget(tab, augment_filter(tab,key))
                end
}


        

augment_values = {
        [-1]    = {{stat="unknown",offset=0}},
        [0x000] = {{stat="none",offset=0}},
        [0x001] = {{stat="HP", offset=1}},
        [0x002] = {{stat="HP", offset=33}},
        [0x003] = {{stat="HP", offset=65}},
        [0x004] = {{stat="HP", offset=97}},
        [0x005] = {{stat="HP", offset=1,multiplier=-1}},
        [0x006] = {{stat="HP", offset=33,multiplier=-1}},
        [0x007] = {{stat="HP", offset=65,multiplier=-1}},
        [0x008] = {{stat="HP", offset=97,multiplier=-1}},
        [0x009] = {{stat="MP", offset=1}},
        [0x00A] = {{stat="MP", offset=33}},
        [0x00B] = {{stat="MP", offset=65}},
        [0x00C] = {{stat="MP", offset=97}},
        [0x00D] = {{stat="MP", offset=1,multiplier=-1}},
        [0x00E] = {{stat="MP", offset=33,multiplier=-1}},
        [0x00F] = {{stat="MP", offset=65,multiplier=-1}},
        [0x010] = {{stat="MP", offset=97,multiplier=-1}},
        [0x011] = {{stat="HP", offset=1}, {stat="MP", offset=1}},
        [0x012] = {{stat="HP", offset=33}, {stat="MP", offset=33}},
        [0x013] = {{stat="HP", offset=1}, {stat="MP", offset=1,multiplier=-1}},
        [0x014] = {{stat="HP", offset=33}, {stat="MP", offset=33,multiplier=-1}},
        [0x015] = {{stat="HP", offset=1,multiplier=-1}, {stat="MP", offset=1}},
        [0x016] = {{stat="HP", offset=33,multiplier=-1}, {stat="MP", offset=33}},
        [0x017] = {{stat="Accuracy", offset=1}},
        [0x018] = {{stat="Accuracy", offset=1,multiplier=-1}},
        [0x019] = {{stat="Attack", offset=1}},
        [0x01A] = {{stat="Attack", offset=1,multiplier=-1}},
        [0x01B] = {{stat="Ranged Accuracy", offset=1}},
        [0x01C] = {{stat="Ranged Accuracy", offset=1,multiplier=-1}},
        [0x01D] = {{stat="Ranged Attack", offset=1}},
        [0x01E] = {{stat="Ranged Attack", offset=1,multiplier=-1}},
        [0x01F] = {{stat="Evasion", offset=1}},
        [0x020] = {{stat="Evasion", offset=1,multiplier=-1}},
        [0x021] = {{stat="DEF", offset=1}},
        [0x022] = {{stat="DEF", offset=1,multiplier=-1}},
        [0x023] = {{stat="Magic Accuracy", offset=1}},
        [0x024] = {{stat="Magic Accuracy", offset=1,multiplier=-1}},
        [0x025] = {{stat="Magic Evasion", offset=1}},
        [0x026] = {{stat="Magic Evasion", offset=1,multiplier=-1}},
        [0x027] = {{stat="Enmity", offset=1}},
        [0x028] = {{stat="Enmity", offset=1,multiplier=-1}},
        [0x029] = {{stat="Critical hit rate", offset=1}},
        [0x02A] = {{stat="Enemy critical hit rate", offset=1,multiplier=-1}},
        [0x02B] = {{stat='Charm', offset=1}},
        [0x02C] = {{stat='Store TP', offset=1}, {stat='Subtle Blow', offset=1}},
        [0x02D] = {{stat="DMG", offset=1}},
        [0x02E] = {{stat="DMG", offset=1,multiplier=-1}},
        [0x02F] = {{stat="Delay", offset=1,percent=true}},
        [0x030] = {{stat="Delay", offset=1,multiplier=-1,percent=true}},
        [0x031] = {{stat="Haste", offset=1}},
        [0x032] = {{stat='Slow', offset=1}},
        [0x033] = {{stat="HP recovered while healing", offset=1}},
        [0x034] = {{stat="MP recovered while healing", offset=1}},
        [0x035] = {{stat="Spell interruption rate down", offset=1,multiplier=-1,percent=true}},
        [0x036] = {{stat="Physical damage taken", offset=1,multiplier=-1,percent=true}},
        [0x037] = {{stat="Magic damage taken", offset=1,multiplier=-1,percent=true}},
        [0x038] = {{stat="Breath damage taken", offset=1,multiplier=-1,percent=true}},
        [0x039] = {{stat="Magic critical hit rate", offset=1}},
        [0x03A] = {{stat='Magic Defense Bonus', offset=1,multiplier=-1}},
        [0x03B] = {{stat='Latent effect: Regain', offset=1}},
        [0x03C] = {{stat='Latent effect: Refresh', offset=1}},
        [0x03D] = {{stat="Occ. inc. resist. to stat. ailments", offset=1}},
        [0x03E] = {{stat="Accuracy", offset=33}},
        [0x03F] = {{stat="Ranged Accuracy", offset=33}},
        [0x040] = {{stat="Magic Accuracy", offset=33}},
        [0x041] = {{stat="Attack", offset=33}},
        [0x042] = {{stat="Ranged Attack", offset=33}},
        [0x043] = {{stat="All Songs", offset=1}},
        [0x044] = {{stat="Accuracy", offset=1},{stat="Attack", offset=1}},
        [0x045] = {{stat="Ranged Accuracy", offset=1},{stat="Ranged Attack", offset=1}},
        [0x046] = {{stat="Magic Accuracy", offset=1},{stat='Magic Attack Bonus', offset=1}},
        [0x047] = {{stat="Damage taken", offset=1,multiplier=-1,percent=true}},
        
        [0x04A] = {{stat="Cap. Point", offset=1,percent=true}},
        [0x04B] = {{stat="Cap. Point", offset=33,percent=true}},
        [0x04C] = {{stat="DMG", offset=33}},
        [0x04D] = {{stat="Delay", offset=33,multiplier=-1,percent=true}},
        [0x04E] = {{stat="HP", offset=1,multiplier=2}},
        [0x04F] = {{stat="HP", offset=1,multiplier=3}},
        [0x050] = {{stat="Magic Accuracy", offset=1}, {stat="Magic Damage", offset=1}},
        [0x051] = {{stat="Evasion", offset=1}, {stat="Magic Evasion", offset=1}},
        [0x052] = {{stat="MP", offset=1,multiplier=2}},
        [0x053] = {{stat="MP", offset=1,multiplier=3}},

        
        -- Need to figure out how to handle this section. The Pet: prefix is only used once despite how many augments are used.
        [0x060] = {{stat="Pet: Accuracy", offset=1}, {stat="Pet: Ranged Accuracy", offset=1}}, -- Pet: Accuracy+5 Rng.Acc.+5
        [0x061] = {{stat="Pet: Attack", offset=1}, {stat="Pet: Ranged Attack", offset=1}}, -- Pet: Attack +5 Rng.Atk.+5
        [0x062] = {{stat="Pet: Evasion", offset=1}},
        [0x063] = {{stat="Pet: DEF", offset=1}},
        [0x064] = {{stat="Pet: Magic Accuracy", offset=1}},
        [0x065] = {{stat='Pet: Magic Attack Bonus', offset=1}},
        [0x066] = {{stat="Pet: Critical Hit Rate", offset=1}},
        [0x067] = {{stat="Pet: Enemy Critical Hit Rate", offset=1,multiplier=-1}},
        [0x068] = {{stat="Pet: Enmity", offset=1}},
        [0x069] = {{stat="Pet: Enmity", offset=1,multiplier=-1}},
        [0x06A] = {{stat="Pet: Accuracy", offset=1}, {stat="Pet: Ranged Accuracy", offset=1}},
        [0x06B] = {{stat="Pet: Attack", offset=1}, {stat="Pet: Ranged Attack", offset=1}},
        [0x06C] = {{stat="Pet: Magic Accuracy", offset=1}, {stat='Pet: Magic Attack Bonus', offset=1}},
        [0x06D] = {{stat='Pet: Double Attack', offset=1}, {stat="Pet: Critical Hit Rate", offset=1}},
        [0x06E] = {{stat='Pet: Regen', offset=1}},
        [0x06F] = {{stat="Pet: Haste", offset=1}},
        [0x070] = {{stat="Pet: Damage Taken", offset=1,multiplier=-1,percent=true}},
        [0x071] = {{stat="Pet: Ranged Accuracy", offset=1}},
        [0x072] = {{stat="Pet: Ranged Attack", offset=1}},
        [0x073] = {{stat='Pet: Store TP', offset=1}},
        [0x074] = {{stat='Pet: Subtle Blow', offset=1}},
        [0x075] = {{stat="Pet: Magic Evasion", offset=1}},
        [0x076] = {{stat="Pet: Physical Damage Taken", offset=1,multiplier=-1,percent=true}},
        [0x077] = {{stat='Pet: Magic Defense Bonus', offset=1}},
        [0x078] = {{stat='Avatar: Magic Attack Bonus', offset=1}},
        [0x079] = {{stat='Pet: Breath', offset=1}},
        [0x07A] = {{stat='Pet: TP Bonus', offset=1, multiplier=20}},
        [0x07B] = {{stat='Pet: Double Attack', offset=1}},
        [0x07C] = {{stat="Pet: Accuracy", offset=1}, {stat="Pet: Ranged Accuracy", offset=1}, {stat="Pet: Attack", offset=1}, {stat="Pet: Ranged Attack", offset=1}},
        [0x07D] = {{stat="Pet: Magic Accuracy", offset=1}, {stat="Pet: Magic Damage", offset=1}},
        [0x07E] = {{stat='Pet: Magic Damage', offset=1}},

        [0x085] = {{stat='Magic Attack Bonus', offset=1}},
        [0x086] = {{stat='Magic Defense Bonus', offset=1}},
        
        [0x089] = {{stat="Regen", offset=1}},
        [0x08A] = {{stat="Refresh", offset=1}},
        [0x08B] = {{stat="Rapid Shot", offset=1}},
        [0x08C] = {{stat="Fast Cast", offset=1}},
        [0x08D] = {{stat="Conserve MP", offset=1}},
        [0x08E] = {{stat="Store TP", offset=1}},
        [0x08F] = {{stat="Double Attack", offset=1}},
        [0x090] = {{stat="Triple Attack", offset=1}},
        [0x091] = {{stat="Counter", offset=1}},
        [0x092] = {{stat="Dual Wield", offset=1}},
        [0x093] = {{stat="Treasure Hunter", offset=1}},
        [0x094] = {{stat="Gilfinder", offset=1}},
        
        [0x097] = {{stat='Martial Arts', offset=1}},
        
        [0x099] = {{stat='Shield Mastery', offset=1}},
        
        [0x0B0] = {{stat='Resist Sleep', offset=1}},
        [0x0B1] = {{stat='Resist Poison', offset=1}},
        [0x0B2] = {{stat='Resist Paralyze', offset=1}},
        [0x0B3] = {{stat='Resist Blind', offset=1}},
        [0x0B4] = {{stat='Resist Silence', offset=1}},
        [0x0B5] = {{stat='Resist Petrify', offset=1}},
        [0x0B6] = {{stat='Resist Virus', offset=1}},
        [0x0B7] = {{stat='Resist Curse', offset=1}},
        [0x0B8] = {{stat='Resist Stun', offset=1}},
        [0x0B9] = {{stat='Resist Bind', offset=1}},
        [0x0BA] = {{stat='Resist Gravity', offset=1}},
        [0x0BB] = {{stat='Resist Slow', offset=1}},
        [0x0BC] = {{stat='Resist Charm', offset=1}},
        
        [0x0C2] = {{stat='Kick Attacks', offset=1}},
        [0x0C3] = {{stat='Subtle Blow', offset=1}},

        [0x0C6] = {{stat='Zanshin', offset=1}},

        [0x0D3] = {{stat='Snapshot', offset=1}},
        [0x0D4] = {{stat='Recycle', offset=1}},

        [0x0D7] = {{stat='Ninja Tool Expertise', offset=1}},
        
        [0x0E9] = {{stat='Blood Boon', offset=1}},
        
        [0x0ED] = {{stat='Occult Acumen', offset=1}},

        [0x101] = {{stat="Hand-to-Hand skill", offset=1}},
        [0x102] = {{stat="Dagger skill", offset=1}},
        [0x103] = {{stat="Sword skill", offset=1}},
        [0x104] = {{stat="Great Sword skill", offset=1}},
        [0x105] = {{stat="Axe skill", offset=1}},
        [0x106] = {{stat="Great Axe skill", offset=1}},
        [0x107] = {{stat="Scythe skill", offset=1}},
        [0x108] = {{stat="Polearm skill", offset=1}},
        [0x109] = {{stat="Katana skill", offset=1}},
        [0x10A] = {{stat="Great Katana skill", offset=1}},
        [0x10B] = {{stat="Club skill", offset=1}},
        [0x10C] = {{stat="Staff skill", offset=1}},

        [0x116] = {{stat="Melee skill", offset=1}}, -- Automaton
        [0x117] = {{stat="Ranged skill", offset=1}}, -- Automaton
        [0x118] = {{stat="Magic skill", offset=1}}, -- Automaton
        [0x119] = {{stat="Archery skill", offset=1}},
        [0x11A] = {{stat="Marksmanship skill", offset=1}},
        [0x11B] = {{stat="Throwing skill", offset=1}},

        [0x11E] = {{stat="Shield skill", offset=1}},

        [0x120] = {{stat="Divine magic skill", offset=1}},
        [0x121] = {{stat="Healing magic skill", offset=1}},
        [0x122] = {{stat="Enhancing magic skill", offset=1}},
        [0x123] = {{stat="Enfeebling magic skill", offset=1}},
        [0x124] = {{stat="Elemental magic skill", offset=1}},
        [0x125] = {{stat="Dark magic skill", offset=1}},
        [0x126] = {{stat="Summoning magic skill", offset=1}},
        [0x127] = {{stat="Ninjutsu skill", offset=1}},
        [0x128] = {{stat="Singing skill", offset=1}},
        [0x129] = {{stat="String instrument skill", offset=1}},
        [0x12A] = {{stat="Wind instrument skill", offset=1}},
        [0x12B] = {{stat="Blue Magic skill", offset=1}},
        [0x12C] = {{stat="Geomancy Skill", offset=1}},
        [0x12D] = {{stat="Handbell Skill", offset=1}},

        [0x140] = {{stat='Blood Pact ability delay', offset=1,multiplier=-1}},
        [0x141] = {{stat='Avatar perpetuation cost', offset=1,multiplier=-1}},
        [0x142] = {{stat="Song spellcasting time", offset=1,multiplier=-1,percent=true}},
        [0x143] = {{stat='Cure spellcasting time', offset=1,multiplier=-1,percent=true}},
        [0x144] = {{stat='Call Beast ability delay', offset=1,multiplier=-1}},
        [0x145] = {{stat='Quick Draw ability delay', offset=1,multiplier=-1}},
        [0x146] = {{stat="Weapon Skill Accuracy", offset=1}},
        [0x147] = {{stat="Weapon skill damage", offset=1,percent=true}},
        [0x148] = {{stat="Critical hit damage", offset=1,percent=true}},
        [0x149] = {{stat='Cure potency', offset=1,percent=true}},
        [0x14A] = {{stat='Waltz potency', offset=1,percent=true}},
        [0x14B] = {{stat='Waltz ability delay', offset=1,multiplier=-1}},
        [0x14C] = {{stat="Skillchain Damage", offset=1,percent=true}},
        [0x14D] = {{stat='Conserve TP', offset=1}},
        [0x14E] = {{stat="Magic Burst Damage", offset=1,percent=true}},
        [0x14F] = {{stat="Magic Critical Hit Damage", offset=1,percent=true}},
        [0x150] = {{stat='Sic and Ready ability delay', offset=1,multiplier=-1}},
        [0x151] = {{stat="Song recast delay", offset=1,multiplier=-1}},
        [0x152] = {{stat='Barrage', offset=1}},
        [0x153] = {{stat='Elemental Siphon', offset=1, multiplier=5}},
        [0x154] = {{stat='Phantom Roll ability delay', offset=1,multiplier=-1}},
        [0x155] = {{stat='Repair potency', offset=1,percent=true}},
        [0x156] = {{stat='Waltz TP cost', offset=1,multiplier=-1}},
        [0x157] = {{stat='Drain and Aspir potency', offset=1}},

        [0x15E] = {{stat="Occ. maximizes magic accuracy", offset=1,percent=true}},
        [0x15F] = {{stat="Occ. quickens spellcasting", offset=1,percent=true}},
        [0x160] = {{stat="Occ. grants dmg. bonus based on TP", offset=1,percent=true}},
        [0x161] = {{stat="TP Bonus", offset=1, multiplier=5}},
        [0x162] = {{stat="Quadruple Attack", offset=1}},

        [0x164] = {{stat='Potency of Cure effect received', offset=1, percent=true}},
        
        [0x168] = {{stat="Save TP", offset=1, multiplier=10}},
        
        [0x16A] = {{stat="Magic Damage", offset=1}},
        [0x16B] = {{stat="Chance of successful block", offset=1}},
        [0x16E] = {{stat="Blood Pact ability delay II", offset=1, multiplier=-1}},
        [0x170] = {{stat="Phalanx", offset=1}},
        [0x171] = {{stat="Blood Pact Damage", offset=1}},
        [0x172] = {{stat='Reverse Flourish', offset=1}},
        [0x173] = {{stat='Regen Potency', offset=1}},
        [0x174] = {{stat='Embolden', offset=1}},
        -- Empties are Numbered up to 0x17F. Their stat is their index + 1
        [0x200] = {{stat="STR", offset=1}},
        [0x201] = {{stat="DEX", offset=1}},
        [0x202] = {{stat="VIT", offset=1}},
        [0x203] = {{stat="AGI", offset=1}},
        [0x204] = {{stat="INT", offset=1}},
        [0x205] = {{stat="MND", offset=1}},
        [0x206] = {{stat="CHR", offset=1}},
        [0x207] = {{stat="STR", offset=1,multiplier=-1}},
        [0x208] = {{stat="DEX", offset=1,multiplier=-1}},
        [0x209] = {{stat="VIT", offset=1,multiplier=-1}},
        [0x20A] = {{stat="AGI", offset=1,multiplier=-1}},
        [0x20B] = {{stat="INT", offset=1,multiplier=-1}},
        [0x20C] = {{stat="MND", offset=1,multiplier=-1}},
        [0x20D] = {{stat="CHR", offset=1,multiplier=-1}},


        [0x2E4] = {{stat="DMG", offset=1}},
        [0x2E5] = {{stat="DMG", offset=33}},
        [0x2E6] = {{stat="DMG", offset=65}},
        [0x2E7] = {{stat="DMG", offset=97}},
        [0x2E8] = {{stat="DMG", offset=1,multiplier=-1}},
        [0x2E9] = {{stat="DMG", offset=33,multiplier=-1}},
        [0x2EA] = {{stat="DMG", offset=1}},
        [0x2EB] = {{stat="DMG", offset=33}},
        [0x2EC] = {{stat="DMG", offset=65}},
        [0x2ED] = {{stat="DMG", offset=97}},
        [0x2EE] = {{stat="DMG", offset=1,multiplier=-1}},
        [0x2EF] = {{stat="DMG", offset=33,multiplier=-1}},
        [0x2F0] = {{stat="Delay", offset=1}},
        [0x2F1] = {{stat="Delay", offset=33}},
        [0x2F2] = {{stat="Delay", offset=65}},
        [0x2F3] = {{stat="Delay", offset=97}},
        [0x2F4] = {{stat="Delay", offset=1,multiplier=-1}},
        [0x2F5] = {{stat="Delay", offset=33,multiplier=-1}},
        [0x2F6] = {{stat="Delay", offset=65,multiplier=-1}},
        [0x2F7] = {{stat="Delay", offset=97,multiplier=-1}},
        [0x2F8] = {{stat="Delay", offset=1}},
        [0x2F9] = {{stat="Delay", offset=33}},
        [0x2FA] = {{stat="Delay", offset=65}},
        [0x2FB] = {{stat="Delay", offset=97}},
        [0x2FC] = {{stat="Delay", offset=1,multiplier=-1}},
        [0x2FD] = {{stat="Delay", offset=33,multiplier=-1}},
        [0x2FE] = {{stat="Delay", offset=65,multiplier=-1}},
        [0x2FF] = {{stat="Delay", offset=97,multiplier=-1}},


        -- 0x359 = 475
        [0x380] = {{stat="Sword enhancement spell damage", offset=1}},
        [0x381] = {{stat='Enhances Souleater effect', offset=1,percent=true}},
        
        -- This is actually a range for static augments that uses all the bits.

        
        [0x4E0] = {{stat="Enh. Mag. eff. dur.", offset=1}},
        [0x4E1] = {{stat="Helix eff. dur.", offset=1}},
        [0x4E2] = {{stat="Indi. eff. dur.", offset=1}},
        
        [0x4F0] = {{stat="Meditate eff. dur.", offset=1}},
        
        [0x700] = {{stat="Pet: STR", offset=1}},
        [0x701] = {{stat="Pet: DEX", offset=1}},
        [0x702] = {{stat="Pet: VIT", offset=1}},
        [0x703] = {{stat="Pet: AGI", offset=1}},
        [0x704] = {{stat="Pet: INT", offset=1}},
        [0x705] = {{stat="Pet: MND", offset=1}},
        [0x706] = {{stat="Pet: CHR", offset=1}},
        [0x707] = {{stat="Pet: STR", offset=1,multiplier=-1}},
        [0x708] = {{stat="Pet: DEX", offset=1,multiplier=-1}},
        [0x709] = {{stat="Pet: VIT", offset=1,multiplier=-1}},
        [0x70A] = {{stat="Pet: AGI", offset=1,multiplier=-1}},
        [0x70B] = {{stat="Pet: INT", offset=1,multiplier=-1}},
        [0x70C] = {{stat="Pet: MND", offset=1,multiplier=-1}},
        [0x70D] = {{stat="Pet: CHR", offset=1,multiplier=-1}},
        [0x70E] = {{stat="Pet: STR", offset=1},{stat="Pet: DEX", offset=1},{stat="Pet: VIT", offset=1}},
		
}


setmetatable(augment_values,augment_meta)

-- TOOLS FOR HANDLING EXTDATA

tools = {}
tools.aug = {}



function tools.aug.unpack_augment(short)
	return short:byte(1) + short:byte(2)%8*256,  math.floor(short:byte(2)/8)
end

function tools.aug.augments_to_table(str)
    local augments,ids,vals = {},{},{}
    for i=1,#str,2 do
        local id,val = tools.aug.unpack_augment(str:sub(i,i+1))
        augments[#augments+1] = {id,(val+augment_values[id][1].offset)*(augment_values[id][1].multiplier or 1)}
    end
    return augments
end
-- ACTUAL EXTDATA LIB FUNCTIONS
    
local extdata = {}
    
function get_augment(id)
	local ret = L{}
	
	if id > 0 then
		for k,v in pairs(augment_values[id]) do
			ret:append(v.stat:lower())	
		end
	end
	
	return ret
end

function extdata.match(str)
	
	for k,v in pairs(augment_values) do
		if v[1] then
			if v[1].stat:lower() == str:lower() then
				return true
			end
		end
	end

	return false
	
end

function extdata.search_aug(str)
	local matches = L{}

	for k,v in pairs(augment_values) do
		if v[1] then
			if string.find(v[1].stat:lower(), str) then
				if not matches:contains(v[1].stat) then
					matches:append(v[1].stat)
				end
			end
		end
	end

	return matches
end
	
function extdata.decode(str)
    local tab = tools.aug.augments_to_table(str:sub(3,12))
	local res = T{}
	
	for k,v in pairs(tab) do
		local augs = get_augment(v[1])
		
		for aug in augs:it() do
			if res:containskey(aug) then
				res[aug] = res[aug] + v[2]
			else
				res[aug] = v[2]
			end
		end
		
	end
	
	return res
end



return extdata