;// @Name                   AHK-ChangeIcon
;// @Author                 iKineticate
;// @Version                v2.8.0
;// @Destription:zh-CN      只需一步操作，用户即可随心批量更换/恢复快捷方式图标
;// @Destription:en         With just one step, users can change or restore the icons of shortcuts in batches as they wish
;// @HomepageURL            https://github.com/iKineticate/AHK-ChangeIcon
;// @Icon Source            https://www.iconfont.cn && https://www.flaticon.com
;// @Date                   2024/04/04
;// @Note                   Copyright © 2023 iKineticate

;@Ahk2Exe-SetVersion 2.8.0
;@Ahk2Exe-SetFileVersion 2.8.0
;@Ahk2Exe-SetProductVersion 2.8.0
;@Ahk2Exe-SetName AHK-ChangeIcon
;@Ahk2Exe-ExeName AHK-ChangeIcon
;@Ahk2Exe-SetCompanyName AHK-ChangeIcon
;@Ahk2Exe-SetProductName AHK-ChangeIcon
;@Ahk2Exe-SetDescription AHK-ChangeIcon
;@Ahk2Exe-SetInternalName AHK-ChangeIcon
;@Ahk2Exe-SetLegalTrademarks AHK-ChangeIcon
;@Ahk2Exe-SetOrigFilename AHK-ChangeIcon.exe
;@Ahk2Exe-SetCopyright Copyright © 2023 iKineticate

#Requires AutoHotkey v2.0
#Include AHK_Base64PNG.ahk
#Include AHK_Language.ahk
#Include AHK_iconGUI.ahk
#Include <Class_Button>
#Include <Class_ModernGUI>
#Include <Class_FontSymbol>
#Include <Class_ConvertToIconFile>
#Include <Class_LV_Colors>        ; https://github.com/AHK-just-me/AHK2_LV_Colors
#Include <Class_GuiCtrlTips>      ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116218
#Include <Class_ListIcons>        ; https://github.com/TheArkive/ListIcons_ahk2
#Include <Gdip_All>               ; https://github.com/buliasz/AHKv2-Gdip
#SingleInstance Ignore

SetControlDelay(-1)
SetWinDelay(-1)

