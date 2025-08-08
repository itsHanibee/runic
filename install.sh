#!/bin/bash
set -e

LAYOUT_NAME="runic"
SYMBOLS_FILE="$LAYOUT_NAME"
SYMBOLS_PATH="/usr/share/X11/xkb/symbols/$LAYOUT_NAME"
DESCRIPTION="Runic Keyboard Layout"
EVDEV_XML="/etc/xkb/rules/evdev.xml"
REMOTE_URL="https://raw.githubusercontent.com/itsHanibee/runic/refs/heads/main/runic"

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Ensure symbols file is available
if [[ -f "./$SYMBOLS_FILE" ]]; then
    echo "Using local $SYMBOLS_FILE file."
else
    echo "Local $SYMBOLS_FILE file not found. Downloading from $REMOTE_URL..."
    curl -fsSL "$REMOTE_URL" -o "$SYMBOLS_FILE" || {
        echo "Failed to download layout file."
        exit 1
    }
fi

# Install the layout file
echo "Installing keyboard layout to $SYMBOLS_PATH"
cp "$SYMBOLS_FILE" "$SYMBOLS_PATH"

# Modify or create /etc evdev.xml for desktop environment integration
if [ ! -f "$EVDEV_XML" ]; then
    echo "Creating override evdev.xml from system default..."
    cp /usr/share/X11/xkb/rules/evdev.xml "$EVDEV_XML"
fi

# Check if layout already exists
if grep -q "<name>$LAYOUT_NAME</name>" "$EVDEV_XML"; then
    echo "Layout '$LAYOUT_NAME' is already registered. Skipping evdev.xml modification."
else
    echo "Registering layout in $EVDEV_XML"

    # Insert XML block before </layoutList>
    sed -i "/<layoutList>/a \
    <layout>\n\
      <configItem>\n\
        <name>$LAYOUT_NAME</name>\n\
        <shortDescription>Runic</shortDescription>\n\
        <description>$DESCRIPTION</description>\n\
        <languageList>\n\
          <iso639Id>run</iso639Id>\n\
        </languageList>\n\
      </configItem>\n\
      <variantList/>\n\
    </layout>" "$EVDEV_XML"

    echo "Layout registered successfully."
fi

# Step 4: Finish
echo
echo "Installation complete."
echo "The '$LAYOUT_NAME' layout is now available in system keyboard settings (GNOME/KDE)."
