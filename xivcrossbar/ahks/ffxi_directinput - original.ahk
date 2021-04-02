; Run every line
Critical

#SingleInstance force

; Switch windows instantaeously
SetWinDelay, -1

; Avoid warning dialogue about over-hits
#MaxHotkeysPerInterval 50000
#HotkeyInterval 1
#WinActivateForce

IniRead, ButtonLayout, config.ini, ButtonMap, ButtonLayout
IniRead, ConfirmButton, config.ini, ButtonMap, ConfirmButton
IniRead, CancelButton, config.ini, ButtonMap, CancelButton
IniRead, MainMenuButton, config.ini, ButtonMap, MainMenuButton
IniRead, ActiveWindowButton, config.ini, ButtonMap, ActiveWindowButton
StringUpper, ButtonLayout, ButtonLayout
StringUpper, ConfirmButton, ConfirmButton
StringUpper, CancelButton, CancelButton
StringUpper, MainMenuButton, MainMenuButton
StringUpper, ActiveWindowButton, ActiveWindowButton

lastKeyPressed := ""
isLeftTriggerDown := false
isRightTriggerDown := false

#Persistent  ; Keep this script running until the user explicitly exits it.
SetTimer, CheckPOVState, 10 ; Poll for POV hat every 10ms

CheckPOVState:
If WinActive("ahk_class FFXiClass") {
  GetKeyState, joyp, JoyPOV
  If (joyp == 0) {
    If (lastKeyPressed != "dpad_up") {
      SendInput {f1}

      lastKeyPressed:= "dpad_up"
    }
  } else If (joyp == 9000) {
    If (lastKeyPressed != "dpad_right") {
      SendInput {f2}

      lastKeyPressed:= "dpad_right"
    }
  } else If (joyp == 18000) {
    If (lastKeyPressed != "dpad_down") {
      SendInput {f3}

      lastKeyPressed:= "dpad_down"
    }
  } else If (joyp == 27000) {
    If (lastKeyPressed != "dpad_left") {
      SendInput {f4}

      lastKeyPressed:= "dpad_left"
    }
  } else If (joyp == -1 and lastKeyPressed != "") {
      lastKeyPressed:= ""
  }
}
return

; Helper subroutines. *DON'T* modify these to remap, instead just change which buttons call them
SendConfirmKey:
SendInput {Enter}
return
SendCancelKey:
SendInput {Esc}
return
SendMainMenuKey:
SendInput {NumpadSub}
return
SendActiveWindowKey:
SendInput {NumpadAdd}
return

; Gamecube Y Button (Playstation Triangle, Xbox Y Button, Nintendo X Button, TOP face button)
Joy1::
If WinActive("ahk_class FFXiClass") {
  If (isLeftTriggerDown or isRightTriggerDown) {
    SendInput {f8}
  } else {
    If (ButtonLayout == "GAMECUBE" or ButtonLayout == "XBOX") {
      If (ConfirmButton == "Y") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "Y") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "Y") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "Y") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "PLAYSTATION") {
      If (ConfirmButton == "TRIANGLE") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "TRIANGLE") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "TRIANGLE") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "TRIANGLE") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "NINTENDO") {
      If (ConfirmButton == "X") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "X") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "X") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "X") {
        Gosub, SendActiveWindowKey
      }
    }
  }
}
return

; Gamecube B Button (Playstation Square, Xbox X Button, Nintendo Y Button, LEFT face button)
Joy2::
If WinActive("ahk_class FFXiClass") {
  If (isLeftTriggerDown or isRightTriggerDown) {
    SendInput {f6}
  } else {
    If (ButtonLayout == "GAMECUBE") {
      If (ConfirmButton == "B") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "B") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "B") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "B") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "XBOX") {
      If (ConfirmButton == "X") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "X") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "X") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "X") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "PLAYSTATION") {
      If (ConfirmButton == "SQUARE") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "SQUARE") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "SQUARE") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "SQUARE") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "NINTENDO") {
      If (ConfirmButton == "Y") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "Y") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "Y") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "Y") {
        Gosub, SendActiveWindowKey
      }
    }
  }
}
return

