import SwiftUI

struct SubscriptionSheetView: View {
  @EnvironmentObject private var subscriptionService: SubscriptionService
  @Environment(\.dismiss) private var dismiss

  @State private var selectedPlan: SubscriptionPlan?
  @State private var isLoading = false
  @State private var showingAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header
          VStack(spacing: 16) {
            Image(systemName: "crown.fill")
              .font(.system(size: 48))
              .foregroundColor(.yellow)

            Text("Upgrade to Premium")
              .font(.title)
              .fontWeight(.bold)

            Text("Unlock all features and get the most out of your tracking experience")
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .padding(.top)

          // Current Status
          if subscriptionService.userProfile.subscription.isTrialActive {
            TrialStatusCard(subscription: subscriptionService.userProfile.subscription)
          } else {
            CurrentSubscriptionCard(subscription: subscriptionService.userProfile.subscription)
          }

          // Subscription Plans
          VStack(spacing: 16) {
            Text("Choose Your Plan")
              .font(.headline)
              .fontWeight(.semibold)

            ForEach(subscriptionService.availablePlans) { plan in
              SubscriptionPlanCard(
                plan: plan,
                isSelected: selectedPlan?.id == plan.id,
                onSelect: { selectedPlan = plan }
              )
            }
          }

          // Purchase Button
          if let selectedPlan = selectedPlan {
            Button(action: {
              purchaseSubscription(selectedPlan)
            }) {
              HStack {
                if isLoading {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                } else {
                  Text("Subscribe for \(selectedPlan.formattedPrice)")
                    .fontWeight(.semibold)
                }
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
            .disabled(isLoading)
            .padding(.horizontal)
          }

          // Restore Purchases
          Button(action: restorePurchases) {
            Text("Restore Purchases")
              .font(.subheadline)
              .foregroundColor(.blue)
          }
          .disabled(isLoading)

          // Features List
          PremiumFeaturesSection()

          Spacer(minLength: 100)
        }
        .padding()
      }
      .navigationTitle("Subscription")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .onAppear {
        selectedPlan = subscriptionService.availablePlans.first
      }
      .alert(alertTitle, isPresented: $showingAlert) {
        Button("OK") {}
      } message: {
        Text(alertMessage)
      }
    }
  }

  private func purchaseSubscription(_ plan: SubscriptionPlan) {
    isLoading = true

    Task {
      do {
        try await subscriptionService.purchaseSubscription(plan)

        await MainActor.run {
          isLoading = false
          alertTitle = "Success!"
          alertMessage = "Welcome to Premium! You now have access to all features."
          showingAlert = true
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertTitle = "Purchase Failed"
          alertMessage = "Unable to complete the purchase. Please try again."
          showingAlert = true
        }
      }
    }
  }

  private func restorePurchases() {
    isLoading = true

    Task {
      do {
        try await subscriptionService.restorePurchases()

        await MainActor.run {
          isLoading = false
          alertTitle = "Restore Complete"
          alertMessage = "Your purchases have been restored successfully."
          showingAlert = true
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertTitle = "Restore Failed"
          alertMessage = "No previous purchases found."
          showingAlert = true
        }
      }
    }
  }
}

struct TrialStatusCard: View {
  let subscription: SubscriptionInfo

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "clock.fill")
          .foregroundColor(.orange)

        Text("Free Trial Active")
          .font(.headline)
          .fontWeight(.semibold)
      }

      VStack(spacing: 4) {
        Text("\(subscription.daysRemainingInTrial) days remaining")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.orange)

        Text("Trial expires on \(subscription.formattedTrialEndDate)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color.orange.opacity(0.1))
    .cornerRadius(12)
  }
}

struct CurrentSubscriptionCard: View {
  let subscription: SubscriptionInfo

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(
          systemName: subscription.status == .active ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .foregroundColor(subscription.status.color)

        Text("Current Plan")
          .font(.headline)
          .fontWeight(.semibold)
      }

      VStack(spacing: 4) {
        Text(subscription.status.displayName)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(subscription.status.color)

        if let plan = subscription.plan {
          Text("\(plan.formattedPrice) \(plan.billingDescription)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding()
    .background(subscription.status.color.opacity(0.1))
    .cornerRadius(12)
  }
}

struct SubscriptionPlanCard: View {
  let plan: SubscriptionPlan
  let isSelected: Bool
  let onSelect: () -> Void

  var body: some View {
    Button(action: onSelect) {
      VStack(spacing: 16) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(plan.name)
              .font(.headline)
              .fontWeight(.bold)

            HStack(alignment: .bottom, spacing: 4) {
              Text(plan.formattedPrice)
                .font(.title2)
                .fontWeight(.bold)

              Text(plan.billingDescription)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          Spacer()

          if isSelected {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.blue)
              .font(.title2)
          }
        }

        // Features
        VStack(alignment: .leading, spacing: 8) {
          ForEach(plan.features, id: \.self) { feature in
            HStack {
              Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.caption)

              Text(feature)
                .font(.subheadline)

              Spacer()
            }
          }
        }
      }
      .padding()
      .background(Color(.systemBackground))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
      )
      .cornerRadius(12)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct PremiumFeaturesSection: View {
  private let features = [
    ("chart.bar.fill", "Advanced Analytics", "Get detailed insights into your tracking patterns"),
    ("icloud.fill", "Cloud Sync", "Access your data across all your devices"),
    ("square.and.arrow.up.fill", "Data Export", "Export your data in multiple formats"),
    ("paintbrush.fill", "Custom Themes", "Personalize your app with custom colors"),
    ("questionmark.circle.fill", "Priority Support", "Get help when you need it most"),
    ("infinity", "Unlimited Trackers", "Create as many trackers as you want"),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Premium Features")
        .font(.headline)
        .fontWeight(.semibold)

      VStack(spacing: 12) {
        ForEach(features, id: \.1) { icon, title, description in
          HStack(spacing: 12) {
            Image(systemName: icon)
              .foregroundColor(.blue)
              .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
              Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

              Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }
          .padding(.vertical, 4)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  SubscriptionSheetView()
    .environmentObject(SubscriptionService())
}
