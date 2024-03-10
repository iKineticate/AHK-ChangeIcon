;// @Name                   AHK-ChangeIcon
;// @Author                 iKineticate
;// @Version                v2.5.3
;// @Destription:zh-CN      快速更换桌面快捷方式图标
;// @Destription:en         Quickly change of desktop shortcut icons
;// @HomepageURL            https://github.com/iKineticate/AHK-ChangeIcon
;// @Icon Source            https://www.iconfont.cn and https://www.flaticon.com
;// @Date                   2024/03/04

;@Ahk2Exe-SetVersion 2.5.3
;@Ahk2Exe-SetFileVersion 2.5.3
;@Ahk2Exe-SetProductVersion 2.5.3
;@Ahk2Exe-SetName AHK-ChangeIcon
;@Ahk2Exe-ExeName AHK-ChangeIcon
;@Ahk2Exe-SetCompanyName AHK-ChangeIcon
;@Ahk2Exe-SetProductName AHK-ChangeIcon
;@Ahk2Exe-SetDescription AHK-ChangeIcon
;@Ahk2Exe-SetOrigFilename AHK-ChangeIcon.exe
;@Ahk2Exe-SetLegalTrademarks AHK-ChangeIcon

#Requires AutoHotkey v2.0
#Include AHK_Language.ahk
#Include <Class_Button>
#Include <Class_MyGui>
#Include <Class_LV_Colors>  ; https://github.com/AHK-just-me/AHK2_LV_Colors
#Include <Gdip_All>         ; https://github.com/buliasz/AHKv2-Gdip
#Include <GuiCtrlTips>      ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116218
#Include <AHK_Base64PNG>
#SingleInstance Ignore

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


;========================================================================================================
; 启动GDIP
;======================================================================================================== 
If !pToken := Gdip_Startup()
{
    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
    ExitApp
}
OnExit ExitFunc


;========================================================================================================
; 创建初始化文件
;======================================================================================================== 
global info_ini_path := A_AppData . "\AHK-ChangeIcon\info.ini"      ; 配置路径
(!FileExist(A_AppData . "\AHK-ChangeIcon")) ? DirCreate(A_AppData . "\AHK-ChangeIcon"):""   ; 若不存在则创建配置文件的目录
(!FileExist(info_ini_path)) ? FileAppend("[info]`nlast_selected_other_path=`nlast_icons_folder_path=", info_ini_path):""    ; 若不存在配置文件，则创建文件并写入段名、键名
For Value in ["last_selected_other_path", "last_icons_folder_path"]
{
    If IniRead(info_ini_path, "info", Value, "0")   ; 若配置文件不存在任意一个键，则在同一段中创建该键（兼容旧版）
        Continue
    iniWrite("", info_ini_path, "info", Value)
}

;========================================================================================================
; 创建窗口
;======================================================================================================== 
; 创建现代风格GUI
ahkGUI := CreateModernGUI( {x:"center", y:"center", w:1200/2, h:650/2, back_color:"202020", gui_options:"-caption -Resize +Border +DPIScale", gui_name:"AHK-ChangeIcon", gui_font_options:"Bold cffffff s8", gui_font:"Microsoft YaHei UI", show_options:""} )
; 创建窗口控制按钮（关闭、最大化、最小化）
ahkGUI.CreateWindowsControlButton( {margin_top:"0", margin_right:"0", button_w:54/2, button_h:40/2, pen_width:3, active_color:"AD62FD"} )
; 设置提示选项
MyGui.Tooltips := GuiCtrlTips(MyGui)
MyGui.ToolTips.SetFont(,"Microsoft YaHei UI",,)
MyGui.ToolTips.SetBkColor("0xff303030")
MyGui.ToolTips.SetTxColor("0xff999999")


;========================================================================================================
; 创建标签页
;======================================================================================================== 
; 创建左侧背景
MyGui.AddPicture("x0 y0" . " w" . 240/2 . " h" . 650/2 . " background252525")
; 创建软件LOGO
MyGui.AddPicture("x" . 70/2 . " y" . 42/2 . " w" . 100/2 . " h" . 100/2 . " BackgroundTrans", "HICON:" Base64PNG_to_HICON(LOGO_PNG_BASE64, height := 512))
; 设置标签页的各项参数
tab_prop := {}
tab_prop.label_name := [Text.HOME, Text.Other, Text.LOG, Text.HELP, Text.ABOUT]
tab_prop.label_prop := {distance:0, text_options:"center +0x200", font_options:"Bold cf5f5f5 s11", font:"", font_normal_color:"f5f5f5", font_active_color:"ad62fd"}   ; 输入空格来调整标签按钮里的文本相对按钮的x位置
tab_prop.label_active  := {margin_left:0, margin_top:"center", w:220/2, h:72/2, R:24/2, color:"0xE6f5f5f5"}
;tab_prop.label_indicator := {margin_left:20/2, margin_top:"center", w:10/2, h:28/2, R:4/2, color:"ad62fd"}
tab_prop.logo_symbol  := {margin_left:2, font_name:"Segoe UI Symbol"}
tab_prop.logo_size    := [22/2, 20/2, 24/2, 24/2, 32/2]
tab_prop.logo_unicode := ["0xE10F", "0xE292", "0x1F4DC", "0xE115", "0x24D8"]
tab_item := CreateButton( {name:"logo", x:10/2, y:180/2, w:220/2, h:85/2} ).NewTab( tab_prop )


