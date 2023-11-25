![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/AHK_ChangeIcon.png)

<h3 align="center"> 简体中文 | <a href='./README-en_US.md'>English</a></h3>

## 关于

这是一款用 AHK 编写的软件，它解决了用户在更换快捷方式图标时的繁琐操作，只需一步，即可随心更换。无论是单个图标还是批量操作，都可以轻松满足。它不仅支持更换**桌面**快捷方式的图标，它还支持更换"开始"菜单和其他文件夹中的快捷方式图标。

## 使用

1.为了正常使用它，使用前请授予软件管理员权限

2.一键更换/一键恢复所有快捷方式图标

    （1）一键更换所有快捷方式图标为红色按钮

    （2）一键恢复所有快捷方式图标为紫色按钮

    （3）更换要求：
        ①图标的名称包含于快捷方式的名称（例如图标名称为"Visual"，快捷方式名称为"Visual Studio"）

        ②快捷方式的名称包含于图标的名称（例如图标名称为"QQ音乐"，快捷方式名称为"QQ"）

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Auto_Change.gif)

3.按下鼠标滚轮键/F2键更换图标：

    （1）打开存放ICO的文件夹

    （2）在AHK_ChangIco中选中需要更换图标的项目，然后在文件夹中使用鼠标滚轮键/F2键点击更换的图标

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/MButtom&F2.gif)

4.左键双击或右键单击需要修改图标的项目

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/LButtom&Menu.gif)


## 其他

1.添加桌面、"开始"菜单或其他文件夹的快捷方式至列表中

2.修改"开始"菜单的快捷方式图标实际上也改变了任务栏中的对应快捷方式图标

3.添加UWP或APP等应用的快捷方式至当前用户的桌面

4.备份列表中的快捷方式至桌面文件夹

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Other.png)

## 右键上下文菜单

1.更换当前桌面快捷方式图标

2.恢复当前桌面快捷方式默认图标

3.重命名当前桌面快捷方式

4.打开当前快捷方式的目标目录

5.运行当前桌面快捷方式

6.添加非桌面的快捷方式至当前用户的桌面

7.支持查看和复制快捷方式的属性

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/Menu.jpg)

## 已知问题

1.仅支持更换快捷方式图标，暂不支持更换非.lnk文件图标（如系统图标、exe等图标）

2.出于安全考虑，UWP和APP应用的快捷方式不支持直接恢复默认图标和打开目标目录

3.部分应用快捷方式的图标源于应用文件夹的.ico，导致错误地判断为已更换"√"

4.推荐一个方便将其他照片转化为ICO图标的软件(图片被拖拽进软件即可转化为ICO图标)

https://github.com/genesistoxical/drop-icons

## 更新内容

1.加快更换所有快捷方式图标的速度

2.优化了部分细节