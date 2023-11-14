## AHK ChangeIcon 简介

这是一款用 AHK 编写的软件，它可以快速地**更换大量**桌面快捷方式图标来帮你**减少操作**和**节约时间**

This is a software written with AHK, which can quickly **replace a large number of** desktop shortcut icons to help you **reduce operations** and **save time**

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/AHK_ChangeIcon.png)

## AHK ChangIcon 的使用

为了更好的更换图标，使用前请授予软件管理员权限

Please grant software administrator permission to complete the operation of changing icons before use

1.一键更换（恢复默认）图标按钮：

One-click Change(restore) all shortcut icon buttons

    （1）一键更换所有快捷方式的图标：

        存在于“主页”的右上角的按钮，它可快速地自动更换快捷方式的图标为选中文件夹中名字匹配的ICON图标

        The button located in the upper right corner of the homepage，it can quickly and automatically change the icon of the shortcut to the ICON that matches the name in the selected folder

    （2）一键恢复所有快捷方式的默认图标

        存在于标签页中的“其他”的右上角的按钮，它可快速地自动恢复快捷方式的默认图标

        The button located in the top right corner of the "Other" tab can quickly and automatically restore the default icon for shortcuts

    （3）注意：该功能要保证快捷方式的名称包含在图标名称中，或者图标名称包含在快捷方式名称中，如Excel.lnk和Microsoft Excel.ico；腾讯QQ.lnk和QQ.ico

    Note: This feature should ensure that the name of the shortcut is included in the icon name, or the icon name is included in the shortcut name, such as Excel.lnk and Microsoft Excel.ico; 腾讯QQ.lnk and QQ.ico.


![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Auto_Change.gif)

2.打开ICON文件夹后，使用**鼠标滚轮键/F2键**更换图标：

After Opening a Folder With Icons, click the mouse wheel button or F2 key to change the icon:

    （1）打开存放ICO的文件夹

    Open A Folder With Icons

    （2）在AHK_ChangIco中选中需要更换图标的项目，然后在文件夹中鼠标滚轮键/F2键点击更换的图标

    Select the item in the AHK_ChangIco that needs to be changed with an icon, and then click on the icon with the mouse scroll wheel or F2 key in the folder

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/MButtom&F2.gif)

3.**左键双击**需要修改的项目，并选择图片修改

**Double left click** the item to be modified, and select the image replacement icon

4.**右键点击**需要修改的项目，根据右键菜单栏内容选择需要的功能

**Right click** the item to be modified, and select the required function according to the context of the right-click menu bar

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/LButtom&Menu.gif)

5.添加开始（菜单）的快捷方式至列表中

Add shortcuts from Start to the list

6.添加其他文件夹中的快捷方式至列表中

Add shortcuts from folders to the list

7.备份列表中的快捷方式至桌面文件夹

Backup shortcuts to a desktop folder

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

1.仅支持更换快捷方式图标，暂不支持更换`我的电脑`、`回收站`、`.url`、`.exe`、`.pdf`等文件图标

Only supports replacing shortcut icons，replacing icons such as' My Computer ',' Recycle Bin ','. URL ','. exe ', and'. pdf 'is currently not supported

2.UWP应用和WSA应用的快捷方式不支持直接恢复默认图标和打开目标目录

Shortcuts for UWP and WSA applications do not support restoring default icon and opening target directories

3.部分快捷方式的原图标源于应用目录的.ico，导致错误判断为已更换

The original icons of some shortcuts originated from the. ico in the application directory, which resulted in an incorrect judgment as replaced

4.推荐一个方便将其他照片转化为ICO图标的软件(图片被拖拽进软件即可转化为ICO图标)

Recommend a software that facilitates converting other photos into ICO icons(The image can be dragged intos the software and converted into icons)

https://github.com/genesistoxical/drop-icons

## 更新内容

v2.2
    （1）缓解了切换标签时闪烁问题

    Alleviated flickering issues when switching labels

    （2）其他标签页添加了新功能（①清空列表；②添加其他文件夹的快捷方式至列表中;③添加开始(菜单)快捷方式至列表中）;④备份快捷方式（暂无点击动画）

    New features have been added to other tabs（① Clear list; ② Add shortcuts to other folders to the list; ③ Add Start (Menu) Shortcut to List；④Backup shortcuts to a desktop folder）（There are currently no click animations available）

    （3）添加了启动界面

    Added startup screen

    （4）优化了部分细节
    
    Optimized some details

    （5）修复了若干问题
    
    Fixed several issues

v2.1

    （1）扁平风格

    Flat Style

    （2）部分按钮添加了动画

    Some buttons have been animated

    （3）添加了标签页（主页、其他、日志、主题、语言、关于）

    Added tabs (Home, Other, Log, About)

    （4）支持中文、英文语言（机器翻译的英文）

    Support for Chinese and English languages (English translated by machine)

    （5）去除原窗口标题栏，重新自绘标题栏

    Remove the original window title bar and redraw the title bar yourself

    （6）优化了部分细节
    
    Optimized some details

    （7）修复了若干问题
    
    Fixed several issues

v2.0

    （1）修改了软件UI
    
    Software UI modified
    
    （2）支持一键更换所有图标
    
    Supports One-Click Change of all shorcut icons

    （3）搜索栏添加了搜索按钮
    
    A search button has been added to the right side of the search bar

    （4）在菜单中添加了可被复制快捷方式的属性
    
    Added shortcut attributes to the menu, and this attributes can be copied

    （5）列表删除了快捷方式的目标路径的一列
    
    The listview has removed a column of the target path for the shortcut

    （6）优化了部分细节
    
    Optimized some details

    （7）修复了若干问题
    
    Fixed several issues

v1.4

    （1）在项目左侧添加了图标显示
    
    Added icon display on the left side of the list item

    （2）优化了部分细节
    
    ptimized some details


v1.3

    （1）添加了鼠标右键/F2键在文件夹中将对应的快捷方式图标替换为鼠标所在的图标

    Added replacing the corresponding shortcut icon in the folder with the icon selected by the MButton/F2

    （2）优化了部分细节
    
    Optimized some details
    
v1.2：

    （1）添加了搜索功能
    
    Added search function

    （2）更换软件图标
    
    Replace software icon

    （3）更改图标显示区域
    
    Change icon display area

    （4）优化了部分细节
    
    Optimized some details
