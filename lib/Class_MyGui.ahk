; If you use this class to create caption, this variable can automatically subtract the height of the caption from the height of button created by the class
; 若创建了caption，则这个变量可以使后续使用CreateButton类创建的按钮控件的高度自动减去标题的高
_caption_h := ""

Class CreateModernGUI
{
    __New( obj:={x:"center", y:"center", w:"", h:"", back_color:"", gui_options:"+DPIScale", gui_name:"", gui_font_options:"s12 Bold cffffff", gui_font:"Microsoft YaHei", show_options:""} )
    {
        If !isObject(obj)
            Return MsgBox("Please create an object for the GUI option`n请在你的CreateModerGui()中创建对象")
        this._SetDefaultsProperties()
        this._SetGuiProperties(obj)
        this._CreateGUI()
    }

    SetFont(options, font)
    {
        MyGui.SetFont(options, font)
    }

    ;========================================================================================================
    ; Create:       Caption
    ; button_w      The width of the close, maximize, and minimize buttons (关闭、最大化、最小化按钮的宽度)
    ; png_quality   The width and height of PNG imagess ("png_quality"是常态PNG图片和活动态PNG图片的宽高)
    ; Note          If using this function, please remember to remove the original caption from MyGui, that is, add "-caption" to the Class--CreateMordenGUI(gui_options:""). So there won't be two title bars
    ;              若创建标题栏，请记得给MyGui移除原来的标题栏，即CreateMordenGUI(gui_options:"")中添加"-caption"，这样就不会有两个标题栏了
    ; Note          After using this function to create the caption, if you don't use this class to create controls , remember to subtract the height of the caption from the "y" value of these controls
    ;              使用这个函数创建标题栏后，若不使用这个类来创建控件，需要记得给这些控件的y值减去标题的高
    ;========================================================================================================   
    CreateCaption( obj:={h:"48", button_w:"72", back_color:"", font_color:"", close_normal_png_base64:'', close_active_png_base64:'', maxi_normal_png_base64:'', maxi_active_png_base64:'', mini_normal_png_base64:'', mini_active_png_base64:'', png_quality:""} )
    {
        ; Change to correct color format, e.g. ffffff (修改为正确的颜色格式)
        For obj_name, descriptor in obj.OwnProps()
        {
            If !Instr(obj_name, "_color")
                Continue
            Switch StrLen(color:=descriptor)
            {
            Case 8  : Obj.%obj_name% := RegExReplace(color,  "i)^0x" )   ; 不能直接obj.obj_name，因为obj_name是值不是变量，使用%name%调用一个名为name的变量，不理解可用不理解可用obj.DefineProp("",{value:""})
            Case 10 : Obj.%obj_name% := RegExReplace(color, "i)^0x..")
            }
        }

        close_button    := CreateButton( {name:"Close",    x:(this.W - obj.button_w),   y:0, w:obj.button_w, h:obj.h} ).PNG( {normal_png_base64:obj.close_normal_png_base64, active_png_base64:obj.close_active_png_base64, png_quality:obj.png_quality} )
        maximize_button := CreateButton( {name:"Maximize", x:(this.W - 2*obj.button_w), y:0, w:obj.button_w, h:obj.h} ).PNG( {normal_png_base64:obj.maxi_normal_png_base64 , active_png_base64:obj.maxi_active_png_base64 , png_quality:obj.png_quality} )
        minimize_button := CreateButton( {name:"Minimize", x:(this.W - 3*obj.button_w), y:0, w:obj.button_w, h:obj.h} ).PNG( {normal_png_base64:obj.mini_normal_png_base64 , active_png_base64:obj.mini_active_png_base64 , png_quality:obj.png_quality} )
        MyGui.AddText("vCaption x0 y0 w" . this.W . " h" . obj.h . " c" . obj.font_color . " Background" . obj.back_color . " +0x4000000 +0x200", "`s`s" . this.gui_name).OnEvent("DoubleClick", (*) => "")
        global _caption_h := obj.h    ; 使后续使用CreateButton类来创建的按钮控件自动减去标题的高
    }

    ;========================================================================================================
    ; Create Windows Control Button（创建关闭、最大化、最小化按钮）
    ;========================================================================================================  
    CreateWindowsControlButton( obj:={margin_top:"", margin_right:"10", button_w:"", button_h:"", pen_width:"", active_color:"", close_color:""} )
    {
        ; Change to correct color format, e.g. active_color=000000, close_color=0xff000000 (修改为正确的颜色格式)
        For obj_name, descriptor in obj.OwnProps()  ; 不能直接obj.obj_name，因为obj_name是值不是变量，使用%name%调用一个名为name的变量，不理解可用不理解可用obj.DefineProp("",{value:""})
        {
            If !Instr(obj_name, "_color")
                Continue
            Switch StrLen(color:=descriptor)
            {
            Case 6 : Obj.%obj_name% := (obj_name="active_color") ? color : "0xff" . color   ; 不能直接obj.obj_name，因为这里的obj_name是一个值不是变量
            Case 8 : Obj.%obj_name% := (obj_name="active_color") ? RegExReplace(color,"i)^0x") : RegExReplace(color, "i)^0x", "0xff")
            Case 10: Obj.%obj_name% := (obj_name="active_color") ? RegExReplace(color, "i)^0x..") : color
            }
        }
        ;=========================================================
        ; Close Button
        ;=========================================================
        local close_button_x := this.w - obj.margin_right - obj.button_w
        local close_button_y := obj.margin_top
        ; 活跃态
        MyGui.AddPicture("vClose_ACTIVE x" . close_button_x . " y" . close_button_y . " w" . obj.button_w . " h" . obj.button_h . " background" . obj.active_color . " +Hidden -E0x200")
        ; 关闭按钮（启动了+DPIScale，且被GDIP绘制，宽高需*(A_ScreenDPI/96) )
        MyGui.AddPicture("vClose_BUTTON x" . close_button_x . " y" . close_button_y . " w" . obj.button_w*(A_ScreenDPI/96) . " h" . obj.button_h*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
        GDIP_CreateCloseButton(MyGui["Close_BUTTON"], obj.close_color, obj.button_w*(A_ScreenDPI/96), obj.button_h*(A_ScreenDPI/96), obj.pen_width)
        MyGui["Close_BUTTON"].OnEvent("Click", ButtonFunc)
        ;=========================================================
        ; Maximize Button
        ;=========================================================
        local max_button_x := this.w - (obj.margin_right + 2*obj.button_w)
        local max_button_y := obj.margin_top
        ; 无活跃态
        ; 最大化按钮
        MyGui.AddPicture("vMaximize_BUTTON x" . max_button_x . " y" . max_button_y . " w" . obj.button_w*(A_ScreenDPI/96) . " h" . obj.button_h*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
        GDIP_CreateMaxButton(MyGui["Maximize_BUTTON"], obj.close_color, obj.button_w*(A_ScreenDPI/96), obj.button_h*(A_ScreenDPI/96), obj.pen_width)
        ;=========================================================
        ; Minimize Button
        ;=========================================================
        local min_button_x := this.w - (obj.margin_right + 3*obj.button_w)
        local min_button_y := obj.margin_top
        ; 活跃态
        MyGui.AddPicture("vMinimize_ACTIVE x" . min_button_x . " y" . min_button_y . " w" . obj.button_w . " h" . obj.button_h . " background" . obj.active_color . " +Hidden -E0x200")
        ; 最小化按钮（启动了+DPIScale，且被GDIP绘制，宽高需*(A_ScreenDPI/96) )
        MyGui.AddPicture("vMinimize_BUTTON x" . min_button_x . " y" . min_button_y . " w" . obj.button_w*(A_ScreenDPI/96) . " h" . obj.button_h*(A_ScreenDPI/96) . " BackgroundTrans +0xE -E0x200")
        GDIP_CreateMiniButton(MyGui["Minimize_BUTTON"], obj.close_color, obj.button_w*(A_ScreenDPI/96), obj.button_h*(A_ScreenDPI/96), obj.pen_width)
        MyGui["Minimize_BUTTON"].OnEvent("Click", ButtonFunc)
    }

    GuiShow(options)
    {
        MyGui.show(options)
    }

    _SetDefaultsProperties()
    {
        this.w := 520
		this.h := 520
        this.back_color := "ffffff"
        this.gui_options := " +DPIScale "
        this.gui_name := "ikineticate"
        this.gui_font := "Microsoft YaHei"
        this.gui_font_options := "s12 Bold cffffff"
        this.show_options := ""
    }

    _SetGuiProperties(obj)
    {
        ; If there is no object, or the value is null, or the value is 'center', then take the default value
        ; 若不存在对象、存在对象但值未空或存在对象但值为"center"，则取默认值
        this.w := Obj.HasOwnProp("w") ? (obj.w ? obj.w : this.w) : this.w
        this.h := Obj.HasOwnProp("h") ? (obj.h ? obj.h : this.h) : this.h
        this.x := Obj.HasOwnProp("x") ? (obj.x ? (!Instr(Trim(obj.x), "center") ? obj.x : "center") : "center") : "center"
        this.y := Obj.HasOwnProp("y") ? (obj.y ? (!Instr(Trim(obj.y), "center") ? obj.y : "center") : "center") : "center"
        ; The color format must comply with formats such as "ffffff" or "0xffffff".If it is in the format such as "0xff000000", remove the "0x**" at the beginning of the color
        ; 颜色格式需符合如ffffff或0xffffff格式，如果像0xff000000格式，则删除颜色文本开头的"0x**
        this.back_color := Obj.HasOwnProp("back_color") ? (obj.back_color ? ( StrLen(obj.back_color)>9 ? RegExReplace(obj.back_color, "i)^0x..") : (obj.back_color ?  obj.back_color : this.back_color)) : this.back_color) : this.back_color
        this.gui_options := Obj.HasOwnProp("gui_options") ? (!obj.gui_options ? this.gui_options : obj.gui_options) : this.gui_options
        this.gui_name := Obj.HasOwnProp("gui_name") ? (!obj.gui_name ? this.gui_name : obj.gui_name) : this.gui_name
        this.gui_font := Obj.HasOwnProp("gui_font") ? (!obj.gui_font ? this.gui_font : obj.gui_font) : this.gui_font
        this.gui_font_options := Obj.HasOwnProp("gui_font_options") ? (!obj.gui_font_options ? this.gui_font_options : obj.gui_font_options) : this.gui_font_options
        this.show_options := Obj.HasOwnProp("show_options") ? obj.show_options : ""
        this.show_options .= " x" . this.x . " y" . this.y . " w" . this.w . " h" . this.h
    }

    _CreateGUI()
    {
        local hwnd
        global
        MyGui := Gui(this.gui_options, this.gui_name)
        hwnd := MyGui.hwnd
        MyGui.BackColor := this.back_color
        MyGui.SetFont(this.gui_font_options, this.gui_font)
        MyGui.OnEvent("Close", (*) => ExitApp())
        MyGui.active_control := False  ; 用于WM_MOUSEMOVE和标签页按钮，最终目的是避免标签页闪烁
        return hwnd
    }
}


