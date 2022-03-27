#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
; #AutoIt3Wrapper_Icon=ap.ico
#AutoIt3Wrapper_Outfile_x64=AccountPal.exe
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=n
#AutoIt3Wrapper_Res_LegalCopyright=(c) 2016 Mike Kovacic
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("RunErrorsFatal", 0)
#include <ad.au3>
global $splash = GUICreate("Please Wait...", 200, 100, -1, -1, 0x00400000)
GUICtrlCreateLabel("Getting Details for: " & @LogonDomain & "\" & @Username, 5, 25, 190, 90 / 2)
	GUISetState(@SW_SHOW, $splash)
_ad_open()
if @Error then
MsgBox(16,"Error","This application could not access your account details. Your account may be locked out, or you may have used the wrong username.")
exit
endif
ShowPWPol()
_ad_Close()
Func ShowPWPol(); WORKS
	$user = @UserName
	$something = _AD_GetObjectProperties($user)
	$Ans = "Unknown"
	For $k = 1 To $something[0][0]
		If $something[$k][0] = "userAccountControl" Then $Ans = $something[$k][1]
	Next
	$isDisabled = "no"
	$islocked = "no"
	$isExpired = "no"
	$isAccExpired = "no"
	If _AD_IsObjectDisabled($user) Then $isDisabled = "YES"
	If _AD_IsObjectLocked($user) Then $islocked = "YES"
	If _AD_IsPasswordExpired($user) Then $isExpired = "YES"
	If _AD_IsAccountExpired($user) Then $isAccExpired = "YES"
	$PWInfo = _AD_GetPasswordInfo($user)
	global $Details = ""
	; $Details = "Domain Password Policy:" & @CRLF
	; $Details &= "  Maximum Password Age (days) : " & $PWInfo[1] & @CRLF
	; $Details &= "  Minimum Password Age (days) : " & $PWInfo[2] & @CRLF
	; $Details &= "  Enforce Password History (# of passwords remembered) : " & $PWInfo[3] & @CRLF
	; $Details &= "  Minimum Password Length : " & $PWInfo[4] & @CRLF
	; $Details &= "  Account Lockout Duration (minutes). : " & $PWInfo[5] & @CRLF
	; $Details &= "  Account Lockout Threshold (invalid logon attempts) : " & $PWInfo[6] & @CRLF
	; $Details &= "  Reset account lockout counter after (minutes) : " & $PWInfo[7] & @CRLF & @CRLF & @CRLF & @CRLF
	$Details &= "Specific password details for " & @LogonDomain & "\" & $user & @CRLF & @CRLF
	$Details &= "  Password last changed : " & _DateTimeFormat($PWInfo[8], 1) & " " & _DateTimeFormat($PWInfo[8], 3) & @CRLF
	$Details &= "  Password expires      : " & _DateTimeFormat($PWInfo[9], 1) & " " & _DateTimeFormat($PWInfo[9], 3) & @CRLF
	
	; $Stuff = _DateTimeFormat($PWInfo[9], 1) & _DateTimeFormat($PWInfo[9], 5) & " -0500"
	; $Stuff = _DateTimeFormat($PWInfo[9], 0)
	; MsgBox(0,"debug",$Stuff)
	; ClipPut($Stuff)

	$days = _DateDiff("D", @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $PWInfo[9])
	$hours = _DateDiff("h", @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $PWInfo[9])
	$minutes = _DateDiff("m", @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $PWInfo[9])
	$seconds = _DateDiff("s", @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $PWInfo[9])
	$iDays = Int($seconds / 86400)
	$iHours = Int(($seconds - ($iDays * 86400)) / 3600)
	$iMinutes = Int((($seconds - ($iDays * 86400)) - ($iHours * 3600)) / 60)
	$iSeconds = Int(((($seconds - ($iDays * 86400)) - ($iHours * 3600) - ($iMinutes * 60)) * 60) / 60)
	$Details &= "  Password is valid for : " & $iDays & " Days, " & $iHours & " Hours, " & $iMinutes & " minutes and " & $iSeconds & " seconds" & @CRLF & @CRLF
	$Details &= "  Is account Disabled   : " & $isDisabled & @CRLF
	$Details &= "  Is account locked     : " & $islocked & @CRLF
	$Details &= "  Is account Expired    : " & $isAccExpired & @CRLF
	$Details &= "  Is password Expired   : " & $isExpired & @CRLF & @CRLF
	; $Details &= "  User Account Details  : " & $Ans & @CRLF & @CRLF
	$Details2 = "To check your account details for a different domain, simply right click on this application and choose 'Run As Different User', then enter the domain, followed by a backslash, followed by your username. (i.e. DOMAIN\jDoe  or  MS\jdoe007)" & @CRLF & @CRLF & "Would you like to copy this to your clipboard?"
	$bz = 50
	GuiDelete($splash)
	Local $PwDetailsBox = GUICreate("AccountPal v1.0", 423, 470 - 150, -1, -1, 0x00400000)
	$Labski = GUICtrlCreateLabel($Details & $Details2, 5, 5, 420, 400 - 150)
	$iMsgBoxAnswerCan = GUICtrlCreateButton("Cancel", 328 - $bz, 408 - 150, 75, 25)
	$iMsgBoxAnswerNo = GUICtrlCreateButton("No", 232      - $bz, 408 - 150, 75, 25)
	$iMsgBoxAnswerYes = GUICtrlCreateButton("Yes", 136    - $bz, 408 - 150, 75, 25)
	GUISetState(@SW_SHOW, $PwDetailsBox)
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case -3, $iMsgBoxAnswerCan, $iMsgBoxAnswerNo
				GUIDelete($PwDetailsBox)
				Return
			Case $iMsgBoxAnswerYes
				ClipPut($Details)
				GUIDelete($PwDetailsBox)
				MsgBox(64, "Copied", "Details have been copied to your clipboard.")
				Return
		EndSwitch
	WEnd
EndFunc   ;==>ShowPWPol



