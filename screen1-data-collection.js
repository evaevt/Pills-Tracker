// Экран 1: Сбор данных от пользователя
const AirtableService = require('./airtable-service');
const { ACTION_TYPES } = require('./airtable-config');

class DataCollectionScreen {
  constructor() {
    this.airtableService = new AirtableService();
    this.currentUserId = null; // Будет установлен при входе пользователя
  }

  // Инициализация экрана
  async initialize(userId) {
    this.currentUserId = userId;
    console.log(`Инициализация экрана сбора данных для пользователя: ${userId}`);
  }

  // Обработка отметки чекбокса
  async handleCheckboxToggle(itemId, itemName, isChecked) {
    try {
      const actionData = {
        itemId: itemId,
        itemName: itemName,
        isChecked: isChecked,
        timestamp: new Date().toISOString()
      };

      // Записываем действие в Airtable
      const record = await this.airtableService.recordUserAction(
        this.currentUserId,
        ACTION_TYPES.CHECKBOX_MARKED,
        actionData,
        'DataCollectionScreen'
      );

      console.log('Действие записано:', record);
      
      // Обновляем локальное состояние для мгновенного отклика
      this.updateLocalState(itemId, isChecked);
      
      return record;
    } catch (error) {
      console.error('Ошибка при сохранении действия:', error);
      throw error;
    }
  }

  // Обработка отправки формы
  async handleFormSubmit(formData) {
    try {
      const actionData = {
        formType: formData.type,
        fields: formData.fields,
        submittedAt: new Date().toISOString()
      };

      // Записываем действие отправки формы
      const record = await this.airtableService.recordUserAction(
        this.currentUserId,
        ACTION_TYPES.DATA_SUBMITTED,
        actionData,
        'DataCollectionScreen'
      );

      // Если есть несколько элементов для отметки
      if (formData.selectedItems && formData.selectedItems.length > 0) {
        const checkboxRecords = await Promise.all(
          formData.selectedItems.map(item => 
            this.airtableService.recordUserAction(
              this.currentUserId,
              ACTION_TYPES.ITEM_SELECTED,
              { itemId: item.id, itemName: item.name },
              'DataCollectionScreen'
            )
          )
        );
        
        console.log(`Создано ${checkboxRecords.length} записей о выборе элементов`);
      }

      // Агрегируем данные для отображения на других экранах
      await this.aggregateUserData();

      return record;
    } catch (error) {
      console.error('Ошибка при отправке формы:', error);
      throw error;
    }
  }

  // Агрегация данных пользователя
  async aggregateUserData() {
    try {
      // Получаем последние действия пользователя
      const recentActions = await this.airtableService.getUserActions(
        this.currentUserId, 
        20
      );

      // Извлекаем ID действий
      const actionIds = recentActions.map(record => record.id);

      // Создаем агрегированную запись для отображения
      const displayRecord = await this.airtableService.aggregateDisplayData(
        this.currentUserId,
        actionIds
      );

      console.log('Данные агрегированы для отображения:', displayRecord);
      return displayRecord;
    } catch (error) {
      console.error('Ошибка при агрегации данных:', error);
      throw error;
    }
  }

  // Обновление локального состояния (для мгновенного отклика UI)
  updateLocalState(itemId, isChecked) {
    // Эмитим событие для обновления UI
    if (typeof window !== 'undefined' && window.dispatchEvent) {
      const event = new CustomEvent('itemStateChanged', {
        detail: { itemId, isChecked }
      });
      window.dispatchEvent(event);
    }
  }

  // Получить текущее состояние всех чекбоксов
  async getCurrentCheckboxStates() {
    try {
      const actions = await this.airtableService.getUserActions(
        this.currentUserId,
        100
      );

      // Фильтруем только действия с чекбоксами
      const checkboxActions = actions.filter(
        record => record.fields.action_type === ACTION_TYPES.CHECKBOX_MARKED
      );

      // Создаем карту состояний (берем последнее состояние для каждого элемента)
      const stateMap = new Map();
      
      checkboxActions.forEach(record => {
        const actionData = JSON.parse(record.fields.action_data);
        stateMap.set(actionData.itemId, {
          isChecked: actionData.isChecked,
          lastUpdated: actionData.timestamp
        });
      });

      return stateMap;
    } catch (error) {
      console.error('Ошибка при получении состояний чекбоксов:', error);
      throw error;
    }
  }
}

// Пример использования
async function exampleUsage() {
  const screen = new DataCollectionScreen();
  
  // Инициализация для пользователя
  await screen.initialize('user123');
  
  // Пользователь отмечает чекбокс
  await screen.handleCheckboxToggle('task1', 'Выполнить упражнение', true);
  
  // Пользователь отправляет форму
  await screen.handleFormSubmit({
    type: 'daily_checklist',
    fields: {
      mood: 'good',
      energy_level: 8,
      notes: 'Чувствую себя отлично!'
    },
    selectedItems: [
      { id: 'item1', name: 'Утренняя зарядка' },
      { id: 'item2', name: 'Медитация' }
    ]
  });
}

module.exports = DataCollectionScreen;