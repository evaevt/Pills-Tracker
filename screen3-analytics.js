// Экран 3: Аналитика и анализ данных
const AirtableService = require('./airtable-service');
const { ANALYTICS_PERIODS, ACTION_TYPES, TABLES } = require('./airtable-config');

class AnalyticsScreen {
  constructor() {
    this.airtableService = new AirtableService();
    this.currentUserId = null;
    this.analyticsData = null;
  }

  // Инициализация экрана
  async initialize(userId) {
    this.currentUserId = userId;
    console.log(`Инициализация экрана аналитики для пользователя: ${userId}`);
    
    // Загружаем и анализируем данные
    await this.performAnalysis();
  }

  // Выполнение полного анализа
  async performAnalysis() {
    try {
      // Получаем все действия пользователя
      const allActions = await this.airtableService.getUserActions(
        this.currentUserId,
        1000 // Больше данных для анализа
      );

      // Получаем существующую аналитику
      const existingAnalytics = await this.getExistingAnalytics();

      // Выполняем анализ для разных периодов
      const dailyAnalysis = await this.analyzePeriod(allActions, ANALYTICS_PERIODS.DAILY);
      const weeklyAnalysis = await this.analyzePeriod(allActions, ANALYTICS_PERIODS.WEEKLY);
      const monthlyAnalysis = await this.analyzePeriod(allActions, ANALYTICS_PERIODS.MONTHLY);

      // Генерируем продвинутую аналитику
      const advancedAnalytics = this.generateAdvancedAnalytics(allActions);

      // Сохраняем результаты
      this.analyticsData = {
        daily: dailyAnalysis,
        weekly: weeklyAnalysis,
        monthly: monthlyAnalysis,
        advanced: advancedAnalytics,
        lastAnalyzed: new Date().toISOString()
      };

      // Сохраняем в Airtable
      await this.saveAnalytics();

      console.log('Анализ завершен:', this.analyticsData);
      return this.analyticsData;
    } catch (error) {
      console.error('Ошибка при выполнении анализа:', error);
      throw error;
    }
  }

  // Анализ для определенного периода
  async analyzePeriod(actions, period) {
    const now = new Date();
    let startDate;

    switch (period) {
      case ANALYTICS_PERIODS.DAILY:
        startDate = new Date(now.setDate(now.getDate() - 1));
        break;
      case ANALYTICS_PERIODS.WEEKLY:
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case ANALYTICS_PERIODS.MONTHLY:
        startDate = new Date(now.setMonth(now.getMonth() - 1));
        break;
    }

    // Фильтруем действия по периоду
    const periodActions = actions.filter(record => {
      const actionDate = new Date(record.fields.timestamp);
      return actionDate >= startDate;
    });

    // Вычисляем метрики
    const metrics = {
      total_actions: periodActions.length,
      completion_rate: this.calculateCompletionRate(periodActions),
      activity_by_type: this.groupByActionType(periodActions),
      peak_hours: this.findPeakActivityHours(periodActions),
      streak_days: this.calculateStreak(actions),
      average_daily_actions: this.calculateAverageDailyActions(periodActions, period),
      most_active_screen: this.findMostActiveScreen(periodActions),
      productivity_score: this.calculateProductivityScore(periodActions)
    };

    return {
      period: period,
      startDate: startDate.toISOString(),
      endDate: new Date().toISOString(),
      metrics: metrics,
      insights: this.generateInsights(metrics, period)
    };
  }

  // Расширенная аналитика
  generateAdvancedAnalytics(actions) {
    return {
      patterns: this.detectPatterns(actions),
      trends: this.analyzeTrends(actions),
      predictions: this.generatePredictions(actions),
      recommendations: this.generateRecommendations(actions),
      behaviorAnalysis: this.analyzeBehavior(actions)
    };
  }

