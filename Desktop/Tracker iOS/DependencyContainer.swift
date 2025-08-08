import Foundation
import Combine

/// Контейнер для управления зависимостями приложения
class DependencyContainer {
    static let shared = DependencyContainer()
    
    private var services: [String: Any] = [:]
    
    private init() {}
    
    /// Регистрация сервиса в контейнере
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory
    }
    
    /// Получение сервиса из контейнера
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = services[key] as? () -> T else {
            fatalError("Service \(key) not registered")
        }
        return factory()
    }
}

// MARK: - Service Registration
extension DependencyContainer {
    func registerServices() {
        // Data Layer
        register(PersistenceController.self) {
            PersistenceController.shared
        }
        
        register(TrackerRepositoryProtocol.self) {
            CoreDataTrackerRepository(
                persistenceController: self.resolve(PersistenceController.self)
            )
        }
        
        register(ModuleRepositoryProtocol.self) {
            CoreDataModuleRepository(
                persistenceController: self.resolve(PersistenceController.self)
            )
        }
        
        // Business Layer
        register(DataServiceProtocol.self) {
            DataService(
                repository: self.resolve(TrackerRepositoryProtocol.self)
            )
        }
        
        register(ModuleFactory.self) {
            ModuleFactory(
                registry: self.resolve(ModuleRegistry.self)
            )
        }
        
        register(ModuleRegistry.self) {
            let registry = ModuleRegistry()
            registry.registerDefaultModules()
            return registry
        }
        
        register(TemplateServiceProtocol.self) {
            TemplateService(
                moduleFactory: self.resolve(ModuleFactory.self)
            )
        }
        
        register(NotificationServiceProtocol.self) {
            NotificationService()
        }
        
        register(ExportServiceProtocol.self) {
            ExportService()
        }
        
        register(ThemeServiceProtocol.self) {
            ThemeService()
        }
        
        register(ValidationServiceProtocol.self) {
            ValidationService()
        }
        
        // Authentication & Push Notifications
        register(AuthenticationServiceProtocol.self) {
            AuthenticationService()
        }
        
        register(PushNotificationServiceProtocol.self) {
            PushNotificationService()
        }
        
        // Presentation Layer
        register(AppRouter.self) {
            AppRouter()
        }
        
        register(AppState.self) {
            AppState(
                dataService: self.resolve(DataServiceProtocol.self)
            )
        }
    }
} 