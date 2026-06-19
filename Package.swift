// swift-tools-version:6.1
import PackageDescription

/// Compile-time options
/// - seealso: [Recommended Compile-time Options](https://sqlite.org/compile.html#recommended_compile_time_options)
let compileTimeOptions: [CSetting] = [
    // https://sqlite.org/compile.html#dqs
    .define("SQLITE_DQS", to: "0", .when(traits: ["DQS_0"])),
    .define("SQLITE_DQS", to: "1", .when(traits: ["DQS_1"])),
    .define("SQLITE_DQS", to: "2", .when(traits: ["DQS_2"])),
    .define("SQLITE_DQS", to: "3", .when(traits: ["DQS_3"])),
    // https://sqlite.org/compile.html#threadsafe
    .define("SQLITE_THREADSAFE", to: "0", .when(traits: ["THREADSAFE_0"])),
    .define("SQLITE_THREADSAFE", to: "1", .when(traits: ["THREADSAFE_1"])),
    .define("SQLITE_THREADSAFE", to: "2", .when(traits: ["THREADSAFE_2"])),
    // https://sqlite.org/compile.html#default_memstatus
    .define("SQLITE_DEFAULT_MEMSTATUS", to: "0", .when(traits: ["DEFAULT_MEMSTATUS_0"])),
    // https://sqlite.org/compile.html#default_wal_synchronous
    .define("SQLITE_DEFAULT_WAL_SYNCHRONOUS", to: "1", .when(traits: ["DEFAULT_WAL_SYNCHRONOUS_1"])),
    // https://sqlite.org/compile.html#like_doesnt_match_blobs
    .define("SQLITE_LIKE_DOESNT_MATCH_BLOBS", .when(traits: ["LIKE_DOESNT_MATCH_BLOBS"])),
    // https://sqlite.org/limits.html#max_expr_depth
    .define("SQLITE_MAX_EXPR_DEPTH", to: "0", .when(traits: ["MAX_EXPR_DEPTH_0"])),
    // https://sqlite.org/compile.html#omit_decltype
    .define("SQLITE_OMIT_DECLTYPE", .when(traits: ["OMIT_DECLTYPE"])),
    // https://sqlite.org/compile.html#omit_deprecated
    .define("SQLITE_OMIT_DEPRECATED", .when(traits: ["OMIT_DEPRECATED"])),
    // https://sqlite.org/compile.html#omit_progress_callback
    .define("SQLITE_OMIT_PROGRESS_CALLBACK", .when(traits: ["OMIT_PROGRESS_CALLBACK"])),
    // https://sqlite.org/compile.html#omit_shared_cache
    .define("SQLITE_OMIT_SHARED_CACHE", .when(traits: ["OMIT_SHARED_CACHE"])),
    // https://sqlite.org/compile.html#use_alloca
    .define("SQLITE_USE_ALLOCA", .when(traits: ["USE_ALLOCA"])),
    // https://sqlite.org/compile.html#omit_autoinit
    .define("SQLITE_OMIT_AUTOINIT", .when(traits: ["OMIT_AUTOINIT"])),
    // https://sqlite.org/compile.html#strict_subtype
    .define("SQLITE_STRICT_SUBTYPE", to: "1", .when(traits: ["STRICT_SUBTYPE_1"])),
]

/// Platform configuration
/// - seealso: [Platform Configuration](https://sqlite.org/compile.html#_platform_configuration)
let platformConfiguration: [CSetting] = [
    .define("HAVE_ISNAN", to: "1"),
    // 'strchrnul' is available on linux since glibc 2.1.1 (1999-05-24)
    .define("HAVE_STRCHRNUL", to: "1", .when(platforms: [.linux])),
    // 'strchrnul' is only available on macOS 15.4, iOS 18.4, tvOS 18.4, watchOS 11.4
    // and there is no way to specify a version in the build settings condition platform
    .define("HAVE_UTIME", to: "1"),
]

