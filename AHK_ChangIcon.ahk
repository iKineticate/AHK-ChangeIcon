;// @Name                   AHK ChangeIcon
;// @Author                 iKineticate(Github)
;// @Version                v2.1
;// @Destription:zh-CN      快速更换桌面快捷方式图标
;// @Destription:en         Quickly change of desktop shortcut icons
;// @HomepageURL            https://github.com/iKineticate/AHK ChangeIcon
;// @Icon Source            www.flaticon.com
;// @Icon Source            www.iconfont.cn
;// @Reference:Tab          https://www.autohotkey.com/boards/viewtopic.php?f=83&t=95676&p=427160&hilit=menubar+theme#
;// @Date                   2023/11/01

;@Ahk2Exe-SetVersion 2.1
;@Ahk2Exe-SetFileVersion 2.1
;@Ahk2Exe-SetProductVersion 2.1
;@Ahk2Exe-SetName AHK ChangeIcon
;@Ahk2Exe-ExeName AHK ChangeIcon
;@Ahk2Exe-SetProductName AHK ChangeIcon
;@Ahk2Exe-SetDescription AHK ChangeIcon

#Requires AutoHotkey >=v2.0
#SingleInstance Ignore
#Include "AHK_Base64PNG.ahk"
#Include "AHK_Language.ahk"

SetControlDelay(0)
SetWinDelay(0)

