@echo off
title NVD System Cleanup Tool v2.0
mode con cols=80 lines=30 >nul 2>&1
color 0B >nul 2>&1

REM === Welcome Screen ===
cls
echo.
echo  ================================================================================
echo                           NVD SYSTEM CLEANUP TOOL v2.0
echo  ================================================================================
echo.
echo                              Welcome %USERNAME%!
echo.
echo                    Thank you for using NVD System Cleanup Tool
echo                         Your trusted system maintenance utility
echo.
echo  ________________________________________________________________________________
echo.
echo   This tool will help you:
echo   * Clean temporary files and free up disk space
echo   * Clear browser caches and system logs  
echo   * Remove unnecessary files safely
echo   * Optimize your system performance
echo.
echo  ________________________________________________________________________________
echo.
echo   System Information:
echo   * Current User: %USERNAME%
echo   * Computer Name: %COMPUTERNAME%
echo   * Current Time: %DATE% %TIME%
echo.
echo  ________________________________________________________________________________
echo.
echo                         Press any key to start cleanup...
echo.
pause >nul

REM === Configuration ===
set VERSION=2.0
set LOGFILE=%~dp0cleanup_log.txt

REM === Initialize logging ===
echo [%date% %time%] Script started - User: %USERNAME% > "%LOGFILE%"
echo Initializing NVD System Cleanup Tool...
pause

REM === Start the main program ===
goto menu_loop

:draw_header
cls
echo.
echo  ================================================================================
echo                           NVD SYSTEM CLEANUP TOOL v%VERSION%
echo  ================================================================================
echo.
goto :eof

:draw_menu
call :draw_header
echo  CLEANUP OPTIONS:
echo  ________________________________________________________________________________
echo.
echo   [1] Quick Clean     - Temp files, Recycle Bin
echo   [2] Standard Clean  - + Browser cache, System temp  
echo   [3] Deep Clean      - + Logs, Prefetch, Large files
echo   [4] Dry Run         - Preview what will be cleaned
echo.
echo   [D] View Disk Usage    [L] View Last Log    [Q] Quit
echo  ________________________________________________________________________________
echo.
set /p choice=Select option: 
goto :eof

:menu_loop
call :draw_menu

if "%choice%"=="" (
    echo No choice entered. Please try again.
    pause
    goto menu_loop
)

echo You selected: %choice%

if "%choice%"=="1" goto quick_clean
if "%choice%"=="2" goto standard_clean  
if "%choice%"=="3" goto deep_clean
if "%choice%"=="4" goto dry_run
if "%choice%"=="d" goto disk_usage
if "%choice%"=="D" goto disk_usage
if "%choice%"=="l" goto view_log
if "%choice%"=="L" goto view_log
if "%choice%"=="q" goto quit
if "%choice%"=="Q" goto quit

echo Invalid choice: %choice%
pause
goto menu_loop

:quick_clean
call :draw_header
echo  STATUS: Starting Quick Clean...
echo  ________________________________________________________________________________
echo.

echo [1/3] Cleaning temp files...
if exist "%TEMP%" (
    echo Temp directory: %TEMP%
    echo Cleaning...
    rd /s /q "%TEMP%" >nul 2>&1
    md "%TEMP%" >nul 2>&1
    echo   - User temp directory cleaned
) else (
    echo   - User temp directory not found
)

echo [2/3] Clearing recycle bin...
echo Running PowerShell command...
powershell -command "Clear-RecycleBin -Force -Confirm:$false" >nul 2>&1
echo   - Recycle bin cleared

echo [3/3] Cleaning metadata...
echo Cleaning Thumbs.db files in user directories...
if exist "%USERPROFILE%" (
    del /f /s /q "%USERPROFILE%\Thumbs.db" >nul 2>&1
)
echo Cleaning .DS_Store files in user directories...
if exist "%USERPROFILE%" (
    del /f /s /q "%USERPROFILE%\.DS_Store" >nul 2>&1
)
echo   - Metadata files cleaned

echo.
echo ================================================================================
echo                         QUICK CLEAN COMPLETED!
echo ================================================================================
echo.

