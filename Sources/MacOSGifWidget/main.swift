// Точка входа приложения. Создаёт NSApplication и запускает run loop.
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
