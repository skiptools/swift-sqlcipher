//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
import Foundation

public protocol QueryType: Expressible {

    var clauses: QueryClauses { get set }

    init(_ name: String, database: String?)

}

public protocol SchemaType: QueryType {

    static var identifier: String { get }

}

extension SchemaType {

    /// Builds a copy of the query with the `SELECT` clause applied.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.select(id, email)
    ///     // SELECT "id", "email" FROM "users"
    ///
    /// - Parameter all: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT` clause applied.
    public func select(_ column1: Expressible, _ more: Expressible...) -> Self {
        select(false, [column1] + more)
    }

    /// Builds a copy of the query with the `SELECT DISTINCT` clause applied.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.select(distinct: email)
    ///     // SELECT DISTINCT "email" FROM "users"
    ///
    /// - Parameter columns: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT DISTINCT` clause applied.
    public func select(distinct column1: Expressible, _ more: Expressible...) -> Self {
        select(true, [column1] + more)
    }

    /// Builds a copy of the query with the `SELECT` clause applied.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.select([id, email])
    ///     // SELECT "id", "email" FROM "users"
    ///
    /// - Parameter all: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT` clause applied.
    public func select(_ all: [Expressible]) -> Self {
        select(false, all)
    }

    /// Builds a copy of the query with the `SELECT DISTINCT` clause applied.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.select(distinct: [email])
    ///     // SELECT DISTINCT "email" FROM "users"
    ///
    /// - Parameter columns: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT DISTINCT` clause applied.
    public func select(distinct columns: [Expressible]) -> Self {
        select(true, columns)
    }

    /// Builds a copy of the query with the `SELECT *` clause applied.
    ///
    ///     let users = Table("users")
    ///
    ///     users.select(*)
    ///     // SELECT * FROM "users"
    ///
    /// - Parameter star: A star literal.
    ///
    /// - Returns: A query with the given `SELECT *` clause applied.
    public func select(_ star: Star) -> Self {
        select([star(nil, nil)])
    }

    /// Builds a copy of the query with the `SELECT DISTINCT *` clause applied.
    ///
    ///     let users = Table("users")
    ///
    ///     users.select(distinct: *)
    ///     // SELECT DISTINCT * FROM "users"
    ///
    /// - Parameter star: A star literal.
    ///
    /// - Returns: A query with the given `SELECT DISTINCT *` clause applied.
    public func select(distinct star: Star) -> Self {
        select(distinct: [star(nil, nil)])
    }

    /// Builds a scalar copy of the query with the `SELECT` clause applied.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///
    ///     users.select(id)
    ///     // SELECT "id" FROM "users"
    ///
    /// - Parameter all: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT` clause applied.
    public func select<V: Value>(_ column: SQLExpression<V>) -> ScalarQuery<V> {
        select(false, [column])
    }
    public func select<V: Value>(_ column: SQLExpression<V?>) -> ScalarQuery<V?> {
        select(false, [column])
    }

    /// Builds a scalar copy of the query with the `SELECT DISTINCT` clause
    /// applied.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.select(distinct: email)
    ///     // SELECT DISTINCT "email" FROM "users"
    ///
    /// - Parameter column: A list of expressions to select.
    ///
    /// - Returns: A query with the given `SELECT DISTINCT` clause applied.
    public func select<V: Value>(distinct column: SQLExpression<V>) -> ScalarQuery<V> {
        select(true, [column])
    }
    public func select<V: Value>(distinct column: SQLExpression<V?>) -> ScalarQuery<V?> {
        select(true, [column])
    }

    public var count: ScalarQuery<Int> {
        select(SQLExpression.count(*))
    }

}

extension QueryType {

    fileprivate func select<Q: QueryType>(_ distinct: Bool, _ columns: [Expressible]) -> Q {
        var query = Q.init(clauses.from.name, database: clauses.from.database)
        query.clauses = clauses
        query.clauses.select = (distinct, columns)
        return query
    }

    // MARK: UNION

    /// Adds a `UNION` clause to the query.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///
    ///     users.filter(email == "alice@example.com").union(users.filter(email == "sally@example.com"))
    ///     // SELECT * FROM "users" WHERE email = 'alice@example.com' UNION SELECT * FROM "users" WHERE email = 'sally@example.com'
    ///
    /// - Parameters:
    ///
    ///   - all: If false, duplicate rows are removed from the result.
    ///
    ///   - table: A query representing the other table.
    ///
    /// - Returns: A query with the given `UNION` clause applied.
    public func union(all: Bool = false, _ table: QueryType) -> Self {
        var query = self
        query.clauses.union.append((all, table))
        return query
    }

    // MARK: JOIN

