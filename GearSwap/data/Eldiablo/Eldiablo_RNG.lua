-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

hastetype=1
hastesambatype=0
enableautora = true
autora = false
--default_ws = "Jishnu's Radiance"
default_ws = "Trueflight"
customincludes=false
--print(world.weather_element)

function get_sets()
	mote_include_version = 2

	-- Load and initialize the include file.
	include('Mote-Include.lua')
	include('organizer-lib')
	send_command('lua u autora')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	state.OffenseMode:options('Normal', 'Fodder', 'Acc', 'AccExtreme')
	state.RangedMode:options('Normal', 'Fodder', 'Acc', 'AccExtreme','threehit','StatusAmmo')
	--state.HybridMode:options('Normal', 'Evasion', 'PDT')
	--state.RangedMode:options('Normal', 'Acc')
	--state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
	--state.accuracy = M{['description']="Accuracy Level",'Normal','Light', 'All Out'}
	state.damagetaken = M{['description']="Damage Taken",'None','DTLight', 'DT', 'MagicLight','MagicEvasion'}
	state.hastemode = M{['description'] = 'Haste Mode'}
	state.hastemode:options('NoHaste','HasteI','HasteII','Capped')
	state.flurrymode = M{['description'] = 'Flurry Mode'}
	state.flurrymode:options('Flurry','FlurryII')
	state.rangetype = M{['description'] = 'Ranged Type'}
	--state.rangetype:options('Crossbow','Bow','Gun','MartialGun','MachineCrossbow','Crossbow2','Throwing')
	state.rangetype:options('Crossbow','Anni','Bow','Gun','MachineCrossbow')
	state.cpmode = M(false, 'CP Mode')
	state.autows = M(false, 'AutoWS')
	state.runaway2 = M(false, 'Run Away! (Jute Boot Version)')
	state.idlemode = M{['description']="Idle Mode",'Normal','Regen'}
	state.hasteknife = M(false, 'Blurred Dagger')
	state.mabdagger = M(false, 'MAB Dagger')
	state.mainweapon = M{['description'] = 'Main Weapon'}
	--state.mainweapon:options('Perun','STPExtreme','Malevolence','Kustawi','Oneiros','KrakenClub')
	state.mainweapon:options('Malevolence','Perun','STPExtreme','Kustawi','Oneiros','KrakenClub')
	state.pullmode = M(false, 'Pull Mode')
	

	state.Buff.Barrage = buffactive.Barrage or false
	state.Buff.Camouflage = buffactive.Camouflage or false
	state.Buff.Overkill = buffactive.Overkill or false

	-- Additional local binds
	--send_command('bind ^q gs c hastetype')
	send_command('bind ^q gs c cycle flurrymode')
	send_command('bind ^d gs c shoot')
	send_command('bind !d gs c shootstop')
	send_command('bind !q gs c rangetype')
	send_command('bind @q gs c hastesambatype')
	send_command('bind f10 gs c cycle idlemode')
	send_command('bind @home gs c warpring')
	
	send_command('bind ^%m gs c cycle meleetype')
	send_command('bind f11 gs c toggle_dt')
	--send_command('bind @f9 gs c cycle mainweapon')
	send_command('bind @f9 gs c mainweapon')
	send_command('bind !f11 gs c cycle damagetaken')
	send_command('bind ^f11 gs c toggle pullmode')
	send_command('alias stp_m7 gs c toggle mabdagger')
	send_command('alias cp input /checkparam <me>')
	send_command('alias trust_levi input /ma "Amchuchu" <me>;wait 5;input /ma "Yoran-Oran (UC)" <me>;wait 5;input /ma "King of Hearts" <me>;wait 5;input /ma "Brygid" <me>;wait 5;input /ma "Ulmia" <me>')
	--send_command('alias trust_bcnm input /ma "August" <me>;wait 5;input /ma "Yoran-Oran (UC)" <me>;wait 5;input /ma "Arciela II" <me>;wait 5;input /ma "Qultada" <me>;wait 5;input /ma "Ulmia" <me>')
	send_command('alias trust_bcnm input /ma "August" <me>;wait 5;input /ma "Yoran-Oran (UC)" <me>;wait 5;input /ma "Arciela II" <me>;wait 5;input /ma "Qultada" <me>;')
	send_command('alias rg lua r gearswap')
	send_command('bind ^[ gs c toggle cpmode')
	send_command('bind ![ gs c toggle autows')

	--send_command('bind !- gs c cycle targetmode')
	--send_command('bind !\ gs c maxth')
	--send_command('bind f11 gs c magicevasion')
	--send_command('bind f11 gs c damagetaken')
	--send_command('bind f10 gs c ranged')
	--send_command('bind f9 gs c accmode')
	--send_command('bind ^q gs c dw')

	--send_command('alias stp_m6 gs c maxth')
	send_command('alias stp_m7 gs c hastemode')
	--send_command('bind f12 gs equip idle')
	send_command('bind ^/ gs c cycle runaway')
	send_command('bind !/ gs c cycle runaway2')
	--send_command('alias stp_m10 input /ma "Monomi: Ichi" <me>')
	send_command('alias stp_m10 gs c switch_dualbox_binds')
	--send_command('bind numpad3 input /ws "Jishnu\'s Radiance" <t>')
	send_command('bind @numpad1 gs c ammotype "Abrasion_Bolt"')
	send_command('bind @numpad2 gs c ammotype "Quelling_Bolt"')
	send_command('bind @numpad4 gs c ammotype "Bloody_Bolt"')
	send_command('bind @numpad5 gs c ammotype "Righteous_Bolt"')

	--send_command('alias stp_m11 input /ws "Rudra\'s Storm" <t>')
	--send_command('alias stp_m12 input /ws "Aeolean Edge" <t>')
	--send_command('alias stp_m13 input /ws "Evisceration" <t>')
	send_command('alias stp_m13 input /ws "Last Stand" <t>')
	--send_command('bind %numpad3 input /ws "Jishnu\'s Radiance" <t>')
	send_command('unbind numpad1')
	send_command('unbind numpad3')
    send_command('bind %numpad1 input /targetbnpc;wait .1;input /attack <t>')
	send_command('bind %numpad3 input /ws "Trueflight" <t>')
	send_command('bind ^%= setkey f8 down;wait .1;setkey f8 up;')
	send_command('alias trust_wkr input /ma "August" <me>;wait 5;input /ma "Apururu (UC)" <me>;wait 5;input /ma "Qultada" <me>;wait 5;input /ma "Koru-Moru" <me>;wait 5;input /ma "Ulmia" <me>')
	--send_command('alias trust_dmn input /ma "August" <me>;wait 5;input /ma "Yoran-Oran (UC)" <me>;wait 5;input /ma "Qultada" <me>;wait 5;input /ma "Selh\'teus" <me>;wait 5;input /ma "Ulmia" <me>')
	send_command('alias trust_dmn input /ma "August" <me>;wait 5;input /ma "Apururu (UC)" <me>;wait 5;input /ma "Koru-Moru" <me>;wait 5;input /ma "Ulmia" <me>;wait 5;/ma "Selh\'teus" <me>')
	send_command('alias trust_woe input /ma "August" <me>;wait 5;input /ma "Apururu (UC)" <me>;wait 5;input /ma "Ullegore" <me>;wait 5;input /ma "Adelheid" <me>;wait 5;input /ma "Zeid II" <me>')
	send_command('alias trust_bcnm input /ma "Gessho" <me>;wait 5;input /ma "Apururu (UC)" <me>;wait 5;input /ma "Selh\'teus" <me>;wait 5;input /ma "Uka Tothlin" <me>;wait 5;input /ma "Arciela II" <me>')

	

	--send_command('bind ^f11 gs c magicevasion')

	send_command('bind @1 gs c alt_buffs')
	send_command('bind @2 gs c alt_sneakinvis')
	send_command('bind @3 gs c alt_cures')
	send_command('bind @4 gs c alt_selfbuffs')
	send_command('bind @5 gs c alt_selfbuffs2')
	send_command('bind @6 gs c alt_selfbuffs3')
	send_command('bind @0 gs c alt_follow')
	send_command('bind @6 gs c setws Coronach')
	send_command('bind @7 gs c setws Jishnus')
	send_command('bind @8 gs c setws Trueflight')
	send_command('bind @9 gs c setws Last_Stand')

	if(customincludes) then 
		include('custom-aliases.lua')
	end
	select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
	send_command('unbind ^`')
	send_command('unbind !-')
	send_command('unbind %numpad1')
	send_command('unbind %numpad3')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

	--lutiancape={ name="Lutian Cape", augments={'STR+2','AGI+1','"Store TP"+3','"Snapshot"+2',}}
	--belenus={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','"Store TP"+10',}}
    --belenus={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10',}}

	--belenuswsd={ name="Belenus's Cape", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','Weapon skill damage +10%',}}
    --belenuswsd={ name="Belenus's Cape", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',}}
    --belenusjish={ name="Belenus's Cape", augments={'DEX+20','Rng.Acc.+20 Rng.Atk.+20','DEX+10','Crit.hit rate+10',}}


    --belenuswsdagi={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}}
	--belenussnap={ name="Belenus's Cape", augments={'"Snapshot"+10',}}
	
	--DefaultAmmo = {[gear.Bow] = "Cronos arrow", [gear.Gun] = "Achiyalabopa bullet"}
	--U_Shot_Ammo = {[gear.Bow] = "Cronos arrow", [gear.Gun] = "Achiyalabopa bullet"} 
	
	--sets.SilenceDagger = {main="Levante dagger"}
	--sets.Mainhand = {main="Perun"}

	--include('augmented-items.lua')
	sets.cpmode = {back="Mecisto. Mantle"}
	sets.basetp = {
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs={ name="Herculean Trousers", augments={'Rng.Atk.+17','STR+1','Rng.Acc.+10',}},
		feet={ name="Herculean Boots", augments={'Accuracy+30','"Triple Atk."+3','DEX+8','Attack+12',}},
	}

	organizer_items = {
		i1="Warp Ring",
		i2="Dim. Ring (Mea)",
		i3="Mephitas's Ring +1",
		i5="Holy Water",
		i6="Remedy",
		i7="Echo Drops",
		i8="Sublime Sushi",
		i9="Sublime Sushi +1",
		i10="Pot-au-feu",
		i11="Pot-au-feu +1",
		i12="Kohlrouladen +1",
		i13="Kohlrouladen",
		i14="Bloody Bolt",
		i15="Miso Ramen",
		i16="Panacea",
		i17="Vile Elixir",
		i18="Vile Elixir +1",
		i19="Echad Ring",
		i20="Trizek Ring",
		i21="Capacity Ring",
		i22="Anniversary Ring",
		i23="Echad Ring",
		i24="Expertise Ring",
		i25="Warp Cudgel",
		i26="Facility Ring",
		i27="Pear Crepe",
		--i28="Adlivun bullet pouch"
	}
	
	if player.sub_job == "NIN" then
		sets.ninsub = {
			ammo="Toolbag (Shihe)",
			ring1="Shihei",
			ring2="Shinobi-Tabi",
			head="Sanjaku-Tenugui",
		}
	end


	------------------------------------------------------------------
	-- Default Base Gear Sets for Ranged Attacks. Geared for Bow
	------------------------------------------------------------------
	sets.mainweapon = {}
	sets.mainweapon.Kustawi = {
		main="Kustawi +1",
		sub="Nusku Shield"
	}
	sets.mainweapon.Oneiros = {
		main="Oneiros Knife",
		sub="Nusku Shield"
	}
	sets.mainweapon.Perun = {
		main="Perun +1",
		sub="Nusku Shield"
	}
	sets.mainweapon.Malevolence = {
		main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
		sub="Nusku Shield"
	}
	sets.mainweapon.KrakenClub={
		main="Kraken Club",
		sub="Nusku Shield",
	}
	sets.mainweapon.STPExtreme={
		main="Mekki Shakki",
		sub="Bloodrain Strap"
	}
	if player.sub_job == "DNC" or player.sub_job == "NIN" then
		sets.mainweapon.Kustawi = {
			main="Kustawi +1",
			sub="Kustawi"
			--sub="Perun +1"
		}
		sets.mainweapon.Oneiros = {
			--main=atoyac,
			main="Kustawi +1",
			sub="Oneiros Knife",
		}
		sets.mainweapon.Perun = {
			main="Perun +1",
			sub="Kustawi +1"
			--sub="Perun"
		}
		sets.mainweapon.Malevolence = {
			main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
			sub={ name="Malevolence", augments={'INT+9','Mag. Acc.+10','"Mag.Atk.Bns."+9','"Fast Cast"+4',}},
			--sub="Trilling Dagger"
		}
		sets.mainweapon.KrakenClub={
			main="Kraken Club",
			sub="Nusku Shield"
		}
		sets.mainweapon.KrakenClub={
			main="Kustawi +1",
			sub="Kraken Club",
			main="Kraken Club",
			sub="Nusku Shield",
		}
	end
	sets.alt = {
		--main="Oneiros Knife",
		--body="Sayadio's Kaftan",
		--feet=p_feet,
		--neck="Gaudryi Necklace"
	}
	sets.midcast.RA = { 
		ammo={"Decimating Bullet"},
		head={ name="Arcadian Beret +1", augments={'Enhances "Recycle" effect',}},
		body={ name="Pursuer's Doublet", augments={'HP+50','Crit. hit rate+4%','"Snapshot"+6',}},
		hands={ name="Carmine Fin. Ga.", augments={'Rng.Atk.+15','"Mag.Atk.Bns."+10','"Store TP"+5',}},
		legs={ name="Adhemar Kecks", augments={'AGI+10','"Rapid Shot"+10','Enmity-5',}},
		feet={ name="Herculean Boots", augments={'Rng.Acc.+16 Rng.Atk.+16','"Rapid Shot"+8','Rng.Atk.+13',}},
		neck="Marked Gorget",
		waist="Impulse Belt",
		left_ear="Neritic Earring",
		right_ear="Volley Earring",
		left_ring="Apate Ring",
		right_ring="Rajas Ring",
		back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+9','"Store TP"+10',}},
	}
	sets.midcast.RA.Fodder = set_combine(sets.midcast.RA, {
		
	})
	sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
		
	})
	sets.midcast.RA.AccExtreme = set_combine(sets.midcast.RA.Acc, {
		
	})
	sets.midcast.RA.threehit = { 
		--head=arc_head,
		--ear1="Telos Earring",
		--ear2="Dedition Earring",
		--body=hercvest_racc,
		--hands=ah_hands,
		--left_ring="Rajas Ring",
		--right_ring="Apate Ring",
		--legs=ah_legs2,
		--feet=hercboots_agi,
		--back=belenus,
		--neck="Iskur Gorget",
		--waist="Yemaya Belt",
	}
	sets.midcast.RA.StatusAmmo = { 
		--head="Mummu Bonnet +1",
		--body="Mummu Jacket +1",
		--hands="Mummu Wrists +1",
		--legs="Mummu Kecks +1",
		--feet="Mummu Gamashes +1",
	}
	sets.midcast.RA.StatusAmmo = set_combine(sets.midcast.RA.AccExtreme,sets.midcast.RA.StatusAmmo)
	sets.racc = sets.midcast.RA.AccExtreme
	--	sets.midcast.RA.Acc = set_combine(sets.midcast.Acc, {
	--		back=lutiancape,
	--		ring1="Longshot Ring",
	--		body="Kyujutsugi",
	--	})
	--	sets.midcast.RA.AccExtreme = set_combine(sets.midcast.RA.AccExtreme, {
	--		neck="Iqabi Necklace", hands="Sigyn's Bazubands",
	--		ring1="Hajduk Ring", ring2="Longshot Ring",
	--		legs="Arcadian Braccae +1"
	--	})
	sets.buff.Barrage = set_combine(sets.midcast.RA.AccExtreme, {
		hands="Orion Bracers",
	})
	sets.BarrageExtra = {
		--legs=desultor,

	}


	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
	--sets.precast.JA['Bounty Shot'] = {hands="Amini Glovelettes +1"}
	--sets.precast.JA['Double Shot'] = {head="Amini Gapette +1"}
	--sets.precast.JA['Camouflage'] = {body="Orion Jerkin +2"}
	--sets.precast.JA['Sharpshot'] = {legs="Orion Braccae +1"}
	sets.precast.JA['Velocity Shot'] = {body="Amini Caban +1"}
	--sets.precast.JA['Scavenge'] = {feet="Orion Socks +1"}
	--sets.precast.JA['Unlimited Shot'] = {feet="Amini Bottillons +1"}
	--sets.precast.JA['Shadowbind'] = {hands="Orion Bracers +1"}

	sets.precast.JA['Eagle Eye Shot'] = set_combine(sets.midcast.RA, {--EES maxes accuracy, only worry about crit chance, boost to EES from relic, attack and crit damage
		--head="Uk'uxkaj Cap", 
		--ear1="Flame Pearl",
		--ear2="Flame Pearl",
		--neck="Rancor Collar",
		--back="Buquwik Cape",
		--hands="Seiryu's Kote",
		--ring1="Ifrit Ring",
		--ring2="Ifrit Ring +1",
		--legs="Amini Brague +1", 
		--legs=arc_legs, --+20% EES dmg
		--feet="Arcadian Socks +1"
	})

	--sets.slashing = {main="Pukulatmuj",sub="Deliverance +1"}
	--sets.blunt = {main="Pukulatmuj"}


	if player.sub_job == "DNC" then
		sets.precast.Waltz  = {
			
		}
	end
	-- Waltz set (chr and vit)
	--sets.precast.Waltz = {ammo="Sonia's Plectrum",
	--    head="Whirlpool Mask",
	--    body="Pillager's Vest +1",hands="Pillager's Armlets +1",ring1="Asklepian Ring",
	--    back="Iximulew Cape",waist="Caudata Belt",legs="Pillager's Culottes +1",feet="Plunderer's Poulaines +1"}

	-- Fast cast sets for spells
	sets.precast.FC = {
		neck="Orunmila's Torque",
		--body="Dread Jupon",
		ring1="Prolix Ring",
		--ring1="Weatherspoon Ring",
		ring2="Rahab Ring",
		--legs="Limbo Trousers",
		ear1="Enchntr. Earring +1",
		ear2="Loquac. Earring"
	}

	--sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {body="Passion Jacket",back="Mujin Mantle"})

	--No Flurry--
	sets.precast.RA = {
		head={ name="Arcadian Beret +1", augments={'Enhances "Recycle" effect',}},
		body={ name="Pursuer's Doublet", augments={'HP+50','Crit. hit rate+4%','"Snapshot"+6',}},
		hands={ name="Carmine Fin. Ga.", augments={'Rng.Atk.+15','"Mag.Atk.Bns."+10','"Store TP"+5',}},
		legs={ name="Adhemar Kecks", augments={'AGI+10','"Rapid Shot"+10','Enmity-5',}},
		feet={ name="Herculean Boots", augments={'Rng.Acc.+16 Rng.Atk.+16','"Rapid Shot"+8','Rng.Atk.+13',}},
		back={ name="Lutian Cape", augments={'STR+1','AGI+2','"Store TP"+1','"Snapshot"+3',}},
		--waist="Yemaya Belt",--R:5
		waist="Impulse Belt",--S:3
		--legs=ah_legs,--S:9 R:10
		--feet="Meghanada Jambeaux +1",--S:8
		--Kustawi+1 and Kustawi R:14
	}
	--Snapshot: 60 
	---- Merits:10
	---- Gear: 10+8+3+9+10+10=50
	--Velocity: 34
	---- Base: 15
	---- Gifts: 10
	---- Gear: 2+7 = 9
	--Rapidshot: 56
	---- Merits:5
	---- Traits:30
	---- Gear: 11+10 = 21
	sets.precast.RA.Gastra = set_combine(sets.precast.RA,{
		body="Amini Caban +1",--V:7
	})
	
	
	--Flurry Set--
	sets.precast.RA.Flurry = {
		--head={ name="Taeon Chapeau", augments={'"Snapshot"+5','"Snapshot"+5',}}, --S:10
		body="Amini Caban +1",--V:7
		--body="Arcadian Jerkin +1",--R:12
		--hands={ name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}},--S:8 R:11
		--waist="Yemaya Belt",--R:5
		--waist="Impulse Belt",--S:3
		--legs=ah_legs,--S:9 R:10
		--feet="Meghanada Jambeaux +1",--S:8
		--feet={ name="Taeon Boots", augments={'Rng.Acc.+7','"Snapshot"+5','"Snapshot"+5',}},--S:10
		--back=belenussnap, --V:2, S:10
		--Kustawi+1 and Kustawi R:14
	}
	--Snapshot: 72
	---- Merits:10
	---- Flurry:15
	---- Gear: 10+8+9+10+10=47
	--Velocity: 34
	---- Base: 15
	---- Gifts: 10
	---- Gear: 2+7 = 9
	--Rapidshot: 61 
	---- Merits:5
	---- Traits:30
	---- Gear: 11+10+5 = 26
	sets.precast.RA.Flurry.Gastra = set_combine(sets.precast.RA.Flurry,{
		head="Orion Beret +1"
	})

	-- Flurry 2 Set -- 
	sets.precast.RA.Flurry2 = {
		--head={ name="Taeon Chapeau", augments={'"Snapshot"+5','"Snapshot"+5',}}, --S:10
		--head="Orion Beret +1", --R:14
		--body="Amini Caban +1",--V:7
		--hands={ name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}},--S:8 R:11
		--waist="Yemaya Belt",--R:5
		--legs=ah_legs,--S:9 R:10
		--feet={ name="Taeon Boots", augments={'Rng.Acc.+7','"Snapshot"+5','"Snapshot"+5',}},--S:10
		--back=belenussnap, --V:2, S:10
		--body="Arcadian Jerkin +1",--R:12
		--Kustawi+1 and Kustawi R:14
		--waist="Impulse Belt",--S:3
		--feet="Meghanada Jambeaux +1",--S:8
	}
	--Snapshot: 77
	---- Merits:10
	---- Flurry:30
	---- Gear: 8+9+10+10=37
	--Velocity: 34
	---- Base: 15
	---- Gifts: 10
	---- Gear: 2+7 = 9
	--Rapidshot: 75 
	---- Merits:5
	---- Traits:30
	---- Gear: 14+11+5+10 = 40
	
	sets.precast.RA.Flurry2.Gastra = set_combine(sets.precast.RA.Flurry2,{
		feet=p_feet,
	})