  // Обнаружение паттернов в поведении
  detectPatterns(actions) {
    const patterns = {
      timePatterns: [],
      sequencePatterns: [],
      frequencyPatterns: []
    };

    // Анализ временных паттернов
    const hourlyActivity = new Map();
    actions.forEach(record => {
      const hour = new Date(record.fields.timestamp).getHours();
      hourlyActivity.set(hour, (hourlyActivity.get(hour) || 0) + 1);
    });

    // Находим часы пиковой активности
    const peakHours = Array.from(hourlyActivity.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3);

    patterns.timePatterns.push({
      type: 'peak_activity_hours',
      data: peakHours.map(([hour, count]) => ({
        hour: hour,
        activity_count: count,
        percentage: (count / actions.length * 100).toFixed(2)
      }))
    });

    // Анализ последовательностей действий
    const sequences = this.findActionSequences(actions);
    patterns.sequencePatterns = sequences;

    // Анализ частоты действий
    const dayOfWeekActivity = this.analyzeDayOfWeekActivity(actions);
    patterns.frequencyPatterns.push({
      type: 'day_of_week_activity',
      data: dayOfWeekActivity
    });

    return patterns;
  }

  // Анализ трендов
  analyzeTrends(actions) {
    const trends = {
      activity_trend: 'stable',
      completion_trend: 'improving',
      engagement_trend: 'high'
    };

    // Разделяем действия на недели
    const weeklyData = this.groupByWeek(actions);
    
    if (weeklyData.length >= 2) {
      const lastWeek = weeklyData[weeklyData.length - 1];
      const previousWeek = weeklyData[weeklyData.length - 2];

      // Тренд активности
      if (lastWeek.count > previousWeek.count * 1.1) {
        trends.activity_trend = 'increasing';
      } else if (lastWeek.count < previousWeek.count * 0.9) {
        trends.activity_trend = 'decreasing';
      }

      // Тренд завершения
      if (lastWeek.completionRate > previousWeek.completionRate) {
        trends.completion_trend = 'improving';
      } else {
        trends.completion_trend = 'declining';
      }
    }

    return trends;
  }

  // Генерация предсказаний
  generatePredictions(actions) {
    const predictions = {
      next_week_activity: 0,
      likelihood_of_maintaining_streak: 0,
      expected_completion_rate: 0
    };

    // Простое предсказание на основе среднего
    const weeklyAverage = actions.length / 4; // Предполагаем 4 недели данных
    predictions.next_week_activity = Math.round(weeklyAverage);

    // Вероятность поддержания серии
    const currentStreak = this.calculateStreak(actions);
    predictions.likelihood_of_maintaining_streak = currentStreak > 7 ? 0.8 : 0.5;

    // Ожидаемый процент завершения
    const recentCompletionRate = this.calculateCompletionRate(
      actions.slice(-50) // Последние 50 действий
    );
    predictions.expected_completion_rate = recentCompletionRate;

    return predictions;
  }

  // Генерация рекомендаций
  generateRecommendations(actions) {
    const recommendations = [];

    // Анализируем данные для рекомендаций
    const completionRate = this.calculateCompletionRate(actions);
    const peakHours = this.findPeakActivityHours(actions);
    const streak = this.calculateStreak(actions);

    // Рекомендации по завершению задач
    if (completionRate < 0.7) {
      recommendations.push({
        type: 'completion',
        priority: 'high',
        message: 'Попробуйте разбивать задачи на более мелкие подзадачи для повышения процента выполнения',
        metric: `Текущий процент выполнения: ${(completionRate * 100).toFixed(0)}%`
      });
    }

    // Рекомендации по времени активности
    if (peakHours.length > 0) {
      recommendations.push({
        type: 'timing',
        priority: 'medium',
        message: `Ваше самое продуктивное время: ${peakHours[0].hour}:00-${peakHours[0].hour + 1}:00`,
        metric: 'Планируйте важные задачи на это время'
      });
    }

    // Рекомендации по поддержанию серии
    if (streak > 0 && streak < 7) {
      recommendations.push({
        type: 'streak',
        priority: 'medium',
        message: `Отличная серия в ${streak} дней! Еще ${7 - streak} дней до недельной серии`,
        metric: 'Поддерживайте ежедневную активность'
      });
    }

    return recommendations;
  }

