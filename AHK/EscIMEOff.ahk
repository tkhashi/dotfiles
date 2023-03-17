; 以下サイトから拝借
; http://www6.atwiki.jp/eamat/pages/17.html
;------------------------------------------------------------------------------------
;Esc時に英字入力にする
;------------------------------------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI,  0, "UInt")  ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
                 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283 ;Message : WM_IME_CONTROL
          ,  Int, 0x006  ;wParam  : IMC_SETOPENSTATUS
          ,  Int, SetSts) ;lParam  : 0 or 1
}

~Esc::IME_SET(0)
~^[::IME_SET(0)
~^'::IME_SET(0)
~^@::IME_SET(0)
vk1D::IME_SET(0)

;------------------------------------------------------------------------------------
;Windowが切り替わるとIMEオフになる
;------------------------------------------------------------------------------------
;Ghoster.ahkを切った時用
;START:
;WinGet,oldid,ID,A
;WinGet,oldtop,ExStyle,ahk_id %oldid%

;LOOP:
;Sleep,50
;WinGet,winid,ID,A
;If winid<>%oldid%
;{
  ;IME_SET(0)
  ;oldid=%winid%
;}
;Goto,LOOP

;------------------------------------------------------------------------------------
;一定時間経過するとIMEオフになる
;------------------------------------------------------------------------------------
;時間経過を感知
;SetTimer, Label [, Period|On|Off]
;Return
;IME on/offを判定
;imeGet := IME_Get()
;If ()
;off以外なら切り替える


;SetTimer
;http://ahkwiki.net/SetTimer
;AHKはマルチスレッドじゃないQ＆A
;http://ahkwiki.net/Faqs#IME.E3.81.AEOn.2FOff.E3.81.AE.E5.88.87.E3.82.8A.E6.9B.BF.E3.81.88.E3.82.84.E3.80.81.E7.8A.B6.E6.85.8B.E3.82.92.E5.BE.97.E3.82.8B.E3.81.AB.E3.81.AF.E3.81.A9.E3.81.86.E3.81.99.E3.82.8C.E3.81.B0.E3.81.84.E3.81.84.E3.81.AE.3F
;IME検知ライブラリ
;https://w.atwiki.jp/eamat/pages/20.html