; 以管理员身份运行AHK
Full_command_line := DllCall("GetCommandLine", "str")
If not (A_IsAdmin OR RegExMatch(Full_command_line, " /restart(?!\S)"))
{
    Try
    {
        If A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        Else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

; 创建窗口、添加标题、允许重绘窗口大小
; 不用添加"+resize"调节窗口，避免在show之后"-resize"标题栏闪烁
MyGui := Gui("-Caption +Border", "AHK ChangeIcon")              ; +E0x02000000 +E0x00080000可以考虑这个避免窗口闪烁
MyGui.BackColor := "262626"
MyGui.SetFont("s11 Bold cffffff", "Microsoft YaHei")            ; 设置其他颜色会导致单选按钮的样式改变
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.OnEvent("Size", MyGui_Size)

; 自建窗口标题栏：宽度自适应
Caption := MyGui.AddText("x0 y0 h25 c8042c0 Background202020 vCaption +0x200","`sAHK`sChangeIcon")
Caption.SetFont("s12")
; 关闭按钮：x坐标自适应
MyGui.Close_Pic := MyGui.AddPicture("yp w36 h25", "HICON:" Base64PNG_to_HICON(Close_Base64PNG, height := 56))
MyGui.Close_Cursor := MyGui.AddPicture("yp wp hp Hidden", "HICON:" Base64PNG_to_HICON(Close_Cursor_Base64PNG, height := 56))
MyGui.Close_Btn := MyGui.AddButton("yp wp hp +0x4000000 -Tabstop vClose_Btn")
; 最大化按钮：x坐标自适应
MyGui.Maximize_Pic := MyGui.AddPicture("yp wp hp", "HICON:" Base64PNG_to_HICON(Maximize_Base64PNG, height := 56))
; 最小化按钮：x坐标自适应
MyGui.Minimize_Pic := MyGui.AddPicture("yp wp hp", "HICON:" Base64PNG_to_HICON(Minimize_Base64PNG, height := 56))
MyGui.Minimize_Cursor := MyGui.AddPicture("yp wp hp Hidden", "HICON:" Base64PNG_to_HICON(Minimize_Cursor_Base64PNG, height := 56))
MyGui.Minimize_Btn := MyGui.AddButton("yp wp hp +0x4000000 -Tabstop vMinimize_Btn")

; 标签页的背景：高度自适应
Tab_Background := MyGui.AddPicture("x0 y25 w150 Background202020")

; 添加Logo
Logo := MyGui.AddPicture("x43 y+5 w64 h64 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Logo_Base64PNG, height := 480))

; 创建Tab2标签页
Tab := MyGui.AddTab("x0 y0 w0 h0 -Wrap -Tabstop +Theme vTabControl")

; 后面的控件的显示不受标签页影响
Tab.UseTab()

; 标签页焦点、鼠标下位标签页时的高亮（Text代替）
Tab_Focus_1 := MyGui.AddPicture("x5 y101 w140 h36 Background0x343434") 
Tab_Focus_2 := MyGui.AddPicture("x5 y110 w5 h18 Background0x8042c0") 
MyGui.Tab_Cursor := MyGui.AddPicture("x5 y101 w140 h36 Background0x343434 Hidden")
MyGui.Ctrl_Cursor := ""

; 每项标签页前面添加图标
MyGui.AddPicture("x14 y110 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Home_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Others_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Log_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(About_Base64PNG, height := 224))

; 从Naigation中将各个名字的添加至标签页然后创建
Loop Navigation.Label.Length
{ 
    Tab.Add([Navigation.Label[A_Index]])

    ; 创建透明背景(可以显示颜色方块)的文本，代表标签页名字
    ; 0x200：垂直居中显示文本.
    Tab_Item := MyGui.AddText("x5 y" (40*A_Index) + 59 " h40 w140 +0x200 BackgroundTrans vTab_Item" . A_Index
        , "`s`s`s`s`s`s`s`s" Navigation.Label[A_Index])
    Tab_Item.SetFont("s10 cffffff")
    Tab_Item.OnEvent("Click", Tab_Focus)
    Tab_Item.Index := A_Index

    ; 打开应用时，第一标签页为默认焦点
    If (A_Index != 1)
        Continue
    MyGui.Active_Tab := Tab_Item
}

;————————————————————————————————————————第一个标签页的开始（主页）——————————————————————————————————————————————————
Tab.UseTab(1)

Show_Icon_Area := MyGui.AddPicture("x162 y37 w56 h56 -E0x200 Background333136") ; 第一个显示区域（顶部ICO显示区域）
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")                       ; 第二个显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")                       ; 第三个显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")                       ; 第四个显示区域

; 一键更换所有图标按钮
MyGui.All_Changed_Pic := MyGui.AddPicture("x+6 yp+3 w116 h50", "HICON:" Base64PNG_to_HICON(All_Changed_Pic_Base64PNG, height := 300))
MyGui.All_Changed_Cursor := MyGui.AddPicture("xp yp wp hp hidden", "HICON:" Base64PNG_to_HICON(All_Changed_Cursor_Base64PNG, height := 300))
MyGui.All_Changed_Btn := MyGui.AddButton("xp yp wp hp +0x4000000 -Tabstop vAll_Changed_Btn").OnEvent("Click", All_Changed)

; 焦点时的搜索栏的下划线
Search_Line := MyGui.AddPicture("x162 y+33 h2 Background8042c0")                    ; 宽度自适应
; 搜索框（0x4000000可以让下划线一直显示在前方，但它会添加边框，因此需-E0x200去除边框）
Search_Bar := MyGui.AddEdit("x162 yp-24 h26 Background191919 -E0x200 0x4000000")    ; 宽度自适应
Search_Bar.SetFont("cbbbbbb s13")
Search_Bar.Focus()
Search_Bar.OnEvent("LoseFocus", Search_LoseFocus)
Search_Bar.OnEvent("Focus", Search_Focus)
; 搜索按钮（x坐标自适应）
Search_Btn := MyGui.AddPicture("yp w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Search_Base64PNG, height := 64))
; 设置为默认按钮，按下Enter键可以触发搜索（隐藏起来后，按键Tab在切换控件时不会选到这个按钮）
Hidden_Btn := MyGui.AddButton("yp wp hp Default Hidden").OnEvent("Click", Search)

; 创建去除边框的列表，且宽度自适应，并赋予点击、双击、右键菜单事件
; -Redraw：关闭列表的重绘，来增快列表载入速度
; -Multi：禁止选择多行，避免出现多个图标更换错误
; -E0x200：去除边框
; +LV0x10000：双缓冲绘图，减少窗口大小变化时列表闪烁
LV := MyGui.AddListView("x162 y+6 r10 Background333136 -Redraw -Multi -E0x200 +LV0x10000", ["Name", "Y/N", "Type"])
LV.SetFont("cffffff s12")
LV.OnEvent("ItemFocus", Display_Top_Icon)
LV.OnEvent("DoubleClick", Change_Link_Icon)
LV.OnEvent("ContextMenu", Link_ContextMenu)

global Link_Map := map()                            ; 创建快捷方式(Link)的键-值数组(Map)
global Link_Yes_Count := 0                          ; 已更换图标的计数
global Logging := ""                                ; 日志的记录
global ImageListID := IL_Create()                   ; 为添加图标做好准备: 创建图像列表
LV.SetImageList(ImageListID)                        ; 为添加图标做好准备: 设置显示图标列表

For Desktop in [A_Desktop, A_DesktopCommon]
{
    Loop Files, Desktop "\*.lnk"
    {
        ; 调用WshShell对象的函数，获取link属性、目标路径、目标目录、图标路径
        Link_Path := A_LoopFilePath
        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
        Link_Target_Path := Link_Attribute.TargetPath
        Link_Target_Dir := Link_Attribute.WorkingDirectory
        ; 部分快捷方式(Office、WSA应用)属性中只存在目标路径，不存在目标目录，通过正则表达式将目标路径删除目标后变为目标目录
        Link_Target_Dir := (Link_Target_Path != "" AND Link_Target_Dir = "") ? RegExReplace(Link_Target_Path, "\\[^\\]+$"):Link_Target_Dir

        ; 获取快捷方式的目录、目标扩展名
        SplitPath(A_LoopFilePath,, &Link_Dir)
        SplitPath(Link_Target_Path,,, &Link_Target_Ext)

        Link_Name := RegExReplace(A_LoopFileName, "\.lnk$")     ; 快捷方式名称 = 去除后缀名后的名称

        Switch                                                  ; 快捷方式更换判定 = 已更换图标显示"√" && 未更换图标不显示
        {
        Case Link_Icon_Location = "" :
            Link_YesNo := ""
        Case Link_Icon_Location = Link_Target_Path :
            Link_YesNo := ""
        Case InStr(Link_Icon_Location, "WindowsSubsystemForAndroid") :
            Link_YesNo := ""
        Default :
            Link_YesNo := "√"
            global Link_Yes_Count += 1 
        }

        Switch                                                  ; 快捷方式的目标扩展名 = 转化为小写 && UWP应用为uwp && WSA应用为app
        {
        Case Link_Target_Ext = "" :
            Link_Target_Ext := "uwp"
        Case InStr(Link_Target_Path, "WindowsSubsystemForAndroid") :
            Link_Target_Ext := "app"
        Case isUpper(Link_Target_Ext) :
            Link_Target_Ext := StrLower(Link_Target_Ext)
        }

        ; 在数组Link_Map中，给"快捷方式名称+英文缩写字符"的键赋予对应的值
        ; LTP = Link Target Path = 快捷方式的目标路径（UWP无法查看）
        ; LTD = Link Target Dir  = 快捷方式的目标目录（UWP无法查看）
        ; LP  = Link Path        = 快捷方式的路径
        ; LD  = Link Dir         = 快捷方式的目录
        Link_Map[Link_Name . "LTP"] := Link_Target_Path = "" ? Safe_Text:Link_Target_Path
        Link_Map[Link_Name . "LTD"] := Link_Target_Dir = "" ? Safe_Text:Link_Target_Dir
        Link_Map[Link_Name . "LP"]  := A_LoopFilePath
        Link_Map[Link_Name . "LD"]  := Link_Dir

        ; 调用DllCall_Icon函数和图像列表替换函数，添加图标并赋予给IconNumber--刷新列表左侧图标
        IconNumber := DllCall("ImageList_ReplaceIcon"
            , "Ptr", ImageListID
            , "Int", -1
            , "Ptr", DllCall_Icon(A_LoopFilePath)) + 1
        DllCall("DestroyIcon", "Ptr", DllCall_Icon(A_LoopFilePath))

        ; 列表添加图标、名称、"√"、目标扩展名
        LV.Add("Icon" . IconNumber, Link_Name, Link_YesNo, Link_Target_Ext)
    }
}

; 先让第一行（名称）排列，在让第三行（扩展名）排列，就可以保证排列顺序以扩展名为主，名称为次
LV.ModifyCol(1, "+Sort")                    
LV.ModifyCol(2, "+Center")
LV.ModifyCol(3, "+Center +Sort")

; 在第二~四的显示区域显示对应的更换、未更换、总共数量
Changed_Count_Title := MyGui.AddText("x224 y42 w56 h23 +Center +0x200 BackgroundTrans", Yes_Text)
UnChanged_Count_1_Title := MyGui.AddText("x286 y42 w56 h23 +Center +0x200 BackgroundTrans", No_Text)
All_Count_1_Title := MyGui.AddText("x348 y42 w56 h23 +Center +0x200 BackgroundTrans", All_Text)

Changed_Count := MyGui.AddText("x224 y65 w56 h23 +Center +0x200 BackgroundTrans", Link_Yes_Count)
UnChanged_Count_1 := MyGui.AddText("x286 y65 w56 h23 +Center +0x200 BackgroundTrans", LV.GetCount() - Link_Yes_Count)
All_Count_1 := MyGui.AddText("x348 y65 w56 h23 +Center +0x200 BackgroundTrans", LV.GetCount())
;————————————————————————————————————————第一个标签页的结束（主页）——————————————————————————————————————————————————



;————————————————————————————————————————第二个标签页（更多功能）的开始———————————————————————————————————————————————
Tab.UseTab(2)
MyGui.AddPicture("x162 y37 w56 h56 -E0x200 Background333136")   ; 第一个显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")   ; 第二个显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")   ; 第三个显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136")   ; 第四个显示区域

UnChanged_Count_2_Title := MyGui.AddText("x286 y42 wp h23 +Center +0x200 BackgroundTrans", No_Text)
All_Count_2_Title := MyGui.AddText("x348 yp wp hp +Center +0x200 BackgroundTrans", All_Text)

UnChanged_Count_2 := MyGui.AddText("x286 y65 wp hp +Center +0x200 BackgroundTrans", LV.GetCount() - Link_Yes_Count)
All_Count_2 := MyGui.AddText("x348 yp wp hp +Center +0x200 BackgroundTrans", LV.GetCount())

; 一键恢复所有默认图标
MyGui.All_Default_Pic := MyGui.AddPicture("x410 y40 w116 h50", "HICON:" Base64PNG_to_HICON(All_Default_Base64PNG, height := 300))
MyGui.All_Default_Cursor := MyGui.AddPicture("xp yp wp hp Hidden", "HICON:" Base64PNG_to_HICON(All_Default_Cursor_Base64PNG, height := 300))
MyGui.All_Default_Btn := MyGui.AddButton("xp yp wp hp +0x4000000 -Tabstop vAll_Default").OnEvent("Click", All_Default)
MyGui.AddProgress("x162 y+9 w364 h26 c8042c0 vMyProgress Background333136 Range0-" . LV.GetCount(), Changed_Count.Value)
;————————————————————————————————————————第二个标签页（更多功能）的结束———————————————————————————————————————————————



;————————————————————————————————————————第三个标签页（日志）的开始——————————————————————————————————————————————————
Tab.UseTab(3)
Log_Change := MyGui.AddEdit("x162 y37 Background333136 -E0x200 +Multi +ReadOnly -WantReturn")   ; 宽度、高度自适应
;————————————————————————————————————————第三个标签页（日志）的结束——————————————————————————————————————————————————


;————————————————————————————————————————第四个标签页（关于）：开始——————————————————————————————————————————————————
Tab.UseTab(4)

MyGui.AddLink("x210 y110 w300", '<a href="https://github.com/iKineticate/AHK-ChangeIcon">Github</a>')
MyGui.AddLink("x210 y+20 w300", '<a href="https://github.com/iKineticate/AHK-ChangeIcon/releases">Download</a>')
MyGui.AddText("x210 y+20 w300", "Vesion: 2.1")
MyGui.AddText("x210 y+20 w300", "Author: iKineticate")
MyGui.AddText("x210 y+20 w300", "酷安: 林琼雅")

Tab.UseTab()
;————————————————————————————————————————第四个标签页（关于）：结束——————————————————————————————————————————————————


; 《深色模式》
; （1）窗口标题栏（根据Windows版本赋予attr不同的值），已启用，自制标题栏统一颜色
;dwAttr:= VerCompare(A_OSVersion, "10.0.18985") >= 0 ? 20 : VerCompare(A_OSVersion, "10.0.17763") >= 0 ? 19 : ""
;DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "int", dwAttr, "int*", True, "int", 4)
; （2）呼出的菜单（1：根据系统显示模式调整深浅，2：深色，3：浅色）
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 135, "Ptr"), "int", 2)
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 136, "Ptr"))
; （3）列表标题栏及其滚动条
LV_Header := SendMessage(0x101F, 0, 0, LV.hWnd)     ;列表标题栏的hwnd
DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", "DarkMode_ItemsView", "Ptr", 0)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
; （4）日志(Edit)的滚动条
DllCall("uxtheme\SetWindowTheme", "Ptr", Log_Change.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)

