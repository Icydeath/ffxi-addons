/*  XInput by Lexikos
 *  This version of the script uses objects, so requires AutoHotkey_L.
 */

/*
    Function: XInput_Init
    
    Initializes XInput.ahk with the given XInput DLL.
    
    Parameters:
        dll     -   The path or name of the XInput DLL to load.
*/
XInput_Init(dll="C:\Windows\System32\xinput1_3")
{
    global
    if _XInput_hm
        return
    
    ;======== CONSTANTS DEFINED IN XINPUT.H ========
    
    ; NOTE: These are based on my outdated copy of the DirectX SDK.
    ;       Newer versions of XInput may require additional constants.
    
    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD          := 0x01

    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD       := 0x01

    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED     := 0x0004

    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP          := 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
    XINPUT_GAMEPAD_START            := 0x0010
    XINPUT_GAMEPAD_BACK             := 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
    XINPUT_GAMEPAD_A                := 0x1000
    XINPUT_GAMEPAD_B                := 0x2000
    XINPUT_GAMEPAD_X                := 0x4000
    XINPUT_GAMEPAD_Y                := 0x8000

    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  := 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE := 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD    := 30

    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD             := 0x00000001
    
    ;=============== END CONSTANTS =================
    
    _XInput_hm := DllCall("LoadLibrary" ,"str",dll)
    
    if !_XInput_hm
    {
        MsgBox, Failed to initialize XInput: %dll%.dll not found.
        return
    }
    
    _XInput_GetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetState")
    _XInput_SetState        := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputSetState")
    _XInput_GetCapabilities := DllCall("GetProcAddress" ,"ptr",_XInput_hm ,"astr","XInputGetCapabilities")
    
    if !(_XInput_GetState && _XInput_SetState && _XInput_GetCapabilities)
    {
        XInput_Term()
        MsgBox, Failed to initialize XInput: function not found.
        return
    }
}

/*
    Function: XInput_GetState
    
    Retrieves the current state of the specified controller.

    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value from 0 to 3.
        State       -   [out] Receives the current state of the controller.
    
    Returns:
        If the function succeeds, the return value is ERROR_SUCCESS (zero).
        If the controller is not connected, the return value is ERROR_DEVICE_NOT_CONNECTED (1167).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
        XInput.dll returns controller state as a binary structure:
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_state
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_gamepad
        XInput.ahk converts this structure to an AutoHotkey_L object.
*/
XInput_GetState(UserIndex)
{
    global _XInput_GetState
    
    VarSetCapacity(xiState,16)

    if ErrorLevel := DllCall(_XInput_GetState ,"uint",UserIndex ,"uint",&xiState)
        return 0
    
    return {
    (Join,
        dwPacketNumber: NumGet(xiState,  0, "UInt")
        wButtons:       NumGet(xiState,  4, "UShort")
        bLeftTrigger:   NumGet(xiState,  6, "UChar")
        bRightTrigger:  NumGet(xiState,  7, "UChar")
        sThumbLX:       NumGet(xiState,  8, "Short")
        sThumbLY:       NumGet(xiState, 10, "Short")
        sThumbRX:       NumGet(xiState, 12, "Short")
        sThumbRY:       NumGet(xiState, 14, "Short")
    )}
}

/*
    Function: XInput_SetState
    
    Sends data to a connected controller. This function is used to activate the vibration
    function of a controller.
    
    Parameters:
        UserIndex       -   [in] Index of the user's controller. Can be a value from 0 to 3.
        LeftMotorSpeed  -   [in] Speed of the left motor, between 0 and 65535.
        RightMotorSpeed -   [in] Speed of the right motor, between 0 and 65535.
    
    Returns:
        If the function succeeds, the return value is 0 (ERROR_SUCCESS).
        If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    Remarks:
        The left motor is the low-frequency rumble motor. The right motor is the
        high-frequency rumble motor. The two motors are not the same, and they create
        different vibration effects.
*/
XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
{
    global _XInput_SetState
    return DllCall(_XInput_SetState ,"uint",UserIndex ,"uint*",LeftMotorSpeed|RightMotorSpeed<<16)
}