/// Features
/// - seealso: [Options To Enable Features Normally Turned Off](https://sqlite.org/compile.html#_options_to_enable_features_normally_turned_off)
let features: [CSetting] = [
    // https://sqlite.org/bytecodevtab.html
    .define("SQLITE_ENABLE_BYTECODE_VTAB", .when(traits: ["ENABLE_BYTECODE_VTAB"])),
    // https://sqlite.org/carray.html
    .define("SQLITE_ENABLE_CARRAY", .when(traits: ["ENABLE_CARRAY"])),
    // https://sqlite.org/c3ref/column_database_name.html
    .define("SQLITE_ENABLE_COLUMN_METADATA", .when(traits: ["ENABLE_COLUMN_METADATA"])),
    // https://sqlite.org/dbpage.html
    .define("SQLITE_ENABLE_DBPAGE_VTAB", .when(traits: ["ENABLE_DBPAGE_VTAB"])),
    // https://sqlite.org/dbstat.html
    .define("SQLITE_ENABLE_DBSTAT_VTAB", .when(traits: ["ENABLE_DBSTAT_VTAB"])),
    // https://sqlite.org/fts3.html
    .define("SQLITE_ENABLE_FTS3", .when(traits: ["ENABLE_FTS3"])),
    .define("SQLITE_ENABLE_FTS3_PARENTHESIS", .when(traits: ["ENABLE_FTS3"])),
    .define("SQLITE_ENABLE_FTS3_TOKENZIER", .when(traits: ["ENABLE_FTS3"])),
    // https://sqlite.org/fts4.html
    .define("SQLITE_ENABLE_FTS4", .when(traits: ["ENABLE_FTS4"])),
    // https://sqlite.org/fts5.html
    .define("SQLITE_ENABLE_FTS5", .when(traits: ["ENABLE_FTS5"])),
    // https://sqlite.org/geopoly.html
    .define("SQLITE_ENABLE_GEOPOLY", .when(traits: ["ENABLE_GEOPOLY"])),
    //.define("SQLITE_ENABLE_ICU", .when(traits: ["ENABLE_ICU"])),
    // https://sqlite.org/lang_mathfunc.html
    .define("SQLITE_ENABLE_MATH_FUNCTIONS", .when(traits: ["ENABLE_MATH_FUNCTIONS"])),
    // https://sqlite.org/c3ref/expanded_sql.html
    .define("SQLITE_ENABLE_NORMALIZE", .when(traits: ["ENABLE_NORMALIZE"])),
    // https://sqlite.org/percentile.html
    .define("SQLITE_ENABLE_PERCENTILE", .when(traits: ["ENABLE_PERCENTILE"])),
    // https://sqlite.org/c3ref/preupdate_blobwrite.html
    .define("SQLITE_ENABLE_PREUPDATE_HOOK", .when(traits: ["ENABLE_PREUPDATE_HOOK"])),
    // https://sqlite.org/rtree.html
    .define("SQLITE_ENABLE_RTREE", .when(traits: ["ENABLE_RTREE"])),
    // https://sqlite.org/sessionintro.html
    .define("SQLITE_ENABLE_SESSION", .when(traits: ["ENABLE_SESSION"])),
    // https://sqlite.org/c3ref/snapshot.html
    .define("SQLITE_ENABLE_SNAPSHOT", .when(traits: ["ENABLE_SNAPSHOT"])),
    // https://sqlite.org/stmt.html
    .define("SQLITE_ENABLE_STMTVTAB", .when(traits: ["ENABLE_STMTVTAB"])),
    // https://sqlite.org/fileformat2.html#stat4tab
    .define("SQLITE_ENABLE_STAT4", .when(traits: ["ENABLE_STAT4"])),
]

