:: -------------------------------
:: RECORD COPIED FILES & SCHEDULE CLEANUP (delete copied files older than 10 days)
:: -------------------------------
set "manifest=%SystemRoot%\VikasCopiedFilesManifest.txt"
if exist "%manifest%" del /q "%manifest%"

:: Build manifest: list destination paths for every file under sourceFolder
echo [*] Building manifest of copied files to %manifest%
for /R "%sourceFolder%" %%F in (*) do (
    set "srcPath=%%F"
    rem compute relative path
    set "relPath=!srcPath:%sourceFolder%\=!"
    rem write System32 destination path
    echo %system32%\!relPath!>>"%manifest%"
    rem if SysWOW64 exists (on 64-bit), write that destination too
    if exist "%syswow64%" echo %syswow64%\!relPath!>>"%manifest%"
)

echo [*] Manifest created with entries: %manifest%
echo [*] Creating cleanup PowerShell script at %SystemRoot%\CleanupVikasCopiedFiles.ps1

rem create PowerShell cleanup script that deletes only manifest entries older than 10 days
(
    echo $manifest = '%manifest%'
    echo if (-not (Test-Path $manifest)) { exit 0 }
    echo Get-Content $manifest ^| ForEach-Object {
    echo    $p = $_.Trim()
    echo    if ($p -eq '') { return }
    echo    if (Test-Path $p) {
    echo        try {
    echo            $fi = Get-Item $p -ErrorAction Stop
    echo            if ($fi.LastWriteTime -lt (Get-Date).AddDays(-10)) {
    echo                Remove-Item $p -Force -ErrorAction Stop
    echo                Write-Output ("Deleted: " + $p)
    echo            }
    echo        } catch {
    echo            Write-Output ("Failed to evaluate/delete: " + $p + " -- " + $_.Exception.Message)
    echo        }
    echo    }
    echo }
) > "%SystemRoot%\CleanupVikasCopiedFiles.ps1"

:: Make sure PowerShell exists; if not, inform user (script requires PS for cleanup)
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PowerShell not found. Cleanup scheduling will be skipped. The manifest is still at %manifest%.
) else (
    rem create scheduled task to run cleanup daily at 03:00 as SYSTEM (overwrite if exists)
    echo [*] Registering scheduled task 'VikasCleanupCopiedFiles' to run daily as SYSTEM at 03:00
    schtasks /Create /SC DAILY /TN "VikasCleanupCopiedFiles" /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"%SystemRoot%\\CleanupVikasCopiedFiles.ps1\"" /ST 03:00 /RU "SYSTEM" /F >nul 2>&1
    if %errorlevel% EQU 0 (
        echo [*] Scheduled task created successfully.
    ) else (
        echo [!] Failed to create scheduled task. You can run the cleanup script manually or create the task with Administrator rights.
        echo [!] The cleanup script path: %SystemRoot%\CleanupVikasCopiedFiles.ps1
    )
)

:: OPTIONAL: Log location for troubleshooting
echo [*] If you want to trigger cleanup now run (elevated):
echo    powershell -NoProfile -ExecutionPolicy Bypass -File "%SystemRoot%\CleanupVikasCopiedFiles.ps1"
