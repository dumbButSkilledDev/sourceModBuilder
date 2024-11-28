#!/bin/bash

source buildsys/config.sh
source buildsys/logfuncs.sh
source buildsys/msbuildvars.sh
source buildsys/buildengine.sh

rm -rf bin/structure/*
rm -rf bin/$GAME_SHORTNAME/testing/*
rm -rf "/c/Program Files (x86)/Steam/steamapps/sourcemods/$GAME_SHORTNAME/*"

if ! [ -x "$(command -v git)" ]; then
    pacman -Sy git
fi

# ======================== STAGE 1 ========================

# check if the file buildsys/.init dose not exist (self explanatory)
if [ ! -f buildsys/.init ]; then
    touch buildsys/.init
    echo "====> it looks like this is your first time running the build system!"
    echo "===> Let this run first so it can initalize your project."
    echo "===> if you have not edited buildsys/config.sh, press ctrl-c and edit it now."
    echo "===> waiting 5 seconds..."
    sleep 5
    clear
fi

# check if the folder source2013 exists
if [ ! -d $SOURCE_ENGINE_DIR ]; then
    echo "====> it appears the source engine directory does not exist."
    echo "====> you should extract source engine 2013 vs2022 fork's sp and mp to $SOURCE_ENGINE_DIR."
    echo "====> $SOURCE_ENGINE_DIR is the name of the configured engine directory from buildsys/config.sh."
    echo "====> Would you like to clone the source engine from github? (y/n)"
    read -r -p "====> " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        git clone "https://github.com/Source-SDK-Resources/source-sdk-vs2022"
        mv source-sdk-vs2022 $SOURCE_ENGINE_DIR
    else
        logYellow "[CHECKS] Exiting because source engine directory not found. Please extract the source engine to $SOURCE_ENGINE_DIR."
        logYellow "[CHECKS] Or run this script again."
        exit 1
    fi
else
    # check for sp/src
    if [ ! -d $SOURCE_ENGINE_DIR/sp/src ]; then
        echo "====> it appears the source engine source directory does not exist."
        echo "====> you should extract source engine 2013 vs2022 fork's sp and mp to $SOURCE_ENGINE_DIR."
        echo "====> $SOURCE_ENGINE_DIR is the name of the configured engine directory from buildsys/config.sh."
        echo "====> Would you like to clone the source engine from github? (y/n)"
        read -r -p "====> " response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
            git clone "https://github.com/Source-SDK-Resources/source-sdk-vs2022"
            rm -rf $SOURCE_ENGINE_DIR
            mv source-sdk-vs2022 $SOURCE_ENGINE_DIR
        else
            logYellow "[CHECKS] Exiting because source engine sp/src directory not found. Please extract the source engine to $SOURCE_ENGINE_DIR."
            logYellow "[CHECKS] Or run this script again."
            exit 1
        fi
    fi
fi
directoryTargets=""
hasMaps=0
hasScripts=0

logBlue "=== SOURCE MOD BUILDER ==="
logBlue "Created by: Connor Walsh (dumbButSkilledDev on github)"
logBlue "[IMPORTANT] this may not even work. this is very wip."
logBlue "[IMPORTANT] I mean, it works on my machine..."
logBlue "[TIP] gameroot is the directory you should focus on. Is has your scripts, maps, and config files."
logBlue "[TIP] You dont need to use your gameconfig, maps, or scripts directories. You can use the gameroot/(target directory) instead."
logBlue "[BUILD] PreTasks: verify engine directories..."

if [ ! -d $SOURCE_ENGINE_DIR ]; then
    logRed "[BUILD] Error: source engine directory not found!"
    exit 1
else
    logGreen "[BUILD] Source engine directory found!"
fi

if [ ! -d $SOURCE_ENGINE_DIR/sp/src ]; then
    logRed "[BUILD] Error: $SOURCE_ENGINE_DIR/sp/src directory not found!"
    exit 1
else
    logGreen "[BUILD] Source engine source directory found!"
fi

logBlue "[BUILD] PreTasks: verify game directories..."

if [ ! -d $GAME_CONFIG_DIR ]; then
    logGreen "[BUILD] game config directory not found! (best practice!)"
else
    logGreen "[BUILD] Game config directory found!"
    directoryTargets="$directoryTargets $GAME_CONFIG_DIR"
fi

if [ ! -d $GAME_MAPS_DIR ]; then
    logGreen "[BUILD] game maps directory not found! (best practice!)"
else
    logGreen "[BUILD] Game maps directory found!"
    directoryTargets="$directoryTargets $GAME_MAPS_DIR"
    hasMaps=1
fi

if [ ! -d $GAME_SCRIPTS_DIR ]; then
    logGreen "[BUILD] game scripts directory not found! (best practice!)"
else
    logGreen "[BUILD] Game scripts directory found!"
    directoryTargets="$directoryTargets $GAME_SCRIPTS_DIR"
    hasScripts=1
fi

# check if a res directory exists
if [ -d gameroot ]; then
    logGreen "[BUILD] gameroot directory found!"
    directoryTargets="$directoryTargets $GAME_CONFIG_DIR/res"
else
    mkdir -p gameroot/cfg
    mkdir -p gameroot/materials
    mkdir -p gameroot/resource
    mkdir -p gameroot/scripts
    mkdir -p gameroot/sound
    mkdir -p gameroot/maps
    mkdir -p gameroot/models
    mkdir -p gameroot/particles
    mkdir -p gameroot/shaders
    mkdir -p gameroot/sound
fi

mkdir -p bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/cfg bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/materials bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/resource bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/scripts bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/sound bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/maps bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/models bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/particles bin/structure/sourcemods/$GAME_SHORTNAME
cp -r gameroot/shaders bin/structure/sourcemods/$GAME_SHORTNAME

logBlue "[BUILD] PreTasks: creating output directories..."

mkdir -p build/engine
mkdir -p bin/structure/sourcemods/$GAME_SHORTNAME/maps
mkdir -p bin/structure/sourcemods/$GAME_SHORTNAME/scripts

logBlue "[BUILD] PreTasks: copying game directories..."

cp -r $GAME_CONFIG_DIR/* bin/structure/sourcemods/$GAME_SHORTNAME > /dev/null 2>&1

if [ $hasMaps -eq 1 ]; then
    cp -r $GAME_MAPS_DIR/* bin/structure/sourcemods/$GAME_SHORTNAME/maps > /dev/null 2>&1
fi

if [ $hasScripts -eq 1 ]; then
    cp -r $GAME_SCRIPTS_DIR/* bin/structure/sourcemods/$GAME_SHORTNAME/scripts > /dev/null 2>&1
fi

logGreen "[BUILD] PreTasks complete!"

# ======================== STAGE 2 ========================

IMP=$(pwd)

buildEngine $SOURCE_ENGINE_DIR

cd $IMP

# copy the output binaries to build/engine
cp -r $SOURCE_ENGINE_DIR/sp/game/mod_hl2/bin build/engine/

# ======================== STAGE 3 ========================
# stage 3 is making the mod actually playable by copying the binaries from steamapps/common/Source SDK Base 2013 Singleplayer/bin to bin/structure/sourcemods/$GAME_SHORTNAME/bin and copying steamapps/common/Source SDK Base 2013 Singleplayer/hl2.exe to bin/structure/sourcemods/$GAME_SHORTNAME/$GAME_SHORTNAME.exe

logBlue "[BUILD] Entering task 2: Copying binaries..."
logBlue "[BUILD] (stage 1) Copying binaries from Source SDK Base 2013 Singleplayer..."
cp -r "/c/Program Files (x86)/steam/steamapps/common/Source SDK Base 2013 Singleplayer/bin" bin/structure/sourcemods/$GAME_SHORTNAME/bin
logBlue "[BUILD] (stage 2) Copying hl2.exe from Source SDK Base 2013 Singleplayer..."
cp "/c/Program Files (x86)/steam/steamapps/common/Source SDK Base 2013 Singleplayer/hl2.exe" bin/structure/sourcemods/$GAME_SHORTNAME/$GAME_SHORTNAME.exe
logBlue "[BUILD] (stage 3) Copying the built client.dll and server.dll to bin/structure/sourcemods/$GAME_SHORTNAME/bin..."
cp build/engine/bin/client.dll bin/structure/sourcemods/$GAME_SHORTNAME/bin
cp build/engine/bin/server.dll bin/structure/sourcemods/$GAME_SHORTNAME/bin
logGreen "[BUILD] Binaries copied!"

mkdir -p bin/$GAME_SHORTNAME/testing/
cp -r bin/structure/sourcemods/* bin/$GAME_SHORTNAME/testing/

# ======================== STAGE 4 ========================
# stage 4 is copying the entire sourcemods/$GAME_SHORTNAME directory to steamapps/sourcemods

logBlue "[BUILD] Entering task 3: Installing to Steam..."
logBlue "[BUILD] (stage 1) Copying to steamapps/sourcemods..."
cp -r bin/structure/sourcemods/* "/c/Program Files (x86)/Steam/steamapps/sourcemods"
logGreen "[BUILD] Installed to Steam!"

# do a quick check to see if the gameconfig or gameroot/ has a gameinfo.txt file
if [ ! -f bin/structure/sourcemods/$GAME_SHORTNAME/gameinfo.txt ]; then
    logYellow "[IMPORTANT] Your game is built, but it wont run."
    logYellow "[IMPORTANT] You need a gameinfo.txt file in your gameconfig or gameroot directory."
    logBlue "[IMPORTANT] Copying a gameinfo.txt template to your gameroot directory... (every file in map,scripts,gameconfig is merged into eachover at some point"
    logBlue "[CONTINUE] so it dosent matter wich directory you put it.)"
    logBlue "[IMPORTANT] any other source engine directories will be in gameroot, even if thier not in the root of the project."
    logBlue "[IMPORTANT] Gameconfig,maps,scripts are only left in for pepole to get started. you can delete them if you want."
    logBlue "[IMPORTANT] For best practice, just use gameroot."
    cp buildsys/res/gameinfo.txt gameroot
fi