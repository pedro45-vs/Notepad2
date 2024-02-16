/************************************************************************
 * @description Extrai o RegEx pesquisado e abre outra instância do 
 * Notepad2 com os dados
 * @author Pedro Henrique C. Xavier
 * @date 2024-02-15
 * @version 2.1-alpha.8
 ***********************************************************************/

#Requires AutoHotkey v2.0
#Include ..\ScintillaLite.ahk

TraySetIcon(EnvGet('LocalAppData') '\Notepad2\Notepad2.exe')
np2_hwnd := EnvGet('np2_hwnd')

GuiP := Gui('-MinimizeBox', 'RegEx Extractor')
GuiP.Opt('+Owner' np2_hwnd)
GuiP.OnEvent('Close', (*) => ExitApp())
GuiP.OnEvent('Escape', (*) => ExitApp())
GuiP.SetFont('s10', 'Segoe UI')
GuiP.AddText(, 'Pesquisar')
GuiP.SetFont(, 'Consolas')
GuiP.SetFont(, 'JetBrains Mono')
GuiP.AddEdit('vRegEx w360')
GuiP.SetFont(, 'Segoe UI')
GuiP.AddText(, 'Grupo (opcional)')
GuiP.SetFont(, 'Consolas')
GuiP.SetFont(, 'JetBrains Mono')
GuiP.AddEdit('vgroup w360')
GuiP.SetFont(, 'Segoe UI')
GuiP.AddButton('w110 default', 'Extrair').OnEvent('Click', Extract)
GuiP.Show()

Extract(*)
{
    sci := Scintilla(ControlGetHwnd('Scintilla1', 'ahk_id' np2_hwnd))
    text := sci.GetText()
    needle := GuiP['RegEx'].text
    group := GuiP['group'].text
    for match in RegExMatchAll(text, needle)
        lista .= Match[group ? group : 0] '`n'

    if lista
    {
        Run(EnvGet('LocalAppData') '\Notepad2\Notepad2.exe',,, &PID)
        WinWaitActive('ahk_pid' PID,, 2)
        sci := Scintilla(ControlGetHwnd('Scintilla1', 'ahk_pid' PID))
        sci.SetText(lista)        
    }
}

/**
 * Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
 * @param haystack The string whose content is searched.
 * @param needleRegEx The RegEx pattern to search for.
 * @param startingPosition If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
 * @returns {Array}
 */
RegExMatchAll(haystack, needleRegEx, startingPosition := 1)
{
	reg := []
	While startingPosition := RegExMatch(haystack, needleRegEx, &outputVar, startingPosition)
    {
		reg.Push(outputVar)
        startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
	}
	return reg
}