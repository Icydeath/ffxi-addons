-------------------------------------------------------------------------------------------------------------------
-- ctrl+F12 cycles Idle modes
-- Alt+F8 cycles Jug Pet Modes

-------------|MACROS|-------------
-- /console gs c cycle JugMode
-- /console gs c cycle RewardMode

-- Example for setting specific jug
-- /console gs c set JugMode BouncingBertha
-------------------------------------------------------------------------------------------------------------------


-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
 
	-- Load and initialize the include file.
	include('Mote-Include.lua')
	
	-- Organizer library
	include('organizer-lib.lua')
end
 
function user_setup()
	state.IdleMode:options('Normal', 'Reraise')  
	
	-- Set your commonly used pets
	state.JugMode = M{['description']='Jug Mode',
		'BlackbeardRandy', 
		'BouncingBertha', -- NoCallBeast
		'ScissorlegXerin',
		'RhymingShizuna',
		'VivaciousVickie', -- NoCallBeast
		'HeadbreakerKen', 
		'WarlikePatrick', 
		'SwoopingZhivago', -- NoCallBeast
		'AttentiveIbuki',
		'PonderingPeter', -- NoCallBeast
		'AlluringHoney', -- NoCallBeast
		'SuspiciousAlice',
		'ThreestarLynn'}
	
	-- Set the rewards you commonly use
	state.RewardMode = M{['description']='Reward Mode', 'Theta'}
	
	-- Set the pet jugs you don't want to lose using 'Call Beast'
	NoCallBeasts = {
		'BouncingBertha', 
		'PonderingPeter', 
		'SwoopingZhivago', 
		'VivaciousVickie', 
		'AlluringHoney'}
	
	-- 'Out of Range' distance; WS will auto-cancel
	target_distance = 6
	
	gear.weaponskill_waist = "Fotia Belt"
	gear.weaponskill_neck = "Fotia Gorget"
	
	set_lockstyle('4')
end

-- Complete list of Ready moves to use with Sic & Ready Recast -5 Desultor Tassets.
ready_moves_to_check = S{
	'Sic','Whirl Claws','Dust Cloud','Foot Kick','Sheep Song','Sheep Charge','Lamb Chop',
	'Rage','Head Butt','Scream','Dream Flower','Wild Oats','Leaf Dagger','Claw Cyclone','Razor Fang',
	'Roar','Gloeosuccus','Palsy Pollen','Soporific','Cursed Sphere','Venom','Geist Wall','Toxic Spit',
	'Numbing Noise','Nimble Snap','Cyclotail','Spoil','Rhino Guard','Rhino Attack','Power Attack',
	'Hi-Freq Field','Sandpit','Sandblast','Venom Spray','Mandibular Bite','Metallic Body','Bubble Shower',
	'Bubble Curtain','Scissor Guard','Big Scissors','Grapple','Spinning Top','Double Claw','Filamented Hold',
	'Frog Kick','Queasyshroom','Silence Gas','Numbshroom','Spore','Dark Spore','Shakeshroom','Blockhead',
	'Secretion','Fireball','Tail Blow','Plague Breath','Brain Crush','Infrasonics','??? Needles',
	'Needleshot','Chaotic Eye','Blaster','Scythe Tail','Ripper Fang','Chomp Rush','Intimidate','Recoil Dive',
	'Water Wall','Snow Cloud','Wild Carrot','Sudden Lunge','Spiral Spin','Noisome Powder','Wing Slap',
	'Beak Lunge','Suction','Drainkiss','Acid Mist','TP Drainkiss','Back Heel','Jettatura','Choke Breath',
	'Fantod','Charged Whisker','Purulent Ooze','Corrosive Ooze','Tortoise Stomp','Harden Shell','Aqua Breath',
	'Sensilla Blades','Tegmina Buffet','Molting Plumage','Swooping Frenzy','Pentapeck','Sweeping Gouge',
	'Zealous Snort','Somersault ','Tickling Tendrils','Stink Bomb','Nectarous Deluge','Nepenthic Plunge',
	'Pecking Flurry','Pestilent Plume','Foul Waters','Spider Web','Sickle Slash','Frogkick','Ripper Fang','Scythe Tail','Chomp Rush'}
 
               
mab_ready_moves = S{
	'Cursed Sphere','Venom','Toxic Spit',
	'Venom Spray','Bubble Shower',
	'Fireball','Plague Breath',
	'Snow Cloud','Acid Spray','Silence Gas','Dark Spore',
	'Charged Whisker','Purulent Ooze','Aqua Breath','Stink Bomb',
	'Nectarous Deluge','Nepenthic Plunge','Foul Waters','Dust Cloud','Sheep Song','Scream','Dream Flower','Roar','Gloeosuccus','Palsy Pollen',
	'Soporific','Geist Wall','Numbing Noise','Spoil','Hi-Freq Field',
	'Sandpit','Sandblast','Filamented Hold',
	'Spore','Infrasonics','Chaotic Eye',
	'Blaster','Intimidate','Noisome Powder','TP Drainkiss','Jettatura','Spider Web',
	'Corrosive Ooze','Molting Plumage','Swooping Frenzy',
	'Pestilent Plume',}
 
