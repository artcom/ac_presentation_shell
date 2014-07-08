# How to create DMG

1. In XCode, build a product using `Archive`.
2. In the Organizer, select the built Archive and `Save Built Products` anywhere you like.
3. Using the Terminal, go to `package_dmg`
4. Use shell script `package [DMG-NAME] [PRODUCT-PATH]`, e.g. `./package ACShell-1.7.1 ~/Desktop/LatestBuild/ACShell.app`
5. The script should now create a DMG in the folder package_dmg. It also using AppleScript to do so which might take some time. Make sure to not interfere as long as the script is still running.

# Notes


- Creating the DMG is based on this: <https://github.com/andreyvit/yoursway-create-dmg>