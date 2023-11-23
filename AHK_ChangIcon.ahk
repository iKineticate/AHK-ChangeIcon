;// @Name                   AHK ChangeIcon
;// @Author                 iKineticate(Github)
;// @Version                v2.4
;// @Destription:zh-CN      快速更换桌面快捷方式图标
;// @Destription:en         Quickly change of desktop shortcut icons
;// @HomepageURL            https://github.com/iKineticate/AHK-ChangeIcon
;// @Icon Source            https://www.iconfont.cn
;// @Startup Screen         https://www.xiaohongshu.com/explore/653de7bc000000001f03cfa4
;// @Source of Inspiration  https://www.autohotkey.com/boards/viewtopic.php?f=83&t=95676&p=427160&hilit=menubar+theme#
;// @Date                   2023/11/24

;@Ahk2Exe-SetVersion 2.4
;@Ahk2Exe-SetFileVersion 2.4
;@Ahk2Exe-SetProductVersion 2.4
;@Ahk2Exe-SetName AHK-ChangeIcon
;@Ahk2Exe-ExeName AHK-ChangeIcon
;@Ahk2Exe-SetCompanyName AHK-ChangeIcon
;@Ahk2Exe-SetProductName AHK-ChangeIcon
;@Ahk2Exe-SetDescription AHK-ChangeIcon
;@Ahk2Exe-SetOrigFilename AHK-ChangeIcon.exe
;@Ahk2Exe-SetLegalTrademarks AHK-ChangeIcon

#Requires AutoHotkey >=v2.0
#SingleInstance Ignore
#Include "AHK_Base64PNG.ahk"
#Include "AHK_Language.ahk"
#Include "RedrawDB.ahk" ;https://www.autohotkey.com/board/topic/95930-window-double-buffering-redraw-gdi-avoid-flickering/

SetControlDelay(-1)
SetWinDelay(-1)


;==========================================================================
; 以管理员身份运行AHK
;==========================================================================
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


;==========================================================================
; 创建等待界面的窗口
;==========================================================================
; +0x4000000：使该控件显示在其他控件的后面（可使按钮在PNG图片后面来实现PNG透明+PNG作为按钮）
Wait_Gui := Gui("-Caption -Resize -Border +Owner", "AHK-ChangeIcon")
Wait_Gui.BackColor := "262626"
WinSetTransColor("262626", Wait_Gui)
Wait_Gui.AddPicture("w616 h474 +0x4000000", "HICON:" Base64PNG_to_HICON(Startup_Screen_Base64PNG, height := 1232))
Wait_Gui.Show("NoActivate Center")


;==========================================================================
; 创建软件界面的窗口
;==========================================================================
; +E0x02000000和+E0x00080000的双缓冲暂时不能避免该软件切换标签页时的闪烁
MyGui := Gui("-Caption -Resize +Border", "AHK-ChangeIcon")
MyGui.BackColor := "262626"
MyGui.SetFont("s12 Bold cffffff", "Microsoft YaHei")
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.OnEvent("Size", MyGui_Size)


;==========================================================================
; 关闭按钮、最大化按钮、最小化按钮（X坐标自适应），标题栏（宽度自适应）
;==========================================================================
MyGui.Close_Pic := MyGui.AddPicture("y0 w36 h25", "HICON:" Base64PNG_to_HICON(Close_Base64PNG, height := 56))
MyGui.Close_Cursor := MyGui.AddPicture("y0 wp hp Hidden", "HICON:" Base64PNG_to_HICON(Close_Cursor_Base64PNG, height := 56))
MyGui.Close_Btn := MyGui.AddButton("y0 wp hp -Tabstop +0x4000000 vClose_Btn")
MyGui.Maximize_Pic := MyGui.AddPicture("y0 wp hp", "HICON:" Base64PNG_to_HICON(Maximize_Base64PNG, height := 56))
MyGui.Minimize_Pic := MyGui.AddPicture("y0 wp hp", "HICON:" Base64PNG_to_HICON(Minimize_Base64PNG, height := 56))
MyGui.Minimize_Cursor := MyGui.AddPicture("y0 wp hp Hidden", "HICON:" Base64PNG_to_HICON(Minimize_Cursor_Base64PNG, height := 56))
MyGui.Minimize_Btn := MyGui.AddButton("y0 wp hp -Tabstop +0x4000000 vMinimize_Btn")
Caption := MyGui.AddText("x0 y0 h25 c8042c0 Background202020 +0x4000000 +0x200 vCaption","`sAHK-ChangeIcon")


;==========================================================================
; 左侧界面（背景+Logo+图标+隐藏标签页+映射标签页）
;==========================================================================
Left_Background := MyGui.AddPicture("x0 y25 w150 Background202020 +0x4000000")

