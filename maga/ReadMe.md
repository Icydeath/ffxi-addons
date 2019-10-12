**Author:**  Cairthenn - modded by Icy<br>
**Version:**  1.0.0.5<br>
**Date:** 10/6/2019<br>

#### UPDATED BY ICY ####
* Added .wav alarms for when you run out of stones and when your required augments are met and its waiting for you to respond.

# MAGA (Make Augments Great Again) #

* After trading a piece of armor to Oseem, the addon will automatically expend stones (as specified) to augment your armor until augments that equal or are greater than your specified augments appear.
* If you have created more than one augment set to compare against, it will stop if it matches the minimum specified augments in ANY set.
* This uses a custom version of extdata for augment handling and user readability. Any augment in the extdata.lua file in this addon folder may be specified.
* Please note that there is NO menu for Oseem while using this addon, and Oseem will retain your gear until (1) you exit the interaction using the 'cancel' or 'accept' sub-command, (2) you run out of stones, or (3) you unload the addon.
* If you use this addon responsibly, your results will be positive. I am not responsible for any lost augments or lost armor for any uninformed or irresponsible use.
* This addon injects packets. Do not use it if you aren't comfortable with that.

----

#### Settings ####

* MAGA uses 'settings.xml' in its data folder for all settings.
* If you choose to edit this manually, this file uses **extdata.lua** in the main addon folder for augment naming schemes.


#### Commands: ####
1. help : Shows a menu of commands in game
2. style [magic|melee|ranged|familiar|healing] : Sets the type of augments to select for the traded armor. If the armor does not support that type of augment, a notice will be displayed in the chat log and your armor will be returned to you.
3. pellucid : Toggles whether pellucid stones are used for augmenting. Takes optional parameter (t)rue/(f)alse/(y)es/(n)o
4. fern : Toggles whether fern stones are used for augmenting. Takes optional parameter (t)rue/(f)alse/(y)es/(n)o
5. taupe : Toggles whether taupe stones are used for augmenting. Takes optional parameter (t)rue/(f)alse/(y)es/(n)o
6. start &lt;style&gt; : After trading an item, starts the augmentation process. Style parameter is optional and will override the current style setting.
7. stop : Stops the augmentation process. NOTE: This does not return your item to you. You are still required to use an interaction-exiting command.
8. accept : Accepts the most recent augment that was applied to your gear.
9. cancel : Declines the selected augment and returns the gear to your inventory.
10. continue : Resumes the augmentation process after it has stopped for you to decide on an augment.
11. add &lt;augment name&gt; &lt;minimum value&gt; &lt;set number&gt; : Adds 'augment name' to the required augments list with 'minimum value' to the specified augment set (default: 1)
12. remove &lt;augment name&gt; : Removes 'augment name' from the required augments list in the specified augment set (default: 1)
13. search  &lt;search str&gt; : Returns a list of valid augments that contain 'search str' and displays them in the chat log.
14. save  &lt;profile name&gt; : Saves the current augment specification to 'profile name'
15. load &lt;profile name&gt; : Loads 'profile name' to the current augment specification
16. newset : Creates an additional augment set to compare against
17. delset &lt;set number&gt; : Deletes the specified augment set #
18. delay &lt;#&gt; : Sets the delay between augments to #. There is no minimum, but 5 is the maximum.

--
