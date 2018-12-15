--TO DO:
-- Add auto convert into the the Auto BP mode. 
-- Currently you have to convert manually and re-instruct BP use after converting to resume AutoBPing

-- Blood Pacts Groupings:	
--[[
     Put: /console gs c pact [PactType] as your macro in game
	 
        PactType can be one of:
            cure
            curaga
            buffOffense
            buffDefense
            buffSpecial
            debuff1
            debuff2
            sleep
            nuke2
            nuke4
            bp70
            bp75 (merits and lvl 75-80 pacts)
			bp99
            astralflow
--]]

-- Setup your Key Bindings here:  (These are optional, but nice toggles to have)
    windower.send_command('bind f7 gs c toggle mb')
    windower.send_command('bind f9 gs c avatar mode')
    windower.send_command('bind f10 gs c toggle auto')
    windower.send_command('bind f12 gs c toggle melee')

--[[
If you don't want the binds and prefer to macro them you can macro:

/console gs c avatar tank           toggle pet DT
/console gs c avatar acc            toggle pet acc mode
/console gs c avatar perp           toggle pet perp and refresh gear (this is default)
/console gs c avatar melee          toggle pet haste / DA / atk set (if you have one)

/console gs c toggle mb             toggle Glyphic Bracers +1 override in MAb set.
/console gs c toggle auto           toggle on / off auto BP recast under Apogee or Astral Conduit (repeat BP asap after 1rst cast)

]]
     
