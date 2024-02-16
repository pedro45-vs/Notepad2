/************************************************************************
 * @description Macros e Plugins para Notepad2
 * @author Pedro Henrique C. Xavier
 * @date 2024-02-16
 * @version 2.1-alpha.8
 ***********************************************************************/

#Requires AutoHotkey v2.1-
#SingleInstance
#Include ScintillaLite.ahk
#Include ..\Lib\Calcular.ahk
#Include ..\Lib\Numlib.ahk
#include ..\Lib\RichEdit.ahk
#include ..\Lib\cJSON.ahk

TraySetIcon(EnvGet('LocalAppData') '\Notepad2\Notepad2.exe')
A_TrayMenu.Default := '&Edit Script'

/**
 * Menu e sub-menus para funções, scriptlets e extensões.
 * O script ScintillaLite.ahk contém os métodos para controle
 * de editores de texto baseado no Scintilla.
 */

; Cria sub-menu com os scriptlets contidos na pasta correspondente
submenu := Menu()
loop files 'ScriptLets\*.scriptlet'
    submenu.Add(StrReplace(A_LoopFileName, '.scriptlet'), MenuHandler)

MenuHandler(item_name, ItemPos, MyMenu) => sci.AddText(FileRead('ScriptLets\' item_name '.scriptlet', 'UTF-8'))

mcontext := Menu()
mcontext.Add('&Remover aspas e parênteses', (*) => RemoveAspPar())
mcontext.Add('&Limpar espaços à direita', (*) => MenuSelect('ahk_exe Notepad2.exe', , '2&', '15&', '8&'))
mcontext.Add('&Abrir pasta do arquivo', (*) => MenuSelect('ahk_exe Notepad2.exe', , '1&', '19&'))
mcontext.Add('Inserir ou atualizar JSDOC', InsertOrUpdateDoc)
mcontext.Add('Formatar CSV', FormatarCSV)
mcontext.Add()
mcontext.Add('&MsgBox Creator', MsgBoxCreator)
mcontext.Add('RegEx E&xtractor', RegExExtractor)
mcontext.Add('&Executar código selecionado', (*)=> ExecutarSelecao())
mcontext.Add()
mcontext.Add('&Scriplets', submenu)

MapDoc := Map(), MapDoc.CaseSense := 0
MapDoc := JSON.Load(FileRead('DocAutohotkey.json', 'UTF-8'))


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
        ;CalltipParser(curr_script := sci.GetText())
        ;for item in IncludeParser(curr_script)
        ;    CalltipParser(FileRead(item, 'UTF-8'))
    }
}

; Analisa a string em busca de definições de classes e funções
CalltipParser(str_script)
{
    str_script := LimparComentarios(str_script)
    while pos_abertura := RegExMatch(str_script, 'class \w+', &re, pos_abertura ?? 1)
    {
        occ := 0
        loop
        {
            pos_fechamento := InStr(str_script, '}',, pos_abertura, ++occ)
            range := SubStr(str_script, pos_abertura, pos_fechamento +1 - pos_abertura)

            StrReplace(range, '{',,, &count_abertura)
            StrReplace(range, '}',,, &count_fechamento)
        }
        until (count_abertura = count_fechamento)
        CalltipFunctionParser(range, re[0] '`n')

        str_script := StrReplace(str_script, range, Format('{: ' StrLen(range) '}', ' '))
        pos_abertura := pos_fechamento
    }
    CalltipFunctionParser(str_script)
}

; Inclui as definições da função presentes no script
CalltipFunctionParser(str_script, pref := '')
{
    global CallTips
    while pos := RegExMatch(str_script, 'm)^[\t ]*(?<funct>\w++)(?<params>\(.*?\))(?=(\s*{|\s*=>))', &re, pos ?? 1)
    {
        CallTips.has(re.funct)
        ? CallTips[re.funct].push(pref . re.funct . re.params)
        : CallTips[re.funct] := [pref . re.funct . re.params]
        pos += re.len
        list .= re.funct '()`n'
    }
}

