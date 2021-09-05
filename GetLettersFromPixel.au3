#include <_PixelGetColor.au3>

;Set Opt PixelCoordMode and MouseCoordMode equal to 0
Opt("PixelCoordMode",0)
Opt("MouseCoordMode",0)

;Open DLL gdi32.dll
$hDll = DllOpen("gdi32.dll")

;Creates a DC for use with the other _PixelGetColor functions.
$vDC = _PixelGetColor_CreateDC($hDll)

; Set Letras file config
$FileLetras = @ScriptDir & "\Letras.ini"

;Wait Window Bloco de notas
$handle = WinActivate(WinWait("*Sem título - Bloco de Notas","",5),"")

;Select Color Search hex and decimal
$ColorSearch = "0078D7"
$ColorSearchD = 30935

;Get Point Initial
$aPInicial = PixelSearch(0,0,1550, 838,$ColorSearchD,0,1,$handle)

;Captures the user defined region and reads it to a memory DC.
$vRegion = _PixelGetColor_CaptureRegion($vDC, -8, -8, @DesktopWidth, @DesktopHeight, False, $hDll)

;Get Point X and Y
$x = $aPInicial[0]
$y = $aPInicial[1]

;Get Width
$contador=$x
while(_PixelGetColor_GetPixel($vDC,$contador, $y, $hDll)=$ColorSearch)
	MouseMove($contador, $y,1)
	$contador = $contador + 1
wend
$xFinal = $contador

;Get Height
$contador=$y
while(_PixelGetColor_GetPixel($vDC,$xFinal-1, $contador, $hDll)=$ColorSearch)
	MouseMove($xFinal-1, $contador,1)
	$contador = $contador + 1
WEnd
$yFinal = $contador

$sScreen = ""
$contJ = 0
$contI = 0
$contEspace = 0
$divisor = ""
$coluna = ""
$charLetras = ""
$FlagInicio = True
local $result[11]

;Get pixel color to String binary
For $j = $x To $xFinal Step 1

	For $i = $y To $yFinal Step 1

		ToolTip("Lendo: " & $j & "/" & $i & " de " & $xFinal & "/" & $yFinal )

		; If Color is equal to variable ColorSearch
		if(_PixelGetColor_GetPixel($vDC,$j,$i, $hDll)=$ColorSearch) then
			;Append 0
			$coluna = $coluna & "0"

		else
			;Append 1
			$coluna = $coluna & "1"

		endif
		;Increment
		$contI = $contI + 1

	next

	;Get default spaces beteween letters
	if($contJ=0) Then
		$sSpace = StringReplace($coluna,"1","")
	endif

	;if 'coluna' have spaces and ScreenCapture is bigger than 1
	if (StringInStr($coluna,$sSpace)>0 And UBound(StringSplit($sScreen, @CRLF,2))>1) then

		;Read text file FileLetras
		$valueLetras = FileRead($FileLetras)

		;If don´t Exists in text file
		if(StringInStr($valueLetras,StringReplace($sScreen,@CRLF,""))=0) then

			; Ask what is the letter? If you don't answer don't do anything...
			$Letra = InputBox("Digita Qual é a letra?",$sScreen,Default,"",600,600)
			if not($Letra = "") then
				; Write in file config
				IniWrite($FileLetras,StringReplace($sScreen,@CRLF,""),"value",$Letra)
			endif

		Else
			; Get Letter and Write Console
			$StringLetter = IniRead($FileLetras,StringReplace($sScreen,@CRLF,""),"value",default)
;~ 			ConsoleWrite($StringLetter & @CRLF)
			_ArrayAdd($result,$StringLetter)
		endif

		;Clean Variable
		$sScreen = ""
	;Else If don´t exists spaces in 'coluna'
	Elseif (StringInStr($coluna,$sSpace)=0) then
		; Append String
		$sScreen = $sScreen & $coluna & @CRLF

	;Else If exists spaces in 'coluna'
	Elseif (StringInStr($coluna,$sSpace)>0 ) then
		;Clean Variable
		$sScreen = ""
	endif

	;Clean Variable
	$coluna=""

;Go Next
Next
MsgBox("","Resultado",StringReplace(_ArrayToString($result),"|",""))