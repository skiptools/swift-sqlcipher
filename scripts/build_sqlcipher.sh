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
wget ${SQLCIPHER_REPO}/archive/refs/tags/v${SQLCIPHER_VERSION}.tar.gz
tar xvzf v${SQLCIPHER_VERSION}.tar.gz
./sqlcipher-${SQLCIPHER_VERSION}/configure --enable-tempstore=yes --with-crypto-lib=libtomcrypt CFLAGS="-DSQLITE_HAS_CODEC -I/opt/homebrew/include/ -L/opt/homebrew/lib/"
make

cp -v sqlite3.c sqlite3.h ${OLDPWD}/../Sources/SQLCipher/sqlite/

