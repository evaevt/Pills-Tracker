import Combine
import Foundation
import SwiftUI

// MARK: - Module Registry
class ModuleRegistry {
  private var modules: [ModuleType: TrackerModuleProtocol.Type] = [:]

  func register<T: TrackerModuleProtocol>(_ moduleType: T.Type, for type: ModuleType) {
    modules[type] = moduleType
  }

  func getModule(for type: ModuleType) -> TrackerModuleProtocol.Type? {
    modules[type]
  }

  func getAllModules() -> [ModuleType: TrackerModuleProtocol.Type] {
    modules
  }

  func registerDefaultModules() {
    // Пока пустая заглушка
    // Здесь будут регистрироваться все модули
  }
}

// MARK: - Module Factory
class ModuleFactory {
  private let registry: ModuleRegistry

  init(registry: ModuleRegistry) {
    self.registry = registry
  }

  func createModule(type: ModuleType, settings: ModuleSettings) -> TrackerModuleProtocol? {
    // Временная заглушка
    return nil
  }
}

// MARK: - Template Service
class TemplateService: TemplateServiceProtocol {
  private let moduleFactory: ModuleFactory

  init(moduleFactory: ModuleFactory) {
    self.moduleFactory = moduleFactory
  }

  func getAllTemplates() -> AnyPublisher<[TrackerTemplate], Error> {
    Just([])
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func getTemplate(id: UUID) -> AnyPublisher<TrackerTemplate?, Error> {
    Just(nil)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func getTemplatesByCategory(_ category: TemplateCategory) -> AnyPublisher<
    [TrackerTemplate], Error
  > {
    Just([])
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func getPopularTemplates() -> AnyPublisher<[TrackerTemplate], Error> {
    Just([])
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func createTrackerFromTemplate(_ template: TrackerTemplate) -> PersonalTracker {
    template.createTracker()
  }
}

// MARK: - Other Services
class NotificationService: NotificationServiceProtocol {
  func requestPermission() -> AnyPublisher<Bool, Error> {
    Just(true)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func scheduleNotification(_ content: NotificationContent, at date: Date) -> AnyPublisher<
    Void, Error
  > {
    Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func cancelNotification(id: String) -> AnyPublisher<Void, Error> {
    Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func getPendingNotifications() -> AnyPublisher<[NotificationContent], Error> {
    Just([])
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}

class ExportService: ExportServiceProtocol {
  func exportTracker(_ tracker: PersonalTracker, format: ExportFormat) -> AnyPublisher<Data, Error>
  {
    Just(Data())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func exportModule(_ module: TrackerModule, format: ExportFormat) -> AnyPublisher<Data, Error> {
    Just(Data())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func exportStatistics(_ statistics: TrackerStatistics, format: ExportFormat) -> AnyPublisher<
    Data, Error
  > {
    Just(Data())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}

class ThemeService: ThemeServiceProtocol {
  func getAllThemes() -> [TrackerTheme] {
    [.default, .dark, .nature, .ocean]
  }

  func getTheme(name: String) -> TrackerTheme? {
    getAllThemes().first { $0.name == name }
  }

  func saveCustomTheme(_ theme: TrackerTheme) -> AnyPublisher<Void, Error> {
    Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  func deleteCustomTheme(name: String) -> AnyPublisher<Void, Error> {
    Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}

class ValidationService: ValidationServiceProtocol {
  func validateTracker(_ tracker: PersonalTracker) -> ValidationResult {
    if tracker.name.isEmpty {
      return .invalid("Название трекера не может быть пустым")
    }

    if tracker.modules.isEmpty {
      return .invalid("Трекер должен содержать хотя бы один модуль")
    }

    return .valid
  }

  func validateModule(_ module: TrackerModule) -> ValidationResult {
    return .valid
  }

  func validateSettings(_ settings: ModuleSettings, for type: ModuleType) -> ValidationResult {
    return .valid
  }
}
