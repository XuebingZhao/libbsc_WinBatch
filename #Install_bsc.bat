@ECHO OFF
:: sendTo文件夹路径
SET "sendTo=%APPDATA%\Microsoft\Windows\SendTo"

:: 创建临时VBS文件来创建快捷方式
ECHO 创建右键“发送到”快捷方式中...

:: 使用循环创建多个快捷方式
SETLOCAL EnableDelayedExpansion

:: 定义快捷方式数组 - 格式：名称|目标路径|图标位置
SET "shortcuts[0]=打包成 .bsc 归档文件|Scripts\AddTo_bsc.bat|%SystemRoot%\System32\SHELL32.dll,166"
SET "shortcuts[1]=从 .bsc 归档文件解压|Scripts\Extract_bsc.bat|%SystemRoot%\System32\SHELL32.dll,166"
:: 添加更多快捷方式只需在此添加新行，格式如上

:: 循环创建所有快捷方式
SET index=0
:CreateLoop
IF NOT DEFINED shortcuts[%index%] GOTO EndLoop

FOR /F "tokens=1-3 delims=|" %%A IN ("!shortcuts[%index%]!") DO (
    SET "name=%%A"
    SET "targetPath=%~dp0%%B"
    SET "iconLocation=%%C"
    
    :: 删除可能已存在的快捷方式
    IF EXIST "%sendTo%\!name!.lnk" DEL "%sendTo%\!name!.lnk"
    
    :: 创建临时VBS文件
    ECHO Set oWS = WScript.CreateObject^("WScript.Shell"^) > "%TEMP%\CreateShortcut%index%.vbs"
    ECHO sLinkFile = "%sendTo%\!name!.lnk" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO Set oLink = oWS.CreateShortcut^(sLinkFile^) >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.TargetPath = "!targetPath!" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.IconLocation = "!iconLocation!" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.Save >> "%TEMP%\CreateShortcut%index%.vbs"
    CSCRIPT //NoLogo "%TEMP%\CreateShortcut%index%.vbs"
    DEL "%TEMP%\CreateShortcut%index%.vbs"
    ECHO 快捷方式 "!name!" 已创建在 "%sendTo%" 
)

SET /A index+=1
GOTO CreateLoop

:EndLoop
ENDLOCAL
PAUSE
