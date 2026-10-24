@echo off
title microOS v1.0
color 0A
chcp 65001 >nul

:: Initialize Virtual Environment & Variables
set "OS_VERSION=microOS 1.0-batch"
set "CURRENT_USER=root"
set "CURRENT_DIR=C:\"
set "PATH_C=C:\"
set "PATH_DOCS=C:\Documents"
set "PATH_SYS=C:\System"

:BOOT
cls
echo ===================================================
echo               BOOTING %OS_VERSION%...
echo ===================================================
timeout /t 1 /nobreak >nul
echo [ OK ] Initializing virtual memory...
timeout /t 1 /nobreak >nul
echo [ OK ] Mounting virtual drives (C:\)...
timeout /t 1 /nobreak >nul
echo [ OK ] Loading kernel and command processor...
timeout /t 1 /nobreak >nul
goto LOGIN

:LOGIN
cls
echo ===================================================
echo                  LOGON SCREEN
echo ===================================================
echo Default user: root (Press Enter to bypass)
set /p "input_user=Username: "
if not "%input_user%"=="" set "CURRENT_USER=%input_user%"
goto WELCOME

:WELCOME
cls
echo Welcome back, %CURRENT_USER%!
echo Type 'help' to see available system commands.
echo.
goto SHELL

:SHELL
:: Prompt loop
set "USER_INPUT="
set /p "USER_INPUT=%CURRENT_USER%@microOS:%CURRENT_DIR%# "

:: Parse input (Split into command and argument)
for %%A in (%USER_INPUT%) do (
    set "CMD=%%A"
    goto PROCESS_CMD
)
goto SHELL

:PROCESS_CMD
if "%USER_INPUT%"=="" goto SHELL

:: --- COMMAND TABLE ---
if /i "%CMD%"=="help" goto HELP
if /i "%CMD%"=="cls" goto CLS_CMD
if /i "%CMD%"=="ver" goto VER_CMD
if /i "%CMD%"=="whoami" goto WHOAMI_CMD
if /i "%CMD%"=="dir" goto DIR_CMD
if /i "%CMD%"=="cd" goto CD_CMD
if /i "%CMD%"=="echo" goto ECHO_CMD
if /i "%CMD%"=="calc" goto APP_CALC
if /i "%CMD%"=="notepad" goto APP_NOTEPAD
if /i "%CMD%"=="reboot" goto BOOT
if /i "%CMD%"=="exit" goto EXIT_OS

echo microOS: command not found: %USER_INPUT%
goto SHELL

:: --- SYSTEM COMMANDS ---

:HELP
echo.
echo AVAILABLE COMMANDS:
echo   help        - Display this help menu
echo   cls         - Clear the screen
echo   ver         - Show OS version info
echo   whoami      - Display current logged-in user
echo   dir         - List contents of current directory
echo   cd [path]   - Change directory (C:\, C:\Documents, C:\System)
echo   echo [text] - Print text to screen
echo   calc        - Launch built-in mini calculator app
echo   notepad     - Launch built-in text editor app
echo   reboot      - Restart the microOS environment
echo   exit        - Shut down microOS
echo.
goto SHELL

:CLS_CMD
goto WELCOME

:VER_CMD
echo %OS_VERSION% (Running on Windows CMD Subsystem)
goto SHELL

:WHOAMI_CMD
echo %CURRENT_USER%
goto SHELL

:DIR_CMD
echo.
echo Directory of %CURRENT_DIR%
echo.
if "%CURRENT_DIR%"=="C:\" (
    echo [DIR]  Documents
    echo [DIR]  System
    echo        readme.txt
) else if "%CURRENT_DIR%"=="C:\Documents\" (
    echo [DIR]  ..
    echo        notes.txt
    echo        todo.list
) else if "%CURRENT_DIR%"=="C:\System\" (
    echo [DIR]  ..
    echo        kernel.sys
    echo        config.cfg
)
echo.
goto SHELL

:CD_CMD
:: Simple path switcher mockup
for %%A in (%USER_INPUT%) do set "ARG=%%A"
:: Check if user just typed 'cd' without args
if /i "%USER_INPUT%"=="cd" (
    echo %CURRENT_DIR%
    goto SHELL
)
:: Extract argument after 'cd '
set "TARGET=%USER_INPUT:~3%"
if "%TARGET%"=="C:\" set "CURRENT_DIR=C:\" & goto SHELL
if "%TARGET%"=="C:\Documents" set "CURRENT_DIR=C:\Documents\" & goto SHELL
if "%TARGET%"=="C:\System" set "CURRENT_DIR=C:\System\" & goto SHELL
if "%TARGET%"==".." set "CURRENT_DIR=C:\" & goto SHELL
echo cd: no such file or directory: %TARGET%
goto SHELL

:ECHO_CMD
set "TEXT=%USER_INPUT:~5%"
echo %TEXT%
goto SHELL

:: --- SIMULATED APPS ---

:APP_CALC
cls
echo === miniCalc v1.0 ===
set /p "EXPR=Enter expression (e.g., 5+5): "
set /a "RESULT=%EXPR%"
echo Result: %RESULT%
pause
goto WELCOME

:APP_NOTEPAD
cls
echo === nanoPad v1.0 ===
echo Type your note below. Press Ctrl+C to exit back to shell.
set /p "NOTE=Note content: "
echo Saved to virtual buffer: "%NOTE%"
pause
goto WELCOME

:EXIT_OS
echo Shutting down microOS...
timeout /t 1 /nobreak >nul
exit