@ECHO OFF
:: sendTo�ļ���·��
SET "sendTo=%APPDATA%\Microsoft\Windows\SendTo"

:: ������ʱVBS�ļ���������ݷ�ʽ
ECHO �����Ҽ������͵�����ݷ�ʽ��...

:: ʹ��ѭ�����������ݷ�ʽ
SETLOCAL EnableDelayedExpansion

:: �����ݷ�ʽ���� - ��ʽ������|Ŀ��·��|ͼ��λ��
SET "shortcuts[0]=����� .bsc �鵵�ļ�|Scripts\AddTo_bsc.bat|%SystemRoot%\System32\SHELL32.dll,166"
SET "shortcuts[1]=�� .bsc �鵵�ļ���ѹ|Scripts\Extract_bsc.bat|%SystemRoot%\System32\SHELL32.dll,166"
:: ��Ӹ����ݷ�ʽֻ���ڴ�������У���ʽ����

:: ѭ���������п�ݷ�ʽ
SET index=0
:CreateLoop
IF NOT DEFINED shortcuts[%index%] GOTO EndLoop

FOR /F "tokens=1-3 delims=|" %%A IN ("!shortcuts[%index%]!") DO (
    SET "name=%%A"
    SET "targetPath=%~dp0%%B"
    SET "iconLocation=%%C"
    
    :: ɾ�������Ѵ��ڵĿ�ݷ�ʽ
    IF EXIST "%sendTo%\!name!.lnk" DEL "%sendTo%\!name!.lnk"
    
    :: ������ʱVBS�ļ�
    ECHO Set oWS = WScript.CreateObject^("WScript.Shell"^) > "%TEMP%\CreateShortcut%index%.vbs"
    ECHO sLinkFile = "%sendTo%\!name!.lnk" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO Set oLink = oWS.CreateShortcut^(sLinkFile^) >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.TargetPath = "!targetPath!" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.IconLocation = "!iconLocation!" >> "%TEMP%\CreateShortcut%index%.vbs"
    ECHO oLink.Save >> "%TEMP%\CreateShortcut%index%.vbs"
    CSCRIPT //NoLogo "%TEMP%\CreateShortcut%index%.vbs"
    DEL "%TEMP%\CreateShortcut%index%.vbs"
    ECHO ��ݷ�ʽ "!name!" �Ѵ����� "%sendTo%" 
)

SET /A index+=1
GOTO CreateLoop

:EndLoop
ENDLOCAL
PAUSE