-- Setup your Gear Sets below:
function get_sets()
	include('organizer-lib')  
    -- My formatting is very easy to follow. All sets that pertain to my character doing things are under 'me'.
    -- All sets that are equipped to faciliate my avatar's behaviour or abilities are under 'avatar', eg, Perpetuation, Blood Pacts, etc
      
    sets.me = {}        -- leave this empty
    sets.avatar = {}    -- leave this empty
      
    -- Your idle set when you DON'T have an avatar out
    sets.me.idle = {
				main="Nirvana",
				sub="Oneiros Grip",
				ammo="Sancus Sachet +1",
				head="Convoker's Horn",
				neck="Caller's Pendant",
				ear1="Moonshade Earring",
				ear2="Andoaa earring",
				rear="Caller's Earring",
				body="Shomonjijoe +1",
				hands="Glyphic Bracers",
				ring1="Evoker's Ring",
				ring2="Thurandaut Ring",
				back="Campestres's Cape",
				waist="Incarnation Sash",
				legs="Assiduity Pants +1",
				feet="Psycloth Boots"
    }
      
    -- Your MP Recovered Whilst Resting Set
    sets.me.resting = { 
	
    }
      
    -----------------------//
    -- Perpetuation Related
    -----------------------
      
    -- Avatar's Out --  
    -- This is the base for all perpetuation scenarios, as seen below
    sets.avatar.perp = {
				main="Nirvana",
                sub="Vox Grip",
                ammo="Sancus Sachet +1",
				head="Befouled Crown",
				body="Shomonjijoe +1",
				neck="Consumm. Torque",
				hands="Glyphic Bracers",
				ear1="Evans Earring",
				ear2="Andoaa earring",
				ring1="Evoker's Ring",
				ring2="Thurandaut Ring",
				back="Campestres's Cape", 
				waist="Lucidity Sash",
				legs="Assiduity Pants +1",
				feet="Psycloth Boots"
	
    }
  
    -- The following sets base off of perpetuation, so you can consider them idle sets.
    -- Set the relevant gear, bearing in mind it will overwrite the perpetuation item for that slot!
    sets.avatar["Carbuncle"] = {hands="Asteria Mitts"}
    sets.avatar["Cait Sith"] = {hands="Lamassu Mitts"}
    -- When we want our avatar to stay alive
    sets.avatar.tank = set_combine(sets.avatar.perp,{
	
    })
      
    -- When we want our avatar to shred
    sets.avatar.melee = set_combine(sets.avatar.perp,{

    })
      
    -- When we want our avatar to hit
    sets.avatar.acc = set_combine(sets.avatar.perp,{

    })
      
    -- When Avatar's Favor is active
    sets.avatar.favor = {
				main="Nirvana",
				sub="Vox Grip",
				ammo="Sancus Sachet +1",
				head="Beckoner's Horn +1",
				body="Beck. Doublet +1",
				hands=merlinic_hands_refresh,
				legs="Beck. Spats +1",
				feet={ name="Apogee Pumps", augments={'MP+60','Summoning magic skill +15','Blood Pact Dmg.+7',}},
				neck="Incanter's Torque",
				waist="Lucidity Sash",
				left_ear="Andoaa Earring",
				right_ear=moonshade,
				left_ring="Globidonta Ring",
				right_ring="Evoker's Ring",
    }
      
    ----------------------------
    -- Summoning Skill Related
    -- Including all blood pacts
    ----------------------------
      
    -- + Summoning Magic. This is a base set for max skill and blood pacts and we'll overwrite later as and when we need to
    sets.avatar.skill = {
				main="Exemplar",
				sub="Vox Grip",
				ammo="Esper Stone +1",
				head="Convoker's Horn",
				body="Beckoner's Doublet",
				hands="Lamassu Mitts",
				legs="Ngen Seraweels",
				feet="Rubeus Boots",
				neck="Caller's Pendant",
				waist="Lucidity Sash",
				left_ear="Smn. Earring",
				right_ear="Andoaa Earring",
				left_ring="Evoker's Ring",
				right_ring="Fervor Ring",
				back={ name="Conveyance Cape", augments={'Summoning magic skill +3','Pet: Enmity+12','Blood Pact Dmg.+2','Blood Pact ab. del. II -2',}},
    }
      
    -------------------------
    -- Individual Blood Pacts
    -------------------------
      
    -- Physical damage
    sets.avatar.atk = set_combine(sets.avatar.skill,{
				main="Nirvana",
				sub="Elan Strap",
				ammo="Sancus Sachet +1",
				head={ name="Helios Band", augments={'Pet: Accuracy+25 Pet: Rng. Acc.+25','Pet: Crit.hit rate +3','Blood Pact Dmg.+5',}},
				body="Con. Doublet +1",
				hands={ name="Merlinic Dastanas", augments={'Pet: Accuracy+24 Pet: Rng. Acc.+24','Blood Pact Dmg.+9','Pet: STR+7','Pet: "Mag.Atk.Bns."+13',}},
				legs={ name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%',}},
				feet={ name="Apogee Pumps", augments={'Pet: Attack+20','Pet: "Mag.Atk.Bns."+20','Blood Pact Dmg.+7',}},
				neck="Consumm. Torque",
				waist="Incarnation Sash",
				left_ear="Gelos Earring",
				right_ear="Andoaa Earring",
				left_ring="Varar Ring +1",
				right_ring="Varar Ring +1",
				back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Pet: Haste+7',}},
    })
	
    sets.avatar.pacc = set_combine(sets.avatar.atk,{
	
    })
      
    -- Magic Attack
    sets.avatar.mab = set_combine(sets.avatar.skill,{
				main={ name="Espiritus", augments={'MP+50','Pet: "Mag.Atk.Bns."+20','Pet: Mag. Acc.+20',}},
				sub="Elan Strap",
				ammo="Sancus Sachet +1",
				head={ name="Merlinic Hood", augments={'Pet: Mag. Acc.+23 Pet: "Mag.Atk.Bns."+23','Blood Pact Dmg.+6','Pet: INT+7','Pet: Mag. Acc.+3',}},
				body="Shomonjijoe +1",
				hands={ name="Merlinic Dastanas", augments={'Pet: Accuracy+24 Pet: Rng. Acc.+24','Blood Pact Dmg.+9','Pet: STR+7','Pet: "Mag.Atk.Bns."+13',}},
				legs={ name="Helios Spats", augments={'Pet: "Mag.Atk.Bns."+29','Pet: "Dbl. Atk."+8','Summoning magic skill +8',}},
				feet={ name="Apogee Pumps", augments={'Pet: Attack+20','Pet: "Mag.Atk.Bns."+20','Blood Pact Dmg.+7',}},
				neck="Adad Amulet",
				waist="Incarnation Sash",
				left_ear="Gelos Earring",
				right_ear="Andoaa Earring",
				left_ring="Varar Ring +1",
				right_ring="Varar Ring +1",
				back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Pet: Haste+7',}},
    })
	
    sets.avatar.mb = set_combine(sets.avatar.mab,{hands="Glyphic Bracers +1"})
    
	-- Hybrid
    sets.avatar.hybrid = set_combine(sets.avatar.skill,{
				main="Nirvana",
				sub="Elan Strap",
				ammo="Sancus Sachet +1",
				head={ name="Merlinic Hood", augments={'Pet: Mag. Acc.+23 Pet: "Mag.Atk.Bns."+23','Blood Pact Dmg.+6','Pet: INT+7','Pet: Mag. Acc.+3',}},
				body={ name="Helios Jacket", augments={'Pet: Attack+29 Pet: Rng.Atk.+29','Pet: "Dbl. Atk."+8','Blood Pact Dmg.+3',}},
				hands={ name="Merlinic Dastanas", augments={'Pet: Accuracy+24 Pet: Rng. Acc.+24','Blood Pact Dmg.+9','Pet: STR+7','Pet: "Mag.Atk.Bns."+13',}},
				legs={ name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%',}},
				feet={ name="Apogee Pumps", augments={'Pet: Attack+20','Pet: "Mag.Atk.Bns."+20','Blood Pact Dmg.+7',}},
				neck="Adad Amulet",
				waist="Incarnation Sash",
				left_ear="Gelos Earring",
				right_ear="Andoaa Earring",
				left_ring="Varar Ring +1",
				right_ring="Varar Ring +1",
				back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Pet: Haste+7',}},
    })
      
    -- Magic Accuracy
    sets.avatar.macc = set_combine(sets.avatar.skill,{

    })
      
    -- Buffs
    sets.avatar.buff = set_combine(sets.avatar.skill,{

    })
      
    -- Other
    sets.avatar.other = set_combine(sets.avatar.skill,{

    })
      
    -- Combat Related Sets
      
    -- Melee
    -- The melee set combines with perpetuation, because we don't want to be losing all our MP whilst we swing our Staff
    -- Anything you equip here will overwrite the perpetuation/refresh in that slot.
    sets.me.melee = set_combine(sets.avatar.perp,{

    })
      
    -- Shattersoul. Weapon Skills do not work off perpetuation as it only stays equipped for a moment
    sets.me["Shattersoul"] = set_combine(sets.avatar.perp,{

    })
    sets.me["Garland of Bliss"] = set_combine(sets.avatar.perp,{

    })
      
    -- Feel free to add new weapon skills, make sure you spell it the same as in game. These are the only two I ever use though
  
    ---------------
    -- Casting Sets
    ---------------
      
    sets.precast = {}
    sets.midcast = {}
    sets.aftercast = {}
      
    ----------
    -- Precast
    ----------
      
    -- Generic Casting Set that all others take off of. Here you should add all your fast cast: 
    sets.precast.casting = {
				neck="Orunmila's Torque",--5
				head="Merlinic Hood",
				body="Eirene's Manteel",
				hands="Wayfarer Cuffs",
				feet="Merlinic Crackows",
				neck="Orunmila's Torque",
				legs="Assid. Pants +1",
				waist="Witful Belt",
				left_ring="Prolix Ring",
				right_ring="Lebeche Ring",
				left_ear="Loquac. Earring",
				back="Swith Cape",
    }   
      
    -- Summoning Magic Cast time - gear
    sets.precast.summoning = set_combine(sets.precast.casting,{

    })
      
    -- Enhancing Magic, eg. Siegal Sash, etc
    sets.precast.enhancing = set_combine(sets.precast.casting,{
		waist="Siegal Sash",
        neck="Melic Torque",
    })
  
    -- Stoneskin casting time -, works off of enhancing -
    sets.precast.stoneskin = set_combine(sets.precast.enhancing,{

    })
      
    -- Curing Precast, Cure Spell Casting time -
    sets.precast.cure = set_combine(sets.precast.casting,{
		back="Pahtli Cape"
    })
      
    ---------------------
    -- Ability Precasting
    ---------------------
      

    sets.precast.bp = {

    }
      
    -- Mana Cede
    sets.precast["Mana Cede"] = set_combine(sets.avatar.skill,{
		hands="Beckoner's Bracers",
    })
      
    -- Astral Flow  
    sets.precast["Astral Flow"] = {

    }
      
    ----------
    -- Midcast
    ----------
      
    -- We handle the damage and etc. in Pet Midcast later
      
    -- Whatever you want to equip mid-cast as a catch all for all spells, and we'll overwrite later for individual spells
    sets.midcast.casting = {

    }
      
    -- Enhancing
    sets.midcast.enhancing = set_combine(sets.midcast.casting,{

    })
      
    -- Stoneskin
    sets.midcast.stoneskin = set_combine(sets.midcast.enhancing,{

    })
    -- Elemental Siphon, eg, Tatsumaki Thingies, Esper Stone, etc
    sets.midcast.siphon = set_combine(sets.avatar.skill,{
				main="Exemplar",
				sub="Vox Grip",
				ammo="Esper Stone +1",
				head="Convoker's Horn",
				body="Beckoner's Doublet",
				hands="Lamassu Mitts",
				legs="Ngen Seraweels",
				feet="Rubeus Boots",
				neck="Caller's Pendant",
				waist="Lucidity Sash",
				left_ear="Smn. Earring",
				right_ear="Andoaa Earring",
				left_ring="Evoker's Ring",
				right_ring="Fervor Ring",
				back={ name="Conveyance Cape", augments={'Summoning magic skill +3','Pet: Enmity+12','Blood Pact Dmg.+2','Blood Pact ab. del. II -2',}},
    })
        
    -- Cure Potency
    sets.midcast.cure = set_combine(sets.midcast.casting,{
				main="Serenity",
				head="Vanya hood",--10%
				body="Vanya robe",
				hands="Reveal. Mitts +1",--14%
				legs="Vanya slops",
				feet="Vanya clogs",--5%
				left_ear="Mendicant's earring",--5%
				right_ear="Roundel Earring",--5%
				right_ring="Lebeche Ring",--3%, -5 enmity
				left_ring="Ephedra Ring",
				neck="Nodens Gorget",--5%
				waist="Witful Belt",
    })
      
    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function, eg, do we have an avatar out?
  
end
