;========================================================================================================
; Class:            Create png/text/logotext/tab button
; Description:      Please add the "ButtonFunc(GuiCtrlObj, Info, *)" Funcontions at the bottom to your main code
;                   请添加"ButtonFunc(GuiCtrlObj, Info, *)"函数到你的代码中
;                   Assign the specified function according to the name of the created button
;                   根据创建按钮的名称来分配指定的功能
; *******************************************************************************************************
; ButtonFunc(GuiCtrlObj, Info, *)
; {
;     ; If Instr(GuiCtrlObj.Name, "Tab_Item_")      ; If you create new tab, need add it
;     ;    Return Tab_Focus(GuiCtrlObj.Text)
;
;     control_btn_name := RegExReplace(GuiCtrlObj.Name, "i)_BUTTON$")
;     Switch control_btn_name
;     {
;     Case "Close"   :ExitApp()
;     Case "Minimize":WinMinimize("A")
;     Case "Change"  :Msgbox("hellow")
;     Case "Click"   :Msgbox("hellow")
;     Case "Add"     :Msgbox("hellow")
;     Case "Delete"  :Msgbox("hellow")
;     }
; }
; *******************************************************************************************************
; Parameters:       GuiCtrlObj                  -   Subclass button control
;                   Case CaseValue              -   Subclass button name
;                   Case CaseValue : Statements -   Function of buttons
;========================================================================================================