;========================================================================================================
; 标签页一：主页
;========================================================================================================  
Tab.UseTab(1)
; 左侧偏右背景
MyGui.AddPicture("x" . 240/2 . " y0" . " w" . 200/2 . " h" . 650/2 . " background303030")
; 上方的框
MyGui.AddPicture("vTop_Group_Box x" . 250/2 . " y" . 59/2 . " w" 180/2*(A_ScreenDPI/96) . " h" . 304/2*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(MyGui["Top_Group_Box"], "0xff999999", 15, isFill:="1")
; 上方快捷方式的旧图标
MyGui.AddPicture("vShow_Old_Icon x" . 295/2 . " y" . 83/2 . " w" . 90/2 . " h" . 90/2 . " BackgroundTrans")
; 转换符号
FontSymbol( {name:"Replace_Symbol", x:250/2, y:59/2, w:180/2, h:304/2, unicode:0xE1FD, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 56/4, text_options:"+0x200 center"} )
; 下方快捷方式的新图标
MyGui.AddPicture("vShow_New_Icon x" . 295/2 . " y" . 248/2 . " w" . 90/2 . " h" . 90/2 . " BackgroundTrans")

; 下方的框
MyGui.AddPicture("vBottom_Goup_Box x" . 250/2 . " y" . 395/2 . " w" . 180/2*(A_ScreenDPI/96) . " h" . 196/2*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(MyGui["Bottom_Goup_Box"], "0xff999999", 15, isFill:="1")
; 下方已更换、未更换、总共符号
FontSymbol( {name:"Change_Symbol", x:250/2, y:416/2, w:55/2, h:38/2, unicode:0x25CB, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 32/2, text_options:"+0x200 center"} )
FontSymbol( {name:"Yes_Symbol", x:250/2, y:420/2, w:55/2, h:36/2, unicode:0x2714, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 32/4, text_options:"+0x200 center"} )
FontSymbol( {name:"Uchange_Symbol", x:250/2, y:472/2, w:55/2, h:38/2, unicode:0x25CE, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 32/2, text_options:"+0x200 center"} )
FontSymbol( {name:"Total_Symbol", x:250/2, y:528/2, w:55/2, h:38/2, unicode:0x25C9, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 32/2, text_options:"+0x200 center"} )
; 已更换、未更换、总共文本
MyGui.AddText("x" . 305/2 . " y" . 420/2 . " w" . 75/2 . " h" . 36/2 . " BackgroundTrans +0x200", Text.CHANGED_ICON)
MyGui.AddText("x" . 305/2 . " y" . 476/2 . " w" . 75/2 . " h" . 36/2 . " BackgroundTrans +0x200", Text.UNCHANGED_ICON)
MyGui.AddText("x" . 305/2 . " y" . 532/2 . " w" . 75/2 . " h" . 36/2 . " BackgroundTrans +0x200", Text.LV_LINK_TOTAL)
; 已更换、未更换、总共数量
MyGui.AddText("vChanged_Count x" . 382/2 . " y" . 420/2 . " w" . 42/2 . " h" . 36/2 . " BackgroundTrans +0x200", "0")
MyGui.AddText("vUnchanged_Count x" . 382/2 . " y" . 476/2 . " w" . 42/2 . " h" . 36/2 . " BackgroundTrans +0x200", "0")
MyGui.AddText("vTotal_Count x" . 382/2 . " y" . 532/2 . " w" . 42/2 . " h" . 36/2 . " BackgroundTrans +0x200", "0")

; 搜索栏(搜索背景+搜索图标+Edit控件)
MyGui.AddPicture("vSearch_Back x" . 478/2 . " y" . 70/2 . " w" . 320/2 . " h" . 74/2 . " BackgroundTrans", "HICON:" Base64PNG_to_HICON(SEARCH_BACK_PNG_BASE64, height := 512))
FontSymbol( {name:"Search_Symbol", x:478/2, y:70/2, w:70/2, h:74/2, unicode:0xE11A, font_name:"Segoe UI Symbol", text_color:"999999", back_color:"trans", font_options:"s" 55/4, text_options:"+0x200 center"} )
MyGui.AddEdit("vSearch_Edit x" . 532/2 . " y" . 92/2 . " w" . 240/2 . " h" . 35/2 . " Background2E2E2E r1 -E0X200", Text.PLEASE_INPUT_NAME) ; r1可以隐藏该控件的上下导航栏
MyGui["Search_Edit"].SetFont("c999999")
MyGui["Search_Edit"].OnEvent("LoseFocus", Search_Bar_LoseFocus)
MyGui["Search_Edit"].OnEvent("Focus", Search_Bar_Focus)
MyGui.AddButton("v Hidden_BTN yp w26 h26 Default Hidden").OnEvent("Click", Search)

; 恢复默认图标的PNG图片按钮
CreateButton( {name:"Restore_All", x:815/2, y:68/2, w:175/2, h:79/2} ).PNG( {normal_png_base64:RESTORE_ALL_NORMAL_PNG_BASE64, active_png_base64:RESTORE_ALL_ACTIVE_PNG_BASE64, png_quality:"300"} )
MyGui.ToolTips.SetTip(MyGui["Restore_All_BUTTON"], TEXT.TIP_RESTORE)
; 更换所有图标的PNG图片按钮
CreateButton( {name:"Change_All", x:1008/2, y:68/2, w:175/2, h:79/2} ).PNG( {normal_png_base64:CHANGE_ALL_NORMAL_PNG_BASE64, active_png_base64:CHANGE_ALL_ACTIVE_PNG_BASE64, png_quality:"300"} )
MyGui.ToolTips.SetTip(MyGui["Change_All_BUTTON"], TEXT.TIP_CHANGE)

; 创建列表(+LV0x10000: 双缓冲，redraw: 加载数据后在redraw， -Multi: 禁止多选)
LV := MyGui.AddListView("x" . 440/2 . " y" . 180/2 . " w" . 760/2 . " h" . 470/2 . " Background232323 -redraw -Multi -E0x200 +LV0x10000", ["Name", "Y/N", "Type"])
LV.SetFont("cf5f5f5 s14")
LV.OnEvent("ItemFocus", Refresh_Display_Icon)
LV.OnEvent("DoubleClick", Change_Link_Icon)
LV.OnEvent("ContextMenu", LV_Context_Menu)
global link_map := map()                        ; 创建快捷方式的映射数组
global LV_link_from := "Desktop"                ; 创建当前列表中的快捷方式是来自哪个文件夹的变量
global image_list_ID := IL_Create()             ; 为添加图标做好准备: 创建图像列表
LV.SetImageList(image_list_ID)                  ; 为添加图标做好准备: 设置显示图标列表
; 添加桌面快捷方式至列表
For Desktop in [A_Desktop, A_DesktopCommon]
{
    Add_Folder_Link_To_LV(Desktop, Mode := "")
}
; 设置、调整列表
LV.ModifyCol(1, 460/2)
LV.ModifyCol(2, "+AutoHdr")
LV.ModifyCol(3, "+AutoHdr")
SetLV := LV_Colors(LV, 0, 0, 0)
SetLV.Critical := 100
Loop LV.GetCount()
{
    If (Mod(A_Index, 2) = 0)
        Continue
    SetLV.Row(A_Index, 0x292929)
}
SetLV.ShowColors(true)
LV.Opt("+Redraw")
; 更新计数
MyGui["Total_Count"].Value := LV.GetCount()
MyGui["Unchanged_Count"].Value := LV.GetCount() - MyGui["Changed_Count"].Value



;==========================================================================
; 第二个标签页：其他(其他)
;==========================================================================
Tab.UseTab(2)
CreateButton( {name:"Add_Desktop", x:320/2, y:80/2, w:800/2, h:90/2} ).Text( {R:24/2, normal_color:"0x26ffffff", active_color:"909090", text:Text.ADD_DESKTOP_TO_LV, text_options:"+0x200", text_margin:10, font_options:"cffffff s13", font:""} )
FontSymbol( {name:"Add_Desktop_Symbol", x:325/2, y:78/2, w:90/2, h:90/2, unicode:0xE2CB, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"trans", font_options:"s" 90/4, text_options:"+0x200 center"} )

CreateButton( {name:"Add_Start", x:320/2, y:190/2, w:800/2, h:90/2} ).Text( {R:24/2, normal_color:"0x26ffffff", active_color:"909090", text:Text.ADD_START_TO_LV, text_options:"+0x200", text_margin:10, font_options:"cffffff s13", font:""} )
FontSymbol( {name:"Add_Start_Symbol", x:325/2, y:191/2, w:90/2, h:90/2, unicode:0xE154, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"trans", font_options:"s" 90/4, text_options:"+0x200 center"} )

CreateButton( {name:"Add_Other", x:320/2, y:300/2, w:800/2, h:90/2} ).Text( {R:24/2, normal_color:"0x26ffffff", active_color:"909090", text:Text.ADD_OTHER_TO_LV, text_options:"+0x200", text_margin:10, font_options:"cffffff s13", font:""} )
FontSymbol( {name:"Add_Other_Symbol", x:325/2, y:304/2, w:90/2, h:90/2, unicode:0xE1C1, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"trans", font_options:"s" 90/5, text_options:"+0x200 center"} )

CreateButton( {name:"Add_UWP_WSA", x:320/2, y:410/2, w:800/2, h:90/2} ).Text( {R:24/2, normal_color:"0x26ffffff", active_color:"909090", text:Text.ADD_UWP_WSA_TO_LV, text_options:"+0x200", text_margin:10, font_options:"cffffff s13", font:""} )
FontSymbol( {name:"Add_UWP_WSA_Symbol", x:325/2, y:409/2, w:90/2, h:90/2, unicode:0xE2F8, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"trans", font_options:"s" 90/3.5, text_options:"+0x200 center"} )

CreateButton( {name:"Add_BackUp", x:320/2, y:520/2, w:800/2, h:90/2} ).Text( {R:24/2, normal_color:"0x26ffffff", active_color:"909090", text:Text.BACKUP_LV_LINK, text_options:"+0x200", text_margin:10, font_options:"cffffff s13", font:""} )
FontSymbol( {name:"Add_BackUp_Symbol", x:325/2, y:522/2, w:90/2, h:90/2, unicode:0xE17C, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"trans", font_options:"s" 90/5, text_options:"+0x200 center"} )


;==========================================================================
; 第三个标签页：日志(Log) 
;==========================================================================
Tab.UseTab(3)
MyGui.AddEdit("vLog x" . 240/2 . " y" . 40/2 . " w" . 960/2 . " h" . 610/2 . " Background303030 -E0x200 -WantReturn -Wrap +0x100000 +ReadOnly") ; +0x100000: 水平滚动条
MyGui["Log"].SetFont("s10")


;==========================================================================
; 第四个标签页：帮助(Help) 
;==========================================================================
Tab.UseTab(4)


;==========================================================================
; 第五个标签页：关于(About) 
;==========================================================================
Tab.UseTab(5)
; 背景
MyGui.AddPicture("vAbout_Background x" . 270/2 . " y" . 45/2 . " w" 900/2*(A_ScreenDPI/96) . " h" . 585/2*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(MyGui["About_Background"], "0x0Dffffff", 15, isFill:="true")
; 软件名
MyGui.AddText("vsoftware x" 320/2 " y" 80/2 " w" 540/2 " h" 60/2 " 0x200 backgroundtrans", "AHK-ChangeIcon")
MyGui["software"].SetFont("s18 cffffff", "Verdana")
; 版本
MyGui.AddText("vVersion x" 320/2 " y" 140/2 " w" 240/2 " h" 40/2 " 0x200 backgroundtrans", "Version 2.5.3 (x64)")
MyGui["Version"].SetFont("s10 cffffff", "Calibri")
; 作者
MyGui.AddText("vAuthor x" 320/2 " y" 180/2 " w" 240/2 " h" 40/2 " 0x200 backgroundtrans", "Author: iKineticate")
MyGui["Author"].SetFont("s10 cffffff", "Calibri")
; 跳转至网页
CreateButton( {name:"github", x:316/2, y:220/2, w:222/2, h:55/2} ).Text( {R:8/2, normal_color:"0x00ffffff", active_color:"0x1Affffff", text_options:"+0x200",text_margin:"2", font_options:"s11 c87eea3", font:"", text:TEXT.GITHUB} )
CreateButton( {name:"download", x:316/2, y:275/2, w:222/2, h:55/2} ).Text( {R:8/2, normal_color:"0x00ffffff", active_color:"0x1Affffff", text_options:"+0x200",text_margin:"2", font_options:"s11 c87eea3", font:"", text:TEXT.DOWNLOAD} )
CreateButton( {name:"help", x:316/2, y:330/2, w:222/2, h:55/2} ).Text( {R:8/2, normal_color:"0x00ffffff", active_color:"0x1Affffff", text_options:"+0x200",text_margin:"2", font_options:"s11 c87eea3", font:"", text:TEXT.ABOUT_HELP} )
CreateButton( {name:"issues", x:316/2, y:385/2, w:222/2, h:55/2} ).Text( {R:8/2, normal_color:"0x00ffffff", active_color:"0x1Affffff", text_options:"+0x200",text_margin:"2", font_options:"s11 c87eea3", font:"", text:TEXT.ISSUES} )
CreateButton( {name:"Contributors", x:316/2, y:440/2, w:222/2, h:55/2} ).Text( {R:8/2, normal_color:"0x00ffffff", active_color:"0x1Affffff", text_options:"+0x200",text_margin:"2", font_options:"s11 c87eea3", font:"", text:TEXT.CONTRIBUTORS} )
MyGui.ToolTips.SetTip(MyGui["github_BUTTON"], "https://github.com/iKineticate/AHK-ChangeIcon")
MyGui.ToolTips.SetTip(MyGui["download_BUTTON"], "https://github.com/iKineticate/AHK-ChangeIcon/releases")
MyGui.ToolTips.SetTip(MyGui["help_BUTTON"], "https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#已知问题") ; 根据中英文更换链接
MyGui.ToolTips.SetTip(MyGui["issues_BUTTON"], "https://github.com/iKineticate/AHK-ChangeIcon/issues")
MyGui.ToolTips.SetTip(MyGui["Contributors_BUTTON"], "https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#感谢")
; 灰色
MyGui.SetFont("s10 c666666", "Calibri")
MyGui.AddText("vcopy_right x" 320/2 " y" 510/2 " w" 600/2 " h" 30/2 " 0x200 backgroundtrans", "Licensed under the MIT License")
MyGui.AddText("vicon_from x" 320/2 " y" 545/2 " w" 600/2 " h" 30/2 " 0x200 backgroundtrans", "Icons from www.iconfont.cn and www.flaticon.com")
MyGui.AddText("vlogo_from x" 320/2 " y" 580/2 " w" 600/2 " h" 30/2 " 0x200 backgroundtrans", "Logo by iconfield from www.flaticon.com")



;==========================================================================
; 深色模式(Drak Mode) 
;==========================================================================
Tab.UseTab()
; （1）窗口标题栏（根据Windows版本赋予attr不同的值）
dwAttr:= VerCompare(A_OSVersion, "10.0.18985") >= 0 ? 20 : VerCompare(A_OSVersion, "10.0.17763") >= 0 ? 19 : ""
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "int", dwAttr, "int*", True, "int", 4)
; （2）呼出的菜单（1：根据系统显示模式调整深浅，2：深色，3：浅色）
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 135, "Ptr"), "int", 2)
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 136, "Ptr"))
; （3）列表标题栏及其滚动条
LV_header_hwnd := SendMessage(0x101F, 0, 0, LV.hWnd)     ;列表标题栏的hwnd
DllCall("uxtheme\SetWindowTheme", "Ptr", LV_header_hwnd, "Str", "DarkMode_ItemsView", "Ptr", 0)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
; （4）日志(Edit)的滚动条
DllCall("uxtheme\SetWindowTheme", "Ptr", MyGui["Log"].hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)

