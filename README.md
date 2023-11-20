## AHK ChangeIcon 简介

这是一款用 AHK 编写的软件，它可以快速地批量更换桌面、"开始"菜单(任务栏)或其他文件夹的快捷方式图标

This is a software written in AHK, which can quickly change the icons of Desktop || Start Menu(Taskbar) || Other Folder Shortcuts in batches

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/AHK_ChangeIcon.png)

## AHK ChangIcon 的使用

1.为了实现功能，使用前请授予软件管理员权限

In order to realize the function, please grant the software administrator permission before use

2.一键更换/一键恢复所有快捷方式图标(One-Click Change/Restore all shortcut icons)

    （1）一键更换所有快捷方式图标为红色按钮
    Replace all shortcut icon functions with purple buttons

    （2）一键恢复所有快捷方式图标为紫色按钮
    Restore all shortcut icon functions with red button

    （3）更换要求（Change Requirements）：
        ①图标的名称包含于快捷方式的名称（例如图标名称为"Visual"，快捷方式名称为"Visual Studio"）
        The name of the icon is included in the name of the shortcut

        ②快捷方式的名称包含于图标的名称（例如图标名称为"QQ音乐"，快捷方式名称为"QQ"）
        The name of the shortcut is included in the name of the icon

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Auto_Change.gif)

3.按下鼠标滚轮键/F2键更换图标：

Press the mouse scroll button or F2 key to change the shortcut icon:

    （1）打开存放ICO的文件夹

    Open A Folder With Icons

    （2）在AHK_ChangIco中选中需要更换图标的项目，然后在文件夹中使用鼠标滚轮键/F2键点击更换的图标

    Select the item in AHK_ChangIco that needs to be changed with an icon, and then use the mouse scroll wheel or F2 key to click on the replacement icon in the folder

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/MButtom&F2.gif)

3.左键双击或右键单击需要修改图标的项目

Double click or right-click the item that need to modify icon

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/LButtom&Menu.gif)

4.添加桌面、"开始"菜单、其他文件夹的快捷方式至列表中

Add shortcuts from Desktop || Start Menu(Taskbar) || Other Folder to the list

5.修改"开始"菜单的图标也是属于修改任务栏的图标

Modifying shortcuts icons in the Start menu is equivalent to modifying shortcuts icons in the Taskbar

6.添加UWP/APP等快捷方式至当前用户的桌面

Add shortcuts such as UWP/APP to the the current user's desktop

7.备份列表中的快捷方式至桌面文件夹

Backup shortcuts from the list to a desktop folder

## AHK_ChangIcon 的右键菜单功能

1.更换当前桌面快捷方式图标

Change the current shortcut icon

2.恢复当前桌面快捷方式默认图标

Restore the default icon for the current shortcut

3.重命名当前桌面快捷方式

Rename the current shortcut

4.打开当前快捷方式的目标目录

Open the shortcut target directory

5.运行当前桌面快捷方式

Run the shortcut

6.添加非桌面的快捷方式至当前用户的桌面

Add non desktop shortcuts to the current desktop

7.支持查看和复制快捷方式的属性

Supports viewing and copying attributes of shortcuts

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Menu.jpg)

## 已知问题 (ISSUES)：

1.仅支持更换快捷方式图标，暂不支持更换非.lnk文件图标（如系统图标、exe等图标）

Only supports changeing shortcuts icons，temporarily not supporting the replacement of non .lnk icons(Icons such as system, exe, etc)

2.出于安全考虑，UWP和APP应用的快捷方式不支持直接恢复默认图标和打开目标目录

UWP||APP Shortcuts do not support restoring default icon and opening target directories

3.部分应用快捷方式的图标源于应用文件夹的.ico，导致错误地判断为已更换"√"

The original icons of some shortcuts originated from the .ico in the application folder, which resulted in an incorrect judgment as replaced

4.推荐一个方便将其他照片转化为ICO图标的软件(图片被拖拽进软件即可转化为ICO图标)

Recommend a software that facilitates converting other photos into ICO icons(The image can be dragged intos the software and converted into icons)

https://github.com/genesistoxical/drop-icons
