# Swift SQLCipher

swift-sqlcipher is a C source packaging of [SQLite3]
with built-in [SQLCipher] and [Full-text search] extensions,
along with a [SQLiteDB] Swift package that provides
API parity with the venerable [SQLite.swift] project.

This is a stand-along and platform-agnostic project, and 
does not presume the presence of any SQLite binary.
It is therefore suitable for embedded projects or 
environments without any accessible `sqlite3.so` library (e.g., Android).

## Features

 - A pure-Swift interface
 - Embeds a modern and consistent sqlite (3.46.1) and sqlcipher (4.6.1) build in the library
 - Works on iOS, macOS, Android, Windows, and Linux
 - A type-safe, optional-aware SQL expression builder
 - A flexible, chainable, lazy-executing query layer
 - Automatically-typed data access
 - A lightweight, uncomplicated query and parameter binding interface
 - Developer-friendly error handling and debugging
 - [Full-text search][] support
 - [Well-documented][See Documentation]
 - Extensively tested
 - [SQLCipher][] support using the embedded [LibTomCrypt][] library
 - [Schema query/migration][]

[SQLCipher]: https://www.zetetic.net/sqlcipher/
[LibTomCrypt]: http://www.libtom.net/LibTomCrypt/
[Full-text search]: Documentation/Index.md#full-text-search
[Schema query/migration]: Documentation/Index.md#querying-the-schema
[See Documentation]: Documentation/Index.md#sqliteswift-documentation

## Usage

```swift
import SQLiteDB

let db = try Connection("path/to/db.sqlite3")

// set the (optional) encryption key for the database
// this must be the first action performed on the Connection
try db.key("x'2DD29CA851E7B56E4697B0E1F08507293D761A05CE4D1B628663F411A8086D99'")

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
```

SQLiteDB also works as a lightweight, Swift-friendly wrapper over the C
API.

```swift
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
```

[Read the documentation][See Documentation]

## Installation

### Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code.

1. Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
      .package(url: "https://github.com/skiptools/swift-sqlcipher.git", from "1.0.0")
  ]
  ```

2. Build your project:

  ```sh
  $ swift build
  ```

[Swift Package Manager]: https://swift.org/package-manager


## Communication

[Read the contributing guidelines][]. The _TL;DR_ (but please; _R_):

 - Found a **bug** or have a **feature request**? [Open an issue][].
 - Want to **contribute**? [Submit a pull request][].

[Read the contributing guidelines]: ./CONTRIBUTING.md#contributing
[Open an issue]: https://github.com/skiptools/swift-sqlcipher/issues/new
[Submit a pull request]: https://github.com/skiptools/swift-sqlcipher/pulls

## License

MIT license. See [the LICENSE file](./LICENSE.txt) for more information.

## Alternatives

Here are a number of other popular SQLite alternative packages:

 - [SQLite.swift](https://github.com/stephencelis/SQLite.swift)
 - [GRDB](https://github.com/groue/GRDB.swift)
 - [swift-toolchain-sqlite](https://github.com/swiftlang/swift-toolchain-sqlite)
 - [FMDB]

[SQLite3]: https://www.sqlite.org
[SQLite.swift]: https://github.com/stephencelis/SQLite.swift
[FMDB]: https://github.com/ccgus/fmdb
