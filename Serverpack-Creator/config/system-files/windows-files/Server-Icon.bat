echo off >nul
REM Script to Grab Server Icon from Curseforge Page

REM Beyond Ascension
if "%MODPACK%"=="1" (
    set "ICON_URL=https://media.forgecdn.net/avatars/thumbnails/1311/957/64/64/638853138308838053_animated.gif"
)

REM Beyond Cosmo
if "%MODPACK%"=="2" (
    set "ICON_URL=https://media.forgecdn.net/avatars/thumbnails/1319/80/64/64/638857668194537957_animated.gif"
)

REM Beyond Depth
if "%MODPACK%"=="3" (
    set "ICON_URL=https://media.forgecdn.net/avatars/thumbnails/1311/962/64/64/638853142230249135_animated.gif"
)

REM Beyond Depth Insanity
if "%MODPACK%"=="4" (
    set "ICON_URL=https://media.forgecdn.net/avatars/thumbnails/1302/847/64/64/638846973151715653.png"
)


powershell -Command ^
    "Invoke-WebRequest '%ICON_URL%' -OutFile '%SERVERPACK%\server-icon.png'"


exit /b
