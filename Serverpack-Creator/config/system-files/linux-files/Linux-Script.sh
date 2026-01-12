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

  if [ -d "$Client_Pack/config" ] \
     && [ -d "$Client_Pack/mods" ] \
     && [ -f "$Client_Pack/manifest.json" ]; then

      echo "Client Pack Found! Complete Continuing..."
      sleep 2
      break

  else

      echo ============================================
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
      echo ====================================================
      echo Info:
      echo ====================================================
      echo

      # 
      # if [ -d "$Client_Pack/config" ] then
      #     sleep 1 
      # else
      #     echo "- The 'config' folder is missing"
      # fi
      # if [ -d "$Client_Pack/mods" ] then
      #   sleep 1
      # else
      #     echo "- The 'mods' folder is missing"
      # fi
      # 
      # if [ -f "$Client_Pack/manifest.json" ]  then
      #    sleep 1
      # else
      #     echo "- The 'manifest.json' file is missing"
      # fi
      # */
      echo
      read -p "Press ENTER once you have finished copying the files."
  fi
done
# Manifest.json lesen

#!/bin/bash


MANIFEST="$Client_Pack/manifest.json"

if [[ ! -f "$MANIFEST" ]]; then
  echo "[ERROR] manifest.json nicht gefunden:"
  echo "  $MANIFEST"
  exit 1
fi

# --- JSON parse (distro-agnostisch): prefer python3, then python, then shell fallback ---
_parse_manifest_with_python() {
  "$1" - "$MANIFEST" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

name = data.get("name","")
version = data.get("version","")

mc = ""
minecraft = data.get("minecraft") or {}
mc = minecraft.get("version","")

forge = ""
for ml in (minecraft.get("modLoaders") or []):
    _id = (ml or {}).get("id","")
    if isinstance(_id, str) and _id.startswith("forge-"):
        forge = _id.split("forge-",1)[1]
        break

# print 4 lines (safe for bash read)
print(name)
print(version)
print(mc)
print(forge)
PY
}

if command -v python3 >/dev/null 2>&1; then
  mapfile -t _m < <(_parse_manifest_with_python python3)
elif command -v python >/dev/null 2>&1; then
  mapfile -t _m < <(_parse_manifest_with_python python)
