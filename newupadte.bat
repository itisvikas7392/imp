@echo off
setlocal enabledelayedexpansion

:: ===============================
:: Setup download paths
:: ===============================
set "url=https://github.com/itisvikas7392/7392045049/archive/refs/heads/main.zip"
set "outputFile=cap.zip"
set "outputFolder=%USERPROFILE%\Downloads"
set "zipPath=%outputFolder%\%outputFile%"

echo [*] Downloading repository zip from: %url%

:: Check if curl exists, else fallback to bitsadmin
where curl >nul 2>&1
if %errorlevel%==0 (
    curl -L "%url%" -o "%zipPath%"
) else (
    echo [!] curl not found, trying bitsadmin...
    bitsadmin /transfer "RepoDownload" "%url%" "%zipPath%"
)

if %errorlevel% neq 0 (
    echo [!] Error: Download failed. Exiting script.
    pause
    exit /b
)

echo [*] Download completed successfully!

:: ===============================
:: Unzip file using PowerShell
:: ===============================
echo [*] Extracting archive...
powershell -command "Expand-Archive -Path '%zipPath%' -DestinationPath '%outputFolder%' -Force"
if %errorlevel% neq 0 (
    echo [!] Extraction failed!
    pause
    exit /b
)
echo [*] Unzipped successfully!

:: ===============================
:: Import registry file
:: ===============================
set "regFile=%outputFolder%\7392045049-main\ie.reg"

if not exist "%regFile%" (
    echo [!] Registry file not found: %regFile%
    pause
    exit /b
)

echo [*] Importing registry settings...
regedit /s "%regFile%"
echo [*] Registry import completed!

:: ===============================
:: Copy files to System folders
:: ===============================
set "sourceFolder=%outputFolder%\7392045049-main"
set "system32=%SystemRoot%\System32"
set "syswow64=%SystemRoot%\SysWOW64"

echo [*] Copying files...
xcopy "%sourceFolder%" "%system32%" /E /Y >nul
if exist "%syswow64%" (
    xcopy "%sourceFolder%" "%syswow64%" /E /Y >nul
)

echo [*] Files copied successfully!

:: ===============================
:: Run included batch file
:: ===============================
if exist "%system32%\Windows7-64bit.bat" (
    cd /d "%system32%"
    call "Windows7-64bit.bat"
    echo [*] Executed Windows7-64bit.bat from System32
)

if exist "%syswow64%\Windows7-64bit.bat" (
    cd /d "%syswow64%"
    call "Windows7-64bit.bat"
    echo [*] Executed Windows7-64bit.bat from SysWOW64
)

:: ===============================
:: Download and install JDK
:: ===============================
set "jdkUrl=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249203_b291ca3e0c8548b5a51d5a5f50063037"
set "jdkFile=jdk-installer.exe"
set "jdkPath=%outputFolder%\%jdkFile%"

echo [*] Downloading JDK from: %jdkUrl%

where curl >nul 2>&1
if %errorlevel%==0 (
    curl -L "%jdkUrl%" -o "%jdkPath%"
) else (
    echo [!] curl not found, trying bitsadmin...
    bitsadmin /transfer "JDKDownload" "%jdkUrl%" "%jdkPath%"
)

if not exist "%jdkPath%" (
    echo [!] JDK download failed!
    pause
    exit /b
)

echo [*] Installing JDK...
start /wait "" "%jdkPath%"
if %errorlevel% neq 0 (
    echo [!] JDK installation failed!
    pause
    exit /b
)

echo [*] JDK installation completed successfully!
pause
exit /b
