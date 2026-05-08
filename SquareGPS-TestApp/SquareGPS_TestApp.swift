import SwiftUI
import SwiftData

@main
struct SquareGPS_TestApp: App {
    
    @State var services = ServicesImpl()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TrackerScreen(services)
            }
        }
    }
}
