// Менеджер синхронизации данных между экранами
const EventEmitter = require('events');
const AirtableService = require('./airtable-service');

class DataSyncManager extends EventEmitter {
  constructor() {
    super();
    this.airtableService = new AirtableService();
    this.syncInterval = null;
    this.listeners = new Map();
    this.cache = new Map();
  }

  // Регистрация экрана для получения обновлений
  registerScreen(screenName, callback) {
    if (!this.listeners.has(screenName)) {
      this.listeners.set(screenName, []);
    }
    this.listeners.get(screenName).push(callback);
    
    console.log(`Экран ${screenName} зарегистрирован для синхронизации`);
    
    // Возвращаем функцию для отписки
    return () => this.unregisterScreen(screenName, callback);
  }

  // Отмена регистрации экрана
  unregisterScreen(screenName, callback) {
    if (this.listeners.has(screenName)) {
      const callbacks = this.listeners.get(screenName);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
      if (callbacks.length === 0) {
        this.listeners.delete(screenName);
      }
    }
  }

  // Уведомление экранов об изменениях
  notifyScreens(eventType, data) {
    this.emit(eventType, data);
    
    // Уведомляем конкретные экраны
    this.listeners.forEach((callbacks, screenName) => {
      callbacks.forEach(callback => {
        try {
          callback({
            type: eventType,
            data: data,
            timestamp: new Date().toISOString(),
            source: 'DataSyncManager'
          });
        } catch (error) {
          console.error(`Ошибка при уведомлении экрана ${screenName}:`, error);
        }
      });
    });
  }

  // Синхронизация данных при действии пользователя на экране 1
  async syncUserAction(userId, action) {
    try {
      // Сохраняем действие в Airtable
      const record = await this.airtableService.recordUserAction(
        userId,
        action.type,
        action.data,
        action.screenName
      );

      // Обновляем кэш
      this.updateCache(userId, 'actions', record);

      // Уведомляем другие экраны
      this.notifyScreens('user_action_recorded', {
        userId: userId,
        action: action,
        record: record
      });

      // Запускаем асинхронное обновление агрегированных данных
      this.scheduleAggregation(userId);

      return record;
    } catch (error) {
      console.error('Ошибка при синхронизации действия:', error);
      throw error;
    }
  }

  // Планирование агрегации данных
  scheduleAggregation(userId) {
    // Используем debounce для оптимизации
    if (this.aggregationTimeout) {
      clearTimeout(this.aggregationTimeout);
    }

    this.aggregationTimeout = setTimeout(async () => {
      await this.aggregateAndNotify(userId);
    }, 2000); // Ждем 2 секунды перед агрегацией
  }

  // Агрегация данных и уведомление экранов
  async aggregateAndNotify(userId) {
    try {
      // Получаем последние действия
      const recentActions = await this.airtableService.getUserActions(userId, 50);
      
      // Агрегируем данные
      const actionIds = recentActions.map(r => r.id);
      const displayData = await this.airtableService.aggregateDisplayData(
        userId,
        actionIds
      );

      // Обновляем кэш
      this.updateCache(userId, 'displayData', displayData);

      // Уведомляем экран отображения (экран 2)
      this.notifyScreens('display_data_updated', {
        userId: userId,
        displayData: displayData,
        recentActions: recentActions
      });

      // Запускаем анализ для аналитики
      this.scheduleAnalytics(userId);

    } catch (error) {
      console.error('Ошибка при агрегации данных:', error);
    }
  }

  // Планирование обновления аналитики
  scheduleAnalytics(userId) {
    // Аналитика обновляется реже
    if (this.analyticsTimeout) {
      clearTimeout(this.analyticsTimeout);
    }

    this.analyticsTimeout = setTimeout(async () => {
      await this.updateAnalytics(userId);
    }, 10000); // Ждем 10 секунд перед обновлением аналитики
  }

  // Обновление аналитики
  async updateAnalytics(userId) {
    try {
      // Получаем все действия для анализа
      const allActions = await this.airtableService.getUserActions(userId, 1000);
      
      // Вычисляем метрики
      const metrics = this.calculateMetrics(allActions);
      
      // Сохраняем аналитику
      const analytics = await this.airtableService.updateAnalytics(
        userId,
        'daily',
        metrics
      );

      // Обновляем кэш
      this.updateCache(userId, 'analytics', analytics);

      // Уведомляем экран аналитики (экран 3)
      this.notifyScreens('analytics_updated', {
        userId: userId,
        analytics: analytics,
        metrics: metrics
      });

    } catch (error) {
      console.error('Ошибка при обновлении аналитики:', error);
    }
  }

