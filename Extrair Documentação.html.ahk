/*
Coleções:
tag := doc.getElementsByTagName('h1').item(0).innerText
cls := doc.getElementsByClassName('Syntax').item(0).innerText

Item único:
id  := doc.getElementById('Parameters').innerText

Propriedades:
    InnerText = todo o texto dentro da tag
    InnerHTML = a representação do elemento em html
*/

#Include '..\Lib\cJson.ahk'
#Include '..\Lib\RichReport.ahk'

DocMap := Map()

;select_folder := FileSelect('D', A_WorkingDir, 'Selecione a pasta para prosseguir')
;if not select_folder
;    ExitApp()

select_folder := 'C:\Users\Pedro RG\Downloads\Projetos\AutoHotkeyDocs-alpha\docs\lib'

Loop files select_folder '\*.htm'
{
    html := FileRead(A_LoopFileFullPath, 'UTF-8')
    ToolTip(A_LoopFileName, 1, 1)
    HelpFile(html)
}

;html := FileRead('C:\Users\Pedro RG\Downloads\Projetos\AutoHotkeyDocs-alpha\docs\lib\OnMessage.htm', 'UTF-8')
;HelpFile(html)

list := ''

HelpFile(html)
{
    global DocMap
    doc := ComObject('HTMLFile')
    doc.Write(html)
    Sleep(200)
    
    Syntax := doc.getElementsByClassName('Syntax')
    itens := Syntax.Length
    
    Loop itens
    {
        
        syntax_def := Syntax.item(A_Index - 1).innerText
        name_func   := Syntax.item(A_Index - 1).getElementsByClassName('func').item(0).innerText
        DocMap[name_func] := syntax_def

        
        ;MsgBox( name_func '`n' syntax_def )
        
        
    }
    
        ;
        ;
    ;name_func := doc.getElementsByTagName('h1').item(0).innerText
    ;desc_func := doc.getElementsByTagName('p').item(0).innerText
    ;syntax_def := ''
    ;if syntax := doc.getElementsByClassName('Syntax').item(0)
    ;{
    ;    syntax_def := syntax.innerText
    ;    if syntax_opt := syntax.getElementsByClassName('optional').item(0)
    ;        syntax_def := StrReplace(syntax_def, syntax_opt.innerText, '[' syntax_opt.innerText ']')        
    ;}
    ;params := []
    ;
    ;Loop doc.getElementsByTagName('dt').Length
    ;{
    ;    nome := doc.getElementsByTagName('dt').item(A_Index - 1).InnerText
    ;    if not dd := doc.getElementsByTagName('dd').item(A_Index - 1)
    ;        continue
        ;    
    ;    desc := ''
    ;    Loop dd.getElementsByTagName('p').Length
    ;    {
    ;        desc .= dd.getElementsByTagName('p').item(A_Index - 1).InnerText '`n'
    ;    }
    ;    params.push( [ {nome: nome, desc: desc} ] )
    ;}
    ;DocMap[name_func] := {desc: desc_func, params: params, syntax: syntax_def}
}

FileEncoding('UTF-8')
FileOpen('DocAutohotkey.json', 'w').Write(JSON.Dump(DocMap))
FileOpen('list.txt', 'w').Write(list)
MsgBox('Concluído')