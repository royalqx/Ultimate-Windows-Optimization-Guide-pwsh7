    @echo off
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
    if '%errorlevel%' NEQ '0' (
    goto uacprompt
    ) else ( goto gotadmin )
    :uacprompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
    :gotadmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

    :menu
    cls
    echo 1. Scripts: On (Recommended)
    echo 2. Scripts: Off
    set /p choice=:
    if "%choice%"=="1" goto A
    if "%choice%"=="2" goto B
    goto menu
    :A

cls
:: allow double click powershell 7 scripts
reg add "HKCR\Applications\pwsh.exe\shell\open\command" /ve /t REG_SZ /d "\"C:\Program Files\PowerShell\7\pwsh.exe\" -NoLogo -ExecutionPolicy unrestricted -File \"%%1\"" /f >nul 2>&1
:: allow powershell 7 scripts
reg add "HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
:: unblock all files in current directory
cd %~dp0
pwsh -Command "Get-ChildItem -Path . -Recurse | Unblock-File"
:: set default terminal to windows console host
reg add "HKCU\Console\%%Startup" /v "DelegationConsole" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f >nul 2>&1
reg add "HKCU\Console\%%Startup" /v "DelegationTerminal" /t REG_SZ /d "{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" /f >nul 2>&1
:: enable inline sudo for windows
sudo config --enable enable >nul 2>&1
echo Enabled Powershell 7 Scripts + Unblocked Files
pause
exit

    :B

cls
:: disallow double click powershell 7 scripts
reg delete "HKCR\Applications\pwsh.exe" /f >nul 2>&1
reg delete "HKCR\ps1_auto_file" /f >nul 2>&1
:: disallow powershell 7 scripts
reg add "HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Restricted" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Restricted" /f >nul 2>&1
:: set default terminal to let windows decide
reg add "HKCU\Console\%%Startup" /v "DelegationConsole" /t REG_SZ /d "{00000000-0000-0000-0000-000000000000}" /f >nul 2>&1
reg add "HKCU\Console\%%Startup" /v "DelegationTerminal" /t REG_SZ /d "{00000000-0000-0000-0000-000000000000}" /f >nul 2>&1
:: disable inline sudo for windows
sudo config --enable disable >nul 2>&1
echo Disabled Powershell 7 Scripts
pause
exit