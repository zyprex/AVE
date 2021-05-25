; vim:fen:fdm=marker:fmr=;;,;.
;; autohotkey vi-mode for windows explorer
 ;
 ;
 ;
#NoEnv
#Warn
#SingleInstance, Force
#Persistent
SendMode Input
SetWorkingDir %A_ScriptDir%
;.
;; global value
AppName := "AVE-0.1.1"
confini := "AVE-CONF-self.ini"
AVE     := 1
gkey    :=  ; global key
;.
;; read confini file
If FileExist(confini){
    iniConf := [ "section" ,"app" ,"terminal" ,"path_template" ,"path_register" ]
    ; section "conf"
    Loop % iniConf.Length()
    {
      conf_name := % iniConf[A_Index]
      IniRead, %conf_name%, %confini% , conf, %conf_name%
    }
    ; app[0-9]
    Loop, 10
    {
        digit := Chr(A_Index + 47)
        IniRead, app%digit%, %confini%, conf, app%digit%
    }
    ; app[a-z]
    Loop, 26
    {
        alpha := Chr(A_Index + 96)
        IniRead, app%alpha%, %confini%, conf, app%alpha%
    }
}
;.
;; tray icon
Menu, Tray, NoStandard
Menu, Tray, DeleteAll
Menu, Tray, Icon, Shell32.dll, 131, 1 ; butterfly
Menu, Tray, Tip , %AppName%
Menu, Tray, Click, 1
Menu, Tray, Add, RELOAD
Menu, Tray, Add, PAUSE
Menu, Tray, Add, EXIT
Menu, Tray, Default, RELOAD
return

PAUSE:
if (A_IsSuspended)
    ;Menu, Tray, Icon , msn_butterfly.ico,,1
    Menu, Tray, Icon , Shell32.dll, 131,1
Else
    Menu, Tray, Icon , Shell32.dll, 110,1 ; ban symbol
Suspend, Toggle
return

RELOAD:
reload
return

