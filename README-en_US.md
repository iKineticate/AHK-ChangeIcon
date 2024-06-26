![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/intro-images/homepage.png)

## About

This is a software written in AHK, which can solves the tedious operation when replacing shortcut icons. With just **one step**, users can change or restore their icons at will. Whether it's replacing a single icon or **batch replacement**, it can be easily satisfied.It not only supports changing Desktop shortcut icons, but also supports changine shortcut icons in the Start Menu and Other Folders

In the future, I plan to rebuild this project using the Rust programming language; therefore, this project may not receive further updates.

## Usage

1.In order to use it properly, please grant the software administrator privileges before using it

2.Change or Restore all shortcut icons
* **Purple** Button: **Replace** all shortcut icons
* **Red** Button: **Restore** default icons for all shortcuts
* The format of the icon is "**.ico**"
* The name of the icon must be named according to the following specifications :

    （1）The full name of the icon is included in the name of the shortcut(e.g. the icon name is "Chrome.ico" and the shortcut name is "Chrome Canary.lnk")
    （2）The full name of the shortcut should be included in the name of the icon(e.g. the icon name is "Honkai: Star Rail.ico" and the shortcut name is "Star Rail.lnk")

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/intro-images/change_and_restore.gif)

3.Change/Restore the icon of a single shortcut

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/intro-images/change_one.gif)

4.List context menu
*  Lanuch the shortcut
*  Change the shortcut icon
*  Restore the default icon for the shortcut
*  Extract shortcut icon
*  Explore the shortcut target directory
*  Rename the shortcut
*  Adds the non-desktop shortcut to the desktop
*  View and copy the properties of shortcuts

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/intro-images/menu.jpg)

## Other Function

1.Manage shortcuts to the desktop, Start menu or other folders

2.Display system icons or user folder icons (supports extracting system icons)

3.Create shortcuts to desktop for UWP/WSA etc. applications

4.Backup shortcuts from the list to a desktop folder

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/intro-images/other_en.png)

## ISSUES：

1.Only support changeing shortcuts icons，temporarily not supporting the replacement of non-.lnk icons(e.g. system icons, exe icons, etc.) for the time being

    Solve: Create a shortcut to the desktop for non shortcut files

2.After some applications are automatically updated, their shortcut icons will automatically return to their default icons

    Solve: Rename the shortcuts

3.Shortcuts for UWP and WSA applications do not support restoring default icons

    Solve: Re-add shortcuts to UWP or WSA apps to desktop from "other" functions

4.Some shortcuts have not had their icons replaced, but the list shows as replaced (√)

    Cause: The app's shortcut icon is derived from the icon in its (parent/child) directory

5.Unable to change the icon of UWP shortcut in the start menu

    Solve: Add the UWP shortcut to the desktop from the "Other" function, then change its icon and paste it into the folder of the Start menu ((C:\Users\your uer name\AppData\Roaming\Microsoft\Windows\Start Menu\Programs)), finally fix it to the "Start" Screen in the "All Apps" section of the Start menu

6.WSA applications (app) are misclassified as UWP because it comes from Applications (shell:AppsFolder), AHK-ChangeIcon can't get the shortcut property and can't differentiate its target file type leading to the determination of UWP.

    Solve:Drag and drop the APP shortcut from "All Apps" in the "Start" menu to the desktop to identify it as a WSA application.

## Recommend:

1.Utility to convert images to icons (.ico) for Windows：[Drop Icons](https://github.com/genesistoxical/drop-icons)

2.Remove Arrows on Shortcut Icons：[Dism++](https://github.com/Chuyu-Team/Dism-Multi-language)

3.Automatically organize your desktop shortcuts icons and running tasks：[Coodesker](https://www.coodesker.com)

## Thanks to

1.Icons source：[iconfont](https://www.iconfont.cn) and [flaticon](https://www.flaticon.com/)

2.GDIP library version 2.0：[AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)

3.Library for setting list colors：[AHK2_LV_Colors](https://github.com/AHK-just-me/AHK2_LV_Colors)

4.GuiControl's ToolTips: [GuiCtrlTips](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116218)

## Updates

1.Font symbols instead of PNG

2.Check info.ini contents

3.Change the font of some content

4.Add icons to vertical tabs

5.Fix some problems and optimize some codes

6.Replace "Help" with "Settings" in the vertical tabs.