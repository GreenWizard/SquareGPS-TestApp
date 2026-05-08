import Foundation
import SwiftData

@Model
class Tracker: Codable, Identifiable {
    
    enum CodingKey: Swift.CodingKey {
        case id
        case label
        case groupId
        case source
        case tagBindings
        case phone
    }
    
    struct Source: Codable {
        
        var creationDate: Date
        var blocked: Bool
        var deviceId: String
        var tariffId: Int
        var model: String
        var tariffEndDate: Date
        var phone: String?
        
        init(creationDate: Date, blocked: Bool, deviceId: String, tariffId: Int, model: String, tariffEndDate: Date, phone: String? = nil) {
            self.creationDate = creationDate
            self.blocked = blocked
            self.deviceId = deviceId
            self.tariffId = tariffId
            self.model = model
            self.tariffEndDate = tariffEndDate
            self.phone = phone
        }
    }
    
    var id: Int
    var label: String
    var groupId: Int
    var source: Source
    var tagBindings: [Int]
    var phone: String?
    
    init(id: Int, label: String, groupId: Int, source: Source, tagBindings: [Int], phone: String? = nil) {
        self.id = id
        self.label = label
        self.groupId = groupId
        self.source = source
        self.tagBindings = tagBindings
        self.phone = phone
    }
    
    static func demo(id: Int = .random(in: (0..<9999))) -> Tracker {
        return Tracker(
            id: id,
            label: "Some awesome tracker",
            groupId: id,
            source: .init(
                creationDate: .now,
                blocked: false,
                deviceId: "Some device id",
                tariffId: id,
                model: "Some model",
                tariffEndDate: .distantFuture,
                phone: "+0 (000) 000 0000"
            ),
            tagBindings: [1, 2, 3, 4, 5],
            phone: "+0 (000) 000 0000"
        )
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        groupId = try container.decode(Int.self, forKey: .groupId)
        source = try container.decode(Source.self, forKey: .source)
        tagBindings = try container.decode([Int].self, forKey: .tagBindings)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(groupId, forKey: .groupId)
        try container.encode(source, forKey: .source)
        try container.encode(tagBindings, forKey: .tagBindings)
        try container.encodeIfPresent(phone, forKey: .phone)
    }
}
