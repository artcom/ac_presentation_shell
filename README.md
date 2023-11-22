# ART+COM Presentation Shell

The ART+COM presentation shell is a frontend to manage, organize and launch a pool of Apple Keynote presentations. The presentation library is synchronized with MS Sharepoint using OneDrive. Presentations are grouped in collections, similar to playlists in iTunes. In presentation mode a slick menu screen is used to navigate and launch presentations.

## Development

To run tests:

    xcodebuild clean test -project ACShell.xcodeproj -scheme ACShell

To build the application:

    xcodebuild clean build -project ACShell.xcodeproj -scheme ACShell -configuration release -derivedDataPath ./DerivedData

Envirpnment variables:

| Variable                     | Description                                                       |
| :--------------------------- | :---------------------------------------------------------------- |
| `APPLICATION_VERSION_NUMBER` | Sets `MARKETING_VERSION` and version in `CURRENT_PROJECT_VERSION` |
| `APPLICATION_BUILD_NUMBER`   | Sets build number part in `CURRENT_PROJECT_VERSION`               |

## How to create a DMG

    cd package_dmg
    ./package.sh ACShell-Release-<version-string>.<build number> ../DerivedData/Build/Products/Release/ACShell.app

The script will now create a DMG in `./package_dmg`

(DMG scripts based on this: <https://github.com/andreyvit/yoursway-create-dmg>)

## License (MIT)

see [MIT Licence](./LICENSE)
