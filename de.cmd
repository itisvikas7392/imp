@echo off
set "url=https://github.com/itisvikas7392/7392045049/archive/refs/heads/main.zip"
set "outputFile=cap.zip"
set "outputFolder=C:\Users\%username%\Downloads"
echo Downloading %url%...

curl -o "%outputFolder%\%outputFile%" -L "%url%" 
if %errorlevel% neq 0 (
    echo Error: Download failed. Exiting script.
    pause
    exit /b
)

echo Download completed successfully!
pause

:: Unzip the downloaded file
powershell -command "Expand-Archive -Path '%outputFolder%\%outputFile%' -DestinationPath '%outputFolder%' -Force"
echo Unzipped the downloaded file successfully!
pause

set "regFile=C:\Users\%username%\Downloads\7392045049-main\ie.reg"
if not exist "%regFile%" (
    echo Error: Registry file "%regFile%" not found. Exiting script.
    pause
    exit /b
)

echo Importing registry settings from %regFile%...
regedit /s "%regFile%"
echo Registry settings imported successfully!
pause

set "sourceFolder=C:\Users\%username%\Downloads\7392045049-main"
set "targetFolder32=C:\Windows\System32"
set "targetFolder64=C:\Windows\SysWOW64"

if exist "%targetFolder32%" (
   xcopy "%sourceFolder%" "%targetFolder32%" /E /Y
   echo Files copied successfully! for 32 bit
)
if exist "%targetFolder64%" (
   xcopy "%sourceFolder%" "%targetFolder64%" /E /Y
   echo Files copied successfully! for 64 bit
)

cd /d "%targetFolder32%"
call "Windows7-64bit.bat"
echo Executed Windows7-64bit.bat

cd /d "%targetFolder64%"
call "Windows7-64bit.bat"
echo Executed Windows7-64bit.bat

:: Delete the folder after successful operations
rmdir /s /q "%sourceFolder%"
echo Folder %sourceFolder% deleted successfully!
pause

set "url=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249203_b291ca3e0c8548b5a51d5a5f50063037"
set "outputFile=jdk-installer.exe"
set "outputFolder=C:\Users\%username%\Downloads"

echo Downloading JDK installer from %url%...
curl -o "%outputFolder%\%outputFile%" -L "%url%"

if %errorlevel% neq 0 (
    echo Error: Download failed. Exiting script.
    pause
    exit /b
)

echo Download completed successfully!
:: Run the installer
echo Installing JDK...
start /wait C:\Users\%username%\Downloads\jdk-installer.exe
echo Installation completed successfully!

:: Get the current date
for /f "tokens=1-3 delims=/" %%a in ('date /t') do (
    set day=%%a
    set month=%%b
    set year=%%c
)

:: Add 5 days to the current day
set /a day=day+5

:: Adjust if the day exceeds 30 (simplified for this example)
if %day% gtr 30 (
    set day=05
    set /a month=month+1
)

if %month% gtr 12 (
    set month=01
    set /a year=year+1
)

:: Format the date in MM/DD/YYYY format (expected by schtasks)
set "scheduledDate=%month%/%day%/%year%"

:: Schedule a task to delete the files Interop.CAPICOM.dll and capicom.dll after 5 days
schtasks /create /tn "DeleteSpecificFilesAfter5Days" /tr "%SystemRoot%\System32\cmd.exe /c del /f /q %targetFolder32%\Interop.CAPICOM.dll && del /f /q %targetFolder32%\capicom.dll && del /f /q %targetFolder64%\Interop.CAPICOM.dll && del /f /q %targetFolder64%\capicom.dll" /sc once /st 00:00 /sd %scheduledDate% /f

echo Interop.CAPICOM.dll and capicom.dll will be deleted from System32 and SysWOW64 after 5 days on %scheduledDate%.
pause
