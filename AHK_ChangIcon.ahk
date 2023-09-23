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

; 创建名为Change_Icon_Gui的窗口并允许重绘窗口大小,添加窗口标题
Change_Icon_Gui := Gui("+Resize", "更改文件图标(Change Icon)————by Leen_Joan(Github)")
; 窗口背景颜色为黑色
Change_Icon_Gui.BackColor := "343434"
; 窗口内的字体为12号大小、加粗、橙色
Change_Icon_Gui.SetFont("s12 Bold cd47a38", "Microsoft YaHei")
; 创建窗口关闭事件
Change_Icon_Gui.OnEvent("Close", (*) => ExitApp())
; 创建窗口大小改变事件
Change_Icon_Gui.OnEvent("Size", Change_Icon_Gui_Size)


; 创建黑色背景列表，添加5个名为“Name、TargetPath、TargetDir、Path、Dir”的标题，后三项不显示，设置“关闭重绘”来加快列表的加载速度
Link_LV := Change_Icon_Gui.AddListView("x6 y6 r15 w700 -Redraw -E0X200 Background1f1f1f"
        , ["Name", "TargetPath", "TargetDir", "Path", "Dir"])
; 创建列表单击事件
Link_LV.OnEvent("Click", Link_Clink)
; 创建列表双击事件
Link_LV.OnEvent("DoubleClick", Link_DC)
; 创建列表右键菜单
Link_LV.OnEvent("ContextMenu", Link_LV_Menu)


; 创建一个名为pathArr的数组，其内包含两个路径（当前用户和所有用户桌面路径）
pathArr := [A_Desktop, A_DesktopCommon]
; 初始化Desktop
Desktop := ""
; 从数组中枚举数组所有的对象至Desktop
For Desktop in pathArr
; 从循环到的对象中查找快捷方式（pathArr[A_Index]:循环到的对象）
Loop Files, Desktop "\*.lnk" {
    ; Link_Name存储去掉.lnk的快捷方式名称
    Link_Name := StrReplace(A_LoopFileName, ".lnk")
    ; 获取快捷方式的目录
    SplitPath(A_LoopFilePath, , &Link_Dir)
    ; 获取快捷方式的属性
    Link_Attrib := ComObject("WScript.Shell").CreateShortcut(A_LoopFilePath)
    ; 将快捷方式的名称、目标路径、目标目录、lnk路径、lnk目录添加至列表中
    Link_LV.Add(
        , Link_Name
        , Link_Attrib.TargetPath
        , Link_Attrib.WorkingDirectory
        , A_LoopFilePath
        , Link_Dir)
}

Link_LV.Opt("+Redraw")              ; 允许列表重绘大小
Link_LV.ModifyCol(1, "160 +Sort")   ; 第一列宽度限制为160，并将两次Loop Files结果重新排序
Link_LV.ModifyCol(2, 520)           ; 第二列宽度限制为500
Link_LV.ModifyCol(3, 0)             ; 隐藏第三列
Link_LV.ModifyCol(4, 0)             ; 隐藏第四列
Link_LV.ModifyCol(5, 0)             ; 隐藏第五列


; 底部添加图标（调用Base64PNG_to_HICON）
Bottom_Base64PNG := '
(
    iVBORw0KGgoAAAANSUhEUgAAABkAAAACCAYAAACt+Hc7AAAAFElEQVQI12OUl5f/z0BjwMRABwAAEE8BYEdKF/AAAAAASUVORK5CYII=
)'
Bottom_Picture := Change_Icon_Gui.AddPicture("x6 w700 h56", "HICON:" Base64PNG_to_HICON(Bottom_Base64PNG))
; 创建ICO显示区域
Show_Icon := Change_Icon_Gui.AddPicture("x6 w56 h56 ")

Change_Icon_Gui.Show()



; 窗口标题栏暗黑模式
DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Change_Icon_Gui.Hwnd, "int", 20, "int*", true, "int", 4)

; 菜单栏深色模式
Class darkMode {   
    Static __New(Mode := 1) => (  
        DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 135, "ptr"), "int", 2),
        DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 136, "ptr"))
    )
}


