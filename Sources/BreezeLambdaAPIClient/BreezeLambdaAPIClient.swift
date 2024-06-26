//    Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-serverless
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

public protocol KeyedCodable: Codable {
    var key: String { get }
}

private struct Items<Item: KeyedCodable>: Codable {
    let items: [Item]
}

public struct BreezeLambdaAPIClient<Item: KeyedCodable> {
    
    let env: APIClientEnv
    let path: String
    let headers: RequestHeaders
    let requestBuilder: BreezeRequest<Item>
    
    public init(env: APIClientEnv, path: String, additionalHeaders: RequestHeaders) {
        self.env = env
        self.path = path
        let requiredHeaders: RequestHeaders = [
            "Content-Type": "application/json",
            "cache-control": "no-cache",
        ]
        self.headers = requiredHeaders.merging(additionalHeaders, uniquingKeysWith: { _, new in
            new
        })
        self.requestBuilder = BreezeRequest<Item>(env: env, path: path, headers: headers)
    }
    
    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            env.logger?.log(data: data, for: response)
            throw APIClientError.invalidResponse
        }
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            env.logger?.log(data: data, for: response)
            throw APIClientError.httpError(code: httpResponse.statusCode, data: data)
        }
        env.logger?.log(data: data, for: response)
    }
    
    public func create(token: String?, item: Item) async throws -> Item {
        let request = try requestBuilder.create(token: token, item: item)
        let (data, response) = try await env.session.data(for: request)
        try validateResponse(data: data, response: response)
        return try env.decoder.decode(Item.self, from: data)
    }
    
    public func read(token: String?, key: String) async throws -> Item {
        let request = try requestBuilder.read(token: token, key: key)
        let (data, response) = try await env.session.data(for: request)
        try validateResponse(data: data, response: response)
        return try env.decoder.decode(Item.self, from: data)
    }
    
    public func update(token: String?, item: Item) async throws -> Item {
        let request = try requestBuilder.update(token: token, item: item)
        let (data, response) = try await env.session.data(for: request)
        try validateResponse(data: data, response: response)
        return try env.decoder.decode(Item.self, from: data)
    }
    
    public func delete(token: String?, key: String, createdAt: String, updatedAt: String) async throws {
        let queryItems = [
            URLQueryItem(name: "createdAt", value: createdAt),
            URLQueryItem(name: "updatedAt", value: updatedAt)
        ]
        let request = try requestBuilder.delete(token: token, key: key, queryItems: queryItems)
        let (data, response) = try await env.session.data(for: request)
        try validateResponse(data: data, response: response)
    }
    
    public func list(token: String?, exclusiveStartKey: String?, limit: Int?) async throws -> [Item] {
        var queryItems: [URLQueryItem] = []
        if let exclusiveStartKey {
            queryItems.append(URLQueryItem(name: "exclusiveStartKey", value: exclusiveStartKey))
        }
        if let limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        let request = try requestBuilder.list(token: token, queryItems: queryItems)
        let (data, response) = try await env.session.data(for: request)
        try validateResponse(data: data, response: response)
        return try env.decoder.decode(Items<Item>.self, from: data).items
    }
}
