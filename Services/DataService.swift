import Foundation
import Combine

// MARK: - Mock Data Service
class MockDataService: DataServiceProtocol {
    func getAllTrackers() -> AnyPublisher<[PersonalTracker], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getTracker(id: UUID) -> AnyPublisher<PersonalTracker?, Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveTracker(_ tracker: PersonalTracker) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteTracker(id: UUID) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateTrackerModule(_ trackerId: UUID, module: TrackerModule) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Real Data Service
class DataService: DataServiceProtocol {
    private let repository: TrackerRepositoryProtocol
    
    init(repository: TrackerRepositoryProtocol) {
        self.repository = repository
    }
    
    func getAllTrackers() -> AnyPublisher<[PersonalTracker], Error> {
        // Временная заглушка
        return MockDataService().getAllTrackers()
    }
    
    func getTracker(id: UUID) -> AnyPublisher<PersonalTracker?, Error> {
        // Временная заглушка
        return MockDataService().getTracker(id: id)
    }
    
    func saveTracker(_ tracker: PersonalTracker) -> AnyPublisher<Void, Error> {
        // Временная заглушка
        return MockDataService().saveTracker(tracker)
    }
    
    func deleteTracker(id: UUID) -> AnyPublisher<Void, Error> {
        // Временная заглушка
        return MockDataService().deleteTracker(id: id)
    }
    
    func updateTrackerModule(_ trackerId: UUID, module: TrackerModule) -> AnyPublisher<Void, Error> {
        // Временная заглушка
        return MockDataService().updateTrackerModule(trackerId, module: module)
    }
} 