import SwiftUI

struct ModuleSettingsView: View {
    let module: TrackerModule
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        Form {
            Section("Основные настройки") {
                HStack {
                    Text("Тип модуля")
                    Spacer()
                    Text(module.type.displayName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Категория")
                    Spacer()
                    Text(module.type.category.displayName)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Настройки") {
                Text("Настройки модуля будут здесь")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Настройки модуля")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ModuleSettingsView(
            module: TrackerModule(type: .waterCounter)
        )
    }
    .environmentObject(AppRouter())
} 