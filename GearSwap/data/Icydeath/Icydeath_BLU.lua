--[[
		== Switch OffenseMode ==
			/con gs c cycle OffenseMode
			
		== Auto Actions (requires the windower addon: shortcuts) ==
			/con gs c cycle AutoMode				[ Default: Off ]
			
		== Below only applies when AutoMode is On. ==
			/con gs c cycle WSWhenHPGreaterThan		[ Default: WS when > 0% ]
			/con gs c cycle SelfCureWhenBelow		[ Default: Cure when < 30% ]
			/con gs c cycle AutoMG					[ Default: Off ]
			
--]]

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
	include('organizer-lib')
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()	
	set_lockstyle('4')
	
	state.AutoMode = M{['description'] = 'Auto Mode(default: Off)'}
	state.WSWhenHPGreaterThan = M{['description'] = 'WS When HP Greater Than(default: 0)'}
	state.SelfCureWhenBelow = M{['description'] = 'Self Cure When Below(default: 30)'}
	state.AutoMG = M{['description'] = 'Auto cast Mighty Guard.(default: Off'}
	
	state.AutoMode:options('Off', 'On')
	state.WSWhenHPGreaterThan:options(0, 20, 40)
	state.SelfCureWhenBelow:options(30, 50, 75)
	state.AutoMG:options('Off', 'On')
	
    state.Buff['Burst Affinity'] = buffactive['Burst Affinity'] or false
    state.Buff['Chain Affinity'] = buffactive['Chain Affinity'] or false
    state.Buff.Convergence = buffactive.Convergence or false
    state.Buff.Diffusion = buffactive.Diffusion or false
    state.Buff.Efflux = buffactive.Efflux or false
    
    state.Buff['Unbridled Learning'] = buffactive['Unbridled Learning'] or false

    state.OffenseMode:options('Normal', 'Acc', 'Refresh', 'Learning')
	state.IdleMode:options('Normal', 'PDT', 'MDT', 'Learning')
    state.HybridMode:options('Normal', 'Acc', 'PDT')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.CastingMode:options('Normal', 'Resistant')
    state.PhysicalDefenseMode:options('PDT', 'MDT')
	
	-- Event Register for AutoMode
	windower.register_event('tp change', function(tp)
        if tp > 100
				and state.AutoMode.value == 'On'
				and player.status == 'Engaged' then
            relaxed_play_mode()
        end
    end)
	
	windower.register_event('time change', function(time)
        if player.tp == 3000
                and state.AutoMode.value == 'On'
                and player.status == 'Engaged' then
            relaxed_play_mode()
        end
    end)
	
	-- Map for auto activation of Berserk/Warcry based
    -- on Weaponskills listed
    berserk_warcry_automation = S{
        'Chant du Cygne',
        'Expiacion',
        'Realmrazer',
        'Requiescat'}
	
    blue_magic_maps = {}
    
    -- Mappings for gear sets to use for various blue magic spells.
    -- While Str isn't listed for each, it's generally assumed as being at least
    -- moderately signficant, even for spells with other mods.
    
    -- Physical Spells --
    
    -- Physical spells with no particular (or known) stat mods
    blue_magic_maps.Physical = S{
        'Bilgestorm'
    }

    -- Spells with heavy accuracy penalties, that need to prioritize accuracy first.
    blue_magic_maps.PhysicalAcc = S{
        'Heavy Strike',
    }

    -- Physical spells with Str stat mod
    blue_magic_maps.PhysicalStr = S{
        'Battle Dance','Bloodrake','Death Scissors','Dimensional Death',
        'Empty Thrash','Quadrastrike','Sinker Drill','Spinal Cleave',
        'Uppercut','Vertical Cleave'
    }
        
    -- Physical spells with Dex stat mod
    blue_magic_maps.PhysicalDex = S{
        'Amorphic Spikes','Asuran Claws','Barbed Crescent','Claw Cyclone','Disseverment',
        'Foot Kick','Frenetic Rip','Goblin Rush','Hysteric Barrage','Paralyzing Triad',
        'Seedspray','Sickle Slash','Smite of Rage','Terror Touch','Thrashing Assault',
        'Vanity Dive'
    }
        
    -- Physical spells with Vit stat mod
    blue_magic_maps.PhysicalVit = S{
        'Body Slam','Cannonball','Delta Thrust','Glutinous Dart','Grand Slam',
        'Power Attack','Quad. Continuum','Sprout Smack','Sub-zero Smash'
    }
        
    -- Physical spells with Agi stat mod
    blue_magic_maps.PhysicalAgi = S{
        'Benthic Typhoon','Feather Storm','Helldive','Hydro Shot','Jet Stream',
        'Pinecone Bomb','Spiral Spin','Wild Oats'
    }

    -- Physical spells with Int stat mod
    blue_magic_maps.PhysicalInt = S{
        'Mandibular Bite','Queasyshroom'
    }

    -- Physical spells with Mnd stat mod
    blue_magic_maps.PhysicalMnd = S{
        'Ram Charge','Screwdriver','Tourbillion'
    }

    -- Physical spells with Chr stat mod
    blue_magic_maps.PhysicalChr = S{
        'Bludgeon'
    }

    -- Physical spells with HP stat mod
    blue_magic_maps.PhysicalHP = S{
        'Final Sting'
    }

    -- Magical Spells --
	all_magical_spells = S{
		'Blastbomb','Blazing Bound','Bomb Toss','Corrosive Ooze','Cursed Sphere','Entomb','Dark Orb','Death Ray',
        'Diffusion Ray','Droning Whirlwind','Embalming Earth','Firespit','Foul Waters',
        'Ice Break','Leafstorm','Maelstrom','Regurgitation','Rending Deluge',
        'Retinal Glare','Spectral Floe','Subduction','Tem. Upheaval','Tenebral Crush','Water Bomb',
        '1000 Needles','Absolute Terror','Actinic Burst','Auroral Drape','Awful Eye',
        'Blank Gaze','Blistering Roar','Blood Drain','Blood Saber','Chaotic Eye',
        'Cimicine Discharge','Cold Wave','Corrosive Ooze','Demoralizing Roar','Digest',
        'Dream Flower','Enervation','Feather Tickle','Filamented Hold','Frightful Roar',
        'Geist Wall','Hecatomb Wave','Infrasonics','Jettatura','Light of Penance',
        'Lowing','Mind Blast','Mortal Ray','MP Drainkiss','Osmosis','Reaving Wind',
        'Sandspin','Sandspray','Sheep Song','Soporific','Sound Blast','Stinking Gas','Benthic Typhoon','Silent Storm',
        'Sub-zero Smash','Venom Shell','Voracious Trunk','Yawn','Charged Whisker','Gates of Hades','Anvil Lightning',
		'Acrid Stream','Evryone. Grudge','Magic Hammer','Mind Blast','Rail Cannon','Scouring Spate',
		'Eyes On Me','Mysterious Light','Blinding Fulgor','Thermal Pulse'
    }
	
    -- Magical spells with the typical Int mod
    blue_magic_maps.Magical = S{
        'Blastbomb','Blazing Bound','Bomb Toss','Corrosive Ooze','Cursed Sphere','Entomb','Dark Orb','Death Ray',
        'Diffusion Ray','Droning Whirlwind','Embalming Earth','Firespit','Foul Waters',
        'Ice Break','Leafstorm','Maelstrom','Regurgitation','Rending Deluge',
        'Retinal Glare','Spectral Floe','Subduction','Tem. Upheaval','Tenebral Crush','Water Bomb'
    }
	
	blue_magic_maps.MagicalDark = S{
        'Tenebral Crush','Blood Drain','Death Ray','MP Drainkiss','Blood Saber','Eyes on Me','Osmosis',
		'Sandspray','Evryone. Grudge','Dark Orb','Atra. Libations','Palling Salvo'
    }
	
    -- Magical spells with a primary Mnd mod
    blue_magic_maps.MagicalMnd = S{
        'Acrid Stream','Evryone. Grudge','Magic Hammer','Mind Blast','Rail Cannon','Diffusion Ray','Scouring Spate'
    }

    -- Magical spells with a primary Agi mod
    blue_magic_maps.MagicalAgi = S{
        'Benthic Typhoon','Silent Storm'
    }

    -- Magical spells with a primary Chr mod
    blue_magic_maps.MagicalChr = S{
        'Eyes On Me','Mysterious Light','Blinding Fulgor'
    }

    -- Magical spells with a Vit stat mod (on top of Int)
    blue_magic_maps.MagicalVit = S{
        'Thermal Pulse','Sub-zero Smash'
    }

    -- Magical spells with a Dex stat mod (on top of Int)
    blue_magic_maps.MagicalDex = S{
        'Charged Whisker','Gates of Hades','Anvil Lightning'
    }
            
    -- Magical spells (generally debuffs) that we want to focus on magic accuracy over damage.
    -- Add Int for damage where available, though.
    blue_magic_maps.MagicAccuracy = S{
        '1000 Needles','Absolute Terror','Actinic Burst','Auroral Drape','Awful Eye',
        'Blank Gaze','Blistering Roar','Blood Drain','Blood Saber','Chaotic Eye',
        'Cimicine Discharge','Cold Wave','Corrosive Ooze','Demoralizing Roar','Digest',
        'Dream Flower','Enervation','Feather Tickle','Filamented Hold','Frightful Roar',
        'Geist Wall','Hecatomb Wave','Infrasonics','Jettatura','Light of Penance',
        'Lowing','Mind Blast','Mortal Ray','MP Drainkiss','Osmosis','Reaving Wind',
        'Sandspin','Sandspray','Sheep Song','Soporific','Sound Blast','Stinking Gas',
        'Sub-zero Smash','Venom Shell','Voracious Trunk','Yawn'
    }
        
    -- Breath-based spells
    blue_magic_maps.Breath = S{
        'Bad Breath','Flying Hip Press','Frost Breath','Heat Breath',
        'Hecatomb Wave','Magnetite Cloud','Poison Breath','Radiant Breath','Self-Destruct',
        'Thunder Breath','Vapor Spray','Wind Breath'
    }

    -- Stun spells
    blue_magic_maps.Stun = S{
        'Blitzstrahl','Frypan','Head Butt','Sudden Lunge','Tail slap','Temporal Shift',
        'Thunderbolt','Whirl of Rage'
    }
        
    -- Healing spells
    blue_magic_maps.Healing = S{
        'Healing Breeze','Magic Fruit','Plenilune Embrace','Pollen','Restoral','White Wind',
        'Wild Carrot'
    }
    
    -- Buffs that depend on blue magic skill
    blue_magic_maps.SkillBasedBuff = S{
        'Barrier Tusk','Diamondhide','Magic Barrier','Metallic Body','Occultation','Plasma Charge',
        'Pyric Bulwark','Reactor Cool',
    }

    -- Other general buffs
    blue_magic_maps.Buff = S{
        'Amplification','Animating Wail','Battery Charge','Carcharian Verve','Cocoon',
        'Erratic Flutter','Exuviation','Fantod','Feather Barrier','Harden Shell',
        'Memento Mori','Mighty Guard','Nat. Meditation','Orcish Counterstance','Refueling',
        'Regeneration','Saline Coat','Triumphant Roar','Warm-Up','Winds of Promyvion',
        'Zephyr Mantle'
    }
    
    
    -- Spells that require Unbridled Learning to cast.
    unbridled_spells = S{
        'Absolute Terror','Bilgestorm','Blistering Roar','Bloodrake','Carcharian Verve',
        'Droning Whirlwind','Gates of Hades','Harden Shell','Mighty Guard','Pyric Bulwark','Thunderbolt',
        'Tourbillion'
    }	
	
	
	-- Additional local binds
    send_command('bind ^` input /ja "Chain Affinity" <me>')
    send_command('bind !` input /ja "Efflux" <me>')
    send_command('bind @` input /ja "Burst Affinity" <me>')

    update_combat_form()
    
	determine_haste_group()
	
	
	sets.Obi = {waist='Hachirin-no-Obi'}
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind @`')
end


-- Set up gear sets.
function init_gear_sets()
    organizer_items = {
		iris="Iris",
		iris_sub="Iris"
	}
	
	--------------------------------------
    -- Start defining the sets
    ---------------------------------
	sets.buff['Burst Affinity'] = {feet="Hashishin Basmak"}
    sets.buff['Chain Affinity'] = {head="Hashishin Kavuk"} --, feet="Assimilator's Charuqs"
    sets.buff.Convergence = {head="Luhlaza Keffiyeh"}
    sets.buff.Diffusion = {feet="Luhlaza Charuqs"}
    sets.buff.Enchainment = {body="Luhlaza Jubbah"}
    sets.buff.Efflux = {
		legs="Hashishin Tayt +1", 
		back={ name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
	}
    
    
    -- Precast Sets
    
    -- Precast sets to enhance JAs
    sets.precast.JA['Azure Lore'] = {hands="Luhlaza Bazubands"}
	

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {}
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast cast sets for spells
    
    sets.precast.FC = {
		ammo="Impatiens",
		head={ name="Herculean Helm", augments={'Mag. Acc.+16 "Mag.Atk.Bns."+16','Crit. hit damage +2%','STR+3','Mag. Acc.+15','"Mag.Atk.Bns."+11',}},
		body="Dread Jupon",
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
		legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
		feet={ name="Amalric Nails", augments={'Mag. Acc.+15','"Mag.Atk.Bns."+15','"Conserve MP"+6',}},
		waist="Witful Belt",
		left_ear="Enchntr. Earring +1",
		right_ear="Loquac. Earring",
		left_ring="Prolix Ring",
		back="Swith Cape",
	}
        
    sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {body="Hashishin Mintan"})

       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo="Jukukik Feather",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Samnuha Tights",
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Brutal Earring",
		right_ear="Moonshade Earring",
		left_ring="Begrudging Ring",
		right_ring="Epona's Ring",
		back="Bleating Mantle",
	}
    
    sets.precast.WS.acc = set_combine(sets.precast.WS, {
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
		back="Sokolski Mantle",
	})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Requiescat'] = {}
    
    sets.precast.WS['Sanguine Blade'] = {}

    sets.precast.WS['Savage Blade'] = {}
		
    sets.precast.WS['Savage Blade'].Acc = {}
    
    sets.precast.WS['Chant du Cygne'] = {
		ammo="Jukukik Feather",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Herculean Vest", augments={'Accuracy+3 Attack+3','Crit. hit damage +4%','DEX+9','Accuracy+7','Attack+1',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+23 Attack+23','Crit. hit damage +3%','STR+8','Attack+15',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+15','Crit. hit damage +3%','DEX+6','Attack+3',}},
		feet={ name="Herculean Boots", augments={'Crit. hit damage +4%','STR+12','Accuracy+11','Attack+11',}},
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Brutal Earring",
		right_ear="Moonshade Earring",
		left_ring="Begrudging Ring",
		right_ring="Epona's Ring",
		back={ name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
	}
    
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS['Chant du Cygne'], {
		left_ear="Steelflash Earring",
		right_ear="Bladeborn Earring",
	})

    
    -- Midcast Sets
    sets.midcast.FastRecast = sets.precast.FC
        
    sets.midcast['Enhancing Magic'] = {waist="Olympus sash", back="Merciful Cape"}

    sets.midcast['Blue Magic'] = set_combine(sets.midcast.FastRecast, {hands="Hashishin Bazubands"})
    
    -- Physical Spells --
    
	-- I usually put a well rounded mix of STR, DEX, and ACC into this set.
    sets.midcast['Blue Magic'].Physical = {
		ammo="Mavi Tathlum",
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs="Hashishin Tayt +1",
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Deceiver's Torque",
		waist="Grunfeld Rope",
		left_ear="Cessance Earring",
		right_ear="Moonshade Earring",
		left_ring="Petrov Ring",
		right_ring="Apate Ring",
		back={ name="Cornflower Cape", augments={'MP+16','DEX+5','Blue Magic skill +8',}},
	}
	
	-- I usually go straight Blue Magic Skill and ACC gear.
    sets.midcast['Blue Magic'].PhysicalAcc = {
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+24 Attack+24','DEX+9','Accuracy+3',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Deceiver's Torque",
		waist="Grunfeld Rope",
		left_ear="Steelflash Earring",
		right_ear="Heartseeker Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Patricius Ring",
		back={ name="Cornflower Cape", augments={'MP+16','DEX+5','Blue Magic skill +8',}},
	}

    sets.midcast['Blue Magic'].PhysicalStr = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalDex = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalVit = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalAgi = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalInt = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalMnd = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalChr = set_combine(sets.midcast['Blue Magic'].Physical, {})

    sets.midcast['Blue Magic'].PhysicalHP = set_combine(sets.midcast['Blue Magic'].Physical, {})


    -- Magical Spells --
    
    sets.midcast['Blue Magic'].Magical = {
		ammo="Mavi Tathlum",
		head={ name="Herculean Helm", augments={'Mag. Acc.+16 "Mag.Atk.Bns."+16','Crit. hit damage +2%','STR+3','Mag. Acc.+15','"Mag.Atk.Bns."+11',}},
		body={ name="Amalric Doublet", augments={'MP+60','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
		hands={ name="Amalric Gages", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
		legs={ name="Amalric Slops", augments={'MP+60','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
		feet={ name="Herculean Boots", augments={'Mag. Acc.+17 "Mag.Atk.Bns."+17','"Store TP"+1','STR+1','"Mag.Atk.Bns."+15',}},
		neck="Deceiver's Torque",
		waist="Yamabuki-no-Obi",
		left_ear="Friomisi Earring",
		right_ear="Hecate's Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Acumen Ring",
		back={ name="Cornflower Cape", augments={'MP+16','DEX+5','Blue Magic skill +8',}},
	}

    sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {
		waist="Porous Rope",
		ring2="Balrahn's Ring",
		ear2="Gwati earring"
	})
    
    sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})
	
	sets.midcast['Blue Magic'].MagicalAgi = set_combine(sets.midcast['Blue Magic'].Magical, {})

	sets.midcast['Blue Magic'].MagicalAgi.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {})

		
    sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})
	
	sets.midcast['Blue Magic'].MagicalDark = set_combine(sets.midcast['Blue Magic'].Magical, {
		head="Pixie Hairpin +1",
		right_ring="Archon Ring"
	})

	-- blue magic skill & magic acc
    sets.midcast['Blue Magic'].MagicAccuracy = {
		ammo="Mavi Tathlum",
		head={ name="Herculean Helm", augments={'Mag. Acc.+16 "Mag.Atk.Bns."+16','Crit. hit damage +2%','STR+3','Mag. Acc.+15','"Mag.Atk.Bns."+11',}},
		body={ name="Amalric Doublet", augments={'MP+60','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
		hands={ name="Amalric Gages", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
		legs="Hashishin Tayt +1",
		feet={ name="Herculean Boots", augments={'Mag. Acc.+17 "Mag.Atk.Bns."+17','"Store TP"+1','STR+1','"Mag.Atk.Bns."+15',}},
		neck="Deceiver's Torque",
		waist="Yamabuki-no-Obi",
		left_ear="Lifestorm Earring",
		right_ear="Psystorm Earring",
		left_ring="Fenrir Ring +1",
		right_ring="Balrahn's Ring",
		back={ name="Cornflower Cape", augments={'MP+16','DEX+5','Blue Magic skill +8',}},
	}

    -- Breath Spells --
    
    sets.midcast['Blue Magic'].Breath = {}

    -- Other Types --
    
    sets.midcast['Blue Magic'].Stun = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {waist="Chaac Belt"})
        
    sets.midcast['Blue Magic']['White Wind'] = {}

	sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast['Blue Magic'].Healing = {
	
	}

    sets.midcast['Blue Magic'].SkillBasedBuff = {
		ammo="Mavi Tathlum",
		head={ name="Luhlaza Keffiyeh", augments={'Enhances "Convergence" effect',}},
		body="Assim. Jubbah",
		hands="Fea's Cuffs",
		legs="Hashishin Tayt +1",
		feet={ name="Luhlaza Charuqs", augments={'Enhances "Diffusion" effect',}},
		neck="Deceiver's Torque",
		back={ name="Cornflower Cape", augments={'MP+16','DEX+5','Blue Magic skill +8',}},
	}

    sets.midcast['Blue Magic'].Buff = set_combine(sets.midcast['Blue Magic'].SkillBasedBuff, {
		hands="Hashishin Bazubands"
	})
    
    sets.midcast.Protect = {ring1="Sheltered Ring"}
    sets.midcast.Protectra = {ring1="Sheltered Ring"}
    sets.midcast.Shell = {ring1="Sheltered Ring"}
    sets.midcast.Shellra = {ring1="Sheltered Ring"}
    

    
    
    -- Sets to return to when not performing an action.

    -- Gear for learning spells: +skill and AF hands.
    sets.Learning = {
		ammo="Mavi Tathlum",
		neck="Deceiver's Torque",
        head="Luhlaza Keffiyeh",
        body="Assimilator's Jubbah",
        hands="Assimilator's Bazubands",
        back="Cornflower Cape",
        legs="Hashishin Tayt +1",
        feet="Luhlaza Charuqs"
	}


    sets.latent_refresh = {waist="Fucho-no-obi"}

    -- Resting sets
        
    -- Idle sets
    sets.idle = {
		ammo="Ginsen",
		head="Rawhide Mask",
		body="Mekosu. Harness",
		hands={ name="Herculean Gloves", augments={'AGI+7','Crit.hit rate+1','"Refresh"+2','Accuracy+5 Attack+5','Mag. Acc.+9 "Mag.Atk.Bns."+9',}},
		legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Sanctity Necklace",
		waist="Flume Belt +1",
		left_ear="Etiolation Earring",
		right_ear="Infused Earring",
		left_ring={ name="Dark Ring", augments={'Magic dmg. taken -5%','Phys. dmg. taken -5%',}},
		right_ring="Defending Ring",
		back="Xucau Mantle",
	}

    sets.idle.PDT = {}

	sets.idle.MDT = {}

    sets.idle.Town = set_combine(sets.idle, {legs="Crimson Cuisses"})

    sets.idle.Learning = set_combine(sets.idle, {
		ammo="Mavi Tathlum",
		neck="Deceiver's Torque",
        head="Luhlaza Keffiyeh",
        body="Assimilator's Jubbah",
        hands="Assimilator's Bazubands",
        back="Cornflower Cape",
        legs="Hashishin Tayt +1",
        feet="Luhlaza Charuqs"
	})

    
    -- Defense sets
    sets.defense.PDT = {}

    sets.defense.MDT = {}

    sets.Kiting = {legs="Crimson Cuisses"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {}
    sets.engaged.Acc = {}
    sets.engaged.Refresh = {}

		--Standard DW engaged set 0% haste (You need 21% DW from gear)
    sets.engaged.DW = {
		ammo="Ginsen",
		head={ name="Taeon Chapeau", augments={'Accuracy+18','"Dual Wield"+4','STR+7 AGI+7',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs={ name="Herculean Trousers", augments={'Accuracy+24 Attack+24','DEX+9','Accuracy+3',}},
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Lissome Necklace",
		waist="Windbuffet Belt +1",
		left_ear="Dudgeon Earring",
		right_ear="Heartseeker Earring",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
	}
    sets.engaged.DW.Refresh = {}
    sets.engaged.DW.Acc = set_combine(sets.engaged.DW, {
		waist="Kentarch Belt +1",
		left_ring="Cacoethic Ring +1",
	})
	sets.engaged.DW.PDT = {}
	sets.engaged.DW.Acc.PDT = {}

		--High Haste engaged sets, approx 30% haste (You need ~16% DW from gear)
    sets.engaged.DW.HighHaste = {
		ammo="Ginsen",
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs="Samnuha Tights",
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Lissome Necklace",
		waist="Windbuffet Belt +1",
		left_ear="Dudgeon Earring",
		right_ear="Heartseeker Earring",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
	}
    sets.engaged.DW.Refresh.HighHaste = {}
	sets.engaged.DW.Acc.HighHaste = set_combine(sets.engaged.DW.HighHaste, {
		waist="Kentarch Belt +1",
		left_ring="Cacoethic Ring +1",
	})
	sets.engaged.DW.PDT.HighHaste = {}
	sets.engaged.DW.Acc.PDT.HighHaste = {}
		
		--Max Haste engaged sets, approx 43.75% haste (You need 11% DW from gear)
    sets.engaged.DW.MaxHaste = {
		ammo="Ginsen",
		head={ name="Dampening Tam", augments={'DEX+9','Accuracy+13','Mag. Acc.+14','Quadruple Attack +2',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Herculean Gloves", augments={'Accuracy+21 Attack+21','"Triple Atk."+3','STR+9','Accuracy+15','Attack+9',}},
		legs="Samnuha Tights",
		feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','Attack+7',}},
		neck="Lissome Necklace",
		waist="Windbuffet Belt +1",
		left_ear="Brutal Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Rosmerta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
	}
    sets.engaged.DW.Refresh.MaxHaste = {}
	sets.engaged.DW.Acc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {
		waist="Kentarch Belt +1",
		left_ring="Cacoethic Ring +1",
	})
	sets.engaged.DW.PDT.MaxHaste = {}
	sets.engaged.DW.Acc.PDT.MaxHaste = {}

		
    sets.Weapons = {main="Almace", sub={ name="Colada", augments={'Crit.hit rate+3','DEX+14','Accuracy+17','DMG:+7',}}}

    sets.engaged.Nuke = {}
    sets.engaged.Learning = set_combine(sets.engaged, sets.Learning)
    sets.engaged.DW.Learning = set_combine(sets.engaged.DW, sets.Learning)
	sets.TreasureHunter = {waist="Chaac Belt"}
    sets.self_healing = { }
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if unbridled_spells:contains(spell.english) and not state.Buff['Unbridled Learning'] then
        eventArgs.cancel = true
        windower.send_command('@input /ja "Unbridled Learning" <me>; wait 1.5; input /ma "'..spell.name..'" '..spell.target.name)
    end
	
	
	-- Automates Aggressor/Berserk/Warcry for Warrior sub job
    if state.AutoMode.value == 'On'
			and berserk_warcry_automation:contains(spell.name)
            and player.status == 'Engaged'
            and player.sub_job == 'WAR'
            and check_recasts(j('Aggressor'))
            and not check_buffs(
                'Amnesia',
                'Berserk',
                'Obliviscence',
                'Paralysis') then
        windower.send_command('aggressor; wait 1; berserk; wait 1; warcry; wait 1;'..spell.name..' '..spell.target.raw)
        cancel_spell()
        return
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Add enhancement gear for Chain Affinity, etc.
    if spell.skill == 'Blue Magic' then
        for buff,active in pairs(state.Buff) do
            if active and sets.buff[buff] then
                equip(sets.buff[buff])
            end
        end
        if spellMap == 'Healing' and spell.target.type == 'SELF' and sets.self_healing then
            equip(sets.self_healing)
        end
    end
	
	-- element belt
	if all_magical_spells:contains(spell.english) then
		if spell.element == world.day_element or spell.element == world.weather_element then
			equip(sets.Obi)
		end
	end
	
    -- If in learning mode, keep on gear intended to help with that, regardless of action.
    if state.OffenseMode.value == 'Learning' then
        equip(sets.Learning)
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if S{'haste','march','embrava','haste samba','mighty guard'}:contains(buff:lower()) then
        determine_haste_group()
        handle_equipping_gear(player.status)
    elseif state.Buff[buff] ~= nil then
        state.Buff[buff] = gain
        handle_equipping_gear(player.status)
	end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
-- Return custom spellMap value that can override the default spell mapping.
-- Don't return anything to allow default spell mapping to be used.
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Blue Magic' then
        for category,spell_list in pairs(blue_magic_maps) do
            if spell_list:contains(spell.english) then
                return category
            end
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 then
        set_combine(idleSet, sets.latent_refresh)
    end
    return idleSet
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    update_combat_form()
	determine_haste_group()
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_combat_form()
    -- Check for H2H or single-wielding
    if player.equipment.sub == "Genbu's Shield" or player.equipment.sub == 'empty' then
        state.CombatForm:reset()
    else
        state.CombatForm:set('DW')
    end
end

function determine_haste_group()

    classes.CustomMeleeGroups:clear()
    
    if buffactive[604] == 1 and buffactive.haste then
		classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive.march == 2 and buffactive.haste then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.embrava and (buffactive.haste or buffactive.march) then
        classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive.haste == 2 then
		classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive.haste == 1 then
		classes.CustomMeleeGroups:append('HighHaste')
    elseif buffactive.march == 2 then
        classes.CustomMeleeGroups:append('HighHaste')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Addtional Methods needed for Auto Mode
-------------------------------------------------------------------------------------------------------------------
function check_buffs(...)
    --[[ Function Author: Arcon
            Simple check before attempting to auto activate Job Abilities that
            check active buffs and debuffs ]]
    return table.any({...}, table.get+{buffactive})
end

function check_set_spells(...)
    --[[ Function Author: Arcon
            Used to pull list of currently set spells, this is useful for
            determining traits such as Dual Wield IV
            Also used to determine the Cure spell set, when used with a
            self_command ]]
    set_spells = set_spells
        or gearswap.res.spells:type('BlueMagic'):rekey('name')
        return table.all({...}, function(name)
        return S(windower.ffxi.get_mjob_data().spells)
        :contains(set_spells[name].id)
    end)
end

do
    --[[ Author: Arcon
            The three next "do" sections are used to aid in checking recast
            times, can check multiple recast times at once ]]
    local cache = {}

    function j(str)
        if not cache[str] then
            cache[str] = gearswap.res.job_abilities:with('name', str)
        end

        return cache[str]
    end
end

do
    local cache = {}

    function s(str)
        if not cache[str] then
            cache[str] = gearswap.res.spells:with('name', str)
        end

        return cache[str]
    end
end

do
    local ja_types = S(gearswap.res.job_abilities:map(table.get-{'type'}))

    function check_recasts(...)
        local spells = S{...}

        for spell in spells:it() do
            local fn = 'get_' .. (ja_types:contains(spell.type)
                    and 'ability'
                    or 'spell') ..'_recasts'
            if windower.ffxi[fn]()[spell.recast_id] > 0 then
                return false
            end
        end

        return true
    end
end


-- MAKE A MACRO: /con gs c cycle AutoMode
-- DEFAULT: Off
function relaxed_play_mode()
    -- This can be used as a mini bot to automate actions
    if not midaction() then
        if player.hpp < state.SelfCureWhenBelow.value 
				and not check_buffs('silence', 'mute') then
            select_self_cure()
		--[[ 
        elseif player.target.hpp < 40
                and player.target.hpp > 15
                and not check_buffs('silence', 'mute')
                and player.target.distance < 5 then
            windower.send_command('sinker drill')
		--]]
		elseif not check_buffs('Mighty Guard')
				and state.AutoMG.value == "On"
				and check_recasts(j('Unbridled Learning'))
				and not check_buffs('silence', 'mute', 'amnesia') then
			windower.send_command('unbridled learning; wait 1; diffusion; wait 1; mighty guard;')
        elseif not check_buffs('Haste') --92mp
                and not check_buffs('silence', 'mute')
                and check_recasts(s('Erratic Flutter')) 
				and player.mp > 91 then
            windower.send_command('erratic flutter')

        elseif not check_buffs('Attack Boost') --38mp
				and not check_buffs('Attack Down')
                and not check_buffs('silence', 'mute')
                and check_recasts(s('Nat. Meditation')) 
				and player.mp > 37 then
            windower.send_command('nat. meditation')

        elseif player.equipment.main == 'Tizona'
                and not check_buffs('Aftermath: Lv.3')
                and player.tp < 3000 then
            return

        elseif player.equipment.main == 'Tizona'
                and not check_buffs('Aftermath: Lv.3')
                and player.target.hpp > 40
                and player.tp == 3000 then
            windower.send_command('expiacion')

        elseif player.tp > 999
                and player.target.hpp > state.WSWhenHPGreaterThan.value
                and player.target.distance < 6 
				and not check_buffs('amnesia') then
            windower.send_command('chant du cygne')
        end
    end
end

function select_self_cure()
	if check_set_spells('Magic Fruit') 
			and check_recasts(s('Magic Fruit')) 
			and player.mp > 72 then
		windower.send_command('input /ma "Magic Fruit" <me>')
	elseif check_set_spells('Plenilune Embrace') 
			and check_recasts(s('Plenilune Embrace')) 
			and player.mp > 106 then
		windower.send_command('plenilune embrace')
	elseif check_set_spells('Restoral') 
			and check_recasts(s('Restoral')) 
			and player.mp > 127 then
		windower.send_command('restoral')
	elseif check_set_spells('White Wind') 
			and check_recasts(s('White Wind')) 
			and player.mp > 145 then
		windower.send_command('white wind')
	else
		if player.sub_job == 'RDM' then
			if check_recasts(s('Cure IV')) 
					and player.mp > 88 then
				windower.send_command('input /ma "Cure IV" <me>')
			elseif check_recasts(s('Cure III')) 
					and player.mp > 46 then
				windower.send_command('input /ma "Cure III" <me>')
			else
				windower.add_to_chat(8,'WARNING: Unable to self cure!')
			end
		else
			windower.add_to_chat(8,'WARNING: No Cure spell is currently set!')
		end
	end
end

function set_lockstyle(num)
	send_command('wait 2; input /lockstyleset '..num)
end