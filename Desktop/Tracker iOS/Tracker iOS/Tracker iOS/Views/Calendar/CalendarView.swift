import SwiftUI

struct CalendarView: View {
  @State private var selectedDate = Date()
  @State private var currentMonth = Date()
  @EnvironmentObject private var analyticsService: AnalyticsService
  @EnvironmentObject private var dayDataService: DayDataService

  private let calendar = Calendar.current
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }()

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Month Header
        HStack {
          Button(action: previousMonth) {
            Image(systemName: "chevron.left")
              .font(.title2)
              .foregroundColor(.blue)
          }

          Spacer()

          Text(dateFormatter.string(from: currentMonth))
            .font(.title2)
            .fontWeight(.semibold)

          Spacer()

          Button(action: nextMonth) {
            Image(systemName: "chevron.right")
              .font(.title2)
              .foregroundColor(.blue)
          }
        }
        .padding(.horizontal)

        // Calendar Grid
        CalendarGridView(
          currentMonth: currentMonth,
          selectedDate: $selectedDate,
          dayDataService: dayDataService
        )

        // Selected Date Info
        if let dayData = getDayData(for: selectedDate) {
          DayDetailCard(dayData: dayData)
            .padding(.horizontal)

          // Notes Block (separate) - только если есть заметки
          if !dayData.noteText.isEmpty {
            DayNotesCard(notes: dayData.noteText)
              .padding(.horizontal)
          }
        }

        Spacer(minLength: 100)
      }
      .padding(.top)
    }
  }

  private func previousMonth() {
    withAnimation(.easeInOut(duration: 0.3)) {
      currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
  }

  private func nextMonth() {
    withAnimation(.easeInOut(duration: 0.3)) {
      currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
  }

  private func getDayData(for date: Date) -> DayData? {
    let dayData = dayDataService.getDayData(for: date)
    // Показываем данные если есть хотя бы что-то (не только полный набор)
    if dayData.waterCount > 0 || dayData.selectedMood != .neutral || !dayData.noteText.isEmpty
      || dayData.vitamins.hasAnyActive
    {
      return dayData
    }
    return nil
  }
}

struct CalendarGridView: View {
  let currentMonth: Date
  @Binding var selectedDate: Date
  let dayDataService: DayDataService

  private let calendar = Calendar.current
  private let columns = Array(repeating: GridItem(.flexible()), count: 7)

  var body: some View {
    LazyVGrid(columns: columns, spacing: 10) {
      // Weekday headers
      ForEach(weekdayHeaders, id: \.self) { weekday in
        Text(weekday)
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundColor(.secondary)
      }

      // Calendar days
      ForEach(calendarDays, id: \.self) { date in
        CalendarDayView(
          date: date,
          isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
          isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
          dayData: getDayData(for: date)
        )
        .onTapGesture {
          selectedDate = date
        }
      }
    }
    .padding(.horizontal)
  }

  private var weekdayHeaders: [String] {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    return formatter.shortWeekdaySymbols
  }

  private var calendarDays: [Date] {
    guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
      let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
      let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end)
    else {
      return []
    }

    var days: [Date] = []
    var date = monthFirstWeek.start

    while date < monthLastWeek.end {
      days.append(date)
      date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    return days
  }

  private func getDayData(for date: Date) -> DayData? {
    let dayData = dayDataService.getDayData(for: date)
    // Показываем данные если есть хотя бы что-то (не только полный набор)
    if dayData.waterCount > 0 || dayData.selectedMood != .neutral || !dayData.noteText.isEmpty
      || dayData.vitamins.hasAnyActive
    {
      return dayData
    }
    return nil
  }
}

struct CalendarDayView: View {
  let date: Date
  let isSelected: Bool
  let isCurrentMonth: Bool
  let dayData: DayData?

  private let calendar = Calendar.current

  var body: some View {
    VStack(spacing: 4) {
      Text("\(calendar.component(.day, from: date))")
        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
        .foregroundColor(textColor)

      // Mood indicator
      if let dayData = dayData {
        Text(dayData.selectedMood.emoji)
          .font(.caption)
      } else {
        Circle()
          .fill(Color.clear)
          .frame(width: 6, height: 6)
      }
    }
    .frame(width: 40, height: 50)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(backgroundColor)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
    )
  }

  private var textColor: Color {
    if !isCurrentMonth {
      return .secondary
    }
    return isSelected ? .white : .primary
  }

  private var backgroundColor: Color {
    if isSelected {
      return .blue
    }
    return Color.clear
  }

  private var borderColor: Color {
    return .blue
  }
}

struct DayDetailCard: View {
  let dayData: DayData

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter
  }()

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Date header
      Text(dateFormatter.string(from: dayData.date))
        .font(.headline)
        .fontWeight(.semibold)

      // Mood
      HStack {
        Text("Mood:")
          .foregroundColor(.secondary)
        Spacer()
        HStack {
          Text(dayData.selectedMood.emoji)
          Text(dayData.selectedMood.displayName)
            .fontWeight(.medium)
        }
      }

      // Water intake
      HStack {
        Text("Water:")
          .foregroundColor(.secondary)
        Spacer()
        Text("\(dayData.waterCount) glasses")
          .fontWeight(.medium)
      }

      // Vitamins
      HStack {
        Text("Vitamins:")
          .foregroundColor(.secondary)
        Spacer()
        HStack(spacing: 8) {
          VitaminIndicator(name: "B", taken: dayData.vitamins.vitaminB)
          VitaminIndicator(name: "Mg", taken: dayData.vitamins.magnesium)
          VitaminIndicator(name: "Fe", taken: dayData.vitamins.iron)
          VitaminIndicator(name: "M", taken: dayData.vitamins.melatonin)
        }
      }

    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
  }
}

struct VitaminIndicator: View {
  let name: String
  let taken: Bool

  var body: some View {
    Text(name)
      .font(.caption)
      .fontWeight(.semibold)
      .foregroundColor(taken ? .white : .secondary)
      .frame(width: 24, height: 24)
      .background(taken ? Color.green : Color(.systemGray5))
      .clipShape(Circle())
  }
}

struct DayNotesCard: View {
  let notes: String

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: "note.text")
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 32, height: 32)

        VStack(alignment: .leading, spacing: 2) {
          Text("Daily Notes")
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          Text("Your thoughts from this day")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Spacer()
      }

      Text(notes)
        .font(.body)
        .foregroundColor(.primary)
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.white)
        .shadow(color: .blue.opacity(0.08), radius: 10, x: 0, y: 4)
    )
  }
}

#Preview {
  CalendarView()
    .environmentObject(AnalyticsService())
}