Logo := MyGui.AddPicture("x43 y+5 w64 h64 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Logo_Base64PNG, height := 480))

Tab := MyGui.AddTab("x0 y0 w0 h0 -Wrap -Tabstop +Theme vTabControl")                ; 隐藏标签页

Tab.UseTab()

MyGui.Ctrl_Cursor := ""
MyGui.Tab_Cursor := MyGui.AddPicture("x5 y101 w140 h36 Background0x343434 Hidden")  ; 鼠标(光标)处于标签页时的高亮长方块
Tab_Focus_Long := MyGui.AddPicture("x5 y101 w140 h36 Background0x343434")           ; 标签页焦点时的长高亮方块
Tab_Focus_Short := MyGui.AddPicture("x5 y110 w5 h18 Background0x8042c0")            ; 标签页焦点时的短高亮方块

; 每个映射标签页的图标
MyGui.AddPicture("x14 y110 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Home_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Others_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Log_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Help_Base64PNG, height := 224))
MyGui.AddPicture("xp y+22 w18 h18 BackgroundTrans", "HICON:" Base64PNG_to_HICON(About_Base64PNG, height := 224))

; 创建隐藏标签页和映射标签页，并将Naigation中各个名字添加至这俩标签页
Loop Navigation.Label.Length
{ 
    Tab.Add([Navigation.Label[A_Index]])    ; 隐藏标签页

    ; 映射标签页（透明、+0x200:文本垂直居中显示）
    Tab_Item := MyGui.AddText("x5 y" (40*A_Index) + 59 " h40 w140 BackgroundTrans +0x200 vTab_Item" . A_Index
        , "`s`s`s`s`s`s`s`s" Navigation.Label[A_Index])
    Tab_Item.SetFont("s10 cffffff")
    Tab_Item.OnEvent("Click", Tab_Focus)    ; 点击映射到隐藏标签页的事件
    Tab_Item.Index := A_Index

    ; 第一个标签页为默认焦点
    If (A_Index != 1)
        Continue
    MyGui.Active_Tab := Tab_Item
}


;==========================================================================
; 共用控件：第一标签页与第二标签页共用 
;==========================================================================
MyGui.SetFont("s11")
MyGui.AddPicture("x162 y37 w56 h56 -E0x200 Background333136 vShow_Icon_Area")     ; 第一个显示区域（顶部ICO的显示区域）
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136 vChanged_Count_Area")     ; 第二个显示区域（已更换的显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136 vUnChanged_Count_Area")   ; 第三个显示区域（未更换的显示区域
MyGui.AddPicture("x+6 yp wp hp -E0x200 Background333136 vAll_Count_Area")         ; 第四个显示区域（总共的显示区域）

MyGui.AddText("x224 y42 w56 h23 +Center +0x200 BackgroundTrans vChanged_Count_Title", Yes_Text)
MyGui.AddText("x286 y42 w56 h23 +Center +0x200 BackgroundTrans vUnChanged_Count_Title", No_Text)
MyGui.AddText("x348 y42 w56 h23 +Center +0x200 BackgroundTrans vAll_Count_Title", All_Text)

Changed_Count := MyGui.AddText("x224 y65 w56 h23 +Center +0x200 BackgroundTrans vChanged_Count", "0")
UnChanged_Count := MyGui.AddText("x286 y65 w56 h23 +Center +0x200 BackgroundTrans vUnChanged_Count", "0")
All_Count := MyGui.AddText("x348 y65 w56 h23 +Center +0x200 BackgroundTrans vAll_Count", "0")

; 共用控件的名称数组
Show_Name_Map := ["Show_Icon_Area", "Changed_Count_Area", "UnChanged_Count_Area", "All_Count_Area"
                    , "Changed_Count_Title", "UnChanged_Count_Title", "All_Count_Title" 
                    , "Changed_Count", "UnChanged_Count", "All_Count"]


;==========================================================================
; 第一个标签页：主页(Home) 
;==========================================================================
Tab.UseTab(1)
MyGui.SetFont("s12")
; 一键更换所有图标按钮
MyGui.All_Changed_Pic := MyGui.AddPicture("x410 y40 w116 h50", "HICON:" Base64PNG_to_HICON(All_Changed_Pic_Base64PNG, height := 300))
MyGui.All_Changed_Cursor := MyGui.AddPicture("xp yp wp hp Hidden", "HICON:" Base64PNG_to_HICON(All_Changed_Cursor_Base64PNG, height := 300))
MyGui.All_Changed_Btn := MyGui.AddButton("xp yp wp hp -Tabstop +0x4000000 vAll_Changed_Btn").OnEvent("Click", All_Changed)

; 焦点时的搜索栏的下划线（宽度自适应）
Search_Line := MyGui.AddPicture("x162 y+33 h2 Background8042c0")
; 搜索框（宽度自适应）（0x4000000使下划线一直显示在搜索框前方，但它会给搜索框添加边框，因此需-E0x200去除边框）
Search_Bar := MyGui.AddEdit("x162 yp-24 h26 Background191919 -E0x200 +0x4000000")
Search_Bar.SetFont("cbbbbbb s13")
Search_Bar.OnEvent("LoseFocus", Search_LoseFocus)
Search_Bar.OnEvent("Focus", Search_Focus)
; 搜索按钮（x坐标自适应）
Search_Btn := MyGui.AddPicture("yp w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Search_Base64PNG, height := 64))
; 设置为默认按钮，按下Enter键可以触发搜索（隐藏起来后，按键Tab在切换控件时不会选到这个按钮）
Hidden_Btn := MyGui.AddButton("yp wp hp Default Hidden").OnEvent("Click", Search)

; 创建无边框、宽度自适应列表，赋予点击、双击、右键菜单事件
; -Redraw：关闭列表的重绘，提升列表载入速度
; -Multi：禁止选择多行，避免出现多个图标更换错误
; -E0x200：去除边框
; +LV0x10000：双缓冲绘图，减少窗口大小变化时列表闪烁
LV := MyGui.AddListView("x162 y+6 r10 Background333136 -Redraw -Multi -E0x200 +LV0x10000", ["Name", "Y/N", "Type"])
LV.SetFont("cffffff")
LV.OnEvent("ItemFocus", Display_Top_Icon)
LV.OnEvent("DoubleClick", Change_Link_Icon)
LV.OnEvent("ContextMenu", Link_ContextMenu)

global Link_Map := map()                            ; 创建快捷方式(Link)的键-值数组(Map)
global Which_Add := "Desktop"                       ; 创建目前是哪一个文件夹的快捷方式的变量
global ImageListID := IL_Create()                   ; 为添加图标做好准备: 创建图像列表
LV.SetImageList(ImageListID)                        ; 为添加图标做好准备: 设置显示图标列表

; 添加桌面快捷方式
For Desktop in [A_Desktop, A_DesktopCommon]
{
    Add_Link_To_LV(Desktop, Mode := "")
    UnChanged_Count.Value := LV.GetCount() - Changed_Count.Value
    All_Count.Value := LV.GetCount()
}


;==========================================================================
; 第二个标签页：其他(其他)
;==========================================================================
Tab.UseTab(2)

; 一键恢复所有默认图标的按钮
MyGui.All_Default_Pic := MyGui.AddPicture("x410 y40 w116 h50", "HICON:" Base64PNG_to_HICON(All_Default_Base64PNG, height := 300))
MyGui.All_Default_Cursor := MyGui.AddPicture("xp yp wp hp Hidden", "HICON:" Base64PNG_to_HICON(All_Default_Cursor_Base64PNG, height := 300))
MyGui.All_Default_Btn := MyGui.AddButton("xp yp wp hp -Tabstop +0x4000000 vAll_Default_Btn").OnEvent("Click", All_Default)

; 条形百分比（Rang0-10，意思是从0-10）
MyGui.AddProgress("x162 y+9 w364 h26 c8042c0 Background333136 vMyProgress Range0-" . LV.GetCount(), Changed_Count.Value)

; 刷新/添加桌面的快捷方式至列表中
Add_Desktop_Cursor := MyGui.AddPicture("x162 y+6 w364 h46 Background343434")
Add_Desktop_Pic := MyGui.AddPicture("x174 yp+10 w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Add_Desktop_Base64PNG, height := 160))
Add_Desktop_Title := MyGui.AddText("x+8 yp w320 hp +0x200 BackgroundTrans", Add_Desktop_Text)
Add_Desktop_Btn := MyGui.AddButton("x162 yp-10 w364 h46 +0x4000000", "Clean").OnEvent("Click", Add_Desktop)

; 开始(菜单)的快捷方式添加至列表中
Sart_Menu_Cursor := MyGui.AddPicture("x162 y+6 w364 h46 Background343434")
Sart_Menu_Pic := MyGui.AddPicture("x174 yp+10 w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Sart_Menu_Base64PNG, height := 160))
Sart_Menu_Title := MyGui.AddText("x+8 yp w320 hp +0x200 BackgroundTrans", Add_Menu_Title_Text)
Sart_Menu_Btn := MyGui.AddButton("x162 yp-10 w364 h46 +0x4000000", "Sart_Menu").OnEvent("Click", Add_Sart_Menu)

; 其他文件夹的快捷方式添加至列表中
Other_Folder_Cursor := MyGui.AddPicture("x162 y+6 w364 h46 Background343434")
Other_Folder_Pic := MyGui.AddPicture("x174 yp+10 w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Other_Folder_Base64PNG, height := 160))
Other_Folder_Title := MyGui.AddText("x+8 yp w320 hp +0x200 BackgroundTrans", Add_Other_Title_Text)
Other_Folder_Btn := MyGui.AddButton("x162 yp-10 w364 h46 +0x4000000").OnEvent("Click", Add_Other_Folder)

; 打开所有快捷方式的文件夹
Add_UWP_APP_Cursor := MyGui.AddPicture("x162 y+6 w364 h46 Background343434")
Add_UWP_APP_Pic := MyGui.AddPicture("x174 yp+10 w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(UWP_APP_Base46PNG, height := 160))
Add_UWP_APP_Title := MyGui.AddText("x+8 yp w320 hp +0x200 BackgroundTrans", Add_UWP_APP_Text)
Add_UWP_APP_Btn := MyGui.AddButton("x162 yp-10 w364 h46 +0x4000000").OnEvent("Click", Add_UWP_APP)

; 备份列表中的快捷方式至桌面
Backup_LV_LINK_Cursor := MyGui.AddPicture("x162 y+6 w364 h46 Background343434")
Backup_LV_LINK_Pic := MyGui.AddPicture("x174 yp+10 w26 h26 BackgroundTrans", "HICON:" Base64PNG_to_HICON(Backup_Base64PNG, height := 160))
Backup_LV_LINK_Title := MyGui.AddText("x+8 yp w320 hp +0x200 BackgroundTrans", Backup_LV_Title_Text)
Backup_LV_LINK_Btn := MyGui.AddButton("x162 yp-10 w364 h46 +0x4000000").OnEvent("Click", Backup_LV_LINK)


;==========================================================================
; 第三个标签页：日志(Log) 
;==========================================================================
Tab.UseTab(3)

Logging := MyGui.AddEdit("x162 y37 Background333136 -E0x200 -WantReturn +Multi +ReadOnly")   ; 宽度、高度自适应


;==========================================================================
; 第四个标签页：帮助(Help) 
;==========================================================================
Tab.UseTab(4)
MyGui.SetFont("s9")
MyGui.AddPicture("x162 y37 w364 h125 Background333333")
MyGui.AddText("xp yp wp h25 BackgroundTrans +0x200", "（1）无法恢复默认图标：")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s原因①：部分应用程序无内置图标，使用的是应用目录中的图标")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s解决办法：在列表中右键项目，打开目标目录并寻找图标")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s原因②：出于安全，无法恢复UWP/APP默认图标")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s解决办法：`"开始(菜单)--更多`"中拖拽快捷方式至桌面")

MyGui.AddPicture("xp y+12 wp h75 Background333333")
MyGui.AddText("xp yp wp h25 BackgroundTrans +0x200", "（2）无法添加开始(菜单)中的UWP/APP至列表中：")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s原因：出于安全，UWP/APP不存在开始(菜单)的文件夹中")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s解决办法：可使用添加UWP/APP至桌面快捷方式的功能")

MyGui.AddPicture("xp y+12 wp h75 Background333333")
MyGui.AddText("xp yp wp h25 BackgroundTrans +0x200", "（3）部分应用未更换图标却显示已更换`"√`"")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s原因：应用程序无内置图标，使用的是应用目录中的图标")
MyGui.AddText("xp y+0 wp hp BackgroundTrans +0x200", "`s`s`s`s解决办法：在列表中右键项目，打开目标目录并寻找图标")


;==========================================================================
; 第五个标签页：关于(About) 
;==========================================================================
Tab.UseTab(5)
MyGui.SetFont("s10")
MyGui.AddPicture("x162 y37 w364 h40 Background333333")
MyGui.AddText("xp yp wp hp BackgroundTrans +0x200", "`s`sGithub：iKineticate")

MyGui.AddPicture("xp y+12 wp hp Background333333")
MyGui.AddText("xp yp wp hp BackgroundTrans +0x200", "`s`s酷安：林琼雅")

MyGui.AddPicture("xp y+12 wp hp Background333333")
MyGui.AddText("xp yp wp hp BackgroundTrans +0x200", Version_Text "2.4")

MyGui.AddPicture("xp y+12 wp hp Background333333")
MyGui.AddText("xp yp wp hp BackgroundTrans +0x200", ICON_SETS_Text "www.iconfont.cn")

MyGui.AddPicture("xp y+12 wp hp Background333333")
MyGui.AddText("xp yp wp hp BackgroundTrans +0x200", Startup_Screen_Text "小红书@黑画灰")

Tab.UseTab()


;==========================================================================
; 深色模式(Drak Mode) 
;==========================================================================
; （1）窗口标题栏（根据Windows版本赋予attr不同的值）
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
DllCall("uxtheme\SetWindowTheme", "Ptr", Logging.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)


;==========================================================================
; 列表透明(ListView transparency)(切换标签页时会闪烁)
;==========================================================================
; GWL_EXSTYLE := -20(设置新的扩展窗口样式)
; WS_EX_LAYERED := 0x80000(设置为分层窗口风格)
; crKey := RGB(颜色值)
; bAlpha := 0~255(透明度)
; LWA_COLORKEY := 0x00000001(crKey 作为透明度颜色)
; LWA_ALPHA := 0x00000002(bAlpha 确定分层窗口的不透明度)
; SW_SHOWNORMAL := 1(激活并显示窗口)
;DllCall("SetWindowLongPtr", "Ptr", LV.hwnd, "int", -20, "Int", 0x80000)
;DllCall("SetLayeredWindowAttributes", "Ptr", LV.hwnd, "Uint", 0xF0F0F0, "Uchar", 200, "Uint", 0x2) 
;DllCall("ShowWindow", "Ptr", LV.hwnd, "int", 1)


;==========================================================================
; 窗口显示与隐藏
;==========================================================================
Sleep(500)
Search_Bar.Focus()
Wait_Gui.Destroy()
Sleep(500)
MyGui.Show("Center")


;==========================================================================
; 监测鼠标的移动与操作
;==========================================================================
OnMessage(0x200, WM_MOUSEMOVE)


;==========================================================================
; 鼠标滚轮键/F2键点击ICO图片后更换快捷方式的图标
;==========================================================================
MButton::
F2:: 
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互
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
        UnChanged_Count.Value -= 1
        MyGui["MyProgress"].Value += 1
    }

    ; 刷新顶部、列表图标，并给该行添加"√"
    Display_Top_Icon(LV, LV.GetNext(0, "F"))
    Display_LV_Icon(LV, LV.GetNext(0, "F"))
    LV.Modify(ListViewGetContent("Count Focused",LV.Hwnd),,,"√")

    ; 添加至日志
    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
        . Log_Change_Text . ListViewGetContent("Selected Col1",LV.Hwnd) . "`n`s" 
        . FileName . "`n`n" 
        . Logging.Value
}


;==========================================================================
Return
;==========================================================================


;==========================================================================
; 监测鼠标活动（控件高亮+标签页移动）
;==========================================================================
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd)
{
    CurrControl := GuiCtrlFromHwnd(Hwnd)                    ; 检测是否为存在事件的控件（无事件的控件不被检测到）
    If CurrControl                                          ; 若是Gui的控件
    {
        thisGui := CurrControl.Gui                          ; thisGui = MyGui(控件的父窗口)
        Switch CurrControl.Name                             ; 检查控件的名称（控件的Opt里面的"vNmae"名称，而不是变量名）
        {
        Case "Minimize_Btn" :
            thisGui.Minimize_Cursor.Visible := True         ; 鼠标(光标)下高亮"最小化"
            thisGui.Close_Cursor.Visible := False
        Case "Close_Btn" :
            thisGui.Close_Cursor.Visible := True            ; 鼠标(光标)下高亮"关闭"
            thisGui.Minimize_Cursor.Visible := False
        Case "Caption" :
            thisGui.Minimize_Cursor.Visible := False        ; 当控件为标题栏，取消"最小化"、"关闭"高亮
            thisGui.Close_Cursor.Visible := False
            If (wParam = 1)                                 ; 若鼠标左键在自创的标题栏点击则变为在窗口原来的标题栏点击（实现拖动）
                Return PostMessage(0xA1, 2)                 ; WM_NCLBUTTONDOWN = 0xA1、LBUTTON = 2
        Case "All_Changed_Btn" :
            thisGui.All_Changed_Cursor.Visible := True      ; 鼠标下高亮"一键更换"的按钮
        Case "All_Default_Btn" :
            thisGui.All_Default_Cursor.Visible := True
        Default:                                            ; 若一个名字未匹配，则判断是否为标签页
            If (InStr(CurrControl.Name, "Tab_Item") AND (CurrControl != thisGui.Active_Tab))
            {
                If (CurrControl = thisGui.Ctrl_Cursor)      ; 若标签页控件等于光标下的上一次标签页控件，则返回（避免一直闪烁）(我也不想嵌套)
                    Return
                thisGui.Ctrl_Cursor := CurrControl          ; 若光标下的标签页发生变化，则定义这次光标下标签页
                thisGui.Tab_Cursor.Move(5, (40 * CurrControl.Index) + 61 )
                thisGui.Tab_Cursor.Redraw()                 ; 重绘：避免移动时出现文本重影在其他文本上
                thisGui.Tab_Cursor.Visible := True          ; 重绘完后在显示可以避免出现闪烁
            }
            Else    ; 不可用Return代替(Return会导致丢下光标下列表的高亮的问题)
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
        MyGui.Tab_Cursor.Visible := False
        MyGui.All_Changed_Cursor.Visible := False
        MyGui.All_Default_Cursor.Visible := False
    }
}


;==========================================================================
; 映射标签页的点击事件（映射到隐藏标签页）
;==========================================================================
Tab_Focus(GuiCtrlObj, info, *)
{
    If GuiCtrlObj = MyGui.Active_Tab
        Return

    DllCall("LockWindowUpdate", "Uint", MyGui.Hwnd)

    MyGui.Active_Tab := GuiCtrlObj                          ; 设置新的活动映射标签页
    Tab_Focus_Long.Move(5, (40*GuiCtrlObj.Index) + 61 )     ; 长焦点高亮方块移动至标签页
    Tab_Focus_Short.Move(5, (40*GuiCtrlObj.Index) + 70 )    ; 短焦点高亮方块移动至标签页
    Tab.Choose(trim(GuiCtrlObj.text))                       ; 选择映射到的对应的隐藏标签页

    ; 若为主页或其他标签页，则显示"图标、数据区域"，否则隐藏
    For Name in Show_Name_Map
    {
        MyGui[Name].Visible := ((GuiCtrlObj.Index = 1) OR (GuiCtrlObj.Index = 2)) ? True : False
    }

    DllCall("LockWindowUpdate", "Uint", 0)
    ; 调用双缓冲库，明显减少切换标签页时的闪烁
    ; https://www.autohotkey.com/board/topic/95930-window-double-buffering-redraw-gdi-avoid-flickering/
    RedrawDB(MyGui.hwnd)
}


;==========================================================================
; 部分控件根据窗口大小自适应调节位置与大小SHOW之前调节可避免
;==========================================================================
MyGui_Size(thisGui, MinMax, Width, Height)
{
    If MinMax = -1
        Return

    Caption.Move(,,Width)
    Caption.OnEvent("DoubleClick", (*) => "")   ; 赋予事件后，WM_MOUSEMOVE才能检测到控件
    MyGui.Minimize_Pic.Move(Width - 108)
    MyGui.Minimize_Cursor.Move(Width - 108)
    MyGui.Minimize_Btn.Move(Width - 108)
    MyGui.Minimize_Btn.OnEvent("Click", (*) => WinMinimize("A"))
    MyGui.Maximize_Pic.Move(Width - 72)
    MyGui.Close_Pic.Move(Width - 36)
    MyGui.Close_Cursor.Move(Width - 36)
    MyGui.Close_Btn.Move(Width - 36)
    MyGui.Close_Btn.OnEvent("Click", (*) => WinClose("A"))
    Left_Background.Move(,,,Height)
    Search_Bar.Move(,,Width - 200)
    Search_Btn.Move(Width - 38)
    Search_Btn.OnEvent("Click", Search)         ; 被赋予事件的控件是不支持移动的，因此先移动后再赋予事件
    Search_Line.Move(,,Width - 200)
    LV.Move(,, Width -174, Height -143)
    LV.ModifyCol(1, Width - 282)
    LV.ModifyCol(2, "+AutoHdr")
    LV.ModifyCol(3, "+AutoHdr")
    LV.Opt("+Redraw")
    Logging.Move(,, Width -174, Height -49)

    MyGui.OnEvent("Size", MyGui_Size, 0)        ; 关闭该事件
}


;==========================================================================
; 在列表中搜索含有关键词的项目的函数
;==========================================================================
Search(*)
{
    ; 若搜索框未输入文本，则提示“请输入”并返回
    If (Search_Bar.Value = "" OR Search_Bar.Value = Search_Text)
        Return  (ToolTip(Input_Text, 400, 240) AND SetTimer((*) => ToolTip(), -2000))

    ; 搜索框为焦点、允许列表多行选择、 取消列表中所有行的选择与焦点（避免与搜索结果重叠）
    Search_Bar.Focus()
    LV.Opt("+Multi")
    LV.Modify(0, "-Select -Focus")

    ; 从列表中搜索，若搜索到指定项目，则设为焦点并选择显示，然后刷新顶部图标
    Loop LV.GetCount()
    {
        If (!InStr(LV.GetText(A_Index), Trim(Search_Bar.Value)))
            Continue
        Sleep(300)
        LV.Modify(A_Index, "+Select +Focus +Vis")
        Display_Top_Icon(LV, A_Index)
    }

    LV.Opt("-Multi")

    ; 若搜素完所有项目后未找到目标，则提示“未找到”（利用未搜索到时焦点会在搜索框机制）
    If (ControlGetFocus("A") = Search_Bar.hWnd)
        Return  (ToolTip(Not_Fountd_Text, 400, 240) AND SetTimer((*) => ToolTip(), -2000))
}


;==========================================================================
; 搜索栏为焦点/非焦点事件的函数（显示/隐藏下划线，显示/隐藏“搜索......”）
;==========================================================================
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


;==========================================================================
; 刷新列表项目图标的函数
;==========================================================================
Display_LV_Icon(LV, Item)
{
    ; 调用DllCall_Icon函数和图像列表替换函数，添加图标并赋予给IconNumber--刷新列表左侧图标
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", DllCall_Icon(Link_Path)) + 1
    LV.Modify(Item, "Icon" . IconNumber)
}


;==========================================================================
; 刷新顶部ICO显示区域的函数
;==========================================================================
Display_Top_Icon(LV, Item)
{
    ; 调用DllCall获取选择(焦点)项目的图标--显示、刷新顶部图标--销毁hIcon
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    MyGui["Show_Icon_Area"].Value := "HICON:" DllCall_Icon(Link_Path)
    MyGui["Show_Icon_Area"].Opt("Background262626")
}


;==========================================================================
; 更换单个快捷方式的图标函数
;==========================================================================
Change_Link_Icon(LV, Item)
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

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

    ; 选择文件格式为“.ico”的图标，需更换图标路径赋予给Select_Icon_Path
    ; 若未选择照片或需更换图片是现在的图标则返回，否则更换图片并保存
    Select_Icon_Path := FileSelect(3,, An_Icon_Text "（" Link_Name "）", "Icon files(*.ico)")
    If ((Select_Icon_Path = "") OR (Select_Icon_Path = Link_Icon_Location))
        Return
    Link_Attribute.IconLocation := Select_Icon_Path
    Link_Attribute.Save()

    ; 更新显示的数据
    If (LV.GetText(Item, 2) = "")
    {
        Changed_Count.Value += 1
        UnChanged_Count.Value -= 1
        MyGui["MyProgress"].Value += 1
    }

    ; 刷新顶部、列表图标、添加"√"
    Display_Top_Icon(LV, Item)
    Display_LV_Icon(LV, Item)
    LV.Modify(Item,,,"√")

    ; 添加至日志
    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
        . Log_Change_Text . Link_Name . "`n`s" 
        . Select_Icon_Path . "`n`n" 
        . Logging.Value
}


;==========================================================================
; 更换所有快捷方式的图标事件
;==========================================================================
All_Changed(*)
{
    Safe_Msgbox := Msgbox(Safe_TrayTip_Text . Safe_Changed_Text,,"OKCancel Icon! Default2")
    If Safe_Msgbox = "Cancel"
        Return

    ; 选择存放ICO的文件夹
    Selected_Folder := DirSelect(, 0, Select_Folder_Text)
    If not Selected_Folder
        Return

    Changed_Log := ""
    Icons_Map := map()
    Same_Map := map()

    ; 从选择的文件夹中，将图标名称和图标路径添加至图标组合【ICO名称(键)-ICO路径(值)】(包括子文件夹里的文件)
    Loop Files, Selected_Folder "\*.ico", "R"
    {
        Icons_Map[RegExReplace(A_LoopFileName, "\.ico$")] := A_LoopFilePath
    }

    ; 提醒正在扫描、更换图标，并在结束扫描更换操作前禁止与窗口交互
    TrayTip(ing_TrayTip_Text)
    MyGui.Opt("+Disabled")

    ; 从图标组合中枚举，并从列表开头开始循环
    For Icon_Name, Icon_Path in Icons_Map
    {
        Loop LV.GetCount()
        {
            ; 注意若要跳过这一次循环，用Continue而不用Return（Return会退出整个循环）
            Link_Name := LV.GetText(A_Index, 1)

            ; 若快捷方式已更换过与快捷方式相同名称的ICO图标，则跳过这一次循环
            If (Same_Map.has(Link_Name) OR (Same_Map.has(Icon_Name)))
                Continue

            ; 比较快捷方式名称和图片名称的长度来决定判断调节谁包含谁
            Switch VerCompare(StrLen(Trim(Link_Name)), StrLen(Trim(Icon_Name)))
            {
            Case -1:
                If (!InStr(Trim(Icon_Name), Trim(Link_Name)))
                    Continue 
            Case 1:
                If (!InStr(Trim(Link_Name), Trim(Icon_Name)))
                    Continue 
            Case 0:
                If (StrLower(Trim(Link_Name)) != StrLower(Trim(Icon_Name)))
                    Continue 
                Same_Map[Link_Name] := "SAME"
                Same_Map[Icon_Name] := "SAME"
            }

            Link_Path := Link_Map[Link_Name . "LP"]
            COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)

            ; 若快捷方式图标为文件夹的图标，则跳过这一次循环
            If (Link_Icon_Location = Icon_Path)
                Continue

            Link_Attribute.IconLocation := Icon_Path
            Link_Attribute.Save()

            ; 更新显示的数据
            If (LV.GetText(A_Index, 2) = "")
            {
                Changed_Count.Value += 1
                UnChanged_Count.Value -= 1
                MyGui["MyProgress"].Value += 1
            }

            ; 刷新顶部图标、列表图标、聚焦更换行
            Display_Top_Icon(LV, A_index)
            Display_LV_Icon(LV, A_index)
            LV.Modify(A_index, "+Select +Focus +Vis",,"√")

            ; 添加至日志
            Changed_Log .= Link_Name . "`s=>`s" . Icon_Name . ".ico`n"
            Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
                . Log_Change_Text . LV.GetText(A_Index, 1) . "`n`s" 
                . Icon_Name . ".ico`n`n" 
                . Logging.Value
        }
    }

    ; 恢复与窗口的交互
    MyGui.Opt("-Disabled")
    SetTimer TrayTip, -2000

    ; 若未记录到更换信息，则显示“未更换任何图标”
    If (Changed_Log = "")
        Return Msgbox(Unchanged_Text, "Hellow World")
    Msgbox(Changed_Log, Success_Text)
}


