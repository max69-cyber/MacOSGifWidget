#!/bin/bash
set -e
cd "$(dirname "$0")"

APP_NAME="MacOSGifWidget"
INSTALL_DIR="$HOME/Applications"
APP_BUNDLE="$INSTALL_DIR/$APP_NAME.app"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST="$PLIST_DIR/com.rayxaus.macosgifwidget.plist"

echo "Building..."
swift build -c release

echo "Installing .app..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp ".build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Sources/$APP_NAME/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "Setting up autostart..."
mkdir -p "$PLIST_DIR"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.rayxaus.macosgifwidget</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_BUNDLE/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

# Перезагрузить агент если уже был зарегистрирован
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "Done! MacOSGifWidget запущен и будет стартовать при входе в систему."
echo "Чтобы удалить с автозапуска: launchctl unload $PLIST && rm $PLIST"