    /// Adds a `JOIN` clause to the query.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let posts = Table("posts")
    ///     let userId = SQLExpression<Int64>("user_id")
    ///
    ///     users.join(posts, on: posts[userId] == users[id])
    ///     // SELECT * FROM "users" INNER JOIN "posts" ON ("posts"."user_id" = "users"."id")
    ///
    /// - Parameters:
    ///
    ///   - table: A query representing the other table.
    ///
    ///   - condition: A boolean expression describing the join condition.
    ///
    /// - Returns: A query with the given `JOIN` clause applied.
    public func join(_ table: QueryType, on condition: SQLExpression<Bool>) -> Self {
        join(table, on: SQLExpression<Bool?>(condition))
    }

    /// Adds a `JOIN` clause to the query.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let posts = Table("posts")
    ///     let userId = SQLExpression<Int64?>("user_id")
    ///
    ///     users.join(posts, on: posts[userId] == users[id])
    ///     // SELECT * FROM "users" INNER JOIN "posts" ON ("posts"."user_id" = "users"."id")
    ///
    /// - Parameters:
    ///
    ///   - table: A query representing the other table.
    ///
    ///   - condition: A boolean expression describing the join condition.
    ///
    /// - Returns: A query with the given `JOIN` clause applied.
    public func join(_ table: QueryType, on condition: SQLExpression<Bool?>) -> Self {
        join(.inner, table, on: condition)
    }

    /// Adds a `JOIN` clause to the query.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let posts = Table("posts")
    ///     let userId = SQLExpression<Int64>("user_id")
    ///
    ///     users.join(.LeftOuter, posts, on: posts[userId] == users[id])
    ///     // SELECT * FROM "users" LEFT OUTER JOIN "posts" ON ("posts"."user_id" = "users"."id")
    ///
    /// - Parameters:
    ///
    ///   - type: The `JOIN` operator.
    ///
    ///   - table: A query representing the other table.
    ///
    ///   - condition: A boolean expression describing the join condition.
    ///
    /// - Returns: A query with the given `JOIN` clause applied.
    public func join(_ type: JoinType, _ table: QueryType, on condition: SQLExpression<Bool>) -> Self {
        join(type, table, on: SQLExpression<Bool?>(condition))
    }

    /// Adds a `JOIN` clause to the query.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///     let posts = Table("posts")
    ///     let userId = SQLExpression<Int64?>("user_id")
    ///
    ///     users.join(.LeftOuter, posts, on: posts[userId] == users[id])
    ///     // SELECT * FROM "users" LEFT OUTER JOIN "posts" ON ("posts"."user_id" = "users"."id")
    ///
    /// - Parameters:
    ///
    ///   - type: The `JOIN` operator.
    ///
    ///   - table: A query representing the other table.
    ///
    ///   - condition: A boolean expression describing the join condition.
    ///
    /// - Returns: A query with the given `JOIN` clause applied.
    public func join(_ type: JoinType, _ table: QueryType, on condition: SQLExpression<Bool?>) -> Self {
        var query = self
        query.clauses.join.append((type: type, query: table,
                                          condition: table.clauses.filters.map { condition && $0 } ?? condition as Expressible))
        return query
    }

    // MARK: WHERE

    /// Adds a condition to the query’s `WHERE` clause.
    ///
    ///     let users = Table("users")
    ///     let id = SQLExpression<Int64>("id")
    ///
    ///     users.filter(id == 1)
    ///     // SELECT * FROM "users" WHERE ("id" = 1)
    ///
    /// - Parameter condition: A boolean expression to filter on.
    ///
    /// - Returns: A query with the given `WHERE` clause applied.
    public func filter(_ predicate: SQLExpression<Bool>) -> Self {
        filter(SQLExpression<Bool?>(predicate))
    }

    /// Adds a condition to the query’s `WHERE` clause.
    ///
    ///     let users = Table("users")
    ///     let age = SQLExpression<Int?>("age")
    ///
    ///     users.filter(age >= 35)
    ///     // SELECT * FROM "users" WHERE ("age" >= 35)
    ///
    /// - Parameter condition: A boolean expression to filter on.
    ///
    /// - Returns: A query with the given `WHERE` clause applied.
    public func filter(_ predicate: SQLExpression<Bool?>) -> Self {
        var query = self
        query.clauses.filters = query.clauses.filters.map { $0 && predicate } ?? predicate
        return query
    }

    /// Adds a condition to the query’s `WHERE` clause.
    /// This is an alias for `filter(predicate)`
    public func `where`(_ predicate: SQLExpression<Bool>) -> Self {
        `where`(SQLExpression<Bool?>(predicate))
    }

