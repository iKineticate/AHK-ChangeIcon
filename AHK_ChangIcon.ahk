;// @Name                 AHK_ChangeIcon
;// @Author               iKineticate(Github)
;// @Destription:zh-CN    快速更换桌面快捷方式图标
;// @Destription:en       Quickly change of desktop shortcut icons
;// @Version              v2.0
;// @HomepageURL          https://github.com/iKineticate/AHK_ChangeIcon
;// @Icon Source          www.flaticon.com
;// @Icon Source          www.iconfont.cn
;// @Date                 2023/10/19

;@Ahk2Exe-SetVersion v2.0
;@Ahk2Exe-SetFileVersion v2.0
;@Ahk2Exe-SetName AHK_ChangIcon
;@Ahk2Exe-ExeName AHK_ChangIcon
;@Ahk2Exe-SetDescription AHK_ChangIcon

#Requires AutoHotkey >=v2.0
#Include "AHK_Base64PNG.ahk"

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
MyGui := Gui("+Resize", "AHK_ChangIcon")
MyGui.Opt("+MinSize250x250 +MaxSize250x +OwnDialogs")
MyGui.BackColor := "343434"
MyGui.SetFont("s12 Bold", "Microsoft YaHei")            ; 设置其他颜色会导致单选按钮的样式改变
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.OnEvent("Size", MyGui_Size)


; 在左侧顶部创建去除边框的ICO显示区域
Show_Icon_Area := MyGui.AddPicture("x6 y6 w56 h56 -E0x200 Background252329")


; 自动更换（Auto）、手动更换（Manual）的单选按钮
Auto_Change_Radio := MyGui.AddRadio("x+6 yp w56 h28 -Wrap Checked1", "自动")
Manual_Change_Radio := MyGui.AddRadio("xp y+0 w56 h28 -Wrap", "手动")


; 一键更换图标按钮
All_Changed_Picture := MyGui.AddPicture("x+0 y9 w120 h50", "HICON:" Base64PNG_to_HICON(All_Changed_Base64PNG, height := 512))
All_Changed_btn := MyGui.AddButton("xp yp wp hp +0x4000000 -Tabstop").OnEvent("Click", All_Changed)


; 创建去除边框的搜索框、搜索按钮、隐藏搜索按钮(设为默认，Enter触发按钮)，并赋予焦点事件/非焦点事件
Search_Bar := MyGui.AddEdit("x6 y68 w212 h26 Background252329 -E0x200")
Search_Bar.SetFont("c788cde")
Search_Bar.Focus()
Search_Bar.OnEvent("LoseFocus", Search_LoseFocus)
Search_Bar.OnEvent("Focus", Search_Focus)
Search_Btn := MyGui.AddPicture("x+0 yp w26 h26 Background252329"
            , "HICON:" Base64PNG_to_HICON(Search_Base64PNG, height := 64)).OnEvent("Click", Search)
Hidden_Btn := MyGui.AddButton("xp y+0 w0 h0 Default").OnEvent("Click", Search)


; 为列表添加背景图片,使列表透明时可看见，宽度与高度由MyGui_Size函数来决定
LV_Background := MyGui.AddPicture("x6 y+6", "HICON:" Base64PNG_to_HICON(LV_Background_Base64PNG, height := 350))


; 创建去除边框的列表，并赋予点击、双击、右键菜单事件
; -Redraw：关闭重绘(增加列表加载速度)
; -Multi：禁止选择多行，避免出现多个图标更换错误
; -E0x200：去除列表的白色边框
; +LV0x10000：双缓冲绘图，减少左右拉伸时列表闪烁
LV := MyGui.AddListView("x6 yp r12 Background1c1c1c -Redraw  -Multi -E0x200 +LV0x10000"
        , ["Name", "Y/N", "Type"])
LV.SetFont("cd4caff")
LV.OnEvent("ItemFocus", Display_Top_Icon)
LV.OnEvent("DoubleClick", Change_Link_Icon)
LV.OnEvent("ContextMenu", Link_ContextMenu)


