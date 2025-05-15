
## Package Trait Example

This example demonstrates conditionally including `swift-sqlcipher` based on a [package trait](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0450-swiftpm-package-traits.md) in order to support both plain `SQLite3` as well as `SQLCipher` from the same package.

There are three separate packages in this example:

```
SQLMiddleware
├── Package.swift
└── Sources
    └── SQLMiddleware
        └── SQLMiddleware.swift

MiddlewareClientWithSQLCipher
├── Package.swift
├── Sources
│   └── MiddlewareClientWithSQLCipher
│       └── MiddlewareClientWithSQLCipher.swift
└── Tests
    └── MiddlewareClientWithSQLCipherTests
        └── MiddlewareClientWithSQLCipherTests.swift

MiddlewareClientWithoutSQLCipher
├── Package.swift
├── Sources
│   └── MiddlewareClientWithoutSQLCipher
│       └── MiddlewareClientWithoutSQLCipher.swift
└── Tests
    └── MiddlewareClientWithoutSQLCipherTests
        └── MiddlewareClientWithoutSQLCipherTests.swift
```

### SQLMiddleware

The package with the dependency on `swift-sqlcipher` that publishes a "SQLCipher" trait enabling client packages to enable the `SQLCipher` import based on the dependency declaration in their `Package.swift`.

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SQLMiddleware",
    products: [
        .library(name: "SQLMiddleware", targets: ["SQLMiddleware"]),
    ],
    traits: [
        .trait(name: "SQLCipher", description: "Use the SQLCipher library rather than the vendored SQLite")
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/swift-sqlcipher.git", from: "1.4.0")
    ],
    targets: [
        .target(name: "SQLMiddleware", dependencies: [
            // target only depends on SQLCipher when the "SQLCipher" trait is activated by a dependent package
            // otherwise it will default to using the system "SQLite3" framework
            .product(name: "SQLCipher", package: "swift-sqlcipher", condition: .when(traits: ["SQLCipher"]))
        ])
    ]
)
```


The `SQLMiddleware` module has just a single top-level function `middlewareDatabaseType()` that will return either "SQLCipher <version>" or "SQLite3 <version>" depending on whether it was included with the "SQLCipher" trait.
 
 ```swift
 #if canImport(SQLCipher)
 import SQLCipher
 #else
 import SQLite3
 #endif
 
 public func databaseVersion() -> String? {
     #if canImport(SQLCipher)
     let dbtype = "SQLCipher"
     let sql = "PRAGMA cipher_version;"
     #else
     let dbtype = "SQLite3"
     let sql = "SELECT sqlite_version();"
     #endif
     let version = queryString(sql: sql)
     return "\(dbtype) \(version ?? "unknown")"
 }
 
 public func queryString(sql: String, databasePath: String = ":memory:") -> String? { 
    if sqlite3_open(databasePath, &db) == SQLITE_OK {
        etc…
    }
}
 ```
 
 
### MiddlewareClientWithSQLCipher

A dependent of `SQLMiddleware` that enables the `SQLCipher` trait.

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MiddlewareClientWithSQLCipher",
    products: [
        .library(name: "MiddlewareClientWithSQLCipher",
            targets: ["MiddlewareClientWithSQLCipher"])
    ],
    dependencies: [
        .package(path: "../SQLMiddleware", traits: ["SQLCipher"])
    ],
    targets: [
        .target(name: "MiddlewareClientWithSQLCipher", dependencies: [
            .product(name: "SQLMiddleware", package: "SQLMiddleware")
        ]),
        .testTarget(name: "MiddlewareClientWithSQLCipherTests",
            dependencies: ["MiddlewareClientWithSQLCipher"])
    ]
)
```

It contains a test case:

```swift
@Test func testDatabaseIsSQLCipher() async throws {
    #expect(databaseVersion() == "SQLCipher 4.9.0 community")
}
```

### MiddlewareClientWithoutSQLCipher

A dependent of `SQLMiddleware` that does not enable the `SQLCipher` trait.  It is otherwise identical to `MiddlewareClientWithSQLCipher` in every way.

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MiddlewareClientWithoutSQLCipher",
    products: [
        .library(name: "MiddlewareClientWithoutSQLCipher",
            targets: ["MiddlewareClientWithoutSQLCipher"])
    ],
    dependencies: [
        .package(path: "../SQLMiddleware")
    ],
    targets: [
        .target(name: "MiddlewareClientWithoutSQLCipher", dependencies: [
            .product(name: "SQLMiddleware", package: "SQLMiddleware")
        ]),
        .testTarget(name: "MiddlewareClientWithoutSQLCipherTests",
            dependencies: ["MiddlewareClientWithoutSQLCipher"])
    ]
)
```

It contains a test case:

```swift
@Test func testDatabaseIsSQLite() async throws {
    #expect(databaseVersion() == "SQLite3 3.43.2")
}
```

