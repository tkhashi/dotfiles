;///////////////////////////////特定のアプリで無効化///////////////////////////////////
#IfWinNotActive C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe
  #IfWinNotActive my task-management tool
  #IfWinNotActive

  ;///////////////////////////////IMEオフ///////////////////////////////////
  ; 以下サイトから拝借
  ; http://www6.atwiki.jp/eamat/pages/17.html
  ;------------------------------------------------------------------------------------
  ;Esc時に英字入力にする
  ;------------------------------------------------------------------------------------
  IME_SET(SetSts, WinTitle="A") {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if (WinActive(WinTitle)) {
      ptrSize := !A_PtrSize ? 4 : A_PtrSize
      VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
      NumPut(cbSize, stGTI, 0, "UInt") ;   DWORD   cbSize;
      hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
      ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }
    return DllCall("SendMessage"
    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
    , UInt, 0x0283 ;Message : WM_IME_CONTROL
    , Int, 0x006 ;wParam  : IMC_SETOPENSTATUS
    , Int, SetSts) ;lParam  : 0 or 1
  }

  ;~Esc::IME_SET(0)
  ;~^[::IME_SET(0)
  ;~^'::IME_SET(0)
  ;~^@::IME_SET(0)

  ;///////////////////////////////エディターリマップ///////////////////////////////////
  #HotkeyInterval 100
  ; 主要なキーをホットキーとして検知可能にしておく
  ; A_ThisHotkey で検知可能にするための記述
  ; 検知だけしてAutoHotKey側では何も処理しない
  ; チルダ(~)で元キーとしても認識する
  *~LCtrl::
  *~RCtrl::
  *~a::
  *~b::
  *~c::
  *~d::
  *~e::
  *~f::
  *~g::
  *~h::
  *~i::
  *~j::
  *~k::
  *~l::
  *~m::
  *~n::
  *~o::
  *~p::
  *~q::
  *~r::
  *~s::
  *~t::
  *~u::
  *~v::
  *~w::
  *~x::
  *~y::
  *~z::
  *~1::
  *~2::
  *~3::
  *~4::
  *~5::
  *~6::
  *~7::
  *~8::
  *~9::
  *~0::
  *~F1::
  *~F2::
  *~F3::
  *~F4::
  *~F5::
  *~F6::
  *~F7::
  *~F8::
  *~F9::
  *~F10::
  *~F11::
  *~F12::
  *~`::
  *~~::
  *~!::
  *~@::
  *~#::
  *~$::
  *~%::
  *~^::
  *~&::
  *~*::
  *~(::
  *~)::
  *~-::
  *~_::
  *~=::
  *~+::
  *~[::
  *~{::
    *~]::
  *~}::
  *~\::
  *~|::
    *~;::
  *~'::
  *~"::
  *~,::
  *~<::
  *~.::
  *~>::
  *~/::
  *~?::
    ;*~Esc::
  *~Tab::
  *~Space::
  *~LAlt::
    ;*~RAlt::
  *~Left::
  *~Right::
  *~Up::
  *~Down::
  *~Enter::
  *~PrintScreen::
  *~Delete::
  *~Home::
  *~End::
  *~PgUp::
  *~PgDn::

  Return

  ;Ctrl + jknp => 矢印キー
  <^H::Send, {BS}
  <^J::Send, {left}
  <^K::Send, {right}
  <^N::Send, {down}
  <^P::Send, {up}
  ;Ctrl + Shift + jknp => Shift + 矢印キー
  +<^J::Send, +{left}
  +<^K::Send, +{right}
  +<^N::Send, +{down}
  +<^P::Send, +{up}
  ;Ctrl + Ctrl + jknp => Ctrl + 矢印キー
  >^<^J::Send, ^{left}
  >^<^K::Send, ^{right}
  >^<^N::Send, ^{down}
  >^<^P::Send, ^{up}
  ;Ctrl + Ctrl + Shift + jknp => Ctrl + Shift + 矢印キー
  +>^<^J::Send, ^+{left}
  +>^<^K::Send, ^+{right}
  +>^<^N::Send, ^+{down}F
  +>^<^P::Send, ^+{up}
  ;Ctrl + Alt + jknp => Alt + 矢印キー
  !<^J::Send, !{left}
  !<^K::Send, !{right}
  !<^N::Send, !{down}
  !<^P::Send, !{up}
  ;Ctrl + Alt + Shift + jknp => Alt + Shift + 矢印キー
  +!<^J::Send, !+{left}
  +!<^K::Send, !+{right}
  +!<^N::Send, !+{down}
  +!<^P::Send, !+{up}
  ;Ctrl + Ctrl + Alt + jknp => Alt + Ctrl + 矢印キー
  !>^<^J::Send, ^!{left}
  !>^<^K::Send, ^!{right}
  !>^<^N::Send, ^!{down}
  !>^<^P::Send, ^!{up}

  <^]::
    Send, {Esc}
    IME_SET(0)
  Return
  <^[::
    Send, {Esc}
    IME_SET(0)
  Return
  +<^[::
    Send, +{Esc}
    IME_SET(0)
  Return
  +<^]::
    Send, +{Esc}
    IME_SET(0)
  Return

  >^Q::Send, !{F4}
  ^4::Send, ^{F4}
  >^[::Send, {Browser_Back}
  >^]::Send, {Browser_Forward}

  ;JISキーボード用
  <^@::
    Send, {Esc}
    IME_SET(0)
  Return
  +<^@::
    Send, +{Esc}
    IME_SET(0)
  Return
  <^vk1C::Send, {AppsKey}

  ;ウィンドウサイズ変更
  #<^p::Send, #{up}
  #<^n::Send, #{down}
  #<^j::Send, #{left}
  #<^k::Send, #{right}

  ;///////////////////////////////マウス操作///////////////////////////////////
  ;------------------------------------------------------------------------------
  ;   前提：
  ;       日本語, 英語キーボードどちらでも使用可能
  ;       英語キーボードの場合、変換・無変換キーが存在するUS配列として扱えるAX配列を利用する
  ;   参考：
  ; https://www.atmarkit.co.jp/ait/articles/0001/26/news001.html
  ;    Change Key使用：
  ;       日本語キーボードの場合
  ;           Caps Lock -> Ctrl
  ;       英語キーボードの場合
  ;           Caps Lock -> Ctrl
  ;           左Alt -> スキャンコード005A(AX配列における変換)
  ;           右Alt -> スキャンコード005B(AX配列における無変換)
  ;           Menuキー -> 左Alt
  ;  参考：
  ;    https://gist.github.com/kondei/87b5f783a6f84a653790
  ;    http://pheromone.hatenablog.com/entry/20130603/1370276768
  ;------------------------------------------------------------------------------
  ;  はじめに 実行準備
  ;------------------------------------------------------------------------------

  ; キーリピートの早いキーボードだと警告が出るので設定
  #HotkeyInterval 100

  ; 変換を修飾キーとして扱うための準備
  ; 変換を押し続けている限りリピートせず待機
  ; vk1C == [変換キー]
  $vk1C::
    startTime := A_TickCount
    KeyWait, vk1C
    keyPressDuration := A_TickCount - startTime
    ; 変換を押している間に他のホットキーが発動した場合は入力しない
    ; 変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1C" and keyPressDuration < 200) {
      IME_SET(1)
      Send,{vk1C}
    }
  Return
  ; vk1D == [無変換キー]
  $vk1D::
    startTime := A_TickCount
    KeyWait, vk1D
    keyPressDuration := A_TickCount - startTime
    If (A_ThisHotkey == "$vk1D" and keyPressDuration < 200) {
      IME_SET(0)
      Send,{vk1D}
    }
  Return

  ;------------------------------------------------------------------------------
  ;   第２弾 マウスカーソル
  ;       カーソルキーを使った移動、選択に慣れて来ると、画面をクリックしたり邪魔なマウスカーソルをどかすといった
  ;       ちょっとしたマウスの操作が面倒に感じるようになってくるaa
  ;       そこまで細かい操作を連続で必要としない場合、ホームポジションからマウス操作を代替できるようにする
  ;------------------------------------------------------------------------------

  ; 変換 + IJKL = マウスカーソル上, 左, 下, 右
  ; そのままだと細かい操作には向くが大きな移動には遅すぎる
  ; カーソル操作中にCtrlキーを一瞬押すといい感じにブーストできる
  ; CtrlとShiftでの加速減速はWindowsのマウスキー機能を踏襲
  ; 精密操作がしたい時は 変換+Shift + IJKL でカーソルをゆっくり動かせる
  ~vk1C & I::
  ~vk1C & J::
  ~vk1C & K::
  ~vk1C & L::
  ~vk1C & .::
    While (GetKeyState("vk1C", "P")) ; 変換キーが押され続けている間マウス移動の処理をループさせる
    {
      MoveX := 0, MoveY := 0
      MoveY += GetKeyState("I", "P") ? -20 : 0 ; 変換キーと一緒にIJKLが押されている間はカーソル座標を変化させ続ける
      MoveX += GetKeyState("J", "P") ? -20 : 0
      MoveX += GetKeyState("J", "P") ? -20 : 0
      MoveY += GetKeyState("K", "P") ? 20 : 0
      MoveX += GetKeyState("L", "P") ? 20 : 0
      MoveX += GetKeyState(".", "P") ? 20 : 0
      MoveX *= GetKeyState("LCtrl", "P") ? 10 : 1 ; Ctrlキーが押されている間は座標を10倍にし続ける(スピードアップ)
      MoveY *= GetKeyState("LCtrl", "P") ? 10 : 1
      MoveX *= GetKeyState("Shift", "P") ? 0.3 : 1 ; Shiftキーが押されている間は座標を30%にする（スピードダウン）
      MoveY *= GetKeyState("Shift", "P") ? 0.3 : 1
      MouseMove, %MoveX%, %MoveY%, 0, R ; マウスカーソルを移動する
      Sleep, 0 ; 負荷が高い場合は設定を変更 設定できる値は-1、0、10～m秒 詳細はSleep
    }
  Return

  ; 以下は日本語キーボード・英語キーボード向け
  ;変換＋F, Enter = 左クリック
  ~vk1C & Enter::MouseClick,left,,,,,D
  ~vk1C & Enter Up::MouseClick,left,,,,,U
  ~vk1C & F::MouseClick,left,,,,,D
  ~vk1C & F Up::MouseClick,left,,,,,U

  ; 英数変換||変換 + Enter|F = 左クリック（押し続けるとドラッグ）
  vk1D & F::
    MouseClick,left,,,,,D
    While(GetKeyState("F","P"))
    {
    }
  Return
  vk1D & F Up::MouseClick,left,,,,,U

  ;英数変換 + D = Space + 左クリック
  vk1D & D::
    Send,{Space Down}
    MouseClick,left,,,,,D
    While(GetKeyState("D","P"))
    {
      BlockInput, Send
    }
  Return
  vk1D & D Up::
    Send, {Space Up}
    MouseClick,left,,,,,U
  Return

  ; 英数変換||変換 + S = 右クリック
  ~vk1C & S::MouseClick,right
  ~vk1D & S::MouseClick,right

  ; 変換 + P = スクロールアップ
  ~vk1C & P::
    Loop
    {
      Send {WheelUp}
      GetKeyState, T, Down
      If T=U ; U is a state for up, D is a state for down
        Break
    }
  Return

  ; 変換 + N = スクロールダウン
  ~vk1C & N::
    Loop
    {
      Send {WheelDown}
      GetKeyState, T, Down
      If T=U ; U is a state for up, D is a state for down
        Break
    }
  Return

  ; 変換 + H = スクロール左スライド
  ~vk1C & H::
    Loop
    {
      Send {WheelLeft}
      GetKeyState, T, Down
      If T=U ; U is a state for up, D is a state for down
        Break
    }
  Return

  ; 変換 + ;(vkBB) = スクロール右スライド
  ~vk1C & vkBB::
    Loop
    {
      Send {WheelRight}
      GetKeyState, T, Down
      If T=U ; U is a state for up, D is a state for down
        Break
    }
  Return