;=========================================================
; 创建关闭按钮函数
;=========================================================
GDIP_CreateCloseButton(GuiCtrl, close_color, button_w, button_h, pen_width)
{
    close_picture_h := close_picture_w := button_h/2
    x1 := (button_w - close_picture_w)/2, y1 := (button_h - close_picture_h)/2
    x2 := (x1 + close_picture_w), y2 := y1 + close_picture_h
    x3 := button_w/2, y3 := button_h/2
    x4 := x1, y4 := y2
    x5 := x2, y5 := y1
    points := x1 . "," . y1 . "|" . x2 . "," . y2 . "|" . x3 . "," . y3 . "|" . x4 . "," . y4 . "|" . x5 . "," . y5 

	hwnd := GuiCtrl.Hwnd, GuiCtrl.GetPos(,,&W,&H)

	pBitmap := Gdip_CreateBitmap(W, H), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

    pPen := Gdip_CreatePen(close_color, pen_width), Gdip_DrawLines(G, pPen, points)
    
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap),  SetImage(hwnd, hBitmap)

	Gdip_DeletePen(pPen), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)

	Return 0
}

;=========================================================
; 创建最大化按钮函数
;=========================================================
GDIP_CreateMaxButton(GuiCtrl, close_color, button_w, button_h, pen_width)
{
    max_picture_h := button_h/2
    max_picture_w := max_picture_h * 5/4
    max_picture_X := (button_w - max_picture_w)/2
    max_picture_Y := (button_h - max_picture_h)/2

    hwnd := GuiCtrl.Hwnd, GuiCtrl.GetPos(,,&W,&H)

	pBitmap := Gdip_CreateBitmap(W, H), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

    pPen := Gdip_CreatePen("0xffffffff", (pen_width-1)), Gdip_DrawRoundedRectangle(G, pPen, max_picture_X, max_picture_Y, max_picture_w, max_picture_h, "3")
    
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap),  SetImage(hwnd, hBitmap)

	Gdip_DeletePen(pPen), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)

	Return 0
}

;=========================================================
; 创建最小化按钮函数
;=========================================================
GDIP_CreateMiniButton(GuiCtrl, close_color, button_w, button_h, pen_width)
{
    mini_picture_w := button_w/2.5
    mini_picture_x := (button_w - mini_picture_w)/2
    mini_picture_y := button_h/2

	hwnd := GuiCtrl.Hwnd, GuiCtrl.GetPos(,,&W,&H)

	pBitmap := Gdip_CreateBitmap(W, H), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

    pPen := Gdip_CreatePen(close_color, pen_width), Gdip_DrawLine(G, pPen, mini_picture_x , mini_picture_y, mini_picture_x + mini_picture_w, mini_picture_y)
    
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap),  SetImage(hwnd, hBitmap)

	Gdip_DeletePen(pPen), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)

	Return 0
}