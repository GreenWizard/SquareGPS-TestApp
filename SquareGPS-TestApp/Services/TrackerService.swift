import Foundation
import SwiftUI
import Combine
import SwiftData

protocol TrackerService: ObservableObject {
    
    var trackers: [TrackerData] { get }
    
    func reloadTrackers() async throws
}

final class TrackerServiceMock: TrackerService {
    
    @Published
    var trackers: [TrackerData] = []
    
    
    func append() {
        trackers.append(.demo(id: (trackers.last?.id ?? 0) + 1))
    }
    
    func reloadTrackers() async throws {
        try await Task.sleep(for: .seconds(2))
        trackers = [.demo(id: 1), .demo(id: 2), .demo(id: 3)]
    }
    
    func getTrackerState(id: String) throws -> TrackerState? {
        TrackerState(gps: .init(location: .init(lat: 10.0, lng: 20.0), heading: 0))
    }
}

final class TrackerServiceImpl: TrackerService {
    
    enum Error: Swift.Error {
        case unauthorized
    }
    
    var trackers: [TrackerData] {
        (try? modelContext.fetch(.init(sortBy: [.init(\.label)]))) ?? []
    }
    
    @Published
    var isRefreshInProgress = false
    
    @Published
    var error: (any Swift.Error)?
    
    private let api: Api
    private let authService: any AuthService
    private let modelContext: ModelContext
    private let lifecycleListener = AppLifecycleListener()
    
    private let reloadSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []
    private var refreshStatesTask: Task<Void, Never>?
    
    init(api: Api, authService: any AuthService, modelContainer: ModelContainer) {
        self.api = api
        self.authService = authService
        self.modelContext = ModelContext(modelContainer)
        
        lifecycleListener.$isForeground
            .combineLatest(reloadSubject) { isForeground, _ in isForeground }
            .map { isForeground -> AnyPublisher<Date, Never> in
                guard isForeground else { return Empty(completeImmediately: false).eraseToAnyPublisher() }
                return Timer.publish(every: 5, tolerance: 0.25, on: .main, in: .common)
                    .autoconnect()
                    .prepend(Date())
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] _ in
                self?.reloadTrackerStates()
            }
            .store(in: &cancellables)
    }
    
    func reloadTrackers() async throws {
        guard !isRefreshInProgress else {
            // Coalesce concurrent refresh calls: if a refresh is already running,
            // await its completion and return the same outcome (success/error).
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
            try modelContext.delete(model: TrackerData.self)
            result.list.forEach { modelContext.insert(TrackerData(tracker: $0)) }
            try modelContext.save()
            reloadSubject.send()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func reloadTrackerStates() {
        refreshStatesTask?.cancel()
        refreshStatesTask = Task.detached { [weak self] in
            guard
                let self,
                let authHash = await authService.authHash
            else {
                return
            }
            
            let trackerIds = await MainActor.run(resultType: [Int].self) { self.trackers.map(\.id) }
            
            let body = TrackerStatesIn(
                hash: authHash,
                trackers: trackerIds,
                listBlocked: true,
                allowNotExist: true
            )
            let result: TrackerStatesOut? = try? await api.post(endpoint: .trackerGetStates, body: body)
            guard !Task.isCancelled, let result else { return }
            await MainActor.run {
                self.trackers.forEach { tracker in
                    guard let state = result.states["\(tracker.id)"] else { return }
                    tracker.state = .init(
                        lat: state.gps.location.lat,
                        lng: state.gps.location.lng,
                        heading: state.gps.heading
                    )
                }
            }
        }
    }
}

final class AppLifecycleListener {
    
    @Published
    private(set) var isForeground = UIApplication.shared.applicationState == .active
    private var observations = [Any]()
    
    init() {
        let ns = NotificationCenter.default
        observations.append(
            ns.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.isForeground = true
            }
        )
        observations.append(
            ns.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.isForeground = false
            }
        )
    }
}
