## AHK_ChangeIcon 简介

这是一款用 AHK 编写的软件，它可以快速地**更换大量**桌面快捷方式图标来帮你**减少操作**和**节约时间**

This is a software written with AHK, which can quickly **replace a large number of** desktop shortcut icons to help you **reduce operations** and **save time**

![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/AHK_ChangeIcon.png)

## AHK_ChangIcon 的使用

为了更好的更换图标，使用前请授予软件管理员权限

Please grant software administrator permission to complete the operation of changing icons before use

1.点击一键更换的按钮：

Click on the button named 'One-Click Change'

    （1）单选按钮：手动（Radio Button：Manual）

        需要一个一个的确认是否更换图标，可以避免匹配错误而导致更换错误的现象
        We need to confirm one by one whether to replace the icons, which can avoid the phenomenon of replacement errors caused by matching errors

    （2）单选按钮：自动（Radio Button：Auto）

        默认开启，无需手动确认即可快速更换ICO文件夹包含的、且匹配的图片
        Default on, quick replacement of matching ICONS contained in ICO folders without manual confirmation

    （3）选择ICO文件夹（Select A Folder with Icons）

    （4）注意：这个功能只支持替换包含有快捷方式名称的Icon图标，如名为"Excel"的快捷方式图标可以替换名为"Microsoft Excel"的Icon图片，但不能名为"Microsoft Edge"的快捷方式图标可以替换名为"Edge"的Icon图片

        Note: This feature only supports replacing Icon icons with shortcut names. For example, a shortcut icon named 'Excel' can be repalced with an Icon named 'Microsoft Excel', but a shortcut icon named 'Microsoft Edge' cannot be replaced with an Icon named 'Edge'

![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/Auto_Change.gif)

2.打开ICON文件夹后，使用**鼠标滚轮键/F2键**更换图标：

After Opening a Folder With Icons, click the mouse wheel button or F2 key to change the icon:

    （1）打开存放ICO的文件夹

    Open A Folder With Icons

    （2）在AHK_ChangIco中选中需要更换图标的项目，然后在文件夹中鼠标滚轮键/F2键点击更换的图标

    Select the item in the AHK_ChangIco that needs to be changed with an icon, and then click on the icon with the mouse scroll wheel or F2 key in the folder

![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/MButtom&F2.gif)

3.**左键双击**需要修改的项目，并选择图片修改

**Double left click** the item to be modified, and select the image replacement icon

4.**右键点击**需要修改的项目，根据右键菜单栏内容选择需要的功能

**Right click** the item to be modified, and select the required function according to the context of the right-click menu bar

![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/LButtom&Menu.gif)

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

1.暂不支持更换`我的电脑`、`回收站`、`.url`、`.exe`、`.pdf`等文件图标

Replacing icons such as' My Computer ',' Recycle Bin ','. URL ','. exe ', and'. pdf 'is currently not supported

2.UWP应用和WSA应用的快捷方式不支持恢复默认图标和打开目标目录

Shortcuts for UWP and WSA applications do not support restoring default icon and opening target directories

3.列表的标题栏的文字不支持更换颜色

The text in the title bar of the listview does not support changing colors

4.推荐一个方便将其他照片转化为ICO图标的软件(拖拽进软件即可转化)

Recommend a software that facilitates converting other photos into ICO icons(Drag and drop into the software to convert)

https://github.com/genesistoxical/drop-icons

## 更新内容

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