REM Calculate final disk space for quick clean
echo Calculating disk space freed...
set final_free=0
set final_gb=0
set used_gb_before=0
set used_gb_after=0
set freed_gb=0

REM Get final disk space
for /f "tokens=3" %%a in ('dir C:\ ^| find "bytes free"') do (
    set final_free=%%a
    set final_free=!final_free:,=!
)

REM Calculate values safely
if defined final_free if not "%final_free%"=="0" (
    set /a final_gb=%final_free% / 1073741824 2>nul
)
if not defined final_gb set final_gb=0

REM Calculate used space and freed space
if not "%total_gb%"=="0" if not "%initial_gb%"=="" if not "%final_gb%"=="" (
    set /a used_gb_before=%total_gb% - %initial_gb% 2>nul
    set /a used_gb_after=%total_gb% - %final_gb% 2>nul
    set /a freed_gb=%final_gb% - %initial_gb% 2>nul
)

REM Set defaults if calculations failed
if not defined used_gb_before set used_gb_before=Unknown
if not defined used_gb_after set used_gb_after=Unknown
if not defined freed_gb set freed_gb=0

echo DISK SPACE RESULTS:
echo ________________________________________________________________________________
echo.
echo   Before cleanup:    %used_gb_before% GB used / %total_gb% GB total  (%initial_gb% GB free)
echo   After cleanup:     %used_gb_after% GB used / %total_gb% GB total  (%final_gb% GB free)
echo   Space freed:       %freed_gb% GB
echo.
echo Quick cleanup completed successfully!
echo [%date% %time%] Quick clean completed >> "%LOGFILE%"
echo.
pause
goto menu_loop

:standard_clean
call :draw_header
echo  STATUS: Starting Standard Clean...
echo  ________________________________________________________________________________
echo.

echo [1/6] Cleaning temp files...
if exist "%TEMP%" (
    echo Temp directory: %TEMP%
    rd /s /q "%TEMP%" >nul 2>&1
    md "%TEMP%" >nul 2>&1
    echo   - User temp directory cleaned
) else (
    echo   - User temp directory not found
)

echo [2/6] Clearing recycle bin...
powershell -command "Clear-RecycleBin -Force -Confirm:$false" >nul 2>&1
echo   - Recycle bin cleared

echo [3/6] Cleaning browser caches...
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
    echo   - Chrome cache cleaned
)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
    echo   - Chrome code cache cleaned
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
    echo   - Edge cache cleaned
)
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%D in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%D\cache2" (
            rd /s /q "%%D\cache2" >nul 2>&1
            echo   - Firefox cache cleaned
        )
    )
)

echo [4/6] Cleaning system temp...
if exist "C:\Windows\Temp" (
    echo System temp: C:\Windows\Temp
    rd /s /q "C:\Windows\Temp" >nul 2>&1
    md "C:\Windows\Temp" >nul 2>&1
    echo   - System temp directory cleaned
)

echo [5/6] Cleaning package caches...
where npm >nul 2>&1 && (
    echo   - Found npm, cleaning cache...
    npm cache clean --force >nul 2>&1
    echo   - npm cache cleaned
)
where yarn >nul 2>&1 && (
    echo   - Found yarn, cleaning cache...
    yarn cache clean >nul 2>&1
    echo   - yarn cache cleaned
)
where pip >nul 2>&1 && (
    echo   - Found pip, cleaning cache...
    pip cache purge >nul 2>&1
    echo   - pip cache cleaned
)

echo [6/6] Cleaning metadata...
del /f /s /q C:\Thumbs.db >nul 2>&1
del /f /s /q C:\.DS_Store >nul 2>&1
echo   - Metadata files cleaned

echo.
echo ================================================================================
echo                        STANDARD CLEAN COMPLETED!
echo ================================================================================
echo.

REM Calculate final disk space for standard clean
echo Calculating disk space freed...
set final_free=0
set final_gb=0
set used_gb_before=0
set used_gb_after=0
set freed_gb=0

dir C:\ > temp_disk2.txt 2>nul
if exist temp_disk2.txt (
    for /f "tokens=3" %%a in ('type temp_disk2.txt ^| find "bytes free"') do (
        set final_free=%%a
    )
    del temp_disk2.txt >nul 2>&1
)