    /// Adds a condition to the query’s `WHERE` clause.
    /// This is an alias for `filter(predicate)`
    public func `where`(_ predicate: SQLExpression<Bool?>) -> Self {
        filter(predicate)
    }

    // MARK: GROUP BY

    /// Sets a `GROUP BY` clause on the query.
    ///
    /// - Parameter by: A list of columns to group by.
    ///
    /// - Returns: A query with the given `GROUP BY` clause applied.
    public func group(_ by: Expressible...) -> Self {
        group(by)
    }

    /// Sets a `GROUP BY` clause on the query.
    ///
    /// - Parameter by: A list of columns to group by.
    ///
    /// - Returns: A query with the given `GROUP BY` clause applied.
    public func group(_ by: [Expressible]) -> Self {
        group(by, nil)
    }

    /// Sets a `GROUP BY`-`HAVING` clause on the query.
    ///
    /// - Parameters:
    ///
    ///   - by: A column to group by.
    ///
    ///   - having: A condition determining which groups are returned.
    ///
    /// - Returns: A query with the given `GROUP BY`–`HAVING` clause applied.
    public func group(_ by: Expressible, having: SQLExpression<Bool>) -> Self {
        group([by], having: having)
    }

    /// Sets a `GROUP BY`-`HAVING` clause on the query.
    ///
    /// - Parameters:
    ///
    ///   - by: A column to group by.
    ///
    ///   - having: A condition determining which groups are returned.
    ///
    /// - Returns: A query with the given `GROUP BY`–`HAVING` clause applied.
    public func group(_ by: Expressible, having: SQLExpression<Bool?>) -> Self {
        group([by], having: having)
    }

    /// Sets a `GROUP BY`-`HAVING` clause on the query.
    ///
    /// - Parameters:
    ///
    ///   - by: A list of columns to group by.
    ///
    ///   - having: A condition determining which groups are returned.
    ///
    /// - Returns: A query with the given `GROUP BY`–`HAVING` clause applied.
    public func group(_ by: [Expressible], having: SQLExpression<Bool>) -> Self {
        group(by, SQLExpression<Bool?>(having))
    }

    /// Sets a `GROUP BY`-`HAVING` clause on the query.
    ///
    /// - Parameters:
    ///
    ///   - by: A list of columns to group by.
    ///
    ///   - having: A condition determining which groups are returned.
    ///
    /// - Returns: A query with the given `GROUP BY`–`HAVING` clause applied.
    public func group(_ by: [Expressible], having: SQLExpression<Bool?>) -> Self {
        group(by, having)
    }

    fileprivate func group(_ by: [Expressible], _ having: SQLExpression<Bool?>?) -> Self {
        var query = self
        query.clauses.group = (by, having)
        return query
    }

    // MARK: ORDER BY

    /// Sets an `ORDER BY` clause on the query.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///     let name = SQLExpression<String?>("name")
    ///
    ///     users.order(email.desc, name.asc)
    ///     // SELECT * FROM "users" ORDER BY "email" DESC, "name" ASC
    ///
    /// - Parameter by: An ordered list of columns and directions to sort by.
    ///
    /// - Returns: A query with the given `ORDER BY` clause applied.
    public func order(_ by: Expressible...) -> Self {
        order(by)
    }

    /// Sets an `ORDER BY` clause on the query.
    ///
    ///     let users = Table("users")
    ///     let email = SQLExpression<String>("email")
    ///     let name = SQLExpression<String?>("name")
    ///
    ///     users.order([email.desc, name.asc])
    ///     // SELECT * FROM "users" ORDER BY "email" DESC, "name" ASC
    ///
    /// - Parameter by: An ordered list of columns and directions to sort by.
    ///
    /// - Returns: A query with the given `ORDER BY` clause applied.
    public func order(_ by: [Expressible]) -> Self {
        var query = self
        query.clauses.order = by
        return query
    }

    // MARK: LIMIT/OFFSET

    /// Sets the LIMIT clause (and resets any OFFSET clause) on the query.
    ///
    ///     let users = Table("users")
    ///
    ///     users.limit(20)
    ///     // SELECT * FROM "users" LIMIT 20
    ///
    /// - Parameter length: The maximum number of rows to return (or `nil` to
    ///   return unlimited rows).
    ///
    /// - Returns: A query with the given LIMIT clause applied.
    public func limit(_ length: Int?) -> Self {
        limit(length, nil)
    }

    /// Sets LIMIT and OFFSET clauses on the query.
    ///
    ///     let users = Table("users")
    ///
    ///     users.limit(20, offset: 20)
    ///     // SELECT * FROM "users" LIMIT 20 OFFSET 20
    ///
    /// - Parameters:
    ///
    ///   - length: The maximum number of rows to return.
    ///
    ///   - offset: The number of rows to skip.
    ///
    /// - Returns: A query with the given LIMIT and OFFSET clauses applied.
    public func limit(_ length: Int, offset: Int) -> Self {
        limit(length, offset)
    }

