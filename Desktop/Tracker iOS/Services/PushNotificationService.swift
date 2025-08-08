import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

protocol PushNotificationServiceProtocol {
    func requestNotificationPermissions() async -> Bool
    func registerForRemoteNotifications()
    func handleNotificationRegistration(deviceToken: Data)
    func subscribeToTopic(_ topic: String) async throws
    func unsubscribeFromTopic(_ topic: String) async throws
}

class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    
    override init() {
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func requestNotificationPermissions() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            return granted
        } catch {
            print("Error requesting notification permissions: \(error)")
            return false
        }
    }
    
    func registerForRemoteNotifications() {
        Task { @MainActor in
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func handleNotificationRegistration(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        // Get FCM token
        Task {
            do {
                let fcmToken = try await Messaging.messaging().token()
                print("FCM Token: \(fcmToken)")
                // You can send this token to your backend server if needed
                await saveFCMToken(fcmToken)
            } catch {
                print("Error getting FCM token: \(error)")
            }
        }
    }
    
    func subscribeToTopic(_ topic: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    print("Subscribed to topic: \(topic)")
                    continuation.resume()
                }
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    print("Unsubscribed from topic: \(topic)")
                    continuation.resume()
                }
            }
        }
    }
    
    private func saveFCMToken(_ token: String) async {
        // Save token to UserDefaults or send to your backend
        UserDefaults.standard.set(token, forKey: "FCMToken")
        
        // If you have a backend, send the token here
        // Example:
        // await sendTokenToBackend(token)
    }
}

// MARK: - MessagingDelegate
extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("FCM registration token: \(fcmToken)")
        
        // Notify about token refresh
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        Task {
            await saveFCMToken(fcmToken)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Process notification data
        print("Notification received in foreground: \(userInfo)")
        
        // Show notification even when app is in foreground
        completionHandler([[.banner, .badge, .sound]])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Process notification tap
        print("Notification tapped: \(userInfo)")
        
        // Handle navigation based on notification data
        handleNotificationTap(userInfo: userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Handle navigation based on notification data
        // Example: Navigate to specific screen based on notification type
        
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "tracker_update":
                // Navigate to tracker screen
                NotificationCenter.default.post(name: .navigateToTracker, object: nil, userInfo: userInfo)
            case "reminder":
                // Navigate to reminder screen
                NotificationCenter.default.post(name: .navigateToReminder, object: nil, userInfo: userInfo)
            default:
                break
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToTracker = Notification.Name("navigateToTracker")
    static let navigateToReminder = Notification.Name("navigateToReminder")
}