if defined final_free (
    set final_free=%final_free:,=%
    set /a final_gb=%final_free% / 1073741824
    set /a freed_gb=%final_gb% - %initial_gb%
    set /a used_gb_before=%total_gb% - %initial_gb%
    set /a used_gb_after=%total_gb% - %final_gb%
)

echo DISK SPACE RESULTS:
echo ________________________________________________________________________________
echo.
echo   Before cleanup:    %used_gb_before% GB used / %total_gb% GB total  (%initial_gb% GB free)
echo   After cleanup:     %used_gb_after% GB used / %total_gb% GB total  (%final_gb% GB free)
echo   Space freed:       %freed_gb% GB
echo.
echo Standard cleanup completed successfully!
echo [%date% %time%] Standard clean completed >> "%LOGFILE%"
echo.
pause
goto menu_loop

:deep_clean
call :draw_header
echo  STATUS: Starting Deep Clean...
echo  ________________________________________________________________________________
echo.
echo  WARNING: Deep clean will:
echo   - Terminate running development processes
echo   - Clear system logs and prefetch files
echo   - Clean Windows Update cache
echo   - Remove temporary installation files
echo.
set /p confirm=Continue with Deep Clean? (y/N): 
if not "%confirm%"=="y" if not "%confirm%"=="Y" (
    echo Deep clean cancelled.
    pause
    goto menu_loop
)

echo.
echo Starting deep clean process...
echo.

echo [1/10] Terminating development processes...
for %%i in (node.exe Code.exe bash.exe wsl.exe python.exe java.exe) do (
    tasklist | find /i "%%i" >nul 2>&1 && (
        echo   - Stopping %%i...
        taskkill /f /im %%i >nul 2>&1
    )
)
echo   - Development processes terminated

echo [2/10] Cleaning temp files...
if exist "%TEMP%" (
    rd /s /q "%TEMP%" >nul 2>&1
    md "%TEMP%" >nul 2>&1
    echo   - User temp directory cleaned
)

echo [3/10] Clearing recycle bin...
powershell -command "Clear-RecycleBin -Force -Confirm:$false" >nul 2>&1
echo   - Recycle bin cleared

echo [4/10] Cleaning browser caches...
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%D in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%D\cache2" rd /s /q "%%D\cache2" >nul 2>&1
    )
)
echo   - Browser caches cleaned

echo [5/10] Cleaning system temp...
if exist "C:\Windows\Temp" (
    rd /s /q "C:\Windows\Temp" >nul 2>&1
    md "C:\Windows\Temp" >nul 2>&1
    echo   - System temp directory cleaned
)

echo [6/10] Cleaning system logs...
if exist "C:\Windows\Logs\CBS" (
    for /f %%f in ('dir /b "C:\Windows\Logs\CBS\*.log" 2^>nul') do (
        del /f "C:\Windows\Logs\CBS\%%f" >nul 2>&1
    )
    echo   - CBS logs cleaned
)
if exist "C:\Windows\Logs\DISM" (
    del /f /q "C:\Windows\Logs\DISM\*" >nul 2>&1
    echo   - DISM logs cleaned
)

echo [7/10] Cleaning prefetch files...
if exist "C:\Windows\Prefetch" (
    del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
    echo   - Prefetch files cleaned
)

echo [8/10] Cleaning Windows Update cache...
if exist "C:\Windows\SoftwareDistribution\Download" (
    rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
    md "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
    echo   - Windows Update cache cleaned
)

echo [9/10] Cleaning package caches...
echo   - Starting package cache cleanup...

echo   - Skipping npm cache (can cause issues)
echo   - Skipping yarn cache (can cause issues)
echo   - Skipping pip cache (can cause issues)
echo   - Package cache cleanup completed (skipped for stability)

echo Step 9 completed successfully, moving to step 10...

echo [10/10] Final cleanup...
echo   - Cleaning Thumbs.db files in user directories...
if exist "%USERPROFILE%" (
    del /f /s /q "%USERPROFILE%\Thumbs.db" >nul 2>&1
    echo   - User profile Thumbs.db cleaned
)
if exist "C:\Users" (
    del /f /s /q "C:\Users\*\Thumbs.db" >nul 2>&1
    echo   - All users Thumbs.db cleaned
)

