#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=..\..\..\..\Portable\Ding-Press\Restart Ding-Press.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf /sv /mi=10 /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Misc.au3>
_Singleton(@ScriptName)
Opt("TrayMenuMode", 1)

If $CmdLine[0] Then
	$p = $CmdLine[1]
	ProcessWaitClose($p, 2.5)
	If ProcessExists($p) Then Error_Msg()
	Run($p)
	ProcessWait($p, 2.5)
	If Not ProcessExists($p) Then Error_Msg()
Else
	Error_Msg()
EndIf

Func Error_Msg()
	MsgBox(0, "", "ERROR!", 2)
	Exit
EndFunc
