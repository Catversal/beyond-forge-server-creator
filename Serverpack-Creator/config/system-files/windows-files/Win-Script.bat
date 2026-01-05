echo off >nul

if exist "%CLIENT_PACK%" goto :ClientPackNMissing
mkdir "%Root%client_pack" >nul
echo Creating Client_Pack Folder ...

timeout /t 5

:ClientPackNMissing

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo ====================================================
echo  Checking Client Pack Folder...
echo ====================================================
echo.
timeout /t 3

if exist "%CLIENT_PACK%\config" goto :clientconfigOK
goto :ModpacknotComplete
:ClientconfigOK
if exist "%CLIENT_PACK%\mods" goto :ClientModsOK
goto :ModpacknotComplete
:ClientModsOK
if exist "%CLIENT_PACK%\manifest.json" goto :ClientPackOK
goto :ModpacknotComplete
:ModpacknotComplete
cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo.
echo ====================================================
echo  Your client pack folder isnt complete.
echo ====================================================
echo.
echo Please copy the CONTENT of the Beyond modpack into this folder:
echo.
echo   %CLIENT_PACK%
echo.
echo Instructions:
echo.
echo 1. Open CurseForge
echo 2. Select the downloaded modpack
echo 3. Click the three dots next to the Play button
echo 4. Click "Open Folder"
echo 5. Copy the CONTENT of this folder into the client_pack directory
echo.
echo IMPORTANT:
echo - Copy ONLY the contents all files and folders INSIDE the modpack folder...
echo - Do NOT copy the parent folder itself
echo.
echo Press ENTER once you have finished copying the files.
echo.
pause >nul

goto :ClientPackNMissing

:ClientPackOK


REM --- Version aus manifest.json lesen ---
for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command ^
    "$m=Get-Content -Raw '%CLIENT_PACK%\manifest.json' | ConvertFrom-Json; $m.version"
`) do set "MANIFEST_VERSION=%%V"

REM --- Version aus manifest.json lesen ---
for /f "usebackq delims=" %%Z in (`
  powershell -NoProfile -Command ^
    "$m = Get-Content -Raw '%CLIENT_PACK%\manifest.json' | ConvertFrom-Json; ($m.minecraft.modLoaders | Where-Object { $_.primary -eq $true }).id"
`) do set "MANIFEST_FORGE=%%Z"

set "MANIFEST_FORGE=%MANIFEST_FORGE:forge-=%"


REM --- Name aus manifest.json lesen ---
for /f "usebackq delims=" %%N in (`
  powershell -NoProfile -Command ^
    "$m=Get-Content -Raw '%CLIENT_PACK%\manifest.json' | ConvertFrom-Json; $m.name"
