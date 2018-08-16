#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Avatars\Ding-A-Ling 64.ico
#AutoIt3Wrapper_Outfile=..\..\..\..\Portable\Ding-Press\Ding-Press.exe
#AutoIt3Wrapper_Outfile_x64=..\..\..\..\Portable\Ding-Press 64\Ding-Press.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf /sv /mi=10 /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("MustDeclareVars", 1)

Local $f, $ini = "ini.txt", $hide = IniRead($ini, "ini", "hide_7-zip_window", "no")

If $CmdLine[0] Then
	$f = $CmdLine[1]
	If Compressed($f) Then
		Decompress($f, BDir($f), "", $hide)
	Else
		Compress("a", $f & ".7z", $f, 9, "", $hide)
	EndIf
	Exit
EndIf

#include <Misc.au3>
_Singleton(@ScriptName)
#include <GUIConstantsEx.au3>
#include <TrayConstants.au3>
#include <WindowsConstants.au3>
#include <Crypt.au3>
Opt("TrayAutoPause", 0)
Opt("GUIEventOptions", 1)

Local $open_h = TrayCreateItem("Open"), $sd = @ScriptDir
Local $lb[] = ["Compression", "Password", "Archive", "File/Folder", "Output-Folder"], $num1 = UBound($lb), $zv = ["Add", "Update"]
Local $sv[$num1 + 3], $v, $nv, $btn[][] = [["Open", 108, 53, 46, 22], ["File", 161, 53, 46, 22], ["No.", 214, 53, 46, 22], ["Clear", 268, 53, 36, 22], ["Extract", 313, 78, 46, 24], [$zv[IniRead($ini, "ini", "Update", "Update")], 108, 107, 46, 22], ["File", 161, 107, 46, 22], ["Folder", 214, 107, 46, 22], ["Clear", 268, 107, 36, 22], [$zv[IniRead($ini, "ini", "Update", "Update")], 313, 132, 46, 24], ["Folder", 214, 161, 46, 22], ["Clear", 268, 161, 36, 22], ["Open", 313, 186, 46, 24]]
Local $mi = ["Ini", "Restart", "License", "Read Me"], $num3 = UBound($mi)
Local $num2 = UBound($btn), $inp_h[$num1 + $num2 + $num3], $a[4], $archive, $bd, $file, $i, $j, $msg, $p, $hash

For $i = 0 To $num1 + 2
	If $i < $num1 Then
		$sv[$i] = IniRead($ini, "ini", $lb[$i], "")
	ElseIf $i = $num1 Then
		$sv[$i] = IniRead($ini, "ini", "Update", "Update")
	Else
		$sv[$i] = IniRead($ini, "ini", "pos" & ($i - $num1 - 1), 0)
	EndIf
Next

Local $g_h = GUICreate("Ding-Press v" & IniRead($ini, "ini", "version", "?.??"), 368, 239, IniRead($ini, "ini", "pos0", -1), IniRead($ini, "ini", "pos1", 0), -1, $WS_EX_ACCEPTFILES + $WS_EX_TOPMOST)
GUISetFont(10)

Local $m_h = GUICtrlCreateMenu("Menu")

Local $w = 42, $ul[] = [9, Min(IniRead($ini, "ini", "number_of_passwords", 10), 100) - 1], $a[4], $bd, $j, $p
For $i = 0 To $num1 - 1
	GUICtrlCreateLabel($lb[$i], 10 + ($i = 1) * 99, 6 + ($i > 1) * ($i - 1) * 54, StringLen($lb[$i]) * 7, 20)
	$inp_h[$i] = GUICtrlCreateInput(IniRead($ini, "ini", $lb[$i], ""), 10 + ($i = 1) * 99, 25 + ($i > 1) * ($i - 1) * 54, $w, 22)
	If $i < 2 Then
		GUICtrlSetLimit(GUICtrlCreateUpdown($inp_h[$i]), $ul[$i], 1 - $i)
	Else
		GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	EndIf
	If $i = 1 Then $w = 294
