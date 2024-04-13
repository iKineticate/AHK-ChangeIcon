/*
    mygu.SegoeUISymbol := FontSymbol(mainGUI, "Segoe UI Symbol")
    mainGUI.SegoeUISymbol.Font( {name:'', unicode:'', x:'', y:'', w:'', h:'', textColor:'', backColor:'', fontOpt:'s12', text_options:'+0x200 center'} )
    Font中的对象可以不添加backColor，默认为透明
*/

Class FontSymbol
{
    __New(GuiObj, Font) => (this.GUI := GuiObj , this.selectedFont := Font)

    Font(obj:={font_name:'',name:'', unicode:'', x:'', y:'', w:'', h:'', textColor:'', backColor:'', fontOpt:'s12', textOpt:'+0x200 center'}) {
        If !IsObject(obj)
            Return
        For propName, value in obj.OwnProps() {
            If !Instr(propName, 'color')
                Continue
            Switch StrLen(color:=value) {
            Case 6  : obj.%propName% := (propName='textColor') ? 'c' color                          : 'Background' color
            Case 8  : obj.%propName% := (propName='textColor') ? 'c' RegExReplace(color,'i)^0x')    : 'Background' RegExReplace(color,'i)^0x')
            Case 10 : obj.%propName% := (propName='textColor') ? 'c' RegExReplace(color, 'i)^0x..') : 'Background' RegExReplace(color, 'i)^0x..')
            Default : obj.%propName% := (propName='textColor') ? 'cffffff'                          : 'BackgroundTrans'
            }
        }
        obj.HasOwnProp("backColor") ? False : obj.backColor := "BackgroundTrans"
        this.noSpacesName := RegExReplace(obj.name, "[\s\r\n]+")
        this.GUI.AddText('v' this.noSpacesName ' x' obj.x ' y' obj.y ' w' obj.w ' h' obj.h ' ' obj.backColor ' ' obj.textOpt, chr(obj.unicode))
        this.GUI[this.noSpacesName].SetFont(obj.fontOpt ' ' obj.textColor, Trim(this.selectedFont))
    }
}