--	sets.precast.RA.Flurry2 = {
--		head="Orion Beret +1", --R:14
--		body="Amini Caban +1",--V:7
--		--body="Arcadian Jerkin +1",--R:12
--		hands={ name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}},--S:8 R:11
--		--waist="Yemaya Belt",--R:5
--		waist="Impulse Belt",--S:3
--		legs=ah_legs,--S:9 R:10
--		--feet="Meghanada Jambeaux +1",--S:8
--		feet=p_feet,--R:10
--		back=belenussnap, --V:2, S:10
--		--Kustawi+1 and Kustawi R:14
--	}
	--Snapshot: 70
	---- Merits:10
	---- Flurry 2:30
	---- Gear: 8+3+9+10=30
	--Velocity: 34
	---- Base: 15
	---- Gifts: 10
	---- Gear: 2+7 = 9
	--Rapidshot: 80
	---- Merits:5
	---- Traits:30
	---- Gear: 14+11+10+10 = 45

	-- Weaponskill sets
	--sets.precast.RA.Flurry = sets.precast.RA

	-- Default set for any weaponskill that isn't any more specifically defined
	--sets.precast.WS = {ammo="Thew Bomblet",
	--    head="Whirlpool Mask",neck=gear.ElementalGorget,ear1="Bladeborn Earring",ear2="Steelflash Earring",
	--    body="Pillager's Vest +1",hands="Pillager's Armlets +1",ring1="Rajas Ring",ring2="Epona's Ring",
	--    back="Atheling Mantle",waist="Caudata Belt",legs="Manibozho Brais",feet="Iuitl Gaiters +1"}
	--sets.precast.WS.Acc = set_combine(sets.precast.WS, {ammo="Falcon Eye", back="Letalis Mantle"})
	--sets.precast.WS.Acc = set_combine(sets.precast.WS, {neck="Ej Necklace"})
	sets.precast.WS = {
		head={ name="Herculean Helm", augments={'Rng.Acc.+30','Weapon skill damage +1%','DEX+9','Rng.Atk.+14',}},
		body={ name="Herculean Vest", augments={'Rng.Acc.+22 Rng.Atk.+22','Crit.hit rate+1','Rng.Acc.+15',}},
		hands={ name="Carmine Fin. Ga.", augments={'Rng.Atk.+15','"Mag.Atk.Bns."+10','"Store TP"+5',}},
		legs={ name="Herculean Trousers", augments={'Rng.Atk.+17','STR+1','Rng.Acc.+10',}},
		feet={ name="Adhemar Gamashes", augments={'AGI+10','Rng.Acc.+15','Rng.Atk.+15',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Neritic Earring",
		left_ear={ name="Moonshade Earring", augments={'Rng.Acc.+4','TP Bonus +25',}},
		left_ring="Apate Ring",
		right_ring="Rajas Ring",
		back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+9','"Store TP"+10',}},
		--hands="Adhemar Wristbands",
		--ear2="Domin. Earring +1",
		--back=belenus,
		--ring1="Ramuh Ring +1",
		--legs={ name="Samnuha Tights", augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}},
		--legs={ name="Samnuha Tights", augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}},
		--legs="Darraigner's brais",
		--ear1="Jupiter's pearl",
		--ear2="Jupiter's pearl",
		--ear2="Bladeborn Earring",
		--ring1="Tyrant's Ring",
		--ring1="Epona's Ring",
		--ring2="Oneiros Ring",
		--back="Mecisto. Mantle",
	}

	-- fill missing slots with base set --

	sets.precast.WS['Jishnu\'s Radiance'] = set_combine(sets.precast.WS, {
		--head=herchelm_crit,
		--body="Meg. Cuirie +1",
		--hands="Mummu Wrists +1",
		--legs="Mummu Kecks +1",
		--feet=hercboots_cdmg,
		--neck="Fotia Gorget",
		--waist="Fotia Belt",
		--left_ear="Mache Earring",
		--left_ear="Ishvara Earring",
		--right_ear=moonshade,
		--left_ring="Begrudging Ring",
		--right_ring="Apate Ring",
		--back=belenusjish,
	})
	sets.Jishnus = sets.precast.WS['Jishnu\'s Radiance']
	sets.precast.WS['Jishnu\'s Radiance'].Fodder = set_combine(sets.Jishnus, {
		head=ah_head,
		--body="Abnoba Kaftan",
		--legs="Jokushu Haidate",
	})
	sets.precast.WS['Jishnu\'s Radiance'].Acc = set_combine(sets.Jishnus, {
		--body="Sayadio's Kaftan",
	})
	sets.precast.WS['Jishnu\'s Radiance'].AccExtreme = set_combine(sets.Jishnus, {
		--main="Perun",
		--hands="Adhemar Wristbands",
		--neck="Erudit. Necklace",
		--left_ear="Enervating Earring",
		--right_ear="Volley Earring",
		--right_ear="Neritic Earring",
		--right_ear=moonshade,
		--ring1="Hajduk Ring",
		--ring2="Cacoethic Ring +1",
		--feet=p_feet,
		--back="Quarrel Mantel"
		--neck="Gaudryi Necklace",
		--head=herchelm_crit,
		--neck="Iskur Gorget",
		--body=hercvest_racc,
		--legs=herctrou_cdmg,
		--back=belenus
	})


	sets.ApexArrow = {
		--body="Sayadio's Kaftan",
		--body=hercvest_racc,
		--hands="Kobo Kote",
		--ring1="Hajduk Ring",
		--ring2="Cacoethic Ring +1",
	}
	sets.precast.WS['Apex Arrow'] = set_combine(sets.precast.WS, sets.ApexArrow)
	sets.precast.WS['Apex Arrow'].Acc = set_combine(sets.ApexArrow, {
		--body="Sayadio's Kaftan",
	})
	sets.precast.WS['Apex Arrow'].AccExtreme = set_combine(sets.ApexArrow, {
		--body="Sayadio's Kaftan",
	})
	--sets.precast.WS['Apex Arrow'].Mid = set_combine(sets.precast.WS.Mid, sets.ApexArrow)
	--sets.precast.WS['Apex Arrow'].Acc = set_combine(sets.precast.WS.Acc, sets.ApexArrow)

	sets.RefulgentArrow = {
	}
	sets.precast.WS['Refulgent Arrow'] = set_combine(sets.precast.WS, sets.RefulgentArrow)
	sets.precast.WS['Refulgent Arrow'].Acc = set_combine(sets.RefulgentArrow, {
		--body="Sayadio's Kaftan",
	})
	sets.precast.WS['Refulgent Arrow'].AccExtreme = set_combine(sets.RefulgentArrow, {
		--body="Sayadio's Kaftan",
		--head=herchelm_agi,
		--neck="Iskur Gorget",
		--body=hercvest_racc,
		--back=belenus
	})
	--sets.precast.WS['Refulgent Arrow'].Mid = set_combine(sets.precast.WS.Mid, sets.RefulgentArrow)
	--sets.precast.WS['Refulgent Arrow'].Acc = set_combine(sets.precast.WS.Acc, sets.RefulgentArrow)

	-- AGI WS --
