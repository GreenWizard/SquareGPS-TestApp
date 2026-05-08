import Foundation
import SwiftData

struct Tracker: Codable, Identifiable {
    struct Source: Codable {
        var creationDate: Date
        var blocked: Bool
        var deviceId: String
        var tariffId: Int
        var model: String
        var tariffEndDate: Date
        var phone: String?
    }
    
    var id: Int
    var label: String
    var groupId: Int
    var source: Source
    var tagBindings: [Int]
    var phone: String?
}
