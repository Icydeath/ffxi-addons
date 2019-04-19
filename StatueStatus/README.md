This addon displays a TXT box window of statues as you target them to help show color.  This will help identify, especially as mobs are facing the other direction, what color their eyes are.

Working as well on an Aurix(Statue) tracker with it.  False positives are occurring I haven't had enough time in Dynamis to debug. 

The way this works:
Every statue that comes into your memory will be registered in a table.  
* All normal statues rotate between Black -> Blue -> Black -> Green (loop). 
* Red/Boss statues rotate between Black -> Red
* Aurix statue simply doesn't rotate and stays Black.
I haven't found a way (I don't think it exists, but throwing out there as a possibility) to uniquely identify Aurix other than the absense of it being red/blue/green.  So if a mob comes into range(50ish yalms) and it is in its transition to black period , the plugin will incorrectly identify it as Aurix - however as it sees an update to red/blue/green it will track it correctly.   This transition is generally going to occur before you 'notice' it being that far away and fighting other mobs etc.  However, depending on your speed / etc, you may get some quick false positives at the furthest distances out. 

To help mitigate the distance/transition period etc,  I make sure that I've seen a mob for at least 15 seconds and is within 30 yalms before a new TXT box will pop up suggesting Aurix has been found, and give a directional / yalm to his statue.


A couple notes:
* Please note this is a WIP and hard to debug due to 3 day dev cycles where you get an hour-90 minutes in a zone that I'd rather "play" than debug.
* If Aurix runs away, it's unknown if a mob you've already tracked with a color change simply stops rotating, or if a new index pops up etc.  Because of this, after Aurix has run away, it may be wise to reload the addon (it'd be easy to program this in, just haven't done so). 
* Trying to think of ways to help mitigate 'false positives'
* probably more I'm forgetting.
