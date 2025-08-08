import SwiftUI

struct AnalyticsView: View {
    let tracker: PersonalTracker
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Аналитика для \(tracker.name)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Графики и статистика будут здесь")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AnalyticsView(
            tracker: PersonalTracker(name: "Тест")
        )
    }
    .environmentObject(AppRouter())
} 