; Limpa os comentários do script para não interferir com o RegEx
LimparComentarios(str_script)
{
    ; Limpa os comentários precedidos de ';'
    while RegExMatch(str_script, 'm);.*', &re)
        str_script := StrReplace(str_script, re[0], Format('{: ' re.len '}', ' '))

    ; Limpa os comentários entre /* e */
    while RegExMatch(str_script, '\/\*[\S\s]*?\*\/', &re)
        str_script := StrReplace(str_script, re[0], Format('{: ' re.len '}', ' '))

    ; Limpa os comentários com abertura /* até o fim do arquivo
    while RegExMatch(str_script, '\/\*[\S\s]*', &re)
        str_script := StrReplace(str_script, re[0], Format('{: ' re.len '}', ' '))

    return str_script
}

; Retorna uma Array com os nomes de bibliotecas encontrados no script
IncludeParser(str_script)
{
    libname := []
    Loop parse str_script, '`n'
    {
        if RegExMatch(A_LoopField, '#Include(.*)', &re)
        {
            ; Lib padrão: Busca o arquivo nas pastas:
            ; A_ScriptDir\lib\, A_AhkPath\lib\ e A_MyDocuments\Autohotkey\Lib\
            if re[1] ~= '<.*>'
            {
                lib := Trim(RegExReplace(re[1], '[<>]'))
                if FileExist(arq := A_ScriptDir '\Lib\' lib '.ahk')
                    libname.Push(arq)

                else if FileExist(arq := A_MyDocuments '\AutoHotkey\Lib\' lib '.ahk')
                    libname.Push(arq)

                else if FileExist(arq := A_AhkPath '\Lib\' lib '.ahk')
                    libname.Push(arq)
            }
            else
            {
                lib := Trim(re[1])
                if FileExist(arq := A_WorkingDir '\' lib)
                    libname.Push(arq)
            }
        }
    }
    return libname
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

; Mostra o calltip para a palavra presente no map CallTips
CalltipComplete()
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

    str := SubStr(CallTips[word][opt], start + 1)
    sci.AddText(RegExReplace(str, '[\[\]()]') )
    sci.CallTipActive() && sci.CallTipCancel()
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

RegExExtractor(*)
{
    EnvSet('np2_hwnd', WinActive('ahk_exe Notepad2.exe'))
    Run('Plugins\RegexExtractor.ahk')
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

ExecutarSelecao()
{
    shell := ComObject('WScript.Shell')
    exec := shell.Exec('AutoHotkey.exe *')
    exec.StdIn.Write(sci.GetSelText())
    exec.StdIn.Close()
}

; Formata o texto como uma tabela ASCII, mas preservando o delimitador
FormatarCSV(*)
{
    text := sci.GetText(), Width :=  Map()
    Loop parse text, '`n', '`r'
    {
        ; Determina qual delimitador usar com base na quantidade que aparece
        ; na primeira linha do texto, depois adiciona o comprimento de cada
        ; campo no Map para determinar o tamanho mínimo de cada coluna.
        if A_Index = 1
        {
            StrReplace(A_LoopField, ',' ,,, &commas)
            StrReplace(A_LoopField, ';' ,,, &semicolons)
            StrReplace(A_LoopField, '|' ,,, &pipes)
            Delimiters := Map(commas, ',', semicolons, ';', pipes, '|')
            Delimiter := Delimiters[Max(commas, semicolons, pipes)]

            for item in StrSplit(A_LoopField, Delimiter)
                Width[A_Index] := [StrLen(item)]
        }
        else
        {
            for item in StrSplit(A_LoopField, Delimiter)
                Width[A_Index].push(StrLen(item))
        }
    }
    ; Formata cada coluna com o comprimento mínimo necessário
    ; e alinha à direita os campos numéricos.
    Loop parse text, '`n', '`r'
    {
        newline := ''
        for item in StrSplit(A_LoopField, Delimiter)
        {
            if item ~= '^[0-9.,]+$'
                newline .= Format('{:' Max(Width[A_Index]*) '}', item) Delimiter
            else
                newline .= Format('{:-' Max(Width[A_Index]*) '}', item) Delimiter
        }
        new .= RTrim(newline, Delimiter) '`n'
    }
    sci.SetText(new)
    MenuSelect('ahk_exe Notepad2.exe', , '4&', '10&')
    if not WinWait('CSV Options',, 2)
        return

    Control := Map(',', 'Button2', ';', 'Button5', '|', 'Button4')
    ControlClick(Control[Delimiter], 'CSV Options',,,, 'NA')
    ControlClick('Button14', 'CSV Options',,,, 'NA')
}

GuiP := Gui('-MaximizeBox -MinimizeBox AlwaysOnTop', 'Docs')
GuiP.OnEvent('Close', (*)=> GuiP.Hide())
GuiP.MarginX := GuiP.MarginY := 0
GuiP.SetFont('s12', 'Segoe UI')
Rich := RichEdit(GuiP, 'VScroll w600 h400')
Rich.SetMargins(20, 20)

Help()
{
    word := sci.GetSelText()
    if not MapDoc.has(word)
        return

    Rich.Clear()
    cab := Rich.Text(word)
    cab.bold := -1, cab.Size := 18, cab.ForeColor := Rich.Color['#FF00FF']
    Rich.Space(10)
    cab := Rich.Text(MapDoc[word]['desc'])
    cab.italic := -1
    Rich.Space(10)

    for param in MapDoc[word]['params']
    {
        cab := Rich.Text(param[1]['nome'])
        cab.bold := -1
        Rich.Space(5)
        cab := Rich.Text(param[1]['desc'])
        Rich.Space(10)
    }
    GuiP.Show()
}

InsertOrUpdateDoc(*)
{
    texto := sci.GetText()
    if texto ~= '@date [0-9\-\/]{10}'
    {
        sci.TargetWholeDocument()
        sci.SetSearchFlags(SCFIND_REGEXP := 0x00200000 | SCFIND_CXX11REGEX := 0x00800000)
        sci.SearchInTarget('@date [0-9\-\/]{10}')
        sci.ReplaceTarget('@date ' FormatTime(A_Now, 'yyyy-MM-dd'))
        sci.TargetWholeDocument()
        sci.SearchInTarget('@version ([\w\.\-]+)')
        sci.ReplaceTarget('@version ' A_AhkVersion)  
    }
    else
    {
        cab := Format('
        (RTrim0
        /************************************************************************
         * @description 
         * @author Pedro Henrique C. Xavier
         * @date {}
         * @version {}
         ***********************************************************************/
        
        
        )', FormatTime(A_Now, 'yyyy-MM-dd'), A_AhkVersion)
        
        sci.InsertText(0, cab)
        sci.SetEmptySelection(90)
        sci.ScrollCaret()
    }
}


#HotIf WinActive('ahk_exe Notepad2.exe')

+F1::Help()
F1::ShowCalltip()
F2::CalltipComplete()
F5::MenuSelect('ahk_exe Notepad2.exe', , '6&', '9&')
F11::AbrirAjuda()
!r::RemoveAspPar()
^r::RegExExtractor()
^m::MsgBoxCreator()

; Calcula a linha atual como expressão e adiciona o resultado
F10::
^!c::
{
    str := sci.GetCurLine()
    if RegExMatch(str, '(?>\=?)([0-9 +\-\*\/\,\.]+$)', &re)
        sci.AppendText(' = ' milhar(calcular(re[1])))
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
