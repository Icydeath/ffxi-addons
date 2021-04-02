**Author:** Mujihina
**Version:** v 1.1

# Widescantool #

This addon will offer you filters and alerts for widescan data, and proximity notification alerts.


- Filters: Filters can be useful if widescantool is too cluttered with monsters you do not care about. Fewer entries in the widescan list, and you are less likely to miss something you do care about. Filters can be configured at a global level and per area. 
	By default, it will also filter common mob pets from widescan.

- Alerts: Alerts can be useful to make sure you really don't miss something you do care about in the widescan list. They can also be configured at a global level, and per area.
	When something shows up in widescan that matches your alert pattern, a message will be sent to your chat log to help you in case you missed what you were looking for.

- Proximity alerts: when your character is close enough to something that matches your alert patterns, you will also see a visual alert on your main screen. They are not limited to entries you can see in widescan, but anything close enough to you that is 'targetable' and 'unengaged', thus you could have entries like 'treasure coffer' or 'logging point' as an alert, in order to help you prevent carpal tunnel syndrome from repeated use of your tab key while looking for those. 


## Configuration ##

Filters/Alerts are saved locally to a config file. 


## Syntax ##

Syntax can be obtained by running the command without arguments, or with the subcommand 'help'

Current syntax is:

- wst lg: List Global settings
- wst la: List settings for current Area
- wst lc: List Combined settings applied to current area
- wst laaf: List All Area Filters
- wst laaa: List All Area Alerts
- wst agf <name or pattern>: Add Global Filter
- wst rgf <name or pattern>: Remove Global Filter
- wst aga <name or pattern>: Add Global Alert
- wst rga <name or pattern>: Remove Global Alert
- wst aaf <name or pattern>: Add Area Filter
- wst raf <name or pattern>: Remove Area Filter
- wst aaa <name or pattern>: Add Area Alert
- wst raa <name or pattern>: Remove Area Alert
- wst defaults: Reset to default settings
- wst toggle: Enable/Disable all filters/alerts temporarily
- wst pet: Enable/Disable filtering of common mob pets
- wst quiet: Enable quiet mode (no <call> alerts). Default.
- wst noquiet: Use <call> alerts.

## Patterns ##

Patterns will be converted to lowercase, so when providing a name or pattern to the addon you do not need to worry about case.

Names and patterns can contain spaces, and some special characters like "'"  and "-".
For instance, it is fine to use these as patterns:
goblin tinkerer
gigas's leech
weird-mithra namemaru

However, it is not advisable to use characters not found in mob names. 

## Configurables ##
global.max_memory_alerts = Max number of alerts to display

global.skip_memory_scans = Increase this number to scan memory less often.


### Examples ###

Adding the pattern goblin as a global filter:

```
wst agf goblin
```

Adding the pattern air elemental as a global alert:

```
wst aga air elemental
```

Adding the pattern emperor to the alerts for your current area:
```
wst aaa emperor
```

Adding the known id of a placeholder as an alert (rather than the name of mob):
```
wst aaa 0x0EE
```

Removing the previously added pattern damselfly from the filters for your current area:
```
wst raf damselfly
```

Listing the current global filters/alerts:
```
wst lg
```

##Notes##
Note that if your patterns are too short, they might unintentionally trigger alerts or filters you do not want.

For example, say you were trying to target all orcs, by using the pattern 'orc', it would also match anything with the name 'sorcerer' as 'orc' is in that string.


##TODO##


##Changelog##

### v1.1
   quiet/noquiet mode
   Accept mob indexes as names.
### v1.04
   Clean up and fix to changes to standard libs, added index and invalid toggles to show index and/or invalid targets

### v1.03
   Added max number of alerts, and performance configurable sttings for slower machines to tweak.

### v1.02
   Clean up and fix to changes to standard libs

### v1.01
   Made changes to fix what broke with recent changes to config.lua
### v1.0 ###
* First release.