Class CreateButton
{
    __New( obj:={name:"", x:"", y:"", w:"", h:""} )
    {
        this._name := obj.name
        this._x := obj.X
        this._y := (_caption_h) ? (obj.Y + _caption_h) : obj.Y
        this._w := obj.W
        this._h := obj.H
    }

    ;========================================================================================================
    ; Create:           PNG Button
    ; Parameters:       *_png_base64    -   Base64 encoding of PNG images
    ;                       norml       -   The state when the button is not clicked or the cursor is not hovering over the button
    ;                       active      -   The state when the button is clicked or the cursor is hovering over the button
    ;                   png_quality     -   The width and height of PNG imagess
    ;========================================================================================================
    PNG( obj:={normal_png_base64:'', active_png_base64:'', png_quality:""} )
    {
        active_name := StrReplace(this._name, "`s") . "_ACTIVE"
        button_name := StrReplace(this._name, "`s") . "_BUTTON"
        ; Normal PNG image (常态的PNG图片)
        MyGui.AddPicture("x" . this._x . " y" . this._y . " w" . this._w . " h" . this._h, "HICON:" Base64PNG_to_HICON(obj.normal_png_base64, obj.png_quality))
        ; 若PNG的Base64不存在或为空，则返回
        If (!obj.HasOwnProp("active_png_base64") or !obj.active_png_base64)
            Return
        ; Active PNG image (活跃态的PNG图片)
        MyGui.AddPicture("x" . this._x . " y" . this._y . " w" . this._w . " h" . this._h . " v" . active_name . " Hidden", "HICON:" Base64PNG_to_HICON(obj.active_png_base64, obj.png_quality))
        ; Top button (顶层按钮) (+0x4000000：Top level buttons are displayed below other controls (顶层控件的显示在其他控件下方) )
        MyGui.AddButton("x" . this._x . " y" . this._y . " w" . this._w . " h" . this._h . " v" . button_name . " -Tabstop +0x4000000").OnEvent("Click", ButtonFunc)
    }

    ;========================================================================================================
    ; Create:           Text Button
    ; Parameters:       norml           -   The state when the button is not clicked or the cursor is not hovering over the button
    ;                   active          -   The state when the button is clicked or the cursor is hovering over the button
    ;                   text_options
    ;                       (1)+0xE     -   Picture control can be drawn by gdip+
    ;                       (2)+0x200"  -   vertical center alignment, but it does not support line breaks
    ;                       (3)center"  -   horizontally center alignment
    ;                   text_margin    -   Add spaces to the left or right of the text depending on the sign of the value(e.g. the value is a positive number, add a space to the left of the text to adjust the text position.)
    ;========================================================================================================
    Text( obj:={R:15, normal_color:"", active_color:"", Text:"", text_options:"+0x200 center", text_margin:"", font_options:"", font:""} )
    {
        default_name := StrReplace(this._name, "`s") . "_NORMAL"
        active_name := StrReplace(this._name, "`s") . "_ACTIVE"
        button_name := StrReplace(this._name, "`s") . "_BUTTON"
        
        ; Change to correct color format, e.g. 0xff000000 (修改为正确的颜色格式，如0xff000000)
        For obj_name, descriptor in obj.OwnProps()
        {
            If !Instr(obj_name, "_color")
                Continue
            Switch StrLen(color:=descriptor)
            {
            Case 6 : Obj.%obj_name% := "0xff" . color   ; 不能直接obj.obj_name，因为obj_name是值不是变量，使用%name%调用一个名为name的变量，不理解可用不理解可用obj.DefineProp("",{value:""})
            Case 8 : Obj.%obj_name% := RegExReplace(color, "i)^0x", "0xff")
            }
        }

        If (obj.HasOwnProp("text_margin") and obj.text_margin!="")
        {
            margin := Format("{:" . Ceil(obj.text_margin) . "}", "`s")
            obj.Text := (obj.text_margin>0) ? (margin . obj.Text) : (obj.Text . margin)
        }

        ; Normal PNG image (常态图片)
        MyGui.AddPicture("x" . this._x . " y" . this._y . " w" . this._w*(A_ScreenDPI/96) . " h" . this._h*(A_ScreenDPI/96) . " v" . default_name . " +0xE -E0x200")
        ; Active PNG image (活跃态图片)
        MyGui.AddPicture("x" . this._x . " y" . this._y . " w" . this._w*(A_ScreenDPI/96) . " h" . this._h*(A_ScreenDPI/96) . " v" . active_name . " +0xE -E0x200 Hidden")
        ; Setting the rounded corners of pictures（设置图片圆角）
        obj.R := Obj.HasOwnProp("R") ? ((obj.R="") ? "0" : obj.R*(A_ScreenDPI/96)) : "0"
        Gdip_SetPicRoundedRectangle(MyGui[default_name], obj.normal_color, obj.r, isFill:="True")
        Gdip_SetPicRoundedRectangle(MyGui[active_name], obj.active_color, obj.r, isFill:="True")
        ; Top text button (顶层文本按钮)
        MyGui.AddText("x" . this._x . " y" . this._y . " w" . this._w . " h" . this._h . " v" . button_name . " BackgroundTrans " . obj.text_options, obj.Text)
        If (obj.HasOwnProp("font_options") and obj.HasOwnProp("font"))
        {
            MyGui[button_name].SetFont(obj.font_options, obj.font)
        }
        ; If the active_color format is 0x00, the control is simply an image and not a button（若活跃态颜色是0x00，则返回，即创建图片而不是按钮）
        If Instr(obj.active_color, "0x00")
            Return
        ; Set the function of the button (设置按钮功能)
        MyGui[button_name].OnEvent("Click", ButtonFunc)
    }

    ;========================================================================================================
    ; Create:           Logo Text Button 
    ; Parameters:       norml           -   The state when the button is not clicked or the cursor is not hovering over the button
    ;                   active          -   The state when the button is clicked or the cursor is hovering over the button
    ;                   text_options
    ;                       (1)+0xE     -   Picture control can be drawn by gdip+
    ;                       (2)+0x200"  -   vertical center alignment, but it does not support line breaks
    ;                       (3)center"  -   horizontally center alignment
    ;                   logo
    ;                       (1)_png_base64  -   Base64 encoding of Logo PNG images
    ;                       (2)_x _y        -   margin inside the control
    ;                       (3)_quality     -   The width and height of Logo PNG imagess
    ;========================================================================================================
    LogoText( obj:={R:15, normal_color:"", active_color:"", Text:"", text_options:"+0x200 center", text_margin:"", font_options:"", font:"", logo_png_base64:'', logo_x:"", logo_y:"", logo_w:"", logo_h:"", logo_quality:""} )
    {
        this.Text(obj)
        If !obj.HasOwnProp("logo_png_base64")
            Return
        obj.logo_h := obj.logo_h
        obj.logo_w := obj.logo_w
        obj.logo_x := trim(obj.logo_x)="center" ? (this._x + (this._w - obj.logo_w) / 2) : (this._x + obj.logo_x)
        obj.logo_y := trim(obj.logo_y)="center" ? (this._y + (this._h - obj.logo_h) / 2) : (this._y + obj.logo_y)
        MyGui.AddPicture("x" . obj.logo_x . " y" . obj.logo_y . " w" . obj.logo_w . " h" . obj.logo_h . " BackgroundTrans", "HICON:" Base64PNG_to_HICON(obj.logo_png_base64, height := obj.logo_quality))
    }

    ;========================================================================================================
    ; Create:           NewTab
    ; Description:      Please add the "tab_prop" object at the bottom to your main code before creating the tab
    ; *******************************************************************************************************
    ; tab_prop := {}
    ; tab_prop.label_name := ["Home", "Other", "Log", "Help", "About"]
    ; tab_prop.label_prop := {distance:"0" ,text_options:"+0x200", font_options:"s10 Bold cffffff", font:"", font_normal_color:"",font_active_color:""}
    ; tab_prop.label_active  := {margin_left:"", margin_top:"", w:"", h:"", R:"5", color:""}
    ; tab_prop.label_indicator := {margin_left:"", margin_top:"", w:"", h:"", R:"5", color:""}
    ; tab_prop.logo_png_base64 := [png_1:='', png_2:='', png_3:='', png_4:='', png_5:='']   ; You can choose not to add a logo
    ; tab_prop.logo_prop := {margin_left:"", margin_top:"", w:"", h:"", quality:""}
    ; *******************************************************************************************************
    ; Parameters:       margin_left    -   The margin-left of the control inside the tab
    ;                   margin_top     -   The margin-top of the control inside the tab
    ;                   logo_png_base64 -   Base64 encoding of Logo PNG images
    ; Note:             The dimensions of the drawn image are influenced by DPI scaling.Therefore, after setting the DPI scaling, the width and height of the picture must be multiplied by the DPI scaling value.
    ;                   GDIP绘制的图片宽高不受"DPI缩放"影响，因此启动+DPIScale后，需给照片控件的宽高*(A_ScreenDPI/96)
    ;                   The two lengths of "logo_png_base64" and "label_name" have to be equal, and their order must also be the same
    ;                   Logo图片的数量需与标签数量相等，且映射顺序一致
    ;========================================================================================================
    NewTab( tab_prop )
    {
        If !isObject(tab_prop)
            Return ExitApp
        ; Set label properties （设置标签属性）
        static label_distance := tab_prop.label_prop.HasOwnProp("distance") ? tab_prop.label_prop.distance:"5"
            ,  active_x       := tab_prop.label_active.margin_left="center" ? this._x + ((this._w - tab_prop.label_active.w) / 2) : (this._x + tab_prop.label_active.margin_left)
            ,  active_y       := tab_prop.label_active.margin_top ="center" ? this._y + ((this._h - tab_prop.label_active.h) / 2) : (this._y + tab_prop.label_active.margin_top )
            ,  active_r       := (tab_prop.label_active.HasOwnProp("R") and tab_prop.label_active.R!="") ? tab_prop.label_active.R*(A_ScreenDPI/96) : "0"
            ,  indicator_x    := tab_prop.label_indicator.margin_left="center" ? this._x + ((this._w - tab_prop.label_indicator.w) / 2) : (this._x + tab_prop.label_indicator.margin_left)
            ,  indicator_y    := tab_prop.label_indicator.margin_top="center" ? this._y + ((this._h - tab_prop.label_indicator.h) / 2) : (this._y + tab_prop.label_indicator.margin_top)
            ,  indicator_r    := (tab_prop.label_indicator.HasOwnProp("R") and tab_prop.label_indicator.R!="") ? tab_prop.label_indicator.R*(A_ScreenDPI/96) : "0"
            ; Set logo properties （设置Logo属性）
        If (tab_prop.HasOwnProp("logo_prop"))
        {
            static logo_h := tab_prop.logo_prop.h
                ,  logo_w := tab_prop.logo_prop.w
                ,  logo_x := trim(tab_prop.logo_prop.margin_left)="center" ? (active_x + (tab_prop.label_active.w - logo_w)/2) : this._x + (tab_prop.logo_prop.margin_left)
                ,  logo_y := trim(tab_prop.logo_prop.margin_top)="center" ? (active_y + (tab_prop.label_active.h - logo_h)/2 + 1) : (active_y + tab_prop.logo_prop.margin_top)
        }
        ; Change to correct color format, e.g. text color: 000000, active color:0xff000000 (修改为正确的颜色格式，如0xff000000)
        For obj_name in tab_prop.OwnProps()
        {
            If !RegExMatch(obj_name, "i)label_prop|label_active|label_indicator")
                Continue
            For color_name, descriptor in tab_prop.%obj_name%.OwnProps()
            {
                If !Instr(color_name, "color")
                    Continue
                Switch StrLen(color := descriptor)
                {
                Case 6  : tab_prop.%obj_name%.%color_name% := (color_name = "color") ? ("0xff" . color) : color
                Case 8  : tab_prop.%obj_name%.%color_name% := (color_name = "color") ? RegExReplace(color, "i)^0x", "0xff") : RegExReplace(color,  "i)^0x")   ; 不能直接obj.obj_name，因为obj_name是值不是变量，使用%name%调用一个名为name的变量，不理解可用不理解可用obj.DefineProp("",{value:""})
                Case 10 : tab_prop.%obj_name%.%color_name% := (color_name = "color") ? color : RegExReplace(color, "i)^0x..")
                }
            }
        }
        ; Create the Tab control （创建标签页控件）
        global Tab := MyGui.AddTab("x0 y0 w0 h0 -wrap -tabstop")
        ; Subsequently created controls are added outside of the Tab control （随后创建的控件不添加在标签页控件内）
        Tab.UseTab()
        ; Loop to create a label to the tab （循环创建标签至标签页）
        Loop tab_prop.label_name.Length
        { 
            actve_name     := StrReplace(tab_prop.label_name[A_Index], "`s") . "_ACTIVE"    ; StrReplace: 控件名称v不支持空格
            indicator_name := StrReplace(tab_prop.label_name[A_Index], "`s") . "_INDICATOR"
            button_name    := StrReplace(tab_prop.label_name[A_Index], "`s") . "_Tab_BUTTON"
            ; Create the label to Hidden the Tab （创建标签至隐藏的标签页）
            Tab.Add([StrReplace(tab_prop.label_name[A_Index], "`s")])    ; 后续的文本按钮文本显示有空格，但文本按钮名称不包含空格，后续Tab_Click函数根据名称来判断，所以创建隐藏Tab也要去空格
            ; Create active/indicator Picture (and Set Rounded Corners) （创建活跃图片、活跃指示器，并设置圆角）
            MyGui.AddPicture("x" . active_x . " y" . ((this._h + label_distance)*(A_Index-1) + active_y) . " w" . tab_prop.label_active.w*(A_ScreenDPI/96) . " h" . tab_prop.label_active.h*(A_ScreenDPI/96) . " v" . actve_name . " backgroundtrans +0xE -E0x200 Hidden")
            MyGui.AddPicture("x" . indicator_x . " y" . ((this._h + label_distance)*(A_Index-1) + indicator_y) . " w" . tab_prop.label_indicator.w*(A_ScreenDPI/96) . " h" . tab_prop.label_indicator.h*(A_ScreenDPI/96) . " v" . indicator_name . " backgroundtrans +0xE -E0x200 Hidden")
            Gdip_SetPicRoundedRectangle(MyGui[actve_name], tab_prop.label_active.color, active_r, isFill:="True")
            Gdip_SetPicRoundedRectangle(MyGui[indicator_name], tab_prop.label_indicator.color, indicator_r, isFill:="True")
            ; Create logo （创建Logo）
            If (tab_prop.HasOwnProp("logo_prop") and tab_prop.HasOwnProp("logo_png_base64"))
            {
                If tab_prop.label_name.Capacity != tab_prop.logo_png_base64.Capacity
                     Return (MsgBox("标签数量与图标数量不等, 或格式不正确"))
                MyGui.AddPicture("x" . logo_x . " y" . ((this._h + label_distance)*(A_Index-1) + logo_y) . " w" . logo_w . " h" . logo_h . " BackgroundTrans", "HICON:" Base64PNG_to_HICON(tab_prop.logo_png_base64[A_Index], height := tab_prop.logo_prop.quality))
            }
            ; Create the label to Visible the Tab ( as a top text button) （创建标签至显示的标签页，并作为顶部的文本按钮）
            MyGui.AddText("x" . this._x . " y" (this._y + (this._h + label_distance)*(A_Index-1)) . " h" . this._h . " w" . this._w . " v" . button_name .  " BackgroundTrans +0x200 " . tab_prop.label_prop.text_options, tab_prop.label_name[A_Index])
            MyGui[button_name].SetFont(tab_prop.label_prop.font_options, tab_prop.label_prop.font)
            MyGui[button_name].OnEvent("Click", ButtonFunc)
            ; Setting the first label to be the default label （设置第一个标签为默认标签，即设置第一个标签是活跃态）
            If (A_Index != 1)
                Continue
            MyGui.Focus_Tab := MyGui[button_name]
            MyGui[actve_name].Visible  := True
            MyGui[indicator_name].Visible := True
            MyGui[button_name].SetFont("c" . tab_prop.label_prop.font_active_color)
        }
    }
}


