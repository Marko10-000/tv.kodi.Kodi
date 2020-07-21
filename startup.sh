#! /usr/bin/env bash

# Config
CONFIG_KODI_ADDONS_SHARE='/tmp/flatpak-kodi/addons-share'
CONFIG_KODI_ADDONS_LIB='/tmp/flatpak-kodi/addons-lib'
CONFIG_KODI_BASE_SHARES='/app/share/kodi/addons_kodi'
CONFIG_KODI_EXTENSIONS='/app/extensions'
CONFIG_KODI_EXTENSIONS_ADDON_SHARE='addons-share'
CONFIG_KODI_EXTENSIONS_ADDON_LIB='addons-lib'
CONFIG_KODI_EXTENSIONS_BIN='bin'
CONFIG_KODI_EXTENSIONS_LIB='lib'

# Helper functions
import_shares() {
    # Args: <SOURCE-DIR>
    ls "$1" | while read i
    do
        ln -s "$1/$i" "$CONFIG_KODI_ADDONS_SHARE/" || exit 1
    done
}

import_libs() {
    # Args: <SOURCE-DIR>
    ls "$1" | while read i
    do
        ln -s "$1/$i" "$CONFIG_KODI_ADDONS_LIB/" || exit 1
    done
}

# Init dirs
mkdir -p "$CONFIG_KODI_ADDONS_LIB" &&
mkdir -p "$CONFIG_KODI_ADDONS_SHARE" &&
import_shares "$CONFIG_KODI_BASE_SHARES" &&

# Load extensions
ls "$CONFIG_KODI_EXTENSIONS" | while read i
do
    (
        if [ -d "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_BIN" ]
        then
            export "PATH=$PATH:$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_BIN"
        fi &&
        if [ -d "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_LIB" ]
        then
            export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_LIB"
        fi &&
        if [ -d "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_ADDON_LIB" ]
        then
            import_libs "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_ADDON_LIB"
        fi &&
        if [ -d "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_ADDON_SHARE" ]
        then
            import_shares "$CONFIG_KODI_EXTENSIONS/$i/$CONFIG_KODI_EXTENSIONS_ADDON_SHARE"
        fi
    ) || exit 1
done

# Start kodi
exec "$(dirname "$0")/kodi-start" "$@"