ahkGUI.GuiShow(ahkGUI.show_options) ; 展示GUI

OnMessage(0x200, WM_MOUSEMOVE)      ; 检测MyGui内的鼠标移动
;OnMessage(0x2A3, WM_MOUSELEAVE)     ; 监测MyGui外的鼠标移动

;==========================================================================
Return
;==========================================================================


;==========================================================================
; 处理鼠标移动的消息（使光标下控件转换为活跃态）
;==========================================================================
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd)
{
    If GuiCtrlFromHwnd(Hwnd)        ; 若鼠标下为窗口控件，则执行知道功能，否则隐藏所有控件的活动态图片
    {
        current_control := GuiCtrlFromHwnd(Hwnd) , thisGui := current_control.Gui   ; 获取控件hwnd和父窗口
  
        ; 若当前控件为活动控件或列表，则返回，否则活动控件设置为当前控件（避免鼠标在同一控件移动时发生闪烁）
        If current_control = thisGui.active_control
        or current_control = LV
        or current_control = MyGui["Log"]
        ; or thisGUI["其他控件"]
            Return
        
        (thisGui.active_control) ? WM_MOUSELEAVE() : ""     ; 等于If ...{...}，前面条件必须加括号

        If current_control = MyGui.Focus_Tab    ; 在取消其他活跃态后，在判读是否为焦点标签页
            Return

        thisGui.active_control := current_control

        If Instr(current_control.name, "_Tab_Button")   ; 若当前控件为标签页，则设置为活动状态
        {
            active_name      := StrReplace(current_control.name, "_Tab_Button", "_ACTIVE")
            indicator_name   := StrReplace(current_control.name, "_Tab_Button", "_INDICATOR")
            logo_symbol_name := StrReplace(current_control.name, "_Tab_Button", "_SYMBOL")
            thisGui[active_name].Visible  := True
            (tab_prop.HasOwnProp("label_indicator")) ? (thisGui[indicator_name].Visible := True) : False
            thisGui[current_control.name].SetFont("c" . tab_prop.label_prop.font_active_color)
            (tab_prop.HasOwnProp("logo_symbol")) ? thisGui[logo_symbol_name].SetFont("c" . tab_prop.label_prop.font_active_color) : False
        }
        Else    ; 若不为标签页，则无需特殊处理设置为活动状态
        {
            active_control_name := StrReplace(current_control.name, "_BUTTON", "_ACTIVE")
            thisGui[active_control_name].Visible := True
        }
    }
    Else
    {
        ; wparam=1 (鼠标左键被按下)
        ; WM_NCLBUTTONDOWN = 0x00A1 (模拟鼠标按下窗口的非客户区域) , WM_NCHITTEST消息中的HTCAPTION = 2 (在标题栏中)
        (wParam=1) ? PostMessage(0xA1, 2) : WM_MOUSELEAVE()
    }
}


