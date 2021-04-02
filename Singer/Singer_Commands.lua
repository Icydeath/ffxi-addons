 -- Singer Addon Commands

//sing [on|off]                     -  Turn actions on/off.
//sing actions [on|off]             -  Same as above.
//sing active [on|off]              -  Display active settings in text box
//sing timers [on|off]              -  Dislay custom song timers.

//sing delay <n>   (I left it fefault)   -  [n] second delay between song casting.


//sing marcato <song>               -  Set song to use following marcato.
//sing marcato honor march


//sing <order> <song> [name]        -  Set songs to be used in specified order.

//sing 1 honor march
//sing 2 Victory march
//sing 3 Valor minuet IV
//sing 4 Valor minuet V

//sing <order> <clear> [name]       -  Remove song from specified slot.

//sing dummy 1 armys paeon
//sing dummy 2 armys paeon II
//sing dummy 3 armys paeon III
//sing dummy 4 armys paeon IV

//sing nightingale [on|off]         -  Toggle nightingale usage, can be shortened to n.
//sing troubadour [on|off]          -  Toggle troubadour usage, can be shortened to t.

//sing pianissimo [on|off]          -  Toggle pianissimo usage, can be shortened to p.
//sing ballad 1 Friend

//sing aoe [slot|name] [on|off]     -  Set party slots to monitor for aoe range.
//sing aoe p3 Darkvlade on/off (whoever the toon is that you want to be in range for songs to go off)

//sing haste <name> [on|off]        -  Add or remove names of players for Haste cycle.
//sing haste darkvlade on/off 

//sing refresh <name> [on|off]
//sing refresh darkvlade on/off 

//sing timers [on|off]              -  Dislay custom song timers.


you can't use //sing 2 march, if you specify a position you need to spell the whole name out. i.e. //sing 2 honor march
if you want multiple marches and don't care position, do //sing march 2

//sing save [list] [name]           -  Save settings, if <list> is provided will save current songs to playlist.

//sing reset     - Reset song timers.

//sing playlist save <list> [name]  -  Saves current songs to playlist.
//sing playlist <list|clear> [name] -  Loads songs from a previously set playlist. (clear is an empty playlist to remove all songs)
//sing clear <name|aoe>				-  Clear song list for name