Link_Map := map()                                   ; 创建快捷方式(Link)的键-值数组(Map)
ImageListID := IL_Create()                          ; 为添加图标做好准备: 创建图像列表
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

        ; （1）快捷方式名称 = 去除后缀名的名称
        ; （2）是否更换快捷方式图标 = 已更换显示"√"，未更换则不显示
        ; （3）转化为小写的快捷方式的目标扩展名(UWP应用为uwp、WSA应用为app)
        Link_Name := RegExReplace(A_LoopFileName, "\.lnk$")
        Link_YesNo := (Link_Icon_Location = "" 
            OR Link_Icon_Location = Link_Target_Path 
            OR InStr(Link_Icon_Location, "WindowsSubsystemForAndroid")) ? "":"√"

        Switch
        {
            case Link_Target_Ext = "":
                Link_Target_Ext := "uwp"
            case InStr(Link_Target_Path, "WindowsSubsystemForAndroid"):
                Link_Target_Ext := "app"
            case isUpper(Link_Target_Ext):
                Link_Target_Ext := StrLower(Link_Target_Ext)
        }

        ; 在数组Link_Map中，给"快捷方式名称+英文缩写字符"的键赋予对应的值
        ; LTP = 快捷方式的目标路径 = Link Target Path（UWP无法查看）
        ; LTD = 快捷方式的目标目录 = Link Target Dir （UWP无法查看）
        ; LP  = 快捷方式的路径 = Link Path
        ; LD  = 快捷方式的目录 = Link Dir
        Link_Map[Link_Name . "LTP"] := Link_Target_Path = "" ? "————出于安全，无法查看—————":Link_Target_Path
        Link_Map[Link_Name . "LTD"] := Link_Target_Dir = "" ? "————出于安全，无法查看—————":Link_Target_Dir
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

;在列表项目加载完后，恢复列表重绘
LV.Opt("+Redraw")
MyGui.Show()

; 必须优先调整列表总宽度后在调整列表单列宽度，保证第2、3列根据列表总宽度和第一列宽度来自调节宽度
LV.ModifyCol(1, "+Sort")                    ; 先排列好第一行，再排列第三行，保证以第三行排序为主，第一行排序为次
LV.ModifyCol(2, "+AutoHdr +Center")
LV.ModifyCol(3, "+AutoHdr +Center +Sort")



; 《深色模式》
; （1）窗口标题栏（根据Windows版本赋予attr不同的值）
; （2）呼出的菜单（1：根据系统显示模式调整深浅，2：深色，3：浅色）
; （3）列表标题栏、滚动条
dwAttr:= VerCompare(A_OSVersion, "10.0.18985") >= 0 ? 20 : VerCompare(A_OSVersion, "10.0.17763") >= 0 ? 19 : ""
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "int", dwAttr, "int*", true, "int", 4)

DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 135, "Ptr"), "int", 2)
DllCall(DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr"), "Ptr", 136, "Ptr"))

LV_Header := SendMessage(0x101F, 0, 0, LV.hWnd)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", "DarkMode_ItemsView", "Ptr", 0)
DllCall("uxtheme\SetWindowTheme", "Ptr", LV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)


; 《列表透明》
;   GWL_EXSTYLE := -20              ; 设置新的扩展窗口样式
;   WS_EX_LAYERED := 0x80000        ; 设置为分层窗口风格
; 
;   crKey := RGB                    ; 颜色值
;   bAlpha := 0~255                 ; 透明度
;   LWA_COLORKEY := 0x00000001      ; 使用 crKey 作为透明度颜色
;   LWA_ALPHA := 0x00000002         ; 使用 bAlpha 确定分层窗口的不透明度
; 
;   SW_SHOWNORMAL := 1              ; 激活并显示窗口
DllCall("SetWindowLongPtr", "Ptr", LV.hwnd, "int", -20, "Int", 0x80000)
DllCall("SetLayeredWindowAttributes", "Ptr", LV.hwnd, "Uint", 0xF0F0F0, "Uchar", 220, "Uint", 0x2) 
DllCall("ShowWindow", "Ptr", LV.hwnd, "int", 1)


; 鼠标滚轮键/F2键点击图片后更换快捷方式图标
MButton::
F2:: 
{
    MyGui.Opt("+OwnDialogs")
    A_Clipboard := ""
    SendInput("{LButton}")
    Send("^c")
    
    ; 若1秒后剪切板无变化、列表存在多行选择或选择了ico外的文件，则返回并提示
    If (!ClipWait(1))                                   
        Return
    If (LV.GetCount("Select") != 1)
        Return  Msgbox("列表中请值选择一行(Please Only Select 1 Row)", "Warn", 0x10)
    If (!RegExMatch(A_Clipboard, "\.ico$"))
        Return  MsgBox("请选择一张ICO图片(Please select an icon)", "Warn", 0x10)

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

    ; 刷新顶部、列表图标，并添加"√"
    Display_Top_Icon(LV, LV.GetNext(0, "F"))
    Display_LV_Icon(LV, LV.GetNext(0, "F"))
    LV.Modify(ListViewGetContent("Count Focused",LV.Hwnd),,,"√")
}


Return


; 搜索关键词项目
Search(*)
{
    ; 若搜索框未输入文本，则提示“请输入”并返回
    If (Search_Bar.Value = "" OR Search_Bar.Value = "搜索(Search)......")
        Return  (ToolTip("请输入(Please Input)", 120, 190) AND SetTimer((*) => ToolTip(), -2000))

    ; 允许列表多行选择、搜索框为焦点、 取消列表中所有行的选择与焦点，避免与搜索前的选择重叠
    LV.Opt("+Multi")
    Search_Bar.Focus()
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
        Return  (ToolTip("未找到(Not Found)", 120, 190) AND SetTimer((*) => ToolTip(), -2000))
}


; Edit为(非)焦点时，若未输入任何内容则清空(添加)提示词“搜素...”
Search_Focus(*)
{
    Search_Bar.Value := Search_Bar.Value="搜索(Search)......" ? "":Search_Bar.Value
}
Search_LoseFocus(*)
{
    Search_Bar.Value := Search_Bar.Value="" ? "搜索(Search)......":Search_Bar.Value
}


; 在列表左侧刷新列表选择（焦点）项目的图标
Display_LV_Icon(LV, Item)
{
    ; 调用DllCall_Icon函数和图像列表替换函数，添加图标并赋予给IconNumber--刷新列表左侧图标
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    IconNumber := DllCall("ImageList_ReplaceIcon"
        , "Ptr", ImageListID
        , "Int", -1
        , "Ptr", DllCall_Icon(Link_Path)) + 1
    LV.Modify(Item, "Icon" . IconNumber)
    DllCall("DestroyIcon", "Ptr", DllCall_Icon(Link_Map[LV.GetText(Item, 1) . "LP"]))
}


; 在顶部显示、刷新ICO显示区域
Display_Top_Icon(LV, Item)
{
    ; 调用DllCall获取选择(焦点)项目的图标--显示、刷新顶部图标--销毁hIcon
    LV.Focus()
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    Show_Icon_Area.Value := "HICON:" DllCall_Icon(Link_Path)
    DllCall("DestroyIcon", "Ptr", DllCall_Icon(Link_Path))
}


; 更换图标设置
Change_Link_Icon(LV, Item)
{
    MyGui.Opt("+OwnDialogs")

    ; 第一次更换图标时Change_ToolTip未被复制，会通知提醒然后复制，后续更换不会通知提醒
    If (!IsSet(Change_TrayTip))
    {
        TrayTip("注意: 出于安全考虑, 更换UWP应用或WSA应用图标后无法恢复默认图标" 
            . "`n`nNotice: After replacing UWP or WSA icons, their default icons cannot be restored")
        static Change_TrayTip := 1
    }

    ; 调用WshShell对象的函数，获取link各个属性
    Link_Target_Path := Link_Map[LV.GetText(Item, 1) . "LTP"]
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)

    ; 选择文件格式为“.ico”的图标，需更换图标路径赋予给Link_Icon_Select
    ; 若未选择照片或需更换图片是现在的图标则返回，否则更换图片并保存
    Link_Icon_Select := FileSelect(3,       
        , "更换" . LV.GetText(Item, 1) . "的图标", "Icon files(*.ico)")
    If ((Link_Icon_Select = "") OR (Link_Icon_Select = Link_Icon_Location))
        Return
    Link_Attribute.IconLocation := Link_Icon_Select
    Link_Attribute.Save()

    ; 刷新顶部、列表图标、添加"√"
    LV.Modify(Item,,,"√")
    Display_Top_Icon(LV, Item)
    Display_LV_Icon(LV, Item)
    TrayTip
}


