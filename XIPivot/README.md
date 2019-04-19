## About

XIPivot is an addon that allows to dynamically override parts of the ROM / sound
files of your FFXI client without touching the actual files.

It provides support for multiple overlay directories as well as runtime controls
of which overlays are loaded and used by the game.

The goals behind XIPivot are simple:

- no modifications to the original DAT / spw / bgw files
- no more huge folder with thousands of anonymous files
- the ability to sort Mods into separate folders for each mod
- the ability to control which Mods take precedence

## Setup

- 1) Copy the XIPivot folder into your Windower addons folder.
- 2) Create a subdirectory inside the `data/DATs` folder for each overlay you want to use
- 3) Edit `data/settings.xml` (see `settings.sample.xml`):
   - add the directory names from 2) for each overlay that should be enabled, separated by ','
   - *order matters* - overlays will be used in order, with the first hit for a file being used.

### Example - XI-View, XI-Vision and Ammelia's HD-Remake:

Directory structure:

```
<Windower Install>
   +-- addons/
        +-- XIPivot/
             +-- XIPivot.lua
             +-- README.md
             +-- libs/
             |    +-- _XIPivot.dll
             |
             +-- data/
                  +-- DATs/
                  |   +-- README.txt
                  |   +-- XI-View/
                  |   |    +-- ROM/
                  |   |
                  |   +-- XI-Vision/
                  |   |    +-- ROM/
                  |   |    +-- ROM2/
                  |   |    +-- ROM3/
                  |   |    +-- ROM4/
                  |   |    +-- ROM4/
                  |   |
                  |   +-- FFXI-HD/
                  |        +-- ROM/
                  |        +-- ROM2/
                  |        +-- ROM3/
                  |
                  +-- settings.xml 
```


settings.xml:

```xml
<?xml version="1.1" ?>
<settings>
    <global>
	<overlays>XI-View,XI-Vision,FFXI-HD</overlays>
    </global>
</settings>
```

XIPivot defaults to look for your overlays in the `data/DATs/` directory inside the `XIPivot/` bundle.
If you prefer a different path you can add the key `'root_path'` to `settings.xml` like so:

```xml
<?xml version="1.1" ?>
<settings>
    <global>
	<overlays>XI-View,XI-Vision,FFXI-HD</overlays>
	<root_path>C:/my/awesome/adds<root_path>
    </global>
</settings>
```

This instructs to XIPivot to seach for overlays inside `"C:\my\awesome\addons"` instead.

## In-Game commands

XIPivot makes the in-game command `//pivot` available to load and unload overlays at runtime.
The following parameters are supported:

- a/add overlay_path     -- will load 'overlay_name' as last entry to the overlay list
- r/remove overlay_path  -- will unload 'overlay_name' and remove it from the overlay list
- s/status               -- dumps XIPivot's global status and the list of active overlays
- h/help                 -- print this text

These commands all support a short first letter version (a/r/s/h).
Changes made with add / remove will be reflected in `settings.xml`.

Please note that adding and removing overlays way after the game launches can have side effects.
XI will load some DAT files right at the start and then never look at them again (some menu and landscape textures)
other DAT files are loaded on-demand and overlay changes are visible once that happens (maps, some menu icons, Mog House and a few other locations)

## Limitations

As a result of how Windower loads this addon some DAT files will already be loaded before any redirects can happen.
Currently this affects Mods that try to replace the initial menu textures or fonts.

Known affected Mods:

- XI-View -- no replaced fonts or menu textures, HQ icons work

## Overlays with sound / music files

XI is pretty unforgiving when replacing BGW music files at runtime and will crash if you do something stupid.

**It is not advised to have sound Mods in <global> or change them at runtime**
**Support for sound / music overlays is considered EXPERIMENTAL**

## Disclaimer

I tested XIPivot to the best of my capabilities but I can not guarantee that it works without bugs for 100% of the time.
Use at your own discretion, I take no responsibility for any client crashes or data loss.