; 《列表透明》：会闪烁
;   GWL_EXSTYLE := -20              ; 设置新的扩展窗口样式
;   WS_EX_LAYERED := 0x80000        ; 设置为分层窗口风格
; 
;   crKey := RGB                    ; 颜色值
;   bAlpha := 0~255                 ; 透明度
;   LWA_COLORKEY := 0x00000001      ; 使用 crKey 作为透明度颜色
;   LWA_ALPHA := 0x00000002         ; 使用 bAlpha 确定分层窗口的不透明度
; 
;   SW_SHOWNORMAL := 1              ; 激活并显示窗口
;DllCall("SetWindowLongPtr", "Ptr", LV.hwnd, "int", -20, "Int", 0x80000)
;DllCall("SetLayeredWindowAttributes", "Ptr", LV.hwnd, "Uint", 0xF0F0F0, "Uchar", 200, "Uint", 0x2) 
;DllCall("ShowWindow", "Ptr", LV.hwnd, "int", 1)

MyGui.Show()

; 监测鼠标的移动与操作
OnMessage(0x200, WM_MOUSEMOVE)


; 鼠标滚轮键/F2键点击图片后更换快捷方式图标
MButton::
F2:: 
{
    MyGui.Opt("+OwnDialogs")
    A_Clipboard := ""
    SendInput("{LButton}")
    Send("^c")
    
    ; 若1秒后剪切板无变化、选择了ico外的文件或列表存在多行选择，则返回并提示
    If (!ClipWait(1))                                   
        Return
    If (!RegExMatch(A_Clipboard, "\.ico$"))
        Return  Msgbox(An_Icon_Text, "Warn", "Icon!")
    If (LV.GetCount("Select") != 1)
        Return  Msgbox(A_Row_Text, "Warn", "Icon!")

    ; 一行接一行地读取复制内容(路径)，并移除内容(路径)里开头结尾所有的换行
    Loop Parse, A_Clipboard, "`n", "`r" 
    {
	    FileName := A_LoopField "`n"
    }
    FileName := Trim(FileName, "`n")

    ; 调用WshShell对象的函数，快捷方式图标更换为选中图标，并保存操作
    Link_Path := Link_Map[ListViewGetContent("Selected Col1",LV.Hwnd) . "LP"]
    COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)                        
    Link_Attribute.IconLocation := FileName
    Link_Attribute.Save()

    ; 更新显示的数据
    If (ListViewGetContent("Selected Col2",LV.Hwnd) = "")
    {
        Changed_Count.Value += 1
        UnChanged_Count_2.Value := UnChanged_Count_1.Value -= 1
        MyGui["MyProgress"].Value += 1
    }

    ; 刷新顶部、列表图标，并给该行添加"√"
    Display_Top_Icon(LV, LV.GetNext(0, "F"))
    Display_LV_Icon(LV, LV.GetNext(0, "F"))
    LV.Modify(ListViewGetContent("Count Focused",LV.Hwnd),,,"√")

    ; 添加至日志
    global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
        . Log_Change_Text . ListViewGetContent("Selected Col1",LV.Hwnd) . "`n`s" 
        . FileName . "`n`n" 
        . Logging
    Log_Change.Value := Logging
}


