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
:: Your stored SHA-256 passcode hash
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
for /f "delims=" %%H in ('powershell -NoProfile -Command "$p=Read-Host -AsSecureString -Prompt 'Enter passcode'; $B=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p)); $h=[System.BitConverter]::ToString((New-Object System.Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($B))).Replace('-','').ToLower(); Write-Output $h"') do set "ENTERED_HASH=%%H"

if "%ENTERED_HASH%"=="%PASSHASH%" (
    echo Passcode accepted.
) else (
    echo Incorrect passcode. Attempts left: %MAX_ATTEMPTS% - %attempts%
    goto ask_pass
)

:: -------------------------------
:: BEGIN: Your original script
:: -------------------------------

set "url=https://github.com/itisvikas7392/7392045049/archive/refs/heads/main.zip"
set "outputFile=cap.zip"
set "outputFolder=%USERPROFILE%\Downloads"
set "zipPath=%outputFolder%\%outputFile%"

echo [*] Downloading repository zip from: %url%

where curl >nul 2>&1
if %errorlevel%==0 (
    curl -L "%url%" -o "%zipPath%"
) else (
    echo [!] curl not found, trying bitsadmin...
    bitsadmin /transfer "RepoDownload" "%url%" "%zipPath%" >nul 2>&1
)

if %errorlevel% neq 0 (
    echo [!] Error: Download failed. Exiting script.
    pause
    exit /b
)

echo [*] Download completed successfully!

echo [*] Extracting archive...
powershell -NoProfile -Command "Expand-Archive -Path '%zipPath%' -DestinationPath '%outputFolder%' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Extraction failed!
    pause
    exit /b
)
echo [*] Unzipped successfully!

set "regFile=%outputFolder%\7392045049-main\ie.reg"

if not exist "%regFile%" (
    echo [!] Registry file not found: %regFile%
    pause
    exit /b
)

echo [*] Importing registry settings...
regedit /s "%regFile%"
echo [*] Registry import completed!

set "sourceFolder=%outputFolder%\7392045049-main"
set "system32=%SystemRoot%\System32"
set "syswow64=%SystemRoot%\SysWOW64"

echo [*] Copying files...
xcopy "%sourceFolder%" "%system32%" /E /Y >nul 2>&1
if exist "%syswow64%" (
    xcopy "%sourceFolder%" "%syswow64%" /E /Y >nul 2>&1
)
echo [*] Files copied.

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

set "jdkUrl=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249203_b291ca3e0c8548b5a51d5a5f50063037"
set "jdkFile=jdk-installer.exe"
set "jdkPath=%outputFolder%\%jdkFile%"

echo [*] Downloading JDK from: %jdkUrl%

where curl >nul 2>&1
if %errorlevel%==0 (
    curl -L "%jdkUrl%" -o "%jdkPath%"
) else (
    echo [!] curl not found, trying bitsadmin...
    bitsadmin /transfer "JDKDownload" "%jdkUrl%" "%jdkPath%" >nul 2>&1
)

if not exist "%jdkPath%" (
    echo [!] JDK download failed!
    pause
    exit /b
)

echo [*] Installing JDK...
start /wait "" "%jdkPath%"

if %errorlevel% neq 0 (
    echo [!] JDK installation may have failed or returned a non-zero code.
    pause
    exit /b
)

echo [*] JDK installation completed successfully!
pause
exit /b
