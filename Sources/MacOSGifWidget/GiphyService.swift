// GiphyService — вся работа с Giphy API.
// fetchRandomGifURL: запрашивает URL случайного GIF по заданному тегу и рейтингу.
// downloadGif: скачивает сырые байты GIF по URL.
import Foundation

// Минимальная модель для парсинга ответа от /v1/gifs/random
struct GiphyRandomResponse: Decodable {
    struct GifData: Decodable {
        struct Images: Decodable {
            struct ImageVariant: Decodable {
                let url: String
            }
            let original: ImageVariant
        }
        let images: Images
        let title: String
    }
    let data: GifData
}

enum GiphyError: LocalizedError {
    case invalidURL
    case invalidResponse
    case missingAPIKey
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Could not build Giphy request URL."
        case .invalidResponse: return "Received an unexpected response from Giphy."
        case .missingAPIKey: return "Set Config.giphyAPIKey to your Giphy API key."
        case .httpError(let code): return "Giphy returned HTTP status \(code)."
        }
    }
}

final class GiphyService {

    // Запрашивает URL случайного GIF с учётом тега и рейтинга из Config
    func fetchRandomGifURL(completion: @escaping (Result<URL, Error>) -> Void) {
        guard Config.giphyAPIKey != "YOUR_GIPHY_API_KEY", !Config.giphyAPIKey.isEmpty else {
            completion(.failure(GiphyError.missingAPIKey))
            return
        }

        guard var components = URLComponents(string: "https://api.giphy.com/v1/gifs/random") else {
            completion(.failure(GiphyError.invalidURL))
            return
        }

        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.giphyAPIKey),
            URLQueryItem(name: "rating", value: Config.rating)
        ]
        // Тег выбирается случайно из Config.tags; если массив пустой — запрос без тега
        if let tag = Config.tags.randomElement(), !tag.isEmpty {
            queryItems.append(URLQueryItem(name: "tag", value: tag))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            completion(.failure(GiphyError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(GiphyError.httpError(http.statusCode)))
                return
            }
            guard let data = data else { completion(.failure(GiphyError.invalidResponse)); return }
            do {
                let decoded = try JSONDecoder().decode(GiphyRandomResponse.self, from: data)
                guard let gifURL = URL(string: decoded.data.images.original.url) else {
                    completion(.failure(GiphyError.invalidResponse))
                    return
                }
                completion(.success(gifURL))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // Скачивает байты GIF по прямому URL
    func downloadGif(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(GiphyError.invalidResponse)); return }
            completion(.success(data))
        }
        task.resume()
    }
}
