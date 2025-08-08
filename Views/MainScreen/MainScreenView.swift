import Combine
import SwiftUI

struct MainScreenView: View {
  @StateObject private var viewModel = MainScreenViewModel()
  @EnvironmentObject private var router: AppRouter
  @EnvironmentObject private var appState: AppState

  var body: some View {
    NavigationView {
      ZStack {
        Color(.systemBackground)
          .ignoresSafeArea()

        if viewModel.trackers.isEmpty {
          emptyStateView
        } else {
          trackersList
        }
      }
      .navigationTitle("Мои трекеры")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            router.navigate(to: .constructor)
          }) {
            Image(systemName: "plus")
              .font(.title2)
              .foregroundColor(.blue)
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            router.navigate(to: .settings)
          }) {
            Image(systemName: "gearshape")
              .font(.title2)
              .foregroundColor(.blue)
          }
        }
      }
    }
    .onAppear {
      viewModel.loadTrackers()
    }
    .refreshable {
      viewModel.refreshTrackers()
    }
  }

  private var emptyStateView: some View {
    VStack(spacing: 24) {
      Image(systemName: "square.stack.3d.up")
        .font(.system(size: 64))
        .foregroundColor(.secondary)

      VStack(spacing: 8) {
        Text("Создайте свой первый трекер")
          .font(.title2)
          .fontWeight(.semibold)

        Text("Соберите персональный трекер из готовых модулей")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }

      VStack(spacing: 16) {
        Button(action: {
          router.navigate(to: .constructor)
        }) {
          HStack {
            Image(systemName: "plus")
            Text("Создать трекер")
          }
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.blue)
          .cornerRadius(12)
        }

        Button(action: {
          router.navigate(to: .templates)
        }) {
          HStack {
            Image(systemName: "square.grid.2x2")
            Text("Выбрать шаблон")
          }
          .font(.headline)
          .foregroundColor(.blue)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(12)
        }
      }
    }
    .padding(.horizontal, 32)
  }

  private var trackersList: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        ForEach(viewModel.trackers) { tracker in
          TrackerCardView(tracker: tracker) {
            router.navigate(to: .activeTracker(tracker))
          }
        }
      }
      .padding(.horizontal)
      .padding(.top, 8)
    }
  }
}

// MARK: - ViewModel

@MainActor
class MainScreenViewModel: ObservableObject {
  @Published var trackers: [PersonalTracker] = []
  @Published var isLoading = false
  @Published var error: AppError?

  private let dataService: DataServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  init() {
    self.dataService = DependencyContainer.shared.resolve(DataServiceProtocol.self)
    setupBindings()
  }

  private func setupBindings() {
    // Настройка реактивных подписок
  }

  func loadTrackers() {
    isLoading = true
    error = nil

    // Временная заглушка с примерами трекеров
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.trackers = self.createSampleTrackers()
      self.isLoading = false
    }
  }

  func refreshTrackers() {
    loadTrackers()
  }

  private func createSampleTrackers() -> [PersonalTracker] {
    [
      PersonalTracker(
        name: "Утренняя рутина",
        modules: [
          TrackerModule(type: .waterCounter, settings: ModuleSettings(goal: 8, unit: "стаканов")),
          TrackerModule(type: .simpleCheckbox, settings: ModuleSettings(customTitle: "Медитация")),
          TrackerModule(type: .stepCounter, settings: ModuleSettings(goal: 10000, unit: "шагов")),
        ],
        tags: ["здоровье", "утро"]
      ),
      PersonalTracker(
        name: "Продуктивность",
        modules: [
          TrackerModule(type: .pomodoroTimer, settings: ModuleSettings(goal: 4, unit: "сессий")),
          TrackerModule(
            type: .simpleCheckbox, settings: ModuleSettings(customTitle: "Главная задача")),
          TrackerModule(type: .ratingScale, settings: ModuleSettings(customTitle: "Энергия")),
        ],
        tags: ["работа", "фокус"]
      ),
      PersonalTracker(
        name: "Фитнес",
        modules: [
          TrackerModule(type: .calorieCounter, settings: ModuleSettings(goal: 2000, unit: "ккал")),
          TrackerModule(type: .activityTimer, settings: ModuleSettings(customTitle: "Тренировка")),
          TrackerModule(
            type: .progressBar, settings: ModuleSettings(customTitle: "Прогресс недели")),
        ],
        tags: ["спорт", "здоровье"]
      ),
    ]
  }
}

#Preview {
  MainScreenView()
    .environmentObject(AppRouter())
    .environmentObject(AppState(dataService: MockDataService()))
}
