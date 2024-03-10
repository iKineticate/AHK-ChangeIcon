![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/homepage.png)

<h3 align="center"> 简体中文 | <a href='./README-en_US.md'>English</a></h3>

## 关于

这是一款用 AHK 编写的软件，它解决了用户在更换快捷方式图标时的繁琐操作，只需一步，即可随心更换。无论是更换单个图标还是批量更换，都可以轻松满足。它不仅支持更换桌面快捷方式的图标，它还支持更换"开始"菜单和其他文件夹中的快捷方式图标。

## 使用

1.为了正常使用它，使用前请授予软件管理员权限

2.一键更换/恢复所有快捷方式图标：
* **紫色**按钮：一键**更换**所有快捷方式的图标
* **红色**按钮：一键**恢复**所有快捷方式的默认图标
* 图标文件的后缀格式为 "**.ico**"
* 图标的名称需按照以下规范命名

    * 图标的全名称包含于快捷方式的名称（例如图标名称为"Chrome"，快捷方式名称为"Chrome Canary"）

    * 快捷方式的全名称包含于图标的名称（例如图标名称为"崩坏：星穹铁道.ico"，快捷方式名称为"星穹铁道.lnk"）

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/change_and_restore.gif)

3.更换/恢复单个快捷方式图标

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/change_one.gif)

4.右键上下文菜单

* 运行快捷方式

* 更换快捷方式图标

* 恢复快捷方式默认图标

* 打开快捷方式目标目录

* 重新命名桌面快捷方式

* 添加非桌面快捷方式至桌面

* 查看和复制快捷方式的属性

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/menu.jpg)

## 其他功能

1.添加桌面、"开始"菜单或其他文件夹的快捷方式至列表中，并进行更换图标等操作

2.添加UWP/WSA等应用的快捷方式至当前用户的桌面

3.备份列表中的快捷方式至桌面文件夹

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/other_zh.png)

## 已知问题

1.仅支持更换快捷方式(.lnk)图标，暂不支持更换非快捷方式图标（如pdf、exe等图标）

    解决办法：为非快捷方式的文件创建快捷方式至桌面即可

2.某些应用自动更新后，其快捷方式图标自动恢复为默认图标

    解决办法：手动创建快捷方式，右键该应用快捷方式--打开文件所在位置，右键点击目标文件--发送到--桌面快捷方式，最后修改其快捷方式图标即可

3.UWP和WSA应用的快捷方式不支持恢复默认图标

    解决办法：重新添加UWP或WSA应用的快捷方式至桌面（在"其他"中选择"添加UWP/APP的快捷方式至桌面"）

4.某些快捷方式未被更换过图标，但列表显示为已更换(√)

    原因：该应用快捷方式的图标源于其(父/子)目录下的.ico图标

5.无法修改开始菜单中的UWP快捷方式的图标

    解决办法：从"其他"功能中添加UWP快捷方式至桌面并修改其图标，然后粘贴至开始菜单的文件夹，最后在"开始菜单"的"所有应用"中固定到"开始"屏幕

6.在处理来自AppsFolder的快捷方式时，若快捷方式无属性，则无法区分其类型，例如UWP和WSA无法进行相互鉴别（目前尚无解决办法）

    解决办法：从"开始"菜单中的"所有应用"中，拖拽其中的快捷方式至桌面，即可鉴别WSA

7.当图标名称和快捷方式名称完全匹配(即相同)时，其他的快捷方式名称即使与该图标名称存在包含关系，其他快捷方式也无法更换图标。如当chrome.lnk和chrome.ico的名称完全匹配，则更换chrome canary.lnk时，无法更换和它存在包含关系的chrome.ico图标

    解决办法：单独更换其他快捷方式图标

## 下载

Github：[AHK-ChangeIcon](https://github.com/iKineticate/AHK-ChangeIcon/releases)

蓝奏云：[AHK-ChangeIcon](https://wwu.lanzoul.com/b03rjy4ud) (密码：6666)


## 推荐

1.一键转化其他图标为ICO图标的软件：[Drop Icons](https://github.com/genesistoxical/drop-icons)

2.隐藏快捷方式小箭头的软件：[Dism++](https://github.com/Chuyu-Team/Dism-Multi-language)

3.小巧的桌面整理软件：[酷呆桌面](https://www.coodesker.com)

## 感谢

1.图标来源网站：[iconfont](https://www.iconfont.cn) 和 [flaticon](https://www.flaticon.com/)

2.GDIP_All库：[AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)

3.设置列表颜色库：[AHK2_LV_Colors](https://github.com/AHK-just-me/AHK2_LV_Colors)

4.控件提示库：[GuiCtrlTips](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116218)

## 更新内容

1.文字图标代替PNG显示图标

2.检索配置内容

3.默认字体更换为UI

4.垂直标签页添加图标

5.修复部分问题，优化部分代码

6.垂直标签页的"帮助"更换为"设置"（设置内的功能未上线）