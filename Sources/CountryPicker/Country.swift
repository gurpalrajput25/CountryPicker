//
//  Country.swift
//  CountryPicker
//
//  Created by Samet Macit on 31.12.2020.
//  Copyright © 2021 Mobven. All rights reserved.

import Foundation

public struct Country: Codable {
    public var phoneCode: String
    public let isoCode: String
    public var minLength: Int
    public var maxLength: Int

    /// E.164-ready calling code with leading "+" (e.g., "+1", "+225").
    /// Derived from `phoneCode` if present.
    public var callingCode: String { phoneCode.isEmpty ? "" : "+" + phoneCode }

    public init(phoneCode: String, isoCode: String, minLength: Int, maxLength: Int) {
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
        
        if let country = CountryManager.shared.getCountries().first(where: { $0.isoCode == isoCode }) {
            self.phoneCode = country.phoneCode
            self.minLength = country.minLength
            self.maxLength = country.maxLength
        }
    }
    
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
        let normalizedCalling = decodedCalling.hasPrefix("+") ? String(decodedCalling.dropFirst()) : decodedCalling
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
        // Intentionally do not encode `callingCode` to keep the JSON shape stable
    }
}

public extension Country {
    /// Returns localized country name for localeIdentifier
    var localizedName: String {
        let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: isoCode])
        let name = NSLocale(localeIdentifier: CountryManager.shared.localeIdentifier)
            .displayName(forKey: NSLocale.Key.identifier, value: id) ?? isoCode
        return name
    }
}
