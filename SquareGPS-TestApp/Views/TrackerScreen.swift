import SwiftUI
import SwiftData

struct TrackerScreen<T: Services>: View {
    
    @State var selectedTracker: TrackerData?
    @State var isAuthPresented = false
    
    @State var refreshError: Error?
    
    @Environment(\.modelContext) var modelContext
    
    let services: T
    
    @ObservedObject var authService: T._AuthService
    @ObservedObject var trackerService: T._TrackerService
    
    init(_ services: T) {
        self.services = services
        _authService = .init(initialValue: services.authService)
        _trackerService = .init(initialValue: services.trackerService)
    }
    
    var body: some View {
        List {
            if let refreshError {
                Text("Refresh error: \(refreshError.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            ForEach(trackerService.trackers) { tracker in
                HStack(alignment: .center) {
                    Text(tracker.label)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let phone = tracker.phone {
                        Text(phone)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .layoutPriority(1)
                    }
                }
                .onTapGesture {
                    selectedTracker = tracker
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await refresh() }
        .navigationTitle("Tracker list")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            if authService.authHash == nil {
                Button("Sign In") { isAuthPresented = true }
            }
            if let trackerService = trackerService as? TrackerServiceMock {
                Button("Add") { trackerService.append() }
            }
        }
        .sheet(
            item: $selectedTracker,
            onDismiss: {
                selectedTracker = nil
            },
            content: {
                TrackerDetails(tracker: $0)
            }
        )
        .sheet(
            isPresented: $isAuthPresented,
            onDismiss: {
                Task { await refresh() }
            },
            content: {
                AuthScreen(services)
            }
        )
        .task { await onAppear() }
    }
    
    func onAppear() async {
        guard authService.authHash != nil else {
            return isAuthPresented = true
        }
        await refresh()
    }
    
    func refresh() async {
        guard authService.authHash != nil else { return }
        do {
            try await trackerService.reloadTrackers()
            refreshError = nil
        } catch {
            refreshError = error
        }
    }
}

#Preview {
    NavigationStack {
        TrackerScreen(ServicesMock())
    }
}
