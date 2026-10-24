@echo off
setlocal EnableExtensions EnableDelayedExpansion
title microOS
set "OSVER=1.1"
set "ROOT=%~dp0microos_fs"
set "CFG=%~dp0microos.cfg"
if not exist "%ROOT%" mkdir "%ROOT%"

:: ============================ BOOT ============================
:boot
color 0A
cls
echo.
echo   microOS v%OSVER% - BIOS check
echo.
for %%s in ("Loading kernel" "Mounting virtual filesystem" "Starting services" "Launching shell") do (
    echo   [ OK ] %%~s
    timeout /t 1 /nobreak >nul
)
if not exist "%CFG%" goto setup
set "i=0"
for /f "usebackq delims=" %%a in ("%CFG%") do (
    set /a i+=1
    if !i!==1 set "OSUSER=%%a"
    if !i!==2 set "OSPASS=%%a"
)
goto login

:: ====================== FIRST-BOOT SETUP ======================
:setup
cls
echo.
echo   Welcome to microOS. Let's create your account.
echo.
set "OSUSER="
set /p "OSUSER=  Username: "
if "!OSUSER!"=="" goto setup
set "OSPASS="
set /p "OSPASS=  Password: "
if "!OSPASS!"=="" goto setup
call :savecfg
echo.
echo   Account created.
timeout /t 2 /nobreak >nul
goto login

:: ============================ LOGIN ============================
:login
cls
echo.
echo   microOS v%OSVER%
echo.
set "tries=0"
:login_loop
set "u="
set "p="
set /p "u=  login: "
set /p "p=  password: "
if /i "!u!"=="!OSUSER!" if "!p!"=="!OSPASS!" goto welcome
set /a tries+=1
echo   Access denied.
if !tries! geq 3 (
    echo   Too many failed attempts.
    timeout /t 3 /nobreak >nul
    exit /b
)
goto login_loop

:welcome
cls
echo.
echo   +----------------------------+
echo   ^|     m i c r o O S  %OSVER%      ^|
echo   +----------------------------+
echo.
echo   Welcome, !OSUSER!. Type 'help' for commands.
echo.
set "STARTED=%time:~0,8%"
cd /d "!ROOT!"

:: ============================ SHELL ============================
:shell
set "REL=!CD:%ROOT%=~!"
set "input="
set /p "input=!OSUSER!@micro:!REL!$ "
if not defined input goto shell
set "cmd="
set "args="
for /f "tokens=1,* delims= " %%a in ("!input!") do (
    set "cmd=%%a"
    set "args=%%b"
)
if /i "!cmd!"=="help"     goto c_help
if /i "!cmd!"=="ver"      goto c_ver
if /i "!cmd!"=="about"    goto c_ver
if /i "!cmd!"=="date"     goto c_date
if /i "!cmd!"=="time"     goto c_time
if /i "!cmd!"=="cls"      goto c_cls
if /i "!cmd!"=="clear"    goto c_cls
if /i "!cmd!"=="echo"     goto c_echo
if /i "!cmd!"=="ls"       goto c_ls
if /i "!cmd!"=="dir"      goto c_ls
if /i "!cmd!"=="cd"       goto c_cd
if /i "!cmd!"=="pwd"      goto c_pwd
if /i "!cmd!"=="mkdir"    goto c_mkdir
if /i "!cmd!"=="rmdir"    goto c_rmdir
if /i "!cmd!"=="touch"    goto c_touch
if /i "!cmd!"=="cat"      goto c_cat
if /i "!cmd!"=="type"     goto c_cat
if /i "!cmd!"=="rm"       goto c_rm
if /i "!cmd!"=="del"      goto c_rm
if /i "!cmd!"=="cp"       goto c_cp
if /i "!cmd!"=="mv"       goto c_mv
if /i "!cmd!"=="edit"     goto c_edit
if /i "!cmd!"=="calc"     goto c_calc
if /i "!cmd!"=="color"    goto c_color
if /i "!cmd!"=="whoami"   goto c_whoami
if /i "!cmd!"=="sysinfo"  goto c_sysinfo
if /i "!cmd!"=="passwd"   goto c_passwd
if /i "!cmd!"=="guess"    goto c_guess
if /i "!cmd!"=="logout"   goto login
if /i "!cmd!"=="reboot"   goto boot
if /i "!cmd!"=="exit"     goto c_exit
if /i "!cmd!"=="shutdown" goto c_exit
echo microOS: command not found: !cmd!
goto shell

