Information:
* Author: ybot
* Thanks to: Selindrile
* banker helps track currencies from the two in-game menus on screen. By default it tracks Coalition Imprimaturs, Bayld, Escha Silt and Escha Beads. Also includes an alert function (Imprims only for now)

Abbreviation: //bank, //banker

Commands:
* //banker status - Show currently tracked items.
* //banker refresh - Manually refreshes onscreen display. Sends a packet to interact with the currency menus.
* //banker mode - Changes the update mode. Defaults to 'zone'. Change to 'manual' if you don't want it to use packet injection. No argument will tell you the current mode
* //banker add/a/+ "Currency Name" - adds a new currency to the balance sheet. Must match the spelling and formatting in the menu. ie "Fire Crystals Stored"
* //banker remove/rem/delete/del/d/- - Removes an item from the list.
* //banker alert true/false - Set alert mode. Defaults to false. Only works on Coalition Imprimaturs
