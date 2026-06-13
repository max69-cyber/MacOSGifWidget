# MacOSGifWidget

Floating desktop widget for macOS that shows a random animated GIF, refreshed
periodically, fetched from the [Giphy](https://developers.giphy.com/) API.

It's a Swift Package executable (no Xcode project required), built with
SwiftUI/AppKit. The app runs as a menu-bar accessory (no Dock icon) and shows
a small always-on-top, draggable, rounded window with the current GIF.

## 1. Get a Giphy API key

1. Go to https://developers.giphy.com/ and sign up / log in.
2. Create an app (the free "Beta key" tier is enough).
3. Copy the API key.
4. Open `Sources/MacOSGifWidget/Config.swift` and replace:

   ```swift
   static let giphyAPIKey = "YOUR_GIPHY_API_KEY"
   ```

   with your real key.

You can also tweak in `Config.swift`:
- `tags` — categories the random gif is pulled from (empty array = fully random)
- `rating` — content rating filter (`g`, `pg`, `pg-13`, `r`)
- `refreshInterval` — how often a new gif loads, in seconds
- `widgetSize` — size of the widget on screen
- `cornerRadius` — corner rounding

## 2. Build & run

Requires Xcode / Swift toolchain (macOS 13+).

```bash
cd MacOSGifWidget
swift run
```

The first run will download dependencies (none external — just AppKit/Foundation)
and compile. A new floating gif window appears in the bottom-right corner of
your main screen, and a menu-bar icon (photo icon) is added.

- Menu bar icon → **New Gif**: load a different random gif immediately
- Menu bar icon → **Quit**: exit the app
- Right-click the widget itself for the same menu
- Drag the widget anywhere by clicking and dragging its background

## 3. Run it persistently (optional)

`swift run` keeps the process attached to your terminal. To run it in the
background:

```bash
swift build -c release
./.build/release/MacOSGifWidget &
```

To launch automatically at login, create a LaunchAgent plist pointing at the
built binary path, or wrap the binary in a minimal `.app` bundle and add it
to System Settings → General → Login Items.

## How it works

- `Config.swift` — all user-tunable settings (API key, tags, refresh interval, size)
- `GiphyService.swift` — calls Giphy's `/v1/gifs/random` endpoint and downloads the raw GIF bytes
- `GifWindowController.swift` — borderless, floating, draggable `NSWindow` with an `NSImageView` that animates the downloaded GIF, plus a refresh timer
- `AppDelegate.swift` — sets up the menu-bar status item and creates the widget window
- `main.swift` — app entry point

## Notes / possible improvements

- Swap Giphy for [Tenor](https://tenor.com/gifapi) by adding a second service with the same interface.
- Persist the last gif to disk so the widget shows something on next launch before the network call completes.
- Add a "favorite tags" picker UI instead of editing `Config.swift`.
- Package as a proper `.app` bundle with an icon if you want it in the Dock/Login Items UI.
