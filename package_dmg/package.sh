#!/bin/sh

# IMPORTANT:
# This script can't position icons correctly
# if the Finder is showing hidden files.

TMP_PACKAGE_DIR="./tmp_package_dir"

function printHelp
{
  echo
  echo $1
  echo "Correct usage: acshell.sh [DMG-NAME] [PRODUCT-PATH]"
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

if [ -z "$3" ]; then
  printHelp "Missing changelog path"
  exit 1
fi

# Remove old TMP_PACKAGE_DIR, leave out 'f' to be safe
rm -Rf $TMP_PACKAGE_DIR
mkdir $TMP_PACKAGE_DIR

# Copy product to temp package destination
ditto "$2" $TMP_PACKAGE_DIR/ACShell.app
ditto "$3" $TMP_PACKAGE_DIR/whatsnew.txt

# Create DMG
./dmg_utils/create-dmg --window-size 550 550 --background installer_background.png --icon-size 96 --volname $1 --app-drop-link 420 250 --icon "ACShell" 96 250 $1.dmg $TMP_PACKAGE_DIR/

echo "Cleaning up"
rm -Rf $TMP_PACKAGE_DIR