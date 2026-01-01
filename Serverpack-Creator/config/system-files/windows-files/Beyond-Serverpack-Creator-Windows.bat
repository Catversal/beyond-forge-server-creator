echo off >null

if exist "%CLIENT_PACK%\mods" goto :ClientPackOK
echo.
echo ====================================================
echo  Your client pack folder is empty.
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
echo - Copy ONLY the contents mods, config, kubejs, ...
echo - Do NOT copy the parent folder itself
echo.
echo Press ENTER once you have finished copying the files.
echo.
pause >nul

:ClientPackOK
