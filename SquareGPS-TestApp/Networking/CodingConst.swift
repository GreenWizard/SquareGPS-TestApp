import Foundation

enum CodingConst {
    
    enum Error: Swift.Error {
        case formattersEmpty
    }
    
    static let formatterOptions = [
        .withInternetDateTime,
        ISO8601DateFormatter.Options.withFullDate,
        [.withInternetDateTime, .withFractionalSeconds]
    ]
    
    static let formatters = formatterOptions.map { options in
        let result = ISO8601DateFormatter()
        result.formatOptions = options
        result.timeZone = .current
        return result
    }
    
    static let dateEncoding: (Date, any Encoder) throws -> Void = { date, encoder in
        var container = encoder.singleValueContainer()
        guard let formatter = formatters.first else { throw Error.formattersEmpty }
        try container.encode(formatter.string(from: date))
    }
    
    static let dateDecoding: (any Decoder) throws -> Date = { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        // API date formats may vary (full datetime, date-only, fractional seconds).
        // Try a small set of ISO8601 variants before failing.
        for formatter in formatters {
            if let date = formatter.date(from: string) { return date }
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported date format"))
    }
    
    static let encoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(dateEncoding)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    static let decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(dateDecoding)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
