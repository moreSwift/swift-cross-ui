#!/bin/bash

set -e
cd "$(dirname "$0")"

VERSION=0.62

cd ..

if [ -f ./Tools/ktfmt.jar ];
then
  exit 0
fi

mkdir -p Tools
cd Tools

curl -o ktfmt.jar \
  "https://repo1.maven.org/maven2/com/facebook/ktfmt/${VERSION}/ktfmt-${VERSION}-with-dependencies.jar"
