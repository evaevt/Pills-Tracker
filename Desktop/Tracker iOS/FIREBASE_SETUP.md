# Firebase Setup Guide for Tracker iOS

This guide will help you set up Firebase Authentication with Google Sign-In and Push Notifications in your iOS app.

## Prerequisites

1. An Apple Developer account (for push notifications)
2. A Firebase account
3. Xcode 14.0 or later

## Step 1: Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an iOS app to your project:
   - Click "Add app" and select iOS
   - Enter your bundle identifier (e.g., `com.yourcompany.tracker`)
   - Download the `GoogleService-Info.plist` file
   - **Important**: Add this file to your Xcode project root (drag and drop into Xcode)

## Step 2: Enable Authentication

1. In Firebase Console, go to Authentication → Sign-in method
2. Enable Google as a sign-in provider
3. Add your support email
4. Save the configuration

## Step 3: Configure Push Notifications

### In Firebase Console:
1. Go to Project Settings → Cloud Messaging
2. Upload your APNs authentication key or certificates:
   - For APNs auth key: Upload your .p8 file
   - For certificates: Upload development and production .p12 files

### In Apple Developer Portal:
1. Create an App ID with Push Notifications capability
2. Create an APNs authentication key:
   - Go to Keys → Create a new key
   - Enable Apple Push Notifications service (APNs)
   - Download the .p8 file
3. Create provisioning profiles with push notifications enabled

## Step 4: Xcode Project Configuration

### Add Dependencies:
The Package.swift file has been created with the necessary dependencies. In Xcode:
1. Go to File → Add Package Dependencies
2. Add the Firebase SDK: `https://github.com/firebase/firebase-ios-sdk`
3. Add Google Sign-In: `https://github.com/google/GoogleSignIn-iOS`
4. Select the following packages:
   - FirebaseAuth
   - FirebaseMessaging
   - GoogleSignIn
   - GoogleSignInSwift

### Configure Capabilities:
1. Select your project in Xcode
2. Go to your app target → Signing & Capabilities
3. Add the following capabilities:
   - Push Notifications
   - Background Modes (check "Remote notifications")

### Configure URL Schemes:
1. Select your project → Info tab
2. Add a new URL Type:
   - URL Schemes: Copy the REVERSED_CLIENT_ID from GoogleService-Info.plist
   - Example: `com.googleusercontent.apps.YOUR_CLIENT_ID`

### Update Info.plist:
Add the following keys to your Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Step 5: Testing

### Test Google Sign-In:
1. Run the app on a real device or simulator
2. Tap the Google Sign-In button
3. Complete the authentication flow
4. Verify the user is logged in

### Test Push Notifications:
1. Run the app on a real device (notifications don't work on simulator)
2. Accept notification permissions when prompted
3. Check the console for the FCM token
4. Use Firebase Console to send a test notification:
   - Go to Cloud Messaging → Compose notification
   - Send a test message using the FCM token

## Step 6: Production Considerations

1. **Security Rules**: Configure Firebase Security Rules for your authentication
2. **Privacy**: Update your app's privacy policy to mention Google Sign-In and push notifications
3. **App Store**: Add usage descriptions in Info.plist:
   ```xml
   <key>NSUserNotificationUsageDescription</key>
   <string>We use notifications to keep you updated about your tracking progress</string>
   ```

## Troubleshooting

### Common Issues:

1. **"No GoogleService-Info.plist found"**
   - Ensure the file is added to your Xcode project
   - Check that it's included in your app target

2. **Google Sign-In not working**
   - Verify the URL scheme is correctly configured
   - Check that the bundle ID matches Firebase configuration

3. **Push notifications not received**
   - Ensure you're testing on a real device
   - Check that APNs certificates/keys are uploaded to Firebase
   - Verify push notification capability is enabled

4. **"Missing required module" errors**
   - Clean build folder (Cmd+Shift+K)
   - Reset package caches: File → Packages → Reset Package Caches

## Code Integration Summary

The following files have been created/modified:
- `Services/AuthenticationService.swift` - Handles Google Sign-In
- `Services/PushNotificationService.swift` - Manages push notifications
- `AppDelegate.swift` - Initializes Firebase and handles notifications
- `Views/LoginView.swift` - Login UI with Google Sign-In button
- `TrackerApp.swift` - Updated with Firebase initialization
- `ContentView.swift` - Shows login screen when not authenticated
- `DependencyContainer.swift` - Registers new services

## Next Steps

1. Implement sign-out functionality in your settings/profile view
2. Handle notification deep linking for specific app sections
3. Implement topic-based notifications for different tracker types
4. Add user profile management with Firebase data