`) do set "MANIFEST_NAME=%%N"

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Modpack name from manifest.json:
echo   "%MANIFEST_NAME%"
echo.
timeout /t 2

set "MODPACK=0"
set "MODPACK_NAME="
set "MCVER="
set "FORGEVER="
set "COPY_TACZ=0"

for /f "usebackq tokens=1-5 delims=|" %%A in ("%MAP_FILE%") do (
  set "ID=%%A"
  set "DISPLAY=%%B"
  set "MATCH=%%C"
  set "MC=%%D"
  set "CT=%%E"

  echo "%MANIFEST_NAME%" | findstr /I /C:"!MATCH!" >nul
  if not errorlevel 1 (
    set "MODPACK=!ID!"
    set "MODPACK_NAME=!DISPLAY!"
    set "MCVER=!MC!"
    set "FORGEVER=!FORGE!"
    set "COPY_TACZ=!CT!"
  )
)

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Detected: "%MODPACK_NAME%" (ID=%MODPACK%)
echo [INFO] mc=%MCVER% forge=%MANIFEST_FORGE% copy_tacz=%COPY_TACZ%
echo.
timeout /t 2

REM ===== Zielordner anlegen =====

set "BASE_NAME=Serverpack_%MODPACK_NAME%_%MANIFEST_VERSION%"
set COUNT=1

:CHECK_FOLDER
set "SERVERPACK=%ROOT%%BASE_NAME%_%COUNT%"

if exist "%SERVERPACK%" (
    set /a COUNT+=1
    goto CHECK_FOLDER
)

mkdir "%SERVERPACK%" >nul

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Serverpack folder Created:
echo   "%Serverpack%"
echo.
timeout /t 2

REM Kopiert alle Dateien und Unterordner, auch leere
XCOPY "%CLIENT_PACK%\config" "%SERVERPACK%\config" /E /I /H /Y
XCOPY "%CLIENT_PACK%\kubejs" "%SERVERPACK%\kubejs" /E /I /H /Y
XCOPY "%CLIENT_PACK%\defaultconfigs" "%SERVERPACK%\defaultconfigs" /E /I /H /Y
XCOPY "%CLIENT_PACK%\mods" "%SERVERPACK%\mods" /E /I /H /Y

if "%COPY_TACZ%"=="1" (
  XCOPY "%CLIENT_PACK%\tacz" "%SERVERPACK%\tacz" /E /I /H /Y
  XCOPY "%CLIENT_PACK%\tacz_backup" "%SERVERPACK%\tacz_backup" /E /I /H /Y
)
if "%MODPACK%"=="1" (
  pushd "%SERVERPACK%\mods"
  ren "Indestructible Server Fix-1.0.jar.disabled" "Indestructible Server Fix-1.0.jar"
  popd
)

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [OK] Copy step finished.
timeout /t 2

Rem Löschen von Mods

set "Remove=%ROOT%config\system-files\windows-files\Remove-Lists.bat"

call "%Remove%"

REM ===== Remove-Liste prüfen =====
if not exist "%REMOVE_LIST%" (
  
  cls
  echo.
  echo ============================================
  echo     Serverpack Builder - Beyond Packs
  echo ============================================
  echo by Catversal
  echo.
  echo [WARN] Remove list not found:
  echo   %REMOVE_LIST%
  echo.
  timeout /t 3
  goto :AfterModRemoval
)

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo.
echo [INFO] Removing client-only mods using list:
echo   %REMOVE_LIST%
echo.
timeout /t 2

for /f "usebackq delims=" %%L in ("%REMOVE_LIST%") do (
  set "PREFIX=%%L"
  if not "!PREFIX!"=="" (
    REM Löscht Prefix*.jar (falls nichts matcht, passiert nichts)
    for %%F in ("%SERVERPACK%\mods\!PREFIX!*.jar") do (
      if exist "%%~fF" (
        echo [DEL] %%~nxF
        del /q "%%~fF" 2>nul
      )
    )
  )
)


:AfterModRemoval


cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [OK] Mod removal step finished.
echo.
echo ==================================================
echo  [INFO] Java is required to run this server
echo --------------------------------------------------
echo  Please make sure you have Java 17, 18 or 21 installed. (not higher versions)
echo.
echo  Recommended for this server: Java 21 
echo.
echo  You can download Java (Eclipse Temurin) here:
echo  https://adoptium.net/de/temurin/releases
echo ==================================================
echo.
echo Press ENTER to continue
echo.
pause >nul




if "%hostingtype%"=="2" goto :SkipF
goto :SkipForgeinstall

:SkipF


REM === Forge Server installieren =====
set "FORGE_INSTALLER=%SERVERPACK%\forge-%MCVER%-%MANIFEST_FORGE%-installer.jar"
set "FORGE_URL=https://maven.minecraftforge.net/net/minecraftforge/forge/%MCVER%-%MANIFEST_FORGE%/forge-%MCVER%-%MANIFEST_FORGE%-installer.jar"
if not exist "%FORGE_INSTALLER%" (
  echo.
  echo [INFO] Downloading Forge installer: %MCVER%-%MANIFEST_FORGE%
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%FORGE_URL%' -OutFile '%FORGE_INSTALLER%';"
)

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Running Forge installer --installServer...
echo.
timeout /t 2
REM --- Run installer in target directory ---
pushd "%SERVERPACK%"
java -jar "%FORGE_INSTALLER%" --installServer
set INSTALL_RESULT=%ERRORLEVEL%
popd

if %INSTALL_RESULT% EQU 0 (
    del "%FORGE_INSTALLER%" >nul 2>&1
)

:SkipForgeinstall

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Writing server.properties...
echo.
timeout /t 2

> "%SERVERPACK%\server.properties" (
echo #Minecraft server properties
echo #Generated by setup script
echo allow-flight=true
echo allow-nether=true
echo broadcast-console-to-ops=true
echo broadcast-rcon-to-ops=true
echo difficulty=normal
echo enable-command-block=true
echo enable-jmx-monitoring=false
echo enable-query=false
echo enable-rcon=false
echo enable-status=true
echo enforce-secure-profile=true
echo enforce-whitelist=false
echo entity-broadcast-range-percentage=100
echo force-gamemode=false
echo function-permission-level=2
echo gamemode=survival
echo generate-structures=true
echo generator-settings={}
echo hardcore=false
echo hide-online-players=false
echo initial-disabled-packs=
echo initial-enabled-packs=vanilla
echo level-name=world
echo level-seed=
echo level-type=minecraft\:normal
echo max-chained-neighbor-updates=1000000
echo max-players=200
echo max-tick-time=-1
echo max-world-size=29999984
echo motd=\u00A74\u00A7lBeyond Modpack \u00A76 ^| \u00A71%MODPACK_NAME%\u00A7r\n\u00A74by Blueversal  \u00A76      ^|\u00A71 %MANIFEST_VERSION%
echo network-compression-threshold=1024
echo online-mode=true
echo op-permission-level=4
echo player-idle-timeout=0
echo prevent-proxy-connections=false
echo pvp=true
echo query.port=25565
echo rate-limit=0
echo rcon.password=
echo rcon.port=25575
echo require-resource-pack=false
echo resource-pack=
echo resource-pack-prompt=
echo resource-pack-sha1=
echo server-ip=
echo server-port=25565
echo simulation-distance=
echo spawn-animals=true
echo spawn-monsters=true
echo spawn-npcs=true
echo spawn-protection=0
echo sync-chunk-writes=true
echo text-filtering-config=
echo use-native-transport=true
echo view-distance=20
echo white-list=false
)

echo after properties

if "%hostingtype%"=="2" goto :SkipG
goto :SkipNoGuiPatch

:SkipG

echo after gotoproperties

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Patching run.bat by adding no gui ...
echo.
timeout /t 2

if exist "%SERVERPACK%\run.bat" del "%SERVERPACK%\run.bat" 2>nul

> "%SERVERPACK%\run.bat" (
echo @echo off
echo REM Forge requires a configured set of both JVM and program arguments.
echo REM Add custom JVM arguments to the user_jvm_args.txt
echo REM Add custom program arguments ^(such as nogui^) to this file in the next line before the %%* or
echo REM pass them to this script directly
echo java @user_jvm_args.txt @libraries/net/minecraftforge/forge/%MCVER%-%MANIFEST_FORGE%/win_args.txt nogui %%*
echo pause
)

REM RAM ALLOCATION

REM ==================================================
REM  RAM Setup + Optional JVM Performance Arguments
REM  Writes / REPLACES: user_jvm_args.txt
REM ==================================================

:SkipNoGuiPatch

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo ==================================================
echo  Dedicated Server RAM Allocation - Helper
echo  Recomanded Ram for Pack
echo --------------------------------------------------
if "%MODPACK%"=="1" echo  Beyond Ascension : 8GB base + 1GB per player
if "%MODPACK%"=="2" echo  Beyond Cosmo     : 8GB base + 1GB per player
if "%MODPACK%"=="3" echo  Beyond Depth     : 6GB base + 1GB per player
echo ==================================================
echo.


if "%hostingtype%"=="2" goto :SkipI
goto :SkipRamSetup

:SkipI

REM --- Detect total system RAM (GB, rounded) ---
set "TOTAL_RAM_GB=?"
for /f "usebackq delims=" %%R in (`
  powershell -NoProfile -Command ^
    "$gb=[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB); Write-Output $gb"
