#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;remove the click
global filePath := A_ScriptDir . "\VoidPaths.txt" 
global actionDelay := 350 ;400 ;450 note only tested wands
global moveDelay := 25 ;50 ;75
global holdDownDelay := 60
global chestDelay := 4000 - actionDelay
;450 (400?) for ? action
;? for a punch action
;? for successful wand action

;honorary global is -9 (well at 1, but everything is +10ed) in the file location, 
; which holds last floor location so this can recall it!wdsazwdsaz

;TODO add spesial characters to prompt as needed
;  add a wait for animations character

;^g exits
;^Capslock starts/stops recording
;^f stores the floor recording
;^d starts the program


;exit
^g::	;Ctrl + g
    MsgBox the end
    ExitApp 	
return

^x::
    InputBox, ActionLine, Record Floor?,%floorOrgActionLine%`n Put an ']' at the end to signify the next level is spesial`n 'p' to throw a Msgbox and stop climbing,,600,200,,,,,%ClipBoard%
    DebugLine(ActionLine)
return

;Record inputs and store to ClipBoard
^CapsLock::
    msgbox, started
    Hotkey, ^CapsLock, Off ; Turn off the Ctrl + CapsLock hotkey temporarily
    Input, keystrokes, V, {Ctrl down}{Capslock} ; Capture input until both Ctrl and CapsLock held down
    ClipBoard := keystrokes ; Store captured input in the clipboard
    SetCapsLockState, Off ; Turn off CapsLock
    Hotkey, ^CapsLock, On ; Turn the Ctrl + CapsLock hotkey back on
return


;stores inputs
^f::
    DefFloor := GetFileLine(-9)
    InputBox, floorInput, Floor?,,,100,110,,,,,%DefFloor%
    if ErrorLevel
        return
    
    floorOrgActionLine := GetFileLine(floorInput)
    InputBox, newLine, Record Floor?,%floorOrgActionLine%`n Put an ']' at the end to signify the next level is spesial`n 'p' to throw a Msgbox and stop climbing,,600,200,,,,,%ClipBoard%
    
    if ErrorLevel
        return
    else
        ReplaceFileLine(floorInput, newLine) 
        ReplaceFileLine(-9, floorInput+1) 
return


;Okay so here is the plan

;have a txt file which will contain all the levels
;The first 10 lines will be blank (in case I need - or a 0th level)
;then for the next 500 or so lines will be deticated to levels
;after that, speisal levels (like chest levels and stuff???)


;press key to record actions
;press key to confirm actions
;  Opens diologe box for which floor
;     which opens the diologe box to enter in the action string
;note: fast track key?


;press key, opens floor confirm diologe box
;  confirm, clicks screen (ie: need to position box over game)
;  then it playes through the floor
;note: how do i want to stop it? (perhaps an optional floor cutoff?)
;note: when will it stop on it's own, eof? what if their is a big ass gap?


