import UserNotifications
import UIKit

enum PushError: Error {
    case denied
    case noToken
    case system(Error)
}

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    private var continuation: CheckedContinuation<String, Error>?

    private var tokenContinuation: CheckedContinuation<String, Error>?
    
    func requestToken() async throws -> String {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            if settings.authorizationStatus == .notDetermined {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if !granted { throw PushError.denied }
            } else if settings.authorizationStatus == .denied {
                throw PushError.denied
            }

            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }

            return try await withCheckedThrowingContinuation { cont in
                self.continuation = cont
            }
        }
    
    func resumeWithToken(_ token: String) {
            continuation?.resume(returning: token)
            continuation = nil
        }

        func resumeWithError(_ error: Error) {
            continuation?.resume(throwing: PushError.system(error))
            continuation = nil
        }
}
