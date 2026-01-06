#!/bin/bash

# Script to Update the Script installer

echo "Creating Client Pack Directory..."

sleep 2.

mkdir -p "$Main_Path/client_pack"

# Check CLient Pack Directory

while true; do

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ====================================================
echo  Checking Client Pack Folder...
echo ====================================================
echo
sleep 2

if [ -f "$Client_Pack/config" ]; then
    if [ -f "$Client_Pack/mods" ]; then
        if [ -f "$Client_Pack/manifest.json" ]; then

            echo "Client Pack Found! Complete Continuing..."
            sleep 2
            break
        fi
    fi
fi
    echo ============================================
    echo
    echo     Serverpack Builder - Beyond Packs
    echo ============================================
    echo by Catversal
    echo
    echo
    echo ====================================================
    echo  Your client pack folder isnt complete.
    echo ====================================================
    echo
    echo Please copy the CONTENT of the Beyond modpack into this folder:
    echo
    echo   $Client_Pack
    echo
    echo Instructions:
    echo
    echo 1. Open CurseForge
    echo 2. Select the downloaded modpack
    echo 3. Click the three dots next to the Play button
    echo 4. Click "Open Folder"
    echo 5. Copy the CONTENT of this folder into the client_pack directory
    echo
    echo IMPORTANT:
    echo - Copy ONLY the contents all files and folders INSIDE the modpack folder...
    echo - Do NOT copy the parent folder itself
    echo
    read -p "Press ENTER once you have finished copying the files."

done

echo debug test