--	sets.AGIWS = {
--		head=herchelm_agiws,
--		body="Amini Caban +1",
--		neck="Marked Gorget",
--		hands="Kobo Kote",
--		left_ear="Neritic Earring",
--		right_ear=moonshade,
--		left_ring="Garuda Ring +1",
--		right_ring="Apate Ring",
--		legs="Amini Brague +1", 
--		feet=ah_feet,
--		waist="Ponente Sash",
--		--back=belenuswsd
--		back=belenuswsdagi,
--		--hands="Adhemar Wristbands",
--		--right_ear="Infused Earring",
--	}
	sets.AGIWS = {
		--head=herchelm_rwsd,
		--body=hercvest_rwsd,
		--hands="Meghanada Gloves +1",
		--legs=herctrou_rwsd,
		--feet=hercboots_rwsd,
		neck="Fotia Gorget",
		waist="Fotia Belt",
		--left_ear="Ishvara Earring",
		--right_ear=moonshade,
		--left_ring="Dingir Ring",
		--right_ring="Garuda Ring +1",
		--back=belenuswsdagi,
		--body=hercvest_racc,
		--hands="Kobo Kote",
		--feet=ah_feet,
	}
	sets.AGIWS = set_combine(sets.precast.WS, sets.AGIWS)
	sets.AGIWS_Acc = set_combine(sets.AGIWS, {
		--body=hercvest_racc,
		--legs=herctrou_agi,
	})
	sets.AGIWS_AccExtreme = set_combine(sets.AGIWS_Acc, {
		--head=herchelm_agi,
		--body=hercvest_racc,
		--hands="Meg. Gloves +1",
		--legs=ah_legs2,
		--feet=hercboots_agi,
		--neck="Fotia Gorget",
		--neck="Iskur Gorget",
		--waist="Fotia Belt",
		--waist="Kwahu Kachina Belt",
		--left_ear="Telos Earring",
		--right_ear=moonshade,
		--right_ear="Enervating Earring",
		--left_ring="Hajduk Ring +1",
		--right_ring="Cacoethic Ring +1",

	})
	sets.LastStand = { 
		--feet=hercboots_agi
	}
	sets.precast.WS['Last Stand'] = set_combine(sets.AGIWS, sets.LastStand)
	sets.precast.WS['Last Stand'].Fodder = set_combine(sets.AGIWS, sets.LastStand)
	sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'],sets.AGIWS_Acc)
	sets.precast.WS['Last Stand'].AccExtreme = set_combine(sets.precast.WS['Last Stand'].Acc, sets.AGIWS_AccExtreme)
	sets.precast.WS['Last Stand'].threehit = sets.precast.WS['Last Stand']
