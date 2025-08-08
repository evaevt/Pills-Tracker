import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import Combine

protocol AuthenticationServiceProtocol {
    var currentUser: CurrentValueSubject<User?, Never> { get }
    var isAuthenticated: AnyPublisher<Bool, Never> { get }
    
    func signInWithGoogle() async throws
    func signOut() throws
    func restorePreviousSignIn() async
}

class AuthenticationService: ObservableObject, AuthenticationServiceProtocol {
    @Published private(set) var user: User?
    
    let currentUser = CurrentValueSubject<User?, Never>(nil)
    
    var isAuthenticated: AnyPublisher<Bool, Never> {
        currentUser
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.currentUser.send(user)
        }
    }
    
    func signInWithGoogle() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthenticationError.noRootViewController
        }
        
        // Get Firebase client ID
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationError.missingClientID
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Perform sign in
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthenticationError.missingIDToken
        }
        
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in to Firebase
        let authResult = try await Auth.auth().signIn(with: credential)
        user = authResult.user
        currentUser.send(authResult.user)
    }
    
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
        user = nil
        currentUser.send(nil)
    }
    
    func restorePreviousSignIn() async {
        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                guard let idToken = currentUser.idToken?.tokenString else { return }
                let accessToken = currentUser.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                let authResult = try await Auth.auth().signIn(with: credential)
                user = authResult.user
                self.currentUser.send(authResult.user)
            }
        } catch {
            print("Failed to restore previous sign-in: \(error)")
        }
    }
}

enum AuthenticationError: LocalizedError {
    case noRootViewController
    case missingClientID
    case missingIDToken
    
    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Unable to find root view controller"
        case .missingClientID:
            return "Firebase client ID is missing"
        case .missingIDToken:
            return "Failed to get ID token from Google Sign-In"
        }
    }
}