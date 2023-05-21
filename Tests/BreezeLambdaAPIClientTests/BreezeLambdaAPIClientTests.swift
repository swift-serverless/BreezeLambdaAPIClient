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

import XCTest
@testable import BreezeLambdaAPIClient

class TestLogger: APIClientLogging {
    
    var request: URLRequest?
    var data: Data?
    var response: URLResponse?
    
    func log(request: URLRequest) {
        self.request = request
    }
    
    func log(data: Data, for response: URLResponse) {
        self.data = data
        self.response = response
    }
}

final class BreezeLambdaAPIClientTests: XCTestCase {
    
    var sut: BreezeLambdaAPIClient<TestItem>!
    var env: APIClientEnv!
    let token = "some token"
    var logger: TestLogger!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        logger = TestLogger()
        env = try APIClientEnv(session: session, baseURL: "http://localhost")
        env.logger = logger
        sut = BreezeLambdaAPIClient<TestItem>(env: env, path: "item", additionalHeaders: ["ClientType": "iOS"])
    }

    override func tearDownWithError() throws {
        sut = nil
        logger = nil
        env = nil
        URLProtocolMock.response = nil
        URLProtocolMock.error = nil
        URLProtocolMock.testURLs = [URL?: Data]()
        try super.tearDownWithError()
    }
    
    func testInit() {
        XCTAssertEqual(sut.headers["ClientType"], "iOS")
        XCTAssertEqual(sut.env.baseURL, URL(string: "http://localhost"))
        XCTAssertEqual(sut.env.session.configuration.protocolClasses?.count, 1)
    }
    
    // MARK: - Create

    func testCreate_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let created = try await sut.create(token: token, item: item)
        XCTAssertEqual(created.key, Mocks.item.key)
        XCTAssertEqual(logger.request?.url, url)
        XCTAssertEqual(logger.request?.httpMethod, "POST")
        XCTAssertNotNil(logger.request?.httpBody)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?.count, 4)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["ClientType"], "iOS")
    }
    
    func testCreate_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.create(token: token, item: item)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    func testCreate_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.create(token: token, item: item)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    // MARK: - Read

    func testRead_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let readed = try await sut.read(token: token, key: item.key)
        XCTAssertEqual(readed.key, item.key)
        XCTAssertEqual(logger.request?.url, url)
        XCTAssertEqual(logger.request?.httpMethod, "GET")
        XCTAssertNil(logger.request?.httpBody)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?.count, 4)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["ClientType"], "iOS")
    }
    
    func testRead_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.read(token: token, key: item.key)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    func testRead_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.read(token: token, key: item.key)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    // MARK: - Update

    func testUpdate_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let updated = try await sut.update(token: token, item: item)
        XCTAssertEqual(updated.key, Mocks.item.key)
        XCTAssertEqual(logger.request?.url, url)
        XCTAssertEqual(logger.request?.httpMethod, "PUT")
        XCTAssertNotNil(logger.request?.httpBody)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?.count, 4)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["ClientType"], "iOS")
    }
    
    func testUpdate_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.update(token: token, item: item)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    func testUpdate_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try XCTUnwrap(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.update(token: token, item: item)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    // MARK: - Delete

    func testDelete_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
        XCTAssertEqual(logger.request?.url, url)
        XCTAssertEqual(logger.request?.httpMethod, "DELETE")
        XCTAssertNil(logger.request?.httpBody)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?.count, 4)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["ClientType"], "iOS")
    }
    
    func testDelete_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    func testDelete_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try XCTUnwrap(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    // MARK: - List

    func testList_success() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try XCTUnwrap(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let readed = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
        XCTAssertEqual(readed.count, 2)
        XCTAssertEqual(logger.request?.url, url)
        XCTAssertEqual(logger.request?.httpMethod, "GET")
        XCTAssertNil(logger.request?.httpBody)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?.count, 4)
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(logger.request?.allHTTPHeaderFields?["ClientType"], "iOS")
    }
    
    func testList_failure() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try XCTUnwrap(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
    
    func testList_invalid() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try XCTUnwrap(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
            XCTFail("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            XCTAssertNotNil(apiError)
        }
        XCTAssertEqual(logger.request?.url, url)
    }
}
