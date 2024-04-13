/*
`   hIconToFile(v1) - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36733
    hIconToIcon(v2) - https://www.autohotkey.com/boards/viewtopic.php?f=76&t=93750&start=20

    Function————————————————Description——————————————————————————————————————————————————————————————————————————————————
    ExtractIcon           - 从可执行文件、DLL 或图标文件中获取指定索引位置(默认0)的图标句柄，总是返回大图标(32x32)
    ExtractIconEx         - 同ExtractIcon，但可检索大图标(32x32)或小图标(16x16)的句柄数组
    ExtractAssociatedIcon - 获取作为资源存储在文件中的图标或存储在文件的关联可执行文件中的大图标(32x32)的句柄
    SHGetFileInfo         - 检索有关文件系统中的对象的信息，可获取Shell所关联的文件对象(驱动器，文件夹，打印机，普通文件等)的图标
    LoadImage             - 加载DLL模块或可执行文件模块或图标文件的"指定分辨率"的图标（注意加载dll图标使用的是其模块）
    LoadIcon              - 从给定可执行文件的资源中抽取图标，源文件由实例标识，不是由文件名标识，图标由ID标识不是由索引标识
    —————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

    For example : 
    ConvertToIconFile.Dll( {dllName:'shell32.dll', index:'#176', size:'128', iconName:'test'} )
    ConvertToIconFile.Dll( {dllName:'shell32.dll', index:'#161', size:'0'  , iconName:'test'} )
    ConvertToIconFile.PNG( {path:"C:\Users\11593\Downloads\Company Portal.png", size:'128', iconName:'test'} )
    ConvertToIconFile.PNG( {path:"C:\Users\11593\Downloads\Company Portal.png", size:'0'  , iconName:'test'} )
    ConvertToIconFile.File( {path:"C:\Windows\regedit.exe", iconName:'test'} )
*/