--	sets.precast.WS['Last Stand'].threehit = {
--		head=arc_head,
--		neck="Fotia Gorget",
--		ear1="Telos Earring",
--		ear2=moonshade,
--		body=hercvest_racc,
--		hands="Amini Glovelettes +1",
--		ring1="Apate Ring",
--		ring2="Rajas Ring",
--		waist="Fotia Belt",
--		legs=ah_legs2,
--		feet=hercboots_agi,
--		back=belenuswsdagi,
--	}
	sets.precast.WS['Last Stand'].Fodder = {
		--head={ name="Arcadian Beret +1", augments={'Enhances "Recycle" effect',}},
		--neck="Iskur Gorget",
		--body=p_body,
		--hands="Amini Glovelettes +1",
		--left_ear="Telos Earring",
		--right_ear="Dedition Earring",
		--left_ring="Rajas Ring",
		--right_ring="Apate Ring",
		--waist="Yemaya Belt",
		--legs="Amini Brague +1",
		--feet="Tatena. Sune.",
		--back=belenus
	}


	sets.Slugshot = {
	}
	sets.precast.WS['Slugshot'] = set_combine(sets.AGIWS, sets.Slugshot)
	sets.precast.WS['Slugshot'].Acc = set_combine(sets.precast.WS['Slugshot'], {
	})
	sets.precast.WS['Slugshot'].AccExtreme = set_combine(sets.precast.WS['Slugshot'].Acc, sets.AGIWS_AccExtreme)

	sets.Detonator = {
	}
	sets.precast.WS['Detonator'] = set_combine(sets.AGIWS, sets.Detonator)
	sets.precast.WS['Detonator'].Acc = set_combine(sets.precast.WS['Detonator'], {
	})
	sets.precast.WS['Detonator'].AccExtreme = set_combine(sets.precast.WS['Detonator'].Acc, sets.AGIWS_AccExtreme)

	sets.NumbingShot = {
	}
	sets.precast.WS['Numbing Shot'] = set_combine(sets.AGIWS, sets.NumbingShot)
	sets.precast.WS['Numbing Shot'].Acc = set_combine(sets.precast.WS['Numbing Shot'], {
	})
	sets.precast.WS['Numbing Shot'].AccExtreme = set_combine(sets.precast.WS['Numbing Shot'].Acc, sets.AGIWS_AccExtreme)

	sets.HeavyShot = {
	}
	sets.precast.WS['Heavy Shot'] = set_combine(sets.AGIWS, sets.HeavyShot)
	sets.precast.WS['Heavy Shot'].Acc = set_combine(sets.precast.WS['Heavy Shot'], {
	})
	sets.precast.WS['Heavy Shot'].AccExtreme = set_combine(sets.precast.WS['Heavy Shot'].Acc, sets.AGIWS_AccExtreme)

	sets.BlastShot = {
	}
	sets.precast.WS['Blast Shot'] = set_combine(sets.AGIWS, sets.BlastShot)
	sets.precast.WS['Blast Shot'].Acc = set_combine(sets.precast.WS['Blast Shot'], {
	})
	sets.precast.WS['Blast Shot'].AccExtreme = set_combine(sets.precast.WS['Blast Shot'].Acc, sets.AGIWS_AccExtreme)

	sets.HotShot = {
	}
	sets.precast.WS['Hot Shot'] = set_combine(sets.AGIWS, sets.HotShot)
	sets.precast.WS['Hot Shot'].Acc = set_combine(sets.precast.WS['Hot Shot'], {
	})
	sets.precast.WS['Hot Shot'].AccExtreme = set_combine(sets.precast.WS['Hot Shot'].Acc, sets.AGIWS_AccExtreme)

	sets.SniperShot = {
	}
	sets.precast.WS['Sniper Shot'] = set_combine(sets.AGIWS, sets.SniperShot)
	sets.precast.WS['Sniper Shot'].Acc = set_combine(sets.precast.WS['Sniper Shot'], {
	})
	sets.precast.WS['Sniper Shot'].AccExtreme = set_combine(sets.precast.WS['Sniper Shot'].Acc, sets.AGIWS_AccExtreme)

	sets.SplitShot = {
	}
	sets.precast.WS['Split Shot'] = set_combine(sets.AGIWS, sets.SplitShot)
	sets.precast.WS['Split Shot'].Acc = set_combine(sets.precast.WS['Split Shot'], {
	})
	sets.precast.WS['Split Shot'].AccExtreme = set_combine(sets.precast.WS['Split Shot'].Acc, sets.AGIWS_AccExtreme)

	--Archery AGI WS--
	sets.FlamingArrow = {
	}
	sets.precast.WS['Flaming Arrow'] = set_combine(sets.AGIWS, sets.FlamingArrow)
	sets.precast.WS['Flaming Arrow'].Acc = set_combine(sets.precast.WS['Flaming Arrow'], {
	})
	sets.precast.WS['Flaming Arrow'].AccExtreme = set_combine(sets.precast.WS['Flaming Arrow'], sets.AGIWS_AccExtreme)

	sets.PiercingArrow = {
	}
	sets.precast.WS['Piercing Arrow'] = set_combine(sets.AGIWS, sets.PiercingArrow)
	sets.precast.WS['Piercing Arrow'].Acc = set_combine(sets.precast.WS['Piercing Arrow'], {
	})
	sets.precast.WS['Piercing Arrow'].AccExtreme = set_combine(sets.precast.WS['Piercing Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.DullingArrow = {
	}
	sets.precast.WS['Dulling Arrow'] = set_combine(sets.AGIWS, sets.DullingArrow)
	sets.precast.WS['Dulling Arrow'].Acc = set_combine(sets.precast.WS['Dulling Arrow'], {
	})
	sets.precast.WS['Dulling Arrow'].AccExtreme = set_combine(sets.precast.WS['Dulling Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.Sidewinder = {
	}
	sets.precast.WS['Sidewinder'] = set_combine(sets.AGIWS, sets.Sidewinder)
	sets.precast.WS['Sidewinder'].Acc = set_combine(sets.precast.WS['Sidewinder'], {
	})
	sets.precast.WS['Sidewinder'].AccExtreme = set_combine(sets.precast.WS['Sidewinder'].Acc, sets.AGIWS_AccExtreme)

	sets.BlastArrow = {
	}
	sets.precast.WS['Blast Arrow'] = set_combine(sets.AGIWS, sets.BlastArrow)
	sets.precast.WS['Blast Arrow'].Acc = set_combine(sets.precast.WS['Blast Arrow'], {
	})
	sets.precast.WS['Blast Arrow'].AccExtreme = set_combine(sets.precast.WS['Blast Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.ArchingArrow = {
	}
	sets.precast.WS['Arching Arrow'] = set_combine(sets.AGIWS, sets.ArchingArrow)
	sets.precast.WS['Arching Arrow'].Acc = set_combine(sets.precast.WS['Arching Arrow'], {
	})
	sets.precast.WS['Arching Arrow'].AccExtreme = set_combine(sets.precast.WS['Arching Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.EmpyrealArrow = {
	}
	sets.precast.WS['Empyreal Arrow'] = set_combine(sets.AGIWS, sets.EmpyrealArrow)
	sets.precast.WS['Empyreal Arrow'].Acc = set_combine(sets.precast.WS['Empyreal Arrow'], {
	})
	sets.precast.WS['Empyreal Arrow'].AccExtreme = set_combine(sets.precast.WS['Empyreal Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.ApexArrow = {
	}
	sets.precast.WS['Apex Arrow'] = set_combine(sets.AGIWS, sets.ApexArrow)
	sets.precast.WS['Apex Arrow'].Acc = set_combine(sets.precast.WS['Apex Arrow'], sets.AGIWS_Acc)
	sets.precast.WS['Apex Arrow'].AccExtreme = set_combine(sets.precast.WS['Apex Arrow'].Acc, sets.AGIWS_AccExtreme)

	sets.Coronach = {
		ammo={"Eradicating Bullet"},
		--body=hercvest_racc,
		--head=herchelm_rwsd,
		--body=hercvest_rwsd,
		--left_ear="Telos Earring",
		--left_ear="Infused Earring",
		--left_ear="Dawn Earring",
		--left_ear="Telos Earring",
		--right_ear="Ishvara Earring",
		--left_ring="Dingir Ring",
		--right_ring="Apate Ring",
		--right_ring="Garuda Ring +1",
		--left_ring="Ifrit Ring",
		--legs=herctrou_rwsd,
		--feet=hercboots_rwsd,
	}
	sets.precast.WS['Coronach'] = set_combine(sets.AGIWS, sets.Coronach)
	sets.precast.WS['Coronach'].Acc = set_combine(sets.precast.WS['Coronach'], sets.AGIWS_Acc)
	sets.precast.WS['Coronach'].AccExtreme = set_combine(sets.precast.WS['Coronach'].Acc, sets.AGIWS_AccExtreme)

	-- MELEE WS --
	sets.precast.MeleeWS = {
	}
	--multi hit , crit rate great here, fTP carries through on all hits
	sets.Evisceration = {
	}
	sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, sets.Evisceration)
	sets.precast.WS['True Strike'] = sets.engaged.AccExtreme

	-- MAGIC WS --
	sets.precast.MagicWS = {
		head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+23','STR+3','"Store TP"+3','Accuracy+3 Attack+3','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		body={ name="Samnuha Coat", augments={'Mag. Acc.+12','"Mag.Atk.Bns."+12','"Dual Wield"+3',}},
		hands={ name="Carmine Fin. Ga.", augments={'Rng.Atk.+15','"Mag.Atk.Bns."+10','"Store TP"+5',}},
		legs={ name="Herculean Trousers", augments={'STR+5','"Subtle Blow"+8','"Treasure Hunter"+1','Mag. Acc.+14 "Mag.Atk.Bns."+14',}},
		feet={ name="Adhemar Gamashes", augments={'AGI+10','Rng.Acc.+15','Rng.Atk.+15',}},
		neck="Sanctity Necklace",
		left_ear="Friomisi Earring",
		right_ear="Hecate's Earring",
		left_ring="Acumen Ring",
		right_ring="Mephitas's Ring",
		back="Izdubar Mantle",
		--waist="Fotia Belt",
		--back="Toro Cape",
		--back="Belenus's cape",
		--body="Samnuha Coat",
		--legs="Gyve Trousers",
	}
	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.MagicWS, {
	})
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.MagicWS, {
	})

	sets.precast.WS['Wildfire'] = set_combine(sets.precast.MagicWS, {
	})

	sets.precast.WS['Trueflight'] = set_combine(sets.precast.MagicWS, {
		--ring1="Garuda Ring",
		--ring1="Garuda Ring",
		--ring1="Dingir Ring",
		--ring2="Garuda Ring +1",
		--ring2="Weatherspoon Ring",
		--waist="Ponente Sash"
		waist="Svelt. Gouriz +1"
	})
	sets.precast.WS['Trueflight'].Acc = set_combine(sets.precast.WS['Trueflight'], {
		--ear1="Hermetic Earring",
		--ear2="Digni. Earring",
		--neck="Sanctity Necklace",
		--ring1="Garuda Ring",
		--ring1="Weatherspoon Ring",
		--ring1="Dingir Ring",
		--ring2="Garuda Ring +1",
		--ring2="Weatherspoon Ring",
		--waist="Eschan stone",
	})
	sets.precast.WS['Trueflight'].AccExtreme = set_combine(sets.precast.WS['Trueflight'].Acc, {
		--ring1="Weatherspoon Ring",
		--ring1="Fenrir Ring",
		--waist="Kwahu Kachina Belt",
	})
	sets.precast.WS['Trueflight'].Acc=sets.precast.WS['Trueflight']
	sets.precast.WS['Trueflight'].AccExtreme=sets.precast.WS['Trueflight']


	sets.precast.WS['Trueflight'].AccKeep = set_combine(sets.precast.WS['Trueflight'], {
		--ear1="Hermetic Earring",
		--ear2="Digni. Earring",
		--ring1="Garuda Ring",
		--ring1="Weatherspoon Ring",
		--ring1="Dingir Ring",
		--ring2="Garuda Ring +1",
		--ring2="Weatherspoon Ring",
		--waist="Eschan stone",
	})
	sets.precast.WS['Trueflight'].AccExtremeKeep = set_combine(sets.precast.WS['Trueflight'].AccKeep, {
		--ring1="Weatherspoon Ring",
		--ring1="Fenrir Ring",
		--waist="Kwahu Kachina Belt",
	})

	-- Currently disabled high magic acc trueflight when in ranged acc and acc extreme mode you can renable it below --
	--sets.precast.WS['Trueflight'].Acc=sets.precast.WS['Trueflight'].AccKeep
	--sets.precast.WS['Trueflight'].AccExtreme=sets.precast.WS['Trueflight'].AccExtremeKeep
	
	--------------------------------------
	-- Midcast sets
	--------------------------------------

	--    sets.midcast.FastRecast = {
	--        head="Whirlpool Mask",ear2="Loquacious Earring",
	--        back=cannycape,legs="Kaabnax Trousers",feet="Iuitl Gaiters +1"}

	-- Specific spells
	--    sets.midcast.Utsusemi = {
	--        head="Whirlpool Mask",neck="Ej Necklace",ear2="Loquacious Earring",
	--        body="Pillager's Vest +1",hands="Pillager's Armlets +1",ring1="Beeline Ring",
	--        back=cannycape,legs="Kaabnax Trousers",feet="Iuitl Gaiters +1"}
	--

	--------------------------------------
	-- Town sets
	--------------------------------------
	--When you zone into mog gardens, what you wear
	sets.farmer = { 
		--main="Hoe",
		--body="Overalls",
		--hands="Work gloves",
		--legs="",
		--feet="Herald's Gaiters"
		--feet="Thatch Boots"
	}
	
	sets.crafting = {
		--head="Magnifying Specs.",
		--left_ring="Artificer's Ring",
		--neck="Weaver's Torque",
		--left_ring="Craftmaster's Ring",
		--right_ring="Orvail Ring",
		--right_ring="Artificer's Ring",
		--body="Weaver's Apron",
	}


	--For more movement in Adoulin
	sets.adoulinmovement = { 
		body="Councilor's Garb"
	}


	--------------------------------------
	-- Idle/resting/defense sets
	--------------------------------------

	-- Resting sets
	sets.rangetype = {}
	sets.rangetype.None = {
	}
	sets.rangetype.Bow = {
		range="Fail-Not",
		ammo="Chrono Arrow",
	}
	sets.rangetype.Gun = {
		range="Fomalhaut",
		ammo="Chrono bullet",
	}
	sets.rangetype.MartialGun = {
		range="Martial Gun",
		ammo="Chrono bullet",
	}
	sets.rangetype.Anni = {
		range="Annihilator",
		ammo="",
	}
	sets.bullets = {}
	sets.bullets.Racc = {
		ammo="",
	}
	sets.rangetype.MachineCrossbow = {
		range="Atalanta",
		ammo="Bloody Bolt",
		--ammo="Abrasion Bolt",
	}
	sets.rangetype.Crossbow = {
		range="Gastraphetes",
		ammo="Quelling Bolt",
		--range="Tsoabichi Crossbow",
		--ammo="Bloody Bolt",
	}
--	sets.rangetype.Shortbow = {
--		range="Paloma Bow",
--		ammo="Chrono Arrow",
--	}
	sets.defdown = {
		ammo="Abrasion Bolt",
	}
	sets.rangetype.Crossbow2 = {
		--range="Wochowsen",
		--ammo="Bloody Bolt",
		--ammo="Righteous Bolt",
	}
	sets.rangetype.Throwing = {
		range="Antitail",
		ammo=""
	}
	sets.resting={
		--head="Oce. Headpiece +1",
		--feet="Jute Boots +1",
		--neck="Wiglen Gorget",
		--waist="Windbuffet Belt +1",
		--ring1="Sheltered Ring",
		--ring2="Paguroidea Ring",
		--back="Solemnity Cape"
		--   range="Snakeeye",
		--back="Engulfer Cape +1"
		--back=cannycape,
		--back="Mecistopins mantle",
	}

	-- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

	sets.idle ={
		--main/offhand determined by rangedmode
		head={ name="Arcadian Beret +1", augments={'Enhances "Recycle" effect',}},
		body="Amini Caban +1",
		hands={ name="Carmine Fin. Ga.", augments={'Rng.Atk.+15','"Mag.Atk.Bns."+10','"Store TP"+5',}},
		legs={ name="Herculean Trousers", augments={'Rng.Atk.+17','STR+1','Rng.Acc.+10',}},
		feet="Hippo. Socks +1",
		neck="Marked Gorget",
		waist="Kwahu Kachina Belt",
		left_ear="Volley Earring",
		right_ear="Neritic Earring",
		left_ring="Apate Ring",
		right_ring="Defending Ring",
		back="Solemnity Cape",
		--neck="Wiglen Gorget",
		--hands="Adhemar Wristbands",
		--body="Sayadio's Kaftan",
		--back="Mollusca Mantle"--5
		--back="Lutian Cape",
		--neck="Ej Necklace",
		--head="Oce. Headpiece +1",
		--body="Adhemar Jacket",
		--body="Mekosuchinae harness",
		--legs={ name="Samnuha Tights", augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}},
		--waist="Windbuffet Belt +1",
		--ring1="Sheltered Ring",
		--back="Engulfer Cape +1"
		--back="Mecistopins mantle",
		--back="Repulse Mantle",
		--ear2="Neritic earring",
	}
	sets.idle = set_combine(sets.basetp,sets.idle)
	sets.idle.Regen = {
		--ring1="Sheltered Ring",
		--ring2="Paguroidea Ring",
		--ear2="Infused Earring",
		--head="Oce. Headpiece +1",
		--neck="Wiglen Gorget",
	}

	--    sets.idle.Weak = {ammo="Thew Bomblet",
	--        head="Pillager's Bonnet +1",neck="Wiglen Gorget",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
	--        body="Pillager's Vest +1",hands="Pillager's Armlets +1",ring1="Sheltered Ring",ring2="Paguroidea Ring",
	--        back="Shadow Mantle",waist="Flume Belt",legs="Pillager's Culottes +1",feet="Skadi's Jambeaux +1"}


	-- Defense sets

	--    sets.defense.Evasion = {
	--        head="Pillager's Bonnet +1",neck="Ej Necklace",
	--        body="Qaaxo Harness",hands="Pillager's Armlets +1",ring1="Defending Ring",ring2="Beeline Ring",
	--        back=cannycape,waist="Flume Belt",legs="Kaabnax Trousers",feet="Iuitl Gaiters +1"}
	--
	--    sets.defense.PDT = {ammo="Iron Gobbet",
	--        head="Pillager's Bonnet +1",neck="Loricate Torque +1",
	--        body="Iuitl Vest",hands="Pillager's Armlets +1",ring1="Defending Ring",ring2=gear.DarkRing.physical,
	--        back="Iximulew Cape",waist="Flume Belt",legs="Pillager's Culottes +1",feet="Iuitl Gaiters +1"}
	--
	--    sets.defense.MDT = {ammo="Demonry Stone",
	--        head="Pillager's Bonnet +1",neck="Loricate Torque +1",
	--        body="Pillager's Vest +1",hands="Pillager's Armlets +1",ring1="Defending Ring",ring2="Shadow Ring",
	--        back="Engulfer Cape",waist="Flume Belt",legs="Pillager's Culottes +1",feet="Iuitl Gaiters +1"}
	--
	sets.runaway2 = {
		--main="Mafic Cudgel",--10PDT
		--neck="Wiglen Gorget",--6PDT
		--ear2="Infused Earring",
		--ring2="Gelatinous Ring +1",--6PDT
		--ring1="Defending Ring",--10
		--waist="Flume Belt +1",--4PDT
		--legs=herctrou_dt,
		--feet="Jute Boots +1",
		--back="Repulse Mantle"--4PDT
		--back="Solemnity Cape",--4DT
		--neck="Inq. Bead Necklace",
	}
	--38 PDT 10 DT
	sets.damagetaken = {}
	sets.damagetaken.None = {
	}
	sets.damagetaken.DTLight = {
		--ring1="Defending Ring",
		--neck="Loricate Torque +1",
		--back="Mollusca Mantle"
		--ring2="Gelatinous Ring",
		--waist="Flume Belt +1",
		--back="Repulse Mantle"
	}
	sets.damagetaken.DT = {
		--head="Genmei kabuto",--5PDT
		--ring2="Dark Ring",--6MDT 6BDT
		--ring2="Lunette Ring +1",--7MDB 3DT
		--ring1="Defending Ring",--10
		--neck="Loricate Torque +1",--6
		--waist="Flume Belt +1",--4PDT
		--legs=herctrou_dt,--2PDT 3DT
		--feet=hercboots_dt, --2pdt 3DT
		--back="Mollusca Mantle",--5 DT
		--back="Xucau Mantle",--3 DT 100 HP
		--body="Meghanada Cuirie +1",--7PDT
		--hands="Meghanada Gloves +1",--3PDT
		--hands=hercgloves_pdt,--5PDT
		--ear1="Etiolation Earring",--3MDT
		--ear1="Sanare Earring", --4MDB
		--ear2="Spellbreaker Earring", --2MDB
		--back="Engulfer Cape +1"

		--hands="Kurys Gloves", --2
		--neck="Inq. Bead Necklace",
		--neck="Wiglen Gorget",--6
	}
	--DT 10+6+3+5+3+3 = 28
	--PDT 5+4+2+2+7+5+2 = 27
	--MDT 3=3
	--BDT 0
	-- 57 PDT 34 MDT 29 BDT
	sets.damagetaken.DTFull = {
	}
	sets.damagetaken.MagicLight = {
		--ring1="Defending Ring",--10
		--ring2="Vengeful Ring",
		--waist="Engraved belt",
		--neck="Inq. Bead Necklace",
		--back="Engulfer Cape +1"
		--back="Mollusca Mantle",--5
		--neck="Loricate Torque +1",
	}
	sets.damagetaken.PDT = {
	}
	sets.damagetaken.MDT = {
	}
	sets.damagetaken.MagicEvasion = {
		--neck="Inq. Bead Necklace",
		--body="Lapidary Tunic",
		--feet="Jute Boots +1",
		--ear1="Sanare Earring",
		--ring1="Defending Ring",
		--ring2="Vengeful Ring",
		--back="Engulfer Cape +1"
		--back="Mollusca Mantle"
	}
	sets.pullmode = {
		--main="Mafic Cudgel", --10
		--sub="Genmei Shield", --10
		--head="Genmei kabuto",--5PDT
		--neck="Loricate Torque +1",--6
		--body="Meghanada Cuirie +1",--7
		--hands="Meghanada Gloves +1",--3
		--left_ear="Etiolation Earring", --3mdt
		--right_ear="Infused Earring",
		--ring2="Gelatinous Ring +1",--7PDT
		--ring1="Defending Ring",--10
		--waist="Flume Belt +1",--4PDT
		--legs=herctrou_dt,
		--feet="Hippomenes socks +1",
		--back="Solemnity Cape"--4
	}
	--DT: 6+10+4+3=23
	--PDT: 5+7+4+2+4+4=26
	--MDT: 3
	


	--------------------------------------
	-- Melee sets
	--------------------------------------
	-- Normal melee group
	--sets.engaged= sets.basetp
	--Caphaste: dw5
	--Cape 4
	--feet 4 + 5
	sets.engaged={
		neck="Sanctity Necklace",
		waist="Windbuffet Belt +1",
		left_ear="Cessance Earring",
		right_ear="Mache Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+9','"Store TP"+10',}},
	}
	sets.engaged = set_combine(sets.basetp,sets.engaged)
	--ring1="Tyrant's Ring",

	-- earrings 7
	-- taeon 23 + 4  = 27
	-- cape 4 --38
	-- sash 5 --43
	-- missing 5 
	-- raiders 3 XOff
	-- blurred 6 XOff

	--Dw4: 30% 
	--No haste magic: dw43
	--Haste samba: dw39
	--Haste1: dw37
	--Haste2: dw26
	--Caphaste: dw5
	--Taeon 27
	--Sash 5
	--Earrings 7
	--Cape 4
	
	sets.hastemode = {}
	-- no dw if not sub nin or dnc
	if player.sub_job == 'NIN' or player.sub_job=='DNC' then
		sets.TaeonDW = {
			--head={ name="Taeon Chapeau", augments={'Accuracy+15 Attack+15','"Dual Wield"+5','STR+4',}},
			--body={ name="Taeon Tabard", augments={'Accuracy+15 Attack+15','"Dual Wield"+5','STR+4 AGI+4',}},
			--hands={ name="Taeon Gloves", augments={'Accuracy+18 Attack+18','"Dual Wield"+4','STR+8',}},
			--legs={ name="Taeon Tights", augments={'Accuracy+17 Attack+17','"Dual Wield"+4','STR+2 DEX+2',}},
			--feet={ name="Taeon Boots", augments={'Accuracy+17 Attack+17','"Dual Wield"+5','STR+4 DEX+4',}},
		}
		--Max: acc 100 att 100 STR 35 DEX 35
		--At: acc 82 att 82 STR 18 DEX 10
		--Missing: acc 18 att 18 STR 17 DEX 25
		sets.hastemode.NoHaste={ -- need 43, at 45
			--taeon: 18
			--waist="Reiki Yotai", --7
			--hands={ name="Floral Gauntlets", augments={'Rng.Acc.+13','Accuracy+14','"Triple Atk."+1','Magic dmg. taken -2%',}},

			--body=ah_body,--5
			--ear1="Eabani Earring",--4
			--ear2="Suppanomimi",--5
			--back=lutiancape,
		}
		sets.hastemode.HasteI={ -- need 37, at 39
			--taeon: 18
			--body=ah_body,--5
			--hands="Floral Gauntlets",--5
			--waist="Reiki Yotai", --7
			--ear1="Eabani Earring",--4
			--ear2="Suppanomimi",--5
		}
		sets.hastemode.HasteII={ -- need 26, at 26
			--taeon: 18 - 4 - 9 = 5 
			--head="Adhemar Bonnet",
			--body=ah_body,--5
			--ear1="Eabani Earring",--4
			ear2="Suppanomimi",--5
			--waist="Reiki Yotai", --7
			legs={ name="Samnuha Tights", augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}},
			--feet=hercboots_ta,
		}
		sets.TaeonDW = set_combine(sets.engaged,sets.TaeonDW)
		sets.hastemode.NoHaste=set_combine(sets.TaeonDW,sets.hastemode.NoHaste)
		sets.hastemode.HasteI=set_combine(sets.TaeonDW,sets.hastemode.HasteI)
		sets.hastemode.HasteII=set_combine(sets.TaeonDW,sets.hastemode.HasteII)
		sets.hastemode.Capped=sets.engaged
	end

	sets.mabdagger={
		--main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
		--sub={ name="Malevolence", augments={'INT+6','Mag. Acc.+7','"Mag.Atk.Bns."+4','"Fast Cast"+3',}},
		--sub={ name="Malevolence", augments={'INT+9','Mag. Acc.+10','"Mag.Atk.Bns."+9','"Fast Cast"+4',}},
	}

	sets.engaged.Acc={
		--head=ah_head,
		--neck="Combatant's Torque",
		--hands="Meghanada Gloves +1",
		--ring1="Epona's Ring",
		--ring2="Rajas Ring",
		--back="Lupine Cape",
		--legs="Meg. Chausses +1",

		--waist="Grunfeld Rope",
		--ring2="Hetairoi Ring",
		--waist="Olseni Belt",
		--range="",
		--ammo="Seething Bomblet",
		--body="Adhemar Jacket",
		--neck="Ej Necklace",
	}
	sets.engaged.Acc=set_combine(sets.engaged,sets.engaged.Acc)
	sets.engaged.AccExtreme={
		--head="Meghanada Visor +1",
		--body="Sayadio's Kaftan",
		--body="Meghanada Cuirie +1",
		--hands="Floral Gauntlets",
		--hands="Meghanada Gloves +1",
		--legs="Meghanda Chausses +1",
		--legs="Meg. Chausses +1",
		--feet=hercboots_acc,
		--neck="Ej Necklace",
		--neck="Combatant's Torque",
		--waist="Olseni Belt",
		--left_ear="Dignitary's earring",
		--left_ear="Telos Earring",
		--right_ear="Zennaroi Earring",
		--left_ring="Cacoethic Ring +1",
		--right_ring="Ramuh Ring +1",
		--back="Ground. Mantle +1",
		--head="Skulker's Bonnet +1",
		--body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		--hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
	}
	sets.engaged.AccExtreme=set_combine(sets.engaged,sets.engaged.AccExtreme)
	sets.engaged.Fodder={
		--head={ name="Adhemar Bonnet", augments={'STR+10','DEX+10','Attack+15',}},

	}
	sets.engaged.Fodder = set_combine(sets.engaged,sets.engaged.Fodder)

	sets.engaged.kclub = {
		--sub="Nusku Shield",
		--head={ name="Pursuer's Beret", augments={'Rng.Atk.+15','Enmity-6','"Subtle Blow"+7',}},
		--body="Tatena. Harama. +1",
		--hands={ name="Adhemar Wristbands", augments={'STR+10','DEX+10','Attack+15',}},
		--legs="Amini Brague +1",
		--feet="Tatena. Sune.",
		--neck="Erudit. Necklace",
		--waist="Olseni Belt",
		--left_ear="Telos Earring",
		--right_ear="Dedition Earring",
		--left_ring="Petrov Ring",
		--right_ring="Rajas Ring",
		--back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','"Store TP"+10',}},
	}
	sets.engaged.kclub = sets.engaged.AccExtreme

	--sets.buff.Barrage = {
		--body="Orion Jerkin +1",
		--legs="Amini Brague +1", 
		--legs={ name="Desultor Tassets", augments={'"Phantom Roll" ability delay -5','"Barrage"+1',}},

--		head={ name="Arcadian Beret +1", augments={'Enhances "Recycle" effect',}},
--		neck="Ocachi Gorget",
--		hands="Orion Bracers +1",
--		body="Sayadio's Kaftan",
--		left_ring="Apate Ring",
--		right_ring="Haverton Ring",--S:6
--		--right_ring="Rajas Ring",
--		ear1="Enervating earring",
--		ear2="Neritic earring",
--		feet="Adhemar Gamashes",
--		waist="Yemaya Belt",
--		back=lutiancape,

		--neck="Rancor Collar",
		--ear1="Flame Pearl",
		--ear2="Flame Pearl",
--		head="Arcadian Beret +1",
--		--hands={ name="Adhemar Wristbands", augments={'AGI+10','Rng.Acc.+15','Rng.Atk.+15',}},
--		hands="Orion Bracers +1",
--		neck="Gaudryi Necklace",
--		waist="Yemaya Belt",
--		left_ear="Enervating Earring",
--		right_ear="Neritic Earring",
--		left_ring="Haverton Ring",
--		right_ring="Cacoethic Ring +1",
--		back=belenus
	--}
	-- placeholder until I can get to it
	--sets.buff.Barrage.Mid = sets.buff.Barrage
	--sets.buff.Barrage.Acc = sets.buff.Barrage

	sets.buff.Camouflage =  {body=""}

	sets.keep5 = {
		--body=arc_body
	}
	sets.Overkill =  {
		--body="Arcadian Jerkin +1"
	}
	sets.Overkill.Preshot = set_combine(sets.precast.RA, sets.Overkill)
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_precast(spell, action, spellMap, eventArgs)
end

