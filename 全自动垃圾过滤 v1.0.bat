@echo off&color 17
setlocal enableextensios
setlocal enabledelayedexpansion
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"



set mark="
set /a count =0
set /a lookfile =0
set /a presearch =0
mode con cols=62 lines=30
color 2F
:main
cls
echo 当前运行路径:%CD%
echo 版本v1.0 后续新增历史版本查看
echo    《请确认路径正确再执行操作！》     管理员权限:OK
echo ************************************************************
echo *                                                          *
echo *                                                          *
echo *  选择模式:                                               *
echo *            1.确认文件（Y）                               *
echo *            2.确认文件（跳过删除隐藏文件属性）            * 
echo *            3.确认文件（跳过删除隐藏文件属性和预搜索              *
echo *            4.删除文件（写完了）                          *
echo *            5.删除空文件夹（写完了）                      *
echo *            6.高级模式（没写完）                          *
echo *            7.全自动过滤删除（慎重）（没写完）            *
echo *                                                          *
echo *                                                          *
echo *           确认文件 (Y/1)               删除文件（2）     *
echo *                                                          *
echo ************************************************************
set /p user_maininput=(请输入 数字/Y/N)   (或者其他按键退出) 
if %user_maininput% equ 1 goto lookfile
if %user_maininput% equ 2 set /a lookfile =1
if %user_maininput% equ 2 goto lookfile
if %user_maininput% equ 3 set /a presearch =1
if %user_maininput% equ 3 goto lookfile
if %user_maininput% equ 4 goto deletefile
if %user_maininput% equ 5 goto EmptyFolder
if %user_maininput% equ Y goto lookfile
if %user_maininput% equ y goto lookfile
exit


::“确认文件主程序”
:lookfile

cls
echo 开始执行...
set /a count =0
echo 这里是文件目录列表 :>C:\\ListInvalidFile.txt
echo 删除条目即可不删除对应文件。 :>>C:\\ListInvalidFile.txt
echo 正在执行预处理...
 
if  %lookfile% == 1 (
set /a lookfile =0
echo 已经跳过删除隐藏文件属性...
goto noattriblookfile
)

if  %presearch% == 1 (
set /a presearch =0
echo 已经跳过删除隐藏文件属性...
echo 已经跳过预搜索...
goto presearch
)

::上面为判断

echo 正在删除隐藏文件属性...
attrib -r -a -s -h -i /s /d
echo OK...

:noattriblookfile

set /a count =0
echo 正在执行文件预搜索...
echo 正在确认总文件个数...
for /r  %%t in (*) do (
set /a count +=1
)
echo 确认完毕，总计%count%个文件。
set /a count =0
echo 正在确认总文件夹个数...
for /f "delims=" %%a in ('dir /ad /b /s ^|sort /r') do (
set /a count +=1
)
echo 确认完毕，总计%count%个文件夹。
set /a count =0

setlocal enabledelayedexpansion

:presearch
echo 正在搜索.tmp文件... 
for /r  %%l in (*.tmp) do (
echo %%l>>C:\\ListInvalidFile.txt && set /a count +=1
)
echo OK... 

echo 正在搜索.~$ -$等文件... 
for /r  %%l in (~$*) do (
echo %%l>>C:\\ListInvalidFile.txt && set /a count +=1
)

for /r  %%l in (-$*) do (
echo %%l>>C:\\ListInvalidFile.txt && set /a count +=1
)
echo OK... 

echo 搜索完毕。
echo 总计无用文件%count%个。
set /a count =0
echo 请在C盘根目录内的ListInvalidFile.txt查看校验。
echo 删除条目即可不删除对应文件。
echo 按键返回菜单。
"C:\\ListInvalidFile.txt"
pause
goto main



:deletefile
set /p user_deleteinput=确定检查完毕无问题了吗 ？(请输入1/2/Y/N)   
if %user_deleteinput% equ y goto deletefileok
if %user_deleteinput% equ Y goto deletefileok
if %user_deleteinput% equ 1 goto deletefileok
exit


::“读取文件删除文件模块”
:deletefileok
echo 开始执行...
echo 正在读取配置文件...
echo 正在删除...
setlocal enabledelayedexpansion

for /f "tokens=*" %%d in (C:\\ListInvalidFile.txt) do (
set target=%mark%%%d%mark%
del /f !target!

)
echo 删除完毕。 按键退出。
pause
exit


::“删除文件夹模块”
:EmptyFolder
cls
set /a count =0
echo 正在删除空文件夹...
for /f "delims=" %%a in ('dir /ad /b /s ^|sort /r') do (
 rd "%%a">nul 2>nul && set /a count +=1
)
echo 删除完毕。
echo 总计删除%count%个空文件夹。
set /a count =0
echo 按键返回主菜单。
pause
goto main