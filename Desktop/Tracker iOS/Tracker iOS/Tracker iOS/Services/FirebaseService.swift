import Combine
import Foundation

/// Простой Firebase сервис для демонстрации
@MainActor
class FirebaseService: ObservableObject {
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var isAuthenticated = true  // Для демо всегда авторизованы

  init() {
    // Инициализация
  }

  /// Сохранение записи в коллекцию
  func saveEntry<T: Codable>(_ entry: T, to collection: String) async throws {
    isLoading = true
    errorMessage = nil

    // Имитация сохранения в Firebase
    try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 секунда

    // Здесь будет реальное сохранение в Firestore
    print("Saved \(entry) to \(collection)")

    isLoading = false
  }

  /// Выход из аккаунта
  func signOut() throws {
    isAuthenticated = false
    print("User signed out")
  }

  /// Вход в аккаунт
  func signIn(email: String, password: String) async throws {
    isLoading = true
    errorMessage = nil

    // Имитация входа
    try await Task.sleep(nanoseconds: 1_000_000_000)

    isAuthenticated = true
    isLoading = false
  }

  /// Регистрация
  func signUp(email: String, password: String, name: String) async throws {
    isLoading = true
    errorMessage = nil

    // Имитация регистрации
    try await Task.sleep(nanoseconds: 1_000_000_000)

    isAuthenticated = true
    isLoading = false
  }

  /// Сброс пароля
  func resetPassword(email: String) async throws {
    isLoading = true
    errorMessage = nil

    // Имитация сброса пароля
    try await Task.sleep(nanoseconds: 1_000_000_000)

    isLoading = false
  }
}
