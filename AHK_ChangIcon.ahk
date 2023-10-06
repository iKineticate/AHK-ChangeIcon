;———————————————————————————————————— 酷安：林琼雅 —————————————————————————————————————————
;————————————————————————————————— Github：Leen_Joan ——————————————————————————————————————
#Requires AutoHotkey >=v2.0

; 以管理员身份运行AHK
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

; 创建窗口、添加标题、允许重绘窗口大小
MyGui := Gui("+Resize", "更改快捷方式图标————Leen_Joan(Github)")
MyGui.BackColor := "343434"                             ; 窗口背景颜色为黑色
MyGui.SetFont("s12 Bold cd47a38", "Microsoft YaHei")    ; 窗口内字体为12号大小、加粗、橙色、微软雅黑
MyGui.OnEvent("Close", (*) => ExitApp())                ; 创建窗口关闭事件（窗口关闭，应用退出）
MyGui.OnEvent("Size", MyGui_Size)                       ; 创建窗口大小改变事件（随窗口改变控件大小也改变）

; 创建去除边框的搜索框，字体为黑色，字体大小为s8
Link_Search := MyGui.AddEdit("x68 y21 w646 h26 -E0x200 -0x100 Background1f1f1f")
Link_Search.SetFont("cb3b3b3")
; 若搜索框不是焦点时显示文字“搜索”，若焦点时清空文本框内容
Link_Search.OnEvent("LoseFocus", Link_Search_LoseFocus)
Link_Search.OnEvent("Focus", Link_Search_Focus)

; 创建隐藏的搜索按钮（在搜索框中按下"Enter"触发搜索功能）
Link_Button := MyGui.AddButton("w0 h0 Default").OnEvent("Click", Search)
; 顶部添加去除边框、无标题的黑色列表（用Listview当背景）
Top_Backgroud_Area := MyGui.AddListView("x62 y6 w646 h56 -Hdr -E0x200 0x4000000 +LV0x10000 Background171717")
; 创建存在边界的ICO显示区域
Show_Icon_Area := MyGui.AddPicture("x6 y6 w56 h56 -E0x200 Background171717")

; 创建去除边框的黑色背景列表，添加“名称、目标扩展名、目标路径、目标目录、lnk路径、lnk目录”的标题，其中后三项不显示
; -Redraw：“关闭重绘”增加列表加载速度；-E0x200：去除边框；+LV0x10000：通过双缓冲绘图, 减少闪烁；-Multi：禁止选择多行
Link_LV := MyGui.AddListView("x6 r15 w700 -Redraw -E0x200 -Multi +LV0x10000 Background1f1f1f"
        , ["Name", "Type","TargetPath", "TargetDir", "Path", "Dir"])
Link_LV.OnEvent("ItemFocus", Link_Focus)            ; 创建列表焦点更新图标事件
Link_LV.OnEvent("DoubleClick", Link_Change)         ; 创建列表双击事件
Link_LV.OnEvent("ContextMenu", Link_ContextMenu)    ; 创建列表右键菜单


; 为列表添加图标做好准备
ImageListID := IL_Create()
Link_LV.SetImageList(ImageListID)
sfi_size := A_PtrSize + 688
sfi := Buffer(A_PtrSize + 688)


; 添加当前用户和所有用户的桌面快捷方式至列表
pathArr := [A_Desktop, A_DesktopCommon]                 ; 创建一个名为pathArr的数组，其内包含两个路径
For Desktop in pathArr                                  ; 从数组中枚举所有对象至Desktop
Loop Files, Desktop "\*.lnk" {                          ; 从循环到的对象中查找快捷方式（pathArr[A_Index]:循环到的对象）
    ; 获取快捷方式的属性
    Link_Attrib := ComObject("WScript.Shell").CreateShortcut(A_LoopFilePath)
    ; 获取快捷方式的目录、目标的扩展名称
    SplitPath(A_LoopFilePath,, &Link_Dir)
    SplitPath(Link_Attrib.TargetPath,,, &Link_Targe_Extension)
    ; Link_Name存储去掉.lnk的快捷方式名称
    Link_Name := StrReplace(A_LoopFileName, ".lnk")
    ;UWP、WSA应用：type和目标路径修改为对应值
    Link_Type := Link_Targe_Extension = "" ? "uwp":Link_Targe_Extension
    Link_Type := InStr(Link_Attrib.TargetPath, "Local\Microsoft\WindowsApps") ? "app":Link_Type
    Link_TargetPath := Link_Attrib.TargetPath = "" ? "————————————————————————————":Link_Attrib.TargetPath

    ; 添加图标至列表
    DllCall("Shell32\SHGetFileInfoW"
        , "Str", A_LoopFilePath
        , "Uint", 0
        , "Ptr", sfi
        , "UInt", sfi_size
        , "UInt", 0x100)
    hIcon := NumGet(sfi, 0, "Ptr")
    IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", hIcon) + 1
    DllCall("DestroyIcon", "Ptr", hIcon)

    ; 将快捷方式的名称、目标路径、目标目录、lnk路径、lnk目录添加至列表中
    Link_LV.Add("Icon" . IconNumber
        , Link_Name
        , Link_Type
        , Link_TargetPath
        , Link_Attrib.WorkingDirectory
        , A_LoopFilePath
        , Link_Dir)
}

