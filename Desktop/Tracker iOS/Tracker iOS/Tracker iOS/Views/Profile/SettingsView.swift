import SwiftUI

struct SettingsView: View {
  @State private var notificationsEnabled = true
  @State private var soundEnabled = true
  @State private var vibrationEnabled = true
  @State private var dailyReminderEnabled = true
  @State private var weeklyReportEnabled = false
  @State private var selectedReminderTime = Date()
  @State private var selectedTheme = AppTheme.system
  @State private var selectedLanguage = AppLanguage.english
  
  var body: some View {
    NavigationView {
      List {
        // Notifications Section
        Section("Notifications") {
          HStack {
            Image(systemName: "bell")
              .foregroundColor(.blue)
              .frame(width: 24)
            
            VStack(alignment: .leading) {
              Text("Push Notifications")
                .font(.body)
              Text("Get notified about your daily progress")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $notificationsEnabled)
          }
          
          if notificationsEnabled {
            HStack {
              Image(systemName: "speaker.wave.2")
                .foregroundColor(.orange)
                .frame(width: 24)
              
              Text("Sound")
              
              Spacer()
              
              Toggle("", isOn: $soundEnabled)
            }
            
            HStack {
              Image(systemName: "iphone.radiowaves.left.and.right")
                .foregroundColor(.purple)
                .frame(width: 24)
              
              Text("Vibration")
              
              Spacer()
              
              Toggle("", isOn: $vibrationEnabled)
            }
          }
        }
        
        // Reminders Section
        Section("Reminders") {
          HStack {
            Image(systemName: "clock")
              .foregroundColor(.green)
              .frame(width: 24)
            
            VStack(alignment: .leading) {
              Text("Daily Reminder")
                .font(.body)
              Text("Remind me to track my progress")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $dailyReminderEnabled)
          }
          
          if dailyReminderEnabled {
            HStack {
              Image(systemName: "clock.badge")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text("Reminder Time")
              
              Spacer()
              
              DatePicker("", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            }
          }
          
          HStack {
            Image(systemName: "chart.bar")
              .foregroundColor(.indigo)
              .frame(width: 24)
            
            VStack(alignment: .leading) {
              Text("Weekly Report")
                .font(.body)
              Text("Get weekly summary via email")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $weeklyReportEnabled)
          }
        }
        
        // Appearance Section
        Section("Appearance") {
          HStack {
            Image(systemName: "paintbrush")
              .foregroundColor(.pink)
              .frame(width: 24)
            
            Text("Theme")
            
            Spacer()
            
            Picker("Theme", selection: $selectedTheme) {
              ForEach(AppTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
              }
            }
            .pickerStyle(.menu)
          }
          
          HStack {
            Image(systemName: "globe")
              .foregroundColor(.cyan)
              .frame(width: 24)
            
            Text("Language")
            
            Spacer()
            
            Picker("Language", selection: $selectedLanguage) {
              ForEach(AppLanguage.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
              }
            }
            .pickerStyle(.menu)
          }
        }
        
        // Data Section
        Section("Data") {
          HStack {
            Image(systemName: "icloud")
              .foregroundColor(.blue)
              .frame(width: 24)
            
            VStack(alignment: .leading) {
              Text("iCloud Sync")
                .font(.body)
              Text("Sync your data across devices")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
          }
          
          Button(action: {
            // Export data action
          }) {
            HStack {
              Image(systemName: "square.and.arrow.up")
                .foregroundColor(.orange)
                .frame(width: 24)
              
              Text("Export Data")
                .foregroundColor(.primary)
              
              Spacer()
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          
          Button(action: {
            // Clear data action with confirmation
          }) {
            HStack {
              Image(systemName: "trash")
                .foregroundColor(.red)
                .frame(width: 24)
              
              Text("Clear All Data")
                .foregroundColor(.red)
              
              Spacer()
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

// MARK: - Supporting Enums

enum AppTheme: String, CaseIterable {
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

enum AppLanguage: String, CaseIterable {
  case english = "en"
  case spanish = "es"
  case french = "fr"
  case german = "de"
  case russian = "ru"
  
  var displayName: String {
    switch self {
    case .english: return "English"
    case .spanish: return "Español"
    case .french: return "Français"
    case .german: return "Deutsch"
    case .russian: return "Русский"
    }
  }
}

#Preview {
  SettingsView()
}