let sqlcipherConfiguration: [CSetting] = [
    .headerSearchPath("libtomcrypt/headers"),
    .define("SQLITE_HAS_CODEC"),
    .define("SQLCIPHER_CRYPTO_LIBTOMCRYPT"),
    .define("SQLCIPHER_CRYPTO_CUSTOM", to: "sqlcipher_ltc_setup"),
    .define("SQLITE_EXTRA_INIT", to: "sqlcipher_extra_init"),
    .define("SQLITE_EXTRA_SHUTDOWN", to: "sqlcipher_extra_shutdown"),
    .define("SQLITE_ENABLE_API_ARMOR"),
    .define("SQLITE_ENABLE_MEMORY_MANAGEMENT"),
    .define("SQLITE_ENABLE_UNKNOWN_SQL_FUNCTION"),
    .define("SQLITE_ENABLE_UNLOCK_NOTIFY"),
    .define("SQLITE_MAX_VARIABLE_NUMBER", to: "250000"),
    .define("SQLITE_SECURE_DELETE"),
    .define("SQLITE_USE_URI"),
    .define("SQLITE_HOMEGROWN_RECURSIVE_MUTEX"), // needed or we see hangs in test cases
    .define("SQLITE_TEMP_STORE", to: "2"),
    .define("HAVE_GETHOSTUUID", to: "0"),
    .define("HAVE_STDINT_H"),
]