;==========================================================================
; 恢复所有快捷方式的默认图标事件（UWP、APP不支持恢复默认）
;==========================================================================
All_Default(*)
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

    ; 提醒UWP、APP不支持恢复默认
    Default_Result := Msgbox(All_Default_Text, Default_Title_Text, "OKCancel Icon? Default2")
    If Default_Result = "Cancel"
        Return

    Loop LV.GetCount()
    {
        If ((LV.GetText(A_Index, 2) != "√") OR (LV.GetText(A_Index, 3) = "uwp") OR (LV.GetText(A_Index, 3) = "app"))
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
            UnChanged_Count.Value += 1
            MyGui["MyProgress"].Value -= 1
        }

        ; 刷新顶部图标、列表图标，聚焦恢复默认行并清除该行"√"
        Display_Top_Icon(LV, A_index)
        Display_LV_Icon(LV, A_index)
        LV.Modify(A_index, "+Select +Focus +Vis",,"")

        ; 添加至日志
        Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Default_Text . LV.GetText(A_Index, 1) . "`n`n" 
            . Logging.Value
    }

    TrayTip(Completed_Text)
    SetTimer TrayTip, -2000
}


;==========================================================================
; 列表右键菜单事件
;==========================================================================
Link_ContextMenu(LV, Item, IsRightClick, X, Y)
{
    If ((Item > 1000) OR (Item <= 0) OR !IsSet(Item)) ; 避免右键列表的标题栏时出现错误
        Return

    ; 快捷方式的目标路径、目标目录、路径、目录
    Link_Name := LV.GetText(Item, 1)
    Link_Target_Path := Link_Map[Link_Name . "LTP"]
    Link_Target_Dir := Link_Map[Link_Name . "LTD"]
    Link_Path := Link_Map[Link_Name . "LP"]
    Link_Dir := Link_Map[Link_Name . "LD"]

    ; 调用WshShell对象的函数，获取link各个属性
    COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)

    ; 创建菜单并添加选项及功能
    Link_Menu := Menu()
    Link_Menu.Add(Menu_Run_Text, (*) => Run(Link_Path))
    Link_Menu.Add
    Link_Menu.Add(Menu_Change_Text, (*) => Run(Change_Link_Icon(LV, Item)))
    Link_Menu.Add
    Link_Menu.Add(Menu_Default_Text, Link_Default)
    Link_Menu.Add
    Link_Menu.Add(Menu_TargetDir_Text, (*) => Run(Link_Target_Dir))
    Link_Menu.Add
    Link_Menu.Add(Menu_Rename_Text, Link_Rename)

    ; 若当前列表中不是桌面的快捷方式，则菜单添加一项"添加至桌面"的选项
    If Which_Add != "Desktop"
    {
        Link_Menu.Add
        Link_Menu.Add(Add_Link_Desktop_Text, Link_Add_Desktop)
        Link_Menu.SetIcon(Add_Link_Desktop_Text, "HICON:" Base64PNG_to_HICON(Menu_Desktop_Base64PNG))
    }

    Link_Infor := Menu()
    Link_Infor.Add(Copy_LTP_Text . Link_Target_Path, (*) => (A_Clipboard := Link_Target_Path))
    Link_Infor.Add
    Link_Infor.Add(Copy_LTD_Text . Link_Target_Dir, (*) => (A_Clipboard := Link_Target_Dir))
    Link_Infor.Add
    Link_Infor.Add(Copy_LP_Text . Link_Path, (*) => (A_Clipboard := Link_Path))
    Link_Infor.Add
    Link_Infor.Add(Copy_LD_Text . Link_Dir, (*) => (A_Clipboard := Link_Dir))
    Link_Infor.Add
    Link_Infor.Add(Copy_LIL_Text . Link_Attribute.IconLocation, (*) => (A_Clipboard := Link_Attribute.IconLocation))
    Link_Menu.Add
    Link_Menu.Add(Menu_LA_Text, Link_Infor)

    ; 调用DllCall获取选择(焦点)项目的图标--在菜单栏第一行显示图标--销毁hIcon
    ; 调用后面的Base64转PNG函数，在菜单栏第二~五行添加对应图标
    Link_Menu.SetIcon(Menu_Run_Text, "HICON:" DllCall_Icon(Link_Path))
    Link_Menu.SetIcon(Menu_Change_Text, "HICON:" Base64PNG_to_HICON(Menu_Change_Base64PNG))
    Link_Menu.SetIcon(Menu_Default_Text, "HICON:" Base64PNG_to_HICON(Menu_Default_Base64PNG))
    Link_Menu.SetIcon(Menu_TargetDir_Text, "HICON:" Base64PNG_to_HICON(Menu_Folders_Base64PNG))
    Link_Menu.SetIcon(Menu_Rename_Text, "HICON:" Base64PNG_to_HICON(Menu_Rename_Base64PNG))
    Link_Menu.SetIcon(Menu_LA_Text, "HICON:" Base64PNG_to_HICON(Menu_Attrib_Base64PNG))
    
    ; 若选择与焦点行为UWP应用或APP应用，则将恢复默认图标和打开目标目录的功能禁止
    If ((Link_Target_Path = Safe_Text) OR InStr(Link_Target_Path, "WindowsSubsystemForAndroid"))
    {
        Link_Menu.Disable(Menu_Default_Text)
        Link_Menu.Disable(Menu_TargetDir_Text)
    }

    Link_Menu.Show()

    ; 恢复快捷方式的默认图标并刷新
    Link_Default(*)
    {
        ; 若图标为默认图标（原EXE图标或UWP/APP应用）则返回，否则更换图片并保存等操作
        If ((Link_Icon_Location = Link_Target_Path) OR (Link_Icon_Location = ""))
            Return
        Link_Attribute.IconLocation := Link_Target_Path
        Link_Attribute.Save()
        
        ; 更新显示的数据
        If (LV.GetText(Item, 2) = "√")
        {
            Changed_Count.Value -= 1
            UnChanged_Count.Value += 1
            MyGui["MyProgress"].Value -= 1
        }

        ; 刷新顶部图标、列表图标、删除"√"
        Display_Top_Icon(LV, Item)
        Display_LV_Icon(LV, Item)
        LV.Modify(Item,,,"")

        ; 添加至日志
        Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Default_Text . Link_Name . "`n`n" 
            . Logging.Value
    }

    ; 重命名快捷方式名称
    Link_Rename(*)
    {
        MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

        IB := InputBox(Rename_Text, Link_Name, "W300 H100", Trim(Link_Name))    ; 输入窗口
        If IB.Result="CANCEL"
            Return

        ; 重命名旧快捷方式的名称（FileMove：移动并重命名）
        New_Link_Path := Link_Dir . "\" . IB.Value . ".lnk"
        FileMove(Link_Path, New_Link_Path)

        ; 重命名后，在ICO数组中,添加对应的新键-值，然后删除对应的旧键-值
        For Value in ["LP", "LTP", "LTD", "LD"]
        {
            Switch Value    ; 用switch而不用if是因为switch好看和短
            {
            Case "LP" : 
                Link_Map[IB.Value . "LP"] := New_Link_Path
                Link_Map.Delete(Link_Name . Value)
            Default   : 
                Link_Map[IB.Value . Value] := Link_Map[Link_Name . Value]
                Link_Map.Delete(Link_Name . Value)
            }
        }

        ; 添加至日志
        Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . Log_Rename_Text . Link_Name . "`n`s" 
            . Log_NewName_Text . IB.Value . "`n`n" 
            . Logging.Value

        ; 更换列表快捷方式名称（在最后才更新是因为过早更新会导致在数组中的link_name发生改变而不能删除对应键值）
        LV.Modify(Item,, IB.Value)
    }

    ; 添加当前的快捷方式至桌面
    Link_Add_Desktop(*)
    {
        Try
        {
            FileCopy(Link_Path, A_Desktop)

            ; 添加至日志
            Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
            . "添加“`s" . Link_Name . "`s”至当前用户的桌面" . "`n`n" 
            . Logging.Value

            Msgbox("成功添加“`s" . Link_Name . "`s”至当前用户的桌面")
        
        }
        Catch Error
        {
            Msgbox(Add_Link_Error_Text,, "Icon!")
            Return
        }
    }
}


