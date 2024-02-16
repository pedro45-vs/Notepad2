#Requires AutoHotkey v2.1-

/**
 * Atualizado 05.10.2023
 */

class BaseScintilla
{
    __New(hSci)
    {
        this.hSci := hSci
        this.CodePage := 'CP' this.GetCodePage()
        this.PID := WinGetPID(hSci)
        this.ptrSize := this.__GetProcessBitness(this.PID) // 8
    }
     ; Simplificação da função SendMessage()
    __Message(msg, wParam?, lParam?) => SendMessage(msg, wParam?, lParam?, this.hSci)
    ; Lê uma string disponibilizada pela mensagem
    __ReadBuffer(msg)
    {
        textSize := this.__Message(msg, 0, 0)
        RB := RemoteBuffer(this.PID, textSize + 1)
        this.__Message(msg, textSize, RB.Ptr)
        RB.Read(textBuf := Buffer(textSize))
        return StrGet(textBuf, this.CodePage)
    }
    ; Coloca uma string na memória virtual
    __WriteBuffer(str)
    {
        buf := Buffer(StrPut(str, this.CodePage))
        StrPut(str, buf, this.CodePage)
        RB := RemoteBuffer(this.PID, StrLen(str))
        RB.Write(buf)
        return RB
    }
    ; retorna se o processo é 32 ou 64bits, como só vou usar no meu computador, talvez seja redundante
    __GetProcessBitness(PID)
    {
        static flag := PROCESS_QUERY_INFORMATION := 0x400
        if !A_Is64bitOS
            return 32
        hProc := DllCall('OpenProcess', 'UInt', flag, 'UInt', 0, 'UInt', PID, 'Ptr')
        DllCall('IsWow64Process', 'Ptr', hProc, 'IntP', &is32 := 0)
        DllCall('CloseHandle', 'Ptr', hProc)
        return 32 << !is32
    }
}

class TextRetrieval extends BaseScintilla
{
    ; Returns the position of the caret.
    GetCurrentPos() => this.__Message(2008)
    ; Returns the position of the opposite end of the selection to the caret.
    GetAnchor() => this.__Message(2009)
    ; Delete all text in the document.
    ClearAll() => this.__Message(2004)
    ; Returns the number of bytes in the document.
    GetLength() => this.__Message(2006)
    ; Returns the character byte at the position.
    GetCharAt(pos) => Chr(this.__Message(2007, pos))
    ; Select all the text in the document.
    SelectAll() => this.__Message(2013)
    ; Redoes the next action on the undo history.
    Redo() => this.__Message(2011)
    ; Find the position from a point within the window.
    PositionFromPoint(x, y) => this.__Message(2022, x, y)
    ; Find the position from a point within the window but return INVALID_POSITION if not close to text.
    PositionFromPointClose(x, y) => this.__Message(2023, x, y)
    ; Set caret to start of a line and ensure it is visible.
    GotoLine(line) => this.__Message(2024, line)
    ; Set caret to a position and ensure it is visible.
    GotoPos(pos) => this.__Message(2025, pos)
    ; Get the highlighted indentation guide column.
    GetHighlightGuide() => this.__Message(2135)
    ; Get the code page used to interpret the bytes of the document as characters.
    GetCodePage() => this.__Message(2137)
    ; Retrieve the number of characters in the document.
    GetTextLength() => this.__Message(2183)
    ;  Delete a range of text in the document.
    DeleteRange(pos, len) => this.__Message(2645, pos, len)
    ; Insert string at a position.
    InsertText(pos, str) => this.__Message(2003, pos, this.__WriteBuffer(str).ptr)
    ; Add text to the document at current position.
    AddText(str) => this.__Message(2001, StrLen(str), this.__WriteBuffer(str).ptr)
    ; Get position of start of word.
    WordStartPosition(pos, bool) => this.__Message(2266, pos, bool)
    ; Get position of end of word.
    WordEndPosition(pos, bool) => this.__Message(2267, pos, bool)
    ;Replace the selected text with the argument text.
    ReplaceSel(str) => this.__Message(2170, 0, this.__WriteBuffer(str).ptr)
    ; Retrieve the text of the line containing the caret.
    GetCurLine() => this.__ReadBuffer(2027)
    ; Retrieve the selected text.
    GetSelText() => this.__ReadBuffer(2161)
    ; Clear the selection.
    Clear() => this.__Message(2180)
    ; Replace the contents of the document with the argument text.
    SetText(str) => this.__Message(2181, 0, this.__WriteBuffer(str).ptr)
    ; Retrieve all the text in the document.
    GetText() => this.__ReadBuffer(2182)
    ; Retrieve the column number of a position, taking tab width into account.
    GetColumn(pos) => this.__Message(2129, pos)
    ; Returns the position of the opposite end of the selection to the caret.
    GetAnchor() => this.__Message(2009)

