import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        if authService.user != nil {
            NavigationStack(path: $router.navigationPath) {
                MainScreenView()
                    .navigationDestination(for: AppRouter.Screen.self) { screen in
                        destinationView(for: screen)
                    }
            }
            .tint(.blue)
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for screen: AppRouter.Screen) -> some View {
        switch screen {
        case .main:
            MainScreenView()
        case .constructor:
            ConstructorView()
        case .activeTracker(let tracker):
            ActiveTrackerView(tracker: tracker)
        case .moduleSettings(let module):
            ModuleSettingsView(module: module)
        case .analytics(let tracker):
            AnalyticsView(tracker: tracker)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
        .environmentObject(AppState(dataService: MockDataService()))
} 