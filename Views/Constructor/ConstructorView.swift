import SwiftUI

struct ConstructorView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var trackerName = ""
    @State private var selectedModules: [TrackerModule] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок и поле ввода названия
                VStack(alignment: .leading, spacing: 16) {
                    Text("Создание трекера")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название трекера")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Введите название", text: $trackerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Холст для модулей
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedModules.isEmpty {
                            emptyCanvasView
                        } else {
                            ForEach(selectedModules) { module in
                                ModulePreviewCard(module: module) {
                                    removeModule(module)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Библиотека модулей
                ModuleLibraryView { module in
                    addModule(module)
                }
                .frame(height: 200)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        router.goBack()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTracker()
                    }
                    .disabled(trackerName.isEmpty || selectedModules.isEmpty)
                }
            }
        }
    }
    
    private var emptyCanvasView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.dashed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Перетащите модули сюда")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Выберите модули из библиотеки ниже")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary, style: StrokeStyle(lineWidth: 2, dash: [5]))
        )
    }
    
    private func addModule(_ moduleType: ModuleType) {
        let newModule = TrackerModule(type: moduleType)
        selectedModules.append(newModule)
    }
    
    private func removeModule(_ module: TrackerModule) {
        selectedModules.removeAll { $0.id == module.id }
    }
    
    private func saveTracker() {
        let tracker = PersonalTracker(
            name: trackerName,
            modules: selectedModules
        )
        
        // Здесь будет сохранение трекера
        router.goBack()
    }
}

struct ModulePreviewCard: View {
    let module: TrackerModule
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: module.type.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(module.displayTitle)
                    .font(.headline)
                
                Text(module.type.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ConstructorView()
        .environmentObject(AppRouter())
} 