let package = Package(
    name: "swift-sqlcipher",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .watchOS(.v9),
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
    traits: [
        // Compile-time options
        .trait(
            name: "DQS_0",
            description: "Disallow double-quoted string literals in DDL and DML"
        ),
        .trait(
            name: "DQS_1",
            description: "Disallow double-quoted strings in DDL, allow in DML"
        ),
        .trait(
            name: "DQS_2",
            description: "Allow double-quoted strings in DDL, disallow in DML"
        ),
        .trait(
            name: "DQS_3",
            description: "Allow double-quoted strings in DDL and DML"
        ),
        .trait(
            name: "THREADSAFE_0",
            description: "Omit all mutex and thread-safety logic"
        ),
        .trait(
            name: "THREADSAFE_1",
            description: "The library may be safely used from multiple threads (serialized mode)"
        ),
        .trait(
            name: "THREADSAFE_2",
            description: "The library may be safely used from multiple threads but individual database connections can only be used by a single thread at a time (multi-thread mode)"
        ),
        .trait(
            name: "DEFAULT_MEMSTATUS_0",
            description: "Disable memory allocation statistics by default"
        ),
        .trait(
            name: "DEFAULT_WAL_SYNCHRONOUS_1",
            description: "Use synchronous=NORMAL in WAL mode by default"
        ),
        .trait(
            name: "LIKE_DOESNT_MATCH_BLOBS",
            description: "Don't allow BLOB operands to LIKE and GLOB operators"
        ),
        .trait(
            name: "MAX_EXPR_DEPTH_0",
            description: "Disable all checking of the expression parse-tree depth"
        ),
        .trait(
            name: "OMIT_DECLTYPE",
            description: "Omit the ability to return the declared type of columns"
        ),
        .trait(
            name: "OMIT_DEPRECATED",
            description: "Omit deprecated interfaces and features"
        ),
        .trait(
            name: "OMIT_PROGRESS_CALLBACK",
            description: "Omit progress callback"
        ),
        .trait(
            name: "OMIT_SHARED_CACHE",
            description: "Omit shared cache support"
        ),
        .trait(
            name: "USE_ALLOCA",
            description: "Use alloca to dynamically allocate temporary stack space"
        ),
        .trait(
            name: "OMIT_AUTOINIT",
            description: "Omit automatic library initialization"
        ),
        .trait(
            name: "STRICT_SUBTYPE_1",
            description: "Cause application-defined SQL functions not registered with the SQLITE_RESULT_SUBTYPE property to raise an error when invoking sqlite3_result_subtype"
        ),
        // Features
        .trait(
            name: "ENABLE_BYTECODE_VTAB",
            description: "Enables bytecode and tables_used table-valued functions"
        ),
        .trait(
            name: "ENABLE_CARRAY",
            description: "Enables the carray extension"
        ),
        .trait(
            name: "ENABLE_COLUMN_METADATA",
            description: "Enables column and table metadata functions"
        ),
        .trait(
            name: "ENABLE_DBPAGE_VTAB",
            description: "Enables the sqlite_dbpage virtual table"
        ),
        .trait(
            name: "ENABLE_DBSTAT_VTAB",
            description: "Enables the dbstat virtual table"
        ),
        .trait(
            name: "ENABLE_FTS3",
            description: "Enables version 3 of the full-text search engine (fts3)"
        ),
        .trait(
            name: "ENABLE_FTS4",
            description: "Enables version 4 of the full-text search engine (fts4)"
        ),
        .trait(
            name: "ENABLE_FTS5",
            description: "Enables version 5 of the full-text search engine (fts5)"
        ),
        .trait(
            name: "ENABLE_GEOPOLY",
            description: "Enables the Geopoly extension"
        ),
        .trait(
            name: "ENABLE_MATH_FUNCTIONS",
            description: "Enables the built-in SQL math functions"
        ),
        .trait(
            name: "ENABLE_NORMALIZE",
            description: "Enables the sqlite3_normalized_sql function"
        ),
        .trait(
            name: "ENABLE_PERCENTILE",
            description: "Enables the percentile extension"
        ),
        .trait(
            name: "ENABLE_PREUPDATE_HOOK",
            description: "Enables the pre-update hook"
        ),
        .trait(
            name: "ENABLE_RTREE",
            description: "Enables the R*Tree index extension"
        ),
        .trait(
            name: "ENABLE_SESSION",
            description: "Enables the pre-update hook and session extension",
            enabledTraits: [
                "ENABLE_PREUPDATE_HOOK",
            ]
        ),
        .trait(
            name: "ENABLE_SNAPSHOT",
            description: "Enables support for database snapshots"
        ),
        .trait(
            name: "ENABLE_STMTVTAB",
            description: "Enables the sqlite_stmt virtual table"
        ),
        .trait(
            name: "ENABLE_STAT4",
            description: "Enables the sqlite_stat4 table"
        ),
        // Default traits
        .default(enabledTraits: [
            "DQS_0",
            "ENABLE_COLUMN_METADATA",
            "ENABLE_DBSTAT_VTAB",
            "ENABLE_SESSION",
            "ENABLE_PREUPDATE_HOOK",
            "THREADSAFE_1",
            "DEFAULT_MEMSTATUS_0",
            "DEFAULT_WAL_SYNCHRONOUS_1",
            "LIKE_DOESNT_MATCH_BLOBS",
            "MAX_EXPR_DEPTH_0",
            "OMIT_DEPRECATED",
            "OMIT_PROGRESS_CALLBACK",
            "USE_ALLOCA",
            "STRICT_SUBTYPE_1",
            "ENABLE_CARRAY",
            "ENABLE_FTS3",
            "ENABLE_FTS4",
            "ENABLE_FTS5",
            "ENABLE_MATH_FUNCTIONS",
            "ENABLE_PERCENTILE",
            "ENABLE_RTREE",
            "ENABLE_SNAPSHOT",
            "ENABLE_STMTVTAB",
            "ENABLE_STAT4",
        ]),
    ],
    targets: [
        .target(
            name: "SQLCipher",
            sources: ["sqlite", "libtomcrypt"],
            publicHeadersPath: "sqlite",
            cSettings: compileTimeOptions + platformConfiguration + features + sqlcipherConfiguration,
            linkerSettings: [.linkedLibrary("log", .when(platforms: [.android]))]),
        .testTarget(
            name: "SQLCipherTests",
            dependencies: ["SQLCipher"],
            cSettings: [.define("SQLITE_HAS_CODEC")]
        ),
        .target(
            name: "SQLiteDB",
            dependencies: [.target(name: "SQLCipher")],
            cSettings: [.define("SQLITE_HAS_CODEC")],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault")
            ]
        ),
        .testTarget(
            name: "SQLiteDBTests",
            dependencies: ["SQLiteDB"],
            resources: [.process("Resources")],
            cSettings: [.define("SQLITE_HAS_CODEC")]
        ),
    ]
)