    ; Retrieve the word at position
    CurrentWord(pos)
    {
        start := this.WordStartPosition(pos, 1)
        end := this.WordEndPosition(pos, 1)
        return (end > start) && this.GetTextRangeFull(start, end)
    }
    ; Retrieve a range of text that can be past 2GB.
    GetTextRangeFull(start, end)
    {
        textSize :=  end - start
        size := this.ptrSize * 3
        RB := RemoteBuffer(this.PID, size + textSize + 1)
        RB.Write(TEXTRANGE(start, end, RB.ptr + size))

        textSize := this.__Message(2039,, RB.ptr) + 1
        textBuf := Buffer(textSize, 0)
        RB.Read(textBuf, size)
        return StrGet(textBuf, this.CodePage)
    }
}


class AutoComplete extends TextRetrieval
{
    ; Display a auto-completion list.
    ; The lengthEntered parameter indicates how many characters before
    ; the caret should be used to provide context.
    AutoCShow(len, list) => this.__Message(2100, len, this.__WriteBuffer(list).Ptr)
    ; Remove the auto-completion list from the screen.
    AutoCCancel() => this.__Message(2101)
    ; Is there an auto-completion list visible?
    AutoCActive() => this.__Message(2102)
    ; Retrieve the position of the caret when the auto-completion list was displayed.
    AutoCPosStart() => this.__Message(2103)
    ; User has selected an item so remove the list and insert the selection.
    AutoCComplete() => this.__Message(2104)
    ; Define a set of character that when typed cancel the auto-completion list.
    AutoCStops(str) => this.__Message(2105, 0, this.__WriteBuffer(str).Ptr)
    ; Change the separator character in the string setting up an auto-completion list.
    ; Default is space but can be changed if items contain space.
    AutoCSetSeparator(delimiter) => this.__Message(2106, ord(delimiter))
    ; Retrieve the auto-completion list separator character.
    AutoCGetSeparator() => chr(this.__Message(2107))
    ; Select the item in the auto-completion list that starts with a string.
    AutoCSelect(str) => this.__Message(2108, 0, this.__WriteBuffer(str).Ptr)
    ; Get currently selected item position in the auto-completion list
    AutoCGetCurrent() => this.__Message(2445)
    ; Get currently selected item text in the auto-completion list
    AutoCGetCurrentText() => this.__ReadBuffer(2610)
    ; Should the auto-completion list be cancelled if the user backspaces to a
    ; position before where the box was created.
    AutoCSetCancelAtStart(bool) => this.__Message(2110, bool)
    ; Retrieve whether auto-completion cancelled by backspacing before start.
    AutoCGetCancelAtStart() => this.__Message(2111)
    ; Define a set of characters that when typed will cause the autocompletion to
    ; choose the selected item.
    AutoCSetFillUps(str) => this.__Message(2112, 0, this.__WriteBuffer(str).Ptr)
    ; Should a single item auto-completion list automatically choose the item.
    AutoCSetChooseSingle(bool) => this.__Message(2113, bool)
    ; Retrieve whether a single item auto-completion list automatically choose the item.
    AutoCGetChooseSingle() => this.__Message(2114)
    ; Set whether case is significant when performing auto-completion searches.
    AutoCSetIgnoreCase(bool) => this.__Message(2115, bool)
    ; Retrieve state of ignore case flag.
    AutoCGetIgnoreCase() => this.__Message(2116)
    ; Set auto-completion case insensitive behaviour to either prefer case-sensitive matches or have no preference.
    AutoCSetCaseInsensitiveBehaviour(bool) => this.__Message(2634, bool)
    ; Get auto-completion case insensitive behaviour.
    AutoCGetCaseInsensitiveBehaviour() => this.__Message(2635)
    ; Change the effect of autocompleting when there are multiple selections.
    AutoCSetMulti(bool) => this.__Message(2636, bool)
    ; Retrieve the effect of autocompleting when there are multiple selections.
    AutoCGetMulti() => this.__Message(2637)
    ; Set the way autocompletion lists are ordered.
    AutoCSetOrder(bool) => this.__Message(2660, bool)
    ; Get the way autocompletion lists are ordered.
    AutoCGetOrder() => this.__Message(2661)
    ; Set whether or not autocompletion is hidden automatically when nothing matches.
    AutoCSetAutoHide(bool) => this.__Message(2118, bool)
    ; Retrieve whether or not autocompletion is hidden automatically when nothing matches.
    AutoCGetAutoHide() => this.__Message(2119)
    ; Set whether or not autocompletion deletes any word characters
    ; after the inserted text upon completion.
    AutoCSetDropRestOfWord(bool) => this.__Message(2270, bool)
    ; Retrieve whether or not autocompletion deletes any word characters
    ; after the inserted text upon completion.
    AutoCGetDropRestOfWord() => this.__Message(2271)
    ; Set autocompletion options.
    AutoCSetOptions(bool) => this.__Message(2638, bool)
    ; Retrieve autocompletion options.
    AutoCompleteOption() => this.__Message(2639)