    // prevents limit(nil, offset: 5)
    fileprivate func limit(_ length: Int?, _ offset: Int?) -> Self {
        var query = self
        query.clauses.limit = length.map { ($0, offset) }
        return query
    }

    // MARK: - Clauses
    //
    // MARK: SELECT

    // MARK: -

    fileprivate var selectClause: Expressible {
        " ".join([
            SQLExpression<Void>(literal:
                            clauses.select.distinct ? "SELECT DISTINCT" : "SELECT"),
           ", ".join(clauses.select.columns),
           SQLExpression<Void>(literal: "FROM"),
           tableName(alias: true)
       ])
    }

    fileprivate var joinClause: Expressible? {
        guard !clauses.join.isEmpty else {
            return nil
        }

        return " ".join(clauses.join.map { arg in
            let (type, query, condition) = arg
            return " ".join([
                SQLExpression<Void>(literal: "\(type.rawValue) JOIN"),
                query.tableName(alias: true),
                SQLExpression<Void>(literal: "ON"),
                condition
            ])
        })
    }

    fileprivate var whereClause: Expressible? {
        guard let filters = clauses.filters else {
            return nil
        }

        return " ".join([
            SQLExpression<Void>(literal: "WHERE"),
            filters
        ])
    }

    fileprivate var groupByClause: Expressible? {
        guard let group = clauses.group else {
            return nil
        }

        let groupByClause = " ".join([
            SQLExpression<Void>(literal: "GROUP BY"),
            ", ".join(group.by)
        ])

        guard let having = group.having else {
            return groupByClause
        }

        return " ".join([
            groupByClause,
            " ".join([
                SQLExpression<Void>(literal: "HAVING"),
                having
            ])
        ])
    }

    fileprivate var orderClause: Expressible? {
        guard !clauses.order.isEmpty else {
            return nil
        }

        return " ".join([
            SQLExpression<Void>(literal: "ORDER BY"),
            ", ".join(clauses.order)
        ])
    }

    fileprivate var limitOffsetClause: Expressible? {
        guard let limit = clauses.limit else {
            return nil
        }

        let limitClause = SQLExpression<Void>(literal: "LIMIT \(limit.length)")

        guard let offset = limit.offset else {
            return limitClause
        }

        return " ".join([
            limitClause,
            SQLExpression<Void>(literal: "OFFSET \(offset)")
        ])
    }

    fileprivate var unionClause: Expressible? {
        guard !clauses.union.isEmpty else {
            return nil
        }

        return " ".join(clauses.union.map { (all, query) in
            " ".join([
                SQLExpression<Void>(literal: all ? "UNION ALL" : "UNION"),
                query
            ])
        })
    }

    // MARK: -

    public func alias(_ aliasName: String) -> Self {
        var query = self
        query.clauses.from = (clauses.from.name, aliasName, clauses.from.database)
        return query
    }

    // MARK: - Operations
    //
    // MARK: INSERT

    public func insert(_ value: Setter, _ more: Setter...) -> Insert {
        insert([value] + more)
    }

    public func insert(_ values: [Setter]) -> Insert {
        insert(nil, values)
    }

    public func insert(or onConflict: OnConflict, _ values: Setter...) -> Insert {
        insert(or: onConflict, values)
    }

    public func insert(or onConflict: OnConflict, _ values: [Setter]) -> Insert {
        insert(onConflict, values)
    }

    public func insertMany( _ values: [[Setter]]) -> Insert {
        insertMany(nil, values)
    }

    public func insertMany(or onConflict: OnConflict, _ values: [[Setter]]) -> Insert {
        insertMany(onConflict, values)
    }

    public func insertMany(or onConflict: OnConflict, _ values: [Setter]...) -> Insert {
        insertMany(onConflict, values)
    }

    fileprivate func insert(_ or: OnConflict?, _ values: [Setter]) -> Insert {
        let insert = values.reduce((columns: [Expressible](), values: [Expressible]())) { insert, setter in
            (insert.columns + [setter.column], insert.values + [setter.value])
        }

        let clauses: [Expressible?] = [
            SQLExpression<Void>(literal: "INSERT"),
            or.map { SQLExpression<Void>(literal: "OR \($0.rawValue)") },
            SQLExpression<Void>(literal: "INTO"),
            tableName(),
            "".wrap(insert.columns) as SQLExpression<Void>,
            SQLExpression<Void>(literal: "VALUES"),
            "".wrap(insert.values) as SQLExpression<Void>,
            whereClause
        ]

        return Insert(" ".join(clauses.compactMap { $0 }).expression)
    }

