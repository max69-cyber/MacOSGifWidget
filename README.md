# MacOSGifWidget

> **Дисклеймер:** этот проект написан с помощью ИИ. Проект выполнен в ознакомительных целях. Автором выполнена только документация алгоритма выполнения программы (в процессе).

---

## Что это

Виджет для рабочего стола macOS — небольшое плавающее окошко, которое показывает случайную анимированную гифку с [Giphy](https://developers.giphy.com/). Окошко живёт прямо на рабочем столе, под всеми окнами приложений, и само меняет гифку каждые 5 минут.

Приложение написано на Swift + AppKit, собирается через Swift Package Manager без Xcode.

---

## Получение Giphy API ключа

1. Зайдите на [developers.giphy.com](https://developers.giphy.com/) и создайте аккаунт, если у Вас его нет;
2. Нажмите **Create an App** и выберите **API** (бесплатный тариф). Прямая ссылка на создание App - [developers.giphy.com/dashboard/?create=true](https://developers.giphy.com/dashboard/?create=true);
3. Скопируйте **API Key**
4. Откройте [`Sources/MacOSGifWidget/Config.swift`](Sources/MacOSGifWidget/Config.swift) и вставьте ключ:

```swift
static let giphyAPIKey = "YOUR_GIPHY_API_KEY"
```

---

## Возможности

- Гифка на рабочем столе — под всеми окнами, не мешает работе
- Автообновление раз в 5 минут
- Перетаскивание — позиция сохраняется между запусками
- Двойной клик — разворачивает виджет до четверти экрана и обратно
- Иконка в menu bar — та же функция через трей
- Не занимает место в Dock и не появляется в Cmd+Tab

---

## Настройки

Настройка происходит через файл [`Config.swift`](Sources/MacOSGifWidget/Config.swift):

| Параметр | По умолчанию | Описание |
|---|---|---|
| `giphyAPIKey` | — | API-ключ Giphy |
| `tags` | `[]` | Теги для фильтрации GIF-ок (пустой = полный рандом) |
| `rating` | `"pg-13"` | Возрастной рейтинг: `g`, `pg`, `pg-13`, `r` |
| `refreshInterval` | `5 * 60` | Как часто менять гифку |
| `widgetSize` | `320 × 240` | Размер виджета (дефолт === 4:3) |
| `cornerRadius` | `16` | Скругление углов |

---

## Как запустить

Требования: Xcode / Swift toolchain (macOS 13+).

Выполните следующие команды в терминале:

```bash
cd MacOSGifWidget
swift run
```

Для запуска в фоне (без привязки к терминалу):

```bash
swift build -c release
./.build/release/MacOSGifWidget &
```

---

## Структура проекта

- `main.swift` — точка входа, запускает приложение
- `AppDelegate.swift` — иконка в менюбаре, создаёт окно виджета
- `GifWindowController.swift` — само окно: отображение, перетаскивание, клики, таймер
- `GiphyService.swift` — запросы к Giphy API, скачивание гифок
- `Config.swift` — все настройки в одном месте
