import Foundation

struct TrackerStatesIn: Codable, Sendable {
    
    var hash: String
    var trackers: [Int]
    var listBlocked: Bool
    var allowNotExist: Bool
}

struct TrackerStatesOut: Codable, Sendable {
    
    var success: Bool
    var userTime: Date
    var blocked: [Int]?
    var notExist: [Int]?
    var states: [String: TrackerState]
}

struct TrackerState: Codable {

    struct Gps: Codable {
        struct Location: Codable {
            
            var lat: Double
            var lng: Double
        }
        
        var location: Location
        var heading: Int
    }
    
    var gps: Gps
}
