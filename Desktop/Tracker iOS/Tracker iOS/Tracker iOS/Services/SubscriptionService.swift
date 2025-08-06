import Combine
import Foundation
import SwiftUI

// MARK: - Subscription Service Protocol
protocol SubscriptionServiceProtocol: ObservableObject {
  var userProfile: UserProfile { get set }
  var availablePlans: [SubscriptionPlan] { get }
  var isLoading: Bool { get set }

  func loadUserProfile() async
  func updateProfile(_ profile: UserProfile) async throws
  func purchaseSubscription(_ plan: SubscriptionPlan) async throws
  func restorePurchases() async throws
  func cancelSubscription() async throws
  func checkSubscriptionStatus() async
}

// MARK: - Subscription Service Implementation
@MainActor
class SubscriptionService: SubscriptionServiceProtocol {
  @Published var userProfile: UserProfile
  @Published var isLoading: Bool = false

  let availablePlans: [SubscriptionPlan] = [
    .monthlyPremium,
    .yearlyPremium,
  ]

  private let userDefaults = UserDefaults.standard
  private let profileKey = "user_profile"

  init() {
    // Загружаем профиль из UserDefaults или создаем новый
    if let data = userDefaults.data(forKey: profileKey),
      let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
    {
      self.userProfile = profile
    } else {
      // Создаем профиль с триал периодом
      self.userProfile = UserProfile(
        name: "John Doe",
        email: "john.doe@example.com",
        subscription: SubscriptionInfo(
          status: .trial,
          trialEndDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
          isTrialActive: true
        ),
        statistics: UserStatistics(
          totalTrackers: 2,
          activeTrackers: 1,
          totalEntries: 145,
          streakDays: 12,
          joinDaysAgo: 30
        )
      )
      saveProfile()
    }
  }

  // MARK: - Profile Management

  func loadUserProfile() async {
    isLoading = true

    // Симуляция загрузки с сервера
    try? await Task.sleep(nanoseconds: 1_000_000_000)

    // Обновляем статистику
    updateStatistics()

    isLoading = false
  }

  func updateProfile(_ profile: UserProfile) async throws {
    isLoading = true

    // Симуляция отправки на сервер
    try? await Task.sleep(nanoseconds: 500_000_000)

    self.userProfile = profile
    saveProfile()

    isLoading = false
  }

  // MARK: - Subscription Management

  func purchaseSubscription(_ plan: SubscriptionPlan) async throws {
    isLoading = true

    // Симуляция покупки через App Store
    try? await Task.sleep(nanoseconds: 2_000_000_000)

    // Успешная покупка
    let startDate = Date()
    let endDate = Calendar.current.date(
      byAdding: plan.billingPeriod == .monthly ? .month : .year,
      value: 1,
      to: startDate
    )

    userProfile.subscription = SubscriptionInfo(
      status: .active,
      plan: plan,
      startDate: startDate,
      endDate: endDate,
      trialEndDate: nil,
      isTrialActive: false,
      autoRenew: true
    )

    saveProfile()
    isLoading = false
  }

  func restorePurchases() async throws {
    isLoading = true

    // Симуляция восстановления покупок
    try? await Task.sleep(nanoseconds: 1_500_000_000)

    // Для демонстрации - восстанавливаем месячную подписку
    if userProfile.subscription.status != .active {
      let startDate = Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
      let endDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())

      userProfile.subscription = SubscriptionInfo(
        status: .active,
        plan: .monthlyPremium,
        startDate: startDate,
        endDate: endDate,
        trialEndDate: nil,
        isTrialActive: false,
        autoRenew: true
      )

      saveProfile()
    }

    isLoading = false
  }

  func cancelSubscription() async throws {
    isLoading = true

    // Симуляция отмены подписки
    try? await Task.sleep(nanoseconds: 1_000_000_000)

    userProfile.subscription.status = .cancelled
    userProfile.subscription.autoRenew = false

    saveProfile()
    isLoading = false
  }

  func checkSubscriptionStatus() async {
    // Проверяем статус подписки и триала
    let now = Date()

    // Проверяем триал
    if userProfile.subscription.isTrialActive,
      let trialEnd = userProfile.subscription.trialEndDate,
      now > trialEnd
    {
      userProfile.subscription.isTrialActive = false
      userProfile.subscription.status = .free
    }

    // Проверяем активную подписку
    if userProfile.subscription.status == .active,
      let endDate = userProfile.subscription.endDate,
      now > endDate
    {
      userProfile.subscription.status = .expired
    }

    saveProfile()
  }

  // MARK: - Helper Methods

  private func saveProfile() {
    if let data = try? JSONEncoder().encode(userProfile) {
      userDefaults.set(data, forKey: profileKey)
    }
  }

  private func updateStatistics() {
    let joinDate = userProfile.joinDate
    let daysSinceJoin = Calendar.current.dateComponents([.day], from: joinDate, to: Date()).day ?? 0

    userProfile.statistics.joinDaysAgo = daysSinceJoin

    // Обновляем другие статистики (в реальном приложении из базы данных)
    userProfile.statistics.totalEntries = Int.random(in: 100...200)
    userProfile.statistics.streakDays = Int.random(in: 5...30)
  }

  // MARK: - Demo Methods

  func startTrial() {
    let trialEnd = Calendar.current.date(byAdding: .day, value: 7, to: Date())
    userProfile.subscription = SubscriptionInfo(
      status: .trial,
      trialEndDate: trialEnd,
      isTrialActive: true
    )
    saveProfile()
  }

  func simulateExpiredTrial() {
    let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    userProfile.subscription = SubscriptionInfo(
      status: .free,
      trialEndDate: yesterdayDate,
      isTrialActive: false
    )
    saveProfile()
  }

  func simulateActivePremium() {
    let startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    let endDate = Calendar.current.date(byAdding: .day, value: 20, to: Date())

    userProfile.subscription = SubscriptionInfo(
      status: .active,
      plan: .monthlyPremium,
      startDate: startDate,
      endDate: endDate,
      trialEndDate: nil,
      isTrialActive: false,
      autoRenew: true
    )
    saveProfile()
  }
}

// MARK: - Mock Subscription Service
class MockSubscriptionService: SubscriptionServiceProtocol {
  @Published var userProfile: UserProfile
  @Published var isLoading: Bool = false

  let availablePlans: [SubscriptionPlan] = [
    .monthlyPremium,
    .yearlyPremium,
  ]

  init() {
    self.userProfile = UserProfile(
      name: "Demo User",
      email: "demo@tracker.app"
    )
  }

  func loadUserProfile() async {
    // Mock implementation
  }

  func updateProfile(_ profile: UserProfile) async throws {
    self.userProfile = profile
  }

  func purchaseSubscription(_ plan: SubscriptionPlan) async throws {
    // Mock purchase
  }

  func restorePurchases() async throws {
    // Mock restore
  }

  func cancelSubscription() async throws {
    // Mock cancel
  }

  func checkSubscriptionStatus() async {
    // Mock check
  }
}
