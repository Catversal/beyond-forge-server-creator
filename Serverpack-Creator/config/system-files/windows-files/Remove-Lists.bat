echo off >nul
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
REM List to Set Removal list based on Modpack


set "REMOVE_LIST="

Rem Beyond Asension
if "%MODPACK%"=="1" set "REMOVE_LIST=%LISTS%\beyond_ascension_remove.txt"

REM Beyond Cosmo
if "%MODPACK%"=="2" set "REMOVE_LIST=%LISTS%\beyond_cosmos_remove.txt"

REM Beyond Depth
if "%MODPACK%"=="3" set "REMOVE_LIST=%LISTS%\beyond_depth_remove.txt"

REM Beyond Depth
if "%MODPACK%"=="4" set "REMOVE_LIST=%LISTS%\beyond_depth_insanity_remove.txt"


exit /b