;==========================================================================
; 处理离开MyGui窗口消息（取消绝大部分控件活跃态）
;==========================================================================
WM_MOUSELEAVE(*)
{
    ; 若活动按钮为空或不为按钮则返回(避免影响caption控件)，若活动按钮为焦点按钮
    If !MyGui.active_control
    or !Instr(MyGui.active_control.name, "_Button")
    or  MyGui.active_control = MyGui.Focus_Tab
        Return

    If Instr(MyGui.active_control.name, "_Tab_Button")      ; 隐藏上一次活跃控件的活跃态
    {
        active_name  := StrReplace(MyGui.active_control.name, "_Tab_Button", "_ACTIVE")
        indicator_name := StrReplace(MyGui.active_control.name, "_Tab_Button", "_INDICATOR")
        logo_symbol_name := StrReplace(MyGui.active_control.name, "_Tab_Button", "_SYMBOL")

        MyGui[active_name].Visible  := False
        (tab_prop.HasOwnProp("label_indicator")) ? (MyGui[indicator_name].Visible := False) : False
        MyGui[MyGui.active_control.name].SetFont("c" . tab_prop.label_prop.font_normal_color)
        (tab_prop.HasOwnProp("logo_symbol")) ? MyGui[logo_symbol_name].SetFont("c" . tab_prop.label_prop.font_normal_color) : False
    }
    Else
    {
        active_control_name := StrReplace(MyGui.active_control.name, "_Button", "_ACTIVE")
        MyGui[active_control_name].Visible := False
    }
    
    MyGui.active_control := False
}


;==========================================================================
; 各个按钮的功能分配
;==========================================================================
ButtonFunc(GuiCtrlObj, Info, *)
{
    If Instr(GuiCtrlObj.Name, "_Tab_Button")
        Return Tab_Click(GuiCtrlObj.Name)
    
    control_btn_name := RegExReplace(GuiCtrlObj.Name, "i)_BUTTON$")
    Switch control_btn_name
    {
    Case "Close" : ExitApp()
    Case "Minimize" : WinMinimize("A")
    Case "Change_All" : Change_All_Shortcut_Icons()
    Case "Restore_All" : Restore_All_Shortcut_Icons()
    Case "Add_Desktop" : Add_Desktop_To_LV()
    Case "Add_Start" : Add_Sart_To_LV()
    Case "Add_Other" : Add_Other_To_LV()
    Case "Add_UWP_WSA" : Add_UWP_APP_To_LV()
    Case "Add_BackUp" : Backup_LV_Link_To_Folder()
    Case "github" : Run("https://github.com/iKineticate/AHK-ChangeIcon")
    Case "download" : Run("https://github.com/iKineticate/AHK-ChangeIcon/releases")
    Case "help" : Run("https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#已知问题")
    Case "issues" : Run("https://github.com/iKineticate/AHK-ChangeIcon/issues")
    Case "Contributors" : Run("https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#感谢")
    }
}


;==========================================================================
; 标签被点击的函数（选择并聚焦该标签页、取消其他标签页活跃态）
;==========================================================================
Tab_Click(current_tab_name)
{
    If MyGui[current_tab_name] = MyGui.Focus_Tab
        Return

    Tab.Choose(StrReplace(current_tab_name, "_Tab_Button"))     ; 选择对应的隐藏标签页

    For name in [MyGui.Focus_Tab.name, current_tab_name]
    {
        active_name  := StrReplace(name, "_Tab_Button", "_ACTIVE")
        indicator_name := StrReplace(name, "_Tab_Button", "_INDICATOR")
        MyGui[active_name].Visible := (name=current_tab_name) ? True:False
        (tab_prop.HasOwnProp("label_indicator")) ? (MyGui[indicator_name].Visible := (name=current_tab_name) ? True:False) : False
    }
    ; 本次被点击标签页激活活跃态
    logo_symbol_name := StrReplace(MyGui[current_tab_name].name, "_Tab_Button", "_SYMBOL")
    MyGui[current_tab_name].SetFont("c" . tab_prop.label_prop.font_active_color)
    (tab_prop.HasOwnProp("logo_symbol")) ? MyGui[logo_symbol_name].SetFont("c" . tab_prop.label_prop.font_active_color) : False
    ; 上次被点击的标签页恢复常态
    logo_symbol_name := StrReplace(MyGui.Focus_Tab.name, "_Tab_Button", "_SYMBOL")
    MyGui.Focus_Tab.SetFont("c" . tab_prop.label_prop.font_normal_color)
    (tab_prop.HasOwnProp("logo_symbol")) ? MyGui[logo_symbol_name].SetFont("c" . tab_prop.label_prop.font_normal_color) : False
    ; 上次被点击标签页=本次
    MyGui.Focus_Tab := MyGui[current_tab_name]
}


;==========================================================================
; 调用WshShell对象（COM对象）获取、更改、创建快捷方式的属性
;==========================================================================
COM_Link_Attribute(&link_path, &link_attribute, &link_icon_location)
{
    link_attribute := ComObject("WScript.Shell").CreateShortcut(link_path)          ; 快捷方式的属性
    link_icon_location := RegExReplace(link_attribute.IconLocation, ",[^,]+$")      ; 快捷方式的图标路径(去除了图片编号)(存储的是值而不是变量)
}


