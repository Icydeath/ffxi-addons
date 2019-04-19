
player = windower.ffxi.get_player()
player.equipment = T{}
player.stats = T{STR = 0, DEX = 0, VIT = 0, AGI = 0, INT = 0, MND = 0, CHR = 0}
player.skill = player.skills
player_base_skills = player.skills
player.is_moving = false
player.position = T{x = 0, y = 0, x = 0} 
buff = 0
full_gear_table_from_file = T{}
Buffs_inform = {		['delay'] = 0,['damage'] = 0,
								['HP'] = 0,['MP'] = 0,
								['STR'] = 0,['DEX'] = 0,['VIT'] = 0,['AGI'] = 0,['INT'] = 0,['MND'] = 0,['CHR'] = 0,
								['Accuracy'] = 0, ['Ranged Accuracy'] = 0, 
								['Attack'] = 0, ['Attack perc'] = 0,
								['Evasion'] = 0,['DEF'] = 0,['Defence perc'] = 0,
								['Magic Accuracy'] = 0, ['Magic Atk. Bonus'] = 0,
								['Magic Evasion'] = 0,['Magic Def. Bonus'] = 0,
								['g_haste']=0,['ma_haste'] = 0,['ja_haste'] = 0,
								['PDT'] = 0,['MDT'] = 0,['BDT'] = 0,['DT'] = 0,['MDT2'] = 0,['PDT2'] = 0,
								['Store TP'] = 0,['Dual Wield'] = 0 ,['Fast Cast'] = 0 ,['Martial Arts'] = 0,
								["Double Attack"] = 0,["Tripple Attack"] = 0,['Quadruple Attack'] = 0,["Critical hit rate"] = 0,["Critical hit damage"] = 0,["Subtle Blow"] = 0,
								}
Geo_buffs = {
	{id=539,en="Regen",							},
	{id=541,en="Refresh",						},
	{id=580,en="Haste",							},
	{id=542,en="STR Boost",					},
	{id=543,en="DEX Boost",					},
	{id=544,en="VIT Boost",					},
	{id=545,en="AGI Boost",					},
	{id=546,en="INT Boost",					},
	{id=547,en="MND Boost",					},
	{id=548,en="CHR Boost",					},
	{id=549,en="Attack Boost",				},
	{id=550,en="Defense Boost",				},
	{id=551,en="Magic Atk. Boost",			},
	{id=552,en="Magic Def. Boost",			},
	{id=553,en="Accuracy Boost",			},
	{id=554,en="Evasion Boost",				},
	{id=555,en="Magic Acc. Boost",			},
	{id=556,en="Magic Evasion Boost",	},
}
ele_to_stat = {
	[0] = {id=0,en="STR"},
	[1] = {id=1,en="INT"},
	[2] = {id=2,en="AGI"},
	[3] = {id=3,en="VIT"},
	[4] = {id=4,en="DEX"},
	[5] = {id=5,en="MND"},
	[6] = {id=6,en="CHR"},
	[7] = {id=7,en={[1]="STR",[2]="INT",[3]="AGI",[4]="VIT",[5]="DEX",[6]="MND",[7]="CHR"}},
}
Gear_info = T{}
member_table = T{}
seen_0x063_type9 = false
delay_0x063_v9 = false
debug_mode = false
party_from_packet = {}

_ExtraData = {
        player = {buff_details = {}},
        pet = {},
        world = {in_mog_house = false,conquest=false},
    }

old_inform = {}
manual_stp = 0
manual_dw = 0
manual_ghaste = 0
manual_mhaste = 0
manual_jahaste = 0
manual_dw_needed = 0
manual_bard_duration_bonus = 0
manual_COR_bonus = 0
manual_GEO_bonus  = 0
manual_hide = false
WSTP = 0
update_gs = true
show_total_haste = true
show_tp_Stuff = true
show_acc_Stuff = true
old_DW_needed = 0
DW = false
dancer_main = false
Crooked_cards = {name = '', bool = false}
__raw = {lower = string.lower, upper = string.upper,}

function to_windower_api(str)
    return __raw.lower(str:gsub(' ','_'))
end
							
defaults = {}
defaults.player = {}
defaults.player.show_logo = true
defaults.player.show_total_haste = true
defaults.player.show_tp_Stuff = true
defaults.player.show_acc_Stuff = false
defaults.player.show_dt_Stuff = false
defaults.player.show_att_Stuff = false
defaults.player.show_Evasion = false
defaults.player.show_Defence = false
defaults.player.show_STP = false
defaults.player.show_DW_Stuff = false
defaults.player.show_MA_Stuff = false
defaults.player.show_COR_messages = true
defaults.player.update_gs = true
defaults.player.rank = 1
defaults.Bards = {}
defaults.Cors = {}
defaults.Cors['qultada'] = 0
defaults.Geos = {}
defaults.Geos['Sylvie'] = 0
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.image_folder_name = "default"

defaults.Bards["joachim"] = {
	['gjallarhorn'] = false,
	['merits'] = {
		['minne'] = 0,
		['minuet'] = 0,
		['madrigal'] = 0,
	},
	['jp'] = {
		['minne'] = 0,
		['minuet'] = 0,
	},
	['emperean_armor_bonus'] = 0,
	['song_bonus'] = {
		['all_songs'] = 0,
		['paeon'] = 0,
		['ballad'] = 0,
		['minne'] = 0,
		['minuet'] = 0,
		['madrigal'] = 0,
		['prelude'] = 0,
		['mambo'] = 0,
		['march'] = 0,
		['etude'] = 0,
		['carol'] = 0,
		['mazurka'] = 0,
	},
}
defaults.Bards["ulmia"] = {
	['gjallarhorn'] = false,
	['merits'] = {
		['minne'] = 0,
		['minuet'] = 0,
		['madrigal'] = 0,
	},
	['jp'] = {
		['minne'] = 0,
		['minuet'] = 0,
	},
	['emperean_armor_bonus'] = 0,
	['song_bonus'] = {
		['all_songs'] = 0,
		['paeon'] = 0,
		['ballad'] = 0,
		['minne'] = 0,
		['minuet'] = 0,
		['madrigal'] = 0,
		['prelude'] = 0,
		['mambo'] = 0,
		['march'] = 0,
		['etude'] = 0,
		['carol'] = 0,
		['mazurka'] = 0,
	},
}

default_bard_settings = {
	['gjallarhorn'] = true,
	['merits'] = {
		['minne'] = 0,
		['minuet'] = 5,
		['madrigal'] = 5,
	},
	['jp'] = {
		['minne'] = 20,
		['minuet'] = 20,
	},
	['emperean_armor_bonus'] = 3,
	['song_bonus'] = {
		['all_songs'] = 0,
		['paeon'] = 0,
		['ballad'] = 0,
		['minne'] = 0,
		['minuet'] = 0,
		['madrigal'] = 0,
		['prelude'] = 0,
		['mambo'] = 0,
		['march'] = 0,
		['etude'] = 0,
		['carol'] = 0,
		['mazurka'] = 0,
	},
}

sections = {}
sections.block= {}












