import SwiftUI

struct SupportView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header
          VStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.blue)

            Text("Need Help?")
              .font(.title2)
              .fontWeight(.bold)

            Text("We're here to help! Reach out to us through any of the channels below.")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }
          .padding(.top, 20)

          // Contact Options
          VStack(spacing: 16) {
            // Email Support
            SupportOptionCard(
              icon: "envelope.fill",
              iconColor: .blue,
              title: "Email Support",
              subtitle: "Get help via email",
              detail: "support@pillstracker.com",
              action: {
                if let url = URL(
                  string: "mailto:support@pillstracker.com?subject=Pills Tracker Support")
                {
                  UIApplication.shared.open(url)
                }
              }
            )

            // FAQ
            SupportOptionCard(
              icon: "questionmark.bubble.fill",
              iconColor: .green,
              title: "Frequently Asked Questions",
              subtitle: "Find quick answers",
              detail: "Browse common questions",
              action: {
                // Navigate to FAQ screen
              }
            )
          }

          // Social Media
          VStack(alignment: .leading, spacing: 16) {
            Text("Follow Us")
              .font(.headline)
              .fontWeight(.semibold)
              .padding(.horizontal)

            VStack(spacing: 12) {
              SocialMediaCard(
                platform: .twitter,
                handle: "@PillsTracker",
                action: {
                  if let url = URL(string: "https://twitter.com/pillstracker") {
                    UIApplication.shared.open(url)
                  }
                }
              )

              SocialMediaCard(
                platform: .facebook,
                handle: "Pills Tracker",
                action: {
                  if let url = URL(string: "https://facebook.com/pillstracker") {
                    UIApplication.shared.open(url)
                  }
                }
              )

              SocialMediaCard(
                platform: .instagram,
                handle: "@pillstracker",
                action: {
                  if let url = URL(string: "https://instagram.com/pillstracker") {
                    UIApplication.shared.open(url)
                  }
                }
              )
            }
          }

          // Additional Help
          VStack(alignment: .leading, spacing: 16) {
            Text("More Help")
              .font(.headline)
              .fontWeight(.semibold)
              .padding(.horizontal)

            VStack(spacing: 12) {
              HelpOptionRow(
                icon: "book.fill",
                iconColor: .orange,
                title: "User Guide",
                subtitle: "Learn how to use the app"
              ) {
                // Navigate to user guide
              }

              HelpOptionRow(
                icon: "video.fill",
                iconColor: .red,
                title: "Video Tutorials",
                subtitle: "Watch step-by-step guides"
              ) {
                // Navigate to video tutorials
              }

              HelpOptionRow(
                icon: "star.fill",
                iconColor: .yellow,
                title: "Rate the App",
                subtitle: "Share your feedback on the App Store"
              ) {
                // Open App Store rating
                if let url = URL(
                  string: "https://apps.apple.com/app/pillstracker/id123456789?action=write-review")
                {
                  UIApplication.shared.open(url)
                }
              }
            }
          }

          Spacer(minLength: 50)
        }
        .padding()
      }
      .navigationTitle("Support")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

// MARK: - Supporting Views

struct SupportOptionCard: View {
  let icon: String
  let iconColor: Color
  let title: String
  let subtitle: String
  let detail: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(iconColor)
          .frame(width: 40, height: 40)
          .background(iconColor.opacity(0.1))
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.headline)
            .foregroundColor(.primary)

          Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.secondary)

          Text(detail)
            .font(.caption)
            .foregroundColor(iconColor)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(12)
      .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct SocialMediaCard: View {
  let platform: SocialPlatform
  let handle: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        Image(systemName: platform.icon)
          .font(.title2)
          .foregroundColor(.white)
          .frame(width: 40, height: 40)
          .background(platform.color)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text(platform.name)
            .font(.headline)
            .foregroundColor(.primary)

          Text(handle)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Spacer()

        Image(systemName: "arrow.up.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct HelpOptionRow: View {
  let icon: String
  let iconColor: Color
  let title: String
  let subtitle: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        Image(systemName: icon)
          .font(.title3)
          .foregroundColor(iconColor)
          .frame(width: 32, height: 32)
          .background(iconColor.opacity(0.1))
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.body)
            .foregroundColor(.primary)

          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Supporting Types

enum SocialPlatform {
  case twitter
  case facebook
  case instagram

  var name: String {
    switch self {
    case .twitter: return "Twitter"
    case .facebook: return "Facebook"
    case .instagram: return "Instagram"
    }
  }

  var icon: String {
    switch self {
    case .twitter: return "bird.fill"
    case .facebook: return "f.circle.fill"
    case .instagram: return "camera.fill"
    }
  }

  var color: Color {
    switch self {
    case .twitter: return .blue
    case .facebook: return Color(.systemBlue)
    case .instagram: return .purple
    }
  }
}

#Preview {
  SupportView()
}
