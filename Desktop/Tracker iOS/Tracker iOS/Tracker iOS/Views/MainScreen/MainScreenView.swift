import Combine
import SwiftUI

struct MainScreenView: View {
  @StateObject private var viewModel = MainScreenViewModel()
  @EnvironmentObject private var router: AppRouter
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var firebaseService: FirebaseService
  @EnvironmentObject private var dayDataService: DayDataService

  @State private var showingAlert = false
  @State private var alertMessage = ""
  @State private var isEditingVitamins = false
  @State private var editableVitaminNames = VitaminNames()
  // Убираем локальное состояние, используем из DayData

  var body: some View {
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 20) {
          // Interactive Calendar
          interactiveCalendarView
            .frame(maxWidth: .infinity)  // Центрируем календарь

          // Water Tracker
          waterTrackerView
            .frame(maxWidth: .infinity)  // Центрируем трекер воды

          // Vitamin Tracker
          vitaminTrackerView
            .frame(maxWidth: .infinity)  // Центрируем витамины

          // Mood Tracker
          moodTrackerView
            .frame(maxWidth: .infinity)  // Центрируем настроение

          // Notes
          notesView
            .frame(maxWidth: .infinity)  // Центрируем заметки

          // Save Button
          saveButton
            .frame(maxWidth: .infinity)  // Центрируем кнопку

          Spacer(minLength: 100)
        }
        .padding(.horizontal, 20)  // Увеличенные симметричные отступы
        .padding(.top, 12)
        .frame(maxWidth: geometry.size.width)  // Используем точную ширину экрана
      }
    }
    .navigationBarHidden(true)
    .background(Color(.systemBackground))
    .alert("Info", isPresented: $showingAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage)
    }
  }

  // MARK: - Interactive Calendar View
  private var interactiveCalendarView: some View {
    VStack(spacing: 12) {
      // Month navigation
      HStack {
        Button(action: previousWeek) {
          Image(systemName: "chevron.left")
            .font(.title2)
            .foregroundColor(.blue)
        }

        Spacer()

        Text(monthYearText)
          .font(.title2)
          .fontWeight(.semibold)

        Spacer()

        Button(action: nextWeek) {
          Image(systemName: "chevron.right")
            .font(.title2)
            .foregroundColor(.blue)
        }
      }
      .padding(.horizontal, 8)

      // Week calendar with date selection
      HStack(spacing: 8) {
        ForEach(getCurrentWeek(), id: \.self) { date in
          VStack(spacing: 4) {
            Text(dayName(for: date))
              .font(.footnote)
              .fontWeight(.medium)
              .foregroundColor(.secondary)

            Text("\(Calendar.current.component(.day, from: date))")
              .font(.title2)
              .fontWeight(isSelected(date) ? .bold : .semibold)
              .foregroundColor(isSelected(date) ? .white : (isToday(date) ? .blue : .primary))

            // Data indicator
            if dayDataService.getDayData(for: date).hasData {
              Circle()
                .fill(.blue)
                .frame(width: 6, height: 6)
            } else {
              Circle()
                .fill(.clear)
                .frame(width: 6, height: 6)
            }
          }
          .frame(width: 44, height: 80)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(
                isSelected(date)
                  ? Color.blue : (isToday(date) ? Color.blue.opacity(0.1) : Color.clear))
          )
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
              dayDataService.selectDate(date)
            }
          }
        }
      }
      .padding(.horizontal, 8)

      // Selected date info
      Text(selectedDateText)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.top, 4)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    )
  }

  // MARK: - Water Tracker
  private var waterTrackerView: some View {
    HStack(spacing: 12) {
      // Modern Water Action Button
      Button(action: {
        withAnimation(.easeInOut(duration: 0.2)) {
          if dayDataService.currentDayData.waterCount < 10 {
            dayDataService.updateCurrentDayData(
              waterCount: dayDataService.currentDayData.waterCount + 1)
          }
        }
      }) {
        ZStack {
          LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 1.0), Color.blue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .frame(width: 70, height: 90)
          .cornerRadius(18)
          .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)

          VStack(spacing: 8) {
            Image(systemName: "cup.and.saucer.fill")
              .font(.title2)
              .foregroundColor(.white)

            Text("+")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)
          }
        }
      }
      .buttonStyle(PlainButtonStyle())
      .onLongPressGesture {
        withAnimation(.easeInOut(duration: 0.3)) {
          dayDataService.updateCurrentDayData(waterCount: 0)
        }
      }

      // Progress Section
      VStack(alignment: .leading, spacing: 12) {
        // Header
        HStack {
          Text("Water Intake")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)

          Spacer()

          Text("\(dayDataService.currentDayData.waterCount)/10")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.blue)
        }

        // Modern Progress Circles - Adaptive Grid
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5), spacing: 6
        ) {
          ForEach(0..<10, id: \.self) { index in
            Circle()
              .fill(
                index < dayDataService.currentDayData.waterCount
                  ? LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 1.0), Color.blue]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                  : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.25)]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
              )
              .frame(width: 16, height: 16)
              .shadow(
                color: index < dayDataService.currentDayData.waterCount
                  ? .blue.opacity(0.3) : .clear,
                radius: 2, x: 0, y: 1
              )
          }
        }

        // Progress Text
        Text("\(dayDataService.currentDayData.waterCount * 300) ml / 3000 ml")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    )
    .frame(maxWidth: .infinity, alignment: .center)  // Центрируем содержимое
  }

  // MARK: - Vitamin Tracker
  private var vitaminTrackerView: some View {
    VStack(alignment: .leading, spacing: 20) {
      // Header with edit button
      HStack {
        Text("Vitamins")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.white)

        Spacer()

        Button(action: {
          if isEditingVitamins {
            // Save changes
            dayDataService.updateVitaminNames(editableVitaminNames)
            withAnimation(.easeInOut(duration: 0.3)) {
              isEditingVitamins = false
            }
          } else {
            // Start editing
            editableVitaminNames = dayDataService.vitaminNames
            withAnimation(.easeInOut(duration: 0.3)) {
              isEditingVitamins = true
            }
          }
        }) {
          ZStack {
            Circle()
              .fill(Color.white.opacity(0.2))
              .frame(width: 36, height: 36)

            Image(systemName: isEditingVitamins ? "checkmark" : "pencil")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.white)
          }
        }
        .buttonStyle(PlainButtonStyle())
      }

      // Vitamin list
      VStack(alignment: .leading, spacing: 12) {
        if isEditingVitamins {
          // Edit mode
          ForEach(VitaminKey.allCases, id: \.self) { vitaminKey in
            editableVitaminRow(for: vitaminKey)
          }
        } else {
          // Normal mode
          ForEach(VitaminKey.allCases, id: \.self) { vitaminKey in
            modernVitaminRow(
              dayDataService.vitaminNames.getName(for: vitaminKey),
              isActive: getVitaminState(for: vitaminKey)
            ) {
              toggleVitamin(vitaminKey)
            }
          }
        }
      }
    }
    .padding(18)
    .background(
      LinearGradient(
        gradient: Gradient(colors: [
          Color(red: 0.9, green: 0.4, blue: 0.9), Color(red: 0.8, green: 0.2, blue: 0.8),
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .cornerRadius(20)
      .shadow(color: .purple.opacity(0.3), radius: 12, x: 0, y: 6)
    )
  }

  private func vitaminRow(_ name: String, isActive: Bool, action: @escaping () -> Void) -> some View
  {
    HStack {
      Text(name)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.primary)

      Spacer()

      Button(action: {
        withAnimation(.spring()) {
          action()
        }
      }) {
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(isActive ? Color.green : Color.gray.opacity(0.3))
            .frame(width: 44, height: 24)

          Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .offset(x: isActive ? 10 : -10)
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  private func modernVitaminRow(_ name: String, isActive: Bool, action: @escaping () -> Void)
    -> some View
  {
    HStack(spacing: 12) {
      // Vitamin icon
      ZStack {
        Circle()
          .fill(Color.white.opacity(0.2))
          .frame(width: 32, height: 32)

        Text(String(name.prefix(1)))
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(.white)
      }

      // Vitamin name
      Text(name)
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(.white)
        .lineLimit(1)

      Spacer()

      // Modern toggle switch
      Button(action: {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          action()
        }
      }) {
        ZStack {
          RoundedRectangle(cornerRadius: 14)
            .fill(isActive ? Color.white : Color.white.opacity(0.3))
            .frame(width: 44, height: 26)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

          Circle()
            .fill(isActive ? Color.purple : Color.gray.opacity(0.6))
            .frame(width: 20, height: 20)
            .offset(x: isActive ? 9 : -9)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .padding(.vertical, 2)
  }

  private func editableVitaminRow(for vitaminKey: VitaminKey) -> some View {
    HStack {
      TextField(
        "Vitamin name",
        text: Binding(
          get: { editableVitaminNames.getName(for: vitaminKey) },
          set: { newValue in
            editableVitaminNames.setName(for: vitaminKey, name: newValue)
          }
        )
      )
      .font(.system(size: 16, weight: .medium))
      .textFieldStyle(RoundedBorderTextFieldStyle())

      Spacer()

      // Disabled switch in edit mode
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.3))
          .frame(width: 44, height: 24)

        Circle()
          .fill(Color.white)
          .frame(width: 20, height: 20)
          .offset(x: -10)
      }
      .opacity(0.5)
    }
  }

  private func getVitaminState(for vitaminKey: VitaminKey) -> Bool {
    switch vitaminKey {
    case .vitaminB: return dayDataService.currentDayData.vitamins.vitaminB
    case .magnesium: return dayDataService.currentDayData.vitamins.magnesium
    case .iron: return dayDataService.currentDayData.vitamins.iron
    case .melatonin: return dayDataService.currentDayData.vitamins.melatonin
    }
  }

  private func toggleVitamin(_ vitaminKey: VitaminKey) {
    var newVitamins = dayDataService.currentDayData.vitamins
    switch vitaminKey {
    case .vitaminB: newVitamins.vitaminB.toggle()
    case .magnesium: newVitamins.magnesium.toggle()
    case .iron: newVitamins.iron.toggle()
    case .melatonin: newVitamins.melatonin.toggle()
    }
    dayDataService.updateCurrentDayData(vitamins: newVitamins)
  }

  // MARK: - Mood Tracker
  private var moodTrackerView: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(alignment: .leading, spacing: 4) {
        Text("How are you")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.primary)

        Text("feeling today?")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.primary)
      }

      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            ForEach(MoodType.allCases, id: \.self) { mood in
              Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                  dayDataService.updateCurrentDayData(selectedMood: mood)
                }
              }) {
                VStack(spacing: 8) {
                  ZStack {
                    Circle()
                      .fill(
                        dayDataService.currentDayData.selectedMood == mood
                          ? Color.orange.opacity(0.15) : Color.gray.opacity(0.08)
                      )
                      .frame(width: 64, height: 64)
                      .shadow(
                        color: dayDataService.currentDayData.selectedMood == mood
                          ? Color.orange.opacity(0.3) : .clear,
                        radius: 8, x: 0, y: 4
                      )

                    Text(mood.emoji)
                      .font(.title)
                      .scaleEffect(dayDataService.currentDayData.selectedMood == mood ? 1.1 : 1.0)
                  }

                  Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(
                      dayDataService.currentDayData.selectedMood == mood ? .orange : .secondary
                    )
                }
              }
              .buttonStyle(PlainButtonStyle())
              .id(mood)
            }
          }
          .padding(.horizontal, 4)
        }
        .padding(.horizontal, 8)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.5)) {
              proxy.scrollTo(dayDataService.currentDayData.selectedMood, anchor: .center)
            }
          }
        }
      }
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.white)
        .shadow(color: .orange.opacity(0.1), radius: 12, x: 0, y: 6)
    )
  }

  // MARK: - Notes View
  private var notesView: some View {
    VStack(alignment: .leading, spacing: 20) {
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

          Text("What's on your mind today?")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Spacer()

        // Показываем кнопку редактирования только когда заметка сохранена
        if dayDataService.currentDayData.isNoteSaved
          && !dayDataService.currentDayData.noteText.isEmpty
        {
          Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
              dayDataService.updateCurrentDayData(isNoteSaved: false)
            }
          }) {
            Image(systemName: "pencil.circle")
              .font(.title3)
              .foregroundColor(.blue)
          }
        }
      }

      if dayDataService.currentDayData.isNoteSaved
        && !dayDataService.currentDayData.noteText.isEmpty
      {
        // Saved note card
        Text(dayDataService.currentDayData.noteText)
          .font(.body)
          .foregroundColor(.primary)
          .padding(16)
          .background(Color.blue.opacity(0.05))
          .cornerRadius(12)
      } else {
        // Editable text field
        TextEditor(
          text: Binding(
            get: { dayDataService.currentDayData.noteText },
            set: { newValue in
              dayDataService.updateCurrentDayData(noteText: newValue)
            }
          )
        )
        .frame(minHeight: 100)
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 1)
        )
        .overlay(
          Group {
            if dayDataService.currentDayData.noteText.isEmpty {
              Text("Write down your thoughts, ideas, or reflections...")
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .allowsHitTesting(false)
            }
          },
          alignment: .topLeading
        )
      }
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.white)
        .shadow(color: .blue.opacity(0.08), radius: 10, x: 0, y: 4)
    )
  }

  // MARK: - Save Button
  private var saveButton: some View {
    Button(action: {
      Task {
        await saveDayData()
      }
    }) {
      HStack {
        if firebaseService.isLoading {
          ProgressView()
            .scaleEffect(0.8)
            .tint(.white)
        }

        Text(firebaseService.isLoading ? "Saving..." : "Save Today's Data")
          .fontWeight(.semibold)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.pink)
      )
      .foregroundColor(.white)
    }
    .disabled(firebaseService.isLoading)
    .padding(.horizontal, 16)
  }

  // MARK: - Helper Methods

  private var monthYearText: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: dayDataService.currentDate)
  }

  private var selectedDateText: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: dayDataService.currentDate)
  }

  private func getCurrentWeek() -> [Date] {
    let calendar = Calendar.current
    let today = dayDataService.currentDate
    let weekday = calendar.component(.weekday, from: today)
    let daysFromMonday = weekday == 1 ? 6 : weekday - 2
    let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today

    return (0..<7).compactMap { offset in
      calendar.date(byAdding: .day, value: offset, to: startOfWeek)
    }
  }

  private func previousWeek() {
    let newDate =
      Calendar.current.date(byAdding: .day, value: -7, to: dayDataService.currentDate)
      ?? dayDataService.currentDate
    dayDataService.selectDate(newDate)
  }

  private func nextWeek() {
    let newDate =
      Calendar.current.date(byAdding: .day, value: 7, to: dayDataService.currentDate)
      ?? dayDataService.currentDate
    dayDataService.selectDate(newDate)
  }

  private func dayName(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
  }

  private func isToday(_ date: Date) -> Bool {
    Calendar.current.isDate(date, inSameDayAs: Date())
  }

  private func isSelected(_ date: Date) -> Bool {
    Calendar.current.isDate(date, inSameDayAs: dayDataService.currentDate)
  }

  // MARK: - Data Saving Methods
  private func saveDayData() async {
    let currentData = dayDataService.currentDayData

    do {
      // Save mood
      let moodEntry = MoodEntry(
        date: currentData.date, moodType: currentData.selectedMood,
        note: currentData.noteText.isEmpty ? nil : currentData.noteText)
      try await firebaseService.saveEntry(moodEntry, to: "mood_entries")

      // Save water
      if currentData.waterCount > 0 {
        let waterEntry = WaterEntry(date: currentData.date, count: currentData.waterCount)
        try await firebaseService.saveEntry(waterEntry, to: "water_entries")
      }

      // Save vitamins
      let vitaminEntry = VitaminEntry(date: currentData.date, vitamins: currentData.vitamins)
      try await firebaseService.saveEntry(vitaminEntry, to: "vitamin_entries")

      // Показываем сохраненную заметку вместо alert
      if !currentData.noteText.isEmpty {
        withAnimation(.easeInOut(duration: 0.5)) {
          dayDataService.updateCurrentDayData(isNoteSaved: true)
        }
      }

    } catch {
      alertMessage = "Failed to save data: \(error.localizedDescription)"
      showingAlert = true
    }
  }
}

