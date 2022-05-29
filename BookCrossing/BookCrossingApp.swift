import SwiftUI
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@main
struct BookCrossingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            let vm = AppViewModel()
            LandingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL(perform: {url in
                    ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
                    
                })
                .environmentObject(vm)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        FBSDKCoreKit.ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }
}
