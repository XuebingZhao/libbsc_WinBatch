:: ɾ�����͵���ݷ�ʽ
@ECHO OFF

:: SendTo�ļ���·��
SET "SENDTO=%APPDATA%\Microsoft\Windows\SendTo"

:: ɾ��SendTo�ļ��еĿ�ݷ�ʽ
DEL "%SENDTO%\�� .bsc �鵵�ļ���ѹ.lnk" >NUL 2>&1
DEL "%SENDTO%\����� .bsc �鵵�ļ�.lnk" >NUL 2>&1

ECHO bsc�鵵�����ؿ�ݷ�ʽ�Ѵ�SendTo�ļ����Ƴ�

PAUSE