/*
    Function: XInput_GetCapabilities
    
    Retrieves the capabilities and features of a connected controller.
    
    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value in the range 0–3.
        Flags       -   [in] Input flags that identify the controller type.
                                0   - All controllers.
                                1   - XINPUT_FLAG_GAMEPAD: Xbox 360 Controllers only.
        Caps        -   [out] Receives the controller capabilities.
    
    Returns:
        If the function succeeds, the return value is 0 (ERROR_SUCCESS).
        If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    Remarks:
        XInput.dll returns capabilities via a binary structure:
            http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.xinput_capabilities
        XInput.ahk converts this structure to an AutoHotkey_L object.
*/
XInput_GetCapabilities(UserIndex, Flags)
{
    global _XInput_GetCapabilities
    
    VarSetCapacity(xiCaps,20)
    
    if ErrorLevel := DllCall(_XInput_GetCapabilities ,"uint",UserIndex ,"uint",Flags ,"ptr",&xiCaps)
        return 0
    
    return,
    (Join
        {
            Type:                   NumGet(xiCaps,  0, "UChar"),
            SubType:                NumGet(xiCaps,  1, "UChar"),
            Flags:                  NumGet(xiCaps,  2, "UShort"),
            Gamepad:
            {
                wButtons:           NumGet(xiCaps,  4, "UShort"),
                bLeftTrigger:       NumGet(xiCaps,  6, "UChar"),
                bRightTrigger:      NumGet(xiCaps,  7, "UChar"),
                sThumbLX:           NumGet(xiCaps,  8, "Short"),
                sThumbLY:           NumGet(xiCaps, 10, "Short"),
                sThumbRX:           NumGet(xiCaps, 12, "Short"),
                sThumbRY:           NumGet(xiCaps, 14, "Short")
            },
            Vibration:
            {
                wLeftMotorSpeed:    NumGet(xiCaps, 16, "UShort"),
                wRightMotorSpeed:   NumGet(xiCaps, 18, "UShort")
            }
        }
    )
}

/*
    Function: XInput_Term
    Unloads the previously loaded XInput DLL.
*/
XInput_Term() {
    global
    if _XInput_hm
        DllCall("FreeLibrary","uint",_XInput_hm), _XInput_hm :=_XInput_GetState :=_XInput_SetState :=_XInput_GetCapabilities :=0
}

#SingleInstance force

lastKeyPressed := ""
isLeftTriggerDown := false
isRightTriggerDown := false
isCtrlDown := false

isDpadUpDown := false
isDpadRightDown := false
isDpadDownDown := false
isDpadLeftDown := false
isButtonADown := false
isButtonBDown := false
isButtonXDown := false
isButtonYDown := false
isButtonStartDown := false
isButtonBackDown := false

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