    fileprivate func insertMany(_ or: OnConflict?, _ values: [[Setter]]) -> Insert {
        guard let firstInsert = values.first else {
            // must be at least 1 object or else we don't know columns. Default to default inserts.
            return insert()
        }
        let columns = firstInsert.map { $0.column }
        let insertValues = values.map { rowValues in
            rowValues.reduce([Expressible]()) { insert, setter in
                insert + [setter.value]
            }
        }

        let clauses: [Expressible?] = [
            SQLExpression<Void>(literal: "INSERT"),
            or.map { SQLExpression<Void>(literal: "OR \($0.rawValue)") },
            SQLExpression<Void>(literal: "INTO"),
            tableName(),
            "".wrap(columns) as SQLExpression<Void>,
            SQLExpression<Void>(literal: "VALUES"),
            ", ".join(insertValues.map({ "".wrap($0) as SQLExpression<Void> })),
            whereClause
        ]
        return Insert(" ".join(clauses.compactMap { $0 }).expression)
    }

    /// Runs an `INSERT` statement against the query with `DEFAULT VALUES`.
    public func insert() -> Insert {
        Insert(" ".join([
            SQLExpression<Void>(literal: "INSERT INTO"),
            tableName(),
            SQLExpression<Void>(literal: "DEFAULT VALUES")
        ]).expression)
    }

    /// Runs an `INSERT` statement against the query with the results of another
    /// query.
    ///
    /// - Parameter query: A query to `SELECT` results from.
    ///
    /// - Returns: The number of updated rows and statement.
    public func insert(_ query: QueryType) -> Update {
        Update(" ".join([
            SQLExpression<Void>(literal: "INSERT INTO"),
            tableName(),
            query.expression
       ]).expression)
    }

    // MARK: UPSERT

    public func upsert(_ insertValues: Setter..., onConflictOf conflicting: Expressible) -> Insert {
        upsert(insertValues, onConflictOf: conflicting)
    }

    public func upsert(_ insertValues: [Setter], onConflictOf conflicting: Expressible) -> Insert {
        let setValues = insertValues.filter { $0.column.asSQL() != conflicting.asSQL() }
            .map { Setter(excluded: $0.column) }
        return upsert(insertValues, onConflictOf: conflicting, set: setValues)
    }

    public func upsert(_ insertValues: Setter..., onConflictOf conflicting: Expressible, set setValues: [Setter]) -> Insert {
        upsert(insertValues, onConflictOf: conflicting, set: setValues)
    }

    public func upsert(_ insertValues: [Setter], onConflictOf conflicting: Expressible, set setValues: [Setter]) -> Insert {
        let insert = insertValues.reduce((columns: [Expressible](), values: [Expressible]())) { insert, setter in
            (insert.columns + [setter.column], insert.values + [setter.value])
        }

        let clauses: [Expressible?] = [
            SQLExpression<Void>(literal: "INSERT"),
            SQLExpression<Void>(literal: "INTO"),
            tableName(),
            "".wrap(insert.columns) as SQLExpression<Void>,
            SQLExpression<Void>(literal: "VALUES"),
            "".wrap(insert.values) as SQLExpression<Void>,
            whereClause,
            SQLExpression<Void>(literal: "ON CONFLICT"),
            "".wrap(conflicting) as SQLExpression<Void>,
            SQLExpression<Void>(literal: "DO UPDATE SET"),
            ", ".join(setValues.map { $0.expression })
        ]

        return Insert(" ".join(clauses.compactMap { $0 }).expression)
    }

    // MARK: UPDATE

    public func update(_ values: Setter...) -> Update {
        update(values)
    }

    public func update(_ values: [Setter]) -> Update {
        let clauses: [Expressible?] = [
            SQLExpression<Void>(literal: "UPDATE"),
            tableName(),
            SQLExpression<Void>(literal: "SET"),
            ", ".join(values.map { " = ".join([$0.column, $0.value]) }),
            whereClause,
            orderClause,
            limitOffsetClause
        ]

        return Update(" ".join(clauses.compactMap { $0 }).expression)
    }

    // MARK: DELETE

    public func delete() -> Delete {
        let clauses: [Expressible?] = [
            SQLExpression<Void>(literal: "DELETE FROM"),
            tableName(),
            whereClause,
            orderClause,
            limitOffsetClause
        ]

        return Delete(" ".join(clauses.compactMap { $0 }).expression)
    }

    // MARK: EXISTS

