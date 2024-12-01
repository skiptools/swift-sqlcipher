# swift-sqlite Documentation

- [swift-sqlite Documentation](#sqliteswift-documentation)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
  - [Getting Started](#getting-started)
    - [Connecting to a Database](#connecting-to-a-database)
      - [Read-Write Databases](#read-write-databases)
      - [Read-Only Databases](#read-only-databases)
      - [In a shared group container](#in-a-shared-group-container)
      - [In-Memory Databases](#in-memory-databases)
      - [URI parameters](#uri-parameters)
      - [Thread-Safety](#thread-safety)
  - [Building Type-Safe SQL](#building-type-safe-sql)
    - [Expressions](#expressions)
    - [Compound Expressions](#compound-expressions)
    - [Queries](#queries)
  - [Creating a Table](#creating-a-table)
    - [Create Table Options](#create-table-options)
    - [Column Constraints](#column-constraints)
    - [Table Constraints](#table-constraints)
  - [Inserting Rows](#inserting-rows)
    - [Handling SQLite errors](#handling-sqlite-errors)
    - [Setters](#setters)
          - [Infix Setters](#infix-setters)
          - [Postfix Setters](#postfix-setters)
  - [Selecting Rows](#selecting-rows)
    - [Iterating and Accessing Values](#iterating-and-accessing-values)
      - [Failable iteration](#failable-iteration)
    - [Plucking Rows](#plucking-rows)
    - [Building Complex Queries](#building-complex-queries)
      - [Selecting Columns](#selecting-columns)
      - [Joining Other Tables](#joining-other-tables)
        - [Column Namespacing](#column-namespacing)
        - [Table Aliasing](#table-aliasing)
      - [Filtering Rows](#filtering-rows)
        - [Filter Operators and Functions](#filter-operators-and-functions)
          - [Infix Filter Operators](#infix-filter-operators)
          - [Prefix Filter Operators](#prefix-filter-operators)
          - [Filtering Functions](#filtering-functions)
      - [Sorting Rows](#sorting-rows)
      - [Limiting and Paging Results](#limiting-and-paging-results)
      - [Recursive and Hierarchical Queries](#recursive-and-hierarchical-queries)
      - [Aggregation](#aggregation)
  - [Upserting Rows](#upserting-rows)
  - [Updating Rows](#updating-rows)
  - [Deleting Rows](#deleting-rows)
  - [Transactions and Savepoints](#transactions-and-savepoints)
  - [Querying the Schema](#querying-the-schema)
    - [Indexes and Columns](#indexes-and-columns)
  - [Altering the Schema](#altering-the-schema)
    - [Renaming Tables](#renaming-tables)
    - [Dropping Tables](#dropping-tables)
    - [Adding Columns](#adding-columns)
      - [Added Column Constraints](#added-column-constraints)
    - [SchemaChanger](#schemachanger)
      - [Adding Columns](#adding-columns-1)
      - [Renaming Columns](#renaming-columns)
      - [Dropping Columns](#dropping-columns)
      - [Renaming/Dropping Tables](#renamingdropping-tables)
    - [Indexes](#indexes)
      - [Creating Indexes](#creating-indexes)
      - [Dropping Indexes](#dropping-indexes)
    - [Migrations and Schema Versioning](#migrations-and-schema-versioning)
  - [Custom Types](#custom-types)
    - [Date-Time Values](#date-time-values)
    - [Binary Data](#binary-data)
  - [Codable Types](#codable-types)
    - [Inserting Codable Types](#inserting-codable-types)
    - [Updating Codable Types](#updating-codable-types)
    - [Retrieving Codable Types](#retrieving-codable-types)
    - [Restrictions](#restrictions)
  - [Other Operators](#other-operators)
          - [Other Infix Operators](#other-infix-operators)
          - [Other Prefix Operators](#other-prefix-operators)
  - [Core SQLite Functions](#core-sqlite-functions)
  - [Aggregate SQLite Functions](#aggregate-sqlite-functions)
  - [Window SQLite Functions](#window-sqlite-functions)
  - [Date and Time functions](#date-and-time-functions)
  - [Custom SQL Functions](#custom-sql-functions)
  - [Custom Aggregations](#custom-aggregations)
  - [Custom Collations](#custom-collations)
  - [Full-text Search](#full-text-search)
    - [FTS5](#fts5)
  - [Executing Arbitrary SQL](#executing-arbitrary-sql)
  - [Online Database Backup](#online-database-backup)
  - [Attaching and detaching databases](#attaching-and-detaching-databases)
  - [Logging](#logging)
  - [Vacuum](#vacuum)

[↩]: #sqliteswift-documentation


## Installation

### Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code. It’s integrated with the Swift build system to automate the
process of downloading, compiling, and linking dependencies.

 1. Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
    .package(url: "https://github.com/skiptools/swift-sqlite.git", from: "1.0.0")
  ]
  ```

 2. Build your project:

  ```sh
  $ swift build
  ```

[Swift Package Manager]: https://swift.org/package-manager

## Getting Started

To use SQLiteDB classes or structures in your target’s source file, first
import the `SQLiteDB` module.

```swift
import SQLiteDB
```


### Connecting to a Database

Database connections are established using the `Connection` class. A
connection is initialized with a path to a database. SQLite will attempt to
create the database file if it does not already exist.

```swift
let db = try Connection("path/to/db.sqlite3")
```


#### Read-Write Databases

You can create a writable database in your app’s **Application Support**
directory.

```swift
let path = URL.applicationSupportDirectory
// create parent directory inside application support if it doesn’t exist
try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
let db = try Connection(dbURL.appendingPathComponent("db.sqlite3").path)
```

#### Read-Only Databases

If you bundle a database with your app (_i.e._, you’ve copied a database file
into your Xcode project and added it to your application target), you can
establish a _read-only_ connection to it.

```swift
let path = Bundle.main.path(forResource: "db", ofType: "sqlite3")!

let db = try Connection(path, readonly: true)
```

> _Note:_ Signed applications cannot modify their bundle resources. If you
> bundle a database file with your app for the purpose of bootstrapping, copy
> it to a writable location _before_ establishing a connection (see
> [Read-Write Databases](#read-write-databases), above, for typical, writable
> locations).

#### In a shared group container

It is not recommend to store databases in a [shared group container],
some users have reported crashes ([#1042](https://github.com/stephencelis/SQLite.swift/issues/1042)).

[shared group container]: https://developer.apple.com/documentation/foundation/filemanager/1412643-containerurl#

#### In-Memory Databases

If you omit the path, SQLiteDB will provision an [in-memory
database](https://www.sqlite.org/inmemorydb.html).

```swift
let db = try Connection() // equivalent to `Connection(.inMemory)`
```

To create a temporary, disk-backed database, pass an empty file name.

```swift
let db = try Connection(.temporary)
```

In-memory databases are automatically deleted when the database connection is
closed.

#### URI parameters

We can pass `.uri` to the `Connection` initializer to control more aspects of
the database connection with the help of `URIQueryParameter`s:

```swift
let db = try Connection(.uri("file.sqlite", parameters: [.cache(.private), .noLock(true)]))
```

See [Uniform Resource Identifiers](https://www.sqlite.org/uri.html#recognized_query_parameters) for more details.

#### Thread-Safety

Every Connection comes equipped with its own serial queue for statement
execution and can be safely accessed across threads. Threads that open
transactions and savepoints will block other threads from executing
statements while the transaction is open.

If you maintain multiple connections for a single database, consider setting a timeout
(in seconds) *or* a busy handler. There can only be one active at a time, so setting a busy
handler will effectively override `busyTimeout`.

```swift
db.busyTimeout = 5 // error after 5 seconds (does multiple retries)

db.busyHandler({ tries in
    tries < 3  // error after 3 tries
})
```

> _Note:_ The default timeout is 0, so if you see `database is locked`
> errors, you may be trying to access the same database simultaneously from
> multiple connections.


## Building Type-Safe SQL

SQLiteDB comes with a typed expression layer that directly maps
[Swift types](https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/SwiftStandardLibraryReference/)
to their [SQLite counterparts](https://www.sqlite.org/datatype3.html).

| Swift Type        | SQLite Type |
| ----------------- | ----------- |
| `Int64`*          | `INTEGER`   |
| `Double`          | `REAL`      |
| `String`          | `TEXT`      |
| `nil`             | `NULL`      |
| `SQLiteDB.Blob`†  | `BLOB`      |
| `URL`             | `TEXT`      |
| `UUID`            | `TEXT`      |
| `Date`            | `TEXT`      |

> *While `Int64` is the basic, raw type (to preserve 64-bit integers on
> 32-bit platforms), `Int` and `Bool` work transparently.
>
> †SQLiteDB defines its own `Blob` structure, which safely wraps the
> underlying bytes.
>
> See [Custom Types](#custom-types) for more information about extending
> other classes and structures to work with SQLiteDB.
>
> See [Executing Arbitrary SQL](#executing-arbitrary-sql) to forego the typed
> layer and execute raw SQL, instead.

These expressions (in the form of the structure,
[`Expression`](#expressions)) build on one another and, with a query
([`QueryType`](#queries)), can create and execute SQL statements.


### Expressions

SQLExpressions are generic structures associated with a type ([built-in
](#building-type-safe-sql) or [custom](#custom-types)), raw SQL, and
(optionally) values to bind to that SQL. Typically, you will only explicitly
create expressions to describe your columns, and typically only once per
column.

```swift
let id = SQLExpression<Int64>("id")
let email = SQLExpression<String>("email")
let balance = SQLExpression<Double>("balance")
let verified = SQLExpression<Bool>("verified")
```

Use optional generics for expressions that can evaluate to `NULL`.

```swift
let name = SQLExpression<String?>("name")
```

> _Note:_ The default `SQLExpression` initializer is for [quoted
> identifiers](https://www.sqlite.org/lang_keywords.html) (_i.e._, column
> names). To build a literal SQL expression, use `init(literal:)`.
> <!-- FIXME -->


### Compound Expressions

Expressions can be combined with other expressions and types using
[filter operators and functions](#filter-operators-and-functions)
(as well as other [non-filter operators](#other-operators) and
[functions](#core-sqlite-functions)). These building blocks can create complex SQLite statements.


### Queries

Queries are structures that reference a database and table name, and can be
used to build a variety of statements using expressions. We can create a
query by initializing a `Table`, `View`, or `VirtualTable`.

```swift
let users = Table("users")
```

Assuming [the table exists](#creating-a-table), we can immediately [insert
](#inserting-rows), [select](#selecting-rows), [update](#updating-rows), and
[delete](#deleting-rows) rows.


## Creating a Table

We can build [`CREATE TABLE`
statements](https://www.sqlite.org/lang_createtable.html) by calling the
`create` function on a `Table`. The following is a basic example of
SQLiteDB code (using the [expressions](#expressions) and
[query](#queries) above) and the corresponding SQL it generates.

```swift
try db.run(users.create { t in     // CREATE TABLE "users" (
    t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
    t.column(email, unique: true)  //     "email" TEXT UNIQUE NOT NULL,
    t.column(name)                 //     "name" TEXT
})                                 // )
```

> _Note:_ `SQLExpression<T>` structures (in this case, the `id` and `email`
> columns), generate `NOT NULL` constraints automatically, while
> `SQLExpression<T?>` structures (`name`) do not.


### Create Table Options

The `Table.create` function has several default parameters we can override.

  - `temporary` adds a `TEMPORARY` clause to the `CREATE TABLE` statement (to
    create a temporary table that will automatically drop when the database
    connection closes). Default: `false`.

    ```swift
    try db.run(users.create(temporary: true) { t in /* ... */ })
    // CREATE TEMPORARY TABLE "users" -- ...
    ```

  - `ifNotExists` adds an `IF NOT EXISTS` clause to the `CREATE TABLE`
    statement (which will bail out gracefully if the table already exists).
    Default: `false`.

    ```swift
    try db.run(users.create(ifNotExists: true) { t in /* ... */ })
    // CREATE TABLE "users" IF NOT EXISTS -- ...
    ```

### Column Constraints

The `column` function is used for a single column definition. It takes an
[expression](#expressions) describing the column name and type, and accepts
several parameters that map to various column constraints and clauses.

  - `primaryKey` adds a `PRIMARY KEY` constraint to a single column.

    ```swift
    t.column(id, primaryKey: true)
    // "id" INTEGER PRIMARY KEY NOT NULL

    t.column(id, primaryKey: .autoincrement)
    // "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    ```

    > _Note:_ The `primaryKey` parameter cannot be used alongside
    > `references`. If you need to create a column that has a default value
    > and is also a primary and/or foreign key, use the `primaryKey` and
    > `foreignKey` functions mentioned under
    > [Table Constraints](#table-constraints).
    >
    > Primary keys cannot be optional (_e.g._, `SQLExpression<Int64?>`).
    >
    > Only an `INTEGER PRIMARY KEY` can take `.autoincrement`.

  - `unique` adds a `UNIQUE` constraint to the column. (See the `unique`
    function under [Table Constraints](#table-constraints) for uniqueness
    over multiple columns).

    ```swift
    t.column(email, unique: true)
    // "email" TEXT UNIQUE NOT NULL
    ```

  - `check` attaches a `CHECK` constraint to a column definition in the form
    of a boolean expression (`SQLExpression<Bool>`). Boolean expressions can be
    easily built using
    [filter operators and functions](#filter-operators-and-functions).
    (See also the `check` function under
    [Table Constraints](#table-constraints).)

    ```swift
    t.column(email, check: email.like("%@%"))
    // "email" TEXT NOT NULL CHECK ("email" LIKE '%@%')
    ```

  - `defaultValue` adds a `DEFAULT` clause to a column definition and _only_
    accepts a value (or expression) matching the column’s type. This value is
    used if none is explicitly provided during
    [an `INSERT`](#inserting-rows).

    ```swift
    t.column(name, defaultValue: "Anonymous")
    // "name" TEXT DEFAULT 'Anonymous'
    ```

    > _Note:_ The `defaultValue` parameter cannot be used alongside
    > `primaryKey` and `references`. If you need to create a column that has
    > a default value and is also a primary and/or foreign key, use the
    > `primaryKey` and `foreignKey` functions mentioned under
    > [Table Constraints](#table-constraints).

  - `collate` adds a `COLLATE` clause to `SQLExpression<String>` (and
    `SQLExpression<String?>`) column definitions with
    [a collating sequence](https://www.sqlite.org/datatype3.html#collation)
    defined in the `Collation` enumeration.

    ```swift
    t.column(email, collate: .nocase)
    // "email" TEXT NOT NULL COLLATE "NOCASE"

    t.column(name, collate: .rtrim)
    // "name" TEXT COLLATE "RTRIM"
    ```

  - `references` adds a `REFERENCES` clause to `SQLExpression<Int64>` (and
    `SQLExpression<Int64?>`) column definitions and accepts a table
    (`SchemaType`) or namespaced column expression. (See the `foreignKey`
    function under [Table Constraints](#table-constraints) for non-integer
    foreign key support.)

    ```swift
    t.column(user_id, references: users, id)
    // "user_id" INTEGER REFERENCES "users" ("id")
    ```

    > _Note:_ The `references` parameter cannot be used alongside
    > `primaryKey` and `defaultValue`. If you need to create a column that
    > has a default value and is also a primary and/or foreign key, use the
    > `primaryKey` and `foreignKey` functions mentioned under
    > [Table Constraints](#table-constraints).


### Table Constraints

Additional constraints may be provided outside the scope of a single column
using the following functions.

  - `primaryKey` adds a `PRIMARY KEY` constraint to the table. Unlike [the
    column constraint, above](#column-constraints), it supports all SQLite
    types, [ascending and descending orders](#sorting-rows), and composite
    (multiple column) keys.

    ```swift
    t.primaryKey(email.asc, name)
    // PRIMARY KEY("email" ASC, "name")
    ```

  - `unique` adds a `UNIQUE` constraint to the table. Unlike
    [the column constraint, above](#column-constraints), it
    supports composite (multiplecolumn) constraints.

    ```swift
    t.unique(local, domain)
    // UNIQUE("local", "domain")
    ```

  - `check` adds a `CHECK` constraint to the table in the form of a boolean
    expression (`SQLExpression<Bool>`). Boolean expressions can be easily built
    using [filter operators and functions](#filter-operators-and-functions).
    (See also the `check` parameter under
    [Column Constraints](#column-constraints).)

    ```swift
    t.check(balance >= 0)
    // CHECK ("balance" >= 0.0)
    ```

  - `foreignKey` adds a `FOREIGN KEY` constraint to the table. Unlike [the
    `references` constraint, above](#column-constraints), it supports all
    SQLite types, both [`ON UPDATE` and `ON DELETE`
    actions](https://www.sqlite.org/foreignkeys.html#fk_actions), and
    composite (multiple column) keys.

    ```swift
    t.foreignKey(user_id, references: users, id, delete: .setNull)
    // FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL
    ```

<!-- TODO
### Creating a Table from a Select Statement
-->


## Inserting Rows

We can insert rows into a table by calling a [query’s](#queries) `insert`
function with a list of [setters](#setters)—typically [typed column
expressions](#expressions) and values (which can also be expressions)—each
joined by the `<-` operator.

```swift
try db.run(users.insert(email <- "alice@mac.com", name <- "Alice"))
// INSERT INTO "users" ("email", "name") VALUES ('alice@mac.com', 'Alice')

try db.run(users.insert(or: .replace, email <- "alice@mac.com", name <- "Alice B."))
// INSERT OR REPLACE INTO "users" ("email", "name") VALUES ('alice@mac.com', 'Alice B.')
```

The `insert` function, when run successfully, returns an `Int64` representing
the inserted row’s [`ROWID`][ROWID].

```swift
do {
    let rowid = try db.run(users.insert(email <- "alice@mac.com"))
    print("inserted id: \(rowid)")
} catch {
    print("insertion failed: \(error)")
}
```

Multiple rows can be inserted at once by similarly calling `insertMany` with an array of
per-row [setters](#setters).

```swift
do {
    let lastRowid = try db.run(users.insertMany([mail <- "alice@mac.com"], [email <- "geoff@mac.com"]))
    print("last inserted id: \(lastRowid)")
} catch {
    print("insertion failed: \(error)")
}
```


The [`update`](#updating-rows) and [`delete`](#deleting-rows) functions
follow similar patterns.

> _Note:_ If `insert` is called without any arguments, the statement will run
> with a `DEFAULT VALUES` clause. The table must not have any constraints
> that aren’t fulfilled by default values.
>
> ```swift
> try db.run(timestamps.insert())
> // INSERT INTO "timestamps" DEFAULT VALUES
> ```

### Handling SQLite errors

You can pattern match on the error to selectively catch SQLite errors. For example, to
specifically handle constraint errors ([SQLITE_CONSTRAINT](https://sqlite.org/rescode.html#constraint)):

```swift
do {
    try db.run(users.insert(email <- "alice@mac.com"))
    try db.run(users.insert(email <- "alice@mac.com"))
} catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
    print("constraint failed: \(message), in \(statement)")
} catch let error {
    print("insertion failed: \(error)")
}
```

The `Result.error` type contains the English-language text that describes the error (`message`),
the error `code` (see [SQLite result code list](https://sqlite.org/rescode.html#primary_result_code_list)
for details) and a optional reference to the `statement` which produced the error.

### Setters

SQLiteDB typically uses the `<-` operator to set values during [inserts
](#inserting-rows) and [updates](#updating-rows).

```swift
try db.run(counter.update(count <- 0))
// UPDATE "counters" SET "count" = 0 WHERE ("id" = 1)
```

There are also a number of convenience setters that take the existing value
into account using native Swift operators.

For example, to atomically increment a column, we can use `++`:

```swift
try db.run(counter.update(count++)) // equivalent to `counter.update(count -> count + 1)`
// UPDATE "counters" SET "count" = "count" + 1 WHERE ("id" = 1)
```

To take an amount and “move” it via transaction, we can use `-=` and `+=`:

```swift
let amount = 100.0
try db.transaction {
    try db.run(alice.update(balance -= amount))
    try db.run(betty.update(balance += amount))
}
// BEGIN DEFERRED TRANSACTION
// UPDATE "users" SET "balance" = "balance" - 100.0 WHERE ("id" = 1)
// UPDATE "users" SET "balance" = "balance" + 100.0 WHERE ("id" = 2)
// COMMIT TRANSACTION
```


###### Infix Setters

| Operator | Types              |
| -------- | ------------------ |
| `<-`     | `Value -> Value`   |
| `+=`     | `Number -> Number` |
| `-=`     | `Number -> Number` |
| `*=`     | `Number -> Number` |
| `/=`     | `Number -> Number` |
| `%=`     | `Int -> Int`       |
| `<<=`    | `Int -> Int`       |
| `>>=`    | `Int -> Int`       |
| `&=`     | `Int -> Int`       |
| `\|\|=`  | `Int -> Int`       |
| `^=`     | `Int -> Int`       |
| `+=`     | `String -> String` |


###### Postfix Setters

| Operator | Types        |
| -------- | ------------ |
| `++`     | `Int -> Int` |
| `--`     | `Int -> Int` |


## Selecting Rows

[Query structures](#queries) are `SELECT` statements waiting to happen. They
execute via [iteration](#iterating-and-accessing-values) and [other means
](#plucking-values) of sequence access.


### Iterating and Accessing Values

Prepared [queries](#queries) execute lazily upon iteration. Each row is
returned as a `Row` object, which can be subscripted with a [column
expression](#expressions) matching one of the columns returned.

```swift
for user in try db.prepare(users) {
    print("id: \(user[id]), email: \(user[email]), name: \(user[name])")
    // id: 1, email: alice@mac.com, name: Optional("Alice")
}
// SELECT * FROM "users"
```

`SQLExpression<T>` column values are _automatically unwrapped_ (we’ve made a
promise to the compiler that they’ll never be `NULL`), while `SQLExpression<T?>`
values remain wrapped.

⚠ Column subscripts on `Row` will force try and abort execution in error cases.
If you want to handle this yourself, use `Row.get(_ column: SQLExpression<V>)`:

```swift
for user in try db.prepare(users) {
    do {
        print("name: \(try user.get(name))")
    } catch {
        // handle
    }
}
```

Note that the iterator can throw *undeclared* database errors at any point during
iteration:

```swift
let query = try db.prepare(users)
for user in query {
    // 💥 can throw an error here
}
```

#### Failable iteration

It is therefore recommended using the `RowIterator` API instead,
which has explicit error handling:

```swift
// option 1: convert results into an Array of rows
let rowIterator = try db.prepareRowIterator(users)
for user in try Array(rowIterator) {
    print("id: \(user[id]), email: \(user[email])")
}

/// option 2: transform results using `map()`
let mapRowIterator = try db.prepareRowIterator(users)
let userIds = try mapRowIterator.map { $0[id] }

/// option 3: handle each row individually with `failableNext()`
do {
    while let row = try rowIterator.failableNext() {
        // Handle row
    }
} catch {
    // Handle error
}
```

### Plucking Rows

We can pluck the first row by passing a query to the `pluck` function on a
database connection.

```swift
if let user = try db.pluck(users) { /* ... */ } // Row
// SELECT * FROM "users" LIMIT 1
```

To collect all rows into an array, we can simply wrap the sequence (though
this is not always the most memory-efficient idea).

```swift
let all = Array(try db.prepare(users))
// SELECT * FROM "users"
```


### Building Complex Queries

[Queries](#queries) have a number of chainable functions that can be used
(with [expressions](#expressions)) to add and modify [a number of
clauses](https://www.sqlite.org/lang_select.html) to the underlying
statement.

```swift
let query = users.select(email)           // SELECT "email" FROM "users"
                 .filter(name != nil)     // WHERE "name" IS NOT NULL
                 .order(email.desc, name) // ORDER BY "email" DESC, "name"
                 .limit(5, offset: 1)     // LIMIT 5 OFFSET 1
```


#### Selecting Columns

By default, [queries](#queries) select every column of the result set (using
`SELECT *`). We can use the `select` function with a list of
[expressions](#expressions) to return specific columns instead.

```swift
for user in try db.prepare(users.select(id, email)) {
    print("id: \(user[id]), email: \(user[email])")
    // id: 1, email: alice@mac.com
}
// SELECT "id", "email" FROM "users"
```

We can access the results of more complex expressions by holding onto a
reference of the expression itself.

```swift
let sentence = name + " is " + cast(age) as SQLExpression<String?> + " years old!"
for user in users.select(sentence) {
    print(user[sentence])
    // Optional("Alice is 30 years old!")
}
// SELECT ((("name" || ' is ') || CAST ("age" AS TEXT)) || ' years old!') FROM "users"
```


#### Joining Other Tables

We can join tables using a [query’s](#queries) `join` function.

```swift
users.join(posts, on: user_id == users[id])
// SELECT * FROM "users" INNER JOIN "posts" ON ("user_id" = "users"."id")
```

The `join` function takes a [query](#queries) object (for the table being
joined on), a join condition (`on`), and is prefixed with an optional join
type (default: `.inner`). Join conditions can be built using [filter
operators and functions](#filter-operators-and-functions), generally require
[namespacing](#column-namespacing), and sometimes require
[aliasing](#table-aliasing).


##### Column Namespacing

When joining tables, column names can become ambiguous. _E.g._, both tables
may have an `id` column.

```swift
let query = users.join(posts, on: user_id == id)
// assertion failure: ambiguous column 'id'
```

We can disambiguate by namespacing `id`.

```swift
let query = users.join(posts, on: user_id == users[id])
// SELECT * FROM "users" INNER JOIN "posts" ON ("user_id" = "users"."id")
```

Namespacing is achieved by subscripting a [query](#queries) with a [column
expression](#expressions) (_e.g._, `users[id]` above becomes `users.id`).

> _Note:_ We can namespace all of a table’s columns using `*`.
>
> ```swift
> let query = users.select(users[*])
> // SELECT "users".* FROM "users"
> ```


##### Table Aliasing

Occasionally, we need to join a table to itself, in which case we must alias
the table with another name. We can achieve this using the
[query’s](#queries) `alias` function.

```swift
let managers = users.alias("managers")

let query = users.join(managers, on: managers[id] == users[managerId])
// SELECT * FROM "users"
// INNER JOIN ("users") AS "managers" ON ("managers"."id" = "users"."manager_id")
```

If query results can have ambiguous column names, row values should be
accessed with namespaced [column expressions](#expressions). In the above
case, `SELECT *` immediately namespaces all columns of the result set.

```swift
let user = try db.pluck(query)
user[id]           // fatal error: ambiguous column 'id'
                   // (please disambiguate: ["users"."id", "managers"."id"])

user[users[id]]    // returns "users"."id"
user[managers[id]] // returns "managers"."id"
```


#### Filtering Rows

SQLiteDB filters rows using a [query’s](#queries) `filter` function with
a boolean [expression](#expressions) (`SQLExpression<Bool>`).

```swift
users.filter(id == 1)
// SELECT * FROM "users" WHERE ("id" = 1)

users.filter([1, 2, 3, 4, 5].contains(id))
// SELECT * FROM "users" WHERE ("id" IN (1, 2, 3, 4, 5))

users.filter(email.like("%@mac.com"))
// SELECT * FROM "users" WHERE ("email" LIKE '%@mac.com')

users.filter(verified && name.lowercaseString == "alice")
// SELECT * FROM "users" WHERE ("verified" AND (lower("name") == 'alice'))

users.filter(verified || balance >= 10_000)
// SELECT * FROM "users" WHERE ("verified" OR ("balance" >= 10000.0))
```

We can build our own boolean expressions by using one of the many [filter
operators and functions](#filter-operators-and-functions).

Instead of `filter` we can also use the `where` function which is an alias:

```swift
users.where(id == 1)
// SELECT * FROM "users" WHERE ("id" = 1)
```

##### Filter Operators and Functions

SQLiteDB defines a number of operators for building filtering predicates.
Operators and functions work together in a type-safe manner, so attempting to
equate or compare different types will prevent compilation.


###### Infix Filter Operators

| Swift | Types                            | SQLite         |
| ----- | -------------------------------- | -------------- |
| `==`  | `Equatable -> Bool`              | `=`/`IS`*      |
| `!=`  | `Equatable -> Bool`              | `!=`/`IS NOT`* |
| `>`   | `Comparable -> Bool`             | `>`            |
| `>=`  | `Comparable -> Bool`             | `>=`           |
| `<`   | `Comparable -> Bool`             | `<`            |
| `<=`  | `Comparable -> Bool`             | `<=`           |
| `~=`  | `(Interval, Comparable) -> Bool` | `BETWEEN`      |
| `&&`  | `Bool -> Bool`                   | `AND`          |
| `\|\|`| `Bool -> Bool`                   | `OR`           |
| `===` | `Equatable -> Bool`              | `IS`           |
| `!==` | `Equatable -> Bool`              | `IS NOT`       |

> * When comparing against `nil`, SQLiteDB will use `IS` and `IS NOT`
> accordingly.


###### Prefix Filter Operators

| Swift | Types              | SQLite |
| ----- | ------------------ | ------ |
| `!`   | `Bool -> Bool`     | `NOT`  |


###### Filtering Functions

| Swift      | Types                   | SQLite  |
| ---------- | ----------------------- | ------- |
| `like`     | `String -> Bool`        | `LIKE`  |
| `glob`     | `String -> Bool`        | `GLOB`  |
| `match`    | `String -> Bool`        | `MATCH` |
| `contains` | `(Array<T>, T) -> Bool` | `IN`    |


<!-- TODO
#### Grouping Results
-->


#### Sorting Rows

We can pre-sort returned rows using the [query’s](#queries) `order` function.

_E.g._, to return users sorted by `email`, then `name`, in ascending order:

```swift
users.order(email, name)
// SELECT * FROM "users" ORDER BY "email", "name"
```

The `order` function takes a list of [column expressions](#expressions).

`Expression` objects have two computed properties to assist sorting: `asc`
and `desc`. These properties append the expression with `ASC` and `DESC` to
mark ascending and descending order respectively.

```swift
users.order(email.desc, name.asc)
// SELECT * FROM "users" ORDER BY "email" DESC, "name" ASC
```


#### Limiting and Paging Results

We can limit and skip returned rows using a [query’s](#queries) `limit`
function (and its optional `offset` parameter).

```swift
users.limit(5)
// SELECT * FROM "users" LIMIT 5

users.limit(5, offset: 5)
// SELECT * FROM "users" LIMIT 5 OFFSET 5
```


#### Recursive and Hierarchical Queries

We can perform a recursive or hierarchical query using a [query's](#queries)
[`WITH`](https://sqlite.org/lang_with.html) function.

```swift
// Get the management chain for the manager with id == 8

let chain = Table("chain")
let id = SQLExpression<Int64>("id")
let managerId = SQLExpression<Int64>("manager_id")

let query = managers
    .where(id == 8)
    .union(chain.join(managers, on: chain[managerId] == managers[id])

chain.with(chain, recursive: true, as: query)
// WITH RECURSIVE
//   "chain" AS (
//     SELECT * FROM "managers" WHERE "id" = 8
//     UNION
//     SELECT * from "chain"
//     JOIN "managers" ON "chain"."manager_id" = "managers"."id"
//   )
// SELECT * FROM "chain"
```

Column names and a materialization hint can optionally be provided.

```swift
// Add a "level" column to the query representing manager's position in the chain
let level = SQLExpression<Int64>("level")

let queryWithLevel =
    managers
        .select(id, managerId, 0)
        .where(id == 8)
        .union(
            chain
                .select(managers[id], managers[manager_id], level + 1)
                .join(managers, on: chain[managerId] == managers[id])
        )

chain.with(chain,
           columns: [id, managerId, level],
           recursive: true,
           hint: .materialize,
           as: queryWithLevel)
// WITH RECURSIVE
//   "chain" ("id", "manager_id", "level") AS MATERIALIZED (
//     SELECT ("id", "manager_id", 0) FROM "managers" WHERE "id" = 8
//     UNION
//     SELECT ("manager"."id", "manager"."manager_id", "level" + 1) FROM "chain"
//     JOIN "managers" ON "chain"."manager_id" = "managers"."id"
//   )
// SELECT * FROM "chain"
```


#### Aggregation

[Queries](#queries) come with a number of functions that quickly return
aggregate scalar values from the table. These mirror the [core aggregate
functions](#aggregate-sqlite-functions) and are executed immediately against
the query.

```swift
let count = try db.scalar(users.count)
// SELECT count(*) FROM "users"
```

Filtered queries will appropriately filter aggregate values.

```swift
let count = try db.scalar(users.filter(name != nil).count)
// SELECT count(*) FROM "users" WHERE "name" IS NOT NULL
```

  - `count` as a computed property on a query (see examples above) returns
    the total number of rows matching the query.

    `count` as a computed property on a column expression returns the total
    number of rows where that column is not `NULL`.

    ```swift
    let count = try db.scalar(users.select(name.count)) // -> Int
    // SELECT count("name") FROM "users"
    ```

  - `max` takes a comparable column expression and returns the largest value
    if any exists.

    ```swift
    let max = try db.scalar(users.select(id.max)) // -> Int64?
    // SELECT max("id") FROM "users"
    ```

  - `min` takes a comparable column expression and returns the smallest value
    if any exists.

    ```swift
    let min = try db.scalar(users.select(id.min)) // -> Int64?
    // SELECT min("id") FROM "users"
    ```

  - `average` takes a numeric column expression and returns the average row
    value (as a `Double`) if any exists.

    ```swift
    let average = try db.scalar(users.select(balance.average)) // -> Double?
    // SELECT avg("balance") FROM "users"
    ```

  - `sum` takes a numeric column expression and returns the sum total of all
    rows if any exist.

    ```swift
    let sum = try db.scalar(users.select(balance.sum)) // -> Double?
    // SELECT sum("balance") FROM "users"
    ```

  - `total`, like `sum`, takes a numeric column expression and returns the
    sum total of all rows, but in this case always returns a `Double`, and
    returns `0.0` for an empty query.

    ```swift
    let total = try db.scalar(users.select(balance.total)) // -> Double
    // SELECT total("balance") FROM "users"
    ```

> _Note:_ Expressions can be prefixed with a `DISTINCT` clause by calling the
> `distinct` computed property.
>
> ```swift
> let count = try db.scalar(users.select(name.distinct.count) // -> Int
> // SELECT count(DISTINCT "name") FROM "users"
> ```

## Upserting Rows

We can upsert rows into a table by calling a [query’s](#queries) `upsert`
function with a list of [setters](#setters)—typically [typed column
expressions](#expressions) and values (which can also be expressions)—each
joined by the `<-` operator. Upserting is like inserting, except if there is a
conflict on the specified column value, SQLite will perform an update on the row instead.

```swift
try db.run(users.upsert(email <- "alice@mac.com", name <- "Alice", onConflictOf: email))
// INSERT INTO "users" ("email", "name") VALUES ('alice@mac.com', 'Alice') ON CONFLICT (\"email\") DO UPDATE SET \"name\" = \"excluded\".\"name\"
```

The `upsert` function, when run successfully, returns an `Int64` representing
the inserted row’s [`ROWID`][ROWID].

```swift
do {
    let rowid = try db.run(users.upsert(email <- "alice@mac.com", name <- "Alice", onConflictOf: email))
    print("inserted id: \(rowid)")
} catch {
    print("insertion failed: \(error)")
}
```

The [`insert`](#inserting-rows), [`update`](#updating-rows), and [`delete`](#deleting-rows) functions
follow similar patterns.

## Updating Rows

We can update a table’s rows by calling a [query’s](#queries) `update`
function with a list of [setters](#setters)—typically [typed column
expressions](#expressions) and values (which can also be expressions)—each
joined by the `<-` operator.

When an unscoped query calls `update`, it will update _every_ row in the
table.

```swift
try db.run(users.update(email <- "alice@me.com"))
// UPDATE "users" SET "email" = 'alice@me.com'
```

Be sure to scope `UPDATE` statements beforehand using [the `filter` function
](#filtering-rows).

```swift
let alice = users.filter(id == 1)
try db.run(alice.update(email <- "alice@me.com"))
// UPDATE "users" SET "email" = 'alice@me.com' WHERE ("id" = 1)
```

The `update` function returns an `Int` representing the number of updated
rows.

```swift
do {
    if try db.run(alice.update(email <- "alice@me.com")) > 0 {
        print("updated alice")
    } else {
        print("alice not found")
    }
} catch {
    print("update failed: \(error)")
}
```


## Deleting Rows

We can delete rows from a table by calling a [query’s](#queries) `delete`
function.

When an unscoped query calls `delete`, it will delete _every_ row in the
table.

```swift
try db.run(users.delete())
// DELETE FROM "users"
```

Be sure to scope `DELETE` statements beforehand using
[the `filter` function](#filtering-rows).

```swift
let alice = users.filter(id == 1)
try db.run(alice.delete())
// DELETE FROM "users" WHERE ("id" = 1)
```

The `delete` function returns an `Int` representing the number of deleted
rows.

```swift
do {
    if try db.run(alice.delete()) > 0 {
        print("deleted alice")
    } else {
        print("alice not found")
    }
} catch {
    print("delete failed: \(error)")
}
```


## Transactions and Savepoints

Using the `transaction` and `savepoint` functions, we can run a series of
statements in a transaction. If a single statement fails or the block throws
an error, the changes will be rolled back.

```swift
try db.transaction {
    let rowid = try db.run(users.insert(email <- "betty@icloud.com"))
    try db.run(users.insert(email <- "cathy@icloud.com", managerId <- rowid))
}
// BEGIN DEFERRED TRANSACTION
// INSERT INTO "users" ("email") VALUES ('betty@icloud.com')
// INSERT INTO "users" ("email", "manager_id") VALUES ('cathy@icloud.com', 2)
// COMMIT TRANSACTION
```

> _Note:_ Transactions run in a serial queue.

## Querying the Schema

We can obtain generic information about objects in the current schema with a `SchemaReader`:

```swift
let schema = db.schema
```

To query the data:

```swift
let indexes = try schema.objectDefinitions(type: .index)
let tables = try schema.objectDefinitions(type: .table)
let triggers = try schema.objectDefinitions(type: .trigger)
```

### Indexes and Columns

Specialized methods are available to get more detailed information:

```swift
let indexes = try schema.indexDefinitions("users")
let columns = try schema.columnDefinitions("users")

for index in indexes {
    print("\(index.name) columns:\(index.columns))")
}
for column in columns {
    print("\(column.name) pk:\(column.primaryKey) nullable: \(column.nullable)")
}
```

## Altering the Schema

SQLiteDB comes with several functions (in addition to `Table.create`) for
altering a database schema in a type-safe manner.

### Renaming Tables

We can build an `ALTER TABLE … RENAME TO` statement by calling the `rename`
function on a `Table` or `VirtualTable`.

```swift
try db.run(users.rename(Table("users_old")))
// ALTER TABLE "users" RENAME TO "users_old"
```

### Dropping Tables

We can build
[`DROP TABLE` statements](https://www.sqlite.org/lang_droptable.html)
by calling the `dropTable` function on a `SchemaType`.

```swift
try db.run(users.drop())
// DROP TABLE "users"
```

The `drop` function has one additional parameter, `ifExists`, which (when
`true`) adds an `IF EXISTS` clause to the statement.

```swift
try db.run(users.drop(ifExists: true))
// DROP TABLE IF EXISTS "users"
```

### Adding Columns

We can add columns to a table by calling `addColumn` function on a `Table`.
SQLiteDB enforces
[the same limited subset](https://www.sqlite.org/lang_altertable.html) of
`ALTER TABLE` that SQLite supports.

```swift
try db.run(users.addColumn(suffix))
// ALTER TABLE "users" ADD COLUMN "suffix" TEXT
```

#### Added Column Constraints

The `addColumn` function shares several of the same [`column` function
parameters](#column-constraints) used when [creating
tables](#creating-a-table).

  - `check` attaches a `CHECK` constraint to a column definition in the form
    of a boolean expression (`SQLExpression<Bool>`). (See also the `check`
    function under [Table Constraints](#table-constraints).)

    ```swift
    try db.run(users.addColumn(suffix, check: ["JR", "SR"].contains(suffix)))
    // ALTER TABLE "users" ADD COLUMN "suffix" TEXT CHECK ("suffix" IN ('JR', 'SR'))
    ```

  - `defaultValue` adds a `DEFAULT` clause to a column definition and _only_
    accepts a value matching the column’s type. This value is used if none is
    explicitly provided during [an `INSERT`](#inserting-rows).

    ```swift
    try db.run(users.addColumn(suffix, defaultValue: "SR"))
    // ALTER TABLE "users" ADD COLUMN "suffix" TEXT DEFAULT 'SR'
    ```

    > _Note:_ Unlike the [`CREATE TABLE` constraint](#table-constraints),
    > default values may not be expression structures (including
    > `CURRENT_TIME`, `CURRENT_DATE`, or `CURRENT_TIMESTAMP`).

  - `collate` adds a `COLLATE` clause to `SQLExpression<String>` (and
    `SQLExpression<String?>`) column definitions with [a collating
    sequence](https://www.sqlite.org/datatype3.html#collation) defined in the
    `Collation` enumeration.

    ```swift
    try db.run(users.addColumn(email, collate: .nocase))
    // ALTER TABLE "users" ADD COLUMN "email" TEXT NOT NULL COLLATE "NOCASE"

    try db.run(users.addColumn(name, collate: .rtrim))
    // ALTER TABLE "users" ADD COLUMN "name" TEXT COLLATE "RTRIM"
    ```

  - `references` adds a `REFERENCES` clause to `Int64` (and `Int64?`) column
    definitions and accepts a table or namespaced column expression. (See the
    `foreignKey` function under [Table Constraints](#table-constraints) for
    non-integer foreign key support.)

    ```swift
    try db.run(posts.addColumn(userId, references: users, id)
    // ALTER TABLE "posts" ADD COLUMN "user_id" INTEGER REFERENCES "users" ("id")
    ```

### SchemaChanger

Version 0.14.0 introduces `SchemaChanger`, an alternative API to perform more complex
migrations such as renaming columns. These operations work with all versions of
SQLite but use SQL statements such as `ALTER TABLE RENAME COLUMN` when available.

#### Adding Columns

```swift
let newColumn = ColumnDefinition(
    name: "new_text_column",
    type: .TEXT,
    nullable: true,
    defaultValue: .stringLiteral("foo")
)

let schemaChanger = SchemaChanger(connection: db)

try schemaChanger.alter(table: "users") { table in
    table.add(column: newColumn)
}
```

#### Renaming Columns

```swift
let schemaChanger = SchemaChanger(connection: db)
try schemaChanger.alter(table: "users") { table in
    table.rename(column: "old_name", to: "new_name")
}
```

#### Dropping Columns

```swift
let schemaChanger = SchemaChanger(connection: db)
try schemaChanger.alter(table: "users") { table in
    table.drop(column: "email")
}
```

#### Renaming/Dropping Tables

```swift
let schemaChanger = SchemaChanger(connection: db)

try schemaChanger.rename(table: "users", to: "users_new")
try schemaChanger.drop(table: "emails", ifExists: false)
```

### Indexes


#### Creating Indexes

We can build
[`CREATE INDEX` statements](https://www.sqlite.org/lang_createindex.html)
by calling the `createIndex` function on a `SchemaType`.

```swift
try db.run(users.createIndex(email))
// CREATE INDEX "index_users_on_email" ON "users" ("email")
```

The index name is generated automatically based on the table and column
names.

The `createIndex` function has a couple default parameters we can override.

  - `unique` adds a `UNIQUE` constraint to the index. Default: `false`.

    ```swift
    try db.run(users.createIndex(email, unique: true))
    // CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email")
    ```

  - `ifNotExists` adds an `IF NOT EXISTS` clause to the `CREATE TABLE`
    statement (which will bail out gracefully if the table already exists).
    Default: `false`.

    ```swift
    try db.run(users.createIndex(email, ifNotExists: true))
    // CREATE INDEX IF NOT EXISTS "index_users_on_email" ON "users" ("email")
    ```


#### Dropping Indexes

We can build
[`DROP INDEX` statements](https://www.sqlite.org/lang_dropindex.html) by
calling the `dropIndex` function on a `SchemaType`.

```swift
try db.run(users.dropIndex(email))
// DROP INDEX "index_users_on_email"
```

The `dropIndex` function has one additional parameter, `ifExists`, which
(when `true`) adds an `IF EXISTS` clause to the statement.

```swift
try db.run(users.dropIndex(email, ifExists: true))
// DROP INDEX IF EXISTS "index_users_on_email"
```

### Migrations and Schema Versioning

You can use the convenience property on `Connection` to query and set the
[`PRAGMA user_version`](https://sqlite.org/pragma.html#pragma_user_version).

This is a great way to manage your schema’s version over migrations.
You can conditionally run your migrations along the lines of:

```swift
if db.userVersion == 0 {
    // handle first migration
    db.userVersion = 1
}
if db.userVersion == 1 {
    // handle second migration
    db.userVersion = 2
}
```

For more complex migration requirements check out the schema management
system [SQLiteMigrationManager.swift][].

## Custom Types

SQLiteDB supports serializing and deserializing any custom type as long
as it conforms to the `Value` protocol.

```swift
protocol Value {
    typealias Datatype: Binding
    class var declaredDatatype: String { get }
    class func fromDatatypeValue(datatypeValue: Datatype) -> Self
    var datatypeValue: Datatype { get }
}
```

The `Datatype` must be one of the basic Swift types that values are bridged
through before serialization and deserialization (see [Building Type-Safe SQL
](#building-type-safe-sql) for a list of types).

> ⚠ _Note:_ `Binding` is a protocol that SQLiteDB uses internally to
> directly map SQLite types to Swift types. **Do _not_** conform custom types
> to the `Binding` protocol.


### Date-Time Values

In SQLite, `DATETIME` columns can be treated as strings or numbers, so we can
transparently bridge `Date` objects through Swift’s `String` types.

We can use these types directly in SQLite statements.

```swift
let published_at = SQLExpression<Date>("published_at")

let published = posts.filter(published_at <= Date())
// SELECT * FROM "posts" WHERE "published_at" <= '2014-11-18T12:45:30.000'

let startDate = Date(timeIntervalSince1970: 0)
let published = posts.filter(startDate...Date() ~= published_at)
// SELECT * FROM "posts" WHERE "published_at" BETWEEN '1970-01-01T00:00:00.000' AND '2014-11-18T12:45:30.000'
```


### Binary Data

We can bridge any type that can be initialized from and encoded to `Data`.

```swift
extension UIImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(blobValue: Blob) -> UIImage {
        return UIImage(data: Data.fromDatatypeValue(blobValue))!
    }
    public var datatypeValue: Blob {
        return UIImagePNGRepresentation(self)!.datatypeValue
    }

}
```

> _Note:_ See the [Archives and Serializations Programming Guide][] for more
> information on encoding and decoding custom types.


[Archives and Serializations Programming Guide]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Archiving/Archiving.html

## Codable Types

[Codable types][Encoding and Decoding Custom Types] were introduced as a part
of Swift 4 to  allow serializing and deserializing types. SQLiteDB supports
the insertion, updating, and retrieval of basic Codable types.

[Encoding and Decoding Custom Types]: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types

### Inserting Codable Types

Queries have a method to allow inserting an [Encodable][] type.

```swift
struct User: Encodable {
    let name: String
}
try db.run(users.insert(User(name: "test")))

```

There are two other parameters also available to this method:

- `userInfo` is a dictionary that is passed to the encoder and made available
  to encodable types to allow customizing their behavior.

- `otherSetters` allows you to specify additional setters on top of those
  that are generated from the encodable types themselves.

[Encodable]: https://developer.apple.com/documentation/swift/encodable

### Updating Codable Types

Queries have a method to allow updating an Encodable type.

```swift
try db.run(users.filter(id == userId).update(user))

```

> ⚠ Unless filtered, using the update method on an instance of a Codable
> type updates all table rows.

There are two other parameters also available to this method:

- `userInfo` is a dictionary that is passed to the encoder and made available
  to encodable types to allow customizing their behavior.

- `otherSetters` allows you to specify additional setters on top of those
  that are generated from the encodable types themselves.

### Retrieving Codable Types

Rows have a method to decode a [Decodable][] type.

```swift
let loadedUsers: [User] = try db.prepare(users).map { row in
    return try row.decode()
}
```

You can also create a decoder to use manually yourself. This can be useful
for example if you are using the
[Facade pattern](https://en.wikipedia.org/wiki/Facade_pattern) to hide
subclasses behind a super class. For example, you may want to encode an Image
type that can be multiple different formats such as PNGImage, JPGImage, or
HEIFImage. You will need to determine the correct subclass before you know
which type to decode.

```swift
enum ImageCodingKeys: String, CodingKey {
    case kind
}

enum ImageKind: Int, Codable {
    case png, jpg, heif
}

let loadedImages: [Image] = try db.prepare(images).map { row in
    let decoder = row.decoder()
    let container = try decoder.container(keyedBy: ImageCodingKeys.self)
    switch try container.decode(ImageKind.self, forKey: .kind) {
    case .png:
        return try PNGImage(from: decoder)
    case .jpg:
        return try JPGImage(from: decoder)
    case .heif:
        return try HEIFImage(from: decoder)
    }
}
```

Both of the above methods also have the following optional parameter:

- `userInfo` is a dictionary that is passed to the decoder and made available
  to decodable types to allow customizing their behavior.

[Decodable]: https://developer.apple.com/documentation/swift/decodable

### Restrictions

There are a few restrictions on using Codable types:

- The encodable and decodable objects can only use the following types:
    - Int, Bool, Float, Double, String, Date
    - Nested Codable types that will be encoded as JSON to a single column
- These methods will not handle object relationships for you. You must write
  your own Codable and Decodable implementations if you wish to support this.
- The Codable types may not try to access nested containers or nested unkeyed
  containers
- The Codable types may not access single value containers or unkeyed
  containers
- The Codable types may not access super decoders or encoders

## Other Operators

In addition to [filter operators](#filtering-infix-operators), SQLiteDB
defines a number of operators that can modify expression values with
arithmetic, bitwise operations, and concatenation.


###### Other Infix Operators

| Swift | Types                            | SQLite   |
| ----- | -------------------------------- | -------- |
| `+`   | `Number -> Number`               | `+`      |
| `-`   | `Number -> Number`               | `-`      |
| `*`   | `Number -> Number`               | `*`      |
| `/`   | `Number -> Number`               | `/`      |
| `%`   | `Int -> Int`                     | `%`      |
| `<<`  | `Int -> Int`                     | `<<`     |
| `>>`  | `Int -> Int`                     | `>>`     |
| `&`   | `Int -> Int`                     | `&`      |
| `\|`  | `Int -> Int`                     | `\|`     |
| `+`   | `String -> String`               | `\|\|`   |

> _Note:_ SQLiteDB also defines a bitwise XOR operator, `^`, which
> expands the expression `lhs ^ rhs` to `~(lhs & rhs) & (lhs | rhs)`.


###### Other Prefix Operators

| Swift | Types              | SQLite |
| ----- | ------------------ | ------ |
| `~`   | `Int -> Int`       | `~`    |
| `-`   | `Number -> Number` | `-`    |


## Core SQLite Functions

Many of SQLite’s [core functions](https://www.sqlite.org/lang_corefunc.html)
have been surfaced in and type-audited for SQLiteDB.

> _Note:_ SQLiteDB aliases the `??` operator to the `ifnull` function.
>
> ```swift
> name ?? email // ifnull("name", "email")
> ```


## Aggregate SQLite Functions

Most of SQLite’s
[aggregate functions](https://www.sqlite.org/lang_aggfunc.html) have been
surfaced in and type-audited for SQLiteDB.

## Window SQLite Functions

Most of SQLite's [window functions](https://www.sqlite.org/windowfunctions.html) have been
surfaced in and type-audited for SQLiteDB. Currently only `OVER (ORDER BY ...)` windowing is possible. 

## Date and Time functions

SQLite's [date and time](https://www.sqlite.org/lang_datefunc.html)
functions are available:

```swift
DateFunctions.date("now")
// date('now')
Date().date
// date('2007-01-09T09:41:00.000')
SQLExpression<Date>("date").date
// date("date")
```

## Custom SQL Functions

We can create custom SQL functions by calling `createFunction` on a database
connection.

For example, to give queries access to
[`MobileCoreServices.UTTypeConformsTo`][UTTypeConformsTo], we can
write the following:

```swift
import MobileCoreServices

let typeConformsTo: (SQLExpression<String>, SQLExpression<String>) -> SQLExpression<Bool> = (
    try db.createFunction("typeConformsTo", deterministic: true) { UTI, conformsToUTI in
        return UTTypeConformsTo(UTI, conformsToUTI)
    }
)
```

> _Note:_ The optional `deterministic` parameter is an optimization that
> causes the function to be created with
> [`SQLITE_DETERMINISTIC`](https://www.sqlite.org/c3ref/c_deterministic.html).

Note `typeConformsTo`’s signature:

```swift
(SQLExpression<String>, SQLExpression<String>) -> SQLExpression<Bool>
```

Because of this, `createFunction` expects a block with the following
signature:

```swift
(String, String) -> Bool
```

Once assigned, the closure can be called wherever boolean expressions are
accepted.

```swift
let attachments = Table("attachments")
let UTI = SQLExpression<String>("UTI")

let images = attachments.filter(typeConformsTo(UTI, kUTTypeImage))
// SELECT * FROM "attachments" WHERE "typeConformsTo"("UTI", 'public.image')
```

> _Note:_ The return type of a function must be
> [a core SQL type](#building-type-safe-sql) or [conform to `Value`](#custom-types).

We can create loosely-typed functions by handling an array of raw arguments,
instead.

```swift
db.createFunction("typeConformsTo", deterministic: true) { args in
    guard let UTI = args[0] as? String, conformsToUTI = args[1] as? String else { return nil }
    return UTTypeConformsTo(UTI, conformsToUTI)
}
```

Creating a loosely-typed function cannot return a closure and instead must be
wrapped manually or executed [using raw SQL](#executing-arbitrary-sql).

```swift
let stmt = try db.prepare("SELECT * FROM attachments WHERE typeConformsTo(UTI, ?)")
for row in stmt.bind(kUTTypeImage) { /* ... */ }
```

> _Note:_ Prepared queries can be reused, and long lived prepared queries should be `reset()` after each use. Otherwise, the transaction (either [implicit or explicit](https://www.sqlite.org/lang_transaction.html#implicit_versus_explicit_transactions)) will be held open until the query is reset or finalized. This can affect performance. Statements are reset automatically during `deinit`.
>
> ```swift
> someObj.statement = try db.prepare("SELECT * FROM attachments WHERE typeConformsTo(UTI, ?)")
> for row in someObj.statement.bind(kUTTypeImage) { /* ... */ }
> someObj.statement.reset()
> ```

[UTTypeConformsTo]: https://developer.apple.com/documentation/coreservices/1444079-uttypeconformsto

## Custom Aggregations

We can create custom aggregation functions by calling `createAggregation`:

```swift
let reduce: (String, [Binding?]) -> String = { (last, bindings) in
    last + " " + (bindings.first as? String ?? "")
}

db.createAggregation("customConcat", initialValue: "", reduce: reduce, result: { $0 })
let result = db.prepare("SELECT customConcat(email) FROM users").scalar() as! String
```

## Custom Collations

We can create custom collating sequences by calling `createCollation` on a
database connection.

```swift
try db.createCollation("NODIACRITIC") { lhs, rhs in
    return lhs.compare(rhs, options: .diacriticInsensitiveSearch)
}
```

We can reference a custom collation using the `Custom` member of the
`Collation` enumeration.

```swift
restaurants.order(collate(.custom("NODIACRITIC"), name))
// SELECT * FROM "restaurants" ORDER BY "name" COLLATE "NODIACRITIC"
```


## Full-text Search

We can create a virtual table using the [FTS4
module](http://www.sqlite.org/fts3.html) by calling `create` on a
`VirtualTable`.

```swift
let emails = VirtualTable("emails")
let subject = SQLExpression<String>("subject")
let body = SQLExpression<String>("body")

try db.run(emails.create(.FTS4(subject, body)))
// CREATE VIRTUAL TABLE "emails" USING fts4("subject", "body")
```

We can specify a [tokenizer](http://www.sqlite.org/fts3.html#tokenizer) using the `tokenize` parameter.

```swift
try db.run(emails.create(.FTS4([subject, body], tokenize: .Porter)))
// CREATE VIRTUAL TABLE "emails" USING fts4("subject", "body", tokenize=porter)
```

We can set the full range of parameters by creating a `FTS4Config` object.

```swift
let emails = VirtualTable("emails")
let subject = SQLExpression<String>("subject")
let body = SQLExpression<String>("body")
let config = FTS4Config()
    .column(subject)
    .column(body, [.unindexed])
    .languageId("lid")
    .order(.desc)

try db.run(emails.create(.FTS4(config))
// CREATE VIRTUAL TABLE "emails" USING fts4("subject", "body", notindexed="body", languageid="lid", order="desc")
```

Once we insert a few rows, we can search using the `match` function, which
takes a table or column as its first argument and a query string as its
second.

```swift
try db.run(emails.insert(
    subject <- "Just Checking In",
    body <- "Hey, I was just wondering...did you get my last email?"
))

let wonderfulEmails: QueryType = emails.match("wonder*")
// SELECT * FROM "emails" WHERE "emails" MATCH 'wonder*'

let replies = emails.filter(subject.match("Re:*"))
// SELECT * FROM "emails" WHERE "subject" MATCH 'Re:*'
```

### FTS5

When linking against a version of SQLite with
[FTS5](http://www.sqlite.org/fts5.html) enabled we can create the virtual
table in a similar fashion.

```swift
let emails = VirtualTable("emails")
let subject = SQLExpression<String>("subject")
let body = SQLExpression<String>("body")
let config = FTS5Config()
    .column(subject)
    .column(body, [.unindexed])

try db.run(emails.create(.FTS5(config)))
// CREATE VIRTUAL TABLE "emails" USING fts5("subject", "body" UNINDEXED)

// Note that FTS5 uses a different syntax to select columns, so we need to rewrite
// the last FTS4 query above as:
let replies = emails.filter(emails.match("subject:\"Re:\"*"))
// SELECT * FROM "emails" WHERE "emails" MATCH 'subject:"Re:"*'
```

## Executing Arbitrary SQL

Though we recommend you stick with SQLiteDB’s
[type-safe system](#building-type-safe-sql) whenever possible, it is possible
to simply and safely prepare and execute raw SQL statements via a `Database` connection
using the following functions.

  - `execute` runs an arbitrary number of SQL statements as a convenience.

    ```swift
    try db.execute("""
        BEGIN TRANSACTION;
        CREATE TABLE users (
            id INTEGER PRIMARY KEY NOT NULL,
            email TEXT UNIQUE NOT NULL,
            name TEXT
        );
        CREATE TABLE posts (
            id INTEGER PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            published_at DATETIME
        );
        PRAGMA user_version = 1;
        COMMIT TRANSACTION;
        """
    )
    ```

  - `prepare` prepares a single `Statement` object from a SQL string,
      optionally binds values to it (using the statement’s `bind` function),
      and returns the statement for deferred execution.

    ```swift
    let stmt = try db.prepare("INSERT INTO users (email) VALUES (?)")
    ```

    Once prepared, statements may be executed using `run`, binding any
    unbound parameters.

    ```swift
    try stmt.run("alice@mac.com")
    db.changes // -> {Some 1}
    ```

    Statements with results may be iterated over, using the columnNames if
    useful.

    ```swift
    let stmt = try db.prepare("SELECT id, email FROM users")
    for row in stmt {
        for (index, name) in stmt.columnNames.enumerated() {
            print ("\(name):\(row[index]!)")
            // id: Optional(1), email: Optional("alice@mac.com")
        }
    }
    ```

  - `run` prepares a single `Statement` object from a SQL string, optionally
    binds values to it (using the statement’s `bind` function), executes,
    and returns the statement.

    ```swift
    try db.run("INSERT INTO users (email) VALUES (?)", "alice@mac.com")
    ```

  - `scalar` prepares a single `Statement` object from a SQL string,
      optionally binds values to it (using the statement’s `bind` function),
      executes, and returns the first value of the first row.

    ```swift
    let count = try db.scalar("SELECT count(*) FROM users") as! Int64
    ```

    Statements also have a `scalar` function, which can optionally re-bind
    values at execution.

    ```swift
    let stmt = try db.prepare("SELECT count (*) FROM users")
    let count = try stmt.scalar() as! Int64
    ```

## Online Database Backup

To copy a database to another using the
[SQLite Online Backup API](https://sqlite.org/backup.html):

```swift
// creates an in-memory copy of db.sqlite
let db = try Connection("db.sqlite")
let target = try Connection(.inMemory)

let backup = try db.backup(usingConnection: target)
try backup.step()
```

## Attaching and detaching databases

We can [ATTACH](https://www3.sqlite.org/lang_attach.html) and [DETACH](https://www3.sqlite.org/lang_detach.html)
databases to an existing connection:

```swift
let db = try Connection("db.sqlite")

try db.attach(.uri("external.sqlite", parameters: [.mode(.readOnly)]), as: "external")
// ATTACH DATABASE 'file:external.sqlite?mode=ro' AS 'external'

let table = Table("table", database: "external")
let count = try db.scalar(table.count)
// SELECT count(*) FROM 'external.table'

try db.detach("external")
// DETACH DATABASE 'external'
```

When compiled for SQLCipher, we can additionally pass a `key` parameter to `attach`:

```swift
try db.attach(.uri("encrypted.sqlite"), as: "encrypted", key: "secret")
// ATTACH DATABASE 'encrypted.sqlite' AS 'encrypted' KEY 'secret'
```

## Logging

We can log SQL using the database’s `trace` function.

```swift
#if DEBUG
    db.trace { print($0) }
#endif
```

## Vacuum

To run the [vacuum](https://www.sqlite.org/lang_vacuum.html) command:

```swift
try db.vacuum()
```


[ROWID]: https://sqlite.org/lang_createtable.html#rowid
[SQLiteMigrationManager.swift]: https://github.com/garriguv/SQLiteMigrationManager.swift