:: ========================== COMMANDS ==========================
:c_help
echo.
echo   System
echo     help              show this list
echo     ver / about       version info
echo     sysinfo           system information
echo     whoami            current user
echo     date / time       current date / time
echo     cls / clear       clear the screen
echo     color [XY]        set colors (e.g. color 0B)
echo     passwd            change password
echo     logout / reboot   log out / restart
echo     exit / shutdown   power off
echo.
echo   Files (sandboxed to the microos_fs folder)
echo     ls / dir          list files
echo     pwd               print working directory
echo     cd [dir]          change directory (cd .. / cd /)
echo     mkdir [dir]       make a directory
echo     rmdir [dir]       remove an empty directory
echo     touch [file]      create an empty file
echo     cat [file]        show a file
echo     edit [file]       text editor (:wq save, :q cancel)
echo     cp [a] [b]        copy a file
echo     mv [a] [b]        move / rename a file
echo     rm [file]         delete a file
echo.
echo   Apps
echo     echo [text]       print text
echo     calc [expr]       calculator, e.g. calc (3+4)*5
echo     guess             number guessing game
echo.
goto shell

:c_ver
echo microOS v%OSVER% - a tiny operating system written in batch.
goto shell

:c_date
echo !date!
goto shell

:c_time
echo !time:~0,8!
goto shell

:c_cls
cls
goto shell

