// Keywords modificadas para personalizar o realce de sintaxe e acrescentar
// algumas funções exclusivas da versão v2.1 (update: v2.1-alpha.7)

#include "EditLexer.h"
#include "EditStyleX.h"

static KEYWORDLIST Keywords_AHK = {{
//++Autogenerated -- start of section automatically generated
"and as break case catch class contains continue default else extends false "
"finally for get global goto if in is local loop not or return set static super "
"switch this throw true try unset until while "

, // 1 directives
"ClipboardTimeout DefaultReturn DllLoad ErrorStdOut HotIf HotIfTimeout Hotstring "
"Include IncludeAgain InputLevel MaxThreads MaxThreadsBuffer MaxThreadsPerHotkey "
"NoTrayIcon Requires SingleInstance SuspendExempt UseHook Warn WinActivateForce "

, // 2 compiler directives
"Ahk2Exe-AddResource Ahk2Exe-Base Ahk2Exe-Bin Ahk2Exe-ConsoleApp Ahk2Exe-Cont "
"Ahk2Exe-Debug Ahk2Exe-ExeName Ahk2Exe-IgnoreBegin Ahk2Exe-IgnoreEnd "
"Ahk2Exe-Keep Ahk2Exe-Let Ahk2Exe-Nop Ahk2Exe-Obey Ahk2Exe-PostExec "
"Ahk2Exe-ResourceID Ahk2Exe-Set Ahk2Exe-SetMainIcon Ahk2Exe-UpdateManifest "
"Ahk2Exe-UseResourceLang "

, // 3 objects
"Any Array BoundFunc Buffer Class ClipboardAll Closure ComObjArray ComObject "
"ComValue ComValueRef Enumerator Error File Func Gui IndexError InputHook Map "
"MemberError MemoryError Menu MenuBar MethodError Object OSError Primitive "
"PropertyError RegExMatchInfo TargetError TimeoutError TypeError UnsetError "
"UnsetItemError ValueError VarRef ZeroDivisionError "

, // 4 built-in variables
"A_AhkPath A_AhkVersion A_AllowMainWindow A_AppData A_AppDataCommon A_Args "
"A_Clipboard A_ComputerName A_ComSpec A_ControlDelay A_CoordModeCaret "
"A_CoordModeMenu A_CoordModeMouse A_CoordModePixel A_CoordModeToolTip A_Cursor "
"A_DD A_DDD A_DDDD A_DefaultMouseSpeed A_Desktop A_DesktopCommon "
"A_DetectHiddenText A_DetectHiddenWindows A_EndChar A_EventInfo A_FileEncoding "
"A_HotkeyInterval A_HotkeyModifierTimeout A_Hour A_IconFile A_IconHidden "
"A_IconNumber A_IconTip A_Index A_InitialWorkingDir A_Is64bitOS A_IsAdmin "
"A_IsCompiled A_IsCritical A_IsPaused A_IsSuspended A_KeybdHookInstalled "
"A_KeyDelay A_KeyDelayPlay A_KeyDuration A_KeyDurationPlay A_Language A_LastError "
"A_LineFile A_LineNumber A_ListLines A_LoopField A_LoopFileAttrib A_LoopFileDir "
"A_LoopFileExt A_LoopFileFullPath A_LoopFileName A_LoopFilePath "
"A_LoopFileShortName A_LoopFileShortPath A_LoopFileSize A_LoopFileSizeKB "
"A_LoopFileSizeMB A_LoopFileTimeAccessed A_LoopFileTimeCreated "
"A_LoopFileTimeModified A_LoopReadLine A_LoopRegKey A_LoopRegName "
"A_LoopRegTimeModified A_LoopRegType A_MaxHotkeysPerInterval A_MenuMaskKey A_Min "
"A_MM A_MMM A_MMMM A_MouseDelay A_MouseDelayPlay A_MouseHookInstalled A_MSec "
"A_MyDocuments A_Now A_NowUTC A_OSVersion A_PriorHotkey A_PriorKey A_ProgramFiles "
"A_Programs A_ProgramsCommon A_PtrSize A_RegView A_ScreenDPI A_ScreenHeight "
"A_ScreenWidth A_ScriptDir A_ScriptFullPath A_ScriptHwnd A_ScriptName A_Sec "
"A_SendLevel A_SendMode A_Space A_StartMenu A_StartMenuCommon A_Startup "
"A_StartupCommon A_StoreCapsLockMode A_Tab A_Temp A_ThisFunc A_ThisHotkey "
"A_TickCount A_TimeIdle A_TimeIdleKeyboard A_TimeIdleMouse A_TimeIdlePhysical "
"A_TimeSincePriorHotkey A_TimeSinceThisHotkey A_TitleMatchMode "
"A_TitleMatchModeSpeed A_TrayMenu A_UserName A_WDay A_WinDelay A_WinDir "
"A_WorkingDir A_YDay A_YWeek A_YYYY "

, // 5 keys
"Alt AppsKey Backspace Browser_Back Browser_Favorites Browser_Forward "
"Browser_Home Browser_Refresh Browser_Search Browser_Stop BS CapsLock Ctrl "
"CtrlBreak Del Delete Down End Enter Esc Escape Help Home Ins Insert JoyAxes "
"JoyButtons JoyInfo JoyName JoyPOV JoyR JoyU JoyV JoyX JoyY JoyZ LAlt "
"Launch_App1 Launch_App2 Launch_Mail Launch_Media LButton LControl LCtrl Left "
"LShift LWin MButton Media_Next Media_Play_Pause Media_Prev Media_Stop NumLock "
"Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 Numpad9 "
"NumpadAdd NumpadClear NumpadDel NumpadDiv NumpadDot NumpadDown NumpadEnd "
"NumpadEnter NumpadHome NumpadIns NumpadLeft NumpadMult NumpadPgDn NumpadPgUp "
"NumpadRight NumpadSub NumpadUp Pause PgDn PgUp PrintScreen RAlt RButton "
"RControl RCtrl Right RShift RWin ScrollLock Shift Sleep Space Up Volume_Down "
"Volume_Mute Volume_Up WheelDown WheelLeft WheelRight WheelUp XButton1 XButton2 "

, // 6 functions
"Abs( ACos( Array( ASin( ATan( ATan2( BlockInput( Buffer( CallbackCreate( "
"CallbackFree( CaretGetPos( Ceil( Chr( Class( Click( ClipboardAll( ClipWait( "
"ComCall( ComObjActive( ComObjArray( ComObjConnect( ComObject( ComObjFlags( "
"ComObjFromPtr( ComObjGet( ComObjQuery( ComObjType( ComObjValue( ComValue( "
"ControlAddItem( ControlChooseIndex( ControlChooseString( ControlClick( "
"ControlDeleteItem( ControlFindItem( ControlFocus( ControlGetChecked( "
"ControlGetChoice( ControlGetClassNN( ControlGetEnabled( ControlGetExStyle( "
"ControlGetFocus( ControlGetHwnd( ControlGetIndex( ControlGetItems( "
"ControlGetPos( ControlGetStyle( ControlGetText( ControlGetVisible( ControlHide( "
"ControlHideDropDown( ControlMove( ControlSend( ControlSendText( "
"ControlSetChecked( ControlSetEnabled( ControlSetExStyle( ControlSetStyle( "
"ControlSetText( ControlShow( ControlShowDropDown( CoordMode( Cos( Critical( "
"DateAdd( DateDiff( DetectHiddenText( DetectHiddenWindows( DirCopy( DirCreate( "
"DirDelete( DirExist( DirMove( DirSelect( DllCall( Download( DriveEject( "
"DriveGetCapacity( DriveGetFileSystem( DriveGetLabel( DriveGetList( "
"DriveGetSerial( DriveGetSpaceFree( DriveGetStatus( DriveGetStatusCD( "
"DriveGetType( DriveLock( DriveRetract( DriveSetLabel( DriveUnlock( Edit( "
"EditGetCurrentCol( EditGetCurrentLine( EditGetLine( EditGetLineCount( "
"EditGetSelectedText( EditPaste( EnvGet( EnvSet( Error( Exit( ExitApp( Exp( "
"FileAppend( FileCopy( FileCreateShortcut( FileDelete( FileEncoding( FileExist( "
"FileGetAttrib( FileGetShortcut( FileGetSize( FileGetTime( FileGetVersion( "
"FileInstall( FileMove( FileOpen( FileRead( FileRecycle( FileRecycleEmpty( "
"FileSelect( FileSetAttrib( FileSetTime( Float( Floor( Format( FormatTime( "
"GetKeyName( GetKeySC( GetKeyState( GetKeyVK( GetMethod( GroupActivate( GroupAdd( "
"GroupClose( GroupDeactivate( Gui( GuiCtrlFromHwnd( GuiFromHwnd( HasBase( "
"HasMethod( HasProp( HotIf( HotIfWinActive( HotIfWinExist( HotIfWinNotActive( "
"HotIfWinNotExist( Hotkey( Hotstring( IL_Add( IL_Create( IL_Destroy( ImageSearch( "
"IniDelete( IniRead( IniWrite( InputBox( InputHook( InstallKeybdHook( "
"InstallMouseHook( InStr( Integer( IsAlnum( IsAlpha( IsDigit( IsFloat( IsInteger( "
"IsLabel( IsLower( IsNumber( IsObject( IsSet( IsSetRef( IsSpace( IsTime( IsUpper( "
"IsXDigit( KeyHistory( KeyWait( ListHotkeys( ListLines( ListVars( "
"ListViewGetContent( Ln( LoadPicture( Log( LTrim( Map( Max( MenuFromHandle( "
"MenuSelect( Min( Mod( MonitorGet( MonitorGetCount( MonitorGetName( "
"MonitorGetPrimary( MonitorGetWorkArea( MouseClick( MouseClickDrag( MouseGetPos( "
"MouseMove( MsgBox( Number( NumGet( NumPut( ObjAddRef( ObjBindMethod( ObjFromPtr( "
"ObjFromPtrAddRef( ObjGetBase( ObjGetCapacity( ObjGetDataPtr( ObjGetDataSize( "
"ObjHasOwnProp( ObjOwnPropCount( ObjOwnProps( ObjPtr( ObjPtrAddRef( ObjRelease( "
"ObjSetBase( ObjSetCapacity( ObjSetDataPtr( OnClipboardChange( OnError( OnExit( "
"OnMessage( Ord( OutputDebug( Pause( Persistent( PixelGetColor( PixelSearch( "
"PostMessage( ProcessClose( ProcessExist( ProcessGetName( ProcessGetParent( "
"ProcessGetPath( ProcessSetPriority( ProcessWait( ProcessWaitClose( Random( "
"RegCreateKey( RegDelete( RegDeleteKey( RegExMatch( RegExReplace( RegRead( "
"RegWrite( Reload( Round( RTrim( Run( RunAs( RunWait( Send( SendEvent( SendInput( "
"SendLevel( SendMessage( SendMode( SendPlay( SendText( SetCapsLockState( "
"SetControlDelay( SetDefaultMouseSpeed( SetKeyDelay( SetMouseDelay( "
"SetNumLockState( SetRegView( SetScrollLockState( SetStoreCapsLockMode( SetTimer( "
"SetTitleMatchMode( SetWinDelay( SetWorkingDir( Shutdown( Sin( Sleep( Sort( "
"SoundBeep( SoundGetInterface( SoundGetMute( SoundGetName( SoundGetVolume( "
"SoundPlay( SoundSetMute( SoundSetVolume( SplitPath( Sqrt( StatusBarGetText( "
"StatusBarWait( StrCompare( StrGet( String( StrLen( StrLower( StrPtr( StrPut( "
"StrReplace( StrSplit( StrTitle( StrUpper( SubStr( Suspend( SysGet( "
"SysGetIPAddresses( Tan( Thread( ToolTip( TraySetIcon( TrayTip( Trim( Type( "
"VarSetStrCapacity( VerCompare( WinActivate( WinActivateBottom( WinActive( "
"WinClose( WinExist( WinGetAlwaysOnTop( WinGetClass( WinGetClientPos( "
"WinGetControls( WinGetControlsHwnd( WinGetCount( WinGetEnabled( WinGetExStyle( "
"WinGetID( WinGetIDLast( WinGetList( WinGetMinMax( WinGetPID( WinGetPos( "
"WinGetProcessName( WinGetProcessPath( WinGetStyle( WinGetText( WinGetTitle( "
"WinGetTransColor( WinGetTransparent( WinHide( WinKill( WinMaximize( WinMinimize( "
"WinMinimizeAll( WinMinimizeAllUndo( WinMove( WinMoveBottom( WinMoveTop( "
"WinRedraw( WinRestore( WinSetAlwaysOnTop( WinSetEnabled( WinSetExStyle( "
"WinSetRegion( WinSetStyle( WinSetTitle( WinSetTransColor( WinSetTransparent( "
"WinShow( WinWait( WinWaitActive( WinWaitClose( WinWaitNotActive( __Call( "
"__Delete( __Enum( __Get( __Init( __Item __New( __Set( "

, // 7 misc
"Add AddActiveX AddButton AddCheckbox AddComboBox AddCustom AddDDL AddDateTime "
"AddDropDownList AddEdit AddGroupBox AddHotkey AddLink AddListBox AddListView "
"AddMonthCal AddPic AddPicture AddProgress AddRadio AddSlider AddStandard "
"AddStatusBar AddTab AddTab2 AddTab3 AddText AddTreeView AddUpDown AtEOF "
"BackColor BackspaceIsUndo Base Bind Call Capacity CaseSense CaseSensitive Check "
"Choose ClassNN Clear ClickCount Clone Close Count Default DefineProp Delete "
"DeleteCol DeleteProp Destroy Disable Enable Enabled Encoding EndKey EndMods "
"EndReason Extra File FindAnywhere Flash Focus Focused FocusedCtrl Get GetChild "
"GetClientPos GetCount GetMethod GetNext GetOwnPropDesc GetParent GetPos GetPrev "
"GetSelection GetText Gui Handle Has HasBase HasMethod HasOwnProp HasProp Hide "
"Hwnd InProgress Input Insert InsertAt InsertCol IsBuiltIn IsByRef IsOptional "
"IsVariadic KeyOpt Len Length Line MarginX MarginY Mark Match MaxParams Maximize "
"MenuBar Message MinParams MinSendLevel Minimize Modify ModifyCol Move Name "
"NotifyNonText OnChar OnCommand OnEnd OnEvent OnKeyDown OnKeyUp OnMessage "
"OnNotify Opt OwnProps Pop Pos Prototype Ptr Push RawRead RawWrite Read ReadLine "
"ReadNumType Redraw RemoveAt Rename Restore Seek Set SetColor SetCue SetFont "
"SetFormat SetIcon SetImageList Show Size Stack Start Stop Submit Text Timeout "
"Title ToggleCheck ToggleEnable Type Uncheck UseTab Value Visible VisibleNonText "
"VisibleText Wait What Write WriteLine WriteNumType "

, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
//--Autogenerated -- end of section automatically generated
}};

