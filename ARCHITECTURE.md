# Архитектура Tracker iOS

## 🏗️ Обзор архитектуры

Tracker iOS использует современную архитектуру, основанную на принципах **MVVM**, **Repository Pattern** и **Dependency Injection** для создания масштабируемого и тестируемого приложения.

## 📊 Диаграмма архитектуры

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                   │
├─────────────────────────────────────────────────────────────┤
│  SwiftUI Views          │  ViewModels        │  Navigation  │
│  ├── MainScreenView     │  ├── MainViewModel │  ├── Router  │
│  ├── ConstructorView    │  ├── ConstructorVM │  └── Coordinator│
│  ├── ActiveTrackerView  │  └── TrackerVM     │              │
│  └── ModuleViews        │                    │              │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                        Business Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Services               │  Module System     │  Validation  │
│  ├── DataService        │  ├── ModuleFactory │  ├── Validator│
│  ├── TemplateService    │  ├── ModuleRegistry│  └── Rules   │
│  ├── NotificationService│  └── ModuleProtocol│              │
│  └── ExportService      │                    │              │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Repository Pattern     │  Core Data         │  Cache       │
│  ├── TrackerRepository  │  ├── DataModel     │  ├── Memory  │
│  ├── ModuleRepository   │  ├── Persistence   │  ├── Disk    │
│  └── TemplateRepository │  └── Migration     │  └── Manager │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Архитектурные принципы

### 1. MVVM (Model-View-ViewModel)
- **View**: SwiftUI компоненты для отображения UI
- **ViewModel**: Бизнес-логика и состояние экрана
- **Model**: Структуры данных и бизнес-объекты

### 2. Repository Pattern
- Абстракция доступа к данным
- Единый интерфейс для различных источников данных
- Легкое тестирование с моками

### 3. Dependency Injection
- Инверсия зависимостей через DI контейнер
- Слабая связанность компонентов
- Простота модульного тестирования

### 4. Protocol-Oriented Programming
- Гибкая система модулей через протоколы
- Возможность легкого расширения функциональности
- Полиморфизм для различных типов модулей

## 🏛️ Слои архитектуры

### Presentation Layer (UI)

#### Views
```swift
// Главный экран со списком трекеров
struct MainScreenView: View {
    @StateObject private var viewModel: MainScreenViewModel
    
    var body: some View {
        NavigationView {
            // UI компоненты
        }
    }
}

// Конструктор трекеров с drag & drop
struct ConstructorView: View {
    @StateObject private var viewModel: ConstructorViewModel
    @State private var draggedModule: TrackerModule?
    
    var body: some View {
        // Drag & Drop интерфейс
    }
}
```

#### ViewModels
```swift
// ViewModel для главного экрана
@MainActor
class MainScreenViewModel: ObservableObject {
    @Published var trackers: [PersonalTracker] = []
    @Published var isLoading = false
    
    private let dataService: DataServiceProtocol
    private let templateService: TemplateServiceProtocol
    
    init(dataService: DataServiceProtocol, templateService: TemplateServiceProtocol) {
        self.dataService = dataService
        self.templateService = templateService
    }
    
    func loadTrackers() {
        // Загрузка трекеров через сервис
    }
}
```

### Business Layer (Логика)

#### Services
```swift
// Сервис для работы с данными трекеров
protocol DataServiceProtocol {
    func getAllTrackers() -> AnyPublisher<[PersonalTracker], Error>
    func saveTracker(_ tracker: PersonalTracker) -> AnyPublisher<Void, Error>
    func deleteTracker(id: UUID) -> AnyPublisher<Void, Error>
}

class DataService: DataServiceProtocol {
    private let repository: TrackerRepositoryProtocol
    
    init(repository: TrackerRepositoryProtocol) {
        self.repository = repository
    }
    
    func getAllTrackers() -> AnyPublisher<[PersonalTracker], Error> {
        repository.fetchAll()
            .map { entities in
                entities.map { $0.toModel() }
            }
            .eraseToAnyPublisher()
    }
}
```