function file_unload()
	if binds_on_unload then
		binds_on_unload()
	end

	-- Unbinds the Jug Pet, Reward, Correlation, Treasure, PetMode, MDEF Mode hotkeys.
	send_command('unbind !=')
	send_command('unbind ^=')
	send_command('unbind !f8')
	send_command('unbind ^f8')
	send_command('unbind @f8')
	send_command('unbind ^f11')
end
 
-- Gearsets
function init_gear_sets()
	organizer_items = {
		kumbhakarna="Kumbhakarna",
		capring="Capacity Ring",	
	}
	
	-- PRECAST SETS
	sets.precast.JA['Killer Instinct'] = {head="Ankusa Helm"}

	sets.precast.JA['Bestial Loyalty'] = {hands="Ankusa Gloves"}

	sets.precast.JA['Call Beast'] = set_combine(sets.precast.JA['Bestial Loyalty'], {})

	sets.precast.JA.Familiar = {legs="Ankusa Trousers"}

	sets.precast.JA.Tame = {
		--head="Beast Helm"
	}

	sets.precast.JA.Spur = {feet="Ferine Ocreae +1"}

	--This is what will equip when you use Reward.  No need to manually equip Pet Food Theta.
	--Reward/MND gear
	sets.precast.JA.Reward = {
		head="Bison Warbonnet",
		body="Totemic Jackcoat",
		hands={ name="Emicho Gauntlets", augments={'Pet: Accuracy+15','Pet: Attack+15','Pet: "Dbl. Atk."+3',}},
		legs={ name="Ankusa Trousers", augments={'Enhances "Familiar" effect',}},
		feet={ name="Ankusa Gaiters", augments={'Enhances "Beast Healer" effect',}},
		neck="Weike Torque",
		waist="Hurch'lan Sash",
		left_ear="Ferine Earring",
		right_ear="Lifestorm Earring",
		left_ring={ name="Dark Ring", augments={'Magic dmg. taken -5%','Phys. dmg. taken -5%',}},
		right_ring="Globidonta Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}
	
	sets.precast.JA.Reward.Theta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Theta"})
	sets.precast.JA.Reward.Zeta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Zeta"})
	sets.precast.JA.Reward.Eta = set_combine(sets.precast.JA.Reward, {ammo="Pet Food Eta"})
	
	--This is your base FastCast set that equips during precast for all spells/magic.
	sets.precast.FC = {
		ammo="Impatiens",
		left_ear="Enchntr. Earring +1",
		right_ear="Loquac. Earring",
		left_ring="Prolix Ring",
		right_ring="Veneficium Ring",
	}
		
	sets.midcast.Stoneskin = {}


	-- WEAPONSKILLS
	
	-- Default weaponskill set.
	sets.precast.WS = {
		ammo="Ginsen",
		head={ name="Despair Helm", augments={'Accuracy+10','Pet: VIT+7','Pet: Damage taken -3%',}},
		body={ name="Acro Surcoat", augments={'MND+2 CHR+2','Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5',}},
		hands={ name="Emicho Gauntlets", augments={'Pet: Accuracy+15','Pet: Attack+15','Pet: "Dbl. Atk."+3',}},
		legs={ name="Acro Breeches", augments={'Pet: Accuracy+20 Pet: Rng. Acc.+20','Pet: "Dbl. Atk."+3','Pet: Haste+3',}},
		feet="Amm Greaves",
		neck=gear.weaponskill_neck,
		waist=gear.weaponskill_waist,
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Epona's Ring",
		right_ring="Petrov Ring",
		back="Atheling Mantle",
	}


	-- Specific weaponskill sets.
	sets.precast.WS['Ruinator'] = set_combine(sets.precast.WS, {neck=gear.weaponskill_neck, waist=gear.weaponskill_waist})
	
	-- 80% DEX
	sets.precast.WS['Onslaught'] = set_combine(sets.precast.WS, {neck=gear.weaponskill_neck, waist=gear.weaponskill_waist})
	
	-- 30% DEX / 60% CHR / MAB
	sets.precast.WS['Primal Rend'] = {
		ammo="Demonry Core",
		head="Gavialis Helm",
		body={ name="Acro Surcoat", augments={'MND+2 CHR+2','Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Acro Breeches", augments={'Pet: Accuracy+20 Pet: Rng. Acc.+20','Pet: "Dbl. Atk."+3','Pet: Haste+3',}},
		feet="Amm Greaves",
		neck=gear.weaponskill_neck,
		waist=gear.weaponskill_waist,
		left_ear="Moonshade Earring",
		right_ear="Friomisi Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Acumen Ring",
		back="Toro Cape",
	}

	-- 40% STR / 40% MND / MAB
	sets.precast.WS['Cloudsplitter'] = set_combine(sets.precast.WS["Primal Rend"], {
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	})

	sets.precast.WS['Rampage'] = set_combine(sets.precast.WS, {})
	
	sets.precast.WS['Decimation'] = set_combine(sets.precast.WS, {})

	
	-- PET SIC & READY MOVES
	
	--This is your base Ready move set, activating for physical Ready moves. Merlin/D.Tassets are accounted for already.
	sets.midcast.Pet.WS = {
		ammo="Demonry Core",
		head={ name="Valorous Mask", augments={'Pet: Accuracy+22 Pet: Rng. Acc.+22','Pet: "Dbl.Atk."+2 Pet: Crit.hit rate +2','Pet: STR+5','Pet: Attack+15 Pet: Rng.Atk.+15',}},
		body={ name="Acro Surcoat", augments={'Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5','MND+2 CHR+2',}},
		hands="Nukumi Manoplas +1",
		legs={ name="Valor. Hose", augments={'Pet: Attack+13 Pet: Rng.Atk.+13','Pet: "Dbl.Atk."+4 Pet: Crit.hit rate +4','Pet: Accuracy+7 Pet: Rng. Acc.+7',}},
		feet={ name="Valorous Greaves", augments={'Pet: Accuracy+30 Pet: Rng. Acc.+30','Pet: "Dbl. Atk."+2','Pet: DEX+10','Pet: Attack+2 Pet: Rng.Atk.+2',}},
		neck="Ferine Necklace",
		waist="Hurch'lan Sash",
		left_ear="Sabong Earring",
		right_ear="Hija Earring",
		left_ring="Thurandaut Ring",
		right_ring="Patricius Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}

	--This will equip for Magical Ready moves like Fireball
	sets.midcast.Pet.MabReady = {
		sub={ name="Skullrender", augments={'DMG:+15','Pet: "Mag.Atk.Bns."+15','Pet: "Regen"+2',}},
		ammo="Demonry Core",
		head={ name="Acro Helm", augments={'Pet: "Mag.Atk.Bns."+16','Pet: "Regen"+3','Pet: Haste+2',}},
		body={ name="Acro Surcoat", augments={'Pet: Mag. Acc.+24','Pet: "Regen"+3','Pet: Damage taken -2%',}},
		hands={ name="Acro Gauntlets", augments={'Pet: "Mag.Atk.Bns."+23','Pet: "Regen"+2','Pet: Damage taken -2%',}},
		legs={ name="Acro Breeches", augments={'Pet: "Mag.Atk.Bns."+24','Pet: "Regen"+3','Pet: Damage taken -4%',}},
		feet={ name="Acro Leggings", augments={'Pet: "Mag.Atk.Bns."+21','Pet: "Regen"+3','Pet: Damage taken -2%',}},
		neck="Deino Collar",
		waist="Hurch'lan Sash",
		left_ear="Handler's Earring +1",
		right_ear="Hija Earring",
		left_ring="Thurandaut Ring",
		right_ring={ name="Dark Ring", augments={'Magic dmg. taken -5%','Phys. dmg. taken -5%',}},
		back="Argochampsa Mantle"
	}

	-- Doesn't work O.o
	sets.midcast.Pet.TPBonus = {hands="Nukumi Manoplas +1",}
	
	-- Equips this before the pets ws type set
	sets.midcast.Pet.ReadyRecast = {sub="Charmer's Merlin", legs="Desultor Tassets"}


	-- IDLE SETS (TOGGLE between RERAISE and NORMAL with CTRL+F12)


	-- Base Idle Set (when you do NOT have a pet out)
	sets.idle = {
		ammo="Demonry Core",
		head={ name="Valorous Mask", augments={'Pet: Accuracy+22 Pet: Rng. Acc.+22','Pet: "Dbl.Atk."+2 Pet: Crit.hit rate +2','Pet: STR+5','Pet: Attack+15 Pet: Rng.Atk.+15',}},
		body={ name="Acro Surcoat", augments={'Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5','MND+2 CHR+2',}},
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Acro Breeches", augments={'Pet: Accuracy+20 Pet: Rng. Acc.+20','Pet: "Dbl. Atk."+3','Pet: Haste+3',}},
		feet="Skd. Jambeaux +1",
		neck="Sanctity Necklace",
		waist="Flume Belt +1",
		left_ear="Etiolation Earring",
		right_ear="Infused Earring",
		left_ring={ name="Dark Ring", augments={'Magic dmg. taken -5%','Phys. dmg. taken -5%',}},
		right_ring="Defending Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}

	sets.idle.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})

	-- Idle Set that equips when you have a pet out and [YOU ARE NOT] fighting an enemy and your [PET IS NOT] fighting.
	sets.idle.Pet = {
		sub={ name="Skullrender", augments={'DMG:+15','Pet: "Mag.Atk.Bns."+15','Pet: "Regen"+2',}},
		ammo="Demonry Core",
		head={ name="Acro Helm", augments={'Pet: "Mag.Atk.Bns."+16','Pet: "Regen"+3','Pet: Haste+2',}},
		body={ name="Acro Surcoat", augments={'Pet: Mag. Acc.+24','Pet: "Regen"+3','Pet: Damage taken -2%',}},
		hands={ name="Acro Gauntlets", augments={'Pet: "Mag.Atk.Bns."+23','Pet: "Regen"+2','Pet: Damage taken -2%',}},
		legs={ name="Acro Breeches", augments={'Pet: "Mag.Atk.Bns."+24','Pet: "Regen"+3','Pet: Damage Taken -4%',}},
		feet={ name="Acro Leggings", augments={'Pet: "Mag.Atk.Bns."+21','Pet: "Regen"+3','Pet: Damage taken -2%',}},
		neck="Sanctity Necklace",
		waist="Isa Belt",
		left_ear="Handler's Earring +1",
		right_ear="Hija Earring",
		left_ring="Thurandaut Ring",
		right_ring="Defending Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}

	-- Idle set that equips when you have a pet out and [YOU ARE NOT] fighting an enemy but your [PET IS] fighting...
	sets.idle.Pet.Engaged = {
		sub="Arktoi",
		ammo="Demonry Core",
		head={ name="Valorous Mask", augments={'Pet: Accuracy+22 Pet: Rng. Acc.+22','Pet: "Dbl.Atk."+2 Pet: Crit.hit rate +2','Pet: STR+5','Pet: Attack+15 Pet: Rng.Atk.+15',}},
		body={ name="Acro Surcoat", augments={'Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5','MND+2 CHR+2',}},
		hands={ name="Emicho Gauntlets", augments={'Pet: Accuracy+15','Pet: Attack+15','Pet: "Dbl. Atk."+3',}},
		legs={ name="Valor. Hose", augments={'Pet: Attack+13 Pet: Rng.Atk.+13','Pet: "Dbl.Atk."+4 Pet: Crit.hit rate +4','Pet: Accuracy+7 Pet: Rng. Acc.+7',}},
		feet={ name="Valorous Greaves", augments={'Pet: Accuracy+30 Pet: Rng. Acc.+30','Pet: "Dbl. Atk."+2','Pet: DEX+10','Pet: Attack+2 Pet: Rng.Atk.+2',}},
		neck="Ferine Necklace",
		waist="Hurch'lan Sash",
		left_ear="Sabong Earring",
		right_ear="Hija Earring",
		left_ring="Thurandaut Ring",
		right_ring="Defending Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}

	
	-- MELEE (SINGLE-WIELD) SETS
	sets.engaged = {
		ammo="Hasty Pinion +1",
		head={ name="Despair Helm", augments={'Accuracy+10','Pet: VIT+7','Pet: Damage taken -3%',}},
		body={ name="Acro Surcoat", augments={'MND+2 CHR+2','Pet: Accuracy+17 Pet: Rng. Acc.+17','Pet: "Dbl. Atk."+5',}},
		hands={ name="Emicho Gauntlets", augments={'Pet: Accuracy+15','Pet: Attack+15','Pet: "Dbl. Atk."+3',}},
		legs={ name="Acro Breeches", augments={'Pet: Accuracy+20 Pet: Rng. Acc.+20','Pet: "Dbl. Atk."+3','Pet: Haste+3',}},
		feet="Amm Greaves",
		neck="Sanctity Necklace",
		waist="Hurch'lan Sash",
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Hetairoi Ring",
		back={ name="Pastoralist's Mantle", augments={'STR+3 DEX+3','Accuracy+3','Pet: Accuracy+18 Pet: Rng. Acc.+18','Pet: Damage taken -3%',}},
	}


	-- MELEE (DUAL-WIELD) SETS FOR DNC AND NIN SUBJOB
	sets.engaged.DW = set_combine(sets.engaged, {
		ear1="Dudgeon Earring",
		ear2="Heartseeker Earring"})
		
	sets.engaged.Reraise = set_combine(sets.idle, {head="Twilight Helm",body="Twilight Mail"})
-------------------------------------------------------------------------------------------------------------------
-- Complete Lvl 76-99 Jug Pet Precast List +Funguar +Courier +Amigo
-------------------------------------------------------------------------------------------------------------------

	sets.precast.JA['Bestial Loyalty'].FunguarFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Seedbed Soil"})
	sets.precast.JA['Bestial Loyalty'].CourierCarrie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Fish Oil Broth"})
	sets.precast.JA['Bestial Loyalty'].AmigoSabotender = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sun Water"})
	sets.precast.JA['Bestial Loyalty'].NurseryNazuna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="D. Herbal Broth"})
	sets.precast.JA['Bestial Loyalty'].CraftyClyvonne = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Cng. Brain Broth"})
	sets.precast.JA['Bestial Loyalty'].PrestoJulio = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="C. Grass. Broth"})
	sets.precast.JA['Bestial Loyalty'].SwiftSieghard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Mlw. Bird Broth"})
	sets.precast.JA['Bestial Loyalty'].MailbusterCetas = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Gob. Bug Broth"})
	sets.precast.JA['Bestial Loyalty'].AudaciousAnna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="B. Carrion Broth"})
	sets.precast.JA['Bestial Loyalty'].TurbidToloi = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Auroral Broth"})
	sets.precast.JA['Bestial Loyalty'].LuckyLulush = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="L. Carrot Broth"})
	sets.precast.JA['Bestial Loyalty'].DipperYuly = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Wool Grease"})
	sets.precast.JA['Bestial Loyalty'].FlowerpotMerle = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Vermihumus"})
	sets.precast.JA['Bestial Loyalty'].DapperMac = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Briny Broth"})
	sets.precast.JA['Bestial Loyalty'].DiscreetLouise = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Deepbed Soil"})
	sets.precast.JA['Bestial Loyalty'].FatsoFargann = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="C. Plasma Broth"})
	sets.precast.JA['Bestial Loyalty'].FaithfulFalcorr = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Lucky Broth"})
	sets.precast.JA['Bestial Loyalty'].BugeyedBroncha = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Svg. Mole Broth"})
	sets.precast.JA['Bestial Loyalty'].BloodclawShasra = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Rzr. Brain Broth"})
	sets.precast.JA['Bestial Loyalty'].GorefangHobs = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="B. Carrion Broth"})
	sets.precast.JA['Bestial Loyalty'].GooeyGerard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Cl. Wheat Broth"})
	sets.precast.JA['Bestial Loyalty'].CrudeRaphie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Shadowy Broth"})
	sets.precast.JA['Bestial Loyalty'].SuspiciousAlice = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Furious Broth"})
	sets.precast.JA['Bestial Loyalty'].FleetReinhard = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Rapid Broth"})
	
