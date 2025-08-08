import SwiftUI

struct MainTabView: View {
  @EnvironmentObject private var firebaseService: FirebaseService
  @EnvironmentObject private var analyticsService: AnalyticsService
  @EnvironmentObject private var subscriptionService: SubscriptionService
  @StateObject private var dayDataService = DayDataService()

  var body: some View {
    TabView {
      // Main Screen
      MainScreenView()
        .environmentObject(dayDataService)
        .tabItem {
          Image(systemName: "house.fill")
          Text("Home")
        }
        .tag(0)

      // Calendar
      CalendarView()
        .tabItem {
          Image(systemName: "calendar")
          Text("Calendar")
        }
        .tag(1)

      // Analytics
      AnalyticsView()
        .tabItem {
          Image(systemName: "chart.bar.fill")
          Text("Analytics")
        }
        .tag(2)

      // Profile
      ProfileView()
        .tabItem {
          Image(systemName: "person.fill")
          Text("Profile")
        }
        .tag(3)
    }
    .tint(.blue)  // Цвет активной вкладки
  }
}

#Preview {
  MainTabView()
    .environmentObject(FirebaseService())
    .environmentObject(AnalyticsService())
    .environmentObject(SubscriptionService())
}
