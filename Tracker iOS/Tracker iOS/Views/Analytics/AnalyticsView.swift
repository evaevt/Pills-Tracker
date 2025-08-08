import SwiftUI

struct AnalyticsView: View {
  @EnvironmentObject private var analyticsService: AnalyticsService
  @State private var selectedPeriod: AnalyticsPeriod = .week

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Period Selector
        PeriodSelector(selectedPeriod: $selectedPeriod)
          .padding(.horizontal)

        if analyticsService.isLoading {
          ProgressView("Calculating analytics...")
            .frame(maxWidth: .infinity, minHeight: 200)
        } else if let analytics = analyticsService.currentAnalytics {
          // Analytics Content
          VStack(spacing: 20) {
            // Overview Cards
            OverviewCardsView(analytics: analytics)

            // Water Analytics
            WaterAnalyticsSection(waterAnalytics: analytics.waterAnalytics)

            // Mood Analytics
            MoodAnalyticsSection(moodAnalytics: analytics.moodAnalytics)

            // Vitamin Analytics
            VitaminAnalyticsSection(vitaminAnalytics: analytics.vitaminAnalytics)
          }
          .padding(.horizontal)
        } else {
          // Empty State
          VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
              .font(.system(size: 48))
              .foregroundColor(.secondary)

            Text("No Analytics Available")
              .font(.headline)
              .foregroundColor(.secondary)

            Text("Start tracking to see your analytics")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, minHeight: 200)
        }

      }
      .padding(.vertical, 12)
    }
    .onAppear {
      loadAnalytics()
    }
    .onChange(of: selectedPeriod) { _ in
      loadAnalytics()
    }
  }

  private func loadAnalytics() {
    let mockData = analyticsService.getMockData()
    analyticsService.calculateAnalytics(for: selectedPeriod, entries: mockData)
  }
}

struct PeriodSelector: View {
  @Binding var selectedPeriod: AnalyticsPeriod

  var body: some View {
    HStack(spacing: 12) {
      ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
        Button(action: {
          selectedPeriod = period
        }) {
          Text(period.rawValue)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(selectedPeriod == period ? .white : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(selectedPeriod == period ? Color.blue : Color.blue.opacity(0.1))
            )
        }
      }
    }
  }
}

struct OverviewCardsView: View {
  let analytics: OverallAnalytics

  var body: some View {
    VStack(spacing: 12) {
      HStack(spacing: 12) {
        MetricCard(
          title: "Total Entries",
          value: "\(analytics.totalEntries)",
          subtitle: "days tracked",
          icon: "calendar",
          color: .blue
        )

        MetricCard(
          title: "Completeness",
          value: "\(Int(analytics.dataCompleteness))%",
          subtitle: "data coverage",
          icon: "chart.pie",
          color: .green
        )
      }

      HStack(spacing: 12) {
        MetricCard(
          title: "Avg Water",
          value: String(format: "%.1f", analytics.waterAnalytics.averageDaily),
          subtitle: "glasses/day",
          icon: "drop",
          color: .cyan
        )

        MetricCard(
          title: "Avg Mood",
          value: String(format: "%.1f", analytics.moodAnalytics.averageMoodScore),
          subtitle: "out of 8",
          icon: "face.smiling",
          color: .orange
        )
      }
    }
  }
}

struct MetricCard: View {
  let title: String
  let value: String
  let subtitle: String
  let icon: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
        Spacer()
      }

      Text(value)
        .font(.title2)
        .fontWeight(.bold)

      Text(title)
        .font(.caption)
        .foregroundColor(.primary)

      Text(subtitle)
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

struct WaterAnalyticsSection: View {
  let waterAnalytics: WaterAnalytics

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader(title: "Water Intake", icon: "drop.fill", color: .cyan)

      VStack(spacing: 12) {
        // Main metrics
        HStack(spacing: 12) {
          AnalyticsMetricView(
            title: "Daily Average",
            value: String(format: "%.1f", waterAnalytics.averageDaily),
            subtitle: "glasses",
            trend: waterAnalytics.trend,
            trendValue: String(format: "%.1f%%", waterAnalytics.trendPercentage)
          )

          AnalyticsMetricView(
            title: "Consistency",
            value: String(format: "%.0f%%", waterAnalytics.consistency),
            subtitle: "goal achieved",
            trend: .stable,
            trendValue: ""
          )
        }

        // Volume info
        HStack {
          Text("Total Volume:")
            .foregroundColor(.secondary)
          Spacer()
          Text("\(waterAnalytics.totalVolume) ml")
            .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
      }
    }
  }
}

struct MoodAnalyticsSection: View {
  let moodAnalytics: MoodAnalytics

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader(title: "Mood Tracking", icon: "face.smiling.fill", color: .orange)

      VStack(spacing: 12) {
        // Main metrics
        HStack(spacing: 12) {
          AnalyticsMetricView(
            title: "Average Score",
            value: String(format: "%.1f", moodAnalytics.averageMoodScore),
            subtitle: "out of 8",
            trend: moodAnalytics.trend,
            trendValue: String(format: "%.1f%%", moodAnalytics.trendPercentage)
          )

          AnalyticsMetricView(
            title: "Current Streak",
            value: "\(moodAnalytics.currentStreak)",
            subtitle: "good days",
            trend: .stable,
            trendValue: ""
          )
        }

        // Most common mood
        HStack {
          Text("Most Common:")
            .foregroundColor(.secondary)
          Spacer()
          HStack {
            Text(moodAnalytics.mostCommonMood.emoji)
            Text(moodAnalytics.mostCommonMood.displayName)
              .fontWeight(.medium)
          }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
      }
    }
  }
}

struct VitaminAnalyticsSection: View {
  let vitaminAnalytics: VitaminAnalytics

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeader(title: "Vitamins", icon: "pills.fill", color: .green)

      VStack(spacing: 8) {
        VitaminRow(stats: vitaminAnalytics.vitaminB)
        VitaminRow(stats: vitaminAnalytics.magnesium)
        VitaminRow(stats: vitaminAnalytics.iron)
        VitaminRow(stats: vitaminAnalytics.melatonin)
      }
    }
  }
}

struct VitaminRow: View {
  let stats: VitaminAnalytics.VitaminStats

  var body: some View {
    HStack {
      Text(stats.name)
        .fontWeight(.medium)
        .frame(width: 80, alignment: .leading)

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        Text("\(Int(stats.consistency))%")
          .font(.subheadline)
          .fontWeight(.semibold)

        Text("\(stats.currentStreak) day streak")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Image(systemName: stats.trend.icon)
        .foregroundColor(stats.trend.color)
        .frame(width: 20)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}

struct SectionHeader: View {
  let title: String
  let icon: String
  let color: Color

  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(color)
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
    }
  }
}

struct AnalyticsMetricView: View {
  let title: String
  let value: String
  let subtitle: String
  let trend: TrendDirection
  let trendValue: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)

      Text(value)
        .font(.title3)
        .fontWeight(.bold)

      Text(subtitle)
        .font(.caption2)
        .foregroundColor(.secondary)

      if !trendValue.isEmpty {
        HStack(spacing: 4) {
          Image(systemName: trend.icon)
            .font(.caption)
            .foregroundColor(trend.color)
          Text(trendValue)
            .font(.caption)
            .foregroundColor(trend.color)
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.systemBackground))
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
  }
}

#Preview {
  AnalyticsView()
    .environmentObject(AnalyticsService())
}