-------------------------------------------------------------------------------------------------------------------
-- Complete iLvl Jug Pet Precast List
-------------------------------------------------------------------------------------------------------------------

	sets.precast.JA['Bestial Loyalty'].DroopyDortwin = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Swirling Broth"})
	sets.precast.JA['Bestial Loyalty'].PonderingPeter = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Vis. Broth"})
	sets.precast.JA['Bestial Loyalty'].SunburstMalfik = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Shimmering Broth"})
	sets.precast.JA['Bestial Loyalty'].AgedAngus = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Ferm. Broth"})
	sets.precast.JA['Bestial Loyalty'].WarlikePatrick = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Livid Broth"})
	sets.precast.JA['Bestial Loyalty'].ScissorlegXerin = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Spicy Broth"})
	sets.precast.JA['Bestial Loyalty'].BouncingBertha = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bubbly Broth"})
	sets.precast.JA['Bestial Loyalty'].RhymingShizuna = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Lyrical Broth"})
	sets.precast.JA['Bestial Loyalty'].AttentiveIbuki = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Salubrious Broth"})
	sets.precast.JA['Bestial Loyalty'].SwoopingZhivago = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Windy Greens"})
	sets.precast.JA['Bestial Loyalty'].AmiableRoche = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Airy Broth"})
	sets.precast.JA['Bestial Loyalty'].HeraldHenry = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Trans. Broth"})
	sets.precast.JA['Bestial Loyalty'].BrainyWaluis = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Crumbly Soil"})
	sets.precast.JA['Bestial Loyalty'].HeadbreakerKen = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Blackwater Broth"})
	sets.precast.JA['Bestial Loyalty'].RedolentCandi = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Electrified Broth"})
	sets.precast.JA['Bestial Loyalty'].AlluringHoney = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Bug-Ridden Broth"})
	sets.precast.JA['Bestial Loyalty'].CaringKiyomaro = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Fizzy Broth"})
	sets.precast.JA['Bestial Loyalty'].VivaciousVickie = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Tant. Broth"})
	sets.precast.JA['Bestial Loyalty'].HurlerPercival = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Pale Sap"})
	sets.precast.JA['Bestial Loyalty'].BlackbeardRandy = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Meaty Broth"})
	sets.precast.JA['Bestial Loyalty'].GenerousArthur = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Dire Broth"})
	sets.precast.JA['Bestial Loyalty'].ThreestarLynn = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Muddy Broth"})
	sets.precast.JA['Bestial Loyalty'].BraveHeroGlenn = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Wispy Broth"})
	sets.precast.JA['Bestial Loyalty'].SharpwitHermes = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Saline Broth"})
	sets.precast.JA['Bestial Loyalty'].ColibriFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sugary Broth"})
	sets.precast.JA['Bestial Loyalty'].ChoralLeera = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Glazed Broth"})
	sets.precast.JA['Bestial Loyalty'].SpiderFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Sticky Webbing"})
	sets.precast.JA['Bestial Loyalty'].GussyHachirobe = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Slimy Webbing"})
	sets.precast.JA['Bestial Loyalty'].AcuexFamiliar = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Poisonous Broth"})
	sets.precast.JA['Bestial Loyalty'].FluffyBredo = set_combine(sets.precast.JA['Bestial Loyalty'], {ammo="Venomous Broth"})