  // Вычисление метрик для аналитики
  calculateMetrics(actions) {
    const metrics = {
      total_actions: actions.length,
      completed_actions: actions.filter(a => a.fields.completed).length,
      completion_rate: 0,
      actions_by_type: {},
      actions_by_screen: {},
      last_action_time: null
    };

    // Процент завершения
    if (metrics.total_actions > 0) {
      metrics.completion_rate = metrics.completed_actions / metrics.total_actions;
    }

    // Группировка по типам и экранам
    actions.forEach(action => {
      const type = action.fields.action_type;
      const screen = action.fields.screen_name;

      metrics.actions_by_type[type] = (metrics.actions_by_type[type] || 0) + 1;
      metrics.actions_by_screen[screen] = (metrics.actions_by_screen[screen] || 0) + 1;
    });

    // Время последнего действия
    if (actions.length > 0) {
      metrics.last_action_time = actions[0].fields.timestamp;
    }

    return metrics;
  }

  // Обновление кэша
  updateCache(userId, dataType, data) {
    if (!this.cache.has(userId)) {
      this.cache.set(userId, {});
    }
    
    const userCache = this.cache.get(userId);
    userCache[dataType] = {
      data: data,
      timestamp: new Date().toISOString()
    };
  }

  // Получение данных из кэша
  getCachedData(userId, dataType) {
    const userCache = this.cache.get(userId);
    if (userCache && userCache[dataType]) {
      return userCache[dataType].data;
    }
    return null;
  }

  // Запуск автоматической синхронизации
  startAutoSync(intervalMs = 30000) {
    if (this.syncInterval) {
      this.stopAutoSync();
    }

    this.syncInterval = setInterval(async () => {
      try {
        // Получаем список активных пользователей из кэша
        const userIds = Array.from(this.cache.keys());
        
        for (const userId of userIds) {
          // Проверяем обновления для каждого пользователя
          await this.checkForUpdates(userId);
        }
      } catch (error) {
        console.error('Ошибка при автосинхронизации:', error);
      }
    }, intervalMs);

    console.log(`Автосинхронизация запущена с интервалом ${intervalMs}мс`);
  }

  // Остановка автоматической синхронизации
  stopAutoSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
      console.log('Автосинхронизация остановлена');
    }
  }

  // Проверка обновлений для пользователя
  async checkForUpdates(userId) {
    try {
      const cachedActions = this.getCachedData(userId, 'actions');
      const latestActions = await this.airtableService.getUserActions(userId, 10);

      // Проверяем, есть ли новые действия
      if (this.hasNewActions(cachedActions, latestActions)) {
        // Запускаем обновление данных
        await this.aggregateAndNotify(userId);
      }
    } catch (error) {
      console.error(`Ошибка при проверке обновлений для пользователя ${userId}:`, error);
    }
  }

  // Проверка наличия новых действий
  hasNewActions(cached, latest) {
    if (!cached || !latest || latest.length === 0) {
      return false;
    }

    const cachedIds = new Set(cached.map ? cached.map(a => a.id) : [cached.id]);
    return latest.some(action => !cachedIds.has(action.id));
  }

  // Принудительная синхронизация всех данных
  async forceSync(userId) {
    try {
      console.log(`Принудительная синхронизация для пользователя ${userId}`);
      
      // Получаем все данные
      const actions = await this.airtableService.getUserActions(userId, 100);
      const displayData = await this.airtableService.getDisplayData(userId);
      
      // Обновляем кэш
      this.updateCache(userId, 'actions', actions);
      this.updateCache(userId, 'displayData', displayData);
      
      // Уведомляем все экраны
      this.notifyScreens('full_sync_completed', {
        userId: userId,
        actions: actions,
        displayData: displayData
      });
      
      // Запускаем обновление аналитики
      await this.updateAnalytics(userId);
      
      return {
        success: true,
        syncedAt: new Date().toISOString()
      };
    } catch (error) {
      console.error('Ошибка при принудительной синхронизации:', error);
      throw error;
    }
  }

  // Очистка кэша для пользователя
  clearUserCache(userId) {
    this.cache.delete(userId);
    console.log(`Кэш очищен для пользователя ${userId}`);
  }

  // Очистка всего кэша
  clearAllCache() {
    this.cache.clear();
    console.log('Весь кэш очищен');
  }
}

// Создаем синглтон для использования во всем приложении
const syncManager = new DataSyncManager();

// Экспортируем экземпляр и класс
module.exports = {
  syncManager,
  DataSyncManager
};