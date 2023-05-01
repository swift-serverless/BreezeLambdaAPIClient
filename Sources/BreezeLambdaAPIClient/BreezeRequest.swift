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

import Foundation

struct BreezeRequest<Item: KeyedCodable> {
    
    let env: APIClientEnv
    let path: String
    let headers: RequestHeaders
    
    init(env: APIClientEnv, path: String, headers: RequestHeaders) {
        self.env = env
        self.path = path
        self.headers = headers
    }
    
    func create(item: Item) throws -> URLRequest {
        let body = try env.encoder.encode(item)
        let endpoint = APIEndpoint(env: env, path: path, queryItems: nil)
        return try APIRequestBuilder.post(env: env, endpoint: endpoint, headers: headers, body: body)
    }
    
    func read(key: String) throws -> URLRequest {
        let keyedPath = "\(path)/\(key)"
        let endpoint = APIEndpoint(env: env, path: keyedPath, queryItems: nil)
        return try APIRequestBuilder.get(env: env, endpoint: endpoint, headers: headers)
    }
    
    func update(item: Item) throws -> URLRequest {
        let body = try env.encoder.encode(item)
        let endpoint = APIEndpoint(env: env, path: path, queryItems: nil)
        return try APIRequestBuilder.put(env: env, endpoint: endpoint, headers: headers, body: body)
    }
    
    func delete(key: String) throws -> URLRequest {
        let keyedPath = "\(path)/\(key)"
        let endpoint = APIEndpoint(env: env, path: keyedPath, queryItems: nil)
        return try APIRequestBuilder.delete(env: env, endpoint: endpoint, headers: headers)
    }
    
    func list(queryItems: [URLQueryItem]?) throws -> URLRequest {
        let endpoint = APIEndpoint(env: env, path: path, queryItems: queryItems)
        return try APIRequestBuilder.get(env: env, endpoint: endpoint, headers: headers)
    }
}
