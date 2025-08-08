import Foundation
import SwiftUI

/// Персональный трекер пользователя
struct PersonalTracker: Identifiable, Codable, Equatable, Hashable {
  let id: UUID
  var name: String
  var modules: [TrackerModule]
  var layoutConfiguration: LayoutConfiguration
  var theme: TrackerTheme
  let createdAt: Date
  var updatedAt: Date
  var isActive: Bool
  var tags: [String]

  init(
    id: UUID = UUID(),
    name: String,
    modules: [TrackerModule] = [],
    layoutConfiguration: LayoutConfiguration = LayoutConfiguration(),
    theme: TrackerTheme = .default,
    createdAt: Date = Date(),
    updatedAt: Date = Date(),
    isActive: Bool = true,
    tags: [String] = []
  ) {
    self.id = id
    self.name = name
    self.modules = modules
    self.layoutConfiguration = layoutConfiguration
    self.theme = theme
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isActive = isActive
    self.tags = tags
  }

  var moduleCount: Int {
    modules.count
  }

  var activeModuleCount: Int {
    modules.filter { $0.settings.isEnabled }.count
  }

  var completionPercentage: Double {
    let completedModules = modules.filter { module in
      switch module.currentValue {
      case .boolean(let value):
        return value
      case .integer(let value):
        if let goal = module.settings.goal {
          return value >= goal
        }
        return value > 0
      case .double(let value):
        return value > 0
      default:
        return false
      }
    }

    guard !modules.isEmpty else { return 0 }
    return Double(completedModules.count) / Double(modules.count)
  }

  mutating func addModule(_ module: TrackerModule) {
    modules.append(module)
    updatedAt = Date()
  }

  mutating func removeModule(id: UUID) {
    modules.removeAll { $0.id == id }
    updatedAt = Date()
  }

  mutating func updateModule(_ module: TrackerModule) {
    if let index = modules.firstIndex(where: { $0.id == module.id }) {
      modules[index] = module
      updatedAt = Date()
    }
  }

  func getModule(id: UUID) -> TrackerModule? {
    modules.first { $0.id == id }
  }
}

/// Конфигурация макета трекера
struct LayoutConfiguration: Codable, Equatable, Hashable {
  var columns: Int
  var spacing: CGFloat
  var paddingTop: CGFloat
  var paddingLeading: CGFloat
  var paddingBottom: CGFloat
  var paddingTrailing: CGFloat
  var backgroundColor: String?
  var cornerRadius: CGFloat
  var showHeaders: Bool
  var compactMode: Bool

  init(
    columns: Int = 2,
    spacing: CGFloat = 16,
    paddingTop: CGFloat = 16,
    paddingLeading: CGFloat = 16,
    paddingBottom: CGFloat = 16,
    paddingTrailing: CGFloat = 16,
    backgroundColor: String? = nil,
    cornerRadius: CGFloat = 12,
    showHeaders: Bool = true,
    compactMode: Bool = false
  ) {
    self.columns = columns
    self.spacing = spacing
    self.paddingTop = paddingTop
    self.paddingLeading = paddingLeading
    self.paddingBottom = paddingBottom
    self.paddingTrailing = paddingTrailing
    self.backgroundColor = backgroundColor
    self.cornerRadius = cornerRadius
    self.showHeaders = showHeaders
    self.compactMode = compactMode
  }

  /// Вычисляемое свойство для совместимости с EdgeInsets
  var padding: EdgeInsets {
    EdgeInsets(
      top: paddingTop, leading: paddingLeading, bottom: paddingBottom, trailing: paddingTrailing)
  }
}

/// Тема трекера
struct TrackerTheme: Codable, Equatable, Hashable {
  var primaryColor: String
  var secondaryColor: String
  var accentColor: String
  var backgroundColor: String
  var textColor: String
  var cardColor: String
  var name: String

  init(
    primaryColor: String = "#007AFF",
    secondaryColor: String = "#8E8E93",
    accentColor: String = "#FF9500",
    backgroundColor: String = "#F2F2F7",
    textColor: String = "#000000",
    cardColor: String = "#FFFFFF",
    name: String = "Default"
  ) {
    self.primaryColor = primaryColor
    self.secondaryColor = secondaryColor
    self.accentColor = accentColor
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    self.cardColor = cardColor
    self.name = name
  }

  static let `default` = TrackerTheme()

  static let dark = TrackerTheme(
    primaryColor: "#0A84FF",
    secondaryColor: "#8E8E93",
    accentColor: "#FF9F0A",
    backgroundColor: "#000000",
    textColor: "#FFFFFF",
    cardColor: "#1C1C1E",
    name: "Dark"
  )

