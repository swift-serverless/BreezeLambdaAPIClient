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

//  References:
//  https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
//  https://nshipster.com/nsurlprotocol/

@objc class URLProtocolMock: URLProtocol {
    static var testURLs = [URL?: Data]()
    static var response: URLResponse?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            if let data = URLProtocolMock.testURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        
        if let response = URLProtocolMock.response {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolMock.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {

    }
}
