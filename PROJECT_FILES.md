# Список файлов проекта Tracker iOS

## 📁 Структура проекта

```
Tracker iOS/
├── README.md                           # Основная документация
├── ARCHITECTURE.md                     # Архитектура приложения
├── XCODE_SETUP.md                      # Инструкция по созданию Xcode проекта
├── PROJECT_FILES.md                    # Этот файл
├── TrackerApp.swift                    # Главный файл приложения
├── ContentView.swift                   # Корневой view
├── DependencyContainer.swift           # DI контейнер
├── Models/
│   ├── TrackerModule.swift            # Модели модулей
│   ├── TrackerConfiguration.swift     # Модели трекеров
│   ├── ModuleTypes.swift              # Протоколы и типы
│   └── CoreData/
│       └── PersistenceController.swift # Core Data контроллер
├── Views/
│   ├── MainScreen/
│   │   ├── MainScreenView.swift       # Главный экран
│   │   └── TrackerCardView.swift      # Карточка трекера
│   ├── Constructor/
│   │   ├── ConstructorView.swift      # Конструктор трекеров
│   │   └── ModuleLibraryView.swift    # Библиотека модулей
│   ├── ActiveTracker/
│   │   └── ActiveTrackerView.swift    # Активный трекер
│   ├── Settings/
│   │   └── ModuleSettingsView.swift   # Настройки модуля
│   └── Analytics/
│       └── AnalyticsView.swift        # Аналитика
├── Services/
│   ├── DataService.swift              # Сервис данных
│   └── ModuleFactory.swift            # Фабрика модулей и сервисы
├── ViewModels/                        # (пустая папка для будущих VM)
├── Modules/                           # (пустая папка для модулей)
├── Utils/                             # (пустая папка для утилит)
├── Resources/                         # (пустая папка для ресурсов)
└── Tests/                             # (пустая папка для тестов)
```

## 📋 Описание файлов

### Документация
- **README.md** - Основная документация проекта с концепцией и инструкциями
- **ARCHITECTURE.md** - Детальное описание архитектуры приложения
- **XCODE_SETUP.md** - Пошаговая инструкция по созданию Xcode проекта
- **PROJECT_FILES.md** - Этот файл со списком всех файлов

### Основные файлы приложения
- **TrackerApp.swift** - Точка входа в приложение, настройка DI
- **ContentView.swift** - Корневой view с навигацией
- **DependencyContainer.swift** - Контейнер зависимостей

### Модели данных
- **TrackerModule.swift** - Типы модулей, настройки, значения
- **TrackerConfiguration.swift** - Персональные трекеры, темы, шаблоны
- **ModuleTypes.swift** - Протоколы, роутер, состояние приложения
- **PersistenceController.swift** - Core Data контроллер и репозитории

### Экраны приложения
- **MainScreenView.swift** - Главный экран со списком трекеров
- **TrackerCardView.swift** - Компонент карточки трекера
- **ConstructorView.swift** - Конструктор для создания трекеров
- **ModuleLibraryView.swift** - Библиотека модулей для конструктора
- **ActiveTrackerView.swift** - Рабочий интерфейс трекера
- **ModuleSettingsView.swift** - Настройки отдельного модуля
- **AnalyticsView.swift** - Аналитика и статистика

### Сервисы
- **DataService.swift** - Сервис для работы с данными
- **ModuleFactory.swift** - Фабрика модулей и другие сервисы

## 🎯 Состояние проекта

### ✅ Готово
- [x] Полная документация проекта
- [x] Архитектура MVVM + Repository + DI
- [x] Модели данных для всех сущностей
- [x] Базовые экраны приложения
- [x] Навигация между экранами
- [x] Заглушки для всех сервисов
- [x] Инструкция по созданию Xcode проекта

### 🔄 В процессе
- [ ] Создание Xcode проекта
- [ ] Первый запуск приложения

### 📋 Следующие шаги
1. Создать Xcode проект по инструкции
2. Добавить все файлы в проект
3. Исправить ошибки компиляции
4. Запустить приложение
5. Реализовать настоящие модули трекеров

## 🚀 Как запустить

1. Следуйте инструкции в `XCODE_SETUP.md`
2. Создайте новый iOS проект в Xcode
3. Добавьте все файлы в соответствующие группы
4. Запустите симулятор

## 📱 Что получится

После запуска вы увидите:
- Главный экран с примерами трекеров
- Рабочий конструктор с библиотекой модулей
- Навигацию между всеми экранами
- Базовый функционал создания трекеров

## 🎨 Особенности дизайна

- Использует системные цвета iOS
- SF Symbols для всех иконок
- Адаптивный дизайн для разных устройств
- Современный SwiftUI интерфейс
- Следует Human Interface Guidelines

## 🔧 Архитектурные решения

- **MVVM** для разделения логики и UI
- **Repository Pattern** для абстракции данных
- **Dependency Injection** для тестируемости
- **Combine** для реактивного программирования
- **Protocol-Oriented Programming** для расширяемости

---

**Проект готов к созданию в Xcode! 🎉** 