Return


; 监测鼠标活动，当鼠标移动至标签页时，高亮该标签页
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd)
{
    CurrControl := GuiCtrlFromHwnd(Hwnd)                    ; 检测是否为存在事件的控件（无事件的控件不被检测到）
    If CurrControl                                          ; 若是Gui的控件
    {
        thisGui := CurrControl.Gui                          ; thisGui = MyGui(控件的父窗口)
        Switch CurrControl.Name                             ; 检查控件的名称（控件的Opt里面的"v"后面的名称，而不是变量名）
        {
        Case "Minimize_Btn" :
            thisGui.Minimize_Cursor.Visible := True         ; 鼠标下高亮"最小化"
            thisGui.Close_Cursor.Visible := False
        Case "Close_Btn" :
            thisGui.Close_Cursor.Visible := True            ; 鼠标下高亮"关闭"
            thisGui.Minimize_Cursor.Visible := False
        Case "Caption" :
            thisGui.Minimize_Cursor.Visible := False        ; 当控件为标题栏，取消"最小化"高亮
            thisGui.Close_Cursor.Visible := False
            If (wParam = 1)                                 ; 若鼠标左键在自创的标题栏点击则变为在窗口原来的标题栏点击（实现拖动）
                Return PostMessage(0xA1, 2)                 ; WM_NCLBUTTONDOWN = 0xA1、LBUTTON = 2
        Case "All_Changed_Btn" :
            thisGui.All_Changed_Cursor.Visible := True           ; 鼠标下高亮"一键更换"的按钮
        Case "All_Default" :
            thisGui.All_Default_Cursor.Visible := True
        Default:                                            ; 若一个名字未匹配，则匹配是否未标签页
            If (InStr(CurrControl.Name, "Tab_Item") AND (CurrControl != thisGui.Active_Tab))
            {
                If (CurrControl = thisGui.Ctrl_Cursor)      ; 若标签页控件等于光标下的上一次标签页控件，则返回（避免一直闪烁）
                    Return
                thisGui.Ctrl_Cursor := CurrControl          ; 若光标下的标签页发生变化，则定义这次光标下标签页
                thisGui.Tab_Cursor.Move(5, (40 * CurrControl.Index) + 61 )
                thisGui.Tab_Cursor.Redraw()                 ; 重绘：防止移动时出现文本重影在其他文本上
                thisGui.Tab_Cursor.Visible := True
            }
            Else    ; 不可用Return代替
            {
                thisGui.Ctrl_Cursor := CurrControl
                thisGui.Tab_Cursor.Visible := False
            }
        }
    }
    Else            ; 若不是Gui的控件，则更新光标下的控件和隐藏高亮，一样不能用Return代替Else
    {
        MyGui.Ctrl_Cursor := CurrControl
        MyGui.Minimize_Cursor.Visible := False
        MyGui.Close_Cursor.Visible := False
        MyGui.All_Changed_Cursor.Visible := False
        MyGui.Tab_Cursor.Visible := False
        MyGui.All_Default_Cursor.Visible := False
    }
}