  // Анализ поведения пользователя
  analyzeBehavior(actions) {
    return {
      consistency_score: this.calculateConsistencyScore(actions),
      engagement_level: this.calculateEngagementLevel(actions),
      task_preferences: this.analyzeTaskPreferences(actions),
      activity_distribution: this.analyzeActivityDistribution(actions)
    };
  }

  // Вспомогательные методы для расчетов
  calculateCompletionRate(actions) {
    if (actions.length === 0) return 0;
    const completed = actions.filter(record => record.fields.completed).length;
    return completed / actions.length;
  }

  groupByActionType(actions) {
    const grouped = {};
    actions.forEach(record => {
      const type = record.fields.action_type;
      if (!grouped[type]) {
        grouped[type] = 0;
      }
      grouped[type]++;
    });
    return grouped;
  }

  findPeakActivityHours(actions) {
    const hourlyActivity = new Map();
    
    actions.forEach(record => {
      const hour = new Date(record.fields.timestamp).getHours();
      hourlyActivity.set(hour, (hourlyActivity.get(hour) || 0) + 1);
    });

    return Array.from(hourlyActivity.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([hour, count]) => ({ hour, count }));
  }

  calculateStreak(actions) {
    // Сортируем действия по дате
    const sortedActions = actions.sort((a, b) => 
      new Date(b.fields.timestamp) - new Date(a.fields.timestamp)
    );

    let streak = 0;
    let currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    for (let i = 0; i < 30; i++) { // Проверяем последние 30 дней
      const dayActions = sortedActions.filter(record => {
        const actionDate = new Date(record.fields.timestamp);
        actionDate.setHours(0, 0, 0, 0);
        return actionDate.getTime() === currentDate.getTime();
      });

      if (dayActions.length > 0) {
        streak++;
      } else if (streak > 0) {
        break; // Серия прервана
      }

      currentDate.setDate(currentDate.getDate() - 1);
    }

    return streak;
  }

  calculateAverageDailyActions(actions, period) {
    let days;
    switch (period) {
      case ANALYTICS_PERIODS.DAILY:
        days = 1;
        break;
      case ANALYTICS_PERIODS.WEEKLY:
        days = 7;
        break;
      case ANALYTICS_PERIODS.MONTHLY:
        days = 30;
        break;
    }
    return (actions.length / days).toFixed(2);
  }

  findMostActiveScreen(actions) {
    const screenActivity = {};
    
    actions.forEach(record => {
      const screen = record.fields.screen_name;
      if (!screenActivity[screen]) {
        screenActivity[screen] = 0;
      }
      screenActivity[screen]++;
    });

    const mostActive = Object.entries(screenActivity)
      .sort((a, b) => b[1] - a[1])[0];

    return mostActive ? mostActive[0] : 'Unknown';
  }

  calculateProductivityScore(actions) {
    // Простая формула продуктивности
    const completionRate = this.calculateCompletionRate(actions);
    const activityScore = Math.min(actions.length / 10, 1); // Нормализуем к 1
    const consistencyScore = this.calculateConsistencyScore(actions);

    return ((completionRate + activityScore + consistencyScore) / 3 * 100).toFixed(0);
  }

  calculateConsistencyScore(actions) {
    // Оцениваем насколько равномерно распределены действия
    const dailyActivity = {};
    
    actions.forEach(record => {
      const date = new Date(record.fields.timestamp).toDateString();
      dailyActivity[date] = (dailyActivity[date] || 0) + 1;
    });

    const activityCounts = Object.values(dailyActivity);
    if (activityCounts.length === 0) return 0;

    const average = activityCounts.reduce((a, b) => a + b, 0) / activityCounts.length;
    const variance = activityCounts.reduce((sum, count) => 
      sum + Math.pow(count - average, 2), 0) / activityCounts.length;
    
    // Чем меньше дисперсия, тем выше консистентность
    return Math.max(0, 1 - (Math.sqrt(variance) / average));
  }

