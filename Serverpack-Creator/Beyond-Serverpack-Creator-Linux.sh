#!/bin/bash

# Script to Update the Script installer

Main_Path="$(cd "$(dirname "$0")" && pwd)"
Client_Pack="$Main_Path/client_pack"
Map_File="$Main_Path/config/modpack_map.txt"
Lists="$Main_Path/config/remove_list"
Linux_Script="$Main_Path/config/system-files/linux-files/Linux-Script.sh"

# Git Path
GIT_PATH="https://github.com/Catversal/beyond-forge-server-creator/archive/refs/heads/main.zip"


# Startup Screen / Text

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal 
echo
echo This script will auto Update now the config files to start.
echo Make sure you have an active Internet connection.
echo
read -p "Press Enter to start..."
echo
echo Downloading Newest Config ...
echo

mkdir -p "$Main_Path/temp-download"
wget -O "$Main_Path/temp-download/config_update.zip" "$GIT_PATH"

# Extract Downloaded Zip
unzip -o "$Main_Path/temp-download/config_update.zip" -d "$Main_Path/temp-download"

if [ -d "$Main_Path/config" ]; then
    # Old Config Delete
    echo "Deleting Old Config ..."
    rm -rf "$Main_Path/config"
fi
# Move New Config
echo Moving New Config ...
mv "$Main_Path/temp-download/beyond-forge-server-creator-main/Serverpack-Creator/config" "$Main_Path"
echo
# Cleanup  
echo Cleaning Teamp Files ...
rm -rf "$Main_Path/temp-download"
echo
sleep 3s


# Info Startup Text

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal 
echo
echo Config Updated Successfully!
echo
echo -------------------------------------------
echo  Info
echo -------------------------------------------
echo
echo This Serverpack Creator Script will help you with the
echo creation of a Serverpack for the Beyond Packs.
echo
echo It Supports the Following Packs:
echo
while IFS='|' read -r A B C D E || [ -n "$A" ]; do
  # A=ID, B=Name, C=DisplayName, D=MC, E=Flag
  echo "$B"
done < "$Map_File"
echo
read -p "Press Enter to continue..."


# HostingTypeSelection
while true; do
clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ================================
echo   Hosting-Typ selection
echo ================================
echo
echo  1 - Dedicated Server / Hosting 
echo  "2 - Local Hosting on Your (PC) [Default]"
echo
    hostingtype=""
    read -p "Selection (1 or 2): " hostingtype
    
    # Default to 2 if empty
    if [ -z "$hostingtype" ]; then
        hostingtype="2"
    fi
    
    if [ "$hostingtype" = "1" ]; then
        echo
        echo "Selected: Dedicated Server / Hosting"
        break
    elif [ "$hostingtype" = "2" ]; then
        echo
        echo "Selected: Local Hosting on Your [PC]"
        break
    else
        echo
        echo "Invalid Entry, please select 1 or 2!"
        sleep 3
    fi
done

sleep 2

export Main_Path Client_Pack Map_File Lists Linux_Script hostingtype
source "$Linux_Script"

exit 0

