import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct TrackerApp: App {
    let persistenceController = PersistenceController.shared
    let dependencyContainer = DependencyContainer.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dependencyContainer.resolve(AppRouter.self))
                .environmentObject(dependencyContainer.resolve(AppState.self))
                .environmentObject(dependencyContainer.resolve(AuthenticationServiceProtocol.self) as! AuthenticationService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
    
    private func setupDependencies() {
        dependencyContainer.registerServices()
    }
} 