;==========================================================================
; 清空列表中的快捷方式的函数
;==========================================================================
Clean_LV(*)
{
    LV.Delete()
    Link_Map.Clear()        ; 删除存储的数组
    Changed_Count.Value := 0
    UnChanged_Count.Value := 0
    All_Count.Value := 0
    MyGui["MyProgress"].Value := 0
}


;==========================================================================
; 刷新/添加桌面的快捷方式至列表中
;==========================================================================
Add_Desktop(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互

    Add_Desktop_Msgbox := Msgbox(Add_Desktop_Title_Text,, "Icon? OKCancel")
    If Add_Desktop_Msgbox = "Cancel"
        Return

    ; 清空列表、计数、数组
    Clean_LV

    global Which_Add := "Desktop"

    ; 添加桌面快捷方式
    For Desktop in [A_Desktop, A_DesktopCommon]
    {
        Add_Link_To_LV(Desktop, Mode := "")
    }
    
    ; 刷新计数
    UnChanged_Count.Value := LV.GetCount() - Changed_Count.Value
    All_Count.Value := LV.GetCount()
    MyGui["MyProgress"].Opt("Range0-" . LV.GetCount())
    MyGui["MyProgress"].Value := Changed_Count.Value

    ; 添加至日志
    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
    . Add_Desktop_Text . "`n`n" 
    . Logging.Value

    Msgbox("成功(Success)！")
}


