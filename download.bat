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
