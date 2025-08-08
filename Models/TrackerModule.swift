import Foundation
import SwiftUI

/// Тип модуля трекера
enum ModuleType: String, CaseIterable, Codable, Hashable {
  // Счетчики
  case waterCounter = "water_counter"
  case stepCounter = "step_counter"
  case calorieCounter = "calorie_counter"
  case autoIncrement = "auto_increment"
  case reverseCounter = "reverse_counter"

  // Чекбоксы
  case simpleCheckbox = "simple_checkbox"
  case multipleChoice = "multiple_choice"
  case ratingScale = "rating_scale"

  // Визуализация
  case progressBar = "progress_bar"
  case circularProgress = "circular_progress"
  case calendarGrid = "calendar_grid"

  // Время
  case timer = "timer"
  case pomodoroTimer = "pomodoro_timer"
  case activityTimer = "activity_timer"
  case timeRange = "time_range"

  // Данные
  case note = "note"
  case photo = "photo"
  case voice = "voice"

  var displayName: String {
    switch self {
    case .waterCounter: return "Счетчик воды"
    case .stepCounter: return "Счетчик шагов"
    case .calorieCounter: return "Счетчик калорий"
    case .autoIncrement: return "Автосчетчик"
    case .reverseCounter: return "Обратный счетчик"
    case .simpleCheckbox: return "Чекбокс"
    case .multipleChoice: return "Множественный выбор"
    case .ratingScale: return "Рейтинг"
    case .progressBar: return "Прогресс-бар"
    case .circularProgress: return "Круговой прогресс"
    case .calendarGrid: return "Календарь"
    case .timer: return "Таймер"
    case .pomodoroTimer: return "Pomodoro"
    case .activityTimer: return "Трекер времени"
    case .timeRange: return "Временной интервал"
    case .note: return "Заметка"
    case .photo: return "Фото"
    case .voice: return "Голосовая запись"
    }
  }

  var icon: String {
    switch self {
    case .waterCounter: return "drop.fill"
    case .stepCounter: return "figure.walk"
    case .calorieCounter: return "flame.fill"
    case .autoIncrement: return "plus.circle.fill"
    case .reverseCounter: return "minus.circle.fill"
    case .simpleCheckbox: return "checkmark.square"
    case .multipleChoice: return "list.bullet.circle"
    case .ratingScale: return "star.fill"
    case .progressBar: return "progress.indicator"
    case .circularProgress: return "circle.fill"
    case .calendarGrid: return "calendar"
    case .timer: return "timer"
    case .pomodoroTimer: return "clock.fill"
    case .activityTimer: return "stopwatch"
    case .timeRange: return "clock.badge"
    case .note: return "note.text"
    case .photo: return "photo"
    case .voice: return "mic.fill"
    }
  }

  var category: ModuleCategory {
    switch self {
    case .waterCounter, .stepCounter, .calorieCounter, .autoIncrement, .reverseCounter:
      return .counters
    case .simpleCheckbox, .multipleChoice, .ratingScale:
      return .checkboxes
    case .progressBar, .circularProgress, .calendarGrid:
      return .visual
    case .timer, .pomodoroTimer, .activityTimer, .timeRange:
      return .time
    case .note, .photo, .voice:
      return .data
    }
  }
}

/// Категория модуля
enum ModuleCategory: String, CaseIterable {
  case counters = "counters"
  case checkboxes = "checkboxes"
  case visual = "visual"
  case time = "time"
  case data = "data"

  var displayName: String {
    switch self {
    case .counters: return "Счетчики"
    case .checkboxes: return "Чекбоксы"
    case .visual: return "Визуализация"
    case .time: return "Время"
    case .data: return "Данные"
    }
  }

  var icon: String {
    switch self {
    case .counters: return "plus.circle"
    case .checkboxes: return "checkmark.square"
    case .visual: return "chart.bar"
    case .time: return "clock"
    case .data: return "folder"
    }
  }
}

/// Настройки модуля
struct ModuleSettings: Codable, Equatable {
  var goal: Int?
  var unit: String?
  var color: String?
  var isEnabled: Bool
  var position: CGPoint?
  var size: CGSize?
  var customTitle: String?
  var reminders: [String]?
  var metadata: [String: String]?

  init(
    goal: Int? = nil,
    unit: String? = nil,
    color: String? = nil,
    isEnabled: Bool = true,
    position: CGPoint? = nil,
    size: CGSize? = nil,
    customTitle: String? = nil,
    reminders: [String]? = nil,
    metadata: [String: String]? = nil
  ) {
    self.goal = goal
    self.unit = unit
    self.color = color
    self.isEnabled = isEnabled
    self.position = position
    self.size = size
    self.customTitle = customTitle
    self.reminders = reminders
    self.metadata = metadata
  }
}

/// Модуль трекера
struct TrackerModule: Identifiable, Codable, Equatable, Hashable {
  let id: UUID
  let type: ModuleType
  var settings: ModuleSettings
  var currentValue: ModuleValue
  let createdAt: Date
  var updatedAt: Date

  init(
    id: UUID = UUID(),
    type: ModuleType,
    settings: ModuleSettings = ModuleSettings(),
    currentValue: ModuleValue = .none,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.type = type
    self.settings = settings
    self.currentValue = currentValue
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  var isValid: Bool {
    // Базовая валидация
    return settings.isEnabled
  }

  var displayTitle: String {
    return settings.customTitle ?? type.displayName
  }

  mutating func updateValue(_ value: ModuleValue) {
    currentValue = value
    updatedAt = Date()
  }
}

/// Значение модуля
enum ModuleValue: Codable, Equatable {
  case none
  case integer(Int)
  case double(Double)
  case boolean(Bool)
  case string(String)
  case array([String])
  case date(Date)
  case data(Data)

  var intValue: Int? {
    if case .integer(let value) = self {
      return value
    }
    return nil
  }

  var doubleValue: Double? {
    if case .double(let value) = self {
      return value
    }
    return nil
  }

  var boolValue: Bool? {
    if case .boolean(let value) = self {
      return value
    }
    return nil
  }

  var stringValue: String? {
    if case .string(let value) = self {
      return value
    }
    return nil
  }

  var arrayValue: [String]? {
    if case .array(let value) = self {
      return value
    }
    return nil
  }

  var dateValue: Date? {
    if case .date(let value) = self {
      return value
    }
    return nil
  }

  var dataValue: Data? {
    if case .data(let value) = self {
      return value
    }
    return nil
  }
}

/// Результат валидации
enum ValidationResult: Equatable {
  case valid
  case invalid(String)

  var isValid: Bool {
    if case .valid = self {
      return true
    }
    return false
  }

  var errorMessage: String? {
    if case .invalid(let message) = self {
      return message
    }
    return nil
  }
}