#### Module System
```swift
// Протокол для всех модулей трекеров
protocol TrackerModuleProtocol {
    var id: UUID { get }
    var type: ModuleType { get }
    var title: String { get }
    var icon: String { get }
    var defaultSettings: ModuleSettings { get }
    
    func createView(settings: ModuleSettings) -> AnyView
    func validateSettings(_ settings: ModuleSettings) -> ValidationResult
}

// Фабрика для создания модулей
class ModuleFactory {
    private let registry: ModuleRegistry
    
    func createModule(type: ModuleType, settings: ModuleSettings) -> TrackerModuleProtocol? {
        registry.getModule(for: type)?.init(settings: settings)
    }
}
```

### Data Layer (Данные)

#### Repository Pattern
```swift
// Протокол репозитория для трекеров
protocol TrackerRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[TrackerEntity], Error>
    func save(_ tracker: TrackerEntity) -> AnyPublisher<Void, Error>
    func delete(id: UUID) -> AnyPublisher<Void, Error>
}

// Реализация репозитория с Core Data
class CoreDataTrackerRepository: TrackerRepositoryProtocol {
    private let persistenceController: PersistenceController
    
    func fetchAll() -> AnyPublisher<[TrackerEntity], Error> {
        Future { promise in
            let context = self.persistenceController.container.viewContext
            let request: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
            
            do {
                let entities = try context.fetch(request)
                promise(.success(entities))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
```

## 🔧 Dependency Injection

### DI Container
```swift
// Контейнер зависимостей
class DependencyContainer {
    static let shared = DependencyContainer()
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = services[key] as? () -> T else {
            fatalError("Service \(key) not registered")
        }
        return factory()
    }
}

// Регистрация сервисов
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
        
        // Business Layer
        register(DataServiceProtocol.self) {
            DataService(
                repository: self.resolve(TrackerRepositoryProtocol.self)
            )
        }
        
        register(ModuleFactory.self) {
            ModuleFactory()
        }
    }
}
```

## 🧩 Модульная система

### Архитектура модулей
```swift
// Базовый класс для всех модулей
class BaseTrackerModule: TrackerModuleProtocol {
    let id = UUID()
    let type: ModuleType
    let title: String
    let icon: String
    let defaultSettings: ModuleSettings
    
    init(type: ModuleType, title: String, icon: String, defaultSettings: ModuleSettings) {
        self.type = type
        self.title = title
        self.icon = icon
        self.defaultSettings = defaultSettings
    }
    
    func createView(settings: ModuleSettings) -> AnyView {
        fatalError("Must be implemented by subclass")
    }
    
    func validateSettings(_ settings: ModuleSettings) -> ValidationResult {
        // Базовая валидация
        return .valid
    }
}

// Конкретная реализация модуля
class WaterCounterModule: BaseTrackerModule {
    init() {
        super.init(
            type: .counter,
            title: "Счетчик воды",
            icon: "drop.fill",
            defaultSettings: ModuleSettings(
                goal: 8,
                unit: "стаканов",
                color: .blue
            )
        )
    }
    
    override func createView(settings: ModuleSettings) -> AnyView {
        AnyView(WaterCounterView(settings: settings))
    }
}
```

### Регистрация модулей
```swift
// Реестр доступных модулей
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
}

// Регистрация всех модулей
extension ModuleRegistry {
    func registerDefaultModules() {
        // Счетчики
        register(WaterCounterModule.self, for: .waterCounter)
        register(StepCounterModule.self, for: .stepCounter)
        register(CalorieCounterModule.self, for: .calorieCounter)
        
        // Чекбоксы
        register(SimpleCheckboxModule.self, for: .simpleCheckbox)
        register(RatingScaleModule.self, for: .ratingScale)
        
        // Таймеры
        register(PomodoroTimerModule.self, for: .pomodoroTimer)
        register(ActivityTimerModule.self, for: .activityTimer)
        
        // Визуализация
        register(ProgressBarModule.self, for: .progressBar)
        register(CircularProgressModule.self, for: .circularProgress)
    }
}
```

## 📱 Навигация и состояние

