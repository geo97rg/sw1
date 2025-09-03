import Foundation

enum LinkFetcher {
    /// Собираем URL: baseURL + query, делаем запрос, читаем заголовок headerKey.
    /// Если заголовок найден и это валидная ссылка — вернём её.
    static func fetchLink(
        baseURL: URL,
        headerKey: String,
        device: DeviceInfo,
        token: String
    ) async -> URL? {

        // 1) Сборка query через URLComponents (корректное percent-encoding)
        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var items: [URLQueryItem] = []
        items.append(.init(name: "uuid", value: device.uuid))
        items.append(.init(name: "token", value: token))
        items.append(.init(name: "model_id", value: device.model_id))
        items.append(.init(name: "os", value: device.os))
        items.append(.init(name: "lang", value: device.lang))
        items.append(.init(name: "rg", value: device.rg))
        items.append(.init(name: "bld", value: device.bld))
        comps?.queryItems = items
        guard let finalURL = comps?.url else {
            print("⚠️ Не удалось собрать URL")
            return nil
        }

        // 2) Запрос
        var req = URLRequest(url: finalURL)
        req.httpMethod = "GET"

        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return nil }

            // 3) Чтение заголовков (ключи в allHeaderFields — case-insensitive)
            let headerValue: String? = {
                for (k, v) in http.allHeaderFields {
                    if String(describing: k).lowercased() == headerKey.lowercased(),
                       let s = v as? String {
                        return s
                    }
                }
                return nil
            }()

            if let linkString = headerValue, let url = URL(string: linkString) {
                return url
            } else {
                print("ℹ️ Заголовок \(headerKey) не найден")
                return nil
            }
        } catch {
            print("❌ Ошибка сети:", error)
            return nil
        }
    }
}
