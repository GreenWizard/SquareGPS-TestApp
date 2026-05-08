import Foundation

struct AuthDataIn: Codable {
    
    var login: String
    var password: String
    var dealerId: String?
}

struct AuthDataOut: Codable {
    
    var success: Bool
    var type: String
    var hash: String
}
