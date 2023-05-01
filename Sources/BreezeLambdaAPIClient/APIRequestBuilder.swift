//    Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-sprinter
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

import Foundation

public typealias RequestHeaders = [String: String]

enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}

enum APIRequestBuilder {
    static func request(env: APIClientEnv,
                        method: HTTPMethod,
                        endpoint: APIEndpoint,
                        headers: RequestHeaders,
                        body: Data?) throws -> URLRequest {
        var request = URLRequest(url: try endpoint.url())
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.cachePolicy = env.cachePolicy
        env.logger?.log(request: request)
        return request
    }
    
    static func get(env: APIClientEnv,
                    endpoint: APIEndpoint,
                    headers: RequestHeaders) throws -> URLRequest {
        try request(env: env, method: .get, endpoint: endpoint, headers: headers, body: nil)
    }
    
    static func delete(env: APIClientEnv,
                       endpoint: APIEndpoint,
                       headers: RequestHeaders) throws -> URLRequest {
        try request(env: env, method: .delete, endpoint: endpoint, headers: headers, body: nil)
    }
    
    static func post(env: APIClientEnv,
                     endpoint: APIEndpoint,
                     headers: RequestHeaders,
                     body: Data?) throws -> URLRequest {
        try request(env: env, method: .post, endpoint: endpoint, headers: headers, body: body)
    }
    
    static func put(env: APIClientEnv,
                    endpoint: APIEndpoint,
                    headers: RequestHeaders,
                    body: Data?) throws -> URLRequest {
        try request(env: env, method: .put, endpoint: endpoint, headers: headers, body: body)
    }
}