    public var exists: Select<Bool> {
        Select(" ".join([
            SQLExpression<Void>(literal: "SELECT EXISTS"),
            "".wrap(expression) as SQLExpression<Void>
        ]).expression)
    }

    // MARK: -

    /// Prefixes a column expression with the query’s table name or alias.
    ///
    /// - Parameter column: A column expression.
    ///
    /// - Returns: A column expression namespaced with the query’s table name or
    ///   alias.
    public func namespace<V>(_ column: SQLExpression<V>) -> SQLExpression<V> {
        SQLExpression(".".join([tableName(), column]).expression)
    }

    public subscript<T>(column: SQLExpression<T>) -> SQLExpression<T> {
        namespace(column)
    }

    public subscript<T>(column: SQLExpression<T?>) -> SQLExpression<T?> {
        namespace(column)
    }

    /// Prefixes a star with the query’s table name or alias.
    ///
    /// - Parameter star: A literal `*`.
    ///
    /// - Returns: A `*` expression namespaced with the query’s table name or
    ///   alias.
    public subscript(star: Star) -> SQLExpression<Void> {
        namespace(star(nil, nil))
    }

    // MARK: -

    // TODO: alias support
    func tableName(alias aliased: Bool = false) -> Expressible {
        guard let alias = clauses.from.alias, aliased else {
            return database(namespace: clauses.from.alias ?? clauses.from.name)
        }

        return " ".join([
            database(namespace: clauses.from.name),
            SQLExpression<Void>(literal: "AS"),
            SQLExpression<Void>(alias)
        ])
    }

    func tableName(qualified: Bool) -> Expressible {
        if qualified {
            return tableName()
        }
        return SQLExpression<Void>(clauses.from.alias ?? clauses.from.name)
    }

    func database(namespace name: String) -> Expressible {
        let name = SQLExpression<Void>(name)

        guard let database = clauses.from.database else {
            return name
        }

        return ".".join([SQLExpression<Void>(database), name])
    }

    public var expression: SQLExpression<Void> {
        let clauses: [Expressible?] = [
            withClause,
            selectClause,
            joinClause,
            whereClause,
            groupByClause,
            unionClause,
            orderClause,
            limitOffsetClause
        ]

        return " ".join(clauses.compactMap { $0 }).expression
    }

}

// TODO: decide: simplify the below with a boxed type instead

/// Queries a collection of chainable helper functions and expressions to build
/// executable SQL statements.
public struct Table: SchemaType {

    public static let identifier = "TABLE"

    public var clauses: QueryClauses

    public init(_ name: String, database: String? = nil) {
        clauses = QueryClauses(name, alias: nil, database: database)
    }

}

public struct View: SchemaType {

    public static let identifier = "VIEW"

    public var clauses: QueryClauses

    public init(_ name: String, database: String? = nil) {
        clauses = QueryClauses(name, alias: nil, database: database)
    }

}

public struct VirtualTable: SchemaType {

    public static let identifier = "VIRTUAL TABLE"

    public var clauses: QueryClauses

    public init(_ name: String, database: String? = nil) {
        clauses = QueryClauses(name, alias: nil, database: database)
    }

}

// TODO: make `ScalarQuery` work in `QueryType.select()`, `.filter()`, etc.

public struct ScalarQuery<V>: QueryType {

    public var clauses: QueryClauses

    public init(_ name: String, database: String? = nil) {
        clauses = QueryClauses(name, alias: nil, database: database)
    }

}

// TODO: decide: simplify the below with a boxed type instead

public struct Select<T>: ExpressionType {

    public var template: String
    public var bindings: [Binding?]

    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }

}

public struct Insert: ExpressionType {

    public var template: String
    public var bindings: [Binding?]

    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }

}

public struct Update: ExpressionType {

    public var template: String
    public var bindings: [Binding?]

    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }

}

public struct Delete: ExpressionType {

    public var template: String
    public var bindings: [Binding?]

    public init(_ template: String, _ bindings: [Binding?]) {
        self.template = template
        self.bindings = bindings
    }

}

public struct RowIterator: FailableIterator {
    public typealias Element = Row
    let statement: Statement
    let columnNames: [String: Int]

    public func failableNext() throws -> Row? {
        try statement.failableNext().flatMap { Row(columnNames, $0) }
    }

    public func map<T>(_ transform: (Element) throws -> T) throws -> [T] {
        var elements = [T]()
        while let row = try failableNext() {
            elements.append(try transform(row))
        }
        return elements
    }

    public func compactMap<T>(_ transform: (Element) throws -> T?) throws -> [T] {
        var elements = [T]()
        while let row = try failableNext() {
            guard let element = try transform(row) else { continue }
            elements.append(element)
        }
        return elements
    }
}

extension Connection {