// MARK: - Supporting Types
enum MoodType: String, CaseIterable, Hashable, Codable {
  case crying, sad, neutral, cheerful, good, angry, irritated, amazing

  var emoji: String {
    switch self {
    case .angry: return "😡"
    case .irritated: return "😤"
    case .crying: return "😭"
    case .sad: return "😔"
    case .neutral: return "😐"
    case .cheerful: return "😄"
    case .good: return "😊"
    case .amazing: return "🤩"
    }
  }

  var color: Color {
    switch self {
    case .angry: return .red
    case .irritated: return .orange
    case .crying: return .purple
    case .sad: return .blue
    case .neutral: return .gray
    case .cheerful: return .yellow
    case .good: return .mint
    case .amazing: return .green
    }
  }

  var name: String {
    switch self {
    case .angry: return "Angry"
    case .irritated: return "Irritated"
    case .crying: return "Crying"
    case .sad: return "Sad"
    case .neutral: return "Neutral"
    case .cheerful: return "Cheerful"
    case .good: return "Good"
    case .amazing: return "Amazing"
    }
  }

  var displayName: String {
    switch self {
    case .angry: return "Angry"
    case .irritated: return "Irritated"
    case .crying: return "Crying"
    case .sad: return "Sad"
    case .neutral: return "Neutral"
    case .cheerful: return "Cheerful"
    case .good: return "Good"
    case .amazing: return "Amazing"
    }
  }
}

struct VitaminState: Codable {
  var vitaminB = false
  var magnesium = false
  var iron = false
  var melatonin = false
}

// MARK: - ViewModel
@MainActor
class MainScreenViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var error: AppError?

  init() {
    // Initialization
  }
}

// MARK: - Preview
struct MainScreenView_Previews: PreviewProvider {
  static var previews: some View {
    MainScreenView()
      .environmentObject(AppRouter())
      .environmentObject(AppState(dataService: MockDataService()))
      .environmentObject(DayDataService())
  }
}
