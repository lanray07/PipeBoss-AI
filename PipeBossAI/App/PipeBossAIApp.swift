import SwiftUI

@main
struct PipeBossAIApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            // Hosted tests configure StoreKit before constructing the real manager.
            if ProcessInfo.processInfo.environment["PIPEBOSS_HOSTED_UNIT_TESTS"] == "1" {
                Color.clear
            } else {
                AppRootView()
            }
            #else
            AppRootView()
            #endif
        }
    }
}