; 标签页(文本)点击事件（标签页为焦点则高亮）
Tab_Focus(GuiCtrlObj, info, *)
{
    If GuiCtrlObj = MyGui.Active_Tab
        Return

    ;MyGui.Opt("-0x10000000")
    ; 闪烁得没那么明显
    DllCall("LockWindowUpdate", "Uint", MyGui.Hwnd)         
    ;DllCall("SendMessage", "Ptr", MyGui.hwnd, "UInt",0xB, "UInt", 0, "UInt", 0)

    ControlFocus Tab                                        ; 设置该标签页为焦点，其他控件脱去焦点
    Tab.Choose(trim(GuiCtrlObj.text))                       ; 打开符合含有对应文本的标签页（因为点击的是Text控件而不是Tab控件）
    Tab_Focus_1.Move(5, (40*GuiCtrlObj.Index) + 61 )        ; 高亮方块1移动至标签页
    Tab_Focus_2.Move(5, (40*GuiCtrlObj.Index) + 70 )        ; 高亮方块2移动至标签页
    MyGui.Active_Tab := GuiCtrlObj                          ; 设置新的活动标签页

    ;DllCall("SendMessage", "Ptr", MyGui.hwnd, "UInt",0xB, "UInt", 1, "UInt", 0)
    DllCall("LockWindowUpdate", "Uint", 0)
    ;MyGui.Opt("+0x10000000")
}


; 窗口控件自适应调节位置和宽高
; 这些都是发生在窗口show之前，这样子就不会出现show之后的闪烁、水平滚动条等等外观问题
MyGui_Size(thisGui, MinMax, Width, Height)
{
    ; LockWindowUpdate：当拖拽窗口、改变窗口尺寸、拖拽窗口内对象时，窗口管理器锁定整个桌面以便可以绘制细点矩形反馈，
    ; 而不会因为其它窗口偶然与细点矩形交叠而导致冲突的风险（说人话就是可以减少闪烁）
    DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
    if MinMax = -1
        Return
    Caption.Move(,,Width- 108)
    Caption.OnEvent("DoubleClick", (*) => "")   ; 赋予事件后，上面的WM_MOUSEMOVE才能检测到它
    MyGui.Minimize_Pic.Move(Width - 108)
    MyGui.Minimize_Cursor.Move(Width - 108)
    MyGui.Minimize_Btn.Move(Width - 108)
    MyGui.Minimize_Btn.OnEvent("Click", (*) => WinMinimize("A"))
    MyGui.Maximize_Pic.Move(Width - 72)
    MyGui.Close_Pic.Move(Width - 36)
    MyGui.Close_Cursor.Move(Width - 36)
    MyGui.Close_Btn.Move(Width - 36)
    MyGui.Close_Btn.OnEvent("Click", (*) => WinClose("A"))
    Tab_Background.Move(,,,Height)
    Search_Bar.Move(,,Width - 200)
    Search_Btn.Move(Width - 38)
    Search_Btn.OnEvent("Click", Search)         ; 被赋予事件的控件是不支持移动的，因此先移动再赋予事件
    Search_Line.Move(,,Width - 200)
    LV.Move(,, Width -174, Height -143)
    LV.ModifyCol(1, Width - 282)
    LV.ModifyCol(2, "+AutoHdr")
    LV.ModifyCol(3, "+AutoHdr")
    LV.Opt("+Redraw")
    Log_Change.Move(,, Width -174, Height -49)
    MyGui.Opt("-Resize") 
    DllCall("LockWindowUpdate", "Uint", 0)      ; 当移动/改变尺寸的操作完成，桌面被解锁，所有东西恢复原貌
    MyGui.OnEvent("Size", MyGui_Size, 0)
}


