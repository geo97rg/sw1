import Foundation
import Network

enum InternetChecker {
    /// Быстрая проверка наличия сети (Wi-Fi/Cellular). Возвращает true/false.
    static func hasInternet(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetChecker")
        monitor.pathUpdateHandler = { path in
            monitor.cancel()
            completion(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    /// Async-обёртка. Ждёт до timeout секунд, пока не получит первый статус.
    static func hasInternet(timeout: TimeInterval = 3.0) async -> Bool {
        await withCheckedContinuation { cont in
            var finished = false
            hasInternet { ok in
                guard !finished else { return }
                finished = true
                cont.resume(returning: ok)
            }
            // Таймаут «на всякий случай»
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !finished {
                    finished = true
                    cont.resume(returning: false)
                }
            }
        }
    }
}
