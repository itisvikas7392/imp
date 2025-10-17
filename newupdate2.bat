@echo off
setlocal enabledelayedexpansion

:: =====================================
:: Developer header
:: =====================================
echo ===========================================
echo Developer: Vikas Prajapati
echo Role: Developer
echo Script start time: %date% %time%
echo ===========================================
echo.

:: -------------------------------
:: PASSCODE PROTECTION
:: -------------------------------
set "PASSHASH=3c35a5001df2c049e1f65fb1a7abe1d6e785818db88a5d0a90b8002bf5ca74c6"
set "MAX_ATTEMPTS=3"
set /a attempts=0

:ask_pass
if %attempts% GEQ %MAX_ATTEMPTS% (
    echo Too many failed attempts. Exiting.
    pause
    exit /b 1
)

set /a attempts+=1
echo Enter passcode to run this script (input is hidden):
for /f "delims=" %%H in (
    'powershell -NoProfile -Command ^
    "$p=Read-Host -AsSecureString -Prompt ''Enter passcode''; ^
    $B=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p)); ^
    $h=[System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($B))).Replace(''-'','').ToLower(); ^
    Write-Output $h"'
) do set "ENTERED_HASH=%%H"

if "%ENTERED_HASH%"=="%PASSHASH%" (
    echo Passcode accepted.
) else (
    echo Incorrect passcode. Attempts left: %MAX_ATTEMPTS% - %attempts%
    goto ask_pass
)

:: -------------------------------
:: Download and setup
:: -------------------------------
set "outputFolder=%USERPROFILE%\Downloads"

:: -------------------------------
:: Download GitHub repo zip
:: -------------------------------
set "repoUrl=https://github.com/itisvikas7392/7392045049/archive/refs/heads/main.zip"
set "repoZip=%outputFolder%\repo.zip"
echo [*] Downloading repository zip...
powershell -Command "Invoke-WebRequest -Uri '%repoUrl%' -OutFile '%repoZip%'"
if %errorlevel% neq 0 (
    echo [!] Repo download failed. Exiting.
    pause
    exit /b
)
echo [*] Download completed!

:: -------------------------------
:: Extract zip
:: -------------------------------
echo [*] Extracting repository...
powershell -NoProfile -Command "Expand-Archive -Path '%repoZip%' -DestinationPath '%outputFolder%' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Extraction failed!
    pause
    exit /b
)
echo [*] Extracted successfully!

set "sourceFolder=%outputFolder%\7392045049-main"

:: -------------------------------
:: Import registry file
:: -------------------------------
set "regFile=%sourceFolder%\ie.reg"
if not exist "%regFile%" (
    echo [!] Registry file not found: %regFile%
    pause
    exit /b
)
echo [*] Importing registry settings...
regedit /s "%regFile%"
echo [*] Registry import completed!

:: -------------------------------
:: Copy files to System32 / SysWOW64
:: -------------------------------
set "system32=%SystemRoot%\System32"
set "syswow64=%SystemRoot%\SysWOW64"

echo [*] Copying files to %system32%...
xcopy "%sourceFolder%" "%system32%" /E /Y >nul 2>&1

if exist "%syswow64%" (
    echo [*] Copying files to %syswow64%...
    xcopy "%sourceFolder%" "%syswow64%" /E /Y >nul 2>&1
)

:: -------------------------------
:: Execute any batch files in System32 / SysWOW64
:: -------------------------------
if exist "%system32%\Windows7-64bit.bat" (
    pushd "%system32%"
    call "Windows7-64bit.bat"
    popd
    echo [*] Executed Windows7-64bit.bat from System32
)

if exist "%syswow64%\Windows7-64bit.bat" (
    pushd "%syswow64%"
    call "Windows7-64bit.bat"
    popd
    echo [*] Executed Windows7-64bit.bat from SysWOW64
)

:: -------------------------------
:: Download and install JDK
:: -------------------------------
set "jdkUrl=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249203_b291ca3e0c8548b5a51d5a5f50063037"
set "jdkFile=%outputFolder%\jdk-installer.exe"

echo [*] Downloading JDK...
powershell -Command "Invoke-WebRequest -Uri '%jdkUrl%' -OutFile '%jdkFile%'"
if not exist "%jdkFile%" (
    echo [!] JDK download failed!
    pause
    exit /b
)

echo [*] Installing JDK...
start /wait "" "%jdkFile%"
if %errorlevel% neq 0 (
    echo [!] JDK installation may have failed.
    pause
    exit /b
)
echo [*] JDK installation completed successfully!

pause
exit /b