  calculateEngagementLevel(actions) {
    const recentActions = actions.slice(-20);
    const diversityScore = new Set(recentActions.map(r => r.fields.action_type)).size / 4;
    const frequencyScore = Math.min(recentActions.length / 20, 1);
    
    return ((diversityScore + frequencyScore) / 2 * 100).toFixed(0);
  }

  analyzeTaskPreferences(actions) {
    const preferences = {};
    const typeCount = {};
    
    actions.forEach(record => {
      const type = record.fields.action_type;
      typeCount[type] = (typeCount[type] || 0) + 1;
    });

    const total = actions.length;
    Object.entries(typeCount).forEach(([type, count]) => {
      preferences[type] = {
        count: count,
        percentage: ((count / total) * 100).toFixed(2),
        preference_level: count > total * 0.3 ? 'high' : count > total * 0.1 ? 'medium' : 'low'
      };
    });

    return preferences;
  }

  analyzeActivityDistribution(actions) {
    const distribution = {
      by_hour: {},
      by_day_of_week: {},
      by_screen: {}
    };

    actions.forEach(record => {
      const timestamp = new Date(record.fields.timestamp);
      const hour = timestamp.getHours();
      const dayOfWeek = timestamp.getDay();
      const screen = record.fields.screen_name;

      distribution.by_hour[hour] = (distribution.by_hour[hour] || 0) + 1;
      distribution.by_day_of_week[dayOfWeek] = (distribution.by_day_of_week[dayOfWeek] || 0) + 1;
      distribution.by_screen[screen] = (distribution.by_screen[screen] || 0) + 1;
    });

    return distribution;
  }

  findActionSequences(actions) {
    const sequences = [];
    const sequenceMap = new Map();

    // Анализируем последовательности из 2-3 действий
    for (let i = 0; i < actions.length - 2; i++) {
      const sequence = [
        actions[i].fields.action_type,
        actions[i + 1].fields.action_type,
        actions[i + 2].fields.action_type
      ].join(' → ');

      sequenceMap.set(sequence, (sequenceMap.get(sequence) || 0) + 1);
    }

    // Находим частые последовательности
    Array.from(sequenceMap.entries())
      .filter(([_, count]) => count > 2)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .forEach(([sequence, count]) => {
        sequences.push({
          sequence: sequence,
          count: count,
          frequency: ((count / actions.length) * 100).toFixed(2)
        });
      });

    return sequences;
  }

  analyzeDayOfWeekActivity(actions) {
    const days = ['Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'];
    const dayActivity = {};

    actions.forEach(record => {
      const dayOfWeek = new Date(record.fields.timestamp).getDay();
      dayActivity[dayOfWeek] = (dayActivity[dayOfWeek] || 0) + 1;
    });

    return days.map((day, index) => ({
      day: day,
      activity_count: dayActivity[index] || 0,
      percentage: ((dayActivity[index] || 0) / actions.length * 100).toFixed(2)
    }));
  }

  groupByWeek(actions) {
    const weeks = [];
    const weekMap = new Map();

    actions.forEach(record => {
      const date = new Date(record.fields.timestamp);
      const weekStart = new Date(date);
      weekStart.setDate(date.getDate() - date.getDay());
      weekStart.setHours(0, 0, 0, 0);
      
      const weekKey = weekStart.toISOString();
      
      if (!weekMap.has(weekKey)) {
        weekMap.set(weekKey, {
          start: weekStart,
          actions: [],
          count: 0,
          completed: 0
        });
      }

      const week = weekMap.get(weekKey);
      week.actions.push(record);
      week.count++;
      if (record.fields.completed) {
        week.completed++;
      }
    });

    weekMap.forEach((week) => {
      week.completionRate = week.count > 0 ? week.completed / week.count : 0;
      weeks.push(week);
    });

    return weeks.sort((a, b) => a.start - b.start);
  }