    ; falta


    ; Display a list of strings and send notification when user chooses one.
    UserListShow(listType, itemList) => this.__Message(2117, listType, this.__WriteBuffer(itemList).Ptr)
}

class Calltips extends AutoComplete
{
    ; Show a call tip containing a definition near position pos.
    CallTipShow(pos, str) => this.__Message(2200, pos, this.__WriteBuffer(str).Ptr)
    ; Remove the call tip from the screen.
    CallTipCancel() => this.__Message(2201)
    ; Is there an active call tip?
    CallTipActive() => this.__Message(2202)
    ; Retrieve the position where the caret was before displaying the call tip.
    CallTipPosStart() => this.__Message(2203)
    ; Highlight a segment of the definition.
    CallTipSetHlt(start, end) => this.__Message(2204, start, end)
    ; Set the background colour for the call tip.
    CallTipSetBack(colour) => this.__Message(2205, colour)
    ; Set the foreground colour for the call tip.
    CallTipSetFore(colour) => this.__Message(2206, colour)
    ; Set the foreground colour for the highlighted part of the call tip.
    CallTipSetForeHlt(colour) => this.__Message(2207, colour)
    ; Enable use of STYLE_CALLTIP and set call tip tab size in pixels.
    CallTipUseStyle(tabsize) => this.__Message(2212, tabsize)
    ; Set position of calltip, above or below text.
    CallTipSetPosition(bool) => this.__Message(2213, bool)
    ; Set the start position in order to change when backspacing removes the calltip.
    CallTipSetPosStart() => this.__Message(2214)
}



class Lexer extends BaseScintilla
{
    ; Retrieve the lexing language of the document.
    GetLexer() => this.__Message(4002)
    ; Retrieve the name of the lexer.
    GetLexerLanguage() => this.__ReadBuffer(4012)
}

class Indicators extends Calltips
{
    ; Turn a indicator on over a range.
    IndicatorFillRange(start, length) => this.__Message(2504, start, length)


}

class Scintilla extends Indicators
{

}

class Selection
{
    ; Sets the position of the caret.
    SetCurrentPos(pos) => this.__Message(2141, pos)
    ; Set caret to a position, while removing any existing selection.
    SetEmptySelection(pos) => this.__Message(2556, pos)
    ; Select a range of text.
    SetSel(pos_anchor, pos_caret) => this.__Message(2160, pos_anchor, pos_caret)
    ; Ensure the caret is visible.
    ScrollCaret() => this.__Message(2169)
    
}

