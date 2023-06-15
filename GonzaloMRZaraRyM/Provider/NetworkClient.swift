//
//  NetworkClient.swift
//  GonzaloMRZaraRyM
//
//  Created by neoris on 14/6/23.
//

import Foundation

protocol NetworkClient {
    func sendRequest<T: Decodable>(endPoint: EndPoint, responseModel: T.Type) async -> Result<T, RequestError>
}

extension NetworkClient {
    func sendRequest<T>(endPoint: EndPoint, responseModel: T.Type) async -> Result<T, RequestError> where T: Decodable {
        let kRequestTimeout: TimeInterval = 20
        
        guard let request = createRequest(from: endPoint) else {
            return .failure(.invalidURL)
        }
        
        do {
            URLSession.shared.configuration.timeoutIntervalForRequest = kRequestTimeout
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noHttpResponse)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                    return .failure(.parseError)
                }
                
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.statusError(code: httpResponse.statusCode))
            }
        } catch {
            return .failure(.unknown)
        }
    }
    
    // MARK: - Private methods
    
    private func createRequest(from endPoint: EndPoint) -> URLRequest? {
        // Url
        guard let url = composeUrl(url: endPoint.basePath + endPoint.path, params: endPoint.urlParameters) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        // Method
        request.httpMethod = endPoint.method.rawValue
        
        // Body
        if let body = endPoint.postBody {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        // Custom headers
        if let customHeaders = endPoint.customHeaders {
            for (header, value) in customHeaders {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        
        return request
    }
    
    private func composeUrl(url: String, params: [String: String]?) -> URL? {
        guard let params = params else { return URL(string: url) }
        
        guard let url = URL(string: url) else { return nil }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        let queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
}

// MARK: - EndPoint

protocol EndPoint {
    var basePath: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var postBody: [String: String]? { get }
    var urlParameters: [String: String]? { get }
    var customHeaders: [String: String]? { get }
}

enum HttpMethod: String {
    case post   = "POST"
    case get    = "GET"
    case delete = "DELETE"
    case put    = "PUT"
}

enum RequestError: Error {
    case invalidURL
    case noData
    case noHttpResponse
    case noInternetConnection
    case parseError
    case statusError(code: Int)
    case unauthorized
    case unknown
}
