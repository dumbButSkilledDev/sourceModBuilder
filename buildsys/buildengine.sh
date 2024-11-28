#!/bin/bash

export PATH="$PATH:/c/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/amd64"

function buildEngine() {
    logBlue "[BUILD] Entering task 1: build source engine..."
    logBlue "[BUILD] (stage 1) Building source engine from directory $1"
    cd $1/sp/src
    logBlue "[BUILD] (stage 2) Creating games solution...."
    powershell ./creategameprojects.bat
    logBlue "[BUILD] (stage 3) Building games solution...."
    "/c/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/amd64/msbuild.exe" games.sln -p:Configuration=Debug -p:Platform=x64
    logGreen "[BUILD] Engine build complete!"
    logBlue "[BUILD] Exiting task 1: build source engine..."
}