static EDITSTYLE Styles_AHK[] = {
	EDITSTYLE_DEFAULT,
	{ SCE_AHK_KEYWORD, NP2StyleX_Keyword, L"bold; fore:#FF8000" },
	{ MULTI_STYLE(SCE_AHK_DIRECTIVE_SHARP, SCE_AHK_DIRECTIVE_AT, 0, 0), NP2StyleX_Directive, L"fore:#C65D09" },
	{ SCE_AHK_CLASS, NP2StyleX_Class, L"bold; fore:#1E90FF" },
	{ SCE_AHK_BUILTIN_FUNCTION, NP2StyleX_BuiltInFunction, L"fore:#0080C0" },
	{ SCE_AHK_FUNCTION, NP2StyleX_Function, L"fore:#A46000" },
	{ SCE_AHK_BUILTIN_VARIABLE, NP2StyleX_PredefinedVariable, L"fore:#B000B0" },
	{ SCE_AHK_DYNAMIC_VARIABLE, NP2StyleX_Variable, L"fore:#808000" },
	{ SCE_AHK_KEY, NP2StyleX_Key, L"fore:#007F7F" },
	{ MULTI_STYLE(SCE_AHK_COMMENTLINE, SCE_AHK_COMMENTBLOCK, SCE_AHK_SECTION_COMMENT, 0), NP2StyleX_Comment, L"fore:#608060" },
	{ MULTI_STYLE(SCE_AHK_STRING_SQ, SCE_AHK_STRING_DQ, SCE_AHK_HOTSTRING_VALUE, 0), NP2StyleX_String, L"fore:#008000" },
	{ MULTI_STYLE(SCE_AHK_HOTSTRING_OPTION, SCE_AHK_HOTSTRING_KEY, 0, 0), NP2StyleX_HotString, L"fore:#C08000" },
	{ SCE_AHK_HOTKEY, NP2StyleX_HotKey, L"fore:#7C5AF3" },
	{ SCE_AHK_SENTKEY, NP2StyleX_SendKey, L"fore:#8080FF" },
	{ MULTI_STYLE(SCE_AHK_SECTION_SQ, SCE_AHK_SECTION_DQ, SCE_AHK_SECTION_NQ, SCE_AHK_SECTION_OPTION), NP2StyleX_Section, L"fore:#F08000" },
	{ SCE_AHK_ESCAPECHAR, NP2StyleX_EscapeSequence, L"fore:#0080C0" },
	{ SCE_AHK_FORMAT_SPECIFIER, NP2StyleX_FormatSpecifier, L"fore:#7C5AF3" },
	{ SCE_AHK_LABEL, NP2StyleX_Label, L"fore:#C80000; back:#F4F4F4" },
	{ SCE_AHK_NUMBER, NP2StyleX_Number, L"fore:#FF0000" },
	{ SCE_AHK_OPERATOR, NP2StyleX_Operator, L"fore:#B000B0" },
};