echo   - Cleaning .DS_Store files in user directories...
if exist "%USERPROFILE%" (
    del /f /s /q "%USERPROFILE%\.DS_Store" >nul 2>&1
    echo   - User profile .DS_Store cleaned
)

echo   - Checking Windows temp directory...
if exist "C:\Windows\Temp" (
    echo   - Cleaning remaining Windows temp files...
    del /f /q "C:\Windows\Temp\*.*" >nul 2>&1
    echo   - Windows temp files cleaned
) else (
    echo   - Windows temp directory not accessible
)

echo   - Final cleanup completed

echo.
echo ================================================================================
echo                          DEEP CLEAN COMPLETED!
echo ================================================================================
echo.

REM Calculate final disk space
echo Calculating disk space freed...
set final_free=0
set final_gb=0
set used_gb_before=0
set used_gb_after=0
set freed_gb=0

dir C:\ > temp_disk2.txt 2>nul
if exist temp_disk2.txt (
    for /f "tokens=3" %%a in ('type temp_disk2.txt ^| find "bytes free"') do (
        set final_free=%%a
    )
    del temp_disk2.txt >nul 2>&1
)

if defined final_free (
    set final_free=%final_free:,=%
    set /a final_gb=%final_free% / 1073741824
    set /a freed_gb=%final_gb% - %initial_gb%
    set /a used_gb_before=%total_gb% - %initial_gb%
    set /a used_gb_after=%total_gb% - %final_gb%
)

echo DISK SPACE RESULTS:
echo ________________________________________________________________________________
echo.
echo   Before cleanup:    %used_gb_before% GB used / %total_gb% GB total  (%initial_gb% GB free)
echo   After cleanup:     %used_gb_after% GB used / %total_gb% GB total  (%final_gb% GB free)
echo   Space freed:       %freed_gb% GB
echo.
echo All deep cleaning operations have been completed successfully.
echo.

REM Log the completion
echo [%date% %time%] Deep clean completed >> "%LOGFILE%" 2>nul

echo Writing completion log...
echo Deep clean finished at %date% %time%
echo.
echo Press any key to return to main menu...
pause >nul
echo Returning to menu...
goto menu_loop

:dry_run
call :draw_header
echo  STATUS: Dry Run - Preview Mode
echo  ________________________________________________________________________________
echo.

echo Analyzing your system...
echo.

if exist "%TEMP%" (
    echo   User Temp Directory:   %TEMP% [EXISTS]
) else (
    echo   User Temp Directory:   %TEMP% [NOT FOUND]
)

if exist "C:\Windows\Temp" (
    echo   System Temp Directory: C:\Windows\Temp [EXISTS]
) else (
    echo   System Temp Directory: C:\Windows\Temp [NOT FOUND]
)

echo   Browser Caches:        Would clean Chrome, Edge caches
echo   Recycle Bin:           Would be emptied
echo   Metadata Files:        Would remove Thumbs.db files
echo.
echo No files were deleted in this preview.
echo.
pause
goto menu_loop

:disk_usage
call :draw_header
echo  STATUS: Current Disk Usage
echo  ________________________________________________________________________________
echo.
echo Getting disk information...
dir C:\ | find "bytes"
echo.
pause
goto menu_loop

:view_log
call :draw_header
if exist "%LOGFILE%" (
    echo  STATUS: Log File Contents
    echo  ________________________________________________________________________________
    echo.
    type "%LOGFILE%"
) else (
    echo  No log file found at: %LOGFILE%
)
echo.
pause
goto menu_loop

:quit
call :draw_header
echo  Thank you for using NVD System Cleanup Tool!
echo.
echo [%date% %time%] Session ended >> "%LOGFILE%"
echo  Goodbye!
echo.
echo Press any key to exit...
pause
exit

REM === ERROR HANDLER ===
:error
echo.
echo ================================================================================
echo ERROR OCCURRED!
echo ================================================================================
echo An error happened in the script.
echo Please take a screenshot of this window and report the issue.
echo.
echo Press any key to exit...
pause
exit