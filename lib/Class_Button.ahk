;===============================================================================================================
; Class:            Create png/text/newTab button
; Description:      Please add the "ButtonFunc(GuiCtrlObj, Info, *)" Funcontions at the bottom to your main code
;                   请添加"ButtonFunc(GuiCtrlObj, Info, *)"函数到你的代码中
;                   Assign the specified function according to the name of the created button
;                   根据创建按钮的名称来分配指定的功能
;===============================================================================================================
/*
    e.g.
    MyGui := GUI()
    MyGui.Button := CreateButton(MyGui)
    MyGui.Button.PNG( {name:'testButton1', x:0 , y:0, w:80, h:40, normal:Base64_PNG_Unclicked, active:Base64_PNG_Click, pngQuality:'300'} )
    MyGui.Button.Text( {name:'testButton2', x:0, y:50, w:80, h:40, R:10, normalColor:'0x26ffffff', activeColor:'909090', text: 'Hellow', textOpt:'+0x200', textHorizontalMargin:4, fontOpt:'c4B6A87 s10', font:''} )
    MyGui.Button.OnEvent('testButton1', 'Click', (*)=>Exist)
    MyGui.Button.Obj['testButton1'] = MyGui['testButton1_BUTTON']
    MyGui.Button.Obj['testButton1'].OnEvent('Click', (*)=>Exist)
*/

