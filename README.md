# sourceModBuilder
A build system for source mods,  that compiles the engine, installs your mod, and much more!<br>
the main build system script is in buildsys/buildsys_init.sh
# Getting started
## do the following
- install msys64, you probally dont want to add it to path, as it may screw your current python install over.
- get vs2022 with the c++ desktop workload.
- get Source Sdk Base 2013 Singleplayer (upcoming) from steam
- clone this repo, and copy build.bat and buildsys the folder that your mod will be in (dont put it in sourcemods, do something like desktop, you know what i mean.
- open up the folder with the build system, and edit buildsys/config.sh to your settings (REQUIRED, THIS HAS IMPORTANT STUFF).
- then:<br>
```
     run: build.bat
     if your using powershell: .\build.bat
```
- let it take its time (the engine compiles in a little under a minute for a 16 core cpu and 32 gbs of ram (i snagged one from a buisness for $250))<br>
NOTE: if you dont have the engine in the configured directory, it will download it for you.<br>
- Run the script again, and it should not yap at you about gameinfo.txt, just edit the one in gameroot.
- restart steam, and you should see your mod there
# wtf are these directories?
## to make it easier, you can crate a maps, scripts, and game config folder in the root of your project.
## game config files is copied to the root of the sourcemod
## map files is copied to the map folder of the source mod.
## script files are copied to the scripts folder of the source mod.
# JUST USE THE FOLDER IN GAMEROOT, ITS LIKE A SOURCEMOD DIRECTORY, GAMEROOT/* IS COPIED TO THE ROOT OF THE SOURCEMOD!
# GAMEROOT WILL NOT HAVE BINAIRES, DO NOT TRY TO RUN IT THERE.
# in bin/(ur game)testing/ there will be a full folder containg the output, you will need to use the -game param with the created exec tho.
