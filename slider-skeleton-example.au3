; ------------------------------------------------------------------------------;
;           / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \
;          ( S ) l ) i ) d ) e ) r ) ( S ) k ) e ) l ) e ) t ) o ) n )
;           \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
;
;                   Copyright (c) 2014 Markus Eschenbach
;
; Language:         English
; Platform:         Win2k / XP / Vista
; Author:           Markus Eschenbach
; Version:          1.0
; License:          GNU General Public License v3
;
;       More informations under: http://www.blogging-it.com
; ------------------------------------------------------------------------------;

#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <StaticConstants.au3>

;~ Opt("TrayIconHide", 1)
Global $hide = 0, $side = "left"

;~ ####### SLIDE FORM SETTINGS #######
Const $SliderWidthOpen = 550
Const $SliderWidthClose = 20
Const $SliderHeight = 250
Const $SliderX = 0
Const $SliderY = -1

Const $SliderBtnWidth = 20
Const $SliderBtnHeight = 230
Const $SliderBtnX = $SliderWidthOpen - $SliderBtnWidth
Const $SliderBtnY = 10
;~ ###################################


;~ ########### GUI ###################
$formSlider = GUICreate("Open", $SliderWidthOpen, $SliderHeight, $SliderX, $SliderY, $WS_POPUP + $WS_BORDER, $WS_EX_TOOLWINDOW) ;or additional BitOR($WS_EX_TOOLWINDOW,$WS_EX_TOOLWINDOW)
$sliderBTNhs = GUICtrlCreateButton("<", $SliderBtnX, $SliderBtnY, $SliderBtnWidth, $SliderBtnHeight, BitOR($BS_CENTER, $BS_FLAT, $BS_MULTILINE))
GUIRegisterMsg($WM_NCHITTEST, "moveFormSlider") ;~ enable the possibility to move the window

;~ slide in the gui on programm start
DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $formSlider, "int", 100, "long", 0x00040001)
;~ ###################################

GUISetState()

While 1
	Switch GUIGetMsg()
		Case $sliderBTNhs
			If ($hide = 0) Then
				SliderHide()
			ElseIf ($hide = 1) Then
				SliderShow()
			EndIf
			setSliderButton()
			WinActivate($formSlider)
			WinWaitActive($formSlider)
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch

	$slider_pos = WinGetPos($formSlider)
	$retVal = dedectScreen()

	If (IsArray($retVal)) Then
		$halfScreen = $retVal[0] + ($retVal[1] / 2)

		If ($hide = 0) Then
			If $slider_pos[0] + getHalfSliderWidth() < $halfScreen Then ;check if the window is on the left side of the screen
				If $side = "right" Then SideSwitch()

				If $slider_pos[0] <> $retVal[0] And $slider_pos[0] Then
					WinMove($formSlider, "", $retVal[0], $slider_pos[1])
				EndIf
			Else
				If $side = "left" Then SideSwitch()

				If $slider_pos[0] <> $retVal[1] - $SliderWidthOpen And $slider_pos[0] Then
					WinMove($formSlider, "", $retVal[2] - $SliderWidthOpen, $slider_pos[1])
				EndIf
			EndIf
		ElseIf ($hide = 1) Then
			If $slider_pos[0] + getHalfSliderWidth() < $halfScreen Then ;check if the window is on the left side of the screen
				If $side = "right" Then SideSwitch()
				If $slider_pos[0] <> $retVal[0] And $slider_pos[0] Then
					WinMove($formSlider, "", $retVal[0], $slider_pos[1])
				EndIf
			Else
				If $side = "left" Then SideSwitch()

				If $slider_pos[0] <> $retVal[1] - $SliderWidthClose And $slider_pos[0] Then
					WinMove($formSlider, "", $retVal[2] - $SliderWidthClose, $slider_pos[1])
				EndIf
			EndIf
		EndIf
	EndIf
WEnd


