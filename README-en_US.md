![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/homepage.png)

## About

This is a software written in AHK, which can solves the tedious operation when replacing shortcut icons. With just <font color=SeaGreen>one step</font>, users can change their icons at will. Whether it's replacing a single icon or <font color=SeaGreen>batch replacement</font>, it can be easily satisfied.It not only supports changing Desktop shortcut icons, but also supports changine shortcut icons in the **Start Menu** and **Other Folders**

## Usage

1.In order to use it properly, please grant the software administrator privileges before using it

2.Change or Restore all shortcut icons
* **<font color=#9657db>Purple</font> Button**: <font color=#9657db>Replace</font> all shortcut icons
* **<font color=#b54646>Red</font> Button**: <font color=#b54646>Restore</font> default icons for all shortcuts
* The name of the icon must be named according to the following specifications :

    （1）The full name of the icon is included in the name of the shortcut(e.g. the icon name is "Chrome" and the shortcut name is "Chrome Canary")
    （2）The full name of the shortcut should be included in the name of the icon(e.g. the icon name is "Honkai: Star Rail" and the shortcut name is "Star Rail")

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/change_and_restore.gif)

3.Change the icon of a single shortcut

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/change_one.gif)

4.List context menu
*  Run the shortcut
*  Change the shortcut icon
*  Restore the default icon for the shortcut
*  Rename the shortcut
*  Open the shortcut target directory
*  Adds the non-desktop shortcut to the current user's desktop
*  Supports viewing and copying attributes of shortcuts

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/menu.jpg)

## Other Function

1.Add shortcuts from (Desktop or Start Menu or Other Folder) to the list，and change their icons on the home page

2.Add shortcuts to applications such as UWP/APP to the the desktop

3.Backup shortcuts from the list to a desktop folder

![image](https://github.com/iKineticate/AHK-ChangeIcon/blob/main/Introduction/other_en.png)

## ISSUES：

1.Only support changeing shortcuts icons，temporarily not supporting the replacement of non-.lnk icons(e.g. system icons, exe icons, etc.) for the time being

    Solve: Create a shortcut to the desktop for non shortcut files

2.After some applications are automatically updated, their shortcut icons will automatically return to their default icons

    Solve: Create shortcuts manually——Find it in the application target directory and create a shortcut to the desktop

3.Shortcuts for UWP and WSA applications do not support restoring default icons

    Solve: Re-add shortcuts to UWP or WSA apps to desktop from "other functions"

4.Some shortcuts have not had their icons replaced, but the list shows as replaced (√)

    Cause: The app's shortcut icon is derived from the icon in its (parent/child) directory

5.Unable to change the icon of UWP shortcut in the start menu

    Solve: Add the UWP shortcut to the desktop from the "Other", then change its icon and paste it into the folder of the Start menu, finally fix it to the "Start" Screen in the "All Apps" section of the Start menu

## Recommend:

1.Utility to convert images to icons (.ico) for Windows：[Drop Icons](https://github.com/genesistoxical/drop-icons)

2.Remove Arrows on Shortcut Icons：[Dism++](https://github.com/Chuyu-Team/Dism-Multi-language)

3.Automatically organize your desktop shortcuts icons and running tasks：[Coodesker](https://www.coodesker.com)

## Thanks to

1.Icons source：[iconfont](https://www.iconfont.cn) and [flaticon](https://www.flaticon.com/)

2.GDIP library version 2.0：[AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)

3.Library for setting list colors：[AHK2_LV_Colors](https://github.com/AHK-just-me/AHK2_LV_Colors)

## Updates

1.New window interface and buttons

2.Fix some problems and optimize some codes

3.Removed a function