  static let nature = TrackerTheme(
    primaryColor: "#34C759",
    secondaryColor: "#8E8E93",
    accentColor: "#FF9500",
    backgroundColor: "#F2F2F7",
    textColor: "#000000",
    cardColor: "#FFFFFF",
    name: "Nature"
  )

  static let ocean = TrackerTheme(
    primaryColor: "#007AFF",
    secondaryColor: "#5AC8FA",
    accentColor: "#FF2D92",
    backgroundColor: "#F2F2F7",
    textColor: "#000000",
    cardColor: "#FFFFFF",
    name: "Ocean"
  )
}

/// Шаблон трекера
struct TrackerTemplate: Identifiable, Codable {
  let id: UUID
  let name: String
  let description: String
  let category: TemplateCategory
  let modules: [TrackerModule]
  let layoutConfiguration: LayoutConfiguration
  let theme: TrackerTheme
  let previewImageName: String?
  let isPopular: Bool
  let createdAt: Date

  init(
    id: UUID = UUID(),
    name: String,
    description: String,
    category: TemplateCategory,
    modules: [TrackerModule],
    layoutConfiguration: LayoutConfiguration = LayoutConfiguration(),
    theme: TrackerTheme = .default,
    previewImageName: String? = nil,
    isPopular: Bool = false,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.category = category
    self.modules = modules
    self.layoutConfiguration = layoutConfiguration
    self.theme = theme
    self.previewImageName = previewImageName
    self.isPopular = isPopular
    self.createdAt = createdAt
  }

  func createTracker() -> PersonalTracker {
    PersonalTracker(
      name: name,
      modules: modules,
      layoutConfiguration: layoutConfiguration,
      theme: theme
    )
  }
}

/// Категория шаблона
enum TemplateCategory: String, CaseIterable, Codable {
  case health = "health"
  case fitness = "fitness"
  case productivity = "productivity"
  case habits = "habits"
  case wellness = "wellness"
  case work = "work"
  case learning = "learning"
  case finance = "finance"

  var displayName: String {
    switch self {
    case .health: return "Здоровье"
    case .fitness: return "Фитнес"
    case .productivity: return "Продуктивность"
    case .habits: return "Привычки"
    case .wellness: return "Благополучие"
    case .work: return "Работа"
    case .learning: return "Обучение"
    case .finance: return "Финансы"
    }
  }

  var icon: String {
    switch self {
    case .health: return "heart.fill"
    case .fitness: return "figure.run"
    case .productivity: return "chart.bar.fill"
    case .habits: return "checkmark.circle.fill"
    case .wellness: return "leaf.fill"
    case .work: return "briefcase.fill"
    case .learning: return "book.fill"
    case .finance: return "dollarsign.circle.fill"
    }
  }

  var color: String {
    switch self {
    case .health: return "#FF2D92"
    case .fitness: return "#FF9500"
    case .productivity: return "#007AFF"
    case .habits: return "#34C759"
    case .wellness: return "#AF52DE"
    case .work: return "#8E8E93"
    case .learning: return "#5AC8FA"
    case .finance: return "#FFCC00"
    }
  }
}

/// Статистика трекера
struct TrackerStatistics: Codable {
  let trackerId: UUID
  let totalDays: Int
  let completedDays: Int
  let currentStreak: Int
  let longestStreak: Int
  let averageCompletion: Double
  let lastUpdated: Date
  let moduleStatistics: [UUID: ModuleStatistics]

  var completionRate: Double {
    guard totalDays > 0 else { return 0 }
    return Double(completedDays) / Double(totalDays)
  }
}

/// Статистика модуля
struct ModuleStatistics: Codable {
  let moduleId: UUID
  let totalInteractions: Int
  let averageValue: Double
  let minValue: Double
  let maxValue: Double
  let lastValue: ModuleValue
  let trend: StatisticsTrend
  let lastUpdated: Date
}

/// Тренд статистики
enum StatisticsTrend: String, Codable {
  case increasing = "increasing"
  case decreasing = "decreasing"
  case stable = "stable"
  case noData = "no_data"

  var displayName: String {
    switch self {
    case .increasing: return "Растет"
    case .decreasing: return "Падает"
    case .stable: return "Стабильно"
    case .noData: return "Нет данных"
    }
  }

  var icon: String {
    switch self {
    case .increasing: return "arrow.up.right"
    case .decreasing: return "arrow.down.right"
    case .stable: return "arrow.right"
    case .noData: return "questionmark"
    }
  }

  var color: String {
    switch self {
    case .increasing: return "#34C759"
    case .decreasing: return "#FF3B30"
    case .stable: return "#007AFF"
    case .noData: return "#8E8E93"
    }
  }
}
