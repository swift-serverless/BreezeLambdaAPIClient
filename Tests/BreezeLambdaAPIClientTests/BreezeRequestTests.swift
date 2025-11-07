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

import Testing
import Foundation
@testable import BreezeLambdaAPIClient

@Suite(.serialized)
final class BreezeRequestTests {
    
    let environment: APIClientEnv
    let sut: BreezeRequest<TestItem>
    let baseURL: String = "https://apitest123.execute-api.us-east-1.amazonaws.com"

    init() throws {
        let session = URLSession(configuration: .ephemeral)
        environment = try APIClientEnv(session: session, baseURL: baseURL)
        sut = BreezeRequest(env: environment, path: "items", headers: [
            "Content-Type": "application/json",
            "cache-control": "no-cache"
        ])
    }

    @Test
    func initialization() throws {
        #expect(sut.env.baseURL.absoluteString == baseURL)
        #expect(sut.path == "items")
        #expect(sut.headers.count == 2)
        #expect(sut.headers["Content-Type"] == "application/json")
        #expect(sut.headers["cache-control"] == "no-cache")
    }
    
    @Test
    func create() throws {
        let request = try sut.create(token: "some-bearer-token", item: Mocks.item)
        #expect(request.url?.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
         #expect(request.httpMethod == "POST")
         #expect(request.allHTTPHeaderFields?.count == 3)
         #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
         #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer some-bearer-token")
         #expect(request.httpBody != nil)
         let body: TestItem = try #require(try request.decodeBody())
         #expect(body.key == "key")
         #expect(body.arrayValue[0].key == "key1_0")
    }
    
    @Test
    func read() throws {
        let request = try sut.read(token: "some-bearer-token", key: "key")
        #expect(request.url?.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/items/key")
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?.count == 3)
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer some-bearer-token")
        #expect(request.httpBody == nil)
    }
    
    @Test
    func update() throws {
        let request = try sut.update(token: "some-bearer-token", item: Mocks.item)
        #expect(request.url?.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
        #expect(request.httpMethod == "PUT")
        #expect(request.allHTTPHeaderFields?.count == 3)
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer some-bearer-token")
        #expect(request.httpBody != nil)
        let body: TestItem = try #require(try request.decodeBody())
        #expect(body.key == "key")
        #expect(body.arrayValue[0].key == "key1_0")
    }
    
    @Test
    func delete() throws {
        let queryItems = [
            URLQueryItem(name: "createdAt", value: Date().ISO8601Format()),
            URLQueryItem(name: "updatedAt", value: Date().ISO8601Format())
        ]
        let request = try sut.delete(token: "some-bearer-token", key: "key", queryItems: queryItems)
        #expect(request.url?.scheme == "https")
        #expect(request.url?.host == "apitest123.execute-api.us-east-1.amazonaws.com")
        #expect(request.url?.path == "/items/key")
        #expect(request.url?.query?.contains("createdAt") == true)
        #expect(request.url?.query?.contains("updatedAt") == true)
        #expect(request.httpMethod == "DELETE")
        #expect(request.allHTTPHeaderFields?.count == 3)
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer some-bearer-token")
        #expect(request.httpBody == nil)
    }
    
    @Test
    func list_withoutQueryItems() throws {
        let request = try sut.list(token: "some-bearer-token", queryItems: nil)
        #expect(request.url?.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?.count == 3)
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer some-bearer-token")
        #expect(request.httpBody == nil)
    }
}

extension URLRequest {
    
    static let decoder = JSONDecoder()
    
    func decodeBody<Item: KeyedCodable>() throws -> Item? {
        guard let httpBody else { return nil }
        return try Self.decoder.decode(Item.self, from: httpBody)
    }
}
