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

final class APIEndpointTests: XCTestCase {
    
    var environment: APIClientEnv!
    var sut: APIEndpoint!
    let baseURL: String = "https://apitest123.execute-api.us-east-1.amazonaws.com"
    
    override func setUpWithError() throws {
        let session = URLSession(configuration: .ephemeral)
        environment = try APIClientEnv(session: session, baseURL: baseURL)
    }

    override func tearDownWithError() throws {
        environment = nil
    }
    
    func testInit() throws {
        sut = APIEndpoint(env: environment, path: "path", queryItems: [URLQueryItem(name: "name", value: "value")])
        XCTAssertEqual(sut.path, "path")
    }
    
    func testUrl_whenNoPathAndNoQueryItemes() throws {
        sut = APIEndpoint(env: environment, path: "", queryItems: nil)
        let url = try sut.url()
        XCTAssertEqual(url.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com")
    }
    
    func testUrl_whenNoQueryItemes() throws {
        sut = APIEndpoint(env: environment, path: "path", queryItems: nil)
        let url = try sut.url()
        XCTAssertEqual(url.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/path")
    }
    
    func testUrl_whenNoPathAndQueryItemes() throws {
        sut = APIEndpoint(env: environment, path: "", queryItems: [URLQueryItem(name: "name", value: "value")])
        let url = try sut.url()
        XCTAssertEqual(url.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com?name=value")
    }
    
    func testUrl_whenQueryItemes() throws {
        sut = APIEndpoint(env: environment, path: "path", queryItems: [URLQueryItem(name: "name", value: "value")])
        let url = try sut.url()
        XCTAssertEqual(url.absoluteString, "https://apitest123.execute-api.us-east-1.amazonaws.com/path?name=value")
    }
}
