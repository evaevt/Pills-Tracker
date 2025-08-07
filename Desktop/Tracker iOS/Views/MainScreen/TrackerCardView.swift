import SwiftUI

struct TrackerCardView: View {
    let tracker: PersonalTracker
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок и статус
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tracker.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("\(tracker.activeModuleCount) модулей")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        completionBadge
                        
                        if tracker.isActive {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Активен")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Превью модулей
                modulePreview
                
                // Теги
                if !tracker.tags.isEmpty {
                    tagView
                }
                
                // Прогресс
                progressView
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var completionBadge: some View {
        Text("\(Int(tracker.completionPercentage * 100))%")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(completionColor)
            )
    }
    
    private var completionColor: Color {
        let percentage = tracker.completionPercentage
        switch percentage {
        case 0..<0.3:
            return .red
        case 0.3..<0.7:
            return .orange
        default:
            return .green
        }
    }
    
    private var modulePreview: some View {
        HStack(spacing: 8) {
            ForEach(Array(tracker.modules.prefix(4).enumerated()), id: \.offset) { index, module in
                moduleIcon(for: module)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            
            if tracker.modules.count > 4 {
                Text("+\(tracker.modules.count - 4)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(.tertiarySystemBackground))
                    )
            }
            
            Spacer()
        }
    }
    
    private func moduleIcon(for module: TrackerModule) -> some View {
        Image(systemName: module.type.icon)
            .font(.system(size: 16))
            .foregroundColor(.blue)
    }
    
    private var tagView: some View {
        HStack(spacing: 8) {
            ForEach(tracker.tags.prefix(3), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
            }
            
            if tracker.tags.count > 3 {
                Text("+\(tracker.tags.count - 3)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Прогресс сегодня")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(tracker.completionPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(completionColor)
                        .frame(width: geometry.size.width * tracker.completionPercentage, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.3), value: tracker.completionPercentage)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TrackerCardView(
            tracker: PersonalTracker(
                name: "Утренняя рутина",
                modules: [
                    TrackerModule(type: .waterCounter, settings: ModuleSettings(goal: 8, unit: "стаканов")),
                    TrackerModule(type: .simpleCheckbox, settings: ModuleSettings(customTitle: "Медитация")),
                    TrackerModule(type: .stepCounter, settings: ModuleSettings(goal: 10000, unit: "шагов"))
                ],
                tags: ["здоровье", "утро"]
            )
        ) {
            print("Tapped")
        }
        
        TrackerCardView(
            tracker: PersonalTracker(
                name: "Продуктивность",
                modules: [
                    TrackerModule(type: .pomodoroTimer, settings: ModuleSettings(goal: 4, unit: "сессий")),
                    TrackerModule(type: .simpleCheckbox, settings: ModuleSettings(customTitle: "Главная задача")),
                    TrackerModule(type: .ratingScale, settings: ModuleSettings(customTitle: "Энергия")),
                    TrackerModule(type: .progressBar, settings: ModuleSettings(customTitle: "Прогресс")),
                    TrackerModule(type: .timer, settings: ModuleSettings(customTitle: "Фокус"))
                ],
                tags: ["работа", "фокус", "продуктивность", "дедлайн"]
            )
        ) {
            print("Tapped")
        }
    }
    .padding()
} 