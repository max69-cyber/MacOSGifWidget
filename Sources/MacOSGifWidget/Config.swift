// Все настройки приложения в одном месте — меняй здесь, не трогая логику.
import Foundation
import CoreGraphics

enum Config {
    // Ключ для апишки, можно получить на сайте https://developers.giphy.com/
    static let giphyAPIKey: String = "D2NZoRxaOgJjX4lAWFwZhBiEzB8B1zkj"

    // Теги для случайных гифок. Если не указаны то выбирается без тега - рандом
    static let tags: [String] = []

    // Возрастной рейтинг контента: g, pg, pg-13, r
    static let rating: String = "pg-13"

    // Частота смены гифки
    static let refreshInterval: TimeInterval = 5 * 60

    // Размер виджета на экране
    static let widgetSize: CGSize = CGSize(width: 320, height: 240)

    // Скругление углов
    static let cornerRadius: CGFloat = 16
}
