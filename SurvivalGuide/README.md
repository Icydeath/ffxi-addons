# Survival Guide


#### Warning - This can/will allow you to warp to Survival Guides that you don't own.  Please use at your own risk and do not blame me if you get banned.    This add-on is meant to remove the menu-lag interaction and add macro-ability to Survival Guide usage.

#### Warning 2: You must talk to a Survival Guide before warping through it the first time to register it.   This is different than the first warning.  IE) You can use SG to warp from any "registered" SurvivalGuide to another one (even if you do not own the target).  Make sure you register your Survival Guides first or you will lock the client and need to //terminate.

This LUA is used to warp to any Survival Guide within FFXI.  Simply type //sg warp <SurvivalGuide>.   

Example: 
//sg warp Northern San d'Oria

You must be within 6 yalms of a Survival Guide to use this.

As a really ugly hack to the Moogle Kupo-Power "Thrifty Transit".

If Thrifty Transit is in play (free transports) you must use //sg free to change the menu structure and it will last until you restart Survival Guide.   If you do not do this, you will send packets on the wrong menu.  To reset type //sg reset1; //sg free; then //sg warp <Survival Guide>.    

