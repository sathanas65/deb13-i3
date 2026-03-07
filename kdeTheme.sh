#!/bin/bash
set -euo pipefail

APPDIR="$HOME/.local/share/applications"
mkdir -p "$APPDIR"

# Clean out previous KDE launcher experiments
rm -f "$APPDIR"/org.kde.kdeconnect*.desktop
rm -f "$APPDIR"/systemsettings.desktop
rm -f "$APPDIR"/kdesystemsettings.desktop
rm -f "$APPDIR"/kcm_kdeconnect.desktop
rm -f "$APPDIR"/org.kde.plasma.settings.open.desktop
rm -f "$APPDIR"/*dark*.desktop
rm -f "$APPDIR"/hide-kde-*.desktop

# KDE Connect
cat > "$APPDIR/org.kde.kdeconnect.app.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=KDE Connect
GenericName=Device Synchronization
Comment=Connect and sync your devices
Exec=env QT_QUICK_CONTROLS_STYLE=Material QT_QUICK_CONTROLS_MATERIAL_THEME=Dark /usr/bin/kdeconnect-app
Icon=kdeconnect
Terminal=false
Categories=Network;Qt;KDE;
StartupNotify=true
NoDisplay=false
EOF

# KDE Connect SMS
cat > "$APPDIR/org.kde.kdeconnect.sms.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=KDE Connect SMS
GenericName=Text Messaging
Comment=Send and receive SMS messages
Exec=env QT_QUICK_CONTROLS_STYLE=Material QT_QUICK_CONTROLS_MATERIAL_THEME=Dark /usr/bin/kdeconnect-sms
Icon=kdeconnect
Terminal=false
Categories=Network;Qt;KDE;
StartupNotify=true
NoDisplay=false
EOF

# KDE System Settings
cat > "$APPDIR/systemsettings.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=KDE System Settings
GenericName=KDE System Settings
Comment=Configure KDE and system settings
Exec=env QT_QUICK_CONTROLS_STYLE=Material QT_QUICK_CONTROLS_MATERIAL_THEME=Dark QT_QUICK_CONTROLS_CONF=/dev/null KDE_COLOR_SCHEME=BreezeDark /usr/bin/systemsettings
Icon=preferences-system
Terminal=false
Categories=Settings;Qt;KDE;
StartupNotify=true
NoDisplay=false
EOF

# KDE Connect Settings
cat > "$APPDIR/org.kde.kdeconnect-settings.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=KDE Connect Settings
GenericName=Device Synchronization Settings
Comment=Configure KDE Connect
Exec=env QT_QUICK_CONTROLS_STYLE=Material QT_QUICK_CONTROLS_MATERIAL_THEME=Dark QT_QUICK_CONTROLS_CONF=/dev/null KDE_COLOR_SCHEME=BreezeDark /usr/bin/systemsettings kcm_kdeconnect
Icon=kdeconnect
Terminal=false
Categories=Settings;Qt;KDE;
StartupNotify=true
NoDisplay=false
EOF

# Hide junk/duplicate KDE entries that clutter rofi
hide_desktop() {
    local file="$1"
    local base
    base="$(basename "$file")"
    [ -f "$file" ] || return 0

    cat > "$APPDIR/$base" <<EOF
[Desktop Entry]
Type=Application
Hidden=true
NoDisplay=true
Name=Hidden $base
EOF
}

hide_desktop /usr/share/applications/kdesystemsettings.desktop
hide_desktop /usr/share/applications/kcm_kdeconnect.desktop
hide_desktop /usr/share/applications/org.kde.plasma.settings.open.desktop
hide_desktop /usr/share/applications/org.kde.kdeconnect.nonplasma.desktop
hide_desktop /usr/share/applications/org.kde.kdeconnect.handler.desktop
hide_desktop /usr/share/applications/org.kde.kdeconnect.daemon.desktop

update-desktop-database "$APPDIR" >/dev/null 2>&1 || true

echo "Done."
echo "Launch with: rofi -show drun"

sudo apt-get install -y qt6ct

# ensure local desktop override directory exists
mkdir -p "$HOME/.local/share/applications"

# copy the original launcher locally
cp /usr/share/applications/org.kde.kdeconnect-settings.desktop \
   "$HOME/.local/share/applications/"

# replace the Exec line so rofi launches the dark-mode command
sed -i \
's#^Exec=.*#Exec=env QT_QPA_PLATFORMTHEME=qt6ct /usr/bin/systemsettings kcm_kdeconnect#' \
"$HOME/.local/share/applications/org.kde.kdeconnect-settings.desktop"

# refresh desktop database and clear rofi cache
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
rm -f "$HOME/.cache/rofi-"* 2>/dev/null || true