^d::
    DefFloor := GetFileLine(-9)
    InputBox, floorInput, Start at Floor?,,,150,110,,,,,%DefFloor%
    if ErrorLevel
        return
    if (DefFloor != floorInput){
        ReplaceFileLine(-9, floorInput) 
        DefFloor := floorInput
    }
    
    
    BreakYet := TypeTextFromLine(DefFloor)
    if (BreakYet){
        return
    }
    
    loop {
        DefFloor := 1 + DefFloor
    StartTime1 := A_TickCount
        Msgbox, 1, Stop here?, %DefFloor% Press cancel to stop the program`n press OK or just wait a few seconds for it to continue, 10
        IfMsgBox Cancel
            return
    ElapsedTime1 := A_TickCount - StartTime1
    if (ElapsedTime1 < 2500) {
        levelLoadWait := 2500-ElapsedTime1
        sleep levelLoadWait
    }
    
        BreakYet := TypeTextFromLine(DefFloor)
        if (BreakYet){
            return
        }        
        ReplaceFileLine(-9, DefFloor+1) 
    }

    MsgBox, Done

return


;note needs to be able to add lines to the file
ReplaceFileLine(TargetLine, newText) {
    ; Read the entire content of the file into an array
    
    FileRead, fileContent, %filePath%
    file := FileOpen(filePath, "w")

    fileMax := 0
    Loop, parse, fileContent, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
    {
        if (A_Index = TargetLine+10) {
            file.WriteLine(newText)
        }
        else {
            file.WriteLine(A_LoopField)
        }
        fileMax := A_Index
    }
    
    ;logic for is we need to extend the file
    if (fileMax < TargetLine+10) {
        LinesToGo =  TargetLine+10-fileMax
        loop, LinesToGo {
            file.WriteLine(" ")
        }
        file.WriteLine(newText)
    
    }
        
    file.Close()
}



DebugLine(ActionLine) {
    
    if (ActionLine == ""){
        return 1
    }
    if (ActionLine == " "){
        return 1
    }
    
    Loop, parse, ActionLine
    {
        key := A_LoopField
        if (key == "p"){
            MsgBox, help P
            IfMsgBox Cancel
                return 1
        }
        else if (key == "w" || key == "a" || key == "s" || key == "d"){
            Send, {%key% down}
            Sleep, %holdDownDelay% ; Adjust the sleep time as needed
            Send, {%key% up}
            Sleep, %moveDelay%
        }
        else if (key == "c"){
            Sleep, %chestDelay%
        }
        else {
            Send, {%key% down}
            Sleep, %holdDownDelay% ; Adjust the sleep time as needed
            Send, {%key% up}
            Sleep, %actionDelay%
        }
    }
    MsgBox, done
    return 0
}

;returns 1 if you should stop, else 0
TypeTextFromLine(TargetLine) {
    ActionLine := GetFileLine(TargetLine)
    
    if (ActionLine == ""){
        return 1
    }
    if (ActionLine == " "){
        return 1
    }
    
    Loop, parse, ActionLine
    {
        key := A_LoopField
        if (key == "p"){
            MsgBox, help P
        }
        else if (key == "w" || key == "a" || key == "s" || key == "d"){
            Send, {%key% down}
            Sleep, %holdDownDelay% ; Adjust the sleep time as needed
            Send, {%key% up}
            Sleep, %moveDelay%
        }
        else if (key == "c"){
            Sleep, %chestDelay%
        }
        else {
            Send, {%key% down}
            Sleep, %holdDownDelay% ; Adjust the sleep time as needed
            Send, {%key% up}
            Sleep, %actionDelay%
        }
    }
    return 0
}

GetFileLine(TargetLine) {
    
    ;MsgBox, %filePath%
    lineNumber := 0
    Loop, read, %filePath%
    {
        
        if (StrLen(A_LoopReadLine) == 0){
            continue
        }
        
        lineNumber := A_Index
        
        if (A_Index == TargetLine + 10) {
            
            return A_LoopReadLine
        }
    }
    return ""
}

;NOT USED!
;translates the character input into presses, used in TypeTextFromLine
SendKeyFromChar(key) {
    spaceing := 5
    switch key {
            case "w": 
                Send {w down}
                sleep spaceing
                Send {w up}
            case "a": Send a
            case "s": Send s
            case "d": Send d            
            case "i": Send i ;alt arrows
            case "j": Send j
            case "k": Send k
            case "l": Send l ;L
            
            case "z": Send z ;staff
            case "m": Send m ;alt staff
            
            
            case "1": Send 1
            case "2": Send 2
            case "3": Send 3
            case "4": Send 4
            case "5": Send 5
            case "6": Send 6
            case "7": Send 7
            case "8": Send 8
            case "9": Send 9
            case "0": Send 0
            
            case "p": ;climb has hit an error
            ;TODO
            msgbox, Pause (except not really, pls kill program before it tries to climb next floor, lol)
            case "]": ;hitting a nonFloor level
            ;TODO
            default: MsgBox, Error [%A_LoopField%] not in exicute bank
        }

}


