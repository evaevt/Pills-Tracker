import Foundation
import SwiftUI

class AnalyticsService: ObservableObject {
  @Published var currentAnalytics: OverallAnalytics?
  @Published var isLoading = false

  private let calendar = Calendar.current
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
  }()

  // MARK: - Public Methods

  func calculateAnalytics(for period: AnalyticsPeriod, entries: [DailyEntry]) {
    isLoading = true

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      let analytics = self?.computeAnalytics(for: period, entries: entries)

      DispatchQueue.main.async {
        self?.currentAnalytics = analytics
        self?.isLoading = false
      }
    }
  }

  func getMockData() -> [DailyEntry] {
    // Генерируем моковые данные для демонстрации
    let calendar = Calendar.current
    var entries: [DailyEntry] = []

    for i in 0..<90 {
      let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()

      // Случайные данные с трендами
      let waterIntake = Int.random(in: 3...10)
      let moodValue = Int.random(in: 1...8)
      let mood = MoodType.allCases[moodValue - 1]

      let vitamins = VitaminState(
        vitaminB: Bool.random(),
        magnesium: Bool.random(),
        iron: Bool.random(),
        melatonin: Bool.random()
      )

      let entry = DailyEntry(
        date: date,
        waterIntake: waterIntake,
        mood: mood,
        vitamins: vitamins,
        notes: "Sample note for \(dateFormatter.string(from: date))"
      )

      entries.append(entry)
    }

    return entries.sorted { $0.date < $1.date }
  }

  // MARK: - Private Methods

  private func computeAnalytics(for period: AnalyticsPeriod, entries: [DailyEntry])
    -> OverallAnalytics
  {
    let periodEntries = filterEntries(entries, for: period)
    let previousPeriodEntries = filterEntriesForPreviousPeriod(entries, for: period)

    let waterAnalytics = calculateWaterAnalytics(
      current: periodEntries,
      previous: previousPeriodEntries
    )

    let moodAnalytics = calculateMoodAnalytics(
      current: periodEntries,
      previous: previousPeriodEntries
    )

    let vitaminAnalytics = calculateVitaminAnalytics(
      current: periodEntries,
      previous: previousPeriodEntries
    )

    return OverallAnalytics(
      period: period,
      waterAnalytics: waterAnalytics,
      moodAnalytics: moodAnalytics,
      vitaminAnalytics: vitaminAnalytics,
      totalEntries: periodEntries.count,
      dataCompleteness: Double(periodEntries.count) / Double(period.days) * 100
    )
  }

  private func filterEntries(_ entries: [DailyEntry], for period: AnalyticsPeriod) -> [DailyEntry] {
    let cutoffDate = calendar.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
    return entries.filter { $0.date >= cutoffDate }
  }

  private func filterEntriesForPreviousPeriod(_ entries: [DailyEntry], for period: AnalyticsPeriod)
    -> [DailyEntry]
  {
    let currentCutoff = calendar.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
    let previousCutoff =
      calendar.date(byAdding: .day, value: -period.days * 2, to: Date()) ?? Date()

    return entries.filter { $0.date >= previousCutoff && $0.date < currentCutoff }
  }

  private func calculateWaterAnalytics(current: [DailyEntry], previous: [DailyEntry])
    -> WaterAnalytics
  {
    let totalGlasses = current.reduce(0) { $0 + $1.waterIntake }
    let averageDaily = current.isEmpty ? 0 : Double(totalGlasses) / Double(current.count)

    let previousTotal = previous.reduce(0) { $0 + $1.waterIntake }
    let previousAverage = previous.isEmpty ? 0 : Double(previousTotal) / Double(previous.count)

    let trend = determineTrend(current: averageDaily, previous: previousAverage)
    let trendPercentage = calculateTrendPercentage(current: averageDaily, previous: previousAverage)

    let bestDay = current.max(by: { $0.waterIntake < $1.waterIntake })?.date
    let worstDay = current.min(by: { $0.waterIntake < $1.waterIntake })?.date

    let daysWithNorm = current.filter { $0.waterIntake >= 8 }.count
    let consistency = current.isEmpty ? 0 : Double(daysWithNorm) / Double(current.count) * 100

    return WaterAnalytics(
      averageDaily: averageDaily,
      totalGlasses: totalGlasses,
      totalVolume: totalGlasses * 300,
      trend: trend,
      trendPercentage: trendPercentage,
      bestDay: bestDay,
      worstDay: worstDay,
      consistency: consistency
    )
  }

  private func calculateMoodAnalytics(current: [DailyEntry], previous: [DailyEntry])
    -> MoodAnalytics
  {
    let moodScores = current.map { moodToScore($0.mood) }
    let averageScore =
      moodScores.isEmpty ? 0 : Double(moodScores.reduce(0, +)) / Double(moodScores.count)

    let previousScores = previous.map { moodToScore($0.mood) }
    let previousAverage =
      previousScores.isEmpty
      ? 0 : Double(previousScores.reduce(0, +)) / Double(previousScores.count)

    let trend = determineTrend(current: averageScore, previous: previousAverage)
    let trendPercentage = calculateTrendPercentage(current: averageScore, previous: previousAverage)

    var moodDistribution: [MoodType: Int] = [:]
    for mood in MoodType.allCases {
      moodDistribution[mood] = current.filter { $0.mood == mood }.count
    }

    let mostCommonMood = moodDistribution.max(by: { $0.value < $1.value })?.key ?? .neutral

    return MoodAnalytics(
      averageMoodScore: averageScore,
      moodDistribution: moodDistribution,
      trend: trend,
      trendPercentage: trendPercentage,
      bestMoodStreak: calculateMoodStreak(current, threshold: 6),
      currentStreak: calculateCurrentMoodStreak(current, threshold: 6),
      mostCommonMood: mostCommonMood
    )
  }

  private func calculateVitaminAnalytics(current: [DailyEntry], previous: [DailyEntry])
    -> VitaminAnalytics
  {
    return VitaminAnalytics(
      vitaminB: calculateVitaminStats("Vitamin B", current: current, previous: previous) {
        $0.vitamins.vitaminB
      },
      magnesium: calculateVitaminStats("Magnesium", current: current, previous: previous) {
        $0.vitamins.magnesium
      },
      iron: calculateVitaminStats("Iron", current: current, previous: previous) {
        $0.vitamins.iron
      },
      melatonin: calculateVitaminStats("Melatonin", current: current, previous: previous) {
        $0.vitamins.melatonin
      }
    )
  }

  private func calculateVitaminStats(
    _ name: String,
    current: [DailyEntry],
    previous: [DailyEntry],
    keyPath: (DailyEntry) -> Bool
  ) -> VitaminAnalytics.VitaminStats {

    let takenDays = current.filter(keyPath).count
    let consistency = current.isEmpty ? 0 : Double(takenDays) / Double(current.count) * 100

    let previousTakenDays = previous.filter(keyPath).count
    let previousConsistency =
      previous.isEmpty ? 0 : Double(previousTakenDays) / Double(previous.count) * 100

    let trend = determineTrend(current: consistency, previous: previousConsistency)
    let trendPercentage = calculateTrendPercentage(
      current: consistency, previous: previousConsistency)

    return VitaminAnalytics.VitaminStats(
      name: name,
      totalDays: takenDays,
      consistency: consistency,
      currentStreak: calculateVitaminStreak(current, keyPath: keyPath),
      longestStreak: calculateLongestVitaminStreak(current, keyPath: keyPath),
      trend: trend,
      trendPercentage: trendPercentage
    )
  }

  // MARK: - Helper Methods

  private func moodToScore(_ mood: MoodType) -> Int {
    switch mood {
    case .crying: return 1
    case .sad: return 2
    case .neutral: return 4
    case .cheerful: return 6
    case .good: return 7
    case .angry: return 2
    case .irritated: return 3
    case .amazing: return 8
    }
  }

  private func determineTrend(current: Double, previous: Double) -> TrendDirection {
    let difference = current - previous
    let threshold = abs(previous) * 0.05  // 5% threshold

    if abs(difference) <= threshold {
      return .stable
    } else if difference > 0 {
      return .up
    } else {
      return .down
    }
  }

  private func calculateTrendPercentage(current: Double, previous: Double) -> Double {
    guard previous != 0 else { return 0 }
    return abs((current - previous) / previous) * 100
  }

  private func calculateMoodStreak(_ entries: [DailyEntry], threshold: Int) -> Int {
    var maxStreak = 0
    var currentStreak = 0

    for entry in entries.sorted(by: { $0.date < $1.date }) {
      if moodToScore(entry.mood) >= threshold {
        currentStreak += 1
        maxStreak = max(maxStreak, currentStreak)
      } else {
        currentStreak = 0
      }
    }

    return maxStreak
  }

  private func calculateCurrentMoodStreak(_ entries: [DailyEntry], threshold: Int) -> Int {
    let sortedEntries = entries.sorted(by: { $0.date > $1.date })
    var streak = 0

    for entry in sortedEntries {
      if moodToScore(entry.mood) >= threshold {
        streak += 1
      } else {
        break
      }
    }

    return streak
  }

  private func calculateVitaminStreak(_ entries: [DailyEntry], keyPath: (DailyEntry) -> Bool) -> Int
  {
    let sortedEntries = entries.sorted(by: { $0.date > $1.date })
    var streak = 0

    for entry in sortedEntries {
      if keyPath(entry) {
        streak += 1
      } else {
        break
      }
    }

    return streak
  }

  private func calculateLongestVitaminStreak(_ entries: [DailyEntry], keyPath: (DailyEntry) -> Bool)
    -> Int
  {
    var maxStreak = 0
    var currentStreak = 0

    for entry in entries.sorted(by: { $0.date < $1.date }) {
      if keyPath(entry) {
        currentStreak += 1
        maxStreak = max(maxStreak, currentStreak)
      } else {
        currentStreak = 0
      }
    }

    return maxStreak
  }
}
