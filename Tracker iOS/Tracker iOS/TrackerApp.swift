import FirebaseCore
import SwiftUI

@main
struct TrackerApp: App {
  let persistenceController = PersistenceController.shared
  let dependencyContainer = DependencyContainer.shared
  @StateObject private var firebaseService = FirebaseService()
  @StateObject private var analyticsService = AnalyticsService()
  @StateObject private var subscriptionService = SubscriptionService()
  @StateObject private var dayDataService = DayDataService()

  init() {
    FirebaseApp.configure()
    setupDependencies()
  }

  var body: some Scene {
    WindowGroup {
      MainTabView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(dependencyContainer.resolve(AppRouter.self))
        .environmentObject(dependencyContainer.resolve(AppState.self))
        .environmentObject(firebaseService)
        .environmentObject(analyticsService)
        .environmentObject(subscriptionService)
        .environmentObject(dayDataService)
    }
  }

  private func setupDependencies() {
    dependencyContainer.registerServices()
  }
}
