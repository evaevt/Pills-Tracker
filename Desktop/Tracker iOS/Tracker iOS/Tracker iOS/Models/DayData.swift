import Foundation

/// Модель для хранения всех данных конкретного дня
struct DayData: Codable, Identifiable {
  let id = UUID()
  let date: Date
  var waterCount: Int = 0
  var selectedMood: MoodType = .neutral
  var noteText: String = ""
  var vitamins: VitaminState = VitaminState()
  var isNoteSaved: Bool = false  // Состояние сохранения заметки

  /// Создание данных для конкретной даты
  init(date: Date) {
    self.date = Calendar.current.startOfDay(for: date)
  }

  /// Проверка, есть ли какие-либо данные за день
  var hasData: Bool {
    return waterCount > 0 || selectedMood != .neutral || !noteText.isEmpty || vitamins.hasAnyActive
  }
}

extension VitaminState {
  /// Проверка, активен ли хотя бы один витамин
  var hasAnyActive: Bool {
    return vitaminB || magnesium || iron || melatonin
  }
}

/// Модель для хранения кастомных названий витаминов
struct VitaminNames: Codable {
  var vitaminB: String = "Vitamin B"
  var magnesium: String = "Magnesium"
  var iron: String = "Iron"
  var melatonin: String = "Melatonin"

  /// Получение названия по ключу
  func getName(for key: VitaminKey) -> String {
    switch key {
    case .vitaminB: return vitaminB
    case .magnesium: return magnesium
    case .iron: return iron
    case .melatonin: return melatonin
    }
  }

  /// Установка названия по ключу
  mutating func setName(for key: VitaminKey, name: String) {
    switch key {
    case .vitaminB: vitaminB = name
    case .magnesium: magnesium = name
    case .iron: iron = name
    case .melatonin: melatonin = name
    }
  }
}

enum VitaminKey: CaseIterable {
  case vitaminB, magnesium, iron, melatonin

  var defaultName: String {
    switch self {
    case .vitaminB: return "Vitamin B"
    case .magnesium: return "Magnesium"
    case .iron: return "Iron"
    case .melatonin: return "Melatonin"
    }
  }
}