; 单击在对应位置显示图标
Link_Clink(Link_LV, Item) {
    Click_fileinfo := Buffer(Click_fisize := A_PtrSize + 688)
    if DllCall("shell32\SHGetFileInfoW"
        , "WStr", Link_LV.GetText(Item, 4)
        , "UInt", 0
        , "Ptr", Click_fileinfo
        , "UInt", Click_fisize
        , "UInt", 0x100)
    {
        Click_Hicon := NumGet(Click_fileinfo, 0, "Ptr")
        Show_Icon.Value := "HICON:" Click_Hicon
        DllCall("DestroyIcon", "Ptr", Click_fileinfo)
    }
}

; 双击更换图标设置
Link_DC(Link_LV, Item) {
    ; 获取双击行的lnk属性
    Link_DC_Attrib := ComObject("WScript.Shell").CreateShortcut(Link_LV.GetText(Item, 4))
    ; 选择ICO图标
    Link_Icon_Select := FileSelect(3, , "更换" . Link_LV.GetText(Item, 1) . "的图标", "Icon files(*.ico)")
    ; 若选择了图标，则更换快捷方式图标、保存修改、清空Icon_Select变量
    If (Link_Icon_Select = "")
        Return
    Link_DC_Attrib.IconLocation := Link_Icon_Select
    Link_DC_Attrib.Save()
    Link_Icon_Select := ""
    ; 刷新图标
    Link_Clink(Link_LV, Item)
}

; 右键打开菜单设置
Link_LV_Menu(Link_LV, Item, IsRightClick, X, Y) {
    ; 显示图标
    Link_Clink(Link_LV, Item)
    ; 创建菜单
    Link_ContextMenu := Menu()
    ; 添加菜单选项及功能
    Link_ContextMenu.Add("运行当前文件(Run)", (*) => Run(Link_LV.GetText(Item, 2)))
    Link_ContextMenu.Add ;————————————————————————————————————————
    Link_ContextMenu.Add("更改文件图标(Change)",Link_Change)
    Link_ContextMenu.Add ;————————————————————————————————————————
    Link_ContextMenu.Add("恢复默认图标(Default)", Link_Default)
    Link_ContextMenu.Add ;————————————————————————————————————————
    Link_ContextMenu.Add("打开目标目录(TargetDir)", (*) => Run(Link_LV.GetText(Item, 3)))
    Link_ContextMenu.Add ;————————————————————————————————————————
    Link_ContextMenu.Add("重新命名文件(Rename)", Link_Rename)

    ; 在菜单第一选项添加文件图标，点击可运行该文件
    fileinfo := Buffer(fisize := A_PtrSize + 688)
    if DllCall("shell32\SHGetFileInfoW"
        , "WStr", Link_LV.GetText(Item, 4)
        , "UInt", 0
        , "Ptr", fileinfo
        , "UInt", fisize
        , "UInt", 0x100)
    {
        hicon := NumGet(fileinfo, 0, "Ptr")
        Link_ContextMenu.SetIcon("运行当前文件(Run)", "HICON:" hicon)
    }

    ; 在菜单栏第二~五项添加对应图标
    Link_ContextMenu.SetIcon("更改文件图标(Change)", "HICON:" Base64PNG_to_HICON(Change_Base64PNG))
    Link_ContextMenu.SetIcon("恢复默认图标(Default)", "HICON:" Base64PNG_to_HICON(Default_Base64PNG))
    Link_ContextMenu.SetIcon("打开目标目录(TargetDir)", "HICON:" Base64PNG_to_HICON(Folders_Base64PNG))
    Link_ContextMenu.SetIcon("重新命名文件(Rename)", "HICON:" Base64PNG_to_HICON(Rename_Base64PNG))

    ; 在鼠标位置展示菜单
    Link_ContextMenu.Show(X, Y)

    ; 更改它的图标
    Link_Change(*) {
        ; 调用前面的函数
        Link_DC(Link_LV, Item)
    }

    ; 恢复快捷方式的默认图标（将目标目录的图标粘贴到快捷方式图标上）
    Link_Default(*) {
        Link_ContextMenu_Attrib := ComObject("WScript.Shell").CreateShortcut(Link_LV.GetText(Item, 4))
        Link_ContextMenu_Attrib.IconLocation := Link_LV.GetText(Item, 2)
        Link_ContextMenu_Attrib.Save()
        ; 刷新图标
        Link_Clink(Link_LV, Item)
    }

    ; 重命名快捷方式名称
    Link_Rename(*) {
        IB := InputBox("请输入新的文件名(不包含.lnk):"
            , "重命名" . Link_LV.GetText(Item, 1)
            , "W300 H100", Link_LV.GetText(Item, 1))
        if IB.Result="CANCEL" 
            Return
        Link_Rename_Name := Link_LV.GetText(Item, 5) . "\" . IB.Value . ".lnk"
        ; 重命名
        FileMove(Link_LV.GetText(Item, 4), Link_Rename_Name)
        ; 刷新显示(修改)命名行所在的lnk名称、lnk路径
        Link_LV.Modify(Item,, IB.Value,,, Link_Rename_Name)
        
    }
}

