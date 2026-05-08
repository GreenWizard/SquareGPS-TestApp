import SwiftData
import Foundation
import KeychainSwift
import Combine

protocol AuthService: ObservableObject {
    
    var authHash: String? { get }
    
    func auth(username: String, password: String) async throws
    func reset()
}

final class AuthServiceMock: AuthService {
    
    enum Error: Swift.Error {
        case testError
    }
    
    @Published
    var authHash: String?
    
    init(authHash: String? = nil) {
        self.authHash = authHash
    }
    
    func auth(username: String, password: String) async throws {
        try await Task.sleep(for: .seconds(2))
        authHash = ""
    }
    
    func reset() {
        authHash = nil
    }
}

final class AuthServiceImpl: AuthService {
    
    private enum Const {
        static let authHashKey = "auth_hash"
    }
        
    @Published
    private(set) var authHash: String? {
        didSet {
            guard let authHash else {
                keychain.delete(Const.authHashKey)
                return
            }
            keychain.set(authHash, forKey: Const.authHashKey)
        }
    }
    
    private let api: Api
    private let keychain = KeychainSwift()
    
    init(api: Api) {
        self.api = api
        self.authHash = keychain.get(Const.authHashKey)
    }
    
    func auth(username: String, password: String) async throws {
        let response: AuthDataOut = try await api.post(
            endpoint: .userAuth,
            body: AuthDataIn(login: username, password: password)
        )
        authHash = response.hash
    }
    
    func reset() {
        authHash = nil
    }
}
