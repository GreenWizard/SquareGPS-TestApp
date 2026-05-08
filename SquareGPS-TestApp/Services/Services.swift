import SwiftData

protocol Services {
    
    associatedtype _AuthService: AuthService
    associatedtype _TrackerService: TrackerService
    
    var authService: _AuthService { get }
    var trackerService: _TrackerService { get }
}

struct ServicesMock: Services {
    
    let authService = AuthServiceMock()
    let trackerService = TrackerServiceMock()
}

struct ServicesImpl: Services {
    
    let modelContainer: ModelContainer
    let authService: AuthServiceImpl
    let trackerService: TrackerServiceImpl
    
    init() {
        let schema = Schema([
            TrackerData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // `ApiDecorator` must call `authService.reset()` on HTTP 401.
        // The decorator is created before `authService` exists; assign `authService` immediately afterward.
        var authService: AuthServiceImpl!
        let api = ApiDecorator(
            onPostError: { error in
                switch error {
                case ApiError.httpError(401, _):
                    authService.reset()
                default:
                    return
                }
            },
            api: ApiImpl()
        )
        authService = AuthServiceImpl(api: api)
                
        self.modelContainer = modelContainer
        self.authService = authService
        self.trackerService = TrackerServiceImpl(
            api: api,
            authService: authService,
            modelContainer: modelContainer
        )
    }
}
