#!/bin/sh

# IMPORTANT:
# This script can't position icons correctly
# if the Finder is showing hidden files.

TMP_PACKAGE_DIR="src"

function printHelp
{
  echo
  echo $1
  echo "Correct usage: acshell.sh [DMG-NAME] [PRODUCT-PATH]"
  echo "Example: acshell.sh ACShell-1.7.1 ~/Desktop/build/ACShell.app"
  echo
}

if [ -z "$1" ]; then
  printHelp "Missing name for DMG"
  exit 1
fi

if [ -z "$2" ]; then
  printHelp "Missing product path"
  exit 1
fi

# Remove old TMP_PACKAGE_DIR, leave out 'f' to be safe
rm -Rf $TMP_PACKAGE_DIR

# Copy product to temp package destination
ditto $2 $TMP_PACKAGE_DIR/ACShell.app

# Create DMG
./dmg_utils/create-dmg --window-size 550 350 --background installer_background.png --icon-size 96 --volname $1 --app-drop-link 430 168 --icon "ACShell" 130 168 $1.dmg $TMP_PACKAGE_DIR/

echo "Cleaning up"
rm -Rf $TMP_PACKAGE_DIR