; 搜索关键词项目
Search(*)
{
    ; 若搜索框未输入文本，则提示“请输入”并返回
    If (Search_Bar.Value = "" OR Search_Bar.Value = Search_Text)
        Return  (ToolTip(Input_Text, 400, 240) AND SetTimer((*) => ToolTip(), -2000))

    ; 搜索框为焦点、允许列表多行选择、 取消列表中所有行的选择与焦点（避免与搜索结果重叠）
    Search_Bar.Focus()
    LV.Opt("+Multi")
    LV.Modify(0, "-Select -Focus")

    ; 开始从头搜索，若搜索到指定项目，则设为焦点并选择显示，然后刷新顶部图标
    Loop LV.GetCount()
    {
        If (InStr(LV.GetText(A_Index), Search_Bar.Value))
        {
            Sleep(300)
            LV.Modify(A_Index, "+Select +Focus +Vis")
            Display_Top_Icon(LV, A_Index)
        }
    }

    LV.Opt("-Multi")

    ; 若搜素完所有项目后未找到目标，则提示“未找到”（利用未搜索到时焦点会在搜索框机制）
    If (ControlGetFocus("A") = Search_Bar.hWnd)
        Return  (ToolTip(Not_Fountd_Text, 400, 240) AND SetTimer((*) => ToolTip(), -2000))
}


; Edit为(非)焦点时，若未输入任何内容则清空(添加)提示词“搜素...”
Search_Focus(*)
{
    Search_Bar.Value := Search_Bar.Value = Search_Text ? "":Search_Bar.Value
    Search_Bar.Opt("Background191919")
    Search_Line.Visible := True
    Search_Bar.Focus()  ; 焦点时，再次让它焦点即可实现全选
}
Search_LoseFocus(*)
{
    Search_Bar.Value := Search_Bar.Value = "" ? Search_Text:Search_Bar.Value
    Search_Bar.Opt("Background333136")
    Search_Line.Visible := False
}


; 在列表左侧刷新列表选择（焦点）项目的图标
Display_LV_Icon(LV, Item)
{
    ; 调用DllCall_Icon函数和图像列表替换函数，添加图标并赋予给IconNumber--刷新列表左侧图标
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", DllCall_Icon(Link_Path)) + 1
    LV.Modify(Item, "Icon" . IconNumber)
    ;DllCall("DestroyIcon", "Ptr", DllCall_Icon(Link_Map[LV.GetText(Item, 1) . "LP"]))
}


; 在顶部显示、刷新ICO显示区域
Display_Top_Icon(LV, Item)
{
    ; 调用DllCall获取选择(焦点)项目的图标--显示、刷新顶部图标--销毁hIcon
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    Show_Icon_Area.Value := "HICON:" DllCall_Icon(Link_Path)
    Show_Icon_Area.Opt("Background262626")
    ;DllCall("DestroyIcon", "Ptr", DllCall_Icon(Link_Path))
}


; 更换单个图标
Change_Link_Icon(LV, Item)
{
    MyGui.Opt("+OwnDialogs")

    ; 第一次更换图标时，若Change_ToolTip未被赋值，则会通知提醒然后赋值，再次更换图标后不会通知提醒
    If (!IsSet(Change_TrayTip))
    {
        TrayTip(Safe_TrayTip_Text)
        static Change_TrayTip := 1
    }

    Link_Name := LV.GetText(Item, 1)

    ; 调用WshShell对象的函数，获取link各个属性
    Link_Target_Path := Link_Map[Link_Name . "LTP"]
    Link_Path := Link_Map[Link_Name . "LP"]
    COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)

    ; 选择文件格式为“.ico”的图标，需更换图标路径赋予给Link_Icon_Select
    ; 若未选择照片或需更换图片是现在的图标则返回，否则更换图片并保存
    Link_Icon_Select := FileSelect(3,, An_Icon_Text . "——————" . Link_Name, "Icon files(*.ico)")
    If ((Link_Icon_Select = "") OR (Link_Icon_Select = Link_Icon_Location))
        Return
    Link_Attribute.IconLocation := Link_Icon_Select
    Link_Attribute.Save()

    ; 更新显示的数据
    If (LV.GetText(Item, 2) = "")
    {
        Changed_Count.Value += 1
        UnChanged_Count_2.Value := UnChanged_Count_1.Value -= 1
        MyGui["MyProgress"].Value += 1
    }

    ; 刷新顶部、列表图标、添加"√"
    Display_Top_Icon(LV, Item)
    Display_LV_Icon(LV, Item)
    LV.Modify(Item,,,"√")

    ; 添加至日志
    global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
        . Log_Change_Text . Link_Name . "`n`s" 
        . Link_Icon_Select . "`n`n" 
        . Logging
    Log_Change.Value := Logging
}


