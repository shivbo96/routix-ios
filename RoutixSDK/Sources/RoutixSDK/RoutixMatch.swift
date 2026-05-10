import Foundation

public struct RoutixMatch: Codable {
    public let success: Bool
    public let shortCode: String?
    public let originalUrl: String?
    public let matchSource: String? // 'universal_link', 'referrer', 'fingerprint', 'clipboard'
    public let confidence: Double   // 0.0 to 1.0
    public let metadata: [String: AnyCodable]?
    public let timestamp: String?

    // MARK: - Memberwise init (used by handleDeepLink and tests)

    public init(
        success: Bool,
        shortCode: String? = nil,
        originalUrl: String? = nil,
        matchSource: String? = nil,
        confidence: Double = 1.0,
        metadata: [String: AnyCodable]? = nil,
        timestamp: String? = nil
    ) {
        self.success = success
        self.shortCode = shortCode
        self.originalUrl = originalUrl
        self.matchSource = matchSource
        self.confidence = confidence
        self.metadata = metadata
        self.timestamp = timestamp
    }

    // MARK: - Codable (from JSON)

    enum CodingKeys: String, CodingKey {
        case success
        case shortCode    = "short_code"
        case originalUrl  = "original_url"
        case matchSource  = "attribution_source"
        case confidence
        case metadata
        case timestamp
    }

    /// Custom decoder ensures `confidence` defaults to `1.0` when absent from JSON,
    /// consistent with Android and React Native SDKs.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success     = try container.decode(Bool.self, forKey: .success)
        shortCode   = try container.decodeIfPresent(String.self, forKey: .shortCode)
        originalUrl = try container.decodeIfPresent(String.self, forKey: .originalUrl)
        matchSource = try container.decodeIfPresent(String.self, forKey: .matchSource)
        confidence  = try container.decodeIfPresent(Double.self, forKey: .confidence) ?? 1.0
        metadata    = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
        timestamp   = try container.decodeIfPresent(String.self, forKey: .timestamp)
    }
}

// MARK: - AnyCodable (supports String, Int, Double, Bool metadata values)

public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self)  { value = x; return }
        if let x = try? container.decode(Int.self)     { value = x; return }
        if let x = try? container.decode(Double.self)  { value = x; return }
        if let x = try? container.decode(Bool.self)    { value = x; return }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "AnyCodable: unsupported value type"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let x = value as? String { try container.encode(x) }
        else if let x = value as? Int    { try container.encode(x) }
        else if let x = value as? Double { try container.encode(x) }
        else if let x = value as? Bool   { try container.encode(x) }
    }
}
