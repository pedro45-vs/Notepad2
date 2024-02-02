#Requires AutoHotkey v2.1-
#SingleInstance
#Include ScintillaLite.ahk
#Include ..\Lib\Calcular.ahk
#Include ..\Lib\Numlib.ahk
#Include ..\Lib\StringLib.ahk
#include ..\Lib\Valida.ahk

TraySetIcon(EnvGet('LocalAppData') '\Notepad2\Notepad2.exe')
A_TrayMenu.Default := '&Edit Script'

; Carrega os Calltips globais
CallTips := Map(), CallTips.CaseSense := 'Off'
CalltipParser(FileRead('src\autoHotkey.api', 'UTF-8'))

; Monitora a janela do Notepad2 para carregar a lib Scintilla
; Para iniciar a classe é preciso passar o hwnd do controle
SetTimer(MonitorHwndScintilla, 250)
MonitorHwndScintilla()
{
    global sci
    static prev_hwnd := 0
    if prev_hwnd = (np2_hwnd := WinActive('ahk_exe Notepad2.exe ahk_class Notepad2'))
        return
    else
    {
        prev_hwnd := np2_hwnd
        WinActive(np2_hwnd) || Exit() 
        sci := Scintilla(ControlGetHwnd('Scintilla1', np2_hwnd))
        sci.CallTipSetPosition(1), sci.CallTipSetForeHlt(0xFF0000)
    }
}


; Cria sub-menu com os scriptlets contidos na pasta
submenu := Menu()
loop files 'ScriptLets\*.scriptlet'
    submenu.Add(StrReplace(A_LoopFileName, '.scriptlet'), MenuHandler)

