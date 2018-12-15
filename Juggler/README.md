# Juggler
Juggler is an add-on for [FFXI Windower](http://windower.net/). The purpose of Juggler is to simplify the use of Ready commands for jug pets by providing dynamic macros based on the active jug pet's abilities. Other features include: current count of Ready charges and time until the next charge is ready.

## Usage
The first thing you should do is setup your Ready recast time. By default, Juggler will use the base 30 second recast. If you have any merits or gear that lowers your recast, run the `jugs set_recast X` command, where X is your final recast time including the recast reduction gear and merits.

Next, create macros for each of the Ready move numbers (1 through 7) like this: `/console jugs ready_move 1`. You'll need 7 macros in total.

Whenever you have a jug pet summoned, the Juggler HUD will appear showing you your available Ready charges, time until next charge, and the list of available Ready moves. Each move is prefaced with a number which corresponds to one of the macros you created.

**Example HUD for BlackbeardRandy**  
`Moves: 3`  
`Next: Idle`  
`[1] Roar`  
`[2] Razor Fang`  
`[3] Claw Cyclone`  

## Commands
* `ready_move {MOVE NUMBER}`
  * `{MOVE NUMBER}` argument: 1-7
* `set_recast {RECAST TIME}`
  * `{RECAST TIME}` argument: your final recast time including recast reduction gear and merits. Default: 30.
* `set_xy {X POS} {Y POS}`
  * `{X POS}`/`{Y POS}` argument: the new X/Y position for the HUD.
