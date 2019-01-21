# SendTarget
FFXI Windower addon that allows multiboxers to more easily send commands. You can capture targets and subtargets. Basic usage looks like `//sta CHAR_NAME /ma "Cure III" <stpc>`.

Note that this addon is compatible with the Shortcuts addon. You could make an alias `alias all sta @all` and then type `//all c3 st`. This will give you subtarget selection, and then upon selecting
a target all of your characters will cast Cure III on the chosen target. Similarly, you could do `//all thunder4` and all of your characters will cast Thunder IV on your current target, regardless
of their target. No `/assist` necessary!

For a more specific example, let's say you have an alt named Maruru and you wanted to make a macro to have them heal based on your <st> choice. `/con sta Maruru /ma "Cure III" <stpc>`

If you need to put additional commands after an <st> line in a macro, you can use the `!capture` command like so (this example uses the Send addon):

    /con sta !capture Maruru
    /ma "Cure III" <stpc>
    /con send Maruru equip main "Light Staff"
    /wait 4
    /con send Maruru equip main "Earth Staff"

## Installation
After downloading, extract to your Windower addons folder. Make sure the folder is called SendTarget, rather than SendTarget-master or SendTarget-v1.whatever. Your file structure should look like this:

    addons/SendTarget/SendTarget.lua

Once the addon is in your Windower addons folder, it won't show up in the Windower launcher. You need to add a line to your scripts/init.txt:

    lua load SendTarget

To use with Shortcuts, make sure that Shortcuts is loaded first! Also, note that this addon has some compatibility issues with GearSwap. You'll want SendTarget loaded before GearSwap (for example,
put `lua load GearSwap` after `lua load SendTarget`), but you'll also want to use the `//sta !packets` command when GearSwap loads a profile. Swapping between jobs that have GearSwap profiles and
jobs that don't will be a pain, but it can be automated by putting `windower.send_command('sta !packets')` in each GearSwap profile's `equip_sets()` and `file_unload()` functions.

## Commands
You can use `//sendtarget` or `//sta`.

    //sta <character_name>|@all|@others
    //sta !capture <character_name>|@all|@others
    //sta !mirror
    //sta !packets