; ================================================================
; Author:   TheArkive
; Github:   https://github.com/TheArkive/ListIcons_ahk2
; ListIcons class
;
;   Methods:
;
;       icons.GetResourceList(sFileName)
;
;           USAGE: array := icons.GetResourceList(sFileName)
;           
;           - Checks %SystemRoot%, %SystemRoot%\System32, and A_ScriptDir for sFileName, or
;             just use a full path.
;           - Returns array of resource names (ie. #1, #32, #16315, sometimes text names too)
;
;       icons.IconPicker(sIconFile:="", parentHwnd:=0, resources:=true)
;
;           USAGE: obj := icons.IconPicker(...)
;           
;           - Specify sIconFile, or pick from the gui list.
;           - Specify parentHwnd of parent window for modal effect.
;           - Specify resources as false to show index numbers in the list instead of resource names.
;           - Return obj has the following properties:
;               type:   HICON, HBITMAP, HCURSOR
;               index:  1-based index number
;               file:   The file the icon was found in.
;               name:   The resource name of the icon.  Use with DllCall("LoadImage").
; ================================================================

class ListIcons {
    Static IconSelectFileList := ["%SystemRoot%\explorer.exe"
                                , "%SystemRoot%\system32\accessibilitycpl.dll", "%SystemRoot%\system32\SensorsCpl.dll"
                                , "%SystemRoot%\system32\ddores.dll"          , "%SystemRoot%\system32\setupapi.dll"
                                , "%SystemRoot%\system32\gameux.dll"          , "%SystemRoot%\system32\shell32.dll"
                                , "%SystemRoot%\system32\imageres.dll"        , "%SystemRoot%\system32\UIHub.dll"
                                , "%SystemRoot%\system32\mmcndmgr.dll"        , "%SystemRoot%\system32\vpc.exe"
                                , "%SystemRoot%\system32\mmres.dll"           , "%SystemRoot%\system32\wmp.dll"
                                , "%SystemRoot%\system32\mstscax.dll"         , "%SystemRoot%\system32\wmploc.dll"
                                , "%SystemRoot%\system32\netshell.dll"        , "%SystemRoot%\system32\wpdshext.dll"
                                , "%SystemRoot%\system32\networkmap.dll"      , "%SystemRoot%\system32\wucltux.dll"
                                , "%SystemRoot%\system32\pifmgr.dll"          , "%SystemRoot%\system32\xpsrchvw.exe"]
    
    Static GetResourceList(str) { ; str = file name
        fileLoc := [str, A_WinDir "\" str,A_WinDir "\System32\" str]
        iconFileExist   := false, sFileName := ''
        
        For A_index, sFile in fileLoc {
            If !FileExist(sFile)
                Continue
            iconFileExist := true, sFileName := sFile
        }

        If !iconFileExist {
            Msgbox "Specified file does not exist.`r`n`r`nSpecifically:    " str
            return
        }
        
        hModule := DllCall("GetModuleHandle", "Str", sFileName, "UPtr"), unload := False
        (!hModule) ? (hModule := DllCall("LoadLibrary", "Str", sFileName, "UPtr"), unload := True) : False
        ; If !hModule
        ;     hModule := DllCall("LoadLibrary", "Str", sFileName, "UPtr"), unload := true
        
        cbAddr := CallbackCreate(ObjBindMethod(this,"EnumIcons",List:=[]),,4)
        r1 := DllCall("EnumResourceNames", "UPtr", hModule, "Str", "#14", "UPtr", cbAddr, "UPtr", 0) ; #14
        CallbackFree(cbAddr)
        
        unload ? DllCall("FreeLibrary", "UPtr", hModule) : ''
        
        return List
    }

    Static EnumIcons(List, hModule, sType, sName, lParam) { ; callback for DllCall("EnumResourceNames")
        str := (StrLen(sName) > 5) ? StrGet(sName) : ''
        val := str ? str : "#" sName
        List.Push(val)
        
        return true
    }

    Static AddIconsToList(objLV, IconFile) {
        If IconFile {
            str := IconFile
            fileLoc := [str, A_WinDir "\" str, A_WinDir "\System32\" str], iconFileExist := false

            For A_Index, sFile in fileLoc {
                If !FileExist(sFile)
                    Continue
                IconFile := sFile, iconFileExist := true
            }

            If !iconFileExist {
                Throw Error("Specified file does not exist.",,str)
            }
        }

        IconFile := StrReplace(IconFile, "%SystemRoot%", A_WinDir)

        If FileExist(IconFile) {
            iList := this.GetResourceList(IconFile)
            objLV.IconIndexArray := []

            objLV.Delete()
            objLV.Opt("-Redraw")
            
            ImgList := IL_Create(400,5,1)
            objLV.SetImageList(ImgList,0)
            
            For A_Index, resName in iList {
                hPic   := LoadPicture(IconFile, "Icon" A_Index, &handleType)
                prefix := !handleType ? "HBITMAP" : ((handleType = 2) ? "HCURSOR" : "HICON")
                
                objLV.IconIndexArray.Push({type:prefix, name:resName, index:A_Index, file:IconFile})
                objLV.Add("Icon" A_Index, A_Index, resName)

                IL_Add(ImgList, prefix ":" hPic)
                DllCall("DestroyIcon", "ptr", hPic)
            }

            objLV.Opt("+Redraw")
        } Else {
            Msgbox "Invalid file selected."
        }
    }

/*
    Static IconPicker(sIconFile:="", hwnd:=0, resources:=true) {
        this.resources := resources
        If sIconFile {
            str := sIconFile
            fileLoc := [str, A_WinDir "\" str, A_WinDir "\System32\" str], iconFileExist := false, sFileName := ""

            For A_Index, sFile in fileLoc {
                If !FileExist(sFile)
                    Continue
                sIconFile := sFile, iconFileExist := true
            }

            If !iconFileExist {
                throw Error("Specified file does not exist.",,str)
            }
        }
        
        newList := []
        For i, file_name In this.IconSelectFileList
            If (FileExist(StrReplace(file_name,"%SystemRoot%",A_WinDir)))
                newList.Push(file_name)
        this.IconSelectFileList := newList
        
        hwndStr := WinExist("ahk_id " hwnd) ? " +Owner" hwnd : ""

        IconSelectUserGui := Gui("-MaximizeBox -MinimizeBox" hwndStr,"List Icons")
        IconSelectUserGui.OnEvent("close",this.gui_close.Bind(this))
        IconSelectUserGui.IconSelectIndex := ""
        
        IconSelectUserGui.Add("Text","","File:")
        ctl := IconSelectUserGui.Add("ComboBox","vIconFile x+m yp-3 w420",this.IconSelectFileList)
        
        ctl.OnEvent("change",this.gui_events.Bind(this)) ; ObjBindMethod(this,"gui_events")
        ctl.Text := sIconFile
        
        ctl := IconSelectUserGui.Add("Button","vPickFileBtn x+m yp w20","...")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        LV := IconSelectUserGui.Add("ListView","vIconList xm w480 h220 Icon")
        LV.OnEvent("doubleclick",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vOkBtn x+-150 y+5 w75","OK")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vCancelBtn x+0 w75","Cancel")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vSwitch x+-480 w75","Show Index")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        If (WinExist("ahk_id " hwnd)) {
            p := GuiFromHwnd(hwnd)
            p.GetPos(&x,&y,&w,&h), pPos := {x:x, y:y, w:w, h:h}
            x := pPos.x + (pPos.w / 2) - (261 * (A_ScreenDPI / 96))
            y := pPos.y + (pPos.h / 2) - (149 * (A_ScreenDPI / 96))
            params := "x" x " y" y
            IconSelectUserGui.Show(params)
        } Else
            IconSelectUserGui.Show()
        
        (sIconFile) ? this.IconSelectListIcons(IconSelectUserGui,sIconFile) : ""
        sIconFile := StrReplace(IconSelectUserGui["IconFile"].Text,"%SystemRoot%",A_WinDir)
        
        Pause
        
        If (idx := IconSelectUserGui.IconSelectIndex) {
            If !(IconSelectUserGui.IconIndexArray.Has(idx)) {
                For index, obj in IconSelectUserGui.IconIndexArray {
                    If (obj.name = idx) {
                        oOutput := obj
                        Break
                    }
                }
            } Else
                oOutput := IconSelectUserGui.IconIndexArray[idx]
        } Else
            oOutput := {index:0, type:"", file:"", name:""}
        
        IconSelectUserGui.Destroy()
        
        return oOutput
    }

    Static gui_events(ctl, info) {
        If (ctl.Name = "IconFile") {
            IconFile := StrReplace(ctl.Text,"%SystemRoot%",A_WinDir)
            this.IconSelectListIcons(ctl.gui,IconFile)
        } Else If (ctl.Name = "PickFileBtn") {
            IconFile := ctl.gui["IconFile"]
            IconFileStr := FileSelect("","C:\Windows\System32","Select an icon file:")
            
            If (IconFileStr)
                this.IconSelectListIcons(ctl.gui,IconFileStr)
        } Else if (ctl.Name = "IconList" Or ctl.Name = "OkBtn") {
            curCtl := ctl.gui["IconList"]
            curRow := curCtl.GetNext()
            
            If !curRow {
                Msgbox "No icon selected."
                return
            }
            
            ctl.gui.IconSelectIndex := curCtl.GetText(curRow)
            If ctl.Name = "OkBtn"
                Pause false
        } Else If (ctl.Name = "CancelBtn") {
            ctl.gui.IconSelectIndex := 0
            Pause false
        } Else If (ctl.Name = "Switch") {
            LV := ctl.gui["IconList"]
            
            If (ctl.Text = "Show Index") {
                Loop LV.GetCount()
                    LV.Modify(A_Index,,ctl.gui.IconIndexArray[A_Index].Index)
                ctl.Text := "Show Name"
            } Else {
                Loop LV.GetCount()
                    LV.Modify(A_Index,,ctl.gui.IconIndexArray[A_Index].Name)
                ctl.Text := "Show Index"
            }
        }
    }
    
    Static gui_close(_gui) {
        _gui.IconSelectIndex := 0
        Pause false
    }

    Static IconSelectListIcons(oGui, IconFile) {
        IconFile := StrReplace(IconFile, "%SystemRoot%", A_WinDir)
        If (FileExist(IconFile)) {
            iList := this.GetResourceList(IconFile)
            oGui.IconIndexArray := []
            
            oGuiLV := oGui["IconList"]
            oGuiLV.Delete()
            oGuiLV.Opt("-Redraw")
            
            ImgList := IL_Create(400,5,1)
            oGuiLV.SetImageList(ImgList,0)
            
            MaxIcons := 0
            For A_Index, resName in iList {
                hPic   := LoadPicture(IconFile,"Icon" A_Index, &handleType)
                prefix := !handleType ? "HBITMAP" : ((handleType = 2) ? "HCURSOR" : "HICON")
                idx    := (this.resources) ? resName : A_Index
                
                oGui.IconIndexArray.Push({type:prefix, name:resName, index:A_Index, file:IconFile})
                oGuiLV.Add("Icon" A_Index,((this.resources) ? resName : A_Index))

                IL_Add(ImgList, prefix ":" hPic)
                DllCall("DestroyIcon", "ptr", hPic)
            }
            
            oGuiLV.Opt("+Redraw")
        } Else
            Msgbox "Invalid file selected."
    }
*/
}