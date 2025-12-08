// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift-sqlcipher",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v12),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SQLiteDB",
            targets: ["SQLiteDB"]
        ),
        .library(
            name: "SQLCipher",
            targets: ["SQLCipher"]
        )
    ],
    targets: [
        .target(
            name: "SQLiteDB",
            dependencies: [.target(name: "SQLCipher")],
            cSettings: [.define("SQLITE_HAS_CODEC")],
            swiftSettings: [.define("SQLITE_SWIFT_SQLCIPHER")]
        ),
        .target(
            name: "SQLCipher",
            sources: ["sqlite", "libtomcrypt"],
            publicHeadersPath: "sqlite",
            cSettings: [
                .headerSearchPath("libtomcrypt/headers"),
                .define("SQLITE_DQS", to: "0"),
                .define("SQLITE_ENABLE_API_ARMOR"),
                .define("SQLITE_ENABLE_COLUMN_METADATA"),
                .define("SQLITE_ENABLE_DBSTAT_VTAB"),
                .define("SQLITE_ENABLE_FTS3"),
                .define("SQLITE_ENABLE_FTS3_PARENTHESIS"),
                .define("SQLITE_ENABLE_FTS3_TOKENIZER"),
                .define("SQLITE_ENABLE_FTS4"),
                .define("SQLITE_ENABLE_FTS5"),
                .define("SQLITE_ENABLE_MEMORY_MANAGEMENT"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
                .define("SQLITE_ENABLE_RTREE"),
                .define("SQLITE_ENABLE_SESSION"),
                .define("SQLITE_ENABLE_STMTVTAB"),
                .define("SQLITE_ENABLE_UNKNOWN_SQL_FUNCTION"),
                .define("SQLITE_ENABLE_UNLOCK_NOTIFY"),
                .define("SQLITE_MAX_VARIABLE_NUMBER", to: "250000"),
                .define("SQLITE_LIKE_DOESNT_MATCH_BLOBS"),
                .define("SQLITE_OMIT_DEPRECATED"),
                .define("SQLITE_OMIT_SHARED_CACHE"),
                .define("SQLITE_SECURE_DELETE"),
                .define("SQLITE_THREADSAFE", to: "2"),
                .define("SQLITE_USE_URI"),
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("SQLITE_HAS_CODEC"),
                .define("SQLITE_HOMEGROWN_RECURSIVE_MUTEX"), // needed or we see hangs in test cases
                .define("SQLITE_TEMP_STORE", to: "2"),
                .define("SQLITE_EXTRA_INIT", to: "sqlcipher_extra_init"),
                .define("SQLITE_EXTRA_SHUTDOWN", to: "sqlcipher_extra_shutdown"),
                .define("HAVE_GETHOSTUUID", to: "0"),
                .define("HAVE_STDINT_H"),
                .define("SQLCIPHER_CRYPTO_LIBTOMCRYPT"),
                .define("SQLCIPHER_CRYPTO_CUSTOM", to: "sqlcipher_ltc_setup"),
            ],
            linkerSettings: [.linkedLibrary("log", .when(platforms: [.android]))]),
        .testTarget(
            name: "SQLiteDBTests",
            dependencies: ["SQLiteDB"],
            resources: [.process("Resources")],
            swiftSettings: [.define("SQLITE_SWIFT_SQLCIPHER")]
        )
    ]
)
