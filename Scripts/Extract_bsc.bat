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
SET "tempList=%temp%\BSC!timeStamp!.txt"

:: �����˳��������
GOTO :MAIN

:CLEANUP
IF EXIST "!tempFile!" DEL "!tempFile!" /f /q >nul 2>&1
IF EXIST "!tempList!" DEL "!tempList!" /f /q >nul 2>&1
EXIT /B

:MAIN
:: ���������ļ���
SET "inputFile=%~dpnx1"

:: Ҫ����չ������Ϊ ".tar.bsc"
SET "extension=%inputFile:~-8%"
FOR /F "tokens=*" %%a IN ('powershell -Command "& {$string = '%extension%'; $string.ToLower()}"') DO SET "lowerExt=%%a"
IF NOT "!lowerExt!" == ".tar.bsc" (
    ECHO ERROR: File "%~nx1" is not a .tar.bsc file.
    PAUSE
    GOTO :CLEANUP
)

:: �������·����
SET "outputPath=!inputFile:~0,-8!\"

ECHO InputFile ��!inputFile!
ECHO TempFile  ��!tempFile!
ECHO OutputPath��!outputPath!
ECHO ------------------------------------------------------------------------

:: ��ѹ����ʱ .tar
%bscExe% d "!inputFile!" "!tempFile!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to decompress !inputFile!
    PAUSE
    GOTO :CLEANUP
)

:: �ж϶���Ŀ¼����
%sevenzExe% l "!tempFile!" > "!tempList!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to list contents of tar file
    PAUSE
    GOTO :CLEANUP
)

SET "topFolderCount=0"
:: ���ж�ȡ 7z l ���������ͳ�ƶ���Ŀ¼����
FOR /f "tokens=*" %%a in ('type "!tempList!" ^| findstr "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"') DO (
    SET "line=%%a"
    
    :: ����Ƿ�ΪĿ¼�������ֶ���D��ͷ��
    IF "!line:~20,1!"=="D" (
        :: ��ȡ����
        SET "name=!line:~53!"
        
        :: ��������Ƿ񲻰���\
        SET "nameNoBackslash=!name:\=!"
        IF "!name!" == "!nameNoBackslash!" (
            :: ��������Ƿ񲻰���/
            SET "nameNoSlash=!name:/=!"
            IF "!name!" == "!nameNoSlash!" (
                SET /a topFolderCount+=1
            )
        )
    )
)

:: ɾ����ʱ�б��ļ�
DEL "!tempList!" /f /q >nul 2>&1

:: ����һ�㶥���ļ���ʱ����ѹ����ǰ�ļ���
IF !topFolderCount! == 1 (
    SET "outputPath=%~dp1"
    ECHO ------------------------------------------------------------------------
    ECHO Automaticaly redirect outputPath��!outputPath!
    ECHO ------------------------------------------------------------------------
)

:: ��� .tar �ļ���ɾ����ʱ�ļ�
"C:\Program Files\PeaZip\res\bin\7z\7z.exe" x -aot -bse0 -bsp2 "-o!outputPath!" -sccUTF-8 -snz "!tempFile!"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ERROR: Failed to extract tar file
    PAUSE
    GOTO :CLEANUP
)

:: ִ������
CALL :CLEANUP

ENDLOCAL