EXIT:
exitapp
return
;.
;; context enable
~Esc::
~Enter::
~#a::
~#d::
~#u::
~#e::
~#x::
AVE=1
return
;.
;; repair key
#1::#1
#2::#2
#3::#3
#4::#4
#5::#5
#6::#6
#7::#7
#8::#8
#9::#9
!p::!p
;.
;; main key
#If AVE && WinActive("ahk_exe explorer.exe")
;; context disable
i::
~F2::
~^+n::
~#r::
AVE=
return
;.
;; move
h::Left
j::Down
k::Up
l::Right
a::Home
g::End
e::PgUp
d::PgDn
-::Send !{Up}
[::Send !{Left}
]::Send !{Right}
^[::Send {Esc}
+/::Appskey
t::toWhich()
f::
    gkey := getKey()
    SendRaw % gkey
return
`;::SendRaw % gkey
;.
;; edit
y::^c
p::^v
c::^x
r::
AVE=
Send {F2}
return
u::^z
^r::Send ^y
;.
;; preview text file
,::previewFrameCreate()
.::
previewFrameGuiClose:
previewFrameGuiEscape:
    Gui, previewFrame:Destroy
    SetTimer, IDLE_DETECT, Off
return
;.
;; move in one folder
x::moveInFolder()
;.
;; clipboard
\::
    ClipBoard :=
    while !ClipBoard {
        Send ^c
        sleep 200
        ClipBoard := ClipBoard
    }
    MsgBox,,%AppName%: file path copied, % ClipBoard
return
; #include Vier-register.ahk
b::clipbrdRegWrite()
+b::clipbrdRegRead()
;.
;; open with
v::
    files := getPathCB("oneline")
    if files
        Run, % app " " files ,,UseErrorLevel
return
^v::
    gkey  := getKey()
    files := getPathCB("oneline")
    if files
        Run, % app%gkey% " " files ,,UseErrorLevel
return
:::Run, %terminal%, % getPathCB("dir")
;.
;; template fiile
n::putTemplate()
;.
;; ini launcher
s::azDisk()
o::runInstant(confini, "open" , 0)
'::runInstant(confini, section, 0)
"::runInstant(confini, section, 1)
m::setMark(confini, section)
+m::delMark(confini, section)
^m::selMarkGroup(confini, "forward" )
^+m::selMarkGroup(confini, "backward")
;.
;; zip archieve
; z::cmdBandizip()    ; (Bandizip)zipFile
z::cmdPeazip()    ; (Peazip)
;.
q::queryStart(confini, "query")
; /::MsgBox % getPathCB("dir")
; =::MsgBox % getPathCB("dir")
#If ; AVE && WinActive("ahk_exe explorer.exe")
;.

;; label: tooltip hide
HIDE_TOOLTIP:
ToolTip
return
;.
;; function: return one key
getKey(){
    Suspend ON
    Input, key, L1
    Suspend OFF
    if ( key = Chr(27) ) ; esc ascii code
        return
    return key
}
;.
;; function: to focus control
toWhich() {
  ControlGetFocus, Focused
  ControlGetPos, X, Y, , , %Focused%
new_hint=
(
To...
  t TreeView
  l ListView
  a AddressBar
  f FiltFile
  h Header
  p previewArea
)
ToolTip,%new_hint%,%X%,%Y%
  key := getKey()
  if(key="t"){
    ControlFocus, SysTreeView321
  }
  if(key="l"){
    ControlFocus, SysListView321
    ControlFocus, DirectUIHWND3
    ControlFocus, DirectUIHWND2
  }
  if(key="a"){
    ControlFocus, Edit1
    Send {F4}
  }
  if(key="f"){
    ControlFocus, DirectUIHWND1
    Send {F3}
  }
  if(key="h"){
    ControlFocus,SysHeader321
  }
  if(key="p"){
    ControlFocus, RICHEDIT50W1
  }
  ; if (ErrorLevel = "Max") ;   return
  ControlGetFocus, Focused
  ControlGetPos, X, Y, , , %Focused%
  ToolTip, You Get Me!, %X%, %Y%
  SetTimer, HIDE_TOOLTIP, -1000
}
;.
;; function: use clipboard to get file path
getPathCB(form){
    ClipSaved := ClipboardAll
    Clipboard :=
    while !ClipBoard {
        Send ^c
        sleep 200
        ClipBoard := ClipBoard
        if !Clipboard
            ToolTip ... try to send Ctrl+C
        if GetKeyState("Esc")
            break
    }
    ToolTip
    path      := Clipboard
    Clipboard := ClipSaved
    ClipSaved :=
    if (form="oneline") { ; format "/./.""/./."
        return """" StrReplace(path,"`r`n",""" """) """"
    }
    else if (form="dir") {
        if InStr(path, "`r`n") ; has multiple path
            path := SubStr(path, 1, InStr(path, "`r`n"))
        SplitPath, path,, dir
        return dir
    }
    return path
}
;.
;; function: text preview frame
previewFrameCreate(){
    global AppName, file, PText, alltext
    file := getPathCB("")
    FileRead, alltext, *P65001 %file%
    pFrameTitle := AppName ">>>" file
    if !WinExist( pFrameTitle ){
        Gui, previewFrame:default
        Gui, -DPIScale +AlwaysOnTop +LastFound -ToolWindow +Resize +Caption
        Gui, Margin, 2, 2
        Gui, font, s10 q5, Consolas
        Gui, Add, Edit, w800 h600 vPText Wrap, % alltext
        Gui, Show, NoActivate w800 h600 , %pFrameTitle%
        WinSet, Transparent, 200, %pFrameTitle%
        alltext:= ; free memory
        SetTimer, IDLE_DETECT, 100
    }
}
IDLE_DETECT:
if( A_TimeIdle > 1000 )&&( WinActive("ahk_exe explorer.exe") ){
    newfile := getPathCB("")
    if (newfile != file){
        FileRead, alltext, *P65001 %newfile%
        GuiControl, previewFrame:, PText, % alltext
    }
    file := newfile
}
return
previewFrameGuiSize:
GuiControl, Move, PText, % "w" A_GuiWidth " h" A_GuiHeight
return
;.
;; function: move in one folder
moveInFolder(){
    bund  := getPathCB("")
    abund := SubStr(bund, 1, InStr(bund,"`r`n"))
    SplitPath, abund, ,dir
    InputBox, UserInput, new directory, Please enter new directory name:,,250,150
    if ErrorLevel
        return ; MsgBox, CANCEL was pressed.
    else {
        dest := dir "\" UserInput
        if FileExist( dest ) {
            MsgBox, 0x131, Exist DIR
            , The directory is already exist`, continue to use as destination ?
            IfMsgBox Cancel
                return
        }
        else {
            FileCreateDir, % dest
        }
    }
    Loop, Parse, bund, `r`n
    {
        FileGetAttrib, Attr, % A_LoopField
        If InStr(Attr, "D") {          ; The file is Directory.
            SplitPath, A_LoopField, , , , name_no_ext
            FileMoveDir, % A_LoopField , % dest "\" name_no_ext, R
        } Else {
            FileMove, % A_LoopField , % dest
        }
    }
}
;.
;; function: clipboard write and read
clipbrdRegWrite() {
    global path_register
    IfNotExist, %path_register%\
        FileCreateDir, %path_register%
hint=
(
b save to register...
| null
\ null
: execute every line of clipbrd
/ count clipbrd words
? view text content on clipbrd
" list .cb file
* open "register.txt"
< insert clipbrd text to "register.txt"
> apphend clipbrd text to "register.txt"
)
    ToolTip % hint
    key := getKey()
    ToolTip
    if key not in \,|,/,:,*,?,",<,>
    {
        ; unconditionally overwritten (i.e. FileDelete is not necessary).
        if key is not Space
        {
            FileAppend, %ClipboardAll%, %path_register%\%key%.cb
            sleep 1000
            if(FileExist(path_register "\" key ".cb")){
                ToolTip % "save clipbrd to " key ".cb!"
                SetTimer, HIDE_TOOLTIP, -1000
            }
        }
        return
    }
    if (key="/") {
       countWords(ClipBoard) 
    }
    if (key="""") {
        cb_list=
        Loop, Files, %path_register%\*.cb, F 
        {
            FormatTime, time_created, %A_LoopFileTimeCreated%, yyyy/MM/dd - HH:mm 
            cb_list .= A_LoopFileName "`t" time_created "`n"
        }
        MsgBox % cb_list
    }
    if (key=":") {
        Loop, Parse, ClipBoard,`r`n
            Run, %A_LoopField%,,UseErrorLevel
    }
    if (key="?") {
        MsgBox % ClipBoard
    }
    if (key="*") {
        Run, %path_register%\register.txt,,UseErrorLevel
    }
    if (key=">") {
        FileAppend, % "`n" StrReplace(ClipBoard,"`r","")
                    , %path_register%\register.txt, UTF-8
    }
    if (key="<") {
        FileRead, tempX, %path_register%\register.txt
        tempX := ClipBoard "`n" tempX
        StringReplace, tempX, tempX,`r,, All
        FileDelete, %path_register%\register.txt
        FileAppend, %tempX%, %path_register%\register.txt, UTF-8
        tempX :=
    }
    ToolTip
}

clipbrdRegRead(){
    global path_register
hint=
(
B read from register...
exceptional key * read 'register.txt' content
if your .cb is file, it will show text but can't be paste in editor!
----------------------------------------

)
  cb_list=
  Loop, Files, %path_register%\*.cb, F
  {
    FormatTime, time_created, %A_LoopFileTimeCreated%, yyyy/MM/dd - HH:mm 
    cb_list .= A_LoopFileName "`t" time_created "`n"
  }
  ToolTip % hint cb_list
  key := getKey()
  ToolTip
  if (key="*") {
    FileRead, Clipboard, %path_register%\register.txt
  }
  if key not in \,|,/,:,*,?,",<,>
  {
    FileRead, Clipboard, *c %path_register%\%key%.cb
    if ClipBoard is not space
        MsgBox % Clipboard
  }
}

countWords(txt){
    if txt=
      return
; RegExReplace(txt,"(https|http):\/\/\S+",,url)
; RegExReplace(txt,"[C-Z]:\\.*",,file)
RegExReplace(txt,"\n",,line)
RegExReplace(txt,"[^\x00-\xff]",,zh)
RegExReplace(txt,"[，。；：‘’“”【】、！￥……（）——？]",,zhp)
RegExReplace(txt,"[a-zA-Z0-9[:punct:]]+",,en)
RegExReplace(txt,"[[:punct:]]",,enp)
RegExReplace(txt,"[0-9]",,num)
RegExReplace(txt,"[[:alpha:]]+",,word)
; Than := % Tzh-Tzhp
; Tall := % Tzh+Ten
    MsgBox % "Line " line
        . "`nzh " zh    "`nzhp " zhp
        . "`nen " en    "`nenp " enp
        . "`nnum " num  "`nword " word
        . "`n------------`nabout " en+zh
}
;.
;; function: template new file
isEmptyFolder(dir){
  Loop, Files, %dir%, FD
      return 0
  return 1
}
putTemplate(){
    global path_template, cwd, f_list := {}
    IfNotExist, %path_template%\
    {
        FileCreateDir, %path_template%
        return
    }
    pattern = %path_template%\*
    if isEmptyFolder(pattern) ; because we can't get file directory in empty folder
        return
    VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
    Loop, Files, %pattern%, FD  ; Recursive File and Directory
    {
        f_list[A_LoopFileName] := A_LoopFileLongPath
        Menu f_temp, Add, %A_LoopFileName%, TEMPLATE_PASTE
        IF DllCall("shell32\SHGetFileInfoW", "wstr", A_LoopFileFullPath
                , "uint", 0, "ptr", &fileinfo, "uint", fisize, "uint", 0x100)
        {
            hicon := NumGet(fileinfo, 0, "ptr")
            Menu f_temp, Icon, %A_Index%&, HICON:%hicon%
        }
    }
    MouseGetPos , , Y
    cwd := % getPathCB("dir")
    if (cwd) {
        ToolTip, % cwd, , % Y-50
        SetTimer, HIDE_TOOLTIP, -5000
        Menu f_temp, Show
    }
}
TEMPLATE_PASTE:
FileGetAttrib, Attributes, % f_list[A_ThisMenuItem]
If InStr(Attributes, "D") {          ; The file is Directory.
  FileCopyDir, % f_list[A_ThisMenuItem] , %  cwd "\" A_ThisMenuItem
} Else {
  FileCopy, % f_list[A_ThisMenuItem] , % cwd
}
goto HIDE_TOOLTIP
;.
;; function: open dick a-z
azDisk() {
    drive_inform=
    DriveGet, list, List
    Loop, Parse, list
    {
        DriveGet, label, Label, %A_LoopField%:\
        if label is space
            label=... ...
        drive_inform .= Format("{1:3s}:\  [ {2:} ]",A_LoopField,label)
        DriveGet, type, Type, %A_LoopField%:\
        DriveGet, status, Status, %A_LoopField%:\
        DriveGet, fs, FileSystem, %A_LoopField%:\
        drive_inform .= Format("`t {1:-9s} {2:-9s} {3:-9s}", type, status ,fs)
        DriveSpaceFree, free, %A_LoopField%:\
        DriveGet, cap, Capacity, %A_LoopField%:\
        if free is not space
            drive_inform .= Format("`t ( {1:6.2f} / {2:6.2f} GB ) ", free/1024, cap/1024)
                            drive_inform .= "`n"
    }
    ToolTip % "input char to choose one disk`n`n" drive_inform
    key := getKey()
    Run, % key  ":\",,UseErrorLevel
    ToolTip, % ErrorLevel="ERROR" ? ":( No Such Disk"
                                  : Format(":) Launch... {:U}:\", key)
    SetTimer, HIDE_TOOLTIP, -1000
}
;.
;; function: ini file operate -- get key name, key list, key exist?
getIniKeyName(confini, section){
    IniRead, list, %confini%, %section%
    kn_list =
    Loop, Parse, list,`n
        kn_list .= SubStr(A_LoopField, 1,InStr(A_LoopField,"=")-1) "`n"
;     MsgBox %k_list%
    return kn_list
}
getIniKeyList(confini, section){
    IniRead, list, %confini%, %section%
    k_list:={}
    Loop, Parse, list,`n
        k_list[SubStr(A_LoopField , 1,InStr(A_LoopField,"=")-1)]
            := SubStr(A_LoopField , InStr(A_LoopField,"=")+1)
    ; for k, v in  k_list ;MsgBox % k " ***** " v
    return k_list
}
hasIniVal(confini, section,Key, ByRef Val) {
    IniRead, tryIt, %confini%, %section%, %Key%, ERROR
    if tryIt=ERROR
        return 0
    else {
        Val:=tryIt
        return 1
    }
}
;.
;; function: execute int val as command -- path, web, executable file etc.
runInstant(confini, section, IsAdmin) {
    if IsAdmin
        ToolTip % "**** ExecAdmin ****`nOpen ... ...[ " section " ]`n"
                . getIniKeyName(confini, section)
    else
        ToolTip % "Open ... ...[ " section " ]`n"
                . getIniKeyName(confini, section)
    key := getKey()
    ToolTip
    for k, v in  getIniKeyList(confini, section) {
        if (SubStr(k,1,1) == key) {
            runIniVal(confini, section, k, IsAdmin)
        }
    }
    return
}
runIniVal(confini, section, keyname, IsAdmin) {
    local cwd, Val
    if !(cwd := getPathCB("dir"))
        return
    ; if !cwd ;     return ; WinGetActiveTitle, cwd ; ToolTip % cwd
    if hasIniVal(confini, section, keyname, Val) {
        ToolTip % StrReplace(Val, """""", "`n")
        SetTimer, HIDE_TOOLTIP, -1500
        ; for multiple value write as "1""2" ... etc.
        Loop, Parse, Val,""
        {
            if (IsAdmin)
                Run, *RunAs %A_LoopField%, %cwd%, UseErrorLevel
            else
                Run, %A_LoopField%, %cwd%, UseErrorLevel
        }
    }
}
;.
;; function: mark set and delete
setMark(confini, section) {
    paths := Trim(getPathCB("oneline"), """")
    paths := StrReplace(paths,""" ""","""""")
    path := getPathCB("")
    if !paths
        return
    ToolTip % "[ " section " ] Mark ... ... ?`n> " path
    key := getKey()
    if (!key) {
        ToolTip
        return
    }
    ToolTip
    Val= ; pass value by ref
    if hasIniVal(confini, section, key, Val) {
        MsgBox, % 4+32+256 , , % "> Mark '" key "' is already set to :`n"
            . StrReplace(Val, """""", "`n")
            . "`n> Do you want to replace by :`n" path
        IfMsgBox, Yes
            confirmMark(confini, section, key, paths)
    } else {
        confirmMark(confini, section, key, paths)
    }
    return

}
confirmMark(confini, section, keyname, value) {
    if InStr(value, "`n") {
        StringReplace, value, value,`n,"", All
        StringReplace, value, value,`r,  , All
    }
    MsgBox, % 1+64,, % "[ " section " ] > Mark `n"
                   . keyname "=""" value """"
    IfMsgBox, Ok
        IniWrite, % """" value """" , %confini%, %section%, %keyname%
}
delMark(confini, section){
    ToolTip % "[ " section " ] > delete Mark ... ...`n" 
            . getIniKeyName(confini, section)
    key := getKey()
    if (!key) {
        ToolTip
        return
    }
    ToolTip
    if hasIniVal(confini, section, key, Val) {
        MsgBox, % 4+32+256 , , % "> Delete Mark '" key "':`n" Val
        IfMsgBox, Yes
            IniDelete, %confini%, %section%, %key%
    }
    return
}
;.
;; function: switch mark group
selMarkGroup(confini, direct) {
    ; ~~~~~~ read all sections in *.ini file ~~~~~~
    global section
    mglist:={}, cnt=0, mg_index=0
    Loop, Read, %confini%
    {
        RegExMatch(A_LoopReadLine , "^\[(.+)\]", match)
        If (match1="conf") or (match1="open") or (match1="query") ; exculde [..]
            continue
        Else If (match1=section) {
            mglist[cnt] := match1
            mg_index    := cnt
            cnt += 1
        }
        Else If (match1) {
            mglist[cnt] := match1
            cnt += 1
        }
    }
    if(direct="forward")
        next_cnt := mg_index + 2 > cnt ?  0     : mg_index + 1
    else if(direct="backward")
        next_cnt := mg_index - 2 < -1  ?  cnt-1 : mg_index - 1
    section := mglist[next_cnt]
    mg_tip  :=
    for k,v in mglist {
        if (v=section)
            mg_tip .= " [ " v " ] <-- <M>`n"
        else
            mg_tip .= " [ " v " ]`n"
    }
    ToolTip % mg_tip
    SetTimer, HIDE_TOOLTIP, -1000
}
;.
;; function: (Bandizip)zipFile
cmdBandizip() {
    bz_fullpath := getPathCB("")
    if !bz_fullpath
        return
    if InStr(bz_fullpath,"`r`n")
        return
    SplitPath, bz_fullpath, name, dir, ext, name_no_ext
    new_Hint=
(
FILE_NAME: "%name%"
{Powerd by Bandizip ...}
z create .zip
7 create .7z
x extract
)
  ; ControlGetFocus, Focused
  ; ControlGetPos, X, Y, W, H, %Focused%
  ; ToolTip, % new_hint , % X + W , % Y + H
  ToolTip % new_hint
  key := getKey()
  if (key="z"){
    Run, % "Bandizip.exe cd """
           . dir "/" name_no_ext ".zip"" """
           . bz_fullpath """",,UseErrorLevel
  }
  if (key="7"){
    Run, % "Bandizip.exe cd """
          . dir "/" name_no_ext ".7z"" """
          . bz_fullpath """",,UseErrorLevel
  }
  if (key="x"){
    Run, % "Bandizip.exe x -o:"""
            . dir """ """  bz_fullpath """",,UseErrorLevel
  }
  ToolTip
}
;.
;; function: (Peazip)
cmdPeazip() {
    pz_fullpath := getPathCB("")
    if (!pz_fullpath)
        return
    if InStr(pz_fullpath,"`r`n") {
        pz_fullpath := """" . StrReplace(pz_fullpath, "`r`n" , """ """) . """"
    }
    else {
        pz_fullpath := """" . pz_fullpath  . """"
    }
    new_Hint=
(
{Powerd by Peazip ...}
* add2archive
p add2pea
7 add27z
z add2zip
x ext2here
f ext2folder
l ext2list
)
    ToolTip % new_hint
    pzexe="C:\Program Files\PeaZip\peazip.exe"
    key := getKey()
    if (key="*")
        Run % pzexe . " -add2archive " . pz_fullpath
    if (key="p")
        Run % pzexe . " -add2pea " . pz_fullpath
    if (key="7")
        Run % pzexe . " -add27z " . pz_fullpath
    if (key="z")
        Run % pzexe . " -add2zip " . pz_fullpath
    if (key="x")
        Run % pzexe . " -ext2here " . pz_fullpath
    if (key="f")
        Run % pzexe . " -ext2folder " . pz_fullpath
    if (key="l")
        Run % pzexe . " -ext2list " . pz_fullpath
    ToolTip
}
;.
;; function: query string on internet
queryStart(confini, section){
    global QB1, QB2
    CoordMode, ToolTip , Screen
    ToolTip, % getIniKeyName(confini, section), 0, 0
    Gui, queryBox:default
    Gui, +OwnDialogs
    Gui, font, s16 q5, Consolas
    Gui, Add, Edit, r1 w310,
    Gui, font, s14
    Gui, Add, Button, x+10            gURLCPY, &copy url
    Gui, Add, Button, w0 x+1 +default gSUBMIT, &submit
    Gui, Show
}
querySubmit(confini, section, type){
    Gui, queryBox:default
    GuiControlGet, UserInput,,Edit1
    ; MsgBox %UserInput% ; InputBox, UserInput, queryStart, <char> <search_strings>,,250,160
    for k, v in getIniKeyList(confini, section) {
        if (SubStr(k,1,1)==SubStr(UserInput, 1, 1)) and (SubStr(UserInput,2,1)==" ") {
            if(type)
                Run, % StrReplace(v, "%s", SubStr(UserInput, 3)),, UseErrorLevel
            else
                ClipBoard := StrReplace(v, "%s", SubStr(UserInput, 3))
        }
    }
    ToolTip
}
SUBMIT:
    querySubmit(confini,"query",1)
    goto queryBoxGuiClose
URLCPY:
    querySubmit(confini,"query",0)
    goto queryBoxGuiClose
queryBoxGuiEscape:
queryBoxGuiClose:
    Gui, queryBox:Destroy
    ToolTip
return
;.

;; #GLOBAL#  function + key : window_switcher #F1 #F2 #F3 #PrintScreen
; RShift::SendInput {LCtrl}{LShift}
#/::windowSwitcher(0,0,32,"Microsoft Text Input Application")
; "WindowsInternal.ComposableShell.Experiences.TextInput.InputApp.exe -- Microsoft Text Input Application")
    ; some exclude windows
    ; ,"Microsoft Text Input Application
    ; ,CN=Microsoft Windows
    ; , O=Microsoft Corporation
    ; , L=Redmond, S=Washington, C=US
    ; ,Windows Shell Experience
    ; ,Dynamic Theme")
