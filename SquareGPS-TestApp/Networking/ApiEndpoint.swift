import Foundation

enum ApiEndpoint: String {
    static let baseURL = URL(string: "https://api.eu.navixy.com/v2")!
    
    case userAuth = "user/auth"
    case trackerList = "tracker/list"
    case trackerGetStates = "tracker/get_states"
    
    var url: URL { Self.baseURL.appending(path: rawValue) }
}
