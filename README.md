## 关于(About)

这是一款用 AHK 编写的软件，它解决了用户在更换快捷方式图标时的繁琐操作，只需一步，即可随心更换。无论是单个图标还是批量操作，都可以轻松满足。它不仅支持更换**桌面**快捷方式的图标，它还支持更换"开始"菜单和其他文件夹中的快捷方式图标。

This is a software written in AHK, which can solves the tedious operation when replacing shortcut icons. With just one step, users can change their icons at will. Whether it's a single icon or a batch operation, it can be easily satisfied.It not only supports changing **Desktop** shortcut icons, but also supports changine shortcut icons in the **Start Menu** and **Other Folders**

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/AHK_ChangeIcon.png)

## 使用(Usage)

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


## 其他(Other)

1.添加桌面、"开始"菜单或其他文件夹的快捷方式至列表中

Add shortcuts from Desktop || Start Menu(Taskbar) || Other Folder to the list

2.修改"开始"菜单的快捷方式图标实际上也改变了任务栏中的对应快捷方式图标

Changing the shortcut icon in the Windows Start menu actually changes the shortcut icon in the Taskbar as well

3.添加UWP或APP等应用的快捷方式至当前用户的桌面

Add shortcuts to applications such as UWP || APP to the the current user's desktop

4.备份列表中的快捷方式至桌面文件夹

Backup shortcuts from the list to a desktop folder

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Other.png)

## 菜单(MENU)

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

UWP || APP Shortcuts do not support restoring default icon and opening target directories

3.部分应用快捷方式的图标源于应用文件夹的.ico，导致错误地判断为已更换"√"

The original icons of some shortcuts originated from the .ico in the application folder, which resulted in an incorrect judgment as replaced

4.推荐一个方便将其他照片转化为ICO图标的软件(图片被拖拽进软件即可转化为ICO图标)

Recommend a software that facilitates converting other photos into ICO icons(The image can be dragged intos the software and converted into icons)

https://github.com/genesistoxical/drop-icons

## 更新内容

1.加快更换所有快捷方式图标的速度
Accelerate the speed of changing icons for all shortcuts.

2.优化了部分细节