Next

For $i = 0 To $num2 - 1
	$inp_h[$num1 + $i] = GUICtrlCreateButton($btn[$i][0], $btn[$i][1], $btn[$i][2], $btn[$i][3], $btn[$i][4])
Next
For $i = 0 To $num3 - 1
	$inp_h[$num1 + $num2 + $i] = GUICtrlCreateMenuitem($mi[$i], $m_h)
Next

GUISetState()

Do
	$msg = GUIGetMsg()
	Switch $msg
		Case $inp_h[$num1]
			$v = GUICtrlRead($inp_h[2])
			$bd = BDir($v)
			If FileExists($bd) Then Run('explorer "' & $bd & '"')
		Case $inp_h[$num1 + 1]
			$v = FileOpenDialog("Archive", $sd, "7zip (*.7z)")
			GUICtrlSetData($inp_h[2], $v)
		Case $inp_h[$num1 + 2]
			$v = GUICtrlRead($inp_h[2])
			If FileExists($v) And StringRight($v, 3) = ".7z" Then
				$p = GUICtrlRead($inp_h[1])
				$j = StringInStr(StringLeft(StringRight($v, 8), 4), "-pw", 2)
				If $j Then
					$nv = StringLeft($v, StringLen($v) - 6 + $j) & $p & ".7z"
				Else
					$nv = StringTrimRight($v, 3) & "-pw" & $p & ".7z"
				EndIf
				If FileMove($v, $nv, 1) Then
					$v = $nv
					GUICtrlSetData($inp_h[2], $v)
				EndIf
			EndIf
		Case $inp_h[$num1 + 3]
			$v = ""
			GUICtrlSetData($inp_h[2], $v)
		Case $inp_h[$num1 + 4]
			$archive = GUICtrlRead($inp_h[2])
			If Compressed($archive) And FileExists($archive) Then
				Decompress($archive, OutputDir($inp_h[4], $archive), Password($ini, $inp_h[1]), $hide)
			Else
				EMsg(1)
			EndIf
		Case $inp_h[$num1 + 5]
			$v = GUICtrlRead($inp_h[$num1 + 5])
			If $v = "Add" Then
				$v = 1
			Else
				$v = 0
			EndIf
			GUICtrlSetData($inp_h[$num1 + 5], $zv[$v])
			GUICtrlSetData($inp_h[$num1 + 9], $zv[$v])
			$sv[$num1] = $v
			IniWrite($ini, "ini", "Update", " " & $v)
		Case $inp_h[$num1 + 6]
			$v = FileOpenDialog("File", $sd, "All (*.*)")
			FileChangeDir($sd)
			GUICtrlSetData($inp_h[3], $v)
		Case $inp_h[$num1 + 7]
			$v = FileSelectFolder("Folder", $sd)
			GUICtrlSetData($inp_h[3], $v)
		Case $inp_h[$num1 + 8]
			$v = ""
			GUICtrlSetData($inp_h[3], $v)
		Case $inp_h[$num1 + 9]
			$v = GUICtrlRead($inp_h[2])
			$file = GUICtrlRead($inp_h[3])
			If $file <> "" And FileExists($file) And StringRight($file, 3) <> ".7z" Then
				If $v <> "" Then
					$archive = $v
					If StringRight($archive, 3) <> ".7z" Then $archive = $archive & ".7z"
					$bd = BDir($archive)
					If Not FileExists($bd) Then DirCreate($bd)
				Else
					$archive = OutputDir($inp_h[4], $file) & FName($file) & ".7z"
				EndIf
				If FileExists($archive) Then
					$hash = _Crypt_HashFile($archive, $CALG_SHA1)
				Else
					$hash = "none"
				EndIf
				Compress(StringLower(StringLeft(GUICtrlRead($inp_h[$num1 + 5]), 1)), $archive, $file, GUICtrlRead($inp_h[0]), Password($ini, $inp_h[1]), $hide)
				If FileExists($archive) Then
					If $v <> $archive Then GUICtrlSetData($inp_h[2], $archive)
					If $hash <> "none" And $hash = _Crypt_HashFile($archive, $CALG_SHA1) Then EMsg(0)
				Else
					GUICtrlSetData($inp_h[2], "")
					EMsg(1)
				EndIf
			Else
				EMsg(1)
			EndIf
		Case $inp_h[$num1 + 10]
			$v = FileSelectFolder("Folder", $sd)
			GUICtrlSetData($inp_h[4], $v)
		Case $inp_h[$num1 + 11]
			$v = ""
			GUICtrlSetData($inp_h[4], $v)
		Case $inp_h[$num1 + 12]
			$v = GUICtrlRead($inp_h[4])
			If Not FileExists($v) Then DirCreate($v)
			Run("explorer " & $v)
		Case $inp_h[$num1 + $num2]
			ShellExecute($ini)
		Case $inp_h[$num1 + $num2 + 1]
			Run('"Restart ' & StringTrimRight(@ScriptName, 4) & '" "' & @ScriptName & '"')
			Exit
		Case $inp_h[$num1 + $num2 + 2]
			ShellExecute("License.txt")
		Case $inp_h[$num1 + $num2 + 3]
			ShellExecute("Read Me.txt")
		Case $GUI_EVENT_MINIMIZE
			GUISetState(@SW_HIDE)
            TraySetState($TRAY_ICONSTATE_SHOW)
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch

	If @WorkingDir <> $sd Then FileChangeDir($sd)

	$a = WinGetPos($g_h)
	For $i = 0 To $num1 + 2
		If $i = $num1 Then ContinueLoop
		Select
			Case $i < $num1
				$v = GUICtrlRead($inp_h[$i])
				If $sv[$i] <> $v Then
					IniWrite($ini, "ini", $lb[$i], " " & $v)
					$sv[$i] = $v
					ExitLoop
				EndIf
			Case Else
				$j = $i - $num1 - 1
				If $sv[$i] <> $a[$j] Then
					IniWrite($ini, "ini", "pos" & $j, " " & $a[$j])
					$sv[$i] = $a[$j]
				EndIf
		EndSelect
	Next

	If TrayGetMsg() = $open_h Then
		TrayItemSetState($open_h, $TRAY_UNCHECKED)
		GUISetState()
		TraySetState($TRAY_ICONSTATE_HIDE)
	EndIf