Class ConvertToIconFile {

    static Dll(obj:={dllName:'', index:'', size:'', iconName:''}) {
        If !IsObject(obj)
            Return MsgBox('Please enter the correct format for the object')
        If !RegExMatch(obj.dllName, 'i)[\.dll|\.exe]$')
            Return Msgbox('Please enter the correct of dllName.`ne.g. shell32.dll',,'iconi')

        obj.size := (!obj.HasOwnProp('size') or !IsNumber(obj.size) or (obj.size < 16)) ? '0' : obj.size

        If !Instr(obj.index, '#') { ; 索引号一般是正整数，但特殊情况下，如Windows API中，一些资源的索引号可能是负数
            hIcon   := DllCall("Shell32\ExtractIcon", "Ptr", 0, "Str", obj.dllName, "Uint", (obj.index-1))
        } Else {    ;  https://www.autohotkey.com/boards/viewtopic.php?f=14&t=45279&p=205246&hilit=MAKEINTRESOURCE#p205246
            iconW   := iconH := obj.size
            hModule := DllCall("GetModuleHandle", "Str", obj.dllName, "UPtr"), unload := False
            (!hModule) ? (hModule := DllCall("LoadLibrary", "Str", obj.dllName, "UPtr"), unload := true) : False
                        ; hModule := DllCall("Kernel32\LoadLibraryEx", "Str", obj.dllName, "Ptr", 0, "UInt", 0x02, "UPtr")
            hIcon   := DllCall('User32\LoadImage', "Ptr", hModule, "Str", obj.index, "UInt", 1, "Int", iconW, "Int", iconH, "UInt", 0x00002000)
            unload  ?  DllCall("FreeLibrary", "UPtr", hModule) : False
        }

        Loop    ; 重复的名称
            obj.iconName := (A_Index = 2) ? obj.iconName '_1' : RegExReplace(obj.iconName, '_\d+$', '_' (A_Index-1))
        Until !FileExist(A_Desktop '\' obj.iconName '.ico')

        this._hIconToFile(hicon, obj.iconName), DllCall("DestroyIcon", "ptr", hIcon)
    }

    static File(obj:={path:'', iconName:''}) {
        If !IsObject(obj)
            Return MsgBox('Please enter the correct format for the object')
        If !FileExist(obj.path)
            Return Msgbox('The file does not exist:   ' obj.path)

        static SHGFI_ICON      := 0x100     ; 检索表示文件图标的句柄
      ; static SHGFI_SMALLICON := 0x001     ; 修改 SHGFI_ICON，使函数检索文件的小型图标
      ; static SHGFI_LARGEICON := 0x000     ; 修改 SHGFI_ICON，使函数检索文件的大型图标
      ; static SHGFI_ICON + SHGFI_LARGEICON = 0x100
      ; static SHGFI_ICON + SHGFI_SMALLICON = 0x101
        fileInfo := Buffer(fisize := A_PtrSize + 688)

        DllCall("Shell32\SHGetFileInfoW"
            , "Str", obj.path
            , "Uint", 0
            , "Ptr", fileInfo
            , "UInt", fisize
            , "UInt", SHGFI_ICON)
        hIcon := (NumGet(fileInfo, 0, "Ptr") ? NumGet(fileInfo, 0, "Ptr") : LoadPicture('shell32.dll', 'icon3'))

        Loop
            obj.iconName := (A_Index = 2) ? obj.iconName '_1' : RegExReplace(obj.iconName, '_\d+$', '_' (A_Index-1))
        Until !FileExist(A_Desktop '\' obj.iconName '.ico')

        this._hIconToFile(hIcon, obj.iconName), DllCall("DestroyIcon", "Ptr", hIcon)
    }

    static PNG(obj:={path:'', iconName:'', size:''}) {
        If !IsObject(obj)
            Return MsgBox('Please enter the correct format for the object')
        If !FileExist(obj.path)
            Return Msgbox('The file does not exist:   ' obj.path)
        If !RegExMatch(obj.path, 'i)\.png$')
            Return Msgbox('This file is not PNG:    ' obj.path)

        w := h := obj.size := (!obj.HasOwnProp('size') or !IsNumber(obj.size) or (obj.size < 16)) ? '0' : obj.size

        hBitmap := LoadPicture(obj.path, "GDI+ w" w ' h' h)
        hIcon   := this._HIconFromHBitmap(hBitmap)

        Loop
            obj.iconName := (A_Index = 2) ? obj.iconName '_1' : RegExReplace(obj.iconName, '_\d+$', '_' (A_Index-1))
        Until !FileExist(A_Desktop '\' obj.iconName '.ico')

        this._hIconToFile(hIcon, obj.iconName), DllCall("DestroyIcon", "Ptr", hIcon), DllCall("DeleteObject", "Ptr", hBitmap)
    }

    static _hIconToFile(hIcon, iconName) {
        static szICONHEADER := 6, szICONDIRENTRY := 16, szBITMAP := 16 + A_PtrSize*2, szBITMAPINFOHEADER := 40
             , IMAGE_BITMAP := 0, flags := (LR_COPYDELETEORG := 0x8) | (LR_CREATEDIBSECTION := 0x2000)
             , szDIBSECTION := szBITMAP + szBITMAPINFOHEADER + 8 + A_PtrSize*3
             , copyImageParams := ["UInt", IMAGE_BITMAP, "Int", 0, "Int", 0, "UInt", flags, "Ptr"]
    
        ICONINFO := Buffer(8 + A_PtrSize*3, 0)
        DllCall("GetIconInfo", "Ptr", hIcon, "Ptr", ICONINFO)
        if !hbmMask  := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize, "UPtr"), copyImageParams*) {
            MsgBox("CopyImage failed. LastError: " . A_LastError)
            Return
        }
        hbmColor := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize*2, "UPtr"), copyImageParams*)
        mskDIBSECTION := Buffer(szDIBSECTION, 0)
        clrDIBSECTION := Buffer(szDIBSECTION, 0)
        DllCall("GetObject", "Ptr", hbmMask , "Int", szDIBSECTION, "Ptr", mskDIBSECTION)
        DllCall("GetObject", "Ptr", hbmColor, "Int", szDIBSECTION, "Ptr", clrDIBSECTION)
    
        clrWidth        := NumGet(clrDIBSECTION, 4 , "UInt")
        clrHeight       := NumGet(clrDIBSECTION, 8 , "UInt")
        clrBmWidthBytes := NumGet(clrDIBSECTION, 12, "UInt")
        clrBmPlanes     := NumGet(clrDIBSECTION, 16, "UShort")
        clrBmBitsPixel  := NumGet(clrDIBSECTION, 18, "UShort")
        clrBits         := NumGet(clrDIBSECTION, 16 + A_PtrSize, "UPtr")
        colorCount      := clrBmBitsPixel >= 8 ? 0 : 1 << (clrBmBitsPixel * clrBmPlanes)
        clrDataSize     := clrBmWidthBytes * clrHeight
    
        mskHeight       := NumGet(mskDIBSECTION, 8 , "UInt")
        mskBmWidthBytes := NumGet(mskDIBSECTION, 12, "UInt")
        mskBits         := NumGet(mskDIBSECTION, 16 + A_PtrSize, "UPtr")
        mskDataSize     := mskBmWidthBytes * mskHeight
    
        iconDataSize  := clrDataSize + mskDataSize
        dwBytesInRes  := szBITMAPINFOHEADER + iconDataSize
        dwImageOffset := szICONHEADER + szICONDIRENTRY
    
        ICONHEADER := Buffer(szICONHEADER, 0)
        NumPut("UShort", 1, ICONHEADER, 2)
        NumPut("UShort", 1, ICONHEADER, 4)
    
        ICONDIRENTRY := Buffer(szICONDIRENTRY, 0)
        NumPut("UChar" , clrWidth      , ICONDIRENTRY, 0)
        NumPut("UChar" , clrHeight     , ICONDIRENTRY, 1)
        NumPut("UChar" , colorCount    , ICONDIRENTRY, 2)
        NumPut("UShort", clrBmPlanes   , ICONDIRENTRY, 4)
        NumPut("UShort", clrBmBitsPixel, ICONDIRENTRY, 6)
        NumPut("UInt"  , dwBytesInRes  , ICONDIRENTRY, 8)
        NumPut("UInt"  , dwImageOffset , ICONDIRENTRY, 12)
    
        NumPut("UInt", clrHeight*2 , clrDIBSECTION, szBITMAP +  8)
        NumPut("UInt", iconDataSize, clrDIBSECTION, szBITMAP + 20)
        
        File := FileOpen(A_Desktop "\" iconName . '.ico', "w", "cp0")
        File.RawWrite(ICONHEADER  , szICONHEADER)
        File.RawWrite(ICONDIRENTRY, szICONDIRENTRY)
        File.RawWrite(clrDIBSECTION.Ptr + szBITMAP, szBITMAPINFOHEADER)
        File.RawWrite(clrBits + 0 , clrDataSize)
        File.RawWrite(mskBits + 0 , mskDataSize)
        File.Close()
    
        DllCall("DeleteObject", "Ptr", hbmColor)
        DllCall("DeleteObject", "Ptr", hbmMask)
    }

    static _HIconFromHBitmap(hBitmap, test_w:=0, test_h:=0) {
        BITMAP := Buffer(size := 4*4 + A_PtrSize*2, 0)
        DllCall("GetObject", "Ptr", hBitmap, "Int", size, "Ptr", BITMAP)
        width := NumGet(BITMAP, 4, "UInt"), height := NumGet(BITMAP, 8, "UInt")
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        hCBM := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", width, "Int", height, "Ptr")
        ICONINFO := Buffer(4*2 + A_PtrSize*3, 0)
    
        NumPut("Int", 1, ICONINFO)
        NumPut("Ptr", hCBM, ICONINFO, 4*2 + A_PtrSize)
        NumPut("Ptr", hBitmap, ICONINFO, 4*2 + A_PtrSize*2)
    
        hIcon := DllCall("CreateIconIndirect", "Ptr", ICONINFO, "Ptr")
        DllCall("DeleteObject", "Ptr", hCBM), DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
        Return hIcon
    }
}