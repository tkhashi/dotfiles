#HotkeyInterval 100

>^I::Send, #1
>^0::Send, #2
#IfWinNotActive スマカン
>^J::Send, #3
#If
^!S::Send, #4
^!L::Send, #5
^!E::Send, #6
^!T::Send, #7
^!Z::Send, #8
^!O::Send, #9
;AHK全部リロード
^!R::
	Run, "C:\Users\Kazuhiro Takahashi\work\ConfigDir\AHK\TypeMouseControl.ahk" 
	Sleep, 50
	Send, y
	Run, "C:\Users\Kazuhiro Takahashi\work\ConfigDir\AHK\Remap.ahk"
	Sleep, 50
	Send, y
	Run, "C:\Users\Kazuhiro Takahashi\work\ConfigDir\AHK\EscIMEOff.ahk"
	Sleep, 50
	Send, y
	Run, "C:\Users\Kazuhiro Takahashi\work\ConfigDir\AHK\AppHotKey.ahk"
	Sleep, 50
	Send, y
	Run, "C:\Users\Kazuhiro Takahashi\AppData\Local\Wox\Wox.exe"
	Sleep, 100
	Send, {Esc}