#!/bin/bash

# Script für Remove der Mods

REMOVE_LIST=""

if [ "$Modpack" = "1" ]; then
        REMOVE_LIST="$Lists/beyond_ascension_remove.txt"

elif [ "$Modpack" = "2" ]; then
        REMOVE_LIST="$Lists/beyond_cosmos_remove.txt"

elif [ "$Modpack" = "3" ]; then
  REMOVE_LIST="$Lists/beyond_depth_remove.txt"

elif [ "$Modpack" = "4" ]; then
  REMOVE_LIST="$Lists/beyond_depth_insanity_remove.txt"

elif [ "$Modpack" = "5" ]; then
  REMOVE_LIST="$Lists/beyond_ocean_remove.txt"

elif [ "$Modpack" = "6" ]; then
  REMOVE_LIST="$Lists/beyond_zombie_remove.txt"

elif [ "$Modpack" = "7" ]; then
  REMOVE_LIST="$Lists/beyond_shenanigans_remove.txt"
  
fi

export REMOVE_LIST
return
