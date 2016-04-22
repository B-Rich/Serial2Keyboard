#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=serial2keyboard.ico
#AutoIt3Wrapper_Outfile=Serial2Keyboard.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <TrayConstants.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Array.au3>
#include 'CommMG.au3'


HotKeySet("+!d", "ExitProgram")

Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

Local $sportSetError

Local $idOpen = TrayCreateItem("Open")
Local $idExit = TrayCreateItem("Exit")
TraySetState($TRAY_ICONSTATE_SHOW)
TrayItemSetOnEvent($idOpen, "ShowGUI")
TrayItemSetOnEvent($idExit, "ExitProgram")

#Region ### START Koda GUI section ###

$Form = GUICreate("Serial2Keyboard", 250, 170, -1, -1)
GUICtrlCreateGroup("Connect config", 8, 8, 233, 73)
$Port = GUICtrlCreateCombo("", 24, 40, 89, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
$Baudrates = GUICtrlCreateCombo("", 136, 40, 89, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1200|2400|4800|9600|19200|38400|57600|115200", "9600")
;~ GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonStart = GUICtrlCreateButton("Start !", 8, 96, 233, 49)
GUICtrlSetFont(-1, 18, 400, 0, "MS Sans Serif")
$Label1 = GUICtrlCreateLabel("IOXhop - www.ioxhop.com", 64, 152, 130, 17, $SS_CENTER)
GUISetState(@SW_SHOW)

$portlist = _CommListPorts(0)

If Not @error = 1 Then
	For $pl = 1 To $portlist[0]
		GUICtrlSetData($Port, $portlist[$pl])
	Next
EndIf

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $ButtonStart
			If GUICtrlRead($Port) == "" Then
				MsgBox(16, "Error", "Please select a COM port")
			Else
				$setport = StringReplace(GUICtrlRead($Port), 'COM', '')
				$resOpen = _CommSetPort($setport, $sportSetError, GUICtrlRead($Baudrates))
				If $resOpen = 0 Then
					MsgBox(16, "Couldn't open port", $sportSetError)
				Else
					GUICtrlSetState($ButtonStart, $GUI_DISABLE)

					GUISetState(@SW_HIDE, $Form)
					TrayTip("Serial2Keyboard", "Press Shift-Alt-d to exit", 5)
					While 1
					   $tray = TrayGetMsg()
					   ConsoleWrite($tray)

						Switch $tray
							Case $idExit
								Exit
							Case $idOpen
								GUISetState(@SW_SHOW, $Form)
						EndSwitch

						$Str = _CommGetLine(Chr(3), 1000)		; get until 0x03 (ETX)

						If $Str <> "" Then
						   ;ConsoleWrite("RAW: " & _StringToHex($Str) & @CRLF)
						   $aStr = StringSplit($Str, "")
						   ;_ArrayDisplay($aStr)

						   $count = 0		; send only 10 characters

						   For $i = 1 To $aStr[0]

							  If ($aStr[$i] >= "0" And $aStr[$i] <= "9") Or ($aStr[$i] >= "A" And $aStr[$i] <= "F") Then
								 ConsoleWrite($aStr[$i])
								 Send($aStr[$i])
								 $count += 1

								 If $count = 10 Then
									ExitLoop
								 EndIf
							  EndIf
						   Next

						   ConsoleWrite(@CRLF)
						   ;Send($Str)
						EndIf
					WEnd
				EndIf
			EndIf
	EndSwitch
WEnd

Func ExitProgram()
   _CommClosePort()
   Exit
 EndFunc

 Func ShowGUI()
	GUISetState(@SW_SHOW, $Form)
 EndFunc