### Router Pattern
```swift
// Роутер для навигации между экранами
class AppRouter: ObservableObject {
    @Published var currentScreen: Screen = .main
    @Published var navigationPath = NavigationPath()
    
    enum Screen {
        case main
        case constructor
        case activeTracker(PersonalTracker)
        case moduleSettings(TrackerModule)
        case analytics(PersonalTracker)
    }
    
    func navigate(to screen: Screen) {
        currentScreen = screen
        navigationPath.append(screen)
    }
    
    func goBack() {
        navigationPath.removeLast()
    }
}
```

### State Management
```swift
// Глобальное состояние приложения
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var selectedTracker: PersonalTracker?
    @Published var isOffline = false
    @Published var theme: AppTheme = .system
    
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
}
```

## 🔄 Реактивное программирование с Combine

### Publishers и Subscribers
```swift
// ViewModel с Combine
class ConstructorViewModel: ObservableObject {
    @Published var availableModules: [TrackerModuleProtocol] = []
    @Published var selectedModules: [TrackerModule] = []
    @Published var trackerName = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let moduleFactory: ModuleFactory
    
    init(moduleFactory: ModuleFactory) {
        self.moduleFactory = moduleFactory
        setupBindings()
    }
    
    private func setupBindings() {
        // Автосохранение при изменении названия
        $trackerName
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] name in
                self?.saveDraft(name: name)
            }
            .store(in: &cancellables)
        
        // Валидация при изменении модулей
        $selectedModules
            .map { modules in
                modules.allSatisfy { $0.isValid }
            }
            .assign(to: \.canSave, on: self)
            .store(in: &cancellables)
    }
}
```

## 🧪 Тестирование архитектуры

### Unit тесты
```swift
// Тест ViewModel
class MainScreenViewModelTests: XCTestCase {
    var viewModel: MainScreenViewModel!
    var mockDataService: MockDataService!
    var mockTemplateService: MockTemplateService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockDataService()
        mockTemplateService = MockTemplateService()
        viewModel = MainScreenViewModel(
            dataService: mockDataService,
            templateService: mockTemplateService
        )
    }
    
    func testLoadTrackers() {
        // Given
        let expectedTrackers = [PersonalTracker.mock()]
        mockDataService.trackersToReturn = expectedTrackers
        
        // When
        viewModel.loadTrackers()
        
        // Then
        XCTAssertEqual(viewModel.trackers, expectedTrackers)
    }
}
```

### Integration тесты
```swift
// Тест интеграции между слоями
class TrackerIntegrationTests: XCTestCase {
    var container: DependencyContainer!
    var dataService: DataServiceProtocol!
    
    override func setUp() {
        super.setUp()
        container = DependencyContainer()
        container.registerTestServices()
        dataService = container.resolve(DataServiceProtocol.self)
    }
    
    func testCreateAndSaveTracker() {
        // Тест полного цикла создания трекера
    }
}
```

## 🚀 Производительность и оптимизация

### Lazy Loading
```swift
// Ленивая загрузка модулей
class ModuleLoader {
    private var loadedModules: [ModuleType: TrackerModuleProtocol] = [:]
    
    func loadModule(_ type: ModuleType) -> TrackerModuleProtocol? {
        if let cached = loadedModules[type] {
            return cached
        }
        
        let module = ModuleFactory.createModule(type: type)
        loadedModules[type] = module
        return module
    }
}
```

### Memory Management
```swift
// Управление памятью для больших данных
class DataCache {
    private let cache = NSCache<NSString, AnyObject>()
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func store<T: AnyObject>(_ object: T, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    func retrieve<T: AnyObject>(_ type: T.Type, forKey key: String) -> T? {
        cache.object(forKey: key as NSString) as? T
    }
}
```

## 📈 Мониторинг и аналитика

### Performance Monitoring
```swift
// Мониторинг производительности
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    func measureTime<T>(operation: String, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("⏱️ \(operation) took \(timeElapsed) seconds")
        return result
    }
}
```

---

Эта архитектура обеспечивает:
- **Масштабируемость** - легко добавлять новые модули и функции
- **Тестируемость** - каждый компонент может быть протестирован изолированно
- **Поддерживаемость** - четкое разделение ответственности
- **Производительность** - оптимизированная работа с данными и UI 