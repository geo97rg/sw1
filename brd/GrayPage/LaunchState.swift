import Foundation

enum LaunchState: Equatable {
    case undecided
    case forceMain
    case web(URL)
}

enum PersistenceKeys {
    static let mode = "launch_mode"   // "main" | "web"
    static let webURL = "launch_web_url"
}

final class Persistence {
    static let shared = Persistence()
    private init() {}

    private let defaults = UserDefaults.standard

    func saveForceMain() {
        defaults.set("main", forKey: PersistenceKeys.mode)
        defaults.removeObject(forKey: PersistenceKeys.webURL)
    }

    func saveWebURL(_ url: URL) {
        defaults.set("web", forKey: PersistenceKeys.mode)
        defaults.set(url.absoluteString, forKey: PersistenceKeys.webURL)
    }

    func loadState() -> LaunchState {
        guard let mode = defaults.string(forKey: PersistenceKeys.mode) else {
            return .undecided
        }
        switch mode {
        case "main":
            return .forceMain
        case "web":
            if let s = defaults.string(forKey: PersistenceKeys.webURL),
               let url = URL(string: s) {
                return .web(url)
            } else {
                // если URL потерялся — перестрахуемся и уйдём в main
                return .forceMain
            }
        default:
            return .undecided
        }
    }
}
