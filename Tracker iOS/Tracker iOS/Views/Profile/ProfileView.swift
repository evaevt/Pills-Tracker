import SwiftUI

struct ProfileView: View {
  @EnvironmentObject private var subscriptionService: SubscriptionService
  @State private var showingEditProfile = false
  @State private var showingSubscriptionSheet = false
  @State private var showingSettings = false
  @State private var showingSupport = false
  @State private var showingAbout = false
  @State private var showingPrivacyPolicy = false
  @State private var showingTermsOfService = false

  var body: some View {
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

        // Actions
        ActionsSection(
          onSettingsTapped: { showingSettings = true },
          onSupportTapped: { showingSupport = true },
          onAboutTapped: { showingAbout = true },
          onPrivacyTapped: { showingPrivacyPolicy = true },
          onTermsTapped: { showingTermsOfService = true }
        )

      }
      .padding()
      .padding(.bottom, 12)
    }
    .sheet(isPresented: $showingEditProfile) {
      EditProfileView()
    }
    .sheet(isPresented: $showingSubscriptionSheet) {
      SubscriptionSheetView()
    }
    .sheet(isPresented: $showingSettings) {
      SettingsView()
    }
    .sheet(isPresented: $showingSupport) {
      SupportView()
    }
    .sheet(isPresented: $showingAbout) {
      AboutView()
    }
    .sheet(isPresented: $showingPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .sheet(isPresented: $showingTermsOfService) {
      TermsOfServiceView()
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

struct ActionsSection: View {
  let onSettingsTapped: () -> Void
  let onSupportTapped: () -> Void
  let onAboutTapped: () -> Void
  let onPrivacyTapped: () -> Void
  let onTermsTapped: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Settings")
        .font(.headline)
        .fontWeight(.semibold)

      VStack(spacing: 12) {
        ActionRow(action: .settings, onTapped: onSettingsTapped)
        ActionRow(action: .support, onTapped: onSupportTapped)
        ActionRow(action: .about, onTapped: onAboutTapped)
        ActionRow(action: .privacy, onTapped: onPrivacyTapped)
        ActionRow(action: .terms, onTapped: onTermsTapped)

        // Logout button
        ActionRow(action: .logout, onTapped: {})
          .foregroundColor(.red)
      }
    }
  }
}

struct ActionRow: View {
  let action: ProfileAction
  let onTapped: () -> Void

  var body: some View {
    Button(action: onTapped) {
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
}

#Preview {
  ProfileView()
    .environmentObject(SubscriptionService())
}
