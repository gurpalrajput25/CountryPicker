//
//  Country.swift
//  CountryPicker
//

import Foundation

public struct Country: Codable {
    
    // MARK: - Properties
    public var phoneCode: String      // "91"
    public let isoCode: String        // "IN"
    public var minLength: Int
    public var maxLength: Int
    
    /// Computed calling code (+91)
    public var callingCode: String {
        return phoneCode.isEmpty ? "" : "+" + phoneCode
    }
    
    // MARK: - Initializers
    
    public init(phoneCode: String,
                isoCode: String,
                minLength: Int,
                maxLength: Int) {
        self.phoneCode = phoneCode
        self.isoCode = isoCode
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    public init(isoCode: String) {
        self.isoCode = isoCode
        self.phoneCode = ""
        self.minLength = 0
        self.maxLength = 0
        
        if let country = CountryManager.shared
            .getCountries()
            .first(where: { $0.isoCode == isoCode }) {
            
            self.phoneCode = country.phoneCode
            self.minLength = country.minLength
            self.maxLength = country.maxLength
        }
    }
    
    // MARK: - Coding
    
    private enum CodingKeys: String, CodingKey {
        case phoneCode
        case callingCode
        case isoCode
        case minLength
        case maxLength
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedPhone = try container.decodeIfPresent(String.self, forKey: .phoneCode) ?? ""
        let decodedCalling = try container.decodeIfPresent(String.self, forKey: .callingCode) ?? ""
        
        // Normalize: remove "+"
        let normalizedCalling = decodedCalling.replacingOccurrences(of: "+", with: "")
        
        // Prefer phoneCode, fallback to callingCode
        self.phoneCode = decodedPhone.isEmpty ? normalizedCalling : decodedPhone
        
        self.isoCode = try container.decode(String.self, forKey: .isoCode)
        self.minLength = try container.decode(Int.self, forKey: .minLength)
        self.maxLength = try container.decode(Int.self, forKey: .maxLength)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phoneCode, forKey: .phoneCode)
        try container.encode(isoCode, forKey: .isoCode)
        try container.encode(minLength, forKey: .minLength)
        try container.encode(maxLength, forKey: .maxLength)
        
        // Not encoding callingCode (derived)
    }
}

// MARK: - Helpers

public extension Country {
    
    /// Localized country name
    var localizedName: String {
        let id = NSLocale.localeIdentifier(
            fromComponents: [NSLocale.Key.countryCode.rawValue: isoCode]
        )
        
        return NSLocale(localeIdentifier: CountryManager.shared.localeIdentifier)
            .displayName(forKey: .identifier, value: id) ?? isoCode
    }
    
    // MARK: - Phone Handling (Manual)
    
    /// Cleans input (removes spaces, dashes, etc.)
    private func cleanNumber(_ number: String) -> String {
        return number
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
    
    /// Removes leading 0 (common in many countries)
    private func removeLeadingZero(_ number: String) -> String {
        if number.hasPrefix("0") {
            return String(number.dropFirst())
        }
        return number
    }
    
    /// Builds E.164 number manually
    /// Example: +919876543210
    func e164Number(with mobile: String) -> String {
        let cleaned = cleanNumber(mobile)
        let normalized = removeLeadingZero(cleaned)
        return callingCode + normalized
    }
    
    /// Basic validation (length only)
    func isValid(number: String) -> Bool {
        let cleaned = cleanNumber(number)
        let length = cleaned.count
        return length >= minLength && length <= maxLength
    }
}