function job_post_precast(spell, action, spellMap, eventArgs)
	if state.Buff.Camouflage then
		equip(sets.buff.Camouflage)
	--elseif state.Buff.Overkill then
		--equip(sets.Overkill.Preshot)
	end
	--log_data_structure(midshot_real)
	if spell.action_type=="Ranged Attack" then
		gastra_preshot = false
		if(player.equipment.range == "Gastraphetes") then 
			gastra_preshot = true
		end
		if not midshot_real then
			if buffactive['Flurry'] then
				if state.flurrymode.value == 'FlurryII' then
					if not gastra_preshot then
						equip(sets.precast.RA.Flurry2)
					else
						equip(sets.precast.RA.Flurry2.Gastra)
					end
				else
					if not gastra_preshot then
						equip(sets.precast.RA.Flurry)
					else
						equip(sets.precast.RA.Flurry.Gastra)
					end
				end
				--add_to_chat(122,"Flurry found")
			else
					if not gastra_preshot then
						equip(sets.precast.RA)
					else
						equip(sets.precast.RA.Gastra)
					end
				--equip(sets.precast.RA.noFlurry)
				--add_to_chat(122,"No flurry")
			end
		end
	end
	--print('weather mode')
	if spell.english == "Trueflight" and (buffactive['Aurorastorm'] or buffactive['Aurorastorm II']) then
		--print('weather mode')
		equip({waist="Hachirin-no-obi"})
	end
	if spell.english == "Wildfire" and (buffactive['Firestorm']) then
		equip({waist="Hachirin-no-obi"})
	end
	--print(player.tp)
	if spell.english == "Trueflight" and player.tp > 2850 then
		equip({ear2="Ishvara Earring"})
	end
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
	--    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
	--        equip(sets.TreasureHunter)
	--    end
	if spell.name == 'Ranged' then
		--print('ranged')
		if buffactive.Barrage then
			--print('equipping barrage')
			equip(sets.buff.Barrage)
		end
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	-- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
	if spell.type == 'WeaponSkill' and not spell.interrupted then
		state.Buff['Sneak Attack'] = false
		state.Buff['Trick Attack'] = false
		state.Buff['Feint'] = false
	end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
