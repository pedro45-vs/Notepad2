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

#Include '\\srvrg-saas\rede\PEDRO\Scripts\Lib\cJson.ahk'
#Include '\\srvrg-saas\rede\PEDRO\Scripts\Lib\RichReport.ahk'

DocMap := Map()


Loop files 'C:\Users\Pedro RG\Downloads\Projetos\AutoHotkeyDocs-alpha\docs\lib\*.htm'
{
    html := FileRead(A_LoopFileFullPath, 'UTF-8')
    ToolTip(A_LoopFileName, 1, 1)
    HelpFile(html)
}

;html := FileRead('C:\Users\Pedro RG\Downloads\Projetos\AutoHotkeyDocs-alpha\docs\lib\OnMessage.htm', 'UTF-8')
;HelpFile(html)

HelpFile(html)
{
    global DocMap
    doc := ComObject('HTMLFile')
    doc.Write(html)
    Sleep(200)
    name_func := doc.getElementsByTagName('h1').item(0).innerText
    desc_func := doc.getElementsByTagName('p').item(0).innerText
    syntax_def := ''
    if syntax := doc.getElementsByClassName('Syntax').item(0)
    {
        syntax_def := syntax.innerText
        if syntax_opt := syntax.getElementsByClassName('optional').item(0)
            syntax_def := StrReplace(syntax_def, syntax_opt.innerText, '[' syntax_opt.innerText ']')        
    }
    params := []

    Loop doc.getElementsByTagName('dt').Length
    {
        nome := doc.getElementsByTagName('dt').item(A_Index - 1).InnerText
        if not dd := doc.getElementsByTagName('dd').item(A_Index - 1)
            continue
        
        desc := ''
        Loop dd.getElementsByTagName('p').Length
        {
            desc .= dd.getElementsByTagName('p').item(A_Index - 1).InnerText '`n'
        }
        params.push( [ {nome: nome, desc: desc} ] )
    }
    DocMap[name_func] := {desc: desc_func, params: params, syntax: syntax_def}
}

FileEncoding('UTF-8')
FileOpen('DocAutohotkey.json', 'w').Write(JSON.Dump(DocMap))
MsgBox('Concluído')