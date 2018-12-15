# HealBot

## Update: HealBot now depends on [libs/lor](https://github.com/lorand-ffxi/lor_libs)

## NEW: IPC has been added! (see below)

### Summary

By default, HealBot will monitor the party that it is in.  Commands to monitor
or ignore additional players can be found below.

Buffs gained via job abilities are now supported, but have not yet been tested
extensively.  Composure has been confirmed to work.  With the addition of job
ability support comes support for prioritization (since, for example, Composure
should be used before other buffs are applied).

Detection of whether the local healer is able to act has been improved for when
debuffs such as sleep or petrify are active, so that now it should not try to
spam spells while unable to act.  This is apparent by the text box in the top-
left corner of the screen displaying the message 'Player is disabled'.

Bard songs are officially unsupported at this time.  YMMV - it cannot handle the
fact that there is no notification given when one song overwrites another, or
maintaining multiple buffs that have the same name.  That being said, if you
only want to maintain 2-3 songs without using a dummy song, it may work.  I have
an idea about how to support BRD songs, so that should be coming soon.

Also coming soon is the ability to cast offensive spells on an assist target's
target.  

--------------------------------------------------------------------------------

### IPC (Inter-Process Communication)

HealBot now supports IPC between multiple instances of Windower running on the
same computer when both characters have HealBot loaded!  This means that HealBot
will now be even better at detecting the buffs/debuffs that are active for
characters on the same computer!

Only the healer's HealBot needs to be on - the non-healer just needs to have
HealBot loaded to be able to tell the healer's instance about its active buffs
and debuffs.


### Settings

If you have the shortcuts addon installed, your aliases.xml file from that addon
will be loaded, and those aliases will be available for use when specifying
buffs.

You can edit/add/remove buff lists that can be invoked with the
`//hb bufflist listName targetName` command in data/buffLists.xml.  The order of
buffs within the list does not affect the order in which they will be cast.
Follow the syntax of existing sets when adding/editing your own.

You can modify the priority with which other players will be attended to by
editing data/priorities.xml.  Note that detection of players' jobs is not
perfect at the moment, so it is better to specify individual players' priorities
by name.  Lower numbers represent higher priority.  Follow the syntax of
existing sets when adding/editing your own.

Monster abilities that do not display what debuffs they cause are specified in
mabil_debuffs.xml.  This list is woefully incomplete, but I plan on vastly
expanding it in the near future.  If you decide to add any, I would greatly
appreciate it if you would share what you have added.  If you add something, and
it isn't detected, please notify me, and I will attempt to make sure that it can
be detected in the future.

Place the healBot folder in .../Windower/addons/

* To load healBot: `//lua load healbot`
* To unload healBot: `//hb unload`
* To reload healBot: `//hb reload`

### Command List
**Note:** Shortcut commands below are highlighted in **bold** (e.g., **f** is a shortcut for **f**ollow)

| Command | Action |
| --- | --- |
| //hb on | Activate |
| //hb off | Deactivate (note: follow will remain active) |
| //hb refresh | Reload settings xmls in the data folder |
| //hb status | Displays whether or not healBot is active in the chat log |
| //hb mincure # | Set the minimum cure tier to # (default is 3) |
| //hb reset | Reset buff & debuff monitors |
| //hb reset buffs | Reset buff monitors |
| //hb reset debuffs | Reset debuff monitors |
| //hb buff charName spellName | Maintain the buff spellName on player charName |
| //hb buff <t> spellName | Maintain the buff spellName on current target |
| //hb cancelbuff charName spellName | Stop maintaining the buff spellName on player charName |
| //hb cancelbuff <t> spellName | Stop maintaining the buff spellName on current target |
| //hb bufflist listName charName | Maintain the buffs in the given list of buffs on player charName |
| //hb bufflist listName <t> | Maintain the buffs in the given list of buffs on current target |
| //hb **f**ollow charName | Follow player charName |
| //hb **f**ollow <t> | Follow current target |
| //hb **f**ollow off | Stop following |
| //hb **f**ollow dist # | Set the follow distance to # |
| //hb ignore charName | Ignore player charName so they won't be healed |
| //hb unignore charName | Stop ignoring player charName (note: will not watch a player that would not otherwise be watched) |
| //hb watch charName | Watch player charName so they will be healed |
| //hb unwatch charName | Stop watching player charName (note: will not ignore a player that would be otherwise watched) |
| //hb ignoretrusts on | Ignore Trust NPCs (default) |
| //hb ignoretrusts off | Heal Trust NPCs |

| Debugging commands | Action |
| --- | --- |
| //hb moveinfo on | Will display current (x,y,z) position and the amount of time spent at that location in the upper left corner. |
| //hb moveinfo off | Hides the moveInfo display |
| //hb packetinfo on | Adds to the chat log packet info about monitored players |
| //hb packetinfo off | Prevents packet info from being added to the chat log |
