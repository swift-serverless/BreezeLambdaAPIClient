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
import Synchronization
@testable import BreezeLambdaAPIClient

final class TestLogger: APIClientLogging, Sendable {
    
    nonisolated(unsafe) var request: URLRequest?
    nonisolated(unsafe) var data: Data?
    nonisolated(unsafe) var response: URLResponse?
    
    func log(request: URLRequest) {
        self.request = request
    }
    
    func log(data: Data, for response: URLResponse) {
        self.data = data
        self.response = response
    }
}

@Suite(.serialized)
final class BreezeLambdaAPIClientTests {
    
    let sut: BreezeLambdaAPIClient<TestItem>
    let env: APIClientEnv
    let token = "some token"
    let logger: TestLogger

    init() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        logger = TestLogger()
        env = try APIClientEnv(session: session, baseURL: "http://localhost", logger: logger)
        sut = BreezeLambdaAPIClient<TestItem>(env: env, path: "item", additionalHeaders: ["ClientType": "iOS"])
    }

    deinit {
        URLProtocolMock.response = nil
        URLProtocolMock.error = nil
        URLProtocolMock.testURLs = [URL?: Data]()
    }
    
    func testInit() {
        #expect(sut.headers["ClientType"] == "iOS")
        #expect(sut.env.baseURL == URL(string: "http://localhost"))
        #expect(sut.env.session.configuration.protocolClasses?.count == 1)
    }
    
    // MARK: - Create

    @Test
    func create_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let created = try await sut.create(token: token, item: item)
        #expect(created.key == Mocks.item.key)
        #expect(logger.request?.url == url)
        #expect(logger.request?.httpMethod == "POST")
        #expect(logger.request?.httpBody != nil)
        #expect(logger.request?.allHTTPHeaderFields?.count == 4)
        #expect(logger.request?.allHTTPHeaderFields?["Authorization"] == "Bearer \(token)")
        #expect(logger.request?.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(logger.request?.allHTTPHeaderFields?["Cache-Control"] == "no-cache")
        #expect(logger.request?.allHTTPHeaderFields?["ClientType"] == "iOS")
    }
    
    @Test
    func create_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.create(token: token, item: item)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    @Test
    func create_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.create(token: token, item: item)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    // MARK: - Read

    @Test
    func read_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let readed = try await sut.read(token: token, key: item.key)
        #expect(readed.key == item.key)
        #expect(logger.request?.url == url)
        #expect(logger.request?.httpMethod == "GET")
        #expect(logger.request?.httpBody == nil)
        #expect(logger.request?.allHTTPHeaderFields?.count == 4)
        #expect(logger.request?.allHTTPHeaderFields?["Authorization"] == "Bearer \(token)")
        #expect(logger.request?.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(logger.request?.allHTTPHeaderFields?["Cache-Control"] == "no-cache")
        #expect(logger.request?.allHTTPHeaderFields?["ClientType"] == "iOS")
    }
    
    @Test
    func read_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.read(token: token, key: item.key)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    @Test
    func read_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item/key"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.read(token: token, key: item.key)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    // MARK: - Update

    @Test
    func update_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let updated = try await sut.update(token: token, item: item)
        #expect(updated.key == Mocks.item.key)
        #expect(logger.request?.url == url)
        #expect(logger.request?.httpMethod == "PUT")
        #expect(logger.request?.httpBody != nil)
        #expect(logger.request?.allHTTPHeaderFields?.count == 4)
        #expect(logger.request?.allHTTPHeaderFields?["Authorization"] == "Bearer \(token)")
        #expect(logger.request?.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(logger.request?.allHTTPHeaderFields?["Cache-Control"] == "no-cache")
        #expect(logger.request?.allHTTPHeaderFields?["ClientType"] == "iOS")
    }
    
    @Test
    func update_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.update(token: token, item: item)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    @Test
    func update_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let url = try #require(URL(string: "http://localhost/item"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.update(token: token, item: item)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    // MARK: - Delete

    @Test
    func delete_success() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try #require(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
        #expect(logger.request?.url == url)
        #expect(logger.request?.httpMethod == "DELETE")
        #expect(logger.request?.httpBody == nil)
        #expect(logger.request?.allHTTPHeaderFields?.count == 4)
        #expect(logger.request?.allHTTPHeaderFields?["Authorization"] == "Bearer \(token)")
        #expect(logger.request?.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(logger.request?.allHTTPHeaderFields?["Cache-Control"] == "no-cache")
        #expect(logger.request?.allHTTPHeaderFields?["ClientType"] == "iOS")
    }
    
    @Test
    func delete_failure() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try #require(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    @Test
    func delete_invalid() async throws {
        let item = Mocks.item
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let createdAt = Date().ISO8601Format()
        let updatedAt = Date().ISO8601Format()
        let url = try #require(URL(string: "http://localhost/item/key?createdAt=\(createdAt)&updatedAt=\(updatedAt)"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            try await sut.delete(token: token, key: item.key, createdAt: createdAt, updatedAt: updatedAt)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    // MARK: - List

    @Test
    func list_success() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try #require(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let readed = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
        #expect(readed.count == 2)
        #expect(logger.request?.url == url)
        #expect(logger.request?.httpMethod == "GET")
        #expect(logger.request?.httpBody == nil)
        #expect(logger.request?.allHTTPHeaderFields?.count == 4)
        #expect(logger.request?.allHTTPHeaderFields?["Authorization"] == "Bearer \(token)")
        #expect(logger.request?.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(logger.request?.allHTTPHeaderFields?["Cache-Control"] == "no-cache")
        #expect(logger.request?.allHTTPHeaderFields?["ClientType"] == "iOS")
    }
    
    @Test
    func list_failure() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try #require(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
    
    @Test
    func list_invalid() async throws {
        let list = Mocks.list
        let encoder = JSONEncoder()
        let data = try encoder.encode(list)
        let url = try #require(URL(string: "http://localhost/item?exclusiveStartKey=start-key&limit=100"))
        URLProtocolMock.testURLs = [url : data]
        URLProtocolMock.response = URLResponse(url: url, mimeType: nil,
                                               expectedContentLength: 0,
                                               textEncodingName: nil)
        do {
            _ = try await sut.list(token: token, exclusiveStartKey: "start-key", limit: 100)
            Issue.record("It should throw and error")
        } catch {
            let apiError = error as? APIClientError
            #expect(apiError != nil)
        }
        #expect(logger.request?.url == url)
    }
}
