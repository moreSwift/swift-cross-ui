#!/bin/bash

set -e
cd "$(dirname "$0")"

# This script ensures that a build of DocC is available at ./Tools/docc. By default
# it builds stackotter's fork of DocC which supports WebP image files.

COMMIT=771f704083804760db2dd19692fa2c13a3dd20d0

cd ..

if [ -f ./Tools/docc ];
then
  exit 0
fi

mkdir -p Tools
cd Tools

# Clone and build required commit
git clone https://github.com/stackotter/swift-docc
cd swift-docc
git checkout $COMMIT
swift build -c release --product docc

# Save compiled binary
cp .build/release/docc ..
cd ..

# Clean up
rm -rf swift-docc
