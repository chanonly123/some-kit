//
//  ApiManagerInterceptor.swift
//  melodyze-core
//
//  Created by Chandan Karmakar on 26/10/23.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol SomeURLRequestInterceptor {
    func onRequest(_ request: inout URLRequest) async throws
    func updateResponse(_ args: (data: Data, response: HTTPURLResponse)) async throws -> (data: Data, response: HTTPURLResponse)
}
