import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showSignOutAlert = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        List {
            // User Info Section
            if let user = authService.user {
                Section {
                    HStack {
                        if let photoURL = user.photoURL {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.displayName ?? "User")
                                .font(.headline)
                            Text(user.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Notifications Section
            Section("Notifications") {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        Task {
                            await toggleNotifications(enabled: newValue)
                        }
                    }
                
                NavigationLink(destination: NotificationTopicsView()) {
                    Label("Notification Topics", systemImage: "bell.badge")
                }
            }
            
            // Account Section
            Section("Account") {
                Button(action: {
                    showSignOutAlert = true
                }) {
                    Label("Sign Out", systemImage: "arrow.right.square")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    private func toggleNotifications(enabled: Bool) async {
        let pushService = DependencyContainer.shared.resolve(PushNotificationServiceProtocol.self)
        
        if enabled {
            _ = await pushService.requestNotificationPermissions()
        } else {
            // Disable notifications by unsubscribing from all topics
            // In a real app, you might want to track subscribed topics
            try? await pushService.unsubscribeFromTopic("all_users")
        }
    }
}

// Notification Topics View
struct NotificationTopicsView: View {
    @State private var trackerUpdates = true
    @State private var reminders = true
    @State private var achievements = true
    
    var body: some View {
        List {
            Section {
                Toggle("Tracker Updates", isOn: $trackerUpdates)
                    .onChange(of: trackerUpdates) { newValue in
                        Task {
                            await updateTopicSubscription("tracker_updates", subscribe: newValue)
                        }
                    }
                
                Toggle("Reminders", isOn: $reminders)
                    .onChange(of: reminders) { newValue in
                        Task {
                            await updateTopicSubscription("reminders", subscribe: newValue)
                        }
                    }
                
                Toggle("Achievements", isOn: $achievements)
                    .onChange(of: achievements) { newValue in
                        Task {
                            await updateTopicSubscription("achievements", subscribe: newValue)
                        }
                    }
            } footer: {
                Text("Choose which types of notifications you want to receive")
            }
        }
        .navigationTitle("Notification Topics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updateTopicSubscription(_ topic: String, subscribe: Bool) async {
        let pushService = DependencyContainer.shared.resolve(PushNotificationServiceProtocol.self)
        
        do {
            if subscribe {
                try await pushService.subscribeToTopic(topic)
            } else {
                try await pushService.unsubscribeFromTopic(topic)
            }
        } catch {
            print("Error updating topic subscription: \(error)")
        }
    }
}