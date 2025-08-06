// Экран 2: Отображение собранных данных
const AirtableService = require('./airtable-service');
const { DISPLAY_TYPES, ACTION_TYPES } = require('./airtable-config');

class DataDisplayScreen {
  constructor() {
    this.airtableService = new AirtableService();
    this.currentUserId = null;
    this.displayData = null;
    this.refreshInterval = null;
  }

  // Инициализация экрана
  async initialize(userId, autoRefresh = true) {
    this.currentUserId = userId;
    console.log(`Инициализация экрана отображения данных для пользователя: ${userId}`);
    
    // Загружаем данные при инициализации
    await this.loadDisplayData();
    
    // Настраиваем автообновление если нужно
    if (autoRefresh) {
      this.startAutoRefresh(30000); // Обновление каждые 30 секунд
    }
  }

  // Загрузка данных для отображения
  async loadDisplayData() {
    try {
      // Получаем агрегированные данные
      const displayRecords = await this.airtableService.getDisplayData(
        this.currentUserId
      );

      // Получаем последние действия пользователя
      const userActions = await this.airtableService.getUserActions(
        this.currentUserId,
        50
      );

      // Обрабатываем данные для отображения
      this.displayData = this.processDataForDisplay(displayRecords, userActions);
      
      console.log('Данные загружены для отображения:', this.displayData);
      
      // Уведомляем UI об обновлении данных
      this.notifyDataUpdate();
      
      return this.displayData;
    } catch (error) {
      console.error('Ошибка при загрузке данных:', error);
      throw error;
    }
  }

  // Обработка данных для различных типов отображения
  processDataForDisplay(displayRecords, userActions) {
    const processedData = {
      summary: this.generateSummary(userActions),
      list: this.generateListView(userActions),
      grid: this.generateGridView(userActions),
      chart: this.generateChartData(userActions),
      lastUpdated: new Date().toISOString()
    };

    return processedData;
  }

  // Генерация сводки
  generateSummary(actions) {
    const summary = {
      totalActions: actions.length,
      completedTasks: 0,
      pendingTasks: 0,
      recentActivity: [],
      categories: new Map()
    };

    actions.forEach(record => {
      const fields = record.fields;
      
      // Подсчет выполненных/невыполненных задач
      if (fields.completed) {
        summary.completedTasks++;
      } else {
        summary.pendingTasks++;
      }

      // Группировка по типам действий
      const actionType = fields.action_type;
      if (!summary.categories.has(actionType)) {
        summary.categories.set(actionType, 0);
      }
      summary.categories.set(actionType, summary.categories.get(actionType) + 1);

      // Добавляем в недавнюю активность (первые 5)
      if (summary.recentActivity.length < 5) {
        const actionData = JSON.parse(fields.action_data || '{}');
        summary.recentActivity.push({
          id: record.id,
          type: actionType,
          data: actionData,
          timestamp: fields.timestamp,
          screenName: fields.screen_name
        });
      }
    });

    // Конвертируем Map в объект для сериализации
    summary.categoriesObject = Object.fromEntries(summary.categories);
    
    return summary;
  }

  // Генерация списка
  generateListView(actions) {
    return actions.map(record => {
      const fields = record.fields;
      const actionData = JSON.parse(fields.action_data || '{}');
      
      return {
        id: record.id,
        title: this.getActionTitle(fields.action_type, actionData),
        subtitle: this.getActionSubtitle(fields.action_type, actionData),
        timestamp: fields.timestamp,
        completed: fields.completed,
        icon: this.getActionIcon(fields.action_type),
        data: actionData
      };
    });
  }

  // Генерация сетки
  generateGridView(actions) {
    // Группируем действия по дням
    const gridData = new Map();
    
    actions.forEach(record => {
      const fields = record.fields;
      const date = new Date(fields.timestamp).toLocaleDateString();
      
      if (!gridData.has(date)) {
        gridData.set(date, []);
      }
      
      const actionData = JSON.parse(fields.action_data || '{}');
      gridData.get(date).push({
        id: record.id,
        type: fields.action_type,
        data: actionData,
        completed: fields.completed,
        time: new Date(fields.timestamp).toLocaleTimeString()
      });
    });

    // Конвертируем в массив для удобного отображения
    return Array.from(gridData.entries()).map(([date, items]) => ({
      date: date,
      items: items,
      totalItems: items.length,
      completedItems: items.filter(item => item.completed).length
    }));
  }

