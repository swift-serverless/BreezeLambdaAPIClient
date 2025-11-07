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

@Suite
struct APIEndpointTests {
    
    let environment: APIClientEnv
    let baseURL: String = "https://apitest123.execute-api.us-east-1.amazonaws.com"
    
    init() throws {
        let session = URLSession(configuration: .ephemeral)
        environment = try APIClientEnv(session: session, baseURL: baseURL)
    }

    @Test
    func initSetPath() throws {
        let sut = APIEndpoint(env: environment, path: "path", queryItems: [URLQueryItem(name: "name", value: "value")])
        #expect(sut.path == "path")
    }
    
    @Test
    func url_whenNoPathAndNoQueryItemes() throws {
        let sut = APIEndpoint(env: environment, path: "", queryItems: nil)
        let url = try sut.url()
        #expect(url.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com")
    }
    
    @Test
    func url_whenNoQueryItemes() throws {
        let sut = APIEndpoint(env: environment, path: "path", queryItems: nil)
        let url = try sut.url()
        #expect(url.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/path")
    }
    
    @Test
    func url_whenNoPathAndQueryItemes() throws {
        let sut = APIEndpoint(env: environment, path: "", queryItems: [URLQueryItem(name: "name", value: "value")])
        let url = try sut.url()
        #expect(url.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com?name=value")
    }
    
    @Test
    func url_whenQueryItemes() throws {
        let sut = APIEndpoint(env: environment, path: "path", queryItems: [URLQueryItem(name: "name", value: "value")])
        let url = try sut.url()
        #expect(url.absoluteString == "https://apitest123.execute-api.us-east-1.amazonaws.com/path?name=value")
    }
}