; 更换所有图标
All_Changed(*)
{
    ; 选择存放ICO的文件夹
    Selected_Folder := DirSelect(, 0, Select_Folder_Text . "`n" . Safe_TrayTip_Text)
    If (Selected_Folder = "")
        Return

    Changed_Items := All_Changed_Text
    Icons_Map := map()
    Same_Name_Map := map()

    ; 从选择的文件夹中，添加图标组合，ICO名称(键)-ICO路径(值)
    Loop Files, Selected_Folder "\*.ico"
    {
        Icons_Map[RegExReplace(A_LoopFileName, "\.ico$")] := A_LoopFilePath
    }

    ; 扫描、更换图标过程中禁止与窗口交互
    MyGui.Opt("+Disabled")
    TrayTip(ing_TrayTip_Text)

    ; 从图标组合中枚举，并从列表开头开始循环
    For Icon_Name, Icon_Path in Icons_Map
    {
        Loop LV.GetCount()
        {
            ; 若名称不匹配或快捷方式已更换过同样名称的ICO，则跳过循环中的这一次
            ; 注意：若要跳过这一次操作，继续下一个循环不能用Return，Return也算退出循环，用Continue
            Link_Name := LV.GetText(A_Index, 1)
            If (!Instr(Icon_Name, Link_Name) OR Same_Name_Map.has(Link_Name))
                Continue

            Link_Path := Link_Map[Link_Name . "LP"]
            COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)

            ; 若已更换过或ICON名称等于快捷方式名称则记录在数组same_name_map中
            ; 保证快捷方式在更换一个名称相同的图片后，不会在更换别的含有它的名字但不属于它的照片
            ; 如"QQ.lnk"已更换图标或更换图标是为"QQ.ico"后，下一次就不会更换成"QQ音乐.ico"了
            If ((Link_Icon_Location = Icon_Path) OR (StrLen(Icon_Name) = StrLen(Link_Name)))
            {
                Same_Name_Map[Link_Name] := "OFF"
            }

            If (Link_Icon_Location = Icon_Path)
                Continue

            Link_Attribute.IconLocation := Icon_Path
            Link_Attribute.Save()

            ; 更新显示的数据
            If (LV.GetText(A_Index, 2) = "")
            {
                Changed_Count.Value += 1
                UnChanged_Count_2.Value := UnChanged_Count_1.Value -= 1
                MyGui["MyProgress"].Value += 1
            }

            ; 刷新顶部图标、列表图标、聚焦更换行，并记录被更换图标的快捷方式名称和图标名称
            Display_Top_Icon(LV, A_index)
            Display_LV_Icon(LV, A_index)
            LV.Modify(A_index, "+Select +Focus +Vis",,"√")
            Changed_Items .= "`n" . Link_Name . "`s→`s" . Icon_Name

            ; 添加至日志
            global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
                . Log_Change_Text . LV.GetText(A_Index, 1) . "`n`s" 
                . Icon_Path . "`n`n" 
                . Logging
            Log_Change.Value := Logging
        }
    }

    ; 恢复与窗口的交互
    MyGui.Opt("-Disabled")
    SetTimer TrayTip, -2500

    ; 若记录有更换记录，则显示被更换图标快捷方式名称和更换图标名称，若未记录，则显示“未更换任何图标”
    If (RegExReplace(Changed_Items, "`n") != RegExReplace(All_Changed_Text, "`n"))
        Return Msgbox(Changed_Items, Success_Text)
    Msgbox(Unchanged_Text, "Hellow World")
}


; 所有快捷方式恢复为默认图标
All_Default(*)
{
    MyGui.Opt("+OwnDialogs")
    Default_Result := Msgbox(All_Default_Text, Default_Title_Text, "OKCancel Icon! Default2")
    If Default_Result = "Cancel"
        Return
    Loop LV.GetCount()
    {
        If (LV.GetText(A_Index, 2) != "√" OR LV.GetText(A_Index, 3) = "uwp" OR LV.GetText(A_Index, 3) = "app")
            Continue

        Link_Name := LV.GetText(A_Index, 1)
        Link_Path := Link_Map[Link_Name . "LP"]
        Link_Target_Path := Link_Map[Link_Name . "LTP"]

        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
        Link_Attribute.IconLocation := Link_Target_Path
        Link_Attribute.Save()

        ; 更新显示的数据
        If (LV.GetText(A_index, 2) = "√")
        {
            Changed_Count.Value -= 1
            UnChanged_Count_2.Value := UnChanged_Count_1.Value += 1
            MyGui["MyProgress"].Value -= 1
        }

        ; 刷新顶部图标、列表图标，聚焦恢复默认行并清除该行"√"
        Display_Top_Icon(LV, A_index)
        Display_LV_Icon(LV, A_index)
        LV.Modify(A_index, "+Select +Focus +Vis",,"")

        ; 添加至日志
        global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Default_Text . LV.GetText(A_Index, 1) . "`n`n" 
            . Logging
        Log_Change.Value := Logging
    }
    TrayTip(Completed_Text)
    SetTimer TrayTip, -2000
}


