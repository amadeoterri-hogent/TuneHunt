//
//  Country.swift
//  TuneHunt
//
//  Created by Amadeo Terrière on 24/12/2024.
//

import Foundation

struct Country: Codable, Identifiable {
    var id: String {country_code}
    var country_code: String
    var name: String
    var alpha_2: String
    var flag: String {
        // Generate flag emoji using the alpha_2 country code
        let base: UInt32 = 127397
        return alpha_2.unicodeScalars.compactMap { UnicodeScalar(base + $0.value) }.map { String($0) }.joined()
    }
    
    enum CodingKeys: String, CodingKey {
        case country_code = "country-code"
        case name
        case alpha_2 = "alpha-2"
    }
    
//    func flag(country:String) -> String {
//        let base : UInt32 = 127397
//        var s = ""
//        for v in country.unicodeScalars {
//            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
//        }
//        return String(s)
//    }
}
