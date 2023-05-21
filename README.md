# BreezeLambdaAPIClient

This is a client for the [Breeze Lambda API](https://github.com/swift-sprinter/Breeze) (from version 0.2.0).

![Breeze](logo.png)

## Installation

### Swift Pacakge Manager

Add BreezeLambdaAPIClient as a dependency to the dependencies value of your `Package.swift`.

```swift
    dependencies: [
        //...
        .package(url: "https://github.com/swift-sprinter/BreezeLmabdaAPIClient.git", from: "0.2.0"),
        // ...
    ]
)
```

## Usage

The following example shows how to use the client to create, read, update, delete and list items.
The `Item` is a struct that conforms to `Codable`.
The `Item` must be shared between the client and the [Breeze Lambda API](https://github.com/swift-sprinter/Breeze).

```swift
import Foundation
import BreezeLambdaAPIClient

struct Item: Codable {
    var key: String?
    var name: String
    var description: String
    var createdAt: Date?
    var updatedAt: Date?
}

struct APIService {
    
    private let apiClient: BreezeLambdaAPIClient<Item>
    
    private var token: String? 
    
    init(session: SessionService) {
        guard var env = try? APIEnvironment.dev() else {
            fatalError("Invalid Environment")
        }
        env.logger = Logger()
        self.session = session
        self.apiClient = BreezeLambdaAPIClient<Item>(env: env, path: "forms", additionalHeaders: [:])
    }
    
    func create(form: Item) async throws -> Item {
        try await apiClient.create(token: token, item: form)
    }
    
    func read(key: String) async throws -> Item {
        try await apiClient.read(token: token, key: key)
    }
    
    func update(form: Item) async throws -> Item {
        try await apiClient.update(token: token, item: form)
    }
    
    func delete(form: Item) async throws {
        guard let updatedAt = form.updatedAt,
              let createdAt = form.createdAt else {
            throw FormServiceError.invalidForm
        }
        try await apiClient.delete(token: token, key: form.key, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    func list(startKey: String?, limit: Int?) async throws -> [Item] {
        try await apiClient.list(token: token, exclusiveStartKey: startKey, limit: limit)
    }
}

struct APIEnvironment {
    static func dev() throws -> APIClientEnv {
        try APIClientEnv(session: URLSession.shared, baseURL: "<API GATEWAY URL>", logger: nil)
    }
}

extension Item: KeyedCodable {}

struct Logger: APIClientLogging {
    func log(request: URLRequest) {
        print(request)
    }
    
    func log(data: Data, for response: URLResponse) {
        print(response)
        let value = String(data: data, encoding: .utf8) ?? ""
        print(value)
    }
}

enum FormServiceError: Error {
    case invalidForm
}
```