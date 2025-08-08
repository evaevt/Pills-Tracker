import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            MainScreenView()
                .navigationDestination(for: AppRouter.Screen.self) { screen in
                    destinationView(for: screen)
                }
        }
        .tint(.blue)
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