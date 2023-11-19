## AHK ChangeIcon 简介

这是一款用 AHK 编写的软件，它可以快速地**批量更换**桌面快捷方式图标

This is a software written in AHK, which can quickly change the icons of shortcuts in **batches**

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

3.左键双击需要修改的项目，并选择图片修改

Double left click the item to be modified, and select the image replacement icon

4.右键点击需要修改的项目，根据右键菜单栏内容选择需要的功能

Right click the item to be modified, and select the required function according to the context of the right-click menu bar

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/LButtom&Menu.gif)

5.添加桌面、开始（菜单）、其他文件夹的快捷方式至列表中

Add shortcuts from Desktop/Start/Other Folder to the list

6.添加UWP/APP等快捷方式至当前用户的桌面

Add shortcuts such as UWP/APP to the the current user's desktop

7.备份列表中的快捷方式至桌面文件夹

Backup shortcuts from the list to a desktop folder

## AHK_ChangIcon 的右键菜单功能

1.**更换**桌面快捷方式图标

**Change** desktop shortcut icons

2.支持恢复桌面快捷方式**默认**图标

Restoring **default** icons of desktop shortcuts

3.支持**重命名**桌面快捷方式

**Rename** desktop shortcuts

4.支持**打开**快捷方式的**目标目录**

**Open the target directory** of shortcut

5.支持**运行**桌面快捷方式

**Run** desktop shortcuts

6.支持**查看和复制**快捷方式的属性

Supports **viewing** and **copying** attributes of shortcuts

## 已知问题 (ISSUES)：

1.仅支持更换快捷方式图标，暂不支持更换非.lnk文件图标（如系统图标、exe等图标）

Only supports changeing shortcuts icons，temporarily not supporting the replacement of non .lnk icons(Icons such as system, exe, etc)

2.UWP和APP应用的快捷方式不支持直接恢复默认图标和打开目标目录

Shortcuts for UWP and APP applications do not support restoring default icon and opening target directories

3.部分快捷方式的原图标源于应用目录的.ico，导致错误判断为已更换

The original icons of some shortcuts originated from the. ico in the application directory, which resulted in an incorrect judgment as replaced

4.推荐一个方便将其他照片转化为ICO图标的软件(图片被拖拽进软件即可转化为ICO图标)

Recommend a software that facilitates converting other photos into ICO icons(The image can be dragged intos the software and converted into icons)

https://github.com/genesistoxical/drop-icons

## 更新内容（UPDATE）：
v2.3

    （1）添加了新功能（New Functions）

        ①刷新/添加桌面的快捷方式至列表中
        Refresh/Add Desktop shortcut to the list

        ②添加UWP/APP等快捷方式至桌面
        Add shortcuts such as UWP/APP to the desktop

    （2）优化了部分细节（Optimized some details）

    （3）修复了若干问题（Fixed several issues）
