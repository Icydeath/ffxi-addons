Unfortunately I no longer play and haven't for years so am unable to fix issues or update. I will leave the code here public incase anyone wishes to take over 

# Lazy

Simple helper for farming XP/CP/Trash items. So far includes:

  - Always Turn to face Target, even if Trust Tank pulls away from you
  - Keep within 3Yalms of Target at all times
  - Weaponskill when TP available
  - Ability to cast a spell whenever Recast/MP allows
  - _SIMPLE_ auto target system

### Installation

* Inside your Windower\Addons folder create a new folder called Lazy
* Copy these files into the folder created above.

### Commands
* //lazy start
* //lazy stop
* //lazy reload

#### //lazy start
Starts the actual helper

#### //lazy stop
Stops the helper

#### //lazy reload
Reloads the options from the settings.xml

#### //lazy target "Some Monster"
Sets/Changes the current auto target monster, Single mob only for now

### settings.xml
```xml
<spell></spell>
<spell_active></spell_active>
<weaponskill></weaponskill>
<weaponskill_active></weaponskill_active>
<autotarget>false</autotarget>
<target>Monster Name<target>
```
* spell - Spell to cast, will cast whenever MP and recast time allows
* spell_active - true/false enables/disables enables casting of the spell
* weaponskill - weaponskill to use when over 1000TP
* weaponskill_active - true/false enables/disables use of weaponskills
* autotarget - true/false enables/disables automatic hunting of mobs in range
* target - name of monster to hunt
