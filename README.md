# swift-sqlite

swift-sqlite is a cross-platform modernization of the [SQLite.swift] project. 

It includes [SQLite3] with [Full-text search] and [SQLCipher] extensions,
and works out-of-the-box on macOS, iOS, Linux, Android, and Windows.

## Features

 - A pure-Swift interface
 - A type-safe, optional-aware SQL expression builder
 - A flexible, chainable, lazy-executing query layer
 - Embeds a modern and consistent sqlite (3.44.2) build with the library
 - Automatically-typed data access
 - A lightweight, uncomplicated query and parameter binding interface
 - Developer-friendly error handling and debugging
 - [Full-text search][] support
 - [Well-documented][See Documentation]
 - Extensively tested
 - [SQLCipher][] support using the embedded [LibTomCrypt][] library
 - [Schema query/migration][]
 - Works on iOS, macOS, Android, Windows, and Linux

[SQLCipher]: https://www.zetetic.net/sqlcipher/
[LibTomCrypt]: http://www.libtom.net/LibTomCrypt/
[Full-text search]: Documentation/Index.md#full-text-search
[Schema query/migration]: Documentation/Index.md#querying-the-schema
[See Documentation]: Documentation/Index.md#sqliteswift-documentation

## Usage

```swift
import SQLiteDB

// Wrap everything in a do...catch to handle errors
do {
    let db = try Connection("path/to/db.sqlite3")

    let users = Table("users")
    let id = SQLExpression<Int64>("id")
    let name = SQLExpression<String?>("name")
    let email = SQLExpression<String>("email")

    try db.run(users.create { t in
        t.column(id, primaryKey: true)
        t.column(name)
        t.column(email, unique: true)
    })
    // CREATE TABLE "users" (
    //     "id" INTEGER PRIMARY KEY NOT NULL,
    //     "name" TEXT,
    //     "email" TEXT NOT NULL UNIQUE
    // )

    let insert = users.insert(name <- "Alice", email <- "alice@mac.com")
    let rowid = try db.run(insert)
    // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')

    for user in try db.prepare(users) {
        print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
        // id: 1, name: Optional("Alice"), email: alice@mac.com
    }
    // SELECT * FROM "users"

    let alice = users.filter(id == rowid)

    try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
    // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
    // WHERE ("id" = 1)

    try db.run(alice.delete())
    // DELETE FROM "users" WHERE ("id" = 1)

    try db.scalar(users.count) // 0
    // SELECT count(*) FROM "users"
} catch {
    print (error)
}
```

SQLiteDB also works as a lightweight, Swift-friendly wrapper over the C
API.

```swift
// Wrap everything in a do...catch to handle errors
do {
    // ...

    let stmt = try db.prepare("INSERT INTO users (email) VALUES (?)")
    for email in ["betty@icloud.com", "cathy@icloud.com"] {
        try stmt.run(email)
    }

    db.totalChanges    // 3
    db.changes         // 1
    db.lastInsertRowid // 3

    for row in try db.prepare("SELECT id, email FROM users") {
        print("id: \(row[0]), email: \(row[1])")
        // id: Optional(2), email: Optional("betty@icloud.com")
        // id: Optional(3), email: Optional("cathy@icloud.com")
    }

    try db.scalar("SELECT count(*) FROM users") // 2
} catch {
    print (error)
}
```

[Read the documentation][See Documentation]

## Installation

### Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code.

1. Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
      .package(url: "https://github.com/skiptools/swift-sqlite.git", from "1.0.0")
  ]
  ```

2. Build your project:

  ```sh
  $ swift build
  ```

[Swift Package Manager]: https://swift.org/package-manager


## Communication

[See the planning document] for a roadmap and existing feature requests.

[Read the contributing guidelines][]. The _TL;DR_ (but please; _R_):

 - Need **help** or have a **general question**? [Ask on Stack
   Overflow][] (tag `sqlite.swift`).
 - Found a **bug** or have a **feature request**? [Open an issue][].
 - Want to **contribute**? [Submit a pull request][].

[Read the contributing guidelines]: ./CONTRIBUTING.md#contributing
[Ask on Stack Overflow]: https://stackoverflow.com/questions/tagged/sqlite.swift
[Open an issue]: https://github.com/skiptools/swift-sqlite/issues/new
[Submit a pull request]: https://github.com/skiptools/swift-sqlite/fork


## Original author

 - [Stephen Celis](mailto:stephen@stephencelis.com)
   ([@stephencelis](https://twitter.com/stephencelis))


## License

SQLite.swift is available under the MIT license. See [the LICENSE
file](./LICENSE.txt) for more information.

## Alternatives

Looking for something else? Try another Swift wrapper (or [FMDB][]):

 - [SQLite.swift](https://github.com/stephencelis/SQLite.swift)
 - [GRDB](https://github.com/groue/GRDB.swift)

[Swift]: https://swift.org/
[SQLite3]: https://www.sqlite.org
[SQLite.swift]: https://github.com/stephencelis/SQLite.swift
[FMDB]: https://github.com/ccgus/fmdb
