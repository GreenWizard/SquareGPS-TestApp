import Foundation

struct TrackerListIn: Codable {
    
    var hash: String
    var labels: [String]?
}

struct TrackerListOut: Codable {
    
    var list: [Tracker]
    var success: Bool
}
