## AHK_ChangeIcon 简介

这是一款用 AHK 编写的软件，它可以快速的批量更换桌面快捷方式图标的软件。当需要更换大量的桌面快捷方式图标时，AHK 可以帮你减少操作来节约时间，约减少**3n-1步**（n为需要更换图标的数量）

This is a software written with AHK, which can quickly batch change the software of desktop shortcut icons.When a large number of desktop shortcut icons need to be replaced, AHK can help you save time by reducing operations by about **"3n-1" steps** ("n" is the number of icons to be replaced)


![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/Usage.gif)

## AHK_ChangIcon 的使用
1.**鼠标滚轮键/F2键**更换图标：

Replacing icons with **mouse wheel button**/**F2**

    （1）打开AHK_ChangIco，并打开存放ICO图片的文件夹，软件和文件夹最好都各自在屏幕的一边，方便查看

    Open the AHK_ChangIco and open the folder where ICO images are stored. It is best to have both the AHK_ChangIco and folder on one side of the screen for easy viewing

    （2）在AHK_ChangIco中选中需要更换图标的项目，然后在文件夹中鼠标滚轮键/F2键点击更换的图标

    Select the item in the AHK_ChangIco that needs to be replaced with an icon, and then click on the icon with the mouse scroll wheel/F2 key in the folder

2.**左键双击**需要修改的项目，并选择图片修改

**Double left click** the item to be modified, and select the image replacement icon

3.**右键点击**需要修改的项目，根据右键菜单栏内容选择需要的功能

**Right click** the item to be modified, and select the required function according to the context of the right-click menu bar


4.推荐一个方便将其他照片转化为ICO图标的软件(拖拽进软件即可转化)

Recommend a software that facilitates converting other photos into ICO icons(Drag and drop into the software to convert)

https://github.com/genesistoxical/drop-icons

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


![image](https://github.com/iKineticate/AHK_ChangeIcon/blob/main/Introduction/Menu.png)

## 注意 (Warn)：

1.暂不支持更换`我的电脑`、`回收站`、`.url`、`.exe`、`.pdf`等图标

Replacing icons such as' My Computer ',' Recycle Bin ','. URL ','. exe ', and'. pdf 'is currently not supported

2.UWP应用和WSA应用的快捷方式不支持恢复默认图标和打开目标目录

Shortcuts for UWP and WSA applications do not support restoring default icons and opening target directories

3.AHK的列表暂不支持显示快捷方式图标（除了系统图标）

The listview of AHK does not support the display of shortcut icons（except system icons）

## 更新内容

v1.3

    （1）添加了鼠标右键/F2键在文件夹中将对应的快捷方式图标替换为鼠标所在的图标

    Added replacing the corresponding shortcut icon in the folder with the icon selected by the MButton/F2

    （2）优化了部分细节（Optimized some details）
    
v1.2：

    （1）添加了搜索功能（Added search function）

    （2）更换软件图标（Replace software icon

    （3）更改图标显示区域（Change icon display area）

    （4）优化、缩减代码（Optimize and reduce code）
