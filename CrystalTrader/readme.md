IMPORTANT
---------

This addon requires the addon "TradeNPC" to be installed and loaded before use.
TradeNPC can be found here: https://github.com/Ivaar/Windower-addons


What does this addon do?
------------------------

Crystal Trader searches your inventory for standard elemental crystals and clusters, then prepares a command to be used by TradeNPC.
This allows you to automatically trade stacks of similar clusters and crystals to the Ephemeral Moogles in the crafting guilds.

In v.1.1.0, the ability to trade seals and crests to Shami in Port Jeuno was added. The addon will automatically switch modes if Shami is your target.
The 5 valid seals are: Beastmen's Seal, Kindred's Seal, Kindred's Crest, High Kindred's Crest, Sacred Kindred's Crest

In v.1.1.2, the ability to trade Moat Carp to Joulet or Gallijaux was added

In v.1.1.3, the ability to trade Copper Vouchers was added


Example
-------

You have 3 stacks of Fire Crystals, 1 stack of Ice Crystals, and 2 Fire Clusters in your inventory that you would like to store.
Travel to and target one of the Ephemeral Moogles you would like to trade to.
In the chat window, enter '//ctr' without the quotes and press enter, or type 'ctr' in the console
The addon will cause TradeNPC to instantly trade all 3 stacks of Fire Crystals and the 2 Fire Clusters with one command.
After you wait for the moogle to do his thing, target the moogle again and re-enter the command.
The addon will then cause TradeNPC to instantly trade the stack of Ice Crystals.

The behavior is similiar when trading seals or crests to Shami in Port Jeuno

You will need to enter the command once for each crystal element or seal type you possess in your inventory.

If you wish to test this addon before using it, you may edit line 33 in the CrystalTrader.lua file.

Change
	exampleOnly = false
to
	exampleOnly = true
	
This will cause the addon to print the commands that will be issued to the windower console.
When you are ready to allow the addon to enter commands for you, change the 'true' back to 'false' and visit an Ephemeral Moogle or Shami.


Installation
------------

Browse to your Windower\addons folder and create a new folder inside called "CrystalTrader"
Place CrystalTrader.lua in this new folder.
Load the addon by accessing the console from within FFXI and typing 'lua l CrystalTrader'

If you want this addon to be loaded automatically every time you launch the game,
add 'lua l CrystalTrader' to the bottom of the file Windower\scripts\init.txt.

I would also recommend having the addon TradeNPC load automatically by adding
'lua l TradeNPC' to your init.txt.


Additional Information and Disclaimer
-------------------------------------

Crystal Trader only scans your inventory for elemental crystals, clusters, seals, and crests, then enters a command that will be used by the TradeNPC addon.
No other actions are carried out. This addon will not function if you do not have the TradeNPC addon loaded and working.

I am an amateur programmer and have never tried anything with LUA until now. Please feel free to modify/change/steal any of the code.
If you end up making this addon better, please let me know!



Version History
---------------
* Crystal Trader has been replaced with QuickTrade and will no longer be updated.

v1.1.3
2018.07.13
* Added Copper Voucher trading to Isakoth, Rolandienne, Fhelm Jobeizat, and Eternal Flame

v1.1.2
2018.07.12
* Added Moat Carp trading to Joulet or Gallijaux in Port San d'Oria

v1.1.1
2018.07.11
* Addon will skip the conversation with the target after trading
* Corrected logic to determine the number of crystal trades that will need to be made to empty the player inventory

v1.1.0
2018.07.10
* Versioning change
* Added seal and crest trading
	* If Shami in Port Jeuno is the target of the 'ctr' command, the addon will switch to Seal trading mode
* The user will be notified if there is no valid target and no trade attempt will be made if one is not present

v1.0.0.1
2018.07.08
* Changes to ensure the script obeys the 8-slot trade limit

v1.0.0.0
2018.07.05
* Initial Release