Link_LV.Opt("+Redraw")              ; 允许列表重绘大小
Link_LV.ModifyCol(1, "154")         ; 第一列宽度限制为160，并将两次Loop Files结果重新排序
Link_LV.ModifyCol(2,"45 +Sort +Center")     ; 按照目标文件的扩展名进行排序并居中
Link_LV.ModifyCol(3, 326)           ; 第二列宽度限制为500
Link_LV.ModifyCol(4, 0)             ; 隐藏第三列
Link_LV.ModifyCol(5, 0)             ; 隐藏第四列
Link_LV.ModifyCol(6, 0)             ; 隐藏第五列

MyGui.Show()

; 鼠标滚轮键/F2键点击图片后更换快捷方式图标
MButton::
F2:: 
{
    ; 点击并复制文件路径
    SendInput("{LButton}")
    A_Clipboard := ""
    Send("^c")
    ; 若剪切板1秒后内容无变化，则返回（未点击到文件）
    If (!ClipWait(1))
        Return
    ; 若列表选择多行，则提示选择单行
    If (Link_LV.GetCount("Select") > 1)
        Return Msgbox("请勿选择多行(Do not select multi-line)", "Warn", 0x10)    
    ; 若复制文件扩展不为.ico，则返回
    If (!InStr(A_Clipboard, ".ico", True,,-1))
        Return MsgBox("请选择一张ICO图片(Please select an icon)", "Warn", 0x10)
    ; 一行接一行地读取复制的内容 
    Loop Parse, A_Clipboard, "`n", "`r" {
	    FileName := A_LoopField "`n"
    }
    ; 移除FileName里的开头和结尾所有的换行
    FileName := Trim(FileName, "`n")
    ; 获取列表选中行的属性（ 其中ListViewGetCon.....为在列表中的选中行的第4列内容 ）
    Focus_Item_Attrib := ComObject("WScript.Shell").CreateShortcut(ListViewGetContent("Selected Col5",Link_LV.Hwnd))
    ; 将快捷方式图标替换为选中的ICO图标
    Focus_Item_Attrib.IconLocation := FileName
    ; 保存更换操作
    Focus_Item_Attrib.Save()
    ; 刷新图标（ 其中ListViewGetCon.....为列表中的焦点行 ）
    Link_Focus(Link_LV, ListViewGetContent("Count Focused", Link_LV.Hwnd))
}


; 窗口标题栏深色模式
DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MyGui.Hwnd, "int", 20, "int*", true, "int", 4)

; 菜单栏深色模式
DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 135, "ptr"), "int", 2),
DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 136, "ptr"))