Until 0

Func FName($file)
	If StringRight($file, 1) = "\" Then $file = StringTrimRight($file, 1)
	Return StringTrimLeft($file, StringInStr($file, "\", 2, -1))
EndFunc

Func BDir($file)
	If StringRight($file, 1) = "\" And StringRight($file, 2) <> ":\" Then $file = StringTrimRight($f, 1)
	Return StringLeft($file, StringInStr($file, "\", 2, -1))
EndFunc

Func Is_Dir(ByRef $file)
	If StringInStr(FileGetAttrib($file), "D") Then
		If StringRight($file, 1) <> "\" Then $file = $file & "\"
		Return True
	Else
		Return False
	EndIf
EndFunc

Func Compressed(Const $fn)
	Local $cf[] = [".7z", ".rar", ".zip"], $c = False, $n = UBound($cf) - 1
	For $i = 0 To $n
		If StringRight($fn, StringLen($cf[$i])) = $cf[$i] Then
			$c = True
			ExitLoop
		EndIf
	Next
	Return $c
EndFunc

Func Decompress($archive, $output_dir, $pw, $hide)
	Local $output = $output_dir & StringLeft(FName($archive), StringInStr(FName($archive), ".", 2, -1) - 1)
	If FileExists($output) Then $output = $output & "•"
	Local $cl = ' x "' & $archive & '" -o"' & $output & '" -aoa -p"' & $pw & '"'
	RunW('7z\7z' & $cl, $hide)
	If DirGetSize($output, 3)[1] + DirGetSize($output, 3)[2] = 1 Then
		Local $output0 = $output, $i = 0, $f_h, $f, $nf
		$output = $output & "•"
		DirMove($output0, $output)
		Do
			$f_h = FileFindFirstFile($output & "\*.*")
			If $i Then Sleep(20)
			$i = $i + 1
		Until $f_h <> -1 Or $i = 20
		If $f_h <> -1 Then
			$f = FileFindNextFile($f_h)
			$nf = $output_dir & $f
			If FileExists($nf) Then
				$nf = $output_dir & "•" & $f
			EndIf
			$f = $output & "\" & $f
			If Is_Dir($f) Then
				DirMove($f, $nf, 1)
			Else
				FileMove($f, $nf, 1)
			EndIf
			DirRemove($output)
		EndIf
		FileClose($f_h)
	EndIf
	If $hide = "yes" Then Folder_Open(0, $output_dir)
EndFunc

Func Compress($zv, $archive, $file, $cl, $pw, $hide)
	Local $sec = "", $c = $cl - 1, $d[][] = [[8, 12, 16, 24, 32, 48, 64, 96, 128], [16, 24, 32, 48, 64, 96, 128, 192, 256]], $w[][] = [[24, 32, 48, 64, 96, 128, 192, 256, 273], [8, 10, 12, 14, 16, 20, 24, 28, 32]]
	If $pw <> "" then $sec = '-mhe -p"' & $pw & '"'
	Local $cmp_cl[] = ['-m0=LZMA2 -myx9 -md=' & $d[0][$c] & 'm -mfb=' & $w[0][$c] & ' -mx' & $cl, '-m0=PPMd -mmem=' & $d[1][$c] & 'm -mo=' & $w[1][$c] & ' -mx' & $cl]

	If Is_Dir($file) Then
		RunW('7z/7z ' & $zv & ' "' & $archive & '" "' & $file & '*" -x!*.txt -r ' & $cmp_cl[0] & ' ' & $sec, $hide)
		RunW('7z/7z ' & $zv & ' "' & $archive & '" "' & $file & '*.txt" -r ' & $cmp_cl[1] & ' ' & $sec, $hide)
	Else
		If StringRight($file, 4) = ".txt" Then
			RunW('7z/7z ' & $zv & ' "' & $archive & '" "' & $file & '" ' & $cmp_cl[1] & ' ' & $sec, $hide)
		Else
			RunW('7z/7z ' & $zv & ' "' & $archive & '" "' & $file & '" ' & $cmp_cl[0] & ' ' & $sec, $hide)
		EndIf
	EndIf
	If $hide = "yes" Then Folder_Open(1, $archive)
EndFunc

Func Password($ini, $pw_h)
	Return IniRead($ini, "ini", "password" & GUICtrlRead($pw_h), "")
EndFunc

Func OutputDir($od_h, $file)
	Local $output_dir = GUICtrlRead($od_h)
	If $output_dir = "" Then $output_dir = BDir($file)
	If Not FileExists($output_dir) Then DirCreate($output_dir)
	Return Add_Slash($output_dir)
EndFunc

Func Add_Slash($f)
	If StringRight($f, 1) <> "\" Then
		Return $f & "\"
	Else
		Return $f
	EndIf
EndFunc

Func Min($a, $b)
	If $a < $b Then
		Return $a
	Else
		Return $b
	EndIf
EndFunc

Func EMsg($e)
	Local $em[] = ["Possible error: SHA1-hashing suggests that the archive is unchanged.", "Error!"]
	MsgBox($MB_TOPMOST, "", $em[$e], 10)
EndFunc

Func RunW($prg, $hide)
	If $hide = "yes" Then
		RunWait($prg, "", @SW_HIDE)
	Else
		RunWait($prg)
	EndIf
EndFunc

Func Folder_Open($bd, $dir)
	local $fn
	If $bd Then	$dir = BDir($dir)
	$fn = FName($dir)
	If Not WinExists($fn) Then Run('explorer "' & $dir & '"')
	If Not WinActive($fn) Then WinActivate($fn)
EndFunc