hastetbl = S{'haste','march','geo-haste','indi-haste','embrava','haste samba','aftermath','mighty guard'}
function job_buff_change(buff, gain)
	buff_lower = buff:lower()
	--print(buff_lower)
	if hastetbl:contains(buff_lower) then
		--print('buff '..buff)
		check_haste_level()
		handle_equipping_gear(player.status)
		--handle_equipping_gear(player.status)
	end
	if state.Buff[buff] ~= nil then
		if not midaction() then

			handle_equipping_gear(player.status)
		end
	end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
	local wsmode
	if state.RangedMode.current == 'Normal' then 
	elseif state.RangedMode.current == "Acc" then
		wsmode = 'Acc'
	elseif state.RangedMode.current == 'AccExtreme' then
		wsmode = 'AccExtreme'
	end

	if state.Buff['Sneak Attack'] then
		wsmode = 'SA'
	end
	if state.Buff['Trick Attack'] then
		wsmode = (wsmode or '') .. 'TA'
	end
	return wsmode
end

-- Check for proper ammo when shooting or weaponskilling
function check_ammo(spell, action, spellMap, eventArgs)
	-- Filter ammo checks depending on Unlimited Shot
	if state.Buff['Unlimited Shot'] then
		if player.equipment.ammo ~= U_Shot_Ammo[player.equipment.range] then
			if player.inventory[U_Shot_Ammo[player.equipment.range]] or player.wardrobe[U_Shot_Ammo[player.equipment.range]] then
				add_to_chat(122,"Unlimited Shot active. Using custom ammo.")
				equip({ammo=U_Shot_Ammo[player.equipment.range]})
			elseif player.inventory[DefaultAmmo[player.equipment.range]] or player.wardrobe[DefaultAmmo[player.equipment.range]] then
				add_to_chat(122,"Unlimited Shot active but no custom ammo available. Using default ammo.")
				equip({ammo=DefaultAmmo[player.equipment.range]})
			else
				add_to_chat(122,"Unlimited Shot active but unable to find any custom or default ammo.")
			end
		end
	else
		if player.equipment.ammo == U_Shot_Ammo[player.equipment.range] and player.equipment.ammo ~= DefaultAmmo[player.equipment.range] then
			if DefaultAmmo[player.equipment.range] then
				if player.inventory[DefaultAmmo[player.equipment.range]] then
					add_to_chat(122,"Unlimited Shot not active. Using Default Ammo")
					equip({ammo=DefaultAmmo[player.equipment.range]})
				else
					add_to_chat(122,"Default ammo unavailable.  Removing Unlimited Shot ammo.")
					equip({ammo=empty})
				end
			else
				add_to_chat(122,"Unable to determine default ammo for current weapon.  Removing Unlimited Shot ammo.")
				equip({ammo=empty})
			end
		elseif player.equipment.ammo == 'empty' then
			if DefaultAmmo[player.equipment.range] then
				if player.inventory[DefaultAmmo[player.equipment.range]] then
					add_to_chat(122,"Using Default Ammo")
					equip({ammo=DefaultAmmo[player.equipment.range]})
				else
					add_to_chat(122,"Default ammo unavailable.  Leaving empty.")
				end
			else
				add_to_chat(122,"Unable to determine default ammo for current weapon.  Leaving empty.")
			end
		elseif player.inventory[player.equipment.ammo].count < 15 then
			add_to_chat(122,"Ammo '"..player.inventory[player.equipment.ammo].shortname.."' running low ("..player.inventory[player.equipment.ammo].count..")")
		end
	end