; 标题栏和滚动条深色模式
Link_LV_Header := SendMessage(0x101F, 0, 0, Link_LV.hWnd)
DllCall("uxtheme\SetWindowTheme", "Ptr", Link_LV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("uxtheme\SetWindowTheme", "Ptr", Link_LV_Header, "Str", "DarkMode_ItemsView", "Ptr", 0)


; 搜索关键词项目
Search(*) {
    Link_LV.Opt("+Multi")                                           ; 搜索时允许列表多行选择
    If (Link_Search.Value = "")                                     ; 若文本框无文本则不执行
        Return
    Link_LV.Modify(0, "-Select -Focus")                             ; 取消列表中所有项目的选择与焦点
    Loop Link_LV.GetCount() {                                       ; 在列表中开始搜索
        If (InStr(Link_LV.GetText(A_Index), Link_Search.Value)) {   ; 若找到关键词项目
            Sleep(300)                                              ; 添加延迟来更直观了解搜索多个项目时的位置
            Link_LV.Modify(A_Index, "+Select +Focus +Vis")          ; 则列表中的关键词项目被选择并设为焦点
            Link_Focus(Link_LV, A_Index)                            ; 并刷新显示图标
        }
    }
    Link_LV.Opt("-Multi")                                           ; 搜索结束后禁止多行选择
    Sleep(100)                                                      ; 给予足够的响应时间
    If (ControlGetClassNN(ControlGetFocus("A")) = "Edit1") {        ; 若搜素后项目任然是搜索框，则提示"未找到"，并于1秒后关闭
        ToolTip("未找到(Not Found)", 200, 80)
        SetTimer () => ToolTip(), -2000
    }
}


; Edit为(非)焦点时，若未输入任何内容则清空(添加)提示词“搜素...”(?:等同于If、Else)
Link_Search_Focus(*) {
    Link_Search.Value := Link_Search.Value="搜索(Search)......"? "":Link_Search.Value
}
Link_Search_LoseFocus(*) {
    Link_Search.Value := Link_Search.Value=""? "搜索(Search)......":Link_Search.Value
}


; 在ICO区域显示焦点项目的图标
Link_Focus(Link_LV, Item) {
    ; 避免在Edit为焦点时点击列表而列表为非焦点状态
    Link_LV.Focus()
    ; 获取焦点项目的图标
    Focus_size := A_PtrSize + 688
    Focus_info := Buffer(Focus_size := A_PtrSize + 688)
    DllCall("shell32\SHGetFileInfoW"
        , "WStr", Link_LV.GetText(Item, 5)  ; 指定文件路径
        , "UInt", 0
        , "Ptr", Focus_info                 ; 接收指定类型信息
        , "UInt", Focus_size                ; 存储大小
        , "UInt", 0x100)                    ; 返回指定类型信息
    Focus_Hicon := NumGet(Focus_info, 0, "Ptr")
    ; 添加/刷新/更换ICON显示区域的图片
    Show_Icon_Area.Value := "HICON:" Focus_Hicon
}


; 更换图标设置
Link_Change(Link_LV, Item) {
    ; 获取lnk属性
    Change_Item_Attrib := ComObject("WScript.Shell").CreateShortcut(Link_LV.GetText(Item, 5))
    ; 在使用主窗口之前，必须先关闭下面的文件选择框.
    MyGui.Opt("+OwnDialogs")
    ; 选择ICO图标
    Link_Icon_Select := FileSelect(3, , "更换" . Link_LV.GetText(Item, 1) . "的图标", "Icon files(*.ico)")
    ; 若选择了图标，则更换快捷方式图标、保存修改、清空Icon_Select变量
    If (Link_Icon_Select = "")
        Return
    Change_Item_Attrib.IconLocation := Link_Icon_Select
    Change_Item_Attrib.Save()
    ; 调用焦点函数，刷新图标
    Link_Focus(Link_LV, Item)
}


; 右键打开菜单设置
Link_ContextMenu(Link_LV, Item, IsRightClick, X, Y) {
    ; 避免多行选择呼出菜单时的不适
    Link_LV.Modify(0, "-Select -Focus")
    Link_LV.Modify(Item, "+Select +Focus")
    ; 创建菜单
    Link_Menu := Menu()
    ; 添加菜单选项及功能
    Link_Menu.Add("运行当前文件(Run)", (*) => Run(Link_LV.GetText(Item, 5)))
    Link_Menu.Add ;————————————————————————————————————————
    Link_Menu.Add("更改文件图标(Change)", (*) => Run(Link_Change(Link_LV, Item)))
    Link_Menu.Add ;————————————————————————————————————————
    Link_Menu.Add("恢复默认图标(Default)", Link_Default)
    Link_Menu.Add ;————————————————————————————————————————
    Link_Menu.Add("打开目标目录(TargetDir)", (*) => Run(Link_LV.GetText(Item, 4)))
    Link_Menu.Add ;————————————————————————————————————————
    Link_Menu.Add("重新命名文件(Rename)", Link_Rename)

    ; 在菜单第一选项添加文件图标，点击可运行该文件
    fisize := A_PtrSize + 688
    fileinfo := Buffer(fisize := A_PtrSize + 688)
    if DllCall("shell32\SHGetFileInfoW"
        , "WStr", Link_LV.GetText(Item, 5)  ; 指定lnk路径
        , "UInt", 0
        , "Ptr", fileinfo                   ; 接受指定类型信息
        , "UInt", fisize                    ; 大小
        , "UInt", 0x100)                    ; 返回指定类型信息
    {
        hicon := NumGet(fileinfo, 0, "Ptr")
        Link_Menu.SetIcon("运行当前文件(Run)", "HICON:" hicon)
        DllCall("DestroyIcon", "Ptr", fileinfo)
    }

    ; 调用后面的Base64转PNG函数，在菜单栏第二~五项添加对应图标
    Link_Menu.SetIcon("更改文件图标(Change)", "HICON:" Base64PNG_to_HICON(Change_Base64PNG))
    Link_Menu.SetIcon("恢复默认图标(Default)", "HICON:" Base64PNG_to_HICON(Default_Base64PNG))
    Link_Menu.SetIcon("打开目标目录(TargetDir)", "HICON:" Base64PNG_to_HICON(Folders_Base64PNG))
    Link_Menu.SetIcon("重新命名文件(Rename)", "HICON:" Base64PNG_to_HICON(Rename_Base64PNG))
    
    ; 若为UWP应用或WSA_app，则不支持恢复默认图标和打开目标目录
    If ((Link_LV.GetText(Item, 3) = "————————————————————————————") or
        InStr(Link_LV.GetText(Item, 3), "Local\Microsoft\WindowsApps")) {
        Link_Menu.Disable("恢复默认图标(Default)")
        Link_Menu.Disable("打开目标目录(TargetDir)")
    }

    Link_LV.Focus()     ; 避免首次进应用程序右键呼出菜单列表不是焦点
    Link_Menu.Show()    ; 在鼠标位置展示菜单

    ; 恢复快捷方式的默认图标（将目标目录的图标粘贴到快捷方式图标上）
    Link_Default(*) {
        Default_Item_Attrib := ComObject("WScript.Shell").CreateShortcut(Link_LV.GetText(Item, 5))
        Default_Item_Attrib.IconLocation := Link_LV.GetText(Item, 3)
        Default_Item_Attrib.Save()
        ; 调用焦点函数，刷新图标
        Link_Focus(Link_LV, Item)
    }

    ; 重命名快捷方式名称
    Link_Rename(*) {
        ; 创建重命名输入框
        IB := InputBox("请输入新的文件名(不包含.lnk):"
            , "重命名" . Link_LV.GetText(Item, 1)
            , "W300 H100"
            , Link_LV.GetText(Item, 1))
        if IB.Result="CANCEL" 
            Return
        Link_Rename_Path := Link_LV.GetText(Item, 6) . "\" . IB.Value . ".lnk"
        ; 重命名
        FileMove(Link_LV.GetText(Item, 5), Link_Rename_Path)
        ; 刷新重命名所在行的lnk名称、lnk路径
        Link_LV.Modify(Item,, IB.Value,,,, Link_Rename_Path)
    }
}


; ListView和第二列的大小随窗口大小改变而改变
MyGui_Size(thisGui, MinMax, Width, Height) { 
    if MinMax = -1 
        Return
    Link_Search.Move(,, Width - 80)
    Top_Backgroud_Area.Move(,, Width - 68)
    Link_LV.Move(,, Width - 12, Height - 80)
    Link_LV.ModifyCol(3, Width - 228)
} 


; Base64转PNG函数
Base64PNG_to_HICON(Base64PNG, height := 24) {
    size := StrLen( RTrim(Base64PNG, '=') )*3//4
    if DllCall('Crypt32\CryptStringToBinary'
        , 'Str', Base64PNG
        , 'UInt', StrLen(Base64PNG)
        , 'UInt', 1
        , 'Ptr', buf := Buffer(size)
        , 'UIntP', &size
        , 'Ptr', 0
        , 'Ptr', 0)
    return DllCall('CreateIconFromResourceEx'
        , 'Ptr', buf
        , 'UInt', size
        , 'UInt', true
        , 'UInt', 0x30000
        , 'Int', height
        , 'Int', height
        , 'UInt', 0)
    return 0
}


; PNG的Base64字符
Change_Base64PNG := ' 
(
    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
    2A1dCAAAAAElFTkSuQmCC
)'

Default_Base64PNG := ' 
(
    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
)'

Folders_Base64PNG := '
(
    iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAB5ElEQVRIS
    +2UMW8TQRCFv5XOEYYooQK7AFGloUpDAQ0UlMDv4CcgSv4Jok8HFE5kJBp6CgokiJCQTAOCYAx3N4/idu7GZ4
    NMR5GRVjs79+a9md3TwKltYgePzh/Y0Uj14cjqw7GqyVjlZGxvn1x8d/f6mXt9/L9YArCjkcwQKSUJUEI0++c
    T+3Lt/qf941n9PiZuagmgmowbXiUkBFkIaPaEKUH+ZpJQShJSQ5G8KCkBiZevF9M7Dz/eSgDz52P9LKG2TJhJ
    lQq2dq5w7tJtiu3LoBqsbHYqsArox0pQSXkyY2v/cSoAir0HDHf3MqhuElXn9QOqb/BrBrIO474McL87D4Y7A
    BQAg+EuLI4DwAncj0QuEvcQb2NVJ4DNwQLYBbAQj2QhttJBxLcC+UqWkmJyJAix2J3qNWcXUH6slihWFcSW/F
    yQReK8VjpQuUqwkWDVYah717kkEIGBqE/sia2wn6NwWK2A/89O6kLt/fcqbUkiafC9k1ZAVSZz5SC0trKAjRh
    /j9U3WPcXWa+zHvmSSO5w5R3+JuCJ3o130b+ipVgsJAiUXz8w2L4QEqOY++Ed/oSx7qoX87ITePb0xfTG1bM3
    BWFKklBqJisg0U7Kxs9TF4+DDClP4ldvvk85tf/CfgOFKUnEl05T0gAAAABJRU5ErkJggg==
)' 

Rename_Base64PNG := '
(
    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
)' 