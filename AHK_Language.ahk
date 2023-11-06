#Requires AutoHotkey v2.0

Navigation_zh := {Label: ["主页", "其他", "日志", "关于"]}
Navigation_en := {Label: ["Home", "Others", "Log", "About"]}

All_Changed_Text_zh := "原图标`s=>`s新图标`n"
All_Changed_Text_en := "Old icon for link`s→`sNew icon for link`n"

All_Default_Text_zh := "`s是否确定全部快捷方式图标恢复为默认图标？`n`s注意：UWP和APP的快捷方式无法恢复默认图标"
All_Default_Text_en := "`sAre you sure to restore all shortcut icons to the default icons?`n`sNote: UWP or APP icon cannot be restored to default icons"

All_Text_zh := "总共"
All_Text_en := "ALL"

An_Icon_Text_zh := "请选择一张ICO图片"
An_Icon_Text_en := "Please select an icon in Folder"

A_Row_Text_zh := "请在列表中仅选择一行"
A_Row_Text_en := "Please only select a row in ListView"

Changing_Text_zh := "更换图标中......"
Changing_Text_en := "Changing......"

Completed_Text_zh := "已完成"
Completed_Text_en := "Completed"

Copy_LTP_Text_zh := "复制快捷方式的目标路径："
Copy_LTP_Text_en := "Copy Target Path："

Copy_LTD_Text_zh := "复制快捷方式的目标目录："
Copy_LTD_Text_en := "Copy Target Dir："

Copy_LP_Text_zh := "复制快捷方式的路径："
Copy_LP_Text_en := "Copy Link Path："

Copy_LD_Text_zh := "复制快捷方式的目录："
Copy_LD_Text_en := "Copy Link Dir："

Default_Title_Text_zh := "恢复所有快捷方式为默认图标"
Default_Title_Text_en := "Restore all shortcuts to default icons"

Icon_Name_Text_zh := "文件图标的名称："
Icon_Name_Text_en := "The name of icon: "

ing_TrayTip_Text_zh := "正在扫描、更换中......"
ing_TrayTip_Text_en := "Scanning and Changing......"

Input_Text_zh := "请输入"
Input_Text_en := "Please input"

Link_Name_Text_zh := "快捷方式的名称："
Link_Name_Text_en := "The name of shortcut: "

Log_Change_Text_zh := "更换图标："
Log_Change_Text_en := "Change："

Log_Default_Text_zh := "恢复默认图标："
Log_Default_Text_en := "Default Icon："

Log_Rename_Text_zh := "重命名："
Log_Rename_Text_en := "Rename："

Log_NewName_Text_zh := "新名称："
Log_NewName_Text_en := "NewName："

Menu_Change_Text_zh := "更改文件图标"
Menu_Change_Text_en := "Change"

Menu_Default_Text_zh := "恢复默认图标"
Menu_Default_Text_en := "Default"

Menu_LA_Text_zh := "快捷方式属性"
Menu_LA_Text_en := "Attribute"

Menu_Rename_Text_zh := "重新命名文件"
Menu_Rename_Text_en := "Rename"

Menu_Run_Text_zh := "打开快捷方式"
Menu_Run_Text_en := "Run"

Menu_TargetDir_Text_zh := "打开目标目录"
Menu_TargetDir_Text_en := "Target Dir"

Not_Fountd_Text_zh := "未找到"
Not_Fountd_Text_en := "Not Found"

No_Text_zh := "未更换"
No_Text_en := "NO"

Rename_Text_zh := "请输入新的文件名(不包含.lnk):"
Rename_Text_en := "Please input a new file name (Excluding'.lnk')"

Safe_Text_zh := "————出于安全，无法查看—————"
Safe_Text_en := "————Unable to view for security reasons—————"

Safe_TrayTip_Text_zh := "注意: 出于安全，UWP和WSA应用无法恢复默认图标"
Safe_TrayTip_Text_en := "Notice: For security reasons, UWP and WSA applications cannot restore default icons"

Search_Text_zh := "搜索......"
Search_Text_en := "Search......"

Select_Folder_Text_zh := "请选择存放ICO图标的文件夹"
Select_Folder_Text_en := "Select a folder with icons"

Success_Text_zh := "更换成功!"
Success_Text_en := "Success!"

Unchanged_Text_zh := "未更换任何快捷方式的图标"
Unchanged_Text_en := "The icon for any shortcut has not been replaced"

