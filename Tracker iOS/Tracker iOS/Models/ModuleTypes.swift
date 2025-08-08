import Combine
import Foundation
import SwiftUI

// MARK: - Module Protocols
//тест синхронизации

/// Основной протокол для всех модулей трекеров
protocol TrackerModuleProtocol: AnyObject {
  var id: UUID { get }
  var type: ModuleType { get }
  var title: String { get }
  var icon: String { get }
  var defaultSettings: ModuleSettings { get }

  func createView(settings: ModuleSettings) -> AnyView
  func validateSettings(_ settings: ModuleSettings) -> ValidationResult
  func processValue(_ value: ModuleValue, settings: ModuleSettings) -> ModuleValue
}

/// Протокол для модулей с возможностью анимации
protocol AnimatableModule: TrackerModuleProtocol {
  func animateValueChange(from oldValue: ModuleValue, to newValue: ModuleValue) -> AnyTransition
}

/// Протокол для модулей с настраиваемым размером
protocol ResizableModule: TrackerModuleProtocol {
  var minSize: CGSize { get }
  var maxSize: CGSize { get }
  var preferredSize: CGSize { get }
}

/// Протокол для модулей с возможностью экспорта данных
protocol ExportableModule: TrackerModuleProtocol {
  func exportData(format: ExportFormat) -> Data?
}

/// Протокол для модулей с уведомлениями
protocol NotifiableModule: TrackerModuleProtocol {
  func shouldSendNotification(for value: ModuleValue, settings: ModuleSettings) -> Bool
  func notificationContent(for value: ModuleValue, settings: ModuleSettings) -> NotificationContent?
}

// MARK: - Service Protocols

/// Протокол для сервиса данных
protocol DataServiceProtocol {
  func getAllTrackers() -> AnyPublisher<[PersonalTracker], Error>
  func getTracker(id: UUID) -> AnyPublisher<PersonalTracker?, Error>
  func saveTracker(_ tracker: PersonalTracker) -> AnyPublisher<Void, Error>
  func deleteTracker(id: UUID) -> AnyPublisher<Void, Error>
  func updateTrackerModule(_ trackerId: UUID, module: TrackerModule) -> AnyPublisher<Void, Error>
}

/// Протокол для сервиса шаблонов
protocol TemplateServiceProtocol {
  func getAllTemplates() -> AnyPublisher<[TrackerTemplate], Error>
  func getTemplate(id: UUID) -> AnyPublisher<TrackerTemplate?, Error>
  func getTemplatesByCategory(_ category: TemplateCategory) -> AnyPublisher<
    [TrackerTemplate], Error
  >
  func getPopularTemplates() -> AnyPublisher<[TrackerTemplate], Error>
  func createTrackerFromTemplate(_ template: TrackerTemplate) -> PersonalTracker
}

/// Протокол для сервиса уведомлений
protocol NotificationServiceProtocol {
  func requestPermission() -> AnyPublisher<Bool, Error>
  func scheduleNotification(_ content: NotificationContent, at date: Date) -> AnyPublisher<
    Void, Error
  >
  func cancelNotification(id: String) -> AnyPublisher<Void, Error>
  func getPendingNotifications() -> AnyPublisher<[NotificationContent], Error>
}

/// Протокол для сервиса экспорта
protocol ExportServiceProtocol {
  func exportTracker(_ tracker: PersonalTracker, format: ExportFormat) -> AnyPublisher<Data, Error>
  func exportModule(_ module: TrackerModule, format: ExportFormat) -> AnyPublisher<Data, Error>
  func exportStatistics(_ statistics: TrackerStatistics, format: ExportFormat) -> AnyPublisher<
    Data, Error
  >
}

/// Протокол для сервиса тем
protocol ThemeServiceProtocol {
  func getAllThemes() -> [TrackerTheme]
  func getTheme(name: String) -> TrackerTheme?
  func saveCustomTheme(_ theme: TrackerTheme) -> AnyPublisher<Void, Error>
  func deleteCustomTheme(name: String) -> AnyPublisher<Void, Error>
}

