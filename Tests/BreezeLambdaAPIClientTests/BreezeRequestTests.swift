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

import XCTest
@testable import BreezeLambdaAPIClient

final class BreezeRequestTests: XCTestCase {
    
    var environment: APIClientEnv!
    var sut: BreezeRequest<TestItem>!
    let baseURL: String = "https://apitest123.execute-api.us-east-1.amazonaws.com"

    override func setUpWithError() throws {
        let session = URLSession(configuration: .ephemeral)
        environment = try APIClientEnv(session: session, baseURL: baseURL)
        sut = BreezeRequest(env: environment, path: "items", headers: [
            "Content-Type": "application/json",
            "cache-control": "no-cache"
        ])
    }

    override func tearDownWithError() throws {
        sut = nil
        environment = nil
    }

    func testInit() throws {
        XCTAssertEqual(sut.env.baseURL.absoluteString, baseURL)
        XCTAssertEqual(sut.path, "items")
        XCTAssertEqual(sut.headers.count, 2)
        XCTAssertEqual(sut.headers["Content-Type"], "application/json")
        XCTAssertEqual(sut.headers["cache-control"], "no-cache")
    }
    
    func testCreate() throws {
        let request = try sut.create(token: "some-bearer-token", item: Mocks.item)
        XCTAssertEqual(request.url?.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 3)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer some-bearer-token")
        XCTAssertNotNil(request.httpBody)
        let body: TestItem = try XCTUnwrap(request.decodeBody())
        XCTAssertNotNil(body.key, "key")
        XCTAssertNotNil(body.arrayValue[0].key, "key")
    }
    
    func testRead() throws {
        let request = try sut.read(token: "some-bearer-token", key: "key")
        XCTAssertEqual(request.url?.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/items/key")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 3)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer some-bearer-token")
        XCTAssertNil(request.httpBody)
    }
    
    func testUpdate() throws {
        let request = try sut.update(token: "some-bearer-token", item: Mocks.item)
        XCTAssertEqual(request.url?.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 3)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer some-bearer-token")
        XCTAssertNotNil(request.httpBody)
        let body: TestItem = try XCTUnwrap(request.decodeBody())
        XCTAssertNotNil(body.key, "key")
        XCTAssertNotNil(body.arrayValue[0].key, "key")
    }
    
    func testDelete() throws {
        let queryItems = [
            URLQueryItem(name: "createdAt", value: Date().ISO8601Format()),
            URLQueryItem(name: "updatedAt", value: Date().ISO8601Format())
        ]
        let request = try sut.delete(token: "some-bearer-token", key: "key", queryItems: queryItems)
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "apitest123.execute-api.us-east-1.amazonaws.com")
        XCTAssertEqual(request.url?.path, "/items/key")
        XCTAssertEqual(request.url?.query?.contains("createdAt"), true)
        XCTAssertEqual(request.url?.query?.contains("updatedAt"), true)
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 3)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer some-bearer-token")
        XCTAssertNil(request.httpBody)
    }
    
    func testList_withoutQueryItems() throws {
        let request = try sut.list(token: "some-bearer-token", queryItems: nil)
        XCTAssertEqual(request.url?.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/items")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 3)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer some-bearer-token")
        XCTAssertNil(request.httpBody)
    }
}

extension URLRequest {
    
    static let decoder = JSONDecoder()
    
    func decodeBody<Item: KeyedCodable>() throws -> Item? {
        guard let httpBody else { return nil }
        return try Self.decoder.decode(Item.self, from: httpBody)
    }
}
