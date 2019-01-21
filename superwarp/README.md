# superwarp

This is an addon for Windower4 for FFXI. It allows text commands to teleport using Homepoints, Waypoints and Survival Guides.

### Commands:

| Command | Action |
| --- | --- |
| //[sw] hp [warp] [all] zone_name [homepoint_number]  | Warp to a specified homepoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "entrance" (or simpler "e"), "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the homepoint_number is omitted, the first homepoint will be chosen (from the mapping). |
| //[sw] wp [warp] [all] zone_name [waypoint_number]  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck). This, otherwise, works just like the homepoint addon, with additional shortcuts such as "fs", "auction" (or simpler "ah") or "mog" (or simpler "mh"). If the waypoint_number is omitted, the first waypoint will be chosen (from the mapping). |
| //[sw] sg [warp] [all] zone_name  | Warp to a specified waypoint. "sw" and "warp" are optional, and do nothing different. It's for those that require it because they've been trained to already. "all" will send an ipc message to all local instances of Windower with a delay (otherwise it could get stuck).  |

### Fuzzy Zone Names

Spaces and punctuation are ignored. So type "southernsand" all you want, buddy. You're going to Southern San d'oria. Also, if you ommit the homepoint/waypoint number, it'll just take the first one in the map. So feel free to rearrange those if you prefer one in particular.

Speaking of editing the map, you can add your own mappings in the map/homepoints.lua (if you dare.)
Note that there are some requirements! The second parameter "hompoint_number" must be 1-word. No spaces people. And please DON'T re-enable Al Zhabi it's a glitched homepoint. 