    public func prepare(_ query: QueryType) throws -> AnySequence<Row> {
        let expression = query.expression
        let statement = try prepare(expression.template, expression.bindings)

        let columnNames = try columnNamesForQuery(query)

        return AnySequence {
            AnyIterator { statement.next().map { Row(columnNames, $0) } }
        }
    }

    public func prepareRowIterator(_ query: QueryType) throws -> RowIterator {
        let expression = query.expression
        let statement = try prepare(expression.template, expression.bindings)
        return RowIterator(statement: statement, columnNames: try columnNamesForQuery(query))
    }

    public func prepareRowIterator(_ statement: String, bindings: Binding?...) throws -> RowIterator {
        try prepare(statement, bindings).prepareRowIterator()
    }

    public func prepareRowIterator(_ statement: String, bindings: [Binding?]) throws -> RowIterator {
        try prepare(statement, bindings).prepareRowIterator()
    }

    private func columnNamesForQuery(_ query: QueryType) throws -> [String: Int] {
        var (columnNames, idx) = ([String: Int](), 0)
        column: for each in query.clauses.select.columns {
            var names = each.expression.template.split { $0 == "." }.map(String.init)
            let column = names.removeLast()
            let namespace = names.joined(separator: ".")

            // Return a copy of the input "with" clause stripping all subclauses besides "select", "join", and "with".
            func strip(_ with: WithClauses) -> WithClauses {
                var stripped = WithClauses()
                stripped.recursive = with.recursive
                for subclause in with.clauses {
                    let query = subclause.query
                    var strippedQuery = type(of: query).init(query.clauses.from.name, database: query.clauses.from.database)
                    strippedQuery.clauses.select = query.clauses.select
                    strippedQuery.clauses.join = query.clauses.join
                    strippedQuery.clauses.with = strip(query.clauses.with)

                    var strippedSubclause = WithClauses.Clause(alias: subclause.alias, query: strippedQuery)
                    strippedSubclause.columns = subclause.columns
                    stripped.clauses.append(strippedSubclause)
                }
                return stripped
            }

            func expandGlob(_ namespace: Bool) -> (QueryType) throws -> Void {
                { (queryType: QueryType) throws -> Void in
                    var query = type(of: queryType).init(queryType.clauses.from.name, database: queryType.clauses.from.database)
                    query.clauses.select = queryType.clauses.select
                    query.clauses.with = strip(queryType.clauses.with)
                    let expression = query.expression
                    var names = try self.prepare(expression.template, expression.bindings).columnNames.map { $0.quote() }
                    if namespace { names = names.map { "\(queryType.tableName().expression.template).\($0)" } }
                    for name in names { columnNames[name] = idx; idx += 1 }
                }
            }

            if column == "*" {
                var select = query
                select.clauses.select = (false, [SQLExpression<Void>(literal: "*") as Expressible])
                let queries = [select] + query.clauses.join.map { $0.query }
                if !namespace.isEmpty {
                    for q in queries where q.tableName().expression.template == namespace {
                        try expandGlob(true)(q)
                        continue column
                    }
                    throw QueryError.noSuchTable(name: namespace)
                }
                for q in queries {
                    try expandGlob(query.clauses.join.count > 0)(q)
                }
                continue
            }

            columnNames[each.expression.template] = idx
            idx += 1
        }
        return columnNames
    }

    public func scalar<V: Value>(_ query: ScalarQuery<V>) throws -> V {
        let expression = query.expression
        return value(try scalar(expression.template, expression.bindings))
    }

    public func scalar<V: Value>(_ query: ScalarQuery<V?>) throws -> V.ValueType? {
        let expression = query.expression
        guard let value = try scalar(expression.template, expression.bindings) as? V.Datatype else { return nil }
        return try V.fromDatatypeValue(value)
    }

    public func scalar<V: Value>(_ query: Select<V>) throws -> V {
        let expression = query.expression
        return value(try scalar(expression.template, expression.bindings))
    }

    public func scalar<V: Value>(_ query: Select<V?>) throws -> V.ValueType? {
        let expression = query.expression
        guard let value = try scalar(expression.template, expression.bindings) as? V.Datatype else { return nil }
        return try V.fromDatatypeValue(value)
    }

    public func pluck(_ query: QueryType) throws -> Row? {
        try prepareRowIterator(query.limit(1, query.clauses.limit?.offset)).failableNext()
    }