/// Протокол для сервиса валидации
protocol ValidationServiceProtocol {
  func validateTracker(_ tracker: PersonalTracker) -> ValidationResult
  func validateModule(_ module: TrackerModule) -> ValidationResult
  func validateSettings(_ settings: ModuleSettings, for type: ModuleType) -> ValidationResult
}

// MARK: - Repository Protocols

/// Протокол для репозитория трекеров
protocol TrackerRepositoryProtocol {
  func fetchAll() -> AnyPublisher<[TrackerEntity], Error>
  func fetch(id: UUID) -> AnyPublisher<TrackerEntity?, Error>
  func save(_ tracker: TrackerEntity) -> AnyPublisher<Void, Error>
  func delete(id: UUID) -> AnyPublisher<Void, Error>
  func update(_ tracker: TrackerEntity) -> AnyPublisher<Void, Error>
}

/// Протокол для репозитория модулей
protocol ModuleRepositoryProtocol {
  func fetchModules(for trackerId: UUID) -> AnyPublisher<[ModuleEntity], Error>
  func saveModule(_ module: ModuleEntity) -> AnyPublisher<Void, Error>
  func deleteModule(id: UUID) -> AnyPublisher<Void, Error>
  func updateModule(_ module: ModuleEntity) -> AnyPublisher<Void, Error>
}

// MARK: - Supporting Types

/// Формат экспорта данных
enum ExportFormat: String, CaseIterable {
  case json = "json"
  case csv = "csv"
  case pdf = "pdf"
  case xlsx = "xlsx"

  var displayName: String {
    switch self {
    case .json: return "JSON"
    case .csv: return "CSV"
    case .pdf: return "PDF"
    case .xlsx: return "Excel"
    }
  }

  var fileExtension: String {
    return rawValue
  }

  var mimeType: String {
    switch self {
    case .json: return "application/json"
    case .csv: return "text/csv"
    case .pdf: return "application/pdf"
    case .xlsx: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
  }
}

/// Содержимое уведомления
struct NotificationContent: Codable, Identifiable {
  let id: String
  let title: String
  let body: String
  let badge: Int?
  let sound: String?
  let categoryIdentifier: String?
  let userInfo: [String: String]?
  let scheduledDate: Date

  init(
    id: String = UUID().uuidString,
    title: String,
    body: String,
    badge: Int? = nil,
    sound: String? = nil,
    categoryIdentifier: String? = nil,
    userInfo: [String: String]? = nil,
    scheduledDate: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.body = body
    self.badge = badge
    self.sound = sound
    self.categoryIdentifier = categoryIdentifier
    self.userInfo = userInfo
    self.scheduledDate = scheduledDate
  }
}

// MARK: - App Router

/// Роутер для навигации между экранами
class AppRouter: ObservableObject {
  @Published var currentScreen: Screen = .main
  @Published var navigationPath = NavigationPath()

  enum Screen: Hashable {
    case main
    case constructor
    case activeTracker(PersonalTracker)
    case moduleSettings(TrackerModule)
    case analytics(PersonalTracker)
    case templates
    case settings
    case about

    var title: String {
      switch self {
      case .main: return "Мои трекеры"
      case .constructor: return "Конструктор"
      case .activeTracker: return "Активный трекер"
      case .moduleSettings: return "Настройки модуля"
      case .analytics: return "Аналитика"
      case .templates: return "Шаблоны"
      case .settings: return "Настройки"
      case .about: return "О приложении"
      }
    }
  }

  func navigate(to screen: Screen) {
    currentScreen = screen
    navigationPath.append(screen)
  }

  func goBack() {
    guard !navigationPath.isEmpty else { return }
    navigationPath.removeLast()
  }