;==========================================================================
; 添加开始(菜单)中的快捷方式至列表的函数
;==========================================================================
Add_Sart_Menu(*)
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

    Sart_Menu_Msgbox := Msgbox(Sart_Menu_Text,, "Icon? OKCancel")
    If Sart_Menu_Msgbox = "Cancel"
        Return

    ; 清空列表、计数、数组
    Clean_LV

    ; 更新备份对象
    global Which_Add := "Start"

     ; 将当前用户、所有用户的开始(菜单)的快捷方式添加至列表中
    For Value in [A_StartMenu, A_StartMenuCommon]
    {
        Add_Link_To_LV(Value, Mode := "R")
    }

     ; 刷新计数
    UnChanged_Count.Value := LV.GetCount() - Changed_Count.Value
    All_Count.Value := LV.GetCount()
    MyGui["MyProgress"].Opt("Range0-" . LV.GetCount())
    MyGui["MyProgress"].Value := Changed_Count.Value

     ; 添加至日志
    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
    . Add_Menu_Text . "`n`n" 
    . Logging.Value

    Msgbox(Add_Menu_Text)
}


;==========================================================================
; 添加其他文件夹的快捷方式至列表中
;==========================================================================
Add_Other_Folder(*)
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

    Add_Other_Msgbox := Msgbox(Add_Other_Msgbox_Text,, "Icon? OKCancel")
    If Add_Other_Msgbox = "Cancel"
        Return

    Selected_Oher_Folder := DirSelect(, 0, Select_Other_Text)
    If not Selected_Oher_Folder
        Return

   ; 清空列表、计数、数组
    Clean_LV

    ; 更新备份对象
    global Which_Add := RegExReplace(Selected_Oher_Folder, "^.*\\")

    Add_Link_To_LV(Selected_Oher_Folder, Mode := "")

    ; 刷新计数
    UnChanged_Count.Value := LV.GetCount() - Changed_Count.Value
    All_Count.Value := LV.GetCount()
    MyGui["MyProgress"].Opt("Range0-" . LV.GetCount())
    MyGui["MyProgress"].Value := Changed_Count.Value

    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
    . Add_Other_Text . "`n`n" 
    . Logging.Value

    Msgbox(Add_Other_Text)
}