  // Генерация данных для графиков
  generateChartData(actions) {
    // Данные для графика активности по дням
    const activityByDay = new Map();
    
    // Данные для круговой диаграммы по типам
    const actionTypes = new Map();
    
    actions.forEach(record => {
      const fields = record.fields;
      const date = new Date(fields.timestamp).toLocaleDateString();
      
      // Активность по дням
      if (!activityByDay.has(date)) {
        activityByDay.set(date, 0);
      }
      activityByDay.set(date, activityByDay.get(date) + 1);
      
      // Типы действий
      if (!actionTypes.has(fields.action_type)) {
        actionTypes.set(fields.action_type, 0);
      }
      actionTypes.set(fields.action_type, actionTypes.get(fields.action_type) + 1);
    });

    return {
      dailyActivity: {
        labels: Array.from(activityByDay.keys()),
        data: Array.from(activityByDay.values())
      },
      actionTypeDistribution: {
        labels: Array.from(actionTypes.keys()),
        data: Array.from(actionTypes.values())
      },
      completionRate: this.calculateCompletionRate(actions)
    };
  }

  // Вспомогательные методы
  getActionTitle(actionType, actionData) {
    switch (actionType) {
      case ACTION_TYPES.CHECKBOX_MARKED:
        return actionData.itemName || 'Элемент отмечен';
      case ACTION_TYPES.DATA_SUBMITTED:
        return `Форма: ${actionData.formType || 'Данные отправлены'}`;
      case ACTION_TYPES.ITEM_SELECTED:
        return actionData.itemName || 'Элемент выбран';
      default:
        return 'Действие';
    }
  }

  getActionSubtitle(actionType, actionData) {
    switch (actionType) {
      case ACTION_TYPES.CHECKBOX_MARKED:
        return actionData.isChecked ? 'Отмечено' : 'Снято';
      case ACTION_TYPES.DATA_SUBMITTED:
        return `Полей: ${Object.keys(actionData.fields || {}).length}`;
      default:
        return '';
    }
  }

  getActionIcon(actionType) {
    const icons = {
      [ACTION_TYPES.CHECKBOX_MARKED]: '✓',
      [ACTION_TYPES.DATA_SUBMITTED]: '📝',
      [ACTION_TYPES.ITEM_SELECTED]: '👆',
      [ACTION_TYPES.PREFERENCE_CHANGED]: '⚙️'
    };
    return icons[actionType] || '•';
  }

  calculateCompletionRate(actions) {
    if (actions.length === 0) return 0;
    const completed = actions.filter(record => record.fields.completed).length;
    return Math.round((completed / actions.length) * 100);
  }

  // Автообновление данных
  startAutoRefresh(intervalMs) {
    this.stopAutoRefresh(); // Останавливаем предыдущий интервал если есть
    
    this.refreshInterval = setInterval(async () => {
      try {
        await this.loadDisplayData();
        console.log('Данные автоматически обновлены');
      } catch (error) {
        console.error('Ошибка при автообновлении:', error);
      }
    }, intervalMs);
  }

  stopAutoRefresh() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = null;
    }
  }

  // Уведомление UI об обновлении данных
  notifyDataUpdate() {
    if (typeof window !== 'undefined' && window.dispatchEvent) {
      const event = new CustomEvent('displayDataUpdated', {
        detail: { data: this.displayData }
      });
      window.dispatchEvent(event);
    }
  }

  // Получить данные определенного типа отображения
  getDisplayDataByType(displayType) {
    if (!this.displayData) return null;
    
    switch (displayType) {
      case DISPLAY_TYPES.LIST:
        return this.displayData.list;
      case DISPLAY_TYPES.GRID:
        return this.displayData.grid;
      case DISPLAY_TYPES.CHART:
        return this.displayData.chart;
      case DISPLAY_TYPES.SUMMARY:
      default:
        return this.displayData.summary;
    }
  }

  // Очистка при уничтожении экрана
  destroy() {
    this.stopAutoRefresh();
    this.displayData = null;
  }
}

// Пример использования
async function exampleUsage() {
  const screen = new DataDisplayScreen();
  
  // Инициализация с автообновлением
  await screen.initialize('user123', true);
  
  // Получение данных для списка
  const listData = screen.getDisplayDataByType(DISPLAY_TYPES.LIST);
  console.log('Данные для списка:', listData);
  
  // Получение данных для графиков
  const chartData = screen.getDisplayDataByType(DISPLAY_TYPES.CHART);
  console.log('Данные для графиков:', chartData);
  
  // Остановка автообновления при необходимости
  // screen.stopAutoRefresh();
}

module.exports = DataDisplayScreen;