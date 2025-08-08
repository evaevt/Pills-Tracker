import SwiftUI

@main
struct TrackerApp: App {
    let persistenceController = PersistenceController.shared
    let dependencyContainer = DependencyContainer.shared
    
    init() {
        setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dependencyContainer.resolve(AppRouter.self))
                .environmentObject(dependencyContainer.resolve(AppState.self))
        }
    }
    
    private func setupDependencies() {
        dependencyContainer.registerServices()
    }
} 