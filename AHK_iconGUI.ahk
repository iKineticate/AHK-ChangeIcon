Create_iconGUI(*)
{
    ; 创建 iconGUI 窗口.
    global iconGUI := Gui(" -Resize -caption +DPIScale +Owner" MyGui.hwnd)
    iconGUI.SetFont("cffffff","Microsoft YaHei UI")
    iconGUI.BackColor := "000000"
    iconGUI.active_control := False
    ; 创建按钮
    iconGUI.AddButton("vTestButton1 x0 y0" " w" 250/2 " h" 78/2, TEXT.SYSTEM_ICONS_TITLE).OnEvent("click", iconGUI_Menu)
    iconGUI.AddButton("vTestButton2 x" 250/2 " y0 w" 250/2 " h" 78/2, TEXT.USERS_ICONS_TITLE).OnEvent("click", Add_Users_Icons)
    iconGUI["TestButton1"].Setfont("s10 cffffff")
    iconGUI["TestButton2"].Setfont("s10 cffffff")
    WinSetTransparent(80, iconGUI["TestButton1"].hwnd)
    WinSetTransparent(80, iconGUI["TestButton2"].hwnd)
    ; 大图标列表
    iconLV := iconGUI.Add("ListView", "viconLV x0 y" 78/2 " h" 572/2 " w" 500/2 " Background252525 -Multi -E0x200 +icon +LV0x10000", ["Icon", "Path"])  ; 创建 ListView.
    iconLV.SetFont("cf5f5f5 s12")
    iconLV.OnEvent("DoubleClick", iconLV_DoubleCick)
    ; 添加图标
    Add_Icon_dll_GUI("shell32.dll", "dll")
    ; 深色模式
    DllCall("uxtheme\SetWindowTheme", "Ptr", iconLV.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
    ; 设置圆角
    FrameShadow(iconGUI.hwnd)
    ; 获取MyGui的大小位置
    MyGui.GetPos(&X, &Y, &Width, &Height)
    ; 显示窗口
    iconGUI.Show("x" (x+Width+10)*(A_ScreenDPI/96) " y" y*(A_ScreenDPI/96) " h" Height " w" 500/2 " NA")
    ; 重绘按钮
    WinRedraw(iconGUI["TestButton1"].hwnd)
    WinRedraw(iconGUI["TestButton2"].hwnd)
    ; 设置鼠标在其上方的按钮
    icursor := "C:\Windows\Cursors\aero_link.cur"
    DllCall("SetClassLongPtr", "ptr", iconGUI["TestButton1"].hwnd, "int", GCLP_HCURSOR := -12, "ptr", LoadPicture(icursor,"w" 28*(A_ScreenDPI/96) " h" 28*(A_ScreenDPI/96), &IMAGE_CURSOR := 2))

    iconGUI_Menu(*)
    {
        iconsMenu := Menu()
        iconsMenu.Add("shell32.dll",  (*) => Add_Icon_dll_GUI("shell32.dll", "dll"))
        iconsMenu.Add("imageres.dll", (*) => Add_Icon_dll_GUI("imageres.dll", "dll"))
        iconsMenu.Add("mmres.dll",    (*) => Add_Icon_dll_GUI("mmres.dll", "dll"))
        iconsMenu.Add("ddores.dll",   (*) => Add_Icon_dll_GUI("ddores.dll", "dll"))
        iconsMenu.Add("explorer.exe", (*) => Add_Icon_dll_GUI("explorer.exe", "dll"))
        iconsMenu.Add("imagesp1.dll", (*) => Add_Icon_dll_GUI("imagesp1.dll", "dll"))
        iconsMenu.Add("pifmgr.dll",   (*) => Add_Icon_dll_GUI("pifmgr.dll", "dll"))
        iconsMenu.Add("networkexplorer.dll", (*) => Add_Icon_dll_GUI("networkexplorer.dll",""))
        iconsMenu.Show(0, 39*(A_ScreenDPI/96))
    }

    Add_Users_Icons(*)
    {
        ; 访问ini，打开上一次打开的存放ICO的文件夹，并更新ini里的上一次打开的图标文件夹路径
        Try
        {
            last_selected_folder_path := iniRead(info_ini_path, "info", "last_icons_folder_path") 
        }
        Catch
        {
            Msgbox("the info.ini does not have an option named `"last_icons_folder_path`" ",,"icon!")
        }
        If not (selected_folder_path := DirSelect("*" . last_selected_folder_path, 0, Text.SELECT_ICONS_FOLDER))
            Return
        Add_Icon_dll_GUI(selected_folder_path, "")
    }

    Add_Icon_dll_GUI(path, Is_dll_Icons)
    {
        global default_dll := path
        iconLV.Opt("-Redraw")
        iconLV.Delete()
        If !Is_dll_Icons
        {
            global is_users_icons := False
            icon_list_ID := IL_Create(,,"true")
            iconLV.SetImageList(icon_list_ID)
            Loop Files, path "\*.ico"
            {
                hIcon := DllCall_Get_Icon(A_LoopFilePath)
                icon_number := DllCall("ImageList_ReplaceIcon", "Ptr", icon_list_ID, "Int", -1, "Ptr", hIcon) + 1
                DllCall("DestroyIcon", "ptr", hIcon)
                iconLV.Add("Icon" . icon_number, A_Index, A_LoopFilePath)
            }
        }
        Else
        {
            global is_users_icons := True
            icon_list_ID := IL_Create(,,"true")
            iconLV.SetImageList(icon_list_ID)
            Loop  ; 把 DLL 中的一系列图标装入图像列表.
            {
                If !IL_Add(icon_list_ID, path, A_Index)
                    Break
                iconLV.Add("Icon" . A_Index+1, A_Index)
            }
        }
        iconLV.Opt("+Redraw")
    }

    iconLV_DoubleCick(*)
    {
        If !LV.GetNext() 
        or !iconLV.GetNext() 
        or Tab.Value != "1"
            Return
        ; 获取快捷方式数据
        link_name := LV.GetText(LV.GetNext())
        link_ext  := LV.GetText(LV.GetNext(), "3")
        key       := link_name . link_ext
        link_path := link_map[key].LP
        ; 更换图标
        COM_Link_Attribute(&Link_Path, &Link_Attribute, &Link_Icon_Location)
        (!is_users_icons) ? (Link_Attribute.IconLocation := iconLV.GetText(iconLV.GetNext(), 2)) : (Link_Attribute.IconLocation := default_dll . "," . iconLV.GetNext())
        Link_Attribute.Save()
        ; 更新显示的数据
        If !LV.GetText(LV.GetNext(), 2)
        {
            MyGui["Changed_Count"].Value += 1
            MyGui["Unchanged_Count"].Value -= 1
        }
        ; 刷新顶部和列表图标，并目标行添加"√"
        Refresh_Display_Icon(LV, LV.GetNext())
        Refresh_LV_Icon(LV, LV.GetNext())
        LV.Modify(LV.GetNext(),,,"√")
        ; 添加日志
        icon_from := (!is_users_icons) ? (iconLV.GetText(iconLV.GetNext(), 2)) : default_dll . "," . iconLV.GetNext()
        MyGui["Log"].Value .= FormatTime(A_Now, "`syyyy/MM/dd HH:mm:ss`n`s")    
        . Text.LOG_CHANGED_LINK . link_name . "`n`s" 
        . Text.Source_OF_ICON . icon_from . "`n`n===========================================`n`n"
    }
}

