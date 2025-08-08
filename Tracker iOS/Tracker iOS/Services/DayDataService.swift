import Combine
import Foundation

/// Сервис для управления данными по датам
@MainActor
class DayDataService: ObservableObject {
  @Published private var dayDataStorage: [String: DayData] = [:]
  @Published var currentDate: Date = Date()
  @Published var currentDayData: DayData = DayData(date: Date())
  @Published var vitaminNames: VitaminNames = VitaminNames()

  private let userDefaults = UserDefaults.standard
  private let storageKey = "dayDataStorage"
  private let vitaminNamesKey = "vitaminNames"

  init() {
    loadFromStorage()
    loadVitaminNames()
    updateCurrentDayData()
  }

  /// Обновление текущих данных дня
  private func updateCurrentDayData() {
    let dateKey = dateKey(for: currentDate)
    if let existingData = dayDataStorage[dateKey] {
      currentDayData = existingData
    } else {
      currentDayData = DayData(date: currentDate)
    }
  }

  /// Переключение на конкретную дату
  func selectDate(_ date: Date) {
    // Сохраняем текущие данные перед переключением
    saveDayData(currentDayData)

    // Переключаемся на новую дату
    currentDate = Calendar.current.startOfDay(for: date)
    updateCurrentDayData()
  }

  /// Сохранение данных дня
  func saveDayData(_ dayData: DayData) {
    let dateKey = dateKey(for: dayData.date)
    dayDataStorage[dateKey] = dayData
    saveToStorage()
  }

  /// Обновление текущих данных дня
  func updateCurrentDayData(
    waterCount: Int? = nil,
    selectedMood: MoodType? = nil,
    noteText: String? = nil,
    vitamins: VitaminState? = nil,
    isNoteSaved: Bool? = nil
  ) {
    if let waterCount = waterCount {
      currentDayData.waterCount = waterCount
    }
    if let selectedMood = selectedMood {
      currentDayData.selectedMood = selectedMood
    }
    if let noteText = noteText {
      currentDayData.noteText = noteText
    }
    if let vitamins = vitamins {
      currentDayData.vitamins = vitamins
    }
    if let isNoteSaved = isNoteSaved {
      currentDayData.isNoteSaved = isNoteSaved
    }

    // Автоматически сохраняем изменения
    saveDayData(currentDayData)
  }

  /// Получение данных для конкретной даты
  func getDayData(for date: Date) -> DayData {
    let dateKey = dateKey(for: date)
    return dayDataStorage[dateKey] ?? DayData(date: date)
  }

  /// Получение всех дат с данными
  func getDatesWithData() -> [Date] {
    return dayDataStorage.values.compactMap { $0.hasData ? $0.date : nil }.sorted()
  }

  /// Обновление названий витаминов
  func updateVitaminNames(_ newNames: VitaminNames) {
    vitaminNames = newNames
    saveVitaminNames()
  }

  // MARK: - Private Methods

  private func dateKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  private func saveToStorage() {
    if let encoded = try? JSONEncoder().encode(dayDataStorage) {
      userDefaults.set(encoded, forKey: storageKey)
    }
  }

  private func loadFromStorage() {
    guard let data = userDefaults.data(forKey: storageKey),
      let decoded = try? JSONDecoder().decode([String: DayData].self, from: data)
    else {
      return
    }
    dayDataStorage = decoded
  }

  private func saveVitaminNames() {
    if let encoded = try? JSONEncoder().encode(vitaminNames) {
      userDefaults.set(encoded, forKey: vitaminNamesKey)
    }
  }

  private func loadVitaminNames() {
    guard let data = userDefaults.data(forKey: vitaminNamesKey),
      let decoded = try? JSONDecoder().decode(VitaminNames.self, from: data)
    else {
      return
    }
    vitaminNames = decoded
  }
}