; 右键打开菜单设置
Link_ContextMenu(LV, Item, IsRightClick, X, Y) {    
    LV.Focus()                                              ; 右键让列表为焦点
    LV.Modify(0, "-Select -Focus")                          ; 关闭列表所有的选择与焦点（避免搜索时多个选项）
    LV.Modify(Item, "+Select +Focus")                       ; 右键点击的行成为选择焦点

    ; 快捷方式的目标路径、目标目录、路径、目录
    Link_Target_Path := Link_Map[LV.GetText(Item, 1) . "LTP"]
    Link_Target_Dir := Link_Map[LV.GetText(Item, 1) . "LTD"]
    Link_Path := Link_Map[LV.GetText(Item, 1) . "LP"]
    Link_Dir := Link_Map[LV.GetText(Item, 1) . "LD"]

    ; 创建菜单并添加选项及功能
    Link_Menu := Menu()
    Link_Menu.Add("运行当前文件(Run)", (*) => Run(Link_Path))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add("更改文件图标(Change)", (*) => Run(Change_Link_Icon(LV, Item)))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add("恢复默认图标(Default)", Link_Default)
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add("打开目标目录(TargetDir)", (*) => Run(Link_Target_Dir))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add("重新命名文件(Rename)", Link_Rename)

    Link_Infor := Menu()
    Link_Infor.Add("复制目标路径：" . Link_Target_Path, (*) => (A_Clipboard := Link_Target_Path))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add("复制目标目录：" . Link_Target_Dir, (*) => (A_Clipboard := Link_Target_Dir))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add("复制快捷方式路径：" . Link_Path, (*) => (A_Clipboard := Link_Path))
    Link_Infor.Add ;————————————————————————————————————————————————————————————————————————————————
    Link_Infor.Add("复制快捷方式目录：" . Link_Dir, (*) => (A_Clipboard := Link_Dir))
    Link_Menu.Add ;—————————————————————————————————————————————————————————————————————————————————
    Link_Menu.Add("快捷方式属性(Attribute)", Link_Infor)

    ; 调用DllCall获取选择(焦点)项目的图标--在菜单栏第一行显示图标--销毁hIcon
    ; 调用后面的Base64转PNG函数，在菜单栏第二~五行添加对应图标
    Link_Menu.SetIcon("运行当前文件(Run)", "HICON:" DllCall_Icon(Link_Path))
    Link_Menu.SetIcon("更改文件图标(Change)", "HICON:" Base64PNG_to_HICON(Change_Base64PNG))
    Link_Menu.SetIcon("恢复默认图标(Default)", "HICON:" Base64PNG_to_HICON(Default_Base64PNG))
    Link_Menu.SetIcon("打开目标目录(TargetDir)", "HICON:" Base64PNG_to_HICON(Folders_Base64PNG))
    Link_Menu.SetIcon("重新命名文件(Rename)", "HICON:" Base64PNG_to_HICON(Rename_Base64PNG))
    Link_Menu.SetIcon("快捷方式属性(Attribute)", "HICON:" Base64PNG_to_HICON(Attrib_Base64PNG))
    
    ; 若选择与焦点行为UWP应用或WSA应用，则关闭(禁止恢复默认图标和打开目标目录功能
    If ((Link_Target_Path = "————出于安全，无法查看—————") OR InStr(Link_Target_Path, "WindowsSubsystemForAndroid"))
    {
        Link_Menu.Disable("恢复默认图标(Default)")
        Link_Menu.Disable("打开目标目录(TargetDir)")
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
        
        ; 刷新顶部图标、列表图标、删除"√"
        Display_Top_Icon(LV, Item)
        Display_LV_Icon(LV, Item)
        LV.Modify(Item,,,"")
    }

    ; 重命名快捷方式名称
    Link_Rename(*)
    {
        MyGui.Opt("+OwnDialogs")

        IB := InputBox("请输入新的文件名(不包含.lnk):"
            , "重命名" . LV.GetText(Item, 1)
            , "W300 H100"
            , LV.GetText(Item, 1))

        If IB.Result="CANCEL"
            Return

        ; 更换旧快捷方式的路径为新路径
        Link_New_Path := Link_Dir . "\" . IB.Value . ".lnk"
        FileMove(Link_Path, Link_New_Path)

        ; 重命名后，发生变化的只有快捷方式名称、快捷方式的路径，因此需要单独更换，而不能在循环数组中更换
        ; 重命名后，在数组中给新名称(键)赋予新的目标路径、目标目录、lnk路径、lnk目录的值，并删除旧键-值
        Link_Map[IB.Value . "LP"] := Link_New_Path
        Link_Map.Delete(LV.GetText(Item, 1) . "LP")
        For Value in ["LTP", "LTD", "LD"]
        {
            Link_Map[IB.Value . Value] := Link_Map[LV.GetText(Item, 1) . Value]
            Link_Map.Delete(LV.GetText(Item, 1) . Value)
        }

        ; 更换项目的lnk名称（在最后才更新名称是因为过早更新会导致在数组中不能检测到旧名称的键-值，只能检测到新名称的键-值）
        LV.Modify(Item,, IB.Value)
    }
}


; 窗口控件自适应调节位置和宽高
MyGui_Size(thisGui, MinMax, Width, Height)
{
    ; 拖拽窗口、改变窗口尺寸、拖拽窗口内对象时，窗口管理器锁定整个桌面以便可以绘制细点矩形反馈，
    ; 而不会因为其它窗口偶然与细点矩形交叠而导致冲突的风险。
    DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
    if MinMax = -1
        Return
    LV.Move(,, Width -12, Height -108)
    LV.ModifyCol(1, Width - 120)
    LV_Background.Move(,, Width -12, Height -108)
    ; 当移动/改变尺寸的操作完成，桌面被解锁，所有东西恢复原貌。
    DllCall("LockWindowUpdate", "Uint", 0)
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


All_Changed(*)
{
    Change_Links_Icon := "原图标(Original icon)`s→`s新图标(New icon)`n"
    Icons_Map := map()
    Same_Name_Map := map()

    ; 选择存放ICO的文件夹
    Selected_Folder := DirSelect(, 0, "请选择图标文件夹(Select A Folder With Icons)")
    If (Selected_Folder = "")
        Return

    ; 从选择的文件夹中，添加图标组合，ICO名称(键)-ICO路径(值)
    Loop Files, Selected_Folder "\*.ico"
    {
        Icons_Map[RegExReplace(A_LoopFileName, "\.ico$")] := A_LoopFilePath
    }

    TrayTip("正在扫描、更换中(Scanning、Changing)....")

    ; 从图标组合中枚举，并从列表开头开始循环
    For Icon_Name, Icon_Path in Icons_Map
    {
        Loop LV.GetCount()
        {
            Link_Name := LV.GetText(A_Index, 1)
            Link_Path := Link_Map[Link_Name . "LP"]
            COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
            
            ; 若名称不匹配或快捷方式已更换过同样名称的ICO，则跳过循环中的这一次
            ; 注意：若要跳过这一次操作，继续下一个循环不能用Return，Return也算退出循环，用Continue
            If (!Instr(Icon_Name, Link_Name, 0) OR Same_Name_Map.has(Link_Name))
                Continue

            ; 若已更换过或ICON名称等于快捷方式名称则记录在数组same_name_map中
            ; 保证快捷方式在更换一个名称相同的图片后，不会在更换别的含有它的名字但不属于它的照片
            ; 如"QQ.lnk"已更换图标或更换图标是为"QQ.ico"后，下一次就不会更换成"QQ音乐.ico"了
            If ((Link_Icon_Location = Icon_Path) OR (StrLen(Icon_Name) = StrLen(Link_Name)))
            {
                Same_Name_Map[Link_Name] := "OFF"
            }

            If (Link_Icon_Location = Icon_Path)
                Continue

            ; 若选取了手动，弹出确认窗口一个一个确认更换图标
            ; 若选取了自动（默认），则自动更换图标
            If (Auto_Change_Radio.Value = 0)
            {
                MB := MsgBox("快捷方式名称(Link Name): " . Link_Name . "`n" . "文件图标名称(Icon Name): " . Icon_Name
                    , "更换图标中(Changing)"
                    , "YesNoCancel 0x40000")
                Switch MB
                {
                    case "Cancel":
                        Break(2)
                    case "No":
                        Continue
                    case "Yes":
                        Link_Attribute.IconLocation := Icon_Path
                        Link_Attribute.Save()
                }
            }
            Else
            {
                Link_Attribute.IconLocation := Icon_Path
                Link_Attribute.Save()
            }

            ; 刷新顶部图标、列表图标、聚焦更换行，并记录被更换图标的快捷方式名称和图标名称
            LV.Modify(A_index,,,"√")
            Display_Top_Icon(LV, A_index)
            Display_LV_Icon(LV, A_index)
            LV.Modify(A_Index, "+Select +Focus +Vis")
            Change_Links_Icon .= "`n" . Link_Name . "`s→`s" . Icon_Name
        }
    }

    TrayTip

    ; 若记录有更换记录，则显示被更换图标快捷方式名称和更换图标名称，若未记录，则显示“未更换任何图标”
    If (RegExReplace(Change_Links_Icon, "`n") != "原图标(Original icon)`s→`s新图标(New icon)")
        Return Msgbox(Change_Links_Icon, "成功更换图标(Success)!")
    Msgbox("未更换任何图标(Unchanged)", "Hellow World")
}