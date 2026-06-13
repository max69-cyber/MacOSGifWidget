// GifWindowController — главное окно виджета.
//
// Отвечает за:
// - создание и настройку плавающего окна на уровне рабочего стола
// - отображение и анимацию GIF через NSImageView
// - перетаскивание окна мышью (глобальный монитор событий)
// - двойной клик для увеличения до четверти экрана и обратно
// - сохранение позиции окна между запусками (UserDefaults)
// - автообновление GIF по таймеру (Config.refreshInterval)
//
// DraggableWindow — подкласс NSWindow, разрешающий фокус на borderless окне.
import AppKit

final class GifWindowController: NSWindowController {

    private let imageView = NSImageView()
    private let spinner = NSProgressIndicator()
    private var refreshTimer: Timer?
    private let service = GiphyService()
    private var isExpanded = false

    // Глобальный монитор: слушает клики и drag по всему экрану
    private var mouseMonitor: Any?
    // Начальные координаты для вычисления смещения при перетаскивании
    private var dragStartMouse: NSPoint?
    private var dragStartOrigin: NSPoint?

    private static let positionKey = "widgetWindowOrigin"

    convenience init() {
        let size = Config.widgetSize
        let window = DraggableWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        // Уровень чуть выше рабочего стола — окно под всеми приложениями
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        self.init(window: window)
        windowDidLoad()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = window, let contentView = window.contentView else { return }

        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = Config.cornerRadius
        contentView.layer?.masksToBounds = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.6).cgColor

        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.width, .height]
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.animates = true
        contentView.addSubview(imageView)

        spinner.style = .spinning
        spinner.isIndeterminate = true
        spinner.controlSize = .large
        spinner.frame = NSRect(
            x: (contentView.bounds.width - 32) / 2,
            y: (contentView.bounds.height - 32) / 2,
            width: 32, height: 32
        )
        spinner.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        spinner.isHidden = true
        contentView.addSubview(spinner)

        addMouseMonitor()
        addContextMenu(to: contentView)
        restoreOrDefaultPosition()
        setupDragTracking()
        loadNewGif()
        startTimer()
    }

    // MARK: - Мышь: перетаскивание и двойной клик

    private func addMouseMonitor() {
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]) { [weak self] event in
            guard let self, let window = self.window else { return }
            switch event.type {
            case .leftMouseDown:
                if event.clickCount == 2, window.frame.contains(event.locationInWindow) {
                    // Двойной клик — переключить размер
                    self.toggleSize()
                } else if window.frame.contains(event.locationInWindow) {
                    // Одиночный клик внутри окна — начало перетаскивания
                    self.dragStartMouse = NSEvent.mouseLocation
                    self.dragStartOrigin = window.frame.origin
                }
            case .leftMouseDragged:
                guard let startMouse = self.dragStartMouse, let startOrigin = self.dragStartOrigin else { return }
                let current = NSEvent.mouseLocation
                let dx = current.x - startMouse.x
                let dy = current.y - startMouse.y
                window.setFrameOrigin(NSPoint(x: startOrigin.x + dx, y: startOrigin.y + dy))
            case .leftMouseUp:
                if self.dragStartMouse != nil {
                    self.dragStartMouse = nil
                    self.dragStartOrigin = nil
                    self.windowMoved() // сохранить новую позицию
                }
            default: break
            }
        }
    }

    // Плавная анимация изменения размера; увеличенный размер = четверть экрана (4:3)
    @objc private func toggleSize() {
        guard let window = window, let screen = NSScreen.main else { return }
        isExpanded.toggle()

        let newSize: CGSize
        if isExpanded {
            let side = min(screen.visibleFrame.width, screen.visibleFrame.height) / 2
            newSize = CGSize(width: side * 4 / 3, height: side)
        } else {
            newSize = Config.widgetSize
        }

        let currentOrigin = window.frame.origin
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(NSRect(origin: currentOrigin, size: newSize), display: true)
        }
    }

    // MARK: - Позиция окна

    private func restoreOrDefaultPosition() {
        guard let window = window else { return }
        if let saved = UserDefaults.standard.string(forKey: Self.positionKey),
           let origin = NSPointFromString(saved) as NSPoint?,
           origin != .zero {
            window.setFrameOrigin(origin)
        } else {
            defaultPosition()
        }
    }

    private func defaultPosition() {
        guard let window = window, let screen = NSScreen.main else { return }
        let f = screen.visibleFrame
        window.setFrameOrigin(NSPoint(x: f.minX + 20, y: f.minY + 20))
    }

    private func setupDragTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowMoved),
            name: NSWindow.didMoveNotification,
            object: window
        )
    }

    @objc private func windowMoved() {
        guard let origin = window?.frame.origin else { return }
        UserDefaults.standard.set(NSStringFromPoint(origin), forKey: Self.positionKey)
    }

    // MARK: - Контекстное меню (правый клик)

    private func addContextMenu(to view: NSView) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "New Gif", action: #selector(loadNewGif), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        for item in menu.items { item.target = self }
        view.menu = menu
    }

    // MARK: - Загрузка GIF

    private func startTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Config.refreshInterval, repeats: true) { [weak self] _ in
            self?.loadNewGif()
        }
    }

    @objc func loadNewGif() {
        spinner.isHidden = false
        spinner.startAnimation(nil)

        service.fetchRandomGifURL { [weak self] result in
            switch result {
            case .success(let url):
                self?.service.downloadGif(from: url) { downloadResult in
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimation(nil)
                        self?.spinner.isHidden = true
                        if case .success(let data) = downloadResult {
                            self?.imageView.image = NSImage(data: data)
                        }
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.spinner.stopAnimation(nil)
                    self?.spinner.isHidden = true
                }
            }
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    deinit {
        refreshTimer?.invalidate()
        if let mouseMonitor { NSEvent.removeMonitor(mouseMonitor) }
        NotificationCenter.default.removeObserver(self)
    }
}

// Borderless окно, которое всё равно может получать фокус —
// нужно для работы контекстного меню и горячих клавиш
final class DraggableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