EDITLEXER lexAutoHotkey = {
	SCLEX_AUTOHOTKEY, NP2LEX_AUTOHOTKEY,
//Settings++Autogenerated -- start of section automatically generated
		LexerAttr_PrintfFormatSpecifier,
		TAB_WIDTH_4, INDENT_WIDTH_4,
		(1 << 0) | (1 << 1), // class, function
		0,
		'`', SCE_AHK_ESCAPECHAR, SCE_AHK_FORMAT_SPECIFIER,
		0,
		0, 0,
		SCE_AHK_OPERATOR, 0
		, KeywordAttr32(0, KeywordAttr_MakeLower | KeywordAttr_PreSorted) // keywords
		| KeywordAttr32(1, KeywordAttr_NoLexer | KeywordAttr_NoAutoComp) // directives
		| KeywordAttr32(2, KeywordAttr_NoLexer | KeywordAttr_NoAutoComp) // compiler directives
		| KeywordAttr32(3, KeywordAttr_MakeLower | KeywordAttr_PreSorted) // objects
		| KeywordAttr32(4, KeywordAttr_MakeLower | KeywordAttr_PreSorted) // built-in variables
		| KeywordAttr32(5, KeywordAttr_MakeLower | KeywordAttr_PreSorted) // keys
		| KeywordAttr32(6, KeywordAttr_MakeLower | KeywordAttr_PreSorted) // functions
		| KeywordAttr64(7, KeywordAttr_NoLexer) // misc
		, SCE_AHK_TASKMARKER,
		SCE_AHK_SECTION_SQ, SCE_AHK_FORMAT_SPECIFIER,
//Settings--Autogenerated -- end of section automatically generated
	EDITLEXER_HOLE(L"AutoHotkey Script", Styles_AHK),
	L"ahk; ia; scriptlet",
	&Keywords_AHK,
	Styles_AHK
};
