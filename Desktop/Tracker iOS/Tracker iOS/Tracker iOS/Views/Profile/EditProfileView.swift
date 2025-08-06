import SwiftUI

struct EditProfileView: View {
  @EnvironmentObject private var subscriptionService: SubscriptionService
  @Environment(\.dismiss) private var dismiss

  @State private var name: String = ""
  @State private var email: String = ""
  @State private var notificationsEnabled: Bool = true
  @State private var selectedTheme: ProfileUserPreferences.AppTheme = .system
  @State private var reminderTime: Date = Date()
  @State private var weekStartsOnMonday: Bool = true

  @State private var isLoading = false
  @State private var showingAlert = false
  @State private var alertMessage = ""

  var body: some View {
    NavigationView {
      Form {
        // Personal Information
        Section("Personal Information") {
          HStack {
            Image(systemName: "person.circle.fill")
              .foregroundColor(.blue)
              .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
              TextField("Name", text: $name)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.headline)

              TextField("Email", text: $email)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            }
          }
          .padding(.vertical, 8)
        }

        // App Preferences
        Section("Preferences") {
          // Theme Selection
          HStack {
            Image(systemName: "paintbrush.fill")
              .foregroundColor(.purple)
              .frame(width: 24)

            Text("Theme")

            Spacer()

            Picker("Theme", selection: $selectedTheme) {
              ForEach(ProfileUserPreferences.AppTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
              }
            }
            .pickerStyle(MenuPickerStyle())
          }

          // Notifications
          HStack {
            Image(systemName: "bell.fill")
              .foregroundColor(.orange)
              .frame(width: 24)

            Text("Notifications")

            Spacer()

            Toggle("", isOn: $notificationsEnabled)
          }

          // Reminder Time
          if notificationsEnabled {
            HStack {
              Image(systemName: "clock.fill")
                .foregroundColor(.blue)
                .frame(width: 24)

              Text("Daily Reminder")

              Spacer()

              DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            }
          }

          // Week Start
          HStack {
            Image(systemName: "calendar")
              .foregroundColor(.green)
              .frame(width: 24)

            Text("Week starts on Monday")

            Spacer()

            Toggle("", isOn: $weekStartsOnMonday)
          }
        }

        // Account Information
        Section("Account") {
          HStack {
            Image(systemName: "calendar.badge.plus")
              .foregroundColor(.blue)
              .frame(width: 24)

            Text("Member since")

            Spacer()

            Text(formatDate(subscriptionService.userProfile.joinDate))
              .foregroundColor(.secondary)
          }

          HStack {
            Image(systemName: "crown.fill")
              .foregroundColor(.yellow)
              .frame(width: 24)

            Text("Subscription")

            Spacer()

            Text(subscriptionService.userProfile.subscription.status.displayName)
              .foregroundColor(subscriptionService.userProfile.subscription.status.color)
              .fontWeight(.medium)
          }
        }
      }
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            saveProfile()
          }
          .disabled(isLoading || name.isEmpty || email.isEmpty)
        }
      }
      .onAppear {
        loadCurrentValues()
      }
      .disabled(isLoading)
      .overlay {
        if isLoading {
          Color.black.opacity(0.3)
            .ignoresSafeArea()

          ProgressView("Saving...")
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
      }
      .alert("Profile Update", isPresented: $showingAlert) {
        Button("OK") {}
      } message: {
        Text(alertMessage)
      }
    }
  }

  private func loadCurrentValues() {
    let profile = subscriptionService.userProfile
    name = profile.name
    email = profile.email
    notificationsEnabled = profile.preferences.notificationsEnabled
    selectedTheme = profile.preferences.theme
    reminderTime = profile.preferences.reminderTime
    weekStartsOnMonday = profile.preferences.weekStartsOnMonday
  }

  private func saveProfile() {
    isLoading = true

    var updatedProfile = subscriptionService.userProfile
    updatedProfile.name = name
    updatedProfile.email = email
    updatedProfile.updatedAt = Date()

    updatedProfile.preferences.notificationsEnabled = notificationsEnabled
    updatedProfile.preferences.theme = selectedTheme
    updatedProfile.preferences.reminderTime = reminderTime
    updatedProfile.preferences.weekStartsOnMonday = weekStartsOnMonday

    Task {
      do {
        try await subscriptionService.updateProfile(updatedProfile)

        await MainActor.run {
          isLoading = false
          alertMessage = "Profile updated successfully!"
          showingAlert = true

          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertMessage = "Failed to update profile. Please try again."
          showingAlert = true
        }
      }
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
}

#Preview {
  EditProfileView()
    .environmentObject(SubscriptionService())
}
