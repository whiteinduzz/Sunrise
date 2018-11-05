//
//  PlaceModel.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import Foundation

final class PredictionResponse: Codable {
    var predictions: [Prediction]
    enum CodingKeys: String, CodingKey {
        case predictions = "predictions"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        predictions = try container.decode([Prediction].self, forKey: .predictions)
    }
}

final class Prediction: Codable {
    var placeId: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case description
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeId = try container.decode(String.self, forKey: .placeId)
        description = try container.decode(String.self, forKey: .description)
    }
}

final class PlacesResponse: Codable {
    var result: PlaceModel
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode(PlaceModel.self, forKey: .result)
    }
}

final class Location: Codable {
    var lat: Double
    var lng: Double
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lng
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lng = try container.decode(Double.self, forKey: .lng)
        lat = try container.decode(Double.self, forKey: .lat)
    }
}

final class Geometry: Codable {
    var location: Location
    enum CodingKeys: String, CodingKey {
        case location
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(Location.self, forKey: .location)
    }
}

final class PlaceModel: Codable {
    var geometry: Geometry
    var name: String
    enum CodingKeys: String, CodingKey {
        case name
        case geometry
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(Geometry.self, forKey: .geometry)
        name = try container.decode(String.self, forKey: .name)
    }
}