;==========================================================================
; 将目标文件夹中的快捷方式添加进列表的事件
;==========================================================================
Add_Folder_Link_To_LV(link_folder_path, Mode)      ; Mode:="R"扫描子文件夹中的文件，默认只扫描目标文件夹中的文件
{
    Loop Files, link_folder_path "\*.lnk", Mode
    {
        If ((LV_link_from = "Start") AND (RegExMatch(A_LoopFileName, "i)uninstall|卸载")))      ; 若添加的是菜单，且快捷方式名为"卸载"，则下一轮循环（避免添加软件的卸载程序）
            Continue

        link_path := A_LoopFilePath
        COM_Link_Attribute(&link_path, &link_attribute, &link_icon_location)        ; 调用WshShell对象的函数，获取快捷方式属性
        link_target_path := link_attribute.TargetPath
        link_target_dir := (link_target_path AND !link_attribute.WorkingDirectory) ? RegExReplace(link_target_path, "\\[^\\]+$"):link_attribute.WorkingDirectory    ; 解决目标目录未填写的情况
        link_name := RegExReplace(A_LoopFileName, "i)\.lnk$")       ; 去除了后缀名的快捷方式的名称
        ; 快捷方式的目标扩展名
        SplitPath(link_target_path,,, &link_target_ext)     
        Switch
        {
        Case !link_target_ext :     ; 空则为UWP
            link_target_ext := "uwp"
        Case InStr(link_target_path, "WindowsSubsystemForAndroid") :    ; 安卓应用
            link_target_ext := "app"
        Case InStr(link_target_path, "schtasks") :  ; 命令任务(计划程序)的快捷方式
            link_target_ext := "schtasks"
        Default :
            link_target_ext := StrLower(link_target_ext)
        }

        key := link_name . link_target_ext

        ; 若本次循环快捷方式名称跟既往循环快捷方式名称相同(即数组存在)，且二者扩展名称相同，则跳过（有些同名称但目标扩展类型不同）
        If link_map.Has(key)
            Continue

        SplitPath(link_path,, &link_dir)                    ; 快捷方式的目录

        If !link_icon_location
        or link_icon_location = link_target_path
        or RegExMatch(link_icon_location, "i)%[^%]*%|WindowsSubsystemForAndroid|system32\\.*dll|\{[^\{]*\}\\[^\\]*\.exe$")  ; WSA或系统图标
        or InStr(link_target_dir, RegExReplace(link_icon_location, "\\([^\\]+)\.ico$"))     ; 某些应用EXE无内置图标，其图标来源于其父目录
        or (!link_icon_location and InStr(link_icon_location, link_target_dir))      ; 图标来源于其子目录中
        or !FileExist(link_icon_location)
        {
            is_changed := ""
        }
        Else
        {
            is_changed := "√"
            MyGui["Changed_Count"].Value += 1
        }
        
        ; 以"快捷方式名称+路径英文缩写"为键，其对应的路径为值，填入link_map数组
        ; LTP = Link Target Path = 快捷方式的目标路径（UWP无法查看）
        ; LTD = Link Target Dir  = 快捷方式的目标目录（UWP无法查看）
        ; LP  = Link Path        = 快捷方式的路径
        ; LD  = Link Dir         = 快捷方式的目录
        link_map[key] := {}
        link_map[key].LTP := (!link_target_path) ? Text.SAFE_UNAVAILABLE : link_target_path
        link_map[key].LTD := (!link_target_dir) ? Text.SAFE_UNAVAILABLE : link_target_dir
        link_map[key].LP  := A_LoopFilePath
        link_map[key].LD  := link_dir

        ; 调用DllCall_Get_Icon函数和图像列表替换函数，添加图标给数组，赋予给icon_number--刷新列表左侧图标
        hIcon := DllCall_Get_Icon(A_LoopFilePath)
        icon_number := DllCall("ImageList_ReplaceIcon", "Ptr", image_list_ID, "Int", -1, "Ptr", hIcon) + 1
        DllCall("DestroyIcon", "ptr", hIcon)
        LV.Add("Icon" . icon_number, link_name, is_changed, link_target_ext)         ; 列表添加图标、名称、"√"、目标扩展名
    }

    LV.ModifyCol(1, "+Sort")
    LV.ModifyCol(2, "+Center")
    LV.ModifyCol(3, "+Center +Sort")        ; 先第一列（名称）排列，后第三列（扩展名）排列，保证扩展名为主排列，名称为次排列
}


;==========================================================================
; DllCall获取图标的函数
;==========================================================================
DllCall_Get_Icon(link_target_path)
{
    fileinfo := Buffer(fisize := A_PtrSize + 688)
    If DllCall("Shell32\SHGetFileInfoW"
        , "Str", link_target_path
        , "Uint", 0
        , "Ptr", fileinfo
        , "UInt", fisize
        , "UInt", 0x100)
    Return hIcon := NumGet(fileinfo, 0, "Ptr")
}


;==========================================================================
; 刷新列表项目图标的函数
;==========================================================================
Refresh_LV_Icon(LV, Item)
{
    LV.Focus()
    key := LV.GetText(Item, 1) . LV.GetText(Item, 3)
    link_path := link_map[key].LP
    hIcon := DllCall_Get_Icon(link_path)
    icon_number := DllCall("ImageList_ReplaceIcon", "Ptr", image_list_ID, "Int", -1, "Ptr", hIcon) + 1   ; 调用DllCall_Icon函数重新刷新列表指定项目图标
    DllCall("DestroyIcon", "ptr", hIcon)
    LV.Modify(Item, "Icon" . icon_number)
}


;==========================================================================
; 刷新ICON显示的函数
;==========================================================================
Refresh_Display_Icon(LV, Item)
{
    LV.Focus()
    key := LV.GetText(Item, 1) . LV.GetText(Item, 3)
    link_path := link_map[key].LP
    link_target_path := link_map[key].LTP

    Try
    {
        hIcon := DllCall_Get_Icon(Link_Path)
        MyGui["Show_New_Icon"].Value := "HICON:" hIcon    ; 调用DllCall_Get_Icon函数重新刷新顶部显示图标区域的图片内容
        DllCall("DestroyIcon", "ptr", hIcon)
    }
    Catch
    {
        MyGui["Show_New_Icon"].Value := "*icon3 shell32.dll"    ; 从系统中调用图标   
    }

    Try     ; 无法获取某些应用(如UWP)目标的路径，或应用目标路径不存在时，采用Try
    {
        hIcon := DllCall_Get_Icon(link_target_path)
        MyGui["Show_Old_Icon"].Value := "HICON:" hIcon
        DllCall("DestroyIcon", "ptr", hIcon)
    }
    Catch
    {
        MyGui["Show_Old_Icon"].Value := "*icon3 shell32.dll"    ; 从系统中调用图标
    }
}

;==========================================================================
; 更换单个快捷方式的图标函数
;==========================================================================
Change_Link_Icon(LV, Item)
{
    MyGui.Opt("+OwnDialogs")        ; 解除对话框(如Msgbox等)后才可于GUI窗口交互

    link_name := LV.GetText(Item, 1)
    key := LV.GetText(Item, 1) . LV.GetText(Item, 3)
    link_path := link_map[key].LP
    link_target_path := link_map[key].LTP

    COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)        ; 调用WshShell对象的函数，获取快捷方式属性

    select_icon_path := FileSelect(3,, TEXT.SELECT_A_ICON, "Icon files(*.ico)")    ; 选择文件格式为“.ico”的图标并赋予图标路径给该变量
    If ((!select_icon_path) OR (select_icon_path = Link_Icon_Location))     ; 若未选择照片或更换图片是现在的图标则返回
        Return
    Link_Attribute.IconLocation := select_icon_path     ; 否则更换图片并保存
    Link_Attribute.Save()

    If !LV.GetText(Item, 2)     ; 更新显示的数据
    {
        MyGui["Changed_Count"].Value += 1
        MyGui["Unchanged_Count"].Value -= 1
    }

    Refresh_Display_Icon(LV, Item)      ; 刷新顶部图标
    Refresh_LV_Icon(LV, Item)           ; 刷新列表图标
    LV.Modify(Item,,,"√")               ; 目标行添加"√"
    ; 添加至日志
    MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")    
        . Text.LOG_CHANGED_LINK . link_name . "`n`s" 
        . Text.Source_OF_ICON . select_icon_path . "`n`n===========================================`n`n" 
}


