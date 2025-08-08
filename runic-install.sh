#!/bin/bash
# Runic Keyboard Layout Installer/Uninstaller
# Run with: sudo bash runic-layout.sh [install|uninstall]

set -e  # Exit on error

# --- Configuration ---
LAYOUT_NAME="runic"
LAYOUT_DESC="Custom Runic Layout (Four Layers)"
SHORT_DESC="Runic Keyboard Layout"
SYMBOLS_FILE="/usr/share/X11/xkb/symbols/$LAYOUT_NAME"
EVDEV_XML="/usr/share/X11/xkb/rules/evdev.xml"
BACKUP_DIR="/usr/share/X11/xkb/backup_runic"

# --- Installation Function ---
install() {
    echo "Starting installation..."
    mkdir -p "$BACKUP_DIR"
    echo "Backing up original files to $BACKUP_DIR"

    # Backup symbols file if exists, otherwise create marker
    if [ -f "$SYMBOLS_FILE" ]; then
        cp "$SYMBOLS_FILE" "$BACKUP_DIR/symbols.bak"
    else
        touch "$BACKUP_DIR/symbols.didnotexist"
    fi

    # Backup evdev.xml
    cp "$EVDEV_XML" "$BACKUP_DIR/evdev.xml.bak"

    # Create symbols file
    echo "Creating Runic symbols file at $SYMBOLS_FILE"
    cat > "$SYMBOLS_FILE" << 'EOF'
default partial alphanumeric_keys
xkb_symbols "basic" {

    include "us(basic)"
    include "level3(ralt_switch)"

    // Layer Shifting (Taking A (AC01) as an example)
    // No Modifier = ᚨ
    // Shift + A = ᚩ
    // RAlt + A = ᚬ
    // Shift + RAlt = ᚭ

    name[Group1] = "Runic";

    key <AD01> { [ U16A6 ] }; // Q: ᚦ
    key <AD02> { [ U16B9 ] }; // W: ᚹ
    key <AD03> { [ U16D6 ] }; // E: ᛖ
    key <AD04> { [ U16B1 ] }; // R: ᚱ
    key <AD05> { // T: ᛏ/ᛐ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16CF, NoSymbol, NoSymbol, U16D0 ]
    };
    key <AD06> { [ U16C7 ] }; // Y: ᛇ
    key <AD07> { // U: ᚢ/ᚣ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16A2, U16A3, NoSymbol, NoSymbol ]
    };
    key <AD08> { [ U16C1 ] }; // I: ᛁ
    key <AD09> { [ U16DF ] }; // O: ᛟ
    key <AD10> { [ U16C8 ] }; // P: ᛈ

    key <AC01> { // A: ᚨ/ᚩ/ᚬ/ᚭ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16A8, U16A9, U16AC, U16AD ]
    };
    key <AC02> { // S: ᛊ/ᛋ/ᛌ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16CA, U16CB, NoSymbol, U16CC ]
    };
    key <AC03> { [ U16DE ] }; // D: ᛞ
    key <AC04> { [ U16A0 ] }; // F: ᚠ
    key <AC05> { [ U16B7 ] }; // G: ᚷ
    key <AC06> { // H: ᚺ/ᚻ/ᚼ/ᚽ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16BA, U16BB, U16BC, U16BD ]
    };
    key <AC07> { // J: ᛃ/ᛄ/ᛅ/ᛆ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16C3, U16C4, U16C5, U16C6 ]
    };
    key <AC08> { // K: ᚴ/ᚵ/ᚶ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16B2, U16B3, U16B4, NoSymbol ]
    };
    key <AC09> { [ U16DA ] }; // L: ᛚ

    key <AB01> { // Z: ᛉ/ᛦ/ᛧ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16C9, NoSymbol, U16E6, U16E7 ]
    };
    key <AB02> { // X: ᛜ/ᛝ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16DC, U16DD, NoSymbol, NoSymbol ]
    };
    key <AB03> { // C: ᚪ/ᚫ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16AA, U16AB, NoSymbol, NoSymbol ]
    };
    key <AB04> { // V: ᛠ/ᛡ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16E0, U16E1, NoSymbol, NoSymbol ]
    };
    key <AB05> { // B: ᛒ/ᛓ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16D2, NoSymbol, NoSymbol, U16D3 ]
    };
    key <AB06> { // N: ᚾ/ᚿ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16BE, NoSymbol, NoSymbol, U16BF ]
    };
    key <AB07> { // M: ᛘ/ᛙ/ᛚ
        type = "FOUR_LEVEL",
        symbols[Group1] = [ U16D7, NoSymbol, U16D8, U16D9 ]
    };

    // Punctuation keys with fourth-layer runes
    key <AC10> { // ;/:/᛭
        type = "FOUR_LEVEL",
        symbols[Group1] = [ semicolon, colon, U16ED, NoSymbol ]
    };
    key <AB08> { // ,/</᛫
        type = "FOUR_LEVEL",
        symbols[Group1] = [ comma, less, U16EB, NoSymbol ]
    };
    key <AB09> { // ./>/᛬
        type = "FOUR_LEVEL",
        symbols[Group1] = [ period, greater, U16EC, NoSymbol ]
    };

};
EOF

    # Update evdev.xml
    echo "Updating $EVDEV_XML..."
    cp "$EVDEV_XML" "$EVDEV_XML.bak"
    awk -v layout_name="$LAYOUT_NAME" -v short_desc="$SHORT_DESC" -v desc="$LAYOUT_DESC" '
    BEGIN { RS="\n"; ORS="\n"; found=0; }
    /<layoutList>/ {
        print;
        print "    <layout>";
        print "      <configItem>";
        print "        <name>" layout_name "</name>";
        print "        <shortDescription>" short_desc "</shortDescription>";
        print "        <description>" desc "</description>";
        print "      </configItem>";
        print "    </layout>";
        found=1;
        next;
    }
    { print; }
    ' "$EVDEV_XML.bak" > "$EVDEV_XML.new" && mv "$EVDEV_XML.new" "$EVDEV_XML"

    echo "Installation complete. Please restart your X server (or reboot) for changes to take effect."
}

# --- Uninstallation Function ---
uninstall() {
    echo "Starting uninstallation..."

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Error: Backup directory not found. Cannot uninstall."
        exit 1
    fi

    # Restore evdev.xml
    if [ -f "$BACKUP_DIR/evdev.xml.bak" ]; then
        echo "Restoring original evdev.xml..."
        cp "$BACKUP_DIR/evdev.xml.bak" "$EVDEV_XML"
    else
        echo "Warning: evdev.xml backup not found. Manual cleanup may be required."
    fi

    # Handle symbols file
    if [ -f "$BACKUP_DIR/symbols.bak" ]; then
        echo "Restoring original symbols file..."
        cp "$BACKUP_DIR/symbols.bak" "$SYMBOLS_FILE"
    elif [ -f "$BACKUP_DIR/symbols.didnotexist" ]; then
        echo "Removing Runic symbols file..."
        rm -f "$SYMBOLS_FILE"
    else
        echo "Warning: Symbols backup not found. Manual cleanup may be required."
    fi

    echo "Uninstallation complete. Please restart your X server (or reboot) for changes to take effect."
}

# --- Main Script Logic ---
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0 $1"
    exit 1
fi

case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Usage: $0 [install|uninstall]"
        exit 1
        ;;
esac
