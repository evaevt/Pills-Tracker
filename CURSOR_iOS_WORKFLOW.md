# Cursor iOS Development Workflow

## Профессиональная разработка iOS в Cursor

Эта инструкция основана на статье [Thomas Ricouard](https://dimillian.medium.com/how-to-use-cursor-for-ios-development-54b912c23941) и адаптирована для проекта Tracker iOS.

## 🛠 Установленные инструменты

### Homebrew пакеты
- ✅ `xcode-build-server` - Language Server Protocol для Swift
- ✅ `xcbeautify` - Красивый вывод xcodebuild
- ✅ `swiftformat` - Автоматическое форматирование Swift кода

### Расширения Cursor (нужно установить)
- [ ] **Swift Language Support** - Подсветка синтаксиса Swift
- [ ] **Sweetpad** - Основное расширение для iOS разработки

## 📁 Структура проекта

```
Tracker iOS/
├── .vscode/
│   ├── settings.json      # Настройки Cursor для Swift
│   ├── launch.json        # Конфигурация отладки
│   └── tasks.json         # Задачи сборки
├── buildServer.json       # Конфигурация xcode-build-server
├── sync_to_xcode.sh      # Скрипт синхронизации
└── [исходный код проекта]
```

## 🔄 Workflow разработки

### 1. Настройка проекта (один раз)

1. **Установите расширения в Cursor:**
   - Откройте Extensions (⌘+Shift+X)
   - Найдите и установите "Swift Language Support"
   - Найдите и установите "Sweetpad"

2. **Инициализируйте Build Server:**
   ```bash
   # В командной палитре Cursor (⌘+Shift+P)
   > Sweetpad: Generate Build Server Config
   ```

3. **Первая сборка:**
   ```bash
   # В командной палитре Cursor (⌘+Shift+P)
   > Sweetpad: Build and Run
   ```

### 2. Ежедневная разработка

#### Редактирование кода
- Работайте в **Cursor** в папке `/Users/tina/Desktop/Tracker iOS/`
- Используйте AI-функции Cursor:
  - **Tab completion** - умное автодополнение
  - **⌘+K** - inline редактирование с AI
  - **⌘+L** - чат с AI о коде
  - **Composer** - генерация множественных файлов

#### Синхронизация с Xcode
После внесения изменений в Cursor:
```bash
./sync_to_xcode.sh
```

#### Сборка и запуск
```bash
# В командной палитре Cursor (⌘+Shift+P)
> Sweetpad: Build and Run
```

#### Отладка
1. Запустите приложение через Sweetpad
2. Нажмите **F5** для подключения отладчика
3. Используйте breakpoints, как в Xcode

### 3. AI-возможности Cursor

#### Cursor Tab (автодополнение)
- Cursor анализирует ваш проект и предлагает контекстные дополнения
- Просто нажимайте **Tab** для принятия предложений
- AI понимает архитектуру проекта и стиль кода

#### Inline Edit (⌘+K)
- Выделите код и нажмите **⌘+K**
- Опишите желаемые изменения на естественном языке
- AI применит изменения с учетом контекста

#### Chat (⌘+L)
- Задавайте вопросы о коде, архитектуре, Swift
- Используйте `@` для добавления файлов в контекст
- AI поможет с рефакторингом, оптимизацией, багфиксами

#### Composer
- Для создания множественных файлов или больших изменений
- Детально опишите требования
- AI сгенерирует все необходимые файлы

## 🚀 Горячие клавиши

| Действие | Клавиши |
|----------|---------|
| Командная палитра | ⌘+Shift+P |
| AI Chat | ⌘+L |
| Inline Edit | ⌘+K |
| Сборка проекта | ⌘+Shift+P → "Sweetpad: Build" |
| Запуск приложения | ⌘+Shift+P → "Sweetpad: Build and Run" |
| Отладка | F5 |
| Синхронизация | `./sync_to_xcode.sh` |

## 📋 Чек-лист перед началом работы

- [ ] Установлены все Homebrew пакеты
- [ ] Установлены расширения Swift Language Support и Sweetpad
- [ ] Создан buildServer.json
- [ ] Проект успешно собирается через Sweetpad
- [ ] Отладка работает (F5)
- [ ] Скрипт синхронизации работает

## 🔧 Решение проблем

### Проблема: Language Server не работает
```bash
# Перезапустите xcode-build-server
killall xcode-build-server
# Пересоберите проект
⌘+Shift+P → "Sweetpad: Build"
```

### Проблема: Изменения не синхронизируются
```bash
# Запустите скрипт синхронизации
./sync_to_xcode.sh
# Обновите Xcode (⌘+R)
```

### Проблема: Отладка не подключается
1. Убедитесь, что приложение запущено
2. Проверьте конфигурацию в `.vscode/launch.json`
3. Попробуйте "Attach to running app" в панели Debug

## 💡 Советы по эффективности

1. **Используйте AI максимально:** Cursor понимает Swift и iOS паттерны
2. **Работайте только в Cursor:** Избегайте переключений между редакторами
3. **Синхронизируйтесь регулярно:** Запускайте `./sync_to_xcode.sh` после значимых изменений
4. **Изучайте Sweetpad:** Множество полезных команд для iOS разработки
5. **Настройте форматирование:** SwiftFormat автоматически форматирует код

## 📚 Дополнительные ресурсы

- [Оригинальная статья](https://dimillian.medium.com/how-to-use-cursor-for-ios-development-54b912c23941)
- [Sweetpad Documentation](https://marketplace.visualstudio.com/items?itemName=sweetpad.sweetpad)
- [Cursor AI Features](https://cursor.com/features)

---

**Готово!** Теперь вы можете эффективно разрабатывать iOS приложения в Cursor с полной поддержкой AI, отладки и автодополнения! 🎉 