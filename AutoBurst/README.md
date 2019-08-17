## AutoBurst Windower Addon
### Automatically Bursts when it reads a SKILLCHAIN packet

---

#### SET UP

Place the Folder AutoBurst inside the Windower/Addons/ directory should look similar too

```
Windower/
     Addons/
          AutoBurst
               AutoBurst.lua
```

Upon loading, to get the best out of AutoBurst you must set an "AssistedPlayer" this is the person whose target will be used to nuke.

Simply type either:
```
//ab assist NAME
or
//autoburst assist NAME
```

If typing in the Windower console remove the two /

Advanced users can also change the element to be used with skillchains and the tier order. See more info below.

Then while in game type in the In Game text box:
***//lua load AutoBurst***

alternatively you can type 
***lua load AutoBurst***
into the Windower Console Window.

With this done the addon should not be ready to work, simply begin skillchaining and 2 seconds after the chain your character wil begin bursting. Please note only the following jobs will burst: RDM, BLM, SCH, or GEO, going forward I'll extend this list.


#### ADVANCED SET UP
Advanced setup allows you to edit Elements to burst with and tiers. Under User Settings in the LUA the additional customizable options are

```
burstMagic = {
  -- LEVEL 3  and 4
  ["radiance"] = "Thunder",
  ["light"] = "Thunder",
  ["umbra"] = "Blizzard",
  ["darkness"] = "Blizzard",
  -- LEVEL 2
  ["gravitation"] = "Stone",
  ["fragmentation"] = "Thunder",
  ["distortion"] = "Blizzard",
  ["fusion"] = "Fire",
  -- LEVEL 1
  ["compression"] = "Aspir",
  ["liquefaction"] = "Fire",
  ["induration"] = "Blizzard",
  ["reverberation"] = "Water",
  ["transfixion"] = "Banish",
  ["scission"] = "Stone",
  ["detonation"] = "Aero",
  ["impaction"] = "Thunder",
}

tierOrder = {
  [1] = "VI",
  [2] = "V",
  [3] = "IV",
  [4] = "III",
  [5] = "II",
  [6] = "I",
}
```

To edit elements simply change the current element to a different one, for example.

```
["radiance"] = "Fire",
```

To edit Tiers, simply change the tier number, for example.

```
  [4] = "VI",
  [3] = "V",
  [2] = "IV",
  [1] = "III",
  [5] = "II",
  [6] = "I",
```

This will then make the addon check and use spells in the following order.

III, IV, V, VI, II, I