Class CreateButton
{
    __New( GuiObj ) => (this.GUI := GuiObj, this.Obj := map())

    OnEvent(GuiCtrlName, EventName, Callback, AddRemove:=1) => this.Obj[GuiCtrlName].OnEvent(EventName, Callback, AddRemove)

    ;===========================================================================================================================
    ; Create:           PNG Button
    ; Parameters:       pngQuality  - The width and height of PNG imagess
    ;                   norml    - Base64 encoding of PNG images, The state when the button is not clicked or the cursor is not hovering over the button
    ;                   active   - Base64 encoding of PNG images, The state when the button is clicked or the cursor is hovering over the button      
    ;===========================================================================================================================
    PNG(obj:={name:"", x:"", y:"", w:"", h:"", normal:'', active:'', pngQuality:""}) {
        If !IsObject(obj)
            Return ExitApp

        activeName := RegExReplace(obj.name, "[\s\r\n]+") . "_ACTIVE"
        buttonName := RegExReplace(obj.name, "[\s\r\n]+") . "_BUTTON"
        ; Active PNG image (活跃态的PNG图片)
        this.GUI.AddPicture("v" activeName " x" obj.x " y" obj.y " w" obj.w " h" obj.h " Hidden", "HICON:" Base64PNGToHICON(obj.active, obj.pngQuality))
            ; Normal PNG image Button (+0x4000000：Top level buttons are displayed below other controls (顶层控件的显示在其他控件下方) )
            this.GUI.AddPicture("v" buttonName " x" obj.x " y" obj.y " w" obj.w " h" obj.h ' +0x4000000', "HICON:" Base64PNGToHICON(obj.normal, obj.pngQuality))
        this.Obj[obj.name] := this.GUI[buttonName]
    }


    ;===========================================================================================================================
    ; Create:           Text Button
    ; Parameters:       norml  - The state when the button is not clicked or the cursor is not hovering over the button
    ;                   active - The state when the button is clicked or the cursor is hovering over the button
    ;                   textOpt
    ;                       (1)+0xE   - Picture control can be drawn by gdip+
    ;                       (2)+0x200 - vertical center alignment, but it does not support line breaks
    ;                       (3)center - horizontally center alignment
    ;                   textHorizontalMargin - Horizontal distance of the text control
    ;===========================================================================================================================
    Text( obj:={name:"", x:"", y:"", w:"", h:"", R:"", normalColor:"", activeColor:"", Text:"", textOpt:"+0x200 center", textHorizontalMargin:"", fontOpt:"", font:""} ) {
        If !IsObject(obj)
            Return ExitApp

        noSpacesName := RegExReplace(obj.name, "[\s\r\n]+")
        defaultName  := noSpacesName . "_NORMAL"
        activeName   := noSpacesName . "_ACTIVE"
        buttonName   := noSpacesName . "_BUTTON"
        obj.R        := (!obj.R) ? "0" : obj.R*(A_ScreenDPI/96)

        For propName, value in obj.OwnProps() {    ; Change the color format to the correct one (e.g. 0xff000000)
            If !Instr(propName, "Color")
                Continue
            Switch StrLen(color := Trim(value)) {
                Case 6 : obj.%propName% := "0xff" color   ; 不能直接obj.propName，因为propName是值不是变量，使用%name%调用一个名为name的变量，不理解可用不理解可用obj.DefineProp("",{value:""})
                Case 8 : obj.%propName% := LTrim(color, "0x") . "0xff"
            }
        }

        ; text margin left（文本距离该控件左侧的距离）
        If (obj.HasOwnProp("textHorizontalMargin") and (obj.textHorizontalMargin>0)) {
            margin   := Format("{:" . Ceil(obj.textHorizontalMargin) . "}", A_Space)
            obj.Text := (obj.textHorizontalMargin > 0) ? (margin . obj.Text) : (obj.Text . margin)
        }
        ; Normal PNG image (常态图片)
        If !Instr(obj.normalColor, "0x00") {
            this.GUI.AddPicture("v" defaultName " x" obj.x " y" obj.y " w" obj.w*(A_ScreenDPI/96) " h" obj.h*(A_ScreenDPI/96) " +0xE -E0x200 BackgroundTrans")
            Gdip_SetPicRoundedRectangle(this.GUI[defaultName], obj.normalColor, obj.r, isFill:="True")
        }
        ; Active PNG image (活跃态图片)
        If !Instr(obj.activeColor, "0x00") {
            this.GUI.AddPicture("v" activeName " x" obj.x " y" obj.y " w" obj.w*(A_ScreenDPI/96) " h" obj.h*(A_ScreenDPI/96) " +0xE -E0x200 Hidden BackgroundTrans")
            Gdip_SetPicRoundedRectangle(this.GUI[activeName], obj.activeColor, obj.r, isFill:="True")
        }
        ; Top text button (顶层文本按钮)
        this.GUI.AddText("v" buttonName " x" obj.x " y" obj.y " w" obj.w " h" obj.h " BackgroundTrans " obj.textOpt, obj.Text)
        this.GUI[buttonName].SetFont(obj.fontOpt, obj.font)
        this.Obj[obj.name] := this.GUI[buttonName]
        ; If Instr(obj.activeColor, "0x00")    ; If the activeColor format is 0x00, the control is simply an image and not a button
        ;     Return
        ; this.GUI[buttonName].OnEvent("Click", ButtonFunc)    ; Set the function of the top text button
    }


    ;========================================================================================================
    ; Create:           NewTab
    ; Description:      Please add the "tabProp" object at the bottom to your main code before creating the tab
    ; *******************************************************************************************************
    ; tabProp             := {x:'', y:'', w:'', h:''}
    ; tabProp.labelName   := ['Home', 'Other', 'Log', 'Help', 'About']    ; 输入空格来调整标签按钮里的文本相对按钮的x位置
    ; tabProp.labelProp   := {distance:'0' ,textOpt:"+0x200", fontOpt:"s10 Bold cffffff", font:"", fontNormalColor:"",fontActiveColor:""}
    ; tabProp.labelActive := {marginLeft:"", marginTop:"", w:"", h:"", R:"5", color:""}
    ; ; --Can--be--selectively--added-- (可以选择性添加以下对象)
    ; tabProp.labelIndicator := {marginLeft:"", marginTop:"", w:"", h:"", R:"5", color:""}
    ; ; --Can--be--selectively--added-- (可以选择性添加以下对象)
    ; tabProp.logoSymbol  := {marginLeft:'', fontName:'Segoe UI Symbol'}
    ; tabProp.logoSize    := ["", "", "", "", ""]
    ; tabProp.logoUnicode := ["", "", "", "", ""]
    ; *******************************************************************************************************
    ; Parameters:       marginLeft     - The margin-left of the control inside the tab
    ;                   marginTop      - The margin-top of the control inside the tab
    ;                   logo_png_base64 - Base64 encoding of Logo PNG images
    ; Note:             (1)The dimensions of the drawn image are influenced by DPI scaling.Therefore, after setting the DPI scaling, the width and height of the picture must be multiplied by the DPI scaling value.
    ;                   GDIP绘制的图片宽高不受"DPI缩放"影响，因此启动+DPIScale后，需给照片控件的宽高*(A_ScreenDPI/96)
    ;                   (2)The two lengths of "logo_png_base64" and "labelName" have to be equal, and their order must also be the same
    ;                   Logo图片的数量需与标签数量相等，且映射顺序一致
    ;========================================================================================================
    NewTab(tabProp) {
        If !IsObject(tabProp)
            Return ExitApp
        ; Set label properties
        static labelDistance := tabProp.labelProp.HasOwnProp("distance") ? tabProp.labelProp.distance:"5"
            ,  activeX       := tabProp.labelActive.marginLeft="center"  ? tabProp.x + ((tabProp.w - tabProp.labelActive.w) / 2) : (tabProp.x + tabProp.labelActive.marginLeft)
            ,  activeY       := tabProp.labelActive.marginTop ="center"  ? tabProp.y + ((tabProp.h - tabProp.labelActive.h) / 2) : (tabProp.y + tabProp.labelActive.marginTop )
            ,  activeR       := (tabProp.labelActive.HasOwnProp("R") and tabProp.labelActive.R!="") ? tabProp.labelActive.R*(A_ScreenDPI/96) : "0"
        ; Set indicator properties
        If (tabProp.HasOwnProp("labelIndicator")) {
            static indicatorX := tabProp.labelIndicator.marginLeft="center" ? tabProp.x + ((tabProp.w - tabProp.labelIndicator.w) / 2) : (tabProp.x + tabProp.labelIndicator.marginLeft)
            ,      indicatorY := tabProp.labelIndicator.marginTop ="center" ? tabProp.y + ((tabProp.h - tabProp.labelIndicator.h) / 2) : (tabProp.y + tabProp.labelIndicator.marginTop)
            ,      indicatorR := (tabProp.labelIndicator.HasOwnProp("R") and tabProp.labelIndicator.R!="") ? tabProp.labelIndicator.R*(A_ScreenDPI/96) : "0"
        }        
        ; Set logo properties
        If (tabProp.HasOwnProp("logoSymbol")) {
            static symbolX := tabProp.logoSymbol.marginLeft="center" ? tabProp.x : (tabProp.x + tabProp.logoSymbol.marginLeft)
            ,      symbolY := tabProp.y
            ,      symbolW := tabProp.h
            ,      symbolH := tabProp.h
        }
        ; Change to the correct colour format (e.g. text color:=000000, active color:=0xff000000)
        For propName in tabProp.OwnProps() {
            If !RegExMatch(propName, "i)labelProp|labelActive|labelIndicator")
                Continue
            For colorName, value in tabProp.%propName%.OwnProps() {
                If !Instr(colorName, "color")
                    Continue
                Switch StrLen(color := Trim(value)) {
                    Case 6  : tabProp.%propName%.%colorName% := (colorName = "color") ? ("0xff" . color) : color
                    Case 8  : tabProp.%propName%.%colorName% := (colorName = "color") ? (LTrim(color, "0x") . "0xff") : LTrim(color, "0x")
                    Case 10 : tabProp.%propName%.%colorName% := (colorName = "color") ? color : LTrim(color, "0x")
                }
            }
        }
        ; Create the Tab control
        global Tab := this.GUI.AddTab("x0 y0 w0 h0 -wrap -tabstop")
        Tab.UseTab()
        ; Loop to create labels to the tab
        Loop tabProp.labelName.Length { 
            labelNoSpacesName := RegExReplace(tabProp.labelName[A_Index], "[\s\r\n]+")    ; 使用StrReplace原因: 控件的Opt中，命名时v后不支持空格，因此命名时需去除对象的'labelName'中的空格
            activeName    := labelNoSpacesName . "_ACTIVE"
            focusName     := labelNoSpacesName . "_FOCUS"
            indicatorName := labelNoSpacesName . "_INDICATOR"
            buttonName    := labelNoSpacesName . "_Tab_BUTTON"
            symbolName    := labelNoSpacesName . "_SYMBOL"

            ; Create the "label" to Hidden the Tab
            Tab.Add([labelNoSpacesName])
            ; Create "active" Picture (and Set Rounded Corners)
            this.GUI.AddPicture("v" activeName " x" activeX " y" ((tabProp.h + labelDistance)*(A_Index-1) + activeY) " w" tabProp.labelActive.w*(A_ScreenDPI/96) " h" tabProp.labelActive.h*(A_ScreenDPI/96) " backgroundtrans +0xE -E0x200 Hidden")
            Gdip_SetPicRoundedRectangle(this.GUI[activeName], "0x1AFFFFFF", activeR, isFill:="True")
            ; Create "focus" Picture (and Set Rounded Corners)
            this.GUI.AddPicture("v" focusName " x" activeX " y" ((tabProp.h + labelDistance)*(A_Index-1) + activeY) " w" tabProp.labelActive.w*(A_ScreenDPI/96) " h" tabProp.labelActive.h*(A_ScreenDPI/96) " backgroundtrans +0xE -E0x200 Hidden")
            Gdip_SetPicRoundedRectangle(this.GUI[focusName], tabProp.labelActive.color, activeR, isFill:="True")          
            ; Create "indicator" Picture (and Set Rounded Corners)
            If tabProp.HasOwnProp("labelIndicator") {
                this.GUI.AddPicture("v" indicatorName " x" indicatorX " y" ((tabProp.h + labelDistance)*(A_Index-1) + indicatorY) " w" tabProp.labelIndicator.w*(A_ScreenDPI/96) " h" tabProp.labelIndicator.h*(A_ScreenDPI/96) " backgroundtrans +0xE -E0x200 Hidden")
                Gdip_SetPicRoundedRectangle(this.GUI[indicatorName], tabProp.labelIndicator.color, indicatorR, isFill:="True")
            }
            ; Create "logo" symbol
            If tabProp.HasOwnProp("logoSymbol") {
                If tabProp.labelName.Capacity != tabProp.logoUnicode.Capacity
                    Return MsgBox("标签数量与图标数量不等, 或格式不正确")
                FontSymbol(this.GUI, tabProp.logoSymbol.fontName).Font( {name:symbolName, unicode:tabProp.logoUnicode[A_Index], x:symbolX, y:((tabProp.h + labelDistance)*(A_Index-1) + symbolY), w:symbolW, h:symbolH, textColor:tabProp.labelProp.fontNormalColor, fontOpt:"s" tabProp.logoSize[A_Index], textOpt:'+0x200 center'} )
            }
            ; Create the "label" to Visible the Tab ( as a top text button)
            this.GUI.AddText("v" buttonName " x" tabProp.x " y" (tabProp.y + (tabProp.h + labelDistance)*(A_Index-1)) " h" tabProp.h " w" tabProp.w  " BackgroundTrans +0x200 " tabProp.labelProp.textOpt, tabProp.labelName[A_Index])
            this.GUI[buttonName].SetFont(tabProp.labelProp.fontOpt, tabProp.labelProp.font)
            this.GUI[buttonName].SetFont("c" tabProp.labelProp.fontNormalColor)
            ; this.GUI[buttonName].OnEvent("Click", ButtonFunc)
            this.GUI[buttonName].OnEvent("Click", OnTabClicked)

            ; Setting the first label to be the default tab
            If (A_Index != 1)
                Continue
            this.GUI.lastTab := this.GUI[buttonName]
            this.GUI[focusName].Visible  := True
            this.GUI[buttonName].SetFont("c" tabProp.labelProp.fontActiveColor)
            tabProp.HasOwnProp("labelIndicator") ? (this.GUI[indicatorName].Visible := True) : False
            tabProp.HasOwnProp("logoSymbol")     ? this.GUI[symbolName].Setfont("c" tabProp.labelProp.fontActiveColor) : False
        }
    
        OnTabClicked(GuiCtrlObj, Info, *) {     ; 需配合WM_MOUSEMOVE和WM_MOUSELEAVE使用
            currentTabName := GuiCtrlObj.name
            If this.GUI[currentTabName] = this.GUI.lastTab
                Return
    
            Tab.Choose(StrReplace(currentTabName, "_TAB_BUTTON"))    ; 切换对应的(隐藏)标签页
    
            For name in [this.GUI.lastTab.name, currentTabName] {    ; 激活标签页的活跃态
                activeName     := StrReplace(name, "_TAB_BUTTON", "_ACTIVE")
                focusName      := StrReplace(name, "_TAB_BUTTON", "_FOCUS")
                indicatorName  := StrReplace(name, "_TAB_BUTTON", "_INDICATOR")
                logoSymbolName := StrReplace(name, "_TAB_BUTTON", "_SYMBOL")
                color          := (name=currentTabName) ? tabProp.labelProp.fontActiveColor : tabProp.labelProp.fontNormalColor
    
                this.GUI[focusName].Visible  := (name=currentTabName) ? True:False    ; 高亮焦点标签背景
                this.GUI[activeName].Visible := False    ; 关闭鼠标下的低亮度高亮
    
                this.GUI[name].SetFont("c" color)    ; 高亮标签名称
                tabProp.HasOwnProp("logoSymbol")     ? this.GUI[logoSymbolName].SetFont("c" color) : False    ; 高亮标签图标名称
                tabProp.HasOwnProp("labelIndicator") ? this.GUI[indicatorName].Visible := ((name=currentTabName) ? True:False) : False    ; 高亮其指示器名称
            }
    
            this.GUI.lastTab := this.GUI[currentTabName]  ; 上次被点击标签页变为本次
        }
    }
}


