/************************************************************************
 * @description Class Scintilla com as funções básicas mais utilizadas
 * @author Pedro Henrique C. Xavier
 * @date 2024-02-16
 * @version 2.1-alpha.8
 ***********************************************************************/

#Requires AutoHotkey v2.1-

class Scintilla
{
    __New(hSci)
    {
        this.hSci := hSci
        this.PID := WinGetPID(hSci)
    }
    ; Add text to the document at current position.
    AddText(str) => this.__Message(2001, StrLen(str), this.__WriteBuffer(str).ptr)
    ; Insert string at a position.
    InsertText(pos, str) => this.__Message(2003, pos, this.__WriteBuffer(str).ptr)
    ; Append a string to the end of the document without changing the selection.
    AppendText(str) => this.__Message(2282, StrLen(str), this.__WriteBuffer(str).ptr)
    ; Returns the position of the caret.
    GetCurrentPos() => this.__Message(2008)
    ; Retrieve the selected text.
    GetSelText() => this.__ReadBuffer(2161)
    ;Replace the selected text with the argument text.
    ReplaceSel(str) => this.__Message(2170, 0, this.__WriteBuffer(str).ptr)
    ; Clear the selection.
    Clear() => this.__Message(2180)
    ; Replace the contents of the document with the argument text.
    SetText(str) => this.__Message(2181, 0, this.__WriteBuffer(str).Ptr)
    ; Retrieve all the text in the document.
    GetText() => this.__ReadBuffer(2182)
    ; Retrieve the column number of a position, taking tab width into account.
    GetColumn(pos) => this.__Message(2129, pos)
    ; Retrieve the text of the line containing the caret.
    GetCurLine() => this.__ReadBuffer(2027)
    ; Show a call tip containing a definition near position pos.
    CallTipShow(pos, str) => this.__Message(2200, pos, this.__WriteBuffer(str).Ptr)
    ; Remove the call tip from the screen.
    CallTipCancel() => this.__Message(2201)
    ; Is there an active call tip?
    CallTipActive() => this.__Message(2202)
    ; Highlight a segment of the definition.
    CallTipSetHlt(start, end) => this.__Message(2204, start, end)
    ; Set the foreground colour for the highlighted part of the call tip.
    CallTipSetForeHlt(colour) => this.__Message(2207, colour)
    ; Set position of calltip, above or below text.
    CallTipSetPosition(bool) => this.__Message(2213, bool)
    ; Set caret to a position, while removing any existing selection.
    SetEmptySelection(pos) => this.__Message(2556, pos)
    ; Ensure the caret is visible.
    ScrollCaret() => this.__Message(2169)
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
    ; Retrieve the word at position
    CurrentWord(pos)
    {
        start := this.__Message(2266, pos, 1)
        end := this.__Message(2267, pos, 1)
        if (end > start)
        {
            this.SetTargetRange(start, end)
            return this.GetTargetText()
        }
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
        return StrGet(textBuf, 'UTF-8')
    }
    ; Coloca uma string na memória virtual
    __WriteBuffer(str)
    {
        buf := Buffer(StrPut(str, 'UTF-8'))
        StrPut(str, buf, 'UTF-8')
        RB := RemoteBuffer(this.PID, StrLen(str))
        RB.Write(buf)
        return RB
    }
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
    __New(PID, size)
    {
        static flags := (PROCESS_VM_OPERATION := 0x8) | (PROCESS_VM_WRITE := 0x20) | (PROCESS_VM_READ := 0x10)
            , Params := ['UInt', MEM_COMMIT := 0x1000, 'UInt', PAGE_READWRITE := 0x4, 'Ptr']

        if !this.hProc := DllCall('OpenProcess', 'UInt', flags, 'Int', 0, 'UInt', PID, 'Ptr')
            throw OSError('Can`'t open remote process PID = ' . PID . '`nA_LastError: ' . A_LastError, 'RemoteBuffer.__New')

        if !this.ptr := DllCall('VirtualAllocEx', 'Ptr', this.hProc, 'Ptr', 0, 'Ptr', size, Params*)
        {
            DllCall('CloseHandle', 'Ptr', this.hProc)
            throw OSError('Can`'t allocate memory in remote process PID = ' . PID . '`nA_LastError: ' . A_LastError, 'RemoteBuffer.__New')
        }
    }
    __Delete()
    {
        DllCall('VirtualFreeEx', 'Ptr', this.hProc, 'Ptr', this.ptr, 'UInt', 0, 'UInt', MEM_RELEASE := 0x8000)
        DllCall('CloseHandle', 'Ptr', this.hProc)
    }
    Read(BufObj, offset := 0)
    {
        if !DllCall('ReadProcessMemory', 'Ptr', this.hProc, 'Ptr', this.ptr + offset, 'Ptr', BufObj, 'Ptr', BufObj.Size, 'PtrP', &bytesRead := 0)
            throw OSError('Can`'t read data from remote buffer`nA_LastError: ' . A_LastError, 'RemoteBuffer.Read')
        return bytesRead
    }
    Write(BufObj, offset := 0)
    {
        if !res := DllCall('WriteProcessMemory', 'Ptr', this.hProc, 'Ptr', this.ptr + offset, 'Ptr', BufObj, 'Ptr', BufObj.Size, 'PtrP', &bytesWritten := 0)
            throw OSError('Can`'t write data to remote buffer`nA_LastError: ' . A_LastError, 'RemoteBuffer.Write')
        return bytesWritten
    }
}
