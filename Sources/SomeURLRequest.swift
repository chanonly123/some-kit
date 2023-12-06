//
//  ApiManager.swift
//  melodyze-core
//
//  Created by Chandan Karmakar on 26/10/23.
//

import Foundation
import OSLog

public enum SomeURLRequestHttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

public enum SomeURLRequestError: Error {
    case apiFailed(status: Int?, message: String?)
    case badUrl
}

public enum SomeURLRequestBodyType {
    case json
    case urlEncoded
}

@available(iOS 13.0.0, *)
public struct SomeURLRequest {
    
    private var session: URLSession
    private let interceptor: SomeURLRequestInterceptor?
    
    public init(interceptor: SomeURLRequestInterceptor?) {
        self.interceptor = interceptor
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 50
        configuration.timeoutIntervalForResource = 50
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    public func send<T: Codable>(url: String,
                        path: [String: String] = [:],
                        query: [String: String] = [:],
                        body: [String: Any] = [:],
                        header: [String: String] = [:],
                        bodyType: SomeURLRequestBodyType = .json,
                        method: SomeURLRequestHttpMethod) async throws -> (T, HTTPURLResponse) {
        
        var url = url
        path.forEach { url = url.replacingOccurrences(of: "{\($0.key)}", with: $0.value) }
        
        guard var url_ = URL(string: url) else {
            throw SomeURLRequestError.badUrl
        }
        
        var queryItems = [URLQueryItem]()
        query.forEach { (key: String, value: String) in
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var urlComps = URLComponents(string: url)
        urlComps?.queryItems = queryItems
        if let urlResult = urlComps?.url {
            url_ = urlResult
            url = url_.absoluteString
        } else {
            throw SomeURLRequestError.badUrl
        }
        
        var request = URLRequest(url: url_)
        
        switch bodyType {
        case .json:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            if method != .get { request.httpBody = jsonData }
        case .urlEncoded:
            break
        }
        
        request.allHTTPHeaderFields = header
        request.httpMethod = method.rawValue
        
        try await interceptor?.onRequest(&request)
        
        let id = String(Int64(Date().timeIntervalSince1970) * 1000)
        
        print("🟡request:\(id):\(request.httpMethod!):\(url):\(body):\(request.allHTTPHeaderFields ?? [:])")
        let res = try await session.data(for: request)
        var args: (Data, HTTPURLResponse) = (res.0, res.1 as! HTTPURLResponse)
        
        if let interceptor {
            args = try await interceptor.updateResponse((args.0, args.1))
        }
        
        let data = args.0
        let response = args.1
        let str = String(data: data, encoding: .utf8) ?? ""
        
        lazy var message: String? = {
            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dict["message"] as? String
            }
            return nil
        }()
        
        guard 200...299 ~= response.statusCode else {
            print("🔴response:\(id):\(url):\(body):\(request.allHTTPHeaderFields ?? [:]) 🅿️\(response.statusCode):\(str)")
            throw SomeURLRequestError.apiFailed(status: response.statusCode, message: message)
        }
        print("🟢response:\(id):\(url):\(body):\(request.allHTTPHeaderFields ?? [:]) 🅿️\(str)")
        let obj = try JSONDecoder().decode(T.self, from: data)
        return (obj, response)
    }
}