end

-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
	-- Check for SATA when equipping gear.  If either is active, equip
	-- that gear specifically, and block equipping default gear.
	check_buff('Haste', eventArgs)
end


function check_haste_level()
	--pr(buffactive)
	--33 is haste 1 and haste 2 580 is indi and geo haste
	hastelevel = 0
	if buffactive[33] and hastetype==1 then
		hastelevel=hastelevel+15
		add_to_chat(122,'Haste I detected')
	elseif buffactive[33] and hastetype==2 then
		hastelevel=hastelevel+30
		add_to_chat(122,'Haste II detected')
	end
	if hastesambatype==1 then
		hastelevel=hastelevel+5
		add_to_chat(122,'Haste samba detected')
	end
	if hastesambatype==2 then
		hastelevel=hastelevel+10
		add_to_chat(122,'Haste samba (dnc) detected')
	end
	if buffactive.march ==2 then --assuming song +3 at least
		hastelevel=hastelevel+25
		--add_to_chat(122,'2 marches detected')
	elseif buffactive.march ==1 then
		hastelevel=hastelevel+15
		--add_to_chat(122,'1 march detected')
	end
	if buffactive[580] then --assuming non idris, indi/geo haste
		hastelevel=hastelevel+33
		--add_to_chat(122,'Geo Haste detected')
	end
	if buffactive['Mighty Guard'] then
		hastelevel=hastelevel+15
		--add_to_chat(122,'Mighty Guard detected')
	end
	if buffactive['Slow'] then
		hastelevel=hastelevel-15
		add_to_chat(122,'Slow Detected')
	end
	add_to_chat(122,'Haste level '..hastelevel)

	--    if buffactive[579] then --mighty guard
	--	    hastelevel=hastelevel+15
	--	    add_to_chat(122,'Mighty Guard detected')
	--    end
	--add_to_chat(122,'Haste number '..hastelevel)

	if hastelevel == 0 then
		add_to_chat(122,'Haste level set to NoHaste')
		state.hastemode:set('NoHaste')
	elseif hastelevel >= 40 then
		add_to_chat(122,'Haste level set to Capped')
		state.hastemode:set('Capped')
	elseif hastelevel >= 25 then
		add_to_chat(122,'Haste level set to HasteII')
		state.hastemode:set('HasteII')
	elseif hastelevel >= 15 then
		add_to_chat(122,'Haste level set to HasteI')
		state.hastemode:set('HasteI')
	end
end

function customize_idle_set(idleSet)
	if player.hpp < 80 then
		idleSet = set_combine(idleSet, sets.ExtraRegen)
	end
	--add_to_chat(122,'Idle Set ')

	if state.RangedMode.current == 'Normal' then 
		idleSet = set_combine(sets.midcast.RA,idleSet) 
	else 
		idleSet = set_combine(sets.midcast.RA[state.RangedMode.current],idleSet) 
	end
	if state.rangetype.value ~= "None" then idleSet = set_combine(idleSet,sets.rangetype[state.rangetype.value]) end
	if state.idlemode.value ~= "Normal" then idleSet = set_combine(idleSet,sets.idle[state.idlemode.value]) end
	if state.damagetaken.value ~= "None" then idleSet = set_combine(idleSet,sets.damagetaken[state.damagetaken.value]) end
	if state.runaway2.current == 'on' then idleSet = set_combine(idleSet,sets.runaway2) end
	if mainswap then
		mainswap=0
		enable('main','sub')
		equip(sets.mainweapon[state.mainweapon.value])
		disable('main','sub')
	end
	if state.pullmode.current == 'on' then 
		enable('main','sub')
		idleSet = set_combine(idleSet,sets.pullmode) 
		equip(idleSet)
		disable('main','sub')
	end

	
	if state.cpmode.current == 'on' then idleSet = set_combine(idleSet,sets.cpmode) end
	if areas.Cities:contains(world.area) and world.area:contains("Adoulin") then
		idleSet = set_combine(idleSet, sets.adoulinmovement)
	elseif  world.area:contains("Mog Garden") then
		enable('main','sub')
		idleSet = set_combine(idleSet, sets.farmer)
		--windower.send_command('input /ja Release <me>;wait 2;input /ma '..tosummon..' <me>')
	end


	return idleSet
end

mainswap = 1
function customize_melee_set(meleeSet)
	meleeSet = set_combine(meleeSet,sets.hastemode[state.hastemode.value])
	if state.RangedMode.current == 'Normal' then meleeSet = set_combine(sets.midcast.RA,meleeSet) 
	else meleeSet = set_combine(sets.midcast.RA[state.RangedMode.current],meleeSet) end

	if state.rangetype.value ~= "None" then meleeSet = set_combine(meleeSet,sets.rangetype[state.rangetype.value]) end
	if rangeswap then
		rangeswap=0
		equip(sets.rangetype[state.rangetype.value])
		if state.rangetype.value == "None" then 
			enable('ranged','ammo')
		else
			disable('ranged','ammo')
		end
	end
	if state.OffenseMode.current ~= 'Normal' then meleeSet = set_combine(meleeSet,sets.engaged[state.OffenseMode.current]) end
	if state.damagetaken.value ~= "None" then meleeSet = set_combine(meleeSet,sets.damagetaken[state.damagetaken.value]) end
	if state.runaway2.current == 'on' then meleeSet = set_combine(meleeSet,sets.runaway2) end
	--if state.hasteknife.current == 'on' then meleeSet = set_combine(meleeSet,sets.hasteknife) end
	--if state.mabdagger.current == 'on' then meleeSet = set_combine(meleeSet,sets.mabdagger) end
	if mainswap then
		mainswap=0
		enable('main','sub')
		equip(sets.mainweapon[state.mainweapon.value])
		disable('main','sub')
	end
	if state.pullmode.current == 'on' then 
		enable('main','sub')
		meleeSet = set_combine(meleeSet,sets.pullmode) 
		equip(meleeSet)
		disable('main','sub')
	end
	if state.mainweapon.current == 'KrakenClub' then meleeSet = sets.engaged.kclub end

	--if state.RangedMode.current ~= 'Normal' then meleeSet = set_combine(idleSet,sets.engaged[state.RangedMode.current]) end
	if state.cpmode.current == 'on' then meleeSet = set_combine(meleeSet,sets.cpmode) end

	return meleeSet
