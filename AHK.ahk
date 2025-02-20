#IfWinActive ahk_exe Typora.exe
{
    ; Ctrl+K c++Code    
    ; crtl 是 ^    k 是 k键
    ^k::addCode()
}
addCode(){
Send,{Asc 096}
Send,{Asc 096}
Send,{Asc 096}
SendInput, {Text}c++
Send,{Enter}
Return
}