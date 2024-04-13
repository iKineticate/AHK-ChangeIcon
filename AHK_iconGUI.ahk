ShowIconGUI(*) {
    ; 获取mainGUI的大小位置
    mainGUI.GetPos(&X, &Y, &Width, &Height)

    ; 创建 iconGUI 窗口.
    global iconGUI := Gui(" -Resize -caption +DPIScale +Owner" mainGUI.hwnd)
    iconGUI.Morden := ModernGUI( {GUI:iconGUI, x:x+(Width+10)*(A_ScreenDPI/96), y:y, w:500/2, h:Height, backColor:"000000", GuiOpt:" -Resize -caption +DPIScale +Owner" mainGUI.hwnd, GuiName:"", GuiFontOpt:"cffffff s10", GuiFont:"Microsoft YaHei UI", showOpt:"NA"} )
    iconGUI.activeControl := False

    ; 创建按钮
    iconGUI.Button := CreateButton(iconGUI)
    iconGUI.Button.Text( {name:"iconGUIBtn1", x:0    , y:0, w:250/2, h:60/2, R:0, normalColor:"2B2B2B", activeColor:"555555", text:TEXT.SYSTEM_ICONS_TITLE, textOpt:"+0x200 center", textHorizontalMargin:0, fontOpt:"cffffff", font:""} )
    iconGUI.Button.Text( {name:"iconGUIBtn2", x:250/2, y:0, w:250/2, h:60/2, R:0, normalColor:"2B2B2B", activeColor:"555555", text:TEXT.USERS_ICONS_TITLE , textOpt:"+0x200 center", textHorizontalMargin:0, fontOpt:"cffffff", font:""} )
    iconGUI.Button.OnEvent('iconGUIBtn1', 'Click', (*) => ShowMenuForIconGUI())
    iconGUI.Button.OnEvent('iconGUIBtn2', 'Click', (*) => AddUsersIconsToIconGUI())

    ; 大图标列表
    global iconLV := iconGUI.Add("ListView", "viconLV x0 y" 60/2 " h" 550/2 " w" 500/2 " Background202020 -Multi -E0x200 +icon +LV0x10000", ["Icon", "Path"])
    iconLV.SetFont("cf5f5f5 s12")
    iconLV.OnEvent("DoubleClick", DoubleClickIconLV)
    iconLV.OnEvent('ItemFocus'  , RefreshStatusBar)
    iconLV.OnEvent('ContextMenu', ShowMenuForIconLV)

    ; 底部状态栏
    iconGUI.AddText('vstatusBar x0 y' 610/2 ' w' 560/2 ' h' 40/2 ' Background171717 +0x200', '     Name: #1')
    iconGUI['statusBar'].SetFont('s8')

    ; 添加图标
    If laseSelectedFolderPath := iniRead(iniPath, "info", "lastSelectedIconFolderPath") {
        AddIconsToIconLV(laseSelectedFolderPath, IsAddDllIcons := False)
    } Else {
        AddIconsToIconLV("shell32.dll", IsAddDllIcons := True)
    }

    ControlClick(mainGUI[StrReplace(tabProp.labelName[1], "`s") . "_TAB_BUTTON"])
    ; 深色模式
    DllCall("uxtheme\SetWindowTheme", "Ptr", iconLV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
    ; 显示窗口
    iconGUI.Morden.Show()
  
    ;========================================================================================================
    ; 函数
    ;========================================================================================================
    DoubleClickIconLV(LV, Item, *) {
        If !mainGUI['LV'].GetNext()
        or !iconLV.GetNext() 
        or Tab.Value != "1"
            Return
        ; 获取mainGUI的LV快捷方式数据
        linkName := mainGUI['LV'].GetText(mainGUI['LV'].GetNext(), 1)
        linkExt  := mainGUI['LV'].GetText(mainGUI['LV'].GetNext(), 3)
        linkID   := linkName . linkExt
        linkPath := MapLinkProp[linkID].LP
        ; 更换图标
        ManageLinkProp(&objLink, &linkPath, &linkIconLocation)
        objLink.IconLocation := IsUsersIcons ? iconLV.GetText(Item, 2) : defaultDllName . "," . (Item-1)
        objLink.Save()
        ; 更新显示的数据
        If !mainGUI['LV'].GetText(mainGUI['LV'].GetNext(), 2) {
            mainGUI["countOfChanged"].Value   += 1
            mainGUI["countOfUnchanged"].Value -= 1
        }
        ; 刷新顶部和列表图标，并目标行添加"√"
        RefreshIconDisplay(mainGUI['LV'], mainGUI['LV'].GetNext(), IsRefreshListIcon := True)
        mainGUI['LV'].Modify(mainGUI['LV'].GetNext(),,,"√")
        RefreshExplorer()
        ; 添加日志
        iconFrom := (IsUsersIcons) ? (iconLV.GetText(Item, 2)) : defaultDllName "," Item
        mainGUI["log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")    
            . Text.LOG_CHANGED_LINK . linkName . "`n`s" 
            . Text.Source_OF_ICON . iconFrom . "`n`n===========================================`n`n"
    }

    RefreshStatusBar(LV, Item, *) {
        iconName := (IsUsersIcons) ? RegExReplace(iconLV.GetText(Item, '2'), '^.*\\') : iconLV.GetText(Item, '2')
        iconGUI['statusBar'].Text := '     Name: ' iconName
    }
    
    ShowMenuForIconLV(LV, Item, *) {  ; 展示列表的右键菜单
        If IsUsersIcons or item<1
            Return

        iconLVMenu := Menu()
        iconLVMenu.Add(TEXT.EXTRACT_ICON, ExtractDllIcon)
        iconLVMenu.SetIcon(TEXT.EXTRACT_ICON, "HICON:" Base64PNGToHICON(Base64.PNG.MENU_EXTRACT))
        iconLVMenu.Show()

        ExtractDllIcon(*) {
            index := Instr(defaultDllName, '.exe') ? Item : iconLV.GetText(Item, '2')
            iconName := defaultDllName '(' index ',' item ')'

            ConvertToIconFile.Dll( {dllName:defaultDllName, index:index, size:0, iconName:iconName} )

            mainGUI["log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")
                . TEXT.EXTRACTED . iconName . "`n`n===========================================`n`n"

            TrayTip(TEXT.EXTRACTED . iconName , "Ciallo～(∠・ω< )⌒★", "Mute"), SetTimer(TrayTip, -5000)
        }
    }
}

AddIconsToIconLV(path, IsAddDllIcons := False) {
    mainGUI.Opt("+Disabled")
    iconGUI.Opt("+Disabled")
    global defaultDllName := path
    iconLV.Opt("-Redraw")
    iconLV.Delete()
    If !IsAddDllIcons {     ; Users的图标文件
        global IsUsersIcons := True
        IL_ID := IL_Create(,,"true")
        iconLV.SetImageList(IL_ID)
        Loop Files, path "\*.ico" {
            hIcon      := GetFileHICON(A_LoopFilePath)
            iconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", IL_ID, "Int", -1, "Ptr", hIcon) + 1, DllCall("DestroyIcon", "ptr", hIcon)
            iconLV.Add("Icon" . iconNumber, A_Index, A_LoopFilePath)
        }
    } Else {    ; Dll图标文件
        global IsUsersIcons := False
        ListIcons.AddIconsToList(iconLV, path)
    }
    iconLV.Opt("+Redraw")
    mainGUI.Opt("-Disabled")
    iconGUI.Opt("-Disabled")
}

ShowMenuForIconGUI(*) {  ; 展示系统图标的菜单
    iconsMenu := Menu()
    ArraySystemIcons := ['shell32.dll', 'imageres.dll', 'ddores.dll', 'mmres.dll', 'wmploc.dll', 'dmdskres.dll', 'setupapi.dll', 'explorer.exe', 'imagesp1.dll', 'pifmgr.dll', 'networkexplorer.dll']
    
    For value in ArraySystemIcons {
        iconsMenu.Add(value, (Item, *) => AddIconsToIconLV(Item, IsAddDllIcons := True))
    }

    iconsMenu.Show(30*(A_ScreenDPI/96), 30*(A_ScreenDPI/96))
}

AddUsersIconsToIconGUI(*) {    ; 访问ini，打开上一次打开的存放ICO的文件夹，并更新ini里的上一次打开的图标文件夹路径
    iconGUI.Opt("+OwnDialogs")
    Try {
        laseSelectedFolderPath := iniRead(iniPath, "info", "lastSelectedIconFolderPath")
    }
    Catch {
        Msgbox("the info.ini does not have an option named `"lastSelectedIconFolderPath`" ",,"icon!")
    }
    If not (selectedFolderPath := DirSelect("*" . laseSelectedFolderPath, 0, Text.SELECT_ICONS_FOLDER))
        Return
    AddIconsToIconLV(selectedFolderPath)
}