import SwiftUI

struct AboutView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 32) {
          // App Icon and Name
          VStack(spacing: 16) {
            // App Icon
            RoundedRectangle(cornerRadius: 22)
              .fill(
                LinearGradient(
                  colors: [.blue, .purple],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 100, height: 100)
              .overlay(
                Image(systemName: "pills.fill")
                  .font(.system(size: 50))
                  .foregroundColor(.white)
              )
              .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 4) {
              Text("Pills Tracker")
                .font(.title)
                .fontWeight(.bold)
              
              Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          .padding(.top, 20)
          
          // Description
          VStack(alignment: .leading, spacing: 16) {
            Text("About Pills Tracker")
              .font(.headline)
              .fontWeight(.semibold)
            
            Text("Pills Tracker is your personal health companion designed to help you maintain consistent medication routines and track your wellness journey. With intuitive design and powerful features, staying on top of your health has never been easier.")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.leading)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // Features
          VStack(alignment: .leading, spacing: 20) {
            Text("Key Features")
              .font(.headline)
              .fontWeight(.semibold)
            
            VStack(spacing: 16) {
              FeatureRow(
                icon: "pills.fill",
                iconColor: .blue,
                title: "Medication Tracking",
                description: "Track your vitamins and supplements with easy toggles"
              )
              
              FeatureRow(
                icon: "drop.fill",
                iconColor: .cyan,
                title: "Water Intake",
                description: "Monitor your daily hydration with visual progress"
              )
              
              FeatureRow(
                icon: "face.smiling",
                iconColor: .yellow,
                title: "Mood Tracking",
                description: "Record your daily mood and emotional well-being"
              )
              
              FeatureRow(
                icon: "note.text",
                iconColor: .green,
                title: "Daily Notes",
                description: "Keep personal notes and reflections for each day"
              )
              
              FeatureRow(
                icon: "calendar",
                iconColor: .orange,
                title: "Calendar View",
                description: "Review your progress over time with calendar overview"
              )
              
              FeatureRow(
                icon: "chart.bar.fill",
                iconColor: .purple,
                title: "Analytics",
                description: "Gain insights into your health patterns and trends"
              )
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // Developer Info
          VStack(alignment: .leading, spacing: 16) {
            Text("Developer")
              .font(.headline)
              .fontWeight(.semibold)
            
            VStack(spacing: 12) {
              HStack {
                Image(systemName: "person.circle.fill")
                  .font(.title2)
                  .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text("Eva Development Team")
                    .font(.body)
                    .fontWeight(.medium)
                  
                  Text("Dedicated to your health and wellness")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
              }
              
              HStack {
                Image(systemName: "envelope.fill")
                  .font(.body)
                  .foregroundColor(.blue)
                
                Text("contact@pillstracker.com")
                  .font(.body)
                  .foregroundColor(.blue)
                
                Spacer()
              }
              .onTapGesture {
                if let url = URL(string: "mailto:contact@pillstracker.com") {
                  UIApplication.shared.open(url)
                }
              }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // Acknowledgments
          VStack(alignment: .leading, spacing: 16) {
            Text("Acknowledgments")
              .font(.headline)
              .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
              Text("Built with ❤️ using:")
                .font(.body)
                .foregroundColor(.secondary)
              
              VStack(alignment: .leading, spacing: 4) {
                Text("• SwiftUI - Apple's modern UI framework")
                Text("• Firebase - Backend and authentication services")
                Text("• SF Symbols - Beautiful iconography")
                Text("• Core Data - Local data persistence")
              }
              .font(.caption)
              .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          // Copyright
          VStack(spacing: 8) {
            Text("© 2025 Pills Tracker")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Text("Made with care for your health journey")
              .font(.caption)
              .foregroundColor(.secondary)
              .italic()
          }
          .padding(.bottom, 20)
        }
        .padding()
      }
      .navigationTitle("About")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

// MARK: - Supporting Views

struct FeatureRow: View {
  let icon: String
  let iconColor: Color
  let title: String
  let description: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(iconColor)
        .frame(width: 32, height: 32)
        .background(iconColor.opacity(0.1))
        .clipShape(Circle())
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.body)
          .fontWeight(.medium)
        
        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.leading)
      }
      
      Spacer()
    }
  }
}

#Preview {
  AboutView()
}
