import SwiftUI

struct ActiveTrackerView: View {
    let tracker: PersonalTracker
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок трекера
                VStack(spacing: 8) {
                    Text(tracker.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Сегодня, \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Модули трекера
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(tracker.modules) { module in
                        ModuleActiveView(module: module)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Аналитика") {
                    router.navigate(to: .analytics(tracker))
                }
            }
        }
    }
}

struct ModuleActiveView: View {
    let module: TrackerModule
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: module.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(module.displayTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Здесь будет реальный модуль
            Text("Модуль: \(module.type.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationView {
        ActiveTrackerView(
            tracker: PersonalTracker(
                name: "Утренняя рутина",
                modules: [
                    TrackerModule(type: .waterCounter, settings: ModuleSettings(goal: 8, unit: "стаканов")),
                    TrackerModule(type: .simpleCheckbox, settings: ModuleSettings(customTitle: "Медитация")),
                    TrackerModule(type: .stepCounter, settings: ModuleSettings(goal: 10000, unit: "шагов"))
                ]
            )
        )
    }
    .environmentObject(AppRouter())
} 