class Searching
{
    ; Replace the target text with the argument text.
    ; Text is counted so it can contain NULs.
    ; Returns the length of the replacement text.
    ReplaceTarget(str) => this.__Message(2194, StrLen(str), this.__WriteBuffer(str).ptr)
    ; Search for a counted string in the target and set the target to the found
    ; range. Text is counted so it can contain NULs.
    ; Returns start of found range or -1 for failure in which case target is not moved.
    SearchInTarget(str) => this.__Message(2197, StrLen(str), this.__WriteBuffer(str).ptr)
    ; Set the search flags used by SearchInTarget.
    SetSearchFlags(searchFlags) => this.__Message(2198, searchFlags)
    ; Retrieve the text in the target.
    GetTargetText() => this.__ReadBuffer(2687)
    ; Sets the target to the whole document.
    TargetWholeDocument() => this.__Message(2690)
    ; Sets both the start and end of the target in one call.
    SetTargetRange(start, end) => this.__Message(2686, start, end)    
}

class Scrolling
{
    ; Ensure the caret is visible.
    ScrollCaret() => this.__Message(2169)
}


; Structure
;
class TEXTRANGE
{
    start : iptr
    end: iptr
    ptrtext : iptr
    __New(start, end, ptrtext)
    {
        this.start := start
        this.end := end
        this.ptrtext := ptrtext
    }
    size => ObjGetDataSize(this)
}

/**
 * https://www.autohotkey.com/boards/viewtopic.php?p=537298#p537298
 * O Controle Scintilla não tem acesso direto ao espaço de memória comum
 * Por isso é preciso alocar um buffer virtual para a memória do processo
 * Ao trabalhar com as funções, é preciso criar um buffer normal e depois
 * passar ao buffer virtual
 */
class RemoteBuffer
{
    __New(PID, size) {
        static flags := (PROCESS_VM_OPERATION := 0x8) | (PROCESS_VM_WRITE := 0x20) | (PROCESS_VM_READ := 0x10)
            , Params := ['UInt', MEM_COMMIT := 0x1000, 'UInt', PAGE_READWRITE := 0x4, 'Ptr']

        if !this.hProc := DllCall('OpenProcess', 'UInt', flags, 'Int', 0, 'UInt', PID, 'Ptr')
            throw OSError('Can`'t open remote process PID = ' . PID . '`nA_LastError: ' . A_LastError, 'RemoteBuffer.__New')

        if !this.ptr := DllCall('VirtualAllocEx', 'Ptr', this.hProc, 'Ptr', 0, 'Ptr', size, Params*) {
            DllCall('CloseHandle', 'Ptr', this.hProc)
            throw OSError('Can`'t allocate memory in remote process PID = ' . PID . '`nA_LastError: ' . A_LastError, 'RemoteBuffer.__New')
        }
    }
    __Delete() {
        DllCall('VirtualFreeEx', 'Ptr', this.hProc, 'Ptr', this.ptr, 'UInt', 0, 'UInt', MEM_RELEASE := 0x8000)
        DllCall('CloseHandle', 'Ptr', this.hProc)
    }
    Read(BufObj, offset := 0) {
        if !DllCall('ReadProcessMemory', 'Ptr', this.hProc, 'Ptr', this.ptr + offset, 'Ptr', BufObj, 'Ptr', BufObj.Size, 'PtrP', &bytesRead := 0)
            throw OSError('Can`'t read data from remote buffer`nA_LastError: ' . A_LastError, 'RemoteBuffer.Read')
        return bytesRead
    }
    Write(BufObj, offset := 0) {
        if !res := DllCall('WriteProcessMemory', 'Ptr', this.hProc, 'Ptr', this.ptr + offset, 'Ptr', BufObj, 'Ptr', BufObj.Size, 'PtrP', &bytesWritten := 0)
            throw OSError('Can`'t write data to remote buffer`nA_LastError: ' . A_LastError, 'RemoteBuffer.Write')
        return bytesWritten
    }
}