;==========================================================================
; 添加UWP、APP的快捷方式至桌面中的函数
;==========================================================================
Add_UWP_APP(*)
{
    Add_UWP_APP_Msgbox := Msgbox(Add_UWP_APP_MT,,"Icon? OKCancel")
    If Add_UWP_APP_Msgbox = "Cancel"
        Return

    Run("shell:AppsFolder")
}


;==========================================================================
; 备份列表中的快捷方式的函数
;==========================================================================
Backup_LV_LINK(*)
{
    MyGui.Opt("+OwnDialogs")    ;解除对话框后才可于GUI窗口交互

    Backup_Msgbox := Msgbox("是否备份列表中的快捷方式至名为“`s" . Which_Add . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm") . "`s”的桌面文件夹？",,"Icon? OKCancel")
    If Backup_Msgbox = "Cancel"
        Return

    Backup_Folder := A_DesktopCommon . "\" . Which_Add . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm")

    If DirExist(Backup_Folder)
    {
        Backup_Folder := "(2)" . Backup_Folder
    }
    
    DirCreate(Backup_Folder)

    ; 复制所有的.lnk至备份文件夹里面
    Loop LV.GetCount()
    {
        Link_Name := LV.GetText(A_Index, 1)
        Link_Path := Link_Map[Link_Name . "LP"]
        FileCopy(Link_Path, Backup_Folder, 1)
    }

    ; 添加至日志
    Logging.Value := "`s" . FormatTime(A_Now, "yyyy/MM/dd HH:mm:ss`n`s") 
    . "已备份至名为" . Which_Add . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm") . "的桌面文件夹" . "`n`n" 
    . Logging.Value

    Msgbox("成功(Success)！")
}


;==========================================================================
; DllCall获取图标的函数
;==========================================================================
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


;==========================================================================
; 调用WshShell对象（COM对象）获取、更改、创建快捷方式的属性
;==========================================================================
COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
{
    Link_Attribute := ComObject("WScript.Shell").CreateShortcut(Link_Path)          ; 快捷方式的属性
    Link_Icon_Location := RegExReplace(Link_Attribute.IconLocation, ",[^,]+$")      ; 快捷方式的图标路径(去除了图片编号)(存储的是值而不是变量)
}


;==========================================================================
; 将目标文件夹中的快捷方式添加进列表的事件
;==========================================================================
Add_Link_To_LV(Link_Folder_Path, Mode)  ; Mode:="R"扫描子文件夹中的文件，=""只扫描目标文件夹中的文件
{
    Loop Files, Link_Folder_Path "\*.lnk", Mode
    {
        If ((Mode = "R") AND (RegExMatch(A_LoopFileName, "Uninstall|卸载")))   ; 若添加开始(菜单)快捷方式至列表，且是卸载的快捷方式，则下一轮循环
            Continue

        Link_Name := RegExReplace(A_LoopFileName, "\.lnk$")     ; 快捷方式的名称（去除了后缀名）

        If Link_Map.Has(Link_Name . "LTP")                      ; 排除相同的名称的快捷方式
            Continue

         ; 调用WshShell对象的函数，获取快捷方式的属性、目标路径、目标目录、图标路径
        Link_Path := A_LoopFilePath
        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
        Link_Target_Path := Link_Attribute.TargetPath
        Link_Target_Dir := (Link_Target_Path != "" AND Link_Attribute.WorkingDirectory = "") ? RegExReplace(Link_Target_Path, "\\[^\\]+$"):Link_Attribute.WorkingDirectory
 
        SplitPath(Link_Path,, &Link_Dir)                        ; 快捷方式的目录
        SplitPath(Link_Target_Path,,, &Link_Target_Ext)         ; 快捷方式的目标扩展名

         ; 快捷方式是否更换图标的判定：已更换图标显示"√" // 未更换图标不显示
        Switch
        {
        Case Link_Icon_Location = "" :                          ; UWP的默认图标
            Link_YesNo := ""
        Case Link_Icon_Location = Link_Target_Path :            ; 应用的默认图标
            Link_YesNo := ""
        ; 系统软件(如%windir%)、APP应用、某些图片路径为{???}\?.exe的UWP应用的默认图标
        Case RegExMatch(Link_Icon_Location, "i)%[^%]*%|WindowsSubsystemForAndroid|system32\\.*dll|\{[^\{]*\}\\[^\\]*\.exe$") :
            Link_YesNo := ""
        ; 需要排除某些应用————应用无图标，使用的是应用目录图标
        Case StrLower(Link_Target_Dir) = StrLower(RegExReplace(Link_Icon_Location, "\\([^\\]+)\.ico$")) :
            Link_YesNo := ""
        Case InStr(Link_Target_Dir, RegExReplace(Link_Icon_Location, "\\([^\\]+)\.ico$")):
            Link_YesNo := ""
        Default :
            Link_YesNo := "√"
            Changed_Count.Value += 1
        }
        
        ; 快捷方式的目标扩展名 = 转化为小写 && UWP应用为uwp && WSA应用为app
        Switch
        {
        Case Link_Target_Ext = "" :
            Link_Target_Ext := "uwp"
        Case InStr(Link_Target_Path, "WindowsSubsystemForAndroid") :
            Link_Target_Ext := "app"
        Case isUpper(Link_Target_Ext) :
            Link_Target_Ext := StrLower(Link_Target_Ext)
        }

        ; 在Link_Map数组中，键--值："快捷方式名称+英文缩写字符"--"对应值"
        ; LTP = Link Target Path = 快捷方式的目标路径（UWP无法查看）
        ; LTD = Link Target Dir  = 快捷方式的目标目录（UWP无法查看）
        ; LP  = Link Path        = 快捷方式的路径
        ; LD  = Link Dir         = 快捷方式的目录
        Link_Map[Link_Name . "LTP"] := Link_Target_Path = "" ? Safe_Text:Link_Target_Path
        Link_Map[Link_Name . "LTD"] := Link_Target_Dir = "" ? Safe_Text:Link_Target_Dir
        Link_Map[Link_Name . "LP"]  := A_LoopFilePath
        Link_Map[Link_Name . "LD"]  := Link_Dir

        ; 调用DllCall_Icon函数和图像列表替换函数，添加图标并赋予给IconNumber--刷新列表左侧图标
        IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", DllCall_Icon(A_LoopFilePath)) + 1

        ; 列表添加图标、名称、"√"、目标扩展名
        LV.Add("Icon" . IconNumber, Link_Name, Link_YesNo, Link_Target_Ext)
    }

    ; 先第一列(名称)排列，后第三列(扩展名)排列，保证排列顺序以扩展名为主，名称为次
    LV.ModifyCol(1, "+Sort")                    
    LV.ModifyCol(2, "+Center")
    LV.ModifyCol(3, "+Center +Sort") 
}