;~ ####### INTERNAL FUNCTIONS ########

#cs------------------------------------------------
	;~ This function is used to move the popup GUI form
	;~ Call the function like
	;~ GUIRegisterMsg($WM_NCHITTEST, "moveForm")
#ce------------------------------------------------
Func moveFormSlider($formSlider, $Msg, $wParam, $lParam)
	Local $iProc
	$iProc = DllCall("user32.dll", "int", "DefWindowProc", "hwnd", $formSlider, "int", $Msg, "wparam", $wParam, "lparam", $lParam)
	$iProc = $iProc[0]
	If $iProc = $HTCLIENT Then Return $HTCAPTION

	Return $GUI_RUNDEFMSG
EndFunc   ;==>moveFormSlider

#cs------------------------------------------------
	;~ This function reads the current position of
	;~ the slider and find out the current monitor.
	;~ Then it returns an Array with the screen informations of the current monitor.
	;~ @return array with monitor informations
	;~ EXAMPLE ARRAY:
	;~  Array[0][0] = monitor 1: screen begin pixel position
	;~	Array[0][1] = monitor 1: width number of  pixel
	;~	Array[0][2] = monitor 1: screen end pixel position
	;~ .................................
#ce------------------------------------------------

Func dedectScreen()
	$screenSettingsArray = getMonitorInfos()

	$slider_pos = WinGetPos($formSlider)
	$formWidth = 0

;~ 	subtraction width of form
	If ($hide = 0) Then
		$formWidth = $SliderWidthOpen
	ElseIf ($hide = 1) Then
		$formWidth = $SliderWidthClose
	EndIf

	For $i = 0 To UBound($screenSettingsArray) - 1 Step +1
		If ($screenSettingsArray[$i][0] < $slider_pos[0] + getHalfSliderWidth() And $slider_pos[0] - getHalfSliderWidth() < ($screenSettingsArray[$i][2] - $formWidth) And $slider_pos[0]) Then
			Dim $screenSettings[3]
			$screenSettings[0] = $screenSettingsArray[$i][0]
			$screenSettings[1] = $screenSettingsArray[$i][1]
			$screenSettings[2] = $screenSettingsArray[$i][2]
			Return $screenSettings
		EndIf
	Next

;~ @TODO: Slider is outside of the screen. Set back into the visble position.

	Return -1
EndFunc   ;==>dedectScreen

#cs------------------------------------------------
	;~ Returns the half slider width.
	;~ Considering if slider opened or closed
#ce------------------------------------------------
Func getHalfSliderWidth()
	If ($hide = 0) Then
		Return ($SliderWidthOpen / 2) ;when slider open
	Else
		Return ($SliderWidthClose / 2) ;when slider close
	EndIf

	Return -1
EndFunc   ;==>getHalfSliderWidth

Func SliderShow()
	$minusPos = 0;
	If ($side = "right") Then $minusPos = $SliderWidthOpen - $SliderBtnWidth ;(big - small)
	$slider_pos = WinGetPos($formSlider)
	WinMove($formSlider, "", $slider_pos[0] - $minusPos, $slider_pos[1], $SliderWidthOpen, $SliderHeight);Größe ändern
	$hide = 0
	setArrow()
EndFunc   ;==>SliderShow

Func SliderHide()
	$plusPos = 0;
	If ($side = "right") Then $plusPos = $SliderWidthOpen - $SliderBtnWidth ;(big - small)
	$slider_pos = WinGetPos($formSlider)
	WinMove($formSlider, "", $slider_pos[0] + $plusPos, $slider_pos[1], $SliderWidthClose, $SliderHeight);Größe ändern
	$hide = 1
	setArrow()
EndFunc   ;==>SliderHide

#cs------------------------------------------------
	;~ Switch the side of the slider.
	;~ Move the Open/Hide Button.
	;~ Set the correct arrow
