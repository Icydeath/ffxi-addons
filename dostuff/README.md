**Author:** Mujihina
**Version:** v2019.02.02

This addon will help you do repetitive command line tasks.

# Command #

Syntax can be obtained by running the command without arguments, or with the subcommand 'help'

Current syntax is:
- 'dos list' : Review current settings
- 'dos start': Start doing stuff
- 'dos stop' : Stop doing stuff
- 'dos cmd'  : Specify command to repeat. Note: If needed, use single quotes instead of double quotes.
- 'dos count': Specify count (0 will loop forever, which is default)
- 'dos delay': Specify delay (default is 5 secs). This can be adjusted while dostuff is running if needed.


##Examples:##
- Say you want to repeat the lastsynth 24 times:

```
dos cmd /lastsynth
dos delay 24
dos start
```

- Say you need to go AFK for a few mins while nuking a WKR
```
dos cmd /ma 'Fire' <t>
dos delay 5
dos count 0
dos start
```

- Say you cast a spell on a trust/alt (party member 2) all night.
```
dos cmd /ma 'Cure II' <p2>
dos delay 6
dos count 0
dos start
```


##TODO##


##Changelog##