MenuHandler(item_name, ItemPos, MyMenu) => sci.AddText(FileRead('ScriptLets\' item_name '.scriptlet', 'UTF-8'))

mcontext := Menu()
mcontext.Add('&Remover aspas e parênteses', (*) => RemoveAspPar())
mcontext.Add('&Limpar espaços à direita', (*) => MenuSelect('ahk_exe Notepad2.exe', , '2&', '15&', '8&'))
mcontext.Add('&Abrir pasta do arquivo', (*) => MenuSelect('ahk_exe Notepad2.exe', , '1&', '19&'))
mcontext.Add()
mcontext.Add('&MsgBox Creator', MsgBoxCreator)
mcontext.Add('&Formatar CNPJ', (*) => formatarCNPJ())
mcontext.Add('&Executar código selecionado', (*)=> ExecutarSelecao())
mcontext.Add()
mcontext.Add('&Scriplets', submenu)

; Analisa a string em busca de definições de classes e funções
CalltipParser(str)
{
    str := LimparComentarios(str)
    while pos_abertura := RegExMatch(str, 'class \w+', &re, pos_abertura ?? 1)
    {
        occ := 0
        loop
        {
            pos_fechamento := InStr(str, '}',, pos_abertura, ++occ)
            range := SubStr(str, pos_abertura, pos_fechamento +1 - pos_abertura)

            StrReplace(range, '{',,, &count_abertura)
            StrReplace(range, '}',,, &count_fechamento)
        }
        until (count_abertura = count_fechamento)
        CalltipFunctionParser(range, re[0] '`n')

        str := StrReplace(str, range, Format('{: ' StrLen(range) '}', ' '))
        pos_abertura := pos_fechamento
    }
    CalltipFunctionParser(str)
}

; Inclui as definições da função presentes na string passada
CalltipFunctionParser(str, pref := '')
{
    global CallTips
    while pos := RegExMatch(str, 'm)^[\t ]*(?<funct>\w++)(?<params>\(.*?\))(?=(\s*{|\s*=>))', &re, pos ?? 1)
    {
        CallTips.has(re.funct)
        ? CallTips[re.funct].push(pref . re.funct . re.params)
        : CallTips[re.funct] := [pref . re.funct . re.params]
        pos += re.len
        list .= re.funct '()`n'
    }
}

; Limpa os comentários para não interferir com o RegEx
LimparComentarios(str)
{
    ; Limpa os comentários precedidos de ';'
    while RegExMatch(str, 'm);.*', &re)
        str := StrReplace(str, re[0], Format('{: ' re.len '}', ' '))

    ; Limpa os comentários entre /* e */
    while RegExMatch(str, '\/\*[\S\s]*?\*\/', &re)
        str := StrReplace(str, re[0], Format('{: ' re.len '}', ' '))

    ; Limpa os comentários com abertura /* até o fim do arquivo
    while RegExMatch(str, '\/\*[\S\s]*', &re)
        str := StrReplace(str, re[0], Format('{: ' re.len '}', ' '))

    return str
}

; Mostra o calltip para a palavra presente no map CallTips
ShowCalltip()
{
    static opt := 0
    sci.CallTipActive() || (opt := 0)
    col := sci.GetColumn(pos := sci.GetCurrentPos()) +1
    line := sci.GetCurLine()

    ; Remove os parênteses e vírgulas dentro de strings literais
    ; para não interferir com o regex de subfunções
    if RegExMatch(line, '[\x22\x27][^\x22\x27]+[\x22\x27]', &re)
    {
        sanitizar := RegExReplace(re[0], '[(),]', ' ')
        line := StrReplace(line, re[0], sanitizar)
    }
    word := '', param := 0
    ; Busca as subfunções até que a posição do caret esteja entre o início e o fim
    while pos_re := RegExMatch(line, '(\w+)\x28([^\x28\x29]*)\x29', &re)
    {
        if IsBetween(col, pos_re, pos_re + re.len -1)
        {
            word := StrLower(re[1])
            subtext := SubStr(line, pos_re, col - pos_re)
            StrReplace(subtext, ',' ,,, &commas)
            break
        }
        else
            line := StrReplace(line, re[0], Format('{:' re.len '}', ''))
    }
    CallTips.has(word) || Exit()
    (++opt > CallTips[word].Length) && opt := 1

    ; Divide os parâmentros da função e determina a posição inicial e final
    ; para colorir o parâmetro corrrespondente
    start := InStr(CallTips[word][opt], '(')
    end   := InStr(CallTips[word][opt], ',')
    loop commas
    {
        start := InStr(CallTips[word][opt], ',',,, A_Index)
        end   := InStr(CallTips[word][opt], ',',,, A_Index + 1)
    }
    (end = 0) && end := InStr(CallTips[word][opt], ')') - 1

    sci.CallTipShow(pos, CallTips[word][opt])
    sci.CallTipSetHlt(start, end)
}

; Remove parênteses e aspas da seleção
RemoveAspPar()
{
    if RegExMatch(sci.GetSelText(), 's)^[\x22\x27()](.*)[\x22\x27()]$', &Rem)
        sci.ReplaceSel(Rem[1])
}

; Abre script para criar MsgBox
MsgBoxCreator(*)
{
    EnvSet('np2_hwnd', WinActive('ahk_exe Notepad2.exe'))
    Run('Plugins\MsgBoxCreator.ahk')
}

; Abre o arquivo de ajuda do script na função selecionada
AbrirAjuda(*)
{
    pos := sci.GetCurrentPos() - 1
    word := sci.CurrentWord(pos)
    WinExist('AutoHotkey v2 Help ahk_class HH Parent') && WinClose()
    CallTips.has(word)
        ? Run('hh mk:@MSITStore:C:\Program%20Files\AutoHotkey\v2\AutoHotkey.chm::/docs/lib/' word '.htm')
        : Run('C:\Program Files\AutoHotkey\v2\AutoHotkey.chm')
}

formatarCNPJ()
{
    if validaCNPJ(sci.GetSelText(), , &form)
        sci.ReplaceSel(form)
}

ExecutarSelecao()
{
    shell := ComObject('WScript.Shell')
    exec := shell.Exec('AutoHotkey.exe *')
    exec.StdIn.Write(sci.GetSelText())
    exec.StdIn.Close()
}

#HotIf WinActive('ahk_exe Notepad2.exe')

F1::ShowCalltip()
F5::MenuSelect('ahk_exe Notepad2.exe', , '6&', '9&')
F11::AbrirAjuda()
!r::RemoveAspPar()

; Calcula a seleção como expressão e adiciona o resultado
^!c::
{
    if not expr := sci.GetSelText()
        expr := sci.GetCurLine()

    pos := ( sci.GetCurrentPos() < sci.GetAnchor() ) ? sci.GetAnchor() : sci.GetCurrentPos()
    sci.InsertText(pos, ' = ' calcular(expr))
}

AppsKey::
{
    mcontext.show(,, 0)
    WinActivate('ahk_class #32768')
}

RButton::
{
    if not KeyWait('RButton', 'T0.5')
        mcontext.show(,, 0), WinActivate('ahk_class #32768')
    else
        Send('{RButton}')
}