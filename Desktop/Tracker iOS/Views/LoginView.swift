import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 40) {
            // App Logo/Title
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your progress, achieve your goals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Sign In Section
            VStack(spacing: 20) {
                Text("Sign in to continue")
                    .font(.headline)
                
                GoogleSignInButton(scheme: .dark, style: .wide, state: .normal) {
                    Task {
                        await signInWithGoogle()
                    }
                }
                .frame(height: 55)
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Terms and Privacy
            VStack(spacing: 8) {
                Text("By signing in, you agree to our")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Button("Terms of Service") {
                        // Open terms
                    }
                    .font(.caption)
                    
                    Text("and")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Privacy Policy") {
                        // Open privacy policy
                    }
                    .font(.caption)
                }
            }
            .padding(.bottom, 40)
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}