import Foundation

enum ApiError: Swift.Error {
    
    case unsupportedResponseType
    case httpError(code: Int, description: String)
}

protocol Api {
    
    func post<Body: Codable, Output: Codable>(endpoint: ApiEndpoint, body: Body) async throws -> Output
}

struct ApiDecorator: Api {
    
    var onPostError: (Error) -> Void
    var api: Api
    
    func post<Body: Codable, Output: Codable>(endpoint: ApiEndpoint, body: Body) async throws -> Output {
        do {
            return try await api.post(endpoint: endpoint, body: body)
        } catch {
            onPostError(error)
            throw error
        }
    }
}

struct ApiImpl: Api {
    
    func post<Body: Codable, Output: Codable>(endpoint: ApiEndpoint, body: Body) async throws -> Output {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try CodingConst.encoder.encode(body)
        print("[API Request] STARTED: \(urlRequest.url?.absoluteString ?? "")")
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                throw ApiError.unsupportedResponseType
            }
            print("[API Request] DATA RECEIVED: \(urlRequest.url?.absoluteString ?? ""), output: \(String(data: data, encoding: .utf8) ?? "")")
            switch response.statusCode {
            case (200..<300):
                let output = try CodingConst.decoder.decode(Output.self, from: data)
                print("[API Request] SUCCEEDED: \(urlRequest.url?.absoluteString ?? ""), output: \(output)")
                return output
            default:
                throw ApiError.httpError(
                    code: response.statusCode,
                    description: String(data: data, encoding: .utf8) ?? "Unknown error"
                )
            }
        } catch {
            print("[API Request] FAILED: \(urlRequest.url?.absoluteString ?? ""), error: \(error.localizedDescription)")
            throw error
        }
    }
}