; ListView和第二列的大小随窗口大小改变而改变
Change_Icon_Gui_Size(thisGui, MinMax, Width, Height) { 
    if MinMax = -1 
    return
    Link_LV.Move(, , Width - 12, Height - 74)
    Link_LV.ModifyCol(2, Width - 190)
    ; y = 6+(h-74)+6 = h-62
    Show_Icon.Move(,Height - 62)
    Bottom_Picture.Move(,Height - 62,Width - 12)
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
    iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAYAAACohjseAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAOxElEQVRoQ9Wabcye5VnHf8fdu3369OVpH
    dBC6UM7CoWy2nYMPpg5R406hWoZC2+LrqV8MMZEglEXwz4wNYtmcwQ3l5gNWpgsy8zGJtNM4uRFl+hgAgNBJsGmLxMTpe1KaEvb6++H/3Gc13
    U/bAw/cvTpc13XeR7ncfz/x3GcL9f93EFKLJpZvuTnbr5lZvutt2eTgKh+SYqI9tz6VZdOQYSk0rcGsoo7PD7bkfskKSBUOkIEoa4TEKcOPPf
    ksUfvvfP4Y1/dw/9TAmDemavXrvi9Lz00OmP12h9ChIhAEgmA1j9JwE2vB2siTXGyL00SHmve1SFCQhGEJLqXD+49/JkdW7tD39/Lm5QAWPkn
    3/rP8Zmza+q5JMkS0WemiFS/AbX2JN6CEYgiXIEQQUas2h1UdTmGHJoZrCARcPrlg3sPf/ID79Txo4d5ExIrb//GE+PZS7aUk7kKTRxUgVr2j
    LC/RUpehDMyGKOyo2FAaKQ8MBp/O7S6ZHvY3skXH3vk6F/s2poW31DG49lLtgB92Q2kRTZRN1D1DJEkJkoMUIdqfoa6ZqfZKMKVXVqmkJM+Ya
    98RoiYv/ay97r1x8t4cC/sTKPRqIFzT9o2YYNq7QAKyVk0PoErTUyA7QEnkwnCzq2zXYSADFDZgGx/U9IISmI439TJtdKBiQpoKxtSi75dFq/
    Uywf3q7JptWTTiDv7JhVD8EWelt1s7jt+nCTBXr8cUvNG1ZhLKS5Lg1KBiEbOpoRU5J0R+jGeDjlWCTgyW9WWEchnKfsyKgwlfveJThJx4uhh
    DnznEd3/2++vvjGgQYZA0GUks+bck0QQIOXaQJ/Fiksr19S3elpQBIS6LlVNzm0SaSvST+fSDDSxsCnt9eL4BFNLl7Puiu2x9Xfu0EOfuBVMs
    AAmkL5M2mqekSugvUNVWIarYPMuiVLAGXWiZAfuV85nd2TAAJznNDeIVC6xc6VT4g0uveGWmFq8TN/46K6xOsFgGddgvuQzOJH9km6GoS4nVA
    Lqx9fAPiN9bMTszHw+9Uur2Lhimm/tf4Xb/v4l9h15jeZXQq6CyGiGY2Ef1FaVEnJFSKcVMXKQ3rHtpphZ9faxrRG+YCeF2v5anx11wiuq25I
    8guorcjXepRaBYHZmPg/vWMfM1AiAKy+Y4d2rF/Pe3f/B/sMn6ePV5nDCydQb2ATBCkzYNw5KhM68YPMYVYlm6ZfNipZEOqookmxam9U6Ggio
    pT2Qyy7t8Edbz27kSpYtnMefX7WaX7nvRduvACUgyWFLrJPkgPQJmKSERKeYWvoT4zbhSbsVjESehKvs+r4ko0puI5rzzCSzqR935YVLrThHN
    q6Yzrh1Da9kqKR93zaMTZKxg0GVtEGOAdRnSwboDLTxZpFjSzKz8qovmZx7DDJHZfZ8Jj1y4jTLpub1ZlKWLZxHl3tsA5jADLV+9cEsUdcR4Z
    niKEi1E40LZHZGGUyxVvblNfkS+T/blM59X3NuIAHimf8+xrvPWzLRAfC3zx9Jx+HTUNo2FvkngQ2i7OcB6KgfH1QYo2F/UCWbmax7B7CUJg7
    PttUCYAUv9ekUYSNS/ObXD/DIzRdOZPHIidP8/oMHraqOqH05yVWpY7t9Qko6Qc6LHGPHksZe6suYcSTYMCa3B9Tca/oOTLPVAAGoE3X46UFJ
    +w6diLd//GmjJTfzPimBC6QqIQ1HH1SJrqHKQbmYpSRoR2GciJEMKJSrZU+65mCREEW+SJdZiVzFACbmlJ8FLQK5vfjkk5LqiUeSvA1J6Seqf
    0K6Dmcl0lehixiXMV+zPBFBILpBKZbX9tzKpICYbyqkTSAkHxVJp8hgusGKCbSDRACIDJZP+1A4+3D04mxJXY12jUsat7dm6+X4LA/fpPHkPZ
    RUQTnnKBBubODVol5lHp06RXicPNjZwWWbxhKXc4g3+LD9gaTzPgpE+R9XO2p6flu183KgJOHB1i2jTpvnWJKqRcjPkhREeC2oahNdh+dDSR+
    cCE9DKP2BXsM1KblYavDuKPUlCr0RTUQMgweXjEov5jpXEo3IldUGAhHyiyVFPFdK4QBl8CtgtlVEMmWpI/zYS0iFhKCcS0GMch9s+nNfW/DV
    Jd11VesJDMhIBNLEcp59YevKyZlnWKE6DFjPwD3vVe3hjny009rObb9JLgBkMMKkAcbItSBhsHIKQvUao2jxyX6G0fQNEgTExpUL+dgvrGbjy
    mmWLZzHvsOvxbY932PfoeOBlOfTHnyRA/lfEbWvdJx69tLmexPv3SIymQ4JIPy6lCNsPBeMhl0yICDb00YbQ2bw+s1n8Olt57X4doJzZxbwtQ
    +t59e++IKeeenVsp2uZJtJqHx26rK0XUT2n75zpZ+QyLGJyTalIHIftApBA5z2BCLrJhcZd0c+N93rN53Bp7adZz92Vl2sXraAe25YF1fvfp7
    9h0/0PlLBr1lAb9MVJiAXLNvVsPp6yYbAW5AbI0DeBwHwiUZATXK3N4fuy+vgrOmS+rNt53F6juMGJODcmSm+suMi3r/7Oe0/fMKNOJXgCrBz
    hp+VmlSe5nP+kcybeA9Goqt1gywijedEsyJou327eZAA7Nhdkq7b9LY4rYLcS/JvRFfNTPHlnRvimt3PYZLKHwknB4fZ60COiy7Px3mqmXQCu
    CHCnbnVp+VxixYYSUbSjxIm7X2xk2QikUa57ifPiDu2raEVWY2tX2GzLhiT/KudG7h2z7Pse/n4cK41/wH+YKrn4tJMm8OcuLc4dEDYJo7WuA
    YGNpb8TKDPWs2J2kwBuHbT2/jkVWs4XfM+jRQQAoZrQgE7d9kUX9pxCdfu/rfYf+h4jvFAhzB9Jhr792DjeB3FgNzOPKSBH3edVyzB4EMlGhr
    J6tUmSR/YdEb86VVrQXAq+8rlhOdhm3odgLNnpnj0ty7lp+94nAOHTggfukUtKi0rtW/XSJHYe+lOtxdccOrIseNKGZW5OcQyHs3ZhhXTfPzK
    ta0k1VXPJIGhVHOD3KzBF27ayI13PxMHXj6miP5NxPrGMHgWPkX2jX0nUttXFDEKqZPPomY4uXq2gX3fhhWL+MIH18dwvgmnfw4Wt0e2i55YK
    pWbVTMLuW/XRrZ9+gmOHj/VOuXtCcP1L/chRc7ZlIpKlh4haomnnUWDAlN7TcLKNiD+8sb1LJmaN7GgKMc1AvheSuKlN2d/7pQBAM6ZWch9uz
    bFr971FEeOnbRC4sqHwm4sWXQlxusPZqqh9taxWdHGWJlsQ45GxMUrplk8Nc973QB4k2woTO3Duoq1+vuWjLQTwPqVi7nnpk186O6n+MGxUx7
    QB1lCuYy2baBJkomAqKhInSJGIx/VHH3BcLXK5VqwYeUi7rlhfQM0l+DwHqDeO0u3ZPAJZSOmuhdcdPYS9uzczI67n9QPnMmJaSMJL5RzPWbs
    +hMRQYyQNC7jrkwM3gZCwMUrptlzw3oWLxjTKQHZT58JX3wvGvK5OFS/KpPMsSFYf84Sdu/aEjs/94SOHj9pXw68R841Coxi0A9JwCC8ispzO
    KoPuOisae66/iJmpl3Fp3K1bObzbWdIFHxf2RuCr2wBbWwRRYM+YN3KJfzjbe+Jzbd9E0k+1iTJ8P1QHXVdLUKC3A9zlrc5CL3O+rOm+ez1F7
    FkKrOmIp+gKwOyyaEIegID6cCNFZBw41y96hJw+zWXcPtXnm1hSHKkSi9VfWnZMcHbRKvnInfmNJ+97mIWLxhzGvL0436liSI7nO05vOkMx1S
    WS2cYrACU/XOr4Ze3nIMEH73/WTBwhaVXAgJlhdYzIO9t41N7v/PwvPMuvaKGfGL7hSye8ktGy1COLRNtKg+vRSLvh59QBIMxQ9Egs2RR9Y9I
    cNWWcxDwB/c/SzHr/ueFJ1OlFNuahvnmpetMcPadVwhYtWyKs2emWllOeBtEeWIfzPvKyrCt2HU1f9W3Nb2BDzHnOa9XbjmHg4eO8bmHXlREx
    Omnvnyne0qUe0AE6nLH8zevxie//cU7F2y6aueq2TVrPnPtxZOnlAJU9wE67WsBbaR/xBaAeqBzr3ODEsHk4bz6BTdfcT4ScdfX/3lv9/yDe3
    otQOTekQtMiKrZsY4fPfzq539j621//dBDK5dOrW0vrQOU1dTuBzqCVo4tS3PErpMATNhs7YNxkl23YAfQwfvOH+297+8+vDXPOu5asHi5rdm
    o8Eks8Gc3MdB9S8rU1g/fP++8y7eTp023tmjF8ItAbzkZb9h2y2j2su3+dD4I+nLIp7duBt/xM1fveNcHP7L7gcf2xfHXTuX7oGCC01uwRKcW
    LV1+1pqLN1/7kd0PA3z/5Vf1wLf3hhfQ08p3xVaub0hw4a4HumjnvEq4mFk4n+t+ag1T80deEEa5fLTS70X9sGoBIcJnXb9SeanxKqo8momu6
    zSKkT+6ILeAGNmXTQngewcPxyNPH2yufHE633AOBv4qR0DaVCyZHmv75bMxNd/flDAon/vwGcnqeeqQZBi1XBq8JwjQ9XpkQQWqZT4m+j2gaw
    GooFx47jKAePi7+xNIRTS/hPCjRK+9coj5i5ZXZJZOL2D75bOxdHqcX7PynwpySc545q+IyD944uEV+Gwr/SA65RLYVSSI/G/VTk6WRIxG9hU
    OhE3BBauWISke/e5+CWkUMepOvHqoGflhMjp74xVTv/iH/0AQSxfO58b3nK8wHysUVjuXU5Swq7PHCTLQyGS7qb0hGGlEu9aHYM5miRMUOZYK
    ng0gwT0PPg2g44/ecc0bZrB76ZmHT73wzXuWb3zfjm2XzQKeN8Dry1IAYoA+K0VuBwpIrurZ1//FCRsEcDaTaIzyw6jAL9OCDhENT3biy+Z1K
    /T439x756kDj3/1DQkCnPynT9+0bnbRkSULd97S4mhuhaV9q0kOYdix7NdBhQF4SG44WyI/2M2pl3PO7DAp0p6Ey5OavyN/hzXbkJj6r3+598
    S/fv7W9PDm5Px3/ezVP//rH9u9YNHMcgwCSWbkugKCVq4tk9UHEJkF2bOAMlbi4aYfYfCjjE0bM5S+4/irrxz+333//uTX/vjmrdX7f38cz4E
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