`) do set "TOTAL_RAM_GB=%%R"

echo [INFO] Detected system RAM: %TOTAL_RAM_GB% GB
echo.

REM --- Ask user for RAM amount (GB only) ---
set "RAM_GB="
set /p RAM_GB=How many GB of RAM should be allocated to the server? [default 6]: 

if "%RAM_GB%"=="" set "RAM_GB=6"

REM --- Validate numeric input ---
for /f "delims=0123456789" %%A in ("%RAM_GB%") do (
    echo.
    echo [WARN] Invalid RAM input detected. Using default: 6 GB.
    set "RAM_GB=6"
)

echo [INFO] Changing Xms ...
REM --- Xms policy: Xms = half of Xmx (minimum 2G) ---
set /a XMS_GB=%RAM_GB%/2 >nul 2>&1
if %XMS_GB% LSS 2 set "XMS_GB=2"


timeout /t 3
echo.

if %hostingtype%=="1" goto :JVMArgsPrompt

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
REM --- Ask if performance JVM args should be added ---
set "ADD_JVM_ARGS="
set /p ADD_JVM_ARGS=Add recommended JVM arguments? (Y/N) [default Y]: 
if "%ADD_JVM_ARGS%"=="" set "ADD_JVM_ARGS=Y"


REM --- Write / REPLACE user_jvm_args.txt ---
set "JVM_ARGS_FILE=%SERVERPACK%\user_jvm_args.txt"


> "%JVM_ARGS_FILE%" (
echo # Xmx and Xms set the maximum and minimum RAM usage, respectively.
    echo # They can take any number, followed by an M or a G.
    echo # M means Megabyte, G means Gigabyte.
    echo # For example, to set the maximum to 3GB: -Xmx3G
    echo # To set the minimum to 2.5GB: -Xms2500M
    echo.
    echo # A good default for a modded server is 4GB.
    echo # Uncomment the next line to set it.
    echo # -Xmx4G
    echo.
    echo -Xmx%RAM_GB%G
    echo -Xms%XMS_GB%G

    if /I "%ADD_JVM_ARGS%"=="Y" (
        echo -Dterminal.jline=false
        echo -Dterminal.ansi=true
        echo -XX:+UseG1GC
        echo -XX:+DisableExplicitGC
        echo -XX:+AlwaysPreTouch
        echo -XX:MaxGCPauseMillis=100
        echo -XX:InitiatingHeapOccupancyPercent=25
        echo -XX:G1ReservePercent=20
        echo -XX:+PerfDisableSharedMem
    )
)

echo.
echo [OK] user_jvm_args.txt updated successfully.
echo [INFO] Memory: -Xmx%RAM_GB%G  -Xms%XMS_GB%G
echo.

REM Accept EULA

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo ==================================================
echo  Minecraft EULA
echo --------------------------------------------------
echo  By running a Minecraft server you must accept
echo  the Minecraft End User License Agreement.
echo.
echo  https://aka.ms/MinecraftEULA
echo ==================================================
echo.
set /p ACCEPT_EULA=Do you accept the Minecraft EULA? (Y/N): 


if /I "%ACCEPT_EULA%"=="Y" (
    echo [INFO] EULA accepted. Writing eula.txt...
    > "%SERVERPACK%\eula.txt" (
        echo eula=true
    )
) else (
    echo.
    echo [WARN] You did NOT accept the Minecraft EULA.
    echo        The server will NOT start until eula=true
    echo        is set in eula.txt.
    echo.
    echo        You can accept it later by editing:
    echo        %SERVERPACK%\eula.txt
    echo.
)

:SkipRAMSetup

cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo.
echo [INFO] Grabbing Server Icon...

REM --- Download server icon ---

set "Server-Icon_Script=%ROOT%config\system-files\windows-files\Server-Icon.bat"

echo Server-Icon set: %SERVERPACK%\server-icon.png

call "%Server-Icon_Script%"

if "%hostingtype%"=="1" goto :SkipJ
goto :FinalMessage

:SkipJ


cls
echo.
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo.
echo ============================================
echo  [OK] Serverpack created successfully!
echo ============================================
echo Pack: %MODPACK_NAME%  MODPACK=%MODPACK%
echo Path: %SERVERPACK%
echo Forge: %MCVER%-%MANIFEST_FORGE%
echo ============================================
echo You can now Upload the Folder to your Hosting.
echo Make sure to have a Forge-%MCVER%-%MANIFEST_FORGE% Server installed.
echo.
Echo Press Enter to Close
pause >nul
exit /b


:finalMessage

echo.
echo ============================================
echo  [OK] Serverpack created successfully!
echo ============================================
echo Pack: %MODPACK_NAME%  MODPACK=%MODPACK%
echo Path: %SERVERPACK%
echo Forge: %MCVER%-%MANIFEST_FORGE%
echo ============================================
echo Open Serverpack and Use the Run.bat to start the Server.
echo.
Echo Press Enter to Close
pause >nul
exit /b
