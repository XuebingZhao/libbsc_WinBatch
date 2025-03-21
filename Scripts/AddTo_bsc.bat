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

:: 设置退出处理，确保在脚本退出时清理临时文件
GOTO :MAIN

:CLEANUP
IF EXIST "!tempFile!" (
    DEL "!tempFile!" /f /q >nul 2>&1
    IF EXIST "!tempFile!" ECHO Warning: Failed to delete temporary file: !tempFile!
)
EXIT /B

:MAIN
:: 设置输入文件名
SET "inputFile=%~dpnx1"
SET "inputArg="!inputFile!""

:: 要求输入文件存在
IF "!inputFile!" == "" (
    ECHO ERROR: Empty input file.
    PAUSE
    GOTO :CLEANUP
)
IF NOT EXIST "!inputFile!" (
    ECHO ERROR: Input file or path "!inputFile!" does not exist.
    PAUSE
    GOTO :CLEANUP
)

:: 设置输出文件名
SET "outputFile=%~dpn1.tar.bsc"

:: 处理多个输入文件的情况
SET "dirPath=%~dp1"
FOR %%I in (%dirPath:~0,-1%) DO SET "fileNamedByFolder=!dirPath!%%~nI.tar.bsc"  :: 用文件夹名作为前缀
IF NOT "%~2"=="" (
    SET "inputArg=%*"
    SET "outputFile=!fileNamedByFolder!"
)

:: 获取 NVIDIA 显卡 Compute Capability
FOR /f "tokens=*" %%i in ('nvidia-smi --query-gpu^=compute_cap --format^=csv^,noheader') DO SET computeCap=%%i
IF "!computeCap!"=="" SET "computeCap=0.0"

ECHO InputFile ：!inputArg!
ECHO TempFile  ：!tempFile!
ECHO OutputFile：!outputFile!
ECHO ------------------------------------------------------------------------

:: 将文件(夹)打包为 .tar
%sevenzExe% a -ttar -w -bb0 -bse0 -bsp2 "!tempFile!" !inputArg!
IF %ERRORLEVEL% NEQ 0 (
    ECHO Error creating tar file.
    PAUSE
    GOTO :CLEANUP
)

:: 将 .tar 压缩为 .tar.bsc
IF !computeCap! GEQ 5 (
    ECHO [Using NVIDIA GPU acceleration]
    %bscExe% e "!tempFile!" "!outputFile!" -b64m0e2 -G
) ELSE (
    %bscExe% e "!tempFile!" "!outputFile!" -b64m0e2
)

:: 执行清理操作
CALL :CLEANUP

PAUSE
ENDLOCAL
