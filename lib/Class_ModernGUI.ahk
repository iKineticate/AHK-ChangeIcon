Class ModernGUI
{
    __New(obj:={GUI:'', x:'center', y:'center', w:'', h:'', backColor:'', GuiOpt:'+DPIScale', GuiNmae:'', GuiFontOpt:'s12 Bold cffffff', GuiFont:'Microsoft YaHei', showOpt:''}) {
        If !isObject(obj)
            Return MsgBox('Please create an object for the GUI option`n请在你的ModerGui()中创建object(对象)')
        this._SetDefaultsProperties()
        this._SetGuiProperties(obj)
        this._CreateGUI()
    }

    ;========================================================================================================
    ; Create:      Caption
    ; buttonW      The width of the close, maximize, and minimize buttons (关闭、最大化、最小化按钮的宽度)
    ; png_quality  The width and height of PNG imagess ("png_quality"是常态PNG图片和活动态PNG图片的宽高)
    ; Note         If using this function, please remember to remove the original caption from this.GUI, that is, add "-caption" to the Class--CreateMordenGUI(GuiOpt:''). So there won't be two title bars
    ;              若创建标题栏，请记得给this.GUI移除原来的标题栏，即CreateMordenGUI(GuiOpt:'')中添加"-caption"，这样就不会有两个标题栏了
    ; Note         After using this function to create the caption, if you don't use this class to create controls , remember to subtract the height of the caption from the "y" value of these controls
    ;              使用这个函数创建标题栏后，若不使用这个类来创建控件，需要记得给这些控件的y值减去标题的高
    ;========================================================================================================   
    CreateCaption(obj:={captionH:'', titleColor:'', backColor:'', buttonW:'', buttonActiveColor:''}) {

        For propName, value in obj.OwnProps() {    ; Change to the correct colour format (e.g. ffffff)
            If !RegExMatch(propName, 'i)backColor|title_color')  ; 无需格式化"buttonActiveColor"，后续WindowCrontrolButtons函数会格式化
                Continue
            Switch StrLen(color := Trim(value)) {
                Case 8  : Obj.%propName% := LTrim(color, '0x')
                Case 10 : Obj.%propName% := RegExReplace(color, 'i)^0x..')
            }
        }
        ; Create Windows Crontro Button
        this.WindowCrontrolButtons({marginTop:'0', marginRight:'0', buttonW:obj.buttonW, buttonH:obj.caption_h, activeColor:obj.buttonActiveColor, symbol_backcolor:obj.backColor})
        ; Create the caption
        this.GUI.AddText('vCaption x0 y0 w' this.W ' h' obj.caption_h ' c' obj.title_color ' Background' obj.backColor ' +0x4000000 +0x200', '`s`s' this.GuiNmae).OnEvent('DoubleClick', (*) => '')
    }

    ;========================================================================================================
    ; Create Windows Control Button（关闭、最大化、最小化按钮）
    ;========================================================================================================  
    WindowCrontrolButtons(obj:={marginTop:'', marginRight:'', buttonW:'', buttonH:'', activeColor:''}) {
        Switch StrLen(color := Trim(obj.activeColor)) {    ; Change to the correct colour format (e.g. 000000)
            Case 6 : obj.activeColor := color
            Case 8 : obj.activeColor := LTrim(color, '0x')
            Case 10: obj.activeColor := RegExReplace(color, 'i)^0x..')
        }

        For key, value in map('WinClose', '0x2716', 'WinMaximize', '0x25A2', 'WinMinimize', '0xE0B8') {    ; Create Windows Control Buttons
            activeName := key '_ACTIVE'
            buttonName := key '_BUTTON'
            buttonX    := this.w - (obj.marginRight + A_Index * obj.buttonW)
            buttonY    := obj.marginTop
            textColor  := (key='WinMaximize') ? '575757' : 'ffffff'
            ; 活跃态（不创建最大化的活跃态）
            (key!='WinMaximize') ? this.GUI.AddPicture('v' activeName ' x' buttonX ' y' buttonY ' w' obj.buttonW ' h' obj.buttonH ' background' obj.activeColor ' +Hidden -E0x200') : False
            ; 文本符号按钮（不创建最大化的按钮）
            FontSymbol(this.GUI, "Segoe UI Symbol").Font( {name:buttonName, unicode:value, x:buttonX, y:buttonY, w:obj.buttonW, h:obj.buttonH, textColor:textColor, backColor:'Trans', fontOpt:'s' obj.buttonH/2, textOpt:'+0x200 center'} )
            ; (key!='WinMaximize') ? this.GUI[buttonName].OnEvent('Click', ButtonFunc) : False
            (key='WinMinimize') ? this.GUI[buttonName].OnEvent('Click', (*) => WinMinimize(this.GUI)) : False
            (key='WinClose') ? this.GUI[buttonName].OnEvent('Click', (*) => ExitApp()) : False
        }

        /*
            CloseWindowWithFadeEffect(GuiHwnd) {
                static TIME     := 600
                static AW_BLEND := 0x00080000   ; 淡化效果
                static AW_HIDE  := 0x00010000   ; 隐藏窗口
                
                ; (IsSet(iconGUI) and (iconGUI is GUI)) ? iconGUI.Destroy() : False
            
                WinGetPos(,,&OutWidth, &OutHeight, GuiHwnd)
                WinSetRegion("0-0 r30-30 w" OutWidth " h" OutHeight, GuiHwnd)   ; 关闭窗口时DWM会失效导致圆角消失，影响视觉效果，因此需在关闭前另使其他办法设置圆角
                DllCall("user32\AnimateWindow", "ptr", GuiHwnd, "uint", TIME, "uint", AW_BLEND|AW_HIDE)
                ExitApp
            }
        */
    }

    Show() {
        this._FrameShadow(this.GUI.hwnd)
        this.GUI.show(this.showOpt)
    }

    _SetDefaultsProperties() {
        this.w          := 520
		this.h          := 520
        this.backColor  := 'ffffff'
        this.GuiOpt     := '+DPIScale'
        this.GuiNmae    := 'ikineticate'
        this.GuiFont    := 'Microsoft YaHei'
        this.GuiFontOpt := 's12 Bold cffffff'
        this.showOpt    := ''
    }

    _SetGuiProperties(obj) {
        this.GUI := Obj.GUI
        ; If there is no object, or the value is null, or the value is 'center', then take the default value
        this.w          := Obj.HasOwnProp('w')          ? (obj.w ? obj.w : this.w) : this.w
        this.h          := Obj.HasOwnProp('h')          ? (obj.h ? obj.h : this.h) : this.h
        this.x          := Obj.HasOwnProp('x')          ? (obj.x ? (!Instr(obj.x, 'center') ? obj.x : 'center') : 'center') : 'center'
        this.y          := Obj.HasOwnProp('y')          ? (obj.y ? (!Instr(obj.y, 'center') ? obj.y : 'center') : 'center') : 'center'
        this.showOpt    := Obj.HasOwnProp('showOpt')    ? (obj.showOpt .= ' x' this.x ' y' this.y ' w' this.w ' h' this.h) : False
        this.GuiOpt     := Obj.HasOwnProp('GuiOpt')     ? (obj.GuiOpt     ? obj.GuiOpt     : this.GuiOpt    ) : this.GuiOpt
        this.GuiNmae    := Obj.HasOwnProp('GuiNmae')    ? (obj.GuiNmae    ? obj.GuiNmae    : this.GuiNmae   ) : this.GuiNmae
        this.GuiFont    := Obj.HasOwnProp('GuiFont')    ? (obj.GuiFont    ? obj.GuiFont    : this.GuiFont   ) : this.GuiFont
        this.GuiFontOpt := Obj.HasOwnProp('GuiFontOpt') ? (obj.GuiFontOpt ? obj.GuiFontOpt : this.GuiFontOpt) : this.GuiFontOpt

        if !obj.HasOwnProp('backColor') or !obj.backColor {    ; Change to the correct color format (e.g. ffffff)
            this.backColor := 'ffffff'
        } else {
            this.backColor := (StrLen(obj.backColor)=8 ) ? LTrim(obj.backColor, '0x')             : obj.backColor
            this.backColor := (StrLen(obj.backColor)=10) ? RegExReplace(obj.backColor, 'i)^0x..') : obj.backColor
        }
    }

    _CreateGUI() {
        global
        this.GUI.Title     := this.GuiNmae
        this.GUI.BackColor := this.backColor
        this.GUI.Opt(this.GuiOpt)
        this.GUI.OnEvent('Close', (*) => ExitApp)
        this.GUI.SetFont(this.GuiFontOpt, this.GuiFont)
        this.GUI.activeControl := False  ; 用于WM_MOUSEMOVE和标签页按钮，最终目的是避免标签页闪烁
    }

    ; 设置窗口圆角+边框阴影   https://www.autohotkey.com/boards/viewtopic.php?f=82&t=113202&p=560692&hilit=WinSetRegion#p560692
    _FrameShadow(GuiHwnd) {
        DllCall('dwmapi.dll\DwmIsCompositionEnabled', 'int*', &dwmEnabled:=0)
        static GCL_STYLE := -26
        if !dwmEnabled {
            DllCall('user32.dll\SetClassLongPtr', 'ptr', GuiHwnd, 'int', GCL_STYLE, 'ptr', DllCall('user32.dll\GetClassLongPtr', 'ptr', GuiHwnd, 'int', GCL_STYLE) | 0x20000)
        } else {
            margins := Buffer(16, 0)    ; DWM(桌面窗口管理器): 提供的视觉效果有毛玻璃框架、3D窗口变换动画、窗口翻转和高分辨率支持(自带双缓冲)
            NumPut('int', 1, 'int', 1, 'int', 1, 'int', 1, margins)
            DllCall('dwmapi.dll\DwmSetWindowAttribute', 'ptr', GuiHwnd, 'Int', 2, 'Int*', 2, 'Int', 4)
            DllCall('dwmapi.dll\DwmExtendFrameIntoClientArea', 'ptr', GuiHwnd, 'ptr', margins)
        }
    }
}