; #F7::windowTitleGet()
; windowTitleGet() {
;     WinGet, id, list ,,, Program Manager
;     win_list=
;     Loop, %id% {
;         this_id := id%A_index%
;         WinGetTitle, this_title, ahk_id %this_id%
;         win_list .= this_title "`n"
;     }
;     MsgBox % win_list
; }
windowSwitcher(menuX,menuY,iconSize,blacklist) {
    VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
    list_cnt=0
    WinGet, id, list ,,, Program Manager
    WinGetTitle, currentTitle, A
    Loop, %id% {
        this_id := id%A_index%
        WinGetTitle, this_title, ahk_id %this_id%
        if this_title in %currentTitle%
            continue
        else if this_title contains %blacklist%
            continue
        else if (this_title<>"") {
            list_cnt++
            WinGet, this_exe, ProcessName, ahk_id %this_id%
            WinGet, this_exe_path, ProcessPath, ahk_id %this_id%
            menu_text :=  this_exe " -- " this_title
            if (!Mod(list_cnt,6))
                Menu, WSW, Add, %menu_text%, HandleWSW, +BarBreak
            else
                 Menu, WSW, Add, %menu_text%, HandleWSW, -BarBreak
            if DllCall("shell32\SHGetFileInfoW", "wstr", this_exe_path
                , "uint", 0, "ptr", &fileinfo, "uint", fisize, "uint", 0x100) {
                fhicon := NumGet(fileinfo, 0, "ptr")
                Menu, WSW, Icon, %menu_text% , HICON:%fhicon%,-1,%iconSize%
            }
        }
    }
    Menu, WSW, Show, %menuX%,%menuY%
    Menu, WSW, DeleteAll
}