Gdip_SetPicRoundedRectangle(GuiCtrl, Color, R, isFill:="True")
{
    hwnd := GuiCtrl.Hwnd        ; 获取控件hWnd
    GuiCtrl.GetPos(,,&W,&H)     ; 获取控件的宽高

    pBitmap := Gdip_CreateBitmap(W, H)      ; 创建和控件大小相等的BMP位图
    G       := Gdip_GraphicsFromImage(pBitmap)    ; 创建画布(在BMP位图上)
    Gdip_SetSmoothingMode(G, 4)             ; 设置画布平滑模式为抗锯齿
    
    if isFill="True" {
        ; 创建实心圆角矩形背景（注意笔刷画图的xy是相对位图距离，不是窗口距离）
        pBrushBack := Gdip_BrushCreateSolid(Color)
        Gdip_FillRoundedRectangle(G, pBrushBack, 0, 0, W-1, H-1, R*(A_ScreenDPI/192))
        Gdip_DeleteBrush(pBrushBack)
    } else {
        pPen := Gdip_CreatePen(Color, isFill)
        Gdip_DrawRoundedRectangle(G, pPen, 0, 0, w-1, h-1, R*(A_ScreenDPI/192))   ; "w-1" and "h-1" can make the border appear completely on the picture control
        Gdip_DeletePen(pPen)
    }

    ; 创建与控件相关联的位图（让hBitmap和pBitmap相关联，后续可以把图片控件变成上面创建好的BMP位图）
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)

    ; 开始删除
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}