; Example: Control the vibration motors using the analog triggers of each controller.
XInput_Init()
Loop {
    Loop, 4 {
        If State := XInput_GetState(A_Index-1) {
            If WinActive("ahk_class FFXiClass") {
                if (State.bLeftTrigger and !isLeftTriggerDown) {
                    isLeftTriggerDown := true
                    If (!isCtrlDown) {
                        isCtrlDown := true
                        SendInput {Ctrl down}
                    }
                    SendInput {f11 down}
                } else If (!State.bLeftTrigger and isLeftTriggerDown) {
                    isLeftTriggerDown := false
                    SendInput {f11 up}
                    If (!State.bRightTrigger and !isRightTriggerDown and isCtrlDown) {
                        isCtrlDown := false
                        SendInput {Ctrl up}
                    }
                }
				
                if (State.bRightTrigger and !isRightTriggerDown) {
                    isRightTriggerDown := true
                    If (!isCtrlDown) {
                        isCtrlDown := true
                        SendInput {Ctrl down}
                    }
                    SendInput {f12 down}
                } else If (!State.bRightTrigger and isRightTriggerDown) {
                    isRightTriggerDown := false
                    SendInput {f12 up}
                    If (!State.bLeftTrigger and !isLeftTriggerDown and isCtrlDown) {
                        isCtrlDown := false
                        SendInput {Ctrl up}
                    }
                }
				
				if (isRightTriggerDown or isLeftTriggerDown or isButtonStartDown) {
					If (!isDpadUpDown and State.wButtons & XINPUT_GAMEPAD_DPAD_UP) {
						SendInput {f1}

						isDpadUpDown := true
					} else If (isDpadUpDown and !(State.wButtons & XINPUT_GAMEPAD_DPAD_UP)) {
						isDpadUpDown := false
					}
					If (!isDpadRightDown and State.wButtons & XINPUT_GAMEPAD_DPAD_RIGHT) {
						SendInput {f2}

						isDpadRightDown := true
					} else If (isDpadRightDown and !(State.wButtons & XINPUT_GAMEPAD_DPAD_RIGHT)) {
						isDpadRightDown := false
					}
					If (!isDpadDownDown and State.wButtons & XINPUT_GAMEPAD_DPAD_DOWN) {
						SendInput {f3}

						isDpadDownDown := true
					} else If (isDpadDownDown and !(State.wButtons & XINPUT_GAMEPAD_DPAD_DOWN)) {
						isDpadDownDown := false
					}
					If (!isDpadLeftDown and State.wButtons & XINPUT_GAMEPAD_DPAD_LEFT) {
						SendInput {f4}

						isDpadLeftDown := true
					} else If (isDpadLeftDown and !(State.wButtons & XINPUT_GAMEPAD_DPAD_LEFT)) {
						isDpadLeftDown := false
					}
				}
				
                If (!isButtonADown and State.wButtons & XINPUT_GAMEPAD_A) {
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

                    isButtonADown := true
                } else If (isButtonADown and !(State.wButtons & XINPUT_GAMEPAD_A)) {
                    isButtonADown := false
                }
                If (!isButtonBDown and State.wButtons & XINPUT_GAMEPAD_B) {
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

                    isButtonBDown := true
                } else If (isButtonBDown and !(State.wButtons & XINPUT_GAMEPAD_B)) {
                    isButtonBDown := false
                }
                If (!isButtonXDown and State.wButtons & XINPUT_GAMEPAD_X) {
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

                    isButtonXDown := true
                } else If (isButtonXDown and !(State.wButtons & XINPUT_GAMEPAD_X)) {
                    isButtonXDown := false
                }
                If (!isButtonYDown and State.wButtons & XINPUT_GAMEPAD_Y) {
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

                    isButtonYDown := true
                } else If (isButtonYDown and !(State.wButtons & XINPUT_GAMEPAD_Y)) {
                    isButtonYDown := false
                }

                If (!isButtonBackDown and State.wButtons & XINPUT_GAMEPAD_BACK) {
                    SendInput {Ctrl down}
                    SendInput {f9 down}

                    isButtonBackDown := true
                } else If (isButtonBackDown and !(State.wButtons & XINPUT_GAMEPAD_BACK)) {
                    SendInput {f9 up}
                    SendInput {Ctrl up}

                    isButtonBackDown := false
                }
                If (!isButtonStartDown and State.wButtons & XINPUT_GAMEPAD_START) {
                    SendInput {Ctrl down}
                    SendInput {f10 down}

                    isButtonStartDown := true
                } else If (isButtonStartDown and !(State.wButtons & XINPUT_GAMEPAD_START)) {
                    SendInput {f10 up}
                    SendInput {Ctrl up}

                    isButtonStartDown := false
                }
            }
        }
    }
    Sleep, 10
}

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