; Gamecube A Button (Playstation Cross, Xbox A Button, Nintendo B Button, BOTTOM face button)
Joy3::
If WinActive("ahk_class FFXiClass") {
  If (isLeftTriggerDown or isRightTriggerDown) {
    SendInput {f5}
  } else {
    If (ButtonLayout == "GAMECUBE" or ButtonLayout == "XBOX") {
      If (ConfirmButton == "A") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "A") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "A") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "A") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "PLAYSTATION") {
      If (ConfirmButton == "CROSS") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "CROSS") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "CROSS") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "CROSS") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "NINTENDO") {
      If (ConfirmButton == "B") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "B") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "B") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "B") {
        Gosub, SendActiveWindowKey
      }
    }
  }
}
return

; Gamecube X Button (Playstation Circle, Xbox B Button, Nintendo A Button, RIGHT face button)
Joy4::
If WinActive("ahk_class FFXiClass") {
  If (isLeftTriggerDown or isRightTriggerDown) {
    SendInput {f7}
  } else {
    If (ButtonLayout == "GAMECUBE") {
      If (ConfirmButton == "X") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "X") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "X") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "X") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "XBOX") {
      If (ConfirmButton == "B") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "B") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "B") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "B") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "PLAYSTATION") {
      If (ConfirmButton == "CIRCLE") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "CIRCLE") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "CIRCLE") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "CIRCLE") {
        Gosub, SendActiveWindowKey
      }
    } else If (ButtonLayout == "NINTENDO") {
      If (ConfirmButton == "A") {
        Gosub, SendConfirmKey
      } else If (CancelButton == "A") {
        Gosub, SendCancelKey
      } else If (MainMenuButton == "A") {
        Gosub, SendMainMenuKey
      } else If (ActiveWindowButton == "A") {
        Gosub, SendActiveWindowKey
      }
    }
  }
}
return

; Left Trigger
Joy7::
If WinActive("ahk_class FFXiClass") {
  SendInput {Ctrl down}
  SendInput {f11 down}
  isLeftTriggerDown := true
  SetTimer, WaitForButtonUp7, 10 ; Poll for button setting every 10ms
}
return

WaitForButtonUp7:
If WinActive("ahk_class FFXiClass") {
  if GetKeyState("Joy7")  ; The button is still, down, so keep waiting.
      return
  ; Otherwise, the button has been released.
  SendInput {f11 up}
  if !isRightTriggerDown {
    SendInput {Ctrl up}
  }
  isLeftTriggerDown := false
  SetTimer, WaitForButtonUp7, Off ; Turn off polling
}
return

; Right Trigger
Joy8::
If WinActive("ahk_class FFXiClass") {
  SendInput {Ctrl down}
  SendInput {f12 down}
  isRightTriggerDown := true
  SetTimer, WaitForButtonUp8, 10 ; Poll for button setting every 10ms
}
return

WaitForButtonUp8:
If WinActive("ahk_class FFXiClass") {
  if GetKeyState("Joy8")  ; The button is still, down, so keep waiting.
      return
  ; Otherwise, the button has been released.
  SendInput {f12 up}
  if !isLeftTriggerDown {
    SendInput {Ctrl up}
  }
  isRightTriggerDown := false
  SetTimer, WaitForButtonUp8, Off ; Turn off polling
}
return

; Opens/closes gamepad binding dialog
Joy9::
If WinActive("ahk_class FFXiClass") {
  SendInput {Ctrl down}
  SendInput {f9 down}
  SetTimer, WaitForButtonUp9, 10 ; Poll for button setting every 10ms
}
return

WaitForButtonUp9:
If WinActive("ahk_class FFXiClass") {
  if GetKeyState("Joy9")  ; The button is still, down, so keep waiting.
      return
  ; Otherwise, the button has been released.
  SendInput {f9 up}
  SendInput {Ctrl up}
  SetTimer, WaitForButtonUp9, Off ; Turn off polling
}
return

; Shows the environment list
Joy10::
If WinActive("ahk_class FFXiClass") {
  SendInput {Ctrl down}
  SendInput {f10 down}
  SetTimer, WaitForButtonUp10, 10 ; Poll for button setting every 10ms
}
return

WaitForButtonUp10:
If WinActive("ahk_class FFXiClass") {
  if GetKeyState("Joy10")  ; The button is still, down, so keep waiting.
      return
  ; Otherwise, the button has been released.
  SendInput {f10 up}
  SendInput {Ctrl up}
  SetTimer, WaitForButtonUp10, Off ; Turn off polling
}
return
