# superwarp

This is an addon for Windower4 for FFXI. It allows text commands to teleport using Homepoints, Waypoints, Survival Guides, Escha/Reis portals, and Unity NPC warps. There may be more coming. 

### Commands:

#### Homepoint Commands
| Command | Action |
| --- | --- |
| //[sw] hp [warp] [all/party] zone_name [homepoint_number]  | Warp to a specified homepoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "entrance" (or simpler "e"), "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the homepoint_number is omitted, the first homepoint will be chosen (from the mapping). |
| //[sw] hp [all/party] set  | Set the nearest homepoint as your home point. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck). |
| //[sw] hp [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |


#### Waypoint Commands
| Command | Action |
| --- | --- |
| //[sw] wp [warp] [all/party] zone_name [waypoint_number]  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "fs", "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the waypoint_number is omitted, the first waypoint will be chosen (from the mapping). |
| //[sw] pwp [warp] [all/party] zone_name  | Warp to a specified proto-waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck). |
| //[sw] wp [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |
| //[sw] pwp [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |


#### Survival Guide Commands
| Command | Action |
| --- | --- |
| //[sw] sg [warp] [all/party] zone_name  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] sg [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |


#### Escha Commands
| Command | Action |
| --- | --- |
| //[sw] ew [warp] [all/party] portal_number  | Warp to a specified portal in Escha/Reis zones. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ew [all/party] enter  | Enters the Escha/Reis zones from the NPC in Qufim/Misareaux/Crags. "sw" is optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ew [all/party] domain  | Aquires Elvorseal if it is available and your character does not already have it, then teleports to the area where the Domain Invasion dragon will apper.  |
| //[sw] ew [all/party] domain return  | Returns the Elvorseal status effect if your character has it.  |
| //[sw] ew [all/party] exit  | Leaves the Escha/Reis zones from the undulating confluenc or dimensional portal in within the zone. "sw" is optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ew [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. Note: this can only be done inside a zone, and only for the zone you are currently in. |


#### Unity Commands
| Command | Action |
| --- | --- |
| //[sw] un [warp] [all/party] zone_name  | Warp to a specified zone or the correct zone for a specified Unity NM. If an NM is specified, Superwarp will display the coordinates for the spawn NPCs. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] un [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |


#### Abyssea Commands
| Command | Action |
| --- | --- |
| //[sw] ab [warp] [all/party] zone_name_or_conflux  | Warp to a specified abyssea entry zone or conflux number. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ab [all/party] enter  | Enter the abyssea zone when next to a cavernous maw. "sw" is optional, and does nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ab [all/party] exit  | Leave the abyssea zone when next to a cavernous maw. "sw" is optional, and does nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] ab [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. Note: this can only be done inside a zone, and only for the zone you are currently in. |

#### Runic Portal Commands
| Command | Action |
| --- | --- |
| //[sw] po [warp] [all/party] staging_point  | Warp to a specified assault staging point. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] po [all/party] assault  | Be taken to your current assault mission staging point. "sw" is optional, and does nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] po [all/party] return  | Leave the assault staging area and return to Whitegate. "sw" is optional, and does nothing different. It's for those that require it because they've been trained to already. "all" and "party" will send an ipc message to all local instances (or specific local party members) with a delay (otherwise it will get stuck).  |
| //[sw] po [all/party] missing [max]  | List out which destinations are still locked. The optional max parameter is a maximum number of lines to display. Default: all. |

#### Misc. Commands
| Command | Action |
| --- | --- |
| //sw debug  | Toggles debug mode which displays debug messages in the log. If debug mode was off, will display the debug logs of the last warp command as well.   |
| //sw cancel [all/party]  | Cancels the current in-progress warp.   |
| //sw reset [all/party]  | Resets client menu lock. This should be exceedingly rare, but it's here in case it's needed.   |

### Fuzzy Zone Names

Spaces and punctuation are ignored. So type "southernsand" all you want, buddy. You're going to Southern San d'oria. Also, if you ommit the homepoint/waypoint number, it'll just take the first one in the map. Favorites are available in the settings file (example follows):
```xml
<?xml version="1.1" ?>
<settings>
    <global>
        <favorites>
            <homepoints>
                <Norg>Auction House</Norg>
                <PortBastok>Mog House</PortBastok>
                <PortJeuno>2</PortJeuno>
                <RuludeGardens>Auction House</RuludeGardens>
            </homepoints>
            <waypoints>
                <ForetdeHennetiel>4</ForetdeHennetiel>
            </waypoints>
        </favorites>
    </global>
</settings>
```