Yes_Text_zh := "已更换"
Yes_Text_en := "YES"

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
Case "0804": Yes_zh := True
Case "7804": Yes_zh := True
Case "0004": Yes_zh := True
Case "1004": Yes_zh := True
Case "7C04": Yes_zh := True
Case "0C04": Yes_zh := True
Case "1404": Yes_zh := True
Case "0404": Yes_zh := True
Default    : Yes_zh := False
}


All_Changed_Text    := Yes_zh = True ? All_Changed_Text_zh:All_Changed_Text_en
All_Default_Text    := Yes_zh = True ? All_Default_Text_zh:All_Default_Text_en
All_Text            := Yes_zh = True ? All_Text_zh:All_Text_en
A_Row_Text          := Yes_zh = True ? A_Row_Text_zh:A_Row_Text_en
An_Icon_Text        := Yes_zh = True ? An_Icon_Text_zh:An_Icon_Text_en

Changing_Text       := Yes_zh = True ? Changing_Text_zh:Changing_Text_en
Completed_Text      := Yes_zh = True ? Completed_Text_zh:Completed_Text_en
Copy_LTP_Text       := Yes_zh = True ? Copy_LTP_Text_zh:Copy_LTP_Text_en
Copy_LTD_Text       := Yes_zh = True ? Copy_LTD_Text_zh:Copy_LTD_Text_en
Copy_LP_Text        := Yes_zh = True ? Copy_LP_Text_zh:Copy_LP_Text_en
Copy_LD_Text        := Yes_zh = True ? Copy_LD_Text_zh:Copy_LD_Text_en

Default_Title_Text  := Yes_zh = True ? Default_Title_Text_zh:Default_Title_Text_en

Icon_Name_Text      := Yes_zh = True ? Icon_Name_Text_zh:Icon_Name_Text_en
ing_TrayTip_Text    := Yes_zh = True ? ing_TrayTip_Text_zh:ing_TrayTip_Text_en
Input_Text          := Yes_zh = True ? Input_Text_zh:Input_Text_en

Link_Name_Text      := Yes_zh = True ? Link_Name_Text_zh:Link_Name_Text_en
Log_Change_Text     := Yes_zh = True ? Log_Change_Text_zh:Log_Change_Text_en
Log_Default_Text    := Yes_zh = True ? Log_Default_Text_zh:Log_Default_Text_en
Log_Rename_Text     := Yes_zh = True ? Log_Rename_Text_zh:Log_Rename_Text_en
Log_NewName_Text    := Yes_zh = True ? Log_NewName_Text_zh:Log_NewName_Text_en

Navigation          := Yes_zh = True ? Navigation_zh:Navigation_en
Not_Fountd_Text     := Yes_zh = True ? Not_Fountd_Text_zh:Not_Fountd_Text_en
No_Text             := Yes_zh = True ? No_Text_zh:No_Text_en

Menu_Run_Text       := Yes_zh = True ? Menu_Run_Text_zh:Menu_Run_Text_en
Menu_Change_Text    := Yes_zh = True ? Menu_Change_Text_zh:Menu_Change_Text_en
Menu_Default_Text   := Yes_zh = True ? Menu_Default_Text_zh:Menu_Default_Text_en
Menu_TargetDir_Text := Yes_zh = True ? Menu_TargetDir_Text_zh:Menu_TargetDir_Text_en
Menu_Rename_Text    := Yes_zh = True ? Menu_Rename_Text_zh:Menu_Rename_Text_en
Menu_LA_Text        := Yes_zh = True ? Menu_LA_Text_zh:Menu_LA_Text_en

Rename_Text         := Yes_zh = True ? Rename_Text_zh:Rename_Text_en

Safe_Text           := Yes_zh = True ? Safe_Text_zh:Safe_Text_en
Safe_TrayTip_Text   := Yes_zh = True ? Safe_TrayTip_Text_zh:Safe_TrayTip_Text_en
Search_Text         := Yes_zh = True ? Search_Text_zh:Search_Text_en
Select_Folder_Text  := Yes_zh = True ? Select_Folder_Text_zh:Select_Folder_Text_en
Success_Text        := Yes_zh = True ? Success_Text_zh:Success_Text_en

Unchanged_Text      := Yes_zh = True ? Unchanged_Text_zh:Unchanged_Text_en

Yes_Text            := Yes_zh = True ? Yes_Text_zh:Yes_Text_en