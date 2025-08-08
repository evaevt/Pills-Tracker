import SwiftUI

struct TermsOfServiceView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          VStack(alignment: .leading, spacing: 16) {
            Text("Terms of Service")
              .font(.title)
              .fontWeight(.bold)
            
            Text("Last updated: [Date will be added]")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Divider()
            
            // Placeholder content
            VStack(alignment: .leading, spacing: 16) {
              Text("Content Coming Soon")
                .font(.headline)
                .fontWeight(.semibold)
              
              Text("The terms of service content will be added here. This section will contain detailed information about:")
                .font(.body)
                .foregroundColor(.secondary)
              
              VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Terms and conditions for using Pills Tracker")
                BulletPoint(text: "User responsibilities and acceptable use")
                BulletPoint(text: "Service availability and limitations")
                BulletPoint(text: "Intellectual property rights")
                BulletPoint(text: "Liability and warranty disclaimers")
                BulletPoint(text: "Termination and account suspension policies")
                BulletPoint(text: "Dispute resolution and governing law")
              }
              
              Text("Please check back soon for the complete terms of service.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
          }
          
          // Contact Information
          VStack(alignment: .leading, spacing: 16) {
            Text("Questions?")
              .font(.headline)
              .fontWeight(.semibold)
            
            Text("If you have any questions about these Terms of Service, please contact us:")
              .font(.body)
              .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Image(systemName: "envelope.fill")
                  .font(.body)
                  .foregroundColor(.blue)
                
                Text("legal@pillstracker.com")
                  .font(.body)
                  .foregroundColor(.blue)
                
                Spacer()
              }
              .onTapGesture {
                if let url = URL(string: "mailto:legal@pillstracker.com?subject=Terms of Service Inquiry") {
                  UIApplication.shared.open(url)
                }
              }
              
              HStack {
                Image(systemName: "questionmark.circle.fill")
                  .font(.body)
                  .foregroundColor(.green)
                
                Text("Visit our Support page for more help")
                  .font(.body)
                  .foregroundColor(.green)
                
                Spacer()
              }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
          }
          
          Spacer(minLength: 50)
        }
        .padding()
      }
      .navigationTitle("Terms of Service")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#Preview {
  TermsOfServiceView()
}
