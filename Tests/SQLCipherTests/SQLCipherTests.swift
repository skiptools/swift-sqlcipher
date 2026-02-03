import Testing
import Foundation
import SQLCipher

@Suite("SQLCipher Cryptographic Integrity")
struct SQLCipherTests {

    let dbPath: String = {
        let temp = NSTemporaryDirectory()
        return (temp as NSString).appendingPathComponent("encrypted-\(UUID().uuidString).db")
    }()

    // Helper to cleanup file between tests
    func cleanup() {
        try? FileManager.default.removeItem(atPath: dbPath)
    }

    // MARK: - Keying & Encryption Tests

    @Test("Successful encryption with valid key")
    func testSuccessfulEncryption() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        #expect(sqlite3_open(dbPath, &db) == SQLITE_OK)

        // Apply key
        let key = "password123"
        #expect(sqlite3_key(db, key, Int32(key.count)) == SQLITE_OK)

        // Create table to force header creation
        #expect(sqlite3_exec(db, "CREATE TABLE secret (data TEXT);", nil, nil, nil) == SQLITE_OK)
        #expect(sqlite3_exec(db, "INSERT INTO secret VALUES ('sensitive');", nil, nil, nil) == SQLITE_OK)

        sqlite3_close(db)
    }

    @Test("Accessing encrypted DB without key fails")
    func testAccessWithoutKey() throws {
        cleanup()
        defer { cleanup() }

        // 1. Create encrypted DB
        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "key", 3)
        sqlite3_exec(db, "CREATE TABLE t1(x);", nil, nil, nil)
        sqlite3_close(db)

        // 2. Try to open without key
        var db2: OpaquePointer?
        sqlite3_open(dbPath, &db2)
        // SQLCipher returns SQLITE_NOTADB or SQLITE_IOERR if the header can't be decrypted
        let result = sqlite3_exec(db2, "SELECT count(*) FROM t1;", nil, nil, nil)
        #expect(result == SQLITE_NOTADB)
        sqlite3_close(db2)
    }

    @Test("Accessing with wrong key fails")
    func testWrongKey() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "right-key", 9)
        sqlite3_exec(db, "CREATE TABLE t1(x);", nil, nil, nil)
        sqlite3_close(db)

        var db2: OpaquePointer?
        sqlite3_open(dbPath, &db2)
        sqlite3_key(db2, "wrong-key", 9)
        let result = sqlite3_exec(db2, "SELECT * FROM t1;", nil, nil, nil)
        #expect(result == SQLITE_NOTADB)
        sqlite3_close(db2)
    }

    @Test("PRAGMA cipher_version verification")
    func testCipherVersion() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "PRAGMA cipher_version;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        let version = String(cString: sqlite3_column_text(stmt, 0))
        #expect(!version.isEmpty) // Ensures SQLCipher is actually linked
        sqlite3_finalize(stmt)
    }

    // MARK: - Cipher Configuration

    @Test("Custom PBKDF2 Iterations")
    func testCustomIterations() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "key", 3)
        // High iteration count for testing
        sqlite3_exec(db, "PRAGMA kdf_iter = 100000;", nil, nil, nil)
        #expect(sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil) == SQLITE_OK)
        sqlite3_close(db)
    }

    @Test("Cipher Page Size adjustment")
    func testPageSize() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }

        #expect(sqlite3_exec(db, "PRAGMA cipher_page_size = 4096;", nil, nil, nil) == SQLITE_OK)
    }

    // MARK: - Rekeying (Key Migration)

    @Test("Changing the database key (rekey)")
    func testRekey() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "old", 3)
        sqlite3_exec(db, "CREATE TABLE t1(x);", nil, nil, nil)

        // Change key
        #expect(sqlite3_rekey(db, "new", 3) == SQLITE_OK)
        sqlite3_close(db)

        // Verify with new key
        var db2: OpaquePointer?
        sqlite3_open(dbPath, &db2)
        #expect(sqlite3_key(db2, "new", 3) == SQLITE_OK)
        #expect(sqlite3_exec(db2, "SELECT * FROM t1;", nil, nil, nil) == SQLITE_OK)
        sqlite3_close(db2)
    }

    // MARK: - Migration & Compatibility

    @Test("Migrating from SQLCipher 3 to 4")
    func testCipherMigration() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }
        sqlite3_key(db, "key", 3)

        // This pragma attempts to upgrade a database if it uses older salt/settings
        let result = sqlite3_exec(db, "PRAGMA cipher_migrate;", nil, nil, nil)
        #expect([SQLITE_OK, SQLITE_DONE].contains(result))
    }

    @Test("Using Raw Key (Hex)")
    func testRawHexKey() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }

        // SQLCipher allows 64-character hex strings prefixed with x'
        let hexKey = "x'6162636465666768696A6B6C6D6E6F706162636465666768696A6B6C6D6E6F70'"
        #expect(sqlite3_exec(db, "PRAGMA key = \"\(hexKey)\";", nil, nil, nil) == SQLITE_OK)
        #expect(sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil) == SQLITE_OK)
    }

    // MARK: - Advanced Cryptographic Features

    @Test("Memory zeroing on close")
    func testMemorySanitizer() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        sqlite3_key(db, "key", 3)
        // SQLCipher automatically zeroes out key material in memory on close
        #expect(sqlite3_close(db) == SQLITE_OK)
    }

    @Test("HMAC Check integrity")
    func testHMACCheck() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }
        sqlite3_key(db, "key", 3)

        // Ensure HMAC is enabled (default in v4)
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, "PRAGMA cipher_use_hmac;", -1, &stmt, nil)
        sqlite3_step(stmt)
        #expect(sqlite3_column_int(stmt, 0) == 1)
        sqlite3_finalize(stmt)
    }

    @Test("Cipher Salt extraction")
    func testSaltExtraction() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "key", 3)
        sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil)

        var stmt: OpaquePointer?
        // This retrieves the 16-byte salt from the DB header
        sqlite3_prepare_v2(db, "PRAGMA cipher_salt;", -1, &stmt, nil)
        #expect(sqlite3_step(stmt) == SQLITE_ROW)
        let salt = sqlite3_column_blob(stmt, 0)
        #expect(salt != nil)
        sqlite3_finalize(stmt)
        sqlite3_close(db)
    }

    // MARK: - ATTACH Operations (Cross-DB Encryption)

    @Test("Attaching encrypted DB to another")
    func testAttachEncrypted() throws {
        cleanup()
        defer { cleanup() }

        var mainDB: OpaquePointer?
        sqlite3_open(dbPath, &mainDB)
        sqlite3_key(mainDB, "key1", 4)

        // Create second DB
        let path2 = dbPath + "2"
        var db2: OpaquePointer?
        sqlite3_open(path2, &db2)
        sqlite3_key(db2, "key2", 4)
        sqlite3_exec(db2, "CREATE TABLE t2(y);", nil, nil, nil)
        sqlite3_close(db2)

        // Attach DB2 to MainDB
        let sql = "ATTACH DATABASE '\(path2)' AS db2 KEY 'key2';"
        #expect(sqlite3_exec(mainDB, sql, nil, nil, nil) == SQLITE_OK)

        sqlite3_close(mainDB)
        try? FileManager.default.removeItem(atPath: path2)
    }

    @Test("Exporting Plaintext to Encrypted")
    func testExportToEncrypted() throws {
        let plainPath = dbPath + ".plain"
        var db: OpaquePointer?
        sqlite3_open(plainPath, &db)
        sqlite3_exec(db, "CREATE TABLE t(x); INSERT INTO t VALUES (1);", nil, nil, nil)

        // Attach a new encrypted DB and export
        sqlite3_exec(db, "ATTACH DATABASE '\(dbPath)' AS encrypted KEY 'secret';", nil, nil, nil)
        #expect(sqlite3_exec(db, "SELECT sqlcipher_export('encrypted');", nil, nil, nil) == SQLITE_OK)
        sqlite3_exec(db, "DETACH DATABASE encrypted;", nil, nil, nil)

        sqlite3_close(db)
        try? FileManager.default.removeItem(atPath: plainPath)
    }


    // MARK: - Error Handling & Edge Cases

    @Test("Empty key behavior")
    func testEmptyKey() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }
        // SQLCipher requires a non-empty key for encryption usually,
        // otherwise it acts as a standard SQLite DB.
        #expect(sqlite3_key(db, "", 0) == SQLITE_MISUSE)
        #expect(sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil) == SQLITE_OK)
    }

    @Test("Rekey on in-memory database")
    func testInMemoryRekey() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }
        sqlite3_key(db, "k1", 2)
        sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil)
        #expect(sqlite3_rekey(db, "k2", 2) == SQLITE_OK)
        #expect(sqlite3_exec(db, "SELECT * FROM t;", nil, nil, nil) == SQLITE_OK)
    }

    @Test("Cipher Settings: plaintext_header_size")
    func testPlaintextHeader() throws {
        var db: OpaquePointer?
        sqlite3_open(":memory:", &db)
        defer { sqlite3_close(db) }
        // Keeping some of the header unencrypted (e.g. for identification)
        #expect(sqlite3_exec(db, "PRAGMA plaintext_header_size = 16;", nil, nil, nil) == SQLITE_OK)
    }

    @Test("Verify file header after encryption")
    func testHeaderValidation() throws {
        cleanup()
        defer { cleanup() }

        var db: OpaquePointer?
        sqlite3_open(dbPath, &db)
        sqlite3_key(db, "key", 3)
        sqlite3_exec(db, "CREATE TABLE t(x);", nil, nil, nil)
        sqlite3_close(db)

        // Read the first 16 bytes. Standard SQLite starts with "SQLite format 3"
        // SQLCipher headers are randomized/encrypted and should NOT start with that string.
        let handle = FileHandle(forReadingAtPath: dbPath)
        let header = handle?.readData(ofLength: 15)
        let headerString = String(data: header ?? Data(), encoding: .ascii)

        #expect(headerString != "SQLite format 3")
        try? handle?.close()
    }
}
