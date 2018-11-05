//
//  SunsetSunriseModel.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import Foundation

final class SunsetSunriseResponse: Codable {
    var results: SunsetSunriseModel
    enum CodingKeys: String, CodingKey {
        case results
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decode(SunsetSunriseModel.self, forKey: .results)
    }
}

final class SunsetSunriseModel: Codable {
    var sunrise: String
    var sunset: String
    var dayLength: String
    
    enum CodingKeys: String, CodingKey {
        case sunset
        case sunrise
        case dayLength = "day_length"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sunset = try container.decode(String.self, forKey: .sunset)
        sunrise = try container.decode(String.self, forKey: .sunrise)
        dayLength = try container.decode(String.self, forKey: .dayLength)
    }
}