; 右键打开菜单设置
Link_ContextMenu(LV, Item, IsRightClick, X, Y)
{    
    LV.Focus()                                              ; 右键让列表为焦点
    LV.Modify(0, "-Select -Focus")                          ; 关闭列表所有的选择与焦点（避免搜索时多个选项）
    LV.Modify(Item, "+Select +Focus")                       ; 右键点击的行成为选择焦点

    ; 快捷方式的目标路径、目标目录、路径、目录
    Link_Name := LV.GetText(Item, 1)
    Link_Target_Path := Link_Map[Link_Name . "LTP"]
    Link_Target_Dir := Link_Map[Link_Name . "LTD"]
    Link_Path := Link_Map[Link_Name . "LP"]
    Link_Dir := Link_Map[Link_Name . "LD"]

    ; 创建菜单并添加选项及功能
    Link_Menu := Menu()
    Link_Menu.Add(Menu_Run_Text, (*) => Run(Link_Path))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add(Menu_Change_Text, (*) => Run(Change_Link_Icon(LV, Item)))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add(Menu_Default_Text, Link_Default)
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add(Menu_TargetDir_Text, (*) => Run(Link_Target_Dir))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add(Menu_Rename_Text, Link_Rename)

    Link_Infor := Menu()
    Link_Infor.Add(Copy_LTP_Text . Link_Target_Path, (*) => (A_Clipboard := Link_Target_Path))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add(Copy_LTD_Text . Link_Target_Dir, (*) => (A_Clipboard := Link_Target_Dir))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add(Copy_LP_Text . Link_Path, (*) => (A_Clipboard := Link_Path))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add(Copy_LD_Text . Link_Dir, (*) => (A_Clipboard := Link_Dir))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add(Menu_LA_Text, Link_Infor)

    ; 调用DllCall获取选择(焦点)项目的图标--在菜单栏第一行显示图标--销毁hIcon
    ; 调用后面的Base64转PNG函数，在菜单栏第二~五行添加对应图标
    Link_Menu.SetIcon(Menu_Run_Text, "HICON:" DllCall_Icon(Link_Path))
    Link_Menu.SetIcon(Menu_Change_Text, "HICON:" Base64PNG_to_HICON(Menu_Change_Base64PNG))
    Link_Menu.SetIcon(Menu_Default_Text, "HICON:" Base64PNG_to_HICON(Menu_Default_Base64PNG))
    Link_Menu.SetIcon(Menu_TargetDir_Text, "HICON:" Base64PNG_to_HICON(Menu_Folders_Base64PNG))
    Link_Menu.SetIcon(Menu_Rename_Text, "HICON:" Base64PNG_to_HICON(Menu_Rename_Base64PNG))
    Link_Menu.SetIcon(Menu_LA_Text, "HICON:" Base64PNG_to_HICON(Menu_Attrib_Base64PNG))
    
    ; 若选择与焦点行为UWP应用或WSA应用，则将恢复默认图标和打开目标目录的功能禁止
    If ((Link_Target_Path = Safe_Text) OR InStr(Link_Target_Path, "WindowsSubsystemForAndroid"))
    {
        Link_Menu.Disable(Menu_Default_Text)
        Link_Menu.Disable(Menu_TargetDir_Text)
    }

    Link_Menu.Show()

    ; 恢复快捷方式的默认图标并刷新
    Link_Default(*)
    {
        ; 调用WshShell对象的函数，获取link各个属性，若图标已为默认则返回，否则更换图片并保存等操作
        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
        If ((Link_Icon_Location = Link_Target_Path) OR (Link_Icon_Location = ""))
            Return
        Link_Attribute.IconLocation := Link_Target_Path
        Link_Attribute.Save()
        
        ; 更新显示的数据
        If (LV.GetText(Item, 2) = "√")
        {
            Changed_Count.Value -= 1
            UnChanged_Count_2.Value := UnChanged_Count_1.Value += 1
            MyGui["MyProgress"].Value -= 1
        }

        ; 刷新顶部图标、列表图标、删除"√"
        Display_Top_Icon(LV, Item)
        Display_LV_Icon(LV, Item)
        LV.Modify(Item,,,"")

        ; 添加至日志
        global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Default_Text . Link_Name . "`n`n" 
            . Logging
        Log_Change.Value := Logging
    }

    ; 重命名快捷方式名称
    Link_Rename(*)
    {
        MyGui.Opt("+OwnDialogs")

        IB := InputBox(Rename_Text, Link_Name, "W300 H100", Link_Name)

        If IB.Result="CANCEL"
            Return

        ; 更换旧快捷方式的路径为新路径
        Link_New_Path := Link_Dir . "\" . IB.Value . ".lnk"
        FileMove(Link_Path, Link_New_Path)

        ; 重命名后，发生变化的只有快捷方式名称、快捷方式的路径，因此需要单独更换，而不能在循环数组中更换
        ; 重命名后，在数组中给新名称(键)赋予新的目标路径、目标目录、lnk路径、lnk目录的值，并删除旧键-值
        Link_Map[IB.Value . "LP"] := Link_New_Path
        Link_Map.Delete(Link_Name . "LP")
        For Value in ["LTP", "LTD", "LD"]
        {
            Link_Map[IB.Value . Value] := Link_Map[Link_Name . Value]
            Link_Map.Delete(Link_Name . Value)
        }

        ; 添加至日志
        global Logging := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Rename_Text . Link_Name . "`n`s" 
            . Log_NewName_Text . IB.Value . "`n`n" 
            . Logging
        Log_Change.Value := Logging

        ; 更换项目的lnk名称（在最后才更新名称是因为过早更新会导致在数组中不能检测到旧名称的键-值，只能检测到新名称的键-值）
        LV.Modify(Item,, IB.Value)
    }
}


; DllCall获取图标的函数
DllCall_Icon(Link_Target_Path)
{
    If DllCall("Shell32\SHGetFileInfoW"
        , "Str", Link_Target_Path
        , "Uint", 0
        , "Ptr", sfi
        , "UInt", sfi_size
        , "UInt", 0x100)
    Return hIcon := NumGet(sfi, 0, "Ptr")
}


; 调用COM对象（WshShell对象）创建快捷方式的函数
COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
{
    Link_Attribute := ComObject("WScript.Shell").CreateShortcut(Link_Path)      ; 快捷方式的属性
    Link_Icon_Location := RegExReplace(Link_Attribute.IconLocation, "..$")      ; 快捷方式的图标路径(去除了图片编号)(存储的是值而不是变量)
}