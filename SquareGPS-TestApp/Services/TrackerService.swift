import Foundation
import SwiftUI
import Combine
import SwiftData

protocol TrackerService: ObservableObject {
    
    var trackers: [Tracker] { get }
    
    func reloadTrackers() async throws
}

final class TrackerServiceMock: TrackerService {
    
    @Published
    var trackers: [Tracker] = []
    
    
    func append() {
        trackers.append(.demo(id: (trackers.last?.id ?? 0) + 1))
    }
    
    func reloadTrackers() async throws {
        try await Task.sleep(for: .seconds(2))
        trackers = [.demo(id: 1), .demo(id: 2), .demo(id: 3)]
    }
}

final class TrackerServiceImpl: TrackerService {
    
    enum Error: Swift.Error {
        case unauthorized
    }
    
    var trackers: [Tracker] {
        (try? modelContext.fetch(.init(sortBy: [.init(\.label)]))) ?? []
    }
    
    @Published
    var isRefreshInProgress = false
    
    @Published
    var error: (any Swift.Error)?
    
    private let api: Api
    private let authService: any AuthService
    private let modelContext: ModelContext
    
    init(api: Api, authService: any AuthService, modelContainer: ModelContainer) {
        self.api = api
        self.authService = authService
        self.modelContext = ModelContext(modelContainer)
    }
    
    func reloadTrackers() async throws {
        guard !isRefreshInProgress else {
            // If refresh in progress, wait until last one is finished
            return try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = _isRefreshInProgress.projectedValue
                    .sink { [weak self] inProgress in
                        guard !inProgress else { return }
                        
                        if let self, let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                        cancellable?.cancel()
                    }
            }
        }
        
        isRefreshInProgress = true
        defer {
            isRefreshInProgress = false
        }
        do {
            error = nil
            guard let authHash = authService.authHash else { throw Error.unauthorized }
            let result: TrackerListOut = try await api.post(
                endpoint: .trackerList,
                body: TrackerListIn(hash: authHash)
            )
            try modelContext.delete(model: Tracker.self)
            result.list.forEach { modelContext.insert($0) }
            try modelContext.save()
        } catch {
            self.error = error
            throw error
        }
    }
}
