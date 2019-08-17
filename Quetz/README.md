This is a mostly automated way to fight Quetz and will cycle through the fight automatically.

Works without EF now, but you need to have SetTarget addon, part of windower addons.

This works with multibox as long as you have healbot and other addons to toggle COR/BRD/GEO abilities.

You MUST edit the settings.xml file in data folder, but if you don't need additional truts or alts just keep it "None"

Required addons:

1.  Superwarp
2.  SetTarget
3.  Anchor
4.  Healbot [Really should use it to buff abilities]
5.  Autows - To WS more often than using healbot

Required for multiboxing:
1.  Multictrl

Recommended:

1.  Singer
2.  Roller
3.  Autogeo


How to use:

Configure:
Edit settings.xml in data folder - YOU MUST DO THIS.

***Add trusts you need, if you don't need trusts on some lines, keep it "None", DO NOT BLANK IT OUT.***

***Edit your lockstyle (this prevents auto run at edge cases after Quetz dies)***

***Edit your teleport ring to dimensional portal.***

***Make sure you've downloaded all dependency addons!***

Single:
1.  Load Quetz
2.  Enter to Reisenjima then get Elvorseal and enter the arena where you fight Quetz.  
3.  Summon your trusts
4.  Start quetz by //Quetz start

Multi:
1.  Load Quetz on all chars.  MAKE SURE YOU HAVE MULTICTRL DOWNLOADED!
2.  [Optional] You can edit the customize the Begin() function in Quetz to add more jobs or functions but the common jobs are there.
3.  Bring all chars with elvorseal into Quetz arena, SUMMON TRUSTS!
4.  On party leader ONLY, run //Quetz start
