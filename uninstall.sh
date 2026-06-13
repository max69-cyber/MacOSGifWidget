#!/bin/bash
set -e

APP_NAME="MacOSGifWidget"
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"
PLIST="$HOME/Library/LaunchAgents/com.rayxaus.macosgifwidget.plist"

echo "Stopping $APP_NAME..."
pkill -x "$APP_NAME" 2>/dev/null || true

echo "Removing from autostart..."
launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"

echo "Removing app..."
rm -rf "$APP_BUNDLE"

echo "Done! $APP_NAME удалён."
