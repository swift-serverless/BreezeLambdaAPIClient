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
import BreezeLambdaAPIClient

struct TestItem: KeyedCodable {
    var key: String
    let boolValue: Bool
    let stringValue: String
    let intValue: Int
    let dictionaryValue: [String: String]
    let arrayValue: [TestItem]
}

struct Mocks {
    static let item = TestItem(
        key: "key",
        boolValue: true,
        stringValue: "string",
        intValue: 1,
        dictionaryValue: ["A": "B"],
        arrayValue: [
            TestItem(
                key: "key1_0",
                boolValue: true,
                stringValue: "string0",
                intValue: 0,
                dictionaryValue: ["A0": "B0"],
                arrayValue: []
            )
        ]
    )
    
    static let list: [String: [TestItem]] = [
        "items": [
            TestItem(
                key: "key",
                boolValue: true,
                stringValue: "string",
                intValue: 1,
                dictionaryValue: ["A": "B"],
                arrayValue: [
                    TestItem(
                        key: "key1_0",
                        boolValue: true,
                        stringValue: "string0",
                        intValue: 0,
                        dictionaryValue: ["A0": "B0"],
                        arrayValue: []
                    )
                ]
            ),
            TestItem(
                key: "key2",
                boolValue: true,
                stringValue: "string",
                intValue: 2,
                dictionaryValue: ["A": "B"],
                arrayValue: [
                    TestItem(
                        key: "key2_0",
                        boolValue: true,
                        stringValue: "string0",
                        intValue: 2,
                        dictionaryValue: ["A2": "B2"],
                        arrayValue: []
                    )
                ]
            )
        ]
    ]
}
