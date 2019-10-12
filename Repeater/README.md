Simple windower command repeating tool for FFXI.

Commands

//repeater                Gives current settings for repeater.

//repeater command        Sets the line following as a windower command to be repeated.

//repeater delay          Sets the delay between repeat in seconds.

//repeater on/start/go    Starts repeating the command you set.

//repeater stop/quit/off  Stops repeating the command.

//repeater repeat         Starts or stops the command repeating.

//repeater count          Determines how many times to repeat the action, default is forever.

Example uses:

Lastsynth: Can be used to repeat your last synth multiple times.
//repeater command input /lastsynth

Shouts: Can be used to shout something over and over again.
//repeater command input /shout Selling Alexandrite <pos>!

Spells: Can be used to cast a spell over and over.
//repeater command input /ma "Fire" <t>

Auctioneer: Can be used to repeatedly buy something while afk, specifically:
//repeater command buy Alexandrite 1 700000

As a timer: Can use it to remind yourself of a pop time.
//repeater delay 300
//repeater command input /echo Guy with a 5 minute repop is popping now!
