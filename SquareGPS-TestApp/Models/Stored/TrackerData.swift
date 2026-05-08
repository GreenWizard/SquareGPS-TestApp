import Foundation
import SwiftData

@Model
final class TrackerData: Sendable {
    
    struct Source: Codable {
        var model: String
    }
    
    struct TrackerState: Codable {
        var lat: Double
        var lng: Double
        var heading: Int
    }
    
    var id: Int
    var label: String
    var groupId: Int
    var source: Source
    var phone: String?
    var state: TrackerState?
    
    init(
        id: Int,
        label: String,
        groupId: Int,
        source: Source,
        phone: String?,
        state: TrackerState? = nil
    ) {
        self.id = id
        self.label = label
        self.groupId = groupId
        self.source = source
        self.phone = phone
        self.state = state
    }
    
    init(tracker: Tracker) {
        id = tracker.id
        label = tracker.label
        groupId = tracker.groupId
        source = .init(model: tracker.source.model)
        phone = tracker.phone
    }
    
    static func demo(id: Int = .random(in: (0..<999))) -> TrackerData {
        TrackerData(
            id: id,
            label: "Some awesome tracker",
            groupId: id,
            source: .init(model: "Some model"),
            phone: "+0 (000) 000-0000",
            state: .init(lat: 10.0, lng: 20.0, heading: 100)
        )
    }
}