;==========================================================================
; 列表右键菜单事件
;==========================================================================
LV_Context_Menu(LV, Item, IsRightClick, X, Y)
{
    If ((Item > 1000) OR (Item <= 0) OR !IsSet(Item))   ; 避免右键列表的标题栏时出现错误
        Return

    link_name := LV.GetText(Item, 1)                    ; 快捷方式的名称
    key := link_name . LV.GetText(Item, 3)
    link_target_path := link_map[key].LTP
    link_target_dir  := link_map[key].LTD
    link_path        := link_map[key].LP
    link_dir         := link_map[key].LD

    COM_Link_Attribute(&link_path, &Link_Attribute, &Link_Icon_Location)    ; 调用WshShell对象的函数，获取快捷方式属性

    link_menu := Menu()     ; 创建菜单并添加选项及功能
    link_menu.Add(Text.MENU_RUN, (*) => Run(link_path))
    link_menu.Add
    link_menu.Add(Text.MENU_CHANGE, (*) => Run(Change_Link_Icon(LV, Item)))
    link_menu.Add
    link_menu.Add(Text.MENU_RESTORE, Link_Restore)
    link_menu.Add
    link_menu.Add(Text.MENU_OPEN, (*) => Run(link_target_dir))
    link_menu.Add
    link_menu.Add(Text.MENU_RENAME, Link_Rename)

    If (LV_link_from != "Desktop")   ; 若当前列表中非桌面快捷方式，则菜单选项添加一行"添加至桌面"
    {
        link_menu.Add
        link_menu.Add(Text.MENU_ADD_LINK_TO_DESKTOP, Link_Add_Desktop)
        link_menu.SetIcon(Text.MENU_ADD_LINK_TO_DESKTOP, "HICON:" Base64PNG_to_HICON(MENU_DESKTOP_PNG_BASE64))
    }

    link_infor := Menu()
    link_infor.Add(Text.COPY_LINK_TARGET_PATH . link_target_path, (*) => (A_Clipboard := link_target_path))
    link_infor.Add
    link_infor.Add(Text.COPY_LINK_TARGET_DIR . link_target_dir, (*) => (A_Clipboard := link_target_dir))
    link_infor.Add
    link_infor.Add(Text.COPY_LINK_PATH . link_path, (*) => (A_Clipboard := link_path))
    link_infor.Add
    link_infor.Add(Text.COPU_LINK_DIR . link_dir, (*) => (A_Clipboard := link_dir))
    link_infor.Add
    link_infor.Add(Text.COPY_LINK_ICON_PATH . Link_Attribute.IconLocation, (*) => (A_Clipboard := Link_Attribute.IconLocation))
    link_menu.Add
    link_menu.Add(Text.MENU_PROPERTIES, link_infor)

    hIcon := DllCall_Get_Icon(link_path)    ; 调用DllCall函数显示该项目的图标
    link_menu.SetIcon(Text.MENU_RUN, "HICON:" hIcon)
    DllCall("DestroyIcon", "ptr", hIcon)    ; 释放hIcon
    link_menu.SetIcon(Text.MENU_CHANGE, "HICON:" Base64PNG_to_HICON(MENU_CHANGE_PNG_BASE64))            ; 菜单的改变图标的图标
    link_menu.SetIcon(Text.MENU_RESTORE, "HICON:" Base64PNG_to_HICON(MENU_DEFAULT_PNG_BASE64))          ; 菜单的恢复默认的图标
    link_menu.SetIcon(Text.MENU_OPEN, "HICON:" Base64PNG_to_HICON(MENU_FOLDER_PNG_BASE64))              ; 菜单的目标目录的图标
    link_menu.SetIcon(Text.MENU_RENAME, "HICON:" Base64PNG_to_HICON(MENU_RENAME_PNG_BASE64))            ; 菜单的重新命名的图标
    link_menu.SetIcon(Text.MENU_PROPERTIES, "HICON:" Base64PNG_to_HICON(MENU_PROPERTY_PNG_BASE64))      ; 菜单的快捷方式属性的图标
    
    If ((link_target_path = Text.SAFE_UNAVAILABLE))     ; 若选择与焦点行为UWP应用或APP应用，将"恢复默认图标"和"打开目标目录"的功能禁止
    {
        link_menu.Disable(Text.MENU_RESTORE)
        link_menu.Disable(Text.MENU_OPEN)
    }

    link_menu.Show()

    Link_Restore(*)     ; 恢复快捷方式的默认图标的函数
    {
        ; 若图标为默认图标则返回     ; 否则恢复为默认图标并保存
        If ((Link_Icon_Location = link_target_path) OR (!Link_Icon_Location))
            Return
        Link_Attribute.IconLocation := link_target_path
        Link_Attribute.Save()
        ; 更新显示的数据
        If (LV.GetText(Item, 2) = "√")
        {
            MyGui["Changed_Count"].Value -= 1
            MyGui["Unchanged_Count"].Value += 1
        }
        ; 刷新显示、列表图标，目标行删除"√"
        Refresh_Display_Icon(LV, Item)
        Refresh_LV_Icon(LV, Item)
        LV.Modify(Item,,,"")
        ; 添加至日志
        MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
            . Text.LOG_RESTORE_LINK . link_name . "`n`n===========================================`n`n" 
    }

    Link_Rename(*)      ; 重命名快捷方式名称的函数
    {
        MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
        ; 重命名输入窗口
        IB := InputBox(Text.RENAME_NEW_NAME, link_name, "W300 H100", Trim(link_name))
        If (IB.Result = "CANCEL")
            Return
        ; 排除重复名称
        IB.Value := RegExReplace(IB.Value, "i).lnk$")
        Loop LV.GetCount()
        {
            If IB.Value = LV.GetText(A_Index, 1)
                Return MsgBox(TEXT.SAME_NAME, "(・∀・(・∀・(・∀・*)", "icon!")
        }
        ; 赋予新名称给变量，然后重命名
        new_link_path := link_dir . "\" . IB.Value . ".lnk"
        FileMove(link_path, new_link_path)
        ; 重命名后，添加新的键值和删除旧的键值于映射数组
        new_key := IB.Value . LV.GetText(Item, 3)
        link_map[new_key] := {LP:new_link_path, LD:link_dir, LTP:link_target_path, LTD:link_target_dir}
        link_map.Delete(key)
        ; 记录日志
        MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
            . Text.LOG_OLD_NAME . link_name . "`n`s" 
            . Text.LOG_NEW_NAME . IB.Value . "`n`n===========================================`n`n" 
        ; 更新列表快捷方式名称（最后更新可避免过早更新使映射数组中的link_name发生改变而不能删除对应键值）
        LV.Modify(Item,, IB.Value)
    }

    Link_Add_Desktop(*)     ; 添加当前快捷方式至桌面的函数
    {
        Try
        {
            FileCopy(link_path, A_Desktop)

            MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")    ; 添加至日志
            . "“`s" . link_name . "`s”被添加至当前用户的桌面" . "`n`n===========================================`n`n" 

            Msgbox("成功添加“`s" . link_name . "`s”至当前用户的桌面", "Ciallo～(∠・ω< )⌒★")
        }
        Catch Error
        {
            Msgbox(Text.ERROE_ADD_LINK_TO_DESKTOP,, "Icon!")
            Return
        }
    }
}


;==========================================================================
; 搜索栏为焦点/非焦点事件的函数（显示/隐藏下划线，显示/隐藏“搜索......”）
;==========================================================================
Search_Bar_Focus(*)
{
    MyGui["Search_Edit"].Value := (MyGui["Search_Edit"].Value = Text.PLEASE_INPUT_NAME) ? "" : MyGui["Search_Edit"].Value
    MyGui["Search_Edit"].Focus()    ; 焦点搜索栏时，再次让它焦点即可实现全选搜索栏中的内容
}
Search_Bar_LoseFocus(*)
{
    MyGui["Search_Edit"].Value := (!MyGui["Search_Edit"].Value) ? Text.PLEASE_INPUT_NAME : MyGui["Search_Edit"].Value
}


