#!/bin/bash

# Script für ICON Download


if [ "$Modpack" = "1" ]; then
    ICON_URL="https://media.forgecdn.net/avatars/thumbnails/1311/957/64/64/638853138308838053_animated.gif"

elif [ "$Modpack" = "2" ]; then
    ICON_URL="https://media.forgecdn.net/avatars/thumbnails/1319/80/64/64/638857668194537957_animated.gif"

elif [ "$Modpack" = "3" ]; then
    ICON_URL="https://media.forgecdn.net/avatars/thumbnails/1311/962/64/64/638853142230249135_animated.gif"

elif [ "$Modpack" = "4" ]; then
    ICON_URL="https://media.forgecdn.net/avatars/thumbnails/1302/847/64/64/638846973151715653.png"

fi



Server_ICON=$Base_Serverpack_Folder/server-icon.png
wget -O "$SERVER_ICON" "$ICON_URL"


return