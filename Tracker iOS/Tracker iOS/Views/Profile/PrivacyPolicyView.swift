import SwiftUI

struct PrivacyPolicyView: View {
  @State private var showingShareSheet = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Placeholder content
          VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
              .font(.title)
              .fontWeight(.bold)
            
            Text("Last updated: [Date will be added]")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Divider()
            
            // Placeholder text
            VStack(alignment: .leading, spacing: 16) {
              Text("Content Coming Soon")
                .font(.headline)
                .fontWeight(.semibold)
              
              Text("The privacy policy content will be added here. This section will contain detailed information about:")
                .font(.body)
                .foregroundColor(.secondary)
              
              VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "How we collect and use your personal information")
                BulletPoint(text: "Data storage and security measures")
                BulletPoint(text: "Your rights and choices regarding your data")
                BulletPoint(text: "How we share information with third parties")
                BulletPoint(text: "Cookie and tracking technology usage")
                BulletPoint(text: "Contact information for privacy inquiries")
              }
              
              Text("Please check back soon for the complete privacy policy.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
          }
          
          Spacer(minLength: 50)
        }
        .padding()
      }
      .navigationTitle("Privacy Policy")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showingShareSheet = true
          }) {
            Image(systemName: "square.and.arrow.up")
              .font(.body)
          }
        }
      }
      .sheet(isPresented: $showingShareSheet) {
        ShareSheet(activityItems: [privacyPolicyContent])
      }
    }
  }
  
  private var privacyPolicyContent: String {
    return """
    Privacy Policy - Pills Tracker
    
    [Complete privacy policy content will be added here]
    
    For questions about this privacy policy, please contact us at:
    privacy@pillstracker.com
    """
  }
}

// MARK: - Supporting Views

struct BulletPoint: View {
  let text: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      Text("•")
        .font(.body)
        .foregroundColor(.secondary)
      
      Text(text)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
      
      Spacer()
    }
  }
}

struct ShareSheet: UIViewControllerRepresentable {
  let activityItems: [Any]
  let applicationActivities: [UIActivity]? = nil
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: applicationActivities
    )
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
    // No updates needed
  }
}

#Preview {
  PrivacyPolicyView()
}
