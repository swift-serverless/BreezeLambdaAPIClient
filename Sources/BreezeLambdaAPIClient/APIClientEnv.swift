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

public struct APIClientEnv: Sendable {

    public let session: URLSession

    public let baseURL: URL
    
    public let cachePolicy: NSURLRequest.CachePolicy
    public let logger: APIClientLogging?
    public let decoder: JSONDecoder
    public let encoder: JSONEncoder

    public init(
        session: URLSession,
        baseURL: String,
        cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy,
        logger: APIClientLogging? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.session = session
        self.logger = logger
        self.decoder = decoder
        self.encoder = encoder
        self.cachePolicy = cachePolicy
        guard let url = URL(string: baseURL) else {
            throw APIClientError.invalidURL
        }
        self.baseURL = url
    }
}
