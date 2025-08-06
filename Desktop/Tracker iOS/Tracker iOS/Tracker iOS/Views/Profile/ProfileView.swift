import SwiftUI

struct ProfileView: View {
  @EnvironmentObject private var subscriptionService: SubscriptionService
  @State private var showingEditProfile = false
  @State private var showingSubscriptionSheet = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Profile Header
          ProfileHeaderView(
            userProfile: subscriptionService.userProfile,
            onEditTapped: { showingEditProfile = true }
          )

          // Subscription Status
          SubscriptionStatusCard(
            subscription: subscriptionService.userProfile.subscription,
            onManageTapped: { showingSubscriptionSheet = true }
          )

          // Statistics
          StatisticsSection(statistics: subscriptionService.userProfile.statistics)

          // Actions
          ActionsSection()

          Spacer(minLength: 100)
        }
        .padding()
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $showingEditProfile) {
        EditProfileView()
      }
      .sheet(isPresented: $showingSubscriptionSheet) {
        SubscriptionSheetView()
      }
    }
    .task {
      await subscriptionService.loadUserProfile()
    }
  }
}

struct ProfileHeaderView: View {
  let userProfile: UserProfile
  let onEditTapped: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      // Avatar
      Button(action: onEditTapped) {
        AsyncImage(url: URL(string: userProfile.avatarURL ?? "")) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          Image(systemName: "person.circle.fill")
            .foregroundColor(.gray)
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
          Circle()
            .stroke(Color.blue, lineWidth: 3)
        )
      }

      // User Info
      VStack(spacing: 4) {
        Text(userProfile.name)
          .font(.title2)
          .fontWeight(.bold)

        Text(userProfile.email)
          .font(.subheadline)
          .foregroundColor(.secondary)

        Text("Member since \(formatJoinDate(userProfile.joinDate))")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Edit Button
      Button(action: onEditTapped) {
        HStack {
          Image(systemName: "pencil")
          Text("Edit Profile")
        }
        .font(.subheadline)
        .foregroundColor(.blue)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func formatJoinDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
}

struct SubscriptionStatusCard: View {
  let subscription: SubscriptionInfo
  let onManageTapped: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Subscription")
            .font(.headline)
            .fontWeight(.semibold)

          HStack {
            Text(subscription.status.displayName)
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(subscription.status.color)

            if subscription.isTrialActive {
              Text("• \(subscription.daysRemainingInTrial) days left")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }

        Spacer()

        Button(action: onManageTapped) {
          Text("Manage")
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
      }

      if subscription.isTrialActive {
        VStack(alignment: .leading, spacing: 8) {
          Text("Trial Period")
            .font(.subheadline)
            .fontWeight(.medium)

          Text(
            "Your free trial expires on \(subscription.formattedTrialEndDate). Upgrade to continue using premium features."
          )
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
  }
}

struct StatisticsSection: View {
  let statistics: UserStatistics

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Statistics")
        .font(.headline)
        .fontWeight(.semibold)

      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 12
      ) {
        StatisticCard(
          title: "Total Trackers",
          value: "\(statistics.totalTrackers)",
          icon: "list.clipboard",
          color: .blue
        )

        StatisticCard(
          title: "Active Trackers",
          value: "\(statistics.activeTrackers)",
          icon: "play.circle",
          color: .green
        )

        StatisticCard(
          title: "Total Entries",
          value: "\(statistics.totalEntries)",
          icon: "calendar",
          color: .orange
        )

        StatisticCard(
          title: "Current Streak",
          value: "\(statistics.streakDays) days",
          icon: "flame",
          color: .red
        )
      }
    }
  }
}

struct StatisticCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(color)

      Text(value)
        .font(.title3)
        .fontWeight(.bold)

      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

struct ActionsSection: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Settings")
        .font(.headline)
        .fontWeight(.semibold)

      VStack(spacing: 12) {
        ForEach(
          [
            ProfileAction.settings,
            ProfileAction.support,
            ProfileAction.about,
            ProfileAction.privacy,
            ProfileAction.terms,
          ], id: \.title
        ) { action in
          ActionRow(action: action)
        }

        // Logout button
        ActionRow(action: .logout)
          .foregroundColor(.red)
      }
    }
  }
}

struct ActionRow: View {
  let action: ProfileAction

  var body: some View {
    Button(action: {
      handleAction(action)
    }) {
      HStack {
        Image(systemName: action.icon)
          .foregroundColor(action.color)
          .frame(width: 24)

        Text(action.title)
          .foregroundColor(action.color)

        Spacer()

        if action != .logout {
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }

  private func handleAction(_ action: ProfileAction) {
    switch action {
    case .editProfile:
      // Handle edit profile
      break
    case .manageSubscription:
      // Handle subscription management
      break
    case .settings:
      // Handle settings
      break
    case .support:
      // Handle support
      break
    case .about:
      // Handle about
      break
    case .privacy:
      // Handle privacy policy
      break
    case .terms:
      // Handle terms of service
      break
    case .logout:
      // Handle logout
      break
    }
  }
}

#Preview {
  ProfileView()
    .environmentObject(SubscriptionService())
}
