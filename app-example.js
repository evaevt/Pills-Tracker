// Пример интеграции всех экранов с синхронизацией данных
const DataCollectionScreen = require('./screen1-data-collection');
const DataDisplayScreen = require('./screen2-data-display');
const AnalyticsScreen = require('./screen3-analytics');
const { syncManager } = require('./data-sync-manager');

// Имитация мобильного приложения
class MobileApp {
  constructor() {
    this.currentUserId = 'user123';
    this.screens = {
      collection: null,
      display: null,
      analytics: null
    };
  }

  // Инициализация приложения
  async initialize() {
    console.log('=== Инициализация мобильного приложения ===\n');

    // Создаем экраны
    this.screens.collection = new DataCollectionScreen();
    this.screens.display = new DataDisplayScreen();
    this.screens.analytics = new AnalyticsScreen();

    // Инициализируем экраны
    await this.screens.collection.initialize(this.currentUserId);
    await this.screens.display.initialize(this.currentUserId, false); // Без автообновления
    await this.screens.analytics.initialize(this.currentUserId);

    // Настраиваем синхронизацию
    this.setupSync();

    // Запускаем автосинхронизацию
    syncManager.startAutoSync(30000);

    console.log('Приложение инициализировано\n');
  }

  // Настройка синхронизации между экранами
  setupSync() {
    // Экран сбора данных уведомляет о новых действиях
    this.screens.collection.updateLocalState = (itemId, isChecked) => {
      console.log(`[Экран 1] Локальное обновление: ${itemId} = ${isChecked}`);
      
      // Синхронизируем через менеджер
      syncManager.syncUserAction(this.currentUserId, {
        type: 'checkbox_marked',
        data: { itemId, isChecked },
        screenName: 'DataCollectionScreen'
      });
    };

    // Экран отображения подписывается на обновления
    const unsubscribeDisplay = syncManager.registerScreen('DataDisplayScreen', (event) => {
      if (event.type === 'display_data_updated') {
        console.log(`[Экран 2] Получено обновление данных для отображения`);
        this.screens.display.displayData = event.data.displayData;
        this.screens.display.notifyDataUpdate();
      }
    });

    // Экран аналитики подписывается на обновления
    const unsubscribeAnalytics = syncManager.registerScreen('AnalyticsScreen', (event) => {
      if (event.type === 'analytics_updated') {
        console.log(`[Экран 3] Получено обновление аналитики`);
        this.screens.analytics.analyticsData = event.data.analytics;
      }
    });

    // Слушаем глобальные события
    syncManager.on('user_action_recorded', (data) => {
      console.log(`[Sync] Действие записано: ${data.action.type}`);
    });

    syncManager.on('full_sync_completed', (data) => {
      console.log(`[Sync] Полная синхронизация завершена для пользователя ${data.userId}`);
    });
  }

  // Демонстрация работы приложения
  async demonstrateWorkflow() {
    console.log('\n=== Демонстрация работы приложения ===\n');

    // 1. Пользователь отмечает задачи на экране 1
    console.log('1. Пользователь отмечает задачи:\n');
    
    await this.screens.collection.handleCheckboxToggle('task1', 'Утренняя зарядка', true);
    await this.delay(1000);
    
    await this.screens.collection.handleCheckboxToggle('task2', 'Медитация', true);
    await this.delay(1000);
    
    await this.screens.collection.handleCheckboxToggle('task3', 'Чтение книги', false);
    await this.delay(1000);

    // 2. Пользователь отправляет форму
    console.log('\n2. Пользователь отправляет форму:\n');
    
    await this.screens.collection.handleFormSubmit({
      type: 'daily_mood',
      fields: {
        mood: 'excellent',
        energy: 9,
        sleep_hours: 8,
        notes: 'Отличный день!'
      },
      selectedItems: [
        { id: 'habit1', name: 'Пить воду' },
        { id: 'habit2', name: 'Прогулка' }
      ]
    });

    // Ждем синхронизации
    await this.delay(3000);

    // 3. Просматриваем данные на экране 2
    console.log('\n3. Отображение данных на экране 2:\n');
    
    const listData = this.screens.display.getDisplayDataByType('list');
    console.log('Список действий:', listData?.slice(0, 3));
    
    const chartData = this.screens.display.getDisplayDataByType('chart');
    console.log('\nДанные для графиков:', chartData);

    // Ждем обновления аналитики
    await this.delay(8000);

    // 4. Просматриваем аналитику на экране 3
    console.log('\n4. Аналитика на экране 3:\n');
    
    const analytics = this.screens.analytics.getAnalytics();
    if (analytics) {
      console.log('Ежедневная аналитика:', analytics.daily?.metrics);
      console.log('\nРекомендации:', this.screens.analytics.getRecommendations());
      console.log('\nПредсказания:', this.screens.analytics.getPredictions());
    }

    // 5. Демонстрация real-time синхронизации
    console.log('\n5. Real-time синхронизация:\n');
    
    console.log('Отмечаем еще одну задачу...');
    await this.screens.collection.handleCheckboxToggle('task4', 'Планирование дня', true);
    
    // Ждем автоматической синхронизации
    await this.delay(3000);
    
    console.log('Данные автоматически синхронизированы между экранами!');
  }

  // Вспомогательная функция задержки
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Завершение работы приложения
  async shutdown() {
    console.log('\n=== Завершение работы приложения ===\n');
    
    // Останавливаем автосинхронизацию
    syncManager.stopAutoSync();
    
    // Очищаем кэш
    syncManager.clearAllCache();
    
    // Останавливаем автообновление на экране отображения
    this.screens.display.destroy();
    
    console.log('Приложение завершено');
  }
}

// Запуск демонстрации
async function runDemo() {
  const app = new MobileApp();
  
  try {
    // Инициализация
    await app.initialize();
    
    // Демонстрация работы
    await app.demonstrateWorkflow();
    
    // Ждем немного перед завершением
    await app.delay(2000);
    
    // Завершение
    await app.shutdown();
    
  } catch (error) {
    console.error('Ошибка в приложении:', error);
  }
}

// Экспорт для использования
module.exports = {
  MobileApp,
  runDemo
};

// Если файл запущен напрямую
if (require.main === module) {
  runDemo();
}