end
function customize_resting_set(restingSet)
	if state.cpmode.current == 'on' then restingSet = set_combine(restingSet,sets.cpmode) end
	return restingSet
end


-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
	--th_update(cmdParams, eventArgs)
end
dw = 0;
dtmode = 0;
accmode = 0;
runaway = 0;
rangeswap = 0;
use_dualbox=false
statusammo = S{'Sleep Bolt','Blind Bolt','Bloody Bolt','Abrasion Bolt','Gashing Bolt','Oxidant Bolt','Acid Bolt','Kabura Arrow','Paralysis Arrow','Poison Arrow','Sleep Arrow','Spartun Bullet','Venom Bolt','Righteous Bolt','Holy Bolt','Darkling Bolt','Demon Arrow','Fire Arrow','Earth Arrow','Wind Arrow','Ice Arrow','Lightning Arrow','Water Arrow'}
priorrangedmode = 'Normal';
function job_self_command(cmdParams, eventArgs)
	command = cmdParams[1]:lower()
	if command=='hastetype' then
		if hastetype == 1 then hastetype=2 
		else hastetype = 1 end
		add_to_chat(122,'Haste '..hastetype)
		check_haste_level()
		handle_equipping_gear(player.status)
	elseif command=='shoot' then
		send_command('input /shoot <t>')
		if player.status == 'Engaged' then
			autora = true
		end
	elseif command=='setws' then
		ws_set = string.gsub(cmdParams[2],"_"," ")
		if ws_set =="Jishnus" then
			ws_set ="Jishnu's Radiance"
		end
		add_to_chat(122,'Default WS set to '..ws_set)
		default_ws = ws_set
		send_command('bind %numpad3 input /ws '..ws_set..'')
	elseif command=='checkandshoot' then
		if player.status == 'Engaged' and autora == true and not midshot_real then
			send_command('input /shoot <t>')
			midshot = true
		end
	elseif command=='shootstop' then
		--print('stopping ')
		--print(autora)
		autora = false
		midshot = false
		midshot_real = false
	elseif command=='hastesambatype' then
		if hastesambatype == 0 then hastesambatype=1 
		elseif hastesambatype == 1 then hastesambatype = 2 
		else hastesambatype = 0 end
		add_to_chat(122,'Hastesambatype '..hastesambatype)
	elseif command=='rangetype' then
		enable('range','ammo')
		rangeswap=1
		send_command('gs c cycle rangetype')
		if state.rangetype.value == "Throwing" then
			default_ws = "Trueflight"
			send_command('bind %numpad3 input /ws "Trueflight" <t>')
			send_command('bind @numpad1 gs c ammotype "Abrasion_Bolt"')
			send_command('bind @numpad2 gs c ammotype "Quelling_Bolt"')
			send_command('bind @numpad4 gs c ammotype "Bloody_Bolt"')
			send_command('bind @numpad5 gs c ammotype "Righteous_Bolt"')
		elseif state.rangetype.value == "Crossbow" then
			default_ws = "Jishnu's Radiance"
			send_command('bind %numpad3 input /ws "Jishnu\'s Radiance" <t>')
			--print('jishnu')
		end
	elseif command=='ammotype' then 
		if state.rangetype.value ~= "None" then 
			atype = string.gsub(cmdParams[2],"_"," ")
			add_to_chat(122,atype)
			sets.rangetype[state.rangetype.value] = set_combine(sets.rangetype[state.rangetype.value],{ammo=atype})
			enable('ammo')
			equip(sets.rangetype[state.rangetype.value])
			disable('ammo')
			if statusammo:contains(atype) then
				if state.RangedMode.value ~= 'StatusAmmo' then 
					priorrangedmode = state.RangedMode.value 
				end
				state.RangedMode:set('StatusAmmo')
			else
				state.RangedMode:set(priorrangedmode)
			end
			add_to_chat(122,'Ranged Attack Mode set to ' .. state.RangedMode.value)
		end
	elseif command=='mainweapon' then
		enable('main','sub')
		mainswap=1
		send_command('gs c cycle mainweapon')
	elseif command=='test' then
		print('equipping set')
		equip(sets.precast.WS["Rudra's Storm SA"])
		--pr(sets.precast.WS)
	elseif command == 'warpring' then
		equip({left_ring="Warp Ring"})
		send_command('gs disable left_ring;wait 10;input /item "Warp Ring" <me>;wait 1;input /item "Warp Ring" <me>;wait 1;input /item "Warp Ring" <me>;wait 10;gs enable left_ring')
	elseif cmdParams[1] == "switch_dualbox_binds" then -- disables stp_m1 to stp_m10 for dual box commands, or enables them
		if use_dualbox then
			send_command('alias stp_m6 gs c toggle hasteknife')
			send_command('alias stp_m7 gs c toggle mabdagger')
			use_dualbox=false
		else
			send_command('alias stp_m1 nil')
			send_command('alias stp_m2 nil')
			send_command('alias stp_m3 nil')
			send_command('alias stp_m4 nil')
			send_command('alias stp_m5 nil')
			send_command('alias stp_m6 nil')
			send_command('alias stp_m7 nil')
			send_command('alias stp_m8 nil')
			send_command('alias stp_m9 nil')
			--send_command('alias stp_m10 nil')
			use_dualbox=true
		end
		--
	elseif cmdParams[1] == "toggle_dt" then 
		if state.damagetaken.value == 'DT' then
			send_command('gs c set damagetaken None')
		else
			send_command('gs c set damagetaken DT')
		end
	elseif cmdParams[1] == 'alt_buffs' then
		send_command("send Blua /ja 'Full Circle';wait 2;send Blua /ma 'Geo-Acumen' <bt>")
		send_command('send Flupplewolfe /ja "Samurai Roll" <me>;wait 65;send Flupplewolfe /ja "Wizard\'s Roll" <me>')
	elseif cmdParams[1] == 'alt_sneakinvis' then
		send_command('send Blua /ma "Sneak" <me>;wait 10;send Blua /ma "Invisible" <me>')
		send_command('send Flupplewolfe /ma "Sneak" <me>;wait 10;send Flupplewolfe /ma "Invisible" <me>')
	elseif cmdParams[1] == 'alt_cures' then
		send_command("send Blua /ma 'Cure IV' Verda;wait 5;send Blua /ma input 'Cure III' <me>")
		send_command("send Flupplewolfe /ma 'Cure IV' Verda;wait 5;send Flupplewolfe /ma input 'Cure III' <me>")
	elseif cmdParams[1] == 'alt_selfbuffs' then
		send_command("send Blua /ma 'Indi-Haste' <me>")
	elseif cmdParams[1] == 'alt_selfbuffs2' then
		send_command("send Blua /ma 'Indi-Refresh' <me>")
	elseif cmdParams[1] == 'alt_selfbuffs3' then
		send_command("send Blua /ma 'Haste' Verda")
	elseif cmdParams[1] == 'alt_follow' then
		send_command("send Blua /follow Verda")
		send_command("send Flupplewolfe /follow Verda")
	end
	command = cmdParams[1]:lower()
	command2 = cmdParams[2]
	if(customincludes) then 
		include('custom-commands.lua')
	end
end

-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
	local msg = 'Melee'

	if state.CombatForm.has_value then
		msg = msg .. ' (' .. state.CombatForm.value .. ')'
	end

	msg = msg .. ': '

	msg = msg .. state.OffenseMode.value
	if state.HybridMode.value ~= 'Normal' then
		msg = msg .. '/' .. state.HybridMode.value
	end
	msg = msg .. ', WS: ' .. state.WeaponskillMode.value

	if state.DefenseMode.value ~= 'None' then
		msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
	end

	if state.Kiting.value == true then
		msg = msg .. ', Kiting'
	end

	if state.PCTargetMode.value ~= 'default' then
		msg = msg .. ', Target PC: '..state.PCTargetMode.value
	end

	if state.SelectNPCTargets.value == true then
		msg = msg .. ', Target NPCs'
	end

	--msg = msg .. ', TH: ' .. state.TreasureMode.value

	add_to_chat(122, msg)

	eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
	if state.Buff[buff_name] then
		equip(sets.buff[buff_name] or {})
		eventArgs.handled = true
	end

	--    if buffactive['Haste'] and player.tp < 200 and usehasteknife == 1 then
	--	    sets.engaged = set_combine(sets.engaged,sets.Mainhand)
	--	    sets.idle = set_combine(sets.idle,sets.Mainhand)
	--    elseif player.tp < 200 and usehasteknife == 1 then 
	--		    sets.engaged = set_combine(sets.engaged,sets.Haste)
	--		    sets.idle = set_combine(sets.idle,sets.Haste)
	--    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	if player.sub_job == 'WAR' then
		set_macro_page(1, 15)
	elseif player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		set_macro_page(1, 15)
	end
end

require 'actions-custom'

midshot = false
function event_action(raw_actionpacket)
	local actionpacket = ActionPacket.new(raw_actionpacket)
	if not autora or not enableautora then 
		return 
	end
	
	actionstr = actionpacket:get_category_string() 

	if actionstr == 'ranged_begin' then
		--print('ranged begin')
		midshot_real=true
	end
	if actionstr == 'ranged_finish' and player.status == 'Engaged' then
		--print('ranged end')
		--send_command('wait .5;input /shoot <t>')
		--send_command('wait .6;input /shoot <t>')
		midshot=false
		midshot_real=false
		--print('autora')
		if autora and player.tp >= 1000 and state.autows.current == 'on' then
			send_command('wait 1;input /ws "'..default_ws..'" <t>;wait 3.5;gs c checkandshoot')
			--send_command('wait 1.3;input /ws "'..default_ws..'" <t>;')
		elseif autora then 
			--send_command('wait .7;input /shoot <t>')
			--send_command('wait .8;input /shoot <t>')
			--send_command('wait .9;input /shoot <t>')
			--send_command('wait .6;gs c checkandshoot')
			--send_command('wait .7;gs c checkandshoot')
			--send_command('wait .8;gs c checkandshoot')
			--send_command('wait .9;gs c checkandshoot')
			send_command('wait 1;gs c checkandshoot')
			--send_command('wait 1.1;gs c checkandshoot')
			--send_command('wait 1.3;gs c checkandshoot')
			--send_command('wait 1;gs c checkandshoot')
			--send_command('wait 1.3;gs c checkandshoot')
		end
	end
	
end
function ActionPacket.open_raw_listener(funct)
    if not funct or type(funct) ~= 'function' then return end
    local id = windower.raw_register_event('incoming chunk',function(id, org, modi, is_injected, is_blocked)
        if id == 0x28 then
            local act_org = windower.packets.parse_action(org)
            act_org.size = org:byte(5)
            local act_mod = windower.packets.parse_action(modi)
            act_mod.size = modi:byte(5)
            return act_to_string(org,funct(act_org,act_mod))
        end
    end)
    return id
end


ActionPacket.open_raw_listener(event_action)