#ce------------------------------------------------
Func SideSwitch()
	If $side = "left" Then
		$side = "right"
	Else
		$side = "left"
	EndIf
	setSliderButton()
EndFunc   ;==>SideSwitch

Func setSliderButton()
	If $side = "right" Then
		If ($hide = 0) Then
			GUICtrlSetPos($sliderBTNhs, 1, $SliderBtnY)
		Else
			GUICtrlSetPos($sliderBTNhs, $SliderWidthClose - $SliderBtnWidth, $SliderBtnY)
		EndIf

	Else
		If ($hide = 0) Then
			GUICtrlSetPos($sliderBTNhs, $SliderWidthOpen - $SliderBtnWidth, $SliderBtnY)
		Else
			GUICtrlSetPos($sliderBTNhs, $SliderWidthClose - $SliderBtnWidth, $SliderBtnY)
		EndIf
	EndIf
	setArrow()
EndFunc   ;==>setSliderButton

#cs------------------------------------------------
	;~ Sets the correct arrow for the slider button
	;~ Considering if slider opened or closed and
	;~ if slider is on the left or right screen side
#ce------------------------------------------------
Func setArrow()
	If ($hide = 0) Then
		If ($side = "left") Then
			GUICtrlSetData($sliderBTNhs, "<") ;~ when slider opened and left
		Else
			GUICtrlSetData($sliderBTNhs, ">") ;~ when slider opened and right
		EndIf
	Else
		If ($side = "left") Then
			GUICtrlSetData($sliderBTNhs, ">") ;~ when slider closed and left
		Else
			GUICtrlSetData($sliderBTNhs, "<") ;~ when slider closed and right
		EndIf
	EndIf
EndFunc   ;==>setArrow


#cs------------------------------------------------
	;~ This function returns an Array with screen informations.
	;~ @return array with monitor informations
	;~ EXAMPLE ARRAY:
	;~  Array[0][0] = monitor 1: screen begin pixel position
	;~	Array[0][1] = monitor 1: width number of  pixel
	;~	Array[0][2] = monitor 1: screen end pixel position
	;~	Array[1][0] = monitor 2: screen begin pixel position
	;~ .................................
#ce------------------------------------------------
Func getMonitorInfos()

	Dim $MonitorPos[1][1]
	$dev = 0
	$id = 0
	$dll = DllOpen("user32.dll")

	Dim $dd = DllStructCreate("int;char[32];char[128];int;char[128];char[128]")
	DllStructSetData($dd, 1, DllStructGetSize($dd))

	Dim $dm = DllStructCreate("byte[32];short;short;short;short;int;int[2];int;int;short;short;short;short;short;byte[32];short;ushort;int;int;int;int")
	DllStructSetData($dm, 4, DllStructGetSize($dm))

	Do
		$EnumDisplays = DllCall("user32.dll", "int", "EnumDisplayDevices", "ptr", "NULL", "int", $dev, "ptr", DllStructGetPtr($dd), "int", 0)
		$StateFlag = Number(StringMid(Hex(DllStructGetData($dd, 4)), 3))
		If ($StateFlag <> 0x00000008) And ($StateFlag <> 0) Then;ignore virtual mirror displays
			ReDim $MonitorPos[$id + 1][3]
			$EnumDisplaysEx = DllCall($dll, "int", "EnumDisplaySettings", "str", DllStructGetData($dd, 2), "int", -1, "ptr", DllStructGetPtr($dm))

			$MonitorPos[$id][0] = DllStructGetData($dm, 7, 1) ;begin
			$MonitorPos[$id][1] = DllStructGetData($dm, 18) ; width
			$MonitorPos[$id][2] = $MonitorPos[$id][0] + $MonitorPos[$id][1] ;end

			$id += 1
		EndIf
		$dev += 1

	Until $EnumDisplays[0] = 0
	DllClose($dll)

	Return $MonitorPos
EndFunc   ;==>getMonitorInfos