Gdip_SetPicRoundedRectangle(GuiCtrl, Color, R, isFill)
{
    hwnd := GuiCtrl.Hwnd        ; 获取控件hWnd
    GuiCtrl.GetPos(,,&W,&H)     ; 获取控件的宽高

    pBitmap := Gdip_CreateBitmap(W, H)      ; 创建和控件大小相等的BMP位图
    G := Gdip_GraphicsFromImage(pBitmap)    ; 创建画布(在BMP位图上)
    Gdip_SetSmoothingMode(G, 4)             ; 设置画布平滑模式为抗锯齿
    
    If isFill="True"
    {
        ; 创建实心圆角矩形背景（注意笔刷画图的xy是相对位图距离，不是窗口距离）
        pBrushBack := Gdip_BrushCreateSolid(Color)
        ;pBrushBack := Gdip_CreateLineBrushFromRect(0, 0, w, h, color, 0xff485563, LinearGradientMode:=0, WrapMode:=1)
        Gdip_FillRoundedRectangle(G, pBrushBack, 0, 0, W-1, H-1, R*(A_ScreenDPI/192))
        Gdip_DeleteBrush(pBrushBack)
    }
    Else
    {
        pPen := Gdip_CreatePen(Color, isFill)
        Gdip_DrawRoundedRectangle(G, pPen, 0, 0, w-1, h-1, R*(A_ScreenDPI/192))   ; "w-1" and "h-1" can make the border appear completely on the picture control
        Gdip_DeletePen(pPen)
    }

    ; 创建与控件相关联的位图（让hBitmap和pBitmap相关联，后续可以把图片控件变成上面创建好的BMP位图）
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)

    ; 开始删除
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)

    Return 0
}
