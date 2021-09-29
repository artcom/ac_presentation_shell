#!/bin/bash

BUILD_NUMBER=$1
VERSION_STRING=$2

rm -rf DerivedData
xcodebuild clean build -project ACShell.xcodeproj -scheme ACShell -configuration release -derivedDataPath ./DerivedData APPLICATION_BUILD_NUMBER=$BUILD_NUMBER
cd package_dmg && ./package.sh "ACShell-Release-$VERSION_STRING" "../DerivedData/Build/Products/Release/ACShell.app"
