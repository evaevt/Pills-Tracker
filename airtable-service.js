const axios = require('axios');
const { AIRTABLE_CONFIG, TABLES } = require('./airtable-config');

class AirtableService {
  constructor() {
    this.apiKey = AIRTABLE_CONFIG.apiKey;
    this.baseId = AIRTABLE_CONFIG.baseId;
    this.apiUrl = AIRTABLE_CONFIG.apiUrl;
    
    // Настройка axios с базовыми параметрами
    this.client = axios.create({
      baseURL: `${this.apiUrl}/${this.baseId}`,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      }
    });
  }

  // Получить записи из таблицы
  async getRecords(tableName, options = {}) {
    try {
      const params = {
        maxRecords: options.maxRecords || 100,
        view: options.view || 'Grid view',
        filterByFormula: options.filterByFormula || '',
        sort: options.sort || []
      };

      const response = await this.client.get(`/${tableName}`, { params });
      return response.data.records;
    } catch (error) {
      console.error(`Error fetching records from ${tableName}:`, error);
      throw error;
    }
  }

  // Получить одну запись по ID
  async getRecord(tableName, recordId) {
    try {
      const response = await this.client.get(`/${tableName}/${recordId}`);
      return response.data;
    } catch (error) {
      console.error(`Error fetching record ${recordId} from ${tableName}:`, error);
      throw error;
    }
  }

  // Создать новую запись
  async createRecord(tableName, fields) {
    try {
      const response = await this.client.post(`/${tableName}`, {
        fields: fields
      });
      return response.data;
    } catch (error) {
      console.error(`Error creating record in ${tableName}:`, error);
      throw error;
    }
  }

  // Создать несколько записей
  async createRecords(tableName, recordsArray) {
    try {
      const records = recordsArray.map(fields => ({ fields }));
      const response = await this.client.post(`/${tableName}`, {
        records: records
      });
      return response.data.records;
    } catch (error) {
      console.error(`Error creating records in ${tableName}:`, error);
      throw error;
    }
  }

  // Обновить запись
  async updateRecord(tableName, recordId, fields) {
    try {
      const response = await this.client.patch(`/${tableName}/${recordId}`, {
        fields: fields
      });
      return response.data;
    } catch (error) {
      console.error(`Error updating record ${recordId} in ${tableName}:`, error);
      throw error;
    }
  }

  // Удалить запись
  async deleteRecord(tableName, recordId) {
    try {
      const response = await this.client.delete(`/${tableName}/${recordId}`);
      return response.data;
    } catch (error) {
      console.error(`Error deleting record ${recordId} from ${tableName}:`, error);
      throw error;
    }
  }

  // Специфичные методы для работы с пользовательскими действиями
  async recordUserAction(userId, actionType, actionData, screenName) {
    const fields = {
      user_id: [userId], // Связь с таблицей Users
      action_type: actionType,
      action_data: JSON.stringify(actionData),
      timestamp: new Date().toISOString(),
      screen_name: screenName,
      completed: false
    };

    return await this.createRecord(TABLES.USER_ACTIONS, fields);
  }

  // Получить действия пользователя
  async getUserActions(userId, limit = 50) {
    const filterFormula = `{user_id} = '${userId}'`;
    const options = {
      filterByFormula: filterFormula,
      maxRecords: limit,
      sort: [{ field: 'timestamp', direction: 'desc' }]
    };

    return await this.getRecords(TABLES.USER_ACTIONS, options);
  }

  // Агрегировать данные для отображения
  async aggregateDisplayData(userId, actionIds) {
    const aggregatedData = {
      user_id: [userId],
      action_ids: actionIds,
      aggregated_data: JSON.stringify({
        total_actions: actionIds.length,
        last_action_time: new Date().toISOString()
      }),
      display_type: 'summary',
      last_updated: new Date().toISOString()
    };

    return await this.createRecord(TABLES.DISPLAY_DATA, aggregatedData);
  }

  // Получить данные для отображения
  async getDisplayData(userId, displayType = null) {
    let filterFormula = `{user_id} = '${userId}'`;
    if (displayType) {
      filterFormula = `AND({user_id} = '${userId}', {display_type} = '${displayType}')`;
    }

    const options = {
      filterByFormula: filterFormula,
      sort: [{ field: 'last_updated', direction: 'desc' }]
    };

    return await this.getRecords(TABLES.DISPLAY_DATA, options);
  }

  // Создать или обновить аналитику
  async updateAnalytics(userId, period, metrics) {
    const analyticsData = {
      user_id: [userId],
      period: period,
      metrics: JSON.stringify(metrics),
      insights: this.generateInsights(metrics),
      calculated_at: new Date().toISOString()
    };

    return await this.createRecord(TABLES.ANALYTICS, analyticsData);
  }

  // Генерация инсайтов на основе метрик
  generateInsights(metrics) {
    // Простой пример генерации инсайтов
    const insights = [];
    
    if (metrics.total_actions > 100) {
      insights.push('Высокая активность пользователя');
    }
    
    if (metrics.completion_rate > 0.8) {
      insights.push('Отличный показатель завершения задач');
    }
    
    return insights.join('; ');
  }
}

module.exports = AirtableService;