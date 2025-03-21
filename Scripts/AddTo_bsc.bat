@ECHO OFF
SETLOCAL EnableDelayedExpansion

:: ���� 7z.exe ����·��
SET sevenzExe="%~dp0..\bin\7z.exe"
:: ���� bsc.exe ����·��
SET bscExe="%~dp0..\bin\bsc.exe"

:: ������ʱ�ļ���
FOR /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') DO SET "dateTime=%%a"
SET "timeStamp=!dateTime:~0,14!"
SET "tempFile=%temp%\BSC!timeStamp!.tar"

:: �����˳�����ȷ���ڽű��˳�ʱ������ʱ�ļ�
GOTO :MAIN

:CLEANUP
IF EXIST "!tempFile!" (
    DEL "!tempFile!" /f /q >nul 2>&1
    IF EXIST "!tempFile!" ECHO Warning: Failed to delete temporary file: !tempFile!
)
EXIT /B

:MAIN
:: ���������ļ���
SET "inputFile=%~dpnx1"
SET "inputArg="!inputFile!""

:: Ҫ�������ļ�����
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

:: ��������ļ���
SET "outputFile=%~dpn1.tar.bsc"

:: �����������ļ������
SET "dirPath=%~dp1"
FOR %%I in (%dirPath:~0,-1%) DO SET "fileNamedByFolder=!dirPath!%%~nI.tar.bsc"  :: ���ļ�������Ϊǰ׺
IF NOT "%~2"=="" (
    SET "inputArg=%*"
    SET "outputFile=!fileNamedByFolder!"
)

:: ��ȡ NVIDIA �Կ� Compute Capability
FOR /f "tokens=*" %%i in ('nvidia-smi --query-gpu^=compute_cap --format^=csv^,noheader') DO SET computeCap=%%i
IF "!computeCap!"=="" SET "computeCap=0.0"

ECHO InputFile ��!inputArg!
ECHO TempFile  ��!tempFile!
ECHO OutputFile��!outputFile!
ECHO ------------------------------------------------------------------------

:: ���ļ�(��)���Ϊ .tar
%sevenzExe% a -ttar -w -bb0 -bse0 -bsp2 "!tempFile!" !inputArg!
IF %ERRORLEVEL% NEQ 0 (
    ECHO Error creating tar file.
    PAUSE
    GOTO :CLEANUP
)

:: �� .tar ѹ��Ϊ .tar.bsc
IF !computeCap! GEQ 5 (
    ECHO [Using NVIDIA GPU acceleration]
    %bscExe% e "!tempFile!" "!outputFile!" -b64m0e2 -G
) ELSE (
    %bscExe% e "!tempFile!" "!outputFile!" -b64m0e2
)

:: ִ���������
CALL :CLEANUP

PAUSE
ENDLOCAL
