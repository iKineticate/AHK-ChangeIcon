![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/homepage.png)

<h3 align="center"> 简体中文 | <a href='./README-en_US.md'>English</a></h3>

## 关于

这是一款用 AHK 编写的软件，它解决了用户在更换快捷方式图标时的繁琐操作，<font color=SeaGreen>只需一步</font>，即可随心更换。无论是更换单个图标还是<font color=SeaGreen>批量更换</font>，都可以轻松满足。它不仅支持更换桌面快捷方式的图标，它还支持更换"开始"菜单和其他文件夹中的快捷方式图标。

## 使用

1.为了正常使用它，使用前请授予软件管理员权限

2.一键更换/恢复所有快捷方式图标：
* **<font color=#9657db>紫色</font>按钮**：一键<font color=#9657db>更换</font>所有快捷方式的图标

* **<font color=#b54646>红色</font>按钮**：一键<font color=#b54646>恢复</font>所有快捷方式的默认图标

* 图标（.ico）的名称需按照以下规范命名

    * 图标的名称包含于快捷方式的名称（例如ico图标名称为"Chrome"，快捷方式名称为"Chrome Canary"）

    * 快捷方式的名称包含于图标的名称（例如ico图标名称为"崩坏：星穹铁道"，快捷方式名称为"星穹铁道"）

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/change_and_restore.gif)

3.更换单个快捷方式图标

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

6.在处理来自文件夹的快捷方式时，当快捷方式无属性时无法区分其类型，例如UWP和APP无法进行鉴别（目前尚无解决办法）

## 推荐

1.一键转化其他图标为ICO图标的软件：[Drop Icons](https://github.com/genesistoxical/drop-icons)

2.隐藏快捷方式小箭头的软件：[Dism++](https://github.com/Chuyu-Team/Dism-Multi-language)

3.小巧的桌面整理软件：[酷呆桌面](https://www.coodesker.com)

## 感谢

1.图标来源网站：[iconfont](https://www.iconfont.cn) 和 [flaticon](https://www.flaticon.com/)

2.v2版本的GDIP库：[AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)

3.设置列表颜色库：[AHK2_LV_Colors](https://github.com/AHK-just-me/AHK2_LV_Colors)

4.工具提示库：[GuiCtrlTips](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116218)

## 更新内容

1.新的窗口界面和按钮

2.修复部分问题，优化部分代码

3.删除功能：按下鼠标滚轮键/F2键更换图标