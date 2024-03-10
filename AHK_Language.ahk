; zh: LCID_7804 := "Chinese"（中文）
; zh-Hans: LCID_0004 := "Chinese (中文简体)"
; zh-Hant: LCID_7C04 := "Chinese (中文繁体)"
; zh-CN: LCID_0804 := "Chinese (中文简体-中国大陆)"
; zh-HK: LCID_0C04 := "Chinese (中文繁体-中国香港)"
; zh-MO: LCID_1404 := "Chinese (中文繁体-中国澳门)"
; zh-TW: LCID_0404 := "Chinese (中文繁体-中国台湾)"
; zh-SG: LCID_1004 := "Chinese (中文简体-新加坡)"
Switch A_Language
{
Case "0804": zh := True
Case "7804": zh := True
Case "0004": zh := True
Case "1004": zh := True
Case "7C04": zh := True
Case "0C04": zh := True
Case "1404": zh := True
Case "0404": zh := True
Default    : zh := False
}

; Note:     This a object, not an array， ":" (√), ":="（×）
; Format:   name_ZH and name_EN
Text :=
{
    ; Label Name
     HOME_ZH : "  主 页"
    ,HOME_EN : "     Home"

    ,OTHER_ZH : "  其 他"
    ,OTHER_EN : "    Other"

    ,LOG_ZH : "  日 志"
    ,LOG_EN : " Log"

    ,HELP_ZH : "  设 置"
    ,HELP_EN : "        Settings"

    ,ABOUT_ZH : "  关 于"
    ,ABOUT_EN : "     About"

    ;==========================================================================
    ; Tab: Home
    ;==========================================================================
    ; Count (计数) 
    ,CHANGED_ICON_ZH : "已更换:"
    ,CHANGED_ICON_EN : "Yes.C`s:"
    
    ,UNCHANGED_ICON_ZH : "未更换:"
    ,UNCHANGED_ICON_EN : "No.C :"

    ,LV_LINK_TOTAL_ZH : "总   共:"
    ,LV_LINK_TOTAL_EN : "Total :"

    ; Change/Restore （改变/恢复按钮的消息）
    ,IS_RESTORE_ALL_ICON_ZH : "是否恢复列表的所有快捷方式图标为默认图标?"
    ,IS_RESTORE_ALL_ICON_EN : "Do you want to restore all shortcut icons in the list as the default?"

    ,COMPLETED_ZH : "已完成！"
    ,COMPLETED_EN : "Completed!"

    ; Right-click context menu (右键上下文菜单)
    ,MENU_RUN_ZH : "运行快捷方式"
    ,MENU_RUN_EN : "Launch"

    ,MENU_CHANGE_ZH : "更换文件图标"
    ,MENU_CHANGE_EN : "Change"
    
    ,MENU_RESTORE_ZH : "恢复默认图标"
    ,MENU_RESTORE_EN : "Restore"
    
    ,MENU_OPEN_ZH : "打开目标目录"
    ,MENU_OPEN_EN : "Explore"
    
    ,MENU_RENAME_ZH : "重新命名文件"
    ,MENU_RENAME_EN : "Rename"

    ,MENU_PROPERTIES_ZH : "快捷方式属性"
    ,MENU_PROPERTIES_EN : "Properties"
    
    ,MENU_ADD_LINK_TO_DESKTOP_ZH : "添加其至桌面"
    ,MENU_ADD_LINK_TO_DESKTOP_EN : "Generate"

    ,COPY_LINK_TARGET_PATH_ZH : "复制目标路径："
    ,COPY_LINK_TARGET_PATH_EN : "Copy Target Path:  "
    
    ,COPY_LINK_TARGET_DIR_ZH : "复制目标目录："
    ,COPY_LINK_TARGET_DIR_EN : "Copy Target Dir:  "
    
    ,COPY_LINK_PATH_ZH : "复制路径："
    ,COPY_LINK_PATH_EN : "Copy Link Path:  "
    
    ,COPU_LINK_DIR_ZH : "复制目录："
    ,COPU_LINK_DIR_EN : "Copy Link Dir:  "
    
    ,COPY_LINK_ICON_PATH_ZH : "复制图标路径："
    ,COPY_LINK_ICON_PATH_EN : "Copy icon path:  "

    ,TIP_CHANGE_ZH : "更换所有快捷方式图标"
    ,TIP_CHANGE_EN : "Change all shortcut icons"

    ,TIP_RESTORE_ZH : "恢复所有快捷方式默认图标"
    ,TIP_RESTORE_EN : "Restore all shortcut icons to default"

    ,SAME_NAME_ZH : "存在重复名称，请重新命名"
    ,SAME_NAME_EN : "Duplicate name exists, please rename"

    ;==========================================================================
    ; Tab: Other
    ;==========================================================================
    ,ADD_DESKTOP_TO_LV_ZH : "重新加载桌面快捷方式至主页列表"
    ,ADD_DESKTOP_TO_LV_EN : "Reload the desktop shortcuts"

    ,ADD_START_TO_LV_ZH : "管理`"开始`"菜单的快捷方式的图标"
    ,ADD_START_TO_LV_EN : "Manage shortcuts to Start Menu"

    ,ADD_OTHER_TO_LV_ZH : "管理其他文件夹的快捷方式的图标"
    ,ADD_OTHER_TO_LV_EN : "Manage shortcuts to other folder"

    ,ADD_UWP_WSA_TO_LV_ZH : "添加UWP/WSA的快捷方式至桌面"
    ,ADD_UWP_WSA_TO_LV_EN : "Add UWP/WSA shortcuts to desktop"

    ,BACKUP_LV_LINK_ZH : "备份列表的快捷方式至桌面文件夹"
    ,BACKUP_LV_LINK_EN : "Backup shortcuts to a desktop folder"
    
    ,ERROE_ADD_LINK_TO_DESKTOP_ZH : "桌面已存在相同名称的快捷方式"
    ,ERROE_ADD_LINK_TO_DESKTOP_EN : "A shortcut with the same name already exists on the desktop"
    
    ,IS_ADD_DESKTOP_TO_LV_ZH : "是否重新加载桌面的快捷方式至列表，并在`"主页`"进行更换图标等操作？"
    ,IS_ADD_DESKTOP_TO_LV_EN : "Do you want to reload desktop shortcuts to the list and manage shortcuts on the home page?"

    ,IS_ADD_START_TO_LV_ZH : "是否添加`"开始`"菜单的快捷方式至列表，并在`"主页`"进行更换图标等操作？`n`s①对于开始菜单的快捷方式，不建议使用`"更换所有快捷方式图标`"的功能`n`s②右键可添加`"开始`"菜单的快捷方式至桌面`n`s③`"开始`"菜单的文件夹中不存在UWP应用"
    ,IS_ADD_START_TO_LV_EN : "Do you want to add Start Menu shortcuts to the list and manage shortcuts on the home page?`n`s①It is not recommended to change the icons of all shortcuts in Start Menu`n`s②Context menu has the function called `"Add to the desktop`"`n`s③There are no UWP apps in Start Menu"

    ,IS_ADD_OTHER_ZH : "是否添加其他文件夹的快捷方式至列表，并在`"主页`"进行更换图标等操作？"
    ,IS_ADD_OTHER_EN : "Do you want to add shortcuts from other folder to the list and change icons on the home page?"
    
    ,IS_ADD_UWP_APP_TO_LV_ZH : "是否添加UWP或APP等应用的快捷方式至桌面？`n`s①建议从(`"开始`"菜单--所有应用)中拖拽UWP/APP快捷方式至桌面`n`s②右键呼出菜单并添加指定的快捷方式至桌面"
    ,IS_ADD_UWP_APP_TO_LV_EN : "Do you want to add UWP or APP shortcuts to the desktops?`n`s①Suggest dragging UWP or APP shortcuts from `"Start Menu--All Apps`" to the desktop`n`s②Context menu The menu has the function `"Add to the desktop`""
    
    ,IS_BACKUP_TO_FOLDER_ZH : "是否备份列表的快捷方式至桌面文件夹——`""
    ,IS_BACKUP_TO_FOLDER_EN : "Do you want to back up the list's shortcuts to a desktop folder named `""
    
    ,HAVE_BACKUP_ZH : "已备份至桌面文件夹`n`s文件夹名："
    ,HAVE_BACKUP_EN : "The shortcut has been backed up to the desktop folder`n`sFolder Name:`s"

    ,SELECT_A_ICON_ZH : "请选择一张ICO图片"
    ,SELECT_A_ICON_EN : "Please select an icon in Folder"
    
    ,CHANGING_ZH : "正在扫描、更换中......"
    ,CHANGING_EN : "Scanning and Changing......"

    ,PLEASE_INPUT_ZH : "请输入"
    ,PLEASE_INPUT_EN : "Please input"
    
    ,THE_LINK_NAME_ZH : "快捷方式的名称："
    ,THE_LINK_NAME_EN : "The name of shortcut: "
    
    ,LOG_CHANGED_LINK_ZH : "更换对象："
    ,LOG_CHANGED_LINK_EN : "A shortcut with a replaced icon:  "
    
    ,LOG_RESTORE_LINK_ZH : "被恢复默认图标的快捷方式："
    ,LOG_RESTORE_LINK_EN : "A shortcut with a restore icon:  "
    
    ,LOG_OLD_NAME_ZH : "旧名称："
    ,LOG_OLD_NAME_EN : "Old Name:  "
    
    ,LOG_NEW_NAME_ZH : "新名称："
    ,LOG_NEW_NAME_EN : "New Name:  "

    ,NOT_FOUND_ZH : "未找到"
    ,NOT_FOUND_EN : "Not Found"
    
    ,RENAME_NEW_NAME_ZH : "`s请输入新的文件名(不包含.lnk):"
    ,RENAME_NEW_NAME_EN : "`sPlease input a new file name (Excluding'.lnk')"
    
    ,SAFE_UNAVAILABLE_ZH : "————出于安全，无法查看—————"
    ,SAFE_UNAVAILABLE_EN : "Cannot view for safety reasons."
    
    ,PLEASE_INPUT_NAME_ZH : "搜索或输入快捷方式名称"
    ,PLEASE_INPUT_NAME_EN : "Search......"
    
    ,SELECT_ICONS_FOLDER_ZH : "`n请选择存放ICO图标的文件夹"
    ,SELECT_ICONS_FOLDER_EN : "`nSelect a folder with icons"

    ,SOURCE_OF_ICON_ZH : "图标来源："
    ,SOURCE_OF_ICON_EN : "Source of the icon: "

    ,SUCCESS_ZH : "更换成功!"
    ,SUCCESS_EN : "Success!"
    
    ,NO_CHANGE_ZH : "未更换任何快捷方式的图标"
    ,NO_CHANGE_EN : "The icon for any shortcut has not been replaced"

    ;==========================================================================
    ; Tab: About
    ;==========================================================================
    ,GITHUB_ZH : "     官   网"
    ,GITHUB_EN : "Github"

    ,DOWNLOAD_ZH : "     下   载"
    ,DOWNLOAD_EN : "Download"

    ,ABOUT_HELP_ZH : "     帮   助"
    ,ABOUT_HELP_EN : "Help"

    ,ISSUES_ZH : "     反   馈"
    ,ISSUES_EN : "Issues"

    ,CONTRIBUTORS_ZH : "     贡献者"
    ,CONTRIBUTORS_EN : "Contributors"
}

For name, Descriptor in Text.OwnProps()
{
    If zh = True
    {
        If !Instr(name, "_ZH")
            Continue
        name := StrReplace(name, "_ZH")
        Text.%name%:=Descriptor
    }
    Else
    {
        If !Instr(name, "_EN")
            Continue
        name := StrReplace(name, "_EN")
        Text.%name%:=Descriptor
    }
}