HandleWSW:
WinActivate % SubStr(A_ThisMenuItem,inStr(A_ThisMenuItem," -- ")+StrLen(" -- "))
return
; win + F1 F2 F3 #F1::setWinExStyle("Topmost")
#F1::setWinExStyle("Topmost")
#F2::setWinExStyle("Hide Caption")
#F3::setWinExStyle("Transparent")
; #F11::
; WinGetActiveTitle actTitle
; WinGet, wList, List
; Loop % wList
;    WinMaximize % "ahk_id " wList%A_Index%
; WinActivate % actTitle
; return
~#PrintScreen::
sleep 1000
Run, C:\Users\%A_UserName%\Pictures\Screenshots
return
setWinExStyle(sty) {
  WExStyle=
  if (sty="Topmost") {
    WinSet, AlwaysOnTop, Toggle, A
    WinGet, ExStyle, ExStyle, A
    WExStyle:=( (ExStyle&0x8) ? "Set Topmost" : "Cancel Topmost")
  }
  if (sty="Hide Caption") {
    WinSet, Style, ^0x0C00000, A   ;(WS_CAPTION)
    WinGet, Style, Style, A
    WExStyle:=( !(Style&0x0C00000) ? "Hide Caption" : "Show Caption")
  }
  if (sty="Transparent") {
    WinGet, winTrans, Transparent, A
    if (winTrans="") {
      WinSet, Transparent, 160, A
      WExStyle:= % "transparent " 160*100//255 " %"
    } else {
      WinSet, Transparent, Off, A
    }
  }
  if A_ThisHotkey=#F12
  {
    ; WinSet, Style, ^0x8000000, A   ; (WS_DISABLED) 
    ; WinGet, Style, Style, A
    ; WExStyle:=( (Style&0x8000000) ? "Disabled" : "Cancel Disabled")
  }
  if WExStyle<>
  {
    WinGetPos , X, Y, Width, Height
    CoordMode, ToolTip, Client
    ToolTip, %WExStyle%,% Width*A_ScreenDPI,0
    Sleep 1000
    ToolTip
  }
  return
}
;.