Further customization can be done with the Shortcuts section in the settings file. You can specify a zone only, enabling you to choose the subzone on the fly, or include a subzone and make it a full shortcut. Shortcut names must match exactly (case-insensitive) and must not have spaces.
```xml
<?xml version="1.1" ?>
<settings>
    <global>
        <shortcuts>
            <homepoints>
                <eado>
                    <sub_zone>Mog House</sub_zone>
                    <zone>Eastern Adoulin</zone>
                </eado>
                <wado>
                    <zone>Western Adoulin</zone>
                </wado>
            </homepoints>
            <waypoints>
                <foretjp>
                    <sub_zone>4</sub_zone>
                    <zone>Foret de Hennetiel</zone>
                </foretjp>
            </waypoints>
        </shortcuts>
    </global>
</settings>
```

### In-Zone warping
When handling the menu through the game's vanilla systems, warping between two homepoints or waypoints in the same zone sends a packet that moves your character without zoning out. Escha/Reis do this too. This is usually accompanied by a fade-to-black animation. When this occurs through Superwarp, no animations are played. It's faster, but it can look jarring. You can disable this behavior for some zones (Escha/Reis cannot be, because of the nature of the zone) with a setting: `<enable_same_zone_teleport>false</enable_same_zone_teleport>`. It is true by default. 

### Locked homepoints and waypoints
Superwarp is no longer able to warp to locations you have not unlocked yet. Square has started checking serverside. 

### Multi-boxing features
Every command can be sent to all characters by prepending the "all" or "party" keyword before the zone name and sub-zone destination or the sub-command. This will send the same command to all characters on the same machine or all characters on the same machine in the same party and delay their responses to prevent Square-Enix's servers from rejecting duplicate packets.

The default behavior of Superwarp is to cancel the in-game follow and autorun during a warp/sub-command event. But to disable this (for some reason), there is an option in the settings.xml file.

An option is available to apply a windower command before a warp/sub-command begins as well as on arrival. The use case is really infinite, but the goal was to enable the user to disable follow addons during a warp or sub-command event. Bonus feature! Prank your friends by setting the command before starting a warp to `sw cancel`. (Don't actually, I'm the one that will get a message about it not working)

### Special thanks
Thanks to Ivaar and Thorny for their work on figuring out the waypoint currency data packs. Without them the waypoint system wouldn't function properly at all.

Thanks to Kenshi for helping collect data about same-zone warp coordinates accurately.

Thanks to Ivaar for also helping with the elvorseal state and receive packets, data for unlocked homepoints, waypoints and survival guides, and for helping with the client menu-lock reset functions.

Thanks to Lili for researching a better fuzzy matching logic.

