import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
  var id = UUID()
  var name: String
  var email: String
  var avatarURL: String?
  var joinDate: Date
  var updatedAt: Date
  var preferences: ProfileUserPreferences
  var subscription: SubscriptionInfo
  var statistics: UserStatistics

  init(
    name: String = "User",
    email: String = "user@example.com",
    avatarURL: String? = nil,
    joinDate: Date = Date(),
    updatedAt: Date = Date(),
    preferences: ProfileUserPreferences = ProfileUserPreferences(),
    subscription: SubscriptionInfo = SubscriptionInfo(),
    statistics: UserStatistics = UserStatistics()
  ) {
    self.name = name
    self.email = email
    self.avatarURL = avatarURL
    self.joinDate = joinDate
    self.updatedAt = updatedAt
    self.preferences = preferences
    self.subscription = subscription
    self.statistics = statistics
  }
}

// MARK: - Profile User Preferences
struct ProfileUserPreferences: Codable {
  var theme: AppTheme = .system
  var language: String = "en"
  var notificationsEnabled: Bool = true
  var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
  var weekStartsOnMonday: Bool = true
  var units: MeasurementUnits = .metric

  enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var displayName: String {
      switch self {
      case .light: return "Light"
      case .dark: return "Dark"
      case .system: return "System"
      }
    }
  }

  enum MeasurementUnits: String, CaseIterable, Codable {
    case metric = "metric"
    case imperial = "imperial"

    var displayName: String {
      switch self {
      case .metric: return "Metric"
      case .imperial: return "Imperial"
      }
    }
  }
}

// MARK: - Subscription Info
struct SubscriptionInfo: Codable {
  var status: SubscriptionStatus
  var plan: SubscriptionPlan?
  var startDate: Date?
  var endDate: Date?
  var trialEndDate: Date?
  var isTrialActive: Bool
  var autoRenew: Bool

  init(
    status: SubscriptionStatus = .trial,
    plan: SubscriptionPlan? = nil,
    startDate: Date? = nil,
    endDate: Date? = nil,
    trialEndDate: Date? = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
    isTrialActive: Bool = true,
    autoRenew: Bool = true
  ) {
    self.status = status
    self.plan = plan
    self.startDate = startDate
    self.endDate = endDate
    self.trialEndDate = trialEndDate
    self.isTrialActive = isTrialActive
    self.autoRenew = autoRenew
  }

  var daysRemainingInTrial: Int {
    guard let trialEnd = trialEndDate, isTrialActive else { return 0 }
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day], from: now, to: trialEnd)
    return max(0, components.day ?? 0)
  }

  var formattedTrialEndDate: String {
    guard let trialEnd = trialEndDate else { return "" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: trialEnd)
  }
}

enum SubscriptionStatus: String, CaseIterable, Codable {
  case free = "free"
  case trial = "trial"
  case active = "active"
  case expired = "expired"
  case cancelled = "cancelled"

  var displayName: String {
    switch self {
    case .free: return "Free"
    case .trial: return "Trial"
    case .active: return "Premium"
    case .expired: return "Expired"
    case .cancelled: return "Cancelled"
    }
  }

  var color: Color {
    switch self {
    case .free: return .gray
    case .trial: return .orange
    case .active: return .green
    case .expired: return .red
    case .cancelled: return .red
    }
  }
}

struct SubscriptionPlan: Codable, Identifiable {
  let id: String
  let name: String
  let price: Double
  let currency: String
  let billingPeriod: BillingPeriod
  let features: [String]

  var formattedPrice: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
  }

  var billingDescription: String {
    switch billingPeriod {
    case .monthly: return "per month"
    case .yearly: return "per year"
    }
  }

  enum BillingPeriod: String, CaseIterable, Codable {
    case monthly = "monthly"
    case yearly = "yearly"

    var displayName: String {
      switch self {
      case .monthly: return "Monthly"
      case .yearly: return "Yearly"
      }
    }
  }

  static let monthlyPremium = SubscriptionPlan(
    id: "premium_monthly",
    name: "Premium",
    price: 3.5,
    currency: "USD",
    billingPeriod: .monthly,
    features: [
      "Unlimited trackers",
      "Advanced analytics",
      "Data export",
      "Cloud sync",
      "Priority support",
      "Custom themes",
    ]
  )

  static let yearlyPremium = SubscriptionPlan(
    id: "premium_yearly",
    name: "Premium",
    price: 35.0,
    currency: "USD",
    billingPeriod: .yearly,
    features: [
      "Unlimited trackers",
      "Advanced analytics",
      "Data export",
      "Cloud sync",
      "Priority support",
      "Custom themes",
      "2 months free!",
    ]
  )
}

// MARK: - User Statistics
struct UserStatistics: Codable {
  var totalTrackers: Int = 0
  var activeTrackers: Int = 0
  var totalEntries: Int = 0
  var streakDays: Int = 0
  var joinDaysAgo: Int = 0

  init(
    totalTrackers: Int = 2,
    activeTrackers: Int = 1,
    totalEntries: Int = 145,
    streakDays: Int = 12,
    joinDaysAgo: Int = 30
  ) {
    self.totalTrackers = totalTrackers
    self.activeTrackers = activeTrackers
    self.totalEntries = totalEntries
    self.streakDays = streakDays
    self.joinDaysAgo = joinDaysAgo
  }
}

// MARK: - Profile Actions
enum ProfileAction {
  case editProfile
  case manageSubscription
  case settings
  case support
  case about
  case privacy
  case terms
  case logout

  var title: String {
    switch self {
    case .editProfile: return "Edit Profile"
    case .manageSubscription: return "Manage Subscription"
    case .settings: return "Settings"
    case .support: return "Support"
    case .about: return "About"
    case .privacy: return "Privacy Policy"
    case .terms: return "Terms of Service"
    case .logout: return "Logout"
    }
  }

  var icon: String {
    switch self {
    case .editProfile: return "person.crop.circle"
    case .manageSubscription: return "creditcard"
    case .settings: return "gearshape"
    case .support: return "questionmark.circle"
    case .about: return "info.circle"
    case .privacy: return "lock.shield"
    case .terms: return "doc.text"
    case .logout: return "arrow.right.square"
    }
  }

  var color: Color {
    switch self {
    case .logout: return .red
    default: return .primary
    }
  }
}