  generateInsights(metrics, period) {
    const insights = [];

    // Инсайты по продуктивности
    if (metrics.productivity_score > 80) {
      insights.push(`Отличная продуктивность! Ваш показатель ${metrics.productivity_score}% за ${period}`);
    } else if (metrics.productivity_score < 50) {
      insights.push(`Есть возможности для улучшения продуктивности. Текущий показатель: ${metrics.productivity_score}%`);
    }

    // Инсайты по завершению задач
    if (metrics.completion_rate > 0.8) {
      insights.push('Превосходный показатель завершения задач!');
    }

    // Инсайты по активности
    if (metrics.average_daily_actions > 10) {
      insights.push('Высокий уровень ежедневной активности');
    }

    // Инсайты по серии дней
    if (metrics.streak_days > 7) {
      insights.push(`Поздравляем с серией в ${metrics.streak_days} дней!`);
    }

    return insights;
  }

  // Получение существующей аналитики
  async getExistingAnalytics() {
    try {
      const filterFormula = `{user_id} = '${this.currentUserId}'`;
      const options = {
        filterByFormula: filterFormula,
        sort: [{ field: 'calculated_at', direction: 'desc' }],
        maxRecords: 10
      };

      return await this.airtableService.getRecords(TABLES.ANALYTICS, options);
    } catch (error) {
      console.error('Ошибка при получении существующей аналитики:', error);
      return [];
    }
  }

  // Сохранение аналитики в Airtable
  async saveAnalytics() {
    try {
      const periods = [
        { period: ANALYTICS_PERIODS.DAILY, data: this.analyticsData.daily },
        { period: ANALYTICS_PERIODS.WEEKLY, data: this.analyticsData.weekly },
        { period: ANALYTICS_PERIODS.MONTHLY, data: this.analyticsData.monthly }
      ];

      for (const { period, data } of periods) {
        await this.airtableService.updateAnalytics(
          this.currentUserId,
          period,
          data.metrics
        );
      }

      console.log('Аналитика сохранена в Airtable');
    } catch (error) {
      console.error('Ошибка при сохранении аналитики:', error);
      throw error;
    }
  }

  // Получить текущую аналитику
  getAnalytics() {
    return this.analyticsData;
  }

  // Получить аналитику за определенный период
  getAnalyticsByPeriod(period) {
    if (!this.analyticsData) return null;
    
    switch (period) {
      case ANALYTICS_PERIODS.DAILY:
        return this.analyticsData.daily;
      case ANALYTICS_PERIODS.WEEKLY:
        return this.analyticsData.weekly;
      case ANALYTICS_PERIODS.MONTHLY:
        return this.analyticsData.monthly;
      default:
        return this.analyticsData;
    }
  }

  // Получить рекомендации
  getRecommendations() {
    return this.analyticsData?.advanced?.recommendations || [];
  }

  // Получить предсказания
  getPredictions() {
    return this.analyticsData?.advanced?.predictions || {};
  }
}

// Пример использования
async function exampleUsage() {
  const screen = new AnalyticsScreen();
  
  // Инициализация и выполнение анализа
  await screen.initialize('user123');
  
  // Получение различных аналитических данных
  const weeklyAnalytics = screen.getAnalyticsByPeriod(ANALYTICS_PERIODS.WEEKLY);
  console.log('Недельная аналитика:', weeklyAnalytics);
  
  const recommendations = screen.getRecommendations();
  console.log('Рекомендации:', recommendations);
  
  const predictions = screen.getPredictions();
  console.log('Предсказания:', predictions);
}

module.exports = AnalyticsScreen;