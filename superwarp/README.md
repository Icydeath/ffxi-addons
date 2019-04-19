# superwarp

This is an addon for Windower4 for FFXI. It allows text commands to teleport using Homepoints, Waypoints, Survival Guides, Escha/Reis portals, and Unity NPC warps. There may be more coming. 

### Commands:

| Command | Action |
| --- | --- |
| //[sw] hp [warp] [all] zone_name [homepoint_number]  | Warp to a specified homepoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "entrance" (or simpler "e"), "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the homepoint_number is omitted, the first homepoint will be chosen (from the mapping). |
| //[sw] hp [all] set  | Set the nearest homepoint as your home point. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck). |
| //[sw] wp [warp] [all] zone_name [waypoint_number]  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "fs", "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the waypoint_number is omitted, the first waypoint will be chosen (from the mapping). |
| //[sw] sg [warp] [all] zone_name  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |
| //[sw] ew [warp] [all] portal_number  | Warp to a specified portal in Escha/Reis zones. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |
| //[sw] ew [all] enter  | Enters the Escha/Reis zones from the NPC in Qufim/Misareaux/Crags. "sw" is optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |
| //[sw] un [warp] [all] zone_name  | Warp to a specified unity zone or unity wanted NM. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |
| //[sw] ab [warp] [all] zone_name_or_conflux  | Warp to a specified abyssea entry zone or conflux number. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |
| //[sw] ab [all] enter  | Enter the abyssea zone when next to a cavernous maw. "sw" is optional, and does nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |

### Fuzzy Zone Names

Spaces and punctuation are ignored. So type "southernsand" all you want, buddy. You're going to Southern San d'oria. Also, if you ommit the homepoint/waypoint number, it'll just take the first one in the map. Favorites are available in the settings file (example follows):
```xml
<?xml version="1.1" ?>
<settings>
    <global>
        <debug>false</debug>
        <send_all_delay>0.4</send_all_delay>
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

Speaking of editing the map, you can add your own mappings in the map/homepoints.lua (if you dare.)
Note that there are some requirements! The second parameter "hompoint_number" must be 1-word. No spaces people. And please DON'T re-enable Al Zhabi it's a glitched homepoint. 

### In-Zone warping
When handling the menu through the game's vanilla systems, warping between two homepoints or waypoints in the same zone sends a packet that moves your character without zoning out. Escha/Reis do this too. This is usually accompanied by a fade-to-black animation. When this occurs through Superwarp, no animations are played. It's faster, but it can look jarring. You can disable this behavior for some zones (Escha/Reis cannot be, because of the nature of the zone) with a setting: `<enable_same_zone_teleport>false</enable_same_zone_teleport>`. It is true by default. 
Note: in-zone warping is planned for the Homepoints, but for now only works with Waypoints and Escha/Reis.