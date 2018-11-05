//
//  APISupport.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//
import RxSwift

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

enum EncodeType: String {
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
}

enum HTTPHeadersKey: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case contentLength = "Content-Length"
    case contentDisposition = "Content-Disposition"
}

protocol APIRequest {
    var method: RequestType { get }
    var path: String { get }
    var pathParameters: [String: String] { get }
    var parameters: [String: Any] { get }
}

protocol APIServiceProtocol {
    var baseUrl: String { get set }
    func executeRequest<T: Codable>(request: APIRequest, encodeType: EncodeType) -> Observable<T>
    func executeRequest(request: APIRequest, encodeType: EncodeType) -> Observable<Void>
}

extension APIRequest {
    
    func createRequest(baseURL: URL, requestEncodeType: EncodeType) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }
        if pathParameters.count > 0 {
            components.queryItems = pathParameters.map {
                URLQueryItem(name: String($0), value: String($1))
            }
        }
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        var parametersString: String?
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(requestEncodeType.rawValue, forHTTPHeaderField: HTTPHeadersKey.contentType.rawValue)
        if parameters.count > 0 {
            switch requestEncodeType {
            case .json:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch let error {
                    print(error.localizedDescription)
                }
            case .urlEncoded:
                parametersString = parameters.map({"\($0)=\($1)" }).joined(separator: "&")
                if let parametersString = parametersString {
                    request.httpBody = parametersString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                }
            }
        }
        
        if let parametersString = parametersString {
            request.httpBody = parametersString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        }
        return request
    }
}
extension APIServiceProtocol {
    func executeRequest<T: Codable>(request: APIRequest, encodeType: EncodeType = .urlEncoded) -> Observable<T> {
        return executeRequest(request: request, encodeType: encodeType)
    }
    
    func executeRequest(request: APIRequest, encodeType: EncodeType = .urlEncoded) -> Observable<Void> {
        return executeRequest(request: request, encodeType: encodeType)
    }
}

final class APIService: APIServiceProtocol {
    
    var baseUrl: String = "https://api.sunrise-sunset.org/"
    
    // MARK: - Public
    func executeRequest<T: Codable>(request: APIRequest, encodeType: EncodeType = .urlEncoded) -> Observable<T> {
        return Observable<T>.create { observer in
            let url = URL(string: self.baseUrl)!
            let urlRequest = request.createRequest(baseURL: url, requestEncodeType: encodeType)
            let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, _, error) in
                guard let self = self else { return }
                guard self.handleResponse(observer: observer, data: data, error: error),
                    let data = data else { return }
                let encodedObject: T!
                do {
                    encodedObject = try JSONDecoder().decode(T.self, from: data)
                } catch _ { return }
                observer.onNext(encodedObject)
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
               task.cancel()
            }
        }
    }
    
    func executeRequest(request: APIRequest, encodeType: EncodeType = .urlEncoded) -> Observable<Void> {
        return Observable<Void>.create { observer in
            let task = URLSession.shared.dataTask(with: request.createRequest(baseURL: URL(string: self.baseUrl)!, requestEncodeType: encodeType)) { [weak self] (data, _, error) in
                guard let self = self else { return }
                guard self.handleResponse(observer: observer, data: data, error: error) else { return }
                observer.onNext(Void())
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // MARK: - private
    private func handleResponse<T>(observer: AnyObserver<T>, data: Data?, error: Error?) -> Bool {
        guard error == nil else { return false }
        guard let data = data else { return false }
        var encodedData: [String: Any] = [:]
        if data.count > 0 {
            do {
                encodedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] ?? [:]
            } catch _ { return false }
        }
        if (encodedData["error"] as? String ??
            encodedData["message"] as? String) != nil { return false }
        return true
    }
}