  func goToRoot() {
    navigationPath = NavigationPath()
    currentScreen = .main
  }
}

// MARK: - App State

/// Глобальное состояние приложения
class AppState: ObservableObject {
  @Published var currentUser: User?
  @Published var selectedTracker: PersonalTracker?
  @Published var isOffline = false
  @Published var theme: TrackerTheme = .default
  @Published var isLoading = false
  @Published var error: AppError?

  private let dataService: DataServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  init(dataService: DataServiceProtocol) {
    self.dataService = dataService
    setupBindings()
  }

  private func setupBindings() {
    // Мониторинг сетевого соединения
    NotificationCenter.default
      .publisher(for: .NSManagedObjectContextDidSave)
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  func selectTracker(_ tracker: PersonalTracker) {
    selectedTracker = tracker
  }

  func clearSelection() {
    selectedTracker = nil
  }

  func updateTheme(_ theme: TrackerTheme) {
    self.theme = theme
  }

  func showError(_ error: AppError) {
    self.error = error
  }

  func clearError() {
    self.error = nil
  }
}

// MARK: - Supporting Models

/// Пользователь приложения
struct User: Codable, Identifiable {
  let id: UUID
  let name: String
  let email: String?
  let preferences: ModuleUserPreferences
  let createdAt: Date
  let lastActiveAt: Date

  init(
    id: UUID = UUID(),
    name: String,
    email: String? = nil,
    preferences: ModuleUserPreferences = ModuleUserPreferences(),
    createdAt: Date = Date(),
    lastActiveAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.preferences = preferences
    self.createdAt = createdAt
    self.lastActiveAt = lastActiveAt
  }
}

/// Настройки пользователя
struct ModuleUserPreferences: Codable {
  var notificationsEnabled: Bool
  var defaultTheme: String
  var preferredLanguage: String
  var dataExportFormat: String
  var autoBackup: Bool
  var privacyMode: Bool

  init(
    notificationsEnabled: Bool = true,
    defaultTheme: String = "Default",
    preferredLanguage: String = "ru",
    dataExportFormat: String = "json",
    autoBackup: Bool = true,
    privacyMode: Bool = false
  ) {
    self.notificationsEnabled = notificationsEnabled
    self.defaultTheme = defaultTheme
    self.preferredLanguage = preferredLanguage
    self.dataExportFormat = dataExportFormat
    self.autoBackup = autoBackup
    self.privacyMode = privacyMode
  }
}

// MARK: - Data Entry Models

/// Запись настроения
struct MoodEntry: Codable, Identifiable {
  let id = UUID()
  let date: Date
  let moodType: MoodType
  let note: String?

  init(date: Date, moodType: MoodType, note: String? = nil) {
    self.date = date
    self.moodType = moodType
    self.note = note
  }
}

/// Запись воды
struct WaterEntry: Codable, Identifiable {
  let id = UUID()
  let date: Date
  let count: Int

  init(date: Date, count: Int) {
    self.date = date
    self.count = count
  }
}

/// Запись витаминов
struct VitaminEntry: Codable, Identifiable {
  let id = UUID()
  let date: Date
  let vitamins: VitaminState

  init(date: Date, vitamins: VitaminState) {
    self.date = date
    self.vitamins = vitamins
  }
}

/// Ошибки приложения
enum AppError: Error, LocalizedError {
  case dataLoadingFailed
  case savingFailed
  case networkUnavailable
  case invalidData
  case permissionDenied
  case exportFailed
  case validationFailed(String)
  case unknown(Error)

  var errorDescription: String? {
    switch self {
    case .dataLoadingFailed:
      return "Не удалось загрузить данные"
    case .savingFailed:
      return "Не удалось сохранить данные"
    case .networkUnavailable:
      return "Нет подключения к интернету"
    case .invalidData:
      return "Неверный формат данных"
    case .permissionDenied:
      return "Доступ запрещен"
    case .exportFailed:
      return "Не удалось экспортировать данные"
    case .validationFailed(let message):
      return "Ошибка валидации: \(message)"
    case .unknown(let error):
      return "Неизвестная ошибка: \(error.localizedDescription)"
    }
  }
}