;==========================================================================
; 在列表中搜索含有关键词的项目的函数
;==========================================================================
Search(*)
{
    ; 若搜索框未输入文本，则提示“请输入”并返回
    If (MyGui["Search_Edit"].Value = "" OR MyGui["Search_Edit"].Value = Text.PLEASE_INPUT_NAME)
        Return  (ToolTip(Text.PLEASE_INPUT, 560, 140) AND SetTimer((*) => ToolTip(), -2000))
    ; 搜索框为焦点，暂时允许列表多行选择, 取消聚焦列表行
    MyGui["Search_Edit"].Focus()                        
    LV.Opt("+Multi"), LV.Modify(0, "-Select -Focus")
    ; 从列表中搜索目标，并刷新显示图标，选择、聚焦目标行
    Loop LV.GetCount()
    {
        If (!InStr(LV.GetText(A_Index), Trim(MyGui["Search_Edit"].Value)))
            Continue
        Sleep(300)
        LV.Modify(A_Index, "+Select +Focus +Vis")
        Refresh_Display_Icon(LV, A_Index)
    }
    ; 禁止列表多行选择（不影响之前的多行选择）
    LV.Opt("-Multi")
    ; 若未搜寻到目标，则提示“未找到”并返回（利用未寻到目标时焦点在搜索框的机制）
    If (ControlGetFocus("A") = MyGui["Search_Edit"].hWnd)
        Return  (ToolTip(Text.NOT_FOUND, 560, 140) AND SetTimer((*) => ToolTip(), -2000))
}


;==========================================================================
; 更换所有快捷方式图标的函数
;==========================================================================
Change_All_Shortcut_Icons(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
    ; 访问ini，打开上一次打开的存放ICO的文件夹，并更新ini里的上一次打开的图标文件夹路径
    last_selected_folder_path := iniRead(info_ini_path, "info", "last_icons_folder_path")       
    If not (selected_folder_path := DirSelect("*" . last_selected_folder_path, 0, Text.SELECT_ICONS_FOLDER))
        Return
    iniWrite(selected_folder_path, info_ini_path, "info", "last_icons_folder_path")
    ; 创建数组
    changed_log_msgbox := ""
    map_iconName_iconPath := map()
    map_both_name_same := map()
    ; 以被选择文件夹的图标名称为键，图标路径为值添加至映射数组(R：扫描包括子文件夹的文件)
    Loop Files, selected_folder_path "\*.ico", "R"
    {
        map_iconName_iconPath[RegExReplace(A_LoopFileName, "i)\.ico$")] := A_LoopFilePath
    }
    ; 若选择文件夹无图标则提醒并返回
    If !map_iconName_iconPath.Count
        Return (Msgbox("There is no icon in the folder", "(っ °Д °;)っ"))
    ; 提醒正在扫描、更换图标，在完成扫描、更换操作前禁止与GUI交互
    TrayTip(Text.CHANGING)
    MyGui.Opt("+Disabled")
    ; 从图标组合中枚举，并从列表开头开始循环
    For icon_name, icon_path in map_iconName_iconPath
    {
        no_space_icon_name := RegExReplace(icon_name, "[`s`n`t]")
        Loop LV.GetCount()
        {
            link_name := LV.GetText(A_Index, 1)
            key := link_name . LV.GetText(A_Index, 3)
            no_space_link_name := RegExReplace(link_name, "[`s`n`t]")

            ; 若快捷方式已更换过与快捷方式相同名称的ICO图标，则跳过这一次循环（比如QQ音乐软件换了"QQ音乐"图标后，可能会更换"QQ"图标，因此需要截停）
            ; 注意：不能根据列表"√"来跳过循环（比如QQ音乐先换了"QQ"图标，要是跳过就不能换"QQ音乐"图标）
            ; 注意：若要跳过这一次循环，用Continue，Return会退出所有循环和函数
            If  (map_both_name_same.has(key) OR (map_both_name_same.has(key)))
                Continue
            ; 根据快捷方式和图标名称长度来检查二者的包含关系，包含则更换，不包含执行下一次循环
            ; 优势：部分应用因版本不同而快捷方式名称不同，如Adobe PhtotShop 2024/2023/2022，使用该方法可以使图标名称只要是"PhtotShop即可匹配更换
            ; 缺点：部分应用名称重叠，导致如QQ音乐换了"QQ"图标
            Switch VerCompare(StrLen(no_space_link_name), StrLen(no_space_icon_name))
            {
            Case -1:
                If !InStr(no_space_icon_name, no_space_link_name)
                    Continue 
            Case 1:
                If !InStr(no_space_link_name, no_space_icon_name)
                    Continue 
            Case 0:
                If (no_space_link_name != no_space_icon_name)           ; 若快捷方式名称与文件名称不同，则下一循环，相同给数组添加两个键
                    Continue 
                map_both_name_same[key] := "SAME"       ; 此处标记，后续扫描跳过第二个循环中的该快捷方式（注意：数组的键是区分大小写的）
                map_both_name_same[key] := "SAME"       ; 此处标记，后续扫描跳过第一个循环中的该图标（注意数组的键是区分大小写的）
            }
            ; 获取快捷方式信息
            link_path := link_map[key].LP
            COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
            ; 若快捷方式图标的路径与文件图标的路径相同，则跳过这一次循环
            If (Link_Icon_Location = icon_path)
                Continue
            ; 更换图标并保存该操作
            Link_Attribute.IconLocation := icon_path    
            Link_Attribute.Save()
            ; 更新显示的数据
            If (LV.GetText(A_Index, 2) = "")
            {
                MyGui["Changed_Count"].Value += 1
                MyGui["Unchanged_Count"].Value -= 1
            }
            ; 刷新显示和列表图标，选择、聚焦目标行并添加"√"
            Refresh_Display_Icon(LV, A_Index) 
            Refresh_LV_Icon(LV, A_Index)
            LV.Modify(A_Index, "+Select +Focus +Vis",,"√")
            ; 记录被更换图标的软件，完成操作后显示
            changed_log_msgbox .= link_name . "`s=>`s" . icon_name . ".ico`n"   
            ; 添加至日志
            MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s") 
                . Text.LOG_CHANGED_LINK . LV.GetText(A_Index, 1) . "`n`s"
                . Text.SOURCE_OF_ICON . icon_name . ".ico`n`n"
        }
    }
    MyGui["Log"].Value .= "======================================`n`n"
    ; 恢复与窗口的交互
    MyGui.Opt("-Disabled")
    ; 若未记录到更换信息，则显示“未更换任何图标”
    If !changed_log_msgbox
        Return (Msgbox(Text.NO_CHANGE, "╰(￣ω￣ｏ)") and TrayTip)
    Msgbox(changed_log_msgbox, Text.SUCCESS)
    ; 更新托盘提醒
    TrayTip
    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★", "Mute"), SetTimer(TrayTip, -2500)
}


