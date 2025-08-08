// Конфигурация Airtable
const AIRTABLE_CONFIG = {
  apiKey: process.env.AIRTABLE_API_KEY || 'your_api_key_here',
  baseId: process.env.AIRTABLE_BASE_ID || 'your_base_id_here',
  apiUrl: 'https://api.airtable.com/v0'
};

// Названия таблиц
const TABLES = {
  USERS: 'Users',
  USER_ACTIONS: 'User_Actions',
  DISPLAY_DATA: 'Display_Data',
  ANALYTICS: 'Analytics'
};

// Типы действий пользователя
const ACTION_TYPES = {
  CHECKBOX_MARKED: 'checkbox_marked',
  ITEM_SELECTED: 'item_selected',
  DATA_SUBMITTED: 'data_submitted',
  PREFERENCE_CHANGED: 'preference_changed'
};

// Типы отображения данных
const DISPLAY_TYPES = {
  LIST: 'list',
  GRID: 'grid',
  CHART: 'chart',
  SUMMARY: 'summary'
};

// Периоды для аналитики
const ANALYTICS_PERIODS = {
  DAILY: 'daily',
  WEEKLY: 'weekly',
  MONTHLY: 'monthly'
};

module.exports = {
  AIRTABLE_CONFIG,
  TABLES,
  ACTION_TYPES,
  DISPLAY_TYPES,
  ANALYTICS_PERIODS
};