#!/bin/sh -ex
# This script will download the latest SQLCipher and create
# the amalgamated sqlite3.c and sqlite3.h files

SQLCIPHER_REPO="https://github.com/sqlcipher/sqlcipher"

# check https://github.com/sqlcipher/sqlcipher/releases for latest
# SQLCIPHER_VERSION=4.6.1 -> SQLite 3.46.1
#SQLCIPHER_VERSION=4.6.1

# get the latest tag from the SQLCipher repository
SQLCIPHER_VERSION=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' ${SQLCIPHER_REPO} | tail -n 1 | cut -d '/' -f 3 | cut -f 1 -d '^' | cut -f 2 -d 'v')

# might need to first run: brew install libtomcrypt

cd `mktemp -d`
TARBALL=v${SQLCIPHER_VERSION}.tar.gz
wget ${SQLCIPHER_REPO}/archive/refs/tags/${TARBALL}
tar xvzf ${TARBALL}

./sqlcipher-${SQLCIPHER_VERSION}/configure --with-tempstore=yes CFLAGS="-DSQLCIPHER_CRYPTO_LIBTOMCRYPT -DSQLCIPHER_CRYPTO_CUSTOM=sqlcipher_ltc_setup -DSQLITE_HAS_CODEC -DSQLITE_EXTRA_INIT=sqlcipher_extra_init -DSQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown -I/opt/homebrew/include/ -L/opt/homebrew/lib/"
make sqlite3.c

# insert some pragmas that quiesce warnings when building with SwiftPM
mv sqlite3.c sqlite.c.orig

cat << 'EOF' > sqlite3.c
// pragmas added for swift-sqlcipher
#pragma GCC diagnostic push

// added for: Implicit conversion loses integer precision: 'i64' (aka 'long long') to 'int'
#pragma GCC diagnostic ignored "-Wshorten-64-to-32"

// added for: Ambiguous expansion of macro 'MAX'
#pragma GCC diagnostic ignored "-Wambiguous-macro"
EOF

cat sqlite.c.orig >> sqlite3.c

cp -v sqlite3.c sqlite3.h ${OLDPWD}/Sources/SQLCipher/sqlite/

