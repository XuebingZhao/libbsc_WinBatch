@ECHO OFF
SETLOCAL EnableDelayedExpansion

:: 设置 7z.exe 程序路径
SET sevenzExe="%~dp0..\bin\7z.exe"
:: 设置 bsc.exe 程序路径
SET bscExe="%~dp0..\bin\bsc.exe"

:: 设置临时文件名
FOR /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') DO SET "dateTime=%%a"
SET "timeStamp=!dateTime:~0,14!"
SET "tempFile=%temp%\BSC!timeStamp!.tar"
SET "tempList=%temp%\BSC!timeStamp!.txt"

:: 设置退出处理程序
GOTO :MAIN

:CLEANUP
IF EXIST "!tempFile!" DEL "!tempFile!" /f /q >nul 2>&1
IF EXIST "!tempList!" DEL "!tempList!" /f /q >nul 2>&1
EXIT /B

:MAIN
:: 设置输入文件名
SET "inputFile=%~dpnx1"

:: 要求扩展名必须为 ".tar.bsc"
SET "extension=%inputFile:~-8%"
FOR /F "tokens=*" %%a IN ('powershell -Command "& {$string = '%extension%'; $string.ToLower()}"') DO SET "lowerExt=%%a"
IF NOT "!lowerExt!" == ".tar.bsc" (
    ECHO ERROR: File "%~nx1" is not a .tar.bsc file.
    PAUSE
    GOTO :CLEANUP
)

:: 设置输出路径名
SET "outputPath=!inputFile:~0,-8!\"

ECHO InputFile ：!inputFile!
ECHO TempFile  ：!tempFile!
ECHO OutputPath：!outputPath!
ECHO ------------------------------------------------------------------------

:: 解压到临时 .tar
%bscExe% d "!inputFile!" "!tempFile!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to decompress !inputFile!
    PAUSE
    GOTO :CLEANUP
)

:: 判断顶层目录数量
%sevenzExe% l "!tempFile!" > "!tempList!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to list contents of tar file
    PAUSE
    GOTO :CLEANUP
)

SET "topFolderCount=0"
:: 逐行读取 7z l 的输出，并统计顶层目录数量
FOR /f "tokens=*" %%a in ('type "!tempList!" ^| findstr "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"') DO (
    SET "line=%%a"
    
    :: 检查是否为目录（属性字段是D开头）
    IF "!line:~20,1!"=="D" (
        :: 提取名称
        SET "name=!line:~53!"
        
        :: 检查名称是否不包含\
        SET "nameNoBackslash=!name:\=!"
        IF "!name!" == "!nameNoBackslash!" (
            :: 检查名称是否不包含/
            SET "nameNoSlash=!name:/=!"
            IF "!name!" == "!nameNoSlash!" (
                SET /a topFolderCount+=1
            )
        )
    )
)

:: 删除临时列表文件
DEL "!tempList!" /f /q >nul 2>&1

:: 仅有一层顶层文件夹时，解压到当前文件夹
IF !topFolderCount! == 1 (
    SET "outputPath=%~dp1"
    ECHO ------------------------------------------------------------------------
    ECHO Automaticaly redirect outputPath：!outputPath!
    ECHO ------------------------------------------------------------------------
)

:: 解包 .tar 文件并删除临时文件
"C:\Program Files\PeaZip\res\bin\7z\7z.exe" x -aot -bse0 -bsp2 "-o!outputPath!" -sccUTF-8 -snz "!tempFile!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to extract tar file
    PAUSE
    GOTO :CLEANUP
)

:: 执行清理
CALL :CLEANUP

ENDLOCAL
