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

public struct APIClientEnv {

    public let session: URLSession

    public let baseURL: URL
    
    public var cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
    public var logger: APIClientLogging?
    public var decoder: JSONDecoder = JSONDecoder()
    public var encoder: JSONEncoder = JSONEncoder()

    public init(session: URLSession, baseURL: String) throws {
        self.session = session
        guard let url = URL(string: baseURL) else {
            throw APIClientError.invalidURL
        }
        self.baseURL = url
    }
}