### Updates
#### v0.96
- **Feature**: Homepoints now uses same-zone teleporting feature.
- **Feature**: Homepoints now check enabled expansion content before warping. Before, if you warped to a zone that came in an expansion that is not enabled or installed, the character would get stuck until the expansion was enabled and installed.
- **Feature**: All warp systems check the currency required to teleport before teleporting. 
- **Feature**: An option has been added to check for unlock status of homepoints, waypoints, and survival guides. To enable unlock checks, set the following setting: `<enable_locked_warps>false</enable_locked_warps>`. This option is TRUE by default, meaning that Superwarp will let you warp there even if you don't have it unlocked.
- **Feature**: When in escha or Reisenjima, use the sub-command "domain" to aquire elvorseal if the status is not already applied and teleport to the target Domain Invasion arena. If the option to acquire elvorseal is not available, the command will warn in the log and cancel. To return the status before the fight is over, use the sub-command "domain return"
- **Resolved**: Escha and Waypoint systems now correctly consume currency.
- **Feature**: Waypoints warp system can now teleport to rune locations.
- **Feature**: Proto-waypoints are now supported under the system "pwp".
- **Feature**: Survival Guides can now use tabs (Valor Points) to teleport instead of gil. Change the setting `<use_tabs_at_survival_guides>true</use_tabs_at_survival_guides>` to enable. If the character is out of tabs, it will switch back to gil and warn the user. This also respects the Thrifty Transit super kupower. 
- **Feature**: All warp systems check if you are already at the desired destination before warping.
- **Feature**: An option to simulate menu choice delay by a fixed number of seconds. Change the setting `<simulated_response_time>0</simulated_response_time>` to a number of seconds to wait between ***EACH*** menu packet sent. Teleports send between 2 and 4 packets that can be affected by this number, so be prepared to wait. This option is specifically designed to make packets sent look more like vanilla behavior.
- **Resolved**: Teleport packets now respect the game's normal order for sending to the client. The next menu option packets will wait for the response packets before continuing. This makes the teleporting take a little bit longer, but it looks much more like vanilla game behavior. 
- **Feature**: Added custom shortcuts. Configured in the settings file, an exact phrase can be specified (e.g. "wado" for "Western Adoulin") that resolves to a zone name or a zone + subzone combination.
- **Feature**: When Superwarp detects that the event has been skipped while mid-teleport, it can retry immediately. Additionally with a new setting, it will enable "fast" mode for the next attempt. Fast mode does not wait for the response packets and removes any simulated menu choice delays. The hope is to fire off the teleport packets to get you out of there ASAP. To enable this option change the setting `<enable_fast_retry_on_interrupt>true</enable_fast_retry_on_interrupt>`.
- **Improvement**: The retry system has been improved. Superwarp has more control over when a retry is attempted. This should mean less issues when the client lags. Retries occur when the warp NPC cannot be found, is out of range, or when the event is skipped.
- **Resolved**: Same-zone teleports now correctly orient your character on arrival. 
- **Resolved**: All same-zone teleports now have fully accurate arrival coordinates. The packet sent matches vanilla exactly.
- **Improvement**: The reset functionality when an error occurs with Superwarp has been improved. This should get your character out of "stuck in menu" issue more often. Ideally, you should never have to use this feature.
- **Imprevement**: When submitting multiple actions accidentally, superwarp will prevent the second attempt. To cancel an in-progress warp type `//sw cancel` or `//sw cancel all`. 
- **Improvement**: Client menu locks should be far less frequent (they were quite infrequent before, but it should be less frequent still). If the warp somehow manages to stall, don't talk to the NPC manually. Instead do `//sw reset` to reset the menu lock before reattempting.
- **Improvement**: Menu ID and NPC IDs are validated when a new menu packet arrives. Odd out-of order things happen sometimes, this aims to prevent issues. 

#### v0.96.1
- **Feature**: Escha and Abyssea systems now have an Exit subcommand.
- **Feature**: Added ability to disable autorun and /follow before starting a warp or using a sub command
- **Feature**: Added ability to run a windower command before starting a warp or using a sub command as well as at arrival time. A delay option is also in place for timing the arrival command.
- **Resolved**: Outdoor Adoulin areas send the correct final menu packet when warping between waypoints in the same zone. No change in anything noticable, but it's nice to be exactly correct.

#### v0.96.2
- **Resolved**: Exiting Abyssea should work again.
- **Feature**: Added option to target warp NPC before initiating. 
- **Feature**: Added option to simulate client lock during a warp. This will prevent your character from moving until the warp is complete. //sw reset will also clear this state.
- **Resolved**: Somehow managing to unload superwarp during a warp/subcommand will now reset the state first (to prevent soft and client locks).
- **Resolved**: Sub commands will now retry if the npc hasn't loaded yet or isn't near, like warp systems.
- **Resolved**: Survival guides under thrifty transit now work with the menu id validation

#### v0.96.3
- **Resolved**: Removed option to warp to locations you have not unlocked yet as the July update broke this functionality for good. 

#### v0.97
- **Feature**: Added runic portals ("po")
- **Improvement**: New option to send to all characters in an order mode (me-first, me-last, or just alphabetical)
- **Feature**: New option to send to just party members. Other key words that work: party, p, @party. Uses above order mode too.
- **Improvement**: Separated sendall logic into a copyable library. Enjoy!
- **Improvement**: Added fuzzy logic from Lili. Thanks!

#### v0.97.1
- **Feature**: Added command to detect destinations that have yet to be unlocked.

#### v0.97.2
- **Feature**: Added setting to direct log messages to console instead, or turn off entirely.