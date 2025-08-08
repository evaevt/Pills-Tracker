# Создание Xcode проекта для Tracker iOS

## 🎯 Сейчас можно запускать Xcode!

Все файлы созданы и готовы к работе. Теперь нужно создать Xcode проект и добавить файлы.

## 📋 Пошаговая инструкция

### 1. Создание нового проекта в Xcode

1. Откройте Xcode
2. Выберите "Create a new Xcode project"
3. Выберите "iOS" → "App"
4. Заполните настройки проекта:
   - **Product Name**: `Tracker iOS`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Use Core Data**: ✅ (включить)
   - **Include Tests**: ✅ (включить)
5. Сохраните проект в папку `Tracker iOS` (заменить существующие файлы)

### 2. Удаление стандартных файлов

После создания проекта удалите эти файлы (они будут заменены нашими):
- `ContentView.swift` (стандартный)
- `Persistence.swift` (стандартный)
- `TrackerModel.xcdatamodeld` (если создался)

### 3. Добавление файлов в проект

#### Создайте группы (папки) в Xcode:
1. Правый клик на проект → "New Group"
2. Создайте следующие группы:
   - Models
   - Views
   - ViewModels
   - Modules
   - Services
   - Utils
   - Resources

#### Добавьте файлы в соответствующие группы:

**Корневые файлы:**
- `TrackerApp.swift` → в корень проекта
- `ContentView.swift` → в корень проекта
- `DependencyContainer.swift` → в корень проекта

**Models:**
- `Models/TrackerModule.swift`
- `Models/TrackerConfiguration.swift`
- `Models/ModuleTypes.swift`
- `Models/CoreData/PersistenceController.swift`

**Views:**
- `Views/MainScreen/MainScreenView.swift`
- `Views/MainScreen/TrackerCardView.swift`
- `Views/Constructor/ConstructorView.swift`
- `Views/Constructor/ModuleLibraryView.swift`
- `Views/ActiveTracker/ActiveTrackerView.swift`
- `Views/Settings/ModuleSettingsView.swift`
- `Views/Analytics/AnalyticsView.swift`

**Services:**
- `Services/DataService.swift`
- `Services/ModuleFactory.swift`

### 4. Настройка проекта

#### Добавьте import statements:
В каждый файл добавьте необходимые импорты:
```swift
import SwiftUI
import Combine
import CoreData
```

#### Настройте Info.plist:
Добавьте описания для разрешений (если потребуется):
```xml
<key>NSUserNotificationUsageDescription</key>
<string>Приложение использует уведомления для напоминаний о трекерах</string>
```

### 5. Исправление ошибок компиляции

После добавления всех файлов могут возникнуть ошибки компиляции. Исправьте их:

1. **Missing imports** - добавьте необходимые импорты
2. **Undefined symbols** - убедитесь, что все файлы добавлены в проект
3. **Core Data model** - создайте пустую модель данных или временно закомментируйте связанный код

### 6. Первый запуск

1. Выберите симулятор iPhone (любой)
2. Нажмите `Cmd + R` для запуска
3. Приложение должно запуститься с главным экраном

## 🔧 Возможные проблемы и решения

### Ошибка: "Cannot find 'X' in scope"
**Решение**: Убедитесь, что все файлы добавлены в проект и имеют правильные импорты.

### Ошибка: Core Data model not found
**Решение**: 
1. Создайте новый Core Data model файл: File → New → Data Model
2. Назовите его `TrackerModel.xcdatamodeld`
3. Или временно закомментируйте Core Data код

### Ошибка: Build failed
**Решение**: 
1. Очистите проект: Product → Clean Build Folder
2. Перезапустите Xcode
3. Проверьте, что все файлы в правильных группах

## 📱 Что вы увидите после запуска

1. **Главный экран** с 3 примерами трекеров:
   - Утренняя рутина
   - Продуктивность
   - Фитнес

2. **Кнопка "+"** для создания нового трекера

3. **Конструктор** с библиотекой модулей

4. **Навигация** между экранами

## 🎨 Дизайн

Приложение использует:
- Системные цвета iOS
- SF Symbols для иконок
- Стандартные отступы и размеры
- Адаптивный дизайн для разных устройств

## 🚀 Следующие шаги

После успешного запуска можно:
1. Реализовать настоящие модули трекеров
2. Добавить Core Data модель
3. Реализовать drag & drop в конструкторе
4. Добавить анимации и переходы
5. Интегрировать аналитику

## 📞 Если что-то не работает

1. Убедитесь, что все файлы добавлены в проект
2. Проверьте импорты в каждом файле
3. Очистите и пересоберите проект
4. Перезапустите Xcode

---

**Готово! Теперь у вас есть рабочий прототип модульного конструктора трекеров! 🎉** 