end
 
-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks that are called to process player actions at specific points in time.
-------------------------------------------------------------------------------------------------------------------
 
function job_precast(spell, action, spellMap, eventArgs)
	cancel_conflicting_buffs(spell, action, spellMap, eventArgs)
	
	if spell.type == "WeaponSkill" and spell.name ~= 'Mistral Axe' and spell.name ~= 'Bora Axe' and spell.target.distance > target_distance then
		cancel_spell()
		add_to_chat(123, spell.name..' Canceled: [Out of Range]')
		return
	end
	
	-- Equip the pet food based off RewardMode
	if spell.english == 'Reward' then
		if state.RewardMode.value == 'Theta' then
			equip(sets.precast.JA.Reward.Theta)
		elseif state.RewardMode.value == 'Zeta' then
			equip(sets.precast.JA.Reward.Zeta)
		elseif state.RewardMode.value == 'Eta' then
			equip(sets.precast.JA.Reward.Eta)
		end
	end
	
	-- A call beast check to protect those expensive jugs!
	if spell.english == 'Call Beast' then
		for _,v in pairs(NoCallBeasts) do
			if v == state.JugMode.value then
				cancel_spell()
				add_to_chat(123, spell.name..' Canceled: [NoCallBeast: ' .. v .. ']')
				return
			end
		end
	end
	
	-- Equip the call beast & jug based off of JugMode
	if spell.english == 'Bestial Loyalty' or spell.english == 'Call Beast' then
		if state.JugMode.value == 'FunguarFamiliar' then
			equip(sets.precast.JA['Bestial Loyalty'].FunguarFamiliar)
		elseif state.JugMode.value == 'CourierCarrie' then
			equip(sets.precast.JA['Bestial Loyalty'].CourierCarrie)
		elseif state.JugMode.value == 'AmigoSabotender' then
			equip(sets.precast.JA['Bestial Loyalty'].AmigoSabotender)
		elseif state.JugMode.value == 'NurseryNazuna' then
			equip(sets.precast.JA['Bestial Loyalty'].NurseryNazuna)
		elseif state.JugMode.value == 'CraftyClyvonne' then
			equip(sets.precast.JA['Bestial Loyalty'].CraftyClyvonne)
		elseif state.JugMode.value == 'PrestoJulio' then
			equip(sets.precast.JA['Bestial Loyalty'].PrestoJulio)
		elseif state.JugMode.value == 'SwiftSieghard' then
			equip(sets.precast.JA['Bestial Loyalty'].SwiftSieghard)
		elseif state.JugMode.value == 'MailbusterCetas' then
			equip(sets.precast.JA['Bestial Loyalty'].MailbusterCetas)
		elseif state.JugMode.value == 'AudaciousAnna' then
			equip(sets.precast.JA['Bestial Loyalty'].AudaciousAnna)
		elseif state.JugMode.value == 'TurbidToloi' then
			equip(sets.precast.JA['Bestial Loyalty'].TurbidToloi)
		elseif state.JugMode.value == 'SlipperySilas' then
			equip(sets.precast.JA['Bestial Loyalty'].SlipperySilas)
		elseif state.JugMode.value == 'LuckyLulush' then
			equip(sets.precast.JA['Bestial Loyalty'].LuckyLulush)
		elseif state.JugMode.value == 'DipperYuly' then
			equip(sets.precast.JA['Bestial Loyalty'].DipperYuly)
		elseif state.JugMode.value == 'FlowerpotMerle' then
			equip(sets.precast.JA['Bestial Loyalty'].FlowerpotMerle)
		elseif state.JugMode.value == 'DapperMac' then
			equip(sets.precast.JA['Bestial Loyalty'].DapperMac)
		elseif state.JugMode.value == 'DiscreetLouise' then
			equip(sets.precast.JA['Bestial Loyalty'].DiscreetLouise)
		elseif state.JugMode.value == 'FatsoFargann' then
			equip(sets.precast.JA['Bestial Loyalty'].FatsoFargann)
		elseif state.JugMode.value == 'FaithfulFalcorr' then
			equip(sets.precast.JA['Bestial Loyalty'].FaithfulFalcorr)
		elseif state.JugMode.value == 'BugeyedBroncha' then
			equip(sets.precast.JA['Bestial Loyalty'].BugeyedBroncha)
		elseif state.JugMode.value == 'BloodclawShasra' then
			equip(sets.precast.JA['Bestial Loyalty'].BloodclawShasra)
		elseif state.JugMode.value == 'GorefangHobs' then
			equip(sets.precast.JA['Bestial Loyalty'].GorefangHobs)
		elseif state.JugMode.value == 'GooeyGerard' then
			equip(sets.precast.JA['Bestial Loyalty'].GooeyGerard)
		elseif state.JugMode.value == 'CrudeRaphie' then
			equip(sets.precast.JA['Bestial Loyalty'].CrudeRaphie)
		elseif state.JugMode.value == 'SuspiciousAlice' then
			equip(sets.precast.JA['Bestial Loyalty'].SuspiciousAlice)
		elseif state.JugMode.value == 'FleetReinhard' then
			equip(sets.precast.JA['Bestial Loyalty'].FleetReinhard)
		elseif state.JugMode.value == 'DroopyDortwin' then
			equip(sets.precast.JA['Bestial Loyalty'].DroopyDortwin)
		elseif state.JugMode.value == 'PonderingPeter' then
			equip(sets.precast.JA['Bestial Loyalty'].PonderingPeter)
		elseif state.JugMode.value == 'SunburstMalfik' then
			equip(sets.precast.JA['Bestial Loyalty'].SunburstMalfik)
		elseif state.JugMode.value == 'AgedAngus' then
			equip(sets.precast.JA['Bestial Loyalty'].AgedAngus)
		elseif state.JugMode.value == 'WarlikePatrick' then
			equip(sets.precast.JA['Bestial Loyalty'].WarlikePatrick)
		elseif state.JugMode.value == 'ScissorlegXerin' then
			equip(sets.precast.JA['Bestial Loyalty'].ScissorlegXerin)
		elseif state.JugMode.value == 'BouncingBertha' then
			equip(sets.precast.JA['Bestial Loyalty'].BouncingBertha)
		elseif state.JugMode.value == 'RhymingShizuna' then
			equip(sets.precast.JA['Bestial Loyalty'].RhymingShizuna)
		elseif state.JugMode.value == 'AttentiveIbuki' then
			equip(sets.precast.JA['Bestial Loyalty'].AttentiveIbuki)
		elseif state.JugMode.value == 'SwoopingZhivago' then
			equip(sets.precast.JA['Bestial Loyalty'].SwoopingZhivago)
		elseif state.JugMode.value == 'AmiableRoche' then
			equip(sets.precast.JA['Bestial Loyalty'].AmiableRoche)
		elseif state.JugMode.value == 'HeraldHenry' then
			equip(sets.precast.JA['Bestial Loyalty'].HeraldHenry)
		elseif state.JugMode.value == 'BrainyWaluis' then
			equip(sets.precast.JA['Bestial Loyalty'].BrainyWaluis)
		elseif state.JugMode.value == 'HeadbreakerKen' then
			equip(sets.precast.JA['Bestial Loyalty'].HeadbreakerKen)
		elseif state.JugMode.value == 'RedolentCandi' then
			equip(sets.precast.JA['Bestial Loyalty'].RedolentCandi)
		elseif state.JugMode.value == 'AlluringHoney' then
			equip(sets.precast.JA['Bestial Loyalty'].AlluringHoney)
		elseif state.JugMode.value == 'CaringKiyomaro' then
			equip(sets.precast.JA['Bestial Loyalty'].CaringKiyomaro)
		elseif state.JugMode.value == 'VivaciousVickie' then
			equip(sets.precast.JA['Bestial Loyalty'].VivaciousVickie)
		elseif state.JugMode.value == 'HurlerPercival' then
			equip(sets.precast.JA['Bestial Loyalty'].HurlerPercival)
		elseif state.JugMode.value == 'BlackbeardRandy' then
			equip(sets.precast.JA['Bestial Loyalty'].BlackbeardRandy)
		elseif state.JugMode.value == 'GenerousArthur' then
			equip(sets.precast.JA['Bestial Loyalty'].GenerousArthur)
		elseif state.JugMode.value == 'ThreestarLynn' then
			equip(sets.precast.JA['Bestial Loyalty'].ThreestarLynn)
		elseif state.JugMode.value == 'BraveHeroGlenn' then
			equip(sets.precast.JA['Bestial Loyalty'].BraveHeroGlenn)
		elseif state.JugMode.value == 'SharpwitHermes' then
			equip(sets.precast.JA['Bestial Loyalty'].SharpwitHermes)
		elseif state.JugMode.value == 'ColibriFamiliar' then
			equip(sets.precast.JA['Bestial Loyalty'].ColibriFamiliar)
		elseif state.JugMode.value == 'ChoralLeera' then
			equip(sets.precast.JA['Bestial Loyalty'].ChoralLeera)
		elseif state.JugMode.value == 'SpiderFamiliar' then
			equip(sets.precast.JA['Bestial Loyalty'].SpiderFamiliar)
		elseif state.JugMode.value == 'GussyHachirobe' then
			equip(sets.precast.JA['Bestial Loyalty'].GussyHachirobe)
		elseif state.JugMode.value == 'AcuexFamiliar' then
			equip(sets.precast.JA['Bestial Loyalty'].AcuexFamiliar)
		elseif state.JugMode.value == 'FluffyBredo' then
			equip(sets.precast.JA['Bestial Loyalty'].FluffyBredo)
		end
	end
	
	-- Define class for Sic and Ready moves.
	if ready_moves_to_check:contains(spell.name) then --and pet.status == 'Engaged'
		classes.CustomClass = "WS"
		equip(sets.midcast.Pet.ReadyRecast)
	end
