# About Fisher

Fisher is an automatic fishing bot for the fishing mini-game in Final Fantasy XI designed as an addon for [Windower 4](http://windower.net).

This project is a complete rewrite of my old addon of the same name.

## Known Issues

### Private Servers

Fisher **will _NOT_** work on private servers! This is due to the fact that private servers do not properly implement the fishing system on the server side. There is nothing that can be done to fisher to fix this. It's a problem with the server and needs to be fixed there.

### Display of Identified Fish

For the most part fisher will only display the exact fish or item you have hooked, but there are a few special cases:

* Fisher will always confuse `1 gil` and `100 gil`.
* Fisher will always confuse `mithran snare` and `tarutaru snare`.
* Fisher will always confuse `crayfish` and `ulbukan lobster` while in Ulbuka.
* Fisher will always confuse `king perch` and `malicious perch` while in Ulbuka.
* Under certain conditions, fisher may confuse `fish scale shield` and `rusty pick`.
* Under certain conditions, fisher may confuse `adoulinian kelp` and `hard-boiled egg`.
* Under certain conditions, fisher may confuse the number of `tiny goldfish` hooked.

### Equipment Restrictions

Automatic fishing will not start and fish/item identification will not work if any of the following items are equipped:

* A `maze monger fishing rod` while not inside Everbloom Hollow
* A `peguin ring`, even if it's not activated

# Installation

The latest stable version is always available here: https://svanheulen.gitlab.io/fisher/fisher.zip

Extract the archive to your `addons` folder, which by default you can find inside the same folder as the `Windower.exe`.

# Usage

## Load and Unload

```
//lua load fisher
//lua unload fisher
//lua reload fisher
```

## Specify Catch and Bait

```
//fisher add <item_name>
//fisher remove <item>
//fisher list
```

There is no need to use the same capitalization as the game, and you can also use both the short and long names.
When removing a fish, item or bait you can also use the item ID instead of the name.

There are also special names that can be used for adding and removing groups of items:

| Name | Description |
| --- | --- |
| `all` | All fishes, items and baits |
| `all fish` | All fishes |
| `all item` | All items |
| `all bait` | All baits |
| `monster` | All monsters |
| `unknown` | Anything that can't be identified by fisher |

Here are some examples:

```
//fisher add moat carp
//fisher add CrAyFiSh
//fisher add insect ball
//fisher add ball of insect paste
//fisher add all fish
//fisher remove Moat Carp
//fisher remove 4472
//fisher remove all
//fisher list
```

## Start and Stop Automatic Fishing

> You will need to add at least one fish/item and one bait before starting automatic fishing.

```
//fisher start [catch_limit]
//fisher stop
```

When starting automatic fishing, you can also specify the optional `catch_limit` to stop fishing after the specified number of catches.

Automatic fishing will also stop under the following conditions:
* Your receive a certain number of "You didn't catch anything." messages in a row.
* Your specified catch limit is reached
* You run out of bait
* You run out of inventory space
* You are targeted by an action
* Your player status changes to something other than fishing or idle
* You receive a chat message from a GM
* You perform any action other than `/fish`
* You manually perform any fishing action
* You change zones or log out
* You have a `maze monger fishing rod` equipped, and you're not inside Everbloom Hollow
* You have a `penguin ring` equipped, even if it's not activated
* Casting fails multiple times in a row

## Without Automatic Fishing

When fisher is loaded but the automatic fishing is not started it will still track fishing fatigue and display the name of the catches you hook.

## Viewing Tracked Fishing Fatigue

> Your tracked fishing fatigue may be inaccurate if you do any fishing without fisher loaded.

> Modifying your tracked fishing fatigue will not allow you to exceed the actual fishing fatigue limit.

```
//fisher fatigue [modifier]
```

When a `modifier` is not provided this command will display your current amount of tracked fishing fatigue.
If one is provided it will modify or overwrite the amount of tracked fishing fatigue.

Here are some examples:

```
//fisher fatigue
//fisher fatigue +10
//fisher fatigue -10
//fisher fatigue 123
```

## Advanced Settings

To modify these setting you will need to edit the settings file manually.
There will be an XML file named after your character, inside fisher's data folder.

> If fisher is loaded, you will need to unload it first before modifying the settings file.

Here are the available advanced settings:

| Name | Description | Default |
| --- | --- | ---: |
| `equip_delay` | The amount of time in seconds to wait after equipping bait. *If you set this value too low, you may have failed casts after bait is equipped.* | 2 |
| `move_delay` | The amount of time in seconds to wait after moving items between bags. | 0 |
| `cast_attempt_delay` | The amount of time in seconds to wait before retrying to cast your fishing rod. | 3 |
| `cast_attempt_max` | The maximum number of times to attempt casting your fishing rod if fishing does not start. | 3 |
| `release_delay` | The amount of time in seconds to wait before releasing a hooked item that's not in your catch list. | 3 |
| `catch_delay_min` | The minimum amount of time in seconds to wait before reeling in a hooked item. | 3 |
| `catch_delay_tweak` | The catch delay for fish near your level, which will be adjusted based on the difference between player skill and fish level. | 15 |
| `recast_delay` | The amount of time in seconds to wait after fishing ends to recast your fishing rod. | 3 |
| `no_hook_max` | The number of consecutive "You didn't catch anything" messages before automatic fishing is stopped. *A value of zero will disable this feature.* | 20 |
| `debug_messages` | Specifies if debug messages should be output to the chat log. | false |
| `alert_command` | A string that will be passed to `windower.send_command` when fisher stops automatically. *An empty string will disable this feature.* | *empty string* |