;==========================================================================
; 以管理员身份运行AHK
;==========================================================================
FullCommandLine := DllCall("GetCommandLine", "str")
If not (A_IsAdmin OR RegExMatch(FullCommandLine, " /restart(?!\S)")) {
    Try {
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
If !pToken := Gdip_Startup() {
    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
    ExitApp
}
OnExit ExitFunc


;========================================================================================================
; 创建初始化配置文件
;========================================================================================================
; 配置路径
global iniPath := A_AppData "\AHK-ChangeIcon\info.ini"

; 若不存在则创建配置文件的目录
If !DirExist(A_AppData "\AHK-ChangeIcon")
    DirCreate(A_AppData "\AHK-ChangeIcon")

; 若不存在配置文件，则创建文件并写入段名、键名
If !FileExist(iniPath)
    FileAppend("[info]`nlastSelectedLinkFolderPath=`nlastSelectedIconFolderPath=", iniPath)

; 若配置文件不存在任意一个键，则在同一段中创建该键（兼容旧版）
For Value in ["lastSelectedLinkFolderPath", "lastSelectedIconFolderPath"] {
    If IniRead(iniPath, "info", Value, "0")
        Continue
    IniWrite('', iniPath, "info", Value)
}


;========================================================================================================
; 创建窗口，并载入库
;========================================================================================================
mainGUI := GUI()
; 创建现代风格窗口
mainGUI.Morden := ModernGUI( {GUI:mainGUI, x:"center", y:"center", w:1200/2, h:650/2, backColor:"202020", GuiOpt:"-caption -Resize -MaximizeBox +DPIScale", GuiNmae:"AHK-ChangeIcon", GuiFontOpt:"Bold cffffff s8", GuiFont:"Microsoft YaHei UI", showOpt:""} )
; 创建控制窗口按钮
mainGUI.Morden.WindowCrontrolButtons( {marginTop:"0", marginRight:"0", buttonW:54/2, buttonH:40/2, activeColor:"AD62FD"} )
; 创建窗口控件按钮
mainGUI.Button := CreateButton(mainGUI)
; 创建窗口控件提示
mainGUI.Tooltips := GuiCtrlTips(mainGUI)
mainGUI.ToolTips.SetFont(,"Microsoft YaHei UI",,)
mainGUI.ToolTips.SetBkColor("0xff303030")
mainGUI.ToolTips.SetTxColor("0xff999999")
mainGUI.ToolTips.SetMargins(L := 10, T := 5, R := 10, B := 5)
; 创建系统字体符号
mainGUI.SegoeUISymbol := FontSymbol(mainGUI, 'Segoe UI Symbol')


;========================================================================================================
; 创建标签页
;======================================================================================================== 
; 创建左侧背景
mainGUI.AddPicture("x0 y0 w" 240/2 " h" 650/2 " background252525")
; 创建软件LOGO
mainGUI.AddPicture("x" 70/2 " y" 42/2 " w" 100/2 " h" 100/2 " BackgroundTrans", "HICON:" Base64PNGToHICON(Base64.PNG.LOGO, height := 512))
; 设置标签页的各项参数
tabProp             := {x:10/2, y:180/2, w:220/2, h:85/2}
tabProp.labelName   := [Text.HOME, Text.Other, Text.LOG, Text.HELP, Text.ABOUT]    ; 输入空格来调整标签文本相对标签x轴位置
tabProp.labelProp   := {distance:0, textOpt:"center +0x200", fontOpt:"Bold cf5f5f5 s11", font:"", fontNormalColor:"f5f5f5", fontActiveColor:"ad62fd"}
tabProp.labelActive := {marginLeft:0, marginTop:"center", w:220/2, h:72/2, R:22/2, color:"0xfff5f5f5"}
tabProp.logoSymbol  := {marginLeft:2, fontName:'Segoe UI Symbol'}
tabProp.logoSize    := [22/2, 20/2, 24/2, 24/2, 32/2]
tabProp.logoUnicode := ["0xE10F", "0xE292", "0x1F4DC", "0xE115", "0x24D8"]
mainGUI.Button.NewTab( tabProp )


;========================================================================================================
; 第一个标签页：主页(Home)
;========================================================================================================  
Tab.UseTab(1)
; 左侧背景
mainGUI.AddPicture("x" 240/2 " y0" " w" 200/2 " h" 650/2 " background303030")

; 上方的圆角边框
mainGUI.AddPicture("vtopGroupBox x" 250/2 " y" 59/2 " w" 180/2*(A_ScreenDPI/96) " h" 304/2*(A_ScreenDPI/96) " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(mainGUI["topGroupBox"], "0xff999999", 15, isFill:="1")
; 上方快捷方式的旧图标
mainGUI.AddPicture("vdisplayOldIcon x" 295/2 " y" 83/2 " w" 90/2 " h" 90/2 " BackgroundTrans")
; 转换符号
mainGUI.SegoeUISymbol.Font( {name:'Replace_Symbol', unicode:0xE1FD, x:250/2, y:59/2, w:180/2, h:304/2, textColor:'999999', fontOpt:'s' 56/4, textOpt:'+0x200 center'} )
; 下方快捷方式的新图标
mainGUI.AddPicture("vdisplayNewIcon x" 295/2 " y" 248/2 " w" 90/2 " h" 90/2 " BackgroundTrans")

; 下方的框
mainGUI.AddPicture("vbottomGroupBox x" 250/2 " y" 395/2 " w" 180/2*(A_ScreenDPI/96) " h" 196/2*(A_ScreenDPI/96) " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(mainGUI["bottomGroupBox"], "0xff999999", 15, isFill:="1")
; 下方已更换、未更换、总共符号
mainGUI.SegoeUISymbol.Font( {name:'changedSymbol' , unicode:0x25CB, x:250/2, y:416/2, w:55/2, h:38/2, textColor:'999999', fontOpt:'s' 32/2, textOpt:'+0x200 center'} )
mainGUI.SegoeUISymbol.Font( {name:'yesSymbol'     , unicode:0x2714, x:250/2, y:420/2, w:55/2, h:36/2, textColor:'999999', fontOpt:'s' 32/4, textOpt:'+0x200 center'} )
mainGUI.SegoeUISymbol.Font( {name:'uchangedSymbol', unicode:0x25CE, x:250/2, y:472/2, w:55/2, h:38/2, textColor:'999999', fontOpt:'s' 32/2, textOpt:'+0x200 center'} )
mainGUI.SegoeUISymbol.Font( {name:'totalSymbol'   , unicode:0x25C9, x:250/2, y:528/2, w:55/2, h:38/2, textColor:'999999', fontOpt:'s' 32/2, textOpt:'+0x200 center'} )
; 已更换、未更换、总共文本
mainGUI.AddText("x" 305/2 " y" 420/2 " w" 75/2 " h" 36/2 " BackgroundTrans +0x200", Text.CHANGED_ICON)
mainGUI.AddText("x" 305/2 " y" 476/2 " w" 75/2 " h" 36/2 " BackgroundTrans +0x200", Text.UNCHANGED_ICON)
mainGUI.AddText("x" 305/2 " y" 532/2 " w" 75/2 " h" 36/2 " BackgroundTrans +0x200", Text.LV_LINK_TOTAL)
; 已更换、未更换、总共数量
mainGUI.AddText("vcountOfChanged   x" 382/2 " y" 420/2 " w" 42/2 " h" 36/2 " BackgroundTrans +0x200", "0")
mainGUI.AddText("vcountOfUnchanged x" 382/2 " y" 476/2 " w" 42/2 " h" 36/2 " BackgroundTrans +0x200", "0")
mainGUI.AddText("vcountOfTotal     x" 382/2 " y" 532/2 " w" 42/2 " h" 36/2 " BackgroundTrans +0x200", "0")

; 搜索栏(搜索背景+搜索图标+Edit控件)
mainGUI.AddPicture("vsearchBarBackground x" 478/2 " y" 70/2 " w" 320/2 " h" 74/2 " BackgroundTrans", "HICON:" Base64PNGToHICON(Base64.PNG.SEARCH_BACK, height := 512))
mainGUI.SegoeUISymbol.Font( {name:'searchSymbol', unicode:0xE11A, x:478/2, y:70/2, w:70/2, h:74/2, textColor:'999999', fontOpt:'s' 55/4, textOpt:'+0x200 center'} )
; Edit控件，控件内不存在内容时显示指定内容  https://github.com/jNizM/AHK_Scripts/blob/master/src/gui/Gui_Complete_Example.ahk
mainGUI.AddEdit("vsearchEditCtrl x" 532/2 " y" 92/2 " Background2E2E2E -multi -wrap -E0X200") ; r1可以隐藏该控件的上下导航栏
SendMessage(EM_SETCUEBANNER := 0x1501, True, StrPtr(Text.PLEASE_INPUT_NAME), mainGUI["searchEditCtrl"].hwnd)
mainGUI["searchEditCtrl"].SetFont("c999999")
; 隐藏的按钮
mainGUI.AddButton("vhiddenSearchButton yp w26 h26 Default Hidden").OnEvent("Click", Search)

; 更换和恢复默认图标的PNG图片按钮
mainGUI.Button.PNG( {name:"restoreAllLinks", x:815/2 , y:68/2, w:175/2, h:79/2, normal:Base64.PNG.RESTORE_ALL_NORMAL, active:Base64.PNG.RESTORE_ALL_ACTIVE, pngQuality:"300"} )
mainGUI.Button.PNG( {name:"changedAllLinks", x:1006/2, y:68/2, w:175/2, h:79/2, normal:Base64.PNG.CHANGE_ALL_NORMAL , active:Base64.PNG.CHANGE_ALL_ACTIVE , pngQuality:"300"} )
mainGUI.Button.OnEvent('restoreAllLinks', 'Click', (*) => RestoreAllLinksIconsToDefault())
mainGUI.Button.OnEvent('changedAllLinks', 'Click', (*) => ChangeAllLinksIcons())
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['restoreAllLinks'], TEXT.TIP_RESTORE)
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['changedAllLinks'] , TEXT.TIP_CHANGE)

global folderListFrom := 'Desktop'   ; 列表快捷方式的来源
global MapLinkProp := map()          ; 快捷方式的映射数组
global IL_ID := IL_Create()          ; 创建列表的图标列表
; 创建列表(+LV0x10000: 双缓冲，redraw: 加载数据后在redraw， -Multi: 禁止多选)
LV := mainGUI.AddListView("vLV x" 440/2 " y" 180/2 " w" 760/2 " h" 470/2 " Background232323 -redraw -Multi -E0x200 +LV0x10000", ["Name", "Y/N", "Type"])
LV.SetFont("cf5f5f5 s14")
LV.OnEvent("ItemFocus", RefreshIconDisplay)
LV.OnEvent("DoubleClick", ChangeLinkIcon)
LV.OnEvent("ContextMenu", ShowListContextMenu)
LV.SetImageList(IL_ID)
; 添加桌面快捷方式至列表
For Desktop in [A_Desktop, A_DesktopCommon] {
    AddLinksFromFolderToLV(Desktop, Mode := "")
}
; 设置列表颜色
mainGUI.SetLV := LV_Colors(LV, 0, 0, 0)
mainGUI.SetLV.Critical := 100
Loop LV.GetCount() {
    If (Mod(A_Index, 2) = 0)
        Continue
    mainGUI.SetLV.Row(A_Index, 0x292929)
}
mainGUI.SetLV.ShowColors()
; 设置、调整列表
LV.ModifyCol(1, 460/2)
LV.ModifyCol(2, "+AutoHdr")
LV.ModifyCol(3, "+AutoHdr")
LV.Opt("+Redraw")
; 更新计数
mainGUI["countOfTotal"].Value     := LV.GetCount()
mainGUI["countOfUnchanged"].Value := LV.GetCount() - mainGUI["countOfChanged"].Value


;========================================================================================================
; 第二个标签页：其他(Other)
;========================================================================================================
Tab.UseTab(2)
mainGUI.Button.Text( {name:'addDesktopLinksToLV', x:278/2, y:75/2, w:790/2, h:90/2, R:20/2, normalColor:'0x26ffffff', activeColor:'909090', text: Text.ADD_DESKTOP_TO_LV, textOpt:'+0x200', textHorizontalMargin:10, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('addDesktopLinksToLV', 'Click', (*) => AddShortcutToList('Desktop'))
mainGUI.SegoeUISymbol.Font( {name:'addDesktopLinksToLV_Symbol', unicode:0xE2CB, x:286/2, y:73/2, w:90/2, h:90/2, textColor:'ffffff', fontOpt:'s' 90/4, textOpt:'+0x200 center'} )

mainGUI.Button.Text( {name:'addStartLinksToLV', x:278/2, y:185/2, w:790/2, h:90/2, R:20/2, normalColor:'0x26ffffff', activeColor:'909090', text: Text.ADD_START_TO_LV, textOpt:'+0x200', textHorizontalMargin:10, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('addStartLinksToLV', 'Click', (*) => AddShortcutToList('Start'))
mainGUI.SegoeUISymbol.Font( {name:'addStartLinksToLV_Symbol', unicode:0xE154, x:286/2, y:186/2, w:90/2, h:90/2, textColor:'ffffff', fontOpt:'s' 90/4, textOpt:'+0x200 center'} )

mainGUI.Button.Text( {name:'addOtherLinksToLV', x:278/2, y:295/2, w:790/2, h:90/2, R:20/2, normalColor:'0x26ffffff', activeColor:'909090', text: Text.ADD_OTHER_TO_LV, textOpt:'+0x200', textHorizontalMargin:10, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('addOtherLinksToLV', 'Click', (*) => AddShortcutToList('Other'))
mainGUI.SegoeUISymbol.Font( {name:'addOtherLinksToLV_Symbol', unicode:0xE1C1, x:286/2, y:299/2, w:90/2, h:90/2, textColor:'ffffff', fontOpt:'s' 90/5, textOpt:'+0x200 center'} )

mainGUI.Button.Text( {name:'openAppsFolder', x:278/2, y:405/2, w:790/2, h:90/2, R:20/2, normalColor:'0x26ffffff', activeColor:'909090', text: Text.ADD_UWP_WSA_TO_LV, textOpt:'+0x200', textHorizontalMargin:10, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('openAppsFolder', 'Click', (*) => AddUwpAppToDesktop())
mainGUI.SegoeUISymbol.Font( {name:'openAppsFolder_Symbol', unicode:0xE2F8, x:286/2, y:404/2, w:90/2, h:90/2, textColor:'ffffff', fontOpt:'s' 90/3.5, textOpt:'+0x200 center'} )

mainGUI.Button.Text( {name:'backupLinksToDesktop', x:278/2, y:515/2, w:790/2, h:90/2, R:20/2, normalColor:'0x26ffffff', activeColor:'909090', text: Text.BACKUP_LV_LINK, textOpt:'+0x200', textHorizontalMargin:10, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('backupLinksToDesktop', 'Click', (*) => BackupLinksToFolder())
mainGUI.SegoeUISymbol.Font( {name:'backupLinksToDesktop_Symbol', unicode:0xE17C, x:286/2, y:516/2, w:90/2, h:90/2, textColor:'ffffff', fontOpt:'s' 90/5, textOpt:'+0x200 center'} )


mainGUI.Button.Text( {name:'showIconGUI', x:1088/2, y:75/2, w:75/2, h:530/2, R:16/2, normalColor:'0x26ffffff', activeColor:'9657DB', text:'', textOpt:'+0x200 center', textHorizontalMargin:0, fontOpt:'cffffff s13', font:''} )
mainGUI.Button.OnEvent('showIconGUI', 'Click', (*) => ToggleIconGUIVisibility())
mainGUI.SegoeUISymbol.Font( {name:'showIconGUI_Symbol', unicode:0xE291, x:1090/2, y:75/2, w:75/2, h:530/2, textColor:'ffffff', fontOpt:'s' 90/5, textOpt:'+0x200 center'} )
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['showIconGUI'], TEXT.SYSTEM_ICONS)


;========================================================================================================
; 第三个标签页：日志(Log) 
;========================================================================================================
Tab.UseTab(3)
mainGUI.AddEdit("vlog x" 240/2 " y" 40/2 " w" 960/2 " h" 610/2 " Background303030 -E0x200 -WantReturn -Wrap +0x100000 +ReadOnly +0x4000000") ; +0x100000: 水平滚动条
mainGUI['log'].SetFont("s10")


;========================================================================================================
; 第四个标签页：设置(Settings) 
;========================================================================================================
Tab.UseTab(4)
mainGUI.Button.Text( {name:'save', x:1030/2, y:570/2, w:140/2, h:50/2, R:10/2, normalColor:'0x1Affffff', activeColor:'9657DB', text:'Save', textOpt:'+0x200 center', textHorizontalMargin:0, fontOpt:'cffffff s10', font:''} )
mainGUI.Button.OnEvent('save', 'Click', (*)=>Msgbox())

;========================================================================================================
; 第五个标签页：关于(About) 
;========================================================================================================
Tab.UseTab(5)
; 背景
mainGUI.AddPicture("vleftBackground x" 260/2 " y" 46/2 " w" 920/2*(A_ScreenDPI/96) " h" 585/2*(A_ScreenDPI/96) " BackgroundTrans +0xE -E0x200")
Gdip_SetPicRoundedRectangle(mainGUI["leftBackground"], "0x0Dffffff", 15, isFill:="true")
; 软件名
mainGUI.AddText("vsoftware x" 320/2 " y" 70/2  " w" 540/2 " h" 60/2 " 0x200 backgroundtrans", "AHK-ChangeIcon")
; 版本
mainGUI.AddText("vversion x"  320/2 " y" 130/2 " w" 300/2 " h" 40/2 " 0x200 backgroundtrans", "Version 2.8.0 (x64)")
; 作者
mainGUI.AddText("vauthor x"   320/2 " y" 170/2 " w" 300/2 " h" 40/2 " 0x200 backgroundtrans", "Author: iKineticate").OnEvent("DoubleClick", (*)=>"")
; 跳转至网页
mainGUI.Button.Text( {name:"github"      , x:316/2, y:210/2, w:222/2, h:60/2, R:10/2, normalColor:"0x00ffffff", activeColor:"0x1Affffff", textOpt:"+0x200",textHorizontalMargin:"2", fontOpt:"s11 c5bad72", font:"", text: TEXT.GITHUB} )
mainGUI.Button.Text( {name:"download"    , x:316/2, y:270/2, w:222/2, h:60/2, R:10/2, normalColor:"0x00ffffff", activeColor:"0x1Affffff", textOpt:"+0x200",textHorizontalMargin:"2", fontOpt:"s11 c5bad72", font:"", text: TEXT.DOWNLOAD} )
mainGUI.Button.Text( {name:"help"        , x:316/2, y:330/2, w:222/2, h:60/2, R:10/2, normalColor:"0x00ffffff", activeColor:"0x1Affffff", textOpt:"+0x200",textHorizontalMargin:"2", fontOpt:"s11 c5bad72", font:"", text: TEXT.ABOUT_HELP} )
mainGUI.Button.Text( {name:"issues"      , x:316/2, y:390/2, w:222/2, h:60/2, R:10/2, normalColor:"0x00ffffff", activeColor:"0x1Affffff", textOpt:"+0x200",textHorizontalMargin:"2", fontOpt:"s11 c5bad72", font:"", text: TEXT.ISSUES} )
mainGUI.Button.Text( {name:"contribution", x:316/2, y:450/2, w:222/2, h:60/2, R:10/2, normalColor:"0x00ffffff", activeColor:"0x1Affffff", textOpt:"+0x200",textHorizontalMargin:"2", fontOpt:"s11 c5bad72", font:"", text: TEXT.CONTRIBUTORS} )

mainGUI["software"].SetFont("s18 cffffff", "Verdana")
mainGUI["version"].SetFont("s10 cbebebe" , "Franklin Gothic")
mainGUI["author"].SetFont("s10 cbebebe"  , "Franklin Gothic")
mainGUI.SetFont("s10 c666666", "Cambria")

mainGUI.Button.OnEvent('github'      , 'Click', (*) => Run('https://github.com/iKineticate/AHK-ChangeIcon'))
mainGUI.Button.OnEvent('download'    , 'Click', (*) => Run('https://github.com/iKineticate/AHK-ChangeIcon/releases/latest'))
mainGUI.Button.OnEvent('help'        , 'Click', (*) => Run('https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#已知问题'))
mainGUI.Button.OnEvent('issues'      , 'Click', (*) => Run('https://github.com/iKineticate/AHK-ChangeIcon/issues'))
mainGUI.Button.OnEvent('contribution', 'Click', (*) => Run('https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#感谢'))

mainGUI.ToolTips.SetTip(mainGUI["author"]                 , "酷安：林琼雅")
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['github']      , "https://github.com/iKineticate/AHK-ChangeIcon")
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['download']    , "https://github.com/iKineticate/AHK-ChangeIcon/releases")
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['help']        , "https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#已知问题") ; 根据中英文更换链接
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['issues']      , "https://github.com/iKineticate/AHK-ChangeIcon/issues")
mainGUI.ToolTips.SetTip(mainGUI.Button.Obj['contribution'], "https://github.com/iKineticate/AHK-ChangeIcon?tab=readme-ov-file#感谢")

mainGUI.AddText("vcopyRight x" 320/2 " y" 510/2 " w" 600/2 " h" 35/2 " 0x200 backgroundtrans", "Copyright " chr(0x00A9) " 2023 iKineticate")
mainGUI.AddText("viconsFrom x" 320/2 " y" 545/2 " w" 600/2 " h" 35/2 " 0x200 backgroundtrans", "Logo by iconfield from www.flaticon.com")
mainGUI.AddText("vlogoFrom  x" 320/2 " y" 580/2 " w" 600/2 " h" 30/2 " 0x200 backgroundtrans", "Icons from www.iconfont.cn and www.flaticon.com")


;==========================================================================
; 深色模式(Drak Mode) 
;==========================================================================
Tab.UseTab()
; （1）窗口标题栏（根据Windows版本赋予attr不同的值）
dwAttr:= (VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : ((VerCompare(A_OSVersion, "10.0.17763") >= 0) ? 19 : "")
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", mainGUI.Hwnd, "int", dwAttr, "int*", True, "int", 4)
; （2）呼出的菜单（1：根据系统显示模式调整深浅，2：深色，3：浅色）
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 135, "Ptr"), "int", 2)
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 136, "Ptr"))
; （3）列表的滚动条+标题栏透明实现浅色
LV_header_hwnd := SendMessage(0x101F, 0, 0, LV.hWnd)     ;列表标题栏的hwnd
DllCall("uxtheme\SetWindowTheme", "Ptr", LV_header_hwnd, "Str", "DarkMode_ItemsView", "Ptr", 0)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
; （4）日志(Edit)的滚动条
DllCall("uxtheme\SetWindowTheme", "Ptr", mainGUI['log'].hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)


mainGUI.Morden.Show()              ; 展示圆角GUI
OnMessage(0x200, WM_MOUSEMOVE)     ; 监测mainGUI内的鼠标移动
OnMessage(0x03 , WM_MOVE)          ; 监测mainGUI窗口的移动
OnMessage(0x20 , WM_SETCURSOR, -1) ; 设置mainGUI内鼠标样式

;==========================================================================
Return
;==========================================================================


;==========================================================================
; 处理鼠标移动的消息（使光标下控件转换为活跃态）
;==========================================================================
WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
    If currentControl := GuiCtrlFromHwnd(Hwnd) {    ; 若鼠标下为窗口控件，则执行功能
        thisGui := currentControl.Gui    ; 获取控件hwnd和父窗口
        
        If currentControl = thisGui.activeControl    ; 若当前控件为活动控件或指定控件，则返回（避免鼠标在这些控件移动时发生重复闪烁或错误）
            Return
        
        (thisGui.activeControl) ? WM_MOUSELEAVE(thisGUI) : False    ; 若存在其他活跃态控件，则取消其活跃态

        If currentControl = mainGUI.lastTab    ; 取消其他活跃态后，在判读是否为当前焦点标签页
        or currentControl = mainGUI["LV"]
        or currentControl = mainGUI['log']
            Return

        thisGui.activeControl := currentControl    ; 定义活跃态控件为当前焦点控件

        If Instr(currentControl.name, "_TAB_BUTTON") {    ; 设置当前控件为活跃态（若为标签页则特殊处理）
            activeName     := StrReplace(currentControl.name, "_TAB_BUTTON", "_ACTIVE")
            indicatorName  := StrReplace(currentControl.name, "_TAB_BUTTON", "_INDICATOR")
            logoSymbolName := StrReplace(currentControl.name, "_TAB_BUTTON", "_SYMBOL")
            activeColor    := tabProp.labelProp.fontActiveColor

            thisGui[activeName].Visible  := True    ; 高亮背景
            thisGui[currentControl.name].SetFont("c" activeColor)    ; 高亮名称

            tabProp.HasOwnProp("labelIndicator") ? thisGui[indicatorName].Visible := True           : False    ; 高亮其指示符
            tabProp.HasOwnProp("logoSymbol")      ? thisGui[logoSymbolName].SetFont("c" activeColor) : False    ; 高亮标签图标
        } Else {
            activeControlName := StrReplace(currentControl.name, "_BUTTON", "_ACTIVE")
            thisGui[activeControlName].Visible := True    ; 高亮背景
        }
    } Else {
        static WM_NCLBUTTONDOWN := 0xA1   ; 按下鼠标的左键
        static WM_NCHITTEST     := 2      ; 窗口的标题栏中
      ; static wParam            = 1      ; 鼠标左键被按下
        ((wParam = 1) and (hwnd = mainGUI.hwnd)) ? PostMessage(WM_NCLBUTTONDOWN, WM_NCHITTEST) : WM_MOUSELEAVE(mainGUI)
    }
}


;==========================================================================
; 处理离开mainGUI窗口消息（取消绝大部分控件活跃态）
;==========================================================================
WM_MOUSELEAVE(thisGUI) {
    Try {
        If !thisGUI.activeControl    ; 若该窗口的活动按钮不存在、不为可被点击的按钮控件或为上一次标签页，则返回
        or !Instr(thisGUI.activeControl.name, "_BUTTON")
        or  thisGUI.activeControl = thisGUI.lastTab
            Return
    }

    If Instr(thisGUI.activeControl.name, "_TAB_BUTTON") {    ; 隐藏上一次活跃控件的活跃态
        activeName     := StrReplace(thisGUI.activeControl.name, "_TAB_BUTTON", "_ACTIVE")
        indicatorName  := StrReplace(thisGUI.activeControl.name, "_TAB_BUTTON", "_INDICATOR")
        logoSymbolName := StrReplace(thisGUI.activeControl.name, "_TAB_BUTTON", "_SYMBOL")
        normalColor    := tabProp.labelProp.fontNormalColor

        thisGUI[activeName].Visible  := False    ; 隐藏高亮背景
        thisGUI[thisGUI.activeControl.name].SetFont("c" normalColor)    ; 恢复名称原色

        tabProp.HasOwnProp("labelIndicator") ? thisGUI[indicatorName].Visible := False          : False    ; 恢复其指示器原色
        tabProp.HasOwnProp("logoSymbol")      ? thisGUI[logoSymbolName].SetFont("c" normalColor) : False    ; 恢复标签图标原色
    } Else {
        activeControlName := StrReplace(thisGUI.activeControl.name, "_BUTTON", "_ACTIVE")
        thisGUI[activeControlName].Visible := False    ; 隐藏高亮背景
    }
    
    thisGUI.activeControl := False    ; 设置窗口活动按钮不存在
}


;==========================================================================
; iconGUI窗口随mainGUI窗口移动而移动
;==========================================================================
WM_MOVE(wParam, lParam, Msg, Hwnd) {
    If (Hwnd != mainGUI.hwnd) or !IsSet(iconGUI) or !(iconGUI is GUI)
        Return

    Try {
        mainGUI.GetPos(&mainX, &mainY, &mainW)
        iconGUI.Move((mainX/(A_ScreenDPI/96)+mainW+10), mainY/(A_ScreenDPI/96))
    } Catch {
        Return
    }
}


;==========================================================================
; 不同控件下的鼠标样式
;==========================================================================
; 不用WM_MOUSEMOVE的原因：光标移动时，系统会在新位置重绘类游标。若要防止重绘类游标，必须处理WM_SETCURSOR消息。每次移动光标和未捕获鼠标输入时，系统都会将此消息发送到光标移动的窗口
WM_SETCURSOR(wParam, lParam, msg, hwnd) {
    static IMAGE_CURSOR   := 2
    ,      LR_DEFAULTSIZE := 0x00000040
    ,      LR_SHARED      := 0x00008000
    
    static LoadCursor(name) => DllCall("User32.dll\LoadImage", "Ptr", hInst:=0, "Ptr", name, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", LR_DEFAULTSIZE|LR_SHARED, "Ptr")

    static hCursPrior := 0    ; About Cursors: https://learn.microsoft.com/zh-CN/windows/win32/menurc/about-cursors
    ,      hCursARROW := LoadCursor(IDC_ARROW:=32512)  ; 正常箭头
    ,      hCursWAIT  := LoadCursor(IDC_WAIT :=32514)   ; 正在工作
    ,      hCursHAND  := LoadCursor(IDC_HAND :=32649)   ; 按钮点击

    ; Critical("on")
    hCursNew := 0, hcursor := 0

    MouseGetPos(,,,&ctrlHwnd:=0, 2) ;   2: 保存控件hwnd到第四个参数，而不是控件ClssNN
    Switch ctrlHwnd {
        Case mainGUI.Button.Obj['changedAllLinks'].hwnd  :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['restoreAllLinks'].hwnd  :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['github'].hwnd           :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['download'].hwnd         :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['help'].hwnd             :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['issues'].hwnd           :  hCursNew := hCursHand
        Case mainGUI.Button.Obj['contribution'].hwnd     :  hCursNew := hCursHand
        Default :
            Try {
                If !IsSet(iconGUI) or !(iconGUI IS GUI) or (hwnd != iconGUI.hwnd)
                    Return
                (ctrlHwnd = iconGUI.Button.Obj['iconGUIBtn1'].hwnd) ? hCursNew := hCursHand : False
                (ctrlHwnd = iconGUI.Button.Obj['iconGUIBtn2'].hwnd) ? hCursNew := hCursHand : False
            }
    }

    If hCursNew {
        hcursor := DllCall("SetCursor", "Ptr", hCursNew, "Ptr")
        hCursPrior ? False : hCursPrior := hcursor
    } Else If hCursPrior {
        hcursor := DllCall("SetCursor", "Ptr", hCursPrior, "Ptr")
        hCursPrior := 0
    }            

    return (hcursor ? True : False)
}


;==========================================================================
; 调用WshShell对象（COM对象）获取、更改、创建快捷方式的属性
;==========================================================================
ManageLinkProp(&objLink, &linkPath, &linkIconLocation) {
    objLink := ComObject("WScript.Shell").CreateShortcut(linkPath)       ; 对象快捷方式
    linkIconLocation := RegExReplace(objLink.IconLocation, ",-?\d+$")    ; 快捷方式的图标路径(去除了图片编号)(存储的是值而不是变量)
    ; objLink.IconLocation     - 提供或设置快捷方式对象的图标位置
    ; objLink.TargePath        - 提供或设置快捷方式对象的目标路径
    ; objLink.WorkingDirectory - 提供或设置快捷方式对象的工作目录
    ; objLink.Save             - 将快捷方式存储到指定的文件系统中
}


;==========================================================================
; 将目标文件夹中的快捷方式添加进列表的功能函数
;==========================================================================
AddLinksFromFolderToLV(shortcutFolderPath, Mode) {    ; Mode:="R"扫描子文件夹中的文件，默认只扫描目标文件夹中的文件
    mainGUI.Opt("+Disabled")    ; 禁止与GUI交互
    Loop Files, shortcutFolderPath "\*.lnk", Mode {
        SplitPath(linkPath := A_LoopFilePath,,,, &linkName)        ; 快捷方式无扩展名的名称
        ManageLinkProp(&objLink, &linkPath, &linkIconLocation)     ; 调用WshShell对象的函数，获取快捷方式属性

        ; 若快捷方式属性中有目标路径，但目标文件不存在，则提醒建议删除，然后执行下一循环
        If !FileExist(linkTargetPath := objLink.TargetPath) and objLink.TargetPath {
            (Msgbox(linkName . TEXT.IS_DELETE, "( •̀ ω •́ )y", "OKCANCEL icon?") = "OK") ? FileDelete(linkPath) : False
            Continue
        }

        ; 若快捷方式属性中有目标目录，但目录不存在，则利用SplitPath分解存在的目标路径获取目录
        If DirExist(linkTargetDir := objLink.WorkingDirectory) {
            SplitPath(linkTargetPath, &linkTargetName, , &linkTargetExt)
        } Else {
            SplitPath(linkTargetPath, &linkTargetName, &linkTargetDir, &linkTargetExt)
        }
        
        Switch linkTargetName {
            Case 'schtasks.exe'   : linkTargetExt := "schtasks" ; 任务计划程序
            Case 'explorer.exe'   : linkTargetExt := "explorer" ; 资源管理器
            Case 'cmd.exe'        : linkTargetExt := "cmd"      ; 命令提示符
            Case 'powershell.exe' : linkTargetExt := "psh"      ; PowerShell
            Case 'wscript.exe'    : linkTargetExt := 'wscript'  ; WScript 对象
            Case 'mstsc.exe'      : linkTargetExt := 'mstsc'    ; 远程连接
            Case 'control.exe'    : linkTargetExt := 'control'  ; 控制面板
            Default :
                Switch {
                    Case !linkTargetExt :
                        linkTargetExt := "uwp"
                    Case InStr(linkTargetPath, "WindowsSubsystemForAndroid") :
                        linkTargetExt := "app"
                    Default :
                        linkTargetExt := StrLower(linkTargetExt)
                }
        }

        linkID := linkName . linkTargetExt
        If MapLinkProp.Has(linkID)  ; 本次循环中，若快捷方式属性的数组存在快捷方式唯一标识，则执行下一循环
            Continue
        MapLinkProp[linkID] := {
              LTP : (linkTargetPath ? linkTargetPath : Text.SAFE_UNAVAILABLE)    ; Link Target Path = 快捷方式的目标路径（UWP无法查看）
            , LTD : (linkTargetDir  ? linkTargetDir  : Text.SAFE_UNAVAILABLE)    ; Link Target Dir  = 快捷方式的目标目录（UWP无法查看）
            , LP  : (A_LoopFilePath)                                             ; Link Path = 快捷方式的路径
            , LD  : (A_LoopFileDir)                                              ; Link Dir  = 快捷方式的目录
        }

        If !FileExist(linkIconLocation)    ; 图标不存在
        or linkIconLocation = linkTargetPath    ; 图标源于目标文件图标
        or RegExMatch(linkIconLocation, "i)WindowsSubsystemForAndroid|%[^%]+%|\{[^\{]+\}\\[^\\]+\.exe$")    ; 图标源于APP图标、系统图标(%__%)或{__}\__\.exe图标
        or (linkTargetDir = RegExReplace(linkIconLocation, "\\([^\\]+)\.ico$"))     ; 图标来源于其目标上一级目录的图标
        or (linkTargetDir and InStr(linkIconLocation, linkTargetDir)) {     ; 图标来源于其目标子目录中的图标
            IsChangede := ""
        } Else {
            IsChangede := "√"
            mainGUI["countOfChanged"].Value += 1
        }

        hIcon      := GetFileHICON(A_LoopFilePath)
        IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", IL_ID, "Int", -1, "Ptr", hIcon) + 1, DllCall("DestroyIcon", "ptr", hIcon)
        LV.Add("Icon" IconNumber, linkName, IsChangede, linkTargetExt)         ; 列表添加图标、名称、"√"、目标扩展名
    }

    LV.ModifyCol(1, "+Sort")
    LV.ModifyCol(2, "+Center")
    LV.ModifyCol(3, "+Center +Sort")        ; 先第一列（名称）排列，后第三列（扩展名）排列，保证扩展名为主排列，名称为次排列
    mainGUI.Opt("-Disabled")
}


;==========================================================================
; DllCall获取图标的函数
;==========================================================================
GetFileHICON(filePath) {
    static SHGFI_ICON := 0x100          ; 检索表示文件图标的句柄
  ; static SHGFI_SMALLICON := 0x001     ; 修改 SHGFI_ICON，使函数检索文件的小型图标
  ; static SHGFI_LARGEICON := 0x000     ; 修改 SHGFI_ICON，使函数检索文件的大型图标
  ; static SHGFI_ICON + SHGFI_LARGEICON = 0x100
  ; static SHGFI_ICON + SHGFI_SMALLICON = 0x101
    fileInfo := Buffer(fisize := A_PtrSize + 688)
    If DllCall("Shell32\SHGetFileInfoW"
        , "Str", filePath
        , "Uint", 0
        , "Ptr", fileInfo
        , "UInt", fisize
        , "UInt", SHGFI_ICON)
    Return hIcon := (NumGet(fileinfo, 0, "Ptr") ? NumGet(fileinfo, 0, "Ptr") : LoadPicture('shell32.dll', 'icon3'))
}


;==========================================================================
; 刷新图标显示的函数
;==========================================================================
RefreshIconDisplay(LV, Item, IsRefreshListIcon := False) {
    LV.Focus()
    linkID         := LV.GetText(Item, 1) . LV.GetText(Item, 3)
    linkPath       := MapLinkProp[linkID].LP
    linkTargetPath := MapLinkProp[linkID].LTP

    Try {
        hIcon := GetFileHICON(linkPath)
        If IsRefreshListIcon {
            IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", IL_ID, "Int", -1, "Ptr", hIcon) + 1
            LV.Modify(Item, "Icon" IconNumber)
        }
        mainGUI["displayNewIcon"].Value := "HICON:" hIcon, DllCall("DestroyIcon", "ptr", hIcon)
    } Catch {
        mainGUI["displayNewIcon"].Value := "*icon3 shell32.dll"    ; 从系统中调用第二个图标--应用
    }

    Try {  ; 无法获取某些应用(如UWP)目标的路径，或应用目标路径不存在时，采用Try
        hIcon := GetFileHICON(linkTargetPath)
        mainGUI["displayOldIcon"].Value := "HICON:" hIcon, DllCall("DestroyIcon", "ptr", hIcon)
    } Catch {
        mainGUI["displayOldIcon"].Value := "*icon3 shell32.dll"    ; 从系统中调用第二个图标--应用
    }
}

;==========================================================================
; 更换单个快捷方式的图标函数
;==========================================================================
ChangeLinkIcon(LV, Item) {
    mainGUI.Opt("+OwnDialogs")   ; 解除对话框(如Msgbox等)后才可与GUI交互
    linkName := LV.GetText(Item, 1)
    linkExt  := LV.GetText(Item, 3)
    linkID   := linkName . linkExt
    linkPath := MapLinkProp[linkID].LP

    ManageLinkProp(&objLink, &linkPath, &linkIconLocation)    ; 创建WshShell对象，设置或获取快捷方式属性

    selectedIconPath := FileSelect(3,, TEXT.SELECT_A_ICON, "Icon file(*.ico)")    ; 选择文件格式为“.ico”的图标并赋予图标路径给该变量
    If ((!selectedIconPath) OR (selectedIconPath = linkIconLocation))
        Return

    objLink.IconLocation := selectedIconPath    ; 更换图片并保存该操作
    objLink.Save()

    If !LV.GetText(Item, 2) {    ; 更新显示的数据
        mainGUI["countOfChanged"].Value   += 1
        mainGUI["countOfUnchanged"].Value -= 1
    }

    RefreshIconDisplay(LV, Item, IsRefreshListIcon:=True)
    RefreshExplorer()

    LV.Modify(Item,,,"√")

    mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")    ; 添加至日志
        . Text.LOG_CHANGED_LINK . linkName . "`n`s" 
        . Text.Source_OF_ICON . selectedIconPath . "`n`n===========================================`n`n" 
}


;==========================================================================
; 列表右键菜单事件
;==========================================================================
ShowListContextMenu(LV, Item, IsRightClick, X, Y) {
    If ((Item > 1000) OR (Item <= 0) OR !IsSet(Item))   ; 避免右键列表的标题栏时出现错误
        Return

    linkName       := LV.GetText(Item, 1)
    linkExt        := LV.GetText(Item, 3)
    linkID         := linkName . linkExt
    linkTargetPath := MapLinkProp[linkID].LTP
    linkTargetDir  := MapLinkProp[linkID].LTD
    linkPath       := MapLinkProp[linkID].LP
    linkDir        := MapLinkProp[linkID].LD

    ManageLinkProp(&objLink, &linkPath, &linkIconLocation)    ; 创建WshShell对象，设置或获取快捷方式属性

    LVContextMenu := Menu()
    LVContextMenu.Add(TEXT.MENU_RUN    , (*) => Run(linkPath))
    LVContextMenu.Add()
    LVContextMenu.Add(TEXT.MENU_CHANGE , (*) => ChangeLinkIcon(LV, Item))
    LVContextMenu.Add()
    LVContextMenu.Add(TEXT.MENU_RESTORE, (*) => RestoreLinkIconsToDefault())
    LVContextMenu.Add()
    LVContextMenu.Add(TEXT.MENU_EXTRACT, (*) => ExtractLinkIcon())
    LVContextMenu.Add()
    LVContextMenu.Add(TEXT.MENU_OPEN   , (*) => Run(linkTargetDir))
    LVContextMenu.Add()
    LVContextMenu.Add(TEXT.MENU_RENAME , (*) => RenameLink())
    LVContextMenu.Add()

    ; 创建总菜单的子菜单
    addLinkPropToMenu := Menu()
    addLinkPropToMenu.Add(TEXT.COPY_LINK_TARGET_PATH . linkTargetPath    , (*) => (A_Clipboard := linkTargetPath))
    addLinkPropToMenu.Add()
    addLinkPropToMenu.Add(TEXT.COPY_LINK_TARGET_DIR . linkTargetDir      , (*) => (A_Clipboard := linkTargetDir))
    addLinkPropToMenu.Add()
    addLinkPropToMenu.Add(TEXT.COPY_LINK_Path . linkPath                 , (*) => (A_Clipboard := linkPath))
    addLinkPropToMenu.Add()
    addLinkPropToMenu.Add(TEXT.COPU_LINK_DIR . linkDir                   , (*) => (A_Clipboard := linkDir))
    addLinkPropToMenu.Add()
    addLinkPropToMenu.Add(TEXT.COPY_LINK_ICON_PATH . objLink.IconLocation, (*) => (A_Clipboard := objLink.IconLocation))

    LVContextMenu.Add(TEXT.MENU_PROPERTIES, addLinkPropToMenu)   ; 快捷方式属性添加至上下文菜单

    hIcon := GetFileHICON(linkPath)
    LVContextMenu.SetIcon(TEXT.MENU_RUN, "HICON:" hIcon), DllCall("DestroyIcon", "ptr", hIcon)       ; 菜单的运行文件的图标
    LVContextMenu.SetIcon(TEXT.MENU_CHANGE    , "HICON:" Base64PNGToHICON(Base64.PNG.MENU_CHANGE))   ; 菜单的改变图标的图标
    LVContextMenu.SetIcon(TEXT.MENU_RESTORE   , "HICON:" Base64PNGToHICON(Base64.PNG.MENU_DEFAULT))  ; 菜单的恢复默认的图标
    LVContextMenu.SetIcon(TEXT.MENU_EXTRACT   , "HICON:" Base64PNGToHICON(Base64.PNG.MENU_EXTRACT))  ; 菜单的提取目标的图标
    LVContextMenu.SetIcon(TEXT.MENU_OPEN      , "HICON:" Base64PNGToHICON(Base64.PNG.MENU_FOLDER))   ; 菜单的目标目录的图标
    LVContextMenu.SetIcon(TEXT.MENU_RENAME    , "HICON:" Base64PNGToHICON(Base64.PNG.MENU_RENAME))   ; 菜单的重新命名的图标
    LVContextMenu.SetIcon(TEXT.MENU_PROPERTIES, "HICON:" Base64PNGToHICON(Base64.PNG.MENU_PROPERTY)) ; 菜单快捷方式属性图标
    
    ; 若当前列表快捷方式来源不是桌面，则给列表右键菜单选项添加一行"添加其至桌面"
    If (folderListFrom != "Desktop") {
        LVContextMenu.Add()
        LVContextMenu.Add(TEXT.MENU_ADD_LINK_TO_DESKTOP, (*) => AddLinkToDesktop)
        LVContextMenu.SetIcon(TEXT.MENU_ADD_LINK_TO_DESKTOP, "HICON:" Base64PNGToHICON(Base64.PNG.MENU_DESKTOP))
    }

    ; 若选择与焦点行为UWP应用或APP应用，将"恢复默认图标"和"打开目标目录"的功能禁止
    If ((linkTargetPath = TEXT.SAFE_UNAVAILABLE)) {
        LVContextMenu.Disable(TEXT.MENU_RESTORE)
        LVContextMenu.Disable(TEXT.MENU_OPEN)
        ; linkIconLocation ? False : LVContextMenu.Disable(TEXT.MENU_EXTRACT)
    }

    LVContextMenu.Show()

    RestoreLinkIconsToDefault(*) {
        ; 若图标为默认图标则返回
        If ((linkIconLocation = linkTargetPath) OR (!linkIconLocation))
            Return

        objLink.IconLocation := linkTargetPath
        objLink.Save()

        ; 更新显示的数据（若此前已更换过图标，则执行更新）
        If (LV.GetText(Item, 2) = "√") {
            mainGUI["countOfChanged"].Value   -= 1
            mainGUI["countOfUnchanged"].Value += 1
        }

        RefreshIconDisplay(LV, Item, IsRefreshListIcon:=True)    ; 刷新显示并修改Y/N
        LV.Modify(Item,,,"")

        RefreshExplorer()

        mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
            . TEXT.LOG_RESTORE_LINK . linkName . "`n`n===========================================`n`n"
    }

    ExtractLinkIcon(*) {
        ; 无法检测系统环境变量如%windir%，如%windir%\system32\Speech\SpeechUX\sapi.cpl,5
        RegExMatch(linkIconLocation, 'i)^%[^%]+%', &environmentVariables)

        If environmentVariables {
            Switch StrLower(environmentVariables[]) {
                Case '%windir%'            : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', A_WinDir)
                Case '%systemroot%'        : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', A_WinDir)
                Case '%programfiles%'      : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', 'C:\Program Files')
                Case '%programfiles(x86)%' : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', 'C:\Program Files (x86)')
                Case '%programfiles(arm)%' : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', 'C:\Program Files (ARM)')
                Case '%systemdrive%'       : linkIconLocation := RegExReplace(linkIconLocation, 'i)^%[^%]+%', 'C:')
            }
        }

        Switch RegExReplace(linkIconLocation, '.+\.') {
            Case 'ico' :
                If Msgbox(TEXT.LINK_ICON_FROM_EXIST_ICO,,'Iconi OKCancel') = 'Cancel'
                    Return
                ; 没有自带loop检测重复名称，需另检测
                iconName := linkName
                Loop    ; 重复的名称
                    iconName := (A_Index = 2) ? iconName '_1' : RegExReplace(iconName, '_\d+$', '_' (A_Index-1))
                Until !FileExist(A_Desktop '\' iconName '.ico')
                FileCopy(linkIconLocation, A_desktop '\' iconName '.ico')
            Case 'dll' :
                RegExMatch(objLink.IconLocation, '-?\d+$', &iconNumber)
                index := iconNumber[]+1
                ConvertToIconFile.Dll( {dllName:linkIconLocation, index:index, size:0, iconName:linkName} )
            Case 'exe' :
                RegExMatch(objLink.IconLocation, '-?\d+$', &iconNumber)
                index := (iconNumber[] = -1) ? 1 : iconNumber[]+1   ; 特殊情况：检测到的索引号是-1的exe提取不了图片，把索引号改为0(index := 0+1)

                If FileExist(linkIconLocation) and (index=1) {    ; 如果exe存在0索引图标(iconNumber[]=0)，则使用File
                    ConvertToIconFile.File( {path:linkIconLocation, iconName:linkName} )
                } Else {    ; 可用于提取linkIconLocation为explorer.exe图标或其他完整路径的exe且有索引号的图标
                    ConvertToIconFile.Dll( {dllName:linkIconLocation, index:index, size:0, iconName:linkName} )
                }
            Case '' :
                path := FileExist(linkTargetPath) ? linkTargetPath : linkPath
                ConvertToIconFile.File( {path:path, iconName:linkName} )
            Default :
                If !FileExist(linkIconLocation) {
                    path := FileExist(linkTargetPath) ? linkTargetPath : linkPath
                    ConvertToIconFile.File( {path:path, iconName:linkName} )
                } Else {
                    RegExMatch(objLink.IconLocation, '-?\d+$', &iconNumber)
                    index := (iconNumber[] = -1) ? 1 : iconNumber[]+1   ; 特殊情况：检测到的索引号是-1的exe提取不了图片，把索引号改为0(index := 0+1)
                    If index=1 {     ; 如果exe存在0索引图标(iconNumber[]=0)，则使用File
                        ConvertToIconFile.File( {path:linkIconLocation, iconName:linkName} )
                    } Else {
                        ConvertToIconFile.Dll( {dllName:linkIconLocation, index:index, size:0, iconName:linkName} )
                    }
                }
        }

        If !FileExist(A_desktop '\' linkName '.ico')
            Return Msgbox(TEXT.FAILED_TO_EXTRACT)
        TrayTip(TEXT.EXTRACTED, "Ciallo～(∠・ω< )⌒★", "Mute"), SetTimer(TrayTip, -5000)
    }

    RenameLink(*) {
        mainGUI.Opt("+OwnDialogs")

        IB := InputBox(TEXT.RENAME_NEW_NAME, linkName, "W300 H100", Trim(linkName))    ; 重命名输入窗口
        If IB.Result = "CANCEL"
            Return
        IB.Value := RegExReplace(IB.Value, "i)\.lnk$")

        Loop LV.GetCount() {     ; 排除重复名称
            If IB.Value = LV.GetText(A_Index, 1)
                Return MsgBox(TEXT.SAME_NAME, "(・∀・(・∀・(・∀・*)", "icon!")
        }

        new_linkPath := linkDir . "\" . IB.Value . ".lnk"   ; 新路径
        FileMove(linkPath, new_linkPath)    ; 重命名

        new_linkID := IB.Value . LV.GetText(Item, 3)    ; 重命名后，快捷方式属性数组添加新键值和删除旧键值
        MapLinkProp[new_linkID] := {LP:new_linkPath, LD:linkDir, LTP:linkTargetPath, LTD:linkTargetDir}
        MapLinkProp.Delete(linkID)

        mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
            . TEXT.LOG_OLD_NAME . linkName . "`n`s" 
            . TEXT.LOG_NEW_NAME . IB.Value . "`n`n===========================================`n`n" 

        LV.Modify(Item,, IB.Value)    ; 更新列表中的快捷方式名称
    }

    AddLinkToDesktop(*) {
        Try {
            If FileExist(A_Desktop '\' linkName '.' linkExt) {
                If Msgbox('桌面已存在相同名称的快捷方式，是否继续创建？',,'iconi OKCancel')='Cancel'
                    Return

                Loop
                    duplicateNmae := (A_Index = 2) ? duplicateNmae '_1' : RegExReplace(duplicateNmae, '_\d+$', '_' (A_Index-1))
                Until !FileExist(A_Desktop '\' duplicateNmae '.' linkExt)
            }

            FileCopy(linkPath, A_Desktop)

            mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
                . "“`s" . linkName . "`s”被添加至当前用户的桌面" . "`n`n===========================================`n`n" 

            Msgbox("成功添加“`s" . linkName . "`s”至当前用户的桌面", "Ciallo～(∠・ω< )⌒★")
        } Catch {
            Msgbox(TEXT.ERROE_ADD_LINK_TO_DESKTOP,, "Icon!")
            Return
        }
    }
}


;==========================================================================
; 在列表中搜索含有关键词的项目的函数
;==========================================================================
Search(*) {
    If mainGUI["searchEditCtrl"].Value = ''
        Return  (ToolTip(TEXT.PLEASE_INPUT, 280*(A_ScreenDPI/96), 70*(A_ScreenDPI/96)) AND SetTimer((*) => ToolTip(), -2000))
    
    mainGUI["searchEditCtrl"].Focus()
    LV.Opt("+Multi")    ; 暂时允许列表多行选择
    LV.Modify(0, "-Select -Focus")

    Loop LV.GetCount() {
        If (!InStr(Trim(LV.GetText(A_Index)), Trim(mainGUI["searchEditCtrl"].Value)))
            Continue
        Sleep(300)
        LV.Modify(A_Index, "+Select +Focus +Vis")   ; 聚焦该列表项目
        RefreshIconDisplay(LV, A_Index)
    }

    ; 禁止列表多行选择（不影响之前的多行选择）
    LV.Opt("-Multi")

    If (ControlGetFocus("A") = mainGUI["searchEditCtrl"].hWnd)    ; 若无目标，则提示“未找到”并返回（利用未寻到目标时焦点在搜索框的机制）
        Return  (ToolTip(TEXT.NOT_FOUND, 280*(A_ScreenDPI/96), 70*(A_ScreenDPI/96)) AND SetTimer((*) => ToolTip(), -2000))
}


;==========================================================================
; 更换所有快捷方式图标的函数
;==========================================================================
ChangeAllLinksIcons(*) {
    mainGUI.Opt("+OwnDialogs")

    ; 访问ini，选择存放ICO文件夹（默认打开上一次），更新ini
    lastSelectedIconFolderPath := iniRead(iniPath, "info", "lastSelectedIconFolderPath")
    If not (selectedFolderPath := DirSelect("*" . lastSelectedIconFolderPath, 0, TEXT.SELECT_ICONS_FOLDER))
        Return
    iniWrite(selectedFolderPath, iniPath, "info", "lastSelectedIconFolderPath")

    changedLog   := ''
    MapMatchName := map()
    
    mainGUI.Opt("+Disabled")
    TrayTip(TEXT.CHANGING)

    Loop Files, selectedFolderPath "\*.ico", "R" {
        iconName := RegExReplace(A_LoopFileName, 'i)\.ico$')
        iconPath := A_LoopFilePath
        noSpacesIconName := RegExReplace(iconName, "[`s`n`t]+")

        Loop LV.GetCount() {
            linkName := LV.GetText(A_Index, 1)
            linkExt  := LV.GetText(A_Index, 3)
            linkID   := linkName . linkExt
            noSpacesLinkName := RegExReplace(linkName, "[`s`n`t]+")

            If MapMatchName.has(linkID)   ; 若数组已存在快捷方式唯一ID，则表明上一次快捷方式和图标完全匹配，再次扫描到该快捷方式时无需在更换，然后跳过本次循环
                Continue  ; 使用Continue跳过本次循环，Return会退出整个函数

            ; 根据快捷方式和图标名称长度来检查二者的包含关系，包含则更换，不包含执行下一次循环
            ; 优势：匹配部分应用名称因版本不同等原因而快捷方式名称不同的情况，如软件Adobe PhtotShop 2024匹配图标名称PhtotShop
            ; 缺点：部分应用与多个不合适的图标匹配，如软件"QQ音乐"更换了图标"QQ"，但图标存在完全与应用名称匹配情况下，可解决该缺点
            Switch VerCompare(StrLen(noSpacesLinkName), StrLen(noSpacesIconName)) {
                Case -1:
                    If !InStr(noSpacesIconName, noSpacesLinkName)
                        Continue 
                Case  1:
                    If !InStr(noSpacesLinkName, noSpacesIconName)
                        Continue 
                Case  0:
                    If (noSpacesLinkName != noSpacesIconName)
                        Continue 
                    MapMatchName[linkID] := "SAME"    ; 本次快捷方式名称和图标名称完全匹配，则添加至数组（注意：数组的键是区分大小写的）
            }

            linkPath := MapLinkProp[linkID].LP
            ManageLinkProp(&objLink, &linkPath, &linkIconLocation)

            If (linkIconLocation = iconPath)    ; 若快捷方式图标路径与文件图标路径相同，则跳过这一次循环
                Continue

            objLink.IconLocation := iconPath
            objLink.Save()

            ; 更新显示的数据(若此前未更换过图标，则执行更新)
            If (LV.GetText(A_Index, 2) = "") {
                mainGUI["countOfChanged"].Value   += 1
                mainGUI["countOfUnchanged"].Value -= 1
            }

            RefreshIconDisplay(LV, A_Index, IsRefreshListIcon:=True)
            LV.Modify(A_Index, "+Select +Focus +Vis",,"√")

            ; 记录更换信息
            changedLog .= linkName . "`s=>`s" . iconName . ".ico`n"

            mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
                . Text.LOG_CHANGED_LINK . LV.GetText(A_Index, 1) . "`n`s"
                . Text.SOURCE_OF_ICON . iconName . ".ico`n`n"
        }
    }
    mainGUI['log'].Value .= "===========================================`n`n"
    mainGUI.Opt("-Disabled")

    If !changedLog
        Return (Msgbox(Text.NO_CHANGE, "╰(￣ω￣ｏ)") and TrayTip)

    RefreshExplorer(), Msgbox(changedLog, Text.SUCCESS)
    TrayTip
    TrayTip(Text.COMPLETED, "Ciallo～(∠・ω< )⌒★", "Mute"), SetTimer(TrayTip, -3000)
}


;==========================================================================
; 恢复所有快捷方式的默认图标事件（UWP、APP不支持恢复默认）
;==========================================================================
RestoreAllLinksIconsToDefault(*) {
    mainGUI.Opt("+OwnDialogs")

    If Msgbox(Text.IS_RESTORE_ALL_ICON, "Ciallo～(∠・ω< )⌒★", "OKCancel Icon? Default2") = "Cancel"
        Return

    mainGUI.Opt("+Disabled")    ; 禁止与GUI交互

    Loop LV.GetCount() {
        If ((LV.GetText(A_Index, 2) != "√") OR (LV.GetText(A_Index, 3) = "uwp"))
            Continue
        linkName       := LV.GetText(A_Index, 1)
        linkExt        := LV.GetText(A_Index, 3)
        linkID         := linkName . linkExt
        linkPath       := MapLinkProp[linkID].LP
        linkTargetPath := MapLinkProp[linkID].LTP

        ManageLinkProp(&objLink, &linkPath, &linkIconLocation)
        objLink.IconLocation := linkTargetPath
        objLink.Save()

        ; 更新显示的数据（若此前更换过图标，则执行更新）
        If (LV.GetText(A_Index, 2) = "√") {
            mainGUI["countOfChanged"].Value   -= 1
            mainGUI["countOfUnchanged"].Value += 1
        }

        RefreshIconDisplay(LV, A_Index, IsRefreshListIcon:=True)
        LV.Modify(A_Index, "+Select +Focus +Vis",,"")

        mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
        . Text.LOG_RESTORE_LINK . LV.GetText(A_Index, 1) . "`n`n"
    }
    mainGUI['log'].Value .= "===========================================`n`n"
    mainGUI.Opt("-Disabled")

    RefreshExplorer()

    TrayTip(Text.COMPLETED, "Ciallo～(∠・ω< )⌒★", "Mute"), SetTimer(TrayTip, -3000)
}


;==========================================================================
; 清空列表中的快捷方式的函数
;==========================================================================
ClearData(*) {
    clearList(), clearMap(), resetCount()
    clearList()  => LV.Delete()
    clearMap()   => MapLinkProp.Clear()
    resetCount() => (mainGUI["countOfChanged"].Value := 0, mainGUI["countOfUnchanged"].Value := 0, mainGUI["countOfTotal"].Value := 0)
}


;==========================================================================
; 添加指定文件夹的快捷方式至列表
;==========================================================================
AddShortcutToList(shortcutFolderPath) {
    Switch folderListFrom := shortcutFolderPath {
        Case 'Desktop' : 
            textIsAdd := Text.IS_ADD_DESKTOP_TO_LV
            textAdded := Text.ADD_DESKTOP_TO_LV
            ArrayLinkFolderPath := [A_Desktop, A_DesktopCommon]
        Case 'Start' :
            textIsAdd := Text.IS_ADD_START_TO_LV
            textAdded := Text.ADD_START_TO_LV
            ArrayLinkFolderPath := [A_StartMenu, A_StartMenuCommon]
        Case 'Other' :
            textIsAdd := Text.IS_ADD_OTHER_TO_LV
            textAdded := Text.ADD_OTHER_TO_LV
    }

    mainGUI.Opt("+OwnDialogs")

    If Msgbox(textIsAdd, "Ciallo～(∠・ω< )⌒★", "Icon? OKCancel") = "Cancel"
        Return

    If folderListFrom = 'Other' {
        lastSelectedLinkFolderPath := iniRead(iniPath, "info", "lastSelectedLinkFolderPath")

        ; 选择目录（默认为上一次选择的目录）
        If not (selectedLinkFolderPath := DirSelect("*" . lastSelectedLinkFolderPath, 0, Text.SELECT_ICONS_FOLDER))
            Return

        ; 检查文件夹名称的最后一个字符是否为反斜杠（避免文件名包含"\"，导致最终变成C:**\**\\这种错误格式）
        (SubStr(selectedLinkFolderPath, -1, 1) = "\") ? (selectedLinkFolderPath := SubStr(selectedLinkFolderPath, 1, -1)) : False
        iniWrite(selectedLinkFolderPath, iniPath, "info", "lastSelectedLinkFolderPath")
        
        folderListFrom := RegExReplace(selectedLinkFolderPath, "^.*\\") 
        
        ArrayLinkFolderPath := [selectedLinkFolderPath]
    }

    ClearData()

    ; 返回主页
    ControlClick(mainGUI[StrReplace(tabProp.labelName[1], "`s") . "_TAB_BUTTON"])

    ; 添加至桌面快捷方式
    For value in ArrayLinkFolderPath {
        AddLinksFromFolderToLV(value, Mode := (shortcutFolderPath='Desktop' ? '':'R'))
    }

    ; 刷新计数
    mainGUI["countOfTotal"].Value     := LV.GetCount() 
    mainGUI["countOfUnchanged"].Value := LV.GetCount() - mainGUI["countOfChanged"].Value
    
    ; 添加至日志
    mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
        . textAdded . "`n`n===========================================`n`n" 

    TrayTip(Text.COMPLETED,"Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)
}



;==========================================================================
; 添加UWP、APP的快捷方式至桌面中的函数
;==========================================================================
AddUwpAppToDesktop(*) {
    mainGUI.Opt("+OwnDialogs")
    If Msgbox(TEXT.IS_ADD_UWP_APP_TO_DESKTOP, "Ciallo～(∠・ω< )⌒★","Icon? OKCancel") = "Cancel"
        Return
    Run("shell:AppsFolder")
}


;==========================================================================
; 备份列表中的快捷方式的函数
;==========================================================================
BackupLinksToFolder(*) {
    mainGUI.Opt("+OwnDialogs")
    If Msgbox(TEXT.IS_BACKUP_TO_FOLDER . folderListFrom . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm") . "`"", "Ciallo～(∠・ω< )⌒★","Icon? OKCancel") = "Cancel"
        Return

     ; 若存在重复文件夹，则创建新的文件夹
    backupFolderPath := A_DesktopCommon . "\" . folderListFrom . FormatTime(A_Now, "_yyyy_MM_dd_HH_mm")
    Loop
        backupFolderPath := (A_Index = 2) ? backupFolderPath '_1' : RegExReplace(backupFolderPath, '_\d+$', '_' (A_Index-1))
    Until !DirExist(backupFolderPath)
    DirCreate(backupFolderPath)

    Loop LV.GetCount() {
        linkName := LV.GetText(A_Index, 1)
        linkExt  := LV.GetText(A_Index, 3)
        linkID   := linkName . linkExt
        linkPath := MapLinkProp[linkID].LP
        FileCopy(linkPath, backupFolderPath, 1)
    }

    mainGUI['log'].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
        . Text.HAVE_BACKUP . StrReplace(backupFolderPath, A_DesktopCommon . "\") . "`n`n===========================================`n`n" 

    TrayTip(Text.COMPLETED, "Ciallo～(∠・ω< )⌒★","Mute"), SetTimer(TrayTip, -2500)
}


;==========================================================================
; 显示/隐藏展示icon窗口
;==========================================================================
ToggleIconGUIVisibility(*) {
    static isShow := False
    If IsSet(iconGUI) and (isShow) {
        iconGUI.Destroy()
        mainGUI["showIconGUI_Symbol"].Text := chr(0xE291)
        isShow := False
    } Else {
        ShowIconGUI()
        mainGUI["showIconGUI_Symbol"].Text := chr(0xE290)
        isShow := true
    }
}


;==========================================================================
; 刷新资源管理器
;==========================================================================
RefreshExplorer() {
    static VT_UI4 := 0x13, SWC_DESKTOP := 0x8
    Windows := ComObject("Shell.Application").Windows
    Windows.Item(ComValue(VT_UI4, SWC_DESKTOP)).Refresh()
    For Process in Windows {
        If (Process.Name = "Internet Explorer")
            Continue
        Process.Refresh()
    }
 }

;==========================================================================
; 退出时关闭GDIP
;==========================================================================
ExitFunc(ExitReason, ExitCode) {
    global  ; gdi+ may now be shutdown on exiting the program
    Gdip_Shutdown(pToken)
}