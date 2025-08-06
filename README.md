# Airtable Integration для мобильного приложения

Это пример интеграции Airtable для мобильного приложения с тремя экранами и автоматической синхронизацией данных между ними.

## Возможности

- **Экран 1**: Сбор данных (чекбоксы, формы)
- **Экран 2**: Отображение данных (списки, сетки, графики)
- **Экран 3**: Аналитика (метрики, тренды, рекомендации)
- **Синхронизация**: Автоматическая синхронизация данных между экранами в реальном времени

## Структура проекта

```
/workspace/
├── airtable-config.js       # Конфигурация Airtable
├── airtable-service.js      # Сервис для работы с Airtable API
├── screen1-data-collection.js # Экран сбора данных
├── screen2-data-display.js   # Экран отображения
├── screen3-analytics.js      # Экран аналитики
├── data-sync-manager.js      # Менеджер синхронизации
├── app-example.js           # Пример приложения
├── airtable-structure.md    # Структура базы данных
├── package.json             # Зависимости
├── .env.example             # Пример переменных окружения
└── README.md                # Этот файл
```

## Установка

1. Клонируйте репозиторий
2. Установите зависимости:
   ```bash
   npm install
   ```

3. Создайте файл `.env` на основе `.env.example`:
   ```bash
   cp .env.example .env
   ```

4. Заполните переменные окружения:
   - `AIRTABLE_API_KEY`: Ваш API ключ от Airtable
   - `AIRTABLE_BASE_ID`: ID вашей базы данных

## Настройка Airtable

1. Создайте новую базу в Airtable
2. Создайте таблицы согласно структуре в `airtable-structure.md`:
   - Users
   - User_Actions
   - Display_Data
   - Analytics

3. Настройте поля в каждой таблице как описано в документации

## Использование

### Запуск демонстрации
```bash
npm start
```

### Интеграция в ваше приложение

```javascript
const DataCollectionScreen = require('./screen1-data-collection');
const DataDisplayScreen = require('./screen2-data-display');
const AnalyticsScreen = require('./screen3-analytics');
const { syncManager } = require('./data-sync-manager');

// Инициализация экранов
const screen1 = new DataCollectionScreen();
await screen1.initialize('userId');

// Обработка действий пользователя
await screen1.handleCheckboxToggle('taskId', 'Task Name', true);
await screen1.handleFormSubmit(formData);

// Синхронизация данных
syncManager.startAutoSync(30000); // Каждые 30 секунд
```

## API Reference

### DataCollectionScreen
- `initialize(userId)` - Инициализация экрана
- `handleCheckboxToggle(itemId, itemName, isChecked)` - Обработка чекбокса
- `handleFormSubmit(formData)` - Отправка формы
- `getCurrentCheckboxStates()` - Получение состояний чекбоксов

### DataDisplayScreen
- `initialize(userId, autoRefresh)` - Инициализация с автообновлением
- `loadDisplayData()` - Загрузка данных для отображения
- `getDisplayDataByType(displayType)` - Получение данных по типу
- `startAutoRefresh(intervalMs)` - Запуск автообновления

### AnalyticsScreen
- `initialize(userId)` - Инициализация и анализ
- `performAnalysis()` - Выполнение полного анализа
- `getAnalyticsByPeriod(period)` - Получение аналитики за период
- `getRecommendations()` - Получение рекомендаций

### DataSyncManager
- `registerScreen(screenName, callback)` - Регистрация экрана
- `syncUserAction(userId, action)` - Синхронизация действия
- `startAutoSync(intervalMs)` - Запуск автосинхронизации
- `forceSync(userId)` - Принудительная синхронизация

## Примеры данных

### Действие пользователя
```javascript
{
  type: 'checkbox_marked',
  data: {
    itemId: 'task1',
    itemName: 'Утренняя зарядка',
    isChecked: true
  },
  screenName: 'DataCollectionScreen'
}
```

### Данные для отображения
```javascript
{
  summary: {
    totalActions: 25,
    completedTasks: 20,
    pendingTasks: 5,
    recentActivity: [...]
  },
  list: [...],
  grid: [...],
  chart: {
    dailyActivity: {...},
    actionTypeDistribution: {...}
  }
}
```

### Аналитика
```javascript
{
  daily: {
    metrics: {
      total_actions: 15,
      completion_rate: 0.85,
      productivity_score: 78
    },
    insights: [...]
  },
  recommendations: [...],
  predictions: {...}
}
```

## Лучшие практики

1. **Безопасность**: Храните API ключи в переменных окружения
2. **Оптимизация**: Используйте кэширование для уменьшения запросов к API
3. **Синхронизация**: Настройте интервалы обновления в зависимости от нагрузки
4. **Обработка ошибок**: Всегда обрабатывайте ошибки сети и API

## Ограничения Airtable

- 5 запросов в секунду на базу
- Максимум 100 записей за один запрос
- Ограничение на размер вложений: 1GB на базу

## Поддержка

При возникновении вопросов обратитесь к:
- [Документация Airtable API](https://airtable.com/api)
- [Airtable Community](https://community.airtable.com/)

## Лицензия

ISC