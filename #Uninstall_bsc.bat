:: 删除发送到快捷方式
@ECHO OFF

:: SendTo文件夹路径
SET "SENDTO=%APPDATA%\Microsoft\Windows\SendTo"

:: 删除SendTo文件夹的快捷方式
DEL "%SENDTO%\从 .bsc 归档文件解压.lnk" >NUL 2>&1
DEL "%SENDTO%\打包成 .bsc 归档文件.lnk" >NUL 2>&1

ECHO bsc归档软件相关快捷方式已从SendTo文件夹移除

PAUSE
