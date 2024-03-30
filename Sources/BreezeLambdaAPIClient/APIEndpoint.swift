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

struct APIEndpoint {
    let path: String
    let queryItems: [URLQueryItem]?

    private let env: APIClientEnv

    init(env: APIClientEnv,
         path: String,
         queryItems: [URLQueryItem]?) {
        self.path = path
        self.queryItems = queryItems
        self.env = env
    }
    
    func url() throws -> URL {
        var endpointURL = env.baseURL
        if !path.isEmpty {
            endpointURL = env.baseURL.appendingPathComponent(path)
        }

        guard let queryItems = queryItems else {
            return endpointURL
        }

        guard !queryItems.isEmpty,
              var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            return endpointURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }
        return url
    }
}
