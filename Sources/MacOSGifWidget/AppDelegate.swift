// Точка входа приложения после запуска.
// Создаёт виджет-окно и иконку в menu bar с меню (New Gif / Quit).
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // Айтем менюбара
    private var statusItem: NSStatusItem?
    // Само окошко отображения gif - свой класс
    private var gifWindowController: GifWindowController?

    // Тут происходит спавн окошка и айтема в менюбаре
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Приложение остается в menubar, но не в Dock
        NSApp.setActivationPolicy(.accessory)

        // Инстанс окошка отображения + оставим его сверху своего уровня, и несворачиваемым
        gifWindowController = GifWindowController()
        gifWindowController?.window?.orderFrontRegardless()

        // А тут вызываем метод настройки айтема менюбара
        setupStatusItem()
    }

    private func setupStatusItem() {
        // Создание самого айтема, ширина ровно под иконку
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        // Иконка и описание в менюбаре
        statusItem?.button?.image = NSImage(
            // Иконка из apple либы
            systemSymbolName: "photo.on.rectangle.angled",
            // for screenreader :)
            accessibilityDescription: "hello, motherfucker"
        )

        // Контекстное меню - открывается из менюбара
        let menu: NSMenu = NSMenu()
        // Накидываем айтемы контекстного меню + разделитель
        menu.addItem(NSMenuItem(title: "New Gif", action: #selector(refreshGif), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        // Говорим искать в этом же файле функции на нажатие каждому
        for item: NSMenuItem in menu.items { item.target = self }

        // Назначаем меню в айтем менюбара
        statusItem?.menu = menu
    }

    // Обнова гифки
    @objc private func refreshGif() {
        gifWindowController?.loadNewGif()
    }

    // Завершение работы
    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // Не закрываем приложение при закрытии окна — оно живёт в трее
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
