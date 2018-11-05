//
//  RestAPIManager.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import RxSwift

struct GetSunserSunriseRequest: APIRequest {
    var method: RequestType = .get
    var path: String = "json"
    var pathParameters: [String: String] = [:]
    var parameters: [String: Any] = [:]
    
    init(lat: String, lng: String) {
        pathParameters["lat"] = lat
        pathParameters["lng"] = lng
        pathParameters["date"] = "today"
    }
}

struct GetPlaceRequest: APIRequest {
    var method: RequestType = .get
    var path: String = "maps/api/place/details/json"
    var pathParameters: [String: String] = [:]
    var parameters: [String: Any] = [:]
    
    init(input: String) {
        pathParameters["placeid"] = input
        pathParameters["key"] = "AIzaSyCUVRFGd_msr_hfxADRmhRZ2FDCFyzU41Q"
    }
}

struct AutocompleteRequest: APIRequest {
    var method: RequestType = .get
    var path: String = "maps/api/place/autocomplete/json"
    var pathParameters: [String: String] = [:]
    var parameters: [String: Any] = [:]
    init(input: String) {
        pathParameters["input"] = input
        pathParameters["key"] = "AIzaSyCUVRFGd_msr_hfxADRmhRZ2FDCFyzU41Q"
    }
}

protocol RestAPIManagerProtocol: class {
    func getSunriseSunsetInformation(lat: String, lng: String) -> Observable<SunsetSunriseModel>
    func getPlace(input: String) -> Observable<PlaceModel>
    func autoCompletePlace(input: String) -> Observable<[Prediction]>
}

final class RestAPIManager: RestAPIManagerProtocol {
    
    var apiManager: APIServiceProtocol = APIService()
    
    func getSunriseSunsetInformation(lat: String, lng: String) -> Observable<SunsetSunriseModel> {
        apiManager.baseUrl = "https://api.sunrise-sunset.org/"
        let request = GetSunserSunriseRequest(lat: lat, lng: lng)
        let response: Observable<SunsetSunriseResponse> = apiManager.executeRequest(request: request, encodeType: .json)
        return response.map { $0.results }
    }
    
    func autoCompletePlace(input: String) -> Observable<[Prediction]> {
        apiManager.baseUrl =  "https://maps.googleapis.com/"
        let request = AutocompleteRequest(input: input)
        let response: Observable<PredictionResponse> = apiManager.executeRequest(request: request, encodeType: .json)
        return response.map { $0.predictions }
    }
    
    func getPlace(input: String) -> Observable<PlaceModel> {
        apiManager.baseUrl =  "https://maps.googleapis.com/"
        let request = GetPlaceRequest(input: input)
        let response: Observable<PlacesResponse> = apiManager.executeRequest(request: request, encodeType: .json)
        return response.map { $0.result }
    } 
}
