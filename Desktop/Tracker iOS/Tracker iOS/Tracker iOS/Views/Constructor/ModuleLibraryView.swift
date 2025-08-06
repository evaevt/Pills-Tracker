import SwiftUI

struct ModuleLibraryView: View {
    let onModuleSelected: (ModuleType) -> Void
    @State private var selectedCategory: ModuleCategory = .counters
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            HStack {
                Text("Библиотека модулей")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Категории
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ModuleCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Модули
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(modulesForCategory(selectedCategory), id: \.self) { moduleType in
                        ModuleLibraryCard(moduleType: moduleType) {
                            onModuleSelected(moduleType)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private func modulesForCategory(_ category: ModuleCategory) -> [ModuleType] {
        ModuleType.allCases.filter { $0.category == category }
    }
}

struct CategoryButton: View {
    let category: ModuleCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModuleLibraryCard: View {
    let moduleType: ModuleType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: moduleType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
                
                Text(moduleType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ModuleLibraryView { moduleType in
        print("Selected: \(moduleType.displayName)")
    }
    .frame(height: 200)
} 