    /// Runs an `Insert` query.
    ///
    /// - SeeAlso: `QueryType.insert(value:_:)`
    /// - SeeAlso: `QueryType.insert(values:)`
    /// - SeeAlso: `QueryType.insert(or:_:)`
    /// - SeeAlso: `QueryType.insertMany(values:)`
    /// - SeeAlso: `QueryType.insertMany(or:_:)`
    /// - SeeAlso: `QueryType.insert()`
    ///
    /// - Parameter query: An insert query.
    ///
    /// - Returns: The insert’s rowid.
    @discardableResult public func run(_ query: Insert) throws -> Int64 {
        let expression = query.expression
        return try sync {
            try self.run(expression.template, expression.bindings)
            return lastInsertRowid
        }
    }

    /// Runs an `Update` query.
    ///
    /// - SeeAlso: `QueryType.insert(query:)`
    /// - SeeAlso: `QueryType.update(values:)`
    ///
    /// - Parameter query: An update query.
    ///
    /// - Returns: The number of updated rows.
    @discardableResult public func run(_ query: Update) throws -> Int {
        let expression = query.expression
        return try sync {
            try self.run(expression.template, expression.bindings)
            return changes
        }
    }

    /// Runs a `Delete` query.
    ///
    /// - SeeAlso: `QueryType.delete()`
    ///
    /// - Parameter query: A delete query.
    ///
    /// - Returns: The number of deleted rows.
    @discardableResult public func run(_ query: Delete) throws -> Int {
        let expression = query.expression
        return try sync {
            try self.run(expression.template, expression.bindings)
            return changes
        }
    }

}

public struct Row {

    let columnNames: [String: Int]

    fileprivate let values: [Binding?]

    internal init(_ columnNames: [String: Int], _ values: [Binding?]) {
        self.columnNames = columnNames
        self.values = values
    }

    func hasValue(for column: String) -> Bool {
        guard let idx = columnNames[column.quote()] else {
            return false
        }
        return values[idx] != nil
    }

    /// Returns a row’s value for the given column.
    ///
    /// - Parameter column: An expression representing a column selected in a Query.
    ///
    /// - Returns: The value for the given column.
    public func get<V: Value>(_ column: SQLExpression<V>) throws -> V {
        if let value = try get(SQLExpression<V?>(column)) {
            return value
        } else {
            throw QueryError.unexpectedNullValue(name: column.template)
        }
    }

    public func get<V: Value>(_ column: SQLExpression<V?>) throws -> V? {
        func valueAtIndex(_ idx: Int) throws -> V? {
            guard let value = values[idx] as? V.Datatype else { return nil }
            return try V.fromDatatypeValue(value) as? V
        }

        guard let idx = columnNames[column.template] else {
            func similar(_ name: String) -> Bool {
                return name.hasSuffix(".\(column.template)")
            }

            guard let firstIndex = columnNames.firstIndex(where: { similar($0.key) }) else {
                throw QueryError.noSuchColumn(name: column.template, columns: columnNames.keys.sorted())
            }

            let secondIndex = columnNames
                .suffix(from: columnNames.index(after: firstIndex))
                .firstIndex(where: { similar($0.key) })

            guard secondIndex == nil else {
                throw QueryError.ambiguousColumn(
                    name: column.template,
                    similar: columnNames.keys.filter(similar).sorted()
                )
            }
            return try valueAtIndex(columnNames[firstIndex].value)
        }

        return try valueAtIndex(idx)
    }

    public subscript<T: Value>(column: SQLExpression<T>) -> T {
        // swiftlint:disable:next force_try
        try! get(column)
    }

    public subscript<T: Value>(column: SQLExpression<T?>) -> T? {
        // swiftlint:disable:next force_try
        try! get(column)
    }
}

/// Determines the join operator for a query’s `JOIN` clause.
public enum JoinType: String {

    /// A `CROSS` join.
    case cross = "CROSS"

    /// An `INNER` join.
    case inner = "INNER"

    /// A `LEFT OUTER` join.
    case leftOuter = "LEFT OUTER"

}

/// ON CONFLICT resolutions.
public enum OnConflict: String {

    case replace = "REPLACE"

    case rollback = "ROLLBACK"

    case abort = "ABORT"

    case fail = "FAIL"

    case ignore = "IGNORE"

}

// MARK: - Private

public struct QueryClauses {

    var select = (distinct: false, columns: [SQLExpression<Void>(literal: "*") as Expressible])

    var from: (name: String, alias: String?, database: String?)

    var join = [(type: JoinType, query: QueryType, condition: Expressible)]()

    var filters: SQLExpression<Bool?>?

    var group: (by: [Expressible], having: SQLExpression<Bool?>?)?

    var order = [Expressible]()

    var limit: (length: Int, offset: Int?)?

    var union = [(all: Bool, table: QueryType)]()

    var with = WithClauses()

    fileprivate init(_ name: String, alias: String?, database: String?) {
        from = (name, alias, database)
    }

}
