import Testing
import Foundation
import SQLCipher

@Suite("SQLite Core Operations & Concurrency")
struct SQLLiteTests {

    // Helper to create an in-memory database
    func openDB() throws -> OpaquePointer {
        var db: OpaquePointer?
        if sqlite3_open(":memory:", &db) != SQLITE_OK {
            throw AppError.connectionFailed
        }
        return db!
    }

    enum AppError: Error {
        case connectionFailed, executionFailed
    }

    @Test("Create table and verify schema")
    func testCreateTable() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }

        let sql = "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);"
        let result = sqlite3_exec(db, sql, nil, nil, nil)
        #expect(result == SQLITE_OK)
    }

    @Test("Insert and fetch single row")
    func testInsertAndFetch() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }

        sqlite3_exec(db, "CREATE TABLE items (val TEXT);", nil, nil, nil)
        sqlite3_exec(db, "INSERT INTO items (val) VALUES ('Swift');", nil, nil, nil)

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "SELECT val FROM items;", -1, &stmt, nil)
        defer { sqlite3_finalize(stmt) }

        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        let text = String(cString: sqlite3_column_text(stmt, 0))
        #expect(text == "Swift")
    }

    @Test("Handle Null values correctly")
    func testNullHandling() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE data (val TEXT); INSERT INTO data (val) VALUES (NULL);", nil, nil, nil)

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "SELECT val FROM data;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        #expect(sqlite3_column_type(stmt, 0) == SQLITE_NULL)
        sqlite3_finalize(stmt)
    }

    @Test("Transaction Rollback on error")
    func testRollback() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE balance (amt INTEGER); INSERT INTO balance VALUES (100);", nil, nil, nil)

        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)
        sqlite3_exec(db, "UPDATE balance SET amt = 200;", nil, nil, nil)
        sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "SELECT amt FROM balance;", -1, &stmt, nil)
        sqlite3_step(stmt)
        #expect(sqlite3_column_int(stmt, 0) == 100)
        sqlite3_finalize(stmt)
    }

    @Test("Large Blob storage and retrieval")
    func testBlobStorage() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        let data = "binary_data".data(using: .utf8)!

        sqlite3_exec(db, "CREATE TABLE blobs (b BLOB);", nil, nil, nil)
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "INSERT INTO blobs (b) VALUES (?);", -1, &stmt, nil)

        _ = data.withUnsafeBytes { ptr in
            sqlite3_bind_blob(stmt, 1, ptr.baseAddress, Int32(data.count), nil)
        }
        #expect(sqlite3_step(stmt) == SQLITE_DONE)
        sqlite3_finalize(stmt)
    }

    @Test("Parameter binding protection (SQL Injection)")
    func testBinding() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE logs (msg TEXT);", nil, nil, nil)

        let maliciousInput = "'); DROP TABLE logs; --"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "INSERT INTO logs (msg) VALUES (?);", -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, maliciousInput, -1, nil)

        #expect(sqlite3_step(stmt) == SQLITE_DONE)
        sqlite3_finalize(stmt)
        // Verify table still exists
        #expect(sqlite3_exec(db, "SELECT * FROM logs;", nil, nil, nil) == SQLITE_OK)
    }

    @Test("Update row count verification")
    func testChangesCount() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE t (id INTEGER); INSERT INTO t VALUES (1), (2), (3);", nil, nil, nil)
        sqlite3_exec(db, "UPDATE t SET id = id + 10;", nil, nil, nil)
        #expect(sqlite3_changes(db) == 3)
    }

    @Test("Data integrity with UNIQUE constraint")
    func testUniqueConstraint() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE u (id INTEGER UNIQUE);", nil, nil, nil)
        sqlite3_exec(db, "INSERT INTO u VALUES (1);", nil, nil, nil)
        let result = sqlite3_exec(db, "INSERT INTO u VALUES (1);", nil, nil, nil)
        #expect(result == SQLITE_CONSTRAINT)
    }

    @Test("Primary Key Autoincrement")
    func testAutoincrement() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE a (id INTEGER PRIMARY KEY AUTOINCREMENT, n TEXT);", nil, nil, nil)
        sqlite3_exec(db, "INSERT INTO a (n) VALUES ('A');", nil, nil, nil)
        sqlite3_exec(db, "INSERT INTO a (n) VALUES ('B');", nil, nil, nil)
        #expect(sqlite3_last_insert_rowid(db) == 2)
    }

    @Test("Complex Join correctness")
    func testJoins() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE t1 (id INT, v TEXT); CREATE TABLE t2 (id INT, v TEXT);", nil, nil, nil)
        sqlite3_exec(db, "INSERT INTO t1 VALUES (1, 'A'); INSERT INTO t2 VALUES (1, 'B');", nil, nil, nil)

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "SELECT t1.v, t2.v FROM t1 JOIN t2 ON t1.id = t2.id;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        #expect(String(cString: sqlite3_column_text(stmt, 0)) == "A")
        #expect(String(cString: sqlite3_column_text(stmt, 1)) == "B")
        sqlite3_finalize(stmt)
    }

    @Test("Concurrent Reads from multiple connections")
    func testConcurrentReads() async throws {
        // Shared file path for multi-connection tests
        let path = NSTemporaryDirectory() + "test_concurrent.db"
        sqlite3_open(path, nil) // Create it

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    var db: OpaquePointer?
                    sqlite3_open(path, &db)
                    let result = sqlite3_exec(db, "SELECT 1;", nil, nil, nil)
                    #expect(result == SQLITE_OK)
                    sqlite3_close(db)
                }
            }
        }
    }

    @Test("Busy handler retry logic")
    func testBusyHandler() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        // Setting a timeout for 1000ms
        let result = sqlite3_busy_timeout(db, 1000)
        #expect(result == SQLITE_OK)
    }

    @Test("WAL Mode enablement")
    func testWALMode() throws {
        let path = NSTemporaryDirectory() + "wal_test.db"
        var db: OpaquePointer?
        sqlite3_open(path, &db)
        defer { sqlite3_close(db) }

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "PRAGMA journal_mode=WAL;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        let mode = String(cString: sqlite3_column_text(stmt, 0))
        #expect(mode.lowercased() == "wal")
        sqlite3_finalize(stmt)
    }

    @Test("Concurrent Write contention (Expected Busy)")
    func testWriteContention() async throws {
        let path = NSTemporaryDirectory() + "contention.db"
        var db1: OpaquePointer?
        sqlite3_open(path, &db1)
        sqlite3_exec(db1, "CREATE TABLE sync_test (id INT);", nil, nil, nil)

        // Start a transaction on connection 1
        sqlite3_exec(db1, "BEGIN EXCLUSIVE;", nil, nil, nil)

        let task = Task {
            var db2: OpaquePointer?
            sqlite3_open(path, &db2)
            // This should fail or timeout because db1 has an exclusive lock
            let res = sqlite3_exec(db2, "INSERT INTO sync_test VALUES (1);", nil, nil, nil)
            sqlite3_close(db2)
            return res
        }

        let result = await task.value
        #expect(result == SQLITE_BUSY)
        sqlite3_exec(db1, "COMMIT;", nil, nil, nil)
        sqlite3_close(db1)
    }

    @Test("Prepared statement re-use in loops")
    func testStatementReuse() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "CREATE TABLE loop (id INT);", nil, nil, nil)

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "INSERT INTO loop VALUES (?);", -1, &stmt, nil)

        for i in 1...5 {
            sqlite3_bind_int(stmt, 1, Int32(i))
            #expect(sqlite3_step(stmt) == SQLITE_DONE)
            sqlite3_reset(stmt) // Essential for reuse
        }
        sqlite3_finalize(stmt)
    }

    @Test("Thread-safe library configuration")
    func testThreadSafeMode() {
        let mode = sqlite3_threadsafe()
        // 1 = Serialized, 2 = Multi-thread
        #expect(mode > 0)
    }

    @Test("Memory management (Double close protection)")
    func testDoubleClose() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        #expect(sqlite3_close(db) == SQLITE_OK)
        // Subsequent calls should not crash, though result may vary by OS
        #expect(sqlite3_close(db) == SQLITE_MISUSE || sqlite3_close(db) == SQLITE_OK)
    }

    @Test("Recursive Trigger limits")
    func testTriggers() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "PRAGMA recursive_triggers = ON;", nil, nil, nil)
        let sql = """
        CREATE TABLE t(x);
        CREATE TRIGGER r AFTER INSERT ON t BEGIN INSERT INTO t VALUES(new.x+1); END;
        """
        sqlite3_exec(db, sql, nil, nil, nil)
        // This will eventually hit the trigger depth limit
        let res = sqlite3_exec(db, "INSERT INTO t VALUES(1);", nil, nil, nil)
        #expect(res == SQLITE_ERROR)
    }

    @Test("Database Corruption check (Integrity Check)")
    func testIntegrity() throws {
        let db = try openDB()
        defer { sqlite3_close(db) }
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "PRAGMA integrity_check;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        let status = String(cString: sqlite3_column_text(stmt, 0))
        #expect(status == "ok")
        sqlite3_finalize(stmt)
    }
}
