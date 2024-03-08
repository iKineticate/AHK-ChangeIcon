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
    CreateCaption( obj:={caption_h:"", title_color:"", back_color:"", button_w:"", button_active_color:""} )
    {
        ; Change to the correct colour format (e.g. ffffff)
        For obj_name, descriptor in obj.OwnProps()
        {
            If !RegExMatch(obj_name, "back_color|title_color")  ; 不需要格式化"button_active_color"
                Continue
            Switch StrLen(color:=Trim(descriptor))
            {   ; 不可直接使用obj.obj_name，obj_name是值不是变量，使用%name%调用一个名为name的变量
            Case 4  : Obj.%obj_name% := "000000"    ; 避免输入trans
            Case 8  : Obj.%obj_name% := RegExReplace(color,  "i)^0x" )
            Case 10 : Obj.%obj_name% := RegExReplace(color, "i)^0x..")
            }
        }
        ; Create Windows Ctrl button
        this.CreateWindowsControlButton({margin_top:"0", margin_right:"0", button_w:obj.button_w, button_h:obj.caption_h, active_color:obj.button_active_color, symbol_backcolor:obj.back_color})
        ; Create a title for the caption
        MyGui.AddText("vCaption x0 y0 w" . this.W . " h" . obj.caption_h . " c" . obj.title_color . " Background" . obj.back_color . " +0x4000000 +0x200", "`s`s" . this.gui_name).OnEvent("DoubleClick", (*) => "")
        global _caption_h := obj.caption_h    ; 使后续使用CreateButton类来创建的按钮控件自动减去标题的高
    }

    ;========================================================================================================
    ; Create Windows Control Button（创建关闭、最大化、最小化按钮）
    ;========================================================================================================  
    CreateWindowsControlButton( obj:={margin_top:"", margin_right:"", button_w:"", button_h:"", active_color:"", symbol_backcolor:""} )
    {
        ; Change to the correct colour format (e.g. 000000)
        Switch StrLen(color:=Trim(obj.active_color))
        {
        Case 6 : obj.active_color:=  color   ; 不能直接obj.obj_name，因为这里的obj_name是一个值不是变量
        Case 8 : obj.active_color:= RegExReplace(color,"i)^0x")
        Case 10: obj.active_color:= RegExReplace(color, "i)^0x..")
        }

        ; Create Windows Control Buttons (Replace button icons with font symbols) (创建文本符号的控制窗口按钮)
        For key, value in map("Close", "0x2716", "Maximize", "0x25A2", "Minimize", "0xE0B8")
        {
            active_name := key . "_ACTIVE"
            button_name := key . "_BUTTON"
            button_x := this.w - (obj.margin_right + A_Index * obj.button_w)
            button_y := obj.margin_top
            (!obj.HasOwnProp("symbol_backcolor")) ? "" : MyGui.AddPicture("x" . button_x . " y" . button_y . " w" . obj.button_w . " h" . obj.button_h . " background" . obj.symbol_backcolor . " -E0x200")
            ; 活跃态
            (key="Maximize") ? "" : MyGui.AddPicture("v" active_name " x" . button_x . " y" . button_y . " w" . obj.button_w . " h" . obj.button_h . " background" . obj.active_color . " +Hidden -E0x200")
            ; 文本按钮
            FontSymbol( {name:button_name, x:button_x, y:button_y, w:obj.button_w, h:obj.button_h, unicode:value, font_name:"Segoe UI Symbol", text_color:"ffffff", back_color:"Trans", font_options:"s" obj.button_h/2, text_options:"+0x200 center"} )
            (key="Maximize") ? "" : MyGui[button_name].OnEvent("Click", ButtonFunc)            
        }
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
        this.w := Obj.HasOwnProp("w") ? (obj.w ? obj.w : this.w) : this.w
        this.h := Obj.HasOwnProp("h") ? (obj.h ? obj.h : this.h) : this.h
        this.x := Obj.HasOwnProp("x") ? (obj.x ? (!Instr(Trim(obj.x), "center") ? obj.x : "center") : "center") : "center"
        this.y := Obj.HasOwnProp("y") ? (obj.y ? (!Instr(Trim(obj.y), "center") ? obj.y : "center") : "center") : "center"
        ; Change to the correct color format (e.g. ffffff)
        If !obj.HasOwnProp("back_color") or !obj.back_color
        {
            this.back_color := "ffffff"
        }
        Else
        {
            this.back_color:= (StrLen(obj.back_color)=8)  ? RegExReplace(obj.back_color, "i)^0x")   : obj.back_color
            this.back_color:= (StrLen(obj.back_color)=10) ? RegExReplace(obj.back_color, "i)^0x..") : obj.back_color
        }
        
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
; 创建文字符号
;=========================================================
FontSymbol( obj:={name:"", x:"", y:"", w:"", h:"", unicode:"", font_name:"", text_color:"", back_color:"", font_options:"", text_options:"+0x200 center"} )
{
    If !IsObject(obj)
        Return
    For obj_name, descriptor in obj.OwnProps()
    {
        If !Instr(obj_name, "color")
            Continue
        Switch StrLen(color:=descriptor)
        {
        Case 6  : obj.%obj_name% := (obj_name="text_color") ? "c" color : "Background" . color
        Case 8  : obj.%obj_name% := (obj_name="text_color") ? "c" RegExReplace(color,"i)^0x") : "Background" . RegExReplace(color,"i)^0x")
        Case 10 : obj.%obj_name% := (obj_name="text_color") ? "c" RegExReplace(color, "i)^0x..") : "Background" . RegExReplace(color, "i)^0x..")
        Default : obj.%obj_name% := (obj_name="text_color") ? "cffffff" : "BackgroundTrans"
        }
    }
    text := MyGui.AddText("v" RegExReplace(obj.name,"`s") " x" obj.x " y" obj.y " w" obj.w " h" obj.h " " obj.back_color " " obj.text_options, chr(obj.unicode))
    text.SetFont(obj.font_options " " obj.text_color, Trim(obj.font_name))
}