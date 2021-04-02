Update Log

01/25/2021 : Added DRGs pet command macros



Steps to get XIVCrossbar working:

1) Install Autohotkey (https://www.autohotkey.com/)

2) Run FFXI Configuration tool and set up your gamepad to match ConfigureYourGamepadLikeThis.jpg. Green box = required to have set, Red box = required to leave blank, Yellow box = configure it the way you usually do.

3) Add the following to your Gearswap LUA for any jobs where you want to use the crossbar. If you already have these functions defined, simply add the "windower.send_command" line in each of them to the existing function.

    function user_setup()
        windower.send_command('lua load xivcrossbar')
    end

    function user_unload()
        windower.send_command('lua unload xivcrossbar')
    end

    function job_setup()
        windower.send_command('lua reload xivcrossbar')
    end

4) Follow the instructions in the setup dialog shown in-game.

    a) If you're using an XInput controller, everything should Just Work.

    b) If you're using a DirectInput controller that is a Wired Fight Pad Pro for Nintendo Switch, everything should Just Work.

    c) If you're using a DirectInput controller that is something else, you may need to modify the button numbers in ffxi_directinput.ahk. You can use the AHK script at https://www.autohotkey.com/docs_1.0/scripts/JoystickTest.htm to determine what your button numbers are. In ffxi_directinput.ahk you shouldn't need to change ANY lines other than changing lines like `Joy10::` to `Joy4::`, and any corresponding lines like `if GetKeyState("Joy10")` to `if GetKeyState("Joy4")`, and so forth. Everything else can be configured through the addon in-game.

5) Minus button (Nintendo), Share button (PS4) or Back button (XBox) brings up the gamepad binding utility, and can also exit out of it.

6) Plus button (Nintendo), Options button (PS4) or Start button (XBox) brings up binding set selector as long as it is held down, and you can switch between different binding sets by using your dpad.

7) Once you're used to the button placement, I recommend updating your settings xml to use the compact layout, just to reclaim some screen real estate.

8) If you want a 4th crossbar in each set, you can set the crossbar number to 4 in settings, which will make the 3rd and 4th crossbars dependent on which trigger you press first. L -> R is Crossbar 4, and R -> L is Crossbar 3.

9) Enjoy!

NOTE: The crossbar unbinds any existing bindings for Ctrl+F1 through Ctrl+F12 because it uses those buttons as proxies for the gamepad. Any Alt, Shift, or neutral bindings to F1-F12 will be unaffected. Ctrl is used for the bindings rather than Alt because Alt has a tendency to get "stuck" when Alt-Tabbing in and out, and can lead to accidental ability use. However, while Ctrl+F9 through Ctrl+F12 are completely locked down by this addon, you can re-add your Ctrl+F1 through Ctrl+F8 bindings by editing function_key_bindings.lua.

NOTE: in order to capture dpad inputs without affecting the underlying game, you will need to hold down at least one of the triggers for XIVCrossbar to be able to use its input. This should really only be noticeable when navigating the gamepad binding utility.