else
  # --- Shell fallback (best-effort, works for typical CurseForge manifest formatting) ---
  # NOTE: This is less reliable than python, but avoids hard dependencies.
  MANIFEST_NAME=$(sed -nE 's/^[[:space:]]*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$MANIFEST" | head -n1)
  MANIFEST_VERSION=$(sed -nE 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$MANIFEST" | head -n1)

  # Try to find minecraft.version in vicinity of "minecraft" block (heuristic)
  MANIFEST_MC_VERSION=$(
    awk '
      /"minecraft"[[:space:]]*:/ {inmc=1}
      inmc && /"version"[[:space:]]*:/ {
        if (match($0, /"version"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
          v=substr($0, RSTART, RLENGTH)
          sub(/.*"version"[[:space:]]*:[[:space:]]*"/,"",v)
          sub(/".*/,"",v)
          print v
          exit
        }
      }
      inmc && /\}/ { } # keep scanning until found
    ' "$MANIFEST"
  )

  # Forge loader id (heuristic: first "forge-...")
  MANIFEST_FORGE=$(
    grep -oE '"id"[[:space:]]*:[[:space:]]*"forge-[^"]+"' "$MANIFEST" \
      | head -n1 \
      | sed -E 's/.*"forge-([^"]+)".*/\1/'
  )
fi

# If python path was used, assign values
if [[ -n "${_m[0]:-}" ]]; then
  MANIFEST_NAME="${_m[0]}"
  MANIFEST_VERSION="${_m[1]}"
  MANIFEST_MC_VERSION="${_m[2]}"
  MANIFEST_FORGE="${_m[3]}"
fi

# Basic validation
if [[ -z "$MANIFEST_NAME" || -z "$MANIFEST_VERSION" || -z "$MANIFEST_MC_VERSION" || -z "$MANIFEST_FORGE" ]]; then
  echo "[ERROR] Konnte manifest.json nicht vollständig auslesen."
  echo "Name='$MANIFEST_NAME' Version='$MANIFEST_VERSION' MC='$MANIFEST_MC_VERSION' Forge='$MANIFEST_FORGE'"
  echo "Installiere python3 für 100% zuverlässiges Parsing."
  exit 1
fi

# For later parts of the script
MC_Version="$MANIFEST_MC_VERSION"



#MANIFEST="$Client_Pack/manifest.json"

#MANIFEST_NAME=$(grep -oP '^\s*"name"\s*:\s*"\K[^"]+' "$MANIFEST")
#MANIFEST_VERSION=$(grep -oP '^\s*"version"\s*:\s*"\K[^"]+' "$MANIFEST")

#MANIFEST_MC_VERSION=$(grep -oP '"minecraft"\s*:\s*\{[\s\S]*?"version"\s*:\s*"\K[^"]+' "$MANIFEST")

#MANIFEST_FORGE=$(grep -oP '"id"\s*:\s*"\Kforge-[^"]+' "$MANIFEST" | head -n1 | sed 's/^forge-//')

echo "Name: $MANIFEST_NAME"
echo "Pack-Version: $MANIFEST_VERSION"
echo "Minecraft-Version: $MANIFEST_MC_VERSION"
echo "Forge-Version: $MANIFEST_FORGE"


clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ====================================================
echo [INFO] Modpack name from manifest.json:
echo ====================================================
echo
echo   $MANIFEST_NAME
echo
sleep 2

Map_File="$Main_Path/config/modpack_map.txt"

FOUND=0

while IFS='|' read -r A B C D E || [ -n "$A" ]; do
  # A=ID, B=Name, C=DisplayName, D=MC, E=Flag

  # Windows-Zeilenenden entfernen
  A="${A%%$'\r'}"
  B="${B%%$'\r'}"
  C="${C%%$'\r'}"
  D="${D%%$'\r'}"
  E="${E%%$'\r'}"

  # Leere Zeilen oder Kommentare überspringen
  [[ -z "$A" ]] && continue
  [[ "$A" =~ ^# ]] && continue

  # === HIER ist der entscheidende Fix ===
  if [[ "$B" == "$MANIFEST_NAME" ]]; then
    Modpack="$A"
    Name="$B"
    DisplayName="$C"
    MC_Version="$MANIFEST_MC_VERSION"
    Flag="$E"
    FOUND=1
    break
  fi
done < "$Map_File"

if [[ $FOUND -ne 1 ]]; then
  echo "[ERROR] Modpack '$MANIFEST_NAME' nicht in modpack_map.txt gefunden!"
  exit 1
fi


clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ====================================================
echo [INFO] Detected Modpack:
echo ====================================================
echo
echo   $DisplayName "("$Modpack")"
echo   MC Version: "$MC_Version" "|" Forge Version: "$MANIFEST_FORGE" Copy_Tacz= "$Flag"
echo
sleep 2

# Zielordner anlegen
Count=1

Base_Serverpack_Folder="$Main_Path/${DisplayName}_${MANIFEST_VERSION}_${Count}"

while [ -d "$Base_Serverpack_Folder" ]; do
  Count=$((Count + 1))
  Base_Serverpack_Folder="$Main_Path/${DisplayName}_${MANIFEST_VERSION}_${Count}"
done

mkdir -p "$Base_Serverpack_Folder"


clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo [INFO] Serverpack folder Created:
echo $Base_Serverpack_Folder
echo
sleep 2

# Copy Files

echo Copying Server Files ...
cp -r "$Client_Pack/config" "$Base_Serverpack_Folder/"
cp -r "$Client_Pack/mods" "$Base_Serverpack_Folder/"
cp -r "$Client_Pack/defaultconfigs" "$Base_Serverpack_Folder/"
cp -r "$Client_Pack/kubejs" "$Base_Serverpack_Folder/"

if $Flag==1; then
  echo Copying Tacz Files ...
  cp -r "$Client_Pack/tacz_backup" "$Base_Serverpack_Folder/"
fi
echo

clear
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ====================================================
echo [INFO] Serverpack Copy Complete!
echo ====================================================
echo
sleep 2


remove_list_scirpt="$Main_Path/config/system-files/linux-files/Remove-Lists.sh"
export Main_Path Lists Modpack Base_Serverpack_Folder 
source "$remove_list_scirpt"

# Zu ergänzen Remove List nicht exestent

clear
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo 
echo [Info] Removing client-only mods using list:
echo "$REMOVE_LIST"
echo
sleep 2

# expandiert Globs zu nichts, wenn keine Treffer
shopt -s nullglob

# Zeile für Zeile verarbeiten (auch letzte Zeile ohne NL)
while IFS= read -r PREFIX || [ -n "$PREFIX" ]; do
  # Windows CR entfernen
  PREFIX="${PREFIX%%$'\r'}"
  [ -z "$PREFIX" ] && continue

  for jar in "$Base_Serverpack_Folder/mods/${PREFIX}"*.jar; do
    if [ -f "$jar" ]; then
      echo "[DEL] $(basename "$jar")"
      rm -f -- "$jar"
    fi
  done
done < "$REMOVE_LIST"

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo [OK] Mod removal step finished.
echo
echo ==================================================
echo  [INFO] Java is required to run this server
echo --------------------------------------------------
echo  "Please make sure you have Java 17, 18 or 21 installed. (not higher versions)"
echo
echo  Recommended for this server: Java 21 
echo
echo  "You can download Java (Eclipse Temurin) here:"
echo  "https://adoptium.net/de/temurin/releases"
echo ==================================================
echo
echo Press ENTER to continue
echo
read -r




if [ "$hostingtype" = "2" ]; then

  # == Forge Server installieren ==

    Forge_Installer="$Base_Serverpack_Folder/forge-$MC_Version-$MANIFEST_FORGE-installer.jar"
    Forge_Url="https://maven.minecraftforge.net/net/minecraftforge/forge/$MC_Version-$MANIFEST_FORGE/forge-$MC_Version-$MANIFEST_FORGE-installer.jar"

    echo Downloading Forge Installer ...
    wget -O "$Forge_Installer" "$Forge_Url"
    echo



    clear
    echo
    echo ============================================
    echo     Serverpack Builder - Beyond Packs
    echo ============================================
    echo by Catversal
    echo
    echo [INFO] Running Forge installer --installServer...
    echo
    sleep 2
    # --- Run installer in target directory ---
    

    cd "$Base_Serverpack_Folder"
    java -jar "$Forge_Installer" --installServer
    cd "$Main_Path"


fi

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo [INFO] Writing server.properties...
echo
sleep 2

cat > "$Base_Serverpack_Folder/server.properties" <<EOF
#Minecraft server properties
#Generated by setup script
allow-flight=true
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
difficulty=normal
enable-command-block=true
enable-jmx-monitoring=false
enable-query=false
enable-rcon=false
enable-status=true
enforce-secure-profile=true
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=world
level-seed=
level-type=minecraft\:normal
max-chained-neighbor-updates=1000000
max-players=200
max-tick-time=-1
max-world-size=29999984
motd=\u00A74\u00A7lBeyond Modpack \u00A76 | \u00A71 $DisplayName\u00A7r\n\u00A74by Blueversal  \u00A76      |\u00A71 $MANIFEST_VERSION
network-compression-threshold=1024
online-mode=true
op-permission-level=4
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=25565
rate-limit=0
rcon.password=
rcon.port=25575
require-resource-pack=false
resource-pack=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=25565
simulation-distance=
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=0
sync-chunk-writes=true
text-filtering-config=
use-native-transport=true
view-distance=20
white-list=false
EOF

# Ram Allocation

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ============================================
echo   Dedicated server RAM Allocation
echo   Recomanded Ram for Pack
echo --------------------------------------------
if [ "$Modpack" = "1" ]; then
    echo " Beyond Ascension:  8GB Base + 1 GB per Player"
elif [ "$Modpack" = "2" ]; then
    echo " Beyond Cosmos: 8 GB + 1 GB per Player"
elif [ "$Modpack" = "3" ]; then
    echo " Beyond Depths: 6 GB + 1 GB per Player"
elif [ "$Modpack" = "4" ]; then
    echo " Beyond Depths Insanity: 8 GB + 1 GB per Player"
fi
echo ============================================
echo
sleep 5
if [ "$hostingtype" = "2" ]; then
    TOTAL_RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
    TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

    echo [Info] Detected System RAM: $TOTAL_RAM_GB GB

    # --- Ask for RAM input ---
    read -p "How many GB of RAM should be allocated to the server? [default 6]: " RAM_GB

    # --- Default if empty ---
    if [[ -z "$RAM_GB" ]]; then
      RAM_GB=6
    fi

    # --- Validate numeric input ---
    if ! [[ "$RAM_GB" =~ ^[0-9]+$ ]]; then
      echo
      echo "[WARN] Invalid RAM input detected. Using default: 6 GB."
      RAM_GB=6
    fi

    echo "[INFO] Changing Xms ..."
    
    # --- Xms policy: Xms = half of Xmx (minimum 2G) ---
    XMS_GB=$((RAM_GB / 2))
    if (( XMS_GB < 2 )); then
      XMS_GB=2
    fi

    echo "[INFO] Xmx = ${RAM_GB}G"
    echo "[INFO] Xms = ${XMS_GB}G"
    sleep 3
fi

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal  
echo
# --- Ask for JVM args ---
read -p "Add recommended JVM arguments? (Y/N) [default Y]: " ADD_JVM_ARGS

# --- Default if empty ---
if [[ -z "$ADD_JVM_ARGS" ]]; then
  ADD_JVM_ARGS="Y"
fi

# --- Normalize input (y/n → Y/N) ---
ADD_JVM_ARGS=$(echo "$ADD_JVM_ARGS" | tr '[:lower:]' '[:upper:]')

# --- JVM args file path ---
JVM_ARGS_FILE="$Base_Serverpack_Folder/user_jvm_args.txt"


if [[ "$ADD_JVM_ARGS" == "Y" ]]; then
    cat > "$JVM_ARGS_FILE" << EOF
    # Xmx and Xms set the maximum and minimum RAM usage, respectively.
    # They can take any number, followed by an M or a G.
    # M means Megabyte, G means Gigabyte.
    # For example, to set the maximum to 3GB: -Xmx3G
    # To set the minimum to 2.5GB: -Xms2500M
    
    # A good default for a modded server is 4GB.
    # Uncomment the next line to set it.
    # -Xmx4G
    
    -Xmx"$RAM_GB"G
    -Xms2"$XMS_GB"G
    -Dterminal.jline=false
    -Dterminal.ansi=true
    -XX:+UseG1GC
    -XX:+DisableExplicitGC
    -XX:+AlwaysPreTouch
    -XX:MaxGCPauseMillis=100
    -XX:InitiatingHeapOccupancyPercent=25
    -XX:G1ReservePercent=20
    -XX:+PerfDisableSharedMem
EOF

else
    cat > "$JVM_ARGS_FILE" << EOF
    # Xmx and Xms set the maximum and minimum RAM usage, respectively.
    # They can take any number, followed by an M or a G.
    # M means Megabyte, G means Gigabyte.
    # For example, to set the maximum to 3GB: -Xmx3G
    # To set the minimum to 2.5GB: -Xms2500M
    
    # A good default for a modded server is 4GB.
    # Uncomment the next line to set it.
    # -Xmx4G
    
    -Xmx"$RAM_GB"G
    -Xms2"$XMS_GB"G
EOF


fi

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo ==================================================
echo  Minecraft EULA
echo --------------------------------------------------
echo  By running a Minecraft server you must accept
echo  the Minecraft End User License Agreement.
echo
echo  https://aka.ms/MinecraftEULA
echo ==================================================
echo

read -p "Do you accept the Minecraft Eula? (Y/N): " EULA

if [[ -z "$EULA" ]]; then
  EULA="N"
fi

EULA_FILE="$Base_Serverpack_Folder/eula.txt"
if [[ "$EULA" == "Y" ]]; then
    cat > "$EULA_FILE" << EOF
    eula=true
EOF
fi

if [[ "$EULA" == "N" ]] then

    clear 
    echo ============================================
    echo     Serverpack Builder - Beyond Packs
    echo ============================================
    echo by Catversal
    echo
    echo "[WARN] You did not accept the Minecraft EULA."
    echo the Server will NOT start until you accept the EULA.
    echo 
    echo you can accept it later by editing:
    echo $Base_Serverpack_Folder/eula.txt
    sleep 5
fi

clear
echo
echo ============================================
echo     Serverpack Builder - Beyond Packs
echo ============================================
echo by Catversal
echo
echo "[INFO] Grabbing Server Icon..."
sleep 2
Server-Icon_Script="$Main_Path/config/system-files/linux-files/Server-Icon.sh"

export Base_Serverpack_Folder
source "$Server-Icon_Script"


if [ "$hostingtype" = "2" ]; then

    clear
    echo
    echo ============================================
    echo  [OK] Serverpack created successfully!
    echo ============================================
    echo Pack: "$MODPACK_NAME"  MODPACK="$MODPACK"
    echo Path: "$Base_Serverpack_Folder"
    echo Forge: "$MC_Version-$MANIFEST_FORGE"
    echo ============================================
    echo Open Serverpack and Use the Run.sh to start the Server.
    echo
    read -p "Press Enter to Close"







else 

    clear
    echo
    echo ============================================
    echo     Serverpack Builder - Beyond Packs
    echo ============================================
    echo
    echo ============================================
    echo  [OK] Serverpack created successfully!
    echo ============================================
    echo Pack: "$MODPACK_NAME"  MODPACK="$MODPACK"
    echo Path: "$Main_Path"
    echo Forge: "$MC_Version"-"$MANIFEST_FORGE"
    echo ============================================
    echo You can now Upload the Folder to your Hosting.
    echo Make sure to have a Forge-"$MC_Version-$MANIFEST_FORGE" Server installed.
    echo
    read -p "Press Enter to Close"

fi

return