;==========================================================================
; 恢复所有快捷方式的默认图标事件（UWP、APP不支持恢复默认）
;==========================================================================
Restore_All_Shortcut_Icons(*)
{
    MyGui.Opt("+OwnDialogs")        ; 解除对话框后才可于GUI窗口交互
    ; 提醒UWP、APP不支持恢复默认
    If Msgbox(Text.IS_RESTORE_ALL_ICON, "Ciallo～(∠・ω< )⌒★", "OKCancel Icon? Default2") = "Cancel"
        Return
    ; 循环恢复
    Loop LV.GetCount()
    {
        If ((LV.GetText(A_Index, 2) != "√") OR (LV.GetText(A_Index, 3) = "uwp"))
            Continue

        link_name := LV.GetText(A_Index, 1)
        key := link_name . LV.GetText(A_Index, 3)
        link_path := link_map[key].LP
        link_target_path := link_map[key].LTP
        ; 获取快捷方式的属性，并恢复默认图标（即更换为目标文件图标）
        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)    
        Link_Attribute.IconLocation := link_target_path
        Link_Attribute.Save()
        ; 更新显示的数据
        If (LV.GetText(A_Index, 2) = "√")                                       
        {
            MyGui["Changed_Count"].Value -= 1
            MyGui["Unchanged_Count"].Value += 1
        }
        ; 刷新显示和列表图标，选择、聚焦目标行并删除"√"
        Refresh_Display_Icon(LV, A_Index)
        Refresh_LV_Icon(LV, A_Index)
        LV.Modify(A_Index, "+Select +Focus +Vis",,"")
        ; 添加至日志
        MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
        . Text.LOG_RESTORE_LINK . LV.GetText(A_Index, 1) . "`n`n"
    }
    MyGui["Log"].Value .= "======================================`n`n"
    ; 提醒
    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)
}


;==========================================================================
; 清空列表中的快捷方式的函数
;==========================================================================
Clean_LV(*)
{
    LV.Delete()             ; 清空列表
    link_map.Clear()        ; 清空数组
    MyGui["Changed_Count"].Value := 0
    MyGui["Unchanged_Count"].Value := 0
    MyGui["Total_Count"].Value := 0
}


;==========================================================================
; 重新添加桌面快捷方式至列表的函数
;==========================================================================
Add_Desktop_To_LV(*)
{
    MyGui.Opt("+OwnDialogs")                                                ; 解除对话框后才可于GUI窗口交互
    ; 确认操作
    If Msgbox(Text.IS_ADD_DESKTOP_TO_LV, "Ciallo～(∠・ω< )⌒★", "Icon? OKCancel") = "Cancel"
        Return
    ; 清空列表、计数、数组
    Clean_LV()
    ; 更新列表的快捷方式来源的变量为桌面
    global LV_link_from := "Desktop"
    ; 添加桌面快捷方式
    For Desktop in [A_Desktop, A_DesktopCommon]
    {
        Add_Folder_Link_To_LV(Desktop, Mode := "")
    }
    ; 刷新计数
    MyGui["Total_Count"].Value := LV.GetCount()
    MyGui["Unchanged_Count"].Value := LV.GetCount() - MyGui["Changed_Count"].Value
    ; 添加至日志
    MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
    . Text.ADD_DESKTOP_TO_LV . "`n`n===========================================`n`n" 
    ; 返回主页
    ControlClick(MyGui[StrReplace(tab_prop.label_name[1], "`s") . "_Tab_BUTTON"])
}


;==========================================================================
; 添加开始(菜单)中的快捷方式至列表的函数
;==========================================================================
Add_Sart_To_LV(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
    ; 确认是否添加
    If Msgbox(Text.IS_ADD_START_TO_LV, "Ciallo～(∠・ω< )⌒★", "Icon? OKCancel") = "Cancel"
        Return
    ; 清空列表、计数、数组
    Clean_LV()
    ; 更新列表的快捷方式来源的变量为开始菜单
    global LV_link_from := "Start"
    ; 将当前用户、所有用户的开始(菜单)中的快捷方式添加至列表中
    For Value in [A_StartMenu, A_StartMenuCommon]
    {
        Add_Folder_Link_To_LV(Value, Mode := "R")
    }
    ; 刷新计数
    MyGui["Total_Count"].Value := LV.GetCount()
    MyGui["Unchanged_Count"].Value := LV.GetCount() - MyGui["Changed_Count"].Value
    ; 添加至日志
    MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
    . Text.ADD_START_TO_LV . "`n`n===========================================`n`n" 
    ; 返回主页
    ControlClick(MyGui[StrReplace(tab_prop.label_name[1], "`s") . "_Tab_BUTTON"])
    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)
}


;==========================================================================
; 添加其他文件夹的快捷方式至列表中
;==========================================================================
Add_Other_To_LV(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
    ; 确认是否添加
    If Msgbox(Text.IS_ADD_OTHER, "Ciallo～(∠・ω< )⌒★", "Icon? OKCancel") = "Cancel"
        Return
    ; 访问ini
    last_selected_other_path := iniRead(info_ini_path, "info", "last_selected_other_path")
    ; 选择目录
    If not (selected_other_path := DirSelect("*" . last_selected_other_path, 0, Text.SELECT_ICONS_FOLDER))
        Return
    ; 检查文件夹名称的最后一个字符是否为反斜杠（避免文件名包含"\"，导致最终变成C:**\**\\这种错误格式）
    (SubStr(selected_other_path, -1, 1) = "\") ? (selected_other_path := SubStr(selected_other_path, 1, -1)) : False
    ; 写入ini
    iniWrite(selected_other_path, info_ini_path, "info", "last_selected_other_path")
    ; 清空列表、计数、数组
    Clean_LV()      
    ; 更新列表的快捷方式来源的变量为其他文件夹
    global LV_link_from := RegExReplace(selected_other_path, "^.*\\")
    ; 将文件夹及其子文件夹的快捷方式添加至列表中
    Add_Folder_Link_To_LV(selected_other_path, Mode := "R")
    ; 刷新计数
    MyGui["Total_Count"].Value := LV.GetCount()
    MyGui["Unchanged_Count"].Value := LV.GetCount() - MyGui["Changed_Count"].Value
    ; 添加至日志
    MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
    . Text.ADD_OTHER_TO_LV . "`n`n===========================================`n`n" 
    ; 返回主页
    ControlClick(MyGui[StrReplace(tab_prop.label_name[1], "`s") . "_Tab_BUTTON"])
    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)           
}


;==========================================================================
; 添加UWP、APP的快捷方式至桌面中的函数
;==========================================================================
Add_UWP_APP_To_LV(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
    ; 确认操作
    If Msgbox(Text.IS_ADD_UWP_APP_TO_LV, "Ciallo～(∠・ω< )⌒★","Icon? OKCancel") = "Cancel"
        Return
    ; 打开存放快捷方式的文件夹
    Run("shell:AppsFolder")
}


;==========================================================================
; 备份列表中的快捷方式的函数
;==========================================================================
Backup_LV_Link_To_Folder(*)
{
    MyGui.Opt("+OwnDialogs")    ; 解除对话框后才可于GUI窗口交互
    ; 确认操作
    If Msgbox(Text.IS_BACKUP_TO_FOLDER . LV_link_from . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm") . "`"", "Ciallo～(∠・ω< )⌒★","Icon? OKCancel") = "Cancel"
        Return
    ; 备份路径
    backup_folder_path := A_DesktopCommon . "\" . LV_link_from . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm")
    ; 存在重复文件夹，则创建新的文件夹
    backup_folder_path .= DirExist(backup_folder_path) ? "_repeat" : ""
    ; 创建备份文件夹
    DirCreate(backup_folder_path)
    ; 循环复制粘贴快捷方式至备份文件夹
    Loop LV.GetCount()                                                          
    {
        link_name := LV.GetText(A_Index, 1)
        key := LV.GetText(A_Index, 1) . LV.GetText(A_Index, 3)
        link_path := link_map[key].LP
        FileCopy(Link_Path, backup_folder_path, 1)
    }
    ; 添加至日志
    MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
    . Text.HAVE_BACKUP . StrReplace(backup_folder_path, A_DesktopCommon . "\") . "`n`n===========================================`n`n" 
    ; 提醒已完成
    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)
}


ExitFunc(ExitReason, ExitCode)
{
    global  ; gdi+ may now be shutdown on exiting the program
    Gdip_Shutdown(pToken)
}