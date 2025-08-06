import Foundation
import SwiftUI

// MARK: - Daily Data Entry
struct DailyEntry: Codable, Identifiable {
  let id = UUID()
  let date: Date
  let waterIntake: Int  // количество стаканов воды
  let mood: MoodType
  let vitamins: VitaminState
  let notes: String
}

// MARK: - Analytics Period
enum AnalyticsPeriod: String, CaseIterable {
  case week = "7 days"
  case month = "30 days"
  case threeMonths = "3 months"

  var days: Int {
    switch self {
    case .week: return 7
    case .month: return 30
    case .threeMonths: return 90
    }
  }
}

// MARK: - Trend Direction
enum TrendDirection {
  case up, down, stable

  var icon: String {
    switch self {
    case .up: return "arrow.up.right"
    case .down: return "arrow.down.right"
    case .stable: return "minus"
    }
  }

  var color: Color {
    switch self {
    case .up: return .green
    case .down: return .red
    case .stable: return .gray
    }
  }
}

// MARK: - Water Analytics
struct WaterAnalytics {
  let averageDaily: Double
  let totalGlasses: Int
  let totalVolume: Int  // в мл
  let trend: TrendDirection
  let trendPercentage: Double
  let bestDay: Date?
  let worstDay: Date?
  let consistency: Double  // процент дней когда выпил норму
}

// MARK: - Mood Analytics
struct MoodAnalytics {
  let averageMoodScore: Double  // 1-8 где 8 это amazing
  let moodDistribution: [MoodType: Int]
  let trend: TrendDirection
  let trendPercentage: Double
  let bestMoodStreak: Int
  let currentStreak: Int
  let mostCommonMood: MoodType
}

// MARK: - Vitamin Analytics
struct VitaminAnalytics {
  let vitaminB: VitaminStats
  let magnesium: VitaminStats
  let iron: VitaminStats
  let melatonin: VitaminStats

  struct VitaminStats {
    let name: String
    let totalDays: Int
    let consistency: Double  // процент дней когда принимал
    let currentStreak: Int
    let longestStreak: Int
    let trend: TrendDirection
    let trendPercentage: Double
  }
}

// MARK: - Overall Analytics
struct OverallAnalytics {
  let period: AnalyticsPeriod
  let waterAnalytics: WaterAnalytics
  let moodAnalytics: MoodAnalytics
  let vitaminAnalytics: VitaminAnalytics
  let totalEntries: Int
  let dataCompleteness: Double  // процент дней с данными
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable {
  let id = UUID()
  let date: Date
  let value: Double
  let label: String
}

// MARK: - Analytics Metric Card
struct AnalyticsMetric {
  let title: String
  let value: String
  let subtitle: String
  let trend: TrendDirection
  let trendValue: String
  let icon: String
  let color: Color
}