end
 
 
 
function job_pet_midcast(spell, action, spellMap, eventArgs)
-- Equip monster correlation gear, as appropriate
    if ready_moves_to_check:contains(spell.english) and pet.status == 'Engaged' then
        equip(sets.midcast.Pet.WS)
	end
 
	if mab_ready_moves:contains(spell.english) and pet.status == 'Engaged' then
		equip(sets.midcast.Pet.MabReady)
	end

	if buffactive['Unleash'] then
		hands="Regimen Mittens" -- https://www.bg-wiki.com/bg/Regimen_Mittens
	end
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
	get_combat_form()

	if state.JugMode.value == 'FunguarFamiliar' then
		PetInfo = "Funguar, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'CourierCarrie' then
		PetInfo = "Crab, Aquan"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'AmigoSabotender' then
		PetInfo = "Cactuar, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'NurseryNazuna' then
		PetInfo = "Sheep, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'CraftyClyvonne' then
		PetInfo = "Coeurl, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'PrestoJulio' then
		PetInfo = "Flytrap, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'SwiftSieghard' then
		PetInfo = "Raptor, Lizard"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'MailbusterCetas' then
		PetInfo = "Fly, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'AudaciousAnna' then
		PetInfo = "Lizard, Lizard"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'TurbidToloi' then
		PetInfo = "Pugil, Aquan"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'SlipperySilas' then
		PetInfo = "Toad, Aquan"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'LuckyLulush' then
		PetInfo = "Rabbit, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'DipperYuly' then
		PetInfo = "Ladybug, Vermin"
		PetJob = 'Thief'
	elseif state.JugMode.value == 'FlowerpotMerle' then
		PetInfo = "Mandragora, Plantoid"
		PetJob = 'Monk'
	elseif state.JugMode.value == 'DapperMac' then
		PetInfo = "Apkallu, Bird"
		PetJob = 'Monk'
	elseif state.JugMode.value == 'DiscreetLouise' then
		PetInfo = "Funguar, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'FatsoFargann' then
		PetInfo = "Leech, Amorph"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'FaithfulFalcorr' then
		PetInfo = "Hippogryph, Bird"
		PetJob = 'Thief'
	elseif state.JugMode.value == 'BugeyedBroncha' then
		PetInfo = "Eft, Lizard"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'BloodclawShasra' then
		PetInfo = "Lynx, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'GorefangHobs' then
		PetInfo = "Tiger, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'GooeyGerard' then
		PetInfo = "Slug, Amorph"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'CrudeRaphie' then
		PetInfo = "Adamantoise, Lizard"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'DroopyDortwin' then
		PetInfo = "Rabbit, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'PonderingPeter' then
		PetInfo = "HQ Rabbit, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'SunburstMalfik' then
		PetInfo = "Crab, Aquan"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'AgedAngus' then
		PetInfo = "HQ Crab, Aquan"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'WarlikePatrick' then
		PetInfo = "Lizard, Lizard"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'ScissorlegXerin' then
		PetInfo = "Chapuli, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'BouncingBertha' then
		PetInfo = "HQ Chapuli, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'RhymingShizuna' then
		PetInfo = "Sheep, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'AttentiveIbuki' then
		PetInfo = "Tulfaire, Bird"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'SwoopingZhivago' then
		PetInfo = "HQ Tulfaire, Bird"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'AmiableRoche' then
		PetInfo = "Pugil, Aquan"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'HeraldHenry' then
		PetInfo = "Crab, Aquan"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'BrainyWaluis' then
		PetInfo = "Funguar, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'HeadbreakerKen' then
		PetInfo = "Fly, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'RedolentCandi' then
		PetInfo = "Snapweed, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'AlluringHoney' then
		PetInfo = "HQ Snapweed, Plantoid"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'CaringKiyomaro' then
		PetInfo = "Raaz, Beast"
		PetJob = 'Monk'
	elseif state.JugMode.value == 'VivaciousVickie' then
		PetInfo = "HQ Raaz, Beast"
		PetJob = 'Monk'
	elseif state.JugMode.value == 'HurlerPercival' then
		PetInfo = "Beetle, Vermin"
		PetJob = 'Paladin'
	elseif state.JugMode.value == 'BlackbeardRandy' then
		PetInfo = "Tiger, Beast"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'GenerousArthur' then
		PetInfo = "Slug, Amorph"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'ThreestarLynn' then
		PetInfo = "Ladybug, Vermin"
		PetJob = 'Thief'
	elseif state.JugMode.value == 'BraveHeroGlenn' then
		PetInfo = "Frog, Aquan"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'SharpwitHermes' then
		PetInfo = "Mandragora, Plantoid"
		PetJob = 'Monk'
	elseif state.JugMode.value == 'ColibriFamiliar' then
		PetInfo = "Colibri, Bird"
		PetJob = 'Red Mage'
	elseif state.JugMode.value == 'ChoralLeera' then
		PetInfo = "HQ Colibri, Bird"
		PetJob = 'Red Mage'
	elseif state.JugMode.value == 'SpiderFamiliar' then
		PetInfo = "Spider, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'GussyHachirobe' then
		PetInfo = "HQ Spider, Vermin"
		PetJob = 'Warrior'
	elseif state.JugMode.value == 'AcuexFamiliar' then
		PetInfo = "Acuex, Amorph"
		PetJob = 'Black Mage'
	elseif state.JugMode.value == 'FluffyBredo' then
		PetInfo = "HQ Acuex, Amorph"
		PetJob = 'Black Mage'
	end
end

-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)    	
	if player.equipment.back == 'Mecisto. Mantle' or player.equipment.back == 'Aptitude Mantle' or player.equipment.back == 'Aptitude Mantle +1' then
		disable('back')
	else
		enable('back')
	end
end

-- Return true if we handled the aftercast work.  Otherwise it will fall back
-- to the general aftercast() code in Mote-Include.
function job_aftercast(spell, action, spellMap, eventArgs)
 
end

function get_combat_form()
	if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		state.CombatForm:set('DW')
	else
		state.CombatForm:reset()
	end
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end