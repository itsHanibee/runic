#!/bin/bash
set -e

LAYOUT_NAME="runic"
DESCRIPTION="Runic Keyboard Layout"
SYMBOLS_PATH="/usr/share/X11/xkb/symbols/$LAYOUT_NAME"
REMOTE_URL="https://raw.githubusercontent.com/itsHanibee/runic/refs/heads/main/runic"
EVDEV_XML="/etc/xkb/rules/evdev.xml"

TMP_SYMBOLS_FILE="/tmp/$LAYOUT_NAME"

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Use local file if available, otherwise download to /tmp
if [[ -f "./$LAYOUT_NAME" ]]; then
    echo "Using local ./$LAYOUT_NAME file."
    SOURCE_FILE="./$LAYOUT_NAME"
else
    echo "Local layout file not found. Downloading to $TMP_SYMBOLS_FILE..."
    curl -fsSL "$REMOTE_URL" -o "$TMP_SYMBOLS_FILE" || {
        echo "Failed to download layout file. Exiting."
        exit 1
    }
    SOURCE_FILE="$TMP_SYMBOLS_FILE"
fi

# Install the layout file
echo "Installing keyboard layout to $SYMBOLS_PATH"
cp "$SOURCE_FILE" "$SYMBOLS_PATH"

# Create override evdev.xml if needed
if [ ! -f "$EVDEV_XML" ]; then
    mkdir -p "$(dirname "$EVDEV_XML")"
    cp /usr/share/X11/xkb/rules/evdev.xml "$EVDEV_XML"
fi

# Add layout to XML if not already present
if grep -q "<name>$LAYOUT_NAME</name>" "$EVDEV_XML"; then
    echo "Layout '$LAYOUT_NAME' is already registered. Skipping XML modification."
else
    echo "Registering layout in $EVDEV_XML"

    tmpfile="$(mktemp)"
    awk -v layout="$LAYOUT_NAME" -v desc="$DESCRIPTION" '
        /<layoutList>/ {
            print
            print "    <layout>"
            print "      <configItem>"
            print "        <name>" layout "</name>"
            print "        <shortDescription>Runic</shortDescription>"
            print "        <description>" desc "</description>"
            print "        <languageList>"
            print "          <iso639Id>run</iso639Id>"
            print "        </languageList>"
            print "      </configItem>"
            print "      <variantList/>"
            print "    </layout>"
            next
        }
        { print }
    ' "$EVDEV_XML" > "$tmpfile" && mv "$tmpfile" "$EVDEV_XML"

    echo "Layout registered successfully."
fi

echo
echo "Installation complete."
echo "The '$LAYOUT_NAME' layout is now available in GNOME/KDE system keyboard settings."
echo
echo "Please reboot your system for all changes to take effect."

