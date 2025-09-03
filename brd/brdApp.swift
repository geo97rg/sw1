import SwiftUI

@main
struct brdApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            GrayPageView()
        }
    }
}
