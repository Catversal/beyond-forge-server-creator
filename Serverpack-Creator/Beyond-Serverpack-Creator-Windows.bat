@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM Main Path

set "ROOT=%~dp0"
set "MAP_FILE=%ROOT%config\modpack_map.txt"
set "CLIENT_PACK=%ROOT%client_pack"
set "WIN_SCRIPT=%ROOT%config\system-files\windows-files\Win-Script.bat"
set "LISTS=%ROOT%config\remove_list"

REM GIT Path
set "GIT_PATH=https://github.com/Catversal/beyond-forge-server-creator/archive/refs/heads/main.zip"

REM Startup Screen / Text

echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo This script will auto Update now the config files to start.
echo Make sure you have an active Internet connection.
echo.
echo Press Enter to start...
pause >nul
echo.
echo Downloading Newest Config ...
echo.

mkdir "%Root%temp_download" >nul
powershell -Command "Invoke-WebRequest -Uri '%GIT_PATH%' -OutFile '%Root%temp_download\config_update.zip'"
Rem Extract Downloaded Zip

powershell -Command "Expand-Archive -Path '%Root%temp_download\config_update.zip' -DestinationPath '%Root%temp_download' -Force"

if exist "%Root%config" goto :OldConfigDelete 
goto :OldConfigNotExist
:OldConfigDelete
REM Old Config Delete
echo Deleting Old Config ...
rmdir /s /q "%Root%config" >nul
 
:OldConfigNotExist

REM Move New Config
echo Moving New Config ...
move "%Root%temp_download\beyond-forge-server-creator-main\Serverpack-Creator\config" "%Root%" >nul

REM Clean Temp Files
echo Cleaning Temp Files ...
rmdir /s /q "%Root%temp_download" >nul
echo.
timeout /t 5

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo Config Updated Successfully!
echo.
echo -------------------------------------------
echo  Info
echo -------------------------------------------
echo. 
echo  This Serverpack Creator will help you with the
echo  Creation a Serverpack for Beyond Packs.
echo. 
echo  It Supports following Modpacks:
echo.
for /f "usebackq tokens=1-5 delims=|" %%A in ("%MAP_FILE%") do (
  rem %%A=ID, %%B=Name, %%C=DisplayName, %%D=MC, %%E=Flag
  echo %%B
)
echo.
echo Press ENTER to continue...
pause >nul

:HostingTypeSelection
cls
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo ================================
echo   Hosting-Typ selection
echo ================================
echo.
echo  1 - Dedicated Server / Hosting 
echo  2 - Local Hosting on Your (PC) [Default]
echo.
echo Pleace select your Hosting Type (1 or 2):
echo.

set "hostingtype="
set /p hostingtype=Selection (1 or 2): 

if not defined hostingtype set "hostingtype=2"

if "%hostingtype%"=="1" (
    echo Selected: Dedicated Server / Hosting
) else if "%hostingtype%"=="2" (
    echo Selected: Local Hosting on Your [PC]
) else (
    echo.
    echo Invalid Entry, please select 1 or 2!
    timeout /t 5
    goto :HostingTypeSelection
)

timeout /t 3

REM === Main Script starten ===
call "%WIN_SCRIPT%"

exit /b