:c_echo
echo(!args!
goto shell

:c_whoami
echo !OSUSER!
goto shell

:c_pwd
echo !REL:\=/!
goto shell

:c_sysinfo
set "nf=0"
set "nd=0"
for /r "!ROOT!" %%f in (*) do set /a nf+=1
for /f "delims=" %%d in ('dir /s /b /ad "!ROOT!" 2^>nul') do set /a nd+=1
echo   OS        : microOS v%OSVER%
echo   User      : !OSUSER!
echo   Host      : %COMPUTERNAME%
echo   Boot time : !STARTED!
echo   Files     : !nf!
echo   Folders   : !nd!
goto shell

:c_ls
set "n=0"
for /f "delims=" %%f in ('dir /b /ad 2^>nul') do (
    echo   [dir]   %%f
    set /a n+=1
)
for /f "delims=" %%f in ('dir /b /a-d 2^>nul') do (
    echo   [file]  %%f
    set /a n+=1
)
if !n!==0 echo   (empty)
goto shell

:c_cd
if "!args!"=="" goto shell
if "!args!"=="/" (
    cd /d "!ROOT!"
    goto shell
)
if "!args!"==".." (
    if /i "!CD!"=="!ROOT!" (
        echo cd: already at root
    ) else (
        cd ..
    )
    goto shell
)
call :validate
if "!BAD!"=="1" echo cd: invalid name & goto shell
if exist "!args!\" (cd "!args!") else (echo cd: no such directory: !args!)
goto shell

:c_mkdir
call :validate
if "!BAD!"=="1" echo usage: mkdir [name] & goto shell
if exist "!args!" echo mkdir: already exists & goto shell
mkdir "!args!"
goto shell

:c_rmdir
call :validate
if "!BAD!"=="1" echo usage: rmdir [name] & goto shell
if not exist "!args!\" echo rmdir: no such directory & goto shell
rmdir "!args!" 2>nul || echo rmdir: directory not empty
goto shell

:c_touch
call :validate
if "!BAD!"=="1" echo usage: touch [file] & goto shell
type nul >> "!args!"
goto shell

:c_cat
call :validate
if "!BAD!"=="1" echo usage: cat [file] & goto shell
if not exist "!args!" echo cat: no such file & goto shell
type "!args!"
echo.
goto shell

:c_rm
call :validate
if "!BAD!"=="1" echo usage: rm [file] & goto shell
if not exist "!args!" echo rm: no such file & goto shell
del /q "!args!"
goto shell

:c_cp
set "a1="
set "a2="
for /f "tokens=1,2" %%a in ("!args!") do (
    set "a1=%%a"
    set "a2=%%b"
)
set "args=!a1!"
call :validate
if "!BAD!"=="1" echo usage: cp [source] [dest] & goto shell
set "args=!a2!"
call :validate
if "!BAD!"=="1" echo usage: cp [source] [dest] & goto shell
if not exist "!a1!" echo cp: no such file: !a1! & goto shell
copy /y "!a1!" "!a2!" >nul
goto shell

:c_mv
set "a1="
set "a2="
for /f "tokens=1,2" %%a in ("!args!") do (
    set "a1=%%a"
    set "a2=%%b"
)
set "args=!a1!"
call :validate
if "!BAD!"=="1" echo usage: mv [source] [dest] & goto shell
set "args=!a2!"
call :validate
if "!BAD!"=="1" echo usage: mv [source] [dest] & goto shell
if not exist "!a1!" echo mv: no such file: !a1! & goto shell
move /y "!a1!" "!a2!" >nul
goto shell

:c_edit
call :validate
if "!BAD!"=="1" echo usage: edit [file] & goto shell
set "TMPF=%TEMP%\microos_edit.tmp"
if exist "!args!" (
    echo --- existing content ---
    type "!args!"
    echo.
    echo --- new lines are appended ---
    copy /y "!args!" "!TMPF!" >nul
) else (
    type nul > "!TMPF!"
)
echo Type text. ':wq' on its own line saves, ':q' cancels.
:edit_loop
set "line="
set /p "line=  | "
if "!line!"==":q" (
    del "!TMPF!" 2>nul
    echo Cancelled.
    goto shell
)
if "!line!"==":wq" (
    move /y "!TMPF!" "!args!" >nul
    echo Saved !args!.
    goto shell
)
>> "!TMPF!" echo(!line!
goto edit_loop

:c_calc
if "!args!"=="" echo usage: calc [expression], e.g. calc (3+4)*5 & goto shell
set "res="
set /a "res=!args!" 2>nul
if not defined res (echo calc: invalid expression) else (echo = !res!)
goto shell

:c_color
if "!args!"=="" echo usage: color [XY]  (background, text; hex digit each) & goto shell
color !args! 2>nul || echo color: invalid value
goto shell

:c_passwd
set "old="
set /p "old=Current password: "
if not "!old!"=="!OSPASS!" echo passwd: wrong password & goto shell
set "new="
set /p "new=New password: "
if "!new!"=="" echo passwd: password cannot be empty & goto shell
set "OSPASS=!new!"
call :savecfg
echo Password updated.
goto shell

:c_guess
set /a "secret=%random% %% 100 + 1"
set "gt=0"
echo I'm thinking of a number between 1 and 100. (q to quit)
:guess_loop
set "g="
set /p "g=  guess: "
if /i "!g!"=="q" goto shell
set "gn=0"
set /a "gn=g" 2>nul
set /a gt+=1
if !gn! lss !secret! echo   Higher...
if !gn! gtr !secret! echo   Lower...
if !gn! neq !secret! goto guess_loop
echo   Correct! You got it in !gt! tries.
goto shell

:c_exit
echo Shutting down microOS...
timeout /t 1 /nobreak >nul
exit /b

:: ========================== HELPERS ==========================
:validate
:: Blocks paths so commands can't escape the sandbox folder.
set "BAD=0"
if "!args!"=="" set "BAD=1"
if not "!args:\=!"=="!args!" set "BAD=1"
if not "!args:/=!"=="!args!" set "BAD=1"
if not "!args::=!"=="!args!" set "BAD=1"
if not "!args:..=!"=="!args!" set "BAD=1"
goto :eof

:savecfg
>  "%CFG%" echo(!OSUSER!
>> "%